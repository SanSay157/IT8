//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Diagnostics;
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Commands
{
    /// <summary>
    /// ����� - ��������� �������� ������������ ��������� ���������� - ������� 
    /// ��������� ������ Singleton.
    /// </summary>
    public class XListWithAccessCheckController
    {
        /// <summary>
        /// ��� �������� ������ (XListInfo). ����: ������������_����:������������_������
        /// </summary>
        private XThreadSafeCache<String, ListInfoWithAccessCheck> m_ListInfoCache = new XThreadSafeCache<String, ListInfoWithAccessCheck>();
        
        /// <summary>
        /// ������ �� �����, ���������� ��� ������ ��������� �� ��������� ������
        /// </summary>
        private XThreadSafeCacheCreateValue<String, ListInfoWithAccessCheck> m_dlgCreateListInfo;

        #region ���������� ������� Singleton
        /// <summary>
        /// ���������� ������������ ��������� ������ XListWithAccessCheckController
        /// </summary>
        private static XListWithAccessCheckController m_Instance = new XListWithAccessCheckController();

        /// <summary>
        /// ����������� �� ���������.
        /// ������������ ��� �������������� ��������������� ������
        /// XListWithAccessCheckController.
        /// </summary>                                            
        private XListWithAccessCheckController()
        {
            m_dlgCreateListInfo = new XThreadSafeCacheCreateValue<String, ListInfoWithAccessCheck>(createListInfo);
        }

        /// <summary>
        /// ���������� ������������ ���������� ��������� XInterfaceObjectsHolder. 
        /// </summary>                                                            
        public static XListWithAccessCheckController Instance
        {
            get { return m_Instance; }
        }
        #endregion
        /// <summary>
        /// ����� ���������� �������� ������ �� ����������������. ���������� ��� <b>m_ListInfoCache</b>.
        /// </summary>
        /// <param name="sName">������������ ������.</param>
        /// <param name="sTypeName">������������ ����.</param>
        /// <param name="connection">��������� ���������� <see cref="Croc.XmlFramework.Data.XStorageConnection" text="XStorageConnection" />.</param>
        /// <returns>
        /// �������� ������. 
        /// </returns>                                                                                                                               
        public ListInfoWithAccessCheck GetListInfo(String sName, string sTypeName, XStorageConnection connection)
        {
            if (sTypeName == null)
                throw new ArgumentNullException("sTypeName");
            if (connection == null)
                throw new ArgumentNullException("connection");
            return m_ListInfoCache.GetValue(sTypeName + ":" + sName, m_dlgCreateListInfo, connection);
        }


        /// <summary>
        /// ������� �������� ������ ��� ������ ���������. 
        /// �������� �������� CreateCacheValue.
        /// </summary>
        /// <param name="sKey">���� � ������� {������������ ����}:{������������ ������}</param>
        /// <param name="value">XStorageConnection</param>
        /// <returns>��������� ListInfoWithAccessCheck</returns>
        private static ListInfoWithAccessCheck createListInfo(string sKey, object value)
        {
            #region Copy-paste ���� �� XInterfaceObjectsHolder::createListInfo

            XStorageConnection connection = (XStorageConnection)value;
            XMetadataManager metadataManager = connection.MetadataManager;

            // ���� ��� ���������� � ������� (����) XModel � ������ ������
            // ������ ���� � ���� {������������ ����}:{������������ ������}
            // �������� ���� ���� - ������� ������������ ���� � ������������ ������
            Debug.Assert(sKey.IndexOf(":") > -1, "����������� ������ ':' � �����");
            int nIndex = sKey.IndexOf(":");
            string sTypeName = sKey.Substring(0, nIndex);
            Debug.Assert(sTypeName.Length > 0, "�� ����� ���");
            string sName = sKey.Substring(nIndex + 1, sKey.Length - nIndex - 1);

            // ���������� XPath-������ � �������� ������������ ������; ��� ������������ 
            // ������� �������� ��� ���������������� ������ - �������� ��������������
            string sXPath = "ds:type[@n='" + sTypeName + "']/i:objects-list";
            if (sName.Length > 0)
                sXPath = sXPath + "[@n='" + sName + "']";

            XmlElement xmlList = (XmlElement)metadataManager.SelectSingleNode(sXPath);
            if (xmlList == null)
                throw new ArgumentException(
                    "����������� ����������� ������ i:objects-list � ����������������� " +
                    "'" + sName + "', ��� ���� '" + sTypeName + "' " +
                    "(�� ������� � ����������, XPath='" + sXPath + "')");

            #endregion
            //������� �������� ������ ListInfoWithAccessCheck.
            ListInfoWithAccessCheck listInfo = new ListInfoWithAccessCheck(xmlList, connection.MetadataManager.NamespaceManager, connection.MetadataManager.XModel);
            XPrivilegeSet privSet = new XPrivilegeSet();

            //���������� �� ���������� ����������� ���������� ��� ������� � ��������� ������ � ���������� �� � ��������� ����������. 
            foreach (XmlElement xmlNode in xmlList.SelectNodes("it-sec:access-requirements/*", connection.MetadataManager.NamespaceManager))
            {
                string sPrivName = xmlNode.GetAttribute("n");
                ITSystemPrivilege priv = new ITSystemPrivilege(SystemPrivilegesItem.GetItem(sPrivName));
                privSet.Add(priv);
            }
            listInfo.AccessSecurity.SetRequiredPrivileges(privSet);
            return listInfo;
        }

        /// <summary>
        /// ����� ������� ���.
        /// </summary>        
        public void Reset()
        {
            m_ListInfoCache.Clear();
        }
    }
	/// <summary>
	/// ��������� ��������� ���������� ��� ������� � ������������� �������� (������/������) 
	/// </summary>
	public class InterfaceSecurityAceessContainer
	{
		/// <summary>
		/// ����� ����������
		/// </summary>
        protected XPrivilegeSet m_requiredPrivileges;

        /// <summary>
        /// �����,������������ � ��������� ����� ����������.
        /// </summary>
        /// <param name="privilege_set">����� ����������</param>
		public void SetRequiredPrivileges(XPrivilegeSet privilege_set)
		{
			m_requiredPrivileges = privilege_set;
		}
        /// <summary>
        /// �����,������������ �� ���������� ���������� � ��� ����� ����������.
        /// </summary>
		public XPrivilegeSet RequiredPrivileges
		{
			get { return m_requiredPrivileges; }
		}
	}

	/// <summary>
	/// ���������� �������� ������ (XListInfo) - ��������� ���������� � �����������, 
	/// �������� ������ �������� ������������ ��� ������� � ������
	/// </summary>
	public class ListInfoWithAccessCheck: XListInfo
	{
        /// <summary>
        /// ��������� ���������� ��� ������� � ������
        /// </summary>
		private InterfaceSecurityAceessContainer m_security = new InterfaceSecurityAceessContainer();

        /// <summary>
        /// ����������� ������
        /// </summary>
        /// <param name="xmlList">xml-�������� ������</param>
        /// <param name="nsManager">XmlNamespaceManager</param>
        /// <param name="model">�������� ����������</param>
		public ListInfoWithAccessCheck(XmlElement xmlList,XmlNamespaceManager nsManager, XModel model)
            : base(xmlList, nsManager, model)
		{}

        /// <summary>
        /// ��������� ���������� ��� ������� � ������
        /// </summary>
		public InterfaceSecurityAceessContainer AccessSecurity
		{
			get { return m_security; }
		}

		/// <summary>
		/// ������� �������� ������ ��� ������ ���������. 
		/// �������� �������� CreateCacheValue.
		/// </summary>
		/// <param name="sKey">���� � ������� {������������ ����}:{������������ ������}</param>
		/// <param name="value">XStorageConnection</param>
        /// <returns>��������� ListInfoWithAccessCheck</returns>
        private static ListInfoWithAccessCheck createListInfo(string sKey, object value) 
		{
			#region Copy-paste ���� �� XInterfaceObjectsHolder::createListInfo

            XStorageConnection connection = (XStorageConnection)value;
            XMetadataManager metadataManager = connection.MetadataManager;

            // ���� ��� ���������� � ������� (����) XModel � ������ ������
            // ������ ���� � ���� {������������ ����}:{������������ ������}
            // �������� ���� ���� - ������� ������������ ���� � ������������ ������
            Debug.Assert(sKey.IndexOf(":") > -1, "����������� ������ ':' � �����");
            int nIndex = sKey.IndexOf(":");
            string sTypeName = sKey.Substring(0, nIndex);
            Debug.Assert(sTypeName.Length > 0, "�� ����� ���");
            string sName = sKey.Substring(nIndex + 1, sKey.Length - nIndex - 1);

            // ���������� XPath-������ � �������� ������������ ������; ��� ������������ 
            // ������� �������� ��� ���������������� ������ - �������� ��������������
            string sXPath = "ds:type[@n='" + sTypeName + "']/i:objects-list";
            if (sName.Length > 0)
                sXPath = sXPath + "[@n='" + sName + "']";

            XmlElement xmlList = (XmlElement)metadataManager.SelectSingleNode(sXPath);
            if (xmlList == null)
                throw new ArgumentException(
                    "����������� ����������� ������ i:objects-list � ����������������� " +
                    "'" + sName + "', ��� ���� '" + sTypeName + "' " +
                    "(�� ������� � ����������, XPath='" + sXPath + "')");

            #endregion
            //������� �������� ������ ListInfoWithAccessCheck.
            ListInfoWithAccessCheck listInfo = new ListInfoWithAccessCheck( xmlList, connection.MetadataManager.NamespaceManager, connection.MetadataManager.XModel );
			XPrivilegeSet privSet = new XPrivilegeSet();

            //���������� �� ���������� ����������� ���������� ��� ������� � ��������� ������ � ���������� �� � ��������� ����������. 
			foreach(XmlElement xmlNode in xmlList.SelectNodes("it-sec:access-requirements/*", connection.MetadataManager.NamespaceManager))
			{
				string sPrivName = xmlNode.GetAttribute("n");
				ITSystemPrivilege priv = new ITSystemPrivilege( SystemPrivilegesItem.GetItem(sPrivName) );
				privSet.Add(priv);
			}
			listInfo.AccessSecurity.SetRequiredPrivileges(privSet);
			return listInfo;
		}
	}


}