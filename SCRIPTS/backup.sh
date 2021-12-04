#!/bin/bash
if [ -f /usr/bin/gsec ]
then
	FBpath='/usr/bin/'
else
	if [ -f /opt/firebird/bin/gsec ]
	then
		FBpath='/opt/firebird/bin/'
	else
		echo "Firebird не установлен, продолжение невозможно."
		exit 1
	fi
fi

password=""

if getopts "p:" flag
then
    	password=$OPTARG
	filename=$2
else
	filename=$1
fi

if [ `expr match "$filename" '^.*\.gz$'` != 0 ]
then
	gunzip -c $filename >${filename/.gz/}
	filename=${filename/.gz/}
fi

ufilename=${filename##*/}
ufilename="$(tr [a-z] [A-Z] <<< "$ufilename")"
ubasename=${ufilename/.FDB/.FBK}

# Если файлов для копирования нет - звершаем работы
if [ $# = 0 ]; then
	echo "Для работы скрипта требуется передать имя файла резервной копии"
	exit
fi

if [ ! -f $filename ]; then
	echo "Передан неверное имя файла резервной копии базы Firebird: $filename"
	exit
fi

rm -f  backup.err
rm -f  backup.log

if [ "$password" == "" ]
then
	echo "Введите пожалуйста пароль для пользователя SYSDBA:"
	read -s password
fi

${FBpath}gbak -b -t -v -USER SYSDBA -PASS $password $filename $ubasename 1> backup.log  2>> backup.err
rm -f "${ubasename}.gz"
gzip -9 $ubasename

FILESIZE=$(stat -c%s backup.err)
if [ $FILESIZE == 0 ]
then
	echo "Архивная копия базы данных $filename создана успешно и сохранена в файле ${ubasename}.gz"
else
	echo "В процессе архивации базы данных $filename произошли ошибки:"
	cat backup.err
fi
