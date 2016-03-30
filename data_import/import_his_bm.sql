TRUNCATE bm.parkeervakken;

INSERT INTO bm.parkeervakken
(
    parkeer_id_md5,
    parkeer_id,
    stadsdeel,
    buurtcode,
    straatnaam,
    "type",
    aantal,
    geom
)
SELECT DISTINCT ON (parkeer_id)
    md5(parkeer_id),
    parkeer_id,
    stadsdeel,
    buurtcode,
    straatnaam,
    "type",
    aantal,
    geom
FROM his.parkeervakken;

TRUNCATE bm.reserveringen_fiscaal;

INSERT INTO bm.reserveringen_fiscaal
(
    reserverings_key_md5,
    parkeer_id,
    parkeer_id_md5,
    soort,
    reserverings_datum,
    begin_datum,
    eind_datum,
    begin_tijd,
    eind_tijd,
    opmerkingen
)
SELECT
    md5(concat(
        reserverings_tijden.parkeer_id,
        '-',
        bm.datums.datum,
        '-',
        reserverings_tijden.begin_tijd
    )),
    reserverings_tijden.parkeer_id,
    reserverings_tijden.parkeer_id_md5,
    'FISCAAL',
    bm.datums.datum,
    reserverings_tijden.begin_datum,
    reserverings_tijden.eind_datum,
    reserverings_tijden.begin_tijd,
    reserverings_tijden.eind_tijd,
    reserverings_tijden.opmerkingen
FROM bm.datums
INNER JOIN (
    SELECT
        parkeer_id,
        md5(parkeer_id) AS parkeer_id_md5,
        soort,
        CASE tvm_begint ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(tvm_begint, ';', ':')::time
            ELSE '00:00:00'::time
        END AS begin_tijd,
        CASE tvm_eindt ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(tvm_eindt, ';', ':')::time
            ELSE '23:59:59'::time
        END AS eind_tijd,
        tvm_opmerk AS opmerkingen,
        tvm_begind AS begin_datum,
        tvm_eindd AS eind_datum
    FROM his.parkeervakken
    WHERE tvm_begint ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$' AND
          tvm_eindt ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$' AND
          soort = 'FISCAAL' AND
          tvm_begind <= tvm_eindd
) AS reserverings_tijden
    ON reserverings_tijden.begin_datum <= bm.datums.datum AND
       bm.datums.datum <= reserverings_tijden.eind_datum
WHERE reserverings_tijden.begin_datum != reserverings_tijden.eind_datum OR
      reserverings_tijden.begin_tijd < reserverings_tijden.eind_tijd;

INSERT INTO bm.reserveringen_fiscaal
(
    reserverings_key_md5,
    parkeer_id,
    parkeer_id_md5,
    soort,
    reserverings_datum,
    begin_datum,
    eind_datum,
    begin_tijd,
    eind_tijd,
    opmerkingen
)
SELECT
    md5(concat(
        reserverings_tijden.parkeer_id,
        '-',
        bm.datums.datum,
        '-',
        reserverings_tijden.begin_tijd
    )),
    reserverings_tijden.parkeer_id,
    reserverings_tijden.parkeer_id_md5,
    'FISCAAL',
    bm.datums.datum,
    reserverings_tijden.begin_datum,
    reserverings_tijden.eind_datum,
    reserverings_tijden.begin_tijd,
    reserverings_tijden.eind_tijd,
    reserverings_tijden.opmerkingen
FROM bm.datums
INNER JOIN (
    SELECT
        parkeer_id,
        md5(parkeer_id) AS parkeer_id_md5,
        soort,
        CASE tvm_begint ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(tvm_begint, ';', ':')::time
            ELSE '00:00:00'::time
        END AS begin_tijd,
        CASE tvm_eindt ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(tvm_eindt, ';', ':')::time
            ELSE '23:59:59'::time
        END AS eind_tijd,
        tvm_begind AS begin_datum,
        tvm_eindd AS eind_datum,
        tvm_opmerk AS opmerkingen
    FROM his.parkeervakken
    WHERE tvm_begind IS NOT NULL AND
          soort = 'MULDER' AND
          tvm_begind <= tvm_eindd
) AS reserverings_tijden
    ON reserverings_tijden.begin_datum <= bm.datums.datum AND
       bm.datums.datum <= reserverings_tijden.eind_datum
WHERE reserverings_tijden.begin_datum != reserverings_tijden.eind_datum OR
      reserverings_tijden.begin_tijd < reserverings_tijden.eind_tijd;

TRUNCATE bm.reserveringen_mulder;

INSERT INTO bm.reserveringen_mulder
(
    reserverings_key_md5,
    parkeer_id,
    parkeer_id_md5,
    soort,
    kenteken,
    e_type,
    bord,
    reserverings_datum,
    begin_tijd,
    eind_tijd,
    opmerkingen
)
SELECT
    md5(concat(
        reserverings_tijden.parkeer_id,
        '-',
        bm.datums.datum,
        '-',
        reserverings_tijden.begin_tijd
    )),
    reserverings_tijden.parkeer_id,
    reserverings_tijden.parkeer_id_md5,
    'MULDER',
    reserverings_tijden.kenteken,
    reserverings_tijden.e_type,
    reserverings_tijden.bord,
    bm.datums.datum,
    reserverings_tijden.begin_tijd,
    reserverings_tijden.eind_tijd,
    reserverings_tijden.opmerkingen
FROM bm.datums
INNER JOIN (
    SELECT
        parkeer_id,
        md5(parkeer_id) AS parkeer_id_md5,
        soort,
        kenteken,
        e_type,
        bord,
        opmerking AS opmerkingen,
        CASE begintijd1 ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(begintijd1, ';', ':')::time
            ELSE '00:00:00'::time
        END AS begin_tijd,
        CASE eindtijd1 ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(eindtijd1, ';', ':')::time
            ELSE '23:59:59'::time
        END AS eind_tijd,
        ma_vr,
        ma_za,
        zo,
        ma,
        di,
        wo,
        "do",
        vr,
        za,
        goedkeurings_datum
    FROM his.parkeervakken
    WHERE soort = 'MULDER'
    UNION ALL
    SELECT
        parkeer_id,
        md5(parkeer_id) AS parkeer_id_md5,
        soort,
        kenteken,
        e_type,
        bord,
        opmerking AS opmerkingen,
        CASE begintijd2 ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(begintijd2, ';', ':')::time
            ELSE '00:00:00'::time
        END AS begin_tijd,
        CASE eindtijd2 ~ '^[0-9][0-9]?[:;][0-9][0-9]?([:;][0-9][0-9]?)?$'
            WHEN TRUE THEN replace(eindtijd2, ';', ':')::time
            ELSE '23:59:59'::time
        END AS eind_tijd,
        ma_vr,
        ma_za,
        zo,
        ma,
        di,
        wo,
        "do",
        vr,
        za,
        goedkeurings_datum
    FROM his.parkeervakken
    WHERE soort = 'MULDER' AND
          begintijd2 IS NOT NULL
) AS reserverings_tijden
    ON ((reserverings_tijden.ma_vr AND
         bm.datums.dag >= 1 AND
         bm.datums.dag <= 5)
        OR
         (reserverings_tijden.ma_za AND
          bm.datums.dag >= 1 AND
          bm.datums.dag <= 6)
        OR
         (reserverings_tijden.zo AND bm.datums.dag = 0)
        OR
         (reserverings_tijden.ma AND bm.datums.dag = 1)
        OR
         (reserverings_tijden.di AND bm.datums.dag = 2)
        OR
         (reserverings_tijden.wo AND bm.datums.dag = 3)
        OR
         (reserverings_tijden."do" AND bm.datums.dag = 4)
        OR
         (reserverings_tijden.vr AND bm.datums.dag = 5)
        OR
         (reserverings_tijden.za AND bm.datums.dag = 6)
        OR(NOT reserverings_tijden.ma_vr AND
           NOT reserverings_tijden.ma_za AND
           NOT reserverings_tijden.zo AND
           NOT reserverings_tijden.ma AND
           NOT reserverings_tijden.di AND
           NOT reserverings_tijden.wo AND
           NOT reserverings_tijden."do" AND
           NOT reserverings_tijden.vr AND
           NOT reserverings_tijden.za))
        AND bm.datums.datum >= reserverings_tijden.goedkeurings_datum;

TRUNCATE bm.reserveringen_mulder_schoon;

INSERT INTO bm.reserveringen_mulder_schoon
(
    "reserverings_key_md5",
    "parkeer_id",
    "parkeer_id_md5",
    "soort",
    "kenteken",
    "e_type",
    "bord",
    "reserverings_datum",
    "begin_datum",
    "eind_datum",
    "begin_tijd",
    "eind_tijd",
    "opmerkingen"
)
SELECT mulder.*
FROM bm.reserveringen_mulder AS mulder
LEFT OUTER JOIN bm.reserveringen_fiscaal AS fiscaal
    ON mulder.parkeer_id_md5 = fiscaal.parkeer_id_md5 AND
       mulder.reserverings_datum = fiscaal.reserverings_datum
WHERE fiscaal.parkeer_id IS NULL;

INSERT INTO bm.reserveringen_mulder_schoon
(
    "reserverings_key_md5",
    "parkeer_id",
    "parkeer_id_md5",
    "soort",
    "kenteken",
    "e_type",
    "bord",
    "reserverings_datum",
    "begin_datum",
    "eind_datum",
    "begin_tijd",
    "eind_tijd",
    "opmerkingen"
)
SELECT
    md5(concat(
        mulder.parkeer_id,
        '-',
        mulder.reserverings_datum,
        '-',
        mulder.begin_tijd
    )),
    mulder.parkeer_id,
    mulder.parkeer_id_md5,
    mulder.soort,
    mulder.kenteken,
    mulder.e_type,
    mulder.bord,
    mulder.reserverings_datum,
    mulder.begin_datum,
    mulder.eind_datum,
    mulder.begin_tijd,
    fiscaal.begin_tijd,
    mulder.opmerkingen
FROM bm.reserveringen_mulder AS mulder
INNER JOIN bm.reserveringen_fiscaal AS fiscaal
    ON mulder.parkeer_id_md5 = fiscaal.parkeer_id_md5 AND
       mulder.reserverings_datum = fiscaal.reserverings_datum
WHERE mulder.begin_tijd < fiscaal.begin_tijd AND
      mulder.eind_tijd > fiscaal.begin_tijd AND
      mulder.eind_tijd <= fiscaal.eind_tijd;

INSERT INTO bm.reserveringen_mulder_schoon
(
    "reserverings_key_md5",
    "parkeer_id",
    "parkeer_id_md5",
    "soort",
    "kenteken",
    "e_type",
    "bord",
    "reserverings_datum",
    "begin_datum",
    "eind_datum",
    "begin_tijd",
    "eind_tijd",
    "opmerkingen"
)
SELECT
    md5(concat(
        mulder.parkeer_id,
        '-',
        mulder.reserverings_datum,
        '-',
        fiscaal.eind_tijd
    )),
    mulder.parkeer_id,
    mulder.parkeer_id_md5,
    mulder.soort,
    mulder.kenteken,
    mulder.e_type,
    mulder.bord,
    mulder.reserverings_datum,
    mulder.begin_datum,
    mulder.eind_datum,
    fiscaal.eind_tijd,
    mulder.eind_tijd,
    mulder.opmerkingen
FROM bm.reserveringen_mulder AS mulder
INNER JOIN bm.reserveringen_fiscaal AS fiscaal
    ON mulder.parkeer_id_md5 = fiscaal.parkeer_id_md5 AND
       mulder.reserverings_datum = fiscaal.reserverings_datum
WHERE mulder.begin_tijd >= fiscaal.begin_tijd AND
      mulder.begin_tijd < fiscaal.eind_tijd AND
      mulder.eind_tijd > fiscaal.eind_tijd;


INSERT INTO bm.reserveringen_mulder_schoon
(
    "reserverings_key_md5",
    "parkeer_id",
    "parkeer_id_md5",
    "soort",
    "kenteken",
    "e_type",
    "bord",
    "reserverings_datum",
    "begin_datum",
    "eind_datum",
    "begin_tijd",
    "eind_tijd",
    "opmerkingen"
)
SELECT
    md5(concat(
        a.parkeer_id,
        '-',
        a.reserverings_datum,
        '-',
        a.begin_tijd
    )),
    a.parkeer_id,
    a.parkeer_id_md5,
    a.soort,
    a.kenteken,
    a.e_type,
    a.bord,
    a.reserverings_datum,
    a.begin_datum,
    a.eind_datum,
    a.begin_tijd,
    a.eind_tijd,
    a.opmerkingen
FROM (
    SELECT
        mulder.parkeer_id,
        mulder.parkeer_id_md5,
        mulder.soort,
        mulder.kenteken,
        mulder.e_type,
        mulder.bord,
        mulder.reserverings_datum,
        mulder.begin_datum,
        mulder.eind_datum,
        unnest(ARRAY[mulder.begin_tijd, fiscaal.eind_tijd]::time without time zone[]) AS begin_tijd,
        unnest(ARRAY[fiscaal.begin_tijd, mulder.eind_tijd]::time without time zone[]) AS eind_tijd,
        mulder.opmerkingen
    FROM bm.reserveringen_mulder AS mulder
    INNER JOIN bm.reserveringen_fiscaal AS fiscaal
        ON mulder.parkeer_id_md5 = fiscaal.parkeer_id_md5 AND
        mulder.reserverings_datum = fiscaal.reserverings_datum
    WHERE mulder.begin_tijd < fiscaal.begin_tijd AND
        mulder.eind_tijd > fiscaal.eind_tijd
) AS a;