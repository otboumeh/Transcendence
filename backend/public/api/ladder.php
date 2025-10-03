<?php

require_once __DIR__ . '/header.php';

$database = connectDatabase();
$requestMethod = $_SERVER['REQUEST_METHOD'];
$queryId = $_GET['id'] ?? null;
$res = null;

if ($requestMethod !== 'GET')
	errorSend(405, 'unauthorized method');

if ($queryId) // selecciona las estadisticas de los amigos del usuario seleccionados
{
	if (!checkJWT($queryId))
		errorSend(403, 'forbidden access'); // u. & r. Son alias de las tablas. Se utilizan para referenciar de forma inequívoca a las columnas cuando se trabaja con más de una tabla en la misma consulta
	$sqlQuery = "SELECT u.user_id, u.username, u.elo, r.games_played, r.games_win, r.games_lose
	FROM users u INNER JOIN ranking r ON u.user_id = r.user_id
	WHERE u.user_id IN (SELECT friend_id FROM friends WHERE user_id = :user_id)"; // INNER JOIN combina filas de dos tablas y prácticamente siempre va acompañado de la cláusula ON para especificar la condición que las une.
	$bind1 = [':user_id', $queryId, SQLITE3_INTEGER];
	$res = doQuery($database, $sqlQuery, $bind1);
}
else // selecciona las estadisticas de todos los usuarios
{
	$sqlQuery = "SELECT u.user_id, u.username, u.elo, r.games_played, r.games_win, r.games_lose INNER JOIN
	ranking r ON u.user_id = r.user_id ORDER BY u.elo DESC";
	$res = doQuery($database, $sqlQuery);
}

if (!$res)
	errorSend(500, 'Sql error: ' . $database->lastErrorMsg());
$data = [];
while ($row = $res->fetchArray(SQLITE3_ASSOC))
	$data[] = $row;
successSend($data, JSON_PRETTY_PRINT);

?>