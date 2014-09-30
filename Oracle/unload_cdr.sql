-- Создаём процедуру WRITE_TO_FILE, если её нет в пакете UTILS_PKG_S

CREATE OR REPLACE PROCEDURE WRITE_TO_FILE(
  vch_VC_LOCATION IN VARCHAR2,
  vch_VC_FILENAME IN VARCHAR2,
  vch_VC_OPEN_MODE IN VARCHAR2 := 'w',
  blb_BL_DATA IN BLOB := NULL)
IS
  num_ChunkSize NUMBER := 4096;
  
  rc_FileData UTL_FILE.FILE_TYPE;
  raw_Buffer RAW(4096);
  num_WritedBytes NUMBER := 0;
BEGIN
  rc_FileData := UTL_FILE.FOPEN(vch_VC_LOCATION, vch_VC_FILENAME, vch_VC_OPEN_MODE);
  
  WHILE num_WritedBytes < DBMS_LOB.GETLENGTH(blb_BL_DATA) LOOP
    DBMS_LOB.READ(
      LOB_LOC => blb_BL_DATA,
      AMOUNT => num_ChunkSize,
      OFFSET => num_WritedBytes + 1,
      BUFFER => raw_Buffer);
    
    UTL_FILE.PUT_RAW(rc_FileData, raw_Buffer);
    
    num_WritedBytes := num_WritedBytes + num_ChunkSize;
  END LOOP;
  
  UTL_FILE.FCLOSE(rc_FileData);
END WRITE_TO_FILE;

-- Создаём временное представление TT_V_SPEC_FOR_CDR

CREATE OR REPLACE FORCE VIEW TT_V_SPEC_FOR_CDR
AS
SELECT N_VALUE_1 N_CDR_ID,         
       VC_VALUE_1 VC_EXT_ID,  
       N_VALUE_2 N_SERVICE_ID,         
       N_VALUE_3 N_FIRM_ID,         
       N_VALUE_4 N_CDR_STATE_ID,         
       N_VALUE_5 N_USER_A_ID,         
       VC_VALUE_2 VC_AUTH_USERNAME,  
       N_VALUE_6 N_ACCOUNT_A_ID,         
       N_VALUE_7 N_ACCOUNT_B_ID,         
       N_VALUE_8 N_PROVIDER_A_ID,         
       N_VALUE_9 N_PROVIDER_B_ID,         
       N_VALUE_10 N_EQUIP_A_ID,         
       N_VALUE_11 N_EQUIP_B_ID,         
       N_VALUE_12 N_ADDRESS_A_ID,         
       N_VALUE_13 N_ADDRESS_B_ID,         
       VC_VALUE_3 VC_STATION_A, 
       VC_VALUE_4 VC_STATION_B, 
       N_VALUE_14 N_GOOD_AB_ID,         
       N_VALUE_15 N_GOOD_BA_ID,        
       D_VALUE_1 D_BEGIN,           
       D_VALUE_2 D_END,           
       N_VALUE_16 N_DURATION_SEC,         
       N_VALUE_17 N_CREDIT_TIME_SEC,         
       VC_VALUE_5 VC_ROUTE_LIST_B, 
       VC_VALUE_6 VC_ROUTE_A,  
       VC_VALUE_7 VC_ROUTE_B,  
       N_VALUE_18 N_PURCH_PRICE_LINE_A_ID,         
       N_VALUE_19 N_PURCH_PRICE_LINE_B_ID,         
       N_VALUE_20 N_TERMINATION_CAUSE,         
       VC_VALUE_8 VC_TERMINATION_CAUSE,  
       N_VALUE_21 N_AB_BYTES,         
       N_VALUE_22 N_BA_BYTES,         
       N_VALUE_23 N_GM_LINE_A_ID,         
       N_VALUE_24 N_GM_LINE_B_ID,         
       N_VALUE_25 N_GM_PURCH_LINE_A_ID,         
       N_VALUE_26 N_GM_PURCH_LINE_B_ID,         
       N_VALUE_27 N_CDR_ACC_STATE_ID,         
       VC_VALUE_9 VC_NAS,  
       D_VALUE_3 D_LOG_CREATE,           
       D_VALUE_4 D_LOG_LAST_MOD,           
       N_VALUE_28 N_LOG_SESSION_ID,         
       N_VALUE_29 N_QUALITY,         
       N_VALUE_30 N_RG_LINE_T_A_ID,         
       N_VALUE_31 N_RG_LINE_T_B_ID,         
       VC_VALUE_10 C_ACTIVE,        
       VC_VALUE_11 VC_REM,  
       N_VALUE_32 N_CDR_TYPE_ID,         
       VC_VALUE_12 VC_EXT_UNIQ_ID,  
       VC_VALUE_13 VC_PORT_NO,  
       VC_VALUE_14 VC_FRAMED_PREFIX,  
       N_VALUE_33 N_FRAMED_PREFIX_ID,         
       VC_VALUE_15 VC_DELEGATED_PREFIX,  
       N_VALUE_34 N_DELEGATED_PREFIX_ID        
FROM TT_VALUES
WHERE N_VALUE_100 = -100
/

-- Выгрузка производится с помощью следующего скрипта

DECLARE
  dt_D_BEGIN DATE;
  dt_D_END DATE;
  num_N_SECTION_ID TT_VALUES.N_VALUE_100%TYPE := -100;
  clb_CL_Data CLOB := NULL;
  cnum_CSID CONSTANT NUMBER := NLS_CHARSET_ID('CL8MSWIN1251');
  blb_BL_DATA BLOB;
  bl_data BLOB;
  vch_VC_FILENAME VARCHAR2(1000);
  clb_CL_Data1 CLOB := NULL;
BEGIN
  FOR day_Num IN 0 .. 61 LOOP

    dt_D_BEGIN := TO_DATE('30.06.2014 00:00:00','DD.MM.YYYY HH24:MI:SS') - day_Num;
    dt_D_END := dt_D_BEGIN + 1 - 1/24/60/60;
    vch_VC_FILENAME := TO_CHAR(dt_D_BEGIN, 'YYYY-MM-DD') || '.csv';

    -- Очистка временной таблицы
    DELETE FROM TT_VALUES
    WHERE N_VALUE_100 = num_N_SECTION_ID;
    
    INSERT INTO TT_VALUES (
      N_VALUE_1,         
      VC_VALUE_1,  
      N_VALUE_2,         
      N_VALUE_3,         
      N_VALUE_4,         
      N_VALUE_5,         
      VC_VALUE_2,  
      N_VALUE_6,         
      N_VALUE_7,         
      N_VALUE_8,         
      N_VALUE_9,         
      N_VALUE_10,         
      N_VALUE_11,         
      N_VALUE_12,         
      N_VALUE_13,         
      VC_VALUE_3, 
      VC_VALUE_4, 
      N_VALUE_14,         
      N_VALUE_15,        
      D_VALUE_1,           
      D_VALUE_2,           
      N_VALUE_16,         
      N_VALUE_17,         
      VC_VALUE_5, 
      VC_VALUE_6,  
      VC_VALUE_7,  
      N_VALUE_18,         
      N_VALUE_19,         
      N_VALUE_20,         
      VC_VALUE_8,  
      N_VALUE_21,         
      N_VALUE_22,         
      N_VALUE_23,         
      N_VALUE_24,         
      N_VALUE_25,         
      N_VALUE_26,         
      N_VALUE_27,         
      VC_VALUE_9,  
      D_VALUE_3,           
      D_VALUE_4,           
      N_VALUE_28,         
      N_VALUE_29,         
      N_VALUE_30,         
      N_VALUE_31,         
      VC_VALUE_10,        
      VC_VALUE_11,  
      N_VALUE_32,         
      VC_VALUE_12,  
      VC_VALUE_13,  
      VC_VALUE_14,  
      N_VALUE_33,         
      VC_VALUE_15,  
      N_VALUE_34,        
      N_VALUE_100)  
    SELECT N_CDR_ID N_VALUE_1,         
            VC_EXT_ID VC_VALUE_1,  
            N_SERVICE_ID N_VALUE_2,         
            N_FIRM_ID N_VALUE_3,         
            N_CDR_STATE_ID N_VALUE_4,         
            N_USER_A_ID N_VALUE_5,         
            VC_AUTH_USERNAME VC_VALUE_2,  
            N_ACCOUNT_A_ID N_VALUE_6,         
            N_ACCOUNT_B_ID N_VALUE_7,         
            N_PROVIDER_A_ID N_VALUE_8,         
            N_PROVIDER_B_ID N_VALUE_9,         
            N_EQUIP_A_ID N_VALUE_10,         
            N_EQUIP_B_ID N_VALUE_11,         
            N_ADDRESS_A_ID N_VALUE_12,         
            N_ADDRESS_B_ID N_VALUE_13,         
            VC_STATION_A VC_VALUE_3, 
            VC_STATION_B VC_VALUE_4, 
            N_GOOD_AB_ID N_VALUE_14,         
            N_GOOD_BA_ID N_VALUE_15,        
            D_BEGIN D_VALUE_1,           
            D_END D_VALUE_2,           
            N_DURATION_SEC N_VALUE_16,         
            N_CREDIT_TIME_SEC N_VALUE_17,         
            VC_ROUTE_LIST_B VC_VALUE_5, 
            VC_ROUTE_A VC_VALUE_6,  
            VC_ROUTE_B VC_VALUE_7,  
            N_PURCH_PRICE_LINE_A_ID N_VALUE_18,         
            N_PURCH_PRICE_LINE_B_ID N_VALUE_19,         
            N_TERMINATION_CAUSE N_VALUE_20,         
            VC_TERMINATION_CAUSE VC_VALUE_8,  
            N_AB_BYTES N_VALUE_21,         
            N_BA_BYTES N_VALUE_22,         
            N_GM_LINE_A_ID N_VALUE_23,         
            N_GM_LINE_B_ID N_VALUE_24,         
            N_GM_PURCH_LINE_A_ID N_VALUE_25,         
            N_GM_PURCH_LINE_B_ID N_VALUE_26,         
            N_CDR_ACC_STATE_ID N_VALUE_27,         
            VC_NAS VC_VALUE_9,  
            D_LOG_CREATE D_VALUE_3,           
            D_LOG_LAST_MOD D_VALUE_4,           
            N_LOG_SESSION_ID N_VALUE_28,         
            N_QUALITY N_VALUE_29,         
            N_RG_LINE_T_A_ID N_VALUE_30,         
            N_RG_LINE_T_B_ID N_VALUE_31,         
            C_ACTIVE VC_VALUE_10,        
            VC_REM VC_VALUE_11,  
            N_CDR_TYPE_ID N_VALUE_32,         
            VC_EXT_UNIQ_ID VC_VALUE_12,  
            VC_PORT_NO VC_VALUE_13,  
            VC_FRAMED_PREFIX VC_VALUE_14,  
            N_FRAMED_PREFIX_ID N_VALUE_33,         
            VC_DELEGATED_PREFIX VC_VALUE_15,  
            N_DELEGATED_PREFIX_ID N_VALUE_34,        
            -100 N_VALUE_100                                  
    FROM EX_CALL_DATA_REC
    WHERE N_CDR_TYPE_ID IN (SYS_CONTEXT('CONST', 'CDR_TYPE_PPP_WithCharging'),
                            SYS_CONTEXT('CONST', 'CDR_TYPE_PPP_WOCharging'))
    AND N_CDR_STATE_ID IN (SYS_CONTEXT('CONST', 'CDR_Status_Finished'), 
                           SYS_CONTEXT('CONST', 'CDR_Status_FinForced'))
    AND D_BEGIN BETWEEN dt_D_BEGIN AND dt_D_END
    ORDER BY N_CDR_ID;
    
    -- Выгрузка представления в CSV
    clb_CL_Data := STR_UTILS_PKG_S.FETCH_TT_TO_CSV(
                     num_N_SECTION_ID => num_N_SECTION_ID,
                     vch_TABLE_NAME => 'TT_V_SPEC_FOR_CDR',
                     vch_ORDER_BY_COLUMNS => 'N_CDR_ID',
                     vch_DATE_FORMAT => 'DD.MM.YYYY HH24:MI:SS');


    DBMS_XSLPROCESSOR.CLOB2FILE(clb_CL_Data, 'CDRS', vch_VC_FILENAME, cnum_CSID);
  
  END LOOP;
END;
/


-- После выгрузки нужно удалить WRITE_TO_FILE и TT_V_SPEC_FOR_CDR
