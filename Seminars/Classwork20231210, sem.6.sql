/*
select * from workers;

set transaction_isolation='READ-UNCOMMITTED';
set transaction_isolation='READ-COMMITTED';
set transaction_isolation='REPEATABLE-READ';
set transaction_isolation='SERIALIZABLE';
show  variables like 'transaction_isolation';

start TRANSACTION;

update workers set name = "Вася7" where id = 1;

insert into workers(name, surname, speciality, seniority, salary, age)
values('Вова', 'Морозов', 'программист', 30, 10000, 52);

commit;

rollback;
*/

/*
CREATE DATABASE lesson_6;
USE lesson_6;
*/

/*
CREATE TABLE `workers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `surname` varchar(50) NOT NULL,
  `speciality` varchar(50) NOT NULL,
  `seniority` int NOT NULL DEFAULT (0),
  `salary` int NOT NULL DEFAULT (3000),
  `age` int NOT NULL DEFAULT (18),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

*/

/*
Задача 1.  Создайте процедуру, которая выберет для одного пользователя 5 пользователей 
в случайной комбинации, которые удовлетворяют хотя бы одному критерию:

1) из одного города 
2) состоят в одной группе
3) друзья друзей
*/

DROP PROCEDURE IF EXISTS task1;
DELIMITER \\
CREATE PROCEDURE task1 (my_id BIGINT) 
BEGIN
	
	SELECT U.id, U.firstname, U.lastname 
    FROM users AS U
    INNER JOIN profiles AS P
    ON U.id = P.user_id
    WHERE P.hometown = (SELECT hometown FROM profiles WHERE user_id = my_id) AND U.id != my_id
    UNION
    SELECT U.id, U.firstname, U.lastname 
    FROM users AS U
    INNER JOIN users_communities AS UC
    ON U.id = UC.user_id
    WHERE UC.community_id IN (SELECT community_id FROM users_communities WHERE user_id = my_id) AND U.id != my_id
    UNION
    SELECT U.id, U.firstname, U.lastname 
    FROM users AS U
    WHERE U.id IN
    (SELECT initiator_user_id FROM friend_requests
	WHERE target_user_id IN (SELECT friend_id FROM friends WHERE id = my_id) AND status =  'approved' AND initiator_user_id != my_id 
	UNION
	SELECT target_user_id FROM friend_requests 
	WHERE initiator_user_id IN (SELECT friend_id FROM friends WHERE id = my_id) AND status =  'approved' AND target_user_id != my_id)
    ORDER BY rand() LIMIT 5;

END \\
DELIMITER ;

INSERT INTO users(id, firstname, lastname, email) 
VALUES (11, "Ivan", "Ivanov", "email@email.com");

INSERT INTO profiles(user_id, gender, birthday, hometown)
VALUES (11, "m", "2023-12-10", "Adriannaport");


CALL task1(1);

SELECT * FROM users INNER JOIN profiles ON users.id = profiles.user_id;

SELECT * FROM users_communities;

SELECT * FROM friends WHERE id = 1;

/*
Задача 2.  Создание функции, вычисляющей коэффициент популярности пользователя 
(по заявкам на дружбу – таблица friend_requests)
*/

DROP FUNCTION IF EXISTS task2;
DELIMITER \\
CREATE FUNCTION task2 (my_id BIGINT) RETURNS FLOAT READS SQL DATA 
BEGIN
	DECLARE cnt_my_id INT;
    DECLARE cnt INT;
	SET cnt_my_id = (SELECT COUNT(*) FROM friend_requests WHERE target_user_id = my_id);
    SET cnt = (SELECT COUNT(*) FROM users);
    RETURN cnt_my_id / cnt;
END \\
DELIMITER ; 

SELECT task2(1);

/*
Задача 3.  Необходимо перебрать всех пользователей и тем пользователям, 
у которых дата рождения меньше определенной даты обновить дату 
рождения на  сегодняшнюю дату.  (реализация с помощью цикла)
*/

DROP PROCEDURE IF EXISTS task3;
DELIMITER \\
CREATE PROCEDURE task3 (my_birthdate DATE)
BEGIN
	DECLARE my_id BIGINT;
    DECLARE done INT DEFAULT 0;
    DECLARE my_cur CURSOR FOR SELECT P.user_id FROM profiles AS P WHERE P.birthday > my_birthdate;
    DECLARE continue handler for sqlstate '02000' SET done = 1; 
    OPEN my_cur;
    WHILE done = 0 DO
		FETCH my_cur INTO my_id;
        UPDATE profiles SET birthday = NOW() WHERE user_id = my_id;
    END WHILE;
    CLOSE my_cur;
END \\
DELIMITER ;

SELECT * FROM profiles;

CALL task3("2000-01-01");

DROP PROCEDURE IF EXISTS task4;
DELIMITER \\
CREATE PROCEDURE task4 (
	my_id BIGINT, 
	my_firstname VARCHAR(50), 
    my_lastname VARCHAR(50), 
    my_email VARCHAR(120),
    my_gender CHAR(1),
    my_birthday DATE,
    my_hometown VARCHAR(100))
BEGIN
	START TRANSACTION;
		INSERT INTO users(id, firstname, lastname, email) 
		VALUES (my_id, my_firstname, my_lastname, my_email);
		INSERT INTO profiles(user_id, gender, birthday, hometown)
		VALUES (my_id, my_gender, my_birthday, my_hometown);	
	COMMIT;
END \\
DELIMITER ;

CALL task4(12,"Petr","Petrov","email@email.ru","m","2023-12-09","Moskow");

SELECT * FROM profiles;

SELECT * FROM users;

/*
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
        BEGIN
            ROLLBACK;
            RESIGNAL;
        END;

    START TRANSACTION;
        -- .. Query 1 ..
        -- .. Query 2 ..
        -- .. Query 3 ..
    COMMIT;
END;

https://stackoverflow.com/questions/9974325/mysql-transaction-within-a-stored-procedure
*/








