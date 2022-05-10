# ETL pipeline Sample-Superstore
## Загрузка данных из репозитория
На первом этапе я скачал [данные](https://github.com/abtcrazy/DE-101/blob/main/Module01/Sample%20-%20Superstore.xls) из [первого](https://github.com/abtcrazy/DE-101/tree/main/Module01) модуля с репозитория github. Для этого я сформировал [job](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/files/job_download_samplestore.kjb):

![job_download_samplestore](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/job_download_samplestore.jpg)

## Помещение данных на первый слой хранилища данных
Потом я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/files/stg_orders.ktr) для загрузки данных на **Staging** уровень хранилища данных:

![stg_orders](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/stg_orders.jpg)

##  Трансформация данных и загрузка на второй слой хранилища данных
Затем я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/files/dw_tables_dim.ktr) для загрузки данных на уровень **Data Warehouse** хранилища данных:

![dw_tables_dim](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/dw_tables_dim.jpg)

## Формирование фактической таблицы продаж
На следующем этапе я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/files/dw_sales_fact.ktr) преобразования итоговой фактической таблицы продаж.

![dw_sales_fact](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/dw_sales_fact.jpg)
##  Формирование финального ETL файла
На финальном этапе я сформировал [job](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/files/job_superstore.kjb) который автоматизирует все этапы цикла загрузки данных в аналитическое хранилище:

![job_superstore](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_superstore_project/job_superstore.jpg)

Из этого job'а можно сформировать скрипт, который будет выполнят ETL операцию по расписанию:

``` 
"C:\pdi-ce-9.2.0.0-290\data-integration\Kitchen.bat" /file:"C:\Users\talipov.am\Documents\REPO\DE-101\Module04\etl_superstore_project\files\job_superstore.kjb" /level:Basic
```

[В начало :arrow_heading_up:](https://github.com/abtcrazy/DE-101/tree/main/Module04/etl_superstore_project)