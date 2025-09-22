<?php

require_once '../utils/init.php';

// var_dump($context);
$requestMethod = $context['requestMethod'];
$queryId = $context['queryId'];

switch ($requestMethod) {
    case 'POST':
        createUser($context); // no pide auth
    case 'GET':
        if ($queryId) {
            userDataById($context); // no pide auth
        }
        else {
            userList($context); // no pide auth
        }
    case 'PATCH':
        editUserData($context); // pide auth
    case 'DELETE':
        deleteUser($context); // pide auth
    default:
        response(405, 'unauthorized method');
}

function userList($context) {
    $database = $context['database'];

    $sqlQuery = "SELECT id, username, elo FROM users";
    $res = $database->query($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());

    $data = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $data[] = $row;

    echo json_encode($data);
    exit ;
}

function userDataById($context) {
    $database = $context['database'];
    $queryId = isId($context['queryId']);

    $sqlQuery = "SELECT username, email, elo FROM users WHERE id = '$queryId'";
    $res = $database->query($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    if (!($res->fetchArray(SQLITE3_ASSOC)))
        response(404, 'user not found');

    echo json_encode($res->fetchArray(SQLITE3_ASSOC));
    exit ;
}

function createUser($context) {
    $database = $context['database'];
    $body = $context['body'];
    
    $username = getAndCheck($body, 'username');
    $email = getAndCheck($body, 'email');
    //var_dump($email);
    $pass = getAndCheck($body, 'password');
    $passwordHash = password_hash($pass, PASSWORD_DEFAULT);
    $sqlQuery = "INSERT INTO users (username, email, pass) VALUES ('$username', '$email', '$passwordHash')";
    $res = $database->exec($sqlQuery);
    if (!$res) {
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    }

    echo json_encode(['success' => 'new user created']);
    exit ;
}

function editUserData($context) {
    $id = $context['tokenId'];
    if ($id !== $context['queryId'])
        response(403, 'forbidden access');
    $body = $context['body'];
    $database = $context['database'];

    if ($context['body']['password'])
        editUserPass($id, $body, $database);

    $username = getAndCheck($body, 'username');
    $email = getAndCheck($body, 'email');

    $updates = [ "username = '$username'", "email = '$email'" ];
    $sqlQuery = "UPDATE users SET" . implode(', ', $updates) . "WHERE id = '$id'";
    $res = $database->exec($sqlQuery);
    if (!res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());

    echo json_encode(['success' => 'user data modified']);
    exit ;
}

function editUserPass($id, $body, $database) {
    $newPassword = getAndCheck($body, 'password');
    $newPasswordHash = password_hash($newPassword, PASSWORD_DEFAULT);

    $sqlQuery = "UPDATE users SET pass = '$newPasswordHash' WHERE id = '$id'";
    $res = $database->exec($sqlQuery);
    if (!res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());

    echo json_encode(['success' => 'password updated']);
    exit ;
}

function deleteUser($context) {
    if ($context['tokenId'] !== $context['queryId'])
        response(403, 'forbidden access');
    $database = $context['database'];

    $sqlQuery = "DELETE FROM users WHERE id = :id";
    $res = $database->exec($sqlQuery);
    if (!$res)
        response(500, 'Sql error: ' . $database->lastErrorMsg());
    
    echo json_encode(['success' => 'user deleted']);
    exit ;
}

?>