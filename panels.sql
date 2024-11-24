CREATE TABLE panels (
	short_name text PRIMARY KEY,
	description text,
	notes text,
	circuit text REFERENCES circuits (uid)
);
