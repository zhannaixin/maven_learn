. $HOME/shell/env_ccfs.sh

NOW=`date '+%Y-%m-%d %H:%M:%S'` 
NOWDATE=`date '+%Y%m%d'`
PROG=`basename ${0}`
PID=$$
PROGFRT=`echo ${PROG}|cut -d "." -f1`

#########################Read Config File########################
BATCH_HOME=`echo ${HOME}`
CFGFILE="${BATCH_HOME}/config/PUBCFG.properties"

LOG_HOME="${BATCH_HOME}/log" 
DATA_HOME="${BATCH_HOME}/dat"
DATA_HOME_TRANS="${BATCH_HOME}/file" 
TRANS_SID=`grep -w TRANS_SID ${CFGFILE}|cut -d "=" -t.f2`
BATCH_SID=`grep -w BATCH_SID ${CFGFILE}|cut -d "=" -t.f2`
ENTITY_ID=`grep -w ENTITY_ID ${CFGFILE}|cut -d "=" -t.f2`
#####################检查并创建日志目录#############################################

if [ ! -d ${LOG_HOME}/S08/${NOWDATE} ];then
     mkdir -p ${LOG_HOME}/S08/${NOWDATE}
fi
LOGFILE="${LOG_HOME}/S08/${NOWDATE}/${PROGFRT}_sh.log"
echo "[START][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">${LOGFILE}

#批量清理 参数格式      待清理目录  清理日志文件地址  清理程序ID  文件名正则表达式  文件保留天数
#注意：1.请确保待删除目录存在  2.windows与UNIX中正则表达式写法不一样 3.每个大目录一条记录，分别记录日志
java batpub.DelByPattern /appdata/MAINFRAME/UPLOAD/APSIN ${LOG_HOME}/S08/${NOWDATE}/${PROGFRT}.log ${PROG} .+ 100 

NOW=`date '+%Y-%m-%d %H:%M:%S'` 
echo "[END  ][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">>${LOGFILE}

exit 0