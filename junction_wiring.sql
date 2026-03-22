CREATE OR REPLACE VIEW junction_wiring AS

SELECT
	jb.uid,
	jb.shape,
	jb.material,
	jb.gang,
	jb.notes,
	ARRAY_AGG(DISTINCT i.space) AS space,
	ARRAY_AGG(interface_type),
	ARRAY_AGG(DISTINCT circuit)
FROM junction_boxes AS jb
JOIN interfaces AS i ON jb.uid = i.sits_within
GROUP BY
	jb.uid,
	jb.shape,
	jb.material,
	jb.gang,
	jb.notes;
