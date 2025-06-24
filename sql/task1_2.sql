-- avg logins per user = 5.02
-- avg payments per user = 0.43

with
installs as (
	select
  		ft.user_id,
		ft.event_time::timestamp as install_time
  	from
  		fact_table ft
	where
  		ft.event_name = 'install'
),
logins_stats as (
  select
      i.user_id,
      count(ft.event_time) as logins_count
  from
      installs i
      left join fact_table ft
      on
          i.user_id = ft.user_id
          and ft.event_name = 'login'
          and ft.event_time::timestamp < i.install_time + '4 weeks'::interval
  group by
      1
),
payments_stats as (
	select
  		i.user_id,
  		count(ft.event_time) as payments_count
  	from
  		installs i
  		left join fact_table ft
  		on
  			i.user_id = ft.user_id
  			and ft.event_name = 'payment'
  			and ft.event_time::timestamp < i.install_time + '4 weeks'::interval
  	group by
  		1
),
users_stats as (
  select
      i.user_id,
      i.install_time::date as install_date,
      ls.logins_count,
      ps.payments_count
  from
      installs i
      inner join logins_stats ls
      on
          i.user_id = ls.user_id
      inner join payments_stats ps
      on
          i.user_id = ps.user_id
)
select
	avg(us.logins_count),
    avg(us.payments_count)
from
	users_stats us