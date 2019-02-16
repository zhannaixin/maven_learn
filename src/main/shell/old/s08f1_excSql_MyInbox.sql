CREATE OR REPLACE function CISSAPS.s08f1_excSql_MyInbox(i_Sql    varchar2,
                                                i_stepId number,
                                                i_operId varchar,
                                                i_table  varchar
                                                ) return varchar2 as
   /*
  功能名称：    收件箱收件函数
  用途：        我的收件箱收件
  执行周期：    无
  作者：        hesg
  时间：        2012-11-06

  数据来源：     S08S1_SURVEY_GEN,S08S1_SURVEY_PRI
                 S08S1_APPROVE_GEN,S08S1_APPROVE_PRI
  目标表：       S08S1_OSCURRENTSTEP

  参数列表：
  --------------------------------------------------------------------
   参数         IN/OUT     类型            说明
  --------------------------------------------------------------------
   i_Sql       IN        VARCHAR2        查询sql
   i_stepId    IN        NUMBER          环节编号
   i_operId    IN        VARCHAR2        操作员编号
   i_table     IN        VARCHAR2        排序表名
   O_MSG       OUT       VARCHAR2        返回的信息

  版本历史：
  --------------------------------------------------------------------
   作者             日期           版本号               说明
  --------------------------------------------------------------------
   何书光         2012-11-06       1.0                  初始版本
  */
  v_sql       varchar2(2000) := i_sql;
  v_update    varchar2(200);
  v_entryId   number;
  v_status    varchar2(50);
  v_stepid    number;
  v_operid    varchar2(11) := i_operId;
  v_num       number := 0;
  o_msg       varchar(1000);
  o_error     varchar(7) := '999999@';
  o_success   varchar(7) := '666666@';
  o_nodata    varchar2(1000);
  o_flag   boolean;
  v_n number;
  v_m number:=0;
  cur_entryId sys_refcursor;
begin
  OPEN cur_entryId for v_sql;
  LOOP
    FETCH cur_entryId
      INTO v_entryId;
    EXIT WHEN cur_entryId%NOTFOUND;

    o_flag:=true;
    /*BEGIN*/
    SELECT count(1) into v_n
        FROM s08s1_oscurrentstep o
       where o.entry_id = v_entryId;

        if v_n=0 then

          if v_m=0 then
            o_nodata:=v_entryId;
           else
             o_nodata:=o_nodata||','||v_entryId;
          end if;

          v_m:=v_m+1;
          o_flag:=false;
          --将标识修改为2，异常状态，表示申请件工作流已结束
           v_update := 'update ' || i_table || ' set flag=2 where entry_id=' ||
                  v_entryId;
           EXECUTE IMMEDIATE v_update;
           commit;
        else
          SELECT o.step_id, o.status
            into v_stepid, v_status
            FROM s08s1_oscurrentstep o
           where o.entry_id = v_entryId;
        end if;
 /*   EXCEPTION
      WHEN NO_DATA_FOUND THEN*/
      /*  o_msg := o_error || '未找到实例编号为' || v_entryId || '的申请件';
        return o_msg;*/

   /* END;*/
    if o_flag=true then
    BEGIN
      if i_stepId = V_STEPID and v_status = 'assigning' then
        if (i_stepId = 18) then
          O_msg := S08F1_OS_DOACTION(v_entryId,
                                     'assigned',
                                     'surveying',
                                     18,
                                     188,
                                     v_operid,
                                     v_operid);
        end if;
        if (i_stepId = 20) then
          O_msg := S08F1_OS_DOACTION(v_entryId,
                                     'assigned',
                                     'approving',
                                     20,
                                     208,
                                     v_operid,
                                     v_operid);
        end if;

        v_num := v_num + 1;
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        o_msg := o_error || '实例编号为' || v_entryId || '的申请件工作流流转失败';
        return o_msg;
    END;
    --更新收件准备表状态
    BEGIN
      v_update := 'update ' || i_table || ' set flag=1 where entry_id=' ||
                  v_entryId;
      EXECUTE IMMEDIATE v_update;
      commit;
    EXCEPTION
      WHEN OTHERS THEN
        o_msg := o_error || '实例编号为' || v_entryId || '的申请件收件标志修改失败';
        return o_msg;
    END;
   end if;
  END LOOP;
  CLOSE cur_entryId;
  o_msg := o_success || v_num ||'&'||o_nodata;
  return o_msg;
EXCEPTION
  WHEN OTHERS THEN
    o_msg := o_error || '收件函数游标部分失败';
    return o_msg;
end;
/
