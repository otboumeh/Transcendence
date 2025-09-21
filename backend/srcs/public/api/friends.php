<?php

require_once '../utils/init.php';

$requestMethod = $context['requestMethod'];
$queryId = $context['queryId'];

switch ($requestMethod) {
    case 'GET':
        getFriendList($context);
    case 'DELETE':
        deleteFriend($context);
    default:
        response(405, 'unauthorized method');
}

function getFriendList($context) {
    if (!$context['auth'] || $context['queryId'] !== $context['tokenId'])
        response(403, 'forbidden access');

    $database = $context['database'];
    $id = $context['tokenId'];

    $sqlQuery = "SELECT u.id, u.username, u.email FROM users u WHERE u.id IN
    ( SELECT friend_id FROM friends WHERE user_id = '$id' UNION SELECT user_id
    FROM friends WHERE friend_id = '$id')";
    $res = $database->query($sqlQuery);
    if (!$res)
        response(500, "Sql error: " . $database->lastErrorMsg());

    $content = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $content[] = $row;
    echo json_encode($content, JSON_PRETTY_PAINT);
    exit ;
}

function deleteFriend($context) {
    if (!$content['auth'])
        response(403, 'forbidden access');

    $database = $content['database'];
    $userId = getAndCheck($content['body'], 'user_id');
    $friendId = getAndCheck($content['body'], 'friend_id');

    $sqlQuery = "DELETE FROM friends WHERE user_id = '$userId' AND friend_id = '$friendId' OR
    user_id = '$friendId' AND friend_id = '$userId'";
    $res = $database->exec($sqlQuery);
    if ($database->changes() === 0)
        response(404, 'friend not found');

    echo json_encode(['success' => 'friend deleted']);
    exit ;
}

?>