CREATE OR REPLACE procedure CISSAPS.s08p1_day_makeInboxData( i_date IN DATE,o_return OUT NUMBER,o_msg OUT VARCHAR2)
as
/*
  功能名称：    准备收件数据
  用途：        为我的收件箱收件，提供数据队列
  执行周期：    每日
  作者：        hesg
  时间：        2012-11-06

  数据来源：    S08S1_PROPOSER, S08S1_APP_SORT
                S08S1_OSCURRENTSTEP
  目标表：      S08S1_SURVEY_GEN,S08S1_SURVEY_PRI
                S08S1_APPROVE_GEN,S08S1_APPROVE_PRI

  参数列表：
  --------------------------------------------------------------------
   参数         IN/OUT     类型            说明
  --------------------------------------------------------------------
   o_return      OUT       NUMBER          -1=失败;0=成功
   o_msg         OUT       VARCHAR2        返回信息

  版本历史：
  --------------------------------------------------------------------
   作者             日期           版本号               说明
  --------------------------------------------------------------------
   何书光         2012-11-06       1.0                  初始版本
  */
v_step number;

BEGIN
  o_return := -1;
  v_step := 100;
  execute immediate 'truncate table s08s1_survey_gen';
  execute immediate 'truncate table s08s1_survey_pri';
  execute immediate 'truncate table s08s1_approve_gen';
  execute immediate 'truncate table s08s1_approve_pri';

  v_step := 110;--征信调查普通件收件队列
  insert into s08s1_survey_gen
    select s.appid, o.entry_id, o.step_id, o.owner, s.filldate, '0'
      from s08s1_oscurrentstep o
     inner join S08S1_APP_SORT s
        on o.entry_id = s.entry_id
     where o.step_id = 18
       and o.status = 'assigning'
       and s.apptype not in ('02', '03')
       and s.apppri = '1';
   commit;

   v_step := 120;----征信调查加急件收件队列
   insert into s08s1_survey_pri
    select s.appid, o.entry_id, o.step_id, o.owner, s.filldate, '0'
      from s08s1_oscurrentstep o
     inner join S08S1_APP_SORT s
        on o.entry_id = s.entry_id
     where o.step_id = 18
       and o.status = 'assigning'
       and s.apptype not in ('02', '03')
       and s.apppri = '2';
   commit;

   v_step := 130;--审批环节普通件收件队列
   insert into s08s1_approve_gen
   select s.appid,
          o.entry_id,
          o.step_id,
          o.owner,
          s.filldate,
          p.c_credit_rmb,
          '0'
     from s08s1_oscurrentstep o
    inner join S08S1_APP_SORT s
       on o.entry_id = s.entry_id
     left join s08s1_proposer p
       on s.appid = p.appid
    where o.step_id = 20
      and o.status = 'assigning'
      and p.inputseq = '0'
      and s.apptype not in ('02', '03')
      and s.apppri = '1';
     commit;

   v_step := 140;--审批环节加急件收件队列
   insert into s08s1_approve_pri
   select s.appid,
          o.entry_id,
          o.step_id,
          o.owner,
          s.filldate,
          p.c_credit_rmb,
          '0'
     from s08s1_oscurrentstep o
    inner join S08S1_APP_SORT s
       on o.entry_id = s.entry_id
     left join s08s1_proposer p
       on s.appid = p.appid
    where o.step_id = 20
      and o.status = 'assigning'
      and p.inputseq = '0'
      and s.apptype not in ('02', '03')
      and s.apppri = '2';
     commit;

  o_return := 0;

  o_msg := '执行过程s08p1_day_makeInboxData成功';
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  o_return := -1;
  o_msg := 'Step='||V_STEP||',OraError='||SQLCODE||','||SQLERRM(SQLCODE);

END;
/
