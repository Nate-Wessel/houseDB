CREATE TABLE wires (
	connects_from smallint NOT NULL REFERENCES interfaces (uid),
	connects_to smallint NOT NULL REFERENCES interfaces (uid),
	gauge smallint,
	conductors smallint NOT NULL DEFAULT 2,
	ground boolean DEFAULT TRUE,
	notes text,
	CHECK (connects_from != connects_to),
	PRIMARY KEY (connects_from, connects_to)
);
