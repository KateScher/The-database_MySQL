INSERT INTO itresume5848463.sales (id, order_date, count_product)
VALUES 
(1, '2022-01-01', 156),
(2, '2022-01-02', 180),
(3, '2022-01-03', 21),
(4, '2022-01-04', 124),
(5, '2022-01-05', 341);

SELECT 
	id AS 'номер заказа',
	IF (count_product < 100, 'Маленький заказ', 
		IF (count_product BETWEEN 100 AND 300, 'Средний заказ', 'Большой заказ')
	) AS 'Тип заказа'	
FROM sales;
