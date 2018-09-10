//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда формирует информацию, достаточную для создания email письма со ссылкой на проект/инцидент
	/// </summary>
	public class GetMailMsgInfoCommand: XCommand
	{
		public GetMailMsgInfoResponse Execute(GetMailMsgInfoRequest request, IXExecutionContext context)
		{
			if (request.ObjectType != "Incident" && request.ObjectType != "Folder")
				throw new ArgumentException("Поддерживается два типа Incident и Folder, передано: " + request.ObjectType);
			bool bLinkToIncident = request.ObjectType == "Incident";
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// загрузим Папку и Инцидент
			DomainObjectData xobjFolder = loadFolderAndIncident(dataSet, request, context);
			DomainObjectData xobjIncident = null;
			if (bLinkToIncident)
				xobjIncident = dataSet.Find("Incident", request.ObjectID);

			// Получим путь к папке от корневой
			XDataSource ds = context.Connection.GetDataSource("GetFolderPath");
			Hashtable dsParams = new Hashtable();
			dsParams.Add("FolderID", xobjFolder.ObjectID);
			ds.SubstituteNamedParams( dsParams, true );
			GetMailMsgInfoResponse response = new GetMailMsgInfoResponse();
			response.FolderPath = "Проект: " + (string)ds.ExecuteScalar();

			StringBuilder bld = new StringBuilder();
			// заголовок - наименование инцидента или проекта
			bld.Append("ITRACKER: ");
			if (bLinkToIncident)
			{
				
				bld.Append("Инцидент №");
				bld.Append(xobjIncident.GetLoadedPropValue("Number"));
				bld.Append(" - ");
				bld.Append(xobjIncident.GetLoadedPropValue("Name"));
			}
			else
			{
				bld.Append(xobjFolder.GetLoadedPropValue("Name"));
			}
			response.Subject = bld.ToString();

			XmlNodeList xmlNodes = context.Config.SelectNodes("it:app-data/it:system-location/*");
			string[] aAppInstanceUrls = new string[xmlNodes.Count];
			for(int i=0;i<xmlNodes.Count;++i)
			{
				aAppInstanceUrls[i] = xmlNodes[i].InnerText;
				if (!aAppInstanceUrls[i].EndsWith("/"))
					aAppInstanceUrls[i] = aAppInstanceUrls[i] + "/";
			}
			
			// ссылки на проект
			bld.Length = 0;
			bld.Append("Просмотр проекта:");
			bld.Append(Environment.NewLine);
			foreach(string sAppUrl in aAppInstanceUrls)
			{
				bld.AppendFormat("\t{0}x-get-report.aspx?Name=r-Folder.xml&ID={1}{2}", sAppUrl, xobjFolder.ObjectID, Environment.NewLine);
			}
			bld.Append("Открыть в дереве:");
			bld.Append(Environment.NewLine);
			foreach(string sAppUrl in aAppInstanceUrls)
				bld.AppendFormat("\t{0}x-tree.aspx?METANAME=Main&LocateFolderByID={1}{2}", sAppUrl, xobjFolder.ObjectID, Environment.NewLine);
			response.ProjectLinks = bld.ToString();

			// ссылки на инцидент
			bld.Length = 0;
			if (bLinkToIncident)
			{
				bld.Append("Редактирование инцидента:");
				bld.Append(Environment.NewLine);
				foreach(string sAppUrl in aAppInstanceUrls)
					bld.AppendFormat("\t{0}x-list.aspx?OT=Incident&METANAME=IncidentSearchingList&OpenEditorByIncidentID={1}{2}", sAppUrl, xobjIncident.ObjectID, Environment.NewLine);
				bld.Append("Просмотр инцидента:");
				bld.Append(Environment.NewLine);
				foreach(string sAppUrl in aAppInstanceUrls)
					bld.AppendFormat("\t{0}x-get-report.aspx?NAME=r-Incident.xml&DontCacheXslfo=true&IncidentID={1}{2}", sAppUrl, xobjIncident.ObjectID, Environment.NewLine);
				bld.Append("Открыть в дереве:");
				bld.Append(Environment.NewLine);
				foreach(string sAppUrl in aAppInstanceUrls)
					bld.AppendFormat("\t{0}x-tree.aspx?METANAME=Main&LocateIncidentByID={1}{2}", sAppUrl, xobjIncident.ObjectID, Environment.NewLine);
				response.IncidentLinks = bld.ToString();
			}
			response.To = getUsersEMail(request, context);

			return response;
		}

		private DomainObjectData loadFolderAndIncident(DomainObjectDataSet dataSet, GetMailMsgInfoRequest request, IXExecutionContext context)
		{
			DomainObjectData xobjFolder;
			if (request.ObjectType == "Folder")
			{
				xobjFolder = dataSet.GetLoadedStub("Folder", request.ObjectID);
				dataSet.LoadProperty(context.Connection, xobjFolder, "Name");
			}
			else
			{
				XDbCommand cmd = context.Connection.CreateCommand(
					@"SELECT f.ObjectID as FolderID, f.Name as FolderName, i.Name as IncidentName, i.Number as IncidentNumber
					FROM Incident i JOIN Folder f ON i.Folder=f.ObjectID 
					WHERE i.ObjectID = @IncidentID");
				cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, request.ObjectID);
				DomainObjectData xobjIncident = dataSet.GetLoadedStub("Incident", request.ObjectID);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (!reader.Read())
						throw new XObjectNotFoundException("Incident", request.ObjectID);
					xobjFolder = dataSet.GetLoadedStub("Folder", reader.GetGuid(reader.GetOrdinal("FolderID")));
					xobjFolder.SetLoadedPropValue("Name", reader.GetString(reader.GetOrdinal("FolderName")));
					xobjIncident.SetLoadedPropValue("Name", reader.GetString(reader.GetOrdinal("IncidentName")));
					xobjIncident.SetLoadedPropValue("Number", reader.GetInt32(reader.GetOrdinal("IncidentNumber")));
					xobjIncident.SetLoadedPropValue("Folder", xobjFolder.ObjectID);
				}
			}
			return xobjFolder;
		}

		private string getUsersEMail(GetMailMsgInfoRequest request, IXExecutionContext context)
		{
			// если заданы идентификаторы сотрудников, чьи адреса требуется получить
			if (request.EmployeeIDs != null && request.EmployeeIDs.Length > 0)
				return getUsersEMail(request.EmployeeIDs, context);
			// если сотрудники явно не заданы, и задан идентификатор инцидента, то получим всех исполнителей инцидента
			if (request.ObjectType == "Incident")
				return getIncidentUsersEMail(request.ObjectID, context);
			// иначе получим всех участников проекта
			return getFolderUsersEMail(request.ObjectID, context);
		}

		private string getIncidentUsersEMail(Guid IncidentID, IXExecutionContext context)
		{
			XDbCommand cmd = context.Connection.CreateCommand(
				"SELECT emp.EMail FROM Task t JOIN Employee emp ON t.Worker = emp.ObjectID WHERE t.Incident = @IncidentID"
				);
			cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, IncidentID);
			return readEMails(cmd);
		}

		private string getFolderUsersEMail(Guid FolderID, IXExecutionContext context)
		{
			XDbCommand cmd = context.Connection.CreateCommand(
				"SELECT emp.EMail FROM ProjectParticipant pp JOIN Employee emp ON pp.Employee = emp.ObjectID WHERE pp.Folder = @FolderID"
				);
			cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, FolderID);
			return readEMails(cmd);
		}

		private string getUsersEMail(Guid[] aEmployeeIDs, IXExecutionContext context)
		{
			StringBuilder bld = new StringBuilder();
			foreach(Guid oid in aEmployeeIDs)
			{
				if (bld.Length > 0)
					bld.Append(", ");
				bld.Append(context.Connection.ArrangeSqlGuid(oid));
			}
			XDbCommand cmd = context.Connection.CreateCommand("SELECT Email FROM Employee WHERE ObjectID IN (" + bld.ToString() + ")");
			return readEMails(cmd);
		}

		/// <summary>
		/// Возвращает строку из емейлов, считанных из первой колонки результата выполнения переданной команды
		/// ВНИМАНИЕ: В список емейлов не включается емейл текущего пользователя
		/// </summary>
		/// <param name="cmd"></param>
		/// <returns></returns>
		private string readEMails(XDbCommand cmd)
		{
			StringBuilder bld = new StringBuilder();
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			string sIgnore = null;
			if (user.EMail != null && user.EMail.Length > 0)
				sIgnore = user.EMail;
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while (reader.Read())
				{
					if (!reader.IsDBNull(reader.GetOrdinal("EMail")))
					{
						string sEmail = reader.GetString(reader.GetOrdinal("EMail"));
						if (!sEmail.Equals(sIgnore))
						{
							if (bld.Length > 0)
								bld.Append(";");
							bld.Append(sEmail);
						}
					}
				}
			}
			return bld.ToString();
		}
	}
}
