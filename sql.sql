CREATE DATABASE salesdb;
USE salesdb;
SELECT COUNT(*) AS transaction_count FROM `Transactions`;
SELECT COUNT(*) AS customer_count FROM `Customers`;
SELECT COUNT(*) AS rfm_rows FROM `RFM Analysis`;
SELECT COUNT(*) AS segment_rows FROM `Segment Summary`;
SELECT COUNT(*) AS rules_count FROM `Association Rules`;
SELECT
  NetAmount,
  TotalAmount,
  UnitPrice
FROM `transactions`
LIMIT 10;
DESCRIBE `transactions`;
DESCRIBE `customers`;
DESCRIBE `rfm_analysis`;
DESCRIBE `segment_summary`;
DESCRIBE `association_rules`;

#Check for NULL Keys
SELECT COUNT(*) FROM transactions WHERE CustomerID IS NULL;
SELECT COUNT(*) FROM transactions WHERE ProductID IS NULL;
SELECT COUNT(*) FROM customers WHERE CustomerID IS NULL;


#FOREGIN KEY Transactions → Customers
ALTER TABLE transactions
MODIFY COLUMN CustomerID VARCHAR(50);
ALTER TABLE transactions
MODIFY COLUMN ProductID VARCHAR(50);
ALTER TABLE customers
MODIFY COLUMN CustomerID VARCHAR(50);
ALTER TABLE customers
ADD PRIMARY KEY (CustomerID);
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_customers
FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);

#FOREGIN KEY Transactions → Products
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_products
FOREIGN KEY (ProductID) REFERENCES products(ProductID);

# the key analytics queries
#Total Sales
SELECT SUM(NetAmount) AS total_sales
FROM transactions;
#Total Unique Customers
SELECT COUNT(DISTINCT CustomerID) AS total_customers
FROM transactions;
#Monthly Sales Trend
SELECT
  DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
  SUM(NetAmount) AS monthly_sales
FROM transactions
GROUP BY month
ORDER BY month;
#Best-Selling Product (by Quantity)
SELECT 
  ProductName,
  SUM(Quantity) AS total_quantity
FROM transactions
GROUP BY ProductName
ORDER BY total_quantity DESC
LIMIT 10;
#Best-Revenue Product
SELECT 
  ProductName,
  SUM(NetAmount) AS total_revenue
FROM transactions
GROUP BY ProductName
ORDER BY total_revenue DESC
LIMIT 10;

#Single Customer View (Customer 360)
SELECT
  c.CustomerID,
  c.CustomerName,
  COUNT(t.InvoiceNo) AS total_orders,
  SUM(t.NetAmount) AS total_spent,
  MAX(t.InvoiceDate) AS last_purchase_date
FROM transactions t
JOIN customers c
  ON t.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY total_spent DESC;
