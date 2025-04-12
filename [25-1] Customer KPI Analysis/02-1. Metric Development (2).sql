# 필수과제1
-- 위의 2개의 마트 쿼리를 검증해 주세요.
-- 명확한 검증 로직을 작성하고 → 해당 값을 검증할 수 있는 코드와 함께 정리해 주세요.
-- 둘 다 모두 검증해야 하고 예시는 최소 2개 이상씩 해야 합니다. - 총 최소 4개 이상진행

# [마트1] 마트 쿼리
use classicmodels;
select 
	o.orderDate,
	sum(od.quantityordered * od.priceeach) as total_revenue, # 총매출
    count(distinct o.ordernumber) as total_orders,
    sum(od.quantityordered) as total_quantity_sold,
    count(distinct o.customernumber) as distinct_customers
from orders as o
join orderdetails od on o.ordernumber = od.ordernumber
where orderdate = '2004-11-24'
group by o.orderDate
order by 1 ;
-- orderdate 2004-11-24 / total_revenue 125129.55 / total_orders 4 

# [마트1] 검증 로직    
select o.ordernumber,
	sum(od.quantityordered*od.priceeach) as total_revenue
from orders o
join orderdetails od on o.ordernumber = od.ordernumber
where o.orderdate = '2004-11-24'
group by o.ordernumber;
-- ordernumber 레코드 4건

select sum(od.quantityordered*od.priceeach) as total_revenue
from orders o
join orderdetails od on o.ordernumber = od.ordernumber
where o.orderdate = '2004-11-24'
group by o.orderdate;
-- total_revenue 24945.21 + 42813.83 + 40265.60 + 17104.91 = 125129.55

# [마트2] 마트 쿼리
select
	c.customerNumber,
    count(distinct o.ordernumber) as total_orders,
    coalesce(sum(od.quantityordered * od.priceeach),0) as total_revenue,  # 계산 null 이슈 유의
    coalesce(round(sum(od.quantityordered * od.priceeach) / nullif(count(distinct o.ordernumber), 0),1),0) as avg_order_value, 
    max(o.orderdate) as last_order_date,
    datediff(curdate(), max(o.orderdate)) as day_since_last_order
from customers as c
left join orders as o on o.customernumber = c.customernumber
left join orderdetails as od on o.ordernumber = od.ordernumber
group by c.customernumber;
-- customernumber 103 / total_orders 3 / total_revenue 22314.36

# [마트2] 검증 로직  
select 
	count(od.ordernumber) as transaction_item,
	sum(od.quantityordered * od.priceeach) as total_revenue
from customers as c
left join orders as o on o.customernumber = c.customernumber
left join orderdetails as od on o.ordernumber = od.ordernumber
where c.customernumber = 103
group by o.ordernumber;
-- transaction_item 레코드 3건 (총 주문 건수 3건)

select sum(od.quantityordered * od.priceeach) as total_revenue
from customers as c
left join orders as o on o.customernumber = c.customernumber
left join orderdetails as od on o.ordernumber = od.ordernumber
where c.customernumber = 103
group by c.customernumber;
-- total_revenue 14571.44+6066.78+1676.14 = 22314.36