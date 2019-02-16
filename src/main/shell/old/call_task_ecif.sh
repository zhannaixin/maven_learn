# This is a shell script for Unix-Like os to run TaskServer in ciss batch enviroment
# Author: Garfield
. /app/batch/shell/env_ccfs.sh
CLASSPATH=$CLASSPATH:/app/batch/javalib:/app/batch/javalib/lib/s08/task-core.jar:/app/batch/javalib/lib/commons-httpclient-3.1.jar:/app/batch/javalib/lib/commons-codec-1.3.jar:/app/batch/javalib/lib/s08/commons-logging-1.1.jar:/app/batch/javalib/lib/s08/weblogic.jar:/app/batch/javalib/lib/s08/bank-comm.jar:/app/batch/shell/s08
echo $CLASSPATH
cd /app/batch/javalib

java -cp $CLASSPATH cn.ccb.icc.task.impl.TaskServer \
        task.taskworker.connection.provider=cn.ccb.icc.task.impl.DBCONNConnectionProvider \
        task.taskserver.batch_size=100 \
        task.taskrunner.multi_thread.pool_size=2 \
        task.delayminutes=290 \
        java.naming.provider.url=t3://128.192.140.10:9003 \
        task.taskserver.target_type=08611M,08611C;
# 08611J = ren hang zheng xing 
# 08611K = ecif 
# 08611H = yu ping fen 
# 08611I = ping fen 
# add ecif check card msg Author: HuSongsong  Jarvis E-Mail:marsdragon@live.cn Time:2011-11-29
# 08611C =ecif check card
# 加上参数 task.taskserver.target_type=08611H,08611I 可指定本脚本只处理指定类型(08611H和08611I)的任务