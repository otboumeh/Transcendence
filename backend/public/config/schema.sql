PRAGMA foreign_keys = ON; -- activa la validación de las restricciones de clave externa. -- Por defecto, para mantener la compatibilidad con versiones anteriores, SQLite no valida las claves externas. -- Esto significa que aunque definas FOREIGN KEY en tus tablas, SQLite las ignorará y te permitirá, por ejemplo, insertar un user_id en la tabla ranking que no existe en la tabla users.

CREATE TABLE IF NOT EXISTS users 
(
	user_id INTEGER PRIMARY KEY AUTOINCREMENT,
	elo INTEGER DEFAULT 200,
	username TEXT UNIQUE NOT NULL,
	email TEXT UNIQUE NOT NULL,
	pass password TEXT NOT NULL,
	created TEXT DEFAULT CURRENT_TIMESTAMP,
	last_login TEXT 
);

CREATE TABLE IF NOT EXISTS twofa_codes 
(
	id INTEGER PRIMARY KEY AUTOINCREMENT, 
	user_id INTEGER NOT NULL, 
	code TEXT NOT NULL, 
	created_at TEXT DEFAULT CURRENT_TIMESTAMP, 
	time_to_expire_mins INTEGER DEFAULT 500,
	attempts_left INTEGER DEFAULT 3, 
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS friend_request 
(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	sender_id INTEGER NOT NULL,
	receiver_id INTEGER NOT NULL,
	created_at TEXT DEFAULT CURRENT_TIMESTAMP,
	UNIQUE (sender_id, receiver_id),
	FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS friends 
(
	user_id INTEGER NOT NULL,
	friend_id INTEGER NOT NULL,
	PRIMARY KEY (user_id, friend_id),
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ranking 
(
	user_id INTEGER PRIMARY KEY,
	games_played INTEGER DEFAULT 0,
	games_win INTEGER DEFAULT 0,
	games_lose INTEGER DEFAULT 0,
	FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
