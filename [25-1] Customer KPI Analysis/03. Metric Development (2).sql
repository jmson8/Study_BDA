# 필수과제
-- 제품을 기준으로 여러분이 중요하게 생각하는 지표를 5개 이상은 만들어서 쿼리로 추출해 주세요!
-- 본인이 생각하는 마트의 쿼리와 검증쿼리까지 비교해서 수치 검증 완료된 것도 같이 공유해 주세요!!
-- 검증쿼리에 대한 설명까지도 적어주셔야 합니다!!!

# [지표1] 주문 수
use classicmodels;

select p.productcode,
	p.productname,
    sum(od.quantityordered) as order_quantity
from products p
inner join orderdetails od on p.productcode = od.productcode
group by p.productcode;

select count(distinct od.productcode) as product
from orderdetails od;
-- 데이터 마트 레코드 개수 = 전체 주문 내 거래된 제품 개수
-- 데이터 마트 레코드 개수 : 109개
-- 전체 주문 내 거래된 제품 개수 : 109개

# [지표2] 재고 현황
select p.productcode,
	p.productname,
    p.quantityinstock - sum(od.quantityordered) as inventory_status
from products p
inner join orderdetails od on p.productcode = od.productcode
group by p.productcode, p.productname;

select sum(quantityinstock) as inventory_sum,
	sum(quantityordered) as order_quantity_sum,
    sum(inventory_status) as inventory_status_sum,
    sum(quantityordered) + sum(inventory_status) as val_value
from(select p.productcode,
		p.productname,
        p.quantityinstock,
        sum(quantityordered) as quantityordered,
		p.quantityinstock - sum(od.quantityordered) as inventory_status
	from products p
	inner join orderdetails od on p.productcode = od.productcode
	group by p.productcode, p.productname) as summary;
-- 전체 재고자산 수 = 주문 수 + 현재 재고자산 수 = 검증값
-- 547,398 = 105,516 + 441,882

# [지표3] 매출액
select p.productcode,
	p.productname,
    sum(od.quantityordered * od.priceeach) as total_sale
from products p
inner join orderdetails od on p.productcode = od.productcode
group by p.productcode;

select sum(total_sale) as total_sale_sum,
	count(distinct(productcode)) as product
from (select p.productcode,
		p.productname,
		sum(od.quantityordered * od.priceeach) as total_sale
	from products p
	inner join orderdetails od on p.productcode = od.productcode
	group by p.productcode) as summary;
-- 주문 109개 매출액 합계 = 총 매출액  
-- 주문 109개 매출액 합계 = 9,604,190.61 
    
select sum(od.quantityordered * od.priceeach) as total_sale
from orderdetails as od;
-- 총 매출액 = 9,604,190.61 

# [지표4] 매출원가, 매출총이익
select p.productcode,
	p.productname,
    sum(od.quantityordered * od.priceeach) as total_sale,
    sum(od.quantityordered * p.buyprice) as cost_of_goods,
    sum(od.quantityordered * (od.priceeach-p.buyprice)) as gross_profit
from products p
inner join orderdetails od on p.productcode = od.productcode
group by p.productcode;

select sum(total_sale) as total_sale_sum,
	sum(cost_of_goods) as cost_of_goods_sum,
    sum(gross_profit) as gross_profit_sum,
    sum(cost_of_goods) + sum(gross_profit) as val_value
from (select p.productcode,
			p.productname,
			sum(od.quantityordered * od.priceeach) as total_sale,
			sum(od.quantityordered * p.buyprice) as cost_of_goods,
			sum(od.quantityordered * (od.priceeach-p.buyprice)) as gross_profit
	from products p
	inner join orderdetails od on p.productcode = od.productcode
	group by p.productcode) as summary;
-- 전체 매출액 = 전체 매출원가 + 전체 매출총이익 = 검증값
-- 9,604,190.61 = 5,778,310.36 + 3,825,880.25

# [지표5] 제품군별 매출액
select p.productline,
	count(distinct(p.productcode)) as product,
    sum(od.quantityordered) as order_quantity,
    sum(od.quantityordered * od.priceeach) as total_sale
from products p
inner join orderdetails od on p.productcode = od.productcode
group by p.productline;

select sum(product_quantity) as product,
	sum(order_quantity) as order_sum,
    sum(total_sale) as total_sale_sum
from (select p.productline,
		count(distinct(p.productcode)) as product_quantity,
		sum(od.quantityordered) as order_quantity,
		sum(od.quantityordered * od.priceeach) as total_sale
	from products p
	inner join orderdetails od on p.productcode = od.productcode
	group by p.productline) as summary_line;
-- 제품군별 레코드 전체 합계 = 제품별 레코드 전체 합계
-- 총 제품 수 109 / 주문량 105,516 / 전체 매출액 9,604,190.61 

select count(distinct(od.productcode)) as product,
	sum(od.quantityordered) as order_quantity, 
	sum(od.quantityordered * od.priceeach) as total_sale
from orderdetails as od;
-- 제품별 레코드 전체 합계
-- 총 제품 수 109 / 주문량 105,516 / 전체 매출액 9,604,190.61 