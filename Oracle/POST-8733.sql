-- Определение услуг для неперетарифицированных CDR по зкупке
SELECT N_GOOD_AB_ID, COUNT(*)
FROM EX_V_CDR
WHERE 1=1
AND VC_ROUTE_B  = 'TTK'
AND D_BEGIN    >= TO_DATE('01.03.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND D_END       < TO_DATE('01.04.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND N_GM_PURCH_LINE_B_ID IS NULL
GROUP BY N_GOOD_AB_ID

-- Определение направлений для CDR у которых не указана услуга
SELECT SI_ADDRESSES_PKG_S.GET_VC_NAME(N_ADDRESS_A_ID), N_ADDRESS_A_ID, COUNT(*)
FROM EX_V_CDR
WHERE 1=1
AND VC_ROUTE_B = 'TTK'
AND D_BEGIN   >= TO_DATE('01.03.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND D_END      < TO_DATE('01.04.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND N_GM_PURCH_LINE_B_ID IS NULL
AND N_GOOD_AB_ID IS NULL
GROUP BY N_ADDRESS_A_ID

-- Определение поставщиков
SELECT CDR.N_PROVIDER_A_ID,
       CDR.VC_ROUTE_A,
       COUNT(*)
FROM EX_V_CDR            CDR
WHERE 1=1
AND CDR.VC_ROUTE_B     = 'TTK'
AND CDR.D_BEGIN       >= TO_DATE('01.03.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND CDR.D_END          < TO_DATE('01.04.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND CDR.N_GM_PURCH_LINE_B_ID IS  NULL
AND CDR.N_PROVIDER_A_ID      IS NULL
GROUP BY CDR.N_PROVIDER_A_ID, CDR.VC_ROUTE_A

--
SELECT SI_ADDRESSES_PKG_S.GET_VC_NAME(CDR.N_ADDRESS_B_ID)   VC_ADDRESS_B_ID, 
       CDR.N_ADDRESS_B_ID,
       SI_ADDRESSES_PKG_S.GET_VC_NAME(PN.N_PAR_ADDR_ID) VC_PAR_ADDRESS_B_ID,
       PN.N_PAR_ADDR_ID                                  N_PAR_ADDRESS_B_ID,
       CASE
         WHEN CDR.N_GOOD_AB_ID = 40215501      THEN 'Телефония междугородная 8 исх.' 
         WHEN CDR.N_GOOD_AB_ID = 4586812620801 THEN 'Телефония международная 8 исх.'
       END                                                          VC_GOOD,
       COUNT(*)
FROM EX_V_CDR            CDR,
     SI_V_PHONE_NUMBERS  PN
WHERE 1=1
AND CDR.VC_ROUTE_B     = 'TTK'
AND CDR.D_BEGIN       >= TO_DATE('01.03.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND CDR.D_END          < TO_DATE('01.04.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
AND CDR.N_GM_PURCH_LINE_B_ID IS NULL
AND CDR.N_PROVIDER_A_ID IS NOT NULL
AND CDR.N_GOOD_AB_ID IN (40215501,          -- Телефония междугородная 8 исх.
                         4586812620801)     -- Телефония международная 8 исх.
AND CDR.N_ADDRESS_B_ID = PN.N_ADDRESS_ID
GROUP BY CDR.N_ADDRESS_B_ID, PN.N_PAR_ADDR_ID, PN.N_PAR_ADDR_ID, CDR.N_GOOD_AB_ID
ORDER BY CDR.N_GOOD_AB_ID; 
