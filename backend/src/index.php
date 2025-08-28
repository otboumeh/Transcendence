<?php
require __DIR__.'/utils/DB.php';
header('Content-Type: application/json');
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

if ($path === '/api/healthz') { echo '{"ok":true}'; exit; }

if ($path === '/api/game/score' && $method==='POST') {
  $in = json_decode(file_get_contents('php://input'), true) ?? [];
  $score = (int)($in['score'] ?? 0);
  $pdo = DB::conn();
  $pdo->exec("CREATE TABLE IF NOT EXISTS scores(id INTEGER PRIMARY KEY AUTOINCREMENT, val INTEGER, ts TEXT)");
  $stmt = $pdo->prepare("INSERT INTO scores(val, ts) VALUES (?, datetime('now'))");
  $stmt->execute([$score]);
  echo json_encode(['saved'=>true,'score'=>$score]); exit;
}

http_response_code(404);
echo json_encode(['error'=>'not found','path'=>$path]);
