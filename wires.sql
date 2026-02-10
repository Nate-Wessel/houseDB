CREATE TABLE wires (
	connects_from smallint NOT NULL REFERENCES interfaces (uid),
	connects_to smallint NOT NULL REFERENCES interfaces (uid),
	gauge smallint,
	ground boolean DEFAULT TRUE,
	notes text,
	CHECK (connects_from != connects_to)
);
