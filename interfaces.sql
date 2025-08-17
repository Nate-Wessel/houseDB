-- "interfaces" are any point where the wiring comes through
-- the wall and interacts either as a wire, a switch, or an outlet
CREATE TABLE interfaces (
	space text NOT NULL REFERENCES spaces (short_name),
	location_in_space text NOT NULL,
	circuit text REFERENCES circuits (uid),
	interface_type text NOT NULL REFERENCES interface_types (short_name),
	grounded boolean,
	notes text,
	rewired boolean,
	PRIMARY KEY (room, location_in_room, interface_type)
);
