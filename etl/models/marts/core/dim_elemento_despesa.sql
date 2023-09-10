WITH nf_diarias AS (
    SELECT DISTINCT
        TRIM(SPLIT_PART(elemento_despesa, '-', 2)) as elemento_despesa
    FROM {{ ref('stg_diarias')}}
), nf_pagamentos as (
    SELECT DISTINCT
        TRIM(SPLIT_PART(elemento_despesa, '-', 2)) as elemento_despesa
    FROM {{ ref('stg_pagamentos')}}
), final as (
    SELECT
        nf_diarias.elemento_despesa
    FROM nf_diarias
    UNION
    SELECT
        nf_pagamentos.elemento_despesa
    FROM nf_pagamentos
)

SELECT DISTINCT
    row_number() over() as id,
    UPPER(elemento_despesa) as elemento_despesa,
    NOW() as data_criacao_registro
FROM final