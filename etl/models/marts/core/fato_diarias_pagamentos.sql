WITH diarias AS (
    SELECT
        CAST(SPLIT_PART(ano, ' - ', 1) AS INTEGER) as ano,
        CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) as mes,
        UPPER(TRIM(SPLIT_PART(elemento_despesa, '-', 2))) as elemento_despesa,
        UPPER(nome_favorecido) as nome_favorecido,
        'DIARIA' as tipo_despesa,
        valor as valor_despesa
    FROM {{ ref('stg_diarias')}}
), pagamentos AS (
    SELECT
        CAST(SPLIT_PART(ano, ' - ', 1) AS INTEGER) as ano,
        CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) as mes,
        UPPER(TRIM(SPLIT_PART(elemento_despesa, '-', 2))) as elemento_despesa,
        UPPER(nome_favorecido) as nome_favorecido,
        'PAGAMENTO' as tipo_despesa,
        valor as valor_despesa
    FROM {{ ref('stg_pagamentos')}}
), fato_temp AS (
    SELECT * FROM diarias
    UNION ALL
    SELECT * FROM pagamentos
), fato_diarias_pagamentos AS (
    SELECT
        temp.ano,
        temp.mes,
        ded.id as id_elemento_despesa,
        df.id as id_favorecido,
        temp.tipo_despesa,
        ROUND(SUM(CAST(temp.valor_despesa AS DECIMAL)),2) as valor_despesa
    FROM fato_temp AS temp

    LEFT JOIN {{ ref ('dim_elemento_despesa')}} as ded
    ON temp.elemento_despesa = ded.elemento_despesa

    LEFT JOIN {{ ref ('dim_favorecidos')}} as df
    ON temp.nome_favorecido = df.nome_favorecido

    GROUP BY 1, 2, 3, 4, 5
)

SELECT * FROM fato_diarias_pagamentos