CREATE TABLE wires (
	uid smallserial PRIMARY KEY,
	connects_from_breaker text REFERENCES circuits (uid),
	connects_from_interface smallint REFERENCES interfaces (uid),
	connects_to_interface smallint NOT NULL REFERENCES interfaces (uid),
	gauge smallint,
	conductors smallint NOT NULL DEFAULT 2,
	ground boolean DEFAULT TRUE,
	was_fished boolean,
	notes text,
	CHECK (connects_from_interface != connects_to_interface)
);
