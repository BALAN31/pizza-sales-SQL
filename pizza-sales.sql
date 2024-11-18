create database pizzahut;

use pizzahut;


----- Retrieve  total number of orders placed;

SELECT COUNT(order_id) AS total_orders
FROM orders;


----- calaculte the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
FROM
    order_details
JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
  
     
----- idefify the highst priced pizza.

SELECT
    pizza_types.name,
    pizzas.price
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY
    pizzas.price DESC
LIMIT 1;

 ----- idefify the most common pizza orderd .
 
 select
	 pizzas.size,
	 count(order_details.order_details_id) as order_count
 from
	 pizzas
 join
     order_details on pizzas.pizza_id = order_details.pizza_id
 group by pizzas.size  
 order by order_count desc;
	
 
 ----- list the top 5  most orderd pizza tupes along with their quantities.
 
 SELECT
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
    pizza_types.name
ORDER BY
    quantity DESC
LIMIT 5;

 
   ----- join the necessary tables to find the total the quqntity of each pizza category orderd.
   
 SELECT
    pizzas.name,  
    SUM(order_details.quantity) AS total_quantity
FROM
    pizzas
JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
    pizzas.name  -- Group by pizza name if you prefer
ORDER BY
    total_quantity DESC;


      
  ----- determine the distribution of orders by hour of the day.
  
 SELECT
    HOUR(order_time) AS hours,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY
    HOUR(order_time)
ORDER BY
    hours;



----- join the relevent tables to find the category - wise  distribution of pizzas .

SELECT category, COUNT(name) AS name_count
FROM pizza_types
GROUP BY category;


----- group the oders by date  and culculate the averge number of pizzas order per day . 

SELECT
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT
        orders.order_date,
        SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_id) AS order_quantity;


----- detemine the top 3 most orderd pizza tupes based on revenue . 


SELECT pizza_types.name,
       SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

----- calculte the percentage contribution of each pizza tupe to total revenue . 


SELECT 
    pizza_types.category,
    ROUND(
        SUM(order_details.quantity * pizzas.price) / 
        (SELECT 
             ROUND(SUM(order_details.quantity * pizzas.price), 2) 
          FROM 
             order_details
          JOIN 
             pizzas ON pizzas.pizza_id = order_details.pizza_id
        ) * 100, 2
    ) AS revenue
FROM 
    pizza_types 
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    revenue DESC;
    
    
    
    ----- analyze the cumulative  revenue  generated over time . 
    
   SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        DATE(orders.created_at) AS order_date, 
        SUM(order_details.quantity * pizzas.price) AS revenue 
    FROM 
        order_details 
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = order_details.order_id
    GROUP BY 
        DATE(orders.created_at)
) AS sales;

----- determine the top  3 most orderd pizza tupes based on revenue for each pizza category . 


SELECT 
    name, 
    revenue
FROM (
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name AS name, -- Assuming `name` is in `pizza_types`
            SUM(order_details.quantity * pizzas.price) AS revenue 
        FROM 
            pizza_types
        JOIN 
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN 
            order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY 
            pizza_types.category, pizza_types.name -- Adjust grouping accordingly
    ) AS ranked_data
) AS final_data
WHERE rn <= 3;


       
    
