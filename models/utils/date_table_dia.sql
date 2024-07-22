-- models/date_table_dia.sql

{{ config(materialized='view') }}

WITH date_table_dia AS (
  SELECT DATE('2020-01-01') + INTERVAL x DAY as data
  FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF(CURRENT_DATE(), DATE('2020-01-01'), DAY))) as x
)

SELECT data FROM date_table_dia
