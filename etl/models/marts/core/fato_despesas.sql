WITH diarias AS (
    SELECT
        CAST(ano AS INTEGER) as ano,
        CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) as mes,
        CASE
            WHEN TRIM(subtitulo) IS NOT NULL THEN UPPER(TRIM(subtitulo))
            ELSE UPPER(TRIM(SPLIT_PART(elemento_despesa, '-', 2)))
        END as elemento_despesa,
        UPPER(nome_favorecido) as nome_favorecido,
        'DIARIA' as tipo_despesa,
        valor as valor_despesa
    FROM {{ ref('stg_diarias')}}
), pagamentos AS (
    SELECT
        CAST(ano AS INTEGER) as ano,
        CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) as mes,
        CASE
            WHEN TRIM(subtitulo) IS NOT NULL THEN UPPER(TRIM(subtitulo))
            ELSE UPPER(TRIM(SPLIT_PART(elemento_despesa, '-', 2)))
        END as elemento_despesa,
        UPPER(nome_favorecido) as nome_favorecido,
        'PAGAMENTO' as tipo_despesa,
        valor as valor_despesa
    FROM {{ ref('stg_pagamentos')}}
), obras AS (
    SELECT
        CAST(ano AS INTEGER) as ano,
        CAST(SPLIT_PART(mes, ' - ', 1) AS INTEGER) as mes,
        CASE
            WHEN TRIM(subtitulo) IS NOT NULL THEN UPPER(TRIM(subtitulo))
            ELSE UPPER(TRIM(SPLIT_PART(elemento_despesa, '-', 2)))
        END as elemento_despesa,
        UPPER(nome_favorecido) as nome_favorecido,
        'OBRA' as tipo_despesa,
        valor as valor_despesa
    FROM {{ ref('stg_obras')}}
), fato_temp AS (
    SELECT * FROM diarias
    UNION ALL
    SELECT * FROM pagamentos
    UNION ALL
    SELECT * FROM obras
), fato_despesas AS (
    SELECT
        temp.ano * 100 + temp.mes AS id_tempo,
        ded.id as id_elemento_despesa,
        df.id as id_favorecido,
        temp.tipo_despesa,
        ROUND(SUM(CAST(temp.valor_despesa AS DECIMAL)),2) as valor_despesa
    FROM fato_temp AS temp

    LEFT JOIN {{ ref ('dim_elemento_despesa')}} as ded
    ON COALESCE(TRIM(temp.elemento_despesa), 'DESPESA NAO IDENTIFICADA') = ded.elemento_despesa

    LEFT JOIN {{ ref ('dim_favorecidos')}} as df
    ON COALESCE(TRIM(temp.nome_favorecido), 'FAVORECIDO NAO ENCONTRADO') = df.nome_favorecido

    GROUP BY 1, 2, 3, 4
)

SELECT * FROM fato_despesas