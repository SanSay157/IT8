//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Configuration;
using System.Diagnostics;
using System.Text;
using System.Xml;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ��������� ������������� ���������������� ����������, ������������ ��� 
	/// ������ ������ �������� ������ �� ��������
	/// </summary>
	public class TrainingRequestProcessParams 
	{
		/// <summary>
		/// XPath-���� ��� ������ ���������� � ����� ������������, � ������ itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:business-process-methods/itws:on-training-request-process";

		#region �������� ���� - ������������� ������, ���������� � ������������
		
		/// <summary>
		/// ��������������� ������������� ds-������� "�����" (Folder): �����, 
		/// � ������� ����� ������ ��������, ��������������� ������ �� ��������
		/// </summary>
		public ObjectOperationHelper TargetFolder = ObjectOperationHelper.GetInstance( "Folder" );
		/// <summary>
		/// ��������������� ������������� ds-������� "��� ��������" (IncidentType):
		/// ��� ��� ���������, ���������������� ������ �� ��������
		/// </summary>
		public ObjectOperationHelper IncidentType = ObjectOperationHelper.GetInstance( "IncidentType" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���� ������������ � 
		/// ���������" (UserRoleInIncident): ����, ����������� ���������� 
		/// ���������� � ������� ���������, ���������������� ������ 
		/// </summary>
		public ObjectOperationHelper Role_Trained = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���� ������������ � 
		/// ���������" (UserRoleInIncident): ����, ����������� ����������-
		/// ��������� �� ��������, � ������� ���������, ���������������� ������
		/// </summary>
		public ObjectOperationHelper Role_Manager = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���.�������� ���������" 
		/// (IncidentProp): ����������� ���. �������� "����� ����� / ��������".
		/// ����������� ���. �������� ������ ���� �������� � ����������� ����
		/// ���������, ��������������� �������� IncidentType; ��� �����������
		/// �� ������ ������������� �������� - ��. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_CourseNumber = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���.�������� ���������" 
		/// (IncidentProp): ����������� ���. �������� "���� ������ ��������".
		/// ����������� ���. �������� ������ ���� �������� � ����������� ����
		/// ���������, ��������������� �������� IncidentType; ��� �����������
		/// �� ������ ������������� �������� - ��. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_CourseBeginningDate = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���.�������� ���������" 
		/// (IncidentProp): ����������� ���. �������� "��� ��������� �������".
		/// ����������� ���. �������� ������ ���� �������� � ����������� ����
		/// ���������, ��������������� �������� IncidentType; ��� �����������
		/// �� ������ ������������� �������� - ��. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_GoalStatus = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���.�������� ���������" 
		/// (IncidentProp): ����������� ���. �������� "����������� ��������".
		/// ����������� ���. �������� ������ ���� �������� � ����������� ����
		/// ���������, ��������������� �������� IncidentType; ��� �����������
		/// �� ������ ������������� �������� - ��. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_TrainingDirection = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���.�������� ���������" 
		/// (IncidentProp): ����������� ���. �������� "������� �����".
		/// ����������� ���. �������� ������ ���� �������� � ����������� ����
		/// ���������, ��������������� �������� IncidentType; ��� �����������
		/// �� ������ ������������� �������� - ��. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_TrainingCenter = ObjectOperationHelper.GetInstance( "IncidentProp" );

        /// <summary>
        /// ��������������� ������������� ds-������� "���.�������� ���������" 
        /// (IncidentProp): ����������� ���. �������� "������� �����".
        /// ����������� ���. �������� ������ ���� �������� � ����������� ����
        /// ���������, ��������������� �������� IncidentType; ��� �����������
        /// �� ������ ������������� �������� - ��. DelayLoad
        /// </summary>
        public ObjectOperationHelper Prop_Summ = ObjectOperationHelper.GetInstance("IncidentProp");
		
		#endregion
		
		#region �������� ���� - ������������� ������, ����������� � �������� �������������
		
		/// <summary>
		/// ��������� ���� "��������� ��������" (IncidentState) - ��������� 
		/// ��������� ��� ��������� ����, ������������ IncidentType.
		/// ��������� ������������� (helper); �� ������������ (IsLoaded=false);
		/// ����������� �� ��������� �������� ���� ��������� (��. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper EduIncident_StartState = ObjectOperationHelper.GetInstance( "IncidentState" );
		/// <summary>
		/// ��������� ��������� ��-���������; ����������� �� ��������� �������� 
		/// ���� ��������� (��. DelayLoaded)
		/// </summary>
		public IncidentPriority EduIncident_DefaultPriority = IncidentPriority.NORMAL;
		/// <summary>
		/// �����, ������������ �� ���������� ������� � ��������� ��� ����������
		/// - ��������� �� ��������. �������� ������������ �� ��������� �������� 
		/// ���� ���������, ��������������� IncidentType - ��. DelayLoad
		/// </summary>
		public int DefaultDuration_for_ManagerRole = 0;
		/// <summary>
		/// �����, ������������ �� ���������� ������� � ��������� ��� ����������
		/// - ������������. �������� ������������ �� ��������� �������� ���� 
		/// ���������, ��������������� IncidentType - ��. DelayLoad
		/// </summary>
		public int DefaultDuration_for_TrainedRole = 0;
		
		#endregion
		
		#region ���������� �������������
		
		/// <summary>
		/// ������� ���������� ���������� ��������/�������� ������
		/// </summary>
		protected bool m_bIsLoaded = false;
			
		/// <summary>
		/// ����� ���������� ��������/�������� ������
		/// </summary>
		internal void DelayLoad() 
		{
			if (m_bIsLoaded)	
				return;
				
			// �������� ��������� ������:
			TargetFolder.CheckExistence( true );
			Prop_CourseNumber.CheckExistence( true );
			Prop_CourseBeginningDate.CheckExistence( true );
			Prop_GoalStatus.CheckExistence( true );
			Prop_TrainingDirection.CheckExistence( true );
			Prop_TrainingCenter.CheckExistence( true );
			// ... ������ ��� ���� ��������� � ����� ��������� ���������, 
			// ��� �� ������� ����� ���������� ��������:
			IncidentType.LoadObject( new string[]{ "Props","States" } );
			Role_Trained.LoadObject( new string[]{ "IncidentType" } );
			Role_Manager.LoadObject( new string[]{ "IncidentType" } );
				
			// �������� ����������� ������������:
			// ... ��� ��������� ��� ����� ������ ��������� � �������� � ������������:
			ObjectOperationHelper helperType;
			helperType = Role_Trained.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
					"��� ��������� \"{0}\" ��� �������� ���� itws:role-for-trained( id=\"{1}\" ) �� ������������� ���� ��������� itws:incident-type( id=\"{2}\" )",
					helperType.ObjectID.ToString(),
					Role_Trained.ObjectID.ToString(),
					IncidentType.ObjectID.ToString()
				));
			helperType = Role_Manager.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
					"��� ��������� \"{0}\" ��� �������� ���� itws:role-for-manager( id=\"{1}\" ) �� ������������� ���� ��������� itws:incident-type( id=\"{2}\" )",
					helperType.ObjectID.ToString(),
					Role_Manager.ObjectID.ToString(),
					IncidentType.ObjectID.ToString()
				));
				
			// ... ��� ���. �������� ������ ���� ������� � ���� ���������:
			XmlElement xmlProps = IncidentType.PropertyXml("Props");
			checkAuxPropExistence( xmlProps, "prop-for-course-number", Prop_CourseNumber );
			checkAuxPropExistence( xmlProps, "prop-for-course-beginning-date", Prop_CourseBeginningDate );
			checkAuxPropExistence( xmlProps, "prop-for-goal-status", Prop_GoalStatus );
			checkAuxPropExistence( xmlProps, "prop-for-training-direction", Prop_TrainingDirection );
			checkAuxPropExistence( xmlProps, "prop-for-training-center", Prop_TrainingCenter );
            checkAuxPropExistence(xmlProps, "prop-for-education-sum", Prop_Summ);

			// ��������� ������ ��� ��� �������� ��������� ������:
			// ... ��������� ��������� �� ���������:
			EduIncident_DefaultPriority = (IncidentPriority)IncidentType.GetPropValue( "DefaultPriority",XPropType.vt_i2 );
			// ... ��������� ��������� ���������; ������������� ������� ��������
			// ��������� XPath-��������, �������� �� ��, ��� �������� ����������:
			XmlElement xmlDefaultState = (XmlElement)IncidentType.PropertyXml("States").SelectSingleNode( "IncidentState[IsStartState='1']" );
			if (null==xmlDefaultState)
				throw new InvalidOperationException( String.Format(
					"��� ���������� ���� ��������� (id={0}) ������������ ��������� ���������",
					IncidentType.ObjectID.ToString()
				));
			EduIncident_StartState.ObjectID = new Guid( xmlDefaultState.GetAttribute("oid") );
			// ...��������������� ����� ��� ���������, �� ���������:
			DefaultDuration_for_ManagerRole = (int)Role_Manager.GetPropValue( "DefDuration", XPropType.vt_i4 );
			// ...��������������� ����� ��� ����������, �� ���������:
			DefaultDuration_for_TrainedRole = (int)Role_Trained.GetPropValue( "DefDuration", XPropType.vt_i4 );
				
			m_bIsLoaded = true;
		}

		
		/// <summary>
		/// ���������� ��������������� ����� ��������
		/// </summary>
		/// <param name="xmlProps"></param>
		/// <param name="sPropName"></param>
		/// <param name="propHelper"></param>
		private void checkAuxPropExistence( XmlElement xmlProps, string sPropName, ObjectOperationHelper propHelper ) 
		{
			XmlNode xmlProp = xmlProps.SelectSingleNode( String.Format( "IncidentProp[@oid='{0}']", propHelper.ObjectID.ToString() ) );
			if (null == xmlProp)
				throw new InvalidOperationException( String.Format( 
					"��� ��������� itws:incident-type( id=\"{0}\" ) �� �������� ����������� ���. �������� {1}( id=\"{2}\" )",
					IncidentType.ObjectID,
					sPropName,
					propHelper.ObjectID
				));
		}
		
		
		#endregion
	}
	
	/// <summary>
	/// ��������� ������������� ���������������� ����������, ������������ ��� 
	/// ������ ������� �������������� � �������� CMDB (� ���������, ��� ��������
	/// ������ ��������� - ������ �� ���������)
	/// </summary>
	public class CmdbChangeRequestProcessParams 
	{
		/// <summary>
		/// XPath-���� ��� ������ ���������� � ����� ������������, � ������ itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:cmdb-process-methods/itws:on-change-request-process";

		#region �������� ���� - ������������� ������, ���������� � ������������

		/// <summary>
		/// ��������������� ������������� ds-������� "��� ��������" (IncidentType):
		/// ��� ��� ���������, ���������������� ������ �� ���������
		/// </summary>
		public ObjectOperationHelper IncidentType = ObjectOperationHelper.GetInstance( "IncidentType" );
		/// <summary>
		/// ��������������� ������������� ds-������� "���� ������������ � 
		/// ���������" (UserRoleInIncident): ���� �����������, ����������� 
		/// ���������� � ������� ��������� - ������ �� ���������
		/// </summary>
		public ObjectOperationHelper Role_Observer = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		
		#endregion		

		#region �������� ���� - ������������� ������, ����������� � �������� �������������

		/// <summary>
		/// ��������� ���� "��������� ��������" (IncidentState) - ��������� 
		/// ��������� ��� ��������� ����, ������������ IncidentType.
		/// ��������� ������������� (helper); �� ������������ (IsLoaded=false);
		/// ����������� �� ��������� �������� ���� ��������� (��. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper ChangeIncident_StartState = ObjectOperationHelper.GetInstance( "IncidentState" );
		/// <summary>
		/// ��������� ��������� ��-���������; ����������� �� ��������� �������� 
		/// ���� ��������� (��. DelayLoaded)
		/// </summary>
		public IncidentPriority ChangeIncident_DefaultPriority = IncidentPriority.NORMAL;
		/// <summary>
		/// �����, ������������ �� ���������� ������� � ��������� ��� ����������
		/// - �����������. �������� ������������ �� ��������� �������� ���� 
		/// ���������, ��������������� IncidentType - ��. DelayLoad
		/// </summary>
		public int DefaultDuration_for_ObserverRole = 0;
		/// <summary>
		/// ��������� ���� "��� ������� ������" (ExternalLinkType), ������������
		/// ������� ������ � ��������� ��� URL - ������������ ��� �����������
		/// ��������� ���� ������ � ���������.
		/// ��������� ������������� (helper); ����������� �������� (��. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper LinkType_URL = ObjectOperationHelper.GetInstance( "ExternalLinkType" );

		#endregion

		#region ���������� �������������
		
		/// <summary>
		/// ������� ���������� ���������� ��������/�������� ������
		/// </summary>
		protected bool m_bIsLoaded = false;
			
		/// <summary>
		/// ����� ���������� ��������/�������� ������
		/// </summary>
		internal void DelayLoad() 
		{
			if (m_bIsLoaded)	
				return;
				
			// ������ ��� ���� ��������� � ���� ��������� ���������, 
			// ��� �� ������� ����� ���������� ��������:
			IncidentType.LoadObject( new string[]{ "Props","States" } );
			Role_Observer.LoadObject( new string[]{ "IncidentType" } );
				
			// �������� ����������� ������������:
			// ... ��� ��������� ��� ����� ������ ��������� � �������� � ������������:
			ObjectOperationHelper helperType;
			helperType = Role_Observer.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
						"��� ��������� \"{0}\" ��� �������� ���� itws:role-for-observer( id=\"{1}\" ) �� ������������� ���� ��������� itws:incident-type( id=\"{2}\" )",
						helperType.ObjectID.ToString(),
						Role_Observer.ObjectID.ToString(),
						IncidentType.ObjectID.ToString()
					));

			// ��������� ������ ��� ��� �������� ��������� ������:
			// ... ��������� ��������� �� ���������:
			ChangeIncident_DefaultPriority = (IncidentPriority)IncidentType.GetPropValue( "DefaultPriority",XPropType.vt_i2 );
			// ... ��������� ��������� ���������; ������������� ������� ��������
			// ��������� XPath-��������, �������� �� ��, ��� �������� ����������:
			XmlElement xmlDefaultState = (XmlElement)IncidentType.PropertyXml("States").SelectSingleNode( "IncidentState[IsStartState='1']" );
			if (null==xmlDefaultState)
				throw new InvalidOperationException( String.Format(
						"��� ���������� ���� ��������� (id={0}) ��������� ��������� �� ����������",
						IncidentType.ObjectID.ToString()
					));
			ChangeIncident_StartState.ObjectID = new Guid( xmlDefaultState.GetAttribute("oid") );
			// ...��������������� ����� ��� �����������, �� ���������:
			DefaultDuration_for_ObserverRole = (int)Role_Observer.GetPropValue( "DefDuration", XPropType.vt_i4 );
				
			// �������� ������ �������� � �� ��������� ��� ������� ������ 
			// ��� ����������� URL, �� �� ������:
			XParamsCollection keys = new XParamsCollection();
			keys.Add( "ServiceType", (int)ServiceSystemType.URL );
			LinkType_URL.LoadObject( keys );
			
			m_bIsLoaded = true;
		}

		
		#endregion
	}
	
	/// <summary>
	/// �����, �������������� ��������� ������������� ���������������� ������ 
	/// "������" ������� ��������� ������ �� ���������, CommonService
	/// </summary>
	public class ExpensesProcessPrarms
	{
		/// <summary>
		/// XPath-���� ��� ������ ���������� � ����� ������������, � ������ itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:expenses-process-methods/itws:get-employees-expenses-process";
		
		
		/// <summary>
		/// ������ � �������� ��������������� �������������, ���������� ������� 
		/// �� ������������ ����� � Incident Tracker
		/// </summary>
		private string m_sEmpExpenses_ExceptedDepsList = null;
		
		/// <summary>
		/// ������ � �������� ��������������� �������������, ���������� ������� 
		/// �� ������������ ����� � Incident Tracker
		/// </summary>
		public string EmpExpenses_ExceptedDepsList
		{
			get { return m_sEmpExpenses_ExceptedDepsList; }
		}
		
		/// <summary>
		/// ������������������� �����������
		/// ��������� ��-�������� ������ � ����������� ��������������, ���� 
		/// ��� ��������� � ������������ � ��������� ����������� ������������
		/// </summary>
		/// <param name="xmlList_ExceptedDepsList">
		/// �������� ���������� itws:department �� ������ itws:excepted-departments.
		/// ����� ���� null ��� ������.
		/// </param>
		public ExpensesProcessPrarms( XmlNodeList xmlList_ExceptedDepsList ) 
		{
			StringBuilder sbExceptedDepsList = new StringBuilder();
			StringBuilder sbExceptedDepsWithNestedList = new StringBuilder();
			if ( null != xmlList_ExceptedDepsList && 0!=xmlList_ExceptedDepsList.Count )
			{
				// ������� ���� ��������� ������������; ����������� ��� ������ - 
				// �������� ��������������� ������������� "��� ����" � ��������
				// ��������������� �������������, ��� ������� ��� ���� ����������
				// �����������:
				foreach( XmlElement xmlExceptedDep in xmlList_ExceptedDepsList  )
				{
					if ( null==xmlExceptedDep )
						continue;
					string sDepID = xmlExceptedDep.GetAttribute( "id" );
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sDepID, "������������� ������������� (" + sDepID + ")" );
					
					if ( String.Empty == xmlExceptedDep.GetAttribute("include-nested") )
						sbExceptedDepsList.Append( sDepID ).Append( "," );
					else
						sbExceptedDepsWithNestedList.Append( sDepID ).Append( "," );
				}
				
				// ���� ���� �����, ��� ������� ���� ���������� �����������, �� 
				// ��������� �������� �� ����������: ��������� ������ � �������:
				if ( sbExceptedDepsWithNestedList.Length > 0 )
				{
					XParamsCollection dsParams = new XParamsCollection();
					sbExceptedDepsWithNestedList.Length -= 1;
					dsParams.Add( "SrcList", sbExceptedDepsWithNestedList.ToString() );
					
					object oResult = ObjectOperationHelper.ExecAppDataSourceScalar( "CommonService-INIT-ExpandDepsIDsWithNested", dsParams );
					if ( null!=oResult && DBNull.Value != oResult )
						sbExceptedDepsList.Append( oResult.ToString() ).Append( "," );
				}
			}
			
			// �������� ������
			if ( sbExceptedDepsList.Length > 0 )
				sbExceptedDepsList.Length -= 1;
			m_sEmpExpenses_ExceptedDepsList = sbExceptedDepsList.ToString();
		}
	}
	
	/// <summary>
	/// �����, �������������� ��������� ������������� ���������������� ������ 
	/// "������" ������� �������������� � �������� ���������, CommonService
	/// </summary>
	public class CommonServiceConfigParams 
	{
		/// <summary>
		/// ��������� ������������� ���������������� ������ ������ 
		/// itws:business-process-methods/itws:on-training-request-process
		/// </summary>
		private TrainingRequestProcessParams m_TrainingRequestProcessParams = null;
		/// <summary>
		/// ��������� ������������� ���������������� ������ ������ 
		/// itws:business-process-methods/itws:on-change-request-process
		/// </summary>
		private CmdbChangeRequestProcessParams m_CmdbChangeRequestProcessParams = null;
		/// <summary>
		/// ��������� ������������� ���������������� ������ ������ 
		/// itws:expenses-process-methods/itws:get-employees-expenses-process
		/// </summary>
		private ExpensesProcessPrarms m_ExpensesProcessPrarms = null;
		
		/// <summary>
		/// ���������� ��������� ������������� ���������������� ������ ������ 
		/// itws:business-process-methods/itws:on-training-request-process
		/// </summary>
		public TrainingRequestProcessParams TrainingRequestProcess 
		{
			get
			{
				if (null==m_TrainingRequestProcessParams)
					throw new ApplicationException( "���������������� ������, ����������� ��� ������������ ������ �������� ������ �� ��������, �� ����������!" );
				m_TrainingRequestProcessParams.DelayLoad();
				return m_TrainingRequestProcessParams;
			}
		}

		
		/// <summary>
		/// ���������� ��������� ������������� ���������������� ������ ������ 
		/// itws:business-process-methods/itws:on-change-request-process
		/// </summary>
		public CmdbChangeRequestProcessParams ChangeRequestProcess 
		{
			get
			{
				if (null==m_CmdbChangeRequestProcessParams)
					throw new ApplicationException( "���������������� ������, ����������� ��� ������������ ������ �������� ������ �� ��������� ������� CMDB, �� ����������!" );
				m_CmdbChangeRequestProcessParams.DelayLoad();
				return m_CmdbChangeRequestProcessParams;
			}
		}
		
		
		/// <summary>
		/// ���������� ��������� ������������� ���������������� ������ ������ 
		/// itws:expenses-process-methods/itws:get-employees-expenses-process
		/// </summary>
		public ExpensesProcessPrarms ExpensesProcess 
		{
			get
			{
				if (null==m_ExpensesProcessPrarms)
					throw new ApplicationException( "���������������� ������, ����������� ��� ������������ ������� ��������� ������ �� ���������, �� ����������!" );
				return m_ExpensesProcessPrarms;
			}
		}
		

		/// <summary>
		/// ����������� �������;
		/// �������������� ������ �� ��������� XML-������ ����������������� �����
		/// </summary>
		/// <param name="config"></param>
		internal CommonServiceConfigParams( ServiceConfig config ) 
		{
			XmlElement xmlSvcElement = (XmlElement)config.SelectNode( "itws:common-service" );
			if (null==xmlSvcElement) 
				throw new ConfigurationErrorsException( String.Format( 
					"{0}: ������ ���������������� ���������� ������ ������� (������� itws:common-service) � ����� ������������ ���", 
					ServiceConfig.ERR_INCORRECT_CONFIG_DATA 
				));
			
			#region #1: ������ ��� ������� �������� ������ �� ��������
			
			XmlElement xmlElement = (XmlElement)xmlSvcElement.SelectSingleNode( TrainingRequestProcessParams.DEF_Config_XPath, config.NSManager );
			if (null!=xmlElement)
			{
				m_TrainingRequestProcessParams = new TrainingRequestProcessParams();
				
				// ...������� itws:target-folder - ������� �����	
                XmlElement xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:target-folder", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:target-folder �� �����" );
				m_TrainingRequestProcessParams.TargetFolder.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:incident-type - ��� ���������
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:incident-type", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:incident-type �� �����" );
				m_TrainingRequestProcessParams.IncidentType.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:role-for-trained - ���� ��� ����������
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-trained", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:role-for-trained �� �����" );
				m_TrainingRequestProcessParams.Role_Trained.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:role-for-manager - ���� ��� ���������
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-manager", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:role-for-manager �� �����" );
				m_TrainingRequestProcessParams.Role_Manager.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:prop-for-course-number - ��� ���.��������, "����� �����"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-course-number", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-course-number �� �����" );
				m_TrainingRequestProcessParams.Prop_CourseNumber.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:prop-for-course-beginning-date - ��� ���.��������, "���� ������ ��������"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-course-beginning-date", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-course-beginning-date �� �����" );
				m_TrainingRequestProcessParams.Prop_CourseBeginningDate.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:prop-for-goal-status - ��� ���. ��������, "������� ������"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-goal-status", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-goal-status �� �����" );
				m_TrainingRequestProcessParams.Prop_GoalStatus.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:prop-for-training-direction - ��� ���. ��������, "����������� ��������"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-training-direction", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-training-direction �� �����" );
				m_TrainingRequestProcessParams.Prop_TrainingDirection.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:prop-for-training-center - ��� ���. ��������, "����� ��������"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-training-center", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-training-center �� �����" );
				m_TrainingRequestProcessParams.Prop_TrainingCenter.ObjectID = new Guid( xmlParam.GetAttribute("id") );

                // ...������� itws:prop-for-training-center - ��� ���. ��������, "����� ��������"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-education-sum", config.NSManager);
                if (null == xmlParam) throw new ApplicationException("�������� itws:prop-for-education-sum �� �����");
                m_TrainingRequestProcessParams.Prop_Summ.ObjectID = new Guid(xmlParam.GetAttribute("id"));
			}
			#endregion

			#region #2: ������ ��� ������� �������� �������������� � CMDB

            xmlElement = (XmlElement)xmlSvcElement.SelectSingleNode(CmdbChangeRequestProcessParams.DEF_Config_XPath, config.NSManager);
			if (null!=xmlElement)
			{
				m_CmdbChangeRequestProcessParams = new CmdbChangeRequestProcessParams();
				
				// ...������� itws:incident-type - ��� ���������
                XmlElement xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:incident-type", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:incident-type �� �����" );
				m_CmdbChangeRequestProcessParams.IncidentType.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...������� itws:role-for-trained - ���� ��� ����������
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-observer", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("�������� itws:role-for-observer �� �����" );
				m_CmdbChangeRequestProcessParams.Role_Observer.ObjectID = new Guid( xmlParam.GetAttribute("id") );
			}
			#endregion
			
			#region #3: ������ ��� ������� ��������� ������ ��������

            xmlElement = (XmlElement)xmlSvcElement.SelectSingleNode(ExpensesProcessPrarms.DEF_Config_XPath, config.NSManager);
			if ( null == xmlElement )
				m_ExpensesProcessPrarms = new ExpensesProcessPrarms( null );
			else
				m_ExpensesProcessPrarms = new ExpensesProcessPrarms(
                    xmlElement.SelectNodes("itws:excepted-departments/itws:department", config.NSManager));
			
			#endregion
		}
	}		
}