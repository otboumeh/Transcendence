<?php

require_once __DIR__ . '/header.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];

if ($requestMethod != 'POST')
	errorSend(405, 'Method Not Allowed');

successSend('Logged out successfully'); // El logout es una acción que debe realizar el frontend // Debe eliminar el JWT que tiene almacenado
exit;

?>
