# Задания для модуля 2
В этом модуле нужно было для данных из первого модуля построить модель данных, затем загрузить все в облачное хранилище данных и в итоге построить дашборд.
Ниже представлены этапы решения задачи:

1. [Построение модели аналитического хранилища данных](#Архитектура_аналитического_решения)
2. [Загрузка](#Загрузка)
3. [Построение дашборда](#Построение_дашборда)

## Построение_модели_аналитического_хранилища_данных
Для [данных](https://github.com/abtcrazy/DE-101/blob/main/Module01/Sample%20-%20Superstore.xls) из [первого](https://github.com/abtcrazy/DE-101/tree/main/Module01) модуля я построил модель с использованием [SqlDBM](https://app.sqldbm.com/):
* Концептуальная модель

![conceptual_model](https://github.com/abtcrazy/DE-101/blob/main/Module02/conceptual_model.jpg)
* Физическая модель

![physical_model](https://github.com/abtcrazy/DE-101/blob/main/Module02/physical_model.jpg)

## Загрузка 
Для хостинга своего хранилища я выбрал сервис [Supabase](https://supabase.com/).
Затем в несколько стадий я провел ELT операцию:
1. Использовав сервис [SQLizer.io](https://sqlizer.io/) я сформировал DDL скрипты для загрузки данных на **Staging** уровень хранилища данных:
  * [stg.orders.sql](https://github.com/abtcrazy/DE-101/blob/main/Module02/stg.orders.sql)
  * [stg.people.sql](https://github.com/abtcrazy/DE-101/blob/main/Module02/stg.people.sql)
  * [stg.returns.sql](https://github.com/abtcrazy/DE-101/blob/main/Module02/stg.returns.sql)
2. С помощью клиента для работы с базами данных [DBeaver](https://dbeaver.io/) я подключился к облачному хранилищу и загрузил туда данные.

3. Для переноса данных с уровня **Staging** на уровень **Data Warehouse** я использовал генерируемые [SqlDBM](https://app.sqldbm.com/) DDL скрипты, которые объединил в единый файл:

  * [from_stg_to_dw_script.sql](https://github.com/abtcrazy/DE-101/blob/main/Module02/from_stg_to_dw_script.sql)


## Построение_дашборда
На этом этапе я воспользовался облачным BI инструментом [Yandex DataLens](https://datalens.yandex.ru/). Сначала я подключился к облачной базе данных. А затем по аналогии с [первым](https://github.com/abtcrazy/DE-101/tree/main/Module01) модулем спроектировал дашборд:

![dashboard](https://github.com/abtcrazy/DE-101/blob/main/Module02/dashboard.jpg)

Подробную версию можно изучить по [ссылке](https://datalens.yandex/jqxhc53d1memb).


[В начало :arrow_heading_up:](https://github.com/abtcrazy/DE-101/tree/main/Module02)