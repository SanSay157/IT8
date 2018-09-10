//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
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
	/// ������� ���������� ������ ��������� ��������� ��������� ����, � ������� ��� ����� ��������� ������� ������������
	/// � ������� ����������� ������ ���� ������ ���������:
	///		������������� �����, � ������� ������������� �������� (Folder)
	///		������������� ���� ��������� (IncidentType)
	///		������������� �������� ��������� (IncidentState)
	///		������������� ���� ������������ � ��������� (UserRoleInIncident)
	///	���� ������� ��������� �������� � ����� ��������� ����������� "���������� ����������� ���������", 
	///	�� ������������ ������ ���� ��������� ��� ���� ���������, ����� ������������ ������ ���������,
	///	� ������� ���� �������� �� �������� ��������� ��� �������� ���� ���������� � ���������.
	/// </summary>
	public class GetAvailableStatesOfUserRoleCommand: XGetListDataCommand
	{
		public new XResponse Execute(XGetListDataRequest request, IXExecutionContext context)
		{
			// �������������� ����� XML:
			string resultXml = String.Empty;
			Guid FolderID;
			// ������� �������� ������:
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
				throw new ArgumentException("�� ������� �������� 'FolderID'- ������������� �����");
			FolderID = new Guid((string)request.Params["FolderID"]);
			XDataSource ds;
			if (((SecurityProvider)XSecurityManager.Instance.SecurityProvider).FolderPrivilegeManager.HasFolderPrivilege(
				(ITUser)XSecurityManager.Instance.GetCurrentUser(), FolderPrivileges.ManageIncidents, 
				DomainObjectData.CreateStubLoaded(context.Connection, "Folder", FolderID),
				context.Connection)
				)
			{
				// ��������� �������� ����������� "���������� ����������� ���������"
				if (!request.Params.Contains("IncidentTypeID"))
					throw new ArgumentException("�� ������� �������� 'IncidentTypeID' - ������������� ���� ���������");
				request.Params["IncidentTypeID"] = new Guid((string)request.Params["IncidentTypeID"]);
				ds = context.Connection.GetDataSource("AllStatesOfIncidentType");
				ds.SubstituteNamedParams(request.Params, true);
			}
			else
			{
				// ��������� �� �������� ����������� "���������� ����������� ���������"
				if (!request.Params.Contains("CurrentStateID"))
					throw new ArgumentException("�� ������� �������� 'CurrentStateID' - ������������� �������� ��������� ���������");
				request.Params["CurrentStateID"] = new Guid((string)request.Params["CurrentStateID"]);
				if (request.Params.Contains("UserRoleID"))
					request.Params["UserRoleID"] = new Guid((string)request.Params["UserRoleID"]);
				ds = context.Connection.GetDataSource("AvailableStatesOfUserRole");
				ds.SubstituteNamedParams(request.Params, true);
			}
            
            DataTable dtData=ds.ExecuteDataTable();
			
			// ���������� ����� � ������ ���
			return new XGetListDataResponse(colInfo,dtData,request.TypeName, iMaxRows,sIconTemplate,bOffIcons);
		}
	}
}
