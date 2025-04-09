# 필수과제2
-- 고객의 세그먼트를 새롭게 나눠주세요.
-- 5등급으로 나눠서(직접 데이터를 보고 설계하시면 됩니다.) 5개의 등급의 고객 세그먼트가 나올 수 있게 만들어 주시면 됩니다.
-- 수업 때는 3개 했지만 실제 5개까지 진행하고 모두 로직상 겹치지 않게 최대한 다 세그먼트로 나뉠 수 있도록 지정해 주세요. 

use classicmodels;

select
	c.customerNumber,
    c.customerName,
    count(distinct o.ordernumber) as total_orders,
    coalesce(sum(od.quantityordered * od.priceeach),0) as total_revenue, 
    coalesce(round(sum(od.quantityordered * od.priceeach) / nullif(count(distinct o.ordernumber), 0),1),0) as avg_order_value, 
    max(o.orderdate) as last_order_date,
    datediff(curdate(), max(o.orderdate)) as day_since_last_order,
    case
		when count(distinct o.ordernumber) > 15 and sum(od.quantityordered * od.priceeach) > 500000 then 'VIP 고객'
        when count(distinct o.ordernumber) between 1 and 15 and sum(od.quantityordered * od.priceeach) > 100000 then '충성 고객'
        when count(distinct o.ordernumber) between 1 and 15 and sum(od.quantityordered * od.priceeach) > 29000 then '일반 고객'
		when count(distinct o.ordernumber) between 1 and 15 then '신규 고객'
        when datediff(curdate(), max(o.orderDate)) is null then '미이용 고객'
	end as customer_seg
from customers as c
left join orders as o on o.customernumber = c.customernumber
left join orderdetails as od on o.ordernumber = od.ordernumber
group by c.customernumber;