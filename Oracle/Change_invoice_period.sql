DECLARE
  dt_D_OPER    SD_GOOD_MOVES.D_END%TYPE := TO_DATE('03.07.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS');
  n_Num        NUMBER := 0;
BEGIN
  FOR rc_Line IN (SELECT T.N_DOC_ID,
                         T.VC_NAME
                  FROM SD_V_INVOICES_T T
                  WHERE T.N_DOC_STATE_ID = SYS_CONTEXT('CONST', 'DOC_STATE_Actual')
                  --AND   T.N_DOC_ID       = 386427501
                  AND   T.D_BEGIN BETWEEN TO_DATE('01.06.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
                                      AND TO_DATE('02.06.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
                  ORDER BY T.D_BEGIN)
  LOOP
    SI_USERS_PKG.CHANGE_INVOICE_PERIOD(
      num_N_DOC_ID                     => rc_Line.N_DOC_ID,
      dt_D_OPER                        => dt_D_OPER);
    
    n_Num := n_Num + 1;
      
    DBMS_OUTPUT.put_line( '№ ' || n_Num || '. ' || rc_Line.VC_NAME );
    
  END LOOP;
END;
/
