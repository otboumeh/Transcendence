<?php
// Servidor WS sencillo con Ratchet (eco de mensajes)
require __DIR__.'/../vendor/autoload.php';

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Http\HttpServer;
use Ratchet\Server\IoServer;
use Ratchet\WebSocket\WsServer;

class GameWs implements MessageComponentInterface {
  protected $clients;
  public function __construct(){ $this->clients = new \SplObjectStorage; }
  public function onOpen(ConnectionInterface $conn){ $this->clients->attach($conn); }
  public function onMessage(ConnectionInterface $from, $msg){
    foreach ($this->clients as $client) { $client->send($msg); }
  }
  public function onClose(ConnectionInterface $conn){ $this->clients->detach($conn); }
  public function onError(ConnectionInterface $conn, \Exception $e){ $conn->close(); }
}
$server = IoServer::factory(new HttpServer(new WsServer(new GameWs())), 9001, "0.0.0.0");
echo "WS listening on :9001\n";
$server->run();
