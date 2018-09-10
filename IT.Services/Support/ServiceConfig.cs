//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
	/// Объект - описатель прикладных конфигурационных данных сервисов
	/// </summary>
	public class ServiceConfig : XConfigurationFile
	{
		/// <summary>
		/// Наименование ключа для элемента прикладной конфигурации 
		/// (appSettings) в файле конфигурации приложения (Web|App.Config),
		/// задающего наименование основного файла конфигурации для Web Service
		/// </summary>
		public readonly static string DEF_APPCONFIG_KEYNAME = "IT-WS-ConfigFileName";
		/// <summary>
		/// Описание ошибки задания пути для прикладного конфигурационного файла сервисов
		/// </summary>
		public const string ERR_UNDEFINED_CONFIG = "Не определено наименование прикладного конфигурационного файла сервисов: не задано значение для элемента \"{0}\"";
		/// <summary>
		/// Ошибка некорректных данных в конфигурационном файле
		/// </summary>
		public const string ERR_INCORRECT_CONFIG_DATA = "Ошибка в задании конфигурационных данных сервисов";
		
		#region Внутренние переменные класса 

		/// <summary>
		/// Путь к основному конфигурационному файлу приложения
		/// </summary>
		private string m_sConfigFileName;
		/// <summary>
		/// Объект-описатель ds-объекта типа "Организация", представляющего данные 
		/// "собственной" организации
		/// </summary>
		private ObjectOperationHelper m_helperOwnOrganization = null;
		/// <summary>
		/// Объект-описатель ds-объекта типа "Тип проектных затрат" (внутренний 
		/// справочник системы IT), представляющего данные для типа "Внешние проекты"
		/// </summary>
		private ObjectOperationHelper m_helperExternalProjectsActivityType = null;
		/// <summary>
		/// Объект-описатель ds-объекта типа "Тип проектных затрат" (внутренний 
		/// справочник системы IT), представляющего данные для типа "Пресейл-активность"
		/// </summary>
		private ObjectOperationHelper m_helperPresaleProjectsActivityType = null;
        /// <summary>
        /// Объект-описатель ds-объекта типа "Тип проектных затрат" (внутренний 
        /// справочник системы IT), представляющего данные для типа "Пилотные/инвестиционные проекты"
        /// </summary>
        private ObjectOperationHelper m_helperPilotProjectsActivityType = null;

        /// <summary>
        /// Объект-описатель ds-объекта типа "Тип проектных затрат" (внутренний 
        /// справочник системы IT), представляющего данные для типа "Тендерные предложения"
        /// </summary>
        private ObjectOperationHelper m_helperTenderProjectsActivityType = null;
		/// <summary>
		/// Объект - описатель карты соотнесения флагов, заданных для пользователя 
		/// в системе НСИ, и соотв. системными ролями, задаваемыми для пользователя
		/// в системе IT
		/// </summary>
		private UserFlagsToRolesMap m_rolesMap = new UserFlagsToRolesMap();
		/// <summary>
		/// Объект, представляющий конфигурационные параметры для "общего" 
		/// сервиса CommonService в объектном виде
		/// </summary>
		private CommonServiceConfigParams m_commonServiceParams = null;
        /// <summary>
        /// Коллекция идентификаторов системных ролей,присваиваемых по умолчанию новым сотрудникам
        /// </summary>
        private ArrayList m_defaultSystemRoles = new ArrayList();

		#endregion

		/// <summary>
		/// Возвращает объект-описатель ds-объекта типа "Организация", представляющего 
		/// данные "собственной" организации; указание объекта задается в прикладном 
		/// файле конфигурации
		/// </summary>
		public ObjectOperationHelper OwnOrganization 
		{
			get { return m_helperOwnOrganization; }
		}

		/// <summary>
		/// Возвращает объект-описатель ds-объекта типа "Тип проектных затрат" 
		/// (внутренний справочник системы IT), представляющего данные для 
		/// типа "Внешние проекты". Указание объекта задается в прикладном 
		/// файле конфигурации
		/// </summary>
		public ObjectOperationHelper ExternalProjectsActivityType 
		{
			get { return m_helperExternalProjectsActivityType; }
		}
		/// <summary>
		/// Возвращает объект-описатель ds-объекта типа "Тип проектных затрат" 
		/// (внутренний справочник системы IT), представляющего данные для 
		/// типа "Пресейл-активность" (проекты по ведению возможностей-presale)
		/// Указание объекта задается в прикладном файле конфигурации.
		/// </summary>
		public ObjectOperationHelper PresaleProjectsActivityType 
		{
			get { return m_helperPresaleProjectsActivityType; }
		}

        /// <summary>
        /// Возвращает объект-описатель ds-объекта типа "Тип проектных затрат" 
        /// (внутренний справочник системы IT), представляющего данные для 
        /// типа Тендер
        /// Указание объекта задается в прикладном файле конфигурации.
        /// </summary>
        public ObjectOperationHelper TenderProjectsActivityType
        {
            get { return m_helperTenderProjectsActivityType; }
        }
        /// <summary>
        /// Возвращает объект-описатель ds-объекта типа "Тип проектных затрат" 
        /// (внутренний справочник системы IT), представляющего данные для 
        /// типа "Пилотные/инвестиционные проекты" 
        /// Указание объекта задается в прикладном файле конфигурации.
        /// </summary>
        public ObjectOperationHelper PilotProjectsActivityType
        {
            get { return m_helperPilotProjectsActivityType; }
        }
		/// <summary>
		/// Возвращает объект - описатель карты соотнесения флагов, заданных для 
		/// пользователя в системе НСИ, и соотв. системными ролями, задаваемыми для 
		/// пользователя в системе IT
		/// </summary>
		public UserFlagsToRolesMap RolesMap 
		{
			get { return m_rolesMap; }
		}

		/// <summary>
		/// Возвращает Объект, представляющий конфигурационные параметры для 
		/// "общего" сервиса CommonService в объектном виде
		/// </summary>
		public CommonServiceConfigParams CommonServiceParams 
		{
			get { return m_commonServiceParams; }
		}
		/// <summary>
		/// Возвращает коллекцию идентификаторов системных ролей, присваиваемых новому сотруднику по умолчанию
		/// </summary>
	    public ArrayList DefaultSystemRoles
	    {
            get { return m_defaultSystemRoles; }
	    }
		
		#region Реализация шаблона Singleton

		/// <summary>
		/// Статический экземпляр объекта описателя конфигурации
		/// </summary>
		private static ServiceConfig m_Instance = null;
		
		/// <summary>
		/// Получение статического объекта
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
		/// Полное наименование каталога, в котором размещен файл конфигурации 
		/// приложения (Web.Config или App.Config)
		/// </summary>
		public static string ApplicationBasePath 
		{
			get { return AppDomain.CurrentDomain.SetupInformation.ApplicationBase; }
		}

		/// <summary>
		/// Полное наименование каталога, в котором размещается прикладной
		/// конфигурационный файл сервисов 
		/// </summary>
		public string BaseConfigPath 
		{
			get { return Path.GetDirectoryName(m_sConfigFileName); }
		}

		/// <summary>
		/// Полное наименование основного прикладного конфигурационного файла сервисов
		/// </summary>
		public string BaseConfigFileName 
		{
			get { return m_sConfigFileName; }
		}

		
		/// <summary>
		/// Нормализует имя файла.
		/// </summary>
		/// <param name="sFileName">Имя файла</param>
		/// <param name="sBaseDirectory">Каталог, относительно которого строятся пути</param>
		/// <returns>Полное имя файла</returns>
		/// <exception cref="FileNotFoundException">Если файл не существует</exception>
		internal static string GetFullPath( string sFileName, string sBaseDirectory ) 
		{
			// Полное имя файла
			string sFullFileName;

			if ( Path.IsPathRooted(sFileName) )
				sFullFileName = sFileName;
			else
				sFullFileName = Path.Combine( sBaseDirectory, sFileName );

			if ( !File.Exists(sFullFileName) )
				throw new FileNotFoundException( "Файл не найден", Path.GetFileName(sFullFileName) );

			return sFullFileName;
		}

		
		/// <summary>
		/// Возвращает имя основного файла конфигурации приложения, как оно 
		/// указано в настройках "системного" конфигурационного файла 
		/// (Web|Application.config)
		/// </summary>
		/// <returns>Имя имя основного файла конфигурации приложения</returns>
		internal static string GetConfigurationFileName() 
		{
			// Получаем параметр - имя основного файла конфигурации приложения
			string sConfigFileName = ConfigurationSettings.AppSettings[DEF_APPCONFIG_KEYNAME];
			// Если имя в файле не задано - считаем это ошибкой
			// (если это не так, то и метод звать не надо)
			if ( sConfigFileName == null )
				throw new ConfigurationErrorsException( 
					String.Format( ERR_UNDEFINED_CONFIG, DEF_APPCONFIG_KEYNAME ) 
				);

			return sConfigFileName;
		}


		/// <summary>
		/// Конструктор, инициализирующий настройки сервисов
		/// </summary>
		/// <param name="sFileName">Путь к основному файлу конфигурации</param>
		public ServiceConfig( string sFileName ) 
		{
			// Если путь к основному файлу конфигурации не задан, то получаем
			// его из настроек "системного" файла конфигурации:
			if ( null==sFileName || 0==sFileName.Length )
				m_sConfigFileName = GetConfigurationFileName();
			else
				m_sConfigFileName = sFileName;

			// Определяем полный путь конфигурационного файла:
			m_sConfigFileName = GetFullPath( m_sConfigFileName, ApplicationBasePath );
			// ..и выполняем инциализацию
			initialize();
		    getDefaultSystemRoles();
		}


		/// <summary>
		/// Инициализация объекта конфигурации
		/// </summary>
		protected void initialize() 
		{
			// Загружаем XML с данными основного конфигурационного файла
			load( m_sConfigFileName );
			// Для основного конфигурационного файла пространство имен ДОЛЖНО 
			// БЫТЬ ОПРЕДЕЛЕНО С ЯВНЫМ ПРЕФИКСОМ:
			if ( null==RootElementNSPrefix || 0==RootElementNSPrefix.Length )
				throw new ConfigurationErrorsException( 
					"Для всех элементов прикладного конфигурационного файла сервисов " +
					"должны быть определены префиксы соответствующего пространства имен!" );

			// ИНИЦИАЛИЗАЦИЯ

			// #1: Данные "собственной" организации
			m_helperOwnOrganization = loadObjectPresentation( 
				"itws:common-params/itws:own-organization",
				"определение \"собственной\" организации ",
				"Organization"
			);
			// ... проверяем, что для указанной организации задан признак "владелец" системы
			if (! (bool)m_helperOwnOrganization.GetPropValue( "Home",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: Некорретное определение идентификатора \"собственной\" организации - " +
					"указанное описание (itws:own-organization@id = {1}) описывает организацию," +
					"у которой не задан признак \"Организация - владелец системы\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperOwnOrganization.ObjectID )
				);

			// #2: Получаем данные типа проектных затрат:
			// #2.1: ... для "Внешних проектов":
			m_helperExternalProjectsActivityType = loadObjectPresentation(
				"itws:common-params/itws:external-projects-activity-type",
				"определение типа проектных затрат для \"Внешних проектов\"",
				"ActivityType"
			);
			// ... проверяем, что для указанного типа проектных затрат 
			// задан признак "активность по отношению ко внешним клиентам":
			if (! (bool)m_helperExternalProjectsActivityType.GetPropValue( "AccountRelated",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: Некорретное определение идентификатора типа проектных затрат - " +
					"указанное описание (external-projects-activity-type@id = {1}) описывает тип затрат," +
					"у которого не задан признак \"Активность в отношении Клиента\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperExternalProjectsActivityType.ObjectID )
				);
			
			// #2.2: ... для "Пресейл-активности":
			m_helperPresaleProjectsActivityType = loadObjectPresentation(
				"itws:common-params/itws:presale-projects-activity-type",
				"определение типа проектных затрат для \"Пресейл-активности\"",
				"ActivityType"
			);
           
			// ... проверяем, что для указанного типа проектных затрат 
			// задан признак "активность по отношению ко внешним клиентам":
			if (! (bool)m_helperPresaleProjectsActivityType.GetPropValue( "AccountRelated",XPropType.vt_boolean ) )
				throw new ConfigurationErrorsException( 
					String.Format( 
					"{0}: Некорретное определение идентификатора типа проектных затрат - " +
					"указанное описание (presale-projects-activity-type@id = {1}) описывает тип затрат," +
					"у которого не задан признак \"Активность в отношении Клиента\"", 
					ERR_INCORRECT_CONFIG_DATA, m_helperExternalProjectsActivityType.ObjectID )
				);
            // #2.3: ... для "Пилотных/инвестиционных проектов":
            m_helperPilotProjectsActivityType = loadObjectPresentation(
                "itws:common-params/itws:pilot-projects-activity-type",
                "определение типа проектных затрат для \"Пресейл-активности\"",
                "ActivityType"
            );

            // #2.4: ... для "Тендеров":
            m_helperTenderProjectsActivityType = loadObjectPresentation(
                "itws:common-params/itws:tender-projects-activity-type",
                "определение типа проектных затрат для \"Тендер-активности\"",
                "ActivityType"
            );
			// #3: Получаем список ссылок из Карты перевода флагов 
			// пользователей в соотв. системные роли
			m_rolesMap.LoadFormConfigXml( this );
			
			// #4: Конфигурационные данные "общего" сервиса
			m_commonServiceParams = new CommonServiceConfigParams( this );

		}

        /// <summary>
        /// Метод получения идентификаторов системных ролей, по умолчанию присваиваемых всем новым сотрудникам
        /// </summary>
        protected void getDefaultSystemRoles()
        {
          DataTable result =  ObjectOperationHelper.ExecAppDataSource("GetDefaultSystemRoles", null);
          for (int i = 0; i < result.Rows.Count; i++)
              m_defaultSystemRoles.Add(result.Rows[i][0].ToString());

        }

		/// <summary>
		/// Внутренний метод загрузки данных ds-объекта заданного типа, 
		/// идентификатор которого определен в конфигурационном файле по 
		/// заданному XPath-пути
		/// </summary>
		/// <param name="sElementPath">XPath-путь для элемента, задающего id объекта</param>
		/// <param name="sElementDescr">Описание объекта (исп. при генерации ошибки в тексте)</param>
		/// <param name="sTargetObjectType">Тип ds-объекта</param>
		/// <returns>
		/// Инициализированный и загруженные Helper-объект
		/// </returns>
		private ObjectOperationHelper loadObjectPresentation( 
			string sElementPath, 
			string sElementDescr, 
			string sTargetObjectType ) 
		{
			XmlElement xmlElement = (XmlElement)SelectNode( sElementPath );
			if (null==xmlElement)
				throw new ConfigurationErrorsException( String.Format( 
					"{0}: Не задано {1} (элемент {2})", 
					ERR_INCORRECT_CONFIG_DATA, sElementDescr, sElementPath
				));
			// ... пробуем зачитать идентификатор - сразу как Guid:
			Guid uidTargetObjectID = Guid.Empty;
			try
			{
				uidTargetObjectID = new Guid( xmlElement.GetAttribute("id") );
				if (Guid.Empty == uidTargetObjectID) 
					throw new ApplicationException("Ожидается не-нулевой идентификатор объекта (атрибут id)!");
			}
			catch( Exception err )
			{
				throw new ConfigurationErrorsException( 
					String.Format( 
						"{0}: Некорретное {1} - значение атрибута id элемента {2} ({3})", 
						ERR_INCORRECT_CONFIG_DATA, 
						sElementDescr, 
						sElementPath,
						xmlElement.GetAttribute("id") 
					), err
				);
			}
			// ... пробуем загрузить описание объекта: 
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( sTargetObjectType, uidTargetObjectID );
			helper.LoadObject();
			
			return helper;
		}
	}
}