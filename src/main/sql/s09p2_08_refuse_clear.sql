CREATE OR REPLACE PROCEDURE s09p2_08_refuse_clear
(
		v_date     IN     DATE,
		v_id       IN     CHAR,
		v_parm     IN     VARCHAR2,
		v_return   OUT    NUMBER,
		v_msg      OUT    VARCHAR2
)IS
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
BEGIN
  

  if (to_char(v_date, 'D') = 6 OR to_char(v_date, 'D') = 2)
  then
    
	v_step := 1;--转数据到临时表中
    insert into s09t2_08_refuse_10
      select *
      from s09s2_08_refuse
      WHERE RECORD_DATE >= v_date-5;
    commit;
    
    v_step := 2;--删除表中的数据
    EXECUTE IMMEDIATE 'truncate table s09s2_08_refuse';

    v_step := 3;--将临时表中的数据转到原表中
    insert into s09s2_08_refuse
      select * from s09t2_08_refuse_10;
    commit;

    v_step := 4;--删除临时表数据
    EXECUTE IMMEDIATE 'truncate table s09t2_08_refuse_10';

    v_RETURN := 0;
    v_MSG    := to_char(v_date, 'yyyy-mm-dd') || '成功清理s09s2_08_refuse数据！';

  end if;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    v_return := -1;
    v_msg    := 'Step =' || v_step || ',OraError =' 
    			|| SQLCODE || ',' || SQLERRM(SQLCODE);

END s09p2_08_refuse_clear;
/