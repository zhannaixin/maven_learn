# This is a shell script for Unix-Like os to run TaskServer in ciss batch enviroment
# Author: Garfield
. /app/batch/shell/env_ccfs.sh
CLASSPATH=$CLASSPATH:/app/batch/javalib:/app/batch/javalib/lib/s08/task-core.jar:/app/batch/javalib/lib/s08/commons-logging-1.1.jar:/app/batch/javalib/lib/s08/weblogic.jar:/app/batch/javalib/lib/s08/CISS.jar:/app/batch/shell/s08
echo $CLASSPATH
cd /app/batch/javalib
/opt/java1.5/bin/java batpub.CallUpdate "update s08s1_task a set a.status = '0' where a.type = '08611J' AND A.STATUS = '4' AND A.RESULT like '089996%' AND A.LASTUPDATETIME > (SELECT b.currdate - 1 FROM S08SYSPARM B)" s08
/opt/java1.5/bin/java -cp $CLASSPATH cn.ccb.icc.task.impl.TaskServer \
        task.taskworker.connection.provider=cn.ccb.icc.task.impl.DBCONNConnectionProvider \
        task.taskserver.batch_size=100 \
        task.taskrunner.multi_thread.pool_size=2 \
        task.delayminutes=290 \
        java.naming.provider.url=t3://128.192.140.10:9003 \
        task.taskserver.target_type=08611J;
# 08611J = ren hang zheng xing 
# 08611H = yu ping fen 
# 08611I = ping fen 
# 加上参数 task.taskserver.target_type=08611H,08611I 可指定本脚本只处理指定类型(08611H和08611I)的任务