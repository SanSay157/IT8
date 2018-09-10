using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Text;
using System.Data;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.Types;
using Croc.XmlFramework.ReportService.DataSources;
using Croc.IncidentTracker.ReportService.Reports;

namespace Croc.IncidentTracker.ReportService.Layouts.DataSources
{
    #region Инцидент
    class IncidentMainDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
    SELECT TOP 1
	    i.ObjectID,
	    i.InputDate,
	    type.[Name] IncidentType,
	    category.[Name] IncidentCategory,
	    i.[Number],
	    i.[Name],
	    i.Solution,
	    i.Folder,
	    dbo.GetFolderPath(i.Folder, 1) FolderPath,
	    emp.ObjectID InitiatorID, 
	    emp.LastName + ' ' + emp.FirstName + IsNull(' ' + emp.MiddleName, '') InitiatorString,
	    emp.Email InitiatorMail,
	    state.[Name] IncidentState,
	    i.Deadline,
	    i.Descr,
	    dbo.NameOf_IncidentPriority(i.Priority) IncidentPriority
    FROM
	    dbo.Incident i WITH(NOLOCK)
	    JOIN dbo.Employee emp WITH(NOLOCK) ON emp.[SystemUser]=i.Initiator
	    JOIN dbo.IncidentState state WITH(NOLOCK) ON state.ObjectID=i.State
	    JOIN dbo.IncidentType type WITH(NOLOCK) on type.ObjectID=i.Type
	    LEFT JOIN dbo.IncidentCategory category WITH(NOLOCK) ON category.ObjectID=i.Category
    WHERE
	    ");
            if (SourceData.Params.GetParam("IncidentID").IsNull)
            {
                cmd.CommandText += "i.[Number]=" + SourceData.Params.GetParam("IncidentNumber").Value;
		    }
			else
			{
                cmd.CommandText += "i.[ObjectID]=" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("IncidentID").Value);
			}
          return cmd.ExecuteReader();
        }
    }
    class IncidentAdditionalProperties : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
        SELECT
	        t.ObjectID TypeID,
	        t.[Name],
	        t.Type,
	        v.NumericData,
	        v.DateData,
        	v.StringData,
        	v.TextData,
        	IsNull(DATALENGTH(v.FileData), 0) BinSize,
	        v.ObjectID,
	        t.IsArray
         FROM 
        	dbo.IncidentPropValue v with (nolock)
        	JOIN dbo.IncidentProp t with (nolock) ON t.ObjectID=v.IncidentProp
        WHERE
	        (
	        	(t.Type IN (1,2,6) AND v.NumericData IS NOT NULL)
	        	OR
	        	(t.Type IN (3,4,5) AND v.DateData IS NOT NULL)
	        	OR
		        (t.Type IN (9,10) AND 0!=IsNull(DATALENGTH(v.FileData),0))
		        OR
		        (t.Type = 8 AND 0!=IsNull(DATALENGTH(v.TextData), 0))
	        )
	        AND v.Incident=" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.CustomData) + @"
        ORDER BY
	        t.[Index],
	        t.[Name],
	        t.[ObjectID]");
            return cmd.ExecuteReader();
        }
    }
    class LinkedIncidentData : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                SELECT x.Dir, i.[Number], i.[Name], i.ObjectID FROM
                (
                SELECT IncidentID, CASE Max(Direction) + Min(Direction) WHEN 0 THEN '<--' WHEN 1 THEN '<->' ELSE '-->' End Dir
                FROM
                (
                SELECT	RoleB IncidentID, 1 Direction
                FROM	dbo.IncidentLink with (nolock)
                WHERE  RoleA=" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.CustomData) + @"
                UNION ALL
               SELECT	RoleA, 0
                FROM 	dbo.IncidentLink
                WHERE  RoleB=" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.CustomData) + @"
                ) x
                GROUP BY IncidentID
                ) x
                JOIN dbo.Incident i with (nolock) ON i.ObjectID=x.IncidentID
                ORDER BY i.[Number]");
            return cmd.ExecuteReader();
        }
    }
    class IncidentTasksData : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"SELECT 
	                    t.ObjectID TaskID,
	                    r.[Name] RoleName,
	                    t.LeftTime,
	                    t.PlannedTime,
	                    emp.ObjectID WorkerID, 
	                    emp.LastName + ' ' + emp.FirstName + IsNull(' ' + emp.MiddleName, '') WorkerString,
	                    emp.Email WorkerMail,
	                    dbo.GetWorkdayGlobalDuration(),
	                    ts.Spent,
	                    ts.RegDate
                    FROM 
	                    dbo.Task t with (nolock)
	                    JOIN dbo.UserRoleInIncident r with (nolock) ON r.ObjectID=t.Role
	                    JOIN dbo.Employee emp with (nolock) ON emp.ObjectID=t.Worker
	                    LEFT JOIN dbo.TimeSpent ts with (nolock) ON ts.Task=t.ObjectID
                    WHERE
	                    t.Incident = " + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.CustomData) + @"
                    ORDER BY
	                    RoleName, WorkerString, ts.RegDate");


            return cmd.ExecuteReader();
        }
    }
    class IncidentHistoryData : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                                SELECT
	                s.[Name] StateName,
	                h.ChangeDate,
	                emp.ObjectID WorkerID, 
	                emp.LastName + ' ' + emp.FirstName + IsNull(' ' + emp.MiddleName, '') WorkerString,
	                IsNull(emp.Email,'') WorkerMail
                FROM
	                dbo.IncidentStateHistory h with (nolock)
	                JOIN dbo.IncidentState s with (nolock) ON s.ObjectID=h.State
	                JOIN dbo.Employee emp with (nolock) ON emp.[SystemUser]=h.[SystemUser]
                WHERE
	                h.Incident = " + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.CustomData) + @"
                ORDER BY
	                h.ChangeDate");
            return cmd.ExecuteReader();
        }
    }
    #endregion
    #region Папка
    class FolderMainDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                        DECLARE	@t table (f uniqueidentifier not null)
                        DECLARE
	                        @nProjectID uniqueidentifier,	-- идекнтификатор проекта
	                        @sFirstID uniqueidentifier,	-- ID первого списавшего по проекту
	                        @sFirstDep varchar(64),		-- Департамент первого списавшего по проекту
	                        @sFirstName varchar(386),	-- (Имя Фамилия) первого списавшего по проекту
	                        @sFirstMail varchar(64),	-- EMail первого списавшего по проекту
	                        @sFirstDate datetime,	-- дата первого списания по проекту

	                        @sLastID uniqueidentifier,	-- ID последнего списавшего по проекту
	                        @sLastDep varchar(64),		-- Департамент последнего списавшего по проекту
	                        @sLastName varchar(386),	-- (Имя Фамилия) последнего списавшего по проекту
	                        @sLastMail varchar(64),		-- EMail последнего списавшего по проекту
	                        @sLastDate datetime,		-- дата последнего списания по проекту

	                        @nSummarySpent int		-- суммарные трудозатраты (в минутах)

                        SET NOCOUNT ON
                        SET ROWCOUNT 0

                        SET @nProjectID = " + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("ID").Value) + @"

                        -- Получим список всех папок во временную табличку
                        INSERT INTO @t(f)
                        (
	                        SELECT fIn.ObjectID
	                        FROM
		                        dbo.Folder f WITH(NOLOCK) 
		                        JOIN dbo.Folder fIn WITH(NOLOCK) ON 
			                        f.Customer=fIn.Customer AND 
			                        fIn.LIndex >= f.LIndex AND f.RIndex >= fIn.RIndex 
	                        WHERE f.ObjectID = @nProjectID
                        )

                        /* ПЕРВОЕ СПИСАНИЕ */
                        SELECT TOP 1 
	                        @sFirstID = tmp.WorkerID,
	                        @sFirstDep = tmp.WorkerDep,
	                        @sFirstName = tmp.WorkerName,
	                        @sFirstMail = tmp.WorkerMail,
	                        @sFirstDate = tmp.FirstDate
                        FROM (
	                        SELECT
		                        su.ObjectID WorkerID,
		                        dbo.GetDepartmentCode(su.Department) WorkerDep,
		                        su.LastName + IsNull(' ' + su.FirstName, '') WorkerName,
		                        su.EMail WorkerMail,
		                        ts.RegDate FirstDate
	                        FROM 
		                        dbo.Incident i WITH(NOLOCK) 
		                        JOIN dbo.Task t WITH(NOLOCK) ON t.Incident = i.ObjectID
		                        JOIN dbo.TimeSpent ts WITH(NOLOCK) ON ts.Task = t.ObjectID
		                        JOIN dbo.Employee su WITH(NOLOCK) ON su.[SystemUser] = t.Worker
		                        JOIN @t f ON f.f=i.Folder
                        UNION ALL
	                        SELECT 
		                        su.ObjectID WorkerID,
		                        dbo.GetDepartmentCode(su.Department) WorkerDep,
		                        su.LastName + IsNull(' ' + su.FirstName, '') WorkerName,
		                        su.EMail WorkerMail,
		                        tl.LossFixed FirstDate
	                        FROM 
		                        dbo.TimeLoss tl WITH(NOLOCK) 
		                        JOIN dbo.Employee su WITH(NOLOCK) ON su.[SystemUser] = tl.Worker
		                        JOIN @t f ON f.f=tl.Folder
                        ) tmp
                        ORDER BY
	                        tmp.FirstDate asc


                        /* ПОСЛЕДНЯЯ АКТИВОСТЬ */
                        SELECT TOP 1 
	                        @sLastID = tmp.WorkerID,
	                        @sLastDep = tmp.WorkerDep,
	                        @sLastName = tmp.WorkerName,
	                        @sLastMail = tmp.WorkerMail,
	                        @sLastDate = tmp.FirstDate
                        FROM (
	                        SELECT
		                        su.ObjectID WorkerID,
		                        dbo.GetDepartmentCode(su.Department) WorkerDep,
		                        su.LastName + IsNull(' ' + su.FirstName, '') WorkerName,
		                        su.EMail WorkerMail,
		                        ts.RegDate FirstDate
	                        FROM 
		                        dbo.Incident i WITH(NOLOCK)
		                        JOIN dbo.Task t WITH(NOLOCK) ON t.Incident = i.ObjectID
		                        JOIN dbo.TimeSpent ts WITH(NOLOCK) ON ts.Task = t.ObjectID
		                        JOIN dbo.Employee su WITH(NOLOCK) ON su.[SystemUser] = t.Worker
		                        JOIN @t f ON f.f=i.Folder
                        UNION ALL
	                        SELECT 
		                        su.ObjectID WorkerID,
		                        dbo.GetDepartmentCode(su.Department) WorkerDep,
		                        su.LastName + IsNull(' ' + su.FirstName, '') WorkerName,
		                        su.EMail WorkerMail,
		                        tl.LossFixed FirstDate
	                        FROM 
		                        dbo.TimeLoss tl WITH(NOLOCK) 
		                        JOIN dbo.Employee su WITH(NOLOCK) ON su.[SystemUser] = tl.Worker
		                        JOIN @t f ON f.f=tl.Folder
                        ) tmp
                        ORDER BY
	                        tmp.FirstDate DESC


                        /* СУММАРНЫЕ ТРУДОЗАТРАТЫ */
                        SELECT 
	                        @nSummarySpent = Sum(tmp.Spent)
                        FROM
                        (	
	                        SELECT 
		                        SUM( ts.Spent ) AS Spent
	                        FROM 
		                        dbo.Incident i WITH(NOLOCK) 
		                        JOIN dbo.Task t WITH(NOLOCK) ON t.Incident = i.ObjectID
		                        JOIN dbo.TimeSpent ts WITH(NOLOCK) ON ts.Task = t.ObjectID
		                        JOIN @t f ON f.f=i.Folder
                        UNION ALL
	                        SELECT 
		                        SUM( tl.LostTime ) AS Spent
	                        FROM 
		                        dbo.TimeLoss tl WITH(NOLOCK) 
		                        JOIN @t f On f.f=tl.Folder
                        ) tmp


                        /* Возвращаем полученные величины */
                        SELECT 
	                        @sFirstID 	FirstID,
	                        @sFirstDep 	FirstDep,
	                        @sFirstName	FirstName,
	                        @sFirstMail	FirstMail,
	                        @sFirstDate	FirstDate,

	                        @sLastID	LastID,
	                        @sLastDep	LastDep,
	                        @sLastName	LastName,
	                        @sLastMail	LastMail,
	                        @sLastDate	LastDate,
	                        IsNull(@nSummarySpent,0) SummarySpent,

	                        t.[Name] DefaultIncidentTypeName,
	                        emp.[LastName] + ' ' + emp.[FirstName] + IsNull(' ' + emp.[MiddleName], '') InitiatorString,
	                        emp.EMail InitiatorMail,

	                        a.[Name] ActivityTypeName,
	                        a.[Code] ActivityTypeCode,
	                        a.[IsTimeLossCause] IsTimeLossCause,
                        	
	                        ISNULL(c.ShortName, c.[Name]) CustomerName,

	                        f.*
                        FROM
	                        dbo.Folder f WITH(NOLOCK) 
	                        JOIN dbo.ActivityType a WITH(NOLOCK) ON a.ObjectID=f.ActivityType
	                        JOIN dbo.Organization c WITH(NOLOCK) ON c.ObjectID=f.Customer
	                        LEFT JOIN dbo.IncidentType t WITH(NOLOCK) ON t.ObjectID=f.DefaultIncidentType
	                        LEFT JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID=f.Initiator
                        WHERE
	                        f.ObjectID = @nProjectID"
                );
            return cmd.ExecuteReader();
        }
    }
    class FolderDirectionsDS : IReportDataSource
        {
            object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
            {
                XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                            SELECT d.[Name] 
                            FROM dbo.FolderDirection fd WITH(NOLOCK) 
                                JOIN dbo.Direction d WITH(NOLOCK) ON d.ObjectID = fd.Direction
                            WHERE fd.Folder = " + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("ID").Value));
                return cmd.ExecuteReader();
                
            }
        }
    class FolderHistoryDS : IReportDataSource
        {
            object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
            {
                XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                            SELECT
	                            h.EventDate,
	                            h.Event,
	                            su.IsServiceAccount,
	                            emp.LastName + ' ' + emp.FirstName + IsNull(' ' + emp.MiddleName,''),
	                            IsNull(emp.EMail,''),
	                            emp.ObjectID
                            FROM
	                            dbo.FolderHistory h WITH(NOLOCK) 
	                            JOIN dbo.[SystemUser] su WITH(NOLOCK) ON su.ObjectID=h.[SystemUser]
	                            LEFT JOIN dbo.Employee emp WITH(NOLOCK) ON emp.[SystemUser]=su.ObjectID
                            WHERE
	                            h.Folder = " + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("ID").Value) + @"
                            ORDER BY
	                            h.EventDate");
                return cmd.ExecuteReader();
            }
        }
    class FolderWorkStaffDS : IReportDataSource
        {
            object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
            {
                XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"SELECT 
	                    t.[Name],
	                    SUM(CASE WHEN s.Category=1 THEN 1 ELSE 0 END) AS IncidentsInWork,
	                    SUM(CASE WHEN s.Category=2 THEN 1 ELSE 0 END) AS IncidentsOnCheck,
	                    SUM(CASE WHEN s.Category=3 THEN 1 ELSE 0 END) AS IncidentsDone,
	                    SUM(CASE WHEN s.Category=4 THEN 1 ELSE 0 END) AS IncidentsFrozen,
	                    SUM(CASE WHEN s.Category=5 THEN 1 ELSE 0 END) AS IncidentsDeclined
                    FROM
	                    dbo.Folder f WITH(NOLOCK) 
	                    JOIN dbo.Folder fIn WITH(NOLOCK) ON fIn.LIndex>=f.LIndex AND f.RIndex>=fIn.RIndex AND f.Customer=fIn.Customer
	                    JOIN dbo.Incident i WITH(NOLOCK) ON i.Folder=fIn.ObjectID 
	                    JOIN dbo.IncidentState s WITH(NOLOCK) ON s.ObjectID=i.State
	                    JOIN dbo.IncidentType t WITH(NOLOCK) ON t.ObjectID=i.Type
                    WHERE
	                    f.ObjectID=" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("ID").Value) + @"
                    GROUP BY
	                    t.ObjectID, t.[Name]
                    ORDER BY 
	                    t.[Name]");
                return cmd.ExecuteReader();
            } 
        }
    class FolderAdditionalDS : IReportDataSource
        {
            object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
            {
                XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"
                    SELECT 
	                    r.Roles,	--0
	                    emp.LastName + ' ' + emp.FirstName + IsNull(' ' + emp.MiddleName,'') + 
	                    IsNull( ' (' + dbo.GetDepartmentCode(emp.Department)+ ')',''), --1
	                    emp.ObjectID, --2
	                    emp.EMail --3
                    FROM 
	                    dbo.GetAllFolderParticipants(" + SourceData.XmlStorage.ArrangeSqlGuid((Guid)SourceData.Params.GetParam("ID").Value) + @") r
	                    JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID=r.EmployeeID
                    ORDER BY 1, 2");
                return cmd.ExecuteReader();
            }
        
    }

    #endregion
    #region Тендер
    class TenderDS : IReportDataSource
    {
        private const string SQL_MAIN = @"exec dbo.rep_TenderCard_Main @TenderID ";
        private const string SQL_LINKS = @"exec dbo.rep_TenderCard_ExtLinks @TenderID ";
        private const string SQL_PARTS = @"exec dbo.rep_TenderCard_Parts @TenderID ";
        private const string SQL_DEPARTMENT_PARTICIPATION = @"exec dbo.rep_TenderCard_DepParts @TenderID ";
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(SQL_MAIN + SQL_LINKS + SQL_PARTS + SQL_DEPARTMENT_PARTICIPATION);
            cmd.Parameters.Add("TenderID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("TenderID").Value);
            return cmd.ExecuteReader();
        }
    }
    #endregion
    #region Сальдо ДС по сотруднику
    class EmployeeSaldoDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"exec dbo.rep_GetEmployeeSaldoDS @EmployeeID ");
            cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("EmployeeID").Value);
            return cmd.ExecuteReader();
        }
    }
    #endregion
    #region Финплан

    //Данные по интервалам дат
    class IntervalSaldoDS : IReportDataSource
    {
        private const string GET_NAME_OF_DATERATIO = @"SELECT ObjectID, Name FROM dbo.DateRatio WHERE ObjectID = @DateRatioID ";
        private const string GET_DATA_INTERVALS = @"EXEC [dbo].[rep_GetDataIntervals] @DateRatioID ";
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(GET_NAME_OF_DATERATIO + GET_DATA_INTERVALS);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            return cmd.ExecuteReader();
        }
    }

    //Данные по проектам
    class PrjGroupDS : IReportDataSource
    {
        private const string GET_NAME_OF_PRJGROUP = @"SELECT ObjectID, Name FROM dbo.PrjGroup WHERE ObjectID = @PrjGroupID ";
        private const string GET_PROJECTS = @"EXEC [dbo].[rep_GetProjectsFromGroup] @PrjGroupID ";
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(GET_NAME_OF_PRJGROUP + GET_PROJECTS);
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            return cmd.ExecuteReader();
        }
    }

    //Финансовые показатели по группе проектов на начало периода, на период после отчетного и всего
    class PrjGroupPreFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetGroupPreFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    class PrjGroupAfterFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetGroupAfterFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    class PrjGroupAllFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetGroupAllFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    //Итоговые финансовые показатели 
    class PrjGroupFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetGroupFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    //Финансовые показатели по проектам на начало периода и на период после отчетного
    class ProjectsPreFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetProjectsPreFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    class ProjectsAfterFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetProjectsAfterFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    class ProjectsAllFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetProjectsAllFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    //Финансовые показатели по проектам 
    class ProjectsFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetProjectsFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }
    //Итоговые суммарные финансовые показатели 
    class PrjGroupSumFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetGroupSumFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }

    //Сумарные финансовые показатели по проектам 
    class ProjectsSumFinDataDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC [dbo].[rep_GetProjectsSumFinData] @PrjGroupID, @DateRatioID, @IsSeparate ");
            cmd.Parameters.Add("PrjGroupID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("DateRatioID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("DateRatio").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
    }
    #endregion 
    #region Интервал дат
    class DateIntervalDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetDateInterval @DateIntervalID");
            cmd.Parameters.Add("DateIntervalID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateIntervalID").Value));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion
    #region Контракт
    class ContractDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            object oParam = SourceData.Params.GetParam("InContract").Value;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetContract @InContract");
            cmd.Parameters.Add("InContract", DbType.Guid, ParameterDirection.Input, true, (Guid)NullToDBNull(oParam));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion

    #region Фин-план по проекту (БДДС)

    class ContractInfoDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"	SELECT
		                            CASE WHEN f.ExternalID IS NULL THEN ' ' ELSE '(' + f.ExternalID + ') ' END + f.Name AS 'Name'
		                            ,c.[Sum] as 'ContractSum'
		                            ,c.AvansSum as 'AvansSum'
                                FROM 
                                    dbo.Contract c
                                INNER JOIN dbo.Folder f ON c.Project = f.ObjectID
                                WHERE c.ObjectID = @ContractID");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("InContract").Value));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    class DateRatioIntervalsDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT [ObjectID]
                                      ,[Name]
                                      ,[DateFrom]
                                      ,[DateTo]
                                FROM  [dbo].[DateInterval]
                                WHERE Ratio = @DateRatio 
                                ORDER BY [DateFrom]");
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectBudgetForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT bo.ObjectID as 'BudgetOutID'
	                                  ,bo.Name as 'BudgetOutName'
	                                  ,bo.[Sum] as 'BudgetOutSum'
	                                  ,bo.Supplier as 'BudgetOutSupplier'
	                                  ,s.[Sum] as 'SupplierSum'
	                                  ,s.Manufacturer as 'SupplierOrgID'
                                FROM [dbo].[BudgetOut] bo
	                                LEFT JOIN dbo.Supplier s WITH(NOLOCK) ON bo.Supplier = s.ObjectID
                                WHERE bo.InContract = @ContractID ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    // 
    class ProjectIncomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT
	                                    di.ObjectID AS 'DateIntervalID',
	                                    dbo.GetProjectIncomeSum(di.[DateFrom], di.[DateTo], @ContractID) AS 'IncomeSum'
	                                    FROM dbo.DateInterval di
                                    WHERE di.Ratio = @DateRatio
                                    ORDER BY di.[DateFrom]");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    // 
    class ProjectTotalBudgetBindedOutcomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT 
	                                    SUM(dbo.[GetBudgetOutcomeSum](di.[DateFrom], di.[DateTo], bo.ObjectID)) AS 'PaymentSum'
	                                    , di.ObjectID as 'DateIntervalID'
                                    FROM dbo.DateInterval di WITH(NOLOCK), 
                                            dbo.BudgetOut bo WITH(NOLOCK)
                                    WHERE di.Ratio = @DateRatio AND bo.[InContract] = @ContractID
                                    GROUP BY di.[DateFrom],di.ObjectID
                                    ORDER BY di.[DateFrom]
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    class ProjectTotalSupplierBindedOutcomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT SUM(dbo.[GetProjectSupplierOutcomeSum](di.DateFrom, di.DateTo, org.ObjectID, @ContractID)) AS 'PaymentSum'
	                                    , di.ObjectID as 'DateIntervalID'
	                                    , di.DateFrom
                                    FROM dbo.DateInterval di,
		                                     dbo.Organization org WITH(NOLOCK)
                                    WHERE di.Ratio = @DateRatio
                                    GROUP BY di.[DateFrom], di.ObjectID
                                    ORDER BY di.[DateFrom]
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    // 
    class ProjectBudgetBindedOutcomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT DISTINCT
                                        bo.ObjectID as 'BudgetOutID'
	                                    ,bo.Name as 'BudgetOutName'
	                                    ,bo.[Sum] as 'BudgetOutSum'
	                                    ,org.ShortName as 'BudgetOutOrg'
	                                    ,dbo.[GetBudgetOutcomeSum](di.[DateFrom], di.[DateTo], bo.ObjectID) AS 'PaymentSum'
	                                    ,bo.Supplier as 'BudgetOutSupplier'
	                                    ,s.[Sum] as 'SupplierSum'
	                                    ,s.Manufacturer as 'SupplierOrgID'
                                        ,di.ObjectID AS 'DateIntervalID'
                                        ,di.DateFrom
    
                                    FROM dbo.DateInterval di WITH(NOLOCK), 
                                            dbo.BudgetOut bo WITH(NOLOCK)
                                            LEFT JOIN dbo.Supplier s WITH(NOLOCK) ON bo.Supplier = s.ObjectID
                                            LEFT JOIN dbo.Organization org WITH(NOLOCK) ON org.ObjectID = bo.Org
                                    WHERE di.Ratio = @DateRatio AND bo.[InContract] = @ContractID
                                    ORDER BY 'BudgetOutName', 'BudgetOutID', di.[DateFrom]
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    class ProjectSupplierBindedOutcomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT DISTINCT
	                                     org.ObjectID as 'SupplierID'
		
	                                    ,CASE 
		                                    WHEN org.ShortName IS NOT NULL THEN org.ShortName
		                                    WHEN (org.ShortName IS NULL) AND (org.Name IS NOT NULL) THEN org.Name
	                                     END as 'OrgName'
	                                    ,dbo.[GetProjectSupplierOutcomeSum](di.DateFrom, di.DateTo, org.ObjectID, @ContractID) AS 'PaymentSum'
                                        ,di.ObjectID AS 'DateIntervalID'
                                        ,di.DateFrom
                                    FROM dbo.DateInterval di WITH(NOLOCK), 
                                         dbo.Organization org WITH(NOLOCK)
                                           JOIN dbo.Outcome o WITH(NOLOCK) ON o.Organization = org.ObjectID 
												                                   /*
                                                                                    AND (o.[Date] > (SELECT TOP 1 DateFrom FROM dbo.DateInterval 
															                                    WHERE Ratio = @DateRatio ORDER BY DateFrom))
												                                    AND (o.[Date] < (SELECT TOP 1 DateTo FROM dbo.DateInterval 
															                                    WHERE Ratio = @DateRatio ORDER BY DateTo DESC))
                                                                                    */
	                                       LEFT JOIN dbo.OutType ot WITH(NOLOCK) ON o.[Type] = ot.ObjectID
                                    WHERE di.Ratio = @DateRatio AND o.[Contract] = @ContractID
                                    ORDER BY 'OrgName', 'SupplierID', di.[DateFrom]
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectBudgetBindedOutcomesBeforeForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                @"  SELECT 
                                        bo.ObjectID as 'BudgetOutID'
	                                    ,bo.Name as 'BudgetOutName'
	                                    ,bo.[Sum] as 'BudgetOutSum'
	                                    ,org.ShortName as 'BudgetOutOrg'
	                                    ,dbo.[GetBudgetOutcomeSum](null, (SELECT TOP 1 DateFrom FROM dbo.DateInterval 
														                  WHERE Ratio = @DateRatio ORDER BY DateFrom), bo.ObjectID) AS 'PaymentSum'
	                                    ,bo.Supplier as 'BudgetOutSupplier'
	                                    ,s.[Sum] as 'SupplierSum'
	                                    ,s.Manufacturer as 'SupplierOrgID'
    
                                    FROM 
                                            dbo.BudgetOut bo WITH(NOLOCK)
                                            LEFT JOIN dbo.Supplier s WITH(NOLOCK) ON bo.Supplier = s.ObjectID
                                            LEFT JOIN dbo.Organization org WITH(NOLOCK) ON org.ObjectID = bo.Org
                                    WHERE  bo.[InContract] = @ContractID
                                    ORDER BY  'BudgetOutName'
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectSupplierBindedOutcomesBeforeForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                    @"  SELECT DISTINCT
	                                         org.ObjectID as 'SupplierID'
	                                        ,CASE 
		                                        WHEN org.Name IS NOT NULL THEN org.Name
		                                        WHEN (org.Name IS NULL) AND (org.ShortName IS NOT NULL) THEN org.ShortName
	                                         END as 'OrgName'
	                                        ,dbo.[GetProjectSupplierOutcomeSum](null, (SELECT TOP 1 DateFrom FROM dbo.DateInterval 
										                                        WHERE Ratio = @DateRatio ORDER BY DateFrom), org.ObjectID, @ContractID) AS 'PaymentSum'
                                        FROM dbo.Organization org WITH(NOLOCK)
                                               JOIN dbo.Outcome o WITH(NOLOCK) ON o.Organization = org.ObjectID 
                                        WHERE o.[Contract] = @ContractID
                                        ORDER BY 'OrgName'
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectZOutcomesForBDDSReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                                    @"  SELECT DISTINCT
	                                         org.ObjectID as 'SupplierID'
	                                        ,CASE 
		                                        WHEN org.Name IS NOT NULL THEN org.Name
		                                        WHEN (org.Name IS NULL) AND (org.ShortName IS NOT NULL) THEN org.ShortName
	                                         END as 'OrgName'
	                                        ,dbo.[GetProjectSupplierOutcomeSum](null, (SELECT TOP 1 DateFrom FROM dbo.DateInterval 
										                                        WHERE Ratio = @DateRatio ORDER BY DateFrom), org.ObjectID, @ContractID) AS 'PaymentSum'
                                        FROM dbo.Organization org WITH(NOLOCK)
                                               JOIN dbo.Outcome o WITH(NOLOCK) ON o.Organization = org.ObjectID 
                                        WHERE o.[Contract] = @ContractID
                                        ORDER BY 'OrgName'
                                    ");
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    #endregion

    #region Общие расходы, расходы по АО и приходы-расходы по займам за заданный интервал (для отчета Финплан)
    class GenSumOutDS : IReportDataSource
    {
        private const string GET_COMMON_SUM_OUTCOMES = @"EXEC dbo.rep_GetGenOutSumFinData @DateRatio, @PrjGroup, @IsSeparate ";
        private const string GET_COMMON_AO_SUM_OUTCOMES = @"EXEC dbo.rep_GetAOSumFinData @DateRatio, @PrjGroup, @IsSeparate ";
        private const string GET_SUM_LOANS = @"EXEC dbo.rep_GetLoansSumFinData @DateRatio, @PrjGroup, @IsSeparate ";
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(GET_COMMON_SUM_OUTCOMES + GET_COMMON_AO_SUM_OUTCOMES + GET_SUM_LOANS);
            cmd.Parameters.Add("DateRatio", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateRatio").Value));
            cmd.Parameters.Add("PrjGroup", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Group").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion
    #region Приходы и расходы по проекту за заданный интервал (для подотчета Финплан)
    class ProjectIncomesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetProjectIncomes @DateIntervalID, @ContractID, @IsSeparate ");
            cmd.Parameters.Add("DateIntervalID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateIntervalID").Value));
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, true, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    class ProjectOutcomesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetProjectOutcomes @DateIntervalID, @ContractID, @IsSeparate ");
            cmd.Parameters.Add("DateIntervalID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateIntervalID").Value));
            cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("InContract").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion

    #region Расходы и приходы по проекту (для отчета БДР)

    class ProjectBudgetForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT org.ShortName as ContractCompany, SupOrg.ShortName as SupplierCompany,
                                   bo.Name as BudgetItem, s.[Sum] as SupplierSum, CAST(ISNULL(bo.[sum], 0) AS MONEY) as BudgetCost,
                                (CASE 
                                    WHEN bo.Supplier IS NOT NULL THEN dbo.GetSupplierFee(bo.Supplier)
                                 END) SupplierFee, 
                                 bo.Rem,
                                 s.[Percent]
                            FROM dbo.BudgetOut bo
	                            join dbo.[Contract] c on c.ObjectID = bo.InContract
	                            left join dbo.Organization org on bo.Org = org.ObjectID
	                            left join dbo.Supplier s on bo.Supplier = s.ObjectID
	                            left join dbo.Organization SupOrg on s.Manufacturer = SupOrg.ObjectID
                            WHERE bo.InContract = @IncContractID ");
            cmd.Parameters.Add("IncContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectOutLimitForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT ot.Name as OutLimitName, ol.Rem as OutLimitRem, ol.[Sum] as OutLimitSum
                                FROM dbo.OutLimit ol
	                                join dbo.OutType ot WITH (NOLOCK) ON ot.ObjectID = ol.OutType
                                WHERE ol.[Contract] = @IncContractID AND UPPER(ot.Name) LIKE 'КОМАНДИР%' ");
            cmd.Parameters.Add("IncContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectOutLimitExtForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT ot.Name as OutLimitName, ol.Rem as OutLimitRem, ol.[Sum] as OutLimitSum
                                FROM dbo.OutLimit ol
	                                join dbo.OutType ot WITH (NOLOCK) ON ot.ObjectID = ol.OutType
                                WHERE ol.[Contract] = @IncContractID AND UPPER(ot.Name) NOT LIKE 'КОМАНДИР%'");
            cmd.Parameters.Add("IncContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectAOLimitForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT aor.Name as AOLimitName, aol.Rem as AOLimitRem, aol.[Sum] as AOLimitSum
                                FROM dbo.AOLimit aol
	                                join dbo.AOReason aor WITH (NOLOCK) ON aor.ObjectID = aol.Reason
                                WHERE aol.[Contract] = @IncContractID AND UPPER(aor.Name) LIKE 'КОМАНДИР%' ");
            cmd.Parameters.Add("IncContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectAOLimitExtForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(
                            @"SELECT aor.Name as AOLimitName, aol.Rem as AOLimitRem, aol.[Sum] as AOLimitSum
                                FROM dbo.AOLimit aol
	                                join dbo.AOReason aor WITH (NOLOCK) ON aor.ObjectID = aol.Reason
                                WHERE aol.[Contract] = @IncContractID AND UPPER(aor.Name) NOT LIKE 'КОМАНДИР%' ");
            cmd.Parameters.Add("IncContractID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectOutcomesForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetProjectOutcomesForBDR @InContract, 1, @IsExtended");
            cmd.Parameters.Add("InContract", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            cmd.Parameters.Add("IsExtended", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("Extended").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class ProjectIncomesForBDRReportDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetProjectIncomesForBDR @InContract, NULL");
            cmd.Parameters.Add("InContract", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("InContract").Value);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion


    #region Приходы и расходы по займу за заданный интервал (для подотчета Финплан)
    class LoansIncomesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetLoansIncomes @DateIntervalID, @PrjGroup, @IsSeparate ");
            cmd.Parameters.Add("DateIntervalID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateIntervalID").Value));
            cmd.Parameters.Add("PrjGroup", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("PrjGroup").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }

    class LoansOutcomesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"EXEC dbo.rep_GetLoansOutcomes @DateIntervalID, @PrjGroup, @IsSeparate ");
            cmd.Parameters.Add("DateIntervalID", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("DateIntervalID").Value));
            cmd.Parameters.Add("PrjGroup", DbType.Guid, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("PrjGroup").Value));
            cmd.Parameters.Add("IsSeparate", DbType.Int16, ParameterDirection.Input, false, (0 != (int)SourceData.Params.GetParam("IsSeparate").Value) ? 1 : 0);
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }    
    #endregion
    #region Сальдо ДС по сотрудникам группы компаний
    class AllEmpSaldoDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"exec dbo.rep_GetAllEmpsSaldoDS @IntervalBegin, @IntervalEnd");
            cmd.Parameters.Add("IntervalBegin", DbType.Date, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("IntervalBegin").Value));
            cmd.Parameters.Add("IntervalEnd", DbType.Date, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("IntervalEnd").Value));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion
    #region Кассовые транзакции сотрудника
    class EmployeeKassTransDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand(@"exec dbo.rep_GetEmployeeKassTrans @EmpID, @IntervalBegin, @IntervalEnd");
            cmd.Parameters.Add("EmpID", DbType.Guid, ParameterDirection.Input, false, SourceData.Params.GetParam("EmpID").Value);
            cmd.Parameters.Add("IntervalBegin", DbType.Date, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("IntervalBegin").Value));
            cmd.Parameters.Add("IntervalEnd", DbType.Date, ParameterDirection.Input, true, NullToDBNull(SourceData.Params.GetParam("IntervalEnd").Value));
            return cmd.ExecuteReader();
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion
    #region Списания Сотрудника
    class UserExpencesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            #region Параметры отчета
            // Получим параметры
            //bool HideGroupColumns = (int)Params.GetParam("HideGroupColumns").Value!=0; 
            object IntervalBegin =SourceData.Params.GetParam("IntervalBegin").Value;
            object IntervalEnd = SourceData.Params.GetParam("IntervalEnd").Value;
            object Folder = SourceData.Params.GetParam("Folder").Value;
            object Customer = SourceData.Params.GetParam("Customer").Value;
            int ActivityAnalysDepth = (int)SourceData.Params.GetParam("ActivityAnalysDepth").Value;
            int SectionByActivity = (int)SourceData.Params.GetParam("SectionByActivity").Value;
            int FolderType = (int)SourceData.Params.GetParam("FolderType").Value;
            int ExpencesType = (int)SourceData.Params.GetParam("ExpensesType").Value;
            int IncludeSubProjects = (int)SourceData.Params.GetParam("IncludeSubProjects").Value;
            int DateDetalization = (int)SourceData.Params.GetParam("DateDetalization").Value;
            int TimeMeasureUnits = (int)SourceData.Params.GetParam("TimeMeasureUnits").Value;

            int SortType = (int)SourceData.Params.GetParam("SortType").Value;
            int SortOrder = (int)SourceData.Params.GetParam("SortOrder").Value;
            int InsertRestrictions = (int)SourceData.Params.GetParam("InsertRestrictions").Value;
            int ShowColumnWorkTimeNorm = (int)SourceData.Params.GetParam("ShowColumnWorkTimeNorm").Value;
            //int ShowColumnOverheads = (int)SourceData.Params.GetParam("ShowColumnOverheads").Value;
            //int ShowColumnSalaryExpenses = (int)SourceData.Params.GetParam("ShowColumnSalaryExpenses").Value;
            CustomDataForDS oCustomData = SourceData.CustomData as CustomDataForDS;
            string sTempTable = oCustomData.sTempTableName;
            #endregion
            #region SQL-Запрос
            StringBuilder sql = new StringBuilder(@"
                SET NOCOUNT ON
                SET ROWCOUNT 0

                -------------------------------------------------------------------------------
                -- Определяем нужные нам папки
                -------------------------------------------------------------------------------
                DECLARE @Folders TABLE
                (
	                Folder uniqueidentifier not null,
	                GroupFolder uniqueidentifier,
	                UNIQUE CLUSTERED (Folder, GroupFolder)
                )

                INSERT INTO @Folders (Folder, GroupFolder)
                SELECT DISTINCT Folder, GroupFolder
                FROM dbo.rep_GetSubFolders (
	                @FolderID,
	                @CustomerID,
	                @ActivityAnalysDepth,
	                @SectionByActivity,
	                @IncludeSubProjects
                ) AS T
                INNER JOIN dbo.Folder AS F with (nolock) ON F.ObjectID = T.Folder
                INNER JOIN dbo.Folder AS F2 with (nolock) ON F2.Customer=F.Customer AND F2.LIndex <= F.LIndex AND F2.RIndex >=F.RIndex
                WHERE (F.Type & @FolderType != 0 OR (F.Type=16 AND F2.Type & @FolderType != 0))

                -------------------------------------------------------------------------------
                -- Изменим даты
                -------------------------------------------------------------------------------
                DECLARE @dtBegin DATETIME
                DECLARE @dtEnd DATETIME
                DECLARE @dtActualBegin DATETIME
                DECLARE @dtActualEnd DATETIME


                SELECT
	                @dtBegin =  @IntervalBegin,
	                @dtEnd =  @IntervalEnd,
	                @IntervalBegin = dbo.DATETRIM(ISNULL(@IntervalBegin, '19781127')),
	                @IntervalEnd = dbo.DATECEIL(ISNULL(@IntervalEnd, '29781127'))


                -------------------------------------------------------------------------------
                -- Временная таблица затрат
                -------------------------------------------------------------------------------
                CREATE TABLE " + sTempTable + @"
                (
	                Folder uniqueidentifier,
	                Employee uniqueidentifier not null,
	                RegDate datetime,
	                ExpensesTime int,
	                UNIQUE CLUSTERED (Folder, Employee, RegDate)
                )

                DECLARE @nCount INT

                -------------------------------------------------------------------------------
                -- Определяем затраты на задания и списания
                -------------------------------------------------------------------------------
                INSERT INTO " + sTempTable + @" (Folder, Employee, RegDate, ExpensesTime)
                SELECT 
	                X.Folder,
	                X.Employee,
	                X.RegDate,
	                SUM(X.ExpensesTime)
                FROM
                (
	                SELECT
		                TS.* 
	                FROM	
	                (
                ");
                            switch (ExpencesType)
                            {
                                case (int)IncidentTracker.ExpencesType.Incidents:
                                    sql.Append(@"
		                SELECT S.GroupFolder AS Folder,
			                T.Worker  AS Employee,
			                dbo.DATETRIM(TS.RegDate) AS RegDate,
			                TS.Spent AS ExpensesTime
		                FROM @Folders AS S
		                INNER JOIN dbo.Incident AS I with (nolock) ON I.Folder = S.Folder
		                INNER JOIN dbo.Task AS T with (nolock) ON T.Incident = I.ObjectID
		                INNER JOIN dbo.TimeSpent AS TS with (nolock) ON TS.Task = T.ObjectID
		                WHERE TS.RegDate BETWEEN @IntervalBegin AND @IntervalEnd
                ");
                                    break;
                                case (int)IncidentTracker.ExpencesType.Discarding:
                                    sql.Append(@"
		                SELECT S.GroupFolder AS Folder,
			                TL.Worker AS Employee,
			                dbo.DATETRIM(TL.LossFixed) AS RegDate,
			                TL.LostTime AS ExpensesTime
		                FROM @Folders AS S
		                INNER JOIN dbo.TimeLoss AS TL with (nolock) ON TL.Folder = S.Folder
		                WHERE TL.LossFixed BETWEEN @IntervalBegin AND @IntervalEnd
                ");
                                    break;
                                default:

                                    sql.Append(@"
		                SELECT S.GroupFolder AS Folder,
			                T.Worker  AS Employee,
			                dbo.DATETRIM(TS.RegDate) AS RegDate,
			                TS.Spent AS ExpensesTime
		                FROM @Folders AS S
		                INNER JOIN dbo.Incident AS I with (nolock) ON I.Folder = S.Folder
		                INNER JOIN dbo.Task AS T with (nolock) ON T.Incident = I.ObjectID
		                INNER JOIN dbo.TimeSpent AS TS with (nolock) ON TS.Task = T.ObjectID
		                WHERE TS.RegDate BETWEEN @IntervalBegin AND @IntervalEnd
                ");
                                    sql.Append(" UNION ALL ");

                                    sql.Append(@"
		                SELECT S.GroupFolder AS Folder,
			                TL.Worker AS Employee,
			                dbo.DATETRIM(TL.LossFixed) AS RegDate,
			                TL.LostTime AS ExpensesTime
		                FROM @Folders AS S
		                INNER JOIN dbo.TimeLoss AS TL with (nolock) ON TL.Folder = S.Folder
		                WHERE TL.LossFixed BETWEEN @IntervalBegin AND @IntervalEnd
                ");
                                    break;
                            }

                            sql.Append(@"

	                ) AS TS
                ) AS X
                GROUP BY X.Folder, X.Employee, X.RegDate

                SELECT @nCount = @@ROWCOUNT

                SELECT
	                @dtActualBegin = MIN(RegDate),
	                @dtActualEnd = MAX(RegDate)
                FROM
	                " + sTempTable + @"

                DECLARE @sOrgName VARCHAR(999)
                DECLARE @sOrgExtID VARCHAR(999)
                DECLARE @sDirectorEmail VARCHAR(999)

                SELECT TOP 1
	                @sOrgName = o.[Name],
	                @sOrgExtID = o.[ExternalID],
	                @sDirectorEmail = d.Email
                FROM
	                dbo.Organization o with (nolock)
	                join dbo.Employee d with (nolock) ON d.ObjectID=o.Director
                WHERE
	                o.ObjectID = @CustomerID
                	

                SELECT
	                ISNULL(dbo.GetFolderPath(@FolderID, 1), '(не задана)') AS Folder,
	                IsNull(@sOrgName,'(не задан)') AS Customer,
	                @dtActualBegin AS ActualBegin, 
	                @dtActualEnd AS ActualEnd,
	                IsNull( 'с ' + CONVERT(VARCHAR, IsNull(@dtBegin, @dtActualBegin), 104) + ' по ' + CONVERT(VARCHAR, IsNull(@dtEnd, @dtActualEnd), 104), '(не задан)') As [Interval],
	                @FolderID As FolderID,
	                IsNull(@sOrgExtID,''),
	                IsNull(@sDirectorEmail,'')
                	

                IF @DateDetalization = 1 /* даты с затратами */ BEGIN
	                SELECT DISTINCT RegDate 
	                FROM " + sTempTable + @"
	                ORDER BY 1
                END

                IF @nCount= 0 BEGIN
	                DROP TABLE " + sTempTable + @"
                END
                ");
            #endregion
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandTimeout = int.MaxValue - 128;
            cmd.CommandText = sql.ToString(); 
         // Добавим параметров
            cmd.Parameters.Add("IntervalBegin", DbType.DateTime, ParameterDirection.Input, true, null == IntervalBegin ? DBNull.Value : IntervalBegin);
            cmd.Parameters.Add("IntervalEnd", DbType.DateTime, ParameterDirection.Input, true, null == IntervalEnd ? DBNull.Value : IntervalEnd);
            cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, true, null == Folder ? DBNull.Value : Folder);
            cmd.Parameters.Add("CustomerID", DbType.Guid, ParameterDirection.Input, true, null == Customer ? DBNull.Value : Customer);
            cmd.Parameters.Add("ActivityAnalysDepth", DbType.Int32, ParameterDirection.Input, false, ActivityAnalysDepth);
            cmd.Parameters.Add("SectionByActivity", DbType.Int32, ParameterDirection.Input, false, SectionByActivity);
            cmd.Parameters.Add("FolderType", DbType.Int32, ParameterDirection.Input, false, FolderType);
            cmd.Parameters.Add("IncludeSubProjects", DbType.Int32, ParameterDirection.Input, false, IncludeSubProjects);
            cmd.Parameters.Add("DateDetalization", DbType.Int32, ParameterDirection.Input, false, DateDetalization);
            cmd.Parameters.Add("ExpencesType", DbType.Int32, ParameterDirection.Input, false, ExpencesType);
            return cmd.ExecuteReader();
        }
    }
    class UserExpencesSecondaryDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            #region Параметры отчета
            // Получим параметры
            //bool HideGroupColumns = (int)Params.GetParam("HideGroupColumns").Value!=0; 
            object IntervalBegin = SourceData.Params.GetParam("IntervalBegin").Value;
            object IntervalEnd = SourceData.Params.GetParam("IntervalEnd").Value;
            object Folder = SourceData.Params.GetParam("Folder").Value;
            object Customer = SourceData.Params.GetParam("Customer").Value;
            int ActivityAnalysDepth = (int)SourceData.Params.GetParam("ActivityAnalysDepth").Value;
            int SectionByActivity = (int)SourceData.Params.GetParam("SectionByActivity").Value;
            int FolderType = (int)SourceData.Params.GetParam("FolderType").Value;
            int ExpencesType = (int)SourceData.Params.GetParam("ExpensesType").Value;
            int IncludeSubProjects = (int)SourceData.Params.GetParam("IncludeSubProjects").Value;
            int DateDetalization = (int)SourceData.Params.GetParam("DateDetalization").Value;
            int TimeMeasureUnits = (int)SourceData.Params.GetParam("TimeMeasureUnits").Value;

            int SortType = (int)SourceData.Params.GetParam("SortType").Value;
            int SortOrder = (int)SourceData.Params.GetParam("SortOrder").Value;
            int InsertRestrictions = (int)SourceData.Params.GetParam("InsertRestrictions").Value;
            int ShowColumnWorkTimeNorm = (int)SourceData.Params.GetParam("ShowColumnWorkTimeNorm").Value;
            //int ShowColumnOverheads = (int)SourceData.Params.GetParam("ShowColumnOverheads").Value;
            //int ShowColumnSalaryExpenses = (int)SourceData.Params.GetParam("ShowColumnSalaryExpenses").Value;
            CustomDataForDS oCustomData = SourceData.CustomData as CustomDataForDS;
            string sTempTable = oCustomData.sTempTableName;

            // Получим данные из предыдущего источника данных
            DateTime dtActualBegin;
            DateTime dtActualEnd;
            DateTime dtBegin;
            DateTime dtEnd;
        
            ArrayList arrDates = new ArrayList();
            dtActualBegin = oCustomData.dtActualBegin;
            dtActualEnd = oCustomData.dtActualEnd;
            arrDates = oCustomData.arrDates;
            dtBegin = IntervalBegin == null ? dtActualBegin : (DateTime)IntervalBegin;
            dtEnd = IntervalEnd == null ? dtActualEnd : (DateTime)IntervalEnd;
            #endregion
            #region SQL-Запрос
            StringBuilder sql = new StringBuilder(@"
                SET NOCOUNT ON
                SET ROWCOUNT 0

                -------------------------------------------------------------------------------
                -- Изменим даты
                -------------------------------------------------------------------------------
                SELECT 
	                @IntervalBegin = dbo.DATETRIM(ISNULL(@IntervalBegin, '19781127')),
	                @IntervalEnd = dbo.DATECEIL(ISNULL(@IntervalEnd, '29781127'))

                -------------------------------------------------------------------------------
                -- Вычисляем запланированное время
                -------------------------------------------------------------------------------
                DECLARE @WorkDays TABLE
                (
	                Date datetime PRIMARY KEY	
                )
                DECLARE @RegDate datetime
                SET @RegDate = @IntervalBegin
                WHILE @RegDate <= @IntervalEnd
                BEGIN	
	                IF dbo.IsWorkday(@RegDate) != 0
		                INSERT INTO @WorkDays (Date) VALUES (@RegDate)

	                SET @RegDate = DATEADD(d, 1, @RegDate)
                END

                SELECT * FROM
                (
                SELECT
	                E.Folder, 
	                dbo.GetFolderPath(E.Folder,1) AS FolderPath,
	                E.Employee,
	                EMP.LastName + ' ' + EMP.FirstName + ISNULL(' ' + EMP.MiddleName, '') AS EmployeeName,
	                IsNull(EMP.EMail,'') AS EmployeeEMail,
	                dbo.GetWorkdayGlobalDuration() AS WorkdayDuration,	
	                SUM(IsNull(E.ExpensesTime,0)) ExpensesTime, 
	                CASE WHEN @SectionByActivity = 0 OR @IncludeSubProjects = 0 OR E.Folder IN ( SELECT Folder FROM dbo.rep_GetTotalFolders(@FolderID, @CustomerID) ) THEN 0 ELSE 1 END ABCD,
	                	(SELECT SUM(Rate) 
					FROM dbo.GetEmployeeCalendar(@IntervalBegin, @IntervalEnd,E.Employee)) AS ExpectExpensesTime
	                --{MEGAMACRO}--
                ");
            #endregion
            switch (DateDetalization)
            {
                case (int)IncidentTracker.DateDetalization.AllDate:
                    DateTime dtCol = (DateTime)(IntervalBegin == null ? dtActualBegin : IntervalBegin);
                    DateTime dtStop = (DateTime)(IntervalEnd == null ? dtActualEnd : IntervalEnd);
                    while (dtCol <= dtStop)
                    {
                        addDateDetalizationColumn(dtCol, sql);
                        dtCol = dtCol.AddDays(1.0);
                    }
                    break;


                case (int)IncidentTracker.DateDetalization.ExpencesDate:
                    foreach (DateTime dt in arrDates)
                        addDateDetalizationColumn(dt, sql);
                    break;
            }
            sql.Append(@"
            FROM 
	            " + sTempTable + @" AS E
	            JOIN dbo.Employee EMP with (nolock) ON EMP.ObjectID=E.Employee
            GROUP BY 
	            E.Folder, E.Employee, EMP.LastName, EMP.FirstName, EMP.MiddleName, EMP.EMail, EMP.WorkBeginDate, EMP.WorkEndDate
            ) X
            ORDER BY 
            ");
            // Сортировка
            if (SectionByActivity != (int)Croc.IncidentTracker.SectionByActivity.NoSection)
            {
                sql.Append(" FolderPath, Folder,");
            }
            switch (SortType)
            {
                case (int)SortExpences.ByNorm:
                    sql.Append("ExpectExpensesTime");
                    break;
                default:
                    sql.Append("EmployeeName");
                    break;
            }

            if (SortOrder == (int)Croc.IncidentTracker.SortOrder.Desc)
                sql.Append(" DESC");

            sql.Append(@"
                -- Дропнем табличку
                DROP TABLE " + sTempTable + @"
                ");
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.Parameters.Add("IntervalBegin", DbType.DateTime, ParameterDirection.Input, true, null == IntervalBegin ? DBNull.Value : IntervalBegin);
            cmd.Parameters.Add("IntervalEnd", DbType.DateTime, ParameterDirection.Input, true, null == IntervalEnd ? DBNull.Value : IntervalEnd);
            cmd.Parameters["IntervalBegin"].Value = IntervalBegin == null ? dtActualBegin : IntervalBegin;
            cmd.Parameters["IntervalEnd"].Value = IntervalEnd == null ? dtActualEnd : IntervalEnd;
            cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, true, null == Folder ? DBNull.Value : Folder);
            cmd.Parameters.Add("SectionByActivity", DbType.Int32, ParameterDirection.Input, false, SectionByActivity);
            cmd.Parameters.Add("CustomerID", DbType.Guid, ParameterDirection.Input, true, null == Customer ? DBNull.Value : Customer);
            cmd.Parameters.Add("ActivityAnalysDepth", DbType.Int32, ParameterDirection.Input, false, ActivityAnalysDepth);
            cmd.Parameters.Add("FolderType", DbType.Int32, ParameterDirection.Input, false, FolderType);
            cmd.Parameters.Add("IncludeSubProjects", DbType.Int32, ParameterDirection.Input, false, IncludeSubProjects);
            cmd.Parameters.Add("DateDetalization", DbType.Int32, ParameterDirection.Input, false, DateDetalization);
            cmd.Parameters.Add("ExpencesType", DbType.Int32, ParameterDirection.Input, false, ExpencesType);
         
            cmd.CommandText = sql.ToString();
            return cmd.ExecuteReader();
        }
        protected void addDateDetalizationColumn(DateTime dt, StringBuilder sql)
        {
            sql.AppendFormat(",SUM(CASE WHEN E.RegDate='{0}' THEN E.ExpensesTime ELSE 0 END) [{1}]{2}", dt.ToString("yyyyMMdd"), dt.ToString("dd.MM.yyyy"), Environment.NewLine);
        }
    }
    #endregion
    #region Структура затрат подразделения
    class DepartmentExpensesStructureMainDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            r_DepartmentExpensesStructure.ThisReportParams oParams = SourceData.CustomData as r_DepartmentExpensesStructure.ThisReportParams;
            cmd.CommandText = "dbo.rep_DepartmentExpensesStructure";
            cmd.CommandType = CommandType.StoredProcedure;

            // ПАРАМЕТРЫ:
            // ...Форма отчета:
            cmd.Parameters.Add("nReportForm", DbType.Int32, ParameterDirection.Input, true, oParams.ReportForm);

            // ...Отчетный период:
            cmd.Parameters.Add("dtIntervalBegin", DbType.DateTime, ParameterDirection.Input, true, oParams.IntervalBegin);
            cmd.Parameters.Add("dtIntervalEnd", DbType.DateTime, ParameterDirection.Input, true, oParams.IntervalEnd);

            // ...Определение базового набора (перечень организаций / подразделений + глубина анализа)
            cmd.Parameters.Add("sOrganizationIDs", DbType.String, ParameterDirection.Input, true, oParams.OrganizationIDs);
            cmd.Parameters.Add("sDepartmentIDs", DbType.String, ParameterDirection.Input, true, oParams.DepartmentIDs);
            cmd.Parameters.Add("nAnalysisDepth", DbType.Int32, ParameterDirection.Input, true, oParams.AnalysisDepth);

            // ..."Разобранные" флаги включения опциональных колонок:
            cmd.Parameters.Add(
                "bShowPeriodRate", DbType.Int16, ParameterDirection.Input, false,
                oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodRate));
            cmd.Parameters.Add(
                "bShowPeriodDisbalance", DbType.Int16, ParameterDirection.Input, false,
                oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodDisbalance));
            cmd.Parameters.Add(
                "bShowUtilization", DbType.Int16, ParameterDirection.Input, false,
                oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization));
            cmd.Parameters.Add(
                "bShowExpenseCause", DbType.Int16, ParameterDirection.Input, false,
                oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization));

            // ...Признак исключения данных уволенных сотрудников
            cmd.Parameters.Add("bPassRedundant", DbType.Int16, ParameterDirection.Input, false, (oParams.PassRedundant ? 1 : 0));
            // ...Признак исключения данных нетрудоспособных сотрудников
            cmd.Parameters.Add("bPassDisabled", DbType.Int16, ParameterDirection.Input, false, (oParams.PassDisabled ? 1: 0));

            // ...Перечень видов активностей, затраты по которым считаются как "внешние"
            cmd.Parameters.Add("sExternalActivityTypeIDs", DbType.String, ParameterDirection.Input, true, oParams.ActivityTypesAsExternalIDs);

            // ...призак группировки по подразедениям (требуется для корректной сортировки данных)			
            cmd.Parameters.Add("bDoGroup", DbType.Int16, ParameterDirection.Input, false, (oParams.DoGroup ? 1 : 0));
            // ...Сортировка 
            cmd.Parameters.Add("nSortingMode", DbType.Int32, ParameterDirection.Input, false, oParams.SortingMode);

            return cmd.ExecuteReader();
        }
    }
    // Получения перечня описаний причин списаний
    class DepartmentExpensesСausesDS : IReportDataSource
    {
        internal enum ExpTypes
        {
            OnIncident = 0,			// Списания на инциденты, без разделения на "внешние" / "внутренние"
            OnIncidentExternal = 1,	// Списания на инциденты по "внешним" активностям
            OnIncidentInternal = 2,	// Списания на инциденты по "внутренним" активностям
            OnCauseFolder = 3,		// Списания на активности, без разделения на "внешние" / "внутренние"
            OnCauseExternal = 4,	// Списания на "внешние" активности
            OnCauseInternal = 5,	// Списания на "внутренние" активности
            OnCauseLoss = 6			// Внепроектные списания
        }
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
           cmd.CommandText = String.Format(@"
						SELECT * FROM 
						(
							SELECT c.ObjectID, c.[Name], CAST(c.[Type] AS int) AS Type, 
								{0} AS CauseExpType, 
								CASE Type WHEN 3 THEN 2 ELSE 1 END AS OrderIdx
							FROM dbo.TimeLossCause c WITH(NOLOCK) WHERE Type IN (1,3)
						UNION ALL 
							SELECT c.ObjectID, c.[Name], CAST(c.[Type] AS int) AS Type,
								{1} AS CauseExpType,
								CASE Type WHEN 3 THEN 3 ELSE 4 END AS OrderIdx
							FROM dbo.TimeLossCause c WITH(NOLOCK) WHERE Type IN (3,2)
                        UNION ALL
                        -- Добавлено для случаев, когда есть непроектные списания с указанием проекта и наоборот
							SELECT c.ObjectID, c.[Name], CAST(c.[Type] AS int) AS Type,
								{1} AS CauseExpType,
								CASE Type WHEN 3 THEN 3 ELSE 4 END AS OrderIdx
							FROM dbo.TimeLossCause c WITH(NOLOCK) WHERE Type IN (1)
							AND EXISTS (SELECT TOP 1 tl.ObjectID 
											FROM dbo.TimeLoss (NOLOCK) tl  
											WHERE (tl.Cause = c.ObjectID) AND (tl.Folder IS NULL) AND (tl.LossFixed > @IntervalBegin) AND (tl.LossFixed < @IntervalEnd))
                        UNION ALL
							SELECT c.ObjectID, c.[Name], CAST(c.[Type] AS int) AS Type,
								{0} AS CauseExpType,
								CASE Type WHEN 3 THEN 2 ELSE 1 END AS OrderIdx
							FROM dbo.TimeLossCause c WITH(NOLOCK) WHERE Type IN (2)
							AND EXISTS (SELECT TOP 1 tl.ObjectID 
											FROM dbo.TimeLoss (NOLOCK) tl  
											WHERE (tl.Cause = c.ObjectID) AND NOT(tl.Folder IS NULL) AND (tl.LossFixed > @IntervalBegin) AND (tl.LossFixed < @IntervalEnd) )
						) t 
						ORDER BY t.OrderIdx, t.Type, t.[Name] ",
                        ((int)ExpTypes.OnCauseFolder), ((int)ExpTypes.OnCauseLoss));
            DateTime intervalBegin = (SourceData.Params.GetParam("IntervalBegin").Value == null)? DateTime.MinValue: (DateTime) (SourceData.Params.GetParam("IntervalBegin").Value);
            DateTime intervalEnd = (SourceData.Params.GetParam("IntervalEnd").Value == null) ? DateTime.Now : (DateTime)(SourceData.Params.GetParam("IntervalEnd").Value);
            cmd.Parameters.Add("IntervalBegin", DbType.DateTime, ParameterDirection.Input, true, intervalBegin);
            cmd.Parameters.Add("IntervalEnd", DbType.DateTime, ParameterDirection.Input, true, intervalEnd);
            return cmd.ExecuteReader();
        }
        
    }
    class DepartmentOrganizationsAndDepartmentsDS : IReportDataSource
    {
        // #3: Базовый набор: перечень организаций и подразделений
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            r_DepartmentExpensesStructure.ThisReportParams oParams = SourceData.CustomData as r_DepartmentExpensesStructure.ThisReportParams;
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = @"
						SELECT t.UnitType, t.UnitName FROM 
						(
							/* Выды активностей */	
							SELECT DISTINCT 0 AS UnitType, a.[Name] AS UnitName
							FROM dbo.ActivityType a WITH(NOLOCK)
							WHERE ','+@ActivityTypesIDs+',' LIKE '%,'+CONVERT(varchar(40),a.ObjectID)+',%'
						UNION ALL
							/* Организации */
							SELECT DISTINCT 1 AS UnitType, o.[Name] AS UnitName
							FROM dbo.Organization o WITH(NOLOCK)
							WHERE ','+@OrgIDs+',' LIKE '%,'+CONVERT(varchar(40),o.ObjectID)+',%'
						UNION ALL
							/* Подразделения */
							SELECT DISTINCT 2 AS UnitType, d.[Name] AS UnitName
							FROM dbo.Department d WITH(NOLOCK)
							WHERE ','+@DepIDs+',' LIKE '%,'+CONVERT(varchar(40),d.ObjectID)+',%'
						) t
						ORDER BY UnitType, UnitName ";

            cmd.Parameters.Add("ActivityTypesIDs", DbType.String, ParameterDirection.Input, false, oParams.ActivityTypesAsExternalIDs);
            cmd.Parameters.Add("OrgIDs", DbType.String, ParameterDirection.Input, false, oParams.OrganizationIDs);
            cmd.Parameters.Add("DepIDs", DbType.String, ParameterDirection.Input, false, oParams.DepartmentIDs);
            return cmd.ExecuteReader();
				
        }
    }
    #endregion
    #region Баланс списаний сотрудника
    class EmployeeExpencesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            r_EmployeeExpensesBalance.ThisReportParams m_oParams = SourceData.CustomData as r_EmployeeExpensesBalance.ThisReportParams;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandText = "dbo.rep_EmployeeExpensesBalance";
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("uidEmployee", DbType.Guid, ParameterDirection.Input, true, m_oParams.EmployeeID);
            cmd.Parameters.Add("dtPeriodBeginDate", DbType.DateTime, ParameterDirection.Input, true, m_oParams.IntervalBegin);
            cmd.Parameters.Add("dtPeriodEndDate", DbType.DateTime, ParameterDirection.Input, true, m_oParams.IntervalEnd);
            return cmd.ExecuteReader();
        }
    }
    class EmployeeExpencesAdditionalDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = @"
						SELECT 
							e.LastName + ' ' + e.FirstName + ISNULL(' ' + e.MiddleName, '') AS FullName,
							e.WorkBeginDate, e.WorkEndDate,
							dbo.GetWorkdayGlobalDuration() AS WorkdayDuration
						FROM dbo.Employee e WITH(NOLOCK)
						WHERE e.ObjectID = @EmployeeID ";
            cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, (Guid)SourceData.Params.GetParam("Employee").Value);
            return cmd.ExecuteReader();
        }
    }
    #endregion
    #region Список инцидентов и затрат сотрудника
    class EmloyeeExpensesListDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            // Получим параметры
            object IntervalBegin = SourceData.Params.GetParam("IntervalBegin").Value;
            object IntervalEnd = SourceData.Params.GetParam("IntervalEnd").Value;
            Guid Employee = (Guid)SourceData.Params.GetParam("Employee").Value;

            int NonProjectExpences = (int)SourceData.Params.GetParam("NonProjectExpences").Value;
            int IncludeParams = (int)SourceData.Params.GetParam("IncludeParams").Value;
            int AnalysDirection = (int)SourceData.Params.GetParam("AnalysDirection").Value;
            int TimeLossReason = (int)SourceData.Params.GetParam("TimeLossReason").Value;
            int SectionByActivity = (int)SourceData.Params.GetParam("SectionByActivity").Value;
            int ExepenseDetalization = (int)SourceData.Params.GetParam("ExepenseDetalization").Value;
            int TimeMeasureUnits = (int)SourceData.Params.GetParam("TimeMeasureUnits").Value;
            object ActivityType = SourceData.Params.GetParam("ActivityType").Value;
            object ExpenseType = SourceData.Params.GetParam("ExpenseType").Value;
            object IncidentState = SourceData.Params.GetParam("IncidentState").Value;

            int Sort = (int)SourceData.Params.GetParam("Sort").Value;
            int SortOrder = (int)SourceData.Params.GetParam("SortOrder").Value;

            bool bIncidentAttributes = 0 != (int)SourceData.Params.GetParam("IncidentAttributes").Value;
            bool bDate = 0 != (int)SourceData.Params.GetParam("Date").Value;
            bool bNumberOfTasks = 0 != (int)SourceData.Params.GetParam("NumberOfTasks").Value;
            bool bRemaining = 0 != (int)SourceData.Params.GetParam("Remaining").Value;
            bool bNewState = 0 != (int)SourceData.Params.GetParam("NewState").Value;
            bool bComment = 0 != (int)SourceData.Params.GetParam("Comment").Value;



            StringBuilder sb = new StringBuilder();
            sb.Append(@"
SET NOCOUNT ON
SET ROWCOUNT 0

DECLARE @days int
DECLARE @dtTmp DateTime



if @IntervalBegin is Null
	SELECT 
		@IntervalBegin = IsNull(MIN(ts.RegDate), GetDate())
	FROM
	(
		SELECT
			MIN(ts.RegDate) RegDate
		FROM 
			dbo.Task t  with (nolock)
			JOIN dbo.TimeSpent ts with (nolock) ON t.ObjectID = ts.Task
		WHERE
			t.Worker = @Employee
			--AND @ExpenseType IN (0,2)
		UNION ALL
		SELECT 
			MIN(tl.LossFixed) 
		FROM 
			dbo.TimeLoss tl with (nolock)
		WHERE 
			tl.Worker = @Employee
			--AND @ExpenseType IN (1,2)

	) ts

IF @IntervalEnd is Null
	SET @IntervalEnd = GetDate()


SELECT 
	@IntervalBegin=dbo.DateTrim(@IntervalBegin), 
	@IntervalEnd=dbo.DateCeil(@IntervalEnd), 
	@days=0,
	@dtTmp =  dbo.DateTrim(@IntervalBegin)


WHILE @dtTmp <= @intervalEnd
	SELECT 
		@days=@days + IsNull(dbo.IsWorkDay(@dtTmp), 0),  
		@dtTmp = DateAdd(Day, 1, @dtTmp)

-- Этим запросом получим данные для заголовка
SELECT
	em.LastName + ' ' + IsNull(Left(em.FirstName, 1) + '.', '') + IsNull(Left(em.MiddleName, 1) + '.', '') AS EmployeeName
	,em.EMail email
	,dbo.NameOf_AnalysDirection(@analysdirection) as AnalysDirection
	,dbo.NameOf_TimeMeasureUnits(@TimeMeasureUnits) as TimeMeasureUnits
	,IsNull(dbo.NameOf_FolderTypeFlags(@ActivityType), 'Все типы') as ActivityType
	,dbo.NameOf_ExpenseDetalization(@ExepenseDetalization) as ExepenseDetalization
	,dbo.NameOf_ExpencesType(@ExpenseType) as ExpenseType
	,dbo.NameOf_SectionByActivity(@SectionByActivity) as SectionByActivity
	,' c ' + Convert(varchar, dbo.Datetrim(@IntervalBegin), 104) + ' по ' + Convert(varchar, dbo.Datetrim(@IntervalEnd), 104) as DateInterval
	,case when @NonProjectExpences = 0 then 'учитывать не проектные списания' else 'не учитывать не проектные списания' end as NonProjectExpences
	,IsNull(dbo.NameOf_IncidentStateCat(@IncidentState),'все') as IncidentState
	,dbo.GetWorkdayGlobalDuration() WorkDayDuration
	,@days WorkDays
	,@IntervalBegin IntervalBegin
	,@IntervalEnd IntervalEnd

FROM
	dbo.Employee em with (nolock)
WHERE 
	em.ObjectID = @Employee
");

            // Допишем запрос на получение основного набора данных отчёта
            switch (ExepenseDetalization)
            {
                case (int)ExpenseDetalization.ByExpences:
                    bNumberOfTasks = false;
                    sb.Append(@"
SELECT
	IsNull(topF.[ObjectID], CAST( 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF as UniqueIdentifier )) topFolder,
	IsNull(topF.[Name],'Не проектные списания') topName,
	0 NumberOfTasks,
	x.*
FROM
	(
	SELECT
		x.CauseType, 
		x.ActivityID,
		x.ActivityName,
		x.CauseID,
		x.CauseName,
		x.DateSpent DateSpent ,
		x.Spent Spent, 
		x.LeftTime LeftTime, 
		x.NewState,
		x.Comments  
	FROM
		(
		SELECT
			1 as CauseType,
			inc.[Folder] as ActivityID,
			dbo.GetFolderPath(inc.[Folder], 1)	as ActivityName,
			inc.ObjectID as CauseID,
			it.[Name] + ' №' + CAST(inc.[Number] AS VARCHAR(99)) + ': ' + inc.[Name] As CauseName,
			ts.RegDate as DateSpent,
			ts.Spent as Spent,
			tk.LeftTime as LeftTime,
			CAST(Null AS VARCHAR(8000)) as Comments,
			(SELECT TOP 1 [Name] FROM dbo.IncidentState with (nolock) WHERE ObjectID =
				IsNull((SELECT TOP 1 State FROM dbo.IncidentStateHistory with (nolock) WHERE Incident=inc.ObjectID AND [SystemUser]=empl.[SystemUser] AND 8>ABS(DATEDIFF(ss , ChangeDate , ts.RegDate))  ),Null /* inc.State */)) AS  NewState

		FROM 
			dbo.Incident inc with (nolock)
			join dbo.IncidentType it with (nolock) ON it.ObjectID=inc.Type
			join dbo.Task tk with (nolock) ON tk.Incident = inc.ObjectID
			join dbo.IncidentState [is] with (nolock) ON [is].ObjectID = inc.State
			join dbo.TimeSpent ts with (nolock) ON ts.Task=tk.ObjectID
			join dbo.Employee empl with (nolock) ON empl.ObjectID=tk.Worker
	
		WHERE 
			tk.Worker = @Employee
			AND (
				(ts.RegDate BETWEEN @IntervalBegin and @IntervalEnd and @AnalysDirection = 0)
				OR
				(@AnalysDirection = 1 AND [is].IsStartState = 1)
			)							
			AND [is].Category = IsNull(@IncidentState, [is].Category)
			AND @ExpenseType in (0, 2)

		UNION ALL

		SELECT
			CASE WHEN tl.Folder IS Null THEN 3 ELSE 4 END, 
			IsNull(tl.Folder, tlc.[ObjectID]),
			IsNull(dbo.GetFolderPath(f.[ObjectID], 1),tlc.[Name]),
			tlc.ObjectID,
			tlc.[Name],
			tl.LossFixed,
			tl.LostTime,
			Cast( Null As INT),
			CASE WHEN tl.Folder IS Null THEN cast(substring(tl.Descr, 1, 8000) as varchar(8000))  ELSE Null END,
			CAST(Null AS VARCHAR(1024)) NewState
		FROM 
			dbo.TimeLoss tl with (nolock)
			join dbo.TimeLossCause tlc with (nolock) on tlc.Objectid = tl.Cause
			LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID=tl.Folder
		WHERE 
			tl.Worker = @Employee
			and tl.LossFixed BETWEEN @IntervalBegin AND @IntervalEnd
			and @ExpenseType in (1, 2)
			and @AnalysDirection = 0
			and (@NonProjectExpences = 0 OR tl.Folder IS NOT Null)
		) x
	) x
	LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID = x.ActivityID AND x.CauseType!=3
	LEFT JOIN dbo.Folder topF with (nolock) ON topF.Customer=f.Customer AND topF.LIndex <= f.LIndex AND topF.RIndex >= f.RIndex AND topF.LRLevel=0
WHERE
	f.ObjectID IS NULL OR (topF.Type & IsNull(@ActivityType, topF.Type) !=0)
ORDER BY 
	CASE WHEN @SectionByActivity!=0 THEN CASE WHEN topF.ObjectID IS NULL THEN 1 ELSE 0 END ELSE 0 END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[Name] END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[ObjectID] END,
");
                    break;
                case (int)ExpenseDetalization.ByIncident:
                    sb.Append(@"
SELECT
	IsNull(topF.[ObjectID], CAST( 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF as UniqueIdentifier )) topFolder,
	IsNull(topF.[Name],'Не проектные списания') topName,
	x.*
FROM
	(
	SELECT
		x.CauseType, 
		x.ActivityID,
		x.ActivityName,
		x.CauseID,
		x.CauseName,
		Sum(x.NumberOfTasks) NumberOfTasks, 
		Max(x.DateSpent) DateSpent ,
		Sum(x.Spent) Spent, 
		Sum(x.LeftTime) LeftTime, 
		x.NewState,
		x.Comments  
	FROM
		(
		SELECT
			1 as CauseType,
			inc.[Folder] as ActivityID,
			dbo.GetFolderPath(inc.[Folder], 1)	as ActivityName,
			inc.ObjectID as CauseID,
			it.[Name] + ' №' + CAST(inc.[Number] AS VARCHAR(99)) + ' ' + inc.[Name] As CauseName,
			1 NumberOfTasks,
			MAX(ts.RegDate) as DateSpent,
			SUM(ts.Spent) as Spent,
			SUM(tk.LeftTime) as LeftTime,
			CAST(Null AS VARCHAR(8000)) as Comments,
			[is].[Name] as NewState
		FROM 
			dbo.Incident inc with (nolock)
			join dbo.IncidentType it with (nolock) ON it.ObjectID=inc.Type
			join dbo.Task tk with (nolock) ON tk.Incident = inc.ObjectID
			join dbo.IncidentState [is] with (nolock) ON [is].ObjectID = inc.State
			join dbo.TimeSpent ts with (nolock) ON ts.Task=tk.ObjectID
		WHERE 
			tk.Worker = @Employee
			AND (
				(ts.RegDate BETWEEN @IntervalBegin and @IntervalEnd and @AnalysDirection = 0)
				OR
				(@AnalysDirection = 1 AND [is].IsStartState = 1)
			)							
			AND [is].Category = IsNull(@IncidentState, [is].Category)
			AND @ExpenseType in (0, 2)
		GROUP BY
			inc.[Folder], inc.[ObjectID],
			it.[Name], inc.[Number], inc.[Name],
			[is].[Name]

		UNION ALL

		SELECT
			CASE WHEN tl.Folder IS Null THEN 3 ELSE 4 END, 
			IsNull(tl.Folder, tlc.[ObjectID]),
			IsNull(dbo.GetFolderPath(f.[ObjectID], 1),tlc.[Name]),
			tlc.ObjectID,
			tlc.[Name],
			CASE WHEN tl.Folder IS Null THEN 1 ELSE 0 END,
			tl.LossFixed,
			tl.LostTime,
			Cast( Null As INT),
			CASE WHEN tl.Folder IS Null THEN cast(substring(tl.Descr, 1, 8000) as varchar(8000))  ELSE Null END,
			CAST(Null AS VARCHAR(1024)) NewState
		FROM 
			dbo.TimeLoss tl with (nolock)
			join dbo.TimeLossCause tlc with (nolock) on tlc.Objectid = tl.Cause
			LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID=tl.Folder
		WHERE 
			tl.Worker = @Employee
			and tl.LossFixed BETWEEN @IntervalBegin AND @IntervalEnd
			and @ExpenseType in (1, 2)
			and @AnalysDirection = 0
			and (@NonProjectExpences = 0 OR tl.Folder IS NOT Null)
		) x
	GROUP BY
		x.CauseType, 
		x.ActivityID,
		x.ActivityName, 
		x.CauseID,
		x.CauseName,
		x.Comments,
		x.NewState
	) x
	LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID = x.ActivityID AND x.CauseType!=3
	LEFT JOIN dbo.Folder topF with (nolock) ON topF.Customer=f.Customer AND topF.LIndex <= f.LIndex AND topF.RIndex >= f.RIndex AND topF.LRLevel=0
WHERE
	f.ObjectID IS NULL OR (topF.Type & IsNull(@ActivityType, topF.Type) !=0)
ORDER BY 
	CASE WHEN @SectionByActivity!=0 THEN CASE WHEN topF.ObjectID IS NULL THEN 1 ELSE 0 END ELSE 0 END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[Name] END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[ObjectID] END,
");
                    break;
                case (int)ExpenseDetalization.BySubActivity:
                    bNewState = bComment = bIncidentAttributes = false;
                    sb.Append(@"
SELECT
	IsNull(topF.[ObjectID], CAST( 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF as UniqueIdentifier )) topFolder,
	IsNull(topF.[Name],'Не проектные списания') topName,
	x.*
FROM
	(
	SELECT
		x.CauseType, 
		x.ActivityID,
		x.ActivityName,
		x.ActivityID CauseID,
		x.ActivityName CauseName,
		Sum(x.NumberOfTasks) NumberOfTasks, 
		Max(x.DateSpent) DateSpent ,
		Sum(x.Spent) Spent, 
		Sum(x.LeftTime) LeftTime, 
		CAST(Null AS VARCHAR(1024)) NewState,
		x.Comments  
	FROM
		(
		SELECT
			2 as CauseType,
			inc.[Folder] as ActivityID,
			dbo.GetFolderPath(inc.[Folder], 1)	as ActivityName,
			1 NumberOfTasks,
			MAX(ts.RegDate) as DateSpent,
			SUM(ts.Spent) as Spent,
			SUM(tk.LeftTime) as LeftTime,
			CAST(Null AS VARCHAR(8000)) as Comments
		FROM 
			dbo.Incident inc with (nolock)
			join dbo.Task tk with (nolock) ON tk.Incident = inc.ObjectID
			join dbo.IncidentState [is] with (nolock) ON [is].ObjectID = inc.State
			join dbo.TimeSpent ts with (nolock) ON ts.Task=tk.ObjectID
		WHERE 
			tk.Worker = @Employee
			AND (
				(ts.RegDate BETWEEN @IntervalBegin and @IntervalEnd and @AnalysDirection = 0)
				OR
				(@AnalysDirection = 1 AND [is].IsStartState = 1)
			)							
			AND [is].Category = IsNull(@IncidentState, [is].Category)
			AND @ExpenseType in (0, 2)
		GROUP BY
			inc.[Folder], inc.[ObjectID]

		UNION ALL

		SELECT
			CASE WHEN tl.Folder IS Null THEN 3 ELSE 4 END, 
			IsNull(tl.Folder, tlc.[ObjectID]),
			IsNull(dbo.GetFolderPath(f.[ObjectID], 1),tlc.[Name]),
			CASE WHEN tl.Folder IS Null THEN 1 ELSE 0 END,
			tl.LossFixed,
			tl.LostTime,
			Cast( Null As INT),
			CASE WHEN tl.Folder IS Null THEN cast(substring(tl.Descr, 1, 8000) as varchar(8000))  ELSE Null END
		FROM 
			dbo.TimeLoss tl with (nolock)
			join dbo.TimeLossCause tlc with (nolock) on tlc.Objectid = tl.Cause
			LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID=tl.Folder
		WHERE 
			tl.Worker = @Employee
			and tl.LossFixed BETWEEN @IntervalBegin AND @IntervalEnd
			and @ExpenseType in (1, 2)
			and @AnalysDirection = 0
			and (@NonProjectExpences = 0 OR tl.Folder IS NOT Null)
		) x
	GROUP BY
		x.CauseType, 
		x.ActivityID,
		x.ActivityName, 
		x.Comments
	) x
	LEFT JOIN dbo.Folder f with (nolock) ON f.ObjectID = x.ActivityID AND x.CauseType!=3
	LEFT JOIN dbo.Folder topF with (nolock) ON topF.Customer=f.Customer AND topF.LIndex <= f.LIndex AND topF.RIndex >= f.RIndex AND topF.LRLevel=0
WHERE
	(f.ObjectID IS NULL) OR f.Type & IsNull(@ActivityType, f.Type)!=0 OR  (f.Type = 16 AND (topF.Type & IsNull(@ActivityType, topF.Type) !=0))
ORDER BY 
	CASE WHEN @SectionByActivity!=0 THEN CASE WHEN topF.ObjectID IS NULL THEN 1 ELSE 0 END ELSE 0 END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[Name] END,
	CASE WHEN @SectionByActivity!=0 THEN topF.[ObjectID] END,
");
                    break;
                default:
                    throw new ArgumentException("Недопустимое значение параметра ExepenseDetalization");
            }


            switch (Sort)
            {
                case (int)SortIncidentExpenses.ByDateTime:
                    sb.Append("DateSpent");
                    break;
                case (int)SortIncidentExpenses.ByLossReason:
                    sb.Append("CauseName");
                    break;
                case (int)SortIncidentExpenses.BySpentTime:
                    sb.Append("Spent");
                    break;
                default:
                    throw new ArgumentException("Недопустимое значение параметра Sort");
            }

            switch (SortOrder)
            {
                case (int)IncidentTracker.SortOrder.Asc:
                    sb.Append(" ASC");
                    break;
                case (int)IncidentTracker.SortOrder.Desc:
                    sb.Append(" DESC");
                    break;
                default:
                    throw new ArgumentException("Недопустимое значение параметра SortOrder");
            }

            // Получим данные
            using (XDbCommand cmd = SourceData.XmlStorage.CreateCommand())
            {
                cmd.CommandText = sb.ToString();
                cmd.Parameters.Add("@IntervalBegin", DbType.DateTime, ParameterDirection.Input, true, NullToDBNull(IntervalBegin));
                cmd.Parameters.Add("@IntervalEnd", DbType.DateTime, ParameterDirection.Input, true, NullToDBNull(IntervalEnd));
                cmd.Parameters.Add("@Employee", DbType.Guid, ParameterDirection.Input, false, NullToDBNull(Employee));
                cmd.Parameters.Add("@NonProjectExpences", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(NonProjectExpences));
                cmd.Parameters.Add("@IncludeParams", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(IncludeParams));
                cmd.Parameters.Add("@AnalysDirection", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(AnalysDirection));
                cmd.Parameters.Add("@TimeLossReason", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(TimeLossReason));
                cmd.Parameters.Add("@SectionByActivity", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(SectionByActivity));
                cmd.Parameters.Add("@ExepenseDetalization", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(ExepenseDetalization));
                cmd.Parameters.Add("@TimeMeasureUnits", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(TimeMeasureUnits));
                cmd.Parameters.Add("@ActivityType", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(ActivityType));
                cmd.Parameters.Add("@ExpenseType", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(ExpenseType));
                cmd.Parameters.Add("@IncidentState", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(IncidentState));
                cmd.Parameters.Add("@Sort", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(Sort));
                cmd.Parameters.Add("@SortOrder", DbType.Int32, ParameterDirection.Input, true, NullToDBNull(SortOrder));
                return cmd.ExecuteReader();
            }
        }
        private object NullToDBNull(object o)
        {
            return null == o ? DBNull.Value : o;
        }
    }
    #endregion
    #region Затраты в разрезе направлений
    class ExpencesDatesDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            r_ExpensesByDirections.ThisReportParams oParams = SourceData.CustomData as r_ExpensesByDirections.ThisReportParams;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = "SELECT ExpensesDateMin, ExpensesDateMax FROM dbo.GetMinimaxBoundingDates( @uidOrganizationID, @uidFolderID, @nFolderTypes, @nOnlyOpenedActivity )";
            cmd.Parameters.Add("uidOrganizationID", DbType.Guid, ParameterDirection.Input, true, oParams.Organization);
            cmd.Parameters.Add("uidFolderID", DbType.Guid, ParameterDirection.Input, true, oParams.Folder);
            cmd.Parameters.Add("nFolderTypes", DbType.Int32, ParameterDirection.Input, true, oParams.FolderType);
            cmd.Parameters.Add("nOnlyOpenedActivity", DbType.Int16, ParameterDirection.Input, true, (oParams.OnlyActiveFolders ? 1 : 0));

            return cmd.ExecuteReader();
        }
    }
    class ExpencesByDirectionsMainDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            r_ExpensesByDirections.ThisReportParams oParams = SourceData.CustomData as r_ExpensesByDirections.ThisReportParams;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandText = "dbo.rep_ExpensesByDirections";
            cmd.CommandType = CommandType.StoredProcedure;

            // ПАРАМЕТРЫ:
            cmd.Parameters.Add("dtIntervalBegin", DbType.DateTime, ParameterDirection.Input, true, oParams.IntervalBegin);
            cmd.Parameters.Add("dtIntervalEnd", DbType.DateTime, ParameterDirection.Input, true, oParams.IntervalEnd);

            // Актуальные значения идентификаторов организации / активности (Guid или 
            // DbNull) уже приведены в согласованное состояние, в соответствии с заданным
            // направлением анализа - добавляем значения как они есть
            cmd.Parameters.Add("uidOrganizationID", DbType.Guid, ParameterDirection.Input, true, oParams.Organization);
            cmd.Parameters.Add("uidFolderID", DbType.Guid, ParameterDirection.Input, true, oParams.Folder);

            cmd.Parameters.Add("nFolderTypes", DbType.Int32, ParameterDirection.Input, false, oParams.FolderType);
            cmd.Parameters.Add("nOnlyOpenedActivity", DbType.Byte, ParameterDirection.Input, false, oParams.OnlyActiveFolders);

            cmd.Parameters.Add("nInDetail", DbType.Byte, ParameterDirection.Input, false, oParams.ShowDetails);
            cmd.Parameters.Add("nSortByName", DbType.Byte, ParameterDirection.Input, false, (0 == oParams.SortBy ? 1 : 0));

            return cmd.ExecuteReader();
        }
    }
    class ExpencesByDirectionsHeaderParamsDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            r_ExpensesByDirections.ThisReportParams oParams = SourceData.CustomData as r_ExpensesByDirections.ThisReportParams;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandType = CommandType.Text;

            if (r_ExpensesByDirections.ThisReportParams.AnalysisDirectionEnum.ByActivity == oParams.AnalysisDirection)
            {
                cmd.CommandText = "SELECT dbo.GetFullFolderName( @uidFolderID,0)";
                cmd.Parameters.Add("uidFolderID", DbType.Guid, ParameterDirection.Input, false, oParams.Folder);
            }
            else // ExpensesByDirections_AnalysisDirection.ByCustomer_TargetCustomer
            {
                cmd.CommandText = "SELECT o.[Name] FROM dbo.Organization o WITH(NOLOCK) WHERE o.ObjectID = @uidOrganizationID";
                cmd.Parameters.Add("uidOrganizationID", DbType.Guid, ParameterDirection.Input, false, oParams.Organization);
            }
            return cmd.ExecuteScalar().ToString();
        }
    }
    class ExpencesByDirectionsHistoryDS : IReportDataSource
    {
        object IReportDataSource.GetData(abstractdatasourceClass DataSourceProfile, ReportDataSourceData SourceData)
        {
            r_ExpensesByDirections.ThisReportParams oParams = SourceData.CustomData as r_ExpensesByDirections.ThisReportParams;
            XDbCommand cmd = SourceData.XmlStorage.CreateCommand();
            cmd.CommandType = CommandType.Text;
            cmd.CommandText = @"
                    SELECT TOP 1 
	                    CONVERT( varchar(10), hst.EventDate, 104) + ' ' + CONVERT( varchar(5), hst.EventDate, 108  ) + ', ' +
	                    ISNULL( e.LastName + ' ' + e.FirstName + ISNULL( ' (#' + e.PhoneExt + ')', '' ) , 'изменения выполнены во внешней системе' )
                    FROM 
	                    dbo.FolderHistory hst WITH(NOLOCK)
	                    /* привязка к сотрдникам - всегда через LEFT JOIN, т.к. изменения и.б. сделаны сервисом */
	                    LEFT JOIN dbo.Employee e WITH(NOLOCK) ON e.[SystemUser] = hst.[SystemUser]
                    WHERE
	                    hst.Event = 11 /* Тип события - Изменение данных по направлениям */
	                    AND hst.Folder = @FolderID
                    ORDER BY
	                    hst.EventDate DESC
                    ";
            cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, oParams.Folder);
            return cmd.ExecuteScalar();
	
        }
    }
    #endregion
}
