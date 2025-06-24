-- day_of_life 	avg_days_7_payments_sum 	avg_days_30_payments_sum
-- 1 	173.0458221024259 	527.7978436657681
-- 2 	191.85175202156333 	561.22102425876
-- 3 	205.8679245283019 	564.455525606469
-- 4 	216.11051212938006 	581.167115902965
-- 5 	217.7277628032345 	599.2264150943396
-- 6 	219.61455525606468 	617.8247978436658
-- 7 	284.84366576819406 	636.1536388140162
-- 8 	286.46091644204853 	673.88948787062
-- 9 	287.53908355795147 	683.3234501347708
-- 10 	288.8867924528302 	693.2964959568733

with
installs as (
	select
  		ft.user_id,
		ft.event_time::date as install_date
  	from
  		fact_table ft
	where
  		ft.event_name = 'install'
),
days_template as (
	select
  		generate_series(
        	0,
         	9,
          	1
        ) as template_day
),
days_of_life as (
    select
        i.*,
        dt.template_day + 1 as day_of_life,
        (i.install_date + '1 day'::interval * dt.template_day)::date as date_of_life
    from
        installs i
        cross join days_template dt
),
payments as (
	select
  		ft.user_id,
  		ft.event_time::date as payment_date,
  		case
  			when ft.currency = 'EUR' then ft.amount
  			when ft.currency = 'JPY' then ft.amount * 0.0059
  		end as amount
  	from
  		fact_table ft
	where
  		ft.event_name = 'payment'
),
payments_stats as (
    select
		dol.user_id,
  		dol.day_of_life,
  		coalesce(sum(p.amount), 0) as days_30_payments_sum,
  		coalesce(sum(p.amount) filter(where p.payment_date < dol.date_of_life + '7 days'::interval), 0) as days_7_payments_sum
    from
        days_of_life dol
        left join payments p
		on
  			dol.user_id = p.user_id
  			and p.payment_date < dol.date_of_life + '30 days'::interval
 	group by
  		1, 2
)
select
	ps.day_of_life,
	avg(ps.days_7_payments_sum) as avg_days_7_payments_sum,
    avg(ps.days_30_payments_sum) as avg_days_30_payments_sum
from
	payments_stats ps
group by
	1
order by
	1