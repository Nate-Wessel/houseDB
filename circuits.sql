CREATE TABLE circuits (
	uid text PRIMARY KEY,
	panel text NOT NULL REFERENCES panels (short_name),
	amps smallint NOT NULL CHECK (amps > 0),
	gfci boolean,
	afci boolean,
	voltage smallint
);
