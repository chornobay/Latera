WITH numbers AS ( 
  SELECT :begin_range + level - 1 AS VC_TEL
  FROM DUAL
  CONNECT BY :begin_range + level - 1 <= :end_range)
SELECT n.VC_TEL
FROM numbers n
WHERE NOT EXISTS ( 
                  SELECT 1
                  FROM SI_V_OBJ_ADDRESSES_SIMPLE_CUR OA
                  WHERE OA.N_ADDR_TYPE_ID   = SYS_CONTEXT('CONST', 'ADDR_TYPE_Telephone') -- Телефон
                  AND   OA.C_FL_ACTUAL      = 'Y'
                  AND  (SYSDATE BETWEEN OA.D_BEGIN AND NVL(OA.D_END, SYSDATE))
                  AND   OA.VC_CODE BETWEEN :begin_range AND :end_range
                  AND   OA.VC_CODE          = n.VC_TEL
                 )
ORDER BY 1; 
