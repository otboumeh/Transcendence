<?php
// Desactiva los warnings para una salida JSON limpia
error_reporting(0);

// Establece la cabecera para indicar que la respuesta es JSON
header('Content-Type: application/json');

// Crea un array con los datos de la respuesta
$response = [
    'status' => 'success',
    'message' => 'El backend de PHP ha respondido correctamente!',
    'headers_received' => [
        'host' => $_SERVER['HTTP_HOST'] ?? 'no_recibido',
        'client_ip' => $_SERVER['HTTP_X_REAL_IP'] ?? 'no_recibido',
        'forwarded_for' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? 'no_recibido',
        'protocol' => $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'no_recibido'
    ]
];

// Imprime el array codificado en formato JSON
echo json_encode($response, JSON_PRETTY_PRINT);