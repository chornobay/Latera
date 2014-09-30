   -- Добавление кода в зону
   DECLARE
    num_N_ADDR_ADDRESS_ID NUMBER;
   BEGIN
    FOR rc_Line IN (
                    SELECT A.N_ADDRESS_ID,
                           A.VC_NAME
                    FROM SI_V_ADDRESSES A
                    -- Указать коды, которые нужно добавить в зону
                    WHERE A.VC_CODE IN ('74852695204',
                                        '74722402346',
                                        '74932773161')
                    AND A.N_PAR_ADDR_ID IS NOT NULL
                    -- Исключаем номера, которые уже добавлены в зону
                    AND NOT EXISTS (
                                       SELECT 1
                                       FROM SI_V_ADDR_ADDRESSES AA
                                       WHERE AA.N_ADDRESS_ID  = A.N_ADDRESS_ID
                                       AND   AA.N_PAR_ADDR_ID = 42635301
                                       AND   AA.N_DOC_ID      = 822034101         -- ПКТ-11/1
                                    --   AND   AA.N_DOC_ID      = 822732301         -- ПКТ-11/2
                                    --   AND   AA.N_DOC_ID      = 824257401         -- ПКТ-11/3
                                   )
                    AND A.N_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'ADDR_TYPE_TelCode')
                    ORDER BY A.VC_NAME
                   )
     LOOP

       num_N_ADDR_ADDRESS_ID := NULL;

       SI_ADDRESSES_PKG.SI_ADDR_ADDRESSES_PUT(
           num_N_ADDR_ADDRESS_ID   => num_N_ADDR_ADDRESS_ID,
           num_N_ADDR_BIND_TYPE_ID => 1043,
           num_N_ADDRESS_ID        => rc_Line.N_ADDRESS_ID,
           num_N_PAR_ADDR_ID       => 42635301,     -- ID зоны Праймлинк
      --     num_N_DOC_ID            => 822034101,    -- ID ПКТ-11/1
      --     num_N_DOC_ID            => 822732301,    -- ID ПКТ-11/2
           num_N_DOC_ID            => 824257401,    -- ID ПКТ-11/3
           vch_VC_REM              => NULL,
           b_UpdateRegister        => 0);           -- Не переформировавыть регистры после добавления каждого номера

      -- COMMIT;
     END LOOP;
   END;
   /
