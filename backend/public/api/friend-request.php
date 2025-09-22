<?php

require_once '../utils/init.php';

$requestMethod = $context['requestMethod'];
$queryId = $context['queryId'];

switch ($requestMethod) {
    case 'POST':
        sendFriendRequest($context);
    case 'GET':
        requestListId($context);
    case 'PATCH':
        acceptDeclineRequest($context);
    default:
        response(405, 'unauthorized method');
}

function sendFriendRequest($context) {
    if (!$context['auth'])
        response(403, 'forbidden access');

    $database = $context['database'];
    $senderId = getAndCheck($context['body'], 'sender_id');
    $receiverId = getAndCheck($context['body'], 'receiver_id');
    if (!checkIfExist($receiverId, $database) || !checkIfExist($senderId, $database))
        response(404, 'sender/receiver id not found');

    $sqlQuery = "INSERT INTO friend_request (sender_id, receiver_id, status) VALUES ('$senderId', '$receiverId', 'pending')";
    $res = $database->exec($sqlQuery);
    if (!$res)
        response(500, "Sql error: " . $database->lastErrorMsg());

    echo json_encode(['success' => 'friend request sent']);
    exit ;
}

function requestListId($context) {
    if (!$context['auth'] || $context['queryId'] !== $context['tokenId'])
        response(403, 'forbidden access');

    $database = $context['database'];
    $id = $context['tokenId'];
    $sqlQuery = "SELECT sender_id FROM friend_request WHERE receiver_id = '$id' AND status = 'pending'";
    $res = $database->query($sqlQuery);

    if (!$res)
        response(500, "Sql error: " . $database->lastErrorMsg());
    $content = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $content[] = $row;

    echo json_encode($content, JSON_PRETTY_PAINT);
    exit ;
}

function acceptDeclineRequest($context) {
    if (!$context['auth'])
        response(403, 'forbidden access');

    $database = $context['database'];
    $senderId = getAndCheck($context['body'], 'sender_id');
    $receiverId = getAndCheck($context['body'], 'receiver_id');
    $action = getAndCheck($context['body'], 'action');

    if (!checkIfExist($receiverId, $database) || !checkIfExist($senderId, $database))
        response(404, 'sender/receiver id not found');

    $checkRequest = "SELECT * FROM friend_request WHERE sender_id = '$senderId' AND receiver_id = '$receiverId'";
    $res = $database->query($checkRequest);
    if (!$res->fetchArray(SQLITE3_ASSOC))
        response(404, 'friend request not found');
    
    if ($action === 'accept')
        accept($database, $senderId, $receiverId);
    else if ($action === 'decline')
        decline($database, $senderId, $receiverId);
    response(400, 'bad request in action');
}

function accept($database, $senderId, $receiverId) {
    $sqlQuery00 = "INSERT INTO friends (user_id, friend_id) VALUES ('$senderId', '$receiverId')";
    $sqlQuery01 = "INSERT INTO friends (user_id, friend_id) VALUES ('$receiverId', '$senderId')";
    $res00 = $database->exec($sqlQuery00);
    $res01 = $database->exec($sqlQuery01);
    if (!$res00 || !$res01)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    echo json_encode(['success' => 'new friend added']);
    exit ;
}

function decline($database, $senderId, $receiverId) {
    $sqlQuery = "DELETE FROM friend_request WHERE sender_id = '$senderId' AND receiver_id = '$receiverId'";
    $res = $database->exec($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    echo json_encode(['success' => 'friend request declined']);
    exit ;
}

?>