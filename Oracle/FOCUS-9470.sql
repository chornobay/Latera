-- Перевыставление инвойсов
BEGIN 
  FOR rc_Invoice IN (
    SELECT IT.N_DOC_ID,
           IT.VC_CODE,
           IT.N_REASON_DOC_ID,
           SS.N_ACCOUNT_ID,
           SS.VC_SUBJ_NAME,
           MIN(IC.D_BEGIN)       D_BEGIN,
           MAX(IC.D_END)         D_END,
           GMT.N_SUBJ_GOOD_ID
    FROM SD_V_INVOICES_T          IT,
         SD_V_INVOICES_C          IC,
         SI_V_USER_CONTRACTS      UC,
         SI_V_DOC_SUBJECTS_SIMPLE SS,
         SD_V_GOOD_MOVES_T        GMT
    WHERE IT.N_DOC_STATE_ID      = SYS_CONTEXT('CONST', 'DOC_STATE_Actual')
    AND   IC.D_BEGIN            >= TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
    --AND   TRUNC(IT.D_BEGIN)      = TRUNC(TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')) 
    AND   IT.N_DOC_ID            = IC.N_DOC_ID
    AND   UC.N_DOC_ID            = IT.N_REASON_DOC_ID
    AND   UC.N_PARENT_DOC_ID IN ( 
                                  213702801         -- БД-14/1
                                  --50492601,          -- БД-13/2
                                  --50495001,          -- БД-13/6
                                  --50493201,          -- БД-13/3
                                  --50494401,          -- БД-13/5
                                  --50493801,          -- БД-13/4
                                  --50488201           -- БД-13/1
                                )
    AND    SS.N_DOC_ID           = IT.N_DOC_ID
    AND    SS.N_DOC_ROLE_ID      = SYS_CONTEXT('CONST', 'SUBJ_ROLE_Receiver')
--    AND    SS.N_SUBJECT_ID       = 63943501
    AND    GMT.N_DOC_ID          = IT.N_DOC_ID
    GROUP BY IT.N_DOC_ID, IT.VC_CODE, IT.N_REASON_DOC_ID, SS.N_ACCOUNT_ID, SS.VC_SUBJ_NAME, GMT.N_SUBJ_GOOD_ID
    ORDER BY D_BEGIN, N_ACCOUNT_ID)
  LOOP
    -- Аннулируем старый инвойс
    SD_INVOICES_PKG.CANCEL_CHARGE_LOG(
      num_N_CHARGE_LOG_ID                 => rc_Invoice.N_DOC_ID);
  
    DBMS_OUTPUT.put_line( 'Аннулированный инвойс ' || rc_Invoice.VC_CODE || ' по абоненту ' || rc_Invoice.VC_SUBJ_NAME );
    
    -- Подготавливаем инвойс для выставления
    SD_CHARGE_LOGS_RATING_PKG.FILL_AND_RATE_SERVICES(
      num_N_ACCOUNT_ID                    => rc_Invoice.N_ACCOUNT_ID,
      dt_D_OPER_BEGIN                     => rc_Invoice.D_BEGIN);
    
    -- Удаляем лишнее
    DELETE FROM TT_SERVICES
    WHERE  N_SUBSCRIPTION_ID NOT IN(
      SELECT N_SUBJ_GOOD_ID
      FROM   SI_SUBJ_GOODS
      WHERE  N_PAR_SUBJ_GOOD_ID = rc_Invoice.N_SUBJ_GOOD_ID
      UNION ALL
      SELECT rc_Invoice.N_SUBJ_GOOD_ID
      FROM   DUAL);
    
    -- Выставляем новый инвойс
    SD_CHARGE_LOGS_CHARGING_PKG.PROCESS_ACCOUNT(
      num_N_ACCOUNT_ID                    => rc_Invoice.N_ACCOUNT_ID,
      b_UseTTServices                     => 1,
      b_ClearTTServices                   => 0,
      dt_D_OPER                           => rc_Invoice.D_BEGIN);
     
  END LOOP;
END;
/
