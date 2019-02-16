CREATE OR REPLACE procedure CISSAPS.S08P_COLLECTIONMYINBOX(
                                                      N_TASKID   IN NUMBER,
                                                      N_OPERID   IN VARCHAR2,
                                                      N_OPERTYPE IN VARCHAR2,
                                                      N_STEPID   IN NUMBER,
                                                      N_ORG      IN VARCHAR2,
                                                      O_MSG      OUT VARCHAR2) AS
  /*
  功能名称：    收件箱收件
  用途：        我的收件箱收件
  执行周期：    每日
  作者：        hesg
  时间：        2012-08-14

  数据来源：    S08S1_PROPOSER, S08S1_APPREGISTER,
                S08S1_OSCURRENTSTEP,S08S1_OSCURR_MYINBOX
  目标表：      S08S1_OSCURR_MYINBOX,S08S1_OSCURRENTSTEP

  关键代码解读：1 ：收取审批岗加急件
                2 ：收取审批岗普通件
                3 ：收取审批岗加急件(特殊情况)
                4 ：收取征信岗加急件
                5 ：收取征信岗普通件
                6 ：收取征信岗加急件(特殊情况)

  参数列表：
  --------------------------------------------------------------------
   参数         IN/OUT     类型            说明
  --------------------------------------------------------------------
   N_OPERID       IN        VARCHAR2        操作员编号
   N_STEPID       IN        NUMBER          环节编号
   N_ORG          IN        VARCHAR2        机构编号
   V_RETURN      OUT       NUMBER          -1=更新失败;0=没有可更新的数据;其他为成功收件数量
   O_MSG         OUT       VARCHAR2        返回的信息

  版本历史：
  --------------------------------------------------------------------
   作者             日期           版本号               说明
  --------------------------------------------------------------------
   何书光         2012-08-14       1.0                  初始版本
  */

  V_OPERID   VARCHAR2(11); --操作员编号
  V_STEPID   NUMBER; --环节编号
  V_ORG      VARCHAR2(20); --机构编号
  V_OPERTYPE VARCHAR(2); --操作员类型

  OWN_NUM        NUMBER; --操作员已收取的件数
  MAX_NUM        NUMBER; --操作员所在岗位最大可收取的件数
  COL_NUM        NUMBER := 0; --可获取的最大件数
  PRE_NUM        NUMBER := 0; --规定收取的件数
  REL_NUM        NUMBER := 0; -- 实际收取件数
  V_OPER_MAXRMB  NUMBER := 0;
  APPPRI_PRE_NUM NUMBER := 0; --加急类型件规定收取件数

  SQL_SELECT       VARCHAR2(2000); --查询字段
  TAB_SURVEY_PRI   VARCHAR2(100);
  TAB_SURVEY_GEN   VARCHAR2(100);
  TAB_APPROVE_PRI  VARCHAR2(100);
  TAB_APPROVE_GEN  VARCHAR2(100);
  SQL_PARA_SURVEY  VARCHAR2(200);
  SQL_PARA_APPROVE VARCHAR2(200);
  SQL_ORDER        VARCHAR2(200); --排序

  F_RETURN_API VARCHAR2(2000);
  F_RETURN_GEN VARCHAR2(2000);
  F_NUM    NUMBER := 0;
  F_SQL    VARCHAR2(2000);

  O_RESULT VARCHAR2(1000):='';

  inboxFullException Exception; --收件箱已满异常
  inboxNullException Exception; --未能收取的件，即0件
  inboxException Exception; --收件内部异常

  rows     varchar2(255);
  V_RETURN NUMBER;

BEGIN
  V_RETURN   := 10;
  V_OPERID   := N_OPERID;
  V_STEPID   := N_STEPID;
  V_ORG      := N_ORG;
  V_OPERTYPE := N_OPERTYPE;

  V_RETURN := 20;
  --1，获取操作员已收取的件数
  rows := '获取操作员现有的申请件数量';
  select count(1)
    into OWN_NUM
    from s08s1_oscurrentstep o
   where o.step_id in (18, 20)
     and o.owner = V_OPERID;

  V_RETURN := 20;
  --2，获取操作员所在岗位最大可收取的件数
  rows := '获取操作员所在岗位最大可收取的件数';
  select NVL(p.pvalue, 0)
    into MAX_NUM
    from s08s1_parameter p
   where code = V_STEPID || 'inboxMaxNum';

  --3，计算出可收取的件数

  rows    := '计算出可收取的件数，如果为0，或者小于0，直接退出';
  COL_NUM := MAX_NUM - OWN_NUM;
  if COL_NUM <= 0 and V_OPERTYPE = '0' THEN
    V_RETURN := 30;
    raise inboxFullException;
  ELSE
    --4，获取操作员所在岗位每次可收取件数
    rows := '获取操作员所在岗位每次可收取件数';
    select NVL(p.pvalue, 0)
      into PRE_NUM
      from s08s1_parameter p
     where code = V_STEPID || 'inboxPreNum';

    --5,获取操作员所在岗位每次可收取加急件数
    rows := '获取操作员所在岗位每次可收取加急件数';
    select NVL(p.pvalue, 0)
      into APPPRI_PRE_NUM
      from s08s1_parameter p
     where code = 'inboxApppriNum';

    IF V_OPERTYPE = '0' THEN
      --普通操作员
      if COL_NUM < PRE_NUM THEN
        REL_NUM := COL_NUM;
      else
        REL_NUM := PRE_NUM;
      END IF;
    ELSE
      --岗位主管
      REL_NUM := PRE_NUM;
    END IF;

    V_RETURN := 40;
    --获取操作员最大处理额度
    rows := '获取操作员' || V_OPERID || '最大处理额度';
    SELECT NVL(O.MAX_RMB, 0)
      into V_OPER_MAXRMB
      FROM S08S1_OPERATOR O
     WHERE O.OPERID = V_OPERID;

    V_RETURN := 50;

    rows             := 'SQL组装...';
    SQL_SELECT       := 'SELECT ENTRY_ID FROM (select s.entry_id from ';
    TAB_SURVEY_GEN   := 'S08S1_SURVEY_GEN';
    TAB_SURVEY_PRI   := 'S08S1_SURVEY_PRI';
    TAB_APPROVE_GEN  := 'S08S1_APPROVE_GEN';
    TAB_APPROVE_PRI  := 'S08S1_APPROVE_PRI';
    SQL_PARA_SURVEY  := ' s where s.org=to_char(' || V_ORG || ') and s.flag=''0''';
    SQL_PARA_APPROVE := ' s where s.org=to_char(' || V_ORG ||
                        ') and s.flag=''0'' and NVL(s.c_credit_rmb,0) <=' ||
                        V_OPER_MAXRMB;
    SQL_ORDER        := ' order by s.filldate ) where rownum<=';

    --4 根据条件查找出符合条件的数据
    if V_STEPID = 20 THEN
      --审批岗位
      IF REL_NUM >= APPPRI_PRE_NUM THEN
        --@1----收取审批岗加急件-----------------------------
        --实应收数>加急数
        F_SQL    := SQL_SELECT || TAB_APPROVE_PRI || SQL_PARA_APPROVE ||
                    SQL_ORDER || APPPRI_PRE_NUM;
        F_RETURN_API := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_APPROVE_PRI); --调用工作流流转函数
        --异常判断
        IF subStr(F_RETURN_API, 0, 6) = '999999' then
          raise inboxException;
        else
          select subStr(F_RETURN_API, 8,instr(F_RETURN_API,'&')-8) into F_NUM from dual;
        end if;
        ---@1--------------------------------------------

        ---@2-----收取审批岗普通件------------------------------
        F_SQL    := SQL_SELECT || TAB_APPROVE_GEN || SQL_PARA_APPROVE ||
                    SQL_ORDER || (REL_NUM - F_NUM);

        F_RETURN_GEN := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_APPROVE_GEN);
         --异常判断
        IF subStr(F_RETURN_GEN, 0, 6) = '999999' then
          raise inboxException;
        END IF;
        IF (F_NUM+subStr(F_RETURN_GEN,8,instr(F_RETURN_GEN,'&')-8)) = 0 then
          raise inboxNullException;
        END IF;
        ---@2----------------------------------------------------

      ELSE
        ---@3------收取审批岗加急件-------------------------------
        F_SQL    := SQL_SELECT || TAB_APPROVE_PRI || SQL_PARA_APPROVE ||
                    SQL_ORDER || REL_NUM;
        F_RETURN_API := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_APPROVE_PRI); --调用工作流流转函数
         --异常判断
        IF subStr(F_RETURN_API, 0, 6) = '999999' then
          raise inboxException;
        END IF;
        IF subStr(F_RETURN_API,8,instr(F_RETURN_API,'&')-8) = 0 then
          raise inboxNullException;
        END IF;
         ---@3-----------------------------------------------------
      END IF;
    ELSE

      --征信岗位
      IF REL_NUM >= APPPRI_PRE_NUM THEN
        ---@4--------收取征信岗加急件-------------------------------
        --实应收数>加急数
        F_SQL    := SQL_SELECT || TAB_SURVEY_PRI || SQL_PARA_SURVEY ||
                    SQL_ORDER || APPPRI_PRE_NUM;
        F_RETURN_API := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_SURVEY_PRI); --调用工作流流转函数
         --异常判断
        IF subStr(F_RETURN_API, 0, 6) = '999999' then
          raise inboxException;
        else
          select subStr(F_RETURN_API, 8,instr(F_RETURN_API,'&')-8) into F_NUM from dual;
        end if;
         ---@4--------------------------------------------

         ---@5-------收取征信岗普通件---------------------------------
        F_SQL    := SQL_SELECT || TAB_SURVEY_GEN || SQL_PARA_SURVEY ||
                    SQL_ORDER || (REL_NUM - F_NUM);
        F_RETURN_GEN := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_SURVEY_GEN);
         --异常判断
        IF subStr(F_RETURN_GEN, 0, 6) = '999999' then
          raise inboxException;
        END IF;
         IF (F_NUM+subStr(F_RETURN_GEN,8,instr(F_RETURN_GEN,'&')-8)) = 0 then
          raise inboxNullException;
        END IF;
         ---@5----------------------------------------------------------

      else
        ---@6---------收取征信岗加急件---------------------------------
        F_SQL    := SQL_SELECT || TAB_SURVEY_PRI || SQL_PARA_SURVEY ||
                    SQL_ORDER || APPPRI_PRE_NUM;
        F_RETURN_API := s08f1_excsql_myinbox(F_SQL,
                                         V_STEPID,
                                         V_OPERID,
                                         TAB_SURVEY_PRI); --调用工作流流转函数
        --异常判断
        IF subStr(F_RETURN_API, 0, 6) = '999999' then
          raise inboxException;
        END IF;
         IF subStr(F_RETURN_API,8,instr(F_RETURN_API,'&')-8) = 0 then
          raise inboxNullException;
        END IF;
       ---@6------------------------------------------------------------
      end if;

    END IF;
    rows:='收件完成，更新任务表执行状态！';
    IF LENGTH(F_RETURN_API)>12 THEN
      O_RESULT:=SUBSTR(F_RETURN_API,INSTR(F_RETURN_API,'&')+1);
    END IF;
    IF LENGTH(F_RETURN_GEN)>12 THEN
       IF length(O_RESULT)>1 THEN
          O_RESULT:=O_RESULT||','||SUBSTR(F_RETURN_GEN,INSTR(F_RETURN_GEN,'&')+1);
       else
          O_RESULT:=SUBSTR(F_RETURN_GEN,INSTR(F_RETURN_GEN,'&')+1);
      end if;
    END IF;
    IF length(O_RESULT)>1  THEN
      O_RESULT:='666666@收件成功，但未找到以下实例编号的申请件：'||O_RESULT;
       IF length(O_RESULT)>230  THEN
        O_RESULT:=SUBSTR(O_RESULT,0,230)||'...';
      END IF;
    END IF;
    update s08s1_task t set t.status='3',t.lastupdatetime=sysdate,t.result=O_RESULT where t.taskid=N_TASKID;
    commit;
    o_msg:='666666@收件成功！';
  END IF;

EXCEPTION

  --收件箱已满
  WHEN inboxFullException THEN
    o_msg:='666666@该操作员收件箱已满！,taskid:'||N_TASKID;
    update s08s1_task t set t.status='3',t.lastupdatetime=sysdate,t.result=o_msg where t.taskid=N_TASKID;
    commit;
    --不存在可收取的申请件
  WHEN inboxNullException THEN
    o_msg:='666666@没有符合条件的申请件！,taskid:'||N_TASKID;
    update s08s1_task t set t.status='3',t.lastupdatetime=sysdate,t.result=o_msg where t.taskid=N_TASKID;
    commit;
  WHEN inboxException THEN
    IF F_RETURN_API IS NOT NULL THEN
    o_msg := F_RETURN_API;
    ELSif F_RETURN_GEN IS NOT NULL THEN
      o_msg:=F_RETURN_GEN;
    ELSE
      o_msg:='999999@收件异常';
    END IF;
    update s08s1_task t set t.status='4',t.lastupdatetime=sysdate,t.result=o_msg where t.taskid=N_TASKID;
    commit;
 WHEN OTHERS THEN
    o_msg:='999999@'||rows||SQLERRM(SQLCODE);
     update s08s1_task t set t.status='4',t.lastupdatetime=sysdate,t.result=o_msg where t.taskid=N_TASKID;
     commit;

END;
/
