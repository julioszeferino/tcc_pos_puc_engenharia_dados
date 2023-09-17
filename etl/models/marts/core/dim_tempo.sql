SELECT DISTINCT
    CONCAT(year_number, LPAD(month_of_year, 2, '0'), '01') AS id,
    year_number AS ano,
    month_of_year AS mes,
    NOW() AS data_criacao_registro
FROM {{ ref ('stg_datas') }}


