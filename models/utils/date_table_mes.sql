-- models/date_table_mes.sql

{{ config(materialized='view') }}

WITH date_table_mes AS (
  SELECT DATE_TRUNC(DATE('2020-01-01') + INTERVAL x DAY, MONTH) as primeiro_dia_do_mes
  FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF(CURRENT_DATE(), DATE('2020-01-01'), DAY))) as x
)

SELECT primeiro_dia_do_mes FROM date_table_mes
