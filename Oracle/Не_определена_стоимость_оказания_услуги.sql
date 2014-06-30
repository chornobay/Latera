SELECT SA.N_SUBJECT_ID,
       (SELECT VC_GOOD_STATE_NAME 
        FROM TABLE(SI_USERS_PKG_S.GET_USER_GOODS_STATES(
               num_N_USER_ID    => SA.N_SUBJECT_ID, -- Идентификатор абонента
               num_N_ACCOUNT_ID => SA.N_ACCOUNT_ID))
        WHERE N_GOOD_STATE_ID = 6114)  VG
FROM SI_V_SUBJ_ACCOUNTS                        SA
