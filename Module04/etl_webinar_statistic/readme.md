# ETL pipeline Webinar
В этом проекте я автоматизировал загрузку дынных по посещаемости занятий по информатике студентами. Занятия проходили на платформе [Webinar](https://webinar.ru/). Данные я получил по [API](https://help.webinar.ru/ru/collections/1839571-%D0%B8%D0%BD%D1%82%D0%B5%D0%B3%D1%80%D0%B0%D1%86%D0%B8%D1%8F-api) платформы.

__Стек:__ **`Pentaho DI`**, **`JavaPath`**, **`DbSchema`**, **`PostgreSQL`**.
##  Получения списка мероприятий
На первом [этапе](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/files/get_events_list.ktr) я собрал _id_ нужных мне занятий, чтобы потом по ним запросить статистику:

![get_events_list](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/get_events_list.jpg)

## Помещение данных на первый слой хранилища данных
Затем я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/files/get_api_statistic.ktr), где сгенерировал ссылки-запросы и получил данные по занятиям и поместил их на уровень **Staging** хранилища данных:

![get_api_statistic](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/get_api_statistic.jpg)

Использование нескольких блоков _JSON input_ обусловлено тем, что в ответ на запрос приходит _nested JSON_.

## Трансформация данных и загрузка на второй слой хранилища данных
После этого я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/files/dw_tables_dim.ktr) для загрузки данных на уровень **Data Warehouse** хранилища данных:

![dw_attendance_dim](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/dw_tables_dim.jpg)

## Формирование фактической таблицы посещаемости
На следующем этапе я сформировал [трансформацию](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/files/dw_attendance_dim.ktr) преобразования итоговой фактической таблицы посещаемости:

![dw_attendance_dim](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/dw_attendance_dim.jpg)

## Формирование финального ETL файла
На финальном этапе я сформировал [job](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/job_webinar.kjb) который автоматизирует все этапы цикла загрузки данных в аналитическое хранилище:

![job_webinar](https://github.com/abtcrazy/DE-101/blob/main/Module04/etl_webinar_statistic/job_webinar.jpg)

[В начало :arrow_heading_up:](https://github.com/abtcrazy/DE-101/tree/main/Module04/etl_webinar_statistic)