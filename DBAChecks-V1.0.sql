use tempdb
SELECT     CONVERT(varchar(200), SERVERPROPERTY('Servername')) AS Server,
(select datediff(dd,min(login_time),getdate()) from master..sysprocesses)  Last_Days_Since_Reboot,
(select case when count(*) =1 then 'Yes' else 'No' End SQLAgent_Running from master..sysprocesses
where program_name='SQLAgent - Generic Refresher') SQLAgent_Running,
--CONVERT(varchar(4), SERVERPROPERTY('ProductVersion')) [SQLVerNo.] ,
cast(db_name() as varchar(20)) + ' Queried' TempDataBaseUP,
   substring(cast( @@VERSION as varchar(28)),10,28) SQL_Version,
   cast(SERVERPROPERTY('Edition') as varchar(100)) EngineEdition,
	  CONVERT(varchar(200), SERVERPROPERTY('ProductLevel')) AS SQL_ProductLevel,
	   CONVERT(varchar(200), SERVERPROPERTY('ProductVersion')) AS SQL_ProductVersion,
	   --vk start
	   (select count(*) from DBASQLADMIN..DiskFreeSpace) As [Total Drives],
	  (select * from DBASQLADMIN..Drives) as Drives,
	   --vk end
case  when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%6.3%' then 'Windows Server 2012 R2'
when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%6.2%' then 'Windows Server 2008 R2'
when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%6.1%' then 'Windows Server 2008 R2'
when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%6.0%' then 'Windows Server 2008'
when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%5.2%' then 'Windows Server 2003 R2'
when RIGHT(@@version, LEN(@@version)- 3 -charindex (' ON ',@@VERSION)) like '%5.2%' then 'Windows Server 2003 R2'
end WindowsVersion,

 cast(substring(cast(@@VERSION as varchar(300)), CHARINDEX('NT ',@@VERSION), 100) as varchar(40)) WindowsServicePack,

          

           
                                           SERVERPROPERTY('Collation') Collation,
           CONVERT(char(100), SERVERPROPERTY('ResourceLastUpdateDateTime')) AS ResourceLastUpdateDateTime,
case WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') 
                      = 1 THEN 'Integrated security' WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 0 THEN 'Not Integrated security' END AS IsIntegratedSecurityOnly, 
 
isnull(CONVERT(varchar(200),SERVERPROPERTY('InstanceName')),'--') AS InstanceName,
  CONVERT(varchar(200), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS, 
                     
                       CASE WHEN CONVERT(char(100), SERVERPROPERTY('IsClustered')) = 1 THEN 'Clustered' WHEN SERVERPROPERTY('IsClustered') 
                      = 0 THEN 'Not Clustered' WHEN SERVERPROPERTY('IsClustered') = NULL THEN 'Error' END AS IsClustered, CASE WHEN CONVERT(char(100), 
                      SERVERPROPERTY('IsFullTextInstalled')) = 1 THEN 'Full-text is installed' WHEN SERVERPROPERTY('IsFullTextInstalled') 
                      = 0 THEN 'Full-text is not installed' WHEN SERVERPROPERTY('IsFullTextInstalled') = NULL THEN 'Error' END AS IsFullTextInstalled,
                                     case cast(@@servername as varchar(100))
when '0CASCADE01' then  'Cascade HR'
when '0LANDSCAPEBP' then  'Landscape Printing'
when 'LANDSCAPEBP' then  'Landscape Printing'
when '0RMSSQLMI01' then  'RMS MI'
when '0SISQL01' then  'SEQUEL, Iras'
when '0SQLCOGNOSLIVE' then  'Cognos BI'
when '0SQLEELIVE01' then  'Earning Engine/Broker DB'
when '0SQLEE01' then  'Earning Engine'
when '0SQLLANDSCAPE01\MI' then  'Landscape MI'
when '0SQLLANDSCAPE02\LSLIVE' then  'Landscape Live'
when '0SQLSUNGARD01' then  'SunGard'
when '0CODASQL01' then  'CODA Server'
when '0UMGPROD01' then  'Online Messaging'
when '0SQLMON01' then  'SolarWinds,Redgate, MDW, CMS'
when '0NAVSQL01' then  'Navigator'

--when '0SQLRMS01' then  'RMS'
--when '0SQLRMS02' then  'RMS'
when '0SQLRMS03' then  'RMS'
when '1SQLRMS03' then  'RMS'
when '2SQLRMS01' then  'RMS'
when '2SQLRMS02' then  'RMS'
when '0SQLRMSIFM01' then  'RMS'
when '0SQLRMSARC01' then  'RMS'
when '2RMSSQLMI01' then  'RMS MI'
-- Added on 07/11/2016 by Vipul Start

when '1sqlWarehouse11' then  'Data Warehouse'
-- Added on 07/11/2016 by Vipul End
when '0HPCPSQL01' then  'ControlPoint: clean data across enterprise systems'
when '0SQLSPOINT01' then  'Sharepoint'
when '0SQLWAREHOUSE01\CDW' then  'Warehouse'
when '0SQLSREP01\MSSQL2K8' then  'Mimecast'

when '1INFSQLMN01' then  'Citirx,Virtual Centre, Trend'
when '1SQLINFN01' then  'Citirx,Virtual Centre, Trend'


when '1LANDSCAPE_PMD1' then  'Landscape PMD'
when '1PROTEUS\PROTEUS' then  'Call Logger'
when '1SMSQLVERIFY01' then  'SQL Verify Server'
when '1SMSQLVERIFY02' then  'SQL Verify Server'
when '1SMSQLVERIFY04' then  'SQL Verify Server'
when '2SMSQLVERIFY01' then  'SQL Verify Server'
when '2SMSQLVERIFY02' then  'SQL Verify Server'
when '2008REPORTING' then  'Reporting Server'
when '2INFSQLMN01' then  'SolarWinds, Citirx,Virtual Centre, Trend'
when '2SQLINFN02' then  'SolarWinds, Citirx,Virtual Centre, Trend'
when '2PRICINGSQL01' then  'Pricing'
when 'BDX_SQL\BDX' then  'BDX'
when 'CLUSTER7' then  'Live Excel Discovery, inventory, data validation and lineage'
when '1CANAIRSQL01' then  'Air'
when 'CANBACKUP' then  'Backup Server'
when 'CANSUBSQL' then  'Subscribe'
when 'CUBL_SUB' then  'Subscribe Bemuda,Zurich'
when 'DEIMOS' then  'Phobos1 Failover/Movement Reports'
when 'DMS-SQL\DMS' then  'DMS Workflow'
when 'DMS-SQL\EPS' then  'DMS Workflow'
when 'ITACSSQL' then  'ITACS'
when 'JUNO' then  'Elgar'
when 'KGM-SQLSVR' then  'Old Helpdesk'
when 'KGMVM-SQL1' then  'WSS_Search_COMPLAINTS, BesMgmt, Interact4'
when 'MARS' then  'Reporting'
when 'MCPSQL\MSSQL2000' then  'Eclipse'
when 'MCPSQL\MSSQL2008' then  'Reporting Server'
when 'MDSSQL' then  'Master Data Services'
when 'Orion' then  'SafeEnd'
when 'PANDORASQL' then  'Pandora'
when 'PHOBOS' then  'Deman,CMS'
when 'PHOBOS1' then  'Subscribe BI'
when 'SOSTENUTO' then  'Web Apps'
when 'SREP' then  'Broker Repository'
when 'SSPBI' then  'Sirius BI'
when 'SSPSQL' then  'Sirius'
when 'SUNDB' then  'Sun Systems'
when 'TARVOS' then  'Eclipse'
when 'UMGPROD' then  'Electronic Messaging'
when 'VKGM-SQL05' then  'Swordfish'
when 'VSOURCEPRO' then  'SourceGear'
when 'XPOSURE' then  'Iras' else '??'
end Application,
(select count(*) from master..sysdatabases) Databse_Total,
(select filename from sysfiles where fileid=1) tempfileloaction