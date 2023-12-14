CREATE TABLE movies 
	(id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    title_eng VARCHAR(255),
    year_movie INT NOT NULL,
    count_min INT,
    storyline TEXT
    );

INSERT INTO movies 
		(title, title_eng, year_movie, count_min, storyline)
        VALUES
        ("Назад в будущее", "Back to the Future", 1985, 116, "Подросток Марти с помощью машины времени, сооружённой его другом-профессором доком Брауном, попадает из 80-х в далекие 50-е. Там он встречается со своими будущими родителями, ещё подростками, и другом-профессором, совсем молодым."),
        ("Иван Васильевич меняет профессию", "", 1973, 128, "Инженер-изобретатель Тимофеев сконструировал машину времени, которая соединила его квартиру с далеким шестнадцатым веком - точнее, с палатами государя Ивана Грозного. Туда-то и попадают тезка царя пенсионер-общественник Иван Васильевич Бунша и квартирный вор Жорж Милославский. На их место в двадцатом веке «переселяется» великий государь. Поломка машины приводит ко множеству неожиданных и забавных событий..."),
        ("Криминальное чтиво","Pulp Fiction", 1994, 154, ""),
        ("Форрест Гамп", "Forrest Gump", 1994, 142, "Сидя на автобусной остановке, Форрест Гамп — не очень умный, но добрый и открытый парень — рассказывает случайным встречным историю своей необыкновенной жизни. С самого малолетства парень страдал от заболевания ног, соседские мальчишки дразнили его, но в один прекрасный день Форрест открыл в себе невероятные способности к бегу. Подруга детства Дженни всегда его поддерживала и защищала, но вскоре дороги их разошлись."),
        ("Игры разума", "A Beautiful Mind", 2001, 135, "От всемирной известности до греховных глубин — все это познал на своей шкуре Джон Форбс Нэш-младший. Математический гений, он на заре своей карьеры сделал титаническую работу в области теории игр, которая перевернула этот раздел математики и практически принесла ему международную известность. Однако буквально в то же время заносчивый и пользующийся успехом у женщин Нэш получает удар судьбы, который переворачивает уже его собственную жизнь.");
        
RENAME TABLE movies TO cinema;

ALTER TABLE cinema 
	ADD COLUMN status_active BIT, 
    ADD COLUMN genre_id BIGINT UNSIGNED AFTER title_eng; 
    
CREATE TABLE actors 
	(id SERIAL PRIMARY KEY,
    name VARCHAR(100)
    );
    
DROP TABLE actors;

CREATE TABLE genre 
	(id SERIAL PRIMARY KEY,
    title VARCHAR(100)
    );

INSERT INTO genre (title)
	VALUES ("Боевик"), ("Комедия");
    
SELECT * FROM genre;

DELETE FROM genre WHERE id = 1;

DELETE FROM genre;

// Удалить все позиции из таблицы (но не саму таблицу)
TRUNCATE TABLE genre;

// ЗАдаем внешний ключ на таблицу cinema (REFERENCES - это ссылка)
ALTER TABLE cinema
	ADD FOREIGN KEY (genre_id) REFERENCES genre(id);
    
SELECT * FROM cinema;

UPDATE cinema SET genre_id = 1 WHERE id IN (1, 3, 5); 

UPDATE cinema SET genre_id = 2 WHERE id IN (2, 4);

SELECT * FROM cinema INNER JOIN genre ON cinema.genre_id = genre.id;

//Добавить колонку age_category, выведите id, название фильма
и категорию фильма, согласно следующего
перечня:
Д- Детская, П – Подростковая,
В – Взрослая, Не указана

ALTER TABLE cinema 
	ADD COLUMN age_category VARCHAR(1);
    
UPDATE cinema SET age_category = "Д" WHERE id = 1;

UPDATE cinema SET age_category = "П" WHERE id IN (3, 4, 5);

UPDATE cinema SET age_category = "В" WHERE id = 2;

UPDATE cinema SET count_min = 75 WHERE id = 1;

SELECT title, count_min,
	IF(count_min < 50, "Короткометражный", IF(count_min < 100,"Среднеметражный","Полнометражный")) AS cinema_type 
    FROM cinema;

SELECT title, count_min,
	CASE
		WHEN count_min < 50 THEN "Короткометражный"
        WHEN count_min BETWEEN 50 AND 100 THEN "Среднеметражный"
        WHEN count_min > 100 THEN "Полнометражный"
        ELSE "Неопределен"
    END    
    AS cinema_type 
    FROM cinema;

INSERT INTO cinema 
		(title, title_eng, year_movie, storyline)
        VALUES
        ("Назад в будущее 2", "Back to the Future 2", 1985, "Подросток Марти с помощью машины времени, сооружённой его другом-профессором доком Брауном, попадает из 80-х в далекие 50-е. Там он встречается со своими будущими родителями, ещё подростками, и другом-профессором, совсем молодым.");
