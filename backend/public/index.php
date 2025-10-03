<?php

// este archivo es solo para hacer pruebas con los HTMLs del backend, una vez unamos el front con el back podemos eliminarlo
require_once 'config/config.php';

$db = connectDatabase();

if ($db)
    echo json_encode(['status' => '1', 'database is ready!']);

?>