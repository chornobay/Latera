SELECT SI_SUBJECTS_PKG_S.IS_LOGIN_AND_PASS_CORRECT(
        /* vch_VC_LOGIN     */ UAB.VC_LOGIN,      
        /* vch_VC_PASS      */ :Password,
        /* num_N_SERVICE_ID */ UAB.N_SERVICE_ID) IS_LOGIN_AND_PASS_CORRECT    
FROM SS_V_USERS_APP_BINDS      UAB,
     SI_V_USER_ACCESS_SERVS    UAS
WHERE UAB.VC_LOGIN        = :Login
AND   UAB.N_SERVICE_ID    = 1105              -- Приложение Личный кабинет
AND   UAB.N_SUBJECT_ID    = UAS.N_USER_ID
AND   UAS.C_FL_ACTIVE     = 'Y'
AND   UAS.N_GOOD_ID       = 50297301;         --  Доступ в Интернет
