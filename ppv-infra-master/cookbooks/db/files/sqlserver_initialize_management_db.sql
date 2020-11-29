USE [master]
GO

PRINT N'backup_dir = $(backup_dir)'
PRINT N'data_dir = $(data_dir)'
PRINT N'log_dir = $(log_dir)'
PRINT N'remote_save_command = $(remote_save_command)'
PRINT N'backup_user = $(backup_user)'
PRINT N'';
PRINT N'==========================================================================';
PRINT N'Dropping the $(management_database) Database';
PRINT N'==========================================================================';

IF DB_ID(upper('$(management_database)')) IS NOT NULL
       EXEC sp_executesql N'alter database [$(management_database)] set single_user with rollback immediate;DROP DATABASE [$(management_database)]';
GO

DECLARE  @create_mgmt_db_sql nvarchar(max)
      ,  @data_dir  nvarchar(max)
      ,  @log_dir nvarchar(max)

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating the $(management_database) Database';
PRINT N'==========================================================================';

SET @create_mgmt_db_sql = N'
CREATE DATABASE [$(management_database)]
    CONTAINMENT = NONE
    ON  PRIMARY
        (
         NAME = N''$(management_database)'',
         FILENAME = N''$(data_dir)\$(management_database).mdf'' ,
         SIZE = 5120KB,
         MAXSIZE = UNLIMITED,
         FILEGROWTH = 1024KB
        )
    LOG ON
        (
            NAME = N''$(management_database)_log'',
            FILENAME = N''$(log_dir)\$(management_database)_log.ldf'' ,
            SIZE = 1024KB,
            MAXSIZE = 2048GB,
            FILEGROWTH = 10%
        )
';

EXEC sp_executesql @create_mgmt_db_sql
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating the Stored Procedutes in $(management_database) Database';
PRINT N'==========================================================================';

USE [$(management_database)]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[BackupDatabaseFull]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[BackupDatabaseFull]
    @databaseName     nvarchar(150)
AS
BEGIN
    DECLARE @backslash nvarchar(1) = char(92)
    DECLARE @time_stamp nvarchar(20) = FORMAT(DATEPART(yyyy,GETDATE()), 'd2')  + '-' + FORMAT(DATEPART(mm,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(dd,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(hh,GETDATE()), 'd2') + FORMAT(DATEPART(minute,GETDATE()), 'd2') 
    DECLARE @backup_file_name nvarchar(max) = N'$(backup_dir)' + @backslash + @databaseName + '_' + @time_stamp +  '_Full.bak'
    DECLARE @sql nvarchar(max) = 'BACKUP DATABASE [' + @databaseName + '] TO  DISK = ''' + @backup_file_name
    + ''' WITH FORMAT, INIT,  NAME = N''' + @databaseName + '-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM'
    EXEC sp_executesql @sql

	DECLARE @backup_set_id as int;
	SELECT @backup_set_id = position FROM msdb..backupset
	WHERE database_name=@databaseName
		AND backup_set_id=(SELECT MAX(backup_set_id)
	FROM msdb..backupset
	WHERE database_name=@databaseName );

	DECLARE @failure_message nvarchar(max)=N'Verify failed. Backup information for database '''+@databaseName+N''' not found.'
	IF @backup_set_id IS NULL BEGIN raiserror(@failure_message, 16, 1) END;
	DECLARE @errorcode nvarchar(max);
	RESTORE VERIFYONLY FROM DISK = @backup_file_name WITH  FILE = @backup_set_id,  NOUNLOAD,  NOREWIND;
	SELECT @errorcode = @@ERROR
	DECLARE @verify_failiure_message nvarchar(max)=N'Verify failed. Restore with verify only failed: Error: '+ @errorcode +'. File: '''+@backup_file_name+N'''. '
	if @errorcode <> 0 BEGIN raiserror(@verify_failiure_message, 16, 1) END;
END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[BackupDatabaseDifferential]';
PRINT N'==========================================================================';
GO
CREATE PROCEDURE [dbo].[BackupDatabaseDifferential]
    @databaseName nvarchar(150)
AS
BEGIN
    DECLARE @backslash nvarchar(1) = char(92)
    DECLARE @time_stamp nvarchar(20) = FORMAT(DATEPART(yyyy,GETDATE()), 'd2')  + '-' + FORMAT(DATEPART(mm,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(dd,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(hh,GETDATE()), 'd2') + FORMAT(DATEPART(minute,GETDATE()), 'd2') 
    DECLARE @backup_file_name nvarchar(max) = N'$(backup_dir)' + @backslash + @databaseName + '_' + @time_stamp +  '_Differential.bak'
    DECLARE @sql nvarchar(max) = 'BACKUP DATABASE [' + @databaseName + '] TO  DISK = ''' + @backup_file_name
    + ''' WITH DIFFERENTIAL, FORMAT, INIT,  NAME = N''' + @databaseName + '-Differentail Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM'
    EXEC sp_executesql @sql

	DECLARE @backup_set_id as int;
	SELECT @backup_set_id = position FROM msdb..backupset
	WHERE database_name=@databaseName
		AND backup_set_id=(SELECT MAX(backup_set_id)
	FROM msdb..backupset
	WHERE database_name=@databaseName );

	DECLARE @failure_message nvarchar(max)=N'Verify failed. Backup information for database '''+@databaseName+N''' not found.'
	IF @backup_set_id IS NULL BEGIN raiserror(@failure_message, 16, 1) END;

	DECLARE @errorcode nvarchar(max);
	RESTORE VERIFYONLY FROM DISK = @backup_file_name WITH  FILE = @backup_set_id,  NOUNLOAD,  NOREWIND;
	SELECT @errorcode = @@ERROR
	DECLARE @verify_failiure_message nvarchar(max)=N'Verify failed. Restore with verify only failed: Error: '+ @errorcode +'. File: '''+@backup_file_name+N'''. '
	if @errorcode <> 0 BEGIN raiserror(@verify_failiure_message, 16, 1) END;
END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[BackupDatabaseTransactionLogs]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[BackupDatabaseTransactionLogs]
    @databaseName nvarchar(150)
AS
BEGIN
    DECLARE @backslash nvarchar(1) = char(92)
    DECLARE @time_stamp nvarchar(20) = FORMAT(DATEPART(yyyy,GETDATE()), 'd2')  + '-' + FORMAT(DATEPART(mm,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(dd,GETDATE()), 'd2')  +'-'+ FORMAT(DATEPART(hh,GETDATE()), 'd2') + FORMAT(DATEPART(minute,GETDATE()), 'd2') 
    DECLARE @backup_file_name nvarchar(max) = N'$(backup_dir)' + @backslash + @databaseName + '_' + @time_stamp +  '_Transactions.trn'
    DECLARE @sql nvarchar(max) = 'BACKUP LOG [' + @databaseName + '] TO  DISK = ''' + @backup_file_name
    + ''' WITH FORMAT, INIT,  NAME = N''' + @databaseName + '-Transaction Log Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10'
    EXEC sp_executesql @sql
END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[ScheduleBackup]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[ScheduleBackup]
      @databaseName nvarchar(150)
    , @backup_user nvarchar(150)
    , @jobName nvarchar(max)
    , @backup_step_name nvarchar(max)
    , @backup_step_command nvarchar(max)
    , @remote_save_step_name nvarchar(max)
    , @remote_save_step_command nvarchar(max)
    , @schedule_name nvarchar(max)
    , @schedule_frequency_type tinyint
    , @schedule_frequency_interval tinyint
    , @schedule_start_time int
    , @schedule_freq_subday_type tinyint
    , @schedule_freq_subday_interval tinyint
AS
BEGIN
    BEGIN TRANSACTION
    DECLARE @ReturnCode INT = 0

    IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
    END

    DECLARE @jobId BINARY(16)

    SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = @jobName)
    IF (@jobId IS NOT NULL)
    BEGIN
        EXEC msdb.dbo.sp_delete_job @jobId
        SET @jobId = NULL
    END

    EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@jobName,
            @enabled=1,
            @notify_level_eventlog=2,
            @notify_level_email=0,
            @notify_level_netsend=0,
            @notify_level_page=0,
            @delete_level=0,
            @description=N'No description available.',
            @category_name=N'Database Maintenance',
            @owner_login_name=@backup_user, @job_id = @jobId OUTPUT
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@backup_step_name,
            @step_id=1,
            @cmdexec_success_code=0,
            @on_success_action=3,
            @on_success_step_id=0,
            @on_fail_action=2,
            @on_fail_step_id=0,
            @retry_attempts=0,
            @retry_interval=0,
            @os_run_priority=0, @subsystem=N'TSQL',
            @command=@backup_step_command,
            @database_name=N'$(management_database)',
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@remote_save_step_name,
            @step_id=2,
            @cmdexec_success_code=0,
            @on_success_action=1,
            @on_success_step_id=0,
            @on_fail_action=2,
            @on_fail_step_id=0,
            @retry_attempts=0,
            @retry_interval=0,
            @os_run_priority=0, @subsystem=N'PowerShell',
            @command=@remote_save_step_command,
            @database_name=N'$(management_database)',
            @flags=0
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--   PRINT 'Creating Schedule for the Job ' + CAST(@jobId   AS NVARCHAR(MAX))
--   PRINT 'freq_type : ' + ISNULL(cast(@schedule_frequency_type as Nvarchar(max)),'Empty')
--   PRINT 'freq_interval : ' + ISNULL(cast(@schedule_frequency_interval as Nvarchar(max)),'Empty')
--   PRINT 'freq_subday_type : ' + ISNULL(cast(@schedule_freq_subday_type as Nvarchar(max)),'Empty')
--   PRINT 'schedule_freq_subday_interval : ' + ISNULL(cast(@schedule_freq_subday_interval as Nvarchar(max)),'Empty')

    declare @job_uid uniqueidentifier = newid()

    EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@schedule_name,
        @enabled=1,
        @freq_type=@schedule_frequency_type,
        @freq_interval=@schedule_frequency_interval,
        @freq_subday_type=@schedule_freq_subday_type,
        @freq_subday_interval=@schedule_freq_subday_interval,
        @freq_relative_interval=0,
        @freq_recurrence_factor=1,
        @active_start_date=20160414,
        @active_end_date=99991231,
        @active_start_time=@schedule_start_time,
        @active_end_time=235959,
        @schedule_uid=@job_uid
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

    COMMIT TRANSACTION
    GOTO EndSave

    QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

    EndSave:
END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[ScheduleWeeklyFullBackup]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[ScheduleWeeklyFullBackup]
      @databaseName nvarchar(150)
    , @backup_user nvarchar(150)
    , @remote_save_command nvarchar(100)
    , @schedule_frequency_interval tinyint
    , @schedule_start_time int
AS
BEGIN
    DECLARE @backup_file_name nvarchar(max)

    DECLARE @job_name nvarchar(max) = @databaseName + N'-MaintenancePlan.Full Database Backup'
    DECLARE @backup_step_name nvarchar(max) = @databaseName + N': Run Full Backup'
    DECLARE @backup_step_command nvarchar(max) = 'EXEC [dbo].[BackupDatabaseFull] @databaseName=''' + @databaseName + ''''
    DECLARE @remote_save_step_name nvarchar(max) = @databaseName + N': Run Full Backup : Save to backup location'
    DECLARE @remote_save_step_command nvarchar(max) = @remote_save_command + ' ''' + @databaseName + ''' ''D'''
    DECLARE @schedule_name nvarchar(max) = @databaseName + N': Run Full Backup: Weekly Schedule'


    EXEC [dbo].[ScheduleBackup]
          @databaseName = @databaseName
        , @backup_user = @backup_user
        , @jobName = @job_name
        , @backup_step_name = @backup_step_name
        , @backup_step_command = @backup_step_command
        , @remote_save_step_name = @remote_save_step_name
        , @remote_save_step_command = @remote_save_step_command
        , @schedule_name = @schedule_name
        , @schedule_frequency_type = 8
        , @schedule_frequency_interval = @schedule_frequency_interval
        , @schedule_start_time = @schedule_start_time
        , @schedule_freq_subday_type=1
        , @schedule_freq_subday_interval=1

END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[ScheduleDailyDifferentialBackup]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[ScheduleDailyDifferentialBackup]
      @databaseName nvarchar(150)
    , @backup_user nvarchar(150)
    , @remote_save_command nvarchar(max)
    , @schedule_frequency_interval tinyint
    , @schedule_start_time int
AS
BEGIN
    DECLARE @job_name nvarchar(max) = @databaseName + N'-MaintenancePlan.Differential Database Backup'
    DECLARE @backup_step_name nvarchar(max) = @databaseName + N': Run Differential Backup'
    DECLARE @backup_step_command nvarchar(max) = 'EXEC [dbo].[BackupDatabaseDifferential] @databaseName=''' + @databaseName + ''''
    DECLARE @remote_save_step_name nvarchar(max) = @databaseName + N': Run Differential Backup : Save to backup location'
    DECLARE @remote_save_step_command nvarchar(max) = @remote_save_command + ' ''' + @databaseName + ''' ''I'''
    DECLARE @schedule_name nvarchar(max) = @databaseName + N': Run Differential Backup: Daily Schedule'

    EXEC [dbo].[ScheduleBackup]
          @databaseName = @databaseName
        , @backup_user = @backup_user
        , @jobName = @job_name
        , @backup_step_name = @backup_step_name
        , @backup_step_command = @backup_step_command
        , @remote_save_step_name = @remote_save_step_name
        , @remote_save_step_command = @remote_save_step_command
        , @schedule_name = @schedule_name
        , @schedule_frequency_type = 8
        , @schedule_frequency_interval = @schedule_frequency_interval
        , @schedule_start_time = @schedule_start_time
        , @schedule_freq_subday_type = 1
        , @schedule_freq_subday_interval=1

END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[ScheduleBiHourlyTransactionLogBackup]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[ScheduleBiHourlyTransactionLogBackup]
      @databaseName nvarchar(150)
    , @backup_user nvarchar(150)
    , @remote_save_command nvarchar(max)
    , @schedule_frequency_interval tinyint
    , @schedule_start_time int
AS
BEGIN
    DECLARE @job_name nvarchar(max) = @databaseName + N'-MaintenancePlan.TransactionLog Database Backup'
    DECLARE @backup_step_name nvarchar(max) = @databaseName + N': Run TransactionLog Backup'
    DECLARE @backup_step_command nvarchar(max) = 'EXEC [dbo].[BackupDatabaseTransactionLogs] @databaseName=''' + @databaseName + ''''
    DECLARE @remote_save_step_name nvarchar(max) = @databaseName + N': Run TransactionLog Backup : Save to backup location'
    DECLARE @remote_save_step_command nvarchar(max) = @remote_save_command + ' ''' + @databaseName + ''' ''L'''
    DECLARE @schedule_name nvarchar(max) = @databaseName + N': Run TransactionLog Backup: Bi Hourly Schedule'

    EXEC [dbo].[ScheduleBackup]
          @databaseName = @databaseName
        , @backup_user = @backup_user
        , @jobName = @job_name
        , @backup_step_name = @backup_step_name
        , @backup_step_command = @backup_step_command
        , @remote_save_step_name = @remote_save_step_name
        , @remote_save_step_command = @remote_save_step_command
        , @schedule_name = @schedule_name
        , @schedule_frequency_type = 4
        , @schedule_frequency_interval = @schedule_frequency_interval
        , @schedule_start_time = @schedule_start_time
        , @schedule_freq_subday_type = 8
        , @schedule_freq_subday_interval=2

END
GO

PRINT N'';
PRINT N'==========================================================================';
PRINT N'Creating [dbo].[CreateDatabaseMaintenancePlan]';
PRINT N'==========================================================================';
GO

CREATE PROCEDURE [dbo].[CreateDatabaseMaintenancePlan]
      @databaseName nvarchar(150)
AS
BEGIN
    DECLARE @remote_save_command varchar(max) = N'$(remote_save_command)'
    DECLARE @backup_user varchar(max) = N'$(backup_user)'

    EXEC [dbo].[ScheduleWeeklyFullBackup]
          @databaseName=@databaseName
        , @backup_user=@backup_user
        , @remote_save_command=@remote_save_command
        , @schedule_frequency_interval = 1
        , @schedule_start_time = 0
    ;

    EXEC [dbo].[ScheduleDailyDifferentialBackup]
          @databaseName=@databaseName
        , @backup_user=@backup_user
        , @remote_save_command=@remote_save_command
        , @schedule_frequency_interval = 126 -- = 127 - 1 (all days other than sunday)
        , @schedule_start_time = 0
    ;

    EXEC [dbo].[ScheduleBiHourlyTransactionLogBackup]
          @databaseName=@databaseName
        , @backup_user=@backup_user
        , @remote_save_command=@remote_save_command
        , @schedule_frequency_interval = 1
        , @schedule_start_time = 20000
    ;

    DECLARE @jobname nvarchar(max) = @databaseName + N'-MaintenancePlan.Full Database Backup'
    EXEC msdb.dbo.sp_start_job
            @job_name=@jobname

END
GO
