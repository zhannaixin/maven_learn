# This is a shell script for Unix-Like os to run TaskServer in ciss batch enviroment
# Author: Garfield
. /app/batch/shell/env_ccfs.sh
CLASSPATH=$CLASSPATH:/app/batch/javalib:/app/batch/javalib/lib/s08/task-core.jar:/app/batch/javalib/lib/s08/commons-logging-1.1.jar:/app/batch/javalib/lib/s08/weblogic.jar:/app/batch/javalib/lib/s08/CISS.jar:/app/batch/shell/s08
echo $CLASSPATH
cd /app/batch/javalib
a=$(date +%H)  #取小时，24小时显示
if  [ $a -ge 16 ]; then
java -cp $CLASSPATH cn.ccb.icc.task.impl.TaskServer \
        task.taskworker.connection.provider=cn.ccb.icc.task.impl.DBCONNConnectionProvider \
        task.taskserver.batch_size=100 \
        task.taskrunner.multi_thread.pool_size=1 \
        task.delayminutes=290 \
        java.naming.provider.url=t3://11.152.68.173:7004 \
        task.taskserver.target_type=08611O,08611N,08611P;
fi
# 08611J = ren hang zheng xing 
# 08611H = yu ping fen 
# 08611I = ping fen 
# 08611N = ji shi jiao cha jian cha
# 08611O = ji shi song kai ka
# 加上参数 task.taskserver.target_type=08611H,08611I 可指定本脚本只处理指定类型(08611H和08611I)的任务