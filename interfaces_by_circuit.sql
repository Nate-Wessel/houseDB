CREATE OR REPLACE VIEW interfaces_by_circuit AS

SELECT
	circuits.uid AS circuit,
	circuits.amps,
	COALESCE(
		bool_or(rewired),
		FALSE
	) AS has_rewired_interfaces,
	COUNT(DISTINCT interfaces.space || location_in_space || interface_type) AS interface_count,
	COUNT(DISTINCT interfaces.space || location_in_space || interface_type) FILTER (WHERE NOT interfaces.grounded) AS ungrounded_interfaces,
	COUNT(DISTINCT interfaces.space || location_in_space || interface_type) FILTER (WHERE interfaces.grounded IS NULL) AS interfaces_grounding_unknown,
	array_agg(DISTINCT space ORDER BY space) FILTER (WHERE space IS NOT NULL) AS spaces,
	array_agg(DISTINCT spaces.floor ORDER BY spaces.floor) AS floors
FROM circuits
LEFT JOIN interfaces ON interfaces.circuit = circuits.uid
LEFT JOIN spaces ON interfaces.space = spaces.short_name
GROUP BY
	circuits.uid,
	circuits.amps
ORDER BY interface_count DESC;
