//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Web;
using Croc.IncidentTracker.Commands.Security;
using Croc.IncidentTracker.Commands.Trees;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Hierarchy;
using Croc.IncidentTracker.Storage;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Configuration;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.XUtils;
using XTreeLevelInfoIT = Croc.IncidentTracker.Hierarchy.XTreeLevelInfoIT;
using System.Globalization;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// ���������� "����������" ���� ��� �������� "������� � �������" (���)
	/// </summary>
	public class DKPTreeMenuLoadProvider : XTreeMenuDataProviderStd
	{
		/// <summary>
		/// �������� ����� ��������� ������ ����, "�������" �����. ���������� 
		/// �� �������������� XFW / IT HierarchySubsystem
		/// </summary>
		/// <param name="request">������ �������� ��������� ���� GetTreeMenu</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <param name="treePage">��������� �������� ������ �������� ��������</param>
		/// <returns>��������� �������� ����</returns>
		public override XTreeMenuInfo GetMenu( XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage ) 
		{
			XTreeStructInfo treeStructInfo = treePage.TreeStruct;
			XTreeLevelInfoIT levelinfo = treeStructInfo.Executor.GetTreeLevel(treeStructInfo, request.Params, request.Path);

			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// ������� ������������� �������, ��� �������� �������� ����
			Guid ObjectID = request.Path.PathNodes[0].ObjectID;
			XTreeMenuInfo treemenu;
			if (levelinfo.ObjectType == "Organization" || levelinfo.ObjectType == "HomeOrganization")
			{
				treemenu = buildMenuForOrganization( ObjectID, request.Path, dataSet, context.Connection );
			}
			else if (levelinfo.ObjectType == "Folder")
			{
				treemenu = getMenuForFolder(request.Path, dataSet, context);
			}
			else if (levelinfo.ObjectType == "ActivityType" || levelinfo.ObjectType == "ActivityTypeInternal" || levelinfo.ObjectType == "ActivityTypeExternal")
			{
				treemenu = getMenuForActivityType(request.Path, dataSet, context.Connection);
			}
			else if (levelinfo.ObjectType == "Incident")
			{
				treemenu = getMenuForIncident(ObjectID, dataSet, context);
			}
            else if (levelinfo.ObjectType == "Stuff" || levelinfo.ObjectType == "UserRoleInProject")
			{
				// ��� ����������� ����� "��������� �������" � "��� ���������", � ����� � �������������� ��������� ����
				treemenu = getMenuForTeamAndRoleNode(request.Path, dataSet);
			}

            else if (levelinfo.ObjectType == "Contracts" /*|| levelinfo.ObjectType == "OutLimits" */ || levelinfo.ObjectType == "Incomes" /* || levelinfo.ObjectType == "Outcomes" */)
            {
                // ��� ����������� ����� "�������", "������", "�������"
                treemenu = getMenuForContractsVirtualNode(request.Path, dataSet);
            }

            else if (levelinfo.ObjectType == "OutDoc")
            {
                // ��� ����� "��������� ��������"
                treemenu = getMenuForOutDocument(request.Path, dataSet, context.Connection);
            }
            
            
            else if (levelinfo.ObjectType == "Contract")
            {
                treemenu = getMenuForContract(request.Path, dataSet, context.Connection);
            }
			else if (levelinfo.ObjectType == "ProjectParticipant")
			{
				treemenu = getMenuForProjectParticipant(request.Path, dataSet, context.Connection);
			}
            else if (levelinfo.ObjectType == "AOReason")
            {
                treemenu = getMenuForAO(request.Path, dataSet, context.Connection);
            }
			else
				treemenu = levelinfo.GetMenu(request, context);


			if (treemenu == null)
				treemenu = treePage.DefaultLevelMenu.GetMenu(levelinfo, request, context);

			if (treemenu != null)
			{
				if (context.Config.IsDebugMode)
				{
					XMenuActionItem item = treemenu.Items.AddActionItem("��������", StdActions.DoNodeRefresh);
					if (treemenu.Items.Count > 1)
						item.SeparatorBefore = true;
				}
			}
			return treemenu;
		}

        #region ���� ��� ����� ���� "��������� �������"

        private XTreeMenuInfo getMenuForContract(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
            CultureInfo culture = new CultureInfo("ru-RU");
            IDictionary arDataRows = null;
            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            
            try
            {
                // ��. s-tree-DKP.vbs
                menu.ExecutionHandlers.Add(new XUserCodeWeb("DKP_ContractMenu_ExecutionHandler"));
                DomainObjectData xobj = dataSet.Load(con, "Contract", path[0].ObjectID);

                XObjectRights rights;
                rights = XSecurityManager.Instance.GetObjectRights(xobj);

                XMenuSection menu_sec;

                Guid contractID = path.PathNodes[0].ObjectID;

                if (rights.AllowParticalOrFullChange)
                {
                    item = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
                    item.Title = "�������������";
                }
                if (rights.AllowDelete)
                {
                    item = menu.Items.AddActionItem("�������", StdActions.DoDelete);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE");
                    item.Title = "�������";
                }

                // ��������� ��������������� ������
                XDbCommand cmd = con.CreateCommand(@"
					SELECT
	                (SELECT dbo.GetSumString(SUM(oc.Sum), null)
	                 FROM dbo.OutContract oc 
		                inner join dbo.[Contract] c on oc.[Contract] = c.ObjectID
	                 WHERE c.ObjectID = @ContractID) as OutContractSum,
	                (SELECT dbo.GetSumString(SUM(o.Sum), null)
	                 FROM dbo.Outcome o 
	                   join dbo.[Contract] c on o.[Contract] = c.ObjectID
	                 WHERE c.ObjectID =  @ContractID) as OutcomesSum,
	                 (SELECT dbo.GetSumString(SUM(od.Sum), null)
	                 FROM dbo.OutDoc od 
	                   join dbo.[Contract] c on od.[Contract] = c.ObjectID
	                 WHERE c.ObjectID =  @ContractID) as OutDocSum
					");
                cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, contractID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                       arDataRows = Utils._GetDataFromDataRow(reader);
                }
                menu_sec = menu.Items.AddSection("������� �� �������");

                string sOutContractSum = Utils.ParseDBString(arDataRows["OutContractSum"].ToString()).ToString("C2", culture) + " ��� � ���";
                menu_sec.Items.AddInfoItem("����� ����� ��������� ���������", sOutContractSum);
                string sOutcomesSum = Utils.ParseDBString(arDataRows["OutcomesSum"].ToString()).ToString("C2", culture) + " ��� � ���";
                menu_sec.Items.AddInfoItem("����� ����� �������� ��� ��������� �� �������", sOutcomesSum);
                string sOutDocSum = Utils.ParseDBString(arDataRows["OutDocSum"].ToString()).ToString("C2", culture) + " ��� � ���";
                menu_sec.Items.AddInfoItem("����� ����� ��������� ����������", sOutDocSum);
                menu_sec = menu.Items.AddSection("������");
                item = menu_sec.Items.AddActionItem("�������� ������ ������� � �������� �������", "DoRunReport");
                item.Parameters.Add("ReportName", "ProjectBudget");
                item.Parameters.Add("UrlParams", ".InContract=@@ContractID");
                item = menu_sec.Items.AddActionItem("���-���� �� �������", "DoRunReport");
                item.Parameters.Add("ReportName", "ProjectBDDS");
                item.Parameters.Add("UrlParams", ".InContract=@@ContractID");
            }
            catch(XObjectNotFoundException)
            {
                // ������ �� ������ � ��
                menu.Items.AddInfoItem("", "������ ������ �� ��");
            }
            return menu;
        }

        #endregion

        #region ���� ��� ����� ���� "��������� ��������"

        private XTreeMenuInfo getMenuForOutDocument(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

            menu.CacheMode = XTreeMenuCacheMode.NoCache;

            try
            {
                DomainObjectData xobj = dataSet.Load(con, "OutDoc", path[0].ObjectID);

                XObjectRights rights;
                rights = XSecurityManager.Instance.GetObjectRights(xobj);

                Guid outDocumentID = path.PathNodes[0].ObjectID;

                if (rights.AllowParticalOrFullChange)
                {
                    item = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
                    item.Title = "�������������";
                }
                if (rights.AllowDelete)
                {
                    item = menu.Items.AddActionItem("�������", StdActions.DoDelete);
                    item.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_PARENTNODE");
                    item.Title = "�������";
                }


                // ��������� ������ �������� �� �������� ���������
                XDbCommand cmd = con.CreateCommand(@"
                    SELECT ot.Name as OutTypeName, 
	                       dbo.GetSumString(o.[Sum], null) as OutSum,
	                       CONVERT(varchar(10), o.[Date], 4) as OutDate,
	                       o.Fact as IsOutFact
                    FROM dbo.Outcome o
	                     join dbo.OutDoc od WITH (NOLOCK) on o.Document = od.ObjectID 
	                     join dbo.OutType ot WITH (NOLOCK) on o.[Type] = ot.ObjectID
                    WHERE od.ObjectID =  @OutDocumentID
					");
                cmd.Parameters.Add("OutDocumentID", DbType.Guid, ParameterDirection.Input, false, outDocumentID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        XMenuSection menu_sec = menu.Items.AddSection("������� �� ���������");
                        
                        do
                        {
                            string sOutTypeName = reader.GetString(reader.GetOrdinal("OutTypeName"));
                            string sOutSum = reader.GetString(reader.GetOrdinal("OutSum"));
                            string sOutDate = reader.GetString(reader.GetOrdinal("OutDate"));
                            bool IsOutFact = reader.GetBoolean(reader.GetOrdinal("IsOutFact"));
                            string sIsOutFact = IsOutFact ? "�����������" : "��������";
                            string sCaption = sOutTypeName + ": [" + sOutDate + "]  - " + sOutSum;

                            menu_sec.Items.AddInfoItem(sCaption, sIsOutFact);
                        }
                        while (reader.Read());

                    }
                }
            }
            catch (XObjectNotFoundException)
            {
                // ������ �� ������ � ��
                menu.Items.AddInfoItem("", "������ ������ �� ��");
            }
            return menu;
        }

        #endregion

        #region ���� ��� ����� ���� "���������� ���������� ������"

        private XTreeMenuInfo getMenuForAO(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
        {
            XMenuActionItem item;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            

            try
            {   
                Guid AOReasonID = path.PathNodes[0].ObjectID;
                Guid ContractID = path.PathNodes[2].ObjectID;   
                
                DomainObjectData xobjNew = dataSet.CreateStubNew("AO");
                xobjNew.SetUpdatedPropValue("Contract", ContractID);
                xobjNew.SetUpdatedPropValue("Reason", AOReasonID);

                if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                {
                    // ������� ��������� ����� �� ������� �������
                    item = menu.Items.AddActionItem("������� ��������� �����", StdActions.DoCreate);
                    item.Parameters.Add("ObjectType", "AO");
                    item.Parameters.Add("URLPARAMS", ".Contract=" + ContractID.ToString());
                    item.Parameters.Add("RefreshFlags", "TRM_PARENT+TRM_NODE");
                }
                

                // ��������� ������ ��������� ������� �� �������� �����������
                XDbCommand cmd = con.CreateCommand(@"
                    SELECT
	                    CONVERT(varchar(10), a.[Date], 4) as AODate,
	                    dbo.GetSumString(a.[Sum], NULL) AS AOSum,
	                    dbo.GetEmployeeString(a.Employee) as AOEmployee
                    FROM
	                    dbo.AO a
	                    join dbo.[Contract] c WITH (NOLOCK) on a.[Contract] = c.ObjectID
                    WHERE 
	                    c.ObjectID = @ContractID and a.Reason = @AOReasonID
                    ORDER BY a.[Date]
					");
                cmd.Parameters.Add("AOReasonID", DbType.Guid, ParameterDirection.Input, false, AOReasonID);
                cmd.Parameters.Add("ContractID", DbType.Guid, ParameterDirection.Input, false, ContractID);

                using (IDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        XMenuSection menu_sec = menu.Items.AddSection("��������� ������");

                        do
                        {
                            string sAODate = reader.GetString(reader.GetOrdinal("AODate"));
                            string sAOSum = reader.GetString(reader.GetOrdinal("AOSum"));
                            string sAOEmployee = reader.GetString(reader.GetOrdinal("AOEmployee"));
                            string sCaption = "[" + sAODate + "]  - " + sAOSum;

                            menu_sec.Items.AddInfoItem(sCaption, sAOEmployee);
                        }
                        while (reader.Read());

                    }
                }
            }
            catch (XObjectNotFoundException)
            {
                // ������ �� ������ � ��
                menu.Items.AddInfoItem("", "������ ������ �� ��");
            }
            return menu;
        }

        #endregion

		private XTreeMenuInfo getMenuForProjectParticipant(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
		{
			XMenuActionItem item;
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);

			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// ��. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			DomainObjectData xobj = dataSet.Load(con,"ProjectParticipant", path[0].ObjectID);
			Guid employeeID = (Guid) xobj.GetPropValue("Employee", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			Guid folderID = (Guid) xobj.GetPropValue("Folder",DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			menu.Items.AddActionItem("�������� �������� ����������", StdActions.DoView).Parameters.Add("ReportURL", StdMenuUtils.GetEmployeeReportURL(null, employeeID));
			bool bSep = true;

			// �������������/�������/������� (������ ��� �������)
			if ( "Stuff" == path[1].ObjectType)
			{
				XObjectRights rights;
				rights = XSecurityManager.Instance.GetObjectRights(xobj);
				xobj = dataSet.CreateStubNew(xobj.ObjectType);
				xobj.SetUpdatedPropValue("Folder", folderID);
				if(XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("�������� ���������", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "ProjectParticipant");
					item.Parameters.Add("URLParams", ".Folder=@@FolderID");
					item.Parameters.Add("RefreshFlags", "TRM_PARENTNODE");
					bSep = true;
				}

				if (rights.AllowParticalOrFullChange)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
					item.Title = "������������� ���������";
					item.Parameters.Add("RefreshFlags", "TRM_NONE");
					bSep = true;
				}
				if (rights.AllowDelete)
				{
					if( bSep ) 
						menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("�������", StdActions.DoDelete);
					item.Parameters.Add("RefreshFlags", "TRM_NODE");
					item.Title = "������� ������� ����������";
				}
			}

			// ������ ������� ����� ���� �������
			// ������
			XMenuSection menu_sec = menu.Items.AddSection("������");
			item = menu_sec.Items.AddActionItem("������ ���������� � ������ ������� (�� ����������)", "DoRunReport");
			item.Parameters.Add("ReportName", "ProjectIncidentsAndExpenses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Workers=@@EmployeeID&.WorkerOrganizations=&.WorkerDepartments=");
			item = menu_sec.Items.AddActionItem("������ ���������� � ������ ������� (�� �����������)", "DoRunReport");
			item.Parameters.Add("ReportName", "ProjectParticipantsAndExpenses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID&.Organizations=&.Departments=");
			item = menu_sec.Items.AddActionItem("�������� ������� ������������", "DoRunReport");
			item.Parameters.Add("ReportName", "TimeLosses");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID&.Organizations=&.Departments=");

			/*
			item = menu_sec.Items.AddActionItem("�������� ������ �����������", "DoRunReport");
			item.Parameters.Add("ReportName", "ReportUsersExpences");
			item.Parameters.Add("UrlParams", ".Folder=@@FolderID&.Employees=@@EmployeeID");
			*/

			item = menu_sec.Items.AddActionItem("��������� � �������� ������� ����������", "DoRunReport");
			item.Parameters.Add("ReportName", "ReportEmployeeExpensesList");
			item.Parameters.Add("UrlParams", ".Employee=@@EmployeeID");

			menu_sec.Items.AddSeparatorItem();

			item = menu_sec.Items.AddActionItem("������ �������� ����������", "DoRunReport");
			item.Parameters.Add("ReportName", "EmployeeExpensesBalance");
			item.Parameters.Add("UrlParams", ".Employee=@@EmployeeID");
			item = menu_sec.Items.AddActionItem("��������� ���������� � ��������", "DoRunReport");
			item.Parameters.Add("ReportName", "EmployeesBusynessInProjects");
			item.Parameters.Add("UrlParams", ".Employees=@@EmployeeID&.Departments=&.Organizations=");

			menu_sec = menu.Items.AddSection("����������");
			CompanyTreeMenuDataProvider.fillEmployeeInfoSection(menu_sec, employeeID, con);


			bool bFirst = true;
			//menu_sec = menu.Items.AddSection("��������� ����");
			using(XDbCommand cmd= con.CreateCommand())
			{
				cmd.CommandText = @"SELECT 
	IsNull(r.Name, '<< �� ���������� >>')
FROM 
	dbo.view_FolderParticipantsAndRoles x
	LEFT JOIN dbo.UserRoleInProject r ON r.ObjectID=x.RoleID
WHERE
	x.FolderID=" + con.ArrangeSqlGuid(folderID) + @"
	AND
	x.EmployeeID=" + con.ArrangeSqlGuid(employeeID);
				using(IDataReader r = cmd.ExecuteReader())
				{
					while(r.Read())
					{
						menu_sec.Items.AddInfoItem(bFirst?"��������� ����":null, r.GetString(0));
						bFirst=false;
					}
				}
			}

			return menu;
		}

		#region ���� ��� ����� ���� "�����������"

		internal struct OrgInfo 
		{
			/// <summary>
			/// ������ �������� ������� (�����������)
			/// </summary>
			internal struct OrgDirectorInfo 
			{
				public Guid DirectorID;	// ������������� ����������
				public string FullName;	// ������ ���, � ���� "������� ��� (#������������)"
				public string EMail;	// ����� ����������� ����� (���� ���, �� null)
			}
           	public bool IsOwnerOrg;		// ������� �������� �����������, ��������� ��������
			public string FullName;		// ������ ������������ �����������
			public string ShortName;	// ������� ������������ ����������� (���� ���, �� null)
			public string NavisionCode;	// ������������� ����������� � Navision (���� ���, �� null)
			public OrgDirectorInfo[] DirectorsInfo;	// ������ ���� ���������� �������

			/// <summary>
			/// ��������� ������ �������� �����������
			/// </summary>
			/// <param name="uidOrg">������������� �����������, ������ ������� �����������</param>
			/// <param name="connection">���������� � ��</param>
			/// <returns>������ �����������</returns>
			public static OrgInfo GetOrgInfo( Guid uidOrg, XStorageConnection connection ) 
			{
				OrgInfo info = new OrgInfo();

				XDbCommand cmd = connection.CreateCommand();
				cmd.CommandType = CommandType.Text;
				cmd.CommandText = @"
	/* ������� ������ � ����� ���������� */
	SELECT
        o.Home,
		o.[Name] AS FullName,
		ISNULL(o.ShortName, '') AS [ShortName],
		ISNULL(o.ExternalID, '') AS [NavisionCode]
	FROM dbo.Organization o WITH(NOLOCK)
	WHERE o.ObjectID = @OrgID

	/* ��������(�) ������� - ��������������� ����������� � ���� ����������� */
	SELECT
		emp.ObjectID AS DirectorID,
		emp.LastName + ' ' + emp.FirstName + ISNULL( ' (#' + emp.PhoneExt + ')', '' ) AS FullName,
		ISNULL(emp.EMail, '') AS EMail
	FROM dbo.Organization o WITH(NOLOCK)
			JOIN dbo.Organization oUp WITH(NOLOCK) ON oUp.LIndex <= o.LIndex AND oUp.RIndex >= o.RIndex
			JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID = oUp.Director
	WHERE o.ObjectID = @OrgID
	ORDER BY o.LRLevel DESC ";
				cmd.Parameters.Add( "OrgID", DbType.Guid, ParameterDirection.Input, false, uidOrg );

				using(IXDataReader reader = cmd.ExecuteXReader())
				{
					if (!reader.Read())
						throw new ApplicationException( "������ ��������� ������� ������ ��� ����������� (ID = " + uidOrg.ToString() + ")" );
			
					// ��������! ��� ��������� ������� - ������������������ ������������ ������������ ���������!
					info.IsOwnerOrg = reader.GetBoolean(reader.GetOrdinal("Home"));
					info.FullName = reader.GetString(reader.GetOrdinal("FullName"));
					info.ShortName = reader.GetString(reader.GetOrdinal("ShortName"));
					info.NavisionCode = reader.GetString(reader.GetOrdinal("NavisionCode"));

					if (reader.NextResult())
					{
						ArrayList arrDirectorsInfo = new ArrayList();
						while( reader.Read() )
						{
							OrgDirectorInfo infoDir = new OrgDirectorInfo();
							infoDir.DirectorID = reader.GetGuid(reader.GetOrdinal("DirectorID"));
							infoDir.FullName = reader.GetString(reader.GetOrdinal("FullName"));
							infoDir.EMail = reader.GetString(reader.GetOrdinal("EMail"));
							arrDirectorsInfo.Add(infoDir);
						}
						info.DirectorsInfo = new OrgDirectorInfo[arrDirectorsInfo.Count];
						if (arrDirectorsInfo.Count > 0)
							arrDirectorsInfo.CopyTo(info.DirectorsInfo);
					}
					else
						info.DirectorsInfo = new OrgDirectorInfo[0];
				}

				return info;
			}
		}
		
		/// <summary>
		/// ���������� ���� ��� ����� ���� "�����������" (� �.�. ��������� ����������� 
		/// � �����������, ��������� ��������).
		/// </summary>
		/// <param name="uidOrg">������������� �����������, ��� ������� �������� ����</param>
		/// <param name="path">���� � �������� �� �����������, ��� ������� �������� ����</param>
		/// <param name="dataSet"></param>
		/// <param name="connection"></param>
		/// <returns>��������� �������� ����</returns>
		private XTreeMenuInfo buildMenuForOrganization( Guid uidOrg, XTreePath path, DomainObjectDataSet dataSet, XStorageConnection connection ) 
		{
			// ��������� ������ �� �����������:
			OrgInfo infoOrg = OrgInfo.GetOrgInfo( uidOrg, connection );

			// ����� �� ������ � ������� �����������:
			DomainObjectData xobj = dataSet.GetLoadedStub( "Organization", uidOrg );
			xobj.SetLoadedPropValue( "Home", infoOrg.IsOwnerOrg );
			XObjectRights rightsOnThisOrg = XSecurityManager.Instance.GetObjectRights(xobj);

			xobj = dataSet.CreateStubNew("Organization");
			xobj.SetUpdatedPropValue("Home",false);
			XNewObjectRights rightsOnNewTempOrg = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			XNewObjectRights rightsOnNewConstOrg = XSecurityManager.Instance.GetRightsOnNewObject(xobj);
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_OrganizationMenu_ExecutionHandler")); // ��. s-tree-DKP.vbs

			XMenuActionItem menuItem;
			XMenuSection menuSection;

			#region ������ ��������

			// TODO: ����� �������� ���������!
			// menuItem = menu.Items.AddActionItem("��������", StdActions.DoView);
			// menu.Items.AddSeparatorItem();

			// "�������", ������:
			// ...�������� ����������� �������� �����������
			if (rightsOnNewConstOrg.AllowCreate)
			{
				menuItem = menu.Items.AddActionItem("������� �������� �����������", StdActions.DoCreate);
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("MetanameForCreate", "CommonEditor");
				menuItem.Parameters.Add("RefreshFlags", "TRM_TREE");
			}
			
            /* ����������� ����������� � ������ 8.0 �����������
            
            // ...�������� �������� ����������� ����������� - ������ � ��� ������, ���� 
			// ��������������� ����������� - ���� ����������, � ��� ���� �� ��������
			// ������������-���������� (��������� ������ ���� �� ��������������)
			
            if (!infoOrg.IsOwnerOrg && rightsOnNewConstOrg.AllowCreate)
			{
				xobj.SetUpdatedPropValue("Parent", uidOrg);
				if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
				{
					menuItem = menu.Items.AddActionItem("������� �������� ����������� �����������", StdActions.DoCreate);
					menuItem.Parameters.Add("ObjectType", "Organization");
					menuItem.Parameters.Add("MetanameForCreate", "CommonEditor");
					menuItem.Parameters.Add("URLParams", ".Parent=@@ObjectID");
					menuItem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
				}
			}
            */

			// "�������������" � �������� ��������������:
			if (rightsOnThisOrg.AllowParticalOrFullChange)
			{
				menuItem = menu.Items.AddActionItem("�������������", "DoEdit");
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("MetanameForEdit", "CommonEditor");
				menuItem.Parameters.Add("RefreshFlags", "TRM_NODE");

                /* ����������� ����������� � ������ 8.0 �����������
				// ...�������� ��������� ���������� - ������������ ������ � ��� ������, 
				// ���� ��������������� ����������� - ���������� � ��� ���� �� ��������
				// ������������-���������� ������� (����� ������ ���� �� ��������������):
				if (!infoOrg.IsOwnerOrg)
				{
					menuItem = menu.Items.AddActionItem("�������� ����������� �����������", StdActions.DoMove);
					menuItem.Parameters.Add("RefreshFlags", "TRM_TREE");
					menuItem.Parameters.Add("ParentPropName", "Parent");
					menuItem.Parameters.Add("Metaname", "OrganizationSelector");
					menuItem.Parameters.Add("UrlParams", "selection-mode=anynode");

					// ���� ����������� ����� ��������, �� - "������� ��������"
					if (xobj.GetLoadedPropValue("Parent") is Guid)
					{
						// TODO!
						menu.Items.AddActionItem("������� ��������", "");
					}
				}
                */

			}
			// ...���� ��������������� ����������� - ���������, �� ��� ��� �������� 
			// �������� ������ �� ���������� �������� - ���� � ������������ ���� �����. 
			// ��������� �����:
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			// �������� �� �������� ����������� ����� - �����������:
			// ������ ��� (�) ���������� �����������, (�) ������� �� �������� ���������� �������:
			if (!infoOrg.IsOwnerOrg)
			{
				// �������� �������� ����� ���������, ������ ���� ��� ��� ������������ ���� ���� 
				// "��������" ���� ��������� ������ - ������ ������ ���� ������� ����������:
				Guid activityTypeID = Guid.Empty;
				for( int i=0; i<path.Length; ++i )
					if ( path[i].ObjectType == DKPTreeObjectLocator.TYPE_ActivityTypeExternalUnderHomeOrg )
					{
						activityTypeID = path[i].ObjectID;
						break;
					}

				if (activityTypeID != Guid.Empty)
					addMenuItem_CreateFolderByActivityTypeAndOrganization( connection, menu, dataSet, activityTypeID, uidOrg );
				else
				{
					// �������� �������� ���������� (�����) �� �������� ������ �������� 
					// ������������� � ������� �� ����������� ��� ���� �� ���� ��� ��������� 
					// ������ (����� ������������ ����� ������� ���������� ��� ����� ����):
					bool bAllow = false;
					if (user.ManageOrganization(uidOrg))
						bAllow = true;
					else
						foreach(DomainObject_ActivityType obj_at in user.ActivityTypes.Values)
							if (obj_at.AccountRelated)
							{
								bAllow = true;
								break;
							}

					if (bAllow)
					{
						menu.Items.AddSeparatorItem();
						menuItem = menu.Items.AddActionItem("������� ����������", StdActions.DoCreate);
						menuItem.Parameters.Add("ObjectType", "Folder");
						menuItem.Parameters.Add("MetanameForCreate", "Universal");
						menuItem.Parameters.Add("UrlParams", ".Customer=" + uidOrg.ToString());
						menuItem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
					}
				}
			}

			// "�������"
			if (rightsOnThisOrg.AllowDelete)
			{
				menu.Items.AddSeparatorItem();
				menuItem = menu.Items.AddActionItem("�������", "DoDelete");
				menuItem.Parameters.Add("ObjectType", "Organization");
				menuItem.Parameters.Add("RefreshFlags", "TRM_PARENT");
			}

			#endregion

			#region ������ "������" 
			menuSection = menu.Items.AddSection("������");
			
			// ����� "������� � ������� �����������":
			// ��� �����������-������� � ������ ������� ���������� ����������
			// ������������� �����������; ��� ���� ��� ����������-��������� 
			// ������� ����� ���������� ��������������� ���, ����� � ������� 
			// ���������� ��� ������� ����� "��� �����������". ��. ��� 
			// ��������� ���������� � s-Report-ExpensesByDirections.vbs:
			menuItem = menuSection.Items.AddActionItem("������� � ������� �����������", "DoRunReport");
			menuItem.Parameters.Add( "ReportName", "ExpensesByDirections" );
			menuItem.Parameters.Add( "UrlParams", ".Folder=&.Organization=" + (infoOrg.IsOwnerOrg? "" : uidOrg.ToString()) );
			
			#endregion

			#region ������ "����������"
			menuSection = menu.Items.AddSection("����������");
			if (infoOrg.IsOwnerOrg)
				menuSection.Items.AddInfoItem("", "<B STYLE='color:green;'>����������� - �������� �������</B>" );

			menuSection.Items.AddInfoItem( "������ ������������", infoOrg.FullName );
			menuSection.Items.AddInfoItem( "������� ������������",
				null!=infoOrg.ShortName && String.Empty!=infoOrg.ShortName ? 
				infoOrg.ShortName : "(�� ������)" );
			
			
		    menuSection.Items.AddInfoItem( "���",
			null!=infoOrg.NavisionCode && String.Empty!=infoOrg.NavisionCode ?
			infoOrg.NavisionCode : "(�� ������)" );
		    menuSection.Items.AddSeparatorItem();
            string sDirsInfo = null;
			foreach( OrgInfo.OrgDirectorInfo infoDir in infoOrg.DirectorsInfo )
			sDirsInfo =	(null==sDirsInfo? "" : sDirsInfo + ",<BR/>") + infoDir.FullName;
			menuSection.Items.AddInfoItem( 
			(infoOrg.DirectorsInfo.Length > 1 ? "�������� �������" : "��������� �������"),
			(null==sDirsInfo? "(�� �����)" : sDirsInfo) );
			#endregion

			return menu;
		}
		
		
		#endregion

        #region ���� ��� ����� ���� "�����"

        private XTreeMenuInfo getMenuForFolder(XTreePath path, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XStorageConnection con = context.Connection;
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			Guid folderID = path.PathNodes[0].ObjectID;
			XMenuActionItem item;
			XTreeMenuInfo menu = new XTreeMenuInfo(GetFolderFullName(con, folderID), true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// ��. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			Guid organizationID;
			Guid activityTypeID;
			Guid parentFolderID = Guid.Empty;
			FolderTypeEnum nType;
			
			try
			{
				DomainObjectData xobjFolder = dataSet.Load(con, "Folder", folderID);
				// ������� ���� ��� ����� � ������ (��� not null)
				nType = (FolderTypeEnum)xobjFolder.GetLoadedPropValue("Type");
				organizationID = (Guid)xobjFolder.GetLoadedPropValue("Customer");
				activityTypeID = (Guid)xobjFolder.GetLoadedPropValue("ActivityType");
				if (xobjFolder.GetLoadedPropValue("Parent") != DBNull.Value)
					parentFolderID = (Guid)xobjFolder.GetLoadedPropValue("Parent");

				// "��������"
				item = menu.Items.AddActionItem("��������", StdActions.DoView);
				item.Parameters.Add("ReportURL", "x-get-report.aspx?name=r-Folder.xml&amp;ID=@@ObjectID");

				// �������� ����� ������ ��� �������� ����
				DomainObjectData xobjNew = dataSet.CreateStubNew("Folder");
				xobjNew.SetUpdatedPropValue("Type", nType);
				xobjNew.SetUpdatedPropValue("Customer", organizationID);
				xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
				if (parentFolderID != Guid.Empty)
					xobjNew.SetUpdatedPropValue("Parent", parentFolderID);
				string sNewFolderParamForDefaultIncidentType = null;
				if (xobjFolder.GetLoadedPropValue("DefaultIncidentType") != DBNull.Value)
					sNewFolderParamForDefaultIncidentType = "&.DefaultIncidentType=" + (Guid)xobjFolder.GetLoadedPropValue("DefaultIncidentType");

				if (path.Length > 1)
				{
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
						// ������� ����� ������ �� ����, ��� � ���������, �� ��� �� ������
						item = menu.Items.AddActionItem("������� " + getFolderTypeNameByType(nType, false), StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ParentFolderID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)nType + (sNewFolderParamForDefaultIncidentType!=null ? sNewFolderParamForDefaultIncidentType : String.Empty) );
						item.Parameters.Add("RefreshFlags", "TRM_PARENT+TRM_NODE");
					}
				}

                // ��� �������: ������� ������� ���� ��� ���
                if (nType == FolderTypeEnum.Project)
                {
                    xobjNew = dataSet.CreateStubNew("Contract");
                    xobjNew.SetUpdatedPropValue("Project", folderID);
                    if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                    {
                        using (XDbCommand cmd2 = con.CreateCommand())
                        {
                            cmd2.CommandText = @"SELECT 1 FROM dbo.Contract c WHERE c.Project = " + con.ArrangeSqlGuid(folderID);
                            using (IDataReader reader = cmd2.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    item = menu.Items.AddActionItem("������� �������", StdActions.DoCreate);
                                    item.Parameters.Add("ObjectType", "Contract");
                                    item.Parameters.Add("URLPARAMS", ".Project=@@ObjectID");
                                    item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                                }

                            }
                        }
                    }
                }

				// ��� ��������: ������� ���������� ��������������
				if (nType == FolderTypeEnum.Directory)
				{
					xobjNew = dataSet.CreateStubNew("Folder");
					xobjNew.SetUpdatedPropValue("Parent", folderID);
                    xobjNew.SetUpdatedPropValue("Type", FolderTypeEnum.Directory);
					xobjNew.SetUpdatedPropValue("Customer", organizationID);
					xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
                        item = menu.Items.AddActionItem("������� ����������", StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ObjectID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)nType + (sNewFolderParamForDefaultIncidentType!=null ? sNewFolderParamForDefaultIncidentType : String.Empty));
                        item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
					}
				}

				// ��� ���� ����� ����� ����� �������� - ������� �����
				if (nType != FolderTypeEnum.Directory)
				{
					xobjNew = dataSet.CreateStubNew("Folder");
					xobjNew.SetUpdatedPropValue("Parent", folderID);
					xobjNew.SetUpdatedPropValue("Type", FolderTypeEnum.Directory);
					xobjNew.SetUpdatedPropValue("Customer", organizationID);
					xobjNew.SetUpdatedPropValue("ActivityType", activityTypeID);
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
					{
						item = menu.Items.AddActionItem("������� �������", StdActions.DoCreate);
						item.Parameters.Add("ObjectType", "Folder");
						item.Parameters.Add("URLPARAMS", ".Parent=@@ObjectID&.Customer=@@OrganizationID&.ActivityType=@@ActivityType&.Type=" + (int)FolderTypeEnum.Directory);
						item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
					}
				}

				if (menu.Items.Count > 0)
					menu.Items.AddSeparatorItem();

				// ������� ��������
				xobjNew = dataSet.CreateStubNew("Incident");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
				if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
				{
					item = menu.Items.AddActionItem("������� ��������", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "Incident");
					item.Parameters.Add("URLPARAMS", ".Folder=@@ObjectID");
					item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
				}
				// ������� �������� � ������� ����� �� ������ ����
				addMenuItem_CreateIncidentWithSelectFolder(menu);

				// ������� ����� �� ��������� ����� (������������� � �������)
				XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobjFolder);
				// �������������
				// ��������: ������ �������� ���� �� ��������� ���� �� ������ ��-�� ���� �������� ����� �� ��������� ��-�� Name,
				// ��� ������� ������, ��� ��� ������� ���������� "������� �����" ����� ����� �������� ��� ��������� ��-�� Parent, Customer, ActivityType,
				// ������ �� ��������� �� �������� ������, ������� ������ � ���������� �������� "�������������" � ���� ������ ���
			    if (rights.AllowParticalOrFullChange)
				{
					menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
					item.Default = true;
					item.Parameters.Add("RefreshFlags", "TRM_NODE");
				}
				/* ���������
				if (rights.HasPropChangeRight("Parent"))
				{
					menu.Items.AddActionItem("���������", "DoMoveFolder");
				}*/

				// ������� �����
				xobjNew = dataSet.CreateStubNew("TimeLoss");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
				xobjNew.SetUpdatedPropValue("Worker", user.EmployeeID );
				XNewObjectRights create_rights = XSecurityManager.Instance.GetRightsOnNewObject(xobjNew);
				if (create_rights.AllowCreate)
				{
					item = menu.Items.AddActionItem("������� �����", StdActions.DoCreate);
					item.Parameters.Add("ObjectType", "TimeLoss");
					item.Parameters.Add("UrlParams", ".Folder=" + folderID + "&.Worker=" + user.EmployeeID );
					item.Parameters.Add("RefreshFlags", "TRM_NONE");
					MenuObjectRightsFormatter.Write(item, create_rights);
				}

				// ������� ��������� ��������� �������
				xobjNew = dataSet.CreateStubNew("ProjectParticipant");
				xobjNew.SetUpdatedPropValue("Folder", folderID);
                if (!rights.HasReadOnlyProp("Participants"))
                {
                    if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
                    {
                        item = menu.Items.AddActionItem("�������� ���������", StdActions.DoCreate);
                        item.Parameters.Add("ObjectType", "ProjectParticipant");
                        item.Parameters.Add("UrlParams", ".Folder=" + folderID.ToString());
                        item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                    }
                }
				// ��������� ���������
                if (rights.HasPropChangeRight("Incidents"))
                {
                    if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name) ||
                        ((SecurityProvider)XSecurityManager.Instance.SecurityProvider).FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolder, con)
                        )
                    {
                        menu.Items.AddActionItem("��������� ���������", "DoMoveIncidents");
                    }
				}

				//menu.Items.AddActionItem("���������� ��������� �����", "DoCopyFolderStructure");

				// �������� ������ ��������� �������
				item = menu.Items.AddActionItem("�������� ������ ��������� �������", "DoExecuteVbs");
				item.Parameters.Add("Script", "MailFolderLinkToAll \"" + folderID + "\"");

				// �������� � ������� ������ � Favorites
				menu.Items.AddActionItem("�������� � ��������� ������ �� �����", "DoAddFavorite");
				menu.Items.AddActionItem("���������� � ����� ������ ������ ���� �� �����", "DoCopyFolderPathToClipboard");
				menu.Items.AddActionItem("���������� � ����� ������ ������ �� �����", "DoCopyFolderLinkToClipboard");

				// �������
				if ( rights.AllowDelete )
				{
					menu.Items.AddSeparatorItem();
					item = menu.Items.AddActionItem("�������", StdActions.DoDelete);
					item.Parameters.Add("RefreshFlags", "TRM_PARENTNODE");
           		}

				// ������
				XMenuSection menu_sec = menu.Items.AddSection("������");
				item = menu_sec.Items.AddActionItem("������ ���������� � ������ ������� (�� ����������)", "DoRunReport");
				item.Parameters.Add("ReportName", "ProjectIncidentsAndExpenses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("������ ���������� � ������ ������� (�� �����������)", "DoRunReport");
				item.Parameters.Add("ReportName", "ProjectParticipantsAndExpenses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("�������� ������� ������������", "DoRunReport");
				item.Parameters.Add("ReportName", "TimeLosses");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("������� ��������� ���������� �������", "DoRunReport");
				item.Parameters.Add("ReportName", "FolderIncidentsHistory");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				
				item = menu_sec.Items.AddActionItem("�������� ������ �����������", "DoRunReport");
				item.Parameters.Add("ReportName", "ReportUsersExpences");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);

				// ...����� "������� � ������� �����������" - ������ �����������
				if (nType != FolderTypeEnum.Directory)
				{
					item = menu_sec.Items.AddActionItem("������� � ������� �����������", "DoRunReport");
					item.Parameters.Add("ReportName", "ExpensesByDirections");
					item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);
				}

				item = menu_sec.Items.AddActionItem("������� � ������� �������������", "DoRunReport");
				item.Parameters.Add("ReportName", "CostsByDepartments");
				item.Parameters.Add("UrlParams", ".Folder=" + xobjFolder.ObjectID);

				// ����������
				menu_sec = menu.Items.AddSection("����������");
				// ��� ������� � ��� � Navision - ������ ��� �����������:
				if (nType != FolderTypeEnum.Directory)
				{
					// ��� �������:
					// ��� ������� � Navision:
					if (xobjFolder.GetLoadedPropValue("ExternalID") != DBNull.Value)
						menu_sec.Items.AddInfoItem("���", (string)xobjFolder.GetLoadedPropValue("ExternalID"));
					else
						menu_sec.Items.AddInfoItem("���", "(�� �����)" );
				}
				// ���������
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValue("State");
				menu_sec.Items.AddInfoItem("���������", FolderStatesItem.GetItem(folderState).Description);
				
				// ������� ���������� �������� �� �����
				bool bIsDirectExpensesBlocked = (bool)xobjFolder.GetLoadedPropValue( "IsLocked" );
				menu_sec.Items.AddInfoItem( 
					"�������� �� �����", 
					bIsDirectExpensesBlocked ? 
						"<B STYLE='color:maroon;'>�������������</B>" : 
						"<B STYLE='color:green;'>���������</B>"
					);
				
				// �����������
				XDbCommand cmd = con.CreateCommand( @"
					SELECT d.[Name] AS DirectionName
					FROM dbo.FolderDirection fd WITH(NOLOCK) 
						JOIN dbo.Direction d WITH(NOLOCK) ON d.ObjectID = fd.Direction
					WHERE fd.Folder = @FolderID
					ORDER BY d.IsObsolete, d.[Name]
				" );
				cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						StringBuilder sbDirsList = new StringBuilder();
						sbDirsList.Append("<DIV STYLE='font-weight:normal;'>");
						sbDirsList.AppendFormat( "{0}", reader.GetString( reader.GetOrdinal("DirectionName") ) ); 
						for( ;reader.Read(); )
							sbDirsList.AppendFormat( ";<BR/>{0}", reader.GetString( reader.GetOrdinal("DirectionName") ) ); 
						sbDirsList.Append("</DIV>");

						menu_sec.Items.AddSeparatorItem();
						menu_sec.Items.AddInfoItem( "�����������", sbDirsList.ToString() );
					}
				}
				
				// ��������� ������� - ��� ��������� ������
				// ��������� ��������������� ������
				cmd = con.CreateCommand(@"
					SELECT emp.LastName + ' ' + emp.FirstName AS EmployeeFullName, 
						x.Roles, 
						emp.ObjectID AS EmployeeID, 
						emp.EMail AS EmployeeEMail
					FROM dbo.GetAllFolderParticipants(@FolderID) x 
						JOIN dbo.Employee emp WITH(NOLOCK) ON emp.ObjectID = x.EmployeeID
					ORDER BY emp.LastName
					");
				cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
				string sValue;
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						menu_sec = menu.Items.AddSection("��������� �������");
						do
						{
							Guid employeeID = reader.GetGuid( reader.GetOrdinal("EmployeeID"));
							string sEmployeeFullName = reader.GetString( reader.GetOrdinal("EmployeeFullName"));
							int nIndex = reader.GetOrdinal("EmployeeEMail");
							if (reader.IsDBNull(nIndex))
								sValue = sEmployeeFullName;
							else
							{
								string sEmployeeEmail = reader.GetString(nIndex);
								sValue = createEmployeeHTMLLinkWithContextMenu(employeeID, sEmployeeEmail, sEmployeeFullName, "Folder", folderID, context.Config);
							}
							nIndex = reader.GetOrdinal("Roles");
							string sRoles;
							if (reader.IsDBNull(nIndex))
								sRoles = "-- �� ���������� --";
							else
								sRoles = reader.GetString(nIndex);
							menu_sec.Items.AddInfoItem(sRoles, sValue);
						} 
						while (reader.Read());
					}
				}
			}
			catch(XObjectNotFoundException)
			{
				// ������ �� ������ � ��
				menu.Items.AddInfoItem("", "������ ������ �� ��");
			}
						
			return menu;
		}

        private string getFolderTypeNameByType(FolderTypeEnum nType, bool bSub)
		{
			return getFolderTypeNameByType(nType, bSub, CASES.Nominative);
		}

		private string getFolderTypeNameByType(FolderTypeEnum nType, bool bSub, CASES nCase)
		{
			string sName;
			switch(nType)
			{
				case FolderTypeEnum.Directory:
					sName = bSub ? "����������" : "�������";
					break;
				case FolderTypeEnum.Presale:
					sName = "�������";
					break;
				case FolderTypeEnum.Project:
					sName = bSub ? "���������" : "������";
					break;
				case FolderTypeEnum.Tender:
					sName = "������";
					break;
				default:
					throw new ArgumentException();
			}
			if (nCase == CASES.Prepositional)
				sName = sName + "�";	// �������, �������, ��������
			else if (nCase == CASES.Genitive)
				sName = sName + "�";	// �������, �������, ��������
			return sName;
		}

        #endregion

        private XTreeMenuInfo getMenuForActivityType(XTreePath path, DomainObjectDataSet dataSet, XStorageConnection con)
		{
			Guid organizationID = Guid.Empty;
			Guid activityTypeID = path[0].ObjectID;

			XTreeMenuInfo menu = new XTreeMenuInfo("��� ��������� ������ \"@@Title\"", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;

			// ������ ������������� �����������, �� ������ ���� �� ����
			for(int i=0;i<path.Length;++i)
				if (path[i].ObjectType == "Organization" || path[i].ObjectType == "HomeOrganization")
				{
					organizationID = path[i].ObjectID;
					break;
				}
			Debug.Assert(organizationID != Guid.Empty);
			if (organizationID == Guid.Empty)
				throw new ApplicationException("�� ������� ����� ����������� �����������");

			// ���� ������� ��� ��������� ������ - ��� ��� ��������� ������ � ��������� ������� (� ������������� �� ���������� ��� ������������-����������),
			// �� ������������ ������ �� �����������-������� ��� �������� ����� �� ����, �.�. �� ��� �� �������� (����� ������ � �������)
			if (path[0].ObjectType == DKPTreeObjectLocator.TYPE_ActivityTypeExternalUnderHomeOrg)
			{
				organizationID = Guid.Empty;
			}

			if (!addMenuItem_CreateFolderByActivityTypeAndOrganization(con, menu, dataSet, activityTypeID, organizationID))
				return menu;

			// ������� �������� � ������� ����� �� ������ ����
			addMenuItem_CreateIncidentWithSelectFolder(menu);

			// �������� ������ � �������� �����������, ���������� ������� �� ������� ��� ��������� ������
			XMenuSection menu_sec = new XMenuSection("Info", "���������");
			XDbCommand cmd = con.CreateCommand(@"
				SELECT emp.LastName + ' ' + emp.FirstName 
				FROM SystemUser_ActivityTypes su_at
					JOIN Employee emp ON emp.SystemUser = su_at.ObjectID
				WHERE su_at.Value = @ObjectID"
				);
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, activityTypeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while (reader.Read())
				{
					menu_sec.Items.AddInfoItem("", reader.GetString(0));
				}
				if (menu_sec.Items.Count > 0)
					menu.Items.Add(menu_sec);
			}
			return menu;
		}

		/// <summary>
		/// ������� ����� ���� "������� ���", ��� ��� - ������������ ���� �����, ��������������� �������� ����� ��������� ������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="menu"></param>
		/// <param name="dataSet"></param>
		/// <param name="activityTypeID"></param>
		/// <param name="organizationID"></param>
		/// <returns></returns>
		private bool addMenuItem_CreateFolderByActivityTypeAndOrganization(XStorageConnection con, XTreeMenuInfo menu, DomainObjectDataSet dataSet, Guid activityTypeID, Guid organizationID)
		{
			FolderTypeEnum nType;
			DomainObjectData xobj;
			XMenuActionItem menuitem;
			// �������� �� �� ���������� ���� ����� ��� ���������� ���� ����������
			XDbCommand cmd = con.CreateCommand("SELECT FolderType FROM " + con.GetTableQName("ActivityType") + " WHERE ObjectID = @ObjectID");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, activityTypeID);

			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					nType = (FolderTypeEnum)reader.GetInt16( reader.GetOrdinal("FolderType") );
					// "��������" "�������"
					nType = nType & (~FolderTypeEnum.Directory);
					xobj = dataSet.CreateStubNew("Folder");
					if (organizationID != Guid.Empty)
						xobj.SetUpdatedPropValue("Customer", organizationID);
					xobj.SetUpdatedPropValue("ActivityType", activityTypeID);
					foreach(FolderTypeEnumItem item in FolderTypeEnumItem.GetItems(nType))
					{
						xobj.SetUpdatedPropValue("Type", item.IntValue);
						if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
						{
							menuitem = menu.Items.AddActionItem("������� " + getFolderTypeNameByType(item.Value, false), StdActions.DoCreate);
							menuitem.Parameters.Add("ObjectType", "Folder");
							string sUrlParams = String.Empty;
							if (organizationID != Guid.Empty)
								sUrlParams = ".Customer=" + organizationID.ToString();
							sUrlParams = sUrlParams + "&.ActivityType=" + activityTypeID + "&.Type=" + item.IntValue;
							menuitem.Parameters.Add("UrlParams", sUrlParams);
							menuitem.Parameters.Add("RefreshFlags", "TRM_CHILDS");
						}
					}
					return true;
				}
				else
				{
					menu.Items.AddInfoItem(String.Empty, "��������� ������ ��� ������");
					return false;
				}
			}
		}

		private XTreeMenuInfo getMenuForIncident(Guid ObjectID, DomainObjectDataSet dataSet, IXExecutionContext context)
		{
			XStorageConnection con = context.Connection;
			XMenuActionItem menuitem;
			DomainObjectData xobj;
			Guid FolderID;
			DomainObjectData xobjIncident;
			string sIncidentStateName;
			string sIncidentTypeName;
			string sIncidentInitiatorFIO;
			Guid initiatorID;
			string sInitiatorEMail;
			DateTime dtLastActivityDate;

			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			// ��. s-tree-DKP.vbs
			menu.ExecutionHandlers.Add( new XUserCodeWeb("DKP_FolderMenu_ExecutionHandler"));
			XDbCommand cmd = con.CreateCommand(@"
				SELECT i.Number, i.Name, i.Folder AS FolderID, 
					i.InputDate,
					i.Priority,
					i.DeadLine,
					i.State As IncidentStateID,
					st.Name AS StateName,
					it.Name AS TypeName,
					emp.ObjectID AS EmployeeID,
					emp.EMail AS UserEMail,
					emp.LastName + ' ' + emp.FirstName AS UserName,
					f.Type AS FolderType,
					(
						SELECT MAX(tmp.d)
						FROM 
							(
								SELECT /*���� ��������� ���������*/
									i2.InputDate d
								FROM dbo.Incident i2 WITH (NOLOCK) 
								WHERE i2.ObjectID = i.ObjectID 
								UNION 
								SELECT /*���� ���������� �������� ������� �� �������� ���������*/
									IsNull(Max(ts2.RegDate), 0) d
								FROM dbo.TimeSpent ts2 WITH (NOLOCK) 
									JOIN dbo.Task t2 WITH (NOLOCK) ON ts2.Task = t2.ObjectID
								WHERE t2.Incident = i.ObjectID 
								UNION 
								SELECT /*���� ���������� ��������� ��������� ���������*/
									IsNull(Max(h2.ChangeDate), 0) d  
								FROM dbo.IncidentStateHistory h2 WITH (NOLOCK) 
								WHERE h2.Incident = i.ObjectID 
							) tmp
					) AS LastActivityDate
				FROM Incident i WITH (NOLOCK)
					JOIN IncidentState st WITH (NOLOCK) ON i.State = st.ObjectID
					JOIN IncidentType it WITH (NOLOCK) ON i.Type = it.ObjectID
					JOIN SystemUser su WITH (NOLOCK) ON i.Initiator = su.ObjectID
						LEFT JOIN Employee emp WITH (NOLOCK) ON emp.SystemUser = su.ObjectID
					JOIN Folder f WITH (NOLOCK) ON i.Folder=f.ObjectID 
				WHERE i.ObjectID = @ObjectID"
				);
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, ObjectID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					FolderID = reader.GetGuid( reader.GetOrdinal("FolderID") );
					FolderTypeEnum nFolderType = (FolderTypeEnum)reader.GetInt16( reader.GetOrdinal("FolderType") );
					sIncidentStateName = reader.GetString(reader.GetOrdinal("StateName"));
					sIncidentTypeName = reader.GetString(reader.GetOrdinal("TypeName"));
					sIncidentInitiatorFIO = reader.GetString(reader.GetOrdinal("UserName"));
					dtLastActivityDate = reader.GetDateTime(reader.GetOrdinal("LastActivityDate"));
					initiatorID = reader.GetGuid( reader.GetOrdinal("EmployeeID") );
					sInitiatorEMail = String.Empty;
					if (!reader.IsDBNull(reader.GetOrdinal("UserEMail")))
						sInitiatorEMail = reader.GetString(reader.GetOrdinal("UserEMail"));
					// �������� ���������
					menuitem = menu.Items.AddActionItem("��������", StdActions.DoView);
					menuitem.Parameters.Add("ReportURL", "x-get-report.aspx?name=r-Incident.xml&amp;DontCacheXslfo=true&amp;IncidentID=@@ObjectID");

					xobj = dataSet.CreateStubNew("Incident");
					xobj.SetUpdatedPropValue("Folder", FolderID);
					// ������� �������� (� ��� �� �����)
					if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
					{
						menuitem = menu.Items.AddActionItem("������� �������� � ������� " + getFolderTypeNameByType(nFolderType,false,CASES.Prepositional), StdActions.DoCreate);
						menuitem.Parameters.Add("ObjectType", "Incident");
						menuitem.Parameters.Add("URLPARAMS", ".Folder=@@FolderID");
						menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");						
					}

					// ������� �������� � ������� ����� �� ������ ����
					addMenuItem_CreateIncidentWithSelectFolder(menu);

					xobjIncident = dataSet.GetLoadedStub("Incident", ObjectID);
					xobjIncident.SetLoadedPropValue("Folder", FolderID);
					xobjIncident.SetLoadedPropValue("Name", reader.GetString( reader.GetOrdinal("Name")));
					xobjIncident.SetLoadedPropValue("Number", reader.GetInt32( reader.GetOrdinal("Number")));
					xobjIncident.SetLoadedPropValue("InputDate", reader.GetDateTime(reader.GetOrdinal("InputDate")));
					xobjIncident.SetLoadedPropValue("Priority", reader.GetInt16(reader.GetOrdinal("Priority")));
					xobjIncident.SetLoadedPropValue("State", reader.GetGuid(reader.GetOrdinal("IncidentStateID")));
					int i = reader.GetOrdinal("DeadLine");
					if (!reader.IsDBNull(i))
						xobjIncident.SetLoadedPropValue("DeadLine", reader.GetDateTime(i));
					XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobjIncident);

					// �������������
					// ����������: ��������, ��� ���� ����� �� ������� ���������, �� ��� ���� �� ��������������, 
					//		������� ���� �������� ����� �� �������� "������������"
					if ( rights.HasPropChangeRight("Name"))
					{
						menuitem = menu.Items.AddActionItem("�������������", StdActions.DoEdit);
						menuitem.Parameters.Add("RefreshFlags", "TRM_NODE+TRM_CHILDS");
						menuitem.Default = true;
					}
					// �������
					if ( rights.AllowDelete )
					{
						menuitem = menu.Items.AddActionItem("�������", StdActions.DoDelete);
						menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");
					}

					// �����������
					if (rights.HasPropChangeRight("Folder"))
					{
						menu.Items.AddActionItem("���������", "DoMoveIncident");
					}
					
					// �������� � ������� ������
					menu.Items.AddActionItem("���������� � ����� ������ ������ �� ��������", "DoCopyIncidentLinkToClipboard");
					menu.Items.AddActionItem("���������� � ����� ������ ������ �� ����� ���������", "DoCopyIncidentViewLinkToClipboard");

					// �������� ���
					/* TODO: ����������������� ����� ����� ������ �������� ��������� ����.
					if (rights.HasPropChangeRight("Type"))
					{
						menuitem = menu.Items.AddActionItem("�������� ���", StdActions.DoEdit);
						menuitem.Parameters.Add("MetanameForEdit", "ChangeType");
					}
					*/
				}
				else
				{
					menu.Items.AddInfoItem("��������� ������ ��� ������", String.Empty);
					return menu;
				}
			}
			// ������ "�������"
			addTaskList(con, ObjectID, menu, context, dataSet);
			// ������ "����������":
			// ���������, ���� �����������, ���������������, ��� ���������, ���������, ���� ��������� ����������
			XMenuSection sec = menu.Items.AddSection("����������");
			sec.Items.AddInfoItem("���������", sIncidentStateName);
			sec.Items.AddInfoItem("���� �����������", ((DateTime)xobjIncident.GetLoadedPropValue("InputDate")).ToString("dd.MM.yyyy HH:mm") );
			sec.Items.AddInfoItem("���������������", 
				createEmployeeHTMLLinkWithContextMenu(initiatorID, sInitiatorEMail, sIncidentInitiatorFIO, "Incident", ObjectID, context.Config)
				);
			sec.Items.AddInfoItem("��� ���������", sIncidentTypeName);
			sec.Items.AddInfoItem("���������", IncidentPriorityItem.GetItem((IncidentPriority)xobjIncident.GetLoadedPropValue("Priority")).Description );
			if (xobjIncident.HasLoadedProp("DeadLine"))
				sec.Items.AddInfoItem("������� ����", xobjIncident.GetLoadedPropValue("DeadLine").ToString());
			sec.Items.AddInfoItem("���� ��������� ����������", dtLastActivityDate.ToString("dd.MM.yyyy HH:mm"));

			addLinkedIncidents(con, ObjectID, menu);
			return menu;
		}

        /// <summary>
        /// ��� ����������� ����� "�������", "������", "�������" � "�������"
        /// </summary>
        /// <param name="path"></param>
        /// <param name="dataSet"></param>
        /// <returns></returns>
        private XTreeMenuInfo getMenuForContractsVirtualNode(XTreePath path, DomainObjectDataSet dataSet)
        {
            string sObjectType = path[0].ObjectType;
            XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
            menu.CacheMode = XTreeMenuCacheMode.NoCache;
            if (sObjectType == "Contracts")
                menu.Caption = "�������";
            if (sObjectType == "OutLimits")
                menu.Caption = "������ �� �������� ��";
            if (sObjectType == "Incomes")
                menu.Caption = "������� ��";
            if (sObjectType == "Outcomes")
                menu.Caption = "������� ��";
            return menu;
        }

		/// <summary>
		/// ���������� ���� ��� ����������� ����� "�������", "��������� �������", "��� ���������" � �������� "���� ������������ � �����" (ProjectParticipant)
		/// </summary>
		/// <param name="path"></param>
		/// <param name="dataSet"></param>
		/// <returns></returns>
		private XTreeMenuInfo getMenuForTeamAndRoleNode(XTreePath path, DomainObjectDataSet dataSet)
		{
			string sObjectType = path[0].ObjectType;
			XTreeMenuInfo menu = new XTreeMenuInfo("@@Title", true);
			menu.CacheMode = XTreeMenuCacheMode.NoCache;
			if (sObjectType == "UserRoleInProject")
				menu.Caption = "��������� ���� @@Title";
  
            XMenuActionItem item;
            Guid folderID = Guid.Empty;
            // ������ ������������� ����� - ������� ������ ����������� ����� ����� �� ���� (��� ������ ����!)
            for (int i = 0; i < path.Length; ++i)
                if (path[i].ObjectType == "Folder")
                {
                    folderID = path[i].ObjectID;
                    break;
                }
            if (folderID == Guid.Empty)
                throw new ApplicationException("�� ������� ����� ������������� ����� � ����: " + path.ToString());
            DomainObjectData xobjNew = dataSet.CreateStubNew("ProjectParticipant");
            xobjNew.SetUpdatedPropValue("Folder", folderID);
            if (XSecurityManager.Instance.GetRightsOnNewObject(xobjNew).AllowCreate)
            {
                item = menu.Items.AddActionItem("�������� ���������", StdActions.DoCreate);
                item.Parameters.Add("ObjectType", "ProjectParticipant");
                item.Parameters.Add("RefreshFlags", "TRM_CHILDS+TRM_NODE");
                if (sObjectType == "UserRoleInProject")
                {
                    item.Title = "�������� ��������� � ������ ����";
                    item.Parameters.Add("URLPARAMS", ".Folder=" + folderID.ToString() + "&.Roles=@@ObjectID");
                }
                else	// if (sObjectType == "Stuff")
                {
                    item.Parameters.Add("URLPARAMS", ".Folder=" + folderID.ToString());
                }
            }
            
            return menu;
		}

		/// <summary>
		/// ��������� ������ ������� � ���� �� ������� ������������ ��������� (����, ���, ���������� ������������ � ����������� �������),
		/// � �����, ���� ����� ������� ���� ������� �������� ������������, �� � ���� ����������� ����� "������� �����"
		/// </summary>
		/// <param name="con">���������� � ��</param>
		/// <param name="ObjectID">������������� ���������</param>
		/// <param name="menu">������� ���� ���� ���������</param>
		/// <param name="context">�������� �������</param>
		private void addTaskList(XStorageConnection con, Guid ObjectID, XMenu menu, IXExecutionContext context, DomainObjectDataSet dataSet)
		{
			XDbCommand cmd;
			cmd = con.CreateCommand(@"
				SELECT t.ObjectID AS TaskID,
					SUM(IsNull(ts.Spent,0)) AS SpentTime, 
					ur.Name AS RoleName, 
					worker_emp.ObjectID AS EmployeeID,
					worker_emp.LastName + ISNULL(' ' + worker_emp.FirstName, '') AS UserFullName, 
					worker_emp.PhoneExt AS UserPhone,
					worker_emp.EMail AS UserEMail,
					dep.Name As DepName,
					t.LeftTime
				FROM Task t WITH (NOLOCK)
					JOIN UserRoleInIncident ur WITH (NOLOCK) ON t.Role = ur.ObjectID
					JOIN Employee worker_emp WITH (NOLOCK) ON t.Worker = worker_emp.ObjectID
						LEFT JOIN Department dep WITH (NOLOCK) ON dep.ObjectID = worker_emp.Department
					LEFT JOIN TimeSpent ts WITH (NOLOCK) ON ts.Task = t.ObjectID
				WHERE t.Incident = @IncidentID
				GROUP BY t.ObjectID, ur.Name, worker_emp.ObjectID, worker_emp.LastName, worker_emp.FirstName, worker_emp.PhoneExt, worker_emp.EMail, dep.Name, t.LeftTime
				ORDER BY UserFullName"
				);
			cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, ObjectID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				
				XMenuSection sec = new XMenuSection("TaskList", "�������");
				string sValue;
				int nIndex;
				string sUserEMail;
				Guid EmployeeID;
				XMenuActionItem item;
				while (reader.Read())
				{
					// �����: {����} : {���} ({�������})
					EmployeeID = reader.GetGuid( reader.GetOrdinal("EmployeeID") );
					sValue = reader.GetString(reader.GetOrdinal("UserFullName"));
					nIndex = reader.GetOrdinal("UserPhone");
					if (!reader.IsDBNull(nIndex))
						sValue = sValue + " (" + reader.GetString(nIndex) + ")";
					sUserEMail = null;
					nIndex = reader.GetOrdinal("UserEMail");
					if (!reader.IsDBNull(nIndex))
						sUserEMail = reader.GetString(nIndex);
					sec.Items.AddInfoItem(
						reader.GetString(reader.GetOrdinal("RoleName")), 
						"<span style='font-size:10pt;color:black;'>" + 
						createEmployeeHTMLLinkWithContextMenu(EmployeeID, sUserEMail, sValue, "Incident", ObjectID, context.Config) +
						"</span>"
						);

					// �����: ��������/���������
					int nLeftTime = reader.GetInt32(reader.GetOrdinal("LeftTime"));
					int nSpentTime = reader.GetInt32(reader.GetOrdinal("SpentTime"));
					int nWorkdayDuration = ((ITUser)XSecurityManager.Instance.GetCurrentUser()).WorkdayDuration;
					sec.Items.AddInfoItem(String.Empty, 
						"<span style='font-size:8pt;color:navy;font-weight:normal;'>" +
							Utils.FormatTimeDuration(nLeftTime, nWorkdayDuration) + " / " + 
						Utils.FormatTimeDuration(nSpentTime, nWorkdayDuration) +
						"</span>"
						);

					// ���� ������� ������� - ��� ������� �������� ����������, �� � ���� (�� � ������ �������), ������� ����� "��������� �����"
					ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
					if (EmployeeID == user.EmployeeID)
					{
						Guid taskID = reader.GetGuid(reader.GetOrdinal("TaskID"));
						DomainObjectData xobj = dataSet.CreateStubNew("TimeSpent");
						xobj.SetUpdatedPropValue("Task", taskID);
						// ��������� �����
						if (XSecurityManager.Instance.GetRightsOnNewObject(xobj).AllowCreate)
						{
							item = menu.Items.AddActionItem("��������� �����", StdActions.DoCreate);
							item.Parameters.Add("ObjectType", "TimeSpent");
							item.Parameters.Add("URLParams", ".Task=" + taskID + "&.RegDate=" + XmlConverter.GetXmlTypedValue(DateTime.Now, "dateTime.tz"));
							item.Parameters.Add("RefreshFlags", "TRM_NODE");
						}
					}
				}
				if (sec.Items.Count > 0)
				{
					// ���� ���� ������ ������������, �� ������ ����� � �������� ���� "�������� ���� ����������"
					item = menu.Items.AddActionItem("�������� ���� ���������� ���������", "DoExecuteVbs");
					item.Parameters.Add("Script", "MailIncidentLinkToAll \"" + ObjectID + "\"");

					menu.Items.Add(sec);
				}
			}
		}

		
		#region ������ ���������� �����/������� ������� ����

		/// <summary>
		/// ��������� ����� "������� �������� � ������� �����"
		/// ����� �� ����������� �������� �� �����������
		/// </summary>
		/// <param name="menu">����</param>
		/// <returns>��������� �����</returns>
		private XMenuActionItem addMenuItem_CreateIncidentWithSelectFolder(XMenu menu)
		{
			// �.�. �� �� �����, ��� ����� ����������� ��������, �� �������� �������� ������
			XMenuActionItem menuitem;
			menuitem = menu.Items.AddActionItem("������� �������� � ������� �����", StdActions.DoCreate);
			menuitem.Parameters.Add("ObjectType", "Incident");
			menuitem.Parameters.Add("MetanameForCreate", "WizardWithSelectFolder");
			menuitem.Parameters.Add("RefreshFlags", "TRM_PARENT");
			return menuitem;
		}

		
		/// <summary>
		/// ������� HTML ��� ��� ������� � �������� �������� ��������������� ������ ����.
		/// ������� ������ (<A>) � ����������� ���� �� �������� "�������� ������" � "��������"
		/// </summary>
		/// <param name="EmployeeID">������������� ����������</param>
		/// <param name="sUserEMail">e-mail ���������� (����� ���� null)</param>
		/// <param name="sTitle">����� ������ (not null)</param>
		/// <param name="sRelatedType">������������ ���� ���������� �������: Folder ��� Incident</param>
		/// <param name="relatedObjectID">������������� ���������� �������</param>
		/// <param name="config">������������</param>
		/// <returns>HTML-���</returns>
		private string createEmployeeHTMLLinkWithContextMenu(Guid EmployeeID, string sUserEMail, string sTitle, string sRelatedType, Guid relatedObjectID, XConfig config)
		{
			if (sRelatedType != "Incident" && sRelatedType != "Folder")
				throw new ArgumentException("���������������� �������� ��������� sRelatedType: " + sRelatedType);

			string sMenuXml = String.Format(
				"<i:menu trustworthy='1' xmlns:i='http://www.croc.ru/Schemas/XmlFramework/Interface/1.0'>" +
				"<i:visibility-handler>EmployeeContextMenu_VisibilityHandler</i:visibility-handler>" +
				"<i:execution-handler>EmployeeContextMenu_ExecutionHandler</i:execution-handler>" +
				"<i:menu-item action='DoMailAbout{0}' t='�������� ������' separator-after='1'>" +
				"	<i:params>" + 
				"		<i:param n='EmployeeID'>" + EmployeeID + "</i:param>" +
				"		<i:param n='{0}ID'>{1}</i:param>" +
				"	</i:params>" +
				"</i:menu-item>", 
				sRelatedType, 
				relatedObjectID);

			string sReportURL = StdMenuUtils.GetEmployeeReportURL(config, EmployeeID);
			if (sReportURL != null)
			{
				sMenuXml = sMenuXml +
					"<i:menu-item action='DoView' t='��������'>" +
					"	<i:params><i:param n='ReportURL'>" + sReportURL + "</i:param></i:params>" +
					"</i:menu-item>";
			}

			// ������
			sMenuXml = sMenuXml +
				"<i:menu-item action='DoRunReport' t='��������� � �������� ������� ����������' separator-before='1'>" +
				"	<i:params>" +
				"		<i:param n='ReportName'>ReportEmployeeExpensesList</i:param>" +
				"		<i:param n='UrlParams'>.Employee=" + EmployeeID + "</i:param>" + 
				"	</i:params>" +
				"</i:menu-item>" +
				"<i:menu-item action='DoRunReport' t='������ �������� ����������'>" +
				"	<i:params>" +
				"		<i:param n='ReportName'>EmployeeExpensesBalance</i:param>" +
				"		<i:param n='UrlParams'>.Employee=" + EmployeeID + "</i:param>" + 
				"	</i:params>" +
				"</i:menu-item>";

			sMenuXml = sMenuXml +
				"</i:menu>";

			// ���������� ������������� �������� TEXTAREA c ����������� ������������ ����, ������������ �� ������ � ������ ����������
			string sMenuMDDivID = "oMenuMD" + Guid.NewGuid().ToString().Replace("-","");
			StringBuilder htmlBuilder = new StringBuilder(32);
			htmlBuilder.Append("<A CLASS='menu-mail-to' HREF='' TITLE='����� ������� - �������� ������, ������ - ����������� ����' onContextMenu=\"ShowContextMenuForEmployee '");
			htmlBuilder.Append(EmployeeID);
			htmlBuilder.Append("', ");
			htmlBuilder.Append(sMenuMDDivID);
			htmlBuilder.Append("\" language='VBScript' ");
			if (sRelatedType == "Incident")
			{
				htmlBuilder.Append(" onClick=\"MailIncidentLinkToUser '");
			}
			else
			{
				htmlBuilder.Append(" onClick=\"MailFolderLinkToUser '");
			}
			htmlBuilder.Append(relatedObjectID);
			htmlBuilder.Append("', '");
			htmlBuilder.Append(EmployeeID);
			htmlBuilder.Append("', Null\" ");
			if (sUserEMail != null)
			{
				htmlBuilder.Append(" onmouseover=\"CrocUserOver '");
				htmlBuilder.Append(sUserEMail.ToLower());
				htmlBuilder.Append("', 5\" onmouseout='CrocUserOut'");
			}
			htmlBuilder.Append(">");
			htmlBuilder.Append(sTitle);
			htmlBuilder.Append("</A><TEXTAREA style='display:none;' id='");
			htmlBuilder.Append(sMenuMDDivID);
			htmlBuilder.Append("'>");
			htmlBuilder.Append(HttpUtility.HtmlEncode( "<?xml version=\"1.0\" encoding=\"windows-1251\"?>" + sMenuXml ));
			htmlBuilder.Append("</TEXTAREA>");
			return htmlBuilder.ToString();
		}

		#endregion

		public override XTreeMenuInfo GetMenuForEmptyTree(XGetTreeMenuRequest request, IXExecutionContext context, XTreePageInfoStd treePage)
		{
			XTreeMenuInfo menu = new XTreeMenuInfo(String.Empty);
			menu.Items.AddActionItem("������� �����������", "DoCreate").Parameters.Add("ObjectType", "Organization");
			return menu;
		}

		/// <summary>
		/// ��������� ������ "��������� ���������" � ���� ���������
		/// </summary>
		/// <param name="con">���������� � ��</param>
		/// <param name="incidentID">������������� ���������</param>
		/// <param name="menu">����</param>
		private void addLinkedIncidents(XStorageConnection con, Guid incidentID, XTreeMenuInfo menu)
		{
			XDbCommand cmd = con.CreateCommand(@"
				SELECT i.ObjectID, i.Number, i.Name, i_s.Name AS StateName, i_t.Name AS TypeName
				FROM IncidentLink il WITH(NOLOCK)
					JOIN Incident i WITH(NOLOCK) ON il.RoleB = i.ObjectID
						JOIN IncidentState i_s WITH(NOLOCK) ON i.State = i_s.ObjectID
						JOIN IncidentType i_t  WITH(NOLOCK) ON i.Type = i_t.ObjectID
				WHERE il.RoleA = @ObjectID 
				UNION
				SELECT i.ObjectID, i.Number, i.Name, i_s.Name, i_t.Name
				FROM IncidentLink il WITH(NOLOCK)
					JOIN Incident i WITH(NOLOCK) ON il.RoleA = i.ObjectID
						JOIN IncidentState i_s WITH(NOLOCK) ON i.State = i_s.ObjectID
						JOIN IncidentType i_t  WITH(NOLOCK) ON i.Type = i_t.ObjectID
				WHERE il.RoleB = @ObjectID 
				");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, incidentID);
			XMenuSection menu_sec = new XMenuSection("", "��������� ���������");
			DKPTreeObjectLocator locator = new DKPTreeObjectLocator();
			ArrayList aLinkedIncidenObjectIDs = new ArrayList();
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while(reader.Read())
				{
					// [{TypeName}][{StateName}]{Number} - {Name}
					StringBuilder bld = new StringBuilder(10);
					bld.Append("[");
					bld.Append(reader.GetString(reader.GetOrdinal("TypeName")));
					bld.Append("] [");
					bld.Append(reader.GetString(reader.GetOrdinal("StateName")));
					bld.Append("] �");
					bld.Append(reader.GetInt32(reader.GetOrdinal("Number")));
					bld.Append(" - ");
					bld.Append(reader.GetString(reader.GetOrdinal("Name")));
					aLinkedIncidenObjectIDs.Add(reader.GetGuid(reader.GetOrdinal("ObjectID")));
					
					menu_sec.Items.AddActionItem(bld.ToString(), "DoNavigate");
				}
			}
			if (menu_sec.Items.Count > 0)
			{
				for(int i = 0; i< menu_sec.Items.Count; ++i)
                    ((XMenuActionItem)menu_sec.Items[i]).Parameters.Add("Path", locator.GetIncidentFullPath(con, (Guid)aLinkedIncidenObjectIDs[i]).ToString());
				menu.Items.Add(menu_sec);
			}
		}
        /// <summary>
        /// ������� ���������� ������ ���� �� �����
        /// </summary>
        /// <param name="con">������� ���������� </param>
        /// <param name="folderID"></param>
        /// <returns></returns>
        private string GetFolderFullName(XStorageConnection con, Guid folderID)
        {
            // �������� �������, ���������� ������ ���� � �����
            XDbCommand cmd = con.CreateCommand("SELECT dbo.GetFullFolderName( @uidFolderID,0)");
            // ��������� ������������� ����� 
            cmd.Parameters.Add("uidFolderID", DbType.Guid, ParameterDirection.Input, false, folderID);
            return cmd.ExecuteScalar().ToString();
        }
	}
}
