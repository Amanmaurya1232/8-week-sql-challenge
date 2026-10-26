use case_study_1_danny_diner;

## 1. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price)
from sales s join menu m on s.product_id=m.product_id
group by s.customer_id
order by customer_id;

##2. How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) as visit_days
from sales 
group by customer_id;

##3. What was the first item from the menu purchased by each customer?
with cte as(select customer_id,product_name,row_number()over(partition by customer_id order by order_date) as inde
from sales s join menu m on s.product_id=m.product_id
where s.order_date=(select min(se.order_date) from sales se where s.customer_id=se.customer_id order by order_date limit 1)
order by order_date )
select customer_id,product_name
from cte where inde=1;

##4. What is the most purchased item on the menu and how many times was it purchased by all customers?
with cte as (select product_id,count(*) as quantity
from sales
group by product_id
order by quantity desc limit 1)
select product_name,quantity 
from cte s join menu m on s.product_id=m.product_id
limit 1;

##5. Which item was the most popular for each customer?
with cte as(
select customer_id,s.product_id,count(s.product_id) as total_purchase from sales s join menu m on s.product_id=m.product_id
group by product_id,product_name,customer_id)
select customer_id,m.product_name,max(total_purchase) as total_purchase
from  cte s join menu m on s.product_id=m.product_id
where total_purchase=(select max(total_purchase) 
from cte 
where cte.customer_id=s.customer_id)
group by  customer_id,product_name;

##6. Which item was purchased first by the customer after they became a member?
with cte as (
select join_date,s.customer_id,order_date,product_id , row_number()over(partition by s.customer_id order by order_date ) as rnk
from members m 
join sales s on s.customer_id=m.customer_id
where join_date<=order_date
)
select distinct c.customer_id,product_name,rnk,order_date
from cte c join menu m on c.product_id=m.product_id
where rnk=1;

## 7. Which item was purchased just before the customer became a member?
with cte as (
select join_date,s.customer_id,order_date,product_id , row_number()over(partition by s.customer_id order by order_date desc ) as rnk
from members m 
join sales s on s.customer_id=m.customer_id
where join_date>order_date
)
select distinct c.customer_id,product_name,rnk,order_date
from cte c join menu m on c.product_id=m.product_id
where rnk=1;

##8. What is the total items and amount spent for each member before they became a member?
with cte as (
select join_date,s.customer_id,order_date,product_id , row_number()over(partition by s.customer_id order by order_date desc ) as rnk
from members m 
join sales s on s.customer_id=m.customer_id
where join_date>order_date
)
select count(c.product_id) as total_item,sum(price) as total_spent
from cte c join menu m on c.product_id=m.product_id;

##9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as(
select distinct product_id,product_name,case when product_name='sushi' then price*20
else price*10 end as points
from menu
)
select s.customer_id,sum(points) as total_points from sales s join cte c on s.product_id=c.product_id
group by s.customer_id;

##10. In the first week after a customer joins the program (including their join date) 
##they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte as(
select s.customer_id,s.product_id*20 as points,order_date,join_date
from sales s join members m on s.customer_id=m.customer_id
where order_date between join_date and date_add(join_date,interval 6 day) and order_date>=2021-01-30
)
select customer_id,sum(points) as total_points
from cte c
group by c.customer_id;

