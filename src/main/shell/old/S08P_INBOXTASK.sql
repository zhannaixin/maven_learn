CREATE OR REPLACE procedure CISSAPS.S08P_INBOXTASK( i_date IN DATE,
                                        o_return out number,
                                        o_msg out varchar2) AS

 /*
   功能名称： 收件箱收件任务调度
   执行周期 ：每日
 */

 V_STEP  NUMBER(6):=0;
 V_TASKNAME VARCHAR2(50);
 V_LEN NUMBER;
 V_TASKID NUMBER;
 V_OPERID VARCHAR2(11);
 V_OPERTYPE VARCHAR2(2);
 V_STEPID NUMBER;
 V_ORG VARCHAR2(9);
 V_MSG VARCHAR2(9);
 err_inboxException Exception;--收件程序异常

 CURSOR CUR_TASKID IS
        select t.taskid
          from s08s1_task t
         where t.status = '0'
           and t.taskgroup = 'TASKTYPE_INBOX'
         order by t.createtime asc;

BEGIN
      o_return:=-1;
      V_STEP:=110;

      --打开游标
      OPEN CUR_TASKID;

      LOOP

      V_STEP:=120;

      FETCH CUR_TASKID
            INTO V_TASKID;
      EXIT WHEN CUR_TASKID%NOTFOUND;

      V_STEP:=130;--根据TASKID查询任务表中记录信息

      select T.TASKID, T.TASKNAME, T.TYPE, T.OWNER
        INTO V_TASKID, V_TASKNAME, V_ORG, V_OPERID
        from s08s1_task t
       where t.taskid = V_TASKID;

      V_STEP:=140;--取TASKNAME字段长度
      select length(V_TASKNAME) into V_LEN FROM DUAL;

      V_STEP:=150;--根据taskname截取环节号及操作员类型

      IF V_LEN>30 THEN
         SELECT SUBSTR(V_TASKNAME,16,2),SUBSTR(V_TASKNAME,31) INTO V_STEPID,V_OPERTYPE FROM DUAL;
      END IF;

      V_STEP:=160;--判断变量是否都已经赋值
      IF V_TASKID IS NOT NULL AND
         V_OPERID IS NOT NULL AND
         V_OPERTYPE IS NOT NULL AND
         V_STEPID IS NOT NULL AND
         V_ORG  IS NOT NULL  THEN

          V_STEP:=170;--调用收件过程
          s08p_collectionmyinbox(V_TASKID,V_OPERID,V_OPERTYPE,V_STEPID,V_ORG,O_MSG);

          V_STEP:=180;--截取返回信息
          SELECT SUBSTR(O_MSG,0,6) INTO V_MSG FROM DUAL;

          IF V_MSG='999999' THEN
            RAISE  err_inboxException;
          END IF;
      END IF;
      END LOOP;
      CLOSE CUR_TASKID;

      o_return:=0;
      IF o_msg is null then
         o_msg:='没有可执行的任务';
      end if;
EXCEPTION
 WHEN err_inboxException then
    o_return:=-1;
 WHEN others then
    o_msg:='收件调度异常：Step=' || V_STEP || ',OraError=' || SQLCODE || ',' ||SQLERRM(SQLCODE);
    o_return:=-1;
END;
/
