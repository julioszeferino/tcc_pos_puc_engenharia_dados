WITH diarias AS (
    SELECT
        *
    FROM {{ source('despesas', 'json_diarias')}}
)

SELECT * FROM diarias
