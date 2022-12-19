#!/bin/bash
ip="121.0.2.2"
if [[ $ip =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]
then
    echo "Match"
    echo ${BASH_REMATCH[1]}
    echo ${BASH_REMATCH[2]}
    echo ${BASH_REMATCH[3]}
    echo ${BASH_REMATCH[4]}
else
    echo "Not match"
fi


