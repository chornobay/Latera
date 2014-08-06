-- Отчет по обешанному платежу
SELECT DS.VC_ACCOUNT_CODE,     -- Лицевой счет
       O.N_SUM,                -- Сумма
       SI_REF_PKG_S.GET_NAME_BY_ID(O.N_CURRENCY_ID) VC_CURRENCY_NAME, -- Валюта
       O.D_BEGIN,              -- Дата начала
       O.D_END,                -- Дата окончания
       D.VC_CREATOR_CODE,      -- Код создателя
       D.VC_CREATOR_NAME,      -- Наименование создателя
       SV.VC_SUBJ_GROUP_NAME,  -- Группа абонента
       AO.VC_CLOSING_REASON    -- Причина закрытия ОП
FROM SD_V_OVERDRAFTS                                              O,
     SD_V_DOCUMENTS                                               D,
     SI_V_DOC_SUBJECTS                                            DS, 
     SI_V_USERS                                                   SV,
     TABLE(SD_OVERDRAFTS_PKG_S.GET_ACCOUNT_OVERDRAFTS_LIST(
            /* num_N_ACCOUNT_ID => */ DS.N_ACCOUNT_ID,
            /* dt_D_BEGIN       => */ O.D_BEGIN,
            /* dt_D_END         => */ O.D_END))                   AO
WHERE O.N_DOC_TYPE_ID       = SYS_CONTEXT('CONST', 'DOC_TYPE_Overdraft')
AND   O.N_ISSUE_REASON_ID   = SYS_CONTEXT('CONST', 'OVERDRAFT_PromisedPayment')
AND   O.D_BEGIN            >= TO_DATE('01.07.2014 00:00:00','DD.MM.YYYY HH24:MI:SS')   -- Дата начала ОП >= определенной даты
AND   O.D_END              <= TO_DATE('31.07.2014 23:59:59','DD.MM.YYYY HH24:MI:SS')   -- Дата конца ОП <= определенной даты
AND   O.N_OVERDRAFT_ID      = AO.N_OVERDRAFT_ID
AND   D.N_DOC_ID            = O.N_DOC_ID
AND   D.N_DOC_STATE_ID      = SYS_CONTEXT('CONST', 'DOC_STATE_Actual')
AND   DS.N_DOC_ID           = D.N_DOC_ID
AND   DS.N_DOC_ID           = O.N_DOC_ID
AND   DS.N_DOC_ROLE_ID      = SYS_CONTEXT('CONST', 'SUBJ_ROLE_Receiver')
AND   SV.N_SUBJECT_ID       = DS.N_SUBJECT_ID;
