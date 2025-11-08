use db_project
GO
--adagidő kiszámítása
select *, (datediff(minute, kezdet, vege)) as "adagido" from adagok
GO
--adagközi idő kiszámítása
select *, case when (datediff(minute, a.kezdet, 
(select a1.vege from adagok as a1 where adagszam = (a.adagszam - 1))))
is null then 0 else 
(datediff(minute, a.kezdet, 
(select a1.vege from adagok as a1 where adagszam = (a.adagszam - 1)))) end as adagkoz
from adagok as a
GO
--átlag, min, max hőmérséklet az adott adag időpontok között a panel1-en
select *,case when
(select avg(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege)
is null then 0 
else
(select avg(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege)
end as "p1 atlag",
case when (select max(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) is null then 0
else (select max(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) end as "p1 max",
case when (select min(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) is null then 0
else (select min(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) end as "p1 min"
from adagok as a
GO
--balra joinolom a panelek eredményeit az adagokhoz, az idővel kapcsolva
select * from adagok as a
left join panelek as p on p.time between a.kezdet and a.vege
order by adagszam asc
go
--ez már csak ilyen túlbonyolított query, az összes panel átlagával és csak azokkal az adagokkal, melyek
--időpontjaiban volt panel hőfokadat
select *,
(select avg(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) as p1_avg,
(select avg(p.panel2) from panelek as p
where p.time between a.kezdet and a.vege) as p2_avg,
(select avg(p.panel3) from panelek as p
where p.time between a.kezdet and a.vege) as p3_avg,
(select avg(p.panel4) from panelek as p
where p.time between a.kezdet and a.vege) as p4_avg,
(select avg(p.panel5) from panelek as p
where p.time between a.kezdet and a.vege) as p5_avg,
(select avg(p.panel6) from panelek as p
where p.time between a.kezdet and a.vege) as p6_avg,
(select avg(p.panel8) from panelek as p
where p.time between a.kezdet and a.vege) as p8_avg,
(select avg(p.panel9) from panelek as p
where p.time between a.kezdet and a.vege) as p9_avg,
(select avg(p.panel10) from panelek as p
where p.time between a.kezdet and a.vege) as p10_avg,
(select avg(p.panel11) from panelek as p
where p.time between a.kezdet and a.vege) as p11_avg,
(select avg(p.panel12) from panelek as p
where p.time between a.kezdet and a.vege) as p12_avg,
(select avg(p.panel13) from panelek as p
where p.time between a.kezdet and a.vege) as p13_avg,
(select avg(p.panel14) from panelek as p
where p.time between a.kezdet and a.vege) as p14_avg,
(select avg(p.panel15) from panelek as p
where p.time between a.kezdet and a.vege) as p15_avg 
from adagok as a
where (select avg(p.panel1) from panelek as p
where p.time between a.kezdet and a.vege) is not null
order by adagszam asc
go
