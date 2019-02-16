CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_DAY_CRSCHK_URGENT(i_appid   IN VARCHAR2,
                                                    i_apptype IN VARCHAR2,
                                                    o_return out NUMBER

                                                    ) IS
  PRAGMA autonomous_transaction;
  /*

  功能名称：  在交叉检查之前取所有即时开卡和即时审批的申请件待交叉检查公用的数据

  用途：      为交叉检查准备数据
  作者：      张峰燕

  时间：      2010-11-22

  数据来源：  s08s1_oscurrentstep, s08s1_appregister


  目标表：    s08s1_chk_app_ontheway


  参数列表：
  --------------------------------------------------------------------

   参数         IN/OUT     类型            说明

  --------------------------------------------------------------------

   v_currdate       IN         DATE            数据日期

   o_return     OUT        NUMBER          0=成功，-1=失败

   o_msg        OUT        VARCHAR2        返回的信息



  返回值：无


  版本历史：

  --------------------------------------------------------------------

   作者             日期           版本号               说明

  --------------------------------------------------------------------

   张峰燕        2010-11-22       1.0                  初始版本
   */

  v_step NUMBER(6);
/*
  o_return NUMBER(6);*/

  o_msg VARCHAR2(400);

  v_currdate date;

BEGIN

  v_step := 10;

  select currdate into v_currdate from s08sysparm;

  v_step := 20;

  --去除在途表中已结束的申请件
  DELETE FROM S08S1_CHK_APP_ONTHEWAY A

   WHERE NOT EXISTS

   (SELECT 1 FROM S08S1_OSCURRENTSTEP O WHERE O.ENTRY_ID = A.ENTRY_ID);

  v_step := 30;

  --初始化汽车牌照

 UPDATE S08S1_PROPOSERAPPEND T
--begin achilles version_201108 20110601 添加了stamp=currentstamp,用于在Trans时做增量卸数
    SET t.stamp=currentstamp, T.AUTONO = S08F_GET_AUTONUMBER(T.FIELDSVALUE)
--end achilles version_201108 20110601 添加了stamp=currentstamp,用于在Trans时做增量卸数
  WHERE T.AUTONO IS NULL

    AND T.APPID = I_APPID;

  v_step := 40;

  --调用批量业务规则检查作业
  S08P1_DAY_RULES_URGENT(i_appid, i_apptype,o_return);

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    o_return := -1 ;
    ROLLBACK;

END S08P1_DAY_CRSCHK_URGENT;
/
