//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Data;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда возвращает список состояний инцидента заданного типа, в которые его может перевести текущий пользователь
	/// В запросе обязательно должны быть заданы параметры:
	///		идентификатор папки, в которой располагается инцидент (Folder)
	///		идентификатор типа инцидента (IncidentType)
	///		идентификатор текущего состояния (IncidentState)
	///		идентификатор роли пользователя в инциденте (UserRoleInIncident)
	///	Если текущий сотрудник обладает в папке инцидента привилегией "Управление участниками инцидента", 
	///	то возвращается список всех состояний для типа инцидента, иначе возвращается список состояний,
	///	в которые есть переходы из текущего состояния для заданной роли сотрудника в инциденте.
	/// </summary>
	public class GetAvailableStatesOfUserRoleCommand: XGetListDataCommand
	{
		public new XResponse Execute(XGetListDataRequest request, IXExecutionContext context)
		{
			// Результирующий текст XML:
			string resultXml = String.Empty;
			Guid FolderID;
			// Получим описание списка:
			XColumnInfo[] colInfo = XInterfaceObjectsHolder.Instance.GetListInfo( 
				request.MetaName, 
				request.TypeName, 
				context.Connection ).GetColumns();
            string sIconTemplate = XInterfaceObjectsHolder.Instance.GetListInfo(
                request.MetaName,
                request.TypeName,
                context.Connection).IconTemplate;
            int iMaxRows = XInterfaceObjectsHolder.Instance.GetListInfo(
                request.MetaName,
                request.TypeName,
                context.Connection).MaxRows;
            bool bOffIcons = XInterfaceObjectsHolder.Instance.GetListInfo(
                request.MetaName,
                request.TypeName,
                context.Connection).OffIcons;
			if (!request.Params.Contains("FolderID"))
				throw new ArgumentException("Не передан параметр 'FolderID'- идентификатор папки");
			FolderID = new Guid((string)request.Params["FolderID"]);
			XDataSource ds;
			if (((SecurityProvider)XSecurityManager.Instance.SecurityProvider).FolderPrivilegeManager.HasFolderPrivilege(
				(ITUser)XSecurityManager.Instance.GetCurrentUser(), FolderPrivileges.ManageIncidents, 
				DomainObjectData.CreateStubLoaded(context.Connection, "Folder", FolderID),
				context.Connection)
				)
			{
				// сотрудник обладает привилегией "Управление участниками инцидента"
				if (!request.Params.Contains("IncidentTypeID"))
					throw new ArgumentException("Не передан параметр 'IncidentTypeID' - идентификатор типа инцидента");
				request.Params["IncidentTypeID"] = new Guid((string)request.Params["IncidentTypeID"]);
				ds = context.Connection.GetDataSource("AllStatesOfIncidentType");
				ds.SubstituteNamedParams(request.Params, true);
			}
			else
			{
				// сотрудник НЕ обладает привилегией "Управление участниками инцидента"
				if (!request.Params.Contains("CurrentStateID"))
					throw new ArgumentException("Не передан параметр 'CurrentStateID' - идентификатор текущего состояния инцидента");
				request.Params["CurrentStateID"] = new Guid((string)request.Params["CurrentStateID"]);
				if (request.Params.Contains("UserRoleID"))
					request.Params["UserRoleID"] = new Guid((string)request.Params["UserRoleID"]);
				ds = context.Connection.GetDataSource("AvailableStatesOfUserRole");
				ds.SubstituteNamedParams(request.Params, true);
			}
            
            DataTable dtData=ds.ExecuteDataTable();
			
			// Сформируем ответ и вернем его
			return new XGetListDataResponse(colInfo,dtData,request.TypeName, iMaxRows,sIconTemplate,bOffIcons);
		}
	}
}
