SELECT sn.username, m.sid, m.type, 
        DECODE(m.lmode, 0, 'None', 
                        1, 'Null', 
                        2, 'Row Share', 
                        3, 'Row Excl.', 
                        4, 'Share', 
                        5, 'S/Row Excl.', 
                        6, 'Exclusive', 
                lmode, ltrim(to_char(lmode,'990'))) lmode, 
        DECODE(m.request,0, 'None', 
                         1, 'Null', 
                         2, 'Row Share', 
                         3, 'Row Excl.', 
                         4, 'Share', 
                         5, 'S/Row Excl.', 
                         6, 'Exclusive', 
                         request, ltrim(to_char(m.request, 
                '990'))) request, m.id1, m.id2 
FROM v$session sn, v$lock m 
WHERE (sn.sid = m.sid AND m.request != 0) 
        OR (sn.sid = m.sid 
                AND m.request = 0 AND lmode != 4 
                AND (id1, id2) IN (SELECT s.id1, s.id2 
     FROM v$lock s 
                        WHERE request != 0 
              AND s.id1 = m.id1 
                                AND s.id2 = m.id2) 
                ) 
ORDER BY id1, id2, m.request; 
/
select do.object_name
, row_wait_obj#
, row_wait_file#
, row_wait_block#
, row_wait_row#
, dbms_rowid.rowid_create (1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, 
    ROW_WAIT_BLOCK#, ROW_WAIT_ROW#)
from v$session s
, dba_objects do
where sid=302
and   s.ROW_WAIT_OBJ# = do.OBJECT_ID
/
select /*+ ordered */
 bs.sid, bs.serial# Serial, hk.ctime,
 bs.username||'\'|| bs.osuser||'\'||bs.machine blocker,
 bs.status,
 bs.sql_hash_value sql_hash,
 bs.prev_hash_value Prev_Sql_hash,
 bs.program, bs.module, bs.action, bs.client_info,
 TO_CHAR(bs.logon_time,'hh:mi:ss dd.mm.yyyy') logon_time,
 hk.type,
 case hk.type
   when 'TM' then (select ob.owner || '.' || ob.object_name
                   from dba_objects ob where ob.object_id= hk.id1)
   when 'TX' then (select ob.owner || '.' || ob.object_name ||' / '||
                   dbms_rowid.rowid_create(1, ob.data_object_id,
                   ws.row_wait_file#, ws.row_wait_block#, ws.row_wait_row#)
                   from dba_objects ob where ob.object_id(+)=ws.row_wait_obj#)
 end obj_rowid
FROM
   v$lock hk, v$session bs, v$lock wk, v$session ws
WHERE
     hk.block   = 1
  AND  wk.request  != 0
  AND  wk.TYPE (+) = hk.TYPE
  AND  wk.id1  (+) = hk.id1
  AND  wk.id2  (+) = hk.id2
  AND  hk.sid    = bs.sid(+)
  AND  wk.sid    = ws.sid(+)
  and  bs.lockwait is null
ORDER BY hk.ctime desc
/
