-- Retrieve the total number of orders placed

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Calculate total revenue generated from the pizza sales

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS total_revenue
FROM
    pizzas AS p
        INNER JOIN
    orders_details AS o ON p.pizza_id = o.pizza_id;
    
-- identify the highest priced pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- identify most common pizza size ordered

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- list  the top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY qty
LIMIT 5;

-- join necessary tables to find total qty of each pizza ordered

SELECT 
    pizza_types.category, SUM(orders_details.quantity) AS qty
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY qty DESC;

-- Determine the distribution of orders by hout of the day

SELECT 
    HOUR(order_time) AS hrs, COUNT(order_id) as order_count
FROM
    orders
GROUP BY hrs;

-- Join relevant tables to find the category-wise distribution of pizzas

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day

with cte_pizza_qty as
(
SELECT 
        orders.order_date, SUM(orders_details.quantity) AS qty
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
)
select round(avg(qty)) from cte_pizza_qty
;

-- Determine the top 3 most ordered pizza types based on revenue

SELECT 
    pizza_types.name, SUM(price * quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(p.price * o.quantity) AS total_revenue
                FROM
                    pizzas AS p
                        INNER JOIN
                    orders_details AS o ON p.pizza_id = o.pizza_id)) * 100,
            2) AS precentage_revnue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY precentage_revnue DESC;

-- Analyze the cumulative revenue genearted over time

select 
	order_date, sum(revenue) over(order by order_date) as cummualtive_sum 
from 
	(select 
		orders.order_date, sum(orders_details.quantity*pizzas.price) as revenue
	from 
		pizzas join orders_details on pizzas.pizza_id = orders_details.pizza_id
	join 
		orders on orders.order_id = orders_details.order_id
	group by orders.order_date) as sales;
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select 
	name, revenue 
from
	(select 
		category, name, revenue, rank() over(partition by category order by revenue desc) as revenue_rank
	from
		(select 
			pizza_types.category, pizza_types.name, sum(orders_details.quantity*pizzas.price) as revenue
		from 
			pizza_types join pizzas on pizza_types.pizza_type_id =pizzas.pizza_type_id
		join 
			orders_details on orders_details.pizza_id = pizzas.pizza_id
		group by pizza_types.category, pizza_types.name
		order by revenue desc) as a) as b
where revenue_rank<=3 ;