#!/bin/bash
shopt -s nocasematch;

rm -f restore.err
rm -f restore.log
rm -f *.FBK

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

# Если файлов для копирования нет - звершаем работы
if [ $# = 0 ]; then
        echo "Для работы скрипта требуется передать имя файла резервной копии"
        exit
fi
if [ ! -f $filename ]; then
        echo "Передан неверное имя файла резервной копии базы Firebird: $filename"
        exit
fi

if [[ $filename =~ ^.*\.gz$ ]]
then
	gunzip -c $filename >${filename/.gz}
else
	if [[ $filename =~ ^.*\.zip$ ]]
	then
		unzip -j $filename \*.FBK
	else
		if [[ $filename =~ ^.*\.fbk$ ]]
		then
			ufilename="$(tr [a-z] [A-Z] <<< "$filename")"
			cp $filename $ufilename
		fi
	fi
fi

fbkfiles=$(ls ./*.FBK | wc -l)
if [ $fbkfiles > 0 ]
then
	if [ "$password" == "" ]
	then
		echo "Введите пожалуйста пароль для пользователя SYSDBA:"
		read -s password
	fi

	for filename in ./*.FBK; do
		echo "Обрабатывается архивная копия $filename ..."
		ufilename=${filename##*/}
		ufilename="$(tr [a-z] [A-Z] <<< "$ufilename")"
		ubasename=${ufilename/.FBK/.FDB}

		${FBpath}gbak -c -v -REP -USER SYSDBA -PASS $password $filename $ubasename 1> restore.log  2>> restore.err
		FILESIZE=$(stat -c%s restore.err)
		if [ $FILESIZE != 0 ]
		then
			if grep -q "Invalid metadata detected. Use -FIX_FSS_METADATA option." restore.err -a $ufilename == "SPACE.FBK"
			then
		    		# База space.fdb это база параграфа 2 с кодировкой WIN1251, перезапустим теперь gbak с опцией для фиксации этой ошибки.
				# проблема в том, что если запустить gbak с этим ключом к нормальной базе на выходе получим испорченную, не использовать самостоятельно!!!

				rm restore.err
				rm restore.log
				echo "Invalid metadata detected. Use -FIX_FSS_METADATA option."
				${FBpath}gbak -c -v -REP -USER SYSDBA -PASS $password $filename $ubasename -fix_fss_data WIN1251 -fix_fss_metadata WIN1251 1> restore.log  2>> restore.err
			fi
		fi

		FILESIZE=$(stat -c%s restore.err)
		if [ $FILESIZE == 0 ]
		then
			echo "База данных $ubasename восстановлена без ошибок!"
		else
			echo "В процессе восстановления базы $ubasename из архивной копии $filename произошли ошибки:"
			cat restore.err
		fi
	done
fi
