WITH nulos_logicos AS (
    SELECT
        -1 as id,
        'DESPESA NAO IDENTIFICADA' as elemento_despesa,
        NOW() as data_criacao_registro
), nf_diarias AS (
    SELECT DISTINCT
        COALESCE(
            (CASE
                WHEN REGEXP_REPLACE(TRIM(subtitulo), '[^a-zA-Z]', '') <> '' THEN TRIM(subtitulo)
                ELSE NULL
            END),
            TRIM(SPLIT_PART(elemento_despesa, '-', 2))
        ) as elemento_despesa
    FROM {{ ref('stg_diarias')}}
), nf_pagamentos as (
    SELECT DISTINCT
        COALESCE(
            (CASE
                WHEN REGEXP_REPLACE(TRIM(subtitulo), '[^a-zA-Z]', '') <> '' THEN TRIM(subtitulo)
                ELSE NULL
            END),
            TRIM(SPLIT_PART(elemento_despesa, '-', 2))
        ) as elemento_despesa
    FROM {{ ref('stg_pagamentos')}}
), nf_obras as (
    SELECT DISTINCT
        COALESCE(
            (CASE
                WHEN REGEXP_REPLACE(TRIM(subtitulo), '[^a-zA-Z]', '') <> '' THEN TRIM(subtitulo)
                ELSE NULL
            END),
            TRIM(SPLIT_PART(elemento_despesa, '-', 2))
        ) as elemento_despesa
    FROM {{ ref('stg_obras')}}
), final as (
    SELECT
        nf_diarias.elemento_despesa
    FROM nf_diarias
    UNION
    SELECT
        nf_pagamentos.elemento_despesa
    FROM nf_pagamentos
    UNION
    SELECT
        nf_obras.elemento_despesa
    FROM nf_obras
)

SELECT DISTINCT
    row_number() over() as id,
    UPPER(elemento_despesa) as elemento_despesa,
    NOW() as data_criacao_registro
FROM final
UNION
SELECT
    id,
    elemento_despesa,
    data_criacao_registro
FROM nulos_logicos