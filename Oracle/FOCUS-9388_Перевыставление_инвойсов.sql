--Перевыставление инвойсов за июнь
declare
  dt_D_OPER_BEGIN DATE := TO_DATE('01.06.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS');
  n_Num           NUMBER := 0;
begin 
  for rc_inv in(select n_doc_id,
                       vc_doc_no,
                       n_subject_id,
                       vc_subj_code,
                       n_subj_good_id,
                       d_time
                from (select it.n_doc_id,
                             it.vc_doc_no,
                             ds.n_subject_id,
                             ds.vc_subj_code,
                             it.n_reason_doc_id,
                             gmt.n_object_id,
                             gmt.n_subj_good_id,
                             it.d_time,
                             it.d_end_initial,
                             ROW_NUMBER() OVER (PARTITION BY gmt.n_subj_good_id, ds.n_subject_id, it.n_reason_doc_id, gmt.n_object_id ORDER BY it.d_time ) n_row
                      from sd_v_invoices_t    it,
                           si_v_doc_subjects  ds,
                           sr_v_goods         g,
                           si_v_user_goods    ug,
                           SD_V_GOOD_MOVES_T  gmt
                      where it.n_doc_state_id     = SYS_CONTEXT('CONST', 'DOC_STATE_Executed') -- Выполнен
                      and   it.n_doc_id           = ds.n_doc_id
                      --and ds.n_subject_id  = 142991891
                      and   ds.n_doc_role_id      = SYS_CONTEXT('CONST', 'SUBJ_ROLE_Receiver') -- Получатель/Клиент
                      and   gmt.n_doc_id          = it.n_doc_id
                      and   gmt.d_begin between TO_DATE('01.06.2014 00:00:01', 'DD.MM.YYYY HH24:MI:SS')
                                            and TO_DATE('30.06.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
                      and   gmt.d_end             = TO_DATE('30.06.2014 23:59:59', 'DD.MM.YYYY HH24:MI:SS')
                      and   gmt.n_good_id         = g.n_good_id
                      and   g.n_parent_good_id in (50724501, -- Тарифы на телефонию для физических лиц
                                                   40216301) -- Тарифы на телефонию для юридических лиц  
                      and   ug.n_doc_id           = it.n_reason_doc_id
                      and   ug.n_subject_id       = ds.n_subject_id
                      and   ug.n_subj_good_id     = gmt.n_subj_good_id
                      and   ug.d_begin           <= TO_DATE('01.06.2014 00:00:00', 'DD.MM.YYYY HH24:MI:SS')
                      group by it.n_doc_id, it.vc_doc_no, ds.n_subject_id, ds.vc_subj_code, gmt.n_object_id, gmt.n_subj_good_id, it.n_reason_doc_id, it.d_time, it.d_end_initial
                      order by ds.n_subject_id) user_invoices
                where user_invoices.n_row = 1
                group by n_doc_id,vc_doc_no,n_subject_id, vc_subj_code, n_subj_good_id, d_time)
  loop
  
      sd_documents_pkg.SD_DOCUMENTS_CHANGE_STATE(
        num_N_DOC_ID                => rc_inv.n_doc_id,
        num_N_New_DOC_STATE_ID      => SYS_CONTEXT('CONST', 'DOC_STATE_Canceled'));
  
      sd_invoices_pkg.TT_PREPARE_INVOICES(
        num_N_USER_ID               => rc_inv.n_subject_id,
        dt_D_OPER_BEGIN             => dt_D_OPER_BEGIN);
      
      DELETE FROM  TT_V_INV_USER_SERVS
      WHERE  N_SUBJ_GOOD_ID NOT IN (SELECT N_SUBJ_GOOD_ID
                                    FROM  SI_SUBJ_GOODS
                                    WHERE  N_PAR_SUBJ_GOOD_ID = rc_inv.n_subj_good_id
                                    UNION ALL
                                    SELECT rc_inv.n_subj_good_id
                                    FROM  DUAL);
                                   
      sd_invoices_pkg.SD_INVOICES_AUTOCREATE(
        num_N_USER_ID               => rc_inv.n_subject_id,
        b_Refill                    => MAIN.b_FALSE);
    
     n_Num := n_Num + 1;
     
     dbms_output.put_line( n_Num || '. Код абонента: ' || rc_inv.vc_subj_code || ', аннулированный инвойс: ' || rc_inv.vc_doc_no );
 
  end loop;
end;
/
