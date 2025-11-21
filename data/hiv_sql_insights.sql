-- hiv_sql_insights.sql
-- Sample schema + query set used to drive the HIV/AIDS SQL card

CREATE TABLE hiv_surveillance (
    district TEXT,
    year INT,
    new_cases INT,
    new_initiated_art INT
);

-- Example aggregation used in dashboards
SELECT
    year,
    SUM(new_cases) AS new_cases,
    SUM(new_initiated_art) AS art_initiations,
    ROUND(
        SUM(new_initiated_art) * 100.0 / NULLIF(SUM(new_cases), 0),
        1
    ) AS art_coverage_pct
FROM hiv_surveillance
WHERE district IN ('Gaborone', 'Francistown', 'Serowe')
GROUP BY year
ORDER BY year;

