-- Массовая перетарификация услуг телефонии по определенным БД
-- Заявка #9689
-- Процесс перетарификации вызван перевыставленем всех инвойсов за июль
-- Применимо к версии базы 3.4.5

-- Изменяем состояние инвойсов на "В обработке" для перетарификации
DECLARE 
 rc_Line NUMBER;
BEGIN
 FOR rc_Line IN (
                  SELECT IT.N_DOC_ID
                  FROM SD_V_INVOICES_T      IT,
                       SD_V_INVOICES_C      IC,
                       SI_V_USER_CONTRACTS  UC
                  WHERE IT.D_BEGIN BETWEEN TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
                                       AND TO_DATE('31.07.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
                  AND   IT.N_DOC_STATE_ID    = SYS_CONTEXT('CONST', 'DOC_STATE_Executed')
                  AND   IC.N_DOC_ID          = IT.N_DOC_ID
                  AND   IC.N_PAR_LINE_ID IS NULL
                  AND   IC.N_GOOD_ID IN  (
                                          SELECT PO_P.N_GOOD_ID
                                          FROM SD_V_PRICE_ORDERS_C    PO_P,
                                               SD_V_PRICE_ORDERS_C    PO_D
                                          WHERE PO_P.N_PAR_LINE_ID IS NULL
                                          AND   PO_D.N_PAR_LINE_ID    = PO_P.N_PRICE_ORDER_LINE_ID
                                          AND   PO_D.N_GOOD_ID IN (40214701,
                                                                   40214501,
                                                                   50406701,
                                                                   50406501,
                                                                   40215701,
                                                                   40215501,
                                                                   40215201,
                                                                   40215001)
                                          GROUP BY PO_P.N_GOOD_ID
                                         )   
                  AND   UC.N_DOC_ID          = IT.N_REASON_DOC_ID
                  AND   UC.N_PARENT_DOC_ID IN ( 
                                               50492601,    -- БД-13/2 
                                               50494401     -- БД-13/5 
                                              )
                  GROUP BY IT.N_DOC_ID
                )
 LOOP
   -- Меняем состояние инвойсов на "В обработке"
   SD_DOCUMENTS_PKG.SD_DOCUMENTS_CHANGE_STATE(
     num_N_DOC_ID                   => rc_Line.N_DOC_ID,
     num_N_New_DOC_STATE_ID         => SYS_CONTEXT('CONST', 'DOC_STATE_Processing')); -- В обработке
 END LOOP;
END;
/
COMMIT;
/

-- Создаем временную таблицу
CREATE TABLE test_temp_table (cdr_id NUMBER);
/

-- Заполняем временную таблицу
INSERT INTO test_temp_table
                 SELECT CDR.N_CDR_ID
                 FROM EX_V_CDR               CDR
                 WHERE CDR.D_BEGIN           >= TO_DATE('01.07.2014 00:00:00','DD.MM.YYYY HH24:MI:SS')
                 AND   CDR.D_BEGIN           <= TO_DATE('31.07.2014 23:59:59','DD.MM.YYYY HH24:MI:SS')
                 AND   CDR.N_SUM_A IS NULL 
                 AND   CDR.N_SUM_B IS NULL
                 AND   CDR.N_CDR_TYPE_ID      = SYS_CONTEXT('CONST', 'CDR_TYPE_Phonecall')
                 ORDER BY CDR.N_CDR_ID;
/
COMMIT;
/

-- Перетарифицируем CDR
DECLARE
  b_Execute_Triggers MAIN.BOOL;
BEGIN
 -- Запоминаем признак работы триггеров
 b_Execute_Triggers := SS_AUDIT_PKG.gb_Execute_Triggers;
 -- Отключаем триггеры
 SS_AUDIT_PKG.gb_Execute_Triggers := MAIN.b_FALSE;

 FOR rc_CDR IN (
                SELECT cdr_id
                FROM test_temp_table
               )
 LOOP
   SS_CDR_PKG.EX_CALL_DATA_REC_CHG_STATE(
        num_N_CDR_ID       => rc_CDR.N_CDR_ID,
        num_N_CDR_STATE_ID => SS_CONSTANTS_PKG_S.CDR_Status_Finished,
        b_REDO_EVERYTHING  => MAIN.b_TRUE);

   COMMIT;

 END LOOP;
 
 -- Восстанавливаем состояние
 SS_AUDIT_PKG.gb_Execute_Triggers := b_Execute_Triggers;
END;
/

 -- Переводим инвойсы в состояние "Выполнен"
DECLARE 
 rc_Line NUMBER;
BEGIN
 FOR rc_Line IN (
                  SELECT IT.N_DOC_ID
                  FROM SD_V_INVOICES_T      IT,
                       SD_V_INVOICES_C      IC,
                       SI_V_USER_CONTRACTS  UC
                  WHERE IT.D_BEGIN BETWEEN TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
                                       AND TO_DATE('31.07.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
                  AND   IT.N_DOC_STATE_ID    = SYS_CONTEXT('CONST', 'DOC_STATE_Processing')
                  AND   IC.N_DOC_ID          = IT.N_DOC_ID
                  AND   IC.N_PAR_LINE_ID IS NULL
                  AND   IC.N_GOOD_ID IN  (
                                          SELECT PO_P.N_GOOD_ID
                                          FROM SD_V_PRICE_ORDERS_C    PO_P,
                                               SD_V_PRICE_ORDERS_C    PO_D
                                          WHERE PO_P.N_PAR_LINE_ID IS NULL
                                          AND   PO_D.N_PAR_LINE_ID    = PO_P.N_PRICE_ORDER_LINE_ID
                                          AND   PO_D.N_GOOD_ID IN (40214701,
                                                                   40214501,
                                                                   50406701,
                                                                   50406501,
                                                                   40215701,
                                                                   40215501,
                                                                   40215201,
                                                                   40215001)
                                          GROUP BY PO_P.N_GOOD_ID
                                         )   
                  AND   UC.N_DOC_ID          = IT.N_REASON_DOC_ID
                  AND   UC.N_PARENT_DOC_ID IN ( 
                                               50492601,    -- БД-13/2 
                                               50494401     -- БД-13/5 
                                              )
                  GROUP BY IT.N_DOC_ID
                )
 LOOP
    -- Change charge log state to executed.
    SD_INVOICES_PKG.EXECUTE_CHARGE_LOG(
      num_N_CHARGE_LOG_ID            => rc_Line.N_DOC_ID);
 END LOOP;
END;
/

-- Дропаем временную таблицу
DROP TABLE test_temp_table;
/
