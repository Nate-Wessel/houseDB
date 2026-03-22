CREATE TABLE junction_boxes (
	uid smallserial PRIMARY KEY,
	shape text NOT NULL CHECK (shape IN ('round', 'rectangular', 'octagon', 'square')),
	material text NOT NULL CHECK (material IN ('metal','plastic')),
	gang smallint CHECK (gang IS NULL OR gang >= 1),
	notes text
);
