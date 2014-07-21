-- Список оказанных услуг абонента.
-- %param num_N_USER_ID               Идентификатор абонента
-- %param dt_D_BEGIN                  Дата начала периода выборки
-- %param dt_D_END                    Дата окончания периода выборки
-- %param b_IncludeBreaks             Флаг включения перерывов в оказании услуг
-- %return Список оказанных услуг
FUNCTION USERS_BILLED_SERVS_LIST(
  num_N_USER_ID                       SI_SUBJECTS.N_SUBJECT_ID%TYPE,
  dt_D_BEGIN                          DATE := NULL,
  dt_D_END                            DATE := NULL,
  b_IncludeBreaks                     MAIN.BOOL := MAIN.b_FALSE)
RETURN BILLED_SERVS_LIST_TABLE_TYPE
PIPELINED;



-- Были ли перерывы в оказании услуг абоненту
SELECT CASE 
         WHEN EXISTS ( SELECT * 
                       FROM TABLE (SI_USERS_PKG_S.USERS_BILLED_SERVS_LIST(
                                   /* num_N_USER_ID    => */  50157001,
                                   /* dt_D_BEGIN       => */  TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS'),
                                   /* dt_D_END         => */  TO_DATE('20.07.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS'),
                                   /* b_IncludeBreaks  => */  1))
                       WHERE VC_GOOD_NAME IS NULL )
           THEN 'да'
           ELSE 'нет'
       END IncludeBreaks
FROM DUAL;


SELECT N_SUBJECT_ID
FROM SI_V_USERS


SELECT N_SUBJECT_ID 
FROM SI_V_USER_GOODS
