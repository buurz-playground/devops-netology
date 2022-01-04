# Домашнее задание к занятию "6.1. Типы и структура СУБД"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Архитектор ПО решил проконсультироваться у вас, какой тип БД
лучше выбрать для хранения определенных данных.

Он вам предоставил следующие типы сущностей, которые нужно будет хранить в БД:

1. Электронные чеки в json виде
2. Склады и автомобильные дороги для логистической компании
3. Генеалогические деревья
4. Кэш идентификаторов клиентов с ограниченным временем жизни для движка аутенфикации
5. Отношения клиент-покупка для интернет-магазина

Выберите подходящие типы СУБД для каждой сущности и объясните свой выбор.

---
**Ответ**

1. mongoDB, подходит для хранения документов в формате json, не имеет четкой схемы.
2. склады как узлы, дороги как ребра - подходит графовая бд
3. иерархические, графовые бд(узлы - члены семьи, ребра родство)
4. редис, ключ-значение с заданием TTl
5. реляционные БД, типа постгрес для связи таблиц между собой через идентификаторы
---

## Задача 2

Вы создали распределенное высоконагруженное приложение и хотите классифицировать его согласно
CAP-теореме. Какой классификации по CAP-теореме соответствует ваша система, если
(каждый пункт - это отдельная реализация вашей системы и для каждого пункта надо привести классификацию):

1. Данные записываются на все узлы с задержкой до часа (асинхронная запись)
2. При сетевых сбоях, система может разделиться на 2 раздельных кластера
3. Система может не прислать корректный ответ или сбросить соединение

А согласно PACELC-теореме, как бы вы классифицировали данные реализации?

---
Ответ:

1. CAP: AP
   PACELC: PA/EL


2. CAP: PC
   PACELC: PC/EL


3. CAP: CA
   PACELC: PC/EC

---

## Задача 3

Могут ли в одной системе сочетаться принципы BASE и ACID? Почему?

---
Ответ:

Сочетаться не могут.
Ключевое свойство C-consistence, согласованность данных в ACID должна соблюдаться на всех нодах. При BASE согласованность может быть достигнута через какое-то время.

Также в ACID системах пока данные не будут согласованны, система может быть не доступна на запись, в отличие от BASE.

Если в целом брать систему как взаимодействие разных инструментов. Где применять, например, PostgreSQL как хранилище данных, а Elasticsearch как обработку запросов на поиск, то сочетаться могут.

---

## Задача 4

Вам дали задачу написать системное решение, основой которого бы послужили:

- фиксация некоторых значений с временем жизни
- реакция на истечение таймаута

Вы слышали о key-value хранилище, которое имеет механизм [Pub/Sub](https://habr.com/ru/post/278237/).
Что это за система? Какие минусы выбора данной системы?

---
Ответ:

Инструмент, обладающий такими свойствами - Redis.

Нужно понимать, что все данные Редис хранит в памяти, памяти должно быть достаточно для данных.

Нет своего языка запросов для какой-то сложной выборки.
Подходит только для определенного ряда задач, например для хранения кэша.

---