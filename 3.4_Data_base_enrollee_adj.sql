/*
Создать вспомогательную таблицу applicant,  куда включить id образовательной
программы, id абитуриента, сумму баллов абитуриентов (столбец itog) в
отсортированном сначала по id образовательной программы, а потом по
убыванию суммы баллов виде (использовать запрос из предыдущего урока).
*/

CREATE TABLE applicant AS
SELECT program.program_id
     , enrollee.enrollee_id
     , SUM(result) AS itog
  FROM enrollee
       JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
       JOIN program          ON program_enrollee.program_id = program.program_id
       JOIN program_subject  ON program.program_id = program_subject.program_id
       JOIN subject          ON program_subject.subject_id = subject.subject_id
       JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id
 WHERE enrollee_subject.enrollee_id = enrollee.enrollee_id
 GROUP BY 1, enrollee.enrollee_id
 ORDER BY 1, 3 DESC;


/*
Из таблицы applicant, созданной на предыдущем шаге, удалить записи, если
абитуриент на выбранную образовательную программу не набрал минимального
балла хотя бы по одному предмету (использовать запрос из предыдущего урока).
*/

DELETE FROM applicant
 USING applicant
       JOIN enrollee         ON enrollee.enrollee_id = applicant.enrollee_id
       JOIN program_enrollee ON enrollee.enrollee_id = program_enrollee.enrollee_id
       JOIN program          ON program_enrollee.program_id = program.program_id
       JOIN program_subject  ON program.program_id = program_subject.program_id
                                AND applicant.program_id = program_subject.program_id
       JOIN subject          ON program_subject.subject_id = subject.subject_id
       JOIN enrollee_subject ON subject.subject_id = enrollee_subject.subject_id
                                AND enrollee_subject.enrollee_id = enrollee.enrollee_id
 WHERE result < min_result;


/*
Повысить итоговые баллы абитуриентов в таблице applicant на значения
дополнительных баллов (использовать запрос из предыдущего урока).
*/

UPDATE applicant
       LEFT JOIN (
                  SELECT enrollee_id
                       , IFNULL(SUM(bonus), 0) AS Бонус
                    FROM achievement
                         JOIN enrollee_achievement USING(achievement_id)
                         RIGHT JOIN enrollee USING(enrollee_id)
                   GROUP BY enrollee_id
                 ) AS bonus USING(enrollee_id)
   SET itog = itog + Бонус;


/*
Поскольку при добавлении дополнительных баллов, абитуриенты по каждой
образовательной программе могут следовать не в порядке убывания суммарных баллов,
необходимо создать новую таблицу applicant_order на основе таблицы applicant.
При создании таблицы данные нужно отсортировать сначала по id образовательной
программы, потом по убыванию итогового балла. А таблицу applicant, которая была
создана как вспомогательная, необходимо удалить.
*/

CREATE TABLE applicant_order AS
SELECT *
  FROM applicant
 ORDER BY program_id, itog DESC;

DROP TABLE applicant;


/*
Включить в таблицу applicant_order новый столбец str_id целого типа ,
расположить его перед первым.
*/

ALTER TABLE applicant_order ADD str_id INT FIRST;


/*
Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов,
которая начинается с 1 для каждой образовательной программы.
*/

SET @num_pr  := 0;
SET @row_num := 1;

UPDATE applicant_order
   SET str_id = IF(@num_pr = program_id, @row_num := @row_num + 1, @row_num := 1 AND @num_pr := program_id);

SELECT * FROM applicant_order;


/*
Создать таблицу student,  в которую включить абитуриентов, которые могут быть
рекомендованы к зачислению  в соответствии с планом набора. Информацию
отсортировать сначала в алфавитном порядке по названию программ, а потом по
убыванию итогового балла.
*/

CREATE TABLE student AS
SELECT name_program
     , name_enrollee
     , itog
  FROM enrollee
       JOIN applicant_order USING(enrollee_id)
       JOIN program         USING(program_id)
 WHERE plan >= str_id
 ORDER BY 1, 3 DESC;

SELECT * FROM student;
