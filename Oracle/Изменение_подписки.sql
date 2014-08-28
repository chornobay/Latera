-- Изменение подписки на тарифы
DECLARE 
  dt_D_END            SI_SUBJ_GOODS.D_END%TYPE := SYSDATE - 1/24/60/60;
  dt_D_BEGIN          SI_SUBJ_GOODS.D_BEGIN%TYPE:= SYSDATE;
  num_N_SUBJ_GOOD_ID  SI_SUBJ_GOODS.N_SUBJ_GOOD_ID%TYPE;
BEGIN
  FOR rc_Good IN (
                  SELECT UG.N_SUBJ_GOOD_ID,
                         UG.N_GOOD_ID,
                         UG.N_SUBJECT_ID,
                         UG.N_ACCOUNT_ID,
                         UG.N_PAY_DAY,
                         UG.N_LINE_NO,
                         UG.N_QUANT,
                         UG.N_UNIT_ID,
                         UG.N_DOC_ID,
                         UG.N_PAR_SUBJ_GOOD_ID,
                         UG.D_END,
                         UG.D_INVOICE_END,
                         UG.N_INVOICE_ID,
                         OS.N_MAIN_OBJECT_ID
                  FROM SI_V_USER_GOODS    UG,
                       SI_V_OBJECTS_SPEC  OS
                  WHERE UG.N_OBJECT_ID    = OS.N_OBJECT_ID
                  AND   UG.C_FL_CLOSED    = 'N' 
                  AND   UG.N_PAR_SUBJ_GOOD_ID IS NULL
                  AND   OS.N_GOOD_ID      = 40249001
                  --AND   UG.N_SUBJECT_ID   = 595307091
                 )
  LOOP
  
    SI_USERS_PKG.SI_USER_GOODS_CLOSE(
      num_N_SUBJ_GOOD_ID                  => rc_Good.N_SUBJ_GOOD_ID,
      dt_D_END                            => dt_D_END);
      
    SI_USERS_PKG.CHANGE_INVOICE_PERIOD(
      num_N_DOC_ID                        => rc_Good.N_INVOICE_ID,
      dt_D_OPER                           => dt_D_END);
    
  
    num_N_SUBJ_GOOD_ID := NULL;
  
    SI_USERS_PKG.SI_USER_GOODS_PUT(
      num_N_SUBJ_GOOD_ID                  => num_N_SUBJ_GOOD_ID,
      num_N_GOOD_ID                       => rc_Good.N_GOOD_ID,
      num_N_SUBJECT_ID                    => rc_Good.N_SUBJECT_ID,
      num_N_ACCOUNT_ID                    => rc_Good.N_ACCOUNT_ID,
      num_N_OBJECT_ID                     => rc_Good.N_MAIN_OBJECT_ID,
      num_N_PAY_DAY                       => rc_Good.N_PAY_DAY,
      num_N_LINE_NO                       => rc_Good.N_LINE_NO,
      num_N_QUANT                         => rc_Good.N_QUANT,
      num_N_UNIT_ID                       => rc_Good.N_UNIT_ID,
      num_N_DOC_ID                        => rc_Good.N_DOC_ID,
      num_N_PAR_SUBJ_GOOD_ID              => rc_Good.N_PAR_SUBJ_GOOD_ID,
      dt_D_BEGIN                          => dt_D_BEGIN,
      dt_D_END                            => rc_Good.D_END,
      dt_D_INVOICE_END                    => rc_Good.D_INVOICE_END);
    
       
   END LOOP; 
END;

