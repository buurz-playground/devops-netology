# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
```
\l
```
- подключения к БД
```
 \c db_test
```
- вывода списка таблиц
```
 \dt
```
- вывода описания содержимого таблиц
```
 \d table_name
```
- выхода из psql

```
\q
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

---
```
select * from pg_stats where tablename = 'orders' order by avg_width DESC limit 1;
```
---

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```
test_database=# CREATE TABLE orders_1(check(price > 499)) INHERITS (orders);
CREATE TABLE
test_database=# CREATE TABLE orders_2(check(price <= 499)) INHERITS (orders);
CREATE TABLE

test_database=# WITH moved_rows AS (
test_database(#     DELETE FROM orders o
test_database(#     WHERE price > 499
test_database(#     RETURNING o.*
test_database(# )
test_database-# INSERT INTO orders_1
test_database-# SELECT DISTINCT * FROM moved_rows;
INSERT 0 3

test_database=# WITH moved_rows AS (
test_database(#     DELETE FROM orders o
test_database(#     WHERE price <= 499
test_database(#     RETURNING o.*
test_database(# )
test_database-# INSERT INTO orders_2
test_database-# SELECT DISTINCT * FROM moved_rows;
INSERT 0 5

test_database=# create rule orders_insert_to_1 AS on insert to orders where (price > 499) do instead insert into orders_1 values (NEW.*);
CREATE RULE

test_database=# create rule orders_insert_to_2 AS on insert to orders where (price <= 499) do instead insert into orders_2 values (NEW.*);
CREATE RULE

test_database=# insert into orders(title, price) values('One test', 300);
INSERT 0 0
test_database=# insert into orders(title, price) values('Two ttest', 3300);
INSERT 0 0
test_database=# select * from orders;
 id |        title         | price
----+----------------------+-------
  8 | Dbiezdmin            |   501
  6 | WAL never lies       |   900
  2 | My little database   |   500
 10 | Two ttest            |  3300
  3 | Adventure psql time  |   300
  5 | Log gossips          |   123
  4 | Server gravity falls |   300
  1 | War and peace        |   100
  7 | Me and my bash-pet   |   499
  9 | One test             |   300
(10 строк)
test_database=# select * from orders_1;
 id |       title        | price
----+--------------------+-------
  8 | Dbiezdmin          |   501
  6 | WAL never lies     |   900
  2 | My little database |   500
 10 | Two ttest          |  3300
(4 строки)

test_database=# select * from orders_2;
 id |        title         | price
----+----------------------+-------
  3 | Adventure psql time  |   300
  5 | Log gossips          |   123
  4 | Server gravity falls |   300
  1 | War and peace        |   100
  7 | Me and my bash-pet   |   499
  9 | One test             |   300
(6 строк)
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

---
Да, можно было. Делается также. Пропускаем шаг с миграцией данных с основной таблицы в шарды.

---


## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

---
Добавил уникальные индексы на таблицы.

```
CREATE UNIQUE INDEX CONCURRENTLY orders_1_title
ON public.orders_1 (title);

CREATE UNIQUE INDEX CONCURRENTLY orders_2_title
ON public.orders_2 (title);
```

---
