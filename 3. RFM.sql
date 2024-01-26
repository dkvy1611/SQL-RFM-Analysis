select * from public.sales_dataset_rfm_prj;
--1) Doanh thu theo từng ProductLine, Year và DealSize
select
  PRODUCTLINE,
  YEAR_ID,
  DEALSIZE,
  sum(quantityordered*priceeach) as REVENUE
from public.sales_dataset_rfm_prj
group by PRODUCTLINE, YEAR_ID, DEALSIZE
order by PRODUCTLINE, YEAR_ID, DEALSIZE;

--2) Tháng có bán nhất mỗi năm?
with cte2 as
(select *,
	rank() over(partition by year_id order by revenue desc) as rank
 from
	(select year_id, month_id, 
		sum(quantityordered*priceeach) as REVENUE
	from public.sales_dataset_rfm_prj
	group by month_id, year_id) a)
select year_id, month_id, revenue from cte2 where rank =1;

--3) Product line nào được bán nhiều ở tháng 11?
select month_id, 
	sum(quantityordered*priceeach) as REVENUE,
	productline
from public.sales_dataset_rfm_prj
where month_id=11
group by month_id, productline
order by revenue desc
limit 1;

--4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? Xếp hạng các các doanh thu đó theo từng năm.
with cte4 as
(select *,
	rank() over(partition by YEAR_ID order by revenue desc) as rank
from
	(select YEAR_ID, PRODUCTLINE,
		sum(quantityordered*priceeach) as REVENUE
	from public.sales_dataset_rfm_prj
	where country = 'UK'
	group by YEAR_ID, PRODUCTLINE
	order by year_id asc, REVENUE desc) a)
select * from cte4 where rank=1;

--5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
CREATE TABLE segment_score
	(segment Varchar,
	scores Varchar);

with customer_rfm as
(select customername,
	current_date - max(orderdate) as R,
	count(distinct ordernumber) as F,
	sum(quantityordered*priceeach) as M
from public.sales_dataset_rfm_prj
group by customername),

rfm_score as
(select customername,
	ntile(5) over (order by r desc) as r_score,
	ntile(5) over (order by f) as f_score,
	ntile(5) over (order by m) as m_score
from customer_rfm),

rfm_final as
(select customername,
	cast(r_score as varchar)|| cast(f_score as varchar)|| cast(m_score as varchar)as rfm
from rfm_score)

select *
from 
(select a.customername, b.segment from rfm_final as a
join public.segment_score as b
on a.rfm = b.scores) a
where segment = 'Champions'

  
