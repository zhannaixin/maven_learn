. $HOME/shell/env_ccfs.sh

NOW=`date '+%Y-%m-%d %H:%M:%S'` 
NOWDATE=`date '+%Y%m%d'`
PROG=`basename ${0}`
PID=$$
PROGFRT=`echo ${PROG}|cut -d "." -f1`
JAVA_OPTIONS="-Djava.security.egd=file:/dev/./urandom"
#########################Read Config File########################
BATCH_HOME=`echo ${HOME}`
CFGFILE="${BATCH_HOME}/config/PUBCFG.properties"

LOG_HOME="${BATCH_HOME}/log" 
DATA_HOME="${BATCH_HOME}/dat" 
TRANS_SID=`grep -w TRANS_SID ${CFGFILE}|cut -d "=" -t.f2`
BATCH_SID=`grep -w BATCH_SID ${CFGFILE}|cut -d "=" -t.f2`
ENTITY_ID=`grep -w ENTITY_ID ${CFGFILE}|cut -d "=" -t.f2`
TOLCNT=`grep -w TOLCNT ${CFGFILE}|cut -d "=" -t.f2`

CFGFILE="${BATCH_HOME}/config/TABMAINT.properties"
TABGATHER_LIST=`grep -w TABGATHER_LIST ${CFGFILE}|cut -d "=" -t.f2`
#####################检查并创建日志目录#############################################


if [ ! -d ${LOG_HOME}/S00/${NOWDATE} ];then
     mkdir -p ${LOG_HOME}/S00/${NOWDATE}
fi
LOGFILE="${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}_sh.log"
echo "[START][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">${LOGFILE}

IFS=',';

for i in ${TABGATHER_LIST} 
    do
        NOW=`date '+%Y-%m-%d %H:%M:%S'` 
        echo "${PROG}:${PID}:${NOW}:${i}:START********" >>${LOGFILE}

        COUNTER=0
        while [ $COUNTER -lt $TOLCNT ]
            do
                java ${JAVA_OPTIONS} batpub.CallSP ${PROGFRT} ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log 0 ${TRANS_SID}:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd ${ENTITY_ID} ${i} 
                
                RET=$?
                NOW=`date '+%Y-%m-%d %H:%M:%S'` 
                echo "[INFO][PROG:${PROG}][DATE:${NOW}][PID:${PID}][SID:${TRANS_SID}][${i}][RET:${RET}]">>${LOGFILE}

                java ${JAVA_OPTIONS} batpub.CallSP ${PROGFRT} ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log 0 ${BATCH_SID}:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd ${ENTITY_ID} ${i} 
                if [ $? -ne 0 ]
                    then 
                        RET=$?
                fi
                NOW=`date '+%Y-%m-%d %H:%M:%S'` 
                echo "[INFO][PROG:${PROG}][DATE:${NOW}][PID:${PID}][SID:${BATCH_SID}][${i}][RET:${RET}]">>${LOGFILE}

                COUNTER=`expr $COUNTER + 1`

                if [ $RET -ne 0 ]
                    then
                        if [ $COUNTER -eq $TOLCNT ]
                            then
                                break
                        fi
                else
                    break
                fi
            done
    
        NOW=`date '+%Y-%m-%d %H:%M:%S'` 
        if [ $RET -ne 0 ];then
            echo "${PROG}:${PID}:${NOW}:${i}:END Failed" >>${LOGFILE}
            echo "[END  ][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">>${LOGFILE}
            exit -1
        else
            echo "${PROG}:${PID}:${NOW}:${i}:END Successed" >>${LOGFILE}
        fi

    done

echo "[END  ][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">>${LOGFILE}
exit 0