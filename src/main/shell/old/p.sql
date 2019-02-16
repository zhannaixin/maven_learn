
CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_DAY_CLEAN_TASK(I_DATE   IN DATE,
                                                     O_RETURN OUT NUMBER,
                                                     O_MSG    OUT VARCHAR2) AS
 /*
  功能名称：    任务过期或者和已经完成的任务
  用途：        清理前一日没有完成的人行征信的任务。
  执行周期：    每日
  作者：        林辛
  时间：        2008-10-23
  数据来源：    s08s1_task
  目标表：      s08s1_task

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
   林辛          2008-10-23       1.0                  初始版本
  */



BEGIN
  -- 取消过期无法操作的人行征信
  UPDATE s08s1_task  a set a.STATUS = '5', a.lastupdatetime = sysdate where a.status = '0' and a.TYPE ='08611J'
         and  CREATETIME < sysdate -2;
  -- 清理到期的已经完成的任务
  delete from s08s1_task a where a.status in ('3','5')  and lastupdatetime <  sysdate - 10;

  O_RETURN := 0;
  O_MSG    := '执行 S08P1_DAY_CLEAN_TASK  成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_MSG := '清理过期的任务失败。' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P1_DAY_CLEAN_TASK;
/



CREATE OR REPLACE procedure CISSAPS.s08p_addInquiryCustType (V_BIZDATE  IN DATE ,
                                                       O_RETURN OUT NUMBER ,
                                                        O_MSG OUT VARCHAR2) IS



     V_STEP NUMBER(6);
     CURSOR row_appid is
     select t.appid
     from s08s1_inquiry_cust_type t,s08t4_transfer_pre p
     where t.appid=p.appid;

     v_appid    s08s1_inquiry_cust_type.appid%TYPE;--申请书编号
     v_note   varchar2(1000);--客户类型（占用）
     v_num    NUMBER;--质检表计数
     v_pnum   NUMBER;--申请人表计数
     v_type1 varchar2(100);--预审批客户
     v_type2 varchar2(100);--公积金客户
     v_type3 varchar2(100);--代发客户
     v_type4 varchar2(100);--航空类客户
     v_type5 varchar2(100);--百货类客户
     v_type6 varchar2(100);--房产类客户
     v_type7 varchar2(100);--车产类客户
     v_type8 varchar2(100);--其他类型客户
     v_type9 varchar2(100);--试点政策客户
     v_type10 varchar2(100);--不参与决策客户
     v_lowest_limit varchar2(100);--可接受最低额度

     v_a_flag varchar2(2);
     v_status varchar2(2);
     v_sort   varchar2(2);

   BEGIN
   V_STEP :=10;
   OPEN row_appid;
     LOOP
         FETCH   row_appid
            INTO v_appid;
              EXIT  WHEN row_appid%NOTFOUND  OR row_appid%NOTFOUND IS NULL;
   V_STEP :=20;--取客户类型信息

   BEGIN
   SELECT case
                when t.pre_approve_flag='1' then
                '预审批客户-预审批额度:'||t.pre_approve_limit
                else
                ''
                end type1,
         case
               when t.accumulation_fund_flag='1' then
               '公积金客户-月收入:'|| t.monthly_income
               else
               ''
               end type2,
         case
               when t.payroll_flag='1' then
               '代发客户-月均工资:'|| t.monthly_salary
               else
               ''
               end type3,
         case
               when t.airline_flag='1' then
               '航空类客户-飞行次数:'||t.flights
               else
               ''
               end  type4,
         case
               when  t.merchandise_flag='1' then
               '百货类客户-消费金额:'||t.expense
               else
               ''
               end type5 ,
         case
               when t.housing_flag='1' then
               '房产类客户-房产价值:'||t.property_value
               else
               ''
               end type6,
         case
               when t.car_flag='1' then
               '车产类客户-车产价值:'||t.car_value
               else
               ''
               end type7,
         case
               when t.other_type_flag='1'  then
               '其他类型客户-客户类型:'||t.cust_type||',可推算月收入:'||t.calculate_income
               else
               ''
               end type8,
          case
              when t.experiment_flag='1' then
              '试点政策客户-试点政策代码:'||t.exp_policy
              else
              ''
              end type9,
          case
              when t.non_decision_flag='1' then
              '不参与决策客户-客户类型:'||t.decision_cust_type
              else
              ''
              end type10,
          case
              when t.lowest_limit is not null then
               '可接受最低额度:'|| t.lowest_limit
               else
               ''
               end lowestLimit
          into
               v_type1,
               v_type2,
               v_type3,
               v_type4,
               v_type5,
               v_type6,
               v_type7,
               v_type8,
               v_type9,
               v_type10,
               v_lowest_limit
                from s08s1_inquiry_cust_type t
                where t.appid=v_appid;

   if length(v_type1)>0 or length(v_type2)>0 or length(v_type3)>0 or length(v_type4)>0 or length(v_type5)>0 or
   length(v_type6)>0 or length(v_type7)>0 or length(v_type8)>0 or length(v_type9)>0 or length(v_type10)>0
   or length(v_lowest_limit)>0 then

     V_STEP :=30;--客户类型不为空，组装客户类型信息集合
      v_note:='';
      if length(v_type1)>0 then v_note :=v_type1;end if ;
      if length(v_type2)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type2; else v_note :=v_type2;end if ;end if;
      if length(v_type3)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type3; else v_note :=v_type3;end if ;end if;
      if length(v_type4)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type4; else v_note :=v_type4;end if ;end if;
      if length(v_type5)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type5; else v_note :=v_type5;end if ;end if;
      if length(v_type6)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type6; else v_note :=v_type6;end if ;end if;
      if length(v_type7)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type7; else v_note :=v_type7;end if ;end if;
      if length(v_type8)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type8; else v_note :=v_type8;end if ;end if;
      if length(v_type9)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type9; else v_note :=v_type9;end if ;end if;
      if length(v_type10)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_type10; else v_note :=v_type10;end if ;end if;
      if length(v_lowest_limit)>0 then if length(v_note)>0 then v_note:=v_note||'|'||v_lowest_limit; else v_note :=v_lowest_limit;end if ;end if;

   V_STEP :=40;--检查客户类型变量长度，过长则需要截取
   if lengthb(v_note)>=300 then
     v_note:=substrb(v_note,0,298);
     end if;
   V_STEP :=50;--查询质检表是否存在相关记录
   SELECT COUNT(1)
       into v_num
          FROM S08S1_QUALITYA S
            WHERE S.APPID=v_appid;

    if v_num =0 then --质检表中不存在则插入一条相关记录

         V_STEP :=55;--质检申请人表是否存在数据

          select count (1)
            into v_pnum
             from s08s4_proposer p
              where p.appid=v_appid
                and p.inputseq=0;

     if v_pnum >0 then
       V_STEP :=60;--读取申请人审批结论
        select nvl(p.a_flag,'1')
          into v_a_flag
            from s08s4_proposer p
             where p.appid=v_appid
               and p.inputseq = 0
               and rownum<2;
     if  v_a_flag ='1' then --设置质检表“审批状态”，“分类”值

       v_status:='1'; v_sort:='3';
       elsif v_a_flag='2' then
          v_status:='2'; v_sort:='4';
          else null;
          end if;

          V_STEP :=70;--向质检表插入数据

           INSERT INTO S08S1_QUALITYA
           (APPID,
           NAME,
           ID,
           APPTYPE,
           START_DATE,
           OPERNAME,
           OPERID,
           H_ERROR,
           NOTE,
           Q_FLAG,
           Q_STATUS,
           Q_SORT,
           A_ESPECIAL,
           H_RETCODE,
           A_CREDIT_RMB,
           ORG,
           OPER,
           stamp)
           SELECT DISTINCT
                          A.APPID,
                          A.NAME,
                          A.ID,
                          A.APPTYPE,
                          (select s.currdate from s08sysparm s),
                          A.OPERNAME,
                          A.OPERID,
                          P.H_ERROR,
                          v_note,
                          1,
                          v_status,
                          v_sort,
                          P.A_ESPECIAL,
                          P.H_RETCODE,
                          P.A_CREDIT_RMB,
                          A.ORG,
                          A.ORG,
                          currentstamp


               FROM S08S4_PROPOSER     P,
                    S08S4_APPREGISTER  A
               WHERE P.APPID=A.APPID
                 AND P.INPUTSEQ= 0
                 AND P.A_FLAG=v_a_flag
                 AND A.APPID=v_appid;
        end if ;
  ELSE
      V_STEP:=80;--更新质检表客户类型
      update S08S1_QUALITYA s set s.note = v_note where s.appid= v_appid;
      END IF;

    commit;

    end if;

    END;
    END LOOP;

   o_return :=0;
   o_msg    :='执行s08p_addInquiryCustType成功';


 EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
         O_RETURN:=-1;
         O_MSG    :='执行s08p_addInquiryCustType出错: STEP='||V_STEP||',ERROR= '||SQLCODE ||', '||SQLERRM(SQLCODE);

     END;
/



CREATE OR REPLACE PROCEDURE CISSAPS.s08p_deletein
(
  i_stamp_date IN DATE,
  o_return     OUT NUMBER,
  outparaxml   OUT VARCHAR2
)

 IS

  /*
  功能：    清理建账失败的件

  作者：        张立卫

  时间：        2008-08-11

  说明：目前只清理 s8s1_ 开头的表 不会清除s08s4_ 开头的表

  注意：调用此过程之前，主附同审，商务卡 须谨慎（原因：这两种进件类型 申请书编号相同，同一个流程实例）

  白银燕       2009-09-27       清理补件信息

  何书光       2013-08   增加对S4表的清理
  */

  errorcode VARCHAR2(20); -- 出现异常的行号

  errormsg VARCHAR2(255); -- 异常信息

  v_delflag CHAR(1); -- 删除标志

  v_step NUMBER(6);

BEGIN

  v_step := 10;

  -- 删除工作流相关表\

  v_delflag := '0';

  UPDATE s08s1_cleardata t
  SET t.entry_id = (SELECT entry_id
                    FROM s08s1_appregister a
                    WHERE a.appid = t.appid)
  WHERE t.delflag = v_delflag;

  --begin hesg version_201308 增加对S4表的清理
  UPDATE s08s1_cleardata t
  SET t.entry_id = (SELECT entry_id
                    FROM s08s4_appregister a
                    WHERE a.appid = t.appid)
  WHERE t.delflag = v_delflag;
  --end hesg

  -- query makecarding
  UPDATE /*+index(t S08S1_CLEARDATA31)*/ s08s1_cleardata t
  SET t.delflag = '3'
  WHERE t.appid IN (SELECT app_nbr FROM s08s1_createappcard) AND
        t.delflag = '0';
  --query  makecarded

  /*  update \*+index(t S08S1_CLEARDATA31)*\ s08s1_cleardata t
  set t.delflag = '4'
  where t.appid in (select app_nbr from s08s4_appcardlog) and
        t.delflag = '0';*/

  COMMIT;
  DELETE FROM s08s1_overtime t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata a WHERE a.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_overtime表的清理
  DELETE FROM s08s4_overtime t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata a WHERE a.delflag = v_delflag);

  DELETE FROM s08s1_oscurrentstep t
  WHERE t.entry_id IN
        (SELECT entry_id FROM s08s1_cleardata a WHERE a.delflag = v_delflag);

  DELETE FROM s08s1_oshistorystep t
  WHERE t.entry_id IN
        (SELECT entry_id FROM s08s1_cleardata a WHERE a.delflag = v_delflag);

  --hesg version_201308 增加对s08s4_oshistorystep表的清理
 DELETE FROM s08s4_oshistorystep t
  WHERE t.entry_id IN
        (SELECT entry_id FROM s08s1_cleardata a WHERE a.delflag = v_delflag);


  DELETE FROM s08s1_oswfentry t
  WHERE t.id IN
        (SELECT entry_id FROM s08s1_cleardata a WHERE a.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_oswfentry表的清理
 DELETE FROM s08s4_oswfentry t
  WHERE t.id IN
        (SELECT entry_id FROM s08s1_cleardata a WHERE a.delflag = v_delflag);

  DELETE FROM s08s1_ospropertyentry t
  WHERE t.global_key IN (SELECT 'osff_' || entry_id
                         FROM s08s1_cleardata a
                         WHERE a.delflag = v_delflag);

  -- 删除质检表

  DELETE FROM s08s1_qualitya t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_qualitya表的清理
  DELETE FROM s08s4_qualitya t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除开卡相关表

  DELETE FROM s08s1_createappcard t
  WHERE t.app_nbr IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_createappcard_errorlog t
  WHERE t.app_nbr IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_appcardresult t
  WHERE t.app_nbr IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_appcardresult_errorlog t
  WHERE t.app_nbr IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除审批环节相关表

  DELETE FROM s08s1_approve t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_approve表的清理
  DELETE FROM s08s4_approve t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除征信环节相关表

  DELETE FROM s08s1_inquiry t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_inquiry表的清理
  DELETE FROM s08s4_inquiry t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_inquirycall t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_inquirycall表的清理
  DELETE FROM s08s4_inquirycall t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --hesg version_201308 增加对s08s4_inquiry_proposer表的清理(没有对s1表进行清理)
  DELETE FROM s08s4_inquiry_proposer t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --cuijt version_201308 增加对s08s1_inquiry_proposer表的清理(没有对s1表进行清理)
  DELETE FROM s08s1_inquiry_proposer t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --cuijt version_201308 增加对s08s1_checkresult表的清理(没有对s1表进行清理)
  DELETE FROM s08s1_checkresult t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --cuijt version_201308 增加对s08s4_checkresult表的清理(没有对s1表进行清理)
  DELETE FROM s08s4_checkresult t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  -- 删除交叉检查结果表

  DELETE FROM s08s1_crschk_rslt t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_crschk_rslt表的清理
  DELETE FROM s08s4_crschk_rslt t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_crschk_crop_rslt t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_crschk_crop_rslt表的清理
  DELETE FROM s08s4_crschk_crop_rslt t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);


  DELETE FROM s08s1_chk_errmsg t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_chk_corp_errmsg t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  -- 删除评分表

  DELETE FROM s08s1_dss_response t
  WHERE t.application_sn IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  DELETE FROM s08s4_dss_response t
  WHERE t.application_sn IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除信息更改记录表

  DELETE FROM s08s1_appmodify t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_appmodify表的清理
  DELETE FROM s08s4_appmodify t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除备注表

  DELETE FROM s08s1_remark t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
 --hesg version_201308 增加对s08s4_remark表的清理
  DELETE FROM s08s4_remark t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除个性化信息表

  DELETE FROM s08s1_proposerappend t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
 --hesg version_201308 增加对s08s4_proposerappend表的清理
  DELETE FROM s08s4_proposerappend t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除申请人表

  DELETE FROM s08s1_proposer t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_proposer表的清理
  DELETE FROM s08s4_proposer t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除进件表

  DELETE FROM s08s1_appregister t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_appregister表的清理
  DELETE FROM s08s4_appregister t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  DELETE FROM s08s1_publiccorpinfo t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对s08s4_publiccorpinfo表的清理
  DELETE FROM s08s4_publiccorpinfo t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除批量相关表

  DELETE FROM s08s1_errorinfo t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  -- 删除影像表

  DELETE FROM s08statinform t
  WHERE t.application IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --hesg version_201308 增加对S08S4_STATINFORM表的清理
  DELETE FROM S08S4_STATINFORM t
  WHERE t.application IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --hesg version_201308 增加对s08s4_image_scan表的清理(没有对s1表进行清理)
  DELETE FROM s08s4_image_scan t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --cuijt version_201308 增加对s08s1_image_scan表的清理(没有对s1表进行清理)
  DELETE FROM s08s1_image_scan t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

 --hesg version_201308 增加对s08s4_scanindex表的清理(没有对s1表进行清理)
  DELETE FROM s08s4_scanindex t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
 --cuijt version_201308 增加对s08s1_scanindex表的清理(没有对s1表进行清理)
  DELETE FROM s08s1_scanindex t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --hesg version_201308 增加对s08s4_self_loan表的清理(没有对s1表进行清理)
  DELETE FROM s08s4_self_loan t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);
  --cuijt version_201308 增加对s08s1_self_loan表的清理(没有对s1表进行清理)
  DELETE FROM s08s1_self_loan t
  WHERE t.appid IN
        (SELECT appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);

  --libo version_201310 增加对s08s1_task表评分任务的清理
  DELETE FROM s08s1_task t
  WHERE t.taskname IN
        (SELECT 'TASKTYPE_PF_'||appid FROM s08s1_cleardata t WHERE t.delflag = v_delflag);


  -- 删除补件信息
  DECLARE
    --select appid INTO V_APPID from s08s1_cleardata where delflag=0;
    CURSOR cur_appid IS
      SELECT appid FROM s08s1_cleardata WHERE delflag = 0;

    v_appid s08s1_cleardata.appid%TYPE;

  BEGIN
    OPEN cur_appid;

    LOOP
      v_step := 20;
      FETCH cur_appid
        INTO v_appid;

      EXIT WHEN cur_appid%NOTFOUND OR cur_appid%NOTFOUND IS NULL;

      DECLARE
        --select appid INTO DV_APPI_1 from s08s1_appregister;
        CURSOR cur_appid_1 IS
          SELECT appid
          FROM s08s1_appregister
          WHERE length(appid) > 13 AND
                appid LIKE v_appid || '%';
        v_appid_1 s08s1_appregister.appid%TYPE;

      BEGIN
        OPEN cur_appid_1;
        LOOP
          v_step := 30;
          FETCH cur_appid_1
            INTO v_appid_1;

          EXIT WHEN cur_appid_1%NOTFOUND OR cur_appid_1%NOTFOUND IS NULL;
          -- 删除工作流相关表(补件)

          DELETE FROM s08s1_oscurrentstep t
          WHERE t.entry_id IN (SELECT entry_id
                               FROM s08s1_appregister a
                               WHERE a.appid = v_appid_1);

          DELETE FROM s08s1_oshistorystep t
          WHERE t.entry_id IN (SELECT entry_id
                               FROM s08s1_appregister a
                               WHERE a.appid = v_appid_1);

          DELETE FROM s08s1_oswfentry t
          WHERE t.id IN (SELECT entry_id
                         FROM s08s1_appregister a
                         WHERE a.appid = v_appid_1);

          DELETE FROM s08s1_ospropertyentry t
          WHERE t.global_key IN (SELECT 'osff_' || entry_id
                                 FROM s08s1_appregister a
                                 WHERE a.appid = v_appid_1);

          -- 删除进件表(补件)

          DELETE FROM s08s1_appregister t WHERE t.appid = v_appid_1;

          -- 删除影像表(补件)

          DELETE FROM s08statinform t WHERE t.application = v_appid_1;

        END LOOP;
        CLOSE cur_appid_1;
        COMMIT;
      END;

    END LOOP;

    CLOSE cur_appid;

    COMMIT;
  END;

  --begin hesg version_201308 增加对s4表补件信息进行清理
  DECLARE
    CURSOR cur_s4_appid IS
      SELECT appid FROM s08s1_cleardata WHERE delflag = 0;

    v_s4_appid s08s1_cleardata.appid%TYPE;

  BEGIN
    OPEN cur_s4_appid;

    LOOP
      v_step := 20;
      FETCH cur_s4_appid
        INTO v_s4_appid;

      EXIT WHEN cur_s4_appid%NOTFOUND OR cur_s4_appid%NOTFOUND IS NULL;

      DECLARE
        CURSOR cur_s4_appid_1 IS
          SELECT appid
          FROM s08s4_appregister
          WHERE length(appid) > 13 AND
                appid LIKE v_s4_appid || '%';
        v_s4_appid_1 s08s4_appregister.appid%TYPE;

      BEGIN
        OPEN cur_s4_appid_1;
        LOOP
          v_step := 30;
          FETCH cur_s4_appid_1
            INTO v_s4_appid_1;

          EXIT WHEN cur_s4_appid_1%NOTFOUND OR cur_s4_appid_1%NOTFOUND IS NULL;
          -- 删除工作流相关表(补件)

          DELETE FROM s08s4_oshistorystep t
          WHERE t.entry_id IN (SELECT entry_id
                               FROM s08s4_appregister a
                               WHERE a.appid = v_s4_appid_1);

          DELETE FROM s08s4_oswfentry t
          WHERE t.id IN (SELECT entry_id
                         FROM s08s4_appregister a
                         WHERE a.appid = v_s4_appid_1);

          -- 删除进件表(补件)

          DELETE FROM s08s4_appregister t WHERE t.appid = v_s4_appid_1;

          -- 删除影像表(补件)

          DELETE FROM S08S4_STATINFORM t WHERE t.application = v_s4_appid_1;

        END LOOP;
        CLOSE cur_s4_appid_1;
        COMMIT;
      END;

    END LOOP;

    CLOSE cur_s4_appid;

    COMMIT;
  END;
  --end hesg
  -- 更新记录表

  UPDATE s08s1_cleardata t SET delflag = '1' WHERE t.delflag = v_delflag;

  COMMIT;

  outparaxml := '数据清理成功';

  o_return := 0;

EXCEPTION

  WHEN OTHERS THEN

    errorcode := SQLCODE;

    errormsg := SQLERRM;

    outparaxml := '<?xml version="1.0" encoding="UTF-8"?><RESPONSE><RESULT><CODE>999999</CODE><RTNMSG>';

    outparaxml := outparaxml || 'Step = ' || v_step || ', ERRCODE=''' ||
                  errorcode || ''',ERRMSG=''' || errormsg;

    outparaxml := outparaxml || '</RTNMSG></RESULT>';

    outparaxml := outparaxml || '</RESPONSE>';

    o_return := -1;

END s08p_deletein;
/



CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_CLEAR_REFUES_DATA_01(V_BIZDATE DATE,
                                                     O_RETURN  OUT NUMBER,
                                                     O_MSG     OUT VARCHAR2) IS
  V_STEP NUMBER(6);
BEGIN
  O_RETURN := -1;

  V_STEP := 1;
  DELETE FROM S08S4_OSWFENTRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01)  B WHERE B.ENTRY_ID = A.ID);
  COMMIT;

  V_STEP := 2;
  DELETE FROM S08S4_OSHISTORYSTEP A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B
           WHERE B.ENTRY_ID = A.ENTRY_ID);
  COMMIT;

  V_STEP := 3;
  DELETE FROM S08S4_APPREGISTER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 4;
  DELETE FROM S08S4_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 5;
  DELETE FROM S08S4_PUBLICCORPINFO A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 6;
  DELETE FROM S08S4_CRSCHK_CROP_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 7;
  DELETE FROM S08S4_CRSCHK_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 8;
  DELETE FROM S08S4_INQUIRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 9;
  DELETE FROM S08S4_INQUIRYCALL A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 10;
  DELETE FROM S08S4_DSS_RESPONSE A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B
           WHERE A.Application_Sn = B.APPID);
  COMMIT;

  V_STEP := 11;
  DELETE FROM S08S4_APPROVE A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 12;
  DELETE FROM S08S4_REMARK A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 13;
  DELETE FROM S08S4_APPMODIFY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 14;
  DELETE FROM S08S4_CHECKRESULT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 15;
  DELETE FROM S08S4_OVERTIME A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 16;
  DELETE FROM S08S4_PROPOSERAPPEND A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 17;
  DELETE FROM S08S4_QUALITYA A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 18;
  DELETE FROM S08STATINFORM A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B
           WHERE A.APPLICATION = B.APPID);
  COMMIT;

  V_STEP := 19;
  DELETE FROM S08S4_SCANINDEX A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 20;
  DELETE FROM S08S4_SELF_LOAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

 /* V_STEP := 21;
  DELETE FROM S08S4_APPBATCH A
   WHERE EXISTS
   (SELECT 1 FROM S08T4_CLEAR_REFUSE_BATCH B WHERE A.BATCHID = B.BATCHID);
  COMMIT;*/

  V_STEP := 22;
  DELETE FROM S08S4_MEMBER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 23;
  DELETE FROM S08S4_INQUIRY_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 24;
  DELETE FROM S08S4_IMAGE_SCAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_01) B WHERE A.APPID = B.APPID);
  COMMIT;

  O_RETURN := 0;
  O_MSG    := '执行 S08P1_CLEAR_REFUES_DATA_01 成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_MSG := '执行 S08P1_CLEAR_REFUES_DATA_01 出错：STEP = ' || V_STEP ||
             ', ERROR= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P1_CLEAR_REFUES_DATA_01;
/




CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_CLEAR_REFUES_DATA_02(V_BIZDATE DATE,
                                                     O_RETURN  OUT NUMBER,
                                                     O_MSG     OUT VARCHAR2) IS
  V_STEP NUMBER(6);
BEGIN
  O_RETURN := -1;

  V_STEP := 1;
  DELETE FROM S08S4_OSWFENTRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02)  B WHERE B.ENTRY_ID = A.ID);
  COMMIT;

  V_STEP := 2;
  DELETE FROM S08S4_OSHISTORYSTEP A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B
           WHERE B.ENTRY_ID = A.ENTRY_ID);
  COMMIT;

  V_STEP := 3;
  DELETE FROM S08S4_APPREGISTER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 4;
  DELETE FROM S08S4_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 5;
  DELETE FROM S08S4_PUBLICCORPINFO A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 6;
  DELETE FROM S08S4_CRSCHK_CROP_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 7;
  DELETE FROM S08S4_CRSCHK_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 8;
  DELETE FROM S08S4_INQUIRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 9;
  DELETE FROM S08S4_INQUIRYCALL A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 10;
  DELETE FROM S08S4_DSS_RESPONSE A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B
           WHERE A.Application_Sn = B.APPID);
  COMMIT;

  V_STEP := 11;
  DELETE FROM S08S4_APPROVE A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 12;
  DELETE FROM S08S4_REMARK A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 13;
  DELETE FROM S08S4_APPMODIFY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 14;
  DELETE FROM S08S4_CHECKRESULT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 15;
  DELETE FROM S08S4_OVERTIME A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 16;
  DELETE FROM S08S4_PROPOSERAPPEND A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 17;
  DELETE FROM S08S4_QUALITYA A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 18;
  DELETE FROM S08STATINFORM A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B
           WHERE A.APPLICATION = B.APPID);
  COMMIT;

  V_STEP := 19;
  DELETE FROM S08S4_SCANINDEX A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 20;
  DELETE FROM S08S4_SELF_LOAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

 /* V_STEP := 21;
  DELETE FROM S08S4_APPBATCH A
   WHERE EXISTS
   (SELECT 1 FROM S08T4_CLEAR_REFUSE_BATCH B WHERE A.BATCHID = B.BATCHID);
  COMMIT;*/

  V_STEP := 22;
  DELETE FROM S08S4_MEMBER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 23;
  DELETE FROM S08S4_INQUIRY_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 24;
  DELETE FROM S08S4_IMAGE_SCAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_02) B WHERE A.APPID = B.APPID);
  COMMIT;

  O_RETURN := 0;
  O_MSG    := '执行 S08P1_CLEAR_REFUES_DATA_02 成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_MSG := '执行 S08P1_CLEAR_REFUES_DATA_02 出错：STEP = ' || V_STEP ||
             ', ERROR= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P1_CLEAR_REFUES_DATA_02;
/




CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_CLEAR_REFUES_DATA_03(V_BIZDATE DATE,
                                                     O_RETURN  OUT NUMBER,
                                                     O_MSG     OUT VARCHAR2) IS
  V_STEP NUMBER(6);
BEGIN
  O_RETURN := -1;

  V_STEP := 1;
  DELETE FROM S08S4_OSWFENTRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03)  B WHERE B.ENTRY_ID = A.ID);
  COMMIT;

  V_STEP := 2;
  DELETE FROM S08S4_OSHISTORYSTEP A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B
           WHERE B.ENTRY_ID = A.ENTRY_ID);
  COMMIT;

  V_STEP := 3;
  DELETE FROM S08S4_APPREGISTER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 4;
  DELETE FROM S08S4_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 5;
  DELETE FROM S08S4_PUBLICCORPINFO A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 6;
  DELETE FROM S08S4_CRSCHK_CROP_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 7;
  DELETE FROM S08S4_CRSCHK_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 8;
  DELETE FROM S08S4_INQUIRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 9;
  DELETE FROM S08S4_INQUIRYCALL A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 10;
  DELETE FROM S08S4_DSS_RESPONSE A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B
           WHERE A.Application_Sn = B.APPID);
  COMMIT;

  V_STEP := 11;
  DELETE FROM S08S4_APPROVE A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 12;
  DELETE FROM S08S4_REMARK A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 13;
  DELETE FROM S08S4_APPMODIFY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 14;
  DELETE FROM S08S4_CHECKRESULT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 15;
  DELETE FROM S08S4_OVERTIME A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 16;
  DELETE FROM S08S4_PROPOSERAPPEND A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 17;
  DELETE FROM S08S4_QUALITYA A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 18;
  DELETE FROM S08STATINFORM A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B
           WHERE A.APPLICATION = B.APPID);
  COMMIT;

  V_STEP := 19;
  DELETE FROM S08S4_SCANINDEX A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 20;
  DELETE FROM S08S4_SELF_LOAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

 /* V_STEP := 21;
  DELETE FROM S08S4_APPBATCH A
   WHERE EXISTS
   (SELECT 1 FROM S08T4_CLEAR_REFUSE_BATCH B WHERE A.BATCHID = B.BATCHID);
  COMMIT;*/

  V_STEP := 22;
  DELETE FROM S08S4_MEMBER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 23;
  DELETE FROM S08S4_INQUIRY_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 24;
  DELETE FROM S08S4_IMAGE_SCAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_03) B WHERE A.APPID = B.APPID);
  COMMIT;

  O_RETURN := 0;
  O_MSG    := '执行 S08P1_CLEAR_REFUES_DATA_03 成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_MSG := '执行 S08P1_CLEAR_REFUES_DATA_03 出错：STEP = ' || V_STEP ||
             ', ERROR= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P1_CLEAR_REFUES_DATA_03;
/




CREATE OR REPLACE PROCEDURE CISSAPS.S08P1_CLEAR_REFUES_DATA_04(V_BIZDATE DATE,
                                                     O_RETURN  OUT NUMBER,
                                                     O_MSG     OUT VARCHAR2) IS
  V_STEP NUMBER(6);
BEGIN
  O_RETURN := -1;

  V_STEP := 1;
  DELETE FROM S08S4_OSWFENTRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04)  B WHERE B.ENTRY_ID = A.ID);
  COMMIT;

  V_STEP := 2;
  DELETE FROM S08S4_OSHISTORYSTEP A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B
           WHERE B.ENTRY_ID = A.ENTRY_ID);
  COMMIT;

  V_STEP := 3;
  DELETE FROM S08S4_APPREGISTER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 4;
  DELETE FROM S08S4_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 5;
  DELETE FROM S08S4_PUBLICCORPINFO A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 6;
  DELETE FROM S08S4_CRSCHK_CROP_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 7;
  DELETE FROM S08S4_CRSCHK_RSLT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 8;
  DELETE FROM S08S4_INQUIRY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 9;
  DELETE FROM S08S4_INQUIRYCALL A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 10;
  DELETE FROM S08S4_DSS_RESPONSE A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B
           WHERE A.Application_Sn = B.APPID);
  COMMIT;

  V_STEP := 11;
  DELETE FROM S08S4_APPROVE A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 12;
  DELETE FROM S08S4_REMARK A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 13;
  DELETE FROM S08S4_APPMODIFY A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 14;
  DELETE FROM S08S4_CHECKRESULT A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 15;
  DELETE FROM S08S4_OVERTIME A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 16;
  DELETE FROM S08S4_PROPOSERAPPEND A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 17;
  DELETE FROM S08S4_QUALITYA A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 18;
  DELETE FROM S08STATINFORM A
   WHERE EXISTS (SELECT 1
            FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B
           WHERE A.APPLICATION = B.APPID);
  COMMIT;

  V_STEP := 19;
  DELETE FROM S08S4_SCANINDEX A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 20;
  DELETE FROM S08S4_SELF_LOAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;
/*
  V_STEP := 21;
  DELETE FROM S08S4_APPBATCH A
   WHERE EXISTS
   (SELECT 1 FROM S08T4_CLEAR_REFUSE_BATCH B WHERE A.BATCHID = B.BATCHID);
  COMMIT;*/

  V_STEP := 22;
  DELETE FROM S08S4_MEMBER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 23;
  DELETE FROM S08S4_INQUIRY_PROPOSER A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  V_STEP := 24;
  DELETE FROM S08S4_IMAGE_SCAN A
   WHERE EXISTS
   (SELECT 1 FROM S08S4_CLEAR_REFUSE_ZCB PARTITION(P_CLEAR_04) B WHERE A.APPID = B.APPID);
  COMMIT;

  O_RETURN := 0;
  O_MSG    := '执行 S08P1_CLEAR_REFUES_DATA_04 成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_MSG := '执行 S08P1_CLEAR_REFUES_DATA_04 出错：STEP = ' || V_STEP ||
             ', ERROR= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P1_CLEAR_REFUES_DATA_04;
/




CREATE OR REPLACE PROCEDURE CISSAPS.S08P_CLEAR_REFUSE_PRE(V_BIZDATE IN DATE,
                                                  O_RETURN  OUT NUMBER,
                                                  O_MSG     OUT VARCHAR2) IS
  V_STEP NUMBER(6);

BEGIN
  --向临时表 S08S4_DELETE_REFUSE_ZCB 插入数据
  EXECUTE IMMEDIATE 'truncate table S08S4_CLEAR_REFUSE_ZCB';

  V_STEP := 1;
  --插入需要迁移的数据 HESG VERSION_201406 MODIFY 关联申请人表
  INSERT INTO S08S4_CLEAR_REFUSE_ZCB
    SELECT A.APPID, A.ENTRY_ID
      FROM S08S4_APPREGISTER A,S08S1_REFUSEAPP B,S08s4_Proposer p
     WHERE A.APPID = B.APPID
       AND A.APPID=P.APPID
       AND B.INPUTSEQ = 0
       AND P.INPUTSEQ = 0
       AND A.ID=B.ID
       AND P.STAMP=B.STAMP
       AND V_BIZDATE - B.STAMP = 181;
  COMMIT;

    V_STEP := 2;
  --插入需要迁移的数据 HESG VERSION_201406 MODIFY 关联共件信息表
  INSERT INTO S08S4_CLEAR_REFUSE_ZCB
    SELECT A.APPID, A.ENTRY_ID
      FROM S08S4_APPREGISTER A,S08S1_REFUSEAPP B,s08s4_publiccorpinfo p
     WHERE A.APPID = B.APPID
       AND A.APPID=P.APPID
       AND B.INPUTSEQ = 0
       AND P.STAMP=B.STAMP
       AND V_BIZDATE - B.STAMP = 181;
  COMMIT;
  O_RETURN := 0;
  O_MSG    := '执行S08P_CLEAR_REFUSE_PRE成功';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    O_RETURN := -1;
    O_MSG    := '执行 S08P_CLEAR_REFUSE_PRE 出错：STEP = ' || V_STEP ||
                ', ERROR= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);
END S08P_CLEAR_REFUSE_PRE;
/




CREATE OR REPLACE PROCEDURE CISSHIS.s09p2_08_apinfo_clear
(
  i_DATE   IN DATE,
  i_RETURN OUT NUMBER,
  i_MSG    OUT VARCHAR2
) IS
  /*
  功能名称：每周定期清理表空间
  执行周期：每五


  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号           说明
  --------------------------------------------------------------------
   檀仲伟    2010-03-08      1         初始版本
  */

  v_step number(1);
  v_date varchar2(20);
  --p       varchar2(100);
BEGIN
  v_step := 1;

  if (to_char(i_DATE, 'D') = 6 AND to_char(i_DATE, 'D') = 2)
  then
    v_date := to_char(i_date - 5, 'yyyy-mm-dd');

    --转数据到临时表中
    insert into s09t2_08_apinfo_10
      select *
      from s09s2_08_apinfo
      WHERE RECORD_DATE >= to_date(v_date, 'yyyy-mm-dd');
    commit;
    --删除表中的数据
    v_step := 2;
    EXECUTE IMMEDIATE 'truncate table s09s2_08_apinfo';

    --将临时表中的数据转到原表中
    v_step := 3;
    insert into s09s2_08_apinfo
      select * from s09t2_08_apinfo_10;
    commit;

    --删除临时表数据
    v_step := 4;
    EXECUTE IMMEDIATE 'truncate table s09t2_08_apinfo_10';

    i_RETURN := 0;
    i_MSG    := to_char(i_DATE, 'yyyy-mm-dd') ||
                '成功清理s09s2_08_apinfo数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    i_RETURN := -1;
    i_MSG    := 'Step =' || v_step || ',OraError =' || SQLCODE || ',' ||
                SQLERRM(SQLCODE);

END s09p2_08_apinfo_clear;
/




CREATE OR REPLACE PROCEDURE CISSHIS.s09p2_08_apprinfo_clear
(
  i_DATE   IN DATE,
  i_RETURN OUT NUMBER,
  i_MSG    OUT VARCHAR2
) IS
  /*
  功能名称：每周定期清理表空间
  执行周期：每五


  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号           说明
  --------------------------------------------------------------------
   檀仲伟    2010-03-08      1         初始版本
  */

  v_step number(1);
  v_date varchar2(20);
  --p       varchar2(100);
BEGIN
  v_step := 1;

  if (to_char(i_DATE, 'D') = 6 AND to_char(i_DATE, 'D') = 2)
  then
    v_date := to_char(i_date - 5, 'yyyy-mm-dd');

    --转数据到临时表中
    insert into s09t2_08_apprinfo_10
      select *
      from s09s2_08_apprinfo
      WHERE RECORD_DATE >= to_date(v_date, 'yyyy-mm-dd');
    commit;
    --删除表中的数据
    v_step := 2;
    EXECUTE IMMEDIATE 'truncate table s09s2_08_apprinfo';

    --将临时表中的数据转到原表中
    v_step := 3;
    insert into s09s2_08_apprinfo
      select * from s09t2_08_apprinfo_10;
    commit;

    --删除临时表数据
    v_step := 4;
    EXECUTE IMMEDIATE 'truncate table s09t2_08_apprinfo_10';

    i_RETURN := 0;
    i_MSG    := to_char(i_DATE, 'yyyy-mm-dd') ||
                '成功清理s09s2_08_apprinfo数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    i_RETURN := -1;
    i_MSG    := 'Step =' || v_step || ',OraError =' || SQLCODE || ',' ||
                SQLERRM(SQLCODE);

END s09p2_08_apprinfo_clear;
/




CREATE OR REPLACE PROCEDURE CISSHIS.s09p2_08_refuse_clear
(
  i_DATE   IN DATE,
  i_RETURN OUT NUMBER,
  i_MSG    OUT VARCHAR2
) IS
  /*
  功能名称：每周定期清理表空间
  执行周期：每五


  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号           说明
  --------------------------------------------------------------------
   檀仲伟    2010-03-08      1         初始版本
  */

  v_step number(1);
  v_date varchar2(20);
  --p       varchar2(100);
BEGIN
  v_step := 1;

  if (to_char(i_DATE, 'D') = 6 AND to_char(i_DATE, 'D') = 2)
  then
    v_date := to_char(i_date - 5, 'yyyy-mm-dd');

    --转数据到临时表中
    insert into s09t2_08_refuse_10
      select *
      from s09s2_08_refuse
      WHERE RECORD_DATE >= to_date(v_date, 'yyyy-mm-dd');
    commit;
    --删除表中的数据
    v_step := 2;
    EXECUTE IMMEDIATE 'truncate table s09s2_08_refuse';

    --将临时表中的数据转到原表中
    v_step := 3;
    insert into s09s2_08_refuse
      select * from s09t2_08_refuse_10;
    commit;

    --删除临时表数据
    v_step := 4;
    EXECUTE IMMEDIATE 'truncate table s09t2_08_refuse_10';

    i_RETURN := 0;
    i_MSG    := to_char(i_DATE, 'yyyy-mm-dd') ||
                '成功清理s09s2_08_refuse数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    i_RETURN := -1;
    i_MSG    := 'Step =' || v_step || ',OraError =' || SQLCODE || ',' ||
                SQLERRM(SQLCODE);

END s09p2_08_refuse_clear;
/




CREATE OR REPLACE PROCEDURE CISSHIS.s09p2_08_svyinfo_clear
(
  i_DATE   IN DATE,
  i_RETURN OUT NUMBER,
  i_MSG    OUT VARCHAR2
) IS
  /*
  功能名称：每周定期清理表空间
  执行周期：每五


  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号           说明
  --------------------------------------------------------------------
   檀仲伟    2010-03-08      1         初始版本
  */

  v_step number(1);
  v_date varchar2(20);
  --p       varchar2(100);
BEGIN
  v_step := 1;

  if (to_char(i_DATE, 'D') = 6 AND to_char(i_DATE, 'D') = 2)
  then
    v_date := to_char(i_date - 5, 'yyyy-mm-dd');

    --转数据到临时表中
    insert into s09t2_08_svyinfo_10
      select *
      from s09s2_08_svyinfo
      WHERE RECORD_DATE >= to_date(v_date, 'yyyy-mm-dd');
    commit;
    --删除表中的数据
    v_step := 2;
    EXECUTE IMMEDIATE 'truncate table s09s2_08_svyinfo';

    --将临时表中的数据转到原表中
    v_step := 3;
    insert into s09s2_08_svyinfo
      select * from s09t2_08_svyinfo_10;
    commit;

    --删除临时表数据
    v_step := 4;
    EXECUTE IMMEDIATE 'truncate table s09t2_08_svyinfo_10';

    i_RETURN := 0;
    i_MSG    := to_char(i_DATE, 'yyyy-mm-dd') ||
                '成功清理s09s2_08_svyinfo数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    i_RETURN := -1;
    i_MSG    := 'Step =' || v_step || ',OraError =' || SQLCODE || ',' ||
                SQLERRM(SQLCODE);

END s09p2_08_svyinfo_clear;
/





CREATE OR REPLACE PROCEDURE CISSHIS.s09p2_08_workflowinfo_clear
(
  i_DATE   IN DATE,
  i_RETURN OUT NUMBER,
  i_MSG    OUT VARCHAR2
) IS
  /*
  功能名称：每周定期清理表空间
  执行周期：每五


  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号           说明
  --------------------------------------------------------------------
   檀仲伟    2010-03-08      1         初始版本
  */

  v_step number(1);
  v_date varchar2(20);
  --p       varchar2(100);
BEGIN
  v_step := 1;

  if (to_char(i_DATE, 'D') = 6 AND to_char(i_DATE, 'D') = 2)
  then
    v_date := to_char(i_date - 5, 'yyyy-mm-dd');

    --转数据到临时表中
    insert into s09t2_08_workflowinfo_10
      select *
      from s09s2_08_workflowinfo
      WHERE RECORD_DATE >= to_date(v_date, 'yyyy-mm-dd');
    commit;
    --删除表中的数据
    v_step := 2;
    EXECUTE IMMEDIATE 'truncate table s09s2_08_workflowinfo';

    --将临时表中的数据转到原表中
    v_step := 3;
    insert into s09s2_08_workflowinfo
      select * from s09t2_08_workflowinfo_10;
    commit;

    --删除临时表数据
    v_step := 4;
    EXECUTE IMMEDIATE 'truncate table s09t2_08_workflowinfo_10';

    i_RETURN := 0;
    i_MSG    := to_char(i_DATE, 'yyyy-mm-dd') ||
                '成功清理s09s2_08_workflowinfo数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    i_RETURN := -1;
    i_MSG    := 'Step =' || v_step || ',OraError =' || SQLCODE || ',' ||
                SQLERRM(SQLCODE);

END s09p2_08_workflowinfo_clear;
/
