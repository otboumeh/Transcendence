<?php

require_once 'config/config.php';

$db = connectDatabase();

if ($db)
    echo json_encode(['status' => '1', 'database is ready!']);

?>