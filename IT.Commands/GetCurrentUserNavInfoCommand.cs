//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Public;
namespace Croc.IncidentTracker.Commands
{
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetCurrentUserNavInfoCommand : XCommand
	{
		/// <summary>
		/// ����������� ������������ ��������� ������
		/// </summary>
		const string DEF_DATASOURCE_NAME = "GetEmployeeUsersProfileID";

		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public GetCurrentUserNavInfoResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			// ���������:
			GetCurrentUserNavInfoResponse response = new GetCurrentUserNavInfoResponse();
			// ����� ������� �������� �� ���������:
			response.NavigationInfo.ShowExpensesPanel = true;
			response.NavigationInfo.ExpensesPanelAutoUpdateDelay = 0;
			response.NavigationInfo.UseOwnStartPage = false;

			// �������� �������������:
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			// ... ���� ������������ �� ���������������� ��� ���� ��� ��������� 
			// ������, �� ���������� "������" ������; Web-������� ����������� 
			// ��� ��������:
			if (!user.IsAuthenticated || user.IsServiceAccount)
				return response;

			// #1: ��������� ������� ������������
			//	-- ���� ������������ ����������������
			//	-- ���� ��� �� ��������� ������
			DomainObjectData dodUserProfile = getUserProfile( user.SystemUserID, context.Connection );
			if ( null!=dodUserProfile )
			{
				// �������� �������� ������� ������� ������� � ��������� �������� 
				// � ������-��������, �� ������ ���� ��� ������� �� NULL (����� 
				// ����� ����������� �������� �� ���������, ������� ����):
				object oValue = dodUserProfile.GetLoadedPropValue("ShowExpensesPanel");
				if (DBNull.Value!=oValue)
					response.NavigationInfo.ShowExpensesPanel = (bool)oValue;

				oValue = dodUserProfile.GetLoadedPropValue("ExpensesPanelAutoUpdateDelay");
				if (DBNull.Value!=oValue)
					response.NavigationInfo.ExpensesPanelAutoUpdateDelay = (int)oValue;

				oValue = dodUserProfile.GetLoadedPropValue("StartPage");
				if (DBNull.Value!=oValue)
				{
					response.NavigationInfo.UseOwnStartPage = true;
					response.NavigationInfo.OwnStartPage = (StartPages)oValue;
				}
			}
			else
			{
				// ������ �� "�����" �������� �� ������ - �� ��������� 
				// ���� �� �������� "��� ���������"
				response.NavigationInfo.UseOwnStartPage = true;
				response.NavigationInfo.OwnStartPage = StartPages.CurrentTaskList;
			}

			
			// #2: ������ ���������� ������������ - ������������ ��������� ��������� ������������� ������:
			//	-- ���� ������������ ����������������
			//	-- ���� ��� �� ��������� ������
			
			// ��������� �������������� ��������� ��������� ������������� ������:
			// ...�������� ������� - �������� ������
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_HomePage, String.Empty );
			// ...�������� "�������-�������" - �������� ������
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_CustomerActivityTree, String.Empty );
			// ...������ �������� - �������� ������
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_ActivityList, String.Empty );
			// ...������ "��� ���������" - �������� ������
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_CurrentTasks, String.Empty );
			// ...������ "����� ����������" - �������� ������
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_IncidentList, String.Empty );
			// ...������ "��������" - �������� ������, �� ��� ������ ���������� ��������� ������ URL:
			if ( user.HasPrivilege( SystemPrivilegesItem.ManageTimeLoss.Name ) || user.IsUnrestricted )
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_TimeLossSearchingList, "x-list.aspx?OT=TimeLoss&METANAME=TimeLossSearchingListAdm" );
			else
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_TimeLossSearchingList, "x-list.aspx?OT=TimeLoss&METANAME=TimeLossSearchingList" );
			// ...������ - �������� ����:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_Reports, String.Empty );
			// ...�������� "��������� ��������" - �������� ����:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_OrgStructure, String.Empty );
			// ...������� "����� ���������" - �������� ����:
			response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_FindIncident, String.Empty );

			// ������������� �������� ���� �������� ������ ���� ���� ���������� "������ � ���"
			if ( user.HasPrivilege( SystemPrivilegesItem.AccessIntoTMS.Name ) || user.IsUnrestricted )
			{
				// ...�������� �������� ���
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.TMS_HomePage, String.Empty );
				// ...������ ��������
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.TMS_TenderList, String.Empty );
			}

			// ...���������������� ��������� �������� ������ "���������������" ������������
			if ( user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name) || user.IsUnrestricted)
				response.NavigationInfo.UsedNavigationItems.Add( NavigationItemIDs.IT_Administation, String.Empty );


			// #3: �������� ��������� ��������: ���� �������� �������� ����������,
			// �� ������� �������� "�����������" ���������� �������� (������������
			// ������� �� "��������":
			if (response.NavigationInfo.UseOwnStartPage)
			{
				string sOwnStartPageID = UserNavigationInfo.StartPage2NavItemID( response.NavigationInfo.OwnStartPage );
				if ( null != sOwnStartPageID )
					if ( null == response.NavigationInfo.UsedNavigationItems.GetValues(sOwnStartPageID) )
						sOwnStartPageID = null;
				if ( null == sOwnStartPageID )
					response.NavigationInfo.UseOwnStartPage = false;
			}

			return response;
		}


		/// <summary>
		/// ���������� ����� ��������� ������ ������� UserProfile ��� ������������
		/// �������, ��������� ��������������� (SystemUser.ObjectID).
		/// </summary>
		/// <param name="uidSystemUserID">������������� ������������</param>
		/// <returns>
		/// -- ������������������ ������ DomainObjectData, ����������� ������ UserProfile
		/// -- null, ���� ������� ������������ ��� (���, � �������� ��������)
		/// </returns>
		protected DomainObjectData getUserProfile( Guid uidSystemUserID, XStorageConnection connection ) 
		{
			// ������� ������������� ������� UserProfile, ���������������� 
			// ���������� ������������; ��� ����� ������������� ��������, 
			// "�������" � data-source:

			// ...�������� ������� - ������������� ������������:
			XParamsCollection datasourceParams = new XParamsCollection();
			datasourceParams.Add( "UserID", uidSystemUserID );
			// ...��������� � ���������� ��������� ������:
			XDataSource dataSource = connection.GetDataSource( DEF_DATASOURCE_NAME );
			dataSource.SubstituteNamedParams( datasourceParams, true );
			dataSource.SubstituteOrderBy();
			object oResult = dataSource.ExecuteScalar();
			
			// ���������, ��� � ���������� �� �������� GUID: ���� � ���������� 
			// �������� null - ��� ������� �� ���������� ������� - ���������� null:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );
			if (Guid.Empty == uidResult)
				return null;
			
			// �������� ������ ������� ������������:
			DomainObjectDataSet dataSet = new DomainObjectDataSet( connection.MetadataManager.XModel );
			DomainObjectData xobj = dataSet.Load( connection, "UserProfile", uidResult );
			return xobj;			
		}
	}
}