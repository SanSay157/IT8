//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
	/// Объектное представление конфигурационных параметров, используемых при 
	/// вызове метода создания заявки на обучение
	/// </summary>
	public class TrainingRequestProcessParams 
	{
		/// <summary>
		/// XPath-путь для набора параметров в файле конфигурации, в секции itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:business-process-methods/itws:on-training-request-process";

		#region Публичне поля - представления данных, задаваемых в конфигурации
		
		/// <summary>
		/// Вспомогательное представление ds-объекта "Папка" (Folder): папка, 
		/// в которой будет создан инцидент, соответствующий заявке на обучение
		/// </summary>
		public ObjectOperationHelper TargetFolder = ObjectOperationHelper.GetInstance( "Folder" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Тип инцидета" (IncidentType):
		/// тип для инцидента, соответствующего заявке на обучение
		/// </summary>
		public ObjectOperationHelper IncidentType = ObjectOperationHelper.GetInstance( "IncidentType" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Роль пользователя в 
		/// инциденте" (UserRoleInIncident): роль, назначаемая обучаемому 
		/// сотруднику в задании инцидента, соответствующего заявке 
		/// </summary>
		public ObjectOperationHelper Role_Trained = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Роль пользователя в 
		/// инциденте" (UserRoleInIncident): роль, назначаемая сотруднику-
		/// менеджеру по обучению, в задании инцидента, соответствующего заявке
		/// </summary>
		public ObjectOperationHelper Role_Manager = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
		/// (IncidentProp): определение доп. свойства "Номер курса / экзамена".
		/// Определение доп. свойства должно быть включено в определение типа
		/// инцидента, представленного объектом IncidentType; это проверяется
		/// на момент инициализации объектов - см. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_CourseNumber = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
		/// (IncidentProp): определение доп. свойства "Дата начала обучения".
		/// Определение доп. свойства должно быть включено в определение типа
		/// инцидента, представленного объектом IncidentType; это проверяется
		/// на момент инициализации объектов - см. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_CourseBeginningDate = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
		/// (IncidentProp): определение доп. свойства "Для получения статуса".
		/// Определение доп. свойства должно быть включено в определение типа
		/// инцидента, представленного объектом IncidentType; это проверяется
		/// на момент инициализации объектов - см. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_GoalStatus = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
		/// (IncidentProp): определение доп. свойства "Направление обучения".
		/// Определение доп. свойства должно быть включено в определение типа
		/// инцидента, представленного объектом IncidentType; это проверяется
		/// на момент инициализации объектов - см. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_TrainingDirection = ObjectOperationHelper.GetInstance( "IncidentProp" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
		/// (IncidentProp): определение доп. свойства "Учебный центр".
		/// Определение доп. свойства должно быть включено в определение типа
		/// инцидента, представленного объектом IncidentType; это проверяется
		/// на момент инициализации объектов - см. DelayLoad
		/// </summary>
		public ObjectOperationHelper Prop_TrainingCenter = ObjectOperationHelper.GetInstance( "IncidentProp" );

        /// <summary>
        /// Вспомогательное представление ds-объекта "Доп.свойство инцидента" 
        /// (IncidentProp): определение доп. свойства "Учебный центр".
        /// Определение доп. свойства должно быть включено в определение типа
        /// инцидента, представленного объектом IncidentType; это проверяется
        /// на момент инициализации объектов - см. DelayLoad
        /// </summary>
        public ObjectOperationHelper Prop_Summ = ObjectOperationHelper.GetInstance("IncidentProp");
		
		#endregion
		
		#region Публичне поля - представления данных, вычисляемых в процессе инициализации
		
		/// <summary>
		/// Экземпляр типа "Состояние инциента" (IncidentState) - стартовое 
		/// состоянию для инцидента типа, описываемого IncidentType.
		/// Объектное представление (helper); не прогружается (IsLoaded=false);
		/// Загружается на основании описания типа инцидента (см. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper EduIncident_StartState = ObjectOperationHelper.GetInstance( "IncidentState" );
		/// <summary>
		/// Приоритет инцидента по-умолчанию; загружается на основании описания 
		/// типа инцидента (см. DelayLoaded)
		/// </summary>
		public IncidentPriority EduIncident_DefaultPriority = IncidentPriority.NORMAL;
		/// <summary>
		/// Время, определенное на выполнение задания в инциденте для сотрудника
		/// - менеджера по обучению. Величина определяется на основании описания 
		/// типа инцидента, представленного IncidentType - см. DelayLoad
		/// </summary>
		public int DefaultDuration_for_ManagerRole = 0;
		/// <summary>
		/// Время, определенное на выполнение задания в инциденте для сотрудника
		/// - обучающегося. Величина определяется на основании описания типа 
		/// инцидента, представленного IncidentType - см. DelayLoad
		/// </summary>
		public int DefaultDuration_for_TrainedRole = 0;
		
		#endregion
		
		#region Отолженная инициализация
		
		/// <summary>
		/// Признак завершения отложенной проверки/загрузки данных
		/// </summary>
		protected bool m_bIsLoaded = false;
			
		/// <summary>
		/// Метод отложенной загрузки/проверки данных
		/// </summary>
		internal void DelayLoad() 
		{
			if (m_bIsLoaded)	
				return;
				
			// Проверка указанных данных:
			TargetFolder.CheckExistence( true );
			Prop_CourseNumber.CheckExistence( true );
			Prop_CourseBeginningDate.CheckExistence( true );
			Prop_GoalStatus.CheckExistence( true );
			Prop_TrainingDirection.CheckExistence( true );
			Prop_TrainingCenter.CheckExistence( true );
			// ... данные для типа инцидента и ролей загружаем полностью, 
			// что бы сделать потом внутреннюю проверку:
			IncidentType.LoadObject( new string[]{ "Props","States" } );
			Role_Trained.LoadObject( new string[]{ "IncidentType" } );
			Role_Manager.LoadObject( new string[]{ "IncidentType" } );
				
			// Проверка внутреннего соответствия:
			// ... тип инцидента для ролей должен совпадать с заданным в конфигурации:
			ObjectOperationHelper helperType;
			helperType = Role_Trained.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
					"Тип инцидента \"{0}\" для заданной роли itws:role-for-trained( id=\"{1}\" ) не соответствует типу инцидента itws:incident-type( id=\"{2}\" )",
					helperType.ObjectID.ToString(),
					Role_Trained.ObjectID.ToString(),
					IncidentType.ObjectID.ToString()
				));
			helperType = Role_Manager.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
					"Тип инцидента \"{0}\" для заданной роли itws:role-for-manager( id=\"{1}\" ) не соответствует типу инцидента itws:incident-type( id=\"{2}\" )",
					helperType.ObjectID.ToString(),
					Role_Manager.ObjectID.ToString(),
					IncidentType.ObjectID.ToString()
				));
				
			// ... все доп. свойства должны быть указаны в типе инцидента:
			XmlElement xmlProps = IncidentType.PropertyXml("Props");
			checkAuxPropExistence( xmlProps, "prop-for-course-number", Prop_CourseNumber );
			checkAuxPropExistence( xmlProps, "prop-for-course-beginning-date", Prop_CourseBeginningDate );
			checkAuxPropExistence( xmlProps, "prop-for-goal-status", Prop_GoalStatus );
			checkAuxPropExistence( xmlProps, "prop-for-training-direction", Prop_TrainingDirection );
			checkAuxPropExistence( xmlProps, "prop-for-training-center", Prop_TrainingCenter );
            checkAuxPropExistence(xmlProps, "prop-for-education-sum", Prop_Summ);

			// Фиксируем нужные нам для создания инцидента данные:
			// ... приоритет инцидента по умолчанию:
			EduIncident_DefaultPriority = (IncidentPriority)IncidentType.GetPropValue( "DefaultPriority",XPropType.vt_i2 );
			// ... начальное состояние инцидента; идентификатор объекта получаем
			// банальным XPath-запросом, опираясь на то, что свойство прогружено:
			XmlElement xmlDefaultState = (XmlElement)IncidentType.PropertyXml("States").SelectSingleNode( "IncidentState[IsStartState='1']" );
			if (null==xmlDefaultState)
				throw new InvalidOperationException( String.Format(
					"Для указанного типа инцидента (id={0}) неопределено стартовое состояние",
					IncidentType.ObjectID.ToString()
				));
			EduIncident_StartState.ObjectID = new Guid( xmlDefaultState.GetAttribute("oid") );
			// ...запланированное время для менеджера, по умолчанию:
			DefaultDuration_for_ManagerRole = (int)Role_Manager.GetPropValue( "DefDuration", XPropType.vt_i4 );
			// ...запланированное время для обучаемого, по умолчанию:
			DefaultDuration_for_TrainedRole = (int)Role_Trained.GetPropValue( "DefDuration", XPropType.vt_i4 );
				
			m_bIsLoaded = true;
		}

		
		/// <summary>
		/// Внутренний вспомогательный метод проверки
		/// </summary>
		/// <param name="xmlProps"></param>
		/// <param name="sPropName"></param>
		/// <param name="propHelper"></param>
		private void checkAuxPropExistence( XmlElement xmlProps, string sPropName, ObjectOperationHelper propHelper ) 
		{
			XmlNode xmlProp = xmlProps.SelectSingleNode( String.Format( "IncidentProp[@oid='{0}']", propHelper.ObjectID.ToString() ) );
			if (null == xmlProp)
				throw new InvalidOperationException( String.Format( 
					"Тип инцидента itws:incident-type( id=\"{0}\" ) не содержит определение доп. свойства {1}( id=\"{2}\" )",
					IncidentType.ObjectID,
					sPropName,
					propHelper.ObjectID
				));
		}
		
		
		#endregion
	}
	
	/// <summary>
	/// Объектное представление конфигурационных параметров, используемых при 
	/// вызове методов взаимодействия с системой CMDB (в частности, при создании
	/// нового инцидента - заявки на изменение)
	/// </summary>
	public class CmdbChangeRequestProcessParams 
	{
		/// <summary>
		/// XPath-путь для набора параметров в файле конфигурации, в секции itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:cmdb-process-methods/itws:on-change-request-process";

		#region Публичне поля - представления данных, задаваемых в конфигурации

		/// <summary>
		/// Вспомогательное представление ds-объекта "Тип инцидета" (IncidentType):
		/// тип для инцидента, соответствующего заявке на изменение
		/// </summary>
		public ObjectOperationHelper IncidentType = ObjectOperationHelper.GetInstance( "IncidentType" );
		/// <summary>
		/// Вспомогательное представление ds-объекта "Роль пользователя в 
		/// инциденте" (UserRoleInIncident): роль наблюдателя, назначаемая 
		/// сотруднику в задании инцидента - заявки на изменение
		/// </summary>
		public ObjectOperationHelper Role_Observer = ObjectOperationHelper.GetInstance( "UserRoleInIncident" );
		
		#endregion		

		#region Публичне поля - представления данных, вычисляемых в процессе инициализации

		/// <summary>
		/// Экземпляр типа "Состояние инциента" (IncidentState) - стартовое 
		/// состоянию для инцидента типа, описываемого IncidentType.
		/// Объектное представление (helper); не прогружается (IsLoaded=false);
		/// Загружается на основании описания типа инцидента (см. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper ChangeIncident_StartState = ObjectOperationHelper.GetInstance( "IncidentState" );
		/// <summary>
		/// Приоритет инцидента по-умолчанию; загружается на основании описания 
		/// типа инцидента (см. DelayLoaded)
		/// </summary>
		public IncidentPriority ChangeIncident_DefaultPriority = IncidentPriority.NORMAL;
		/// <summary>
		/// Время, определенное на выполнение задания в инциденте для сотрудника
		/// - наблюдателя. Величина определяется на основании описания типа 
		/// инцидента, представленного IncidentType - см. DelayLoad
		/// </summary>
		public int DefaultDuration_for_ObserverRole = 0;
		/// <summary>
		/// Экземпляр типа "Тип внешней ссылки" (ExternalLinkType), определяющий
		/// внешнюю ссылку в инциденте как URL - используется для корректного
		/// заведения всех ссылок в инциденте.
		/// Объектное представление (helper); загружается отложено (см. DelayLoaded)
		/// </summary>
		public ObjectOperationHelper LinkType_URL = ObjectOperationHelper.GetInstance( "ExternalLinkType" );

		#endregion

		#region Отолженная инициализация
		
		/// <summary>
		/// Признак завершения отложенной проверки/загрузки данных
		/// </summary>
		protected bool m_bIsLoaded = false;
			
		/// <summary>
		/// Метод отложенной загрузки/проверки данных
		/// </summary>
		internal void DelayLoad() 
		{
			if (m_bIsLoaded)	
				return;
				
			// Данные для типа инцидента и роли загружаем полностью, 
			// что бы сделать потом внутреннюю проверку:
			IncidentType.LoadObject( new string[]{ "Props","States" } );
			Role_Observer.LoadObject( new string[]{ "IncidentType" } );
				
			// Проверка внутреннего соответствия:
			// ... тип инцидента для ролей должен совпадать с заданным в конфигурации:
			ObjectOperationHelper helperType;
			helperType = Role_Observer.GetInstanceFromPropScalarRef("IncidentType");
			if ( helperType.ObjectID != IncidentType.ObjectID )
				throw new InvalidOperationException( String.Format( 
						"Тип инцидента \"{0}\" для заданной роли itws:role-for-observer( id=\"{1}\" ) не соответствует типу инцидента itws:incident-type( id=\"{2}\" )",
						helperType.ObjectID.ToString(),
						Role_Observer.ObjectID.ToString(),
						IncidentType.ObjectID.ToString()
					));

			// Фиксируем нужные нам для создания инцидента данные:
			// ... приоритет инцидента по умолчанию:
			ChangeIncident_DefaultPriority = (IncidentPriority)IncidentType.GetPropValue( "DefaultPriority",XPropType.vt_i2 );
			// ... начальное состояние инцидента; идентификатор объекта получаем
			// банальным XPath-запросом, опираясь на то, что свойство прогружено:
			XmlElement xmlDefaultState = (XmlElement)IncidentType.PropertyXml("States").SelectSingleNode( "IncidentState[IsStartState='1']" );
			if (null==xmlDefaultState)
				throw new InvalidOperationException( String.Format(
						"Для указанного типа инцидента (id={0}) стартовое состояние не определено",
						IncidentType.ObjectID.ToString()
					));
			ChangeIncident_StartState.ObjectID = new Guid( xmlDefaultState.GetAttribute("oid") );
			// ...запланированное время для наблюдателя, по умолчанию:
			DefaultDuration_for_ObserverRole = (int)Role_Observer.GetPropValue( "DefDuration", XPropType.vt_i4 );
				
			// Отдельно прямым запросом в БД определям тип внешней ссылки 
			// для определения URL, по ее классу:
			XParamsCollection keys = new XParamsCollection();
			keys.Add( "ServiceType", (int)ServiceSystemType.URL );
			LinkType_URL.LoadObject( keys );
			
			m_bIsLoaded = true;
		}

		
		#endregion
	}
	
	/// <summary>
	/// Класс, представляющий объектное представление конфигурационных данных 
	/// "общего" сервиса получения данных по списаниям, CommonService
	/// </summary>
	public class ExpensesProcessPrarms
	{
		/// <summary>
		/// XPath-путь для набора параметров в файле конфигурации, в секции itws:common-service
		/// </summary>
		public static readonly string DEF_Config_XPath = "itws:expenses-process-methods/itws:get-employees-expenses-process";
		
		
		/// <summary>
		/// Строка с перечнем идентификаторов подразделений, сотрудники которых 
		/// не регистрируют время в Incident Tracker
		/// </summary>
		private string m_sEmpExpenses_ExceptedDepsList = null;
		
		/// <summary>
		/// Строка с перечнем идентификаторов подразделений, сотрудники которых 
		/// не регистрируют время в Incident Tracker
		/// </summary>
		public string EmpExpenses_ExceptedDepsList
		{
			get { return m_sEmpExpenses_ExceptedDepsList; }
		}
		
		/// <summary>
		/// Параметризированный конструктор
		/// Выполняет до-загрузку данных о подчиненных подразделениях, если 
		/// это требуется в соответствии с заданными параметрами конфигурации
		/// </summary>
		/// <param name="xmlList_ExceptedDepsList">
		/// Перечень элемментов itws:department из секции itws:excepted-departments.
		/// Может быть null или пустым.
		/// </param>
		public ExpensesProcessPrarms( XmlNodeList xmlList_ExceptedDepsList ) 
		{
			StringBuilder sbExceptedDepsList = new StringBuilder();
			StringBuilder sbExceptedDepsWithNestedList = new StringBuilder();
			if ( null != xmlList_ExceptedDepsList && 0!=xmlList_ExceptedDepsList.Count )
			{
				// Перебор всех элементов конфигурации; формируется две строки - 
				// перечень идентификаторов подразделений "как есть" и перечень
				// идентификаторов подразделений, для которых еще надо определить
				// подчиненных:
				foreach( XmlElement xmlExceptedDep in xmlList_ExceptedDepsList  )
				{
					if ( null==xmlExceptedDep )
						continue;
					string sDepID = xmlExceptedDep.GetAttribute( "id" );
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sDepID, "Идентификатор подразделения (" + sDepID + ")" );
					
					if ( String.Empty == xmlExceptedDep.GetAttribute("include-nested") )
						sbExceptedDepsList.Append( sDepID ).Append( "," );
					else
						sbExceptedDepsWithNestedList.Append( sDepID ).Append( "," );
				}
				
				// Если есть такие, для которых надо определить подчиненных, то 
				// выполняем действия по дозагрузке: получение данных с сервера:
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
			
			// Итоговый список
			if ( sbExceptedDepsList.Length > 0 )
				sbExceptedDepsList.Length -= 1;
			m_sEmpExpenses_ExceptedDepsList = sbExceptedDepsList.ToString();
		}
	}
	
	/// <summary>
	/// Класс, представляющий объектное представление конфигурационных данных 
	/// "общего" сервиса взаимодействия с внешними системами, CommonService
	/// </summary>
	public class CommonServiceConfigParams 
	{
		/// <summary>
		/// Объектное представление конфигурационных данных секции 
		/// itws:business-process-methods/itws:on-training-request-process
		/// </summary>
		private TrainingRequestProcessParams m_TrainingRequestProcessParams = null;
		/// <summary>
		/// Объектное представление конфигурационных данных секции 
		/// itws:business-process-methods/itws:on-change-request-process
		/// </summary>
		private CmdbChangeRequestProcessParams m_CmdbChangeRequestProcessParams = null;
		/// <summary>
		/// Объектное представление конфигурационных данных секции 
		/// itws:expenses-process-methods/itws:get-employees-expenses-process
		/// </summary>
		private ExpensesProcessPrarms m_ExpensesProcessPrarms = null;
		
		/// <summary>
		/// Возвращает объектное представление конфигурационных данных секции 
		/// itws:business-process-methods/itws:on-training-request-process
		/// </summary>
		public TrainingRequestProcessParams TrainingRequestProcess 
		{
			get
			{
				if (null==m_TrainingRequestProcessParams)
					throw new ApplicationException( "Конфигурационные данные, необходимые для обслуживания метода создания заявки на обучение, не определены!" );
				m_TrainingRequestProcessParams.DelayLoad();
				return m_TrainingRequestProcessParams;
			}
		}

		
		/// <summary>
		/// Возвращает объектное представление конфигурационных данных секции 
		/// itws:business-process-methods/itws:on-change-request-process
		/// </summary>
		public CmdbChangeRequestProcessParams ChangeRequestProcess 
		{
			get
			{
				if (null==m_CmdbChangeRequestProcessParams)
					throw new ApplicationException( "Конфигурационные данные, необходимые для обслуживания метода создания заявки на изменение сервиса CMDB, не определены!" );
				m_CmdbChangeRequestProcessParams.DelayLoad();
				return m_CmdbChangeRequestProcessParams;
			}
		}
		
		
		/// <summary>
		/// Возвращает объектное представление конфигурационных данных секции 
		/// itws:expenses-process-methods/itws:get-employees-expenses-process
		/// </summary>
		public ExpensesProcessPrarms ExpensesProcess 
		{
			get
			{
				if (null==m_ExpensesProcessPrarms)
					throw new ApplicationException( "Конфигурационные данные, необходимые для обслуживания методов получения данных по списаниям, не определены!" );
				return m_ExpensesProcessPrarms;
			}
		}
		

		/// <summary>
		/// Конструктор объекта;
		/// Инициализирует данные на основании XML-данных конфигурационного файла
		/// </summary>
		/// <param name="config"></param>
		internal CommonServiceConfigParams( ServiceConfig config ) 
		{
			XmlElement xmlSvcElement = (XmlElement)config.SelectNode( "itws:common-service" );
			if (null==xmlSvcElement) 
				throw new ConfigurationErrorsException( String.Format( 
					"{0}: Секции конфигурационных параметров общего сервиса (элемент itws:common-service) в файле конфигурации нет", 
					ServiceConfig.ERR_INCORRECT_CONFIG_DATA 
				));
			
			#region #1: Данные для методов создания заявки на обучение
			
			XmlElement xmlElement = (XmlElement)xmlSvcElement.SelectSingleNode( TrainingRequestProcessParams.DEF_Config_XPath, config.NSManager );
			if (null!=xmlElement)
			{
				m_TrainingRequestProcessParams = new TrainingRequestProcessParams();
				
				// ...Элемент itws:target-folder - целевая папка	
                XmlElement xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:target-folder", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:target-folder не задан" );
				m_TrainingRequestProcessParams.TargetFolder.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:incident-type - тип инцидента
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:incident-type", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:incident-type не задан" );
				m_TrainingRequestProcessParams.IncidentType.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:role-for-trained - роль для обучаемого
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-trained", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:role-for-trained не задан" );
				m_TrainingRequestProcessParams.Role_Trained.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:role-for-manager - роль для менеджера
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-manager", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:role-for-manager не задан" );
				m_TrainingRequestProcessParams.Role_Manager.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:prop-for-course-number - тип доп.свойства, "Номер курса"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-course-number", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-course-number не задан" );
				m_TrainingRequestProcessParams.Prop_CourseNumber.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:prop-for-course-beginning-date - тип доп.свойства, "Дата начала обучения"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-course-beginning-date", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-course-beginning-date не задан" );
				m_TrainingRequestProcessParams.Prop_CourseBeginningDate.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:prop-for-goal-status - тип доп. свойства, "Целевой статус"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-goal-status", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-goal-status не задан" );
				m_TrainingRequestProcessParams.Prop_GoalStatus.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:prop-for-training-direction - тип доп. свойства, "Направление обучения"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-training-direction", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-training-direction не задан" );
				m_TrainingRequestProcessParams.Prop_TrainingDirection.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:prop-for-training-center - тип доп. свойства, "Центр обучения"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-training-center", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-training-center не задан" );
				m_TrainingRequestProcessParams.Prop_TrainingCenter.ObjectID = new Guid( xmlParam.GetAttribute("id") );

                // ...Элемент itws:prop-for-training-center - тип доп. свойства, "Центр обучения"
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:prop-for-education-sum", config.NSManager);
                if (null == xmlParam) throw new ApplicationException("Параметр itws:prop-for-education-sum не задан");
                m_TrainingRequestProcessParams.Prop_Summ.ObjectID = new Guid(xmlParam.GetAttribute("id"));
			}
			#endregion

			#region #2: Данные для методов создания взаимодействия с CMDB

            xmlElement = (XmlElement)xmlSvcElement.SelectSingleNode(CmdbChangeRequestProcessParams.DEF_Config_XPath, config.NSManager);
			if (null!=xmlElement)
			{
				m_CmdbChangeRequestProcessParams = new CmdbChangeRequestProcessParams();
				
				// ...Элемент itws:incident-type - тип инцидента
                XmlElement xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:incident-type", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:incident-type не задан" );
				m_CmdbChangeRequestProcessParams.IncidentType.ObjectID = new Guid( xmlParam.GetAttribute("id") );
				
				// ...Элемент itws:role-for-trained - роль для обучаемого
                xmlParam = (XmlElement)xmlElement.SelectSingleNode("itws:role-for-observer", config.NSManager);
				if (null == xmlParam) throw new ApplicationException("Параметр itws:role-for-observer не задан" );
				m_CmdbChangeRequestProcessParams.Role_Observer.ObjectID = new Guid( xmlParam.GetAttribute("id") );
			}
			#endregion
			
			#region #3: Данные для методов получения данных списаний

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