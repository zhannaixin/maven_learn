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
#####################检查并创建日志目录#############################################

if [ ! -d ${LOG_HOME}/S08/${NOWDATE} ];then
     mkdir -p ${LOG_HOME}/S08/${NOWDATE}
fi
LOGFILE="${LOG_HOME}/S08/${NOWDATE}/${PROGFRT}_sh.log"
echo "[START][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">${LOGFILE}

java ${JAVA_OPTIONS} batpub.CallSP ${PROGFRT} ${LOG_HOME}/S08/${NOWDATE}/${PROGFRT}.log 0 ${TRANS_SID}:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd ${ENTITY_ID} parm
RET=$?
NOW=`date '+%Y-%m-%d %H:%M:%S'` 
echo "[INFO][PROG:${PROG}][DATE:${NOW}][PID:${PID}][RET:${RET}][SID:${TRANS_SID}]">>${LOGFILE}

java ${JAVA_OPTIONS} batpub.CallSP ${PROGFRT} ${LOG_HOME}/S08/${NOWDATE}/${PROGFRT}.log 0 ${BATCH_SID}:S00T1_Cmpt_Ent_Parm_Inf:Bfr_1_OprgDay_Prd ${ENTITY_ID} parm
if [ $? -ne 0 ]
    then
        RET=$?
fi
NOW=`date '+%Y-%m-%d %H:%M:%S'` 
echo "[INFO][PROG:${PROG}][DATE:${NOW}][PID:${PID}][RET:${RET}][SID:${BATCH_SID}]">>${LOGFILE}

NOW=`date '+%Y-%m-%d %H:%M:%S'` 
echo "[END  ][PROG:${PROG}][DATE:${NOW}][PID:${PID}][RET:${RET}]">>${LOGFILE}

if [ $RET -ne 0 ]
then
   exit -1
fi   

exit 0