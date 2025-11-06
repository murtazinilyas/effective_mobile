#!/bin/bash

#Задаем переменные для более легкого написания скрипта
log_file="/var/log/test_monitoring.log" #Указываем адрес и имя файла лога
pid_file="/var/run/test_pid" #Записываем сюда айди процесса для проверки на его перезапуск
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
