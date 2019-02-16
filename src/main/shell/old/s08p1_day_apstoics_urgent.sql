CREATE OR REPLACE PROCEDURE CISSAPS.s08p1_day_apstoics_urgent(

                                                      i_appid in VARCHAR2

                                                      ) is
  PRAGMA autonomous_transaction;

  /*

  功能名称：    准实时批量制卡数据准备

  用途：        准实时准备制卡数据

  作者：        孙绪龙

  时间：        2011-01-17

  数据来源：    s08s1_proposer、s08s1_appregister。s08s1_publiccorpinfo

  调用函数：    s08f_get_corpinf()、s08f_get_custinf()、s08f_get_pcardinf、

                S08F_CONVERT_ADDR、S08F_CONVERT_ADDR_ITEM、S08F1_APSTOICS_NOTNULL

  临时表：

  目标表：      s08s1_createappcard_urgent,s08s1_createappcard_errorlog



  参数列表：

  --------------------------------------------------------------------

    参数               IN/OUT     类型            说明

  --------------------------------------------------------------------



  版本历史：

  --------------------------------------------------------------------

    作者             日期           版本号        说明

  --------------------------------------------------------------------

    孙绪龙          2011-01-17       1.0           初始版本、

    孙绪龙          2011-02-25       1.1           添加对于检查失败申请件自动流转到质检队列

    孙绪龙          2010-03-23       1.2           根据输入卡号确定字段卡号标识，‘1’为字段卡号，‘0’非自选卡号 version_201105

    李德良          2012-03-26       1.3           为审批后处理（开卡失败）报表准备数据
  */
  f_check NUMBER(1) := 0; --是否存在质检队列检查标志

  o_return NUMBER;

  o_msg VARCHAR2(2000);

  I_DATE DATE;

  I_STEP_APPROVED S08S1_OSCURRENTSTEP.STEP_ID%TYPE := 21;

  V_STATUS_MAKECARDING S08S1_OSCURRENTSTEP.STATUS%TYPE := 'makecarding';

  V_CARDTYPE S08S1_APPREGISTER.CARDTYPE%TYPE;

  EXP EXCEPTION;

  EXP_NONEEDCARD EXCEPTION;

  EXP_INVALID EXCEPTION;

  WAIT_MEMBERID EXCEPTION;

  V_ERR_CODE VARCHAR2(25);

  V_ERR_MSG VARCHAR2(255);

  V_H_ERROR VARCHAR2(255);

  N_RSCOUNT NUMBER(10);

  ROW_APPREG S08S1_APPREGISTER%ROWTYPE;

  ROW_PROPOSER S08S1_PROPOSER%ROWTYPE;

  N_INPUT_ENTRY_ID S08S1_OSCURRENTSTEP.ENTRY_ID%TYPE;

  V_INPUT_OLD_STATUS S08S1_OSCURRENTSTEP.STATUS%TYPE;

  V_INPUT_STATUS S08S1_OSCURRENTSTEP.STATUS%TYPE;

  I_INPUT_STEPID S08S1_OSCURRENTSTEP.STEP_ID%TYPE;

  I_INPUT_ACTIONID S08S1_OSCURRENTSTEP.ACTION_ID%TYPE;

  V_INPUT_OWNER S08S1_OSCURRENTSTEP.OWNER%TYPE;

  V_INPUT_CALLER S08S1_OSCURRENTSTEP.CALLER%TYPE;

  V_CUST_SHOT_NAME S08S0_01_CUST.Short_Name%TYPE;

  --caoyy 20091223 卡TAPY为：800、801、802、813、814、815的钻白卡，增加客户等级字段为"D"
  V_CUSTOMER_CLASS VARCHAR2(1);

  V_OUTPUT VARCHAR2(1000);

  B_OUTPUT_ADDR BOOLEAN;

  V_OUTPUT_INVALID S08S1_PROPOSER.H_ERROR%TYPE;

  V_ADDR2 VARCHAR2(30);

  V_TYPE  VARCHAR2(3);

  V_ADDR3 VARCHAR2(30);

  ROW_CARDTYPE VARCHAR2(5);


  --caoyy 2009-11-27 主机工作单位长度
  EMPLOYER_LENGTH INTEGER(2) := 30;

  ROW_EMBOSSER_NAME_2 VARCHAR2(19);

  c_Fee VARCHAR2(3);

  c_Fee_Validdate VARCHAR2(10);

  V_OWNER_CNT NUMBER(2);

  CURSOR CUR_APPCARD IS

    SELECT T.*

      FROM S08S1_APPREGISTER T
     INNER JOIN S08S1_OSCURRENTSTEP T1 ON T.ENTRY_ID = T1.ENTRY_ID

     WHERE T.APPID = i_appid
       AND T1.STEP_ID = I_STEP_APPROVED
       AND T1.STATUS = V_STATUS_MAKECARDING;

  CURSOR CUR_PROPOSER(V_APPID CHAR) IS

    SELECT T.*

      FROM S08S1_PROPOSER T

     WHERE T.APPID = V_APPID

       AND T.IDTYPE IS NOT NULL
       AND T.ID IS NOT NULL

       AND T.A_FLAG = '1' --审批同意

     ORDER BY T.APPID, T.INPUTSEQ;

  e_error EXCEPTION;

  v_num NUMBER(3);

  v_step NUMBER(6);

  --检查个人责任还款商务卡
  function checkIBCCorpCard(cardtype varchar2) return boolean is
    ROW_PVALUE varchar2(30);
    corptype   varchar2(3);
  begin
    select t.pvalue
      into ROW_PVALUE
      from s08s1_parameter t
     where t.code = 'IBCCARD';

    corptype := substr(cardtype, 1, 3);
    if instr(ROW_PVALUE, corptype, 1) > 0 then
      return true;
    end if;
    return false;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return false;
  end;

BEGIN

  v_step := 10;

  --获取业务当前时间

  SELECT currdate into I_DATE from s08sysparm;

  OPEN CUR_APPCARD;

  LOOP

    v_step := 20;

    FETCH CUR_APPCARD
      INTO ROW_APPREG;

    EXIT WHEN CUR_APPCARD%NOTFOUND OR CUR_APPCARD%NOTFOUND IS NULL;

    DECLARE

      V_INPUT VARCHAR2(1000) := NULL;

      V_CORPINF VARCHAR2(5000) := NULL;

      XML_CORP XMLTYPE := NULL;

      ROW_ORG S08S1_PUBLICCORPINFO%ROWTYPE := NULL;

      ROW_PROPOSER_MAIN S08S1_PROPOSER%ROWTYPE := NULL;

    BEGIN

      v_step := 30;

      OPEN CUR_PROPOSER(ROW_APPREG.APPID);

      LOOP

        v_step := 40;

        FETCH CUR_PROPOSER
          INTO ROW_PROPOSER;

        EXIT WHEN CUR_PROPOSER%NOTFOUND OR CUR_PROPOSER%NOTFOUND IS NULL;

        DECLARE

          ROW_CARD S08S1_CREATEAPPCARD_URGENT%ROWTYPE := NULL;

          V_CUSTINF VARCHAR2(5000) := NULL;

          XML_CUST XMLTYPE := NULL;

          V_MAININF VARCHAR2(5000) := NULL;

          XML_MAIN XMLTYPE := NULL;

          -- 增加南航卡的处理  2009-09-29 谢凤玲

          V_CORPID S08S1_CARDTYPELMK.CORPID%TYPE; --联名单位代码

          V_MEMBER_RESULT VARCHAR2(10) := null; --0、1、2、3、4
          /* 0 正常开卡，将会员号更新到申请人表和开卡表，将会员信息表删除标志位置为1；
          1 反馈的会员信息有问题，进入开卡失败队列；
          2 等待反馈会员信息超时，进入开卡失败队列；
          3 在会员信息表找不到的,向会员信息表插入数据,不上送主机，在待开卡状态等候
          4 在规定时间内，未反馈会员信息，不上送主机，在待开卡状态等候 */

          V_MEMBERINFO VARCHAR2(5000) := NULL; --会员信息表中的信息

          XML_MEMBERINFO XMLTYPE := NULL; --会员信息表中的信息

          V_CODE VARCHAR2(6) := NULL;

          V_MEMBERID S08S1_MEMBER.MEMBERID%TYPE;

          V_DOWNFLAG S08S1_MEMBER.DOWNFLAG%TYPE;

          V_DOWNDATE S08S1_MEMBER.DOWNDATE%TYPE := NULL;

          V_UPLOADDATE S08S1_MEMBER.UPLOADDATE%TYPE := NULL;

          V_CONTRASTCODE S08S1_MEMBER.CONTRASTCODE%TYPE;

          V_CONTRASTDESC S08S1_MEMBER.CONTRASTDESC%TYPE;

          /*

          1--主卡类型

          2--商务卡类型

          3--附卡类型

          4--附卡单申类型

          5--主卡开卡成功，对应附卡为附卡单申类型

          */

          I_STATUS INTEGER;

        BEGIN

          --modify by   fanfuqiao  delete 13
          IF ROW_APPREG.APPTYPE NOT IN ('07')

             AND ROW_PROPOSER.INPUTSEQ = 0 THEN

            ROW_PROPOSER_MAIN := ROW_PROPOSER;

          END IF;

          IF ROW_PROPOSER.H_RETCODE = '00' THEN

            --制卡成功，不需要加入到待制卡表

            v_step := 45;

            RAISE EXP_NONEEDCARD;

          END IF;

          --商务卡的法人代表不需要加入待制卡表

          IF ROW_APPREG.APPTYPE = '13' AND ROW_PROPOSER.INPUTSEQ = 0 THEN

            v_step := 48;

            RAISE EXP_NONEEDCARD;

          END IF;

          --查询制卡信息表里面是否已经存在要开卡的记录

          --已经存在就不需要再加入到制卡信息表中

          v_step := 50;

          SELECT COUNT(T.APP_NBR)
            INTO N_RSCOUNT
            FROM S08S1_CREATEAPPCARD_URGENT T

           WHERE T.APP_NBR = ROW_PROPOSER.APPID
             AND T.SEQ = ROW_PROPOSER.INPUTSEQ;

          IF N_RSCOUNT <> 0 THEN

            v_step := 55;

            RAISE EXP_NONEEDCARD;

          END IF;

          --进件类型APP_TYPE

          --商务卡

          IF ROW_APPREG.APPTYPE = '13' THEN

            ROW_CARD.APP_TYPE := '2';

            I_STATUS := 2;

            --附卡单申

          ELSIF ROW_APPREG.APPTYPE = '07' THEN

            ROW_CARD.APP_TYPE := '4';

            I_STATUS := 4;

            --其它进件类型,主卡

          ELSIF ROW_PROPOSER.INPUTSEQ = 0 OR ROW_PROPOSER.INPUTSEQ IS NULL THEN

            ROW_CARD.APP_TYPE := '1';

            I_STATUS := 1;

          ELSE

            --如果主卡开卡成功，那么主卡对应附卡为附卡单申类型

            IF ROW_PROPOSER_MAIN.H_RETCODE = '00' THEN

              ROW_CARD.APP_TYPE := '4';

              I_STATUS := 5;

              --如果主卡开卡失败，那么主卡对应附卡为附卡类型

            ELSE

              ROW_CARD.APP_TYPE := '3';

              I_STATUS := 3;

            END IF;

          END IF;

          IF I_STATUS = 2 THEN
            --商务卡

            IF ROW_ORG.APPID IS NULL THEN

              v_step := 60;

              SELECT T.*
                INTO ROW_ORG

                FROM S08S1_PUBLICCORPINFO T

               WHERE T.APPID = ROW_PROPOSER.APPID;

            END IF;

            --查询组织机构信息

            IF XML_CORP IS NULL THEN

              v_step := 70;

              V_INPUT := '<REQUEST><PARAMETER><ID>CORP_NBR</ID><VALUE>' ||
                         ROW_ORG.ORGANISEID ||
                         '</VALUE></PARAMETER></REQUEST>';

              BEGIN

                v_step := 80;

                --modify by wuqf on 2010-03-26  调用xmltype(clob)函数，去除返回字符大于4000的错误
                --V_CORPINF := S08F_GET_CORPINF(V_INPUT);
                XML_CORP := XMLTYPE(S08F_GET_CORPINF(V_INPUT));
                --end wuqf

              EXCEPTION

                WHEN OTHERS THEN

                  v_step := 90;

                  V_CORPINF := '<RESPONSE><RESULT><CORP><CREDIT_LIMIT></CREDIT_LIMIT></CORP></RESULT></RESPONSE>';
                  --modify by wuqf on 2010-03-26，对于查询出错的，调用xmltype(varchar2).
                  XML_CORP := XMLTYPE(V_CORPINF);
                  --end wuqf
              END;

              --modify by wuqf on 2010-03-26.以前是正确的返回公司信息与错误一同处理，现在提到各情况中处理
              --XML_CORP := XMLTYPE(V_CORPINF);
              --end

            END IF;

          ELSE

            --查询申请件的客户信息

            v_step := 100;

            V_INPUT := '<REQUEST><PARAMETER><ID>IDNBR</ID><VALUE>' ||
                       ROW_PROPOSER.ID || '</VALUE></PARAMETER></REQUEST>';

            BEGIN

              v_step := 110;

              V_CUSTINF := S08F_GET_CUST_FOC(V_INPUT);

            EXCEPTION

              WHEN OTHERS THEN

                v_step := 120;

                V_CUSTINF := '<RESPONSE><RESULT><CRLIMIT></CRLIMIT><ACCT_NBR></ACCT_NBR><SHORT_NAME></SHORT_NAME><CRLIMIT_PERM></CRLIMIT_PERM></RESULT></RESPONSE>';

            END;

            v_step := 130;

            XML_CUST := XMLTYPE(V_CUSTINF);

            --附卡单申类型，查询主卡的信息，国籍类别、证件号码

            IF I_STATUS = 4 THEN

              v_step := 140;

              V_INPUT := '<REQUEST><PARAMETER><ID>CARDNBR</ID><VALUE>' ||
                         ROW_PROPOSER.OLDCARDNBR ||
                         '</VALUE></PARAMETER></REQUEST>';

              BEGIN

                v_step := 150;

                V_MAININF := S08F_GET_PCARD_FOC(V_INPUT);

              EXCEPTION

                WHEN OTHERS THEN

                  v_step := 160;

                  V_MAININF := '<RESPONSE><RESULT><NATIONALITY></NATIONALITY><IDNBR></IDNBR><CARDTYPE></CARDTYPE><POST></POST></RESULT></RESPONSE>';

              END;

              XML_MAIN := XMLTYPE(V_MAININF);

            END IF;

          END IF;

          --机构MAINT_ORG

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.MAINT_ORG := '171';

          ELSE

            ROW_CARD.MAINT_ORG := '169';

          END IF;

          --卡类                            MAINT_TYPE

          IF I_STATUS = 4 THEN
            --附卡单申

            v_step := 170;

            SELECT EXTRACTVALUE(XML_MAIN, '/RESPONSE/RESULT/CARDTYPE')

              INTO ROW_CARD.MAINT_TYPE

              FROM DUAL;

          ELSIF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.MAINT_TYPE := SUBSTR(ROW_PROPOSER.CARDTYPE, 1, 3);

          ELSE

            IF ROW_APPREG.CARDTYPE IS NOT NULL THEN

              ROW_CARD.MAINT_TYPE := SUBSTR(ROW_APPREG.CARDTYPE, 1, 3);

            END IF;

          END IF;

          --进件号                          APP_NBR

          ROW_CARD.APP_NBR := ROW_PROPOSER.APPID;

          --附卡顺序号                      SEQ

          ROW_CARD.SEQ := ROW_PROPOSER.INPUTSEQ;

          --进件核准日期                    MAINT_JUL

          v_step := 180;

          SELECT TO_CHAR(T.CURRDATE, 'YYYYDDD')
            INTO ROW_CARD.MAINT_JUL

            FROM S08SYSPARM T
           WHERE T.INO = '000000000';

          --进件核准时间                    MAINT_TIME

          ROW_CARD.MAINT_TIME := '000000';

          --进件录入终端号                  TERMINAL_ID

          ROW_CARD.TERMINAL_ID := '0000';

          --进件录入操作员ID                SIGNON_NAME

          BEGIN

            v_step := 190;

            SELECT T.CALLER
              INTO ROW_CARD.SIGNON_NAME

              FROM S08S1_OSHISTORYSTEP T

             WHERE T.ENTRY_ID = ROW_APPREG.ENTRY_ID

               AND T.ACTION_ID = 141;

          EXCEPTION

            WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN

              ROW_CARD.SIGNON_NAME := ' ';

          END;

          --持卡人姓名                      NAME_LINE_1

          ROW_CARD.NAME_LINE_1 := NVL(ROW_PROPOSER.NAME, ' ');

          --持卡人姓名（简称）              SH_NAME

          -- ROW_CARD.SH_NAME := NVL(ROW_PROPOSER.SH_NAME,' '); 2008-9-5
          ROW_CARD.SH_NAME := S08F_CUT_SH_NAME(ROW_PROPOSER.NAME);

          --主卡申请人英文姓名或拼音        NAME_LINE_2

          ROW_CARD.NAME_LINE_2 := NVL(ROW_PROPOSER.SPELLNAME, ' ');

          --住宅电话                        HOME_PHONE

          IF ROW_PROPOSER.H_TEL IS NOT NULL

             AND LENGTH(ROW_PROPOSER.H_TEL) > 18 THEN

            ROW_CARD.HOME_PHONE := SUBSTR(ROW_PROPOSER.H_TEL, 1, 18);

            ROW_CARD.HOME_PHONE := NVL(ROW_CARD.HOME_PHONE,
                                       '000000000000000000');

          ELSE

            ROW_CARD.HOME_PHONE := NVL(ROW_PROPOSER.H_TEL,
                                       '000000000000000000');

          END IF;

          --手机号                          CO_PHONE

          ROW_CARD.CO_PHONE := NVL(ROW_PROPOSER.MOBILE, ' ');

          --住宅地址拆分

          V_ADDR2 := NULL;

          V_ADDR3 := NULL;

          B_OUTPUT_ADDR := NULL;

          v_step := 200;

          B_OUTPUT_ADDR := S08F_CONVERT_ADDR(ROW_PROPOSER.H_ADDR,

                                             V_ADDR2,

                                             V_ADDR3);

          IF B_OUTPUT_ADDR IS NOT NULL AND B_OUTPUT_ADDR = FALSE THEN

            V_OUTPUT_INVALID := '住宅地址拆分发生错误！';

            RAISE EXP_INVALID;

          END IF;

          --住宅地址１                      ADDR_LINE_1

          ROW_CARD.ADDR_LINE_1 := ROW_PROPOSER.H_ADDR;

          --住宅地址2                       ADDR_LINE_2

          ROW_CARD.ADDR_LINE_2 := V_ADDR2;

          --住宅地址3                       CITY

          ROW_CARD.CITY := V_ADDR3;

          --分行代码                        CENSUS

          ROW_CARD.CENSUS := NVL(ROW_APPREG.AUTHORG, '000000000');

          --主卡国籍类别                    STATE_P

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.STATE_P := NVL(ROW_PROPOSER.COUNTRY, '1');

          ELSIF I_STATUS = 4 THEN
            --附卡单申

            v_step := 210;

            SELECT EXTRACTVALUE(XML_MAIN, '/RESPONSE/RESULT/NATIONALITY')

              INTO ROW_CARD.STATE_P

              FROM DUAL;

            ROW_CARD.STATE_P := NVL(ROW_CARD.STATE_P, '1');

          ELSIF I_STATUS = 1 THEN
            --主卡

            ROW_CARD.STATE_P := NVL(ROW_PROPOSER.COUNTRY, '1');

          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN
            --附卡 或者  主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.STATE_P := NVL(ROW_PROPOSER_MAIN.COUNTRY, '1');

          END IF;

          --附卡国籍类别                    STATE_S

          v_step := 220;

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.STATE_S := ' ';

          ELSIF I_STATUS = 4 THEN
            --附卡单申

            ROW_CARD.STATE_S := NVL(ROW_PROPOSER.COUNTRY, '1');

          ELSIF I_STATUS = 1 THEN
            --主卡

            ROW_CARD.STATE_S := ' ';

          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN
            --附卡 或者  主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.STATE_S := NVL(ROW_PROPOSER.COUNTRY, '1');

          END IF;

          --邮编                            ZIP_CODE

          v_step := 230;

          IF I_STATUS = 4 THEN
            --附卡单申

            ROW_CARD.ZIP_CODE := ROW_PROPOSER.H_POST;

            --如果是空，查询主卡的邮编

            IF ROW_CARD.ZIP_CODE IS NULL THEN

              v_step := 240;

              SELECT EXTRACTVALUE(XML_MAIN, '/RESPONSE/RESULT/POST')

                INTO ROW_CARD.ZIP_CODE

                FROM DUAL;

              IF ROW_CARD.ZIP_CODE IS NULL THEN

                ROW_CARD.ZIP_CODE := '000000';

              END IF;

            END IF;

          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN

            ROW_CARD.ZIP_CODE := ROW_PROPOSER.H_POST;

            --如果是空，查询主卡的邮编

            IF ROW_CARD.ZIP_CODE IS NULL THEN

              ROW_CARD.ZIP_CODE := NVL(ROW_PROPOSER_MAIN.H_POST, '000000');

            END IF;

          ELSIF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.ZIP_CODE := ROW_ORG.CORPPOST;

          ELSE

            ROW_CARD.ZIP_CODE := NVL(ROW_PROPOSER.H_POST, '000000');

          END IF;

          --证件类别                        RACE

          ROW_CARD.RACE := NVL(ROW_PROPOSER.IDTYPE, ' ');

          --证件号码                        CO_OWNER

          ROW_CARD.CO_OWNER := NVL(ROW_PROPOSER.ID, ' ');

          --客户（商务卡部门）的人民币信用额度      CREDIT_LINE

          IF I_STATUS = 2 THEN
            --商务卡

            v_step := 250;

            SELECT EXTRACTVALUE(XML_CORP,
                                '/RESPONSE/RESULT/CORP/CREDIT_LIMIT')

              INTO ROW_CARD.CREDIT_LINE

              FROM DUAL;

            ROW_CARD.CREDIT_LINE := NVL(ROW_CARD.CREDIT_LINE, 0);

          ELSE

            v_step := 260;

            SELECT EXTRACTVALUE(XML_CUST, '/RESPONSE/RESULT/CRLIMIT')

              INTO ROW_CARD.CREDIT_LINE

              FROM DUAL;

            IF ROW_CARD.CREDIT_LINE IS NULL THEN

              ROW_CARD.CREDIT_LINE := NVL(ROW_PROPOSER.A_CREDIT_RMB, 0);

            END IF;
          END IF;

          v_step := 261;
          --生日(DDMMYYYY)                          BIRTH_DATE

          ROW_CARD.BIRTH_DATE := NVL(TO_CHAR(ROW_PROPOSER.BIRTH, 'DDMMYYYY'),
                                     '00000000');

          --caoyy 2009-11-27 工作单位名称 > 28字节，拒件
          v_step := 262;
          --工作单位名称                            EMPLOYER

          ROW_CARD.EMPLOYER := NVL(ROW_PROPOSER.CORPNAME, ' ');

          IF S08F_CONVERT_ADDR_ITEM(ROW_CARD.EMPLOYER) > EMPLOYER_LENGTH THEN

            v_step := 263;

            V_OUTPUT_INVALID := '工作单位名称大于28字节！';

            RAISE EXP_INVALID;

          END IF;

          --工作单位电话                            WORK_PHONE
          v_step := 264;
          IF ROW_PROPOSER.CORPTEL IS NOT NULL AND
             LENGTH(ROW_PROPOSER.CORPTEL) > 18 THEN

            ROW_CARD.WORK_PHONE := SUBSTR(ROW_PROPOSER.CORPTEL, 1, 18);

          ELSE
            v_step              := 265;
            ROW_CARD.WORK_PHONE := NVL(ROW_PROPOSER.CORPTEL, ' ');

          END IF;

          --联系人名称                              CO_EMPLOYER
          v_step               := 266;
          ROW_CARD.CO_EMPLOYER := NVL(ROW_PROPOSER.CONTNAME, ' ');

          --联系人电话                              CO_WORK_PHONE
          IF ROW_PROPOSER.CONTMOBILE IS NOT NULL THEN
            v_step                 := 267;
            ROW_CARD.CO_WORK_PHONE := ROW_PROPOSER.CONTMOBILE;
          ELSIF ROW_PROPOSER.CONTTEL IS NOT NULL THEN
            v_step                 := 268;
            ROW_CARD.CO_WORK_PHONE := substr(ROW_PROPOSER.CONTTEL, 1, 18);
          ELSIF ROW_PROPOSER.CONT_H_TEL IS NOT NULL THEN
            v_step                 := 269;
            ROW_CARD.CO_WORK_PHONE := substr(ROW_PROPOSER.CONT_H_TEL, 1, 18);
          ELSE
            ROW_CARD.CO_WORK_PHONE := '99999999999';
          END IF;

          --助记1(质押金帐号 + 金额)                MEMO_1
          v_step          := 271;
          ROW_CARD.MEMO_1 := NVL(ROW_PROPOSER.ASSUREACCT ||
                                 ROW_PROPOSER.ASSUREMONEY,
                                 ' ');

          --助记2                                   MEMO_2
          v_step          := 272;
          ROW_CARD.MEMO_2 := ' ';

          --兴趣                                    EU_SURN
          v_step           := 273;
          ROW_CARD.EU_SURN := '10';

          --条件差异注记                            EU_TITLE
          v_step            := 274;
          ROW_CARD.EU_TITLE := '00';

          --性别                                    EU_SEX
          v_step          := 275;
          ROW_CARD.EU_SEX := NVL(ROW_PROPOSER.SEX, 0);

          --住宅性质                                HOME_OWNER
          v_step              := 276;
          ROW_CARD.HOME_OWNER := NVL(ROW_PROPOSER.H_KIND, 0);

          --居住年限(YYMM)                          PER_OF_RES
          v_step              := 277;
          ROW_CARD.PER_OF_RES := '0000';

          --来源码                                  ACORN_CODE
          --增加商务卡流程OR I_STATUS = 2
          v_step := 278;
          IF I_STATUS = 3 OR I_STATUS = 5 OR I_STATUS = 2 THEN
            --附卡 或者  主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.ACORN_CODE := NVL(ROW_PROPOSER_MAIN.SRCCODE, ' ');

          ELSE

            ROW_CARD.ACORN_CODE := NVL(ROW_PROPOSER.SRCCODE, ' ');

          END IF;

          --婚姻状态                                MARITAL_STATUS
          v_step                  := 279;
          ROW_CARD.MARITAL_STATUS := NVL(ROW_PROPOSER.MARRYSTATE, 0);

          --已持信用卡状况                          NBR_OF_DEPS
          v_step               := 281;
          ROW_CARD.NBR_OF_DEPS := NVL(ROW_PROPOSER.HOLDCREDIT, 0);

          --职务                                    OCCPN_CODE
          v_step              := 282;
          ROW_CARD.OCCPN_CODE := NVL(ROW_PROPOSER.TITLE, ' ');

          --现单位工作年限(YYMM)                    PER_OCCPN
          v_step := 283;
          IF ROW_PROPOSER.WORKAGE IS NOT NULL THEN

            IF ROW_PROPOSER.WORKAGE < 10 THEN

              ROW_CARD.PER_OCCPN := '0' || ROW_PROPOSER.WORKAGE || '00';

            ELSE

              ROW_CARD.PER_OCCPN := ROW_PROPOSER.WORKAGE || '00';

            END IF;

          ELSE

            ROW_CARD.PER_OCCPN := '0000';

          END IF;

          --卡人等级                                CUSTOMER_CLASS
          v_step     := 284;
          V_CARDTYPE := ROW_APPREG.CARDTYPE;
          --caoyy 20100111 初始化V_CUSTOMER_CLASS
          V_CUSTOMER_CLASS := ' ';

          --caoyy 20091223 主附同申、附卡单申情况，根据主卡卡TYPE判断附卡卡人等级
          IF I_STATUS = 3 OR I_STATUS = 5 THEN
            --主附同申

            V_CARDTYPE := ROW_PROPOSER_MAIN.CARDTYPE;

          ELSIF I_STATUS = 4 THEN
            --附卡单申
            V_CARDTYPE := ROW_CARD.MAINT_TYPE;

          END IF;

          --caoyy 20091223 钻石白金卡，增加卡人等级
          IF V_CARDTYPE IS NOT NULL THEN
            BEGIN

              SELECT CUSTOMER_CLASS
                INTO V_CUSTOMER_CLASS
                FROM S08S1_PARA_CARDTYPECLASS
               WHERE CARDTYPE = SUBSTR(V_CARDTYPE, 1, 3);

            EXCEPTION
              WHEN OTHERS THEN
                --caoyy 20100111 普通卡客户等级为' '
                V_CUSTOMER_CLASS := ' ';
            END;

            ROW_CARD.CUSTOMER_CLASS := NVL(V_CUSTOMER_CLASS, ' ');
          ELSE

            ROW_CARD.CUSTOMER_CLASS := ' ';

          END IF;

          --行业                                    EMPLOYER_CODE
          v_step                 := 285;
          ROW_CARD.EMPLOYER_CODE := NVL(ROW_PROPOSER.C_INDUSTRY, ' ');

          --职称                                    OCCPN_TITLE
          v_step               := 286;
          ROW_CARD.OCCPN_TITLE := NVL(TO_CHAR(ROW_PROPOSER.WORKTITLE), '00');

          --账单地址拆分

          --帐单地址 1                              ADDL_ADDR_1

          --帐单地址 2                              ADDL_ADDR_2

          --帐单地址 3                              ADDL_ADDR_3

          v_step := 270;

          IF ROW_PROPOSER.ACCTADDRFLAG = 1 THEN
            --账单地址为住宅地址

            ROW_CARD.ADDL_ADDR_1 := ROW_PROPOSER.H_ADDR;

            ROW_CARD.ADDL_ADDR_2 := V_ADDR2;

            ROW_CARD.ADDL_ADDR_3 := V_ADDR3;

          ELSIF ROW_PROPOSER.ACCTADDRFLAG = 2 THEN
            --账单地址为单位地址

            V_ADDR2 := NULL;

            V_ADDR3 := NULL;

            B_OUTPUT_ADDR := NULL;

            v_step := 280;

            B_OUTPUT_ADDR := S08F_CONVERT_ADDR(ROW_PROPOSER.CORPADDR,

                                               V_ADDR2,

                                               V_ADDR3);

            IF B_OUTPUT_ADDR IS NOT NULL AND B_OUTPUT_ADDR = FALSE THEN

              V_OUTPUT_INVALID := '账单地址(单位地址)拆分发生错误！';

              RAISE EXP_INVALID;

            END IF;

            ROW_CARD.ADDL_ADDR_1 := ROW_PROPOSER.CORPADDR;

            ROW_CARD.ADDL_ADDR_2 := V_ADDR2;

            ROW_CARD.ADDL_ADDR_3 := V_ADDR3;

          ELSE
            --账单地址为其他账单地址

            V_ADDR2 := NULL;

            V_ADDR3 := NULL;

            B_OUTPUT_ADDR := NULL;

            v_step := 290;

            B_OUTPUT_ADDR := S08F_CONVERT_ADDR(ROW_PROPOSER.ACCTADDR,

                                               V_ADDR2,

                                               V_ADDR3);

            IF B_OUTPUT_ADDR IS NOT NULL AND B_OUTPUT_ADDR = FALSE THEN

              V_OUTPUT_INVALID := '其他账单地址拆分发生错误！';

              RAISE EXP_INVALID;

            END IF;

            ROW_CARD.ADDL_ADDR_1 := ROW_PROPOSER.ACCTADDR;

            ROW_CARD.ADDL_ADDR_2 := V_ADDR2;

            ROW_CARD.ADDL_ADDR_3 := V_ADDR3;

          END IF;

          --账单地址邮编                            ADDL_ZIP

          v_step := 300;

          IF ROW_PROPOSER.ACCTADDRFLAG = 1 THEN
            --账单地址为住宅地址

            ROW_CARD.ADDL_ZIP := NVL(ROW_PROPOSER.H_POST, ' ');

          ELSIF ROW_PROPOSER.ACCTADDRFLAG = 2 THEN
            --账单地址为单位地址

            ROW_CARD.ADDL_ZIP := NVL(ROW_PROPOSER.CORPPOST, ' ');

          ELSE
            --账单地址为其他账单地址

            ROW_CARD.ADDL_ZIP := NVL(ROW_PROPOSER.ACCTPOST, ' ');

          END IF;

          --E_MAIL 地址                             EMAIL

          ROW_CARD.EMAIL := NVL(ROW_PROPOSER.EMAIL, ' ');

          --学历                                    ADDL_USAGE_6

          ROW_CARD.ADDL_USAGE_6 := NVL(ROW_PROPOSER.EDUCATION, ' ');

          --自有不动产数量                          ADDL_USAGE_7

          ROW_CARD.ADDL_USAGE_7 := '0';

          --分配还款标志                            ADDL_USAGE_8

          IF I_STATUS = 1 THEN

            ROW_CARD.ADDL_USAGE_8 := '3';--version 20131102 杨春 还款分配标识默认有3变更为2

          ELSE

            ROW_CARD.ADDL_USAGE_8 := '0';

          END IF;

          --年收入                                  INCOME

          ROW_CARD.INCOME := NVL(ROW_PROPOSER.EARNING, 0);

          --特征资料                                MOTHER

          ROW_CARD.MOTHER := ' ';

          --营销人员代码                            ALPHA_KEY_1

          ROW_CARD.ALPHA_KEY_1 := NVL(ROW_APPREG.SALNBR, ' ');

          --营销单位代码                            ALPHA_KEY_2

          ROW_CARD.ALPHA_KEY_2 := ' ';

          --卡片人民币信用限额                      CREDIT_LIMI
            IF    trim(ROW_PROPOSER.ACCTPRODFLAG) IS NULL   THEN

             V_TYPE :=SUBSTR(ROW_PROPOSER.CARDTYPE,0,3);

            IF   ROW_APPREG.APPTYPE='05'AND( V_TYPE='026' OR V_TYPE='900'OR
                   V_TYPE='910' )THEN

                     IF trim(ROW_PROPOSER.EMAIL) IS NULL THEN
                            ROW_CARD.ACCTPRODFLAG:='03';
                     ELSIF
                            trim(ROW_PROPOSER.EMAIL) IS NOT NULL  THEN
                          ROW_CARD.ACCTPRODFLAG:='00';
                     END IF;

                  ELSIF   ROW_APPREG.APPTYPE='04' AND
                  (V_TYPE='110' OR V_TYPE='210' OR
                   V_TYPE='310' OR V_TYPE='410' )THEN

                     IF trim(ROW_PROPOSER.EMAIL) IS NULL THEN
                            ROW_CARD.ACCTPRODFLAG:='03';
                     ELSIF
                            trim(ROW_PROPOSER.EMAIL) IS NOT NULL  THEN
                          ROW_CARD.ACCTPRODFLAG:='00';
                     END IF;

                    ELSIF   ROW_APPREG.APPTYPE='06'OR ROW_APPREG.APPTYPE='17' OR ROW_APPREG.APPTYPE='07'THEN

                       ROW_CARD.ACCTPRODFLAG:=' ';

                       ELSE

                        ROW_CARD.ACCTPRODFLAG:='03';
               END IF;
         ELSE
               ROW_CARD.ACCTPRODFLAG:=ROW_PROPOSER.ACCTPRODFLAG;
         END IF;--账单

   ROW_CARD.PROFESSION:= NVL(ROW_PROPOSER.PROFESSION, ' ');--职业

          ROW_CARD.PRO_CUSTOM:= NVL(ROW_PROPOSER.PRO_CUSTOM, ' ');--其他职业

          if ROW_PROPOSER.UNLIMIT_FLAG=1 THEN
          ROW_CARD.ID_VALID_DATE:=  TO_CHAR(DATE'2199-01-01','DDMMYYYY');--证件有效期
           ELSE
             ROW_CARD.ID_VALID_DATE:= NVL(TO_CHAR(ROW_PROPOSER. ID_VALID_DATE,'DDMMYYYY'),
                                     '00000000');
          End If;
--陶兴 version201404 新增 账单 职业 其他职业 证件有效期

          ROW_CARD.CREDIT_LIMI := NVL(ROW_PROPOSER.A_CREDIT_RMB, 0);

          --商务卡卡片美元限额                      CREDIT_LIMI_USD

          ROW_CARD.CREDIT_LIMI_USD := NVL(ROW_PROPOSER.A_CREDIT_USD, 0);

          --人民币账户还款方式                      ACH_FLAG

          ROW_CARD.ACH_FLAG := NVL(ROW_PROPOSER.PAYTYPE_RMB, 0);
          -- 2008-07-29 lyg 修补人民币设定还款帐号必须存在
          If ROW_CARD.ACH_FLAG In (1) -- 默认还款
             And (length(ROW_PROPOSER.Ach_Bank) < 3 -- 无效分行号
             Or LENGTH(ROW_PROPOSER.ACCT_RMB) Not In (16, 19) -- 无效的帐号
             Or instr(ROW_PROPOSER.ACCT_RMB, '0000000', 1, 1) = 1 -- linxin : 08-10-14 拒绝全零的还款帐号
             ) Then
            v_step := 970;
            --2008-09-03 ，人民币账户还款方式校验不通过时，向申请人表的错误原因字段添加信息  xfl
            V_OUTPUT_INVALID := '人民币账户还款方式为1时，人民币账户指定分行长度不能小于3，人民币还款账号只能为16或19位非零帐号，请检查！';
            RAISE EXP_INVALID;
          End If;

          --人民币账户指定分行                      modified by ZhangZhihui on 2008-03-24

          IF ROW_PROPOSER.ACCT_RMB IS NULL THEN

            ROW_CARD.ACH_BANK := '000000000';

          ELSE

            --ROW_CARD.ACH_BANK := substr(ROW_PROPOSER.AUTHORG, 1, 3) || length(ROW_PROPOSER.ACCT_RMB) || substr(ROW_PROPOSER.ACCT_RMB, 1, 4); modified by chenms on 20080418

            ROW_CARD.ACH_BANK := substr(ROW_PROPOSER.Ach_Bank, 1, 3) ||
                                 length(ROW_PROPOSER.ACCT_RMB) ||
                                 substr(ROW_PROPOSER.ACCT_RMB, 1, 4);

          END IF;

          --人民币指定还款帐号                      ACH_ACCT

          IF ROW_PROPOSER.ACCT_RMB IS NULL THEN

            ROW_CARD.ACH_ACCT := '0000000000000000';

          ELSE

            IF LENGTH(ROW_PROPOSER.ACCT_RMB) = 16 THEN

              ROW_CARD.ACH_ACCT := ROW_PROPOSER.ACCT_RMB;

            ELSIF LENGTH(ROW_PROPOSER.ACCT_RMB) = 19 THEN

              ROW_CARD.ACH_ACCT := SUBSTR(ROW_PROPOSER.ACCT_RMB, 1, 1) ||
                                   SUBSTR(ROW_PROPOSER.ACCT_RMB, 5, 15);

            END IF;

            ROW_CARD.ACH_ACCT := NVL(ROW_CARD.ACH_ACCT, '0000000000000000');

          END IF;

          --美元账户还款方式                        ACH_FLAG_U

          ROW_CARD.ACH_FLAG_U := NVL(ROW_PROPOSER.PAYTYPE_USD, 0);

          If ROW_CARD.ACH_FLAG_U In (1, 9) -- 美元还款标记
             And (length(ROW_PROPOSER.Ach_Bank_u) < 3 Or -- 无效的美元帐户分行号
             LENGTH(ROW_PROPOSER.ACCT_USD) Not In (16, 19) -- 无效的美元帐户
             Or instr(ROW_PROPOSER.ACCT_USD, '00000000', 1, 1) = 1) -- linxin : 08-10-14 拒绝全零的还款帐号
           Then
            v_step := 980;
            --2008-09-03 ，美元账户还款方式校验不通过时，向申请人表的错误原因字段添加信息   xfl
            V_OUTPUT_INVALID := '美元账户还款方式为购汇或者美元还款时，账户指定分行长度不能小于3，还款账号只能为16或19位，请检查！';
            RAISE EXP_INVALID;
          End If;

          --美元账户指定分行                        modified by ZhangZhihui on 2008-03-24

          IF ROW_PROPOSER.Acct_Usd IS NULL THEN

            ROW_CARD.ACH_BANK_U := '000000000';

          ELSE

            --ROW_CARD.ACH_BANK_U := substr(ROW_PROPOSER.AUTHORG, 1, 3) || length(ROW_PROPOSER.ACCT_USD) || substr(ROW_PROPOSER.ACCT_USD, 1, 4); modified by chenms on 20080418

            ROW_CARD.ACH_BANK_U := substr(ROW_PROPOSER.Ach_Bank_u, 1, 3) ||
                                   length(ROW_PROPOSER.ACCT_USD) ||
                                   substr(ROW_PROPOSER.ACCT_USD, 1, 4);

          END IF;

          --美元指定还款帐号                        ACH_ACCT_U

          IF ROW_PROPOSER.ACCT_USD IS NULL THEN

            ROW_CARD.ACH_ACCT_U := '0000000000000000';

          ELSE

            IF LENGTH(ROW_PROPOSER.ACCT_USD) = 16 THEN

              ROW_CARD.ACH_ACCT_U := ROW_PROPOSER.ACCT_USD;

            ELSIF LENGTH(ROW_PROPOSER.ACCT_USD) = 19 THEN

              ROW_CARD.ACH_ACCT_U := SUBSTR(ROW_PROPOSER.ACCT_USD, 1, 1) ||
                                     SUBSTR(ROW_PROPOSER.ACCT_USD, 5, 15);

            END IF;

            ROW_CARD.ACH_ACCT_U := NVL(ROW_CARD.ACH_ACCT_U,
                                       '0000000000000000');

          END IF;

          --与主卡持卡人关系                        OWNERSHIP_FLAG

          ROW_CARD.OWNERSHIP_FLAG := NVL(ROW_PROPOSER.RELATION, ' ');

          --持他行信用卡家数                        COLLATERAL_CODE

          ROW_CARD.COLLATERAL_CODE := 0;

          --捐款类别                                USER_CODE_1

          ROW_CARD.USER_CODE_1 := NVL(ROW_PROPOSER.DONATIONTYPE, ' ');

          --caoyy 2009-11-27 上送捐款单位
          v_step            := 985;
          ROW_CARD.SAMECORP := NVL(ROW_PROPOSER.SAMECORP, '  ');

          --caoyy 2009-11-27
          --【捐款单位】有；【捐款类别】没有将捐款单位置空
          --【捐款类别】有；【捐款单位】没有流转到开卡失败队列
          IF TRIM(ROW_CARD.USER_CODE_1) IS NOT NULL AND
             TRIM(ROW_CARD.SAMECORP) IS NULL THEN
            V_OUTPUT_INVALID := '捐款单位与捐款类别不匹配！';
            RAISE EXP_INVALID;
          ELSIF TRIM(ROW_CARD.USER_CODE_1) IS NULL AND
                TRIM(ROW_CARD.SAMECORP) IS NOT NULL THEN
            ROW_CARD.SAMECORP := '  ';
          END IF;

          --人民币缴款比例                          PYMT_FLAG

          ROW_CARD.PYMT_FLAG := NVL(ROW_PROPOSER.SCALE_RMB, ' ');

          --美元缴款比例                            PYMT_FLAG_U

          ROW_CARD.PYMT_FLAG_U := NVL(ROW_PROPOSER.SCALE_USD, ' ');

          --授权短信标志                            DISPLAY_REQUEST

          ROW_CARD.DISPLAY_REQUEST := '2';

          --卡面类型                                EMBOSSER_TYPE_1

          IF I_STATUS = 2 THEN
            ROW_CARD.EMBOSSER_TYPE_1 := SUBSTR(ROW_PROPOSER.CARDTYPE, 4, 2);
          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN
            --附卡 或者 主卡开卡成功，主附同申的附卡送主机用主卡的卡TYPE，附卡的卡FACE  2008-10-13
            ROW_CARD.EMBOSSER_TYPE_1 := SUBSTR(ROW_PROPOSER.CARDTYPE, 4, 2);
          ELSE
            ROW_CARD.EMBOSSER_TYPE_1 := SUBSTR(ROW_APPREG.CARDTYPE, 4, 2);
          END IF;

          --领用方式                                EMBOSSER_RQTYPE_3

          --ROW_CARD.EMBOSSER_RQTYPE_3 := NVL(ROW_PROPOSER.GETMODE,0);  -- 20090418

          -- 20090418 start
          IF I_STATUS = 3 OR I_STATUS = 5 THEN
            ROW_CARD.EMBOSSER_RQTYPE_3 := NVL(ROW_PROPOSER_MAIN.GETMODE, 0);
          ELSE
            ROW_CARD.EMBOSSER_RQTYPE_3 := NVL(ROW_PROPOSER.GETMODE, 0);
          END IF;
          -- 20090418 end

          --消费验密标志                            VERIFY_PASS_FLAG
          IF ROW_PROPOSER.Inputseq != 0 THEN
            BEGIN
              SELECT A.PASSWDFLAG
                INTO ROW_PROPOSER.PASSWDFLAG
                FROM S08S1_PROPOSER A, S08S1_APPREGISTER B
               WHERE A.APPID = B.APPID
                 AND A.APPID = ROW_PROPOSER.APPID
                 AND A.INPUTSEQ = 0
                 AND B.APPTYPE != '13';
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                NULL;
            END;
          END IF;
          ROW_CARD.VERIFY_PASS_FLAG := NVL(ROW_PROPOSER.PASSWDFLAG, ' ');

          --消费验密金额                            VERIFY_PASS_AMT

          ROW_CARD.VERIFY_PASS_AMT := 0;

          -- 2008-10-14         根据新的方案修改优惠方案代码、优惠方案有效期
          --优惠方案代码                         POT_SELECT_CODE
          /*                                     优惠方案代码
              01-刷N次免次年年费 00 0000 无
              02－不免年费   00 0000 无
              03－终身免年费 01 1239（极大期限） 必须在POT_SETTING中建立有效01方案的对应关系
              04－免一年年费  01  0708（次年对月） 同上
              05－免二年年费  01  0709（次二年对月） 同上
              06－免三年年费 01  0710（次三年对月） 同上
              07－年费8折  02  1239（极大期限） 必须在POT_SETTING中建立有效02方案的对应关系
              ------------------- 主机自定义POT 策略。

              也就是说超过优惠方案'10'以上的直接转化为POT值, 并用极大期限填充有效期，例如
              33－白金钻石年费减半 33 1239（极大期限）必须在POT_SETTING中建立有效33方案的对应关系
              66－白金钻石年费全免 66 1239（极大期限）必须在POT_SETTING中建立有效66方案的对应关系
          */
          If ROW_PROPOSER.a_Feemode IN ('08', '09') Then
            v_step           := 900;
            V_OUTPUT_INVALID := '无效的年费政策！';
            RAISE EXP_INVALID;
          End If;

          -------------------------新增卡费优惠方案修改处理程序    韩哲修改---------------------

          c_Fee := ROW_PROPOSER.Cardfee; ----修改卡费由申请人信息表中的卡费值取得

          IF c_Fee IS NULL THEN
            ---------卡优惠代码为空则传'000'
            v_step := 901;
            c_Fee  := '000';

          END IF;

          v_step                := 902;
          ROW_CARD.CARDFEE_CODE := c_Fee;

          c_Fee_Validdate := ROW_PROPOSER.c_Fee_Validdate;

          IF c_Fee_Validdate = '00' THEN
            ----有效日期代码与有效日期转换对应关系  '00' 无优惠

            c_Fee_Validdate := '0000'; ----'01' 优惠终身;'02' 免一年年费；'03' 免二年年费；

          ELSIF c_Fee_Validdate = '01' THEN
            ----'04' 免三年年费

            c_Fee_Validdate := '1239';

          ELSIF c_Fee_Validdate = '02' THEN

            c_Fee_Validdate := to_char(add_months(i_date, 11), 'MMYY');

          ELSIF c_Fee_Validdate = '03' THEN

            c_Fee_Validdate := to_char(add_months(i_date, 23), 'MMYY');

          ELSIF c_Fee_Validdate = '04' THEN

            c_Fee_Validdate := to_char(add_months(i_date, 35), 'MMYY');

          END IF;

          IF c_Fee_Validdate IS NULL or c_Fee = '000' THEN
            v_step          := 903;
            c_Fee_Validdate := '0000';

          END IF;

          ROW_CARD.CARDFEE_EXP_DATE := c_Fee_Validdate; ----修改卡费由申请人信息表中的卡费有效日期的取得

          ROW_CARD.CARDFEE_TYPE := 'A'; -------  赋给默认值

          ROW_CARD.POT_SELECT_CODE := '00';

          ROW_CARD.POT_EXP_DATE := '0000';

          v_step := 910; --必须在POT_SETTING中建立优惠方案代码、卡type的对应关系

          IF TRIM(ROW_CARD.MAINT_TYPE) IS NOT NULL AND
             TRIM(ROW_CARD.POT_SELECT_CODE) IS NOT NULL and
             ROW_CARD.POT_SELECT_CODE <> '00' THEN

            BEGIN
              select potcode

                INTO ROW_CARD.POT_SELECT_CODE

                FROM s08s1_pot_setting

               WHERE cardtype = ROW_CARD.MAINT_TYPE

                 AND potcode = ROW_CARD.POT_SELECT_CODE

                 AND rownum = 1;

            EXCEPTION

              WHEN NO_DATA_FOUND THEN

                V_OUTPUT_INVALID := '在表s08s1_pot_setting中找不到：cardtype=' ||
                                    ROW_CARD.MAINT_TYPE || ',potcode =' ||
                                    ROW_CARD.POT_SELECT_CODE || '的记录';

                RAISE EXP_INVALID;

            END;

          END IF;

          --推荐人姓名                              REFERENCE

          ROW_CARD.REFERENCE := NVL(ROW_PROPOSER.INTRONAME, ' ');

          --推荐人证件号码                          HOLDER_ADDR_1

          ROW_CARD.HOLDER_ADDR_1 := NVL(ROW_PROPOSER.INTROID, ' ');

          --主管代码                                SUP_NAME

          ROW_CARD.SUP_NAME := '000';

          --联名卡参考信息及个人责任还款商务卡公司拼音                          EMBOSSER_NAME_2
          /*
          增加根据卡种的前三位701判断是否为个人责任还款商务卡，如果是个人责任还款商务卡，则将公司拼音写到EMBOSSER_NAME_2中，如果公司
          拼音为空，则抛异常。
          */
          v_step := 924;
          IF I_STATUS = 1 and checkIBCCorpCard(ROW_PROPOSER.CARDTYPE) THEN
            v_step := 925;
            BEGIN
              select t.embosser_name_2
                into ROW_EMBOSSER_NAME_2
                from s08s4_ibc_corpinfo t
               where (select s08F1_extandXMLParameterValue(d.FIELDSVALUE

                                                          ,
                                                           'RESULT/PARAMETER[NAME/text()="ORGID"]/VALUE') as ORGCODEOFCORP
                        from s08s1_proposerappend d
                       where

                       d.appid = ROW_APPREG.APPID) = t.orgcodeofcorp;
              ROW_CARD.EMBOSSER_NAME_2 := NVL(ROW_EMBOSSER_NAME_2, ' ');

            EXCEPTION

              WHEN NO_DATA_FOUND THEN

                V_OUTPUT_INVALID := '在个人还款商务卡组织机构表中查询不到对应组织机构信息';

                RAISE EXP_INVALID;
            END;
          ELSE
            ROW_CARD.EMBOSSER_NAME_2 := NVL(ROW_PROPOSER.Relcorpcredit, ' ');
          END IF;

          --************判断是否南航卡 2009-09-29 谢凤玲，（目前情况：个人还款商务卡无南航卡，若个人还款商务卡有南航卡，需做相应处理）
          v_step := 510;

          V_CORPID := NULL;

          V_CORPID := S08F1_CHECK_LMKCARD(ROW_PROPOSER.CARDTYPE);

          v_step := 520;

          IF V_CORPID IS NOT NULL --是南航卡

           THEN

            v_step := 530;

            V_MEMBERINFO := S08F1_GET_MEMBERINFO(ROW_PROPOSER.APPID,
                                                 ROW_PROPOSER.INPUTSEQ);

            v_step := 540;

            XML_MEMBERINFO := XMLTYPE(V_MEMBERINFO);

            v_step := 550;

            SELECT EXTRACTVALUE(XML_MEMBERINFO, '/RESPONSE/RESULT/CODE')

              INTO V_CODE

              FROM DUAL;

            IF V_CODE IS NOT NULL AND V_CODE = '000000'

             THEN

              v_step := 560;

              SELECT EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/MEMBERID'),
                     EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/DOWNFLAG'),
                     EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/DOWNDATE'),
                     EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/UPLOADDATE'),
                     EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/CONTRASTCODE'),
                     EXTRACTVALUE(XML_MEMBERINFO,
                                  '/RESPONSE/RESULT/CONTRASTDESC')

                INTO V_MEMBERID, --会员号
                     V_DOWNFLAG, --下发标志
                     V_DOWNDATE, --下发日期
                     V_UPLOADDATE, --反馈日期
                     V_CONTRASTCODE, --比对结果代码
                     V_CONTRASTDESC --比对结果描述

                FROM DUAL;

              v_step := 570;

              V_MEMBER_RESULT := S08F1_MEMBER_PROCESS(V_DOWNFLAG,
                                                      V_DOWNDATE,
                                                      V_UPLOADDATE,
                                                      V_CONTRASTCODE,
                                                      I_DATE);

              v_step := 580;

            ELSE
              --在会员信息表找不到的,向会员信息表插入数据,不上送主机，在待开卡状态等候

              v_step := 590;

              V_MEMBER_RESULT := '3';

            END IF;
            v_step := 600;
            IF V_MEMBER_RESULT = '0' --0 正常开卡，将会员号更新到申请人表和开卡表，将会员信息表删除标志位置为1；

             THEN

              v_step                   := 610;
              ROW_CARD.EMBOSSER_NAME_2 := V_MEMBERID;

            ELSIF V_MEMBER_RESULT = '1' --1 反馈的会员信息有问题，进入开卡失败队列；

             THEN

              v_step           := 620;
              V_OUTPUT_INVALID := '反馈的会员信息有问题';
              RAISE EXP_INVALID;

            ELSIF V_MEMBER_RESULT = '2' --馈会员信息超时，开卡失败

             THEN
              v_step           := 630;
              V_OUTPUT_INVALID := '反馈会员信息超时';
              RAISE EXP_INVALID;

            ELSE
              --不上送主机，在待开卡状态等候

              RAISE WAIT_MEMBERID;

            END IF;

          END IF;

          --************************判断是否南航卡 2009-09-29 谢凤玲

          --主卡帐户号                              SPOUSE_FIRST_NAME

          v_step := 310;

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.SPOUSE_FIRST_NAME := '0000000000000000';

          ELSIF I_STATUS = 4 THEN
            --附卡单申

            ROW_CARD.SPOUSE_FIRST_NAME := cardno_to_accno(NVL(ROW_PROPOSER.OLDCARDNBR,
                                                              '0000000000000000'));

          ELSIF I_STATUS = 5 THEN
            --主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.SPOUSE_FIRST_NAME := '0000000000000000';

          ELSE

            ROW_CARD.SPOUSE_FIRST_NAME := '0000000000000000';

          END IF;

          --主卡持卡人证件类别                      P_RACE

          v_step := 320;

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.P_RACE := ' ';

          ELSIF I_STATUS = 4 THEN
            --附卡单申

            ROW_CARD.P_RACE := ' ';

          ELSIF I_STATUS = 1 THEN
            --主卡

            ROW_CARD.P_RACE := ' ';

          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN
            --附卡  或者  主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.P_RACE := NVL(ROW_PROPOSER_MAIN.IDTYPE, ' ');

          END IF;

          --主持卡人证件号                          P_CO_OWNER

          v_step := 330;

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.P_CO_OWNER := ' ';

          ELSIF I_STATUS = 4 THEN
            --附卡单申

            v_step := 340;

            SELECT EXTRACTVALUE(XML_MAIN, '/RESPONSE/RESULT/IDNBR')

              INTO ROW_CARD.P_CO_OWNER

              FROM DUAL;

            ROW_CARD.P_CO_OWNER := NVL(ROW_CARD.P_CO_OWNER, ' ');

          ELSIF I_STATUS = 1 THEN
            --主卡

            ROW_CARD.P_CO_OWNER := ' ';

          ELSIF I_STATUS = 3 OR I_STATUS = 5 THEN
            --附卡 或者  主卡开卡成功，对应附卡为附卡单申类型

            ROW_CARD.P_CO_OWNER := NVL(ROW_PROPOSER_MAIN.ID, ' ');

          END IF;

          --公司代码                                LANDLORD_MORTGAGE

          --部门代码                                PREV_SUP_NAME

          v_step := 350;

          IF I_STATUS = 2 THEN
            --商务卡

            ROW_CARD.LANDLORD_MORTGAGE := NVL(ROW_ORG.ORGANISEID, ' ');

            ROW_CARD.PREV_SUP_NAME := NVL(ROW_PROPOSER.DEPNBR, ' ');

          ELSE

            ROW_CARD.LANDLORD_MORTGAGE := ' ';

            ROW_CARD.PREV_SUP_NAME := ' ';

          END IF;

          --担保人姓名                              ASSURE_NAME

          ROW_CARD.ASSURE_NAME := NVL(ROW_PROPOSER.ASSURENAME, ' ');

          --内部客户号码                            CUST_NBR_16

          v_step := 360;

          IF XML_CUST IS NOT NULL THEN

            v_step := 370;
            -- 林辛 ： 2008-10-15 提取客户档中间的简称，检查简称是否一致，如果不一致,则拒绝上送主机系统。
            SELECT EXTRACTVALUE(XML_CUST, '/RESPONSE/RESULT/ACCT_NBR'),
                   EXTRACTVALUE(XML_CUST, '/RESPONSE/RESULT/SHORT_NAME')
              INTO ROW_CARD.CUST_NBR_16, V_CUST_SHOT_NAME
              FROM DUAL;

            IF (I_STATUS = 1 -- 仅仅判别个人卡主卡
               and V_CUST_SHOT_NAME != ROW_CARD.SH_NAME) THEN
              V_OUTPUT_INVALID := '同一证件 CardLink客户姓名:[' ||
                                  V_CUST_SHOT_NAME || '] 和 申请人姓名[' ||
                                  ROW_CARD.SH_NAME ||
                                  ']不一致，建议维护 CardLink客户姓名';
              RAISE EXP_INVALID;
            END IF;

            ROW_CARD.CUST_NBR_16 := NVL(ROW_CARD.CUST_NBR_16,
                                        '0000000000000000');

          ELSE

            ROW_CARD.CUST_NBR_16 := '0000000000000000';

          END IF;

          --主附同申附卡张数                        COCARD_CNT

          ROW_CARD.COCARD_CNT := NVL(ROW_PROPOSER.ADDCNT, 0);

          --时间戳（对应当前业务时间精确到时分秒）              STAMP

          /* SELECT T.CURRDATE
          INTO ROW_CARD.STAMP
          FROM S08SYSPARM T
          WHERE T.INO = '000000000';*/

          SELECT TO_DATE(TO_CHAR(i_date, 'yyyy-mm-dd ') ||
                         TO_CHAR(SYSDATE, 'hh24:mi:ss'),
                         'yyyy-mm-dd  hh24:mi:ss')
            INTO ROW_CARD.STAMP
            FROM dual;

          --备注                                    FILLER

          ROW_CARD.FILLER := ' ';

          --客户原永久额度                          CUST_CP_OLD

          v_step := 380;

          SELECT EXTRACTVALUE(XML_CUST, '/RESPONSE/RESULT/CRLIMIT_PERM')

            INTO ROW_CARD.CUST_CP_OLD

            FROM DUAL;

          ROW_CARD.CUST_CP_OLD := NVL(ROW_CARD.CUST_CP_OLD, 0);

          --账单日                                  BILLING_CYCLE
          v_step := 385;
          --                             ROW_CARD.BILLING_CYCLE := 0;
          -- 生成账单日过程合成到APS_TO_ICS

          IF I_STATUS = 2 THEN
            --商务卡
            select S08F1_CYCLERULE(ROW_CARD.APP_TYPE,
                                   ROW_CARD.race,
                                   ROW_CARD.LANDLORD_MORTGAGE,
                                   i_date)
              into ROW_CARD.BILLING_CYCLE
              from dual;
          else
            select S08F1_CYCLERULE(ROW_CARD.APP_TYPE,
                                   ROW_CARD.race,
                                   ROW_CARD.co_owner,
                                   i_date)
              into ROW_CARD.BILLING_CYCLE
              from dual;
          end if;

          --caoyy 2009-11-27 临额改造重新定义取值逻辑
          --如果是商务卡【客户原永久额度】 = 单位人民币信用额度
          IF I_STATUS = 2 THEN

            ROW_CARD.CUST_CP_OLD := ROW_CARD.CREDIT_LINE;

            --如果【审批额度】>=【客户原永久额度】
            --caoyy 20100125 增加【审批额度】=【客户原永久额度】的处理
          ELSIF ROW_CARD.CREDIT_LIMI >= ROW_CARD.CUST_CP_OLD Then
            v_step := 395;

            ROW_CARD.CUST_CP_OLD := ROW_CARD.CREDIT_LIMI;

            ROW_CARD.CREDIT_LINE := ROW_CARD.CREDIT_LIMI;

            --如果【审批额度】<【客户原永久额度】
          ELSIF ROW_CARD.CREDIT_LIMI < ROW_CARD.CUST_CP_OLD THEN
            v_step := 397;

            ROW_CARD.CREDIT_LINE := ROW_CARD.CUST_CP_OLD;

          END IF;
          --zhangqun 20100304 增加ECIF号 begin
          ROW_CARD.ECIF_CUSTNBR := ROW_PROPOSER.ECIF_CUSTNBR;
          --zhangqun 20100304 增加ECIF号 end

          --sunxl 2011-03-23 根据输入卡号确定字段卡号标识
          --Y为自选卡号，N非自选卡号 version_201105

          IF ROW_PROPOSER.SELECT_NUM IS NOT NULL AND
             LENGTH(ROW_PROPOSER.SELECT_NUM) = 16 THEN

            ROW_CARD.SELECT_FLAG := 'Y';

            --sunxl 2010-12-27 添加自选卡号

            ROW_CARD.SELECT_NUM := ROW_PROPOSER.SELECT_NUM;

          ELSE

            ROW_CARD.SELECT_FLAG := 'N';

            ROW_CARD.SELECT_NUM := '';

          END IF;

          /*
                    --人民币信用额度CREDIT_LINE、审批额度CREDIT_LIMI、原永久额度CUST_CP_OLD

                    --如果是已有卡，审批额度大于人民币信用额度，并且大于原永久额度，那么以审批额度为准

                    --IF ROW_APPREG.APPTYPE = '06' THEN

                    v_step := 390;

                    IF ROW_CARD.CREDIT_LIMI > ROW_CARD.CREDIT_LINE
                    THEN

                      IF ROW_CARD.CREDIT_LIMI > ROW_CARD.CUST_CP_OLD
                      THEN

                        ROW_CARD.CREDIT_LINE := ROW_CARD.CREDIT_LIMI;

                        ROW_CARD.CUST_CP_OLD := ROW_CARD.CREDIT_LIMI;

                      ELSE

                        ROW_CARD.CREDIT_LINE := ROW_CARD.CUST_CP_OLD;

                      END IF;

                    ELSE

                      IF ROW_CARD.CREDIT_LINE > ROW_CARD.CUST_CP_OLD
                      THEN

                        ROW_CARD.CUST_CP_OLD := ROW_CARD.CREDIT_LINE;

                      ELSE

                        ROW_CARD.CREDIT_LINE := ROW_CARD.CUST_CP_OLD;

                      END IF;

                    END IF;
          */
          --非空的校验检查

          v_step := 400;

          V_OUTPUT_INVALID := NULL;

          V_OUTPUT_INVALID := S08F1_APSTOICS_NOTNULL(ROW_CARD);

          IF V_OUTPUT_INVALID IS NOT NULL THEN

            RAISE EXP_INVALID;

          END IF;

          --插入数据到制卡信息表

          v_step := 410;

          INSERT INTO S08S1_CREATEAPPCARD_URGENT

            (

             APP_NBR,

             SEQ,

             MAINT_ORG,

             MAINT_TYPE,

             APP_TYPE,

             MAINT_JUL,

             MAINT_TIME,

             TERMINAL_ID,

             SIGNON_NAME,

             NAME_LINE_1,

             SH_NAME,

             NAME_LINE_2,

             HOME_PHONE,

             CO_PHONE,

             ADDR_LINE_1,

             ADDR_LINE_2,

             CITY,

             CENSUS,

             STATE_P,

             STATE_S,

             ZIP_CODE,

             RACE,

             CO_OWNER,

             CREDIT_LINE,

             BIRTH_DATE,

             EMPLOYER,

             WORK_PHONE,

             CO_EMPLOYER,

             CO_WORK_PHONE,

             BILLING_CYCLE,

             MEMO_1,

             MEMO_2,

             EU_SURN,

             EU_TITLE,

             EU_SEX,

             HOME_OWNER,

             PER_OF_RES,

             ACORN_CODE,

             MARITAL_STATUS,

             NBR_OF_DEPS,

             OCCPN_CODE,

             PER_OCCPN,

             CUSTOMER_CLASS,

             EMPLOYER_CODE,

             OCCPN_TITLE,

             ADDL_ADDR_1,

             ADDL_ADDR_2,

             ADDL_ADDR_3,

             ADDL_ZIP,

             EMAIL,

             ADDL_USAGE_6,

             ADDL_USAGE_7,

             ADDL_USAGE_8,

             INCOME,

             MOTHER,

             ALPHA_KEY_1,

             ALPHA_KEY_2,

             CREDIT_LIMI,

             CREDIT_LIMI_USD,

             ACH_FLAG,

             ACH_BANK,

             ACH_ACCT,

             ACH_FLAG_U,

             ACH_BANK_U,

             ACH_ACCT_U,

             OWNERSHIP_FLAG,

             COLLATERAL_CODE,

             USER_CODE_1,

             PYMT_FLAG,

             PYMT_FLAG_U,

             DISPLAY_REQUEST,

             EMBOSSER_TYPE_1,

             EMBOSSER_RQTYPE_3,

             VERIFY_PASS_FLAG,

             VERIFY_PASS_AMT,

             POT_SELECT_CODE,

             POT_EXP_DATE,

             REFERENCE,

             HOLDER_ADDR_1,

             SUP_NAME,

             EMBOSSER_NAME_2,

             SPOUSE_FIRST_NAME,

             P_RACE,

             P_CO_OWNER,

             LANDLORD_MORTGAGE,

             PREV_SUP_NAME,

             ASSURE_NAME,

             CUST_NBR_16,

             COCARD_CNT,

             STAMP,

             CUST_CP_OLD,

             FILLER,

             CARDFEE_TYPE,

             CARDFEE_CODE,

             CARDFEE_EXP_DATE,

             SAMECORP, --caoyy 2009-11-27 捐款单位

             ECIF_CUSTNBR, --zhangqun 2010-03-04 ECIF内部客户号

             SELECT_FLAG, --2010-12-27  添加是否为自选卡号


             SELECT_NUM, --2010-12-27  自选卡卡号

             ACCTPRODFLAG,--账单

             PROFESSION,--职业

             PRO_CUSTOM,--其他职业

             ID_VALID_DATE--证件有效期
    --陶兴 version201404 新增 账单 职业 其他职业 证件有效期
             )

          VALUES

            (

             ROW_CARD.APP_NBR,

             ROW_CARD.SEQ,

             ROW_CARD.MAINT_ORG,

             ROW_CARD.MAINT_TYPE,

             ROW_CARD.APP_TYPE,

             ROW_CARD.MAINT_JUL,

             ROW_CARD.MAINT_TIME,

             ROW_CARD.TERMINAL_ID,

             ROW_CARD.SIGNON_NAME,

             ROW_CARD.NAME_LINE_1,

             ROW_CARD.SH_NAME,

             ROW_CARD.NAME_LINE_2,

             ROW_CARD.HOME_PHONE,

             ROW_CARD.CO_PHONE,

             ROW_CARD.ADDR_LINE_1,

             ROW_CARD.ADDR_LINE_2,

             ROW_CARD.CITY,

             ROW_CARD.CENSUS,

             ROW_CARD.STATE_P,

             ROW_CARD.STATE_S,

             ROW_CARD.ZIP_CODE,

             ROW_CARD.RACE,

             ROW_CARD.CO_OWNER,

             ROW_CARD.CREDIT_LINE,

             ROW_CARD.BIRTH_DATE,

             ROW_CARD.EMPLOYER,

             ROW_CARD.WORK_PHONE,

             ROW_CARD.CO_EMPLOYER,

             ROW_CARD.CO_WORK_PHONE,

             ROW_CARD.BILLING_CYCLE,

             ROW_CARD.MEMO_1,

             ROW_CARD.MEMO_2,

             ROW_CARD.EU_SURN,

             ROW_CARD.EU_TITLE,

             ROW_CARD.EU_SEX,

             ROW_CARD.HOME_OWNER,

             ROW_CARD.PER_OF_RES,

             ROW_CARD.ACORN_CODE,

             ROW_CARD.MARITAL_STATUS,

             ROW_CARD.NBR_OF_DEPS,

             ROW_CARD.OCCPN_CODE,

             ROW_CARD.PER_OCCPN,

             ROW_CARD.CUSTOMER_CLASS,

             ROW_CARD.EMPLOYER_CODE,

             ROW_CARD.OCCPN_TITLE,

             ROW_CARD.ADDL_ADDR_1,

             ROW_CARD.ADDL_ADDR_2,

             ROW_CARD.ADDL_ADDR_3,

             ROW_CARD.ADDL_ZIP,

             ROW_CARD.EMAIL,

             ROW_CARD.ADDL_USAGE_6,

             ROW_CARD.ADDL_USAGE_7,

             ROW_CARD.ADDL_USAGE_8,

             ROW_CARD.INCOME,

             ROW_CARD.MOTHER,

             ROW_CARD.ALPHA_KEY_1,

             ROW_CARD.ALPHA_KEY_2,

             ROW_CARD.CREDIT_LIMI,

             ROW_CARD.CREDIT_LIMI_USD,

             ROW_CARD.ACH_FLAG,

             ROW_CARD.ACH_BANK,

             ROW_CARD.ACH_ACCT,

             ROW_CARD.ACH_FLAG_U,

             ROW_CARD.ACH_BANK_U,

             ROW_CARD.ACH_ACCT_U,

             ROW_CARD.OWNERSHIP_FLAG,

             ROW_CARD.COLLATERAL_CODE,

             ROW_CARD.USER_CODE_1,

             ROW_CARD.PYMT_FLAG,

             ROW_CARD.PYMT_FLAG_U,

             ROW_CARD.DISPLAY_REQUEST,

             ROW_CARD.EMBOSSER_TYPE_1,

             ROW_CARD.EMBOSSER_RQTYPE_3,

             ROW_CARD.VERIFY_PASS_FLAG,

             ROW_CARD.VERIFY_PASS_AMT,

             ROW_CARD.POT_SELECT_CODE,

             ROW_CARD.POT_EXP_DATE,

             ROW_CARD.REFERENCE,

             ROW_CARD.HOLDER_ADDR_1,

             ROW_CARD.SUP_NAME,

             ROW_CARD.EMBOSSER_NAME_2,

             ROW_CARD.SPOUSE_FIRST_NAME,

             ROW_CARD.P_RACE,

             ROW_CARD.P_CO_OWNER,

             ROW_CARD.LANDLORD_MORTGAGE,

             ROW_CARD.PREV_SUP_NAME,

             ROW_CARD.ASSURE_NAME,

             ROW_CARD.CUST_NBR_16,

             ROW_CARD.COCARD_CNT,

             ROW_CARD.STAMP,

             ROW_CARD.CUST_CP_OLD,

             ROW_CARD.FILLER,

             ROW_CARD.CARDFEE_TYPE,

             ROW_CARD.CARDFEE_CODE,

             ROW_CARD.CARDFEE_EXP_DATE,

             ROW_CARD.SAMECORP, --caoyy 2009-11-27 捐款单位

             ROW_CARD.ECIF_CUSTNBR, --zhangqun 2010-03-04 ECIF内部客户号

             ROW_CARD.SELECT_FLAG, --2010-12-27  添加是否为自选卡号

             ROW_CARD.SELECT_NUM, --2010-12-27  自选卡卡号

             ROW_CARD.ACCTPRODFLAG,

             ROW_CARD.PROFESSION,

             ROW_CARD.PRO_CUSTOM,

             ROW_CARD.ID_VALID_DATE
--陶兴 version201404 新增 账单 职业 其他职业 证件有效期
             );

          v_step := 420;

          IF V_MEMBER_RESULT IS NOT NULL and V_MEMBER_RESULT IN ('0') THEN
            --增加南航卡的处理  2009-09-29 谢凤玲

            v_step := S08F1_UPDATE_MEMBER_RELATEINFO(ROW_PROPOSER,
                                                     V_MEMBERID,
                                                     V_CONTRASTDESC,
                                                     I_DATE,
                                                     V_CORPID,
                                                     V_MEMBER_RESULT,
                                                     ROW_CARD.APP_TYPE);

          END IF;

          -----异常处理------------

        EXCEPTION

          WHEN EXP_INVALID THEN

            --存在非法字段

            IF CUR_PROPOSER%ISOPEN THEN

              CLOSE CUR_PROPOSER;

            END IF;

            --将同申请件编号的所有商务卡或者主附卡都回滚

            ROLLBACK;

            v_step    := 430;
            V_H_ERROR := '同申请书其它件存在非法字段！';

            IF V_MEMBER_RESULT IS NOT NULL and
               V_MEMBER_RESULT IN ('1', '2') THEN
              --增加南航卡的处理  2009-09-29 谢凤玲

              v_step    := S08F1_UPDATE_MEMBER_RELATEINFO(ROW_PROPOSER,
                                                          V_MEMBERID,
                                                          V_CONTRASTDESC,
                                                          I_DATE,
                                                          V_CORPID,
                                                          V_MEMBER_RESULT,
                                                          ROW_CARD.APP_TYPE);
              V_H_ERROR := '同申请书其它件' || V_OUTPUT_INVALID;

            END IF;

            --将校验出错信息写入到制卡出错日志表
            INSERT INTO S08S1_CREATEAPPCARD_ERRORLOG
              (APP_NBR, SEQ, SQLCODE, SQLERRM, STAMP)

            VALUES
              (ROW_PROPOSER.APPID,
               ROW_PROPOSER.INPUTSEQ,
               '-1',
               'Step=' || v_step || '：' || V_OUTPUT_INVALID,
               i_date);

            --存在非法字段，将检查非法信息写入申请人表的错误原因

            v_step := 440;

            UPDATE S08S1_PROPOSER T
               SET T.H_ERROR = V_OUTPUT_INVALID,

                   T.STAMP = i_date, --xiefengling 2008-07-30

                   T.h_carddate = i_date, --谢凤玲 2008-11-03 　本申请人检验不通过的，上送主机失败的添加：开卡日期、错误码'99'

                   T.h_retcode = '99'

             WHERE T.APPID = ROW_PROPOSER.APPID
               AND T.INPUTSEQ = ROW_PROPOSER.INPUTSEQ;

            v_step := 450;

            UPDATE S08S1_PROPOSER T
               SET T.H_ERROR = V_H_ERROR,

                   T.STAMP = i_date, --xiefengling 2008-07-30

                   T.h_carddate = i_date, --谢凤玲 2008-11-03 同申请书其它件存在非法字段，上送主机失败的添加：开卡日期、错误码'98'

                   T.h_retcode = '98'

             WHERE T.APPID = ROW_PROPOSER.APPID
               AND T.INPUTSEQ <> ROW_PROPOSER.INPUTSEQ;

            --实时流转到质检队列  sunxl  2011-02-25 添加检查失败申请件流转到质检队列 version201105   BEGIN

            BEGIN
              v_step := 2011;
              SELECT 1
                INTO f_check
                FROM dual
               WHERE not EXISTS (SELECT 1
                        FROM S08S1_QUALITYA
                       WHERE appid = ROW_PROPOSER.APPID);
            EXCEPTION
              WHEN no_data_found THEN
                NULL;
            END;

            if f_check = 1 then

              INSERT INTO S08S1_QUALITYA
                (APPID,
                 NAME,
                 ID,
                 APPTYPE,
                 START_DATE,
                 OPERNAME,
                 OPERID,
                 H_ERROR,
                 Q_FLAG,
                 Q_STATUS,
                 Q_SORT,
                 A_ESPECIAL,
                 H_RETCODE,
                 A_CREDIT_RMB,
                 ORG,
                 OPER)
              values
                (ROW_PROPOSER.APPID,
                 ROW_PROPOSER.Name,
                 ROW_PROPOSER.Id,
                 ROW_APPREG.Apptype,
                 i_date,
                 ROW_APPREG.Opername,
                 ROW_APPREG.OPERID,
                 V_OUTPUT_INVALID,
                 1,
                 2,
                 4,
                 ROW_PROPOSER.a_Especial,
                 '99',
                 ROW_PROPOSER.a_Credit_Rmb,
                 ROW_APPREG.Org,
                 ROW_APPREG.Org);

            end if;

            --------------------------------END-------------------------------------------

            --存在非法字段，将工作流流转到开卡失败的状态

            N_INPUT_ENTRY_ID := ROW_APPREG.ENTRY_ID;

            V_INPUT_OLD_STATUS := 'makecarding';

            V_INPUT_STATUS := 'failed';

            I_INPUT_STEPID := I_STEP_APPROVED;

            I_INPUT_ACTIONID := 214;

            -- modified by lidl for v_201205, 2012-03-02
            -------------------------------------------- start
            --V_INPUT_OWNER := ROW_APPREG.ORG;
            v_step := 451;

            select count(1)
              into V_OWNER_CNT
              from s08s1_oshistorystep t
             where t.action_id = '201'
               and t.entry_id = ROW_APPREG.ENTRY_ID;

            if V_OWNER_CNT >= 1 then
              select t2.owner
                into V_INPUT_OWNER
                from (select *
                        from s08s1_oshistorystep t
                       where t.action_id = '201'
                         and t.entry_id = ROW_APPREG.ENTRY_ID
                       order by t.finish_date desc) t2
               where rownum = 1;
            else
              V_INPUT_OWNER := null;
            end if;

            if V_INPUT_OWNER is null then
              V_INPUT_OWNER := ROW_APPREG.ORG;
            end if;
            -------------------------------------------- end

            V_INPUT_CALLER := '010000000';

            --流程流转

            v_step := 460;

            V_OUTPUT := S08F1_OS_DOACTION(

                                          N_INPUT_ENTRY_ID,

                                          V_INPUT_OLD_STATUS,

                                          V_INPUT_STATUS,

                                          I_INPUT_STEPID,

                                          I_INPUT_ACTIONID,

                                          V_INPUT_OWNER,

                                          V_INPUT_CALLER

                                          );

            COMMIT;

            -- added by lidl for v_201205, 2012-03-01
            -------------------------------------------- start
            v_step := 461;

            INSERT INTO S08S1_APPROVED_FAILED
              (APPID,
               ORG,
               STATUS, --0待处理，1已处理
               FAILED_TYPE, --0开卡失败，1建档失败
               BUI_DATE,
               OPERATOR,
               START_TIME,
               STAMP)
              SELECT T.APPID,
                     T.ORG,
                     0,
                     0,
                     currentstamp,
                     V_INPUT_OWNER,
                     currentstamp,
                     currentstamp
                FROM S08S1_APPREGISTER T
               WHERE T.APPID = ROW_PROPOSER.APPID
                 and not exists
               (select 1
                        from S08S1_APPROVED_FAILED t2
                       where t2.appid = ROW_PROPOSER.APPID
                         and t2.stamp = currentstamp);
            -------------------------------------------- end

            --退出同申请件编号的循环

            RAISE EXP;

          WHEN EXP_NONEEDCARD THEN

            --已经开卡成功，不需要再进行开卡

            NULL;

          ---南航卡 2009-09-29 谢凤玲  START
          WHEN WAIT_MEMBERID THEN
            -- 南航卡 不上送主机，在待开卡状态等候

            IF CUR_PROPOSER%ISOPEN THEN
              CLOSE CUR_PROPOSER;
            END IF;

            --将同申请件编号的所有商务卡或者主附卡都回滚
            ROLLBACK;

            --在会员信息表找不到的,向会员信息表插入数据
            v_step := 470;

            IF V_MEMBER_RESULT IS NOT NULL and V_MEMBER_RESULT IN ('3') THEN

              v_step := S08F1_UPDATE_MEMBER_RELATEINFO(ROW_PROPOSER,
                                                       V_MEMBERID,
                                                       V_CONTRASTDESC,
                                                       I_DATE,
                                                       V_CORPID,
                                                       V_MEMBER_RESULT,
                                                       ROW_APPREG.APPTYPE);

            END IF;
            COMMIT;
            --退出同申请件编号的循环
            RAISE EXP;

          ---南航卡 END

          WHEN OTHERS THEN

            IF CUR_PROPOSER%ISOPEN THEN

              CLOSE CUR_PROPOSER;

            END IF;

            --将同申请件编号的所有商务卡或者主附卡都回滚

            ROLLBACK;

            --将错误信息记录到错误信息表

            V_ERR_CODE := SQLCODE;

            V_ERR_MSG := SQLERRM;

            INSERT INTO S08S1_CREATEAPPCARD_ERRORLOG
              (APP_NBR, SEQ, SQLCODE, SQLERRM, STAMP)

            VALUES
              (ROW_PROPOSER.APPID,
               ROW_PROPOSER.INPUTSEQ,
               V_ERR_CODE,
               'Step=' || v_step || '：' || V_ERR_MSG,
               i_date);

            COMMIT;

            --退出同申请件编号的循环

            RAISE EXP;

        END;

      END LOOP;

      CLOSE CUR_PROPOSER;

      COMMIT;

      -----异常处理------------

    EXCEPTION

      WHEN OTHERS THEN

        NULL;

    END;

  END LOOP;

  CLOSE CUR_APPCARD;

  /*BEGIN

    v_step := 480;

    SELECT COUNT(*)

    INTO v_num

    FROM s08s1_createappcard_errorlog

    WHERE stamp = i_date;

    IF v_num > 0
    THEN

      RAISE e_error;

    END IF;

  EXCEPTION

    WHEN no_data_found THEN

      NULL;

  END;*/

  o_return := 0;

  o_msg := '执行过程s08p1_day_apstoics_urgent成功';

EXCEPTION

  /* WHEN e_error THEN
  o_msg := '部分申请件出错，请查看表s08s1_createappcard_errorlog获取出错信息！';
  IF v_num > 100
  THEN

    o_return := -1;
    o_msg    := '部分申请件出错,error count number > 100 ，请查看表s08s1_createappcard_errorlog获取出错信息！';
  END IF;*/

  WHEN OTHERS THEN

    o_return := -1;

    o_msg := '执行s08p1_day_apstoics_urgent出错：Step = ' || v_step ||
             ', Error= ' || SQLCODE || ', ' || SQLERRM(SQLCODE);

END s08p1_day_apstoics_urgent;
/
