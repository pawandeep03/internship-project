
CREATE TABLE Dim_Customer (
    customer_id INT PRIMARY KEY,
    region VARCHAR(50),
    join_date DATE
);

CREATE TABLE Dim_Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE Fact_Sales (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    sales_amount DECIMAL(10,2)
);

DELETE FROM Fact_Sales WHERE sales_amount IS NULL OR sales_amount <= 0;

CREATE VIEW vw_single_customer_view AS
SELECT customer_id,
       MAX(order_date) AS last_purchase_date,
       COUNT(transaction_id) AS frequency,
       SUM(sales_amount) AS monetary
FROM Fact_Sales
GROUP BY customer_id;
