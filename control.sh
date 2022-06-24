#!/bin/sh
weekPath="/root/control/weeklycount.txt"
dayPath="/root/control/dailycount.txt"
dayTimePath="/root/control/daytime"
weekTimePath="/root/control/weektime"
maxMinutesPerWeek=$((5*60))
maxMinutesPerDay=$((2,5*60))
while true; do
	sleep 1m
	weektime=$(cat "$weekPath")
	daytime=$(cat "$dayPath")
	weektime=$((weektime+1))
	daytime=$((daytime+1))
	today=$(date +%s)
	daylimit=$(cat "$dayTimePath")
	weeklimit=$(cat "$weekTimePath")
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
	echo "$weektime" > $weekPath
	echo "$daytime" > $dayPath
	echo "week : $weektime day : $daytime"
done
