set linesize 120
col sid for 999
col username for a14 trunc
col osuser for a18 trunc
col spid for 99990
col logon_time for a12
col status for a9 trunc
col machine for a26 trunc
col running for a10 trunc
select s.sid,
       s.serial#, 
       s.username,
       s.osuser,
       s.machine,
       s.status,
       p.spid spid,
       to_char( logon_time, 'Mon dd@hh24:mi') logon_time
       rtrim (s.module)||decode( nvl(length( rtrim(s.module)),0),0,'',' ')|| upper(s.program) running,
from v$session   s,
     v$process   p
where ( p.addr = s.paddr ) and s.type!='BACKGROUND'
and upper(s.program) not like '%CJQ0%' and s.program is not null and s.username is not null 
order by s.sid;
