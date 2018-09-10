//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
    /// Класс - контейнер описаний интерфейсных элементов метаданных - списков 
    /// Реализует шаблон Singleton.
    /// </summary>
    public class XListWithAccessCheckController
    {
        /// <summary>
        /// Кеш описаний списка (XListInfo). Ключ: наименование_типа:наименование_списка
        /// </summary>
        private XThreadSafeCache<String, ListInfoWithAccessCheck> m_ListInfoCache = new XThreadSafeCache<String, ListInfoWithAccessCheck>();
        
        /// <summary>
        /// Ссылка на метод, вызываемый при первом обращении за описанием списка
        /// </summary>
        private XThreadSafeCacheCreateValue<String, ListInfoWithAccessCheck> m_dlgCreateListInfo;

        #region Реализация шаблона Singleton
        /// <summary>
        /// Глобальный единственный экземпляр класса XListWithAccessCheckController
        /// </summary>
        private static XListWithAccessCheckController m_Instance = new XListWithAccessCheckController();

        /// <summary>
        /// Конструктор по умолчанию.
        /// Предназначен для предотвращения инстанцирования класса
        /// XListWithAccessCheckController.
        /// </summary>                                            
        private XListWithAccessCheckController()
        {
            m_dlgCreateListInfo = new XThreadSafeCacheCreateValue<String, ListInfoWithAccessCheck>(createListInfo);
        }

        /// <summary>
        /// Возвращает единственный глобальный экземпляр XInterfaceObjectsHolder. 
        /// </summary>                                                            
        public static XListWithAccessCheckController Instance
        {
            get { return m_Instance; }
        }
        #endregion
        /// <summary>
        /// Метод возвращает описание списка по метанаименованию. Использует кэш <b>m_ListInfoCache</b>.
        /// </summary>
        /// <param name="sName">Наименование списка.</param>
        /// <param name="sTypeName">Наименование типа.</param>
        /// <param name="connection">Экземпляр реализации <see cref="Croc.XmlFramework.Data.XStorageConnection" text="XStorageConnection" />.</param>
        /// <returns>
        /// Описание списка. 
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
        /// Создает описание списка при первом обращении. 
        /// Параметр делегата CreateCacheValue.
        /// </summary>
        /// <param name="sKey">Ключ в формате {Наименование типа}:{Наименование списка}</param>
        /// <param name="value">XStorageConnection</param>
        /// <returns>экземпляр ListInfoWithAccessCheck</returns>
        private static ListInfoWithAccessCheck createListInfo(string sKey, object value)
        {
            #region Copy-paste кода из XInterfaceObjectsHolder::createListInfo

            XStorageConnection connection = (XStorageConnection)value;
            XMetadataManager metadataManager = connection.MetadataManager;

            // Ключ для сохранения в реестре (кеше) XModel в данном случае
            // ДОЛЖЕН БЫТЬ в виде {Наименование типа}:{Наименование списка}
            // Разберем этот ключ - выделим наименование типа и наименование списка
            Debug.Assert(sKey.IndexOf(":") > -1, "Отсутствует символ ':' в ключе");
            int nIndex = sKey.IndexOf(":");
            string sTypeName = sKey.Substring(0, nIndex);
            Debug.Assert(sTypeName.Length > 0, "Не задан тип");
            string sName = sKey.Substring(nIndex + 1, sKey.Length - nIndex - 1);

            // Сформируем XPath-запрос и загрузим метаописание списка; при формировании 
            // запроса учитваем что метанаименование списка - параметр необязательный
            string sXPath = "ds:type[@n='" + sTypeName + "']/i:objects-list";
            if (sName.Length > 0)
                sXPath = sXPath + "[@n='" + sName + "']";

            XmlElement xmlList = (XmlElement)metadataManager.SelectSingleNode(sXPath);
            if (xmlList == null)
                throw new ArgumentException(
                    "Неизвестное определение списка i:objects-list с метанаименованием " +
                    "'" + sName + "', для типа '" + sTypeName + "' " +
                    "(не найдено в метаданных, XPath='" + sXPath + "')");

            #endregion
            //Создаем описание списка ListInfoWithAccessCheck.
            ListInfoWithAccessCheck listInfo = new ListInfoWithAccessCheck(xmlList, connection.MetadataManager.NamespaceManager, connection.MetadataManager.XModel);
            XPrivilegeSet privSet = new XPrivilegeSet();

            //Зачитываем из метаданных необходимые привилегии для доступа к заданному списку и записываем их в контейнер привилегий. 
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
        /// Метод ощищает кэш.
        /// </summary>        
        public void Reset()
        {
            m_ListInfoCache.Clear();
        }
    }
	/// <summary>
	/// Контейнер требуемых привилегий для доступа к интерфейсному элементу (списку/дереву) 
	/// </summary>
	public class InterfaceSecurityAceessContainer
	{
		/// <summary>
		/// Набор привилегий
		/// </summary>
        protected XPrivilegeSet m_requiredPrivileges;

        /// <summary>
        /// Метод,записывающий в контейнер набор привилегий.
        /// </summary>
        /// <param name="privilege_set">набор привилегий</param>
		public void SetRequiredPrivileges(XPrivilegeSet privilege_set)
		{
			m_requiredPrivileges = privilege_set;
		}
        /// <summary>
        /// Метод,возвращающий из контейнера хранящийся в нем набор привилегий.
        /// </summary>
		public XPrivilegeSet RequiredPrivileges
		{
			get { return m_requiredPrivileges; }
		}
	}

	/// <summary>
	/// Расширение описания списка (XListInfo) - добавлена информация о привилегиях, 
	/// которыми должен обладать пользователь для доступа к списку
	/// </summary>
	public class ListInfoWithAccessCheck: XListInfo
	{
        /// <summary>
        /// Контейнер привилегий для доступа к списку
        /// </summary>
		private InterfaceSecurityAceessContainer m_security = new InterfaceSecurityAceessContainer();

        /// <summary>
        /// Конструктор класса
        /// </summary>
        /// <param name="xmlList">xml-описание списка</param>
        /// <param name="nsManager">XmlNamespaceManager</param>
        /// <param name="model">описание метаданных</param>
		public ListInfoWithAccessCheck(XmlElement xmlList,XmlNamespaceManager nsManager, XModel model)
            : base(xmlList, nsManager, model)
		{}

        /// <summary>
        /// Контейнер привилегий для доступа к списку
        /// </summary>
		public InterfaceSecurityAceessContainer AccessSecurity
		{
			get { return m_security; }
		}

		/// <summary>
		/// Создает описание списка при первом обращении. 
		/// Параметр делегата CreateCacheValue.
		/// </summary>
		/// <param name="sKey">Ключ в формате {Наименование типа}:{Наименование списка}</param>
		/// <param name="value">XStorageConnection</param>
        /// <returns>экземпляр ListInfoWithAccessCheck</returns>
        private static ListInfoWithAccessCheck createListInfo(string sKey, object value) 
		{
			#region Copy-paste кода из XInterfaceObjectsHolder::createListInfo

            XStorageConnection connection = (XStorageConnection)value;
            XMetadataManager metadataManager = connection.MetadataManager;

            // Ключ для сохранения в реестре (кеше) XModel в данном случае
            // ДОЛЖЕН БЫТЬ в виде {Наименование типа}:{Наименование списка}
            // Разберем этот ключ - выделим наименование типа и наименование списка
            Debug.Assert(sKey.IndexOf(":") > -1, "Отсутствует символ ':' в ключе");
            int nIndex = sKey.IndexOf(":");
            string sTypeName = sKey.Substring(0, nIndex);
            Debug.Assert(sTypeName.Length > 0, "Не задан тип");
            string sName = sKey.Substring(nIndex + 1, sKey.Length - nIndex - 1);

            // Сформируем XPath-запрос и загрузим метаописание списка; при формировании 
            // запроса учитваем что метанаименование списка - параметр необязательный
            string sXPath = "ds:type[@n='" + sTypeName + "']/i:objects-list";
            if (sName.Length > 0)
                sXPath = sXPath + "[@n='" + sName + "']";

            XmlElement xmlList = (XmlElement)metadataManager.SelectSingleNode(sXPath);
            if (xmlList == null)
                throw new ArgumentException(
                    "Неизвестное определение списка i:objects-list с метанаименованием " +
                    "'" + sName + "', для типа '" + sTypeName + "' " +
                    "(не найдено в метаданных, XPath='" + sXPath + "')");

            #endregion
            //Создаем описание списка ListInfoWithAccessCheck.
            ListInfoWithAccessCheck listInfo = new ListInfoWithAccessCheck( xmlList, connection.MetadataManager.NamespaceManager, connection.MetadataManager.XModel );
			XPrivilegeSet privSet = new XPrivilegeSet();

            //Зачитываем из метаданных необходимые привилегии для доступа к заданному списку и записываем их в контейнер привилегий. 
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