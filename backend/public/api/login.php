<?php
require_once __DIR__ . '/header.php';
require_once __DIR__ . '/gmail_api/mail_gmail.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];

if ($requestMethod !== 'POST')
    errorSend(405, 'unauthorized method');

$body = json_decode(file_get_contents('php://input'), true);
if (!is_array($body))
    errorSend(400, 'invalid json');

if (!checkBodyData($body, 'username', 'pass'))
    errorSend(400, 'Bad request. Missing fields');

$username = $body['username'];
$passwordSent = $body['pass'];

// Ajuste: usar 'id' en el SELECT
$sqlQuery = "SELECT id, pass, email FROM users WHERE username = :username";
$bind1 = [':username', $username, SQLITE3_TEXT];
$res1 = doQuery($database, $sqlQuery, $bind1);

if (!$res1)
    errorSend(500, "SQLite Error: " . $database->lastErrorMsg());

$row = $res1->fetchArray(SQLITE3_ASSOC);
if (!$row)
    errorSend(401, 'Invalid username or password');

$user_id = $row['id'];          // <-- cambio aquí de 'user_id' a 'id'
$passwordStored = $row['pass'];
$email = $row['email'];

if (!password_verify($passwordSent, $passwordStored))
    errorSend(401, 'Invalid username or password');

// Limpiamos códigos 2FA previos
$stmt_delete = $database->prepare('DELETE FROM twofa_codes WHERE user_id = :user_id');
$stmt_delete->bindValue(':user_id', $user_id, SQLITE3_INTEGER);
if (!$res_delete = $stmt_delete->execute())
    errorSend(500, "SQLite Error: " . $database->lastErrorMsg());

// Generamos nuevo código 2FA
$two_fa_code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

$stmt_insert = $database->prepare('INSERT OR REPLACE INTO twofa_codes (user_id, code) VALUES (:user_id, :code)');
$stmt_insert->bindValue(':user_id', $user_id, SQLITE3_INTEGER);
$stmt_insert->bindValue(':code', $two_fa_code, SQLITE3_TEXT);
if ($stmt_insert->execute() === false)
    errorSend(500, 'couldn`t insert two_fa_code');

// Enviamos el código por email
if (!sendMailGmailAPI($user_id, $email, $two_fa_code))
    errorSend(500, 'couldn\'t send mail with Gmail API');

// Respuesta JSON
echo json_encode(['pending_2fa' => true, 'user_id' => $user_id]);
exit;
?>
