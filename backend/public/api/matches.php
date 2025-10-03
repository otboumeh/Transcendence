<?php

require_once __DIR__ . '/header.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];
$body = json_decode(file_get_contents('php://input'), true);
$queryId = $_GET['id'] ?? null;

switch ($requestMethod)
{
	case 'POST':
		if (!checkBodyData($body, 'win_id', 'loser_id'))
			errorSend(400, 'bad request');
		$winner_id = $body['winner_id'];
		$loser_id = $body['loser_id'];
		if (!(checkJWT($winner_id) || checkJWT($loser_id)))
			errorSend(403, 'forbidden access');
		updateElo($database, $winner_id, $loser_id);
		break;
	case 'GET':
		if (!checkJWT($queryId))
			errorSend(403, 'forbidden access');
		findMatch($database, $queryId);
		break;
	default:
		errorSend(405, 'unauthorized method');
}

function updateElo(SQLite3 $database, int $win_id, int $ls_id): void
{
	$winElo = getElo($database, $win_id);									
	$lsElo = getElo($database, $ls_id);

	$newWinElo = operateElo($winElo, $lsElo, true);
	$newLsElo = operateElo($lsElo, $winElo, false);

	$database->exec('BEGIN');
	try
	{
		updateEloAux($database, $win_id, $newWinElo, true);
		updateEloAux($database, $ls_id, $newLsElo, false);
		$database->exec('COMMIT');
		successSend('elo updated');
	}
	catch (Exception $e)
	{
		$database->exec('ROLLBACK');
		errorSend(500, 'couldn\'t update elo', $e->getMessage());
	}
}

function getElo(SQLite3 $database, int $user_id): int
{
	$sqlQ = "SELECT user_id, elo FROM users WHERE user_id = :user_id";
	$bind1 = [':user_id', $user_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQ, $bind1);
	if (!$res)
		errorSend(500, 'SQL error ' . $database->lastErrorMsg());
	$row = $res->fetchArray(SQLITE3_ASSOC);
	if (!$row)
		errorSend(400, 'couldn\'t find user elo');
	return $row['elo'];
}

function operateElo(int $oldElo, int $oppElo, bool $win) 
{
	$k = 32;
	$expected = 1 / (1 + pow(10, ($oppElo - $oldElo) / 400));
	$newElo = $oldElo + $k * ($win - $expected);
	return round($newElo);
}

function updateEloAux(SQLite3 $database, int $user_id, int $newElo, bool $win): void
{
	$sqlQ = "UPDATE users SET elo = :newElo WHERE user_id = :user_id";
	$bind1 = [':newElo', $newElo, SQLITE3_INTEGER];
	$bind2 = [':user_id', $user_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQ, $bind1, $bind2);
	if (!$res)
		throw new Exception ('SQL error ' . $database->lastErrorMsg());

	$sqlQ = "SELECT games_played, games_win, games_lose FROM ranking WHERE user_id = :user_id";
	$bind1 = [':user_id', $user_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQ, $bind1);
	if (!$res)
		throw new Exception ('SQL error ' . $database->lastErrorMsg());
	$row = $res->fetchArray(SQLITE3_ASSOC);
	if (!$row)
		throw new Exception ('Couldn\'t find ranked data');

	$bind1 = [':games_played', $row['games_played'] + 1, SQLITE3_INTEGER];
	$columnToUpdate = $win ? 'games_win' : 'games_lose';
	$newValue = $row[$columnToUpdate] + 1;
	$bind2 = [':newValue', $newValue, SQLITE3_INTEGER];
	$bind3 = [':user_id', $user_id, SQLITE3_INTEGER];
	$sqlQ = "UPDATE ranking SET games_played = :games_played, $columnToUpdate = :newValue WHERE user_id = :user_id";
	$res = doQuery($database, $sqlQ, $bind1, $bind2, $bind3);
	if (!$res)
		throw new Exception ('SQL error ' . $database->lastErrorMsg());
}

function findMatch(SQLite3 $database, int $queryId)
{
	$sqlQ = "SELECT user_id, elo, username FROM users WHERE user_id = :user_id";
	$bind = [':user_id', $queryId, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQ, $bind);
	if (!$res)
		errorSend(500, 'SQL error -> ' . $database->lastErrorMsg());
	$row = $res->fetchArray(SQLITE3_ASSOC);
	if (!$row)
		errorSend(404, 'Player not found');
	$currentElo = $row['elo'];

	$sqlQ = "SELECT user_id, elo, ABS(elo - :currentElo) AS elo_diff FROM users
	WHERE user_id != :user_id ORDER BY elo_diff ASC LIMIT 1";
	$bind1 = [':currentElo', $currentElo, SQLITE3_INTEGER]; 
	$bind2 = [':user_id', $queryId, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQ, $bind1, $bind2);
	if (!$res)
		errorSend(500, 'SQL error -> ' . $database->lastErrorMsg());
	$nextRival = $res->fetchArray();
	if (!$nextRival)
		errorSend(404, 'no rival found');
	else
		successSend('rival found', 200, "user_id -> $nextRival");
}

?>
