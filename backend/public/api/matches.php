<?php

require_once '../utils/init.php';

$requiredMethod = $context['requestMethod'];
$queryId = $context['queryId'];

switch  ($requiredMethod) {
    case 'POST':
        updateElo($context);
    case 'GET':
        searchPlayers($context);
    default:
        response(405, 'unauthorized');
}

/* HOLA la idea es tener la funcion searchPlayers() la cual recibe el
numero de jugadores que se buscan (variable para un solo partido
o para un torneo) el formato es player_id: y player_search: x,  */

function searchPlayers($context) {
    if (!$context['auth'])
        response(403, 'forbidden');

    $database = $context['database'];
    $playerId = getAndCheck($context['body'], 'player_id');
    $limit = getAndCheck($context['body'], 'player_search');

    $playerElo = $database->query_single("SELECT elo FROM users WHERE id = '$playerId'");
    if (!$playerElo)
        response(404, 'player not found');
    $sqlQuery = "SELECT id, elo, ABS(elo - '$playerElo') AS diff
    FROM users WHERE id != '$playerId' ORDER BY diff ASC LIMIT '$limit'";
    $res = $database->query($sqlQuery);
    
    $data = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $data[] = $row;
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit ;
}

function updateElo($context) {
    if (!$context['auth'])
        response(403, 'forbidden');

    $database = $context['database'];
    $winnerId = getAndCheck($context['body'], 'winner_id');
    $loserId = getAndCheck($context['body'], 'loser_id');

    $winnerElo = $database->query_single("SELECT elo FROM users WHERE id = '$winnerId'");
    $loserElo = $database->query_single("SELECT elo FROM users WHERE id = '$loserId'");

    $newWinnerElo = operateElo($winnerElo, $loserElo, 1);
    $newLoserElo = operateElo($loserElo, $winnerElo, 0);

    $sqlQuery = "UPDATE users SET elo = '$newWinnerElo' WHERE id = '$winnerId'";
    $winRes = $database->exec($sqlQuery);
    $sqlQuery = "UPDATE users SET elo = '$newLoserElo' WHERE id = '$loserId'";
    $losRes = $database->exec($sqlQuery);
    
    if (!$winRes || !$losRes)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    echo json_encode(['success' => 'elo updated']);
    exit ;
}

?>