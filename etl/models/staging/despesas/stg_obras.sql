WITH obras AS (
    SELECT
        *
    FROM {{ source('despesas', 'json_obras')}}
)

SELECT * FROM obras
