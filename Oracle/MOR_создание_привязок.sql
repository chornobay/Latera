-- Создаем временную таблицу для работы с данными клиента
CREATE TABLE TEMP_TABLE_FOR_BINDS (
                                    VC_DOC         varchar2(500), 
                                    VC_ADDR        varchar2(500), 
                                    VC_GROUP       varchar2(500), 
                                    N_PORT         varchar2(500), 
                                    VC_COMM        varchar2(500),
                                    C_DOC_ADDR     varchar2(5),
                                    C_IS_BIND      varchar2(5),
                                    C_IS_COMM      varchar2(5),
                                    C_IS_PORT_FREE varchar2(5));


-- Проверяем соответствует ли информация с файла клиента с информацией в Гидре
-- Привязана ли указанная подсеть к указанному абоненту
-- Если информация с файла соответствует информации в Гидре в поле C_DOC_ADDR ставим 'Y'
UPDATE TEMP_TABLE_FOR_BINDS
SET C_DOC_ADDR = 'Y'
WHERE VC_DOC IN ( SELECT TEMP.VC_DOC
                  FROM SI_V_DOC_SUBJECTS     DS,
                       SD_V_DOCUMENTS        D,
                       TEMP_TABLE_FOR_BINDS  TEMP,
                       SI_V_USER_DEVICES     UD
                  WHERE DS.N_DOC_ROLE_ID     = 1004 -- Получатель/Клиент
                  AND   DS.N_DOC_ID          = D.N_DOC_ID
                  AND   D.VC_DOC_NO          = TEMP.VC_DOC
                  AND   DS.N_SUBJECT_ID      = UD.N_SUBJECT_ID
                  AND   UD.VC_IP_CODE        = TEMP.VC_ADDR
                  GROUP BY TEMP.VC_DOC);
                  
                  
-- Проверяем существует ли уже привязка оборудования абонента к указанному коммутатору
-- Если сушествует, ставим 'Y' в поле C_IS_BIND
UPDATE TEMP_TABLE_FOR_BINDS
SET C_IS_BIND = 'Y'
WHERE VC_DOC IN (
                  SELECT TEMP.VC_DOC
                     /*    OO.N_MAIN_OBJECT_ID,
                         OO.N_OBJECT_ID,
                         UD.VC_IP_CODE,
                         OO.N_BIND_MAIN_OBJ_ID,
                         A.VC_CODE,
                         OO.N_BIND_OBJECT_ID,
                         O.VC_CODE           VC_PORT_NO  */
                  FROM SI_V_DOC_SUBJECTS            DS,
                       SD_V_DOCUMENTS               D,
                       TEMP_TABLE_FOR_BINDS         TEMP,
                       SI_V_USER_DEVICES            UD,
                       SI_V_OBJ_OBJECTS_BINDS       OO,
                       SI_V_SUBJ_SERVICES_SIMPLE    SS,
                       SI_OBJ_ADDRESSES             OA,
                       SI_V_ADDRESSES               A,
                       SI_V_OBJECTS                 O
                  WHERE DS.N_DOC_ROLE_ID       = 1004 -- Получатель/Клиент
                  AND   DS.N_DOC_ID            = D.N_DOC_ID
                  AND   TEMP.VC_DOC            = D.VC_DOC_NO
                  AND   DS.N_SUBJECT_ID        = UD.N_SUBJECT_ID
                  AND   OO.N_MAIN_OBJECT_ID    = UD.N_DEVICE_ID
                  AND   OO.N_OBJECT_ID         = UD.N_PORT_ID
                  AND   SS.N_OBJECT_ID         = OO.N_BIND_MAIN_OBJ_ID
                  AND   OA.N_OBJ_ADDRESS_ID    = SS.N_OBJ_ADDRESS_ID
                  AND   A.N_ADDRESS_ID         = OA.N_ADDRESS_ID
                  AND   O.N_OBJECT_ID          = OO.N_BIND_OBJECT_ID
                  AND   TEMP.VC_COMM           = A.VC_CODE
                  AND   TEMP.N_PORT            = O.VC_CODE
                  GROUP BY TEMP.VC_DOC);


-- Проверяем существет ли коммутатор с указанным IP
-- Если существует, ставим 'Y' в поле C_IS_COMM
UPDATE TEMP_TABLE_FOR_BINDS
SET C_IS_COMM = 'Y'
WHERE VC_COMM IN ( SELECT TEMP.VC_COMM
                  FROM TEMP_TABLE_FOR_BINDS         TEMP,
                       SI_V_SUBJ_SERVICES_SIMPLE    SS,
                       SI_OBJ_ADDRESSES             OA,
                       SI_V_ADDRESSES               A,
                       SI_V_OBJECTS                 O
                  WHERE OA.N_OBJ_ADDRESS_ID    = SS.N_OBJ_ADDRESS_ID
                  AND   A.N_ADDRESS_ID         = OA.N_ADDRESS_ID
                  AND   TEMP.VC_COMM           = A.VC_CODE
                  GROUP BY TEMP.VC_COMM);



-- Проверяем свободен ли порт коммутатора, к которому должно быть привязано абонентское оборудование
-- Если порт занят, ставим 'N' в поле C_IS_PORT_FREE
UPDATE TEMP_TABLE_FOR_BINDS
SET C_IS_PORT_FREE = 'N'
WHERE VC_DOC IN ( SELECT TEMP.VC_DOC
                    /*     OO.N_MAIN_OBJECT_ID,
                         OO.N_OBJECT_ID,
                         OO.N_BIND_MAIN_OBJ_ID,
                         A.VC_CODE,
                         OO.N_BIND_OBJECT_ID,
                         O.VC_CODE           VC_PORT_NO  */
                  FROM TEMP_TABLE_FOR_BINDS         TEMP,
                       SI_V_OBJ_OBJECTS_BINDS       OO,
                       SI_V_SUBJ_SERVICES_SIMPLE    SS,
                       SI_OBJ_ADDRESSES             OA,
                       SI_V_ADDRESSES               A,
                       SI_V_OBJECTS                 O
                  WHERE SS.N_OBJECT_ID         = OO.N_BIND_MAIN_OBJ_ID
                  AND   OA.N_OBJ_ADDRESS_ID    = SS.N_OBJ_ADDRESS_ID
                  AND   A.N_ADDRESS_ID         = OA.N_ADDRESS_ID
                  AND   O.N_OBJECT_ID          = OO.N_BIND_OBJECT_ID
                  AND   TEMP.VC_COMM           = A.VC_CODE
                  AND   TEMP.N_PORT            = O.VC_CODE
                  GROUP BY TEMP.VC_DOC);




-- Создаем привязку
DECLARE
  num_N_OBJ_OBJECT_ID          SI_OBJ_OBJECTS.N_OBJ_OBJECT_ID%TYPE;
  n_Num                        NUMBER := 0;
BEGIN
  FOR rc_Bind IN (
    SELECT UD.N_DEVICE_ID      N_MAIN_OBJECT_ID,
           UD.N_PORT_ID        N_OBJECT_ID,
           SS.N_OBJECT_ID      N_BIND_MAIN_OBJ_ID,
           O.N_OBJECT_ID       N_BIND_OBJECT_ID,
           TEMP.VC_DOC
    FROM TEMP_TABLE_FOR_BINDS         TEMP,
         SD_V_DOCUMENTS               D,
         SI_V_DOC_SUBJECTS            DS,
         SI_V_USER_DEVICES            UD,
         SI_V_SUBJ_SERVICES_SIMPLE    SS,
         SI_OBJ_ADDRESSES             OA,
         SI_V_ADDRESSES               A,
         SI_V_OBJECTS                 O,
         SI_V_OBJECTS_SPEC_SIMPLE     OS
    WHERE TEMP.C_IS_PORT_FREE    = 'Y'
    AND   TEMP.C_IS_BIND         = 'N'
    AND   TEMP.C_DOC_ADDR        = 'Y'
    -- Определяем идентификаторы оборудования и компонента оборудования абонента
    AND   TEMP.VC_DOC            = D.VC_DOC_NO
    AND   DS.N_DOC_ID            = D.N_DOC_ID
    AND   DS.N_DOC_ROLE_ID       = 1004                     -- Получатель/Клиент
    AND   DS.N_SUBJECT_ID        = UD.N_SUBJECT_ID
    AND   UD.VC_IP_CODE          = TEMP.VC_ADDR
    -- Определяем идентификатор коммутатора для привязки
    AND   TEMP.VC_COMM           = A.VC_CODE
    AND   A.N_ADDRESS_ID         = OA.N_ADDRESS_ID
    AND   OA.N_OBJ_ADDRESS_ID    = SS.N_OBJ_ADDRESS_ID
    -- Определяем идентификатор порта коммутатора для привязки
    AND   TEMP.N_PORT            = O.VC_CODE
    AND   O.N_OBJECT_ID          = OS.N_OBJECT_ID
    AND   OS.N_MAIN_OBJECT_ID    = SS.N_OBJECT_ID
    GROUP BY TEMP.VC_DOC, UD.N_DEVICE_ID, UD.N_PORT_ID, SS.N_OBJECT_ID, O.N_OBJECT_ID)
  LOOP
  
    num_N_OBJ_OBJECT_ID := NULL; 
  
    SI_OBJECTS_PKG.SI_OBJ_OBJECTS_BINDS_PUT(
      num_N_OBJ_OBJECT_ID                 => num_N_OBJ_OBJECT_ID,
      num_N_OBJ_ROLE_ID                   => SYS_CONTEXT('CONST', 'OBJOBJ_BIND_TYPE_NetConnection'),
      num_N_MAIN_OBJECT_ID                => rc_Bind.N_MAIN_OBJECT_ID,
      num_N_OBJECT_ID                     => rc_Bind.N_OBJECT_ID,
      num_N_BIND_MAIN_OBJ_ID              => rc_Bind.N_BIND_MAIN_OBJ_ID,
      num_N_BIND_OBJECT_ID                => rc_Bind.N_BIND_OBJECT_ID);
    
    n_Num := n_Num + 1;
      
    DBMS_OUTPUT.put_line( '#' || n_Num || '. номер договора: ' || rc_Bind.VC_DOC );
    
  END LOOP;
END;
/


-- Удаляем старые привязки, которые не соответствовали данным с файла клиента
BEGIN 
  FOR rc_Double IN (
    SELECT OB.N_OBJ_OBJECT_ID
    FROM (SELECT O.N_OBJ_OBJECT_ID, 
                 O.N_OBJECT_ID,
                 O.D_LOG_LAST_MOD,
                 ROW_NUMBER() OVER (PARTITION BY O.N_OBJECT_ID ORDER BY O.D_LOG_LAST_MOD) N_ROW
          FROM SI_OBJ_OBJECTS O
          WHERE N_OBJECT_ID IN (
                SELECT N_OBJECT_ID
                FROM SI_OBJ_OBJECTS
                WHERE C_ACTIVE = 'Y'
                GROUP BY N_OBJECT_ID
                HAVING COUNT(*) = 2)
          AND O.C_ACTIVE = 'Y')              OB
    WHERE OB.N_ROW = 1)
  LOOP
    SI_OBJECTS_PKG.SI_OBJ_OBJECTS_DEL(
      num_N_OBJ_OBJECT_ID                 => rc_Double.N_OBJ_OBJECT_ID);
  END LOOP;
END;
/
