/*
Включить нового человека в таблицу с клиентами. Его имя Попов Илья,
его email popov@test, проживает он в Москве.
*/

INSERT INTO client(name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
  FROM city
 WHERE name_city = 'Москва';


/*
Создать новый заказ для Попова Ильи. Его комментарий для заказа:
«Связаться со мной по вопросу доставки».
Важно! В решении нельзя использоваться VALUES и делать отбор по client_id.
*/

INSERT INTO buy(buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки'
     , client_id
  FROM client
 WHERE name_client = 'Попов Илья';

SELECT * FROM buy;


/*
В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать
книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова
«Белая гвардия» в одном экземпляре.
*/

INSERT INTO buy_book(buy_id, book_id, amount)
SELECT 5, book_id, 2
  FROM book JOIN author USING(author_id)
 WHERE name_author = 'Пастернак Б.Л.' AND title = 'Лирика';

INSERT INTO buy_book(buy_id, book_id, amount)
SELECT 5, book_id, 1
  FROM book JOIN author USING(author_id)
 WHERE name_author = 'Булгаков М.А.' AND title = 'Белая гвардия';

SELECT * FROM buy_book;


/*
Количество тех книг на складе, которые были включены в заказ с номером 5,
уменьшить на то количество, которое в заказе с номером 5  указано.
*/

UPDATE book JOIN buy_book USING(book_id)
   SET book.amount = book.amount - buy_book.amount
 WHERE buy_id = 5;


/*
Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который
включить название книг, их автора, цену, количество заказанных книг и
стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести
в отсортированном по названиям книг виде.
*/

CREATE TABLE buy_pay AS
SELECT title
     , name_author
     , price
     , buy_book.amount
     , price * buy_book.amount AS Стоимость
  FROM author
       JOIN book     USING(author_id)
       JOIN buy_book USING(book_id)
 WHERE buy_id = 5
 ORDER BY title;


/*
Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5.
Куда включить номер заказа, количество книг в заказе (название столбца
Количество) и его общую стоимость (название столбца Итого).
Для решения используйте ОДИН запрос.
*/

CREATE TABLE buy_pay AS
SELECT buy_id
     , SUM(buy_book.amount)         AS Количество
     , SUM(price * buy_book.amount) AS Итого
  FROM book
       JOIN buy_book USING(book_id)
 WHERE buy_id = 5
 GROUP BY buy_id;

SELECT * FROM buy_pay;


/*
В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step,
которые должен пройти этот заказ. В столбцы date_step_beg и date_step_end
всех записей занести Null.
*/

INSERT INTO buy_step (buy_id, step_id)
SELECT buy_id
     , step_id
  FROM step
       CROSS JOIN buy
 WHERE buy_id = 5;

SELECT * FROM buy_step;


/*
В таблицу buy_step занести дату 12.04.2020 выставления
счета на оплату заказа с номером 5.
Правильнее было бы занести не конкретную, а текущую дату.
Это можно сделать с помощью функции Now(). Но при этом в разные
дни будут вставляться разная дата, и задание нельзя будет проверить,
поэтому  вставим дату 12.04.2020.
*/

UPDATE buy_step
   SET buy_step.date_step_beg = '2020.04.12'
 WHERE step_id = 1
       AND buy_id = 5;


/*
Завершить этап «Оплата» для заказа с номером 5, вставив в столбец
date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»),
задав в столбце date_step_beg для этого этапа ту же дату.
Реализовать два запроса для завершения этапа и начале следующего.
Они должны быть записаны в общем виде, чтобы его можно было применять
для любых этапов, изменив только текущий этап. Для примера пусть это
будет этап «Оплата».
*/

UPDATE buy_step, step
   SET buy_step.date_step_end = '2020.04.13'
 WHERE buy_id = 5 AND buy_step.step_id = (
                                          SELECT step_id
                                            FROM step
                                           WHERE name_step = 'Оплата'
                                          );
UPDATE buy_step, step
   SET buy_step.date_step_beg = '2020.04.13'
 WHERE buy_id = 5 AND buy_step.step_id = (
                                          SELECT step_id + 1
                                            FROM step
                                           WHERE name_step = 'Оплата'
                                          );

SELECT * FROM buy_step;