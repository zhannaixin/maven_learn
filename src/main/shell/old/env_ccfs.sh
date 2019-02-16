export ORACLE_HOME=/home/db/oracle/10g
export LIBPATH=$ORACLE_HOME/lib32:$ORACLE_HOME/lib
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK

export PATH=$PATH
export PATH            # SD Installer: do not remove !

SHLIB_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/ctx/lib:/lib:/usr/lib:$ORACLE_HOME/rdbms/lib:$ORACLE_HOME/lib32; 
export SHLIB_PATH
PATH=/usr/bin:$PATH    # SD Installer: do not remove !
export PATH            # SD Installer: do not remove !

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME/ctx/lib:/lib:/usr/lib:$ORACLE_HOME/rdbms/lib:$ORACLE_HOME/lib32

CLASSPATH=/opt/java1.5/lib/dt.jar:/opt/java1.5/lib/tools.jar:/app/batch/javalib/lib/ojdbc14.jar:.
CLASSPATH=$CLASSPATH:/app/batch/javalib/lib/log4j.jar:/app/batch/javalib/lib/jdom.jar:/app/batch/javalib/lib/velocity-dep-1.4.jar:/app/batch/javalib/lib/s08/CissService_client15.jar:/app/batch/javalib/lib/webserviceclient.jar:/app/batch/javalib/lib/iTextAsian.jar:/app/batch/javalib/lib/itext-2.0.4.jar:/app/batch/javalib/lib/ant-1.6.0.jar:/app/batch/javalib/lib/crimson.jar:/app/batch/javalib/lib/s08/CardService_client.jar:.
export CLASSPATH

export PATH=/opt/java1.5/bin:$ORACLE_HOME/bin:$PATH.

ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
export ORA_NLS33

export LANG=zh_CN.hp15CN