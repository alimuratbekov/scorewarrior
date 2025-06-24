-- payments_sum
-- 96644

with
payments as (
    select
        ft.user_id,
        ft.event_time as payment_time,
        case
          when ft.currency = 'EUR' then ft.amount
          when ft.currency = 'JPY' then ft.amount * 0.0059
        end as amount,
        row_number() over(partition by ft.user_id order by ft.event_time) as rn
    from
        fact_table ft
    where
        ft.event_name = 'payment'
)
select
    sum(p.amount) as payments_sum
from
    payments p
where
    p.rn between 2 and 7