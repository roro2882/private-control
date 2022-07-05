#!/bin/sh
homePath="/home/roro/"
weekPath="${homePath}control/weeklycount.txt"
dayPath="${homePath}control/dailycount.txt"
dayTimePath="${homePath}control/daytime"
weekTimePath="${homePath}control/weektime"
requestPath="${homePath}request.txt"
passwordPath="${homePath}password"
requestTimePath="${homePath}control/requestTime"
maxMinutesPerWeek=$((5*60))
maxMinutesPerDay=$((2,5*60))
rootpassDelayInHours=1
while true; do
	#sleep 1m
	sleep 1s
	weektime=$(cat "$weekPath")
	daytime=$(cat "$dayPath")
	weektime=$((weektime+1))
	daytime=$((daytime+1))
	today=$(date +%s)
	daylimit=$(cat "$dayTimePath")
	weeklimit=$(cat "$weekTimePath")
	request=$(cat  "$requestPath")

	if (( today > daylimit )) ;
	then
		#daybegins=$(date -d '05:00 +1 day' +%s)
		daybegins=$(date -d '+20 second' +%s)
		echo "New day ! "
		echo "$daybegins" > $dayTimePath
		daytime=0
	fi

	if (( today > weeklimit ));
	then
		echo "New week ! "
		#weekbegins=$(date -d 'Monday' +%s)
		weekbegins=$(date -d '+40 second' +%s)
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
		echo "$requesttime" > $requestTimePath
	elif echo "$request" | grep -q "password request received"; then
		echo "request pending"
		requesttime=$(cat "$requestTimePath")
		goodtime=$(date -d "-${rootpassDelayInHours} second" +%s)
		echo "$goodtime : $requesttime"
		if (( goodtime > requesttime)); then
			pass=$(cat "$passwordPath")
			echo "rootpasswd : $pass"> $requestPath
			requesttime=$(date +%s)
			echo "$requesttime" > $requestTimePath
		fi

	elif echo "$request" | grep -q "rootpasswd"; then
		echo "root passwd detected"
	else 
		echo "no request" > $requestPath
		requesttime=$(date +%s)
		echo "$requesttime" > $requestTimePath
	fi
	echo "$weektime" > $weekPath
	echo "$daytime" > $dayPath
	echo "week : $weektime day : $daytime"
done
