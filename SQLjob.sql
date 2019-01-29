USE [msdb]
GO

/****** Object:  Job [Backup Checks]    Script Date: 06/12/2018 13:44:50 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:50 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup Checks', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CANOPIUS\SQLServiceLive', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PSCheck]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PSCheck', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'SL "d:\results"


.\EPM_EnterpriseEvaluation_412.ps1 -ConfigurationGroup tt -PolicyCategoryFilter mc -EvalMode "Check"', 
		@database_name=N'master', 
		@output_file_name=N'D:\Results\pwresults.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - 10 Weeks Old-Cloned Database Email Alert]    Script Date: 06/12/2018 13:44:51 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:51 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - 10 Weeks Old-Cloned Database Email Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Warehouse Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Warehouse Servers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST Warehouse Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EE Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EE Servers', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST EE Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RMS Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RMS Servers', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST RMS Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SunSystems Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SunSystems Servers', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST SunSystems Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [NAV_CODA_ELGAR Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'NAV_CODA_ELGAR Servers', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST NAV_CODA_ELGAR Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Pricing Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Pricing Servers', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '',  
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST Pricing Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CUBL_SUB_DMS Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CUBL_SUB_DMS Servers', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''cubl_subuat'',''psdmssql'',''sub_uat''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''cubl_subuat'',''psdmssql'',''sub_uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''Helen.Jones@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST CUBL_SUB_DMS Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA Servers', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''DBATEST'',''KGMVM-RDT2'',''0VARONIS''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''DBATEST'',''KGMVM-RDT2'',''0VARONIS'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '',  
@subject = ''REMINDER-Cloned Database Email Alert: >=10 WEEKS OLD Databases on DEV/UAT/TEST DBA Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [KCenter Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'KCenter Servers', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''kcenterdev'',''KCenterUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''kcenterdev'',''KCenterUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST KCenter Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BDX Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BDX Servers', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''BDX_SQLUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''BDX_SQLUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''Ajay.Kumar@canopius.com;Diwakar.Bansal@canopius.com;Abhilash.Patro@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST BDX Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COGNOS_SI_UMG Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COGNOS_SI_UMG Servers', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''Lorraine.Brewster@canopius.com;Maaz.Ali@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST COGNOS_SI_UMG Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WEB_SHAREPOINT Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WEB_SHAREPOINT Servers', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The following databases have exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''REMINDER-Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST WEB_SHAREPOINT Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Live Servers]    Script Date: 06/12/2018 13:44:51 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Live Servers', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND Environment in (''LIVE''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND Environment in (''LIVE'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> Please review the following cloned databases.It is recommended not to have cloned databases in production environment.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: Cloned databases detected on LIVE Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ReminderCloneEmailAlert', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=40, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180710, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'a9614393-633c-401b-95da-2113574ffd28'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - 11+ Weeks Old- Cloned Database Email Alert]    Script Date: 06/12/2018 13:44:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - 11+ Weeks Old- Cloned Database Email Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [ClonedDatabasesEmailAlert]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'ClonedDatabasesEmailAlert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks > ''10'')

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks > ''10'' 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> The following databases have already exceeded the 10 week age policy.Please check with users if the databases are still required.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',  
@body = @body,
@body_format =''HTML'',
@recipients = ''dba.team@canopius.com'', 
@subject = ''REMINDER-Cloned Database Email Alert:11+ WEEKS OLD Databases'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'ClonedDBEmailAlert11weeks', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180710, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'9067e7e2-b0f0-4b65-bb8e-830928684001'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - 9_10 Weeks Old-Cloned Database Email Alert]    Script Date: 06/12/2018 13:44:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - 9_10 Weeks Old-Cloned Database Email Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Warehouse Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Warehouse Servers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com'', 
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST Warehouse Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''Warehouse2'',''Warehouse3'',''Warehouse3_RS'',''Warehouse4'',''Warehouse12'',''2008reportingde'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', 
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com'', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST Warehouse Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EE Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EE Servers', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com'', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST EE Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0SQLDEV2014'',''0SQLEEDEV01'',''0SQLEE01'',''0SQLEEUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''DWHOperations@canopius.com;NIIT-AMSTeam@canopius.com;DBA.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST EE Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [RMS Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'RMS Servers', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST RMS Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0AIRSQLUAT01'',''0RMSSQLMIUAT01'',''0SQLRMSUAT01'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST RMS Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SunSystems Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SunSystems Servers', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST SunSystems Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''DEVSUNDB'',''TESTSUNDB'',''UATSUNDB'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = '' sqldba@canopius.com  '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST SunSystems Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [NAV_CODA_ELGAR Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'NAV_CODA_ELGAR Servers', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST NAV_CODA_ELGAR Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0CODASQLTEST01'',''0NAVSQLCDATST01'',''0NAVSQLTEST01'',''0CODASQLUAT01'',''0NAVSQLUAT01'',''juno-uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = '' NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST NAV_CODA_ELGAR Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Pricing Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Pricing Servers', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST Pricing Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''2PRICINGDEV'',''2PRICINGDEV01'',''2PRICINGUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST Pricing Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CUBL_SUB_DMS Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CUBL_SUB_DMS Servers', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''cubl_subuat'',''psdmssql'',''sub_uat''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''cubl_subuat'',''psdmssql'',''sub_uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''Helen.Jones@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST CUBL_SUB_DMS Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''cubl_subuat'',''psdmssql'',''sub_uat''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''cubl_subuat'',''psdmssql'',''sub_uat'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''Helen.Jones@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST CUBL_SUB_DMS Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DBA Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DBA Servers', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''DBATEST'',''KGMVM-RDT2'',''0VARONIS''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''DBATEST'',''KGMVM-RDT2'',''0VARONIS'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST DBA Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''DBATEST'',''KGMVM-RDT2'',''0VARONIS''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''DBATEST'',''KGMVM-RDT2'',''0VARONIS'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com  '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST DBA Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [KCenter Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'KCenter Servers', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''kcenterdev'',''KCenterUAT''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''kcenterdev'',''KCenterUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = '' NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST KCenter Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''kcenterdev'',''KCenterUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''kcenterdev'',''KCenterUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST KCenter Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [BDX Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'BDX Servers', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''BDX_SQLUAT''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''BDX_SQLUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''Ajay.Kumar@canopius.com;Diwakar.Bansal@canopius.com;Gaurav.Tanwar@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST BDX Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''BDX_SQLUAT''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''BDX_SQLUAT'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''Ajay.Kumar@canopius.com;Diwakar.Bansal@canopius.com;Abhilash.Patro@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST BDX Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COGNOS_SI_UMG Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COGNOS_SI_UMG Servers', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''Lorraine.Brewster@canopius.com;Maaz.Ali@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST COGNOS_SI_UMG Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0UMGTEST01'',''0SISQLUAT01'',''1SQLCOGNOS02'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = ''Lorraine.Brewster@canopius.com;Maaz.Ali@canopius.com;NIIT-AMSTeam@canopius.com;dba.team@canopius.com '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST COGNOS_SI_UMG Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WEB_SHAREPOINT Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WEB_SHAREPOINT Servers', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName in (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''9''AND HostName IN (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> The cloned databases below are about to exceed the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: 9 WEEKS OLD Databases on DEV/UAT/TEST WEB_SHAREPOINT Servers'';

END


if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName in (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04''))

BEGIN
SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND AgeWeeks = ''10''AND HostName IN (''0SQLDEVSPOINT01'',''SQLappWeb03'',''SQLAPPWEB04'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi All <br /> Please ignore this email if you have already responded. <br /> The cloned databases below have already exceeded the 10 week age policy.Please review and let us know when these can be refreshed.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FF0000"> HostName </th> <th bgcolor="#FF0000"> SQL Instance </th> <th bgcolor="#FF0000"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'',
@from_address = ''DBA Team <DBA.Team@canopius.com>'',
@body = @body,
@body_format =''HTML'',
@recipients = '' sqldba@canopius.com  '', 
@subject = ''Cloned Database Email Alert:10 WEEKS OLD Databases on DEV/UAT/TEST WEB_SHAREPOINT Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Live Servers]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Live Servers', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[CloneReport3]
  where type_desc = ''ROWS'' AND Environment in (''LIVE''))

BEGIN

SET @xml = CAST(( SELECT [Hostname] AS ''td'','''',[Server] AS ''td'' ,'''',[dbName] AS ''td''
FROM  [DBASQLADMIN].[dbo].[CloneReport3] 
where
type_desc = ''ROWS'' AND Environment in (''LIVE'') 
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> Please review the following cloned databases.It is  recommended that we do not clone databases to production server.</H4>
<table border = 1> 
<tr>
<th bgcolor="#FFFF00"> HostName </th> <th bgcolor="#FFFF00"> SQL Instance </th> <th bgcolor="#FFFF00"> Database Name </th></tr>''    

SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile
@from_address = ''DBA Team <DBA.Team@canopius.com>'', 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com '', -- replace with your email address
@subject = ''Cloned Database Email Alert: Cloned databases detected on LIVE Servers'';

END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'CloneEmailAlert', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=2, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180709, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'aed51661-c95b-4349-9309-068c8033cf86'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Backup databases]    Script Date: 06/12/2018 13:44:52 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:52 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Backup databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup master]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup master', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database master to disk = ''D:\DailyBackups\master.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup msdb]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup msdb', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database msdb to disk = ''D:\DailyBackups\msdb.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup model]    Script Date: 06/12/2018 13:44:52 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup model', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database model to disk = ''D:\DailyBackups\model.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SWNPM_DB]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SWNPM_DB', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database SWNPM_DB to disk = ''D:\DailyBackups\SWNPM_DB.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup DBASQLADMIN]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup DBASQLADMIN', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database DBASQLADMIN  to disk = ''D:\DailyBackups\DBASQLADMIN.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup CanopiusMonitor]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup CanopiusMonitor', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database CanopiusMonitor to disk = ''D:\DailyBackups\CanopiusMonitor.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup RedGateMonitor]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup RedGateMonitor', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database RedGateMonitor to disk = ''D:\DailyBackups\RedGateMonitor.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Shavlik]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Shavlik', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database Shavlik to disk = ''D:\DailyBackups\Shavlik.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SQLAUDIT]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SQLAUDIT', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database SQLAUDIT to disk = ''D:\DailyBackups\SQLAUDIT.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup AdfsArtifactStore]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup AdfsArtifactStore', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database AdfsArtifactStore to disk = ''D:\DailyBackups\AdfsArtifactStore.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SPM]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SPM', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database SPM to disk = ''D:\DailyBackups\SPM.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup AdfsConfiguration]    Script Date: 06/12/2018 13:44:53 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup AdfsConfiguration', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database AdfsConfiguration to disk = ''D:\DailyBackups\AdfsConfiguration.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup ReleaseLog]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup ReleaseLog', 
		@step_id=13, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database ReleaseLog to disk = ''D:\DailyBackups\ReleaseLog.bak'' with compression, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy to canbackup2]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy to canbackup2', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'copy /Y "\\0sqlmon01\DailyBackups\*.bak"  "\\canbackup2\SQLBackups\0sqlmon01"

', 
		@output_file_name=N'C:\Errorshell.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151030, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'7dd16298-a709-49f2-bf6a-d5b6140565f5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Backup databases PrepPatches]    Script Date: 06/12/2018 13:44:54 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Backup databases PrepPatches', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup master]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup master', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database master to disk = ''D:\DailyBackups\PrepPatches\master.bak'' with compression,copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup msdb]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup msdb', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database msdb to disk = ''D:\DailyBackups\PrepPatches\msdb.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup model]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup model', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database model to disk = ''D:\DailyBackups\PrepPatches\model.bak'' with compression,copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SWNPM_DB]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SWNPM_DB', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database SWNPM_DB to disk = ''D:\DailyBackups\PrepPatches\SWNPM_DB.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup DBASQLADMIN]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup DBASQLADMIN', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database DBASQLADMIN  to disk = ''D:\DailyBackups\PrepPatches\DBASQLADMIN.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup CanopiusMonitor]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup CanopiusMonitor', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database CanopiusMonitor to disk = ''D:\DailyBackups\PrepPatches\CanopiusMonitor.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup RedGateMonitor]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup RedGateMonitor', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database RedGateMonitor to disk = ''D:\DailyBackups\PrepPatches\RedGateMonitor.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Shavlik]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Shavlik', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database Shavlik to disk = ''D:\DailyBackups\PrepPatches\Shavlik.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SQLAUDIT]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SQLAUDIT', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database SQLAUDIT to disk = ''D:\DailyBackups\PrepPatches\SQLAUDIT.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup AdfsArtifactStore]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup AdfsArtifactStore', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database AdfsArtifactStore to disk = ''D:\DailyBackups\PrepPatches\AdfsArtifactStore.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup AdfsConfiguration]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup AdfsConfiguration', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'backup database AdfsConfiguration to disk = ''D:\DailyBackups\PrepPatches\AdfsConfiguration.bak'' with compression, copy_only, init', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy to canbackup2]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy to canbackup2', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'copy /Y "\\0sqlmon01\D:\DailyBackups\PrepPatches\*.bak"  "\\canbackup2\SQLBackups\0SQLMON01\PrepPatches"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Backup Email Alert]    Script Date: 06/12/2018 13:44:54 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Backup Email Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FullBackupEmailAlert]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FullBackupEmailAlert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[LiveDbBackupStatusReport]
where (SQL_Instance NOT LIKE ''%SMSQLVERIFY%'' AND SQL_Instance NOT IN (''0SQLRMSARC01'',''0SQLRMSARC01\RMS'',''1SQLRMS03'')) AND (Backup_Status = ''No Backup Detected'' OR Days_Since_Last_FullBackup >1))

BEGIN
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

SET @xml = CAST(( SELECT [SQL_Instance] AS ''td'','''',[Database_Name] AS ''td''
FROM  [dbo].[LiveDbBackupStatusReport] 
where (SQL_Instance NOT LIKE ''%SMSQLVERIFY%'' AND SQL_Instance NOT IN (''0SQLRMSARC01'',''0SQLRMSARC01\RMS'',''1SQLRMS03'')) AND (Backup_Status = ''No Backup Detected'' OR Days_Since_Last_FullBackup >1)
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> The following databases have not been backed up in the last 24 hours.Please review.</H4>
<table border = 1> 
<tr>
<th bgcolor="#000080"> SQL Instance </th> <th bgcolor="#000080"> Database Name </th></tr>''    

 
SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com'', -- replace with your email address
@subject = ''Daily Database FullBackup Email Alert'' ;
END', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [LogBackupEmailAlert]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'LogBackupEmailAlert', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[LiveDbBackupStatusReport]
 where sql_instance NOT IN (''2SQLINFN02'') AND Recovery_Model = ''FULL'' AND (Hours_Since_Last_LOGBackup >12 OR Hours_Since_Last_LOGBackup IS NULL))

BEGIN
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

SET @xml = CAST(( SELECT [SQL_Instance] AS ''td'','''',[Database_Name] AS ''td''    
  FROM [DBASQLADMIN].[dbo].[LiveDbBackupStatusReport]
 where sql_instance NOT IN (''2SQLINFN02'') AND Recovery_Model = ''FULL'' AND (Hours_Since_Last_LOGBackup >12 OR Hours_Since_Last_LOGBackup IS NULL)
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> The following databases have not been backed up in the last 12 hours.Some of these databases do not require log backup and therefore need changing to simple mode .Please review.</H4>
<table border = 1> 
<tr>
<th bgcolor="#000080"> SQL Instance </th> <th bgcolor="#000080"> Database Name </th></tr>''    

 
SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com'', -- replace with your email address
@subject = ''Daily Database LOGBackup Email Alert'';
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DIFFBackupEmailAlert]    Script Date: 06/12/2018 13:44:54 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DIFFBackupEmailAlert', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DBASQLADMIN]
go

if exists (SELECT *     
  FROM [DBASQLADMIN].[dbo].[LiveDbBackupStatusReport]
where SQL_Instance IN (''1SQLRMS03'') AND (Backup_Status = ''No Backup Detected''  OR Days_Since_Last_DIFFBackup > 1))

BEGIN
DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

SET @xml = CAST(( SELECT [SQL_Instance] AS ''td'','''',[Database_Name] AS ''td''
FROM  [dbo].[LiveDbBackupStatusReport] 
where SQL_Instance IN (''1SQLRMS03'') AND (Backup_Status = ''No Backup Detected'' OR Days_Since_Last_DIFFBackup > 1)
FOR XML PATH(''tr''), ELEMENTS ) AS NVARCHAR(MAX))


SET @body =''<html><body><H4>Hi Team <br /> The following databases have not been backed up in the last 24 hours.Please review.</H4>
<table border = 1> 
<tr>
<th bgcolor="#000080"> SQL Instance </th> <th bgcolor="#000080"> Database Name </th></tr>''    

 
SET @body = @body + @xml +''</table></body></html>''


EXEC msdb.dbo.sp_send_dbmail
@profile_name = ''SQL Mail'', -- replace with your SQL Database Mail Profile 
@body = @body,
@body_format =''HTML'',
@recipients = ''sqldba@canopius.com'', -- replace with your email address
@subject = ''Daily Database DIFFBackup Email Alert'' ;
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'BackupEmailAlert', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180710, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=235959, 
		@schedule_uid=N'b326f1d9-d81e-4613-afcf-f76e985b92eb'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Morning Checks SQL Live Servers]    Script Date: 06/12/2018 13:44:54 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Morning Checks SQL Live Servers', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check Monday to Saturdays all SQL live servers and send a report via email', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Morning Checks SQL Live Servers]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Morning Checks SQL Live Servers', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\Daily_CheckSQlLiveServers2.ps1


', 
		@flags=0, 
		@proxy_name=N'PSProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check SQl Servers LIve Status', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170814, 
		@active_end_date=99991231, 
		@active_start_time=72000, 
		@active_end_time=235959, 
		@schedule_uid=N'2d045ed7-89b4-4fbf-bb9f-1a99e2bd3a42'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check SQL Servers Live Status_Evening', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180518, 
		@active_end_date=99991231, 
		@active_start_time=170000, 
		@active_end_time=235959, 
		@schedule_uid=N'6512e2e5-f89c-45c1-bd44-64e652b78f5d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Morning Checks Verify Jobs]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Morning Checks Verify Jobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check Monday to Saturdays all verification jobs set in live servers and send a report via email', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Verification Jobs Status]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Verification Jobs Status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\CheckVerificationJobstatus.ps1


', 
		@flags=0, 
		@proxy_name=N'PSProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Report_Disk_Space_Monthly_Growth', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=126, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170717, 
		@active_end_date=99991231, 
		@active_start_time=72500, 
		@active_end_time=235959, 
		@schedule_uid=N'298f8039-942d-486b-bf03-46e2ef47177f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - New SQL Server Build Notification]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - New SQL Server Build Notification', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [check for new builds]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'check for new builds', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'IF OBJECT_ID(''tempdb..#top2'') IS NOT NULL
  DROP TABLE #top2

IF OBJECT_ID(''tempdb..#newBuilds'') IS NOT NULL
  DROP TABLE  #newBuilds

set nocount on
GO
with cte_top2
as
(
	select
		* 
	from [dbo].[sqlserverbuildscus] where datestamp in (
	select 
		top 2 max(datestamp) as ds
	from 
		[dbo].[sqlserverbuildscus]
	group by 
		datestamp
	order by 
		max(datestamp) desc
    )
)
select 
	*
into #top2
from 
	cte_top2

/*  can use the DELETE lines to create a test to ensure that the email is generated
-- remove a row from the older of the two record sets to simulate a new build in the latest recordset
select * from #top2 
where DateStamp = ''2018-05-22 02:20:25.000''  and BuldNumber = ''14.0.3025.34''

delete from #top2 
where DateStamp = ''2018-05-22 02:20:25.000''  and BuldNumber = ''14.0.3025.34''


select * from #top2 
where DateStamp = ''2018-05-22 02:20:25.000''  and BuldNumber = ''13.0.5026.0''


delete from #top2 
where DateStamp = ''2018-05-22 02:20:25.000''  and BuldNumber = ''13.0.5026.0''
*/




declare @tDay1 DateTime = (select Max(DateStamp) from #top2 )
declare @tDay2 DateTime = (select Min(DateStamp) from #top2 )

SELECT 
	*
INTO #newBuilds
FROM 
	#top2 
WHERE 
	BuldNumber not in 
	(
		select BuldNumber from #top2 where DateStamp =  @tDay2 
	)
	and
		DateStamp =  @tDay1
ORDER BY 
	DateStamp


IF (SELECT COUNT(*) FROM #newBuilds) > 0
BEGIN
	DECLARE @bodyMsg nvarchar(max)
	DECLARE @subject nvarchar(max)
	DECLARE @tableHTML nvarchar(max)
	DECLARE @Table NVARCHAR(MAX) = N''''

	SET @subject = ''New SQL Server Builds Identified''

	SELECT @Table = @Table +''<tr style="background-color:''+CASE WHEN (ROW_NUMBER() OVER (ORDER BY [DateStamp]))%2 =1 THEN ''#A3E0FF'' ELSE ''#8ED1FB'' END +'';">'' +
	''<td>'' + CONVERT(VARCHAR(30),DateStamp,120) + ''</td>'' +
	''<td>'' + [SQLServerVersion]+ ''</td>'' +
	''<td>'' + [BuldNumber]+ ''</td>'' +
	''<td>'' + [ServicePack] + ''</td>'' +
	''<td>'' + [ItemUpdate] + ''</td>'' +
	''<td>'' + [KBArticle] + ''</td>'' +
	''<td>'' + [ReleaseDate] + ''</td>'' +
	''</tr>''
	FROM #top2 
	where BuldNumber not in 
	(
		select BuldNumber from #top2 where DateStamp =  @tDay2 
	)
	and
		DateStamp =  @tDay1
	ORDER BY DateStamp

	SET @tableHTML = 
	N''<H2><font color="Black">Microsoft SQL Server Build Update Notification</H2>'' +
	N''<H3><font color="Black">ref: https://support.microsoft.com/en-gb/help/321185/how-to-determine-the-version-edition-and-update-level-of-sql-server-an )</H3>'' +
	N''<table border="1" align="left" cellpadding="2" cellspacing="0" style="color:purple;font-family:arial,helvetica,sans-serif;text-align:left;" >'' +
	N''<tr style ="font-size: 14px;font-weight: normal;background: #b9c9fe;">
	<th>DateStamp</th>
	<th>SQLServerVersion</th>
	<th>BuildNumber</th>
	<th>ServicePack</th>
	<th>ItemUpdate</th>
	<th>KBArticle</th>
	<th>ReleaseDate</th></tr>'' + @Table + N''</table>'' 


	--EXEC msdb.dbo.sp_send_dbmail @recipients=''clive.richardson@canopius.com'',
	EXEC msdb.dbo.sp_send_dbmail @recipients=''SQLDBA@canopius.com'',
	 @subject = @subject,
	 @body = @tableHTML,
	 @body_format = ''HTML'' ;

END
ELSE
	PRINT ''No new Builds to Notify''', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180523, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'd582a7ff-bdfb-4164-8cc7-e7109e30f54c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Report_Disk_Space_Monthly_Growth]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Report_Disk_Space_Monthly_Growth', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check Monday to Saturdays Report_Disk_Space_Monthly_Growth and send a report via email', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Report_Disk_Space_Monthly_Growth]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Report_Disk_Space_Monthly_Growth', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\Report_Disk_Space_Monthly_Growth2.ps1


', 
		@flags=0, 
		@proxy_name=N'PSProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Report Non-Production Clones Status', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170825, 
		@active_end_date=99991231, 
		@active_start_time=74000, 
		@active_end_time=235959, 
		@schedule_uid=N'4b01c3b2-0643-4539-aac8-47147122c9e1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Report_Non-Production Clones Status]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Report_Non-Production Clones Status', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check Monday to Fridays Report_Non-Production Clones Status and send a report via email', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CANOPIUS\SQLServiceLive', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Report_Non-Production Clones Status]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Report_Non-Production Clones Status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\NonProductionClonesStatus.ps1


', 
		@flags=0, 
		@proxy_name=N'PSProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'check clone status', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170921, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'c45b318d-264e-41d2-a0c6-9ccce6807aa3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - Rollup and Truncate SQLTLogSizeUsageGrowth]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Rollup and Truncate SQLTLogSizeUsageGrowth', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [rollup and truncate]    Script Date: 06/12/2018 13:44:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'rollup and truncate', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
/*
Author: Clive Richardson
Date: 22 Sep 2017

Description:-
Tran log size and useage data is collected every 15 minutes via the Powershell schedule task...
''Run Powershell for SQL TLog Size Usage Growth''

This query is necessary to rollup the data to record max values for Size and Usage of each Tran Log and then
truncate the source table, SQLTLogSizeUsageGrowth.  This is necessary or it would get too big.
The design of this procedure is that the rollup can be done at any time and it will simply rollup 
whatever rows it finds in SQLTLogSizeUsageGrowth and then truncate.  Suggested schedule is once per day.


*/
-- rollup sum data from [SQLTLogSizeUsageGrowth]
INSERT INTO SQLTLogSizeUsageGrowth_rollup
SELECT 
	max(DateStamp) as DateStamp,
	SQLInstanceName,
	DatabaseName,
	max(LogFileSizeMb) as MaxLogFileSizeMb,
	max(LogFileUsedMb) as MaxLogFileUsedMb
FROM 
	[dbo].[SQLTLogSizeUsageGrowth] WITH (NOLOCK)
GROUP BY 
	SQLInstanceName,DatabaseName

-- Truncate the source table
TRUNCATE TABLE SQLTLogSizeUsageGrowth', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170922, 
		@active_end_date=99991231, 
		@active_start_time=235000, 
		@active_end_time=235959, 
		@schedule_uid=N'c483fe44-000e-427f-bbfa-c8beec13f622'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - SQLAudit-SELECT-LMT]    Script Date: 06/12/2018 13:44:55 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:55 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - SQLAudit-SELECT-LMT', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Audit-SELECT-LMT]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Audit-SELECT-LMT', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/****************************************************/
/* Created by: SQL Server 2012  Profiler          */
/* Date: 26/09/2018  16:18:42         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5 

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N''F:\Audit\TraceSQLAUDIT-SELECT-LMT.trc'', @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 40, 1, @on
exec sp_trace_setevent @TraceID, 40, 4, @on
exec sp_trace_setevent @TraceID, 40, 6, @on
exec sp_trace_setevent @TraceID, 40, 7, @on
exec sp_trace_setevent @TraceID, 40, 8, @on
exec sp_trace_setevent @TraceID, 40, 10, @on
exec sp_trace_setevent @TraceID, 40, 11, @on
exec sp_trace_setevent @TraceID, 40, 12, @on
exec sp_trace_setevent @TraceID, 40, 14, @on
exec sp_trace_setevent @TraceID, 40, 26, @on
exec sp_trace_setevent @TraceID, 40, 30, @on
exec sp_trace_setevent @TraceID, 40, 35, @on
exec sp_trace_setevent @TraceID, 40, 41, @on
exec sp_trace_setevent @TraceID, 40, 50, @on
exec sp_trace_setevent @TraceID, 40, 64, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 1, 0, 6, N''SELECT%LMT%''
exec sp_trace_setfilter @TraceID, 35, 0, 6, N''SQLAUDIT''
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - SystemsBackups Jobs Non-Production Servers Status]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - SystemsBackups Jobs Non-Production Servers Status', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Check Daily SystemsBackups Jobs Non-Production Servers and send a report via email', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SystemsBackups Jobs Non-Production]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SystemsBackups Jobs Non-Production', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\SystemsBackupsJobsNonProduction.ps1


', 
		@flags=0, 
		@proxy_name=N'PSProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SystemsBackups Jobs Non-Production Status', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170823, 
		@active_end_date=99991231, 
		@active_start_time=70000, 
		@active_end_time=235959, 
		@schedule_uid=N'30768021-6b11-40ec-b9bd-069df3402292'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA - VM Excel Import]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - VM Excel Import', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy spreadsheet]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy spreadsheet', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'xcopy "\\Rhea\#rhea\ITShared\Infrastructure\Daily Checks\VMware\RVTools_export_all.xls" C:\Temp\*.*', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [excel import]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'excel import', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'D:
cd PowershellScripts
.\ExcelImportWorksheet1.ps1

', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20171005, 
		@active_end_date=99991231, 
		@active_start_time=83000, 
		@active_end_time=235959, 
		@schedule_uid=N'eafcbfba-0cd3-495c-be17-806a549df309'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA Audit Server Scope Change Event]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Audit Server Scope Change Event', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CANOPIUS\Puneet.Kukreti', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Server Scope Change Alert]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Server Scope Change Alert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @p_subject NVARCHAR(255), @p_action INT, @p_importance VARCHAR (6) , 
	  @p_action_desc NVARCHAR(10), @p_permission NVARCHAR(255), @TextData NVARCHAR(500)

SELECT @p_action = $(ESCAPE_SQUOTE(WMI(EventSubClass))), 
               @p_importance = CASE WHEN $(ESCAPE_SQUOTE(WMI(Success))) = 0 THEN ''High'' ELSE ''Normal'' END,
               @p_action_desc = CASE WHEN @p_action = 1 THEN ''GRANT''
		WHEN @p_action = 3 THEN ''DENY''
		WHEN @p_action = 2 THEN ''REVOKE'' END,
	@TextData  =  LTRIM(RTRIM(REPLACE(''$(ESCAPE_SQUOTE(WMI(TextData)))'', char(9), '' '')))

SELECT  @p_permission =
	LTRIM(RTRIM(SUBSTRING(@TextData, 
	CHARINDEX(@p_action_desc, @TextData, 0)+ LEN(@p_action_desc),
	CHARINDEX(CASE WHEN @p_action = 2 THEN '' FROM '' ELSE '' TO '' END,
	 @TextData, 0) - CHARINDEX(@p_action_desc, @TextData, 0) - LEN(@p_action_desc)) )) 

SELECT  @p_subject = N''WMI Alert: Login [$(ESCAPE_SQUOTE(WMI(TargetLoginName)))] '' + 
		'' - ['' +  @p_permission + ''] '' +
		'' SQL Server Permission ''  + CASE 	WHEN  @p_action = 1 THEN ''granted'' 
		 	WHEN  @p_action = 2 THEN ''revoked'' 
		 	WHEN  @p_action = 3 THEN ''denied'' 
		 	ELSE '''' END + '' on [$(ESCAPE_SQUOTE(WMI(ComputerName)))\$(ESCAPE_SQUOTE(WMI(SQLInstance)))].'' ;

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = ''SQLDBA'',
	@recipients = ''SQLDBA@canopius.com'', 
	@importance = @p_importance ,
	@subject = @p_subject,
	@body = N''Time: $(ESCAPE_SQUOTE(WMI(StartTime))); 
ComputerName: $(ESCAPE_SQUOTE(WMI(ComputerName)));
SQL Instance: $(ESCAPE_SQUOTE(WMI(SQLInstance))); 
Target Login Name: $(ESCAPE_SQUOTE(WMI(TargetLoginName)));
Source Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName)));
Source Host Name: $(ESCAPE_SQUOTE(WMI(HostName)));
Source Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
Source Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
EventSubClass: $(ESCAPE_SQUOTE(WMI(EventSubClass)));
TextData: $(ESCAPE_SQUOTE(WMI(TextData)));
Success: $(ESCAPE_SQUOTE(WMI(Success)));
''; 			', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA Login Add or Delete Alert]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Login Add or Delete Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login add or delete]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login add or delete', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @p_subject NVARCHAR(255), @p_action INT 

SELECT @p_action = $(ESCAPE_SQUOTE(WMI(EventSubClass)))

SELECT  @p_subject = N''WMI Alert: Login [$(ESCAPE_SQUOTE(WMI(ObjectName)))] '' + 
      CASE WHEN  @p_action = 1 THEN ''created on'' 
           WHEN  @p_action = 3 THEN ''dropped from'' 
           ELSE ''changed on'' 
      END + 
      '' [$(ESCAPE_SQUOTE(WMI(ComputerName)))\$(ESCAPE_SQUOTE(WMI(SQLInstance)))].'' ;

EXEC msdb.dbo.sp_send_dbmail
   @profile_name = ''SQLDBA'', -- update with your values
   @recipients = ''SQLDBA@canopius.com'', -- update with your values
   @subject = @p_subject,
   @body = N''Time: $(ESCAPE_SQUOTE(WMI(StartTime))); 
ComputerName: $(ESCAPE_SQUOTE(WMI(ComputerName)));
SQL Instance: $(ESCAPE_SQUOTE(WMI(SQLInstance))); 
Database: $(ESCAPE_SQUOTE(WMI(DatabaseName)));
Target Login Name: $(ESCAPE_SQUOTE(WMI(ObjectName)));
Source Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName)));
Source Host Name: $(ESCAPE_SQUOTE(WMI(HostName)));
Source Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
Source Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
EventSubClass: $(ESCAPE_SQUOTE(WMI(EventSubClass)));
'';
GO	', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA Login Change Alert]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:56 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Login Change Alert', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CANOPIUS\Puneet.Kukreti', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login Change alert]    Script Date: 06/12/2018 13:44:56 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Change alert', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @p_subject NVARCHAR(255), @p_action INT, @p_importance VARCHAR (6)

SELECT @p_action = $(ESCAPE_SQUOTE(WMI(EventSubClass))), 
               @p_importance = CASE WHEN $(ESCAPE_SQUOTE(WMI(Success))) = 0 THEN ''High'' ELSE ''Normal'' END

SELECT @p_subject = N''WMI Alert: Login''''s [$(ESCAPE_SQUOTE(WMI(TargetLoginName)))] '' + 
		CASE 	WHEN  @p_action = 4 THEN ''Credential '' 
		 	WHEN  @p_action = 5 THEN ''Policy '' 
		 	WHEN  @p_action = 6 THEN ''Expiration '' 
		 	ELSE '''' END + 
		''property changed on [$(ESCAPE_SQUOTE(WMI(ComputerName)))\$(ESCAPE_SQUOTE(WMI(SQLInstance)))].'' ;

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = ''SQLDBA'', -- update with your values
	@recipients = ''SQLDBA@canopius.com'', -- update with your values
	@importance = @p_importance ,
	@subject = @p_subject,
	@body = N''Time: $(ESCAPE_SQUOTE(WMI(StartTime))); 
ComputerName: $(ESCAPE_SQUOTE(WMI(ComputerName)));
SQL Instance: $(ESCAPE_SQUOTE(WMI(SQLInstance))); 
Target Login Name: $(ESCAPE_SQUOTE(WMI(TargetLoginName)));
Source Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName)));
Source Host Name: $(ESCAPE_SQUOTE(WMI(HostName)));
Source Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
Source Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
EventSubClass: $(ESCAPE_SQUOTE(WMI(EventSubClass)));
Success: $(ESCAPE_SQUOTE(WMI(Success)));
'';', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA Login Permission Change]    Script Date: 06/12/2018 13:44:56 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA Login Permission Change', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'CANOPIUS\Puneet.Kukreti', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Login Permission Change]    Script Date: 06/12/2018 13:44:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Login Permission Change', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @p_subject NVARCHAR(255), @p_action INT, @p_importance VARCHAR (6) 

SELECT @p_action = $(ESCAPE_SQUOTE(WMI(EventSubClass))), 
       @p_importance = CASE WHEN $(ESCAPE_SQUOTE(WMI(Success))) = 0 THEN ''High'' ELSE ''Normal'' END

SELECT  @p_subject = N''WMI Alert: SQL Server - [$(ESCAPE_SQUOTE(WMI(ComputerName)))\$(ESCAPE_SQUOTE(WMI(SQLInstance)))]. Permissions '' + 
		CASE 	WHEN  @p_action = 1 THEN ''granted'' 
		 	WHEN  @p_action = 2 THEN ''revoked'' 
		 	WHEN  @p_action = 3 THEN ''denied'' 
		 	ELSE '''' END + '' on ['' +
		CASE WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 19539 THEN ''SQL Login''
		WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 19543 THEN ''Windows Login''
		WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 18263 THEN ''Microsoft Windows Group''
		WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 18259 THEN ''Server Role''
		WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 20549 THEN ''Endpoint''
		WHEN $(ESCAPE_SQUOTE(WMI(ObjectType))) = 18241 THEN ''Availability Group''
		ELSE ''Other Server Object'' END + 
		'']:[$(ESCAPE_SQUOTE(WMI(ObjectName)))].'' ;

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = ''SQLDBA'', -- update with your values
	@recipients = ''SQLDBA@canopius.com'', -- update with your values 
	@importance = @p_importance,
	@subject = @p_subject,
	@body = N''Time: $(ESCAPE_SQUOTE(WMI(StartTime))); 
ComputerName: $(ESCAPE_SQUOTE(WMI(ComputerName)));
SQL Instance: $(ESCAPE_SQUOTE(WMI(SQLInstance))); 
Database: $(ESCAPE_SQUOTE(WMI(DatabaseName)));
Target Login Name: $(ESCAPE_SQUOTE(WMI(TargetLoginName)));
Target Object Name: $(ESCAPE_SQUOTE(WMI(ObjectName)));
Source Application Name: $(ESCAPE_SQUOTE(WMI(ApplicationName)));
Source Host Name: $(ESCAPE_SQUOTE(WMI(HostName)));
Source Login Name: $(ESCAPE_SQUOTE(WMI(LoginName)));
Source Session Login Name: $(ESCAPE_SQUOTE(WMI(SessionLoginName)));
EventSubClass: $(ESCAPE_SQUOTE(WMI(EventSubClass)));
Text Data: $(ESCAPE_SQUOTE(WMI(TextData))); 
Success: $(ESCAPE_SQUOTE(WMI(Success)));
''			', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA_CustomJobHistoryPurge]    Script Date: 06/12/2018 13:44:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_CustomJobHistoryPurge', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Custom Purge]    Script Date: 06/12/2018 13:44:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Custom Purge', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [dbo].[spUsrCustomPurgeJobHistory]', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180514, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
		@active_end_time=235959, 
		@schedule_uid=N'297b479e-08bb-4eb9-9c71-2a2512000264'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA_DDL_Events]    Script Date: 06/12/2018 13:44:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_DDL_Events', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DDL]    Script Date: 06/12/2018 13:44:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DDL', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- ensure adequate filtering is applied to the DDL_Events Extended Events Session before enabling email alerts
exec spUsrAlertNewDDLEvents @SendEmailAlerts = 1', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181022, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'b426b766-06fc-43f6-af7e-a71a52c2a78b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA_MergeDBFileGrowths]    Script Date: 06/12/2018 13:44:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_MergeDBFileGrowths', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Merge db file growth info]    Script Date: 06/12/2018 13:44:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Merge db file growth info', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec spUsrMergeDBFileGrowths', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Twice Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=12, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180629, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e2ff28eb-ec9f-4f28-ab7c-3d9dd1387ba1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA_Test]    Script Date: 06/12/2018 13:44:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:57 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_Test', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [test]    Script Date: 06/12/2018 13:44:57 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'test', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'C:\Powershell scripts\test.bat', 
		@output_file_name=N'F:\temptest\test.log', 
		@flags=0, 
		@proxy_name=N'cmdShellProxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBA_UpdateStats]    Script Date: 06/12/2018 13:44:57 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_UpdateStats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Stats]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Stats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE [dbo].[IndexOptimize]
        @Databases = ''USER_DATABASES'' ,
        @FragmentationLow = NULL ,
        @FragmentationMedium = NULL ,
        @FragmentationHigh = NULL ,
        @UpdateStatistics = ''ALL'' ,
        @OnlyModifiedStatistics = N''Y'' ,
        @LogToTable = N''Y'';
', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160615, 
		@active_end_date=99991231, 
		@active_start_time=183000, 
		@active_end_time=235959, 
		@schedule_uid=N'e67f88cc-fa68-4f0a-ad98-5d02ce3a796a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBABackups]    Script Date: 06/12/2018 13:44:58 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBABackups', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=3, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'DBA Job to Backup All Databases', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Dummy start]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Dummy start', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database master]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database master', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE mastellr to disk =''F:\backups\master.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\master.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database model]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database model', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE model to disk =''F:\backups\model.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\model.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup check]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup check', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @tableHTML  NVARCHAR(MAX) ;                          
SET @tableHTML =                 
              
                       
 N''<table width="700" border="0" cellpadding="5" cellspacing="0" >                             
  <tr>                             
  <td height="70" align="right" ><a href="http://phobos:8989/"><img src="http://releases:8989/Canopiuslogo.jpg" alt="Canopius Release Alerts"  border="0" /></a></td>                             
  </tr>                             
<br>                             
                              
  <tr>                             
        <td valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>                             
         '' + '' Backup Check,'' + ''</font></td>                              
        </tr>                             
                              
<tr>                             
    <td valign="middle"  ><font size="2" face="Verdana, Arial, Helvetica, sans-serif">                             
      </a>                  
       
                  <b>Note: Urgent! Please review the Backup Job.</b>            
                   
       <br />                             
      <br />                             
    </font></td>                             
  </tr>                             
  <tr>                             
    <td>                            
                                
    <table border="0" cellpadding="5" cellspacing="1">'' +                      
                          
    N''<th><font size="1" face="verdana, sans-serif">ServerName</th><th><font size="1" face="verdana, sans-serif">JobStep</th><th><font size="1" face="verdana, sans-serif">StepName</th>                        
    <th><font size="1" face="verdana, sans-serif">ErrorMessage</th>'' +                             
      CAST ( (             
                  
                
                           
            select		td = ''<font size="1" face="verdana, sans-serif">'' + server + ''<th></font>'',
						td = ''<font size="1" face="verdana, sans-serif">'' + cast(step_id  as varchar(100)) + ''</font>'', '''', 
                        td = ''<font size="1" face="verdana, sans-serif">'' + step_name + ''</font>'', '''', 
                        td = ''<font size="1" face="verdana, sans-serif">'' + message + ''</font>'', '''' 
                    
                                                      
									                  
   FROM [msdb].[dbo].[sysjobhistory] SH
  INNER JOIN [msdb].[dbo].[sysjobs] SJ
  ON SJ.job_id =SH.job_id
  WHERE NAME =''DBABackups''
  AND sql_severity <>0
  and run_date =convert(varchar (12),getdate(),112)           
                       
              FOR XML PATH(''tr''), TYPE                           
    ) AS NVARCHAR(MAX) ) +                          
    N''</table>''  +              
    N''<a href=><h6></h6></a>''             
    ;                                   
                          
                      
 -- PRINT      @tableHTML               
set @tableHTML = REPLACE( @tableHTML, ''&lt;'', ''<'' );              
set @tableHTML = REPLACE( @tableHTML, ''&gt;'', ''>'' );              
set @tableHTML = REPLACE( @tableHTML, ''&amp;'', ''&'' );                         
                          
EXEC msdb.dbo.sp_send_dbmail         
@recipients =''DBATeam@canopius.com'',
                  
                       
                          
    @subject = ''Backup Job Issue'',                          
    @body = @tableHTML,          
    @importance=''High'',                  
    @body_format = ''HTML''    
  
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Dummy End]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Dummy End', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database msdb]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database msdb', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE msdb to disk =''F:\backups\msdb.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\msdb.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database MDW]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database MDW', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE MDW to disk =''F:\backups\MDW.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\MDW.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database SWNPM_DB]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database SWNPM_DB', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE SWNPM_DB to disk =''F:\backups\SWNPM_DB.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\SWNPM_DB.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database RedGateMonitor]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database RedGateMonitor', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE RedGateMonitor to disk =''F:\backups\RedGateMonitor.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\RedGateMonitor.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database SQLAUDIT]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database SQLAUDIT', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE SQLAUDIT to disk =''F:\backups\SQLAUDIT.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\SQLAUDIT.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database vbvb]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database vbvb', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE vbvb to disk =''F:\backups\vbvb.bak'' with init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\vbvb.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CopyBackup]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CopyBackup', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'F:\backups\CopyBackup.bat', 
		@output_file_name=N'F:\backups\CopyBackup.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBABackups_old]    Script Date: 06/12/2018 13:44:58 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBABackups_old', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'DBA Job to Backup All Databases', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Dummy start]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Dummy start', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database master]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database master', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE master to disk =''F:\backups\master.bak'' with compression, init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\master.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database model]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database model', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE model to disk =''F:\backups\model.bak'' with compression, init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\model.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database msdb]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database msdb', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' BACKUP DATABASE msdbddd to disk =''F:\backups\msdb.bak'' with compression, init  ', 
		@database_name=N'master', 
		@output_file_name=N'F:\backups\msdb.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup check]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup check', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @tableHTML  NVARCHAR(MAX) ;                          
SET @tableHTML =                 
              
                       
 N''<table width="700" border="0" cellpadding="5" cellspacing="0" >                             
  <tr>                             
  <td height="70" align="right" ><a href="http://phobos:8989/"><img src="http://releases:8989/Canopiuslogo.jpg" alt="Canopius Release Alerts"  border="0" /></a></td>                             
  </tr>                             
<br>                             
                              
  <tr>                             
        <td valign="middle"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><br>                             
         '' + '' Backup Check,'' + ''</font></td>                              
        </tr>                             
                              
<tr>                             
    <td valign="middle"  ><font size="2" face="Verdana, Arial, Helvetica, sans-serif">                             
      </a>                  
       
                  <b>Note: Urgent! Please review the Backup Job.</b>            
                   
       <br />                             
      <br />                             
    </font></td>                             
  </tr>                             
  <tr>                             
    <td>                            
                                
    <table border="0" cellpadding="5" cellspacing="1">'' +                      
                          
    N''<th><font size="1" face="verdana, sans-serif">ServerName</th><th><font size="1" face="verdana, sans-serif">JobStep</th><th><font size="1" face="verdana, sans-serif">StepName</th>                        
    <th><font size="1" face="verdana, sans-serif">ErrorMessage</th>'' +                             
      CAST ( (             
                  
                
                           
            select		td = ''<font size="1" face="verdana, sans-serif">'' + server + ''<th></font>'',
						td = ''<font size="1" face="verdana, sans-serif">'' + cast(step_id  as varchar(100)) + ''</font>'', '''', 
                        td = ''<font size="1" face="verdana, sans-serif">'' + step_name + ''</font>'', '''', 
                        td = ''<font size="1" face="verdana, sans-serif">'' + message + ''</font>'', '''' 
                    
                                                      
									                  
          FROM [msdb].[dbo].[sysjobhistory] SH
  INNER JOIN [msdb].[dbo].[sysjobs] SJ
  ON SJ.job_id =SH.job_id
  WHERE NAME =''DBABackups''
  AND sql_severity <>0
  and run_date =convert(varchar (12),getdate(),112)           
                       
              FOR XML PATH(''tr''), TYPE                           
    ) AS NVARCHAR(MAX) ) +                          
    N''</table>''  +              
    N''<a href=><h6></h6></a>''             
    ;                                   
                          
                      
 -- PRINT      @tableHTML               
set @tableHTML = REPLACE( @tableHTML, ''&lt;'', ''<'' );              
set @tableHTML = REPLACE( @tableHTML, ''&gt;'', ''>'' );              
set @tableHTML = REPLACE( @tableHTML, ''&amp;'', ''&'' );                         
                          
EXEC msdb.dbo.sp_send_dbmail         
@recipients =''DBATeam@canopius.com'',
                  
                       
                          
    @subject = ''Backup Job Issue'',                          
    @body = @tableHTML,          
    @importance=''High'',                  
    @body_format = ''HTML''    
  
', 
		@database_name=N'test', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Dummy End]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Dummy End', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CopyBackup]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CopyBackup', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'F:\backups\CopyBackup.bat', 
		@output_file_name=N'F:\backups\CopyBackup.log', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [DBASQLMonitor]    Script Date: 06/12/2018 13:44:58 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:58 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBASQLMonitor', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SQLMonitor]    Script Date: 06/12/2018 13:44:58 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SQLMonitor', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'INSERT INTO SQLMonitorTable
SELECT T.text, P.query_plan, S.host_name, S.program_name, S.client_interface_name, S.login_name, R.*
FROM sys.dm_exec_requests R
JOIN sys.dm_exec_sessions S on S.session_id=R.session_id
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS T
CROSS APPLY sys.dm_exec_query_plan(plan_handle) As P', 
		@database_name=N'DBASQLADMIN', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [Email Release Alert]    Script Date: 06/12/2018 13:44:59 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:59 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Email Release Alert', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Update tasks then send email to alert users of releases', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email]    Script Date: 06/12/2018 13:44:59 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec Usp_DailyAssignedReleaseAlertnew

exec  Usp_DailyRequestedReleaseAlertnew

exec  Usp_TodaysReleaseAlertNew







', 
		@database_name=N'ReleaseLog', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Alert', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20101109, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=235959, 
		@schedule_uid=N'30cd8c6e-0f46-4c74-8459-97538e2d4317'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

/****** Object:  Job [ReleaseLogFolder]    Script Date: 06/12/2018 13:44:59 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 06/12/2018 13:44:59 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ReleaseLogFolder', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Folder Creation]    Script Date: 06/12/2018 13:44:59 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Folder Creation', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @releaseid int
DECLARE @CMDSQL VARCHAR(1000)  
select @releaseid = max(releaseid) from ReleaseLog..WorkFlow
SET @CMDSQL =''XCOPY /I /E /R /Y "\\titan\ITShared\Releases\Release Notes\Files"    "\\titan\ITShared\Releases\Release Notes\Release"'' +  cast(@releaseid as varchar(20))
print @CMDSQL
EXEC  master..xp_CMDShell @CMDSQL


', 
		@database_name=N'master', 
		@output_file_name=N'C:\Releaselog\Releaselog.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


