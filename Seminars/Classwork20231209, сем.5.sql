DROP DATABASE IF EXISTS lesson_5;
CREATE DATABASE lesson_5;
USE lesson_5;

-- Персонал
DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	firstname VARCHAR(45),
	lastname VARCHAR(45),
	post VARCHAR(100),
	seniority INT, 
	salary INT, 
	age INT
);

-- Наполнение данными
INSERT INTO staff (firstname, lastname, post, seniority, salary, age)
VALUES
('Вася', 'Петров', 'Начальник', '40', 100000, 60),
('Петр', 'Власов', 'Начальник', '8', 70000, 30),
('Катя', 'Катина', 'Инженер', '2', 70000, 25),
('Саша', 'Сасин', 'Инженер', '12', 50000, 35),
('Ольга', 'Васютина', 'Инженер', '2', 70000, 25),
('Петр', 'Некрасов', 'Уборщик', '36', 16000, 59),
('Саша', 'Петров', 'Инженер', '12', 50000, 49),
('Иван', 'Сидоров', 'Рабочий', '40', 50000, 59),
('Петр', 'Петров', 'Рабочий', '20', 25000, 40),
('Сидр', 'Сидоров', 'Рабочий', '10', 20000, 35),
('Антон', 'Антонов', 'Рабочий', '8', 19000, 28),
('Юрий', 'Юрков', 'Рабочий', '5', 15000, 25),
('Максим', 'Максимов', 'Рабочий', '2', 11000, 22),
('Юрий', 'Галкин', 'Рабочий', '3', 12000, 24),
('Людмила', 'Маркина', 'Уборщик', '10', 10000, 49),
('Юрий', 'Онегин', 'Начальник', '8', 100000, 39);

-- Оценки учеников
DROP TABLE IF EXISTS academic_record;
CREATE TABLE academic_record (
	id INT AUTO_INCREMENT PRIMARY KEY, 
	name VARCHAR(45),
	quartal  VARCHAR(45),
    subject VARCHAR(45),
	grade INT
);

INSERT INTO academic_record (name, quartal, subject, grade)
values
	('Александр','1 четверть', 'математика', 4),
	('Александр','2 четверть', 'русский', 4),
	('Александр', '3 четверть','физика', 5),
	('Александр', '4 четверть','история', 4),
	('Антон', '1 четверть','математика', 4),
	('Антон', '2 четверть','русский', 3),
	('Антон', '3 четверть','физика', 5),
	('Антон', '4 четверть','история', 3),
    ('Петя', '1 четверть', 'физика', 4),
	('Петя', '2 четверть', 'физика', 3),
	('Петя', '3 четверть', 'физика', 4),
	('Петя', '2 четверть', 'математика', 3),
	('Петя', '3 четверть', 'математика', 4),
	('Петя', '4 четверть', 'физика', 5);
    
/*
	Примеры. 
	1. Вывести список всех сотрудников и указать место в рейтинге по зарплатам
*/

SELECT * FROM staff;

SELECT firstname, lastname, salary,
dense_rank() OVER(ORDER BY salary DESC) 
FROM staff;   

SELECT firstname, lastname, salary,
rank() OVER(ORDER BY salary DESC) 
FROM staff;  

SELECT firstname, lastname, salary, post,
dense_rank() OVER(PARTITION BY post ORDER BY salary DESC) 
FROM staff; 

SELECT * FROM 
(SELECT firstname, lastname, salary, post,
max(salary) OVER(PARTITION BY post ORDER BY salary DESC) AS maxsalary 
FROM staff) AS tabl1
WHERE salary = maxsalary; 

SELECT firstname, lastname, salary, post,
rank() OVER(PARTITION BY post ORDER BY salary DESC)  
FROM staff;

/*
	Вывести список всех сотрудников, отсортировав по зарплатам в порядке убывания 
	и указать на сколько процентов ЗП меньше, чем у сотрудника со следующей (по значению) зарплатой
*/

SELECT firstname, lastname, salary, post,
LEAD(salary) OVER(ORDER BY salary DESC) AS nextsalary,
100*(salary - LEAD(salary) OVER(ORDER BY salary DESC))/salary AS diff 
FROM staff;

/*
Вывести всех сотрудников, отсортировав по зарплатам в рамках каждой должности и рассчитать:
-- общую сумму зарплат для каждой должности
-- процентное соотношение каждой зарплаты от общей суммы по должности
-- среднюю зарплату по каждой должности 
-- процентное соотношение каждой зарплаты к средней зарплате по должности 
Вывести список всех сотрудников и указать место в рейтинге по зарплатам, но по каждой должности
*/

SELECT firstname, lastname, salary, post,
SUM(salary) OVER(PARTITION BY post) AS sumsalary,
100*salary / (SUM(salary) OVER(PARTITION BY post)) AS percent_of_sum_salary,
AVG(salary) OVER(PARTITION BY post) AS avgsalary,
100*salary / (AVG(salary) OVER(PARTITION BY post)) AS percent_of_avg_salary 
FROM staff;

SELECT firstname, lastname, salary, post,
SUM(salary) OVER post_window AS sumsalary,
100*salary / (SUM(salary) OVER post_window) AS percent_of_sum_salary,
AVG(salary) OVER post_window AS avgsalary,
100*salary / (AVG(salary) OVER post_window) AS percent_of_avg_salary 
FROM staff WINDOW post_window AS (PARTITION BY post);


/*
средний балл ученика 
наименьшую оценку ученика
наибольшую оценку ученика
сумму всех оценок
количество всех оценок
*/

SELECT * FROM academic_record;

SELECT name, quartal, subject,
AVG(grade) OVER pupil,
MIN(grade) OVER pupil,
MAX(grade) OVER pupil,
SUM(grade) OVER pupil,
COUNT(grade) OVER pupil
FROM academic_record WINDOW 
pupil AS (PARTITION BY name);

/*
Получить информацию об оценках 
Пети по физике по четвертям:  текущая успеваемость 
оценка в следующей четверти
оценка в предыдущей четверти
*/

SELECT name, quartal, subject, grade,
LEAD(grade) OVER pupil,
LAG(grade) OVER pupil
FROM academic_record
WHERE name = "Петя" AND subject = "физика"
WINDOW pupil AS (ORDER BY quartal);

/*
Существует в течении сессии 
CREATE TEMPORARY TABLE new_tbl 
SELECT * FROM orig_tbl LIMIT 0;

Существует во время исполнения запроса
WITH
  cte1 AS (SELECT a, b FROM table1),
  cte2 AS (SELECT c, d FROM table2)
SELECT b, d FROM cte1 JOIN cte2
WHERE cte1.a = cte2.c;

CREATE OR REPLACE VIEW v_tbl AS 
SELECT * FROM orig_tbl LIMIT 0;
*/

/*
создайте представление, в котором будут выводится все сообщения, 
в которых принимал участие пользователь с id = 1;
*/

USE lesson_4;

CREATE VIEW view1 AS
SELECT body 
FROM messages
WHERE from_user_id = 1 OR to_user_id = 1;

SELECT * FROM view1;

/*
найдите друзей у друзей пользователя с id = 1 и поместите выборку в представление; 
(решение задачи с помощью CTE)
*/

SELECT * FROM friend_requests WHERE status =  'approved';

WITH 
	friends_of_1 AS 
		(SELECT initiator_user_id AS id FROM friend_requests 
		WHERE target_user_id = 1 AND status =  'approved'
		UNION
		SELECT target_user_id FROM friend_requests 
		WHERE initiator_user_id = 1 AND status =  'approved')
SELECT initiator_user_id FROM friend_requests
	WHERE target_user_id IN (SELECT id FROM friends_of_1) AND status =  'approved' AND initiator_user_id != 1
UNION 
SELECT target_user_id FROM friend_requests 
	WHERE initiator_user_id IN (SELECT id FROM friends_of_1) AND status =  'approved' AND target_user_id != 1;

CREATE VIEW friends_of_friends_of_1 AS
WITH 
	friends_of_1 AS 
		(SELECT initiator_user_id AS id FROM friend_requests 
		WHERE target_user_id = 1 AND status =  'approved'
		UNION
		SELECT target_user_id FROM friend_requests 
		WHERE initiator_user_id = 1 AND status =  'approved')
SELECT initiator_user_id FROM friend_requests
	WHERE target_user_id IN (SELECT id FROM friends_of_1) AND status =  'approved' AND initiator_user_id != 1
UNION 
SELECT target_user_id FROM friend_requests 
	WHERE initiator_user_id IN (SELECT id FROM friends_of_1) AND status =  'approved' AND target_user_id != 1;

SELECT * FROM friends_of_friends_of_1;


/*
3.  найдите друзей у  друзей пользователя с id = 1. 
(решение задачи с помощью представления “друзья”)
*/

WITH 
	friends AS 
		(SELECT initiator_user_id AS id, target_user_id AS friend_id FROM friend_requests 
		WHERE status =  'approved'
		UNION
		SELECT target_user_id, initiator_user_id FROM friend_requests 
		WHERE status =  'approved')
SELECT * FROM friends
WHERE id = 10;

CREATE OR REPLACE VIEW friends AS
WITH 
	friends AS 
		(SELECT initiator_user_id AS id, target_user_id AS friend_id FROM friend_requests 
		WHERE status =  'approved'
		UNION
		SELECT target_user_id, initiator_user_id FROM friend_requests 
		WHERE status =  'approved')
SELECT * FROM friends;

SELECT * FROM friends;

SELECT initiator_user_id FROM friend_requests
	WHERE target_user_id IN (SELECT friend_id FROM friends WHERE id = 1) AND status =  'approved' AND initiator_user_id != 1 
UNION 
SELECT target_user_id FROM friend_requests 
	WHERE initiator_user_id IN (SELECT friend_id FROM friends WHERE id = 1) AND status =  'approved' AND target_user_id != 1;

SELECT * FROM friends_of_friends_of_1;
	




