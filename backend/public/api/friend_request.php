<?php

require_once __DIR__ . '/header.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];
$body = json_decode(file_get_contents('php://input'), true);
$queryId = $_GET['id'] ?? null;

switch ($requestMethod) 
{
	case 'POST':
		if (!checkBodyData($body, 'sender_id'))
			errorSend(400, 'bad request');
		$sender_id = $body['sender_id'];
		if (!checkJWT($sender_id))
			errorSend(403, 'forbidden access');
		sendFriendRequest($body, $database, $sender_id);
		break;
	case 'GET':
		if (!checkJWT($queryId))
			errorSend(403, 'forbidden access');
		requestListId($queryId, $database);
		break;
	case 'PATCH':
		if (!checkBodyData($body, 'receiver_id'))
			errorSend(400, 'bad request');
		$receiver_id = $body['receiver_id'];
		if (!checkJWT($receiver_id))
			errorSend(403, 'forbidden access');
		acceptDeclineRequest($body, $database, $receiver_id);
		break;
	default:
		errorSend(405, 'unauthorized method');
}

function sendFriendRequest(array $body, SQLite3 $database, int $sender_id): void 
{
	if (!checkBodyData($body, 'receiver_id'))
		errorSend(400, 'bad request');
	$receiver_id = $body['receiver_id'];

	$sqlQuery = "INSERT INTO friend_request (sender_id, receiver_id) VALUES (:sender_id, :receiver_id)";
	$bind1 = [':sender_id', $sender_id, SQLITE3_INTEGER];
	$bind2 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQuery, $bind1, $bind2);
	if (!$res)
		errorSend(500, "Sql error: " . $database->lastErrorMsg());
	else
		successSend('friend request sent');
}

function requestListId(int $queryId, SQLite3 $database): void
{
	$sqlQuery = "SELECT sender_id, created_at FROM friend_request WHERE receiver_id = :receiver_id";
	$bind1 = [':receiver_id', $queryId, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQuery, $bind1);
	if (!$res)
		errorSend(500, "Sql error: " . $database->lastErrorMsg());
	$content = [];
	while ($row = $res->fetchArray(SQLITE3_ASSOC))
		$content[] = $row;
	successSend($content, JSON_PRETTY_PRINT);
}

function acceptDeclineRequest(array $body, SQLite3 $database, int $receiver_id): void
{
	if (!checkBodyData($body, 'sender_id', 'receiver_id', 'action'))
		errorSend(400, 'bad request');
	$sender_id = $body['sender_id'];
	$action = $body['action'];

	$sqlQuery = "SELECT * FROM friend_request WHERE sender_id = :sender_id AND receiver_id = :receiver_id";
	$bind1 = [':sender_id', $sender_id, SQLITE3_INTEGER];
	$bind2 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQuery, $bind1, $bind2);
	if (!$res)
		errorSend(500, 'Sql error: ' . $database->lastErrorMsg());
	if (!$res->fetchArray(SQLITE3_ASSOC))
		errorSend(404, 'user not found');
		
	if ($action === 'accept')
		accept($database, $sender_id, $receiver_id);
	else if ($action === 'decline')
		decline($database, $sender_id, $receiver_id);
}

function accept(SQLite3 $database, int $sender_id, int $receiver_id): void
{
	$database->exec('BEGIN');
	try
	{
		$success = true;
		$sqlQuery00 = "INSERT INTO friends (user_id, friend_id) VALUES (:sender_id, :receiver_id)";
		$bind01 = [':sender_id', $sender_id, SQLITE3_INTEGER];
		$bind02 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
		$res00 = doQuery($database, $sqlQuery00, $bind01, $bind02);

		$sqlQuery01 = "INSERT INTO friends (user_id, friend_id) VALUES (:receiver_id, :sender_id)";
		$bind12 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
		$bind11 = [':sender_id', $sender_id, SQLITE3_INTEGER];
		$res01 = doQuery($database, $sqlQuery01, $bind11, $bind12);

		$sqlQuery02 = "DELETE FROM friend_request WHERE sender_id = :sender_id AND receiver_id = :receiver_id";
		$bind21 = [':sender_id', $sender_id, SQLITE3_INTEGER];
		$bind22 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
		$res02 = doQuery($database, $sqlQuery02, $bind21, $bind22);

		if (!$res00 || !$res01 || !$res02)
			$success = false;
		if ($success)
		{
			$database->exec('COMMIT');
			successSend('friend request accepted');
		}
		else
			throw new Exception ('friend accept operation failed');
	}
	catch (Exception $e)
	{
		$database->exec('ROLLBACK');
		errorSend(500, 'couldn\'t accept friend: ' . $database->lastErrorMsg());
	}
}

function decline(SQLite3 $database, int $sender_id, int $receiver_id): void
{
	$sqlQuery = "DELETE FROM friend_request WHERE sender_id = :sender_id AND receiver_id = :receiver_id";
	$bind1 = [':sender_id', $sender_id, SQLITE3_INTEGER];
	$bind2 = [':receiver_id', $receiver_id, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQuery, $bind1, $bind2);
	if (!$res)
		errorSend(500, 'Sql error: ' . $database->lastErrorMsg());
	successSend('friend request declined');
}

?>
