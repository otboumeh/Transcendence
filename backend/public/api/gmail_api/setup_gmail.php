<?php

require_once(__DIR__ . '/../../../vendor/autoload.php'); // Carga el autoloader de Composer => para que encuentre la clase Google\Client

$credentialsPath = __DIR__ . '/../../../secrets/google_oauth_client.json'; // Ruta al archivo de credenciales descargado de Google Cloud
$tokenPath = __DIR__ . '/../../../secrets/google_token.json'; // Ruta donde se guardará el token de acceso/refresco

if (!file_exists($credentialsPath))
	throw new Exception('No se encuentra el archivo de credenciales. Descárgalo de Google Cloud y guárdalo en: ' . $credentialsPath);

$client = new Google\Client();
$client->setApplicationName('Transcendence 2FA Setup');
$client->setScopes(['https://www.googleapis.com/auth/gmail.send']);
$client->setAuthConfig($credentialsPath);
$client->setAccessType('offline'); // Solicita un refresh_token
$client->setPrompt('select_account consent');

$authUrl = $client->createAuthUrl();
echo "Abre esta URL en tu navegador para autorizar la aplicación:\n\n";
echo $authUrl . "\n\n";

echo "Pega el código de autorización (en el URL entre code= y &scope) aquí y presiona Enter: ";
$authCode = trim(fgets(STDIN));

$accessToken = $client->fetchAccessTokenWithAuthCode($authCode);
if (array_key_exists('error', $accessToken))
	throw new Exception("Error al obtener el token: " . join(', ', $accessToken));

file_put_contents($tokenPath, json_encode($accessToken, JSON_PRETTY_PRINT));

printf("¡Éxito! El token ha sido guardado en: %s\n", $tokenPath);
printf("Ahora tu aplicación puede enviar correos.\n");
