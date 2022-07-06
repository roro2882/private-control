#!/bin/sh
homePath="/root/"
weekPath="${homePath}control/weeklycount.txt"
dayPath="${homePath}control/dailycount.txt"
dayTimePath="${homePath}control/daytime"
weekTimePath="${homePath}control/weektime"
passwordPath="${homePath}password"
requestTimePath="${homePath}control/requestTime"
requestTypePath="${homePath}control/requestType"
requestPath="/home/roro/request.txt"
infosPath="/home/roro/infos.txt"
maxMinutesPerWeek=$((20*60))
maxMinutesPerDay=$((5*60))
rootpassDelayInHours=3
wifiDelayInHours=1
while true; do
	sleep 1m
	#sleep 1s
	weektime=$(cat "$weekPath")
	daytime=$(cat "$dayPath")
	weektime=$((weektime+1))
	daytime=$((daytime+1))
	today=$(date +%s)
	daylimit=$(cat "$dayTimePath")
	weeklimit=$(cat "$weekTimePath")
	request=$(cat  "$requestPath")
	requesttype=$(cat  "$requestTypePath")

	if (( today > daylimit )) ;
	then
		daybegins=$(date -d '+1 day 05:00' +%s)
		#daybegins=$(date -d '+20 second' +%s)
		echo "New day ! "
		echo "$daybegins" > $dayTimePath
		daytime=0
	fi

	if (( today > weeklimit ));
	then
		echo "New week ! "
		weekbegins=$(date -d 'Monday' +%s)
		#weekbegins=$(date -d '+40 second' +%s)
		echo "$weekbegins" > $weekTimePath
		weektime=0
	fi

	if (( daytime > maxMinutesPerDay )); then
		echo "day time limit reached !!!!"
		xbacklight 0
		sleep 1
		xbacklight 10
		sleep 1 
		xbacklight 50
		sleep 1m
		shutdown 0
	fi

	if (( weektime > maxMinutesPerWeek )); then
		echo "week time limit reached !!!!"	
		xbacklight 0
		sleep 1
		xbacklight 10
		sleep 1 
		xbacklight 50
		sleep 1m
		shutdown 0
	fi

	if echo "$request" | grep -q "please password"; then
		echo "root password requested ! "
		echo "password request received" > $requestPath
		requesttime=$(date +%s)
		echo "root password" > $requestTypePath
		echo "$requesttime" > $requestTimePath

	elif echo "$request" | grep -q "please wifi"; then
		echo "wifi requested ! "
		echo "request received" > $requestPath
		requesttime=$(date +%s)
		echo "wifi" > $requestTypePath
		echo "$requesttime" > $requestTimePath

	elif echo "$request" | grep -q "request received"; then
		echo "request pending"
		requesttime=$(cat "$requestTimePath")
		if echo "$requesttype" | grep -q "root password"; then
			echo "request root"
			goodtime=$(date -d "-${rootpassDelayInHours} hours" +%s)
			if (( goodtime > requesttime)); then
				pass=$(cat "$passwordPath")
				echo "rootpasswd : $pass"> $requestPath
				requesttime=$(date +%s)
				echo "$requesttime" > $requestTimePath
			else
				echo "request received : $goodtime : $requesttime" >> $requestPath
			fi

		elif echo "$requesttype" | grep -q "wifi"; then
			echo "request wifi"
			goodtime=$(date -d "-${wifiDelayInHours} hours" +%s)
			if (( goodtime > requesttime )); then
				bash ${homePath}unblock_wifi.sh
				echo "wifi activated">$requestPath
			else
				echo "request received : $goodtime : $requesttime" >> $requestPath
			fi
		fi

	elif echo "$request" | grep -q "rootpasswd"; then
		echo "root passwd detected"
		requesttime=$(date +%s)
		echo "$requesttime" > $requestTimePath

	else 
		echo "no request" > $requestPath
		requesttime=$(date +%s)
		echo "$requesttime" > $requestTimePath
	fi
	echo "$weektime" > $weekPath
	echo "$daytime" > $dayPath
	echo "week : $weektime day : $daytime"
	echo "week : $weektime / $maxMinutesPerWeek day : $daytime / $maxMinutesPerDay" > $infosPath
done
