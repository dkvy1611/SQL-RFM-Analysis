SELECT * 
FROM public.sales_dataset_rfm_prj;

--Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 
ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN priceeach TYPE numeric USING (priceeach::numeric);

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN sales TYPE numeric USING (sales::numeric);

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE date USING (orderdate::text::date);

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN quantityordered TYPE numeric USING (quantityordered::numeric);

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN ordernumber TYPE numeric USING (ordernumber::numeric);

ALTER TABLE public.sales_dataset_rfm_prj
ALTER COLUMN orderlinenumber TYPE numeric USING (orderlinenumber::numeric);

--Check NULL/BLANK (‘’) ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
SELECT *
FROM public.sales_dataset_rfm_prj
WHERE ordernumber IS NULL
  OR ordernumber = '';


SELECT *
FROM public.sales_dataset_rfm_prj
WHERE quantityordered IS NULL
  OR quantityordered = '';

SELECT *
FROM public.sales_dataset_rfm_prj
WHERE priceeach IS NULL;

SELECT *
FROM public.sales_dataset_rfm_prj
WHERE orderlinenumber IS NULL
  OR orderlinenumber = '';

SELECT *
FROM public.sales_dataset_rfm_prj
WHERE SALES IS NULL;

SELECT *
FROM public.sales_dataset_rfm_prj
WHERE orderdate IS NULL;

--Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME. Viết hoa chữ cái đầu.
ALTER TABLE public.sales_dataset_rfm_prj ADD CONTACTLASTNAME varchar;

ALTER TABLE public.sales_dataset_rfm_prj ADD CONTACTFIRSTNAME varchar;

WITH name AS
  (SELECT contactfullname,
          INITCAP(LEFT(contactfullname, POSITION('-' IN contactfullname)-1)) AS lastname,
          INITCAP(SUBSTRING(contactfullname, POSITION('-' IN contactfullname)+1, length(contactfullname))) AS firstname
   FROM sales_dataset_rfm_prj)
UPDATE sales_dataset_rfm_prj AS a
SET contactlastname = name.lastname,
    contactfirstname = name.firstname
FROM name
WHERE a.contactfullname = name.contactfullname;

--Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 
ALTER TABLE public.sales_dataset_rfm_prj ADD QTR_ID int;

ALTER TABLE public.sales_dataset_rfm_prj ADD MONTH_ID int;

ALTER TABLE public.sales_dataset_rfm_prj ADD YEAR_ID int;

WITH date AS
  (SELECT orderdate,
          extract(QUARTER
                  FROM orderdate) AS qtr,
          extract(MONTH
                  FROM orderdate) AS MONTH,
          extract(YEAR
                  FROM orderdate) AS YEAR
   FROM sales_dataset_rfm_prj)
UPDATE sales_dataset_rfm_prj AS a
SET QTR_ID = date.qtr,
    MONTH_ID = date.month,
    YEAR_ID = date.year
FROM date
WHERE date.orderdate = a.orderdate;

-- Tìm outlier (nếu có) cho cột QUANTITYORDERED và chọn cách xử lý cho bản ghi đó
--C1: Boxplot
WITH a AS
	(SELECT 
		percentile_cont(0.25) within GROUP (ORDER BY quantityordered) AS Q1,
		percentile_cont(0.75) within GROUP (ORDER BY quantityordered) AS Q3,
        	percentile_cont(0.75) within GROUP (ORDER BY quantityordered) - percentile_cont(0.25) within GROUP (ORDER BY quantityordered) AS IQR
      FROM sales_dataset_rfm_prj),
	
boxplot AS
  	(SELECT 
		Q1 - 1.5*IQR AS MIN,
         	Q3 + 1.5*IQR AS MAX
   	FROM a)
	
SELECT *
FROM sales_dataset_rfm_prj
WHERE quantityordered < (SELECT MIN FROM boxplot)
  OR quantityordered > (SELECT MAX FROM boxplot)

--C2: z-score
WITH zscore AS
  (SELECT 
	*,
	(SELECT avg(quantityordered) FROM sales_dataset_rfm_prj) AS avg,
	(SELECT stddev(quantityordered) FROM sales_dataset_rfm_prj) AS stddev
   FROM sales_dataset_rfm_prj)
SELECT *
FROM zscore
WHERE ABS((quantityordered - avg)/stddev) > 3
	
-- Xử lý:
-- Thay outlier bằng giá trị trung bình
	
UPDATE quantityordered
SET quantityordered =
  (SELECT avg(quantityordered)
   FROM sales_dataset_rfm_prj)
WHERE quantityordered in
    (SELECT quantityordered
     FROM zscore);

-- Xóa outlier ra khỏi db

DELETE
FROM quantityordered
WHERE quantityordered in
    (SELECT quantityordered
     FROM zscore);

-- Lưu vào bảng mới
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT *
FROM sales_dataset_rfm_prj;
