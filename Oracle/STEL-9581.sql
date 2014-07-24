DECLARE 
  num_N_SUBJ_SUBJECT_ID     SI_SUBJ_SUBJECTS.N_SUBJ_SUBJECT_ID%TYPE := NULL;
BEGIN
  FOR rc_Users IN (
    WITH vkl_users AS (
      -- Выбираем активных абонентов
      SELECT U2.N_SUBJECT_ID,
             U2.N_BASE_SUBJECT_ID
      FROM SI_V_USERS          U2,
           SI_V_USER_CONTRACTS UC1
      WHERE U2.N_BASE_SUBJECT_ID IN (
                                      -- Получаем базовые СУ, у которых есть больше одной роли "абонент"
                                      SELECT U1.N_BASE_SUBJECT_ID
                                      FROM SI_V_USERS     U1
                                      GROUP BY U1.N_BASE_SUBJECT_ID
                                      HAVING COUNT(*) > 1
                                    )
      AND   U2.N_SUBJ_STATE_ID != SYS_CONTEXT('CONST', 'SUBJ_STATE_Disabled') 
      AND   (U2.VC_SUBJ_CODE LIKE 'ani%' OR
             U2.VC_SUBJ_CODE LIKE 'dol%' OR
             U2.VC_SUBJ_CODE LIKE 'gor%' OR
             U2.VC_SUBJ_CODE LIKE 'nev%')
      AND   UC1.N_SUBJECT_ID(+) = U2.N_SUBJECT_ID
      AND   UC1.N_PARENT_DOC_ID IN (50228901,
                                    1309915601,
                                    1777731701,
                                    2186190401,
                                    2186179001,
                                    2186184501,
                                    2186209001,
                                    2186231301,
                                    2186219801,
                                    2186236001,
                                    2186213801,
                                    2186216201,
                                    2186227301,
                                    50659301,
                                    524468101,
                                    2441623101,
                                    3136633401,
                                    3185041901,
                                    3235135501,
                                    3235134701,
                                    3264340401,
                                    3345508101,
                                    50655301,
                                    50228101))
    -- Выбираем отключенных абонентов
    SELECT U3.N_SUBJECT_ID
    FROM SI_V_USERS          U3,
         SI_V_USER_CONTRACTS UC2,
         SI_V_SUBJ_SUBJECTS  SS,
         vkl_users
    WHERE U3.N_BASE_SUBJECT_ID = vkl_users.N_BASE_SUBJECT_ID
    AND   U3.N_SUBJ_STATE_ID   = SYS_CONTEXT('CONST', 'SUBJ_STATE_Disabled') 
    AND  (U3.VC_SUBJ_CODE LIKE 'ani%' OR
          U3.VC_SUBJ_CODE LIKE 'dol%' OR
          U3.VC_SUBJ_CODE LIKE 'gor%' OR
          U3.VC_SUBJ_CODE LIKE 'nev%')
    AND   UC2.N_SUBJECT_ID(+)  = U3.N_SUBJECT_ID
    AND   UC2.N_PARENT_DOC_ID IN (50228901,
                                  1309915601,
                                  1777731701,
                                  2186190401,
                                  2186179001,
                                  2186184501,
                                  2186209001,
                                  2186231301,
                                  2186219801,
                                  2186236001,
                                  2186213801,
                                  2186216201,
                                  2186227301,
                                  50659301,
                                  524468101,
                                  2441623101,
                                  3136633401,
                                  3185041901,
                                  3235135501,
                                  3235134701,
                                  3264340401,
                                  3345508101,
                                  50655301,
                                  50228101)  
    -- Проверяем, не входит ли данный абонент в группу "Переоформлен"
    AND   SS.N_SUBJECT_ID       = U3.N_SUBJECT_ID
    AND   SS.N_SUBJECT_BIND_ID != 3766576001              -- ID группы "Переоформлен"
    GROUP BY U3.N_SUBJECT_ID)
  LOOP
    SI_SUBJECTS_PKG.SI_SUBJ_SUBJECTS_PUT(
      num_N_SUBJ_SUBJECT_ID              => num_N_SUBJ_SUBJECT_ID,
      num_N_SUBJ_BIND_TYPE_ID            => SYS_CONTEXT('CONST', 'SUBJBIND_TYPE_Group'), -- Привязка к группе
      num_N_SUBJECT_ID                   => rc_Users.N_SUBJECT_ID,
      num_N_SUBJECT_BIND_ID              => 3766576001,                                  -- ID группы "Переоформлен"
      ch_C_FL_MAIN                       => 'N');                                        -- Группа не основная
  END LOOP;
END;
/
