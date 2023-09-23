WITH nulos_logicos AS (
    SELECT
        -1 as id,
        'FAVORECIDO NAO ENCONTRADO' as nome_favorecido,
        NOW() as data_criacao_registro
), nf_diarias AS (
    SELECT DISTINCT
        nome_favorecido
    FROM {{ ref('stg_diarias')}}
), nf_pagamentos as (
    SELECT DISTINCT
        nome_favorecido
    FROM {{ ref('stg_pagamentos')}}
), nf_obras as (
    SELECT DISTINCT
        nome_favorecido
    FROM {{ ref('stg_obras')}}
), final as (
    SELECT
        nf_diarias.nome_favorecido
    FROM nf_diarias
    UNION
    SELECT
        nf_pagamentos.nome_favorecido
    FROM nf_pagamentos
    UNION
    SELECT
        nf_obras.nome_favorecido
    FROM nf_obras
)

SELECT DISTINCT
    row_number() over() as id,
    UPPER(nome_favorecido) as nome_favorecido,
    NOW() as data_criacao_registro
FROM final
WHERE TRIM(nome_favorecido) IS NOT NULL
UNION
SELECT
    id,
    nome_favorecido,
    data_criacao_registro
FROM nulos_logicos