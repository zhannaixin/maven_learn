CREATE OR REPLACE PROCEDURE CISSOTHER.cissdb3_gather_s03(P_DATE   IN DATE,
                                             V_RETURN OUT NUMBER,
                                             V_MSG    OUT VARCHAR2) IS
  /*
  功能名称：对常用大表信息进行定期收集，提高系统性能
  执行周期：每日
  作者：舒展
  时间：2007-09-25

  参数列表：
  --------------------------------------------------------------------
    参数         IN/OUT     类型            说明
  --------------------------------------------------------------------
    P_DATE       IN         DATE            数据日期

  返回值：无

  版本历史：
  --------------------------------------------------------------------
    作者      日期        版本号      说明
  --------------------------------------------------------------------
    舒展    2007-09-25  1.0         初始版本
  */

BEGIN
  V_RETURN := -1;
  dbms_stats.gather_table_stats('cissother',
                                's03custinf',
                                estimate_percent => 10,
                                method_opt => 'for all indexed columns',
                                degree => 4,
                                granularity => 'all',
                                cascade => true);
  dbms_stats.gather_table_stats('cissother',
                                's03stmthead',
                                estimate_percent => 10,
                                method_opt => 'for all indexed columns',
                                degree => 4,
                                granularity => 'all',
                                cascade => true);
  dbms_stats.gather_table_stats('cissother',
                                's03stmtdetail',
                                estimate_percent => 10,
                                method_opt => 'for all indexed columns',
                                degree => 4,
                                granularity => 'all',
                                cascade => true);


  v_return := 0;
  V_RETURN := 0;
  V_MSG    := '帐单表信息收集成功！';
END cissdb3_gather_s03;
/
