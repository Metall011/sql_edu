/*
Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и
в каком количестве он заказал) в отсортированном по номеру заказа и
названиям книг виде.
*/

SELECT buy_id
     , title
     , price
     , buy_book.amount
  FROM client
       JOIN buy      USING(client_id)
       JOIN buy_book USING(buy_id)
       JOIN book     USING(book_id)
 WHERE name_client = 'Баранов Павел'
 ORDER BY buy_id
        , title;


/*
Посчитать, сколько раз была заказана каждая книга, для книги вывести ее
автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).
Вывести фамилию и инициалы автора, название книги, последний столбец
назвать Количество. Результат отсортировать сначала  по фамилиям авторов,
а потом по названиям книг.
*/

SELECT name_author
     , title
     , COUNT(buy_book.book_id) AS Количество
  FROM author
       JOIN book     USING(author_id)
       LEFT JOIN buy_book USING(book_id)
 GROUP BY book_id
 ORDER BY 1
        , 2;


/*
Вывести города, в которых живут клиенты, оформлявшие заказы в
интернет-магазине. Указать количество заказов в каждый город,
этот столбец назвать Количество. Информацию вывести по убыванию количества
заказов, а затем в алфавитном порядке по названию городов.
*/

SELECT name_city
     , COUNT(*) AS Количество
  FROM buy
       JOIN client USING(client_id)
       JOIN city USING(city_id)
 GROUP BY name_city
 ORDER BY Количество DESC, name_city;


/*
Вывести номера всех оплаченных заказов и даты, когда они были оплачены.
*/

SELECT buy_id
     , date_step_end
  FROM buy_step
 WHERE step_id = 1
       AND date_step_end IS NOT NULL


/*
Вывести информацию о каждом заказе: его номер, кто его сформировал
(фамилия пользователя) и его стоимость (сумма произведений количества
заказанных книг и их цены), в отсортированном по номеру заказа виде.
Последний столбец назвать Стоимость.
*/

SELECT buy_id
     , name_client
     , SUM(buy_book.amount * price) AS Стоимость
  FROM client
       JOIN buy      USING(client_id)
       JOIN buy_book USING(buy_id)
       JOIN book     USING(book_id)
 GROUP BY 1, 2
 ORDER BY 1;


/*
Вывести номера заказов (buy_id) и названия этапов, на которых они в
данный момент находятся. Если заказ доставлен –  информацию о нем не
выводить. Информацию отсортировать по возрастанию buy_id.
*/

SELECT buy_id
     , name_step
  FROM step
       JOIN buy_step USING(step_id)
 WHERE date_step_beg     IS NOT NULL
       AND date_step_end IS NULL
 ORDER BY buy_id ASC;


/*
В таблице city для каждого города указано количество дней, за которые
заказ может быть доставлен в этот город (рассматривается только этап
Транспортировка). Для тех заказов, которые прошли этап транспортировки,
вывести количество дней за которое заказ реально доставлен в город.
А также, если заказ доставлен с опозданием, указать количество дней
задержки, в противном случае вывести 0. В результат включить номер
заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание.
Информацию вывести в отсортированном по номеру заказа виде.
/*

SELECT buy_id
     , DATEDIFF(date_step_end, date_step_beg) AS Количество_дней
     , IF(DATEDIFF(date_step_end, date_step_beg)<days_delivery,
         0, DATEDIFF(date_step_end, date_step_beg)-days_delivery)
       AS Опоздание
  FROM city
       JOIN client   USING(city_id)
       JOIN buy      USING(client_id)
       JOIN buy_step USING(buy_id)
       JOIN step     USING(step_id)
 WHERE name_step = 'Транспортировка'
       AND date_step_end IS NOT NULL;


/*
Выбрать всех клиентов, которые заказывали книги Достоевского, информацию
вывести в отсортированном по алфавиту виде. В решении используйте фамилию
автора, а не его id.
*/

SELECT DISTINCT name_client
  FROM author
       JOIN book      USING(author_id)
       JOIN buy_book  USING(book_id)
       JOIN buy       USING(buy_id)
       JOIN client    USING(client_id)
 WHERE name_author = 'Достоевский Ф.М.'
 ORDER BY 1;


/*
Вывести жанр (или жанры), в котором было заказано больше всего
экземпляров книг, указать это количество. Последний столбец назвать
Количество.
*/

SELECT name_genre
     , SUM(buy_book.amount) AS Количество
  FROM genre
       JOIN book     USING(genre_id)
       JOIN buy_book USING(book_id)
 GROUP BY name_genre
HAVING Количество = (
                     SELECT MAX(Maximum)
                     FROM (SELECT SUM(buy_book.amount) AS Maximum
                             FROM book
                                  JOIN buy_book USING(book_id)
                            GROUP BY genre_id
                          ) AS max_genre
                    );


/*
Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы.
Для этого вывести год, месяц, сумму выручки в отсортированном сначала по
возрастанию месяцев, затем по возрастанию лет виде. Название столбцов:
Год, Месяц, Сумма.
*/

SELECT YEAR(date_payment) AS Год
     , MONTHNAME(date_payment) AS Месяц
     , SUM(amount * price) AS Сумма
  FROM buy_archive
 GROUP BY 1, 2
UNION
SELECT YEAR(date_step_end) AS Год
     , MONTHNAME(date_step_end) AS Месяц
     , SUM(price * buy_book.amount) AS Сумма
  FROM book
       JOIN buy_book USING(book_id)
       JOIN buy      USING(buy_id)
       JOIN buy_step USING(buy_id)
 WHERE step_id = 1
       AND date_step_end
 GROUP BY 1, 2
 ORDER BY 2, 1;


/*
Для каждой отдельной книги необходимо вывести информацию о количестве
проданных экземпляров и их стоимости за 2020 и 2019 год . За 2020 год
проданными считать те экземпляры, которые уже оплачены. Вычисляемые
столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию
стоимости.
*/

SELECT title
     , SUM(Количество) AS Количество
     , SUM(Сумма)      AS Сумма
  FROM (SELECT title
            , SUM(buy_archive.amount) AS Количество
            , SUM(buy_archive.price * buy_archive.amount) AS Сумма
         FROM buy_archive
              JOIN book USING(book_id)
        GROUP BY title
       UNION ALL
       SELECT title
            , SUM(buy_book.amount)         AS Количество
            , SUM(price * buy_book.amount) AS Сумма
         FROM book
              JOIN buy_book USING(book_id)
              JOIN buy      USING(buy_id)
              JOIN buy_step USING(buy_id)
        WHERE date_step_end
              AND step_id = 1
        GROUP BY title
       ) AS books
GROUP BY title
ORDER BY 3 DESC;

