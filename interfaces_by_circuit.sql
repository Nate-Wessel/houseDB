CREATE OR REPLACE VIEW interfaces_by_circuit AS

SELECT
	circuits.uid AS circuit,
	circuits.amps,
	COUNT(DISTINCT interfaces.space || location_in_space || interface_type) AS interface_count,
	COUNT(DISTINCT interfaces.space || location_in_space || interface_type) FILTER (WHERE interfaces.grounded IS NOT TRUE) AS k_and_t_interfaces,
	array_agg(DISTINCT space) FILTER (WHERE space IS NOT NULL) AS spaces
FROM circuits
LEFT JOIN interfaces ON interfaces.circuit = circuits.uid
GROUP BY
	circuits.uid,
	circuits.amps
ORDER BY interface_count DESC;
