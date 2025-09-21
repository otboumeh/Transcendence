<?php

require_once '../utils/init.php';

$requiredMethod = $context['requestMethod'];
$queryId = $context['queryId'];

if ($requiredMethod !== 'GET')
    response(405, 'unauthorized');

if (!$queryId)
    globalRankingList($context);
friendsRankingList($context);

function globalRankingList($context) {
    if (!$context['auth'])
        response(403, 'forbidden access');
    
    $database = $context['database'];
    $sqlQuery = "SELECT u.id, u.username, u.elo FROM users u INNER JOIN friends f 
        ON (u.id = f.friend_id OR u.id = f.user_id) WHERE $id IN (f.user_id, f.friend_id)
        AND u.id != $id ORDER BY u.elo DESC";
    $res = $database->query($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    $data = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $data[] = $row;
    echo json_encode($data, JSON_PRETTY_PAINT);
    exit ;
}

function friendsRankingList($context) {
    if (!$context['auth'])
        response(403, 'forbidden access');
    
    $database = $context['database'];
    $sqlQuery = "SELECT id, username, elo FROM users ORDER BY elo DESC";
    $res = $database->query($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    $data = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $data[] = $row;
    echo json_encode($data, JSON_PRETTY_PAINT);
    exit ;
}

?>