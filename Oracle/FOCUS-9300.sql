-- Добавление необходимых домов
DECLARE
  num_N_REGION_ID   SR_REGIONS.N_REGION_ID%TYPE;
BEGIN
 FOR rc_Reg IN (
                -- Опеределяем недостающие дома
                WITH tt_regions AS (
                SELECT TT.VC_STREET, TT.N_INDEX, TT.VC_HOUSE,
                       SR3.N_REGION_ID,
                       ROW_NUMBER() OVER (PARTITION BY TT.VC_STREET, TT.N_INDEX, TT.VC_HOUSE ORDER BY SR3.N_REGION_ID) rn
                FROM SR_V_REGIONS                                        SR3,
                    ( SELECT TBR.VC_STREET,
                             TBR.VC_HOUSE,
                             TBR.N_INDEX
                      FROM TT_BS_REGIONS TBR
                      WHERE UPPER(TBR.VC_HOUSE) NOT IN (
                                        SELECT UPPER(SR2.VC_HOME)
                                        FROM SR_V_REGIONS SR1,
                                             SR_V_REGIONS SR2
                                        WHERE SR1.N_PAR_REGION_ID = 50409701   -- Оренбург
                                        AND   TBR.VC_STREET LIKE SR1.VC_CODE || '%'
                                        AND   SR1.N_REGION_ID     = SR2.N_PAR_REGION_ID
                                       )
                      GROUP BY TBR.VC_STREET, TBR.N_INDEX, TBR.VC_HOUSE ) TT
                WHERE TT.VC_STREET LIKE SR3.VC_CODE || '%'
                AND   SR3.N_PAR_REGION_ID = 50409701   -- Оренбург
                GROUP BY SR3.N_REGION_ID, TT.VC_STREET, TT.N_INDEX, TT.VC_HOUSE
                ORDER BY TT.VC_STREET)
                SELECT *
                FROM tt_regions
                WHERE rn = 1
               )
 LOOP
    
    num_N_REGION_ID := NULL;
 
    SR_REGIONS_PKG.SR_REGIONS_PUT(
      num_N_REGION_ID                     => num_N_REGION_ID,
      num_N_REGION_TYPE_ID                => 6027,
      num_N_PAR_REGION_ID                 => rc_Reg.N_REGION_ID,
      vch_VC_CODE                         => NULL,
      vch_VC_NAME                         => NULL,
      vch_VC_ENG_NAME                     => NULL,
      num_N_HIERARCHY_TYPE_ID             => SYS_CONTEXT('CONST', 'HIER_REG_TYPE_Federal'),
      num_N_BASE_REGION_ID                => NULL,
      num_N_PAR_BIND_REGION_ID            => NULL,
      num_N_REALTY_GOOD_ID                => 106,
      vch_VC_ZIP                          => rc_Reg.N_INDEX,
      vch_VC_HOME                         => rc_Reg.VC_HOUSE,
      vch_VC_BUILDING                     => NULL,
      vch_VC_CONSTRUCT                    => NULL,
      vch_VC_OWNERSHIP                    => NULL,
      vch_VC_CODE_EXT                     => NULL,
      b_UpdateSearchIndex                 => 1);
  
  END LOOP;
END;
/



SELECT *
FROM SR_V_REGIONS


SELECT TBR.*,
       SR.N_REGION_ID
FROM TT_BS_REGIONS     TBR,
     SR_V_REGIONS      SR,
     SR_V_REGIONS      SR_P
WHERE SR_P.N_PAR_REGION_ID     = 50409701   -- Оренбург
AND   TBR.VC_STREET LIKE SR_P.VC_CODE || '%'
AND   SR_P.N_REGION_ID       = SR.N_PAR_REGION_ID
AND   UPPER(SR.VC_HOME)      = UPPER(TBR.VC_HOUSE) 


SELECT *
FROM SR_V_REGIONS

-- Добавление адресов субъектам
DECLARE
  num_N_SUBJ_ADDRESS_ID    SI_SUBJ_ADDRESSES.N_SUBJ_ADDRESS_ID%TYPE;
  num_N_ADDRESS_ID         SI_SUBJ_ADDRESSES.N_ADDRESS_ID%TYPE;
BEGIN
FOR rc_Line IN (
               SELECT TBR.N_SUBJECT_ID,
                       TO_CHAR(TBR.N_FLAT)   VC_FLAT,
                       SR.N_REGION_ID
                FROM TT_BS_REGIONS     TBR,
                     SR_V_REGIONS      SR,
                     SR_V_REGIONS      SR_P
                WHERE SR_P.N_PAR_REGION_ID     = 50409701   -- Оренбург
                AND   TBR.VC_STREET LIKE SR_P.VC_CODE || '%'
                AND   SI_SUBJECTS_PKG_S.GET_SUBJ_TYPE_ID(TBR.N_SUBJECT_ID) IN (18001, 14001)
                AND   SR_P.N_REGION_ID       = SR.N_PAR_REGION_ID
                AND   UPPER(SR.VC_HOME)      = UPPER(TBR.VC_HOUSE) 
               )
  LOOP
  
    num_N_SUBJ_ADDRESS_ID   := NULL;
    num_N_ADDRESS_ID        := NULL;
  
    SI_ADDRESSES_PKG.SI_SUBJ_ADDRESSES_PUT_EX(
      num_N_SUBJ_ADDRESS_ID               => num_N_SUBJ_ADDRESS_ID,
      num_N_SUBJECT_ID                    => rc_Line.N_SUBJECT_ID,
      num_N_ADDRESS_ID                    => num_N_ADDRESS_ID,
      num_N_SUBJ_ADDR_TYPE_ID             => 1016,
      num_N_ADDR_STATE_ID                 => 1029,
      ch_C_FL_MAIN                        => NULL,
      num_N_ADDR_TYPE_ID                  => 1006,
      num_N_PAR_ADDR_ID                   => NULL,
      vch_VC_CODE                         => NULL,
      vch_VC_ADDRESS                      => NULL,
      vch_VC_FLAT                         => rc_Line.VC_FLAT,
      num_N_REGION_ID                     => rc_Line.N_REGION_ID,
      num_N_ENTRANCE_NO                   => NULL,
      num_N_FLOOR_NO                      => NULL,
      vch_VC_DIS_CODE                     => NULL,
      vch_VC_REM                          => NULL,
      b_UpdateRegister                    => 1);
    
   END LOOP;
END;
/

