CREATE OR REPLACE FUNCTION CISSAPS.S08F1_OS_DOACTION(
                  N_ENTRY_ID         S08S1_OSCURRENTSTEP.ENTRY_ID%TYPE,
                  V_OLD_STATUS       S08S1_OSCURRENTSTEP.STATUS%TYPE,
                  V_STATUS           S08S1_OSCURRENTSTEP.STATUS%TYPE,
                  I_STEPID           S08S1_OSCURRENTSTEP.STEP_ID%TYPE,
                  I_ACTIONID         S08S1_OSCURRENTSTEP.ACTION_ID%TYPE,
                  V_OWNER            S08S1_OSCURRENTSTEP.OWNER%TYPE,
                  V_CALLER           S08S1_OSCURRENTSTEP.CALLER%TYPE
                  ) RETURN VARCHAR2 AS

/*
功能名称：  流程流转
用途：      根据输入参数将流程实例流转
作者：      王志
时间：      2007-12-10

参数列表：
-------------------------------------------------------------------------------------
  参数             IN/OUT     类型                                 说明
-------------------------------------------------------------------------------------
  N_ENTRY_ID      IN         NUMBER                               工作流实例id
  V_OLD_STATUS    IN         VARCHAR2                             旧状态
  V_STATUS        IN         VARCHAR2                             新状态
  I_STEPID        IN         NUMBER                               新环节
  I_ACTIONID      IN         NUMBER                               动作id
  V_OWNER         IN         VARCHAR2                             拥有人
  V_CALLER        IN         VARCHAR2                             调用者

  RESULT          OUT        VARCHAR2                             暂时无

返回值：VARCHA2



版本历史：
--------------------------------------------------------------------
  作者             日期           版本号               说明
--------------------------------------------------------------------
  王志            2007-12-10      1.0                  初始版本
  陈铭森          2008-06-05      1.2                  去掉前置表

*/

  RESULT                                              VARCHAR2(1000);
  EXP                                                 EXCEPTION;
  ROW_OSCUR_OLD                                       S08S1_OSCURRENTSTEP%ROWTYPE;
  ROW_OSHIS                                           S08S1_OSHISTORYSTEP%ROWTYPE;
  ROW_OSCUR_NEW                                       S08S1_OSCURRENTSTEP%ROWTYPE;

BEGIN
  --查询当前流程表
  SELECT T.* INTO ROW_OSCUR_OLD FROM S08S1_OSCURRENTSTEP T
  WHERE T.ENTRY_ID = N_ENTRY_ID;

  ROW_OSHIS.ID := ROW_OSCUR_OLD.ID;
  ROW_OSHIS.ENTRY_ID := ROW_OSCUR_OLD.ENTRY_ID;
  ROW_OSHIS.STEP_ID := ROW_OSCUR_OLD.STEP_ID;
  ROW_OSHIS.ACTION_ID := I_ACTIONID;
  ROW_OSHIS.OWNER := ROW_OSCUR_OLD.OWNER;
  ROW_OSHIS.START_DATE := ROW_OSCUR_OLD.START_DATE;
  ROW_OSHIS.FINISH_DATE := SYSDATE;
  ROW_OSHIS.STATUS := V_OLD_STATUS;
  IF V_CALLER IS NOT NULL THEN
     ROW_OSHIS.CALLER := V_CALLER;
  ELSE
     ROW_OSHIS.CALLER := ROW_OSCUR_OLD.OWNER;
  END IF;
  ROW_OSHIS.BUZSTARTDATE := ROW_OSCUR_OLD.BUZSTARTDATE;
  SELECT T.CURRDATE INTO ROW_OSHIS.BUZENDDATE FROM S08SYSPARM T WHERE T.INO = '000000000';

  ROW_OSHIS.PREV_STEPIDS := ROW_OSCUR_OLD.PREV_STEPIDS; --add by chenms on 20080606
  --增加历史流程
  INSERT INTO S08S1_OSHISTORYSTEP
  (
      ID,
      ENTRY_ID,
      STEP_ID,
      ACTION_ID,
      OWNER,
      START_DATE,
      FINISH_DATE,
      STATUS,
      CALLER,
      BUZSTARTDATE,
      BUZENDDATE,
      prev_stepids  --add by chenms on 20080606
  )
  VALUES
  (
      ROW_OSHIS.ID,
      ROW_OSHIS.ENTRY_ID,
      ROW_OSHIS.STEP_ID,
      ROW_OSHIS.ACTION_ID,
      ROW_OSHIS.OWNER,
      ROW_OSHIS.START_DATE,
      ROW_OSHIS.FINISH_DATE,
      ROW_OSHIS.STATUS,
      ROW_OSHIS.CALLER,
      ROW_OSHIS.BUZSTARTDATE,
      ROW_OSHIS.BUZENDDATE,
      ROW_OSHIS.PREV_STEPIDS--add by chenms on 20080606
  );
  
  --删除当前流程表中记录
  DELETE FROM S08S1_OSCURRENTSTEP T WHERE T.ID = ROW_OSCUR_OLD.ID;

  --查询当前流程表的序号
  SELECT S08S_SEQ_OSCURRENTSTEPS.NEXTVAL INTO ROW_OSCUR_NEW.ID FROM DUAL;
  SELECT T.CURRDATE INTO ROW_OSCUR_NEW.BUZSTARTDATE FROM S08SYSPARM T WHERE T.INO = '000000000';
  ROW_OSCUR_NEW.ENTRY_ID := N_ENTRY_ID;
  ROW_OSCUR_NEW.STEP_ID := I_STEPID;
  ROW_OSCUR_NEW.ACTION_ID := NULL;
  ROW_OSCUR_NEW.OWNER := V_OWNER;
  ROW_OSCUR_NEW.START_DATE := SYSDATE;
  ROW_OSCUR_NEW.FINISH_DATE := NULL;
  ROW_OSCUR_NEW.DUE_DATE := NULL;
  ROW_OSCUR_NEW.STATUS := V_STATUS;
  ROW_OSCUR_NEW.CALLER := NULL;

  ROW_OSCUR_NEW.PREV_STEPIDS :=ROW_OSCUR_OLD.ID;
  --新增记录到当前流程表
  INSERT INTO S08S1_OSCURRENTSTEP
  (
      ID,
      ENTRY_ID,
      STEP_ID,
      ACTION_ID,
      OWNER,
      START_DATE,
      FINISH_DATE,
      DUE_DATE,
      STATUS,
      CALLER,
      BUZSTARTDATE,
      BUZENDDATE,
      prev_stepids
  )
  VALUES
  (
      ROW_OSCUR_NEW.ID,
      ROW_OSCUR_NEW.ENTRY_ID,
      ROW_OSCUR_NEW.STEP_ID,
      ROW_OSCUR_NEW.ACTION_ID,
      ROW_OSCUR_NEW.OWNER,
      ROW_OSCUR_NEW.START_DATE,
      ROW_OSCUR_NEW.FINISH_DATE,
      ROW_OSCUR_NEW.DUE_DATE,
      ROW_OSCUR_NEW.STATUS,
      ROW_OSCUR_NEW.CALLER,
      ROW_OSCUR_NEW.BUZSTARTDATE,
      NULL,
      ROW_OSCUR_NEW.PREV_STEPIDS
  );


  RETURN(RESULT);
END S08F1_OS_DOACTION;
/
