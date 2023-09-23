SELECT DISTINCT
    year_number * 100 + month_of_year AS id,
    year_number AS ano,
    month_of_year AS mes,
    NOW() AS data_criacao_registro
FROM {{ ref ('stg_datas') }}


