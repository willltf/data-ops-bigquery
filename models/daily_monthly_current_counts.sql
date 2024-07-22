-- models/daily_monthly_current_counts.sql

{{ config(materialized='table') }}

SELECT
  type,
  data,
  total_ate_hoje,
  CURRENT_TIMESTAMP() AS processed_at
FROM (
  -- Consulta para contagem diária
  SELECT
    'DIA' as type,
    d.data,
    MAX((
      SELECT 
        COUNT(*) 
        FROM {{ source('learntofly_data_lake', 'v_program') }} as self
        WHERE DATE(self.created_at) <= d.data
    )) AS total_ate_hoje
  FROM {{ ref('date_table_dia') }} as d
  LEFT JOIN {{ source('learntofly_data_lake', 'v_program') }} as v_program ON DATE(d.data) = DATE(v_program.created_at)
  GROUP BY d.data

  UNION ALL

  -- Consulta para contagem mensal acumulada
  SELECT
    'MES' as type,
    m.primeiro_dia_do_mes as data,
    MAX((
      SELECT 
        COUNT(*) 
        FROM {{ source('learntofly_data_lake', 'v_program') }} as self
        WHERE DATE(self.created_at) <= LAST_DAY(m.primeiro_dia_do_mes)
    )) AS total_ate_final_do_mes
  FROM {{ ref('date_table_mes') }} as m
  LEFT JOIN {{ source('learntofly_data_lake', 'v_program') }} as v_program
    ON DATE_TRUNC(DATE(v_program.created_at), MONTH) = m.primeiro_dia_do_mes
  GROUP BY m.primeiro_dia_do_mes

  UNION ALL

  -- Consulta para contagem atual
  SELECT
    'CURRENT' as type,
    CURRENT_DATE() as data,
    COUNT(*) AS total_ate_final_do_mes
  FROM {{ source('learntofly_data_lake', 'v_program') }} as v_program
  WHERE DATE(v_program.created_at) <= CURRENT_DATE()
  GROUP BY CURRENT_DATE()
) as results
