/*
В таблицу attempt включить новую попытку для студента Баранова Павла
по дисциплине «Основы баз данных». Установить текущую дату в качестве даты
выполнения попытки.
*/

INSERT INTO attempt(student_id, subject_id, date_attempt)
SELECT student_id
     , subject_id
     , NOW()
  FROM student
       JOIN attempt USING(student_id)
       JOIN subject USING(subject_id)
 WHERE name_student = 'Баранов Павел'
       AND name_subject = 'Основы баз данных';

SELECT * FROM attempt;


/*
Случайным образом выбрать три вопроса (запрос) по дисциплине,
тестирование по которой собирается проходить студент, занесенный в таблицу
attempt последним, и добавить их в таблицу testing. id последней попытки
получить как максимальное значение id из таблицы attempt.
*/

INSERT INTO testing (attempt_id, question_id, answer_id)
SELECT attempt_id
     , question_id
     , NULL
  FROM attempt
       JOIN question USING(subject_id )
 WHERE attempt.attempt_id = (SELECT MAX(attempt_id) FROM attempt)
 ORDER BY RAND()
 LIMIT 3;

SELECT * FROM testing;


/*
Студент прошел тестирование (то есть все его ответы занесены в таблицу
testing), далее необходимо вычислить результат(запрос) и занести его в
таблицу attempt для соответствующей попытки.  Результат попытки вычислить
как количество правильных ответов, деленное на 3 (количество вопросов в
каждой попытке) и умноженное на 100. Результат округлить до целого.
Будем считать, что мы знаем id попытки,  для которой вычисляется результат,
в нашем случае это 8.
*/

UPDATE attempt
   SET result = (
                 SELECT SUM(is_correct) / 3 * 100
                   FROM answer
                        JOIN testing USING(answer_id)
                  WHERE attempt_id = 8
                )
 WHERE attempt_id = 8;


/*
Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года.
Также удалить и все соответствующие этим попыткам вопросы из таблицы testing
*/

DELETE FROM attempt
 WHERE DATEDIFF(date_attempt, '2020.05.01') < 0;

SELECT * FROM attempt;
SELECT * FROM testing;


