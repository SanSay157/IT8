//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.IO;
using System.Xml;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ������ - ��������� ���������� ���������������� ������ ��������
	/// </summary>
	public class ServiceConfig : XConfigurationFile
	{
		/// <summary>
		/// ������������ ����� ��� �������� ���������� ������������ 
		/// (appSettings) � ����� ������������ ���������� (Web|App.Config),
		/// ��������� ������������ ��������� ����� ������������ ��� Web Service
		/// </summary>
		public readonly static string DEF_APPCONFIG_KEYNAME = "IT-WS-ConfigFileName";
		/// <summary>
		/// �������� ������ ������� ���� ��� ����������� ����������������� ����� ��������
		/// </summary>
		public const string ERR_UNDEFINED_CONFIG = "�� ���������� ������������ ����������� ����������������� ����� ��������: �� ������ �������� ��� �������� \"{0}\"";
		/// <summary>
		/// ������ ������������ ������ � ���������������� �����
		/// </summary>
		public const string ERR_INCORRECT_CONFIG_DATA = "������ � ������� ���������������� ������ ��������";
		
		#region ���������� ���������� ������ 

		/// <summary>
		/// ���� � ��������� ����������������� ����� ����������
		/// </summary>
		private string m_sConfigFileName;
		/// <summary>
		/// ������-��������� ds-������� ���� "�����������", ��������������� ������ 
		/// "�����������" �����������
		/// </summary>
		private ObjectOperationHelper m_helperOwnOrganization = null;
		/// <summary>
		/// ������-��������� ds-������� ���� "��� ��������� ������" (���������� 
		/// ���������� ������� IT), ��������������� ������ ��� ���� "������� �������"
		/// </summary>
		private ObjectOperationHelper m_helperExternalProjectsActivityType = null;
		/// <summary>
		/// ������-��������� ds-������� ���� "��� ��������� ������" (���������� 
		/// ���������� ������� IT), ��������������� ������ ��� ���� "�������-����������"
		/// </summary>
		private ObjectOperationHelper m_helperPresaleProjectsActivityType = null;
        /// <summary>
        /// ������-��������� ds-������� ���� "��� ��������� ������" (���������� 
        /// ���������� ������� IT), ��������������� ������ ��� ���� "��������/�������������� �������"
        /// </summary>
        private ObjectOperationHelper m_helperPilotProjectsActivityType = null;

        /// <summary>
        /// ������-��������� ds-������� ���� "��� ��������� ������" (���������� 
        /// ���������� ������� IT), ��������������� ������ ��� ���� "��������� �����������"
        /// </summary>
        private ObjectOperationHelper m_helperTenderProjectsActivityType = null;
		/// <summary>
		/// ������ - ��������� ����� ����������� ������, �������� ��� ������������ 
		/// � ������� ���, � �����. ���������� ������, ����������� ��� ������������
		/// � ������� IT
		/// </summary>
		private UserFlagsToRolesMap m_rolesMap = new UserFlagsToRolesMap();
		/// <summary>
		/// ������, �������������� ���������������� ��������� ��� "������" 
		/// ������� CommonService � ��������� ����
		/// </summary>
		private CommonServiceConfigParams m_commonServiceParams = null;
        /// <summary>
        /// ��������� ��������������� ��������� �����,������������� �� ��������� ����� �����������
        /// </summary>
        private ArrayList m_defaultSystemRoles = new ArrayList();

		#endregion

		/// <summary>
		/// ���������� ������-��������� ds-������� ���� "�����������", ��������������� 
		/// ������ "�����������" �����������; �������� ������� �������� � ���������� 
		/// ����� ������������
		/// </summary>
		public ObjectOperationHelper OwnOrganization 
		{
			get { return m_helperOwnOrganization; }
		}

		/// <summary>
		/// ���������� ������-��������� ds-������� ���� "��� ��������� ������" 
		/// (���������� ���������� ������� IT), ��������������� ������ ��� 
		/// ���� "������� �������". �������� ������� �������� � ���������� 
		/// ����� ������������
		/// </summary>
		public ObjectOperationHelper ExternalProjectsActivityType 
		{
			get { return m_helperExternalProjectsActivityType; }
		}
		/// <summary>
		/// ���������� ������-��������� ds-������� ���� "��� ��������� ������" 
		/// (���������� ���������� ������� IT), ��������������� ������ ��� 
		/// ���� "�������-����������" (������� �� ������� ������������-presale)
		/// �������� ������� �������� � ���������� ����� ������������.
		/// </summary>
		public ObjectOperationHelper PresaleProjectsActivityType 
		{
			get { return m_helperPresaleProjectsActivityType; }
		}

        /// <summary>
        /// ���������� ������-��������� ds-������� ���� "��� ��������� ������" 
        /// (���������� ���������� ������� IT), ��������������� ������ ��� 
        /// ���� ������
        /// �������� ������� �������� � ���������� ����� ������������.
        /// </summary>
        public ObjectOperationHelper TenderProjectsActivityType
        {
            get { return m_helperTenderProjectsActivityType; }
        }
        /// <summary>
        /// ���������� ������-��������� ds-������� ���� "��� ��������� ������" 
        /// (���������� ���������� ������� IT), ��������������� ������ ��� 
        /// ���� "��������/�������������� �������" 
        /// �������� ������� �������� � ���������� ����� ������������.
        /// </summary>
        public ObjectOperationHelper PilotProjectsActivityType
        {
            get { return m_helperPilotProjectsActivityType; }
        }
		/// <summary>
		/// ���������� ������ - ��������� ����� ����������� ������, �������� ��� 
		/// ������������ � ������� ���, � �����. ���������� ������, ����������� ��� 
		/// ������������ � ������� IT
		/// </summary>
		public UserFlagsToRolesMap RolesMap 
		{
			get { return m_rolesMap; }
		}

		/// <summary>
		/// ���������� ������, �������������� ���������������� ��������� ��� 
		/// "������" ������� CommonService � ��������� ����
		/// </summary>
		public CommonServiceConfigParams CommonServiceParams 
		{
			get { return m_commonServiceParams; }
		}
		/// <summary>
		/// ���������� ��������� ��������������� ��������� �����, ������������� ������ ���������� �� ���������
		/// </summary>
	    public ArrayList DefaultSystemRoles
	    {
            get { return m_defaultSystemRoles; }
	    }
		
		#region ���������� ������� Singleton

		/// <summary>
		/// ����������� ��������� ������� ��������� ������������
		/// </summary>
		private static ServiceConfig m_Instance = null;
		
		/// <summary>
		/// ��������� ������������ �������
		/// </summary>
		public static ServiceConfig Instance 
		{
			get 
			{
				if (null==m_Instance)
					m_Instance = new ServiceConfig( null );
				return m_Instance;
			}
		}

		
		#endregion

		/// <summary>
		/// ������ ������������ ��������, � ������� �������� ���� ������������ 
		/// ���������� (Web.Config ��� App.Config)
		/// </summary>
		public static string ApplicationBasePath 
		{
			get { return AppDomain.CurrentDomain.SetupInformation.ApplicationBase; }
		}

		/// <summary>
		/// ������ ������������ ��������, � ������� ����������� ����������
		/// ���������������� ���� �������� 
		/// </summary>
		public string BaseConfigPath 
		{
			get { return Path.GetDirectoryName(m_sConfigFileName); }
		}

		/// <summary>
		/// ������ ������������ ��������� ����������� ����������������� ����� ��������
		/// </summary>
		public string BaseConfigFileName 
		{
			get { return m_sConfigFileName; }
		}

		
		/// <summary>
		/// ����������� ��� �����.
		/// </summary>
		/// <param name="sFileName">��� �����</param>
		/// <param name="sBaseDirectory">�������, ������������ �������� �������� ����</param>
		/// <returns>������ ��� �����</returns>
		/// <exception cref="FileNotFoundException">���� ���� �� ����������</exception>
		internal static string GetFullPath( string sFileName, string sBaseDirectory ) 
		{
			// ������ ��� �����
			string sFullFileName;

			if ( Path.IsPathRooted(sFileName) )
				sFullFileName = sFileName;
			else
				sFullFileName = Path.Combine( sBaseDirectory, sFileName );

			if ( !File.Exists(sFullFileName) )
				throw new FileNotFoundException( "���� �� ������", Path.GetFileName(sFullFileName) );

			return sFullFileName;
		}

		
		/// <summary>
		/// ���������� ��� ��������� ����� ������������ ����������, ��� ��� 
		/// ������� � ���������� "����������" ����������������� ����� 
		/// (Web|Application.config)
		/// </summary>
		/// <returns>��� ��� ��������� ����� ������������ ����������</returns>
		internal static string GetConfigurationFileName() 
		{
			// �������� �������� - ��� ��������� ����� ������������ ����������
			string sConfigFileName = ConfigurationSettings.AppSettings[DEF_APPCONFIG_KEYNAME];
			// ���� ��� � ����� �� ������ - ������� ��� �������
			// (���� ��� �� ���, �� � ����� ����� �� ����)
			if ( sConfigFileName == null )
				throw new ConfigurationErrorsException( 
					String.Format( ERR_UNDEFINED_CONFIG, DEF_APPCONFIG_KEYNAME ) 
				);

			return sConfigFileName;
		}


		/// <summary>
		/// �����������, ���������������� ��������� ��������
		/// </summary>
		/// <param name="sFileName">���� � ��������� ����� ������������</param>
		public ServiceConfig( string sFileName ) 
		{
			// ���� ���� � ��������� ����� ������������ �� �����, �� ��������
			// ��� �� �������� "����������" ����� ������������:
			if ( null==sFileName || 0==sFileName.Length )
				m_sConfigFileName = GetConfigurationFileName();
			else
				m_sConfigFileName = sFileName;

			// ���������� ������ ���� ����������������� �����:
			m_sConfigFileName = GetFullPath( m_sConfigFileName, ApplicationBasePath );
			// ..� ��������� ������������
			initialize();
		    getDefaultSystemRoles();
		}


		/// <summary>
		/// ������������� ������� ������������
		/// </summary>
		protected void initialize() 
		{
			// ��������� XML � ������� ��������� ����������������� �����
			load( m_sConfigFileName );
			// ��� ��������� ����������������� ����� ������������ ���� ������ 
			// ���� ���������� � ����� ���������:
			if ( null==RootElementNSPrefix || 0==RootElementNSPrefix.Length )
				throw new ConfigurationErrorsException( 
					"��� ���� ��������� ����������� ����������������� ����� �������� " +
					"������ ���� ���������� �������� ���������������� ������������ ����!" );

			// �������������

			// #1: ������ "�����������" �����������
			m_helperOwnOrganization = loadObjectPresentation( 
				"itws:common-params/itws:own-organization",
				"����������� \"�����������\" ����������� ",
				"Organization"
			);
			// ... ���������, ��� ��� ��������� ����������� ����� ������� "��������" �������
			if (! (bool)m_helperOwnOrganization.GetPropValue( "Home",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: ����������� ����������� �������������� \"�����������\" ����������� - " +
					"��������� �������� (itws:own-organization@id = {1}) ��������� �����������," +
					"� ������� �� ����� ������� \"����������� - �������� �������\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperOwnOrganization.ObjectID )
				);

			// #2: �������� ������ ���� ��������� ������:
			// #2.1: ... ��� "������� ��������":
			m_helperExternalProjectsActivityType = loadObjectPresentation(
				"itws:common-params/itws:external-projects-activity-type",
				"����������� ���� ��������� ������ ��� \"������� ��������\"",
				"ActivityType"
			);
			// ... ���������, ��� ��� ���������� ���� ��������� ������ 
			// ����� ������� "���������� �� ��������� �� ������� ��������":
			if (! (bool)m_helperExternalProjectsActivityType.GetPropValue( "AccountRelated",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: ����������� ����������� �������������� ���� ��������� ������ - " +
					"��������� �������� (external-projects-activity-type@id = {1}) ��������� ��� ������," +
					"� �������� �� ����� ������� \"���������� � ��������� �������\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperExternalProjectsActivityType.ObjectID )
				);
			
			// #2.2: ... ��� "�������-����������":
			m_helperPresaleProjectsActivityType = loadObjectPresentation(
				"itws:common-params/itws:presale-projects-activity-type",
				"����������� ���� ��������� ������ ��� \"�������-����������\"",
				"ActivityType"
			);
           
			// ... ���������, ��� ��� ���������� ���� ��������� ������ 
			// ����� ������� "���������� �� ��������� �� ������� ��������":
			if (! (bool)m_helperPresaleProjectsActivityType.GetPropValue( "AccountRelated",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: ����������� ����������� �������������� ���� ��������� ������ - " +
					"��������� �������� (presale-projects-activity-type@id = {1}) ��������� ��� ������," +
					"� �������� �� ����� ������� \"���������� � ��������� �������\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperExternalProjectsActivityType.ObjectID )
				);
            // #2.3: ... ��� "��������/�������������� ��������":
            m_helperPilotProjectsActivityType = loadObjectPresentation(
                "itws:common-params/itws:pilot-projects-activity-type",
                "����������� ���� ��������� ������ ��� \"�������-����������\"",
                "ActivityType"
            );

            // #2.4: ... ��� "��������":
            m_helperTenderProjectsActivityType = loadObjectPresentation(
                "itws:common-params/itws:tender-projects-activity-type",
                "����������� ���� ��������� ������ ��� \"������-����������\"",
                "ActivityType"
            );
			// #3: �������� ������ ������ �� ����� �������� ������ 
			// ������������� � �����. ��������� ����
			m_rolesMap.LoadFormConfigXml( this );
			
			// #4: ���������������� ������ "������" �������
			m_commonServiceParams = new CommonServiceConfigParams( this );

		}

        /// <summary>
        /// ����� ��������� ��������������� ��������� �����, �� ��������� ������������� ���� ����� �����������
        /// </summary>
        protected void getDefaultSystemRoles()
        {
          DataTable result =  ObjectOperationHelper.ExecAppDataSource("GetDefaultSystemRoles", null);
          for (int i = 0; i < result.Rows.Count; i++)
              m_defaultSystemRoles.Add(result.Rows[i][0].ToString());

        }

		/// <summary>
		/// ���������� ����� �������� ������ ds-������� ��������� ����, 
		/// ������������� �������� ��������� � ���������������� ����� �� 
		/// ��������� XPath-����
		/// </summary>
		/// <param name="sElementPath">XPath-���� ��� ��������, ��������� id �������</param>
		/// <param name="sElementDescr">�������� ������� (���. ��� ��������� ������ � ������)</param>
		/// <param name="sTargetObjectType">��� ds-�������</param>
		/// <returns>
		/// ������������������ � ����������� Helper-������
		/// </returns>
		private ObjectOperationHelper loadObjectPresentation( 
			string sElementPath, 
			string sElementDescr, 
			string sTargetObjectType ) 
		{
			XmlElement xmlElement = (XmlElement)SelectNode( sElementPath );
			if (null==xmlElement)
				throw new ConfigurationErrorsException( String.Format( 
					"{0}: �� ������ {1} (������� {2})", 
					ERR_INCORRECT_CONFIG_DATA, sElementDescr, sElementPath
				));
			// ... ������� �������� ������������� - ����� ��� Guid:
			Guid uidTargetObjectID = Guid.Empty;
			try
			{
				uidTargetObjectID = new Guid( xmlElement.GetAttribute("id") );
				if (Guid.Empty == uidTargetObjectID) 
					throw new ApplicationException("��������� ��-������� ������������� ������� (������� id)!");
			}
			catch( Exception err )
			{
				throw new ConfigurationErrorsException( 
					String.Format( 
						"{0}: ����������� {1} - �������� �������� id �������� {2} ({3})", 
						ERR_INCORRECT_CONFIG_DATA, 
						sElementDescr, 
						sElementPath,
						xmlElement.GetAttribute("id") 
					), err
				);
			}
			// ... ������� ��������� �������� �������: 
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( sTargetObjectType, uidTargetObjectID );
			helper.LoadObject();
			
			return helper;
		}
	}
}