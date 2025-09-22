<?php

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: GET, POST, DELETE, PATCH');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require 'utils.php';
require '../config/config.php';
$database = connectDatabase();
$authToken = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
$requestMethod = $_SERVER['REQUEST_METHOD'];
$auth = checkAuthorization($authToken);
$idFromAuth = extractIdFromAuth($authToken, $auth);
$bodyArray = json_decode(file_get_contents('php://input'), true);
$queryId = $_GET['id'] ?? null;

$context = [
    'database' => $database,
    'requestMethod' => $requestMethod,
    'auth' => $auth,
    'tokenId' => $idFromAuth,
    'queryId' => $queryId,
    'body' => $bodyArray
];

?>