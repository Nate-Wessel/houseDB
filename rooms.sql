CREATE TABLE rooms (
	short_name text PRIMARY KEY,
	floor text NOT NULL REFERENCES floors (uid),
	description text
);

