WITH nf_diarias AS (
    SELECT DISTINCT
        nome_favorecido
    FROM {{ ref('stg_diarias')}}
), nf_pagamentos as (
    SELECT DISTINCT
        nome_favorecido
    FROM {{ ref('stg_pagamentos')}}
), final as (
    SELECT
        nf_diarias.nome_favorecido
    FROM nf_diarias
    UNION
    SELECT
        nf_pagamentos.nome_favorecido
    FROM nf_pagamentos
)

SELECT DISTINCT
    row_number() over() as id,
    UPPER(nome_favorecido) as nome_favorecido,
    NOW() as data_criacao_registro
FROM final