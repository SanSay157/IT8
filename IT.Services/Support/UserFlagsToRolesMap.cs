//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections.Specialized;
using System.Xml;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ��������� ������ - ��������� ����� �/� ������, ���������� ��� ������������
	/// � ������� ��� � ��������������� ������� �� ��������� ���� � Incident Tracker.
	/// ��� ����� ������������ �������� ���� UserFlagToRolesMap.
	/// ������ � ��������� ����������� �� ��������� ������, �������� � ���������� 
	/// ���������������� ����� ��������. 
	/// </summary>
	public class UserFlagToRoleLink 
	{
		/// <summary>
		/// ��������������� ������, �������������� XML-������ ds-������� "��������� 
		/// ����" (SystemRole), �������������� �������� ����������
		/// </summary>
		private ObjectOperationHelper m_oRolerObject = null;
		
		/// <summary>
		/// �������� ����� (����������� ��� ������������ � ������� ���)
		/// </summary>
		public int Flag;
		/// <summary>
		/// ������������� ��������� ���� (ds-������� SystemRole), ����������������
		/// ����� � ������� IT. ���� ����� �� ���������� � ������������ �� ���� ����
		/// �������� �������� ���� Guid.Empty
		/// </summary>
		public Guid RoleID;
		/// <summary>
		/// �������, �����������, ��� ����, �������� ��� ������������ � ���, 
		/// ���������� ��� ����, �������� ��� ������������ � ������� IT, ��� 
		/// ����������� �� �������� RoleID. ������������ ��� ������� ����� 
		/// ������ ��� "2" (������) � "16384" (�� ������������� �����)
		/// </summary>
		public bool IsClearRolesFlag;

		/// <summary>
		/// ��������������� ������, �������������� XML-������ ds-������� "��������� 
		/// ����" (SystemRole), �������������� �������� ����������. �������� ������
		/// ������� ����������� ��� ������ ��������� � ��������.
		/// </summary>
		public ObjectOperationHelper RoleObject 
		{
			get
			{
				if (Guid.Empty == RoleID)
					throw new ApplicationException("�� ����� ������������� ��� ��������� ������� \"����\"");
				if (null == m_oRolerObject)
					m_oRolerObject = ObjectOperationHelper.GetInstance( "SystemRole", RoleID );
				if ( !m_oRolerObject.IsLoaded )
					m_oRolerObject.LoadObject();
				if ( m_oRolerObject.IsNewObject )
					throw new ApplicationException("�������� ������������� ���������� ����� ������ \"����\" � �� ����� ���� �����������");

				return m_oRolerObject;
			}
		}
	}

	
	/// <summary>
	/// ������-��������� ����� ������ �/� �������, ���������� ��� ������������
	/// � ������� ��� � ��������������� ������� �� ��������� ���� � Incident Tracker.
	/// ������ ����� ������������ �������� ���� UserFlagToRoleLink.
	/// </summary>
	public class UserFlagsToRolesMap
	{
		/// <summary>
		/// ��������� ���� ���������� ������; �������� �� ��������� �������� 
		/// � ���������������� �����
		/// </summary>
		private HybridDictionary m_rolesLinks = new HybridDictionary();
		/// <summary>
		/// ������ ������, ���������� �� ��������� �������� � ������. �����
		/// </summary>
		private int[] m_arrFlags = new int[0];

		/// <summary>
		/// ��������� �������� �������� ������ �� ����������������� �����, ������ 
		/// �������� ������������ ����. ������ ���� XConfigurationFile
		/// </summary>
		/// <param name="config">����������������� ����</param>
		/// <remarks>
		/// �������� ������ �� ���������� ���������� ������� - m_rolesLinks �
		/// m_arrFlags
		/// </remarks>
		public void LoadFormConfigXml( XConfigurationFile config ) 
		{
			// �������� ������
			m_rolesLinks.Clear();
			m_arrFlags = new int[0];
			
			// ���� ������������ �� ������ - �� � ����� ������ ���:
			if (null == config) 
				return;
			
			XmlNodeList xmlRoleLinks = config.SelectNodes( "itws:nsi-sync-service/itws:flags-to-roles-map/itws:role-link" );
			if (null==xmlRoleLinks)
				return;
			
			foreach( XmlNode xmlNodeLink in xmlRoleLinks )
			{
				XmlElement xmlRoleLink = (XmlElement)xmlNodeLink ;
				UserFlagToRoleLink link = new UserFlagToRoleLink();

				// #1: ����� ����
				string sAttribute = xmlRoleLink.GetAttribute("for-flag");
				if (null==sAttribute || String.Empty == sAttribute)
					throw new ApplicationException( String.Format( 
						"{0}: �� ������ �������� ����� (������� for-flag �������� itws:role-link)", 
						ServiceConfig.ERR_INCORRECT_CONFIG_DATA 
					));

				try { link.Flag = Int32.Parse(sAttribute); }
				catch( Exception err )
				{
					throw new ApplicationException( String.Format( 
						"{0}: ��������� �������� {1} ��� �������� for-flag �������� itws:role-link �� �������� �����", 
						ServiceConfig.ERR_INCORRECT_CONFIG_DATA, sAttribute
					), err );
				}

				// #2: � ����� ������ ���� - ������������� ���� 
				sAttribute = xmlRoleLink.GetAttribute("to-role");
				if (null==sAttribute || String.Empty == sAttribute)
					link.RoleID = Guid.Empty;
				else
				{
					try { link.RoleID = new Guid(sAttribute); }
					catch( Exception err )
					{
						throw new ApplicationException( String.Format( 
							"{0}: ��������� �������� {1} ��� �������� to-role �������� itws:role-link �� �������� ��������������� ���� GUID", 
							ServiceConfig.ERR_INCORRECT_CONFIG_DATA, sAttribute
						), err );
					}
				}
				
				// #3: ������� �������� ��� ����
				sAttribute = xmlRoleLink.GetAttribute("clear-roles");
				link.IsClearRolesFlag = !(null==sAttribute || String.Empty == sAttribute);

				// �����: ��������� � ���������:
				m_rolesLinks.Add( link.Flag, link );
			}
			
			// ��������� ������ ������:
			m_arrFlags = new int[m_rolesLinks.Keys.Count];
			if (0!=m_rolesLinks.Keys.Count)
				m_rolesLinks.Keys.CopyTo(m_arrFlags,0);
		}

		
		/// <summary>
		/// ���������� ������ ������, ���������� �� ��������� �������� � 
		/// ���������� ���������������� �����
		/// </summary>
		/// <remarks>��� ���������� �������� ���������� ������ ������</remarks>
		public int[] Flags 
		{
			get { return m_arrFlags; }
		}
		
		
		/// <summary>
		/// ���������� ��������� �����, ��������������� ��������� �����.
		/// ���� ��� ���������� ����� ��������� ���, ���������� null
		/// </summary>
		public UserFlagToRoleLink this[int nFlag] 
		{
			get
			{
				object oLink = m_rolesLinks[nFlag];
				if (null==oLink)
					return null;
				return (oLink as UserFlagToRoleLink);
			}
		}
	}
}