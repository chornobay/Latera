WITH 
  Accounts AS (
    SELECT N_ACCOUNT_ID
    FROM SI_SUBJ_ACCOUNTS
    WHERE N_SUBJECT_ID    = :n_subject_id
    AND N_ACCOUNT_TYPE_ID = SYS_CONTEXT('CONST', 'ACC_TYPE_Personal')
    AND C_ACTIVE          = 'Y'),
  IncludeBreaks AS (
    SELECT CASE 
             WHEN (D.D_BEGIN - LAG (D.D_END, 1) OVER (ORDER BY D.D_END, D.D_BEGIN)) * 24 >= 48 
               THEN '1'
             ELSE '0'
           END Breaks
    FROM Accounts A,
    TABLE (
            SI_USERS_PKG_S.USERS_ACC_DETALIZATION(
                                                  /* dt_D_BEGIN             => */ TO_DATE('01.07.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS'),
                                                  /* dt_D_END               => */ TO_DATE('05.08.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS'),
                                                  /* num_N_ACCOUNT_ID       => */ A.N_ACCOUNT_ID,
                                                  /* b_Payment              => */ 0,
                                                  /* b_WriteOff             => */ 1,
                                                  /* b_Overdraft            => */ 0,
                                                  /* vch_VC_TRANSACTION_ID  => */ NULL)
          ) D
    WHERE D.C_FL_TOTALS = 'N'
    AND   D.N_GOOD_ID IN (
                            SELECT PO_P.N_GOOD_ID
                            FROM SD_V_INVOICES_C        IC,
                                 SD_V_PRICE_ORDERS_C    PO_P,
                                 SD_V_PRICE_ORDERS_C    PO_D
                            WHERE PO_P.N_PAR_LINE_ID IS NULL
                            AND   PO_D.N_PAR_LINE_ID      = PO_P.N_PRICE_ORDER_LINE_ID
                            AND   PO_D.N_GOOD_ID          = 40217401                   -- Доступ в Интернет
                            AND   IC.N_PRICE_ORDER_DOC_ID = PO_P.N_DOC_ID
                            AND   IC.N_DOC_ID             = D.N_DOC_ID
                            GROUP BY PO_P.N_GOOD_ID
                            UNION ALL
                            SELECT 139923101 N_GOOD_ID                                 -- Пауза
                            FROM DUAL
                         )
    ORDER BY D.D_BEGIN)
SELECT CASE
         WHEN SUM(Breaks) != 0 THEN '1'
         ELSE '0'
       END Breaks
FROM IncludeBreaks;
