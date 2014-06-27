--id абонента + Оборудовани + Порт + Скорость.
SELECT UD.N_SUBJECT_ID,
       OOB.VC_BIND_MAIN_OBJ,
       OOB.VC_BIND_OBJECT,
       PC.N_SPEED_VOLUME || ' ' || PC.VC_SPEED_UNIT_NAME     VC_SPEED
FROM SI_V_USER_DEVICES      UD,
     SI_V_USER_GOODS        UG,
     SI_V_OBJ_OBJECTS_BINDS OOB,
     SD_V_DOC_BINDS         DB,
     SD_V_PRICE_ORDERS_C    PC
WHERE UD.N_DEVICE_GOOD_ID     = 1596865801       -- Спецификация "Порт" сетевой службы "Аренда канала"
AND   UD.N_USE_DEVICE_ID      = UG.N_OBJECT_ID
AND   UD.N_SUBJECT_ID         = UG.N_SUBJECT_ID
AND   UG.N_GOOD_ID            = 107915001        -- Услуга "Аренда VLAN"
AND  (UG.D_END                > SYSDATE OR
      UG.D_END IS NULL)
AND   UG.C_FL_CLOSED          = 'N'
AND   OOB.N_OBJECT_ID(+)      = UD.N_USE_DEVICE_ID
AND   DB.N_DOC_ID             = UG.N_DOC_ID
AND   PC.N_DOC_ID             = DB.N_BIND_DOC_ID
AND   PC.N_GOOD_ID            = UG.N_GOOD_ID
GROUP BY UD.N_SUBJECT_ID, OOB.VC_BIND_MAIN_OBJ, OOB.VC_BIND_OBJECT, PC.N_SPEED_VOLUME, PC.VC_SPEED_UNIT_NAME
ORDER BY VC_SPEED;
