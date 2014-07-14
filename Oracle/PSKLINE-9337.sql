-- id абонента + Оборудовани + Порт + Скорость.
-- v1
SELECT SI_SUBJECTS_PKG_S.GET_VC_NAME(UD.N_SUBJECT_ID)              VC_SUBJ_NAME,
       OOB.VC_BIND_MAIN_OBJ                                        VC_OBJ_NAME,
       SI_OBJECTS_PKG_S.GET_CODE_BY_ID(OOB.N_BIND_MAIN_OBJ_ID)     VC_OBJ_CODE,
       OOB.VC_BIND_OBJECT,
       PC.N_SPEED_VOLUME || ' ' || PC.VC_SPEED_UNIT_NAME           VC_SPEED
FROM SI_V_USER_DEVICES_SIMPLE      UD,
     SI_V_USER_GOODS               UG,
     SI_V_OBJ_OBJECTS_BINDS        OOB,
     SD_V_DOC_BINDS                DB,
     SD_V_PRICE_ORDERS_C           PC,
     SD_V_PRICE_ORDERS_T           PT
WHERE UD.N_DEVICE_GOOD_ID     = 1596865801       -- Спецификация "Порт" сетевой службы "Аренда канала"
AND   UD.N_USE_DEVICE_ID      = UG.N_OBJECT_ID
AND   UD.N_SUBJECT_ID         = UG.N_SUBJECT_ID
AND   UG.N_GOOD_ID            = 107915001        -- Услуга "Аренда VLAN"
AND  (UG.D_END                > SYSDATE OR
      UG.D_END IS NULL)
AND   UG.C_FL_CLOSED          = 'N'
AND   OOB.N_OBJECT_ID         = UD.N_USE_DEVICE_ID
AND   DB.N_DOC_ID             = UG.N_DOC_ID
AND   PC.N_DOC_ID             = DB.N_BIND_DOC_ID
AND   PC.N_GOOD_ID            = UG.N_GOOD_ID
AND   PC.N_DOC_ID             = PT.N_DOC_ID
AND   PT.N_DOC_STATE_ID       = SYS_CONTEXT('CONST', 'DOC_STATE_Actual')
GROUP BY UD.N_SUBJECT_ID, OOB.VC_BIND_MAIN_OBJ, OOB.N_BIND_MAIN_OBJ_ID, OOB.VC_BIND_OBJECT, PC.N_SPEED_VOLUME, PC.VC_SPEED_UNIT_NAME
ORDER BY VC_SPEED;



-- v2
SELECT s.VC_NAME,
       o.vc_obj_name,
       o.vc_obj_code,
       OOB.VC_BIND_OBJECT,
       PC.N_SPEED_VOLUME || ' ' || PC.VC_SPEED_UNIT_NAME VC_SPEED
FROM SI_V_USER_DEVICES_SIMPLE UD,
     SI_V_USER_GOODS          UG,
     SI_V_OBJ_OBJECTS_BINDS   OOB,
     SD_V_DOC_BINDS           DB,
     SD_V_PRICE_ORDERS_C      PC,
     SD_V_PRICE_ORDERS_T      PT,
     SI_V_OBJECTS_SIMPLE      o,
     SI_V_SUBJECTS            s
WHERE UD.N_DEVICE_GOOD_ID     = 1596865801 -- Спецификация "Порт" сетевой службы "Аренда канала"
AND   UD.N_USE_DEVICE_ID      = UG.N_OBJECT_ID
AND   UD.N_SUBJECT_ID         = UG.N_SUBJECT_ID
AND   UG.N_GOOD_ID            = 107915001 -- Услуга "Аренда VLAN"
AND   (UG.D_END > SYSDATE OR
      UG.D_END IS NULL)
AND   UG.C_FL_CLOSED          = 'N'
AND   OOB.N_OBJECT_ID(+)      = UD.N_USE_DEVICE_ID
AND   OOB.N_BIND_MAIN_OBJ_ID  = o.n_object_id 
AND   DB.N_DOC_ID             = UG.N_DOC_ID
AND   PC.N_DOC_ID             = DB.N_BIND_DOC_ID
AND   PC.N_GOOD_ID            = UG.N_GOOD_ID
AND   PC.N_DOC_ID             = PT.N_DOC_ID
AND   PT.N_DOC_STATE_ID       = SYS_CONTEXT('CONST', 'DOC_STATE_Actual')
AND   UD.N_SUBJECT_ID         = s.N_SUBJECT_ID
GROUP BY s.VC_NAME, o.vc_obj_name, o.vc_obj_code,OOB.VC_BIND_OBJECT, PC.N_SPEED_VOLUME, PC.VC_SPEED_UNIT_NAME;
