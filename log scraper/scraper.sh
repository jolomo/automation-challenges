#!/bin/bash

LOG=puppet_access_ssl.log
BASE=/production/file_metadata/modules/ssh/sshd_config?

SSHDCOUNT=0
SSHD200COUNT=0
SSHDnon200COUNT=0
RETURN200=0
RETURNnon200=0
REPORTPUT=0

# temp file for IP list
IPLIST=/tmp/ips
touch $IPLIST

cat $LOG | tr -d \" | {
        while read ip a b date time op stub prot return eol
        do
                if [ $return = 200 ]
                then
                        ((RETURN200++))
                else
                        ((RETURNnon200++))
                fi
                if [ $BASE = $stub ]
                then
                        ((SSHDCOUNT++))
                        if [ $return = 200 ]
                        then
                                ((SSHD200COUNT++))
                        else
                                ((SSHDnon200COUNT++))
                        fi

                else
                        if [[ $stub =~ /dev/report/* ]]
                        then
                                if [ $op = PUT ]
                                then
                                        ((REPORTPUT++))
                                        echo $ip >> $IPLIST
                                fi
                        fi
                fi
        done
echo Total fetches of sshd_config: $SSHDCOUNT
echo Total fetches of sshd_config with non-200 return code: $SSHDnon200COUNT
echo Total requests with non-200 return code: $RETURNnon200
echo Total PUT requests of "/dev/report/*": $REPORTPUT
echo Total PUT requests of "/dev/report/*" by IP address:
sort $IPLIST | sort -n | uniq -c
}

# cleanup
rm $IPLIST
