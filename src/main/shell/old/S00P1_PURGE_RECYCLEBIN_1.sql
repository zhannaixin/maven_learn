CREATE OR REPLACE PROCEDURE S00P1_PURGE_RECYCLEBIN_1 (v_date     IN     DATE,
                                                 v_id       IN     CHAR,
                                                 v_parm     IN     VARCHAR2,
                                                 v_return      OUT NUMBER,
                                                 v_msg         OUT VARCHAR2)
IS
   v_step      NUMBER (10);
   v_stmt1     VARCHAR2 (256);

BEGIN
   v_return := -1;

   v_step :=10;

   EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';

   v_return :=0;
   v_msg := 'S00P1_PURGE_RECYLEBIN 执行成功!'||v_parm;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      v_return := -1;
      v_msg :=
            'Step ='
         || v_step
         || ', OraError = '
         || SQLCODE
         || SQLERRM (SQLCODE)
         || 'PARM: '
         || v_parm;
END;
