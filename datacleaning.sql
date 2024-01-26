select * from public.sales_dataset_rfm_prj;

--Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN priceeach TYPE numeric USING (priceeach::numeric);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN sales TYPE numeric USING (sales::numeric);
alter table public.sales_dataset_rfm_prj alter column orderdate type date using (orderdate::text::date);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN quantityordered TYPE numeric USING (quantityordered::numeric);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN ordernumber TYPE numeric USING (ordernumber::numeric);
ALTER TABLE public.sales_dataset_rfm_prj ALTER COLUMN orderlinenumber TYPE numeric USING (orderlinenumber::numeric);

--Check NULL/BLANK (‘’) ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
select * 
from public.sales_dataset_rfm_prj
where ordernumber is null or ordernumber = '';
select * 
from public.sales_dataset_rfm_prj
where QUANTITYORDERED is null or QUANTITYORDERED = '';
select * 
from public.sales_dataset_rfm_prj
where PRICEEACH is null;
select * 
from public.sales_dataset_rfm_prj
where ORDERLINENUMBER is null or ORDERLINENUMBER = '';
select * 
from public.sales_dataset_rfm_prj
where SALES is null;
select * 
from public.sales_dataset_rfm_prj
where ORDERDATE is null;

--Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME. Viết hoa chữ cái đầu.
alter table public.sales_dataset_rfm_prj add CONTACTLASTNAME varchar;
alter table public.sales_dataset_rfm_prj add CONTACTFIRSTNAME varchar;

with name as
(select contactfullname,
	initcap(left(contactfullname,position('-' in contactfullname)-1)) as lastname,
 	initcap(substring(contactfullname,position('-' in contactfullname)+1,length(contactfullname))) as firstname
 from sales_dataset_rfm_prj
)
update sales_dataset_rfm_prj as a
set CONTACTLASTNAME = name.lastname, CONTACTFIRSTNAME = name.firstname
from name
where a.contactfullname = name.contactfullname;

--Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
alter table public.sales_dataset_rfm_prj add QTR_ID int;
alter table public.sales_dataset_rfm_prj add MONTH_ID int;
alter table public.sales_dataset_rfm_prj add YEAR_ID int;

with date as
(select orderdate, extract(quarter from orderdate) as qtr, 
 		extract(month from orderdate) as month, extract(year from orderdate) as year
from sales_dataset_rfm_prj
)
update sales_dataset_rfm_prj as a
set QTR_ID = date.qtr, MONTH_ID = date.month, YEAR_ID = date.year
from date
where date.orderdate = a.orderdate;

-- Tìm outlier (nếu có) cho cột QUANTITYORDERED và chọn cách xử lý cho bản ghi đó
--C1: Boxplot
with boxplot as
(select Q1 - 1.5*IQR as min, Q3 + 1.5*IQR as max
from
(select percentile_cont(0.25) within group (order by quantityordered) as Q1,
		percentile_cont(0.75) within group (order by quantityordered) as Q3,
		percentile_cont(0.75) within group (order by quantityordered) - percentile_cont(0.25) within group (order by quantityordered) as IQR
from sales_dataset_rfm_prj) as a)
select * from sales_dataset_rfm_prj
where quantityordered < (select min from boxplot) or quantityordered > (select max from boxplot)
--C2: z-score
with zscore as
(select *,
	(select avg(quantityordered) from sales_dataset_rfm_prj) as avg, 
	(select stddev(quantityordered) from sales_dataset_rfm_prj) as stddev
from sales_dataset_rfm_prj)
select *
from zscore
where abs((quantityordered-avg)/stddev) > 3
-- Xử lý:
-- Thay outlier bằng giá trị trung bình
update quantityordered 
set quantityordered = (select avg(quantityordered) from sales_dataset_rfm_prj)
where quantityordered in (select quantityordered from zscore);
-- Xóa outlier ra khỏi db
delete from quantityordered
where quantityordered in (select quantityordered from zscore);

-- Lưu vào bảng mới
create table SALES_DATASET_RFM_PRJ_CLEAN as
select * from sales_dataset_rfm_prj;
