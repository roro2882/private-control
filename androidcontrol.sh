#!/bin/sh
homePath="/data/local/root/"
weekPath="${homePath}control/weeklycount.txt"
dayPath="${homePath}control/dailycount.txt"
dayTimePath="${homePath}control/daytime"
weekTimePath="${homePath}control/weektime"
passwordPath="${homePath}password"
requestTimePath="${homePath}control/requestTime"
requestTypePath="${homePath}control/requestType"
requestPath="/sdcard/request.txt"
infosPath="/sdcard/infos.txt"
maxMinutesPerWeek=$((6*60))
maxMinutesPerDay=$((2*60))
rootpassDelayInHours=24
wifiDelayInMinutes=30
sleep 1m
bash ${homePath}block_wifi_android.sh
i=0
while true; do
	sleep 1s
	#sleep 1s
	if echo "$(dumpsys power)" | grep -q "mHoldingDisplaySuspendBlocker=true"; then
	i=$((i+1))
	fi
	weektime=$(cat "$weekPath")
	daytime=$(cat "$dayPath")
	if (( i%60 == 0 )); then
		weektime=$((weektime+1))
		daytime=$((daytime+1))
	fi
	today=$(cat /sys/class/rtc/rtc0/since_epoch)
	daylimit=$(cat "$dayTimePath")
	weeklimit=$(cat "$weekTimePath")
	request=$(cat  "$requestPath")
	requesttype=$(cat  "$requestTypePath")

	if (( today > daylimit )) ;
	then
		daybegins=$(( today + 22*60*60 ))
		echo "New day ! "
		echo "$daybegins" > $dayTimePath
		daytime=0
	fi

	if (( today > weeklimit ));
	then
		echo "New week ! "
		weekbegins=$(( today + 6*24*60*60))
		echo "$weekbegins" > $weekTimePath
		weektime=0
	fi

	if (( daytime > maxMinutesPerDay )); then
		echo "day time limit reached !!!!"
		su -lp 2000 -c 'cmd notification post -S bigtext -t "time" "tag" "day times up"'
		sleep 1m
		svc power shutdown
	fi

	if (( weektime > maxMinutesPerWeek )); then
		echo "week time limit reached !!!!"	
		su -lp 2000 -c 'cmd notification post -S bigtext -t "time" "tag" "day times up"'
		sleep 1m
		svc power shutdown
	fi

	if echo "$request" | grep -q "please password"; then
		echo "root password requested ! "
		echo "password request received" > $requestPath
		requesttime=$today
		echo "root password" > $requestTypePath
		echo "$requesttime" > $requestTimePath

	elif echo "$request" | grep -q "please wifi"; then
		echo "wifi requested ! "
		echo "request received" > $requestPath
		requesttime=$today
		echo "wifi" > $requestTypePath
		echo "$requesttime" > $requestTimePath
	elif echo "$request" | grep -q "please block wifi"; then
		echo "block wifi requested ! "
		echo "request received" > $requestPath
		bash block_wifi_android.sh
	elif echo "$request" | grep -q "request received"; then
		echo "request pending"
		requesttime=$(cat "$requestTimePath")
		if echo "$requesttype" | grep -q "root password"; then
			echo "request root"
			goodtime=$((today - rootpassDelayInHours*60*60))
			if (( goodtime > requesttime)); then
				pass=$(cat "$passwordPath")
				echo "rootpasswd : $pass"> $requestPath
				requesttime=$today
				echo "$requesttime" > $requestTimePath
			else
				echo "request received : $goodtime : $requesttime" > $requestPath
			fi

		elif echo "$requesttype" | grep -q "wifi"; then
			echo "request wifi"
			goodtime=$((today - wifiDelayInMinutes*60))
			if (( goodtime > requesttime )); then
				bash ${homePath}unblock_wifi_android.sh
				echo "wifi activated">$requestPath
			else
				echo "request received : $goodtime : $requesttime" > $requestPath
			fi
		fi

	elif echo "$request" | grep -q "rootpasswd"; then
		echo "root passwd detected"
		requesttime=$today
		echo "$requesttime" > $requestTimePath

	else 
		echo "no request" > $requestPath
		requesttime=$today
		echo "$requesttime" > $requestTimePath
	fi
	echo "$weektime" > $weekPath
	echo "$daytime" > $dayPath
	echo "week : $weektime day : $daytime"
	echo "week : $weektime / $maxMinutesPerWeek day : $daytime / $maxMinutesPerDay" > $infosPath
	echo "week : $weeklimit  day : $daylimit today : $today" >> $infosPath
done

