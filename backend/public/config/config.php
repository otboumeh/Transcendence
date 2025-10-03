<?php

function connectDatabase (): ?SQLite3 
{
    $databasePath = __DIR__ . '/../../database/database.sqlite';
    $tablesPath = __DIR__ . '/schema.sql';
    try
	{
        $database = new SQLite3($databasePath);
        $tableSchema = file_get_contents($tablesPath);
        if (!$tableSchema)
            throw new Exception("unable to read $tablesPath");
        $database->exec($tableSchema);
    }
	catch (Exception $exc)
	{
        http_response_code(500);
        echo json_encode(["error" => $exc->getMessage()]);
        return (null);
    }
    return ($database);
}

?>