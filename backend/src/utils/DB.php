<?php
final class DB {
  private static ?PDO $pdo = null;
  static function conn(): PDO {
    if (!self::$pdo) {
      $dsn = 'sqlite:/var/www/html/database/db.sqlite3';
      self::$pdo = new PDO($dsn, null, null, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
      ]);
      self::$pdo->exec('PRAGMA foreign_keys = ON; PRAGMA journal_mode = WAL; PRAGMA busy_timeout = 3000;');
    }
    return self::$pdo;
  }
}
