--ЗАПРОСЫ НА ВЫБОРКУ

/* 1. Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести по убыванию результатов тестирования.*/

select name_student, date_attempt, result
from subject join attempt using (subject_id)
join student using (student_id)
where name_subject = 'Основы баз данных'
order by result desc;

/* 2. Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.*/

select name_subject, count(result) as Количество, round(avg(result),2) as Среднее
from subject left join attempt  using (subject_id)
group by  subject_id
order by name_subject;

/* 3. Вывести студентов (различных студентов), имеющих максимальные результаты попыток . Информацию отсортировать в алфавитном порядке по фамилии студента.*/

select name_student, result
from student join attempt using (student_id)
where result = (select max(result) from attempt)
order by result desc;

/* 4. Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. */

select name_student, name_subject, DATEDIFF(max(date_attempt), min(date_attempt)) as Интервал
from subject join attempt using (subject_id)
             join student using (student_id)
group by student_id, subject_id
having count(subject_id)>=2
order by Интервал

/* 5. Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.*/

select name_subject, count(student_id) as Количество
from (select name_subject, student_id
      from subject left join attempt using (subject_id)
      group by student_id,name_subject) as new
group by name_subject
order by Количество desc,name_subject;

/* 6. Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.*/

select question_id, name_question
from subject join question using (subject_id)
where name_subject = 'Основы баз данных'
ORDER BY RAND()
limit 3

/* 7. Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет (вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.*/

select name_question, name_answer, if(is_correct=1,'Верно','Неверно') as Результат
from question join testing using (question_id)
              join answer using (answer_id)
where subject_id = 1 and attempt_id=7;

/* 8. Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой. Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.*/

select name_student, name_subject, date_attempt, round((sum(is_correct)/3*100),2) as Результат
from attempt join student using (student_id)
            join subject using (subject_id)
            join testing using(attempt_id)
            join answer using(answer_id)
group by name_student, name_subject, date_attempt
order by name_student, date_attempt desc;

/* 9. Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.
Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".*/

SELECT name_subject,
       CONCAT(LEFT(name_question, 30), '...')              AS Вопрос,
       COUNT(is_correct)                                   AS Всего_ответов, 
       ROUND(SUM(is_correct) / COUNT(is_correct) * 100, 2) AS Успешность
FROM testing t INNER JOIN answer a USING (answer_id)
               RIGHT JOIN question q ON q.question_id = a.question_id
               INNER JOIN subject s  ON s.subject_id = q.subject_id
GROUP BY name_subject, name_question 
ORDER BY name_subject, Успешность DESC, name_question;

-- ЗАПРОСЫ КОРРЕКТИРОВКИ

/* 1. В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». Установить текущую дату в качестве даты выполнения попытки.*/

insert into attempt (student_id, subject_id, date_attempt)
select student_id, subject_id, now()
from student join attempt using (student_id)
            join subject using (subject_id)
where name_subject= 'Основы баз данных' and name_student= 'Баранов Павел';

/* 2. Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент, занесенный в таблицу attempt последним, и добавить их в таблицу testing. id последней попытки получить как максимальное значение id из таблицы attempt.*/

insert into testing (attempt_id, question_id)
select (select max(attempt_id) from attempt),question_id
from question join attempt using (subject_id)
where attempt_id = (select max(attempt_id) from attempt)
ORDER BY RAND()
limit 3;

/* 3. Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить результат(запрос) и занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до целого.*/

UPDATE attempt
SET result = (SELECT SUM(is_correct) / 3 * 100
              FROM testing JOIN answer USING (answer_id)
              WHERE attempt_id = 8
             )
WHERE attempt_id = 8;

/* 4. Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. Также удалить и все соответствующие этим попыткам вопросы из таблицы testing.*/

delete from attempt
where date_attempt < '2020-05-01';

select * from attempt;
select * from testing;

-- ЗАПРОСЫ НА ВЫБОРКУ

/* 1. Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» в отсортированном по фамилиям виде.*/

select name_enrollee
from program_enrollee join enrollee using (enrollee_id)
join program using (program_id)
where name_program= 'Мехатроника и робототехника'
order by name_enrollee;

/* 2. Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». Программы отсортировать в обратном алфавитном порядке.*/

select name_program
from program_subject join program using (program_id)
join subject using (subject_id)
where name_subject= 'Информатика';

/* 3. Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и среднее значение баллов по предмету ЕГЭ. Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее. Информацию отсортировать по названию предмета в алфавитном порядке, среднее значение округлить до одного знака после запятой.*/

select name_subject, count(result) as Количество, max(result) Максимум, min(result) Минимум, round(avg(result),1) Среднее
from enrollee_subject join subject using (subject_id)
group by name_subject
order by name_subject;

/* 4. Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или равен 40 баллам. Программы вывести в отсортированном по алфавиту виде.*/

select name_program 
from program 
where name_program not in (select name_program
from program_subject join program using (program_id)
where min_result <40)
order by name_program;

/* 5. Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной.*/

select name_program, plan
from program
where plan = (select max(plan) from program);

/* 6. Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами назвать Бонус. Информацию вывести в отсортированном по фамилиям виде.*/

select name_enrollee, if(sum(bonus) is null,0, sum(bonus)) as Бонус
from achievement join enrollee_achievement using (achievement_id)
right join enrollee using (enrollee_id)
group by enrollee_id
order by name_enrollee;

/* 7. Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее (число поданных заявлений деленное на количество мест по плану), округленный до 2-х знаков после запятой. В запросе вывести название факультета, к которому относится образовательная программа, название образовательной программы, план набора абитуриентов на образовательную программу (plan), количество поданных заявлений (Количество) и Конкурс. Информацию отсортировать в порядке убывания конкурса.*/

select name_department, name_program, plan,count(enrollee_id) as Количество,round((count(enrollee_id)/plan),2) as Конкурс 
from program_enrollee join program using (program_id)
join department using(department_id)
group by name_department, name_program, plan
order by Конкурс  desc;

/* 8. Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика» в отсортированном по названию программ виде.*/

select name_program
from subject inner join program_subject using (subject_id)
             inner join program using (program_id)
group by name_program 
having sum(name_subject = 'Информатика' or name_subject = 'Математика') = 2
order by name_program;

/* 9. Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал заявление, по результатам ЕГЭ. В результат включить название образовательной программы, фамилию и имя абитуриента, а также столбец с суммой баллов, который назвать itog. Информацию вывести в отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.*/

select name_program, name_enrollee, sum(result) as itog
FROM program
    INNER JOIN program_enrollee USING (program_id)
    INNER JOIN enrollee USING(enrollee_id)
    INNER JOIN enrollee_subject USING(enrollee_id)
    INNER JOIN program_subject using(subject_id, program_id)
group by name_program, name_enrollee
order by name_program, itog desc;

/* 10. Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту образовательную программу, но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, необходимым для поступления на эту образовательную программу, меньше минимального балла. Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.
Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы «Прикладная механика» минимальный балл по этому предмету определен в 45 баллов. Следовательно, абитуриент на данную программу не может поступить.*/

select name_program, name_enrollee
FROM program
    INNER JOIN program_enrollee USING (program_id)
    INNER JOIN enrollee USING(enrollee_id)
    INNER JOIN enrollee_subject USING(enrollee_id)
    INNER JOIN program_subject using(subject_id, program_id)
where result < min_result
group by name_program, name_enrollee, subject_id
order by name_program, name_enrollee;

-- ЗАПРОСЫ КОРРЕКТИРОВКИ

/* 1. Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, id абитуриента, сумму баллов абитуриентов (столбец itog) в отсортированном сначала по id образовательной программы, а потом по убыванию суммы баллов виде (использовать запрос из предыдущего урока).*/

create table applicant as 
select program_id, enrollee_id, sum(result) as itog
FROM program
    INNER JOIN program_enrollee USING (program_id)
    INNER JOIN enrollee USING(enrollee_id)
    INNER JOIN enrollee_subject USING(enrollee_id)
    INNER JOIN program_subject using(subject_id, program_id)
group by program_id, enrollee_id
order by program_id, itog desc;

/* 2. Из таблицы applicant, созданной на предыдущем шаге, удалить записи, если абитуриент на выбранную образовательную программу не набрал минимального балла хотя бы по одному предмету (использовать запрос из предыдущего урока).*/

delete from applicant
where (program_id, enrollee_id) in(select program_id, enrollee_id
FROM program
    INNER JOIN program_enrollee USING (program_id)
    INNER JOIN enrollee USING(enrollee_id)
    INNER JOIN enrollee_subject USING(enrollee_id)
    INNER JOIN program_subject using(subject_id, program_id)
where result < min_result
group by program_id, enrollee_id, subject_id
order by name_program, name_enrollee);

/* 3. Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов*/

update applicant 
inner join (select enrollee_id, if(sum(bonus) is null,0, sum(bonus)) as Бонус
from achievement join enrollee_achievement using (achievement_id)
           right join enrollee using (enrollee_id)
group by enrollee_id) as new using (enrollee_id)
set itog = itog+ Бонус;

/* 4. Поскольку при добавлении дополнительных баллов, абитуриенты по каждой образовательной программе могут следовать не в порядке убывания суммарных баллов, необходимо создать новую таблицу applicant_order на основе таблицы applicant. При создании таблицы данные нужно отсортировать сначала по id образовательной программы, потом по убыванию итогового балла. А таблицу applicant, которая была создана как вспомогательная, необходимо удалить.*/

create table applicant_order as
select * from applicant
order by program_id, itog desc;

drop table applicant;

/* 5. Включить в таблицу applicant_order новый столбец str_id целого типа , расположить его перед первым.*/

Alter table applicant_order ADD str_id int first;

/* 6. Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, которая начинается с 1 для каждой образовательной программы.*/

SET @num_pr := 0;
SET @row_num := 1;

Update applicant_order
set str_id = if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1 and @num_pr := program_id);

SELECT * from applicant_order;




















 










