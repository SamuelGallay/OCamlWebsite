CREATE TABLE comment (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  text NOT NULL
);

CREATE TABLE dream_session (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  expires_at REAL NOT NULL,
  payload TEXT NOT NULL
);

CREATE TABLE users (
	pseudo	TEXT PRIMARY KEY,
	password	TEXT NOT NULL
);