<?php

function response($status, $data) {
    if (status == 200) {
        json_encode(['success' => $data]);
    } else {
        http_response_code($status);
        json_encode(['error' => $data]);
    }
    exit ;
}

function isId($num) {
    if (is_numeric($num))
        return ($num);
    response (400, 'bad request');
    return null ;
}

function getAndCheck($body, $content) {
    $data = $body[$content];
    if (!$data)
        response(400, 'bad request');
    if (!checkSqlInjection($data))
        response(403, 'FORBIDDEN');
    return ($data);
}

function checkSqlInjection($string) {
    $blacklist = [
        'select', 'insert', 'update', 'drop', 'truncate',
        'union', 'or', 'and', '--', ';', '/*', '*/', '@@', '@',
        'char', 'nchar', 'varchar', 'nvarchar', 'exec', 'xp_'
    ];
    $lowerStr = strtolower($string);
    foreach ($blacklist as $word) {
        if (strpos($lowerStr, $word))
            return (false);
    }
    return (true);
}

function checkIfExists($id, $database) {
    $num = isId($id);
    $sqlQuery = "SELECT 1 FROM users WHERE id = '$num' LIMIT 1";
    $res = $database->query($sqlQuery);
    if (!$res)
        return false;
    return true;
}

function operateElo($oldElo, $oppElo, $score) {
    $k = 32;
    $expected = 1 / (1 + pow(10, ($oppElo - $oldElo) / 400));
    $newElo = $oldElo + $k * ($score - $expected);
    return (round($newElo));
}

function checkAuthorization($token) {
    // comprobar si el token es valido en caso de que si devolver true
    // en caso de que no devolver false xD
    return (true);
}

function extractIdFromAuth($token, $auth) {
    if (!$auth)
        return (0);
    // extraer el Id del token, en caso de no ser valido retornara 0
    return (1);
}

?>