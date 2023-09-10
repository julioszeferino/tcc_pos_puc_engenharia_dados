WITH pagamentos AS (
    SELECT
        *
    FROM {{ source('despesas', 'json_pagamentos')}}
)

SELECT * FROM pagamentos
