//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Data;
using System.Diagnostics;
using System.Security.Principal;
using System.Threading;
using System.Web.Services;
using System.Xml;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ������ ������������� ������ ������������, �������������� � ������������� 
	/// ������� ������� ����������� ���������� ���������� (���)
	/// </summary>
	[WebService(
		 Name="NSISyncService",
		 Namespace="http://www.croc.ru/Namespaces/IncientTracker/WebServices/NSISync/1.0",
		 Description=
			"������� ������������ ���������� ��������� Incident Tracker : " +
			"C����� ������������� ������ ������������, �������������� " +
			"� ������������� ������� ������� ����������� ���������� ���������� (���)" )
	]
	public class NSISyncService : WebService 
	{
		#region ����� ���������, ������������, �����

		/// <summary>
		/// ����������� ����� ��������� �� ������
		/// </summary>
		private const string DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE = "��� ��������� ������������� ������ �� ����������� ������������� �� ����� ���� �������� ��������� �������";
		/// <summary>
		/// ����������� ����������� ������, ���������� ��� ������������� � ���:
		/// </summary>
		[Flags]
		private enum NsiConst_UserFlags 
		{
			/// <summary>
			/// ������� ���������������� ���������� � �������
			/// </summary>
			Administrator = 1,
			/// <summary>
			/// ������������ � ������ ������ �� �������� (� �������)
			/// </summary>
			ArchiveUser = 2,
			/// <summary>
			/// �������� ������� (��� ��������) - ���� ���
			/// </summary>
			TmsTenderManager = 4,
			/// <summary>
			/// ����������� �� ������������ (��� ��������) - ���� ���
			/// </summary>
			TmsTenderResponsible = 16,
			/// <summary>
			/// ����������� �� �������� (��� ��������) - ���� ���
			/// </summary>
			TmsInquiryResponsible = 32,
			/// <summary>
			/// �������� ������� (��� ��������) - ���� ���
			/// </summary>
			TmsDecidingMan= 64,
			/// <summary>
			/// �����. ������������ (���������) - ���� ���
			/// </summary>
			TmsAdministrator = 128,
			/// <summary>
			/// �������� accounta (��� ��������) - ���� ���
			/// </summary>
			TmsDirector = 256,
			/// <summary>
			/// ����� ������ � ������� �������� - ���� ���
			/// </summary>
			TmsUser = 512,
			/// <summary>
			/// ������� ������������
			/// </summary>
			ExternalUser = 1024,
			/// <summary>
			/// �������� ��������� ���������
			/// </summary>
			ReceiveSysMessages = 2048,
			/// <summary>
			/// �� �������� ������� ���������
			/// </summary>
			DoNotReceiveMessages = 4096,
			/// <summary>
			/// ���������������� ����� �� ��� �������
			/// </summary>
			ProjectAdministration = 8192,
			/// <summary>
			/// �� ������������� �����
			/// </summary>
			OnTrailPeriod = 16384,
			/// <summary>
			/// �������� ��������
			/// </summary>
			Cheif = 65536,
			/// <summary>
			/// ����� ��� ���������� ����������
			/// </summary>
			CanViewFinancialInfo = 131072
		}


		#endregion

		/// <summary>
		/// ����������� ������� 
		/// </summary>
		public NSISyncService() 
		{
           ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
           DataTableXmlFormatter.DirectBooleanFieldNames = new string[]{ "TimeReporting" };
		}

		
		/// <summary>
		/// ��������� ������������ ����������������� �������, ����������� 
		/// ������� ���������� ������� Incident Tracker
		/// </summary>
		[WebMethod (Description=@"��������� ������������ ����������������� �������, ����������� ������� ���������� ������� Incident Tracker")]
		public void TestTran() 
		{
			// ��� �������� ����������������� ��������� ���������:
			//	(�) � ����������� ������� ����������;
			//	(�) � ���, ��� �������� ���������� ��������;
			//	(�) � ���, ��� ��� ���������� �������� ����������� �������� � ��

			// ��� ����� ����� ��������� �������� ��������� �������������� ������� 
			// "SystemUser", ��������� � �������� ����� ����������� ����� - ����,
			// �������, �� ��� ����� ��������:
			string sLoginName = null;
			IPrincipal originalPrincipal = Thread.CurrentPrincipal;
			if (null!=originalPrincipal )
			{
				sLoginName = originalPrincipal.Identity.Name;
				int nSlashIndex = sLoginName.IndexOf('\\');
				if (nSlashIndex == -1)
					nSlashIndex = sLoginName.IndexOf('/');
				if (nSlashIndex > -1)
					sLoginName = sLoginName.Substring(nSlashIndex +1);
			}
			if (null!=sLoginName && 0!=sLoginName.Length)
			{
				GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest();
				requestGetId.TypeName = "SystemUser";
				requestGetId.Params = new XParamsCollection();
				requestGetId.Params.Add( "Login", sLoginName );

                GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)ApplicationServerProxy.Facade.ExecCommand(requestGetId);
				if(Guid.Empty == responseGetId.ObjectID) throw new ApplicationException("������������ ������������� ������������ �������!"); 
			}
		}


		#region ������, ������������ ��� ������������� ����������� "�������������"

		/// <summary>
		/// ��������� ��������������� ������ - helper, ���������� ������ 
		/// "������������ �������������", ��������� "������� �������"
		/// ����� ��������� ���������: ��� ����� ���� ������������� ����������� 
		/// �������������, � ����� ���� � ����������� - �.�. � ��� (����� �� ITv5)
		/// ��� �������� ������ �� ����������� ������ ��������� ��� �� �������� ��� 
		/// ������������� (sic!) ��������� ������.
		/// </summary>
		/// <param name="nPseudoDepartmentExtRefId">"�������" ������ �� "�������������"</param>
		/// <returns>
		/// ������������������ helper-������, c ������������ ������� �������.
		/// ��� ������� ����������� ��������� TypeName
		/// </returns>
		protected ObjectOperationHelper findPseudoDepartmentRef( int nPseudoDepartmentExtRefId ) 
		{
			XParamsCollection keyPropCollection = new XParamsCollection();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse(nPseudoDepartmentExtRefId.ToString()) );
			
			// ��� �� ������ ��� ������ � ������ ������ ��������, ������� 
			// ��������� ����� ������ �������������, � �������� "�������" 
			// ������������� �����. ���������: ��� ����� ��������� 
			// ����������� "�������� ������", ����������� ������������ ���� 
			// � ������������� (guid) ����������� �������. 
			// � �������� ��������� �������� "�������" �������������:
			DataTable data = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-Special-FindRealParentDepartment", keyPropCollection );
			if ((data==null) || (null!=data && 0==data.Rows.Count))
				throw new ArgumentException( 
					String.Format( 
						"������������ ������������� ������������ ������������� (ParentOrgUnit={0}); "+
						"��������� ������������� � ������������ ������� Incident Tracker �� �������!", 
						nPseudoDepartmentExtRefId ), 
					"ParentOrgUnit" );

			// ��������� ������ �����. ������� - ��� ����������������� ������
			// (������������ ���� � �������������) ���� � ���������� ������:
			ObjectOperationHelper helperRef = ObjectOperationHelper.GetInstance( 
				(string)data.Rows[0][0],	// � ������ ������ ������ - ������������ ����
				(Guid)data.Rows[0][1]		// �� ������ ������ ������ - �������������
			);
			helperRef.LoadObject();

			return helperRef;
		}
		
		
		/// <summary>
		/// ���������� ������ ���� ������� ����������� "�������������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <returns>
		/// �������� XML � ������� ���� ������� ������
		/// </returns>
		[WebMethod (Description = @"���������� ������ ���� ������� ����������� ""�������������"", �������������� � ������� Incident Tracker")]
		public XmlDocument GetOrgUnits() 
		{
			// �����a���� ������ � ���� XML-��������� ���������� ������� (� �������
			// �������� ������ ����������� ������ ������ ��� ������ �������������; 
			// ������� �������� ����� ��������):
			//		<Root>
			//			<orgUnit
			//				ObjectID="..."
			//				Name="..."
			//				ParentOrgUnit="..."
			//				Head="..."
			//				ObjectGUID="..."
			//				Flags="..."
			//				TimeReporting="..."
			//				Descr="..."
			//				Address="..."
			//				EMail="..."
			//				Phone="..."
			//				AccessRights="..."
			//				Code="..."
            //              IsArchive="..." 
			//			/>
			//		</Root>
			return ObjectOperationHelper.ExecAppDataSourceSpecial( "SyncNSI-GetList-Departments", null, "orgUnit" );
		}


		/// <summary>
		/// ��������� �������� ������ ������������� � ���������� "�������������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="Address">�����</param>
		/// <param name="Descr">��������</param>
		/// <param name="eMail">eMail</param>
		/// <param name="Head">������������� ������������ ������</param>
		/// <param name="Name">��������</param>
		/// <param name="ParentOrgUnit">������������� ������������� �������������</param>
		/// <param name="Phone">�������</param>
		/// <param name="TimeReporting">������������� ������ ������������</param>
		/// <param name="Code">������� ������������ �������������</param>
		/// <param name="ObjectGUID">GUID �������������</param>
		/// <returns>������������� ���������� ������</returns>
		[WebMethod (Description = @"��������� �������� ������ ������������� � ���������� ""�������������"", �������������� � ������� Incident Tracker")]
		public int InsertOrgUnitITracker(
			string Address, 
			string Descr, 
			string eMail, 
			int Head, 
			string Name,  
			int ParentOrgUnit, 
			string Phone, 
			byte TimeReporting, 
			string Code, 
			out string ObjectGUID ) 
		{
            // ��������������� �������� ������:
			ObjectOperationHelper.ValidateRequiredArgument( Name,"Name" );

            ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
			// ��������������� ������� ��� ������ � ds-�������
            ObjectOperationHelper helper = null;	
			ObjectOperationHelper helperRef = null;
			// ...� ��� ������������� ds-������� �� ������ �������� ��� �������
			XParamsCollection keyPropCollection = new XParamsCollection();
			
			if ( 0 == ParentOrgUnit )
			{
				// ���� ������������� ������������� ������������� �� ����� - �� �����
				// ��������������� �������� ��������� �������������, ��������� ���� 
				// �������� �����������; ������ � ����� �������� - ��� ����������� -
				// � ������� ����� ������.
				
				// #1: ������ ��� ������� ����� ����������� - ��������, ����� ��� �����������
				// ��� ��� � IT ������� (� ���� ������ _���������_ ��� ������ �� ����); � ��������
				// ����� ���������� ������������ (������� � ������) �����������:
				helper = ObjectOperationHelper.GetInstance( "Organization" );
				keyPropCollection.Add( "ShortName", Code );
				keyPropCollection.Add( "Name", Name );

				if ( helper.SafeLoadObject( keyPropCollection ) )
				{
					// #2.1: ����������� �����; ������ � ������� ������������ � ��� �����
					// ����� ����� (������ � �����). ����������� � ���� ������ �������
					// �� �����; ��������� ���� �������, ������������ ��� � ���� �����������
					// ���� �������� ���������:
					helper.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );

					// �.�. � ������ ������ �� �������� ������ �����������, �� ������
					// �� ���������� �� ��������, ������� �������� �� ����� (��� ��� ����):
					helper.DropPropertiesXml("Home" );
				}
				else
				{
					// ����������� �� ������� - ��������� "��������" �������� ����� �����������
					helper.LoadObject();

					// ������������� ��������� ����������� �������� ��� ������ �������:
					helper.SetPropValue( "ShortName", XPropType.vt_string, Code );
					helper.SetPropValue( "Name", XPropType.vt_string, Name );
					helper.SetPropValue( "Comment", XPropType.vt_string, Descr );
					// ��� �� ����������� - "��������"
					helper.SetPropValue( "Home", XPropType.vt_boolean, false );
					// ���������, ��� � ����������� "���������� ���������" (��� ������ ��� 
					// ����� - ��� �������� ��������� - �� ����� � �������):
					helper.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );
				}
				// ���� ��� ��������� ������ �� ������������ - ����� ����������� �����
			}
			else
			{
				// ������� ��������������� ������; � �������� �����������
				// ��������� ���������� ������ ������� ���� "�������"
				helper = ObjectOperationHelper.GetInstance( "Department" );
				helper.LoadObject();

				// ������������� ��������� ����������� �������� ��� ������ �������:
				helper.SetPropValue( "Code", XPropType.vt_string, Code );
				helper.SetPropValue( "Name", XPropType.vt_string, Name );
				helper.SetPropValue( "Comment", XPropType.vt_string, Descr );

				helper.SetPropValue( "Type", XPropType.vt_i2, DepartmentType.Direction ); // ������ ��� �����
				helper.SetPropValue( "TimeReporting", XPropType.vt_boolean, TimeReporting );

				// ��������� ��������� ��������:

				// ������ �� ����������� �������������; ����� ��������� ���������: 
				// ��� ����� ���� ������������� ����������� �������������, � ����� 
				// ���� � ����������� - �.�. � ��� ��� �������� ������ �� 
				// ����������� ������ ��������� ��� �� �������� ��� �������������
				// ��������� ������.
				// 
				// ��� �������� ������ ����� ������� ���������� ����������� 
				// ���������� �����, ������� ������� ���������� ��� ������ 
				// ������������ � ������ ������. �������� ��� ������� ����� � 
				// helperRef.TypeName:
				helperRef = findPseudoDepartmentRef( ParentOrgUnit );
				
				// ������ ��������� ������ �� ����� ����������� ������:
				// ���� ���������� ��������� "�����������" - ��� ������������� 
				// �������������, �� �� ��� ������ (����������� � helperRef) 
				// ��������� �� ����� ����������� ������ ������ �� �����������; 
				// ���� �� ��� � ���� ����������� - �� � ���� ������ ������ ��
				// ����������� ������������� ��������� ��������������������, 
				// �.�. � �� ����� �������� NULL
				if ( "Department" == helperRef.TypeName )
				{
					helper.SetPropScalarRef( "Parent", "Department", helperRef.ObjectID );
					// ����������� ������ �� �����������:
					XmlElement xmlPropOrgRef = helper.PropertyXml( "Organization" );
					xmlPropOrgRef.RemoveAll();
					xmlPropOrgRef.InnerXml = helperRef.PropertyXml("Organization").InnerXml;
				}
				else if ( "Organization" == helperRef.TypeName )
					helper.SetPropScalarRef( "Organization", "Organization", helperRef.ObjectID );
				else
					throw new ApplicationException("����������� ��� ������� - " + helperRef.TypeName);
			}

			// ������ �� ������������ �������������:
			if ( 0!=Head )
			{
				keyPropCollection.Clear();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(Head.ToString()) );

				helperRef = ObjectOperationHelper.GetInstance( "Employee" );
				helperRef.LoadObject( keyPropCollection );

				//� ������ ���� ��������� �� ����������� - ��������� �������� �������� "�������� �������" 
                //�������� ����� ����� �������� � ����� ����� ������������� �������� "�������� �������" ��� �����������
                if (helper.TypeName != "Organization")
                    helper.SetPropScalarRef("Director", "Employee", helperRef.ObjectID);
                else
                {
                    helper.DropPropertiesXml("Director");
                }
			}
			// ����� ������� ������ �� ���������� �������� �������, 
			// ������� ������ �� ������ ������������:
			helper.DropPropertiesXml( "ExternalRefID" );

			// ���������� ������ �������
			helper.SaveObject();
			
			// ������������ ������ ��� ��� - ��� ��� ������������ � �� - ��� ����, 
			// ��� �� �������� "�������" �������������:
			helper.LoadObject();
			// ���������� ���������� ������������� (��� ����� ������� � �� ������, 
			// �� ����� ������������� ����� ������� ���� ������ � NewObjectID):
			ObjectGUID = helper.ObjectID.ToString().ToUpper();
			return (int)helper.GetPropValue( "ExternalRefID",XPropType.vt_i4 );
		}

		
		/// <summary>
		/// ��������� �������� ������������� � ����������� "�������������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectID">������������� ������������ �������������</param>
		/// <param name="Address">�����</param>
		/// <param name="Descr">��������</param>
		/// <param name="eMail">eMail</param>
		/// <param name="Head">������������� ������������ �������������</param>
		/// <param name="Name">�������� �������������</param>
		/// <param name="ParentOrgUnit">������������� ������������� �������������</param>
		/// <param name="Phone">�������</param>
		/// <param name="TimeReporting">������������� ������ ������������ �� �������� �������</param>
		/// <param name="Flags">�����</param>
		/// <param name="Code">��� �����������</param>
        /// <param name="IsArchive">��������</param>
        [WebMethod(Description = @"��������� �������� ������������� � ����������� ""�������������"", �������������� � ������� Incident Tracker")]
		public void UpdateOrgUnitITracker(
			int ObjectID, 
			string Address, 
			string Descr, 
			string eMail, 
			int Head, 
			string Name, 
			int ParentOrgUnit, 
			string Phone, 
			byte TimeReporting, 
			int Flags, 
			string Code,
            bool IsArchive) 
		{
			if (0==ObjectID)
				throw new ArgumentException("�� ����� ������������� �������� �������������/�����������", "ObjectID");

			// ��������� ������ ���������� ������������� � ������-helper.
			// ����� ��������� ���������: ��� ����� ���� ������������� ����������� 
			// �������������, � ����� ���� � ����������� - �.�. � ��� (����� �� ITv5)
			// ��� �������� ������ �� ����������� ������ ��������� ��� �� �������� ��� 
			// ������������� (sic!) ��������� ������.
			// "���������" ��� ������� ����� � helperDepartment.TypeName
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( ObjectID );
			helperDepartment.LoadObject();


			// ���������� ������ �� ����������� �������������
			// �������� ��� � ���: ������ �.�. ������������ ������ ����
			//	(�) �������� ������������� - ���� "���������", � �� �����������, 
			//	(�) ������ ����� ����������� ������������� (�� ����� - "���������" ��� ���)

			// ������� ���������������� ������ ��������� ������������ �������������:
			ObjectOperationHelper helperParentDepartment = null;
			// ...������� ����� ���� ����������� ������ � "����������" �������������:
			if ( "Department" == helperDepartment.TypeName )
			{
				if (0!=helperDepartment.PropertyXml("Parent").ChildNodes.Count)
				{
					helperParentDepartment = helperDepartment.GetInstanceFromPropScalarRef( "Parent" );
					if (Guid.Empty == helperParentDepartment.ObjectID)
						helperParentDepartment = null;
				}
			}
			// ������� ����������������� ������ "������" ������������ �������������
			ObjectOperationHelper helperNewParentDep = null;
			if ( 0!=ParentOrgUnit )
				helperNewParentDep = findPseudoDepartmentRef( ParentOrgUnit );
			
			// ���� ������ ������� � ��������� �� �����. �������� (��. ����), 
			// ���������� ����������:
			if ( "Organization"==helperDepartment.TypeName && null!=helperNewParentDep )
				throw new ArgumentException( 
					DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE + 
					": �������� ������������� (�����������) �� ����� ���� ��������� ������� ������������ / �����������", 
					"ParentOrgUnit" );
			if ( "Department"==helperDepartment.TypeName && null==helperNewParentDep )
				throw new ArgumentException(
					DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE + 
					": ����������� ������������� �� ����� ������������ ��� �������� (�����������)", 
					"ParentOrgUnit" );
			
			// �������� ������������ ������ �� "�����������" (���� ������ 
			// ������������� ������ - "��������� �������������):
			if ( "Department"==helperDepartment.TypeName )
			{
				// ���� ����� ����������� - "���������" �������������: ����������
				// � �������������� ������ �� ������������� � ��������� ������ �� 
				// ����������� (��� ���� ������� ��������� ������ ������ "������������"):
				if ( "Department"==helperNewParentDep.TypeName )
				{
					helperDepartment.SetPropScalarRef( "Parent", "Department", helperNewParentDep.ObjectID );
					// ����������� ������ �� �����������:
					helperNewParentDep.LoadObject();
					XmlElement xmlPropOrgRef = helperDepartment.PropertyXml( "Organization" );
					xmlPropOrgRef.RemoveAll();
					xmlPropOrgRef.InnerXml = helperNewParentDep.PropertyXml("Organization").InnerXml;
				}
				// ���� �� ����� ����������� - ����������� � ����, �� � ��������������
				// (�) ������� ������ �� ����������� �������������,
				// (�) ��������� ������ �� ����� �����������
				else
				{
					helperDepartment.PropertyXml("Parent").RemoveAll();
					helperDepartment.SetPropScalarRef( "Organization", "Organization", helperNewParentDep.ObjectID );
				}
			}
			else
			{
				// � ������ �������������� "������"-�������������, ������� �� 
				// ����� ���� ����������� - �������� ������ �� ����������� (�����
				// ��� - �����������) �� ���������� - ��� �� Storage ������ �� 
				// ��������:
				helperDepartment.DropPropertiesXml("Parent");
			}
			
			
			// ���������� ������ �� ���������� - ������������ �������������
			if ( 0!=Head )
			{
				// ��� ��������� ������ ����� ���������� ObjectID �������; �������
				// ��� �� ��������� ��������� "��������", ��������� ������ 
				// ���������������� �������:
				XParamsCollection keyPropCollection = new XParamsCollection();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(Head.ToString()) );

				ObjectOperationHelper helperNewDirector = ObjectOperationHelper.GetInstance( "Employee" );
				helperNewDirector.GetObjectIdByExtProp(keyPropCollection);
				
				// ������������� ����� ������ - ��������� ������� � ������ ���� ������ �������� ��������������
                //�������� ����� ����� ����� ������������� �������� "�������� �������" ��� �����������
				if (helperDepartment.TypeName!="Organization") helperDepartment.SetPropScalarRef( 
	            "Director","Employee", helperNewDirector.ObjectID);
				else
				{
				    helperDepartment.DropPropertiesXml("Director");
				}
				
			}
			else
			{
				// ������������� ���������� - ������������ ������� - ������ 
				// ������ �� ������ - ������� ������ ������ � ����������; ��� 
				// �� ��������� Stroage ��������� � �����. ���� NULL:
				helperDepartment.PropertyXml("Director").RemoveAll();
			}


			// ������ ����� �������� ��������� ����������� �������
			if ( "Department"==helperDepartment.TypeName )
			{
				// ��� ������, ���� ������������� ���� "���������" �������������:
				helperDepartment.SetPropValue("Code", XPropType.vt_string, Code );
				helperDepartment.SetPropValue("Name", XPropType.vt_string, Name );
				helperDepartment.SetPropValue("Comment", XPropType.vt_string, Descr );
				helperDepartment.SetPropValue("TimeReporting", XPropType.vt_boolean, TimeReporting );
                helperDepartment.SetPropValue("IsArchive", XPropType.vt_boolean, IsArchive);

				// ������� ��������, �������� ������� ���������� �� ������
				helperDepartment.DropPropertiesXml( 
					"Type",
					"ExternalID", 
					"ExternalRefID" ); 
			}
			else
			{
				helperDepartment.SetPropValue( "ShortName", XPropType.vt_string, Code );
				helperDepartment.SetPropValue( "Name", XPropType.vt_string, Name );
				helperDepartment.SetPropValue( "Comment", XPropType.vt_string, Descr );

				// ��� ����������� ������ ������������� ����������� ������� ������� ��������
				// ��������� ����������� (���� ��� � �� ������ ��������, ������ �.�. ���������
				// �������):
				helperDepartment.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );

				// ������� ��������, �������� ������� ���������� �� ������
				helperDepartment.DropPropertiesXml( 
					"Home", 
					"ExternalID", 
					"ExternalRefID"  );
			}


			// ���������� ������ ����������� �������
			helperDepartment.SaveObject();
		}

	
		/// <summary>
		/// ������� �������� ������������� �� ����������� "�������������", 
		/// ��������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectID">������������� �������������</param>
		[WebMethod (Description = @"������� �������� ������������� �� ����������� ""�������������"", ��������������� � ������� Incident Tracker")]
		public void DeleteOrgUnitITracker( int ObjectID ) 
		{
            ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
			// ��������������� ������ ��� ������ � ds-�������
			ObjectOperationHelper helper = null;	
			// ...� ��� ������������� ds-������� �� ������ �������� ��� �������
			XParamsCollection keyPropCollection = new XParamsCollection();

			// ��������� ������������� �������������
			// ����� ��������� ���������: ��� ����� ���� ������������� 
			// �������������, � ����� ���� � ����������� - �.�. � ��� ��� �������� 
			// ������ �� ����������� ������ ��������� ��� �� �������� ��� 
			// ������������� (sic!) ��������� ������.

			// ��� �� ������ ��� ������ � ������ ������ ��������, ������� 
			// ��������� ���������� ��� � ������������� ������� (������������� 
			// ��� �����������), � �������� "�������" ������������� �����. 
			// ���������: ��� ����� ��������� ����������� "�������� ������", 
			// ����������� ������������ ���� � ������������� (guid) ����������� 
			// �������. � �������� ��������� �������� "�������" �������������:
			keyPropCollection.Clear();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse(ObjectID.ToString()) );
				
			DataTable data = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-Special-FindRealParentDepartment", keyPropCollection );
			if ((data==null) || (null!=data && 0==data.Rows.Count))
				throw new ArgumentException( 
					String.Format( 
					"������������ ������������� ������������� (ObjectID={0}); "+
					"��������� ������������� � ������������ ������� Incident Tracker �� �������!", ObjectID ), 
					"ObjectID" );

			// ��������� ������ �����. ������� - ��� ����������������� ������
			// (������������ ���� � �������������) ���� � ���������� ������:
			helper = ObjectOperationHelper.GetInstance( 
				(string)data.Rows[0][0],	// � ������ ������ ������ - ������������ ����
				(Guid)data.Rows[0][1]		// �� ������ ������ ������ - �������������
			);
			
			// �������� �������� ������� (��� �� ��� �� ����)
			helper.DeleteObject();
		}

		
		#endregion

		#region ������, ������������ ��� ������������� ������������ "����������" � "������������"

		/// <summary>
		/// ���������� ���� �����������/�������������, �������������� 
		/// � ����������� "������������" ������� Incident Tracker
		/// </summary>
		/// <param name="loadPict">������ ���� ������ false</param>
		/// <returns>
		/// �������� XML c ������� ����������� / �������������
		/// </returns>
		[WebMethod (Description=@"���������� ���� �����������/�������������, �������������� � ����������� ""������������"" ������� Incident Tracker")]
		public XmlDocument GetUsers( bool loadPict ) 
		{
			// �������� ���� ������ ������������� ����� � ���� ������ - ������� 
			// �� ������� ������ ��� ������������ ��������������� ��������� 
			// ������: �.�. ��������� �������� ������ - ������� �� ��� ����.
			// �� ��� ���� ��������� ����� ������ � ���������� loadPict, ��������
			// � true:
			if (loadPict)
				throw new ArgumentException( 
					"�������� ������ ���� �����������, ���������� ����������, ����������! " +
					"������������� ����������� ����� GetPhoto(...)",
					"loadPict"
				);
			
			// �����a���� ������ � ���� XML-��������� ���������� ������� (� �������
			// �������� ������ ����������� ������ ������ ��� ������ ������������; 
			// ������� �������� ����� ��������):
			//		<Root>
			//			<user
			//				UID="..." 
			//				FirstName="..."
			//				MiddleName="..."
			//				LastName="..."
			//				OrgUnit="..."
			//				ObjectID="..."
			//				SystemUserPosition="..."
			//				Address="..."
			//				ObjectGUID="..."
			//				Flags="..."
			//				Picture="..." <<<-- ����������, ������ ���� ����� ���� loadPict
			//				Phone="..."
			//				EMail="..."
			//				MobilePhone="..."
			//				PhoneExt="..."
			//			/>
			//		</Root>

			// ������ �������� ����� ��������, ������� ��������� ��������
			// ���������� ����������� - � ��������� ������ ������� ������� 
			// "�������" �������������� XML ��� ������������ ����������
			// �������� � ���������� ���� OutOfMemoryException
			XParamsCollection dataSourceParams = new XParamsCollection();
			dataSourceParams.Add( "DoPictureLoad", false );
			return ObjectOperationHelper.ExecAppDataSourceSpecial( "SyncNSI-GetList-Employees", dataSourceParams, "user" );
		}

		/// <summary>
		/// ��������� �������� ������ ���������� � ���������� "����������", 
		/// �������������� � ������� Incident Tracker; ��� �� ������� 
		/// ��������������� �������� ����������� "������������"
		/// </summary>
		/// <param name="Address">�����</param>
		/// <param name="eMail">eMail</param>
		/// <param name="FirstName">���</param>
		/// <param name="LastName">�������</param>
		/// <param name="MiddleName">��������</param>
		/// <param name="MobilePhone">��������� �������</param>
		/// <param name="OrgUnit">������������� �������������, ��� ��������� ��������</param>
		/// <param name="Phone">�������</param>
		/// <param name="PhoneExt">���������� �������</param>
		/// <param name="SystemUserPosition">������������� ��������� ����������</param>
		/// <param name="UID">������������� ���������� (�������)</param>
		/// <param name="ObjectGUID">GUID ����������</param>
		/// <param name="Flags">�����</param>
		/// <param name="Picture">���������� ���������� � ���� ������ bin.hex</param>
		/// <returns>������������� ����������� ������</returns>
		[WebMethod (Description = @"��������� �������� ������ ���������� � ���������� ""����������"", �������������� � ������� Incident Tracker; ��� �� ������� ��������������� �������� ����������� ""������������""")]
		public int InsertUserITracker(
			string Address, 
			string eMail, 
			string FirstName, 
			string LastName, 
			string MiddleName, 
			string MobilePhone, 
			int OrgUnit, 
			string Phone, 
			string PhoneExt, 
			int SystemUserPosition, 
			string UID, 
			out string ObjectGUID, 
			int Flags, 
			string Picture ) 
		{
			// ���������� ������������� out-�������� � "�����������" ��������
			ObjectGUID = String.Empty;

			// ������� �������� �������������� �������� "�������������" �
			// "���������". ���������� ��� ����� ��������������� �������. 
			
			// -- ������ �� �������������; ����� ��������� ���������: 
			// ��� ����� ���� ������������� �������������, � ����� ���� � 
			// ����������� - �.�. � ��� (����� �� ITv5) ��� �������� ������ �� 
			// ����������� ������ ��������� ��� �� �������� ��� �������������
			// (sic!) ��������� ������.
			// 
			// ��� �������� ������ ����� ������� ���������� ����������� 
			// ���������� �����, ������� ������� ���������� ��� ������ 
			// ������������ � ������ ������. �������� ��� ������� ����� � 
			// helperDepartment.TypeName:
			if ( 0==OrgUnit )
				throw new ArgumentException("������������� ������������� / ����������� �� �����", "OrgUnit");
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( OrgUnit );

			// -- ������ �� ��������� (����� �� ����������)
			// ���� ������ ��������� ��������� ��� �� ����� - ����� ������ 
			// �������� ������������� �������:
			ObjectOperationHelper helperPosition = ObjectOperationHelper.GetInstance( "Position" );
			// �������������� ������ "�������" ��������������� - ���� ��, �������, �����:
			if ( 0!=SystemUserPosition )
			{
				XParamsCollection keyPropCollection = new XParamsCollection();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(SystemUserPosition.ToString()) );
				helperPosition.GetObjectIdByExtProp( keyPropCollection );
			}


			// ��������� ��������������� ������� ������� ������� ��������� ��� 
            // �������� ���� "������������" (SystemUser), "���������" (Employee), 
            // "����� �������� �������" (EmployeeRate)
            // SystemUser ������������ ��� ���������� ����������, ����������� ��� 
			// ����� � ������� (�����, �������������� ���������� UID), 
            // Employee ������������ ��� ������ ����������
            // EmployeeRate ������ �� ����� �������� ������� ����������
            // Organization ������������ ������ �� ����������� � ������� ��������� ���������
			ObjectOperationHelper helperSystemUser = ObjectOperationHelper.GetInstance( "SystemUser" );
			helperSystemUser.LoadObject();
			ObjectOperationHelper helperEmployee = ObjectOperationHelper.GetInstance( "Employee" );
			helperEmployee.LoadObject();
            ObjectOperationHelper helperEmployeeRate = ObjectOperationHelper.GetInstance("EmployeeRate");
            helperEmployeeRate.LoadObject();
            ObjectOperationHelper helperOrganization = ObjectOperationHelper.GetInstance("Organization");
  
         
            // ����� ������ ����� �/� ��������� - "���������" ��������� �� "������������":
			helperEmployee.SetPropScalarRef( "SystemUser", "SystemUser", helperSystemUser.NewlySetObjectID );

			// ��������� ������ �� ����������� � ������������� (���� ��������� ������):
			// ���� ��������� "������������" - ��� ������������� �������������, 
			// �� �� ��� ������ (����������� � helperDepartment) ��������� �� 
			// ����� ����������� ������ ������ �� �����������; ���� �� ��� � 
			// ���� ����������� - �� � ���� ������ ������ �� ������������� 
			// ��������� ��������������������, �.�. � �� ����� �������� NULL
			if ( "Department" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Department", "Department", helperDepartment.ObjectID );
				// ����������� ������ �� �����������:
				XmlElement xmlPropOrgRef = helperEmployee.PropertyXml( "Organization" );
				xmlPropOrgRef.RemoveAll();
				xmlPropOrgRef.InnerXml = helperDepartment.PropertyXml("Organization").InnerXml;
                //�����������, � ������� ������� ���������� - ��� �����������,�� ������� ��������� ����������� 
			    helperOrganization = helperDepartment.GetInstanceFromPropScalarRef("Organization");
			}
            else if ("Organization" == helperDepartment.TypeName)
            {
                helperEmployee.SetPropScalarRef("Organization", "Organization", helperDepartment.ObjectID);
                //���������� ���������� ������������� �����������,������� helperOrganization ��� � ���� helperDepartment
                helperOrganization = helperDepartment;
            }
            else
                throw new ApplicationException("����������� ��� ������� - " + helperDepartment.TypeName);
			
            //���� ��������� ��������� � ����������� - ��������� �������,�� ������������� ��� ���� ��������� ����,
            //������� ����� �������� �� ��������� (������� IsDefaultRole=1)
            helperOrganization.LoadObject();
            if ((bool)helperOrganization.GetPropValue("Home", XPropType.vt_boolean, true))
            {
                foreach (string item in ServiceConfig.Instance.DefaultSystemRoles)
                {
                    helperSystemUser.AddArrayPropRef("SystemRoles", "SystemRole", new Guid(item)); 
                }
                
            }

		    // ������ �� ��������� (���� ����� ������)
			if ( Guid.Empty != helperPosition.ObjectID )
				helperEmployee.SetPropScalarRef( "Position", "Position", helperPosition.ObjectID );


			// ����� �������� ����������� ��������� �������:
			// -- ��� SystemUser:
			helperSystemUser.SetPropValue( "Login", XPropType.vt_string, UID );
			helperSystemUser.SetPropValue( "IsServiceAccount", XPropType.vt_boolean, false );

			// ��� "�����", ���������� � ITv5 ��������, � ITv6 �������� ������������,
			// ��������� ��������������� ��� ������������, ��� ������������� - ����� 
			// ������ ��������� ���� (������� �� ���� - ����������� ������ ����������)
			//
			// � ������� ������������� ����� ITv5 ����������� ��� ������ �� ����������������
			// ������� �����, ���������� ��� ������������. ����� ������ (����� ���� �����
			// ���� ������) ����������� � ���������� ���������������� ����� ��������.
			// 
			// �����: ��������� ���������� �� ���������������:
			helperSystemUser.SetPropValue( "SystemPrivileges", XPropType.vt_i4, 0 );
			// ������� ������ ���� ����� ������������: 		
			bool bIsClearRoles = false;
			// ����: ���� �� ������, �������� ��� ������������; ���� ��������������� ����
			// ����� ��� ������������ � ����� ����� � ������������ �����. ������������ ����,
			// �� ��������� ��� ����:
			foreach( int nFlag in ServiceConfig.Instance.RolesMap.Flags )
			{
				// ���� ��������������� ���� - �� ���, ��� ����� - ����������:
				if ( nFlag != (Flags & nFlag) )
					continue;
					
				// �������� �������� ������
				UserFlagToRoleLink link = ServiceConfig.Instance.RolesMap[nFlag];
				// ���������, ��� ��� �� "����������" - ���� ���, �� ���������� ��� 
				// � ������� �� ����� - ����� ������������� ����� �� ����� ������
				if ( (bIsClearRoles = link.IsClearRolesFlag) )
					break;
					
				// ���� ������ �������� �����-�� ���� - �������� �����. ��������� ������
				// � �������� ������� (��� ���� � ��������� ������ ���������� ��-�� 
				// RoleObject - ��� ������ ������� ��� ���� �������� �������� ������ 
				// � ������� ����������)
				if (Guid.Empty != link.RoleID)
					helperSystemUser.AddArrayPropRef( "SystemRoles", link.RoleObject.TypeName, link.RoleObject.ObjectID ) ;
			}
			if ( bIsClearRoles )
				helperSystemUser.ClearArrayProp( "SystemRoles" );
			
			// -- ��� Employee:
			helperEmployee.SetPropValue( "LastName", XPropType.vt_string, LastName );
			helperEmployee.SetPropValue( "FirstName", XPropType.vt_string, FirstName );
			helperEmployee.SetPropValue( "MiddleName", XPropType.vt_string, MiddleName );
			// ���� ������ ������ �������� �� ������� �������� ��������:
			helperEmployee.SetPropValue( "WorkBeginDate", XPropType.vt_date, DateTime.Today );
			// ������ (�������� Flags) ����� ���� �������, ��� ���������/������������ 
			// �������� ��������. � ITv6 ���� "����������" �������� ����� ���������� 
			// ������, WorkEndDate. ���� ���� "��������" �����, �� ���������
			// ���� ���������� ������; ��� ���� ���������� ������� ����:
			if ( 0x2 == (Flags & 0x2)) // ���� "��������"
				helperEmployee.SetPropValue( "WorkEndDate", XPropType.vt_date, DateTime.Today );
			helperEmployee.SetPropValue( "Phone", XPropType.vt_string, Phone );
			helperEmployee.SetPropValue( "PhoneExt", XPropType.vt_string, PhoneExt );
			helperEmployee.SetPropValue( "MobilePhone", XPropType.vt_string, MobilePhone );
			helperEmployee.SetPropValue( "Address", XPropType.vt_string, Address );
			helperEmployee.SetPropValue( "EMail", XPropType.vt_string, eMail );
			// ������ �������� ���������� ���������� - ���� ������
			if (null!=Picture && 0!=Picture.Length)
			{
				helperEmployee.PropertyXml("Picture").RemoveAll();
				helperEmployee.PropertyXml("Picture").InnerText = ObjectOperationHelper.ConvertBinHexToBinBase64( Picture );
			}
			// NB: ��� �������� ����� ��� ��� ���� �������� � ExternalID - ��� �� 
			// ����� ������� �� � ������������ ���� �������, ��� ������� �� ���
			// (��. ���������� GetUsers � SQL-�������� � �������� ��������� ������ 
			// SyncNSI-GetList-Employees:
			helperEmployee.SetPropValue( "ExternalID", XPropType.vt_string, Flags.ToString() );

			// ������� ���������, ������ ������� �� ������ ������������ � ��:
			helperEmployee.DropPropertiesXml( "ExternalRefID" );

            // �������� ������ � ������� EmployeeRate - ����� �������� ������� �� ��������� ��� ���� ����� �����������
            // "����� �������� �������" ��������� �� "���������"
            helperEmployeeRate.SetPropScalarRef("Employee", "Employee", helperEmployee.NewlySetObjectID);
            // ����� �������� ����������� � ������� ������ ���������� �� ������ (WorkBeginDate)
            // �������� ������� �� ��������, ���� � ������� ���� ������ �� ������ ����� ������� �� ��������� "������� ����"
            helperEmployeeRate.SetPropValue("Date", XPropType.vt_date, helperEmployee.GetPropValue("WorkBeginDate", XPropType.vt_date));
            // � ���� "����������" ��������� "����� �� ������"
            helperEmployeeRate.SetPropValue("Comment", XPropType.vt_text, EmployeeHistoryEventsItem.WorkBeginDay.Description);
            // � ���� "�����" ��������� �������� �� ��������� �� ���� ������.
            DataTable data = ObjectOperationHelper.ExecAppDataSource("GetWorkdayGlobalDuration", null);
            if ((data == null) || (null != data && 1 != data.Rows.Count))
                throw new ApplicationException("GetWorkdayGlobalDuration: ������ ��������� ����� �� ���������. ������ �� ������ ������ ��� ������ ����� ����� ������.");

            helperEmployeeRate.SetPropValue("Rate", XPropType.vt_i2, data.Rows[0][0]);


			// ���������� ������ ����� �������� ������������, � ������ ����� 
			// "�������" ����������; ��� ���������� ��� ����������� ���������
			// �����������, �������� �/� ���������
            ObjectOperationHelper.SaveComplexDatagram(helperSystemUser, helperEmployee, helperEmployeeRate);

			// � �������� ��������������� GUID-� ���������� ������������� �������
			// ���� "���������" (Employee) - �.�. ����� ��� ������������� ������
			// "�����������" ������������ ���������������� ������ ������ ���� 
			// ��������:
			ObjectGUID = helperEmployee.ObjectID.ToString();

			// �������������� � �������� ��������������� "��������" ��������������
			// ���������� ExternalRefId ������� "���������"; ��� �� ��� ��������, 
			// ������� ���������� ������ �������:
			helperEmployee.LoadObject();
			return int.Parse( helperEmployee.GetPropValue("ExternalRefID", XPropType.vt_i4).ToString() );
		}
		
		
		/// <summary>
		/// ��������� �������� ���������� � ����������� "����������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectID">������������� ���������� � ������� SystemUser</param>
		/// <param name="Address">�����</param>
		/// <param name="eMail">eMail</param>
		/// <param name="FirstName">���</param>
		/// <param name="LastName">�������</param>
		/// <param name="MiddleName">��������</param>
		/// <param name="MobilePhone">��������� �������</param>
		/// <param name="OrgUnit">������������� �������������, � ������� ��������� ��������</param>
		/// <param name="Phone">�������</param>
		/// <param name="PhoneExt">���������� �������</param>
		/// <param name="SystemUserPosition">������������� ��������� ����������</param>
		/// <param name="UID">������������� ���������� (�������)</param>
		/// <param name="Flags">�����</param>
		/// <param name="Picture">���������� ����������, ���� �������� ����� null - ���������� �� �����������</param>
		[WebMethod (Description=@"��������� �������� ���������� � ����������� ""����������"", �������������� � ������� Incident Tracker")]
		public void UpdateUserITracker(
			int ObjectID, 
			string Address, 
			string eMail, 
			string FirstName, 
			string LastName, 
			string MiddleName, 
			string MobilePhone, 
			int OrgUnit,
			string Phone, 
			string PhoneExt, 
			int SystemUserPosition, 
			string UID, 
			int Flags, 
			string Picture ) 
		{
			// TODO: �������� ������� ����������:

			// ��������� ������ ��������
			// ��������� ������ ������� "���������"
			ObjectOperationHelper helperEmployee = ObjectOperationHelper.GetInstance( "Employee" );
			XParamsCollection keyPropCollection = new XParamsCollection();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse( ObjectID.ToString() ) );
			helperEmployee.LoadObject( keyPropCollection );
			
			// ��������� ������ ������� "������������"; ����������������� ������
			// ������� ����� �� ��������� ������ SystemUser
			ObjectOperationHelper helperSystemUser = helperEmployee.GetInstanceFromPropScalarRef( "SystemUser" );
			helperSystemUser.LoadObject( new string[]{ "SystemRoles"} );
			
			// ����� �������� ����������� ��������� �������:
			
			// -- ��� SystemUser:
			helperSystemUser.SetPropValue( "Login", XPropType.vt_string, UID );

			// ��� "�����", ���������� � ITv5 ��������, � ITv6 �������� ������������,
			// ��������� ��������������� ��� ������������, ��� ������������� - ����� 
			// ������ ��������� ���� (������� �� ���� - ����������� ������ ����������)
			//
			// � ������� ������������� ����� ITv5 ����������� ��� ������ �� ����������������
			// ������� �����, ���������� ��� ������������. ����� ������ (����� ���� �����
			// ���� ������) ����������� � ���������� ���������������� ����� ��������.

			// �����:
			// #0: �������� �������� ��� ��������: "�������� ������������"...
			bool bHasArchivedFlag = ( NsiConst_UserFlags.ArchiveUser == ((NsiConst_UserFlags)Flags & NsiConst_UserFlags.ArchiveUser) );
			// ...� ������� "�� �������� ���������" (� IT6 ��� �������� �������������� "�������"):
			bool bHasNoMessageFlag = ( NsiConst_UserFlags.DoNotReceiveMessages == ((NsiConst_UserFlags)Flags & NsiConst_UserFlags.DoNotReceiveMessages) );
			
			// #1: ��������, ��� ����� ���������� (���������� �������� ��������� �
			// ExternalRefID ����������) - ���� ����� �� ��������, �� � ����� ������� 
			// �� �����:
			string sPrevFlags = (string)helperEmployee.GetPropValue( "ExternalID", XPropType.vt_string );

			if (null==sPrevFlags || String.Empty==sPrevFlags)
				sPrevFlags = "0";
			if ( Flags.ToString() != sPrevFlags )
			{
				// #2: �������������� ������� ��� ����:
				helperSystemUser.ClearArrayProp( "SystemRoles" );

				// #3: ���� �� ������, �������� ��� ������������; ���� ��������������� ����
				// ����� ��� ������������ � ����� ����� � ������������ �����. ������������ ����,
				// �� ��������� ��� ����:
				bool bIsClearRoles = false;
				foreach( int nFlag in ServiceConfig.Instance.RolesMap.Flags )
				{
					// ���� ��������������� ���� - �� ���, ��� ����� - ����������:
					if ( nFlag != (Flags & nFlag) )
						continue;
					
					// �������� �������� ������
					UserFlagToRoleLink link = ServiceConfig.Instance.RolesMap[nFlag];
					// ���������, ��� ��� �� "����������" - ���� ���, �� ���������� ��� 
					// � ������� �� ����� - ����� ������������� ����� �� ����� ������
					if ( (bIsClearRoles = link.IsClearRolesFlag) )
						break;
					
					// ���� ������ �������� �����-�� ���� - �������� �����. ��������� ������
					// � �������� ������� (��� ���� � ��������� ������ ���������� ��-�� 
					// RoleObject - ��� ������ ������� ��� ���� �������� �������� ������ 
					// � ������� ����������)
					if (Guid.Empty != link.RoleID)
						helperSystemUser.AddArrayPropRef( "SystemRoles", link.RoleObject.TypeName, link.RoleObject.ObjectID ) ;
				}
				if ( bIsClearRoles )
					helperSystemUser.ClearArrayProp( "SystemRoles" );
				
				// #4: ��������� ����������:
				// ... ���� ��������� ������ (���� ���� "��������") - ������������:
				if ( bHasArchivedFlag )
					helperSystemUser.SetPropValue( "SystemPrivileges", XPropType.vt_i4, 0 );
				// ... ���� ��������� �������� - �� ���������� (�������� �� 
				// ���������� ����, ����� ��� �� ������������):
				else
					helperSystemUser.DropPropertiesXml( "SystemPrivileges" );
			}

			
			// -- ��� Employee:
			helperEmployee.SetPropValue( "LastName", XPropType.vt_string, LastName );
			helperEmployee.SetPropValue( "FirstName", XPropType.vt_string, FirstName );
			helperEmployee.SetPropValue( "MiddleName", XPropType.vt_string, MiddleName );
			
			// ���� ������ ������ � ������� ������� ����� �� ����������; �����., 
			// helperEmployee.SetPropValue( "WorkBeginDate", ... ) �� ���������; 
			// �� - ������ (�������� Flags) ����� ���� �������, ��� ���������
			// (������������) �������� ��������. � ITv6 ���� "����������" �������� 
			// ����� ���������� ������, WorkEndDate. 
			if ( bHasArchivedFlag ) 
			{
				// ���� ���� �������� ��� �� ���������, � ��� ���� ���� "��������" 
				// �����, �� ��������� ���� ���������� ������; ��� ���� ���������� 
				// ������� ����:
				if ( 0 == helperEmployee.PropertyXml("WorkEndDate").InnerText.Length )
					helperEmployee.SetPropValue( "WorkEndDate", XPropType.vt_date, DateTime.Today );
				else
					// ����� - ���� ���� ��� ���� ������ - ������� �������� ������, 
					// ��� �� �� ������������ ��� ��������� � ��:
					helperEmployee.DropPropertiesXml( "WorkEndDate" );
			}
			else
			{
				// ���� "��������" �������: 
				// ������� � IT6 ���� ���������� - ��� � ������� ��������� 
				// ���������� �������� "��������":
				helperEmployee.PropertyXml("WorkEndDate").InnerText = String.Empty;
			}
			
			helperEmployee.SetPropValue( "Phone", XPropType.vt_string, Phone );
			helperEmployee.SetPropValue( "PhoneExt", XPropType.vt_string, PhoneExt );
			helperEmployee.SetPropValue( "MobilePhone", XPropType.vt_string, MobilePhone );
			helperEmployee.SetPropValue( "Address", XPropType.vt_string, Address );
			helperEmployee.SetPropValue( "EMail", XPropType.vt_string, eMail );
			// ������ �������� ���������� ���������� - ���� �� ������, ��
			// ����� ����������� ������ ������ ������, ������� ��� ������ �����
			// ���������������� Storage-�� ��� NULL - ������ � �� ����� ��������
			helperEmployee.PropertyXml("Picture").RemoveAll();
			helperEmployee.PropertyXml("Picture").InnerText = ObjectOperationHelper.ConvertBinHexToBinBase64( Picture );

			// NB: ��� �������� ����� ��� ��� ���� �������� � ExternalID - ��� �� 
			// ����� ������� �� � ������������ ���� �������, ��� ������� �� ���
			// (��. ���������� GetUsers � SQL-�������� � �������� ��������� ������ 
			// SyncNSI-GetList-Employees:
			helperEmployee.SetPropValue( "ExternalID", XPropType.vt_string, Flags.ToString() );

			
			// ���������� ��������� ������ �� �������������, �����������, ���������

			// -- ������ �� �������������; ����� ��������� ���������: 
			// ��� ����� ���� ������������� �������������, � ����� ���� � 
			// ����������� - �.�. � ��� (����� �� ITv5) ��� �������� ������ �� 
			// ����������� ������ ��������� ��� �� �������� ��� �������������
			// (sic!) ��������� ������.
			// 
			// ��� �������� ������ ����� ������� ���������� ����������� 
			// ���������� �����, ������� ������� ���������� ��� ������ 
			// ������������ � ������ ������. �������� ��� ������� ����� � 
			// helperDepartment.TypeName:
			if ( 0==OrgUnit )
				throw new ArgumentException("������������� ������������� / ����������� �� �����", "OrgUnit");
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( OrgUnit );

			// -- ������ �� ��������� (����� �� ����������)
			// ���� ������ ��������� ��������� ��� �� ����� - ����� ������ 
			// �������� ������������� �������:
			ObjectOperationHelper helperPosition = ObjectOperationHelper.GetInstance( "Position" );
			// �������������� ������ "�������" ��������������� - ���� ��, �������, �����:
			if ( 0!=SystemUserPosition )
			{
				keyPropCollection.Clear();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(SystemUserPosition.ToString()) );
				helperPosition.GetObjectIdByExtProp( keyPropCollection );
			}

			// ��������� ������ �� ����������� � ������������� (���� ��������� ������):
			// ���� ��������� "������������" - ��� ������������� �������������, 
			// �� �� ��� ������ (����������� � helperDepartment) ��������� �� 
			// ����� ����������� ������ ������ �� �����������; ���� �� ��� � 
			// ���� ����������� - �� � ���� ������ ������ �� �������������
			// ���������� - ������� ������ ��������, �.�. � �� ����� �������� NULL
			if ( "Department" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Department", "Department", helperDepartment.ObjectID );
				// ����������� ������ �� �����������:
				XmlElement xmlPropOrgRef = helperEmployee.PropertyXml( "Organization" );
				xmlPropOrgRef.RemoveAll();
				xmlPropOrgRef.InnerXml = helperDepartment.PropertyXml("Organization").InnerXml;
			}
			else if ( "Organization" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Organization", "Organization", helperDepartment.ObjectID );
				// ������� ������ ������ �� �������������
				helperEmployee.PropertyXml( "Department" ).RemoveAll();
			}
			else
				throw new ApplicationException("����������� ��� ������� - " + helperDepartment.TypeName);
			
			// ������ �� ��������� (���� ����� ������)
			if ( Guid.Empty != helperPosition.ObjectID )
				helperEmployee.SetPropScalarRef( "Position", "Position", helperPosition.ObjectID );
			else
				// � ��������� ������ ������� ������ �������� - � �� ����� �������� NULL
				helperEmployee.PropertyXml("Position").RemoveAll();


			// ������� ���������, ������ ������� �� ������ ������������ � ��:
			helperEmployee.DropPropertiesXml( "WorkBeginDate", "ExternalRefID", "TemporaryDisability" );

			
			// ���������� ������ ����� �������� ������������, � ������ ����� 
			// "�������" ����������; ��� ���������� ��� ����������� ���������
			// �����������, �������� �/� ���������. 
			// ���� ��� ���� ��� ���������� � ��� ����� ���� "�� �������� �������
			// ���������", �� � IT6 ��� ����� ��������� �������������� "�������"
			// ���������� ��� ���� ���������; ��� ������ ����������� � �����������
			// �������� ���������, ������� ����� ������� ����� ����� ������ ������
			// ����������, � ��� �� ���������� �� (�.�. post-call ���������)
            if (bHasNoMessageFlag)
            {
                ObjectOperationHelper.SaveComplexDatagram(
                    new ObjectOperationHelper[] { helperSystemUser, helperEmployee },
                    new XObjectIdentity(helperEmployee.TypeName, helperEmployee.ObjectID),
                    "ForceUnsubscribeEmployee"
                );
            }
            else
            {
                ObjectOperationHelper.SaveComplexDatagram( 
				    new ObjectOperationHelper[]{ helperSystemUser, helperEmployee }
			    );
            }
			
		}

		
		#endregion
        #region ������, ������������ ��� ������������� ����������� "���������"

        /// <summary>
        /// ���������� ������ ���� ������� ����������� "���������", 
        /// ��������������� � ������� Incident Tracker
        /// </summary>
        /// <returns></returns>
        [WebMethod(Description = @"���������� ������ ���� ������� ����������� ""���������"", ��������������� � ������� Incident Tracker")]
        public XmlDocument GetUserPosition()
        {
            // �����a���� ������ � ���� XML-��������� ���������� ������� (� �������
            // �������� ������ ����������� ������ ������ ��� ����� �������; �������
            // �������� ����� ��������):
            //		<Root>
            //			<position
            //				ObjectID="..."
            //				Name="..."
            //				ObjectGUID="..."
            //				Flags="..."
            //			>
            //		</Root>
            return ObjectOperationHelper.ExecAppDataSourceSpecial("SyncNSI-GetList-Positions", null, "position");
        }


        /// <summary>
        /// ��������� ����� �������� ��������� � ���������� "���������", 
        /// �������������� � ������� Incident Tracker
        /// </summary>
        /// <param name="Name">�������� ���������</param>
        /// <param name="Flags">�����</param>
        /// <param name="ObjectGUID">GUID ���������</param>
        /// <returns>������������� ����������� ������</returns>
        /// <remarks>
        /// ��������: �������� ��������� Flags ����� ������������ - 
        /// � ������� Incident Tracker ������ 6 ��������������� ����� ���
        /// </remarks>
        [WebMethod(Description = @"��������� ����� �������� ��������� � ���������� ""���������"", �������������� � ������� Incident Tracker")]
        public int InsertPositionITracker(string Name, int Flags, out string ObjectGUID)
        {
            // ������� ��������������� ������; � �������� �����������
            // ��������� ���������� ������ ������� ���� "�������"
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Position");
            helper.LoadObject();

            // ������������� ����������� �������� ������� ������ �������,
            // ���������� ���������� ������������� (����� �� - ObjectGUID):
            // ��������: �������� ��������� Flags ����� ������������ - 
            // � ������� Incident Tracker ������ 6 ��������������� ����� ���
            helper.SetPropValue("Name", XPropType.vt_string, Name);
            // ... � ���������� ������ �������
            helper.SaveObject();
            ObjectGUID = helper.ObjectID.ToString();

            // ������������ ������ ��� ��� - ��� ��� ������������ � ��
            helper.LoadObject();
            // ... ��� ����, ��� �� �������� "�������" �������������:
            return (int)helper.GetPropValue("ExternalRefID", XPropType.vt_i4);
        }


        /// <summary>
        /// ��������� �������� ��������� � ����������� "���������", 
        /// �������������� � ������� Incident Tracker
        /// </summary>
        /// <param name="ObjectID">������������� ����������� ������</param>
        /// <param name="Name">�������� ���������</param>
        /// <param name="Flags">�����</param>
        /// <remarks>
        /// ��������: �������� ��������� Flags ����� ������������ - 
        /// � ������� Incident Tracker ������ 6 ��������������� ����� ���
        /// </remarks>
        [WebMethod(Description = @"��������� �������� ��������� � ����������� ""���������"", �������������� � ������� Incident Tracker")]
        public void UpdatePositionITracker(int ObjectID, string Name, int Flags)
        {
            // ������� ��������������� ������; � �������� �����������
            // ��������� ���������� ���������� ������� ���� "�������"
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Position");

            XParamsCollection keyPropCollection = new XParamsCollection();
            keyPropCollection.Add("ExternalRefID", Int32.Parse(ObjectID.ToString()));
            helper.LoadObject(keyPropCollection);

            // ������������� ����������� �������� ������� �������:
            // ��������: �������� ��������� Flags ����� ������������ - 
            // � ������� Incident Tracker ������ 6 ��������������� ����� ���
            helper.SetPropValue("Name", XPropType.vt_string, Name);

            // ������� �� ���������� ��� ������ �������, �� ����������� Name
            // - ��� �������� ����������� �� ������:
            helper.DropPropertiesXmlExcept("Name");

            // ���������� ����������� ������ �������
            helper.SaveObject();
        }


        #endregion


        #region ������, ������������ ��� ������������� ����������� "�����������"
		
		/// <summary>
		/// ���������� ������ ���� ������� ����������� "�����������", 
		/// ��������������� � ������� Incident Tracker
		/// </summary>
		/// <returns>
		/// ������ ���� ����������� �� ITracker � ���� XML ���������
		/// </returns>
		[WebMethod (Description=@"���������� ������ ���� ������� ����������� ""�����������"", ��������������� � ������� Incident Tracker")]
		public XmlDocument GetOrganizations() 
		{
			// �����a���� ������ � ���� XML-��������� ���������� ������� (� �������
			// �������� ������ ����������� ������ ������ ��� ����� �����������; 
			// ������� �������� ����� ��������):
			//		<Root>
			//			<organization
			//				ObjectGUID="..."
			//				Parent="..."
			//				sName="..."
			//				Type="..."
			//				AccChiefGUID="..."
			//				ShortName="..."
			//				NavisionID="..."
			//			/>
			//		</Root>
			return ObjectOperationHelper.ExecAppDataSourceSpecial( "SyncNSI-GetList-Organizations", null, "organization" );
		}

		
		/// <summary>
		/// ���������� �������� ��������� �����������, �������������� � 
		/// ����������� "�����������" ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">id �����������</param>
		/// <returns>����������� �� ���� ITracker � ���� XML ���������</returns>
		[WebMethod (Description=@"���������� �������� ��������� �����������, �������������� � ����������� ""�����������"" ������� Incident Tracker")]
		public XmlDocument GetOrganization( Guid ObjectGUID ) 
		{
			// ��������� ��������������� ������, �������� ������ ��������� �����������
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// ��������� �������������� ������ � ���� XML-��������� ���������� ������� 
			// (������� �������� ����� ��������):
			//		<Root>
			//			<organization
			//				ObjectGUID="..."
			//				Parent="..."
			//				sName="..."
			//				Type="..."
			//				AccChiefGUID="..."
			//				ShortName="..."
			//				NavisionID="..."
			//			/>
			//		</Root>
			XmlDocument xmlResult = new XmlDocument();
			XmlElement xmlRoot = xmlResult.CreateElement( "Root" );

			xmlResult.AppendChild( xmlRoot );
			xmlRoot = (XmlElement)xmlRoot.AppendChild( xmlResult.CreateElement("organization" ) );
			
			// ���������� ������, �������������� � ����������, � �������������� XML;
			// ...������� ��� ����������� ��������:
			xmlRoot.SetAttribute( "ObjectGUID", helper.ObjectID.ToString()	);
			xmlRoot.SetAttribute( "Type", "1" ); // NB! ���� - ������ ���������

			if (helper.PropertyXml("Name").InnerText.Length > 0)
				xmlRoot.SetAttribute( "sName", helper.GetPropValue("Name",XPropType.vt_string).ToString() );
			if (helper.PropertyXml("ShortName").InnerText.Length > 0)
				xmlRoot.SetAttribute( "ShortName", helper.GetPropValue("ShortName",XPropType.vt_string).ToString() );
			if (helper.PropertyXml("ExternalID").InnerText.Length > 0)
				xmlRoot.SetAttribute( "NavisionID", helper.GetPropValue("ExternalID",XPropType.vt_string).ToString() );

			// ...������ - ��������� ������:
			XmlElement xmlRefElement = (XmlElement)(helper.PropertyXml("Parent").SelectSingleNode("Organization"));
			if ( null != xmlRefElement )
				xmlRoot.SetAttribute( "Parent", xmlRefElement.GetAttribute("oid") );

			xmlRefElement = (XmlElement)(helper.PropertyXml("Director").SelectSingleNode("Employee"));
			if ( null != xmlRefElement )
				xmlRoot.SetAttribute( "AccChiefGUID", xmlRefElement.GetAttribute("oid") );

			// ���������� ���������:
			return xmlResult;
		}

		
		/// <summary>
		/// ��������� ����� �������� ����������� � ���������� "�����������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="Name">��������</param>
		/// <param name="Type">���</param>
		/// <param name="ShortName">�������� ������������</param>
		/// <param name="NavisionID">������������� � Navision</param>
		/// <param name="AccChief">������������� ���������� - ��������� �������</param>
		/// <param name="ObjectGUID">ID ��������� �����������</param>
		[WebMethod (Description = @"��������� ����� �������� ����������� � ���������� ""�����������"", �������������� � ������� Incident Tracker")]
		public void CreateOrganization(
			string Name, 
			int Type, 
			string ShortName, 
			string NavisionID, 
			Guid AccChief, 
			out Guid ObjectGUID ) 
		{
			ObjectGUID = Guid.Empty;
			
			// ��������� ��������������� ������, ������� ������ ���������� ������ �������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			helper.LoadObject();

			// ��������� �������� �������; ������� - �����������:
			// (��� ���� - ���� - ���������� �������� ��������� Type)
			helper.SetPropValue( "Name", XPropType.vt_string, Name );
			helper.SetPropValue( "ShortName", XPropType.vt_string, ShortName );
			helper.SetPropValue( "ExternalID", XPropType.vt_string, NavisionID );
			// ���� ����� ������������� ���������� - ��������� �������, �� ��������� 
			// ��������������� ��������� ������:
			if (Guid.Empty!=AccChief)
				helper.SetPropScalarRef( "Director", "Employee", AccChief );

			// ������ �� ���������� ����, ������� �� ������ ������������:
			helper.DropPropertiesXml( 
				"Home",
				"Comment",
				"ExternalRefID" );

			// ��������� ������ ������:
			helper.SaveObject();

			// ���� ����� �� ���� ����� - �� ��� ������, ��� ������ ������� ����������
			// ������ "������" ��������� ������������� ���������� �������:
			ObjectGUID = helper.ObjectID;
		}


		/// <summary>
		/// ��������� �������� ����������� � ����������� "�����������", 
		/// �������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">ID �����������</param>
		/// <param name="Name">��������</param>
		/// <param name="Type">���</param>
		/// <param name="ShortName">�������� ������������</param>
		/// <param name="NavisionID">������������� � Navision</param>
		/// <param name="AccChief">������������� ���������� - ��������� �������</param>
		[WebMethod (Description=@"��������� �������� ����������� � ����������� ""�����������"", �������������� � ������� Incident Tracker")]
		public void UpdateOrganization(
			Guid ObjectGUID, 
			string Name, 
			int Type, 
			string ShortName, 
			string NavisionID, 
			Guid AccChief ) 
		{
			// ��������� ��������������� ������, �������� ������ ���������� �������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// ��������� ������ ����������� ��������� �������
			// (��� ���� - ���� - ���������� �������� ��������� Type)
			helper.SetPropValue( "Name", XPropType.vt_string, Name );
			helper.SetPropValue( "ShortName", XPropType.vt_string, ShortName );
			helper.SetPropValue( "ExternalID", XPropType.vt_string, NavisionID );

			// ���� ������������� ���������� - ��������� ������� �� �����, �������
			// ������ �������� Director: ��� ������ Storage ������� ������:
			if (Guid.Empty == AccChief)
				helper.PropertyXml("Director").RemoveAll();
			else
			{
				// ����������� ������ ��������:
				XmlElement xmlRefProp = (XmlElement)helper.PropertyXml("Director").SelectSingleNode("Employee");

				// ������ � ���������� ��� ������ - ������ ������ �������:
				if (null==xmlRefProp)
					helper.SetPropScalarRef( "Director", "Employee", AccChief );
				else
				{
					// �������� - ��������, ������������� ���������� � �� ���������:
					if ( AccChief.ToString().ToUpper() != xmlRefProp.GetAttribute("oid").ToUpper() )
						// ���������: ����������� ������ ������
						helper.SetPropScalarRef( "Director", "Employee", AccChief );
					else
						// �� ���������: ������� �������� ������ - Storage ������ ��������� �� �����
						helper.DropPropertiesXml( "Director" );
				}
			}

			// ������ �� ���������� ����, ������� �� ������ ������������:
			helper.DropPropertiesXml( 
				"Comment", 
				"Home", 
				"OwnTenderParticipant",
				"Parent", 
				"Children",
				"ExternalRefID",
				"RefCodeNSI"
			);
			// ��������� ������ ������:
			helper.SaveObject();
		}
		

		/// <summary>
		/// �������� ����������� ����������� �����������, ��� ��������� 
		/// ����������� �� ����������� "�����������", ��������������� 
		/// � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">ID �����������</param>
		/// <param name="ParentObjectGUID">ID ������������ �����������</param>
		[WebMethod (Description=@"�������� ����������� ����������� �����������, ��� ��������� ����������� �� ����������� ""�����������"", ��������������� � ������� Incident Tracker")]
		public void UpdateOrganizationParent( Guid ObjectGUID, Guid ParentObjectGUID ) 
		{
			// ��������� ��������������� ������, �������� ������ ���������� �������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// ���� ������������� ����������� ����������� �� �����, �������
			// ������ �������� Parent: ��� ������ Storage ������� ������:
			if (Guid.Empty == ParentObjectGUID)
				helper.PropertyXml("Parent").RemoveAll();
			else
			{
				// ����������� ������ ��������:
				XmlElement xmlRefProp = (XmlElement)helper.PropertyXml("Parent").SelectSingleNode("Organization");
				// ������ � ����������� ����������� ��� ������ - ������� ������:
				if (null==xmlRefProp)
					helper.SetPropScalarRef( "Parent", "Organization", ParentObjectGUID );
				else
				{
					// �������� - ��������, ������������� ����������� ����������� � �� ���������:
					if ( ParentObjectGUID.ToString().ToUpper() != xmlRefProp.GetAttribute("oid").ToUpper() )
						// ���������: ����������� ������ ������
						helper.SetPropScalarRef( "Parent", "Organization", ParentObjectGUID );
					else
						// �� ���������: ������� �������� ������ - Storage ������ ��������� �� �����
						helper.DropPropertiesXml( "Parent" );
				}
			}

			// ������ �� ���������� ��� ����, �� ����������� Parent - ��� ��� 
			// ������ �� ������ �����������:
			helper.DropPropertiesXmlExcept( "Parent" );
			// ��������� ������ ������:
			helper.SaveObject();
		}


		/// <summary>
		/// ������� ��������� �������� ����������� �� ����������� "�����������", 
		/// ��������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">id �����������</param>
		[WebMethod (Description=@"������� ��������� �������� ����������� �� ����������� ""�����������"", ��������������� � ������� Incident Tracker")]
		public void DeleteOrganization( Guid ObjectGUID ) 
		{
			// ��������� ��������������� ������, ������ ������ ���������� �������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.DeleteObject();
		}
        #endregion 

	
		#region ������ ��������� ������ ��� ����� ������-�������� "����� �������� �������"
		// ��������� ������, �� ���������� ����������� ������� � ���
		// ����������� � ������� �� ���������� - � ������� �������, ��������� ������
		
		#endregion

        #region ������, ������������ ��� ������������� ����������� "�������" (������� ����� ��������)

        /// <summary>
        /// ���������� ������ ���� ������� ����������� "�������", 
        /// ��������������� � ������� ����� ��������
        /// </summary>
        /// <returns>������ ���� �������� �� ���� ��������� ������� � ���� XML ���������</returns>
        [WebMethod(Description = @"���������� ������ ���� ������� ����������� ""�������"", ��������������� � ������� ����� ��������")]
        public XmlDocument GetBranches()
        {
            // �����a���� ������ � ���� XML-��������� ���������� ������� (� �������
            // �������� ������ ����������� ������ ������ ��� ����� �������; �������
            // �������� ����� ��������):
            //		<Root>
            //			<Branch
            //				ObjectID="..."
            //				ObjectGUID="..."
            //				Name="..."
            //				Rem="..."
            //			>
            //		</Root>
            return ObjectOperationHelper.ExecAppDataSourceSpecial("SyncNSI-GetList-Branches", null, "Branch");
        }
        #endregion
    }
}