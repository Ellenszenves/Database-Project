USE master
GO
DROP DATABASE IF EXISTS db_project
GO
CREATE DATABASE db_project
GO
--creating login
USE db_project
GO
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'db_admin')
CREATE LOGIN [db_admin] WITH PASSWORD=N'admin', DEFAULT_DATABASE=[db_project], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'db_reader')
CREATE LOGIN [db_reader] WITH PASSWORD=N'reader', DEFAULT_DATABASE=[db_project], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'db_writer')
CREATE LOGIN [db_writer] WITH PASSWORD=N'writer', DEFAULT_DATABASE=[db_project], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
--creating user
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'db_admin')
CREATE USER [db_admin] FOR LOGIN [db_admin] WITH DEFAULT_SCHEMA=[dbo]
GO
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'db_reader')
CREATE USER [db_reader] FOR LOGIN [db_reader] WITH DEFAULT_SCHEMA=[dbo]
GO
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'db_writer')
CREATE USER [db_writer] FOR LOGIN [db_writer] WITH DEFAULT_SCHEMA=[dbo]
GO
--add role
ALTER ROLE db_owner ADD MEMBER db_admin
ALTER ROLE [db_datareader] ADD MEMBER db_reader
ALTER ROLE [db_datawriter] ADD MEMBER db_writer
GO
--adag data
drop table if exists new_adagok
go
create table new_adagok (adagszam int, kezdet_datum date,
kezdet_ido time, vege_datum date, vege_ido time, adagkozi int, 
adagido int)
go
BULK INSERT dbo.new_adagok
    FROM 'C:\Adagok.csv'
    WITH
    (FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK)
go
drop table if exists adagok
go
create table adagok (adagszam INT IDENTITY(1, 1) PRIMARY KEY, kezdet datetime, vege datetime)
go
insert into adagok (adagszam, kezdet, vege)
select adagszam, cast(kezdet_datum as datetime) + cast(kezdet_ido as datetime), 
cast(vege_datum as datetime) + cast(vege_ido as datetime) from dbo.new_adagok
go
delete from adagok where adagszam is null
go
drop table new_adagok
go
--panel data
Drop table if exists new_panelek
go
create table new_panelek (time1 datetime, panel1 varchar(256), 
time2 datetime, panel2 varchar(256), time3 datetime, panel3 varchar(256), time4 datetime, panel4 varchar(256),
time5 datetime, panel5 varchar(256), time6 datetime, panel6 varchar(256), time8 datetime, panel8 varchar(256),
time9 datetime, panel9 varchar(256), time10 datetime, panel10 varchar(256), time11 datetime, panel11 varchar(256),
time12 datetime, panel12 varchar(256), time13 datetime, panel13 varchar(256), time14 datetime, panel14 varchar(256),
time15 datetime, panel15 varchar(256))
go
BULK INSERT new_panelek
    FROM 'C:\Hűtőpanelek.csv'
    WITH
    (FORMAT ='CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    TABLOCK)
go
drop table if exists panelek
go
CREATE TABLE panelek (id INT IDENTITY(1, 1) PRIMARY KEY, time datetime, panel1 float, panel2 float, panel3 float, 
    panel4 float, panel5 float, panel6 float, panel8 float, panel9 float, panel10 float, panel11 float, panel12 float,
    panel13 float, panel14 float, panel15 float)
go
insert into panelek (time, panel1, panel2, panel3, panel4, panel5, panel6, panel8, 
    panel9, panel10, panel11, panel12, panel13, panel14, panel15)
select time1, cast(replace(panel1, ',', '.') as float), cast(replace(panel2, ',', '.') as float),
cast(replace(panel3, ',', '.') as float), cast(replace(panel4, ',', '.') as float), cast(replace(panel5, ',', '.') as float),
cast(replace(panel6, ',', '.') as float), cast(replace(panel8, ',', '.') as float), cast(replace(panel9, ',', '.') as float),
cast(replace(panel10, ',', '.') as float), cast(replace(panel11, ',', '.') as float), cast(replace(panel12, ',', '.') as float),
cast(replace(panel13, ',', '.') as float), cast(replace(panel14, ',', '.') as float), cast(replace(panel15, ',', '.') as float)
from new_panelek
go
drop table new_panelek
go
select * from panelek
go