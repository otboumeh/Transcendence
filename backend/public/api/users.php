<?php

header("Access-Control-Allow-Origin: http://localhost:3000");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PATCH, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once __DIR__ . '/header.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];
$body = json_decode(file_get_contents('php://input'), true);
$queryId = $_GET['id'] ?? null;

switch ($requestMethod)
{
    case 'POST':
        createUser($body, $database);
        break;
    case 'GET':
        if ($queryId)
            userDataById($database, $queryId);
        else
            userList($database);
        break;
    case 'PATCH':
        if (!checkJWT($queryId))
            errorSend(403, 'forbidden access');
        editUserData($queryId, $body, $database);
        break;
    case 'DELETE':
        if (!checkJWT($queryId))
            errorSend(403, 'forbidden access');
        deleteUser($queryId, $database);
        break;
    default:
        errorSend(405, 'unauthorized method');
}

function createUser(array $body, SQLite3 $database): void
{
    if (!checkBodyData($body, 'username', 'email', 'pass'))
        errorSend(400, 'bad request');

    $username = $body['username'];
    $email = $body['email'];
    $pass = $body['pass'];

    $passHash = password_hash($pass, PASSWORD_DEFAULT);

    $sqlQuery = "INSERT INTO users (username, email, pass) VALUES (:username, :email, :pass)";
    $bind1 = [':username', $username, SQLITE3_TEXT];
    $bind2 = [':email', $email, SQLITE3_TEXT];
    $bind3 = [':pass', $passHash, SQLITE3_TEXT];

    $res = doQuery($database, $sqlQuery, $bind1, $bind2, $bind3);
    if (!$res)
        errorSend(500, 'Sql error: ' . $database->lastErrorMsg());
    else
        successSend('Created', 201, 'new UserID: ' . $database->lastInsertRowID());
}

function userDataById(SQLite3 $database, int $queryId): void
{
    $sqlQuery = "SELECT username, email, elo FROM users WHERE user_id = :queryId";
    $bind1 = [':queryId', $queryId, SQLITE3_INTEGER];
    $res = doQuery($database, $sqlQuery, $bind1);

    if (!$res)
        errorSend(500, 'Sql error: ' . $database->lastErrorMsg());

    $userData = $res->fetchArray(SQLITE3_ASSOC);
    if (!$userData)
        errorSend(404, 'user not found');
    else
        successSend($userData);
}

function userList(SQLite3 $database): void
{
    $res = doQuery($database, "SELECT user_id, username, elo FROM users");
    if (!$res)
        errorSend(500, 'Sql error: ' . $database->lastErrorMsg());

    $data = [];
    while ($row = $res->fetchArray(SQLITE3_ASSOC))
        $data[] = $row;

    successSend($data);
}

function editUserData(int $queryId, array $body, SQLite3 $database): void
{
    $database->exec('BEGIN');
    try
    {
        $success = true;

        if (checkBodyData($body, 'pass'))
        {
            $newPass = $body['pass'];
            $newPassHash = password_hash($newPass, PASSWORD_DEFAULT);
            if (!editUserDataAux($queryId, 'pass', $newPassHash, $database))
                $success = false;
        }

        if (checkBodyData($body, 'username'))
            if (!editUserDataAux($queryId, 'username', $body['username'], $database))
                $success = false;

        if (checkBodyData($body, 'email'))
            if (!editUserDataAux($queryId, 'email', $body['email'], $database))
                $success = false;

        if ($success)
        {
            $database->exec('COMMIT');
            successSend('user data modified');
        }
        else
            throw new Exception('One of the update operations failed');
    }
    catch (Exception $e)
    {
        $database->exec('ROLLBACK');
        errorSend(500, 'Could not update user data', $e->getMessage());
    }
}

function editUserDataAux(int $queryId, string $column, string $newValue, SQLite3 $database): bool
{
    switch ($column)
    {
        case 'pass':
            $sqlQuery = "UPDATE users SET pass = :newValue WHERE user_id = :queryId";
            break;
        case 'username':
            $sqlQuery = "UPDATE users SET username = :newValue WHERE user_id = :queryId";
            break;
        case 'email':
            $sqlQuery = "UPDATE users SET email = :newValue WHERE user_id = :queryId";
            break;
        default:
            return false;
    }

    $bind1 = [':newValue', $newValue, SQLITE3_TEXT];
    $bind2 = [':queryId', $queryId, SQLITE3_INTEGER];
    $res = doQuery($database, $sqlQuery, $bind1, $bind2);

    return $res !== false;
}

function deleteUser(int $queryId, SQLite3 $database)
{
    $sqlQuery = "DELETE FROM users WHERE user_id = :queryId";
    $bind1 = [':queryId', $queryId, SQLITE3_INTEGER];
    $res = doQuery($database, $sqlQuery, $bind1);

    if (!$res)
        errorSend(500, 'Sql error: ' . $database->lastErrorMsg());
    else
        successSend('user deleted');
}
