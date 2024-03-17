SELECT *
FROM public.sales_dataset_rfm_prj;

--1) Doanh thu theo từng ProductLine, Year và DealSize
SELECT PRODUCTLINE,
       YEAR_ID,
       DEALSIZE,
       sum(quantityordered*priceeach) AS REVENUE
FROM public.sales_dataset_rfm_prj
GROUP BY PRODUCTLINE,
         YEAR_ID,
         DEALSIZE
ORDER BY PRODUCTLINE,
         YEAR_ID,
         DEALSIZE;

--2) Tháng có bán nhất mỗi năm?
WITH cte2 AS
  (SELECT *,
          rank() over(PARTITION BY year_id ORDER BY revenue DESC) AS rank
   FROM
     (SELECT year_id,
             month_id,
             sum(quantityordered*priceeach) AS revenue
      FROM public.sales_dataset_rfm_prj
      GROUP BY month_id,
               year_id) a)
SELECT year_id,
       month_id,
       revenue
FROM cte2
WHERE rank =1;

--3) Product line nào được bán nhiều ở tháng 11?
SELECT month_id,
       SUM(quantityordered*priceeach) AS revenue,
       productline
FROM public.sales_dataset_rfm_prj
WHERE month_id=11
GROUP BY month_id,
         productline
ORDER BY revenue DESC
LIMIT 1;

--4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? Xếp hạng các các doanh thu đó theo từng năm.
WITH cte4 AS
  (SELECT *,
          rank() over(PARTITION BY YEAR_ID ORDER BY revenue DESC) AS rank
   FROM
     (SELECT YEAR_ID,
             PRODUCTLINE,
             sum(quantityordered*priceeach) AS revenue
      FROM public.sales_dataset_rfm_prj
      WHERE country = 'UK'
      GROUP BY YEAR_ID,
               PRODUCTLINE
      ORDER BY year_id ASC, REVENUE DESC) a)
SELECT *
FROM cte4
WHERE rank=1;

--5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
WITH customer_rfm AS
         (SELECT customername,
                 CURRENT_DATE - max(orderdate) AS R,
                 COUNT(DISTINCT ordernumber) AS F,
                 SUM(quantityordered*priceeach) AS M
          FROM public.sales_dataset_rfm_prj
          GROUP BY customername),
     rfm_score AS
         (SELECT customername,
                 ntile(5) OVER (ORDER BY r DESC) AS r_score,
                 ntile(5) OVER (ORDER BY f) AS f_score,
                 ntile(5) OVER (ORDER BY m) AS m_score
          FROM customer_rfm),
     rfm_final AS
         (SELECT customername,
                 cast(r_score AS varchar)|| cast(f_score AS varchar)|| cast(m_score AS varchar)AS rfm
          FROM rfm_score)
SELECT *
FROM
  (SELECT a.customername,
          b.segment
   FROM rfm_final AS a
   JOIN public.segment_score AS b ON a.rfm = b.scores) a
WHERE SEGMENT = 'Champions';

  
