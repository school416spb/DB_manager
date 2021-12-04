#!/bin/bash
#версия 2021.12.04
echo "2021 (с) Давыдов Денис Эдуардович, davydov@school416spb.ru"
echo "Менеджер БД АИСУ ПАРАГРАФ для резервного копирования и восстановления"

echo "Выберите действие:"
echo "1 - СОЗДАТЬ РЕЗЕРВНУЮ КОПИЮ"
echo "2 - ВОССТАНОВИТЬ РЕЗЕРВНУЮ КОПИЮ"
echo "3 - ВЫХОД"

read ACTION

sudo chmod 777 -R SCRIPTS/

if [[ "$ACTION" = "1" ]]
then
	WAY="$(date +"%d-%m-%Y-%T") $@"
	mkdir $HOME"/DB_manager/DB/"$WAY
	cd "/var/bases/prg3/"
	
	echo "Выполняется копирование файлов BASE.FDB BIN.FDB BLOB.FDB"
	echo "ОЖИДАЙТЕ..."
	sudo cp BASE.FDB BIN.FDB BLOB.FDB $HOME"/DB_manager/DB/"$WAY
	sudo chmod 777 BASE.FDB BIN.FDB BLOB.FDB
	echo "Файлы BASE.FDB BIN.FDB BLOB.FDB скопированы в каталог "$HOME"/DB_manager/DB/"$WAY
	
	cd $HOME"/DB_manager/SCRIPTS"
	cp backup.sh "../DB/"$WAY
	cp restore.sh "../DB/"$WAY
	cd "../DB/"$WAY
	
	echo "Идёт архивация файлов BASE.FDB BIN.FDB BLOB.FDB"
	echo "ОЖИДАЙТЕ..."
	sudo ./backup.sh /var/bases/prg3/BASE.FDB
	echo "В каталоге "$HOME"/DB_manager/DB/"$WAY
	sudo ./backup.sh /var/bases/prg3/BIN.FDB
	echo "В каталоге "$HOME"/DB_manager/DB/"$WAY
	sudo ./backup.sh /var/bases/prg3/BLOB.FDB
	echo "В каталоге "$HOME"/DB_manager/DB/"$WAY
	rm backup.err backup.log
    
	echo "Для завершения работы нажмите ENTER..."
	read
	echo "РАБОТА ЗАВЕРШЕНА!"
elif [[ "$ACTION" = "2" ]]
then
    echo "Выберите действие:"
    echo "1 - КОПИРОВАТЬ ФАЙЛЫ BASE.FDB BIN.FDB BLOB.FDB в каталог /var/bases/prg3"
    echo "2 - ВОССТАНОВИТЬ ИЗ АРХИВА УТИЛИТОЙ GBAK"
    echo "3 - ВЫХОД"
    read ACTION
    
    if [[ "$ACTION" = "1" ]]
    then
        cd "DB/"
        echo "Доступный для восстановлени копии:"
        ls
        echo "Укажите имя каталога с резервной копией по форме ДД-ММ-ГГГГ-ЧЧ:ММ:СС = "
        read WAY
        cd $WAY
        echo "Выполняется копирование файлов BASE.FDB BIN.FDB BLOB.FDB"
        echo "ОЖИДАЙТЕ..."
        sudo chmod 777 BASE.FDB BIN.FDB BLOB.FDB
        sudo cp BASE.FDB BIN.FDB BLOB.FDB /var/bases/prg3
        echo "ФАЙЛЫ УСПЕШНО ВОССТАНОВЛЕНЫ!"
        echo "Для завершения работы нажмите ENTER..."
        read
        echo "РАБОТА ЗАВЕРШЕНА!"
    elif [[ "$ACTION" = "2" ]]
    then
        cd "DB/"
        echo "Доступный для восстановлени копии:"
        ls
        echo "Укажите имя каталога с резервной копией по форме ДД-ММ-ГГГГ-ЧЧ:ММ:СС = "
        read WAY
        cd $WAY
        sudo cp BASE.FBK.gz BIN.FBK.gz BLOB.FBK.gz /var/bases/prg3
        cd /var/bases/prg3
        echo "Выполняется восстановление БД из архивов"
        echo "ОЖИДАЙТЕ..."
        sudo ./restore.sh BASE.FBK.gz
        sudo ./restore.sh BIN.FBK.gz
        sudo ./restore.sh BLOB.FBK.gz
        sudo chmod 777 BASE.FDB BIN.FDB BLOB.FDB
        sudo rm BASE.FBK BIN.FBK BLOB.FBK 0 BASE.FBK.gz BIN.FBK.gz BLOB.FBK.gz restore.err restore.log
        echo "ФАЙЛЫ УСПЕШНО ВОССТАНОВЛЕНЫ!"
        echo "Для завершения работы нажмите ENTER..."
        read
        echo "РАБОТА ЗАВЕРШЕНА!"
    else 
        echo "РАБОТА ЗАВЕРШЕНА!"
    fi

else
    echo "РАБОТА ЗАВЕРШЕНА!"
fi
