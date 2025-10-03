<?php
// ============================================
// HEADER.PHP - Common functions + CORS setup
// ============================================

// Respuesta en JSON
header('Content-Type: application/json');

// --------------------------------------------
// CORS setup
// --------------------------------------------
$frontend_origin = "http://localhost:3000"; // Cambia si tu frontend usa otro puerto
header("Access-Control-Allow-Origin: $frontend_origin");
header("Access-Control-Allow-Methods: GET, POST, DELETE, PATCH, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Responder al preflight (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// --------------------------------------------
// Mostrar errores (solo desarrollo)
// --------------------------------------------
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// --------------------------------------------
// Cargar configuraciones y dependencias
// --------------------------------------------
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../../vendor/autoload.php';

// --------------------------------------------
// Funciones auxiliares
// --------------------------------------------

function successSend(string|array $msg, int $code = 200, ?string $detailsMsg = null): void
{
    http_response_code($code);
    $response = ['success' => $msg];
    if ($detailsMsg) $response['details'] = $detailsMsg;
    echo json_encode($response);
    exit;
}

function errorSend(int $code, string $msg, ?string $detailsMsg = null): void
{
    http_response_code($code);
    $response = ['error' => $msg];
    if ($detailsMsg) $response['details'] = $detailsMsg;
    echo json_encode($response);
    exit;
}

function checkBodyData(array $body, string ...$keys): bool
{
    foreach ($keys as $key) {
        if (!isset($body[$key]) || !$body[$key]) return false;
        if (stripos($key, '_id') !== false && !is_numeric($body[$key])) return false;
        if (stripos($key, 'email') !== false && !filter_var($body[$key], FILTER_VALIDATE_EMAIL)) return false;
    }
    return true;
}

function doQuery(SQLite3 $database, string $sqlQuery, array ...$bindings): SQLite3Result|bool
{
    $stmt = $database->prepare($sqlQuery);
    if ($stmt === false) return false;
    foreach ($bindings as $bind) $stmt->bindValue(...$bind);
    return ($stmt->execute());
}

function checkJWT(int $id): bool
{
    $JWT = $_SERVER['HTTP_AUTHORIZATION'] ?? null;
    if (!$JWT) return false;
    $decodedJWT = getDecodedJWT($JWT);
    if (!$decodedJWT) return false;
    $idJWT = $decodedJWT->data->userId ?? null;
    if ($id !== $idJWT) return false;
    return true;
}

function getDecodedJWT(string $JWT): ?object
{
    list($jwt) = sscanf($JWT, 'Bearer %s');
    if (!$jwt) return null;
    $secretKey = getenv('JWTsecretKey');
    if ($secretKey === false) errorSend(500, "FATAL: JWT_SECRET_KEY no está configurada en el entorno.");
    try {
        $decodedToken = Firebase\JWT\JWT::decode($jwt, new Firebase\JWT\Key($secretKey, 'HS256'));
        return $decodedToken;
    } catch (Exception $e) {
        error_log("Couldn't decode JWT -> " . $e->getMessage());
        return null;
    }
}
?>
