# Тестовое задание Effective Mobile DevOps Муртазина И.А.

### Текст задания:

Написать скрипт на bash для мониторинга процесса test в среде linux. Скрипт должен отвечать следующим требованиям:
1. Запускаться при запуске системы (предпочтительно написать юнит systemd в дополнение к скрипту)
2. Отрабатывать каждую минуту
3. Если процесс запущен, то стучаться(по https) на https://test.com/monitoring/test/api
4. Если процесс был перезапущен, писать в лог /var/log/monitoring.log (если процесс не запущен, то ничего не делать)
5. Если сервер мониторинга не доступен, так же писать в лог.    

### [Скрипт](https://github.com/murtazinilyas/effective_mobile/blob/main/test.sh) мониторинга работы процесса test:

```bash
#!/bin/bash

#Задаем переменные для более легкого написания скрипта
log_file="/var/log/monitoring.log" #Указываем адрес и имя файла лога
pid_file="/tmp/pid" #Записываем сюда айди процесса для проверки на его перезапуск
proc_name="test" #Имя искомого процесса
mon_srv="https://test.com/monitoring/test/api" #Адрес сервера

if pgrep -x "$proc_name" > /dev/null; then #Проверяем запущен ли процесс

    PID=$(pgrep -x $proc_name | head -n1) #Записываем в переменную айди процесса

    if [[ -f "$pid_file" ]]; then #Проверяем, есть ли файл с айди процесса

        OLD_PID=$(cat "$pid_file") #Возвращаем старый айди процесса
        
        if [[ "$OLD_PID" != "$PID" ]]; then #Проверяем, был ли наш процесс перезапущен
            echo "$(date "+%b %d %T") Process $proc_name was restarted" >> "$log_file" #Пишем в лог, если наш процесс был перезапущен
        fi

    fi

    echo "$PID" > "$pid_file" #Записываем в файл текущий айди процесса

    if ! curl -s -f --max-time 5 "$mon_srv" > /dev/null; then #Стучимся по адресу мониторинг-сервера
        echo "$(date "+%b %d %T") Monitoring server $mon_srv is unavailable" >> "$log_file" #Пишем в лог, если сервер недоступен
    fi

    else
        exit 0 #Если процесс не запущен, выходим с кодом завершения 0

fi
```

### [Unit](https://github.com/murtazinilyas/effective_mobile/blob/main/test.service) systemd для запуска скрипта:

```
[Unit]
Description=Monitoring of test process
Wants=test.timer

[Service]
Type=simple
ExecStart=/var/log/test.sh

[Install]
WantedBy=multi-user.target
```

### [Таймер](https://github.com/murtazinilyas/effective_mobile/blob/main/test.timer) для запуска скрипта при загрузке системы и далее каждую минуту:

```
[Unit]
Description=Timer for monitor process test

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
AccuracySec=1sec

[Install]
WantedBy=timers.target
```
