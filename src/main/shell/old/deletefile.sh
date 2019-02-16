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

if [ ! -d ${LOG_HOME}/S00/${NOWDATE} ];then
     mkdir -p ${LOG_HOME}/S00/${NOWDATE}
fi
LOGFILE="${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}_sh.log"
echo "[START][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">${LOGFILE}

#批量日志清理
java batpub.DelByPattern ${LOG_HOME}/S00 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100 
java batpub.DelByPattern ${LOG_HOME}/S21 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/S31 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/S36 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/S71 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/S82 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/S66 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToBAT ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToBAT_DEL ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToP9 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToP9_DEL ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToP3 ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${LOG_HOME}/ToCCMS ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100

java batpub.DelByPattern ${DATA_HOME}/file/mig ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30
java batpub.DelByPattern ${DATA_HOME}/file/mig_DEL ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30

#卸数文件清理
java batpub.DelByPattern ${DATA_HOME}/file/output/a0581/000000000/data/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${DATA_HOME}/file/output/a0581/000000000/ctrl/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100
java batpub.DelByPattern ${DATA_HOME}/file/output/a0581/000000000/ddl/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 100

#联机相关文件清理
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/CCBS/000000000/data/N1/010/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/CCBS/000000000/data/S1/010/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/CCS/000000000/data/BCS_BACKUP/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} CMS_ICS_CPHST_\\d{8}\\.+\(dat\) 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/CCS/000000000/data/BCS_BACKUP/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} CMS_ICS_CPHST_\\d{8}\\.+\(ebcdic\) 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/VSS/000000000/data/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} CMP_TECHDTL_5_\\d{8}\\.+\(txt\) 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/input/a0651/000000000/data ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30
java batpub.DelByPattern ${DATA_HOME_TRANS}/oltpfile/ ${LOG_HOME}/S00/${NOWDATE}/${PROGFRT}.log ${PROG} [0-9]{8} 30


NOW=`date '+%Y-%m-%d %H:%M:%S'` 
echo "[END  ][PROG:${PROG}][DATE:${NOW}][PID:${PID}]">>${LOGFILE}

exit 0