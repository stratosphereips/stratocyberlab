#!/bin/sh

START_DATE=1557352800
END_DATE=1670886000
SERVICES="dashboard proxy mail"

# seed random generator
RANDOM=31337

random() {
  while true; do
    echo $RANDOM
  done
}

for SERVICE in $SERVICES; do
  echo $SERVICE
  HOWMANY=$(shuf -i 0-5000 -n 1 --random-source=<(random))
  for TS in $(shuf -i $START_DATE-$END_DATE --random-source=<(random) -n $HOWMANY | sort -g); do
    FN="$SERVICE$(date --date="@$TS" +"%Y-%m-%d").log"
    ENTRY=$(shuf "${SERVICE}-messages" -n1 --random-source=<(random))
    echo "{\"time\":$TS,\"entry\":\"$ENTRY\"}" >>$FN
  done
done
