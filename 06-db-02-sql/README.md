# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume,
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

## Задача 2

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)


---
Ответ:

**итоговый список БД после выполнения пунктов выше**

```
db_test=# \dt
           Список отношений
 Схема  |   Имя   |   Тип   | Владелец
--------+---------+---------+----------
 public | clients | таблица | postgres
 public | orders  | таблица | postgres
```

**описание таблиц (describe)**
```
db_test=# \d clients
                                               Таблица "public.clients"
   Столбец    |          Тип           | Правило сортировки | Допустимость NULL |            По умолчанию
--------------+------------------------+--------------------+-------------------+-------------------------------------
 id           | bigint                 |                    | not null          | nextval('clients_id_seq'::regclass)
 last_name    | character varying(255) |                    |                   |
 country_name | character varying(255) |                    |                   |
 order_id     | bigint                 |                    |                   |
Индексы:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_country_name_idx" btree (country_name)
Ограничения внешнего ключа:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
```

```
db_test=# \d orders
                                            Таблица "public.orders"
 Столбец |          Тип           | Правило сортировки | Допустимость NULL |            По умолчанию
---------+------------------------+--------------------+-------------------+------------------------------------
 id      | bigint                 |                    | not null          | nextval('orders_id_seq'::regclass)
 name    | character varying(255) |                    |                   |
 price   | integer                |                    |                   |
Индексы:
    "orders_pkey" PRIMARY KEY, btree (id)
Ссылки извне:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
```

**SQL-запрос для выдачи списка пользователей с правами над таблицами test_db**
```
SELECT grantee,table_catalog, table_schema, table_name, privilege_type
FROM   information_schema.table_privileges
WHERE  grantee = 'test-simple-user' or grantee = 'test-admin-user' order by grantee;
```
**список пользователей с правами над таблицами test_db**

```
     grantee      | table_catalog | table_schema | table_name | privilege_type
------------------+---------------+--------------+------------+----------------
 test-admin-user  | db_test       | public       | clients    | INSERT
 test-admin-user  | db_test       | public       | clients    | SELECT
 test-admin-user  | db_test       | public       | clients    | UPDATE
 test-admin-user  | db_test       | public       | clients    | DELETE
 test-admin-user  | db_test       | public       | clients    | TRUNCATE
 test-admin-user  | db_test       | public       | clients    | REFERENCES
 test-admin-user  | db_test       | public       | clients    | TRIGGER
 test-admin-user  | db_test       | public       | orders     | INSERT
 test-admin-user  | db_test       | public       | orders     | SELECT
 test-admin-user  | db_test       | public       | orders     | UPDATE
 test-admin-user  | db_test       | public       | orders     | DELETE
 test-admin-user  | db_test       | public       | orders     | TRUNCATE
 test-admin-user  | db_test       | public       | orders     | REFERENCES
 test-admin-user  | db_test       | public       | orders     | TRIGGER
 test-simple-user | db_test       | public       | orders     | INSERT
 test-simple-user | db_test       | public       | clients    | INSERT
 test-simple-user | db_test       | public       | clients    | SELECT
 test-simple-user | db_test       | public       | clients    | UPDATE
 test-simple-user | db_test       | public       | clients    | DELETE
 test-simple-user | db_test       | public       | orders     | SELECT
 test-simple-user | db_test       | public       | orders     | UPDATE
 test-simple-user | db_test       | public       | orders     | DELETE
```
---

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

---
```
insert into orders(name, price) VALUES
('Шоколад', 10),
('Принтер', 3000),
('Книга', 500),
('Монитор', 7000),
('Гитара', 4000);
```
---

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

---
```
insert into clients(last_name, country_name) VALUES
('Иванов Иван Иванович', 'USA'),
('Петров Петр Петрович', 'Canada'),
('Иоганн Себастьян Бах', 'Japan'),
('Ронни Джеймс Дио','Russia'),
('Ritchie Blackmore','Russia');
```
---

Используя SQL синтаксис:
- **вычислите количество записей для каждой таблицы**

---
  ```
  db_test=#  select count(*) from orders;
  count
  -------
      5
  ```

  ```
  db_test=#   select count(*) from clients;
  count
  -------
      5
  ```
---

- приведите в ответе:
    - запросы
    - результаты их выполнения.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

Подсказк - используйте директиву `UPDATE`.

---
```
db_test=# UPDATE clients
db_test-# SET order_id = 3 where id = 1;
UPDATE 1
db_test=# UPDATE clients
SET order_id = 4 where id = 2;
UPDATE 1
db_test=# UPDATE clients
SET order_id = 5 where id = 3;
UPDATE 1
db_test=# select * from clients where order_id is not null;
 id |      last_name       | country_name | order_id
----+----------------------+--------------+----------
  1 | Иванов Иван Иванович | USA          |        3
  2 | Петров Петр Петрович | Canada       |        4
  3 | Иоганн Себастьян Бах | Japan        |        5
```
---

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

---
```
db_test=# EXPLAIN select * from clients where order_id is not null;
                         QUERY PLAN
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..10.70 rows=70 width=1048)
   Filter: (order_id IS NOT NULL)
```

Сначала происходит фильтрация по order_id.
Далее перебор записей по результату фильтрации.

---

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

---
```
pg_dump -U postgres db_test > /tmp/db_backup/db_test_backup.sql

```

```
db_test=# DROP table orders, clients;
DROP TABLE
db_test=# \dt
Отношения не найдены.
```
---

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

---
```
~/code/devops-netology/06-db-02-sql (master*) » docker ps

CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                    NAMES
5f2334db7bea        postgres:13.3-alpine   "docker-entrypoint.s…"   2 hours ago         Up 2 hours          0.0.0.0:5432->5432/tcp   06-db-02-sql_db
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
~/code/devops-netology/06-db-02-sql (master*) » docker stop 5f2334db7bea
5f2334db7bea
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
~/code/devops-netology/06-db-02-sql (master*) » docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
---

Поднимите новый пустой контейнер с PostgreSQL.

---
```
~/code/devops-netology/06-db-02-sql (master*) » docker-compose up -d
Creating network "06-db-02-sql_default" with the default driver
Creating 06-db-02-sql_db ... done
```
---

Восстановите БД test_db в новом контейнере.

---
```
psql -h localhost -U postgres db_test < /tmp/db_backup/db_test_backup.sql
```

**После восстановления**
```

bash-5.1# psql -h localhost -U postgres -d db_test
psql (13.3)
Type "help" for help.

db_test=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

db_test=# select * from orders;
 id |  name   | price
----+---------+-------
  1 | Шоколад |    10
  2 | Принтер |  3000
  3 | Книга   |   500
  4 | Монитор |  7000
  5 | Гитара  |  4000
(5 rows)
```
---

Приведите список операций, который вы применяли для бэкапа данных и восстановления.
