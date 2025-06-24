-- Пользователи, у которых есть платежи, но нет установки
with
installs as (
	select
		user_id,
  		event_time::timestamp as install_time
	from
		fact_table
	where
		event_name = 'install'
),
payments as (
	select
  		user_id,
  		count(*) as payments_count,
  		min(event_time::timestamp) as first_payment_time,
  		max(event_time::timestamp) as last_payment_time
  	from
  		fact_table
  	where
  		event_name = 'payment'
 	group by
  		user_id
)
select
	p.*
from
	payments p
    left join installs i
    on
    	p.user_id = i.user_id
where
	i.install_time is null