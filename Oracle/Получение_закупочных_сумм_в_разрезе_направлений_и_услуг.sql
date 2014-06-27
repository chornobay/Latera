-- Получение закупочных сумм в разрезе направлений и услуг
WITH PURCH_GM AS (
  SELECT DISTINCT CDR.N_GM_PURCH_LINE_B_ID
  FROM   EX_V_CDR CDR
  WHERE  CDR.N_CDR_TYPE_ID = SYS_CONTEXT('CONST', 'CDR_TYPE_Phonecall')
  AND    VC_ROUTE_B        = 'TTK'
  AND    CDR.D_BEGIN      >= TO_DATE('01.03.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
  AND    CDR.D_END         < TO_DATE('01.04.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
  AND    CDR.N_GM_PURCH_LINE_B_ID IS NOT NULL)
SELECT   SR_GOODS_PKG_S.GET_NAME_BY_ID(GM.N_GOOD_ID)     "Услуга",
         SI_ADDRESSES_PKG_S.GET_VC_CODE(GM.N_ADDRESS_ID) "Направление",
         SUM(GM.N_QUANT)                                 "Минуты",
         SUM(GM.N_SUM)                                   "Сумма, руб."       
FROM     SD_GOOD_MOVES GM,
         PURCH_GM      GML
WHERE    GM.C_ACTIVE              = 'Y'
AND      GML.N_GM_PURCH_LINE_B_ID = GM.N_LINE_ID
GROUP BY GM.N_GOOD_ID, GM.N_ADDRESS_ID