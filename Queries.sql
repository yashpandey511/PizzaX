USE PIZZAX;

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(ORDER_ID)
FROM
    ORDERS;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS SALES
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pt.name AS NAME, p.price AS PRICE
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    P.SIZE AS SIZE, SUM(OD.QUANTITY) AS QTY
FROM
    pizzas P
        JOIN
    order_details OD ON P.pizza_id = OD.pizza_id
GROUP BY SIZE
ORDER BY QTY DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS QTY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY QTY DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS QTY
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY QTY DESC;



-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.time), COUNT(order_details.order_id) AS QTY
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.time)
ORDER BY HOUR(orders.time) ASC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    CATEGORY, COUNT(NAME)
FROM
    pizza_types
GROUP BY CATEGORY;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ORDERS.DATE, SUM(ORDER_DETAILS.QUANTITY) AS QTY
FROM
    ORDERS
        JOIN
    ORDER_DETAILS ON ORDERS.ORDER_ID = ORDER_DETAILS.ORDER_ID
GROUP BY ORDERS.DATE;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.NAME,
    SUM(order_details.QUANTITY * pizzas.PRICE) AS REVENUE
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.NAME
ORDER BY REVENUE DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name AS Pizza_Type,
    SUM(od.quantity * p.price) AS Revenue,
    ROUND(SUM(od.quantity * p.price) * 100.0 / (SELECT SUM(od2.quantity * p2.price) 
                                                FROM order_details od2
                                                JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id), 2) AS Percentage_Contribution
FROM 
    order_details od
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.name
ORDER BY 
    Revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    SUM(od.quantity * p.price) AS Daily_Revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY order_date) AS Cumulative_Revenue
FROM 
    order_details od
JOIN 
    orders o ON od.order_id = o.order_id
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY date
ORDER BY date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH Pizza_Revenue AS (
    SELECT 
        pt.category AS Category,
        pt.name AS Pizza_Type,
        SUM(od.quantity * p.price) AS Revenue
    FROM 
        order_details od
    JOIN 
        pizzas p ON od.pizza_id = p.pizza_id
    JOIN 
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY 
        pt.category, pt.name
)
SELECT 
    Category,
    Pizza_Type,
    Revenue
FROM 
    (
        SELECT 
            Category,
            Pizza_Type,
            Revenue,
            ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Revenue DESC) AS RowNum
        FROM 
            Pizza_Revenue
    ) ranked
WHERE 
    RowNum <= 3
ORDER BY 
    Category, Revenue DESC;

