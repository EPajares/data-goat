CREATE TABLE public_transport_lines AS
SELECT
    osm_id,
    name,
    OPERATOR,
    REF,
    route,
    service,
    tags -> 'route_name' AS route_name,
    tags -> 'to' AS origin,
    tags -> 'via' AS via,
    tags -> 'from' AS destination,
    tags -> 'network' AS network,
    way AS geom
FROM
    planet_osm_line
WHERE
    route IN (
        'tram', 'train', 'bus', 'subway'
);

SELECT
    osm_id,
    'bus_stop' AS public_transport_stop,
    name,
    way AS geom,
    tags
FROM
    planet_osm_point
WHERE
    highway = 'bus_stop'
    AND name IS NOT NULL DROP TABLE IF EXISTS public_transport_stops;

CREATE TABLE public_transport_stops AS
SELECT
    *,
    'point' AS orgin_geometry,
    (
        SELECT
            max(gid)
        FROM
            pois) + row_number(
) OVER () AS gid
    FROM (
        SELECT
            osm_id,
            'bus_stop' AS public_transport_stop,
            name,
            way AS geom
        FROM
            planet_osm_point
        WHERE
            highway = 'bus_stop'
            AND name IS NOT NULL
        UNION ALL
        SELECT
            osm_id,
            'bus_stop' AS public_transport_stop,
            name,
            way AS geom
        FROM
            planet_osm_point
        WHERE
            public_transport = 'platform'
            AND name IS NOT NULL
            AND tags -> 'bus' = 'yes'
        UNION ALL
        SELECT
            osm_id,
            'tram_stop' AS public_transport_stop,
            name,
            way AS geom
        FROM
            planet_osm_point
        WHERE
            public_transport = 'stop_position'
            AND tags -> 'tram' = 'yes'
            AND name IS NOT NULL
        UNION ALL
        SELECT
            osm_id,
            'subway_entrance' AS public_transport,
            name,
            way AS geom
        FROM
            planet_osm_point
        WHERE
            railway = 'subway_entrance'
        UNION ALL
        SELECT
            osm_id,
            'rail_station' AS public_transport,
            name,
            way AS geom
        FROM
            planet_osm_point
        WHERE
            railway = 'stop'
            AND tags -> 'train' = 'yes') x;

