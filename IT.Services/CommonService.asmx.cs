//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Web.Services;
using System.Xml;
using System.Xml.Serialization;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using System.Security.Principal;
using System.Threading;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Общий сервис системы Incident Tracker
	/// </summary>
	[WebService(
		 Name="CommonService",
		 Namespace="http://www.croc.ru/Namespaces/IncientTracker/WebServices/CommonService/1.0",
		 Description=
			"Система оперативного управления проектами Incident Tracker : " +
			"Общий сервис обеспечения взаимодействия с внешними системами" )
	]
	public class CommonService
	{
        /// <summary>
		/// Конструктор объекта
		/// </summary>
		public CommonService() 
		{
			ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
		}

		#region Внутренние вспомогательные методы

		/// <summary>
		/// "Безопасное" чтение данных строковых свойств, значения которых могут 
		/// быть NULL-ом: в этом случае метод так же возвращает null.
		/// </summary>
		/// <param name="helper">Вспомогательный объект с данными</param>
		/// <param name="sPropName">Наименование свойства (д.б. в объекте!)</param>
		private static string safeReadData( ObjectOperationHelper helper, string sPropName ) 
		{
			object oData = helper.GetPropValue( sPropName, XPropType.vt_string, false );
			return ( null==oData ? null : oData.ToString() );
		}

      	/// <summary>
		/// "Безопасное" приведение данных объекта из БД в строку.
		/// Обыгрывает значения DBNull и пустую строку как null.
		/// </summary>
		/// <param name="oDbData"></param>
		/// <returns></returns>
		private string safeDbString2String( object oDbData ) 
		{
			if ( null==oDbData || DBNull.Value == oDbData )
				return null;
			string sResult = oDbData.ToString();
			return ( String.Empty==sResult? null : sResult );
		}

		
		#endregion

		#region Методы получения данных констант, представленнех в системе Incident Tracker

		/// <summary>
		/// Перечень констант, значения которых задаются в системе IT
		/// </summary>
		public enum ITConstants 
		{
			/// <summary>
			/// Базовый URL-адрес стартовой страницы системы IT, 
			/// для внутренней закрытой сети
			/// </summary>
			UnsecuredInternalSystemBaseURL,

			/// <summary>
			/// Базовый URL-адрес стартовой страницы системы IT, 
			/// для внешнего Internet-доступа 
			/// </summary>
			SecuredExternalSystemBaseURL
		}
		

		#endregion
		#region Общие методы сервиса CommonService
		/// <summary>
		/// Получение списка описаний направления деятельности (в версии 5.х 
		/// называлось "видами деятельности")
		/// </summary>
		/// <returns>
		/// Документ XML с данными списка направлений; каждая запись содержит:
		///		- внутренний идентификатор направления в системе IT (в формате GUID)
		///		- идентификатор направления в системе НСИ (длинное целое)
		///		- наименование направления (строка)
		/// </returns>
		[WebMethod]
        public string[] GetDirectionsList()
        {

            // Получаем данные всех направлений:
            DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-Directions", null);
            if (null == oDataTable)
                return new string[0];
            String[] Directions = new String[oDataTable.Rows.Count];
            for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
            {
                Directions[nRowIndex] = oDataTable.Rows[nRowIndex]["DirectionID"].ToString();
            }
            return Directions;

        }
        #endregion

		#region Методы взаимодействия с системой Oracle HRMS

		/// <summary>
		/// Создание "бланка" XML-документа - результата, возвращаемого при вызове
		/// метода GetProjectsParticipants. Полное описание формата XML-результата 
		/// приведено в ФС "Взаимодействие с внешними системами".
		/// </summary>
		/// <param name="nCode"></param>
		/// <param name="sErrDescription"></param>
		/// <param name="sErrSatck"></param>
		/// <returns></returns>
		private XmlDocument createHrmsResultBlank( int nCode, string sErrDescription, string sErrSatck )
		{
			XmlDocument xmlBlank = new XmlDocument();
			
			// Корневой элемент:
			XmlElement xmlRoot = xmlBlank .CreateElement( "Result" );
			xmlBlank.AppendChild(xmlRoot);

			// Секция статуса (Result/Status):
			XmlElement xmlSection = xmlBlank.CreateElement( "Status" );
			xmlRoot.AppendChild( xmlSection );
			
			// Наполнение секции статуса:
			// ... код (Result/Status/Code):
			XmlElement xmlElement = xmlBlank.CreateElement( "Code" );
			xmlElement.InnerText = nCode.ToString();
			xmlSection.AppendChild( xmlElement );
			// ... описание ошибки (Result/Status/Descr):
			xmlElement = xmlBlank.CreateElement( "Descr" );
			if ( null!=sErrDescription )
				xmlElement.AppendChild( xmlBlank.CreateCDataSection( sErrDescription ) );
			xmlSection.AppendChild( xmlElement );
			// ... стек ошибки (Result/Status/Stack):
			xmlElement = xmlBlank.CreateElement( "Stack" );
			if ( null!=sErrSatck )
				xmlElement.AppendChild( xmlBlank.CreateCDataSection( sErrSatck ) );
			xmlSection.AppendChild( xmlElement );

			// Секция данных (Result/Data):
			xmlSection = xmlBlank.CreateElement( "Data" );
			xmlRoot.AppendChild( xmlSection );

			return xmlBlank;
		}

		
		/// <summary>
		/// Получение списка участников проектных команд активностей, в которых 
		/// в заданный период времени работал заданный (целевой) сотрудник.
		/// </summary>
		/// <param name="uidTargetEmployeeID">Идентификатор целевого сотрудника</param>
		/// <param name="dtPeriodBeginDate">Дата начала анализируемого периода (включительно)</param>
		/// <param name="dtPeriodEndDate">Дата завершения анализируемого периода (включительно)</param>
		/// <returns>
		/// Форматированный XML-документ, представляющий данные об проектах и их 
		/// участниках. Полное описание формата XML-результата приведено в ФС
		/// "Взаимодействие с внешними системами".
		/// </returns>
		[WebMethod( Description="Получение списка проектов и их участников, в которых указанный сотрудник в заданный период принимал участие" )]
		public XmlDocument GetProjectsParticipants(
			Guid uidTargetEmployeeID,
			DateTime dtPeriodBeginDate,
			DateTime dtPeriodEndDate ) 
		{
			// Данные - результат:
			XmlDocument xmlResult = null; 

			try 
			{
				// Проверка параметров:
				ObjectOperationHelper.ValidateRequiredArgument( uidTargetEmployeeID, "Сотрудник, для которого выполняется расчет (uidTargetEmployeeID)" );

				// Формируем параметры для вызова источника данных (в котором прописан 
				// вызов хранимой процедуры - см. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "uidEmployee", uidTargetEmployeeID );	// Идентификатор целевого сотрудника
				procParams.Add( "dtPeriodBegin", dtPeriodBeginDate );	// Дата начала анализируемого периода
				procParams.Add( "dtPeriodEnd", dtPeriodEndDate );		// Дата завершения анализируемого периода
				procParams.Add( "nThresholdForTargetEmp", 600 );		// Порог затрат для целевого сотруднника (NB! КОНСТАНТА!)
				procParams.Add( "nThresholdForOtherEmp", 60 );			// Порог затрат для др. сотруднников команды (NB! КОНСТАНТА!)
				procParams.Add( "nFolderTypeMask", 1 );					// Типы анализируемых активностей (NB! КОНСТАНТА!)
				procParams.Add( "bPassOwnOrg", 0 );						// Признак пропуска данных организации - владельца(NB! КОНСТАНТА!)
			
				// Вызов источника данных и формирование специального XML-результата
				// вида <Data><p id='...' user='...' role='...'/> ... <Data>
				// Форматирование XML-результата осуществляется на основании специальных
				// наименований колонок результирующего набора форматтером 
				// DataTableCodeNamedXmlFormatter - см. комментарии к реализации
				DataTable data = ObjectOperationHelper.ExecAppDataSource( "CommonService-Interop-GetProjectsParticipants", procParams );
				DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter( "Data" );
				XmlDocument xmlData = formatter.FormatNamedDataTable( data, "p" );

				// Формируем результирующие данные: изначально загружаем XML-текст,
				// описывающий результат с "хорошим" статусом - нулевым кодом и пустыми
				// элементами, описывающими ошибку (Descr и Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... импортируем данные, полученные в результате вызова 
				// источника данных и отформатированные:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" )
				);
			}
			catch( Exception err )
			{
				// Формируем результат, описывающий ошибку: элемент Code задан в (-1),
				// элементы Descr и Stack содержат описание и стек ошибки соответственно:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... саму ошибку при этом - ДАВИМ! */
			}
			return xmlResult;
		}

		
		/// <summary>
		/// Получение описания проектной команды для заданной активности, члены которой
		/// осуществляли списания в заданный период времени.
		/// </summary>
		/// <param name="uidTargetActivityID">Идентификатор целевой активности</param>
		/// <param name="dtPeriodBeginDate">Дата начала анализируемого периода (включительно)</param>
		/// <param name="dtPeriodEndDate">Дата завершения анализируемого периода (включительно)</param>
		/// <returns>
		/// Форматированный XML-документ, представляющий данные об участника проектной
		/// команды, определенной для указанной активности. Полное описание формата 
		/// XML-результата приведено в ФС "Взаимодействие с внешними системами".
		/// </returns>
		[WebMethod( Description="Получение описания проектной команды для активности, члены которой осуществляли списания в заданный период времени" )]
		public XmlDocument GetAllProjectParticipants(
			Guid uidTargetActivityID,
			DateTime dtPeriodBeginDate,
			DateTime dtPeriodEndDate )
		{
			// Данные - результат:
			XmlDocument xmlResult = null; 

			try 
			{
				// Проверка параметров:
				ObjectOperationHelper.ValidateRequiredArgument( uidTargetActivityID, "Активность, для которой определяется проектная команда (uidTargetActivityID)" );

				// Формируем параметры для вызова источника данных (в котором прописан 
				// вызов хранимой процедуры - см. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "uidActivity", uidTargetActivityID );	// Идентификатор целевой активности
				procParams.Add( "dtPeriodBegin", dtPeriodBeginDate );	// Дата начала анализируемого периода
				procParams.Add( "dtPeriodEnd", dtPeriodEndDate );		// Дата завершения анализируемого периода
			
				// Вызов источника данных и формирование специального XML-результата
				// вида <Data><p user='...' role='...'/> ... <Data>
				// Форматирование XML-результата осуществляется на основании специальных
				// наименований колонок результирующего набора форматтером 
				// DataTableCodeNamedXmlFormatter - см. комментарии к реализации
				DataTable data = ObjectOperationHelper.ExecAppDataSource( "CommonService-Interop-GetAllProjectParticipants", procParams );
				DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter( "Data" );
				XmlDocument xmlData = formatter.FormatNamedDataTable( data, "p" );

				// Формируем результирующие данные: изначально загружаем XML-текст,
				// описывающий результат с "хорошим" статусом - нулевым кодом и пустыми
				// элементами, описывающими ошибку (Descr и Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... импортируем данные, полученные в результате вызова 
				// источника данных и отформатированные:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" ) );
			}
			catch( Exception err )
			{
				// Формируем результат, описывающий ошибку: элемент Code задан в (-1),
				// элементы Descr и Stack содержат описание и стек ошибки соответственно:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... саму ошибку при этом - ДАВИМ! */
			}
			return xmlResult;
		}
        /// <summary>
        /// Получение списаний сотрудников по заданной причине списания, в заданный диапазон времени.
        /// </summary>
        /// <param name="sCauseID">Идентификатор причины списания</param>
        /// <param name="dtPeriodBegin">Начало периода</param>
        /// <param name="dtPeriodEnd">Конец периода</param>
        /// <returns></returns>
        [WebMethod(Description = "Метод получение информации о списаниях пользователей в заданнй период времени по заданной причине списаний")]
        public XmlDocument GetEmployeesExpensesWithCause(
            string sCauseID,
            DateTime dtPeriodBegin,
            DateTime dtPeriodEnd)
        {
            // Данные - результат:
            XmlDocument xmlResult = null;
            try
            {
                Guid uidCauseID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCauseID, "Идентификатор причины списания");
                XParamsCollection procParams = new XParamsCollection();
                procParams.Add("uidCauseID", uidCauseID);	// Идентификатор причины списания
                procParams.Add("dtPeriodBeginDate", dtPeriodBegin);	// Дата начала  периода
                procParams.Add("dtPeriodEndDate", dtPeriodEnd); // Дата конца периода

                DataTable data = ObjectOperationHelper.ExecAppDataSource("GetEmployeeExpensesWithCause", procParams);
                DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter("Data");
                XmlDocument xmlData = DataTableXmlFormatter.GetXmlFromDataTable(data, "Data", "row");
                // Формируем результирующие данные: изначально загружаем XML-текст,
                // описывающий результат с "хорошим" статусом - нулевым кодом и пустыми
                // элементами, описывающими ошибку (Descr и Stack):
                xmlResult = createHrmsResultBlank(0, null, null);
                // ... импортируем данные, полученные в результате вызова 
                // источника данных и отформатированные:
                xmlResult.DocumentElement.ReplaceChild(
                    xmlResult.ImportNode(xmlData.DocumentElement, true),
                    xmlResult.SelectSingleNode("Result/Data"));
            }
            catch (Exception e)
            {
                // Формируем результат, описывающий ошибку: элемент Code задан в (-1),
                // элементы Descr и Stack содержат описание и стек ошибки соответственно:
                xmlResult = createHrmsResultBlank(-1, e.Message, e.StackTrace);
            }

            return xmlResult;
        }
		


		#endregion
	
	
		#region Методы обеспечения взаимодействия с автоматизированными бизнес-процессами

		/// <summary>
		/// Внутренний метод; формирует овспомогательный объект, заполненный
		/// данными "дополнительного свойства" инцидента, реальное значение
		/// которого передается параметром
		/// </summary>
		/// <param name="helperIncident">Вспомогательный объект с данными инцидента</param>
		/// <param name="helperPropType">Вспомогательный объект с данными ТИПА доп. свойства</param>
		/// <param name="helperPropValueTemplate">Вспомогательный объект с "болванкой" доп. свойства - НЕ МЕНЯЕТСЯ</param>
		/// <param name="oRealPropValue">Реальное значене - или строка, или дата/время, или null</param>
		/// <returns>
		///	Результат зависит от реального значения:
		/// -- если реальное значение есть null, то и результат есть null;
		/// -- если реальное значение есть DateTime.MinValue, то результат есть null;
		/// -- иначе - экземпляр заполненного объекта, описывающего свойства 
		/// инцидента; ВНИМАНИЕ! В этом случае так же меняются данные инцидента
		/// представленного helper-ом helperIncident - тут проставляются ссылки
		/// в массивном объектом свойстве Props!
		/// </returns>
		private static ObjectOperationHelper applayAdditionalIncidentProp( 
			ObjectOperationHelper helperIncident,
			ObjectOperationHelper helperPropType,
			ObjectOperationHelper helperPropValueTemplate,
			object oRealPropValue ) 
		{
			// Если реальное значение свойства есть null, то и возвращаем null:
			if ( null==oRealPropValue )
				return null;
			
			// В качестве реального значения принимается или строка или дата-время:
			Type realPropValueType = oRealPropValue.GetType();
			if ( realPropValueType!=typeof(string) && realPropValueType!=typeof(DateTime) && realPropValueType!= typeof(decimal))
				throw new ArgumentException( 
					"В качестве реального значения дополнительного свойства допускается или строка " +
					"или дата/время; заданное значение имеет тип " + realPropValueType.Name, 
					"oRealPropValue" );
			// Если реальное значение есть дата/время и оно задано в MinValue, то 
			// интерпретируем это как "null"-значение, и значит возвращаем null:
			if ( typeof(DateTime)==realPropValueType && DateTime.MinValue==(DateTime)oRealPropValue )
				return null;
			
			// #1: Копируем "болванку"; саму болванку при этом никак не меняем
			if (null == helperPropValueTemplate) throw new ApplicationException();
			if (!helperPropValueTemplate.IsLoaded) throw new ApplicationException();
			ObjectOperationHelper helperPropValue = ObjectOperationHelper.CloneFrom( helperPropValueTemplate, false );
			if (!helperPropValue.IsLoaded) throw new ApplicationException();
			
			// #2: Записываем само значение свойства:
			if ( realPropValueType==typeof(DateTime) )
            {
				helperPropValue.SetPropValue( "DateData", XPropType.vt_dateTime, oRealPropValue );
            }
            else if (realPropValueType==typeof(decimal))
            {
                helperPropValue.SetPropValue("NumericData", XPropType.vt_fixed, oRealPropValue);
            }
			else 
            {
				helperPropValue.SetPropValue( "StringData", XPropType.vt_string, oRealPropValue );
            }
				
			// #3: Ссылки:
			// Ссылка на тип свойства:
            
            helperPropValue.SetPropScalarRef("IncidentProp", helperPropType.TypeName, helperPropType.ObjectID);
            // Ссылка на инцидент:
            helperPropValue.SetPropScalarRef("Incident", helperIncident.TypeName, helperIncident.NewlySetObjectID);
            // Ссылка на свойство в самом инциденте:
            helperIncident.AddArrayPropRef("Props", helperPropValue.TypeName, helperPropValue.NewlySetObjectID);
        	return helperPropValue;
		}

		
		/// <summary>
		/// Метод создания запроса на обучение, как инцидента соответствующего типа.
		/// </summary>
		/// <param name="sInitiatorEmployeeID"></param>
		/// <param name="sTrainedEmployeeID"></param>
		/// <param name="sRequestFormalName"></param>
		/// <param name="sRequestDescription"></param>
		/// <param name="dtDeadLine"></param>
		/// <param name="sPropCourseOrExamNumber"></param>
		/// <param name="sPropGoalStatus"></param>
		/// <param name="dtPropCourseBeginningDate"></param>
		/// <param name="sPropTrainingDirection"></param>
		/// <param name="sPropTrainingCenter"></param>
        /// <param name="sCategoryID"></param>
        /// <param name="dSum"></param>
		/// <returns></returns>
		[WebMethod( Description="" )]
		public BP_EducationRequestResult CreateEducationRequest(
			string sInitiatorEmployeeID,
			string sTrainedEmployeeID,
			string sRequestFormalName,
			string sRequestDescription,
			DateTime dtDeadLine,
			string sPropCourseOrExamNumber,
			string sPropGoalStatus,
			DateTime dtPropCourseBeginningDate,
			string sPropTrainingDirection,
			string sPropTrainingCenter, 
            string sCategoryID,
            decimal dSum) 
		{
			BP_EducationRequestResult result = new BP_EducationRequestResult();
			try 
			{
				// Прежде всего - проверка корректности входных параметров:
				Guid uidInitiatorEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "Иднтификатор сотрудника - инициатора заявки на обучение (sInitiatorEmployeeID)" );
				Guid uidTrainedEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sTrainedEmployeeID, "Идентификатор сотрудника - обучающегося (sTrainedEmployeeID)" );
                Guid uidCategoryID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCategoryID, "Идентификатор категории инцидента (sCategoryID)");
                ObjectOperationHelper.ValidateRequiredArgument( sRequestFormalName, "Формальное наименование заявки на обучение (sRequestFormalName)" );
			
				#region #1: ЗАГРУЖАЕМ ОСНОВЫ:
				// ... "болванка" ds-объекта "Инцидент":
				ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance( "Incident" );
				helperIncident.LoadObject();
				if (!helperIncident.IsLoaded) throw new ApplicationException();
				#endregion
				
				#region #2: ФОРМИРУЕМ ДАННЫЕ ИНЦИДЕНТА:
				// Главное - объектные ссылки, определяющие папку/проект, тип 
				// инцидента, его характеристики - все на основании данных из
				// конфигурации:
				// ... папка, в которой будет создан инцидент:
                // ... тип инцидента:
				helperIncident.SetPropScalarRef(
					"Type",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.TypeName,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.ObjectID );
				// ... стартовое состоения инцидента (определяется на основании 
				// типа, см. реализацию TrainingRequestProcess.DelayLoad):
				helperIncident.SetPropScalarRef(
					"State",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.TypeName,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.ObjectID );
				// ... приоритет инцидента по умолчанию (на основании типа) - по 
				// сути скалярная НЕ объектная ссылка, здесь - по смыслу:
				helperIncident.SetPropValue( 
					"Priority", 
					XPropType.vt_i2, 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_DefaultPriority );

				// Данные, заданные параметрами метода: 
				// ... наименование...
				helperIncident.SetPropValue( "Name", XPropType.vt_string, sRequestFormalName );
				// ... если задано - описание:
				if (null!=sRequestDescription && String.Empty!=sRequestDescription)
					helperIncident.SetPropValue( "Descr", XPropType.vt_string, sRequestDescription );
				// ... если задан - крайний срок:
				if (DateTime.MinValue != dtDeadLine)
					helperIncident.SetPropValue( "DeadLine", XPropType.vt_date, dtDeadLine );
				// Категория инц-та
                helperIncident.SetPropScalarRef("Category", "IncidentCategory", uidCategoryID);

				// ... сотрудник-инициатор: на самом деле в инциденте хранится сслыка
				// на ПОЛЬЗОВАТЕЛЯ, а не сотрудника (это разделенные объекты); поэтому
				// сначала определим пользователя для указанного сотрудника: прогрузим
				// данные сотрудника:
				ObjectOperationHelper helperIniciator = ObjectOperationHelper.GetInstance( "Employee", uidInitiatorEmployeeID );
				helperIniciator.LoadObject(); // (если указан несуществующий, здесь будет исключение)
				if (!helperIniciator.IsLoaded) throw new ApplicationException();
				// ...получаем идентификационные данные пользователя (не прогружаем!)
				// и используя их проставим ссылку на инициатора в инциденте:
				ObjectOperationHelper helperIniciatorUser = helperIniciator.GetInstanceFromPropScalarRef( "SystemUser" );
				helperIncident.SetPropScalarRef( 
					"Initiator",
					helperIniciatorUser.TypeName,
					helperIniciatorUser.ObjectID );
				#endregion
				
				#region #3: ФОРМИРУЕМ ДАННЫЕ ЗАДАНИЙ:
				// ... загружаем "болванку" экземпляра ds-объекта "Задание":
				ObjectOperationHelper helperTrainedTask = ObjectOperationHelper.GetInstance("Task");
                helperTrainedTask.LoadObject();
				if (!helperTrainedTask.IsLoaded) throw new ApplicationException();
				
				int nDefaultDuration = ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.DefaultDuration_for_ManagerRole;
				
				// ...для ОБУЧАЕМОГО (повторяем аналогично):
				// (запланированное, оно же оставшееся время на задание, по умолчанию)
				nDefaultDuration = ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.DefaultDuration_for_TrainedRole;
				helperTrainedTask.SetPropValue( "PlannedTime", XPropType.vt_i4, nDefaultDuration );	
				helperTrainedTask.SetPropValue( "LeftTime", XPropType.vt_i4, nDefaultDuration );
				// ... время создания и изменения времени на задание:
				helperTrainedTask.SetPropValue( "InputDate", XPropType.vt_date, DateTime.Today );
				helperTrainedTask.SetPropValue( "LeftTimeChanged", XPropType.vt_dateTime, DateTime.Now );
				// ... ссылки: на инцидент:
				helperTrainedTask.SetPropScalarRef( 
					"Incident", 
					helperIncident.TypeName, 
					helperIncident.NewlySetObjectID );
				// ... на роль исполнителя в инциденте; берем из конфигурации, для ОБУЧАЕМОГО:
				helperTrainedTask.SetPropScalarRef( 
					"Role",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Role_Trained.TypeName, 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Role_Trained.ObjectID );
				// ... кто именно выступает в данной роли - берем из параметров:
				helperTrainedTask.SetPropScalarRef( 
					"Worker",
					"Employee",
					uidTrainedEmployeeID );
				// ... кто является планировщиком задания - тот же, кто задан как инициатор:
				helperTrainedTask.SetPropScalarRef( 
					"Planner",
					"Employee",
					uidInitiatorEmployeeID );
				// NB! -- добавляем ссылку В МАССИВ В ИНЦИДЕНТ:
				helperIncident.AddArrayPropRef( "Tasks", helperTrainedTask.TypeName, helperTrainedTask.NewlySetObjectID );
				#endregion

				#region #4: ДОПОЛНИТЕЛЬНЫЕ СВОЙСТВА:
				// Если задано хотя бы одно вспомогательное свойство (что, 
				// вообще, не является обязательным), то загрузим "болванку", 
				// с которой потом будем делать копии "болванок" для реальных
				// свойств:
				ObjectOperationHelper helperProp_Base = ObjectOperationHelper.GetInstance("IncidentPropValue");
				if ( DateTime.MinValue!=dtPropCourseBeginningDate 
					|| null!=sPropCourseOrExamNumber
				    || null!=sPropGoalStatus
					|| null!=sPropTrainingDirection
					|| null!=sPropTrainingCenter || dSum!=0)
				{
					helperProp_Base.LoadObject();
					if (!helperProp_Base.IsLoaded) throw new ApplicationException();
				}
				
				// Далее, по каждому свойству отдельно: если данные для соотв.
				// свойства заданы, то (а) копируем "болванку", (б) заполняем
				// данные, в т.ч. и ссылку на инцидент, (в) в данных инцидента
				// добавляем ссылку на свойство в массвное объектное свойство.
				// Если данные не заданы, то вспомогательный объект не будет 
				// формироваться - вместо него будет null; далее это обыгрыается
				// при формировании общей датаграммы на запись.
				// Все действия выполняются вспомогательным методом - см. 
				// реализацию:

                // ... "Стоимость обучения"
                ObjectOperationHelper helperProp_Sum = applayAdditionalIncidentProp(
                    helperIncident,
                    ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_Summ,
                    helperProp_Base,
                    dSum);
				// ... "Номер курса / экзамена":
				ObjectOperationHelper helperProp_CourseNumber = applayAdditionalIncidentProp( 
						helperIncident, 
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_CourseNumber,
						helperProp_Base,
						sPropCourseOrExamNumber );
				
				// ... "Для получения статуса":
				ObjectOperationHelper helperProp_GoalStatus = applayAdditionalIncidentProp( 
						helperIncident,
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_GoalStatus,
						helperProp_Base,
						sPropGoalStatus );
				
				// ... "Дата начала обучения":
				ObjectOperationHelper helperProp_CourseBeginningDate = applayAdditionalIncidentProp(
						helperIncident,
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_CourseBeginningDate,
						helperProp_Base,
						dtPropCourseBeginningDate );
				
				// ... "Направление обучения/сертификации":
				ObjectOperationHelper helperProp_TrainingDirection = applayAdditionalIncidentProp(
					helperIncident,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_TrainingDirection,
					helperProp_Base,
					sPropTrainingDirection );
				
				// ... "Учебный центр":
				ObjectOperationHelper helperProp_TrainingCenter = applayAdditionalIncidentProp(
					helperIncident,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_TrainingCenter,
					helperProp_Base,
					sPropTrainingCenter );
				
                #endregion				
                #region #5: 
                // Создадим объект "IncidentCategory"
                ObjectOperationHelper helperIncidentCategory = ObjectOperationHelper.GetInstance("IncidentCategory");
                XParamsCollection paramsIncidentCategory = new XParamsCollection();
                paramsIncidentCategory.Add("ObjectID", uidCategoryID);
                // Получим объект "IncidentCategory" по его идентификатору
                helperIncidentCategory.LoadObject(paramsIncidentCategory);
                // Получаем название "Категории инц-та"
                string sCategoryName = (string)helperIncidentCategory.GetPropValue("Name", XPropType.vt_string);
                // Далее ищем ID папки с названием, таким же как и категория создаваемого инц-та и родительской папкой,
                // идентификаторой которой прописан в конфиге [itws:target-folder]
                ObjectOperationHelper helperFolder = ObjectOperationHelper.GetInstance("Folder");
                XParamsCollection paramsIncFolder = new XParamsCollection();
                paramsIncFolder.Add("Parent", ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.TargetFolder.ObjectID);
                paramsIncFolder.Add("Name", sCategoryName);
                Guid uidFolderID = helperFolder.GetObjectIdByExtProp(paramsIncFolder);
                if (uidFolderID == Guid.Empty)
                    throw new ApplicationException(String.Format("Папка с наименованием {0} не найдена", sCategoryName));
                helperIncident.SetPropScalarRef( 
					"Folder", 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.TargetFolder.TypeName,
                    uidFolderID);
                #endregion
                #region #6: ЗАПИСЬ ДАННЫХ; ФОМРИРОВАНИЕ РЕЗУЛЬТАТА:
                ObjectOperationHelper.SaveComplexDatagram( 
					new ObjectOperationHelper[]
						{
							helperIncident,				// Сам инцидент
							helperTrainedTask,			// Задание для обучаемого
							helperProp_CourseNumber,	// Далее - свойства (м.б. null-ами)...
							helperProp_GoalStatus,
							helperProp_CourseBeginningDate,
							helperProp_TrainingDirection,
							helperProp_TrainingCenter,
                            helperProp_Sum              // Сумма обучения
						} 
					);
				
				// Перезагрузка инцидента и формирование результата:
				// ... необходимо, чтобы получить номер:
				helperIncident.LoadObject();
				if (!helperIncident.IsLoaded) throw new ApplicationException();
				// Результат: идентификатор и номер инцидента:
				result.EducationIncidentID = helperIncident.ObjectID.ToString();
				result.EducationIncidentNumber = helperIncident.GetPropValue( "Number", XPropType.vt_i4 ).ToString();
				#endregion
			}
			catch( Exception err )
			{
				// Значимые результаты в случае ошибки - это описание и стек ошибки:
				result.ErrorDescription = err.Message;
				result.ErrorStack = err.ToString();
				// ... все остальные поля - пустая строка:
				result.EducationIncidentID = String.Empty;
				result.EducationIncidentNumber = String.Empty;
			}
			return result;
		}
        /// <summary>
        /// Метод изменения состояния инц-та на обучение.
        /// </summary>
        /// <param name="nIncidentNumber"></param>
        /// <param name="sIncidentStatusID"></param>
        /// <param name="sDescription"></param>
        /// <param name="dtDeadLine"></param> 
        /// <returns></returns>
        [WebMethod(Description = "Измемение инцидента по обучению")]
        public BP_EducationRequestResult UpdateIncidentStatus(int nIncidentNumber , 
                                                                string sIncidentStatusID, 
                                                                string sDescription,
                                                                DateTime dtDeadLine)
        {

            BP_EducationRequestResult result = new BP_EducationRequestResult();
            try
            {
                Guid uidIncidentStatus = ObjectOperationHelper.ValidateRequiredArgumentAsID(sIncidentStatusID, "Иднтификатор состояния инцидента");
                ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance("Incident");
                XParamsCollection keyIncidentParams = new XParamsCollection();
                // Передадим в параметры номер инц-та
                keyIncidentParams.Add("Number", nIncidentNumber);
                keyIncidentParams.Add("Type", ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.ObjectID);
                // Загрузим объект с переданнымит параметрами для поиска
                helperIncident.LoadObject(keyIncidentParams);
                // Сбросим значение свойств, которые ТОЧНО не изменяются
                helperIncident.DropPropertiesXml(new string[] {"Number", "Type" });
                helperIncident.SetPropScalarRef(
                    "State",
                    ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.TypeName,
                    uidIncidentStatus);
                // "Описание" инцидента
                string sDescr = String.Empty;
                if (!String.IsNullOrEmpty(sDescription))
                {
                    helperIncident.UploadBinaryProp("Solution");
                    sDescr = helperIncident.PropertyXml("Solution").InnerText + "\n" + sDescription;
                    helperIncident.SetPropValue("Solution", XPropType.vt_text, sDescr);
                }
                // "Дата крайнего срока" 
                if (dtDeadLine != DateTime.MinValue)
                    helperIncident.SetPropValue("DeadLine", XPropType.vt_date, dtDeadLine);
                else
                    helperIncident.SetPropValue("DeadLine", XPropType.vt_date, null);
                // Сохраним инцидент с новым состоянием
                helperIncident.SaveObject();
                result.EducationIncidentID = helperIncident.ObjectID.ToString();
                result.EducationIncidentNumber = nIncidentNumber.ToString();

                
            }
            catch (Exception err)
            {
                // Значимые результаты в случае ошибки - это описание и стек ошибки:
                result.ErrorDescription = err.Message;
                result.ErrorStack = err.ToString();
                // ... все остальные поля - пустая строка:
                result.EducationIncidentID = String.Empty;
                result.EducationIncidentNumber = String.Empty;
            }
            return result;
        }
		#endregion
		
		#region Методы, используемые для синхронизации данных Проектов

		/// <summary>
		/// Внутренний служебный метод загрузки данных Папки (Folder) типа 
		/// "Проект", заданной идентификатором в строковом представлении. 
		/// Проверяет корректность задания идентификатора, а так же тип папки
		/// </summary>
		/// <param name="sProjectID">Идентификатор папки-проекта, в строке</param>
		/// <param name="arrPreloadProperties">
		/// Массив наименований прогружаемых параметров, м.б. null
		/// </param>
		/// <param name="bIsStrictLoad">
		/// Признак "жесткой" загрузки - если указанный объект не будет найден, будет
		/// сгенерировано исклбчение; если параметр задан в false, и объект не будет 
		/// найден, то в кач. результата метод вернет null;
		/// </param>
		/// <returns>
		/// Инициализированный объект - helper или null если объект не найден, 
		/// и признак "жесткой" загрузки (bIsStrictLoad) сброшен
		/// </returns>
		/// <exception cref="ArgumentNullException">Если sProjectID есть null</exception>
		/// <exception cref="ArgumentException">Если sProjectID есть пустая строка</exception>
		/// <exception cref="ArgumentException">Если проекта с ID sProjectID нет и bIsStrictLoad=true</exception>
		/// <exception cref="ArgumentException">Если sProjectID задает папку - НЕ проект</exception>
		private ObjectOperationHelper loadProject( string sProjectID, bool bIsStrictLoad, string[] arrPreloadProperties ) 
		{
			// Проверяем корректность входных параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "Идентификатор проекта (sProjectID)" );
			
			// Загружаем данные: в любом случае испрользуем "мягкую" загрузку
			// при этом проверяем, загрузилось или нет: дальнейшая реакция зависит 
			// от значения флага bIsStrictLoad:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			if ( !helper.SafeLoadObject( null, arrPreloadProperties ) )
			{
				if (bIsStrictLoad)
					throw new ArgumentException( "Проект с указанным идентификатором (" + sProjectID + ") не найден", "sProjectID" );
				else
					return null;
			}

			// Проверяем, что загруженное описание, представленное объектом типа 
			// "Folder" есть проект - проверим значение "типа" папки:
			if ( FolderTypeEnum.Project != getFolderType(helper) )
				throw new ArgumentException( "Заданный идентификатор (sProjectID) не является идентификатором проекта" );
			
			return helper;			
		}



        /// <summary>
        /// Внутренний служебный метод загрузки данных Папки (Folder) всех типов
        /// , заданной идентификатором в строковом представлении. 
        /// Проверяет корректность задания идентификатора, а так же тип папки
        /// </summary>
        /// <param name="sActivityID">Идентификатор папки-проекта, в строке</param>
        /// <param name="arrPreloadProperties">
        /// Массив наименований прогружаемых параметров, м.б. null
        /// </param>
        /// <param name="bIsStrictLoad">
        /// Признак "жесткой" загрузки - если указанный объект не будет найден, будет
        /// сгенерировано исклбчение; если параметр задан в false, и объект не будет 
        /// найден, то в кач. результата метод вернет null;
        /// </param>
        /// <returns>
        /// Инициализированный объект - helper или null если объект не найден, 
        /// и признак "жесткой" загрузки (bIsStrictLoad) сброшен
        /// </returns>
        /// <exception cref="ArgumentNullException">Если sActivityID есть null</exception>
        /// <exception cref="ArgumentException">Если sActivityID есть пустая строка</exception>
        /// <exception cref="ArgumentException">Если проекта с ID sActivityID нет и bIsStrictLoad=true</exception>
        /// <exception cref="ArgumentException">Если sActivityID задает папку - НЕ проект</exception>
        private ObjectOperationHelper loadActivity(string sActivityID, bool bIsStrictLoad, string[] arrPreloadProperties)
        {
            // Проверяем корректность входных параметров:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sActivityID, "Идентификатор проекта (sActivityID)");

            // Загружаем данные: в любом случае испрользуем "мягкую" загрузку
            // при этом проверяем, загрузилось или нет: дальнейшая реакция зависит 
            // от значения флага bIsStrictLoad:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            if (!helper.SafeLoadObject(null, arrPreloadProperties))
            {
                if (bIsStrictLoad)
                    throw new ArgumentException("Проект с указанным идентификатором (" + sActivityID + ") не найден", "sActivityID");
                else
                    return null;
            }
            return helper;
        }

	
		/// <summary>
		/// Внутренний метод получения значения "Типа папки" (Folder.Type) как
		/// значения перечисления FolderTypeEnum, для данных объекта "Папка",
		/// переденных во вспомогательном объекте-heler-е
		/// </summary>
		/// <param name="helperProject">Вспомогательный объект с данными объекта "Папка"</param>
		/// <returns>Тип папки, как значение перечисления FolderTypeEnum</returns>
		private FolderTypeEnum getFolderType( ObjectOperationHelper helperProject ) 
		{
			if (null == helperProject) throw new ApplicationException("Служебный объект ObjectOperationHelper не передан!");
			if ("Folder" != helperProject.TypeName) throw new ApplicationException("Объект не является папкой; определение типа папки невозможно!");

			return (FolderTypeEnum)helperProject.GetPropValue( "Type", XPropType.vt_i2 );
		}
		

		/// <summary>
		/// Метод преобразования значения состояния папки в соответствующее 
		/// состояние проекта
		/// </summary>
		/// <param name="enFolderState">Состояние папки</param>
		/// <returns>Соответствующее состояние проекта</returns>
		private ProjectStates getFolder2ProjectState( FolderStates enFolderState ) 
		{
			ProjectStates enProjectState;
			switch (enFolderState)
			{
				case FolderStates.Open: enProjectState = ProjectStates.Open; break;
				case FolderStates.WaitingToClose: enProjectState = ProjectStates.WaitingToClose; break;
				case FolderStates.Closed: enProjectState = ProjectStates.Closed; break;
				case FolderStates.Frozen: enProjectState = ProjectStates.Frozen; break;
				default:
					throw new ArgumentException( "Неизвестное состояние папки (enFolderState)","enFolderState" );
			}
			return enProjectState;
		}

		/// <summary>
		/// Метод преобразования значения состояния проекта в соответствующее 
		/// состояние папки
		/// </summary>
		/// <param name="enProjectState">Состояние проекта</param>
		/// <returns>Соответствующее состояние папки</returns>
		private FolderStates getProject2FolderState(ProjectStates enProjectState)
		{
			FolderStates enFolderState;
			switch (enProjectState)
			{
				case ProjectStates.Open: enFolderState = FolderStates.Open; break;
				case ProjectStates.WaitingToClose: enFolderState = FolderStates.WaitingToClose; break;
				case ProjectStates.Closed: enFolderState = FolderStates.Closed; break;
				case ProjectStates.Frozen: enFolderState = FolderStates.Frozen; break;
				default:
					throw new ArgumentException("Неизвестное состояние проекта (enProjectState)", "enProjectState");
			}
			return enFolderState;
		}
		
		/// <summary>
		/// Внутренний метод перевода данных из загруженного объекта - описателя
		/// в объект типа ProjectInfo
		/// </summary>
		/// <param name="helper">Объект описатель, должен представлять данные типа Folder и д.б. загружен</param>
		/// <returns>Объект ProjectInfo с описанием данных проекта</returns>
		private ProjectInfo getProjectInfoFromHelper( ObjectOperationHelper helper ) 
		{
			// Проверки корректности полученных данных + доразвертывание необходимых 
			// объектных представлений: 
			// (1) проверим, что это heler-объект задан и представляет данные объекта типа "Папка" (Folder):
			if (null==helper)
				throw new ArgumentNullException( "helper", "Перевод в ProjectInfo невозможен: вспомогательный объект-описатель не задан" );
			if ("Folder"!=helper.TypeName)
				throw new ArgumentException( "Перевод в ProjectInfo невозможен: вспомогательный объект-описатель представляет данные типа, отличного от Folder (" + helper.TypeName + ")", "helper" );
			// (2) проверим, что это - проект:
			if ( FolderTypeEnum.Project != getFolderType(helper) )
				throw new ApplicationException( String.Format(
					"Некорректные данные: указанный объект с идентификатором {0} не является проектом (тип папки - {1})",
					helper.ObjectID.ToString(), 
					((FolderTypeEnum)helper.GetPropValue("Type",XPropType.vt_i2)).ToString() )
				);

			ObjectOperationHelper helperParentFolder = helper.GetInstanceFromPropScalarRef( "Parent", false );
			ObjectOperationHelper helperOrg = helper.GetInstanceFromPropScalarRef( "Customer", false );
			if (null==helperOrg)
				throw new ApplicationException( String.Format(
					"Некорректные данные: для указанного проекта с идентификатором {0} " +
					"не задана организация Клиента, к которому относится данный проект",
					helper.ObjectID.ToString() )
				);
	
			ProjectInfo info = new ProjectInfo();
			// Заполняем свойства класса - описателя соотв. значениями объекта:
			info.ObjectID = helper.ObjectID.ToString(); 
			info.CustomerID = helperOrg.ObjectID.ToString();
			info.Name = helper.GetPropValue( "Name", XPropType.vt_string ).ToString();
			//info.Code = safeReadData( helper, "ProjectCode" ).ToString();
			info.NavisionID = safeReadData( helper, "ExternalID" );
            ObjectOperationHelper helperActivityType = helper.GetInstanceFromPropScalarRef("ActivityType", false);
            Guid uidActType = Guid.Empty;
            if (helperActivityType != null)
            {
                uidActType = helperActivityType.ObjectID;
                info.IsPilot = (uidActType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            }
          	// Статус проекта
			info.State = getFolder2ProjectState( (FolderStates)helper.GetPropValue( "State", XPropType.vt_i2) );
			// Указание идентификатора вышестоящего проекта - если таковой задан, иначе - null;
			info.MasterProjectID = (null==helperParentFolder ? null : helperParentFolder.ObjectID.ToString());
			// ...коррекция данных: если код проекта или код Navision есть пустая строка, то делаем их null:
			if (String.Empty == info.Code)
				info.Code = null;
			if (String.Empty == info.NavisionID)
				info.NavisionID = null;
			
			return info;
		}

		
		/// <summary>
		/// Возвращает данные всех проектов, представленных в системе Incident Tracker, 
		/// как массив экземпляров класса Croc.IncidentTracker.Services.ProjectInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.ProjectInfo"/>
		/// </summary>
		[WebMethod(Description="Возвращает данные всех проектов, представленных в системе Incident Tracker")]
		public ProjectInfo[] GetProjectsInfo() 
		{
			// Получам данные всех проектов:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-Projects", null );

			if ( null == oDataTable )
				return new ProjectInfo[0];
            Guid uidActivityType = Guid.Empty;
			ProjectInfo[] arrProjectsInfo = new ProjectInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// Убедимся, что рассматриваем папку типа "Проект"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if ( FolderTypeEnum.Project != enType )
					continue;
				
				ProjectInfo info = new ProjectInfo();

				// Переносим данные обязательных полей
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				info.CustomerID = oDataTable.Rows[nRowIndex]["CustomerID"].ToString();
				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();
                uidActivityType = new Guid(oDataTable.Rows[nRowIndex]["ActivityType"].ToString());
                info.IsPilot = (uidActivityType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
				// Код проекта и код в Navision в общем случае могут быть и не заданы;
				// более того, случай задания значения как пустой строки нельзя отличить
				// от случая значения null - поэтому случай пустой строки всегда сводим
				// к null-у:
				if ( String.Empty == info.Code )
					info.Code = null;
				
				if ( DBNull.Value==oDataTable.Rows[nRowIndex]["NavisionID"] )
					info.NavisionID = null;
				else
					info.NavisionID = oDataTable.Rows[nRowIndex]["NavisionID"].ToString();
				if ( String.Empty == info.NavisionID )
					info.NavisionID = null;
				
				// Состояние проекта: здесь требуется коррекция - значения из IT 
				// нужно приводить в значения для НСИ:
				info.State = getFolder2ProjectState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// Ссылка на страший проект - может быть и не задана:
				if ( DBNull.Value == oDataTable.Rows[nRowIndex]["MasterProjectID"] )
					info.MasterProjectID = null;
				else
					info.MasterProjectID = oDataTable.Rows[nRowIndex]["MasterProjectID"].ToString();

				// Добавлем данные в массив
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		/// <summary>
		/// Возвращает данные проекта, представленного в системе Incident Tracker
		/// </summary>
		/// <param name="sProjectID">
		/// Строка с идентификатором проекта, для которого требуется получение 
		/// данные. Если указанный проект в системе не описан, метод возвращает
		/// null (см. описание результатов)
		/// </param>
		/// <returns>
		/// -- Экземпляр ProjectInfo с описанием проекта, если указанный проект 
		///		представлен в системе;
		///	-- null, если описание указанного проекта в системе не найдено
		/// </returns>
		[WebMethod(Description="Возвращает данные проекта, представленного в системе Incident Tracker")]
		public ProjectInfo GetProjectInfoByID( string sProjectID ) 
		{
			// Проверка переданного параметра, с его одновременным приведением:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sProjectID, "Идентификатор проекта (sObjectID)" );

			// Пробуем загрузить данные указанного объекта типа "Папка" (Folder)
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder",uidProjectID );

			// Объект не найден - в соответствии со спецификацией возвращаем null:
			if ( !helper.SafeLoadObject(null) )
				return null;
			else
				return getProjectInfoFromHelper(helper);
		}

		
		/// <summary>
		/// Возвращает данные о проектной команде, определенной для указанного проекта
		/// </summary>
		/// <param name="sProjectID">
		/// Строка (System.String) с идентификатором проекта, для которого 
		/// требуется получение данных. Задание значения является обязательным
		/// </param>
		/// <returns> 
		/// Описание проектной команды, как массив экземпляров класса 
		/// ProjectTeamParticipant.
		/// <seealso cref="Croc.IncidentTracker.Services.ProjectTeamParticipant"/>
		/// </returns>
		///	<exception cref="ArgumentNullException">Если sProlectID задан в null</exception>
		///	<exception cref="ArgumentException">Если sProlectID задан в String.Empty</exception>
		///	<exception cref="ArgumentException">Если проекта с идентификатором sProlectID нет</exception>
		[WebMethod(Description="Возвращает данные о проектной команде, определенной для указанного проекта")]
        public ProjectTeamParticipant[] GetActivityTeam(string sActivity) 
		{
			// Проверяем корректность входных параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sActivity, "Идентификатор проекта (sProjectID)" );
			
			// Пробуем получть данные указанного проекта:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "ProjectID", uidProjectID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-ProjectTeam", paramsCollection );

			if (null == oDataTable)
				return new ProjectTeamParticipant[0];

			// Временная коллекция, в которую будем набирать:
			// ... информацию по всем участникам
			ArrayList listProjectParticipants = new ArrayList();
			// ... информацию по ролям рассматриваемого участника
			ArrayList listParticipantRoles = new ArrayList();

			string sCurrEmployee = String.Empty;
			string sPrevEmployee = String.Empty;
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				sCurrEmployee = oDataTable.Rows[nRowIndex]["EmployeeID"].ToString();
				if (sCurrEmployee!=sPrevEmployee)
				{
					if (String.Empty == sPrevEmployee)
						sPrevEmployee = sCurrEmployee;
					else
					{
						ProjectTeamParticipant itemTeamInfo = new ProjectTeamParticipant();
						itemTeamInfo.EmployeeID = sPrevEmployee;
						itemTeamInfo.RoleIDs = new string[ listParticipantRoles.Count ];
						if (listParticipantRoles.Count>0)
							listParticipantRoles.CopyTo( itemTeamInfo.RoleIDs, 0 );

						listProjectParticipants.Add( itemTeamInfo );

						sPrevEmployee = sCurrEmployee;
						listParticipantRoles.Clear();
					}
				}
				if ( DBNull.Value != oDataTable.Rows[nRowIndex]["RoleID"] )
					listParticipantRoles.Add( oDataTable.Rows[nRowIndex]["RoleID"].ToString() );
			}
			if (String.Empty != sCurrEmployee)
			{
				ProjectTeamParticipant itemTeamInfo = new ProjectTeamParticipant();
				itemTeamInfo.EmployeeID = sCurrEmployee;
				itemTeamInfo.RoleIDs = new string[ listParticipantRoles.Count ];
				if (listParticipantRoles.Count>0)
					listParticipantRoles.CopyTo( itemTeamInfo.RoleIDs, 0 );

				listProjectParticipants.Add( itemTeamInfo );
			}
			
			ProjectTeamParticipant[] arrTeamInfo = new ProjectTeamParticipant[ listProjectParticipants.Count ];
			if (listProjectParticipants.Count > 0)
				listProjectParticipants.CopyTo( arrTeamInfo, 0 );
			return arrTeamInfo;
		}


		/// <summary>
		/// Создает в системе Incident Tracker описание проекта с заданными параметрами
		/// </summary>
		/// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
		/// <param name="sCode">Строка с кодом проекта</param>
		/// <param name="sName">Строка с наименованием проекта</param>
		/// <param name="sNavisionID">Строка с кодом проекта в Navision</param>
		/// <param name="bIsPilot">Признак проекта, находящегося на фазе "пилота"</param>
		/// <param name="enInitialState">Начальное состояние проекта</param>
		/// <param name="sMastrProjectID">Строка с идентификатором старшего проекта</param>
		/// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора проекта</param>
		/// <returns>Строка с идентификатором созданного проекта</returns>
		[WebMethod(Description="Создает в системе Incident Tracker описание проекта с заданными параметрами")]
		public string CreateProject(
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			bool bIsPilot,
			ProjectStates enInitialState,
			string sMastrProjectID,
			string sInitiatorEmployeeID ) 
		{
			// Проверяем корректность входных параметров:
			ObjectOperationHelper.ValidateRequiredArgument( sCustomerID, "Идентификатор организации - Клиента (sCustomerID)", typeof(Guid) );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "Уникальный код проекта (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "Наименование проекта (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sMastrProjectID, "Идентификатор старшего проекта (sMasterProjectID)", typeof(Guid) );
			ObjectOperationHelper.ValidateRequiredArgument( sInitiatorEmployeeID, "Идентификатор сотрудника - инициатора создания проекта (sInitiatorEmployeeID)", typeof(Guid) );

			// Далее - генерируем идентификатор нового проекта, и вызываем спец. 
			// метод, создающий проект с ЯВНО ЗАДАННЫМ идентификатором:
			string sNewProjectID = Guid.NewGuid().ToString();
			CreateIdentifiedProject( sNewProjectID, sCustomerID, sCode, sName, sNavisionID, bIsPilot, enInitialState, sMastrProjectID, sInitiatorEmployeeID );
			
			return sNewProjectID;
		}

		/// <summary>
		/// Создает в системе Incident Tracker описание проекта с заданными параметрами 
		/// и заранее указанным уникальным идентификатором
		/// </summary>
		/// <param name="sNewProjectID">Строка с идентификатором создаваемого проекта</param>
		/// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
		/// <param name="sCode">Строка с кодом проекта</param>
		/// <param name="sName">Строка с наименованием проекта</param>
		/// <param name="sNavisionID">Строка с кодом проекта в сист. Navision</param>
		/// <param name="bIsPilot">Признак проекта, находящегося на фазе "пилота"</param>
		/// <param name="enInitialState">Начальное состояние проекта</param>
		/// <param name="sMastrProjectID">Строка с идентификатором старшего проекта</param>
		/// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора проекта</param>
		[WebMethod(Description="Создает в системе Incident Tracker описание проекта с заданными параметрами и заранее указанным уникальным идентификатором")]
		public void CreateIdentifiedProject(
			string sNewProjectID,
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			bool bIsPilot,
			ProjectStates enInitialState,
			string sMastrProjectID,
			string sInitiatorEmployeeID ) 
		{
			// Проверяем корректность входных параметров:
			Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewProjectID,"Уникальный идентификатор создаваемого проекта (sNewProjectID)" );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "Уникальный код проекта (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "Наименование проекта (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sMastrProjectID, "Идентификатор старшего проекта (sMasterProjectID)", typeof(Guid) );
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sCustomerID, "Идентификатор организации - Клиента (sCustomerID)" );
			Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "Идентификатор сотрудника - инициатора создания проекта (sInitiatorEmployeeID)" );

			// ОСОБЕННАЯ ПРОВЕРКА: 
			// Бизнес-правило: Создание проектов под КРОК-ом при помощи сервиса запрещено
			// Поэтому проверяем, что заданная организация не есть КРОК; идентификатор 
			// последнего д.б. задан в прикладном конфигурационном файле сервисов (и, соотв.
			// представлен в объекте - описателе конфигурации, ServiceConfig)
			if ( uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID )
				throw new ArgumentException( 
					String.Format(
						"Создание проектов для организации - владельца системы \"{0}\" при помощи метода сервиса " +
						"запрещено. Создание таких проектов должно выполняться непосредственно в системе Incident " +
						"Tracker, пользователем системы, обладающим необходимыми полномочиями.",
						ServiceConfig.Instance.OwnOrganization.GetPropValue( "ShortName", XPropType.vt_string )
					), "sCustomerID" 
				);

			// Болванка нового объекта - проекта - загружаем, и ПОСЛЕ загрузки 
			// переставляем идентификатор на заданный:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder" );
			helperProject.LoadObject();
			helperProject.NewlySetObjectID = uidNewProjectID;
			
			// Задаем свойства проекта, в соотв. с заданными значениями параметров:
			// ... проект - это папка с типом "Проект":
			helperProject.SetPropValue( "Type", XPropType.vt_i2, FolderTypeEnum.Project );
            // Если у нас признак пилотного проекта, то указываем тип проектных затрат "пилотные/инвестиционные проекты",
			// иначе "Внешние проекты"; идентификатор соотв. Activity Type берем из конфигурации:
            if (bIsPilot)
                helperProject.SetPropScalarRef(
                        "ActivityType",
                        ServiceConfig.Instance.PilotProjectsActivityType.TypeName,
                        ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            else
			    helperProject.SetPropScalarRef( 
				    "ActivityType", 
				    ServiceConfig.Instance.ExternalProjectsActivityType.TypeName, 
				    ServiceConfig.Instance.ExternalProjectsActivityType.ObjectID );

			// ... задаем все переданные скаляры:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sName );
			// ... идентификатор проекта в Navision для треккера не является обязательным;
			// в кач. значения может быть задан null или пустая строка - сведем все 
			// к пустой строке - при записи в БД будет NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNavisionID? String.Empty : sNavisionID) );
			// ... статус проекта при создании соотносим явно: 
			helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getProject2FolderState(enInitialState));

			// Проставляем ссылки:
			// ...на сотрудника - инициатора проекта 
			helperProject.SetPropScalarRef( "Initiator", "Employee", uidInitEmployeeID );
			// ...на организацию:
			helperProject.SetPropScalarRef( "Customer", "Organization", uidOrganizationID );
			// ...на старший проект (если таковой задан):
			if (null!=sMastrProjectID)
				helperProject.SetPropScalarRef( 
					"Parent", "Folder", 
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sMastrProjectID, "Идентификатор старшего проекта (sMasterProjectID)" )
				);
			
			// Записываем новый объект:
			helperProject.SaveObject();
		}

		/// <summary>
		/// Изменение параметров описания указанного проекта в системе Incident Tracker.
		/// </summary>
		/// <param name="sProjectID">Строковое представление идентификатора изменяемого описания проекта</param>
		/// <param name="sNewCustomerID">Строковое представление идентификатора организации - Клиента</param>
		/// <param name="sNewCode">Строка с новым кодом проекта</param>
		/// <param name="sNewName">Строка с новым наименованием проекта</param>
		/// <param name="sNewNavisionID">Строка с новым кодом проекта в Navision</param>
		/// <param name="bIsPilot">Признак пилотного проекта</param>
		/// <returns>
		/// -- True - если указанный проект найден и успешно обновлен;
		/// -- False - если указанный проект не найден.
		/// </returns>
		/// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
		[WebMethod(Description="Изменение параметров описания указанного проекта в системе Incident Tracker")]
		public bool UpdateProject(
			string sProjectID,
			string sNewCustomerID,
			string sNewCode,
			string sNewName,
			string sNewNavisionID,
			bool bIsPilot ) 
		{
			// Проверяем парамтры
			//ObjectOperationHelper.ValidateRequiredArgument( sNewCode, "Уникальный код проекта (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sNewName, "Наименование проекта (sName)" );
			Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewCustomerID, "Идентификатор организации - Клиента (sCustomerID)" );

			// Загружаем указанный проект: внутренний метод проверяет корректность параметра
			ObjectOperationHelper helperProject = loadProject( sProjectID, false, null );
			// ... если объект не найден - просто вернем false:
			if (null==helperProject)
				return false;

			// Заменяем заданные данные проекта:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sNewCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sNewName );
			// Идентификатор проекта в Navision для треккера не является обязательным;
			// поэтому в кач. допустимых значений параметра принимаются и null, и пустая
			// строка; null сводится к пустой строке - при записи в БД будет NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNewNavisionID? String.Empty : sNewNavisionID) );
			
			// Признак пилотного проекта
            bool bIsPilotNow = false;
            ObjectOperationHelper helperActivityType = helperProject.GetInstanceFromPropScalarRef("ActivityType", false);
            Guid uidActType = Guid.Empty;
            if (helperActivityType != null)
            {
                uidActType = helperActivityType.ObjectID;
                bIsPilotNow = (uidActType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            }
            if (bIsPilot != bIsPilotNow)
			{
				// Если проект не является "Пилотом", то сделать "Пилотом" нельзя:
				if (!bIsPilotNow)	
					throw new ArgumentException( 
						"Установки признака \"пилота\" для рабочего проекта запрещена!",
						"Новое значение признака \"пилотного\" проекта (bIsPilot)" 
					);
				else // bIsPilotNow, и этот признак снимается:
                    helperProject.SetPropScalarRef(
                        "ActivityType",
                        ServiceConfig.Instance.ExternalProjectsActivityType.TypeName,
                        ServiceConfig.Instance.ExternalProjectsActivityType.ObjectID);
			}
           	
			// Перестановка организации клиента: проверим, какая организация указана сейчас:
			ObjectOperationHelper helperOrg = helperProject.GetInstanceFromPropScalarRef( "Customer" );
			if (helperOrg.ObjectID!=uidNewCustomerOrgID)
				helperProject.SetPropScalarRef( "Customer", "Organization", uidNewCustomerOrgID );

			// Сбросим в датаграмме все свойства, которые точно не изменяются:
			helperProject.DropPropertiesXml( new string[]{"Type", "State", "IsLocked", "Parent" } );
			// Записываем измененные данные:
			helperProject.SaveObject();

			return true;
		}

		
		/// <summary>
		/// Изменяет ссылку на "старший" проект для указанного проекта. 
		/// Метод используется так же для сброса ссылки на "старший" проект.
		/// </summary>
		/// <param name="sProjectID">
		/// Строковое представление идентификатора изменяемого описания проекта
		/// </param>
		/// <param name="sNewMasterProjectID">
		/// Строковое представление идентификатора "старшего" проекта или null
		/// </param>
		[WebMethod(Description="Изменяет ссылку на старший проект для указанного проекта")]
		public void UpdateMasterProjectRef(
			string sProjectID, 
			string sNewMasterProjectID ) 
		{
			// Проверяем корректность входных параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "Идентификатор изменяемного проекта (sProjectID)" );
			
			Guid uidNewMasterProjectID = Guid.Empty;
			if ( null != sNewMasterProjectID )
				uidNewMasterProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
					sNewMasterProjectID, "Идентификатор страшего проекта (sNewMasterProjectID)" );
			
			// Загружаем указанный проект:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			helperProject.LoadObject();

			if (Guid.Empty == uidNewMasterProjectID)
				helperProject.PropertyXml("Parent").RemoveAll();
			else
			{
				// Анализируем данные заглушки:
				XmlElement xmlRefProp = (XmlElement)helperProject.PropertyXml("Parent").SelectSingleNode("Folder");
				// Данных о вышестоящем проекте нет вообще - создаем ссылку:
				if (null==xmlRefProp)
					helperProject.SetPropScalarRef( "Parent", "Folder", uidNewMasterProjectID );
				else
				{
					// Проверим - возможно, идентификатор вышестоящей организации и не изменился:
					ObjectOperationHelper helperMasterProject = helperProject.GetInstanceFromPropScalarRef( "Parent" );
					if (helperMasterProject.ObjectID != uidNewMasterProjectID)
						// изменился: перезапишем данные ссылки
						helperProject.SetPropScalarRef( "Parent","Folder",uidNewMasterProjectID );
					else
						// не изменился: сбросим свойство вообще - Storage ничего обновлять не будет
						helperProject.DropPropertiesXml( "Parent" );
				}
			}

			helperProject.DropPropertiesXmlExcept( "Parent" );
			helperProject.SaveObject();
		}

        /// <summary>
        /// Изменяет данные о соотнесении указанного проекта с заданными направлениями.
        /// </summary>
        /// <param name="sProjectID">
        /// Строковое представление идентификатора изменяемого описания проекта. 
        /// Задание значения яв-ся обязательным. 
        /// </param>
        /// <param name="aDirectionsIDs">
        /// Массив строк с идентификаторами направлений, соотносимых с проектом. 
        /// Все ранее заданные направления для проекта будут отменены. В качестве 
        /// значения может быть задан пустой массив - в этом случае все направления
        /// для указанного проекта отменяются.
        /// Задаваемые направления должны быть представлены в системе Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - если указанный проект найден и успешно обновлен;
        /// -- False - если указанный проект не найден
        /// </returns>
        /// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
        [WebMethod(Description = "Изменяет данные о соотнесении указанного проекта с заданными направлениями")]
        [System.Obsolete("use method UpdateProjectDirectionsAndExpenseRatio")]
        public bool UpdateProjectDirections(
            string sProjectID,
            string[] aDirectionsIDs)
        {
            // Проверим переданный параметр:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "Идентификатор проекта (sProjectID)");
            // ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
            if (null == aDirectionsIDs)
                aDirectionsIDs = new string[0];


            // #1:
            // Загружаем указанный проект: внутренний метод проверяет корректность параметра
            ObjectOperationHelper helperProject = loadProject(sProjectID, false, new string[] { "FolderDirections" });
            // ... если объект не найден - просто вернем false:
            if (null == helperProject)
                return false;

            // Сразу изымем из датаграммы все свойства, кроме изменяемого - FolderDirections,
            // для упрошения работы с XML датаграммы и просто параноии ради
            helperProject.DropPropertiesXmlExcept("FolderDirections");


            // #2:
            // Связь проекта и направления выполняется при помощи спец. служебного 
            // объекта FolderDirection, который также хранит значение доли затрат
            // по направлению. 
            //
            // Для каждого заданного направления создадим описатель данных нового 
            // FolderDirection; всего их будет столько же, сколько и идентификаторов
            // заданных направлений - создавать будем массивом. При этом в массиве 
            // выделим на один элемент больше - в последний потом загрузим данные 
            // самого прокта; все вместе в одном массиве, потому что так удобнее 
            // потом создать комплексную датаграмму (см. далее #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[aDirectionsIDs.Length + 1];
            for (int nIndex = 0; nIndex < aDirectionsIDs.Length; nIndex++)
            {
                // Проверяем идентификатор заданного направления
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(aDirectionsIDs[nIndex], String.Format("Идентификатор направления aDirectionsIDs[{0}]", nIndex));

                // Поищем среди существующих направлений
                foreach (XmlElement xmlFolderDirection in helperProject.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(aDirectionsIDs[nIndex], StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperProject.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // Загружаем "болванку" нового служебного ds-объекта FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... проставляем ссылку на направление:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... и сразу проставляем ссылку на проект:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "доля затрат" - в ноль:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 0);
            }
            // ... последний элемент массива - сам проект (см. далее #4):
            arrHelpers[aDirectionsIDs.Length] = helperProject;


            // #3:
            // Если для проекта были определены направления, то, соотв., существуют 
            // служебные объекты FolderDirection, связывающие проект и направления. 
            // 
            // Для снятия связи м/у проектом и направлением эти служебные объекты надо
            // удалить. Удаление выполним одновременно с записью измененной датаграммы 
            // самого проекта, как "комплексной" датаграммы, в которой все FolderDirection
            // будут помечены как удаленные - для них будет задан атрибут delete="1".
            // 
            // Изымаем XML-данные свойства FolderDirection, сохранив при этом их клон -
            // далее при создании комплексной датаграммы данные из клона используем
            // для формирования записией об удаляемых объектах (см #4). В самом объекте
            // "Папка" все старые ссылки на FolderDirections удалим, а новые - добавим:

            XmlElement xmlFolderDirections = (XmlElement)helperProject.PropertyXml("FolderDirections").CloneNode(true);
            // ... удаляем старые ссылки:
            helperProject.ClearArrayProp("FolderDirections");
            // ... новые - добавляем:
            // Идем по массиву вспомогательных объектов, и помним при этом:
            // -- что последний там - сам проект, его учитывать на надо, поэтому 
            //		цикл до длины массива минус один;
            // -- что данные вспомогательных объектов в массиве еще не записаны, 
            //		поэтому для получения идентификатора пользуемся NewlySetObjectID
            for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                helperProject.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


            // #4:
            // Строим комплексную датаграмму для записи. Здесь: (а) данные самого 
            // изменного проекта, (б) данные новых FolderDirection-ов, (в) данные 
            // старых, удаляемых FolderDirection-ов
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
            // ... в датаграмме уже есть измененный и новые объекты - их данные 
            // перенесены из helper-ов. Добавим данные удаляемых:
            foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                // содержимое данных удаляемого FolderDirection уже не важно - удаляем (грубо)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... устанавливаем атриубут delete="1", ключ для сервера, 
                // указывающий что соответствующий объект в БД надо удалить
                xmlDeletedFolderDirection.SetAttribute("delete", "1");
            }


            // #5: 
            // Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
            // будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
            // FolderDirection, обновлены данные папки-проекта
            ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

            return true;
        }

       	/// <summary>
		/// Изменяет данные о соотнесении указанного проекта с заданными направлениями.
		/// </summary>
		/// <param name="sProjectID">
		/// Строковое представление идентификатора изменяемого описания проекта. 
		/// Задание значения яв-ся обязательным. 
		/// </param>
        /// <param name="ProjectDirections">
        /// Массив классов ProjectDirection, в котором содержится информация по направлениям 
        /// соотносимых с проектом. 
		/// Все ранее заданные направления для проекта будут отменены. В качестве 
		/// значения может быть задан пустой массив - в этом случае все направления
		/// для указанного проекта отменяются.
		/// Задаваемые направления должны быть представлены в системе Incident Tracker.
		/// </param>
		/// <returns>
		/// -- True - если указанный проект найден и успешно обновлен;
		/// -- False - если указанный проект не найден
		/// </returns>
		/// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
        [WebMethod(Description = "Изменяет данные о соотнесении указанного проекта с заданными направлениями")]
        public bool UpdateProjectDirectionsAndExpenseRatio(
            string sProjectID,
            ProjectDirection[] ProjectDirections)
        {
            // Проверим переданный параметр:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "Идентификатор проекта (sProjectID)");
            // ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
            if (null == ProjectDirections)
                ProjectDirections = new ProjectDirection[0];


            // #1:
            // Загружаем указанный проект: внутренний метод проверяет корректность параметра
            ObjectOperationHelper helperProject = loadProject(sProjectID, false, new string[] { "FolderDirections" });
            // ... если объект не найден - просто вернем false:
            if (null == helperProject)
                return false;

            // Сразу изымем из датаграммы все свойства, кроме изменяемого - FolderDirections,
            // для упрошения работы с XML датаграммы и просто параноии ради
            helperProject.DropPropertiesXmlExcept("FolderDirections");

            // Сумма всех переданных процентов аккамулируется
            int nTotalPercentage = 0;

            // #2:
            // Связь проекта и направления выполняется при помощи спец. служебного 
            // объекта FolderDirection, который также хранит значение доли затрат
            // по направлению. 
            //
            // Для каждого заданного направления создадим описатель данных нового 
            // FolderDirection; всего их будет столько же, сколько и идентификаторов
            // заданных направлений - создавать будем массивом. При этом в массиве 
            // выделим на один элемент больше - в последний потом загрузим данные 
            // самого проекта; все вместе в одном массиве, потому что так удобнее 
            // потом создать комплексную датаграмму (см. далее #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ProjectDirections.Length + 1];
            for (int nIndex = 0; nIndex < ProjectDirections.Length; nIndex++)
            {
                // Проверяем идентификатор заданного направления
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(ProjectDirections[nIndex].DirectionID, String.Format("Идентификатор направления ProjectDirections[{0}].DirectionID", nIndex));

                // Проверяем процент заданного направления.
                int nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(ProjectDirections[nIndex].ExpenseRatio, String.Format("Процент распределения затрат по направлению ProjectDirections[{0}].Percentage", nIndex));


                // Поищем среди существующих направлений
                foreach (XmlElement xmlFolderDirection in helperProject.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(ProjectDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperProject.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // Загружаем "болванку" нового служебного ds-объекта FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... проставляем ссылку на направление:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... и сразу проставляем ссылку на проект:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "доля затрат" - в ноль:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                nTotalPercentage += nPercentage;
            }
            // Если передано хотя бы одно направление, сумма процентных долей должна быть равна 100
            if ((ProjectDirections.Length > 0) && (nTotalPercentage != 100))
                throw new ArgumentException("Сумма процентных долей по направлениям должна быть равна 100");

            // ... последний элемент массива - сам проект (см. далее #4):
            arrHelpers[ProjectDirections.Length] = helperProject;


            // #3:
            // Если для проекта были определены направления, то, соотв., существуют 
            // служебные объекты FolderDirection, связывающие проект и направления. 
            // 
            // Для снятия связи м/у проектом и направлением эти служебные объекты надо
            // удалить. Удаление выполним одновременно с записью измененной датаграммы 
            // самого проекта, как "комплексной" датаграммы, в которой все FolderDirection
            // будут помечены как удаленные - для них будет задан атрибут delete="1".
            // 
            // Изымаем XML-данные свойства FolderDirection, сохранив при этом их клон -
            // далее при создании комплексной датаграммы данные из клона используем
            // для формирования записией об удаляемых объектах (см #4). В самом объекте
            // "Папка" все старые ссылки на FolderDirections удалим, а новые - добавим:

            XmlElement xmlFolderDirections = (XmlElement)helperProject.PropertyXml("FolderDirections").CloneNode(true);
            // ... удаляем старые ссылки:
            helperProject.ClearArrayProp("FolderDirections");
            // ... новые - добавляем:
            // Идем по массиву вспомогательных объектов, и помним при этом:
            // -- что последний там - сам проект, его учитывать на надо, поэтому 
            //		цикл до длины массива минус один;
            // -- что данные вспомогательных объектов в массиве еще не записаны, 
            //		поэтому для получения идентификатора пользуемся NewlySetObjectID
            for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                helperProject.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


            // #4:
            // Строим комплексную датаграмму для записи. Здесь: (а) данные самого 
            // изменного проекта, (б) данные новых FolderDirection-ов, (в) данные 
            // старых, удаляемых FolderDirection-ов
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
            // ... в датаграмме уже есть измененный и новые объекты - их данные 
            // перенесены из helper-ов. Добавим данные удаляемых:
            foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                // содержимое данных удаляемого FolderDirection уже не важно - удаляем (грубо)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... устанавливаем атриубут delete="1", ключ для сервера, 
                // указывающий что соответствующий объект в БД надо удалить
                xmlDeletedFolderDirection.SetAttribute("delete", "1");
            }


            // #5: 
            // Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
            // будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
            // FolderDirection, обновлены данные папки-проекта
            ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

            return true;
        }

		delegate TRes Func<TRes>();
		delegate TRes Func<TParam, TRes>(TParam param);
		delegate TRes Func<TParam1, TParam2, TRes>(TParam1 param1, TParam2 param2);
		/// <summary>
		/// Обновляет определение проектной команды для указанного проекта.
		/// </summary>
		/// <param name="sProjectID">
		/// Строковое представление идентификатора изменяемого описания проекта. 
		/// Задание значения яв-ся обязательным. 
		/// </param>
		/// <param name="aTeamParticipants">
		/// Массив описаний участников проектной команды, как экземпляров типа 
		/// ProjectTeamParticipant. Может быть задан пустой массив.
		/// </param>
		/// <param name="bReplaceTeam">
		/// Определяет режим обновления данных проектной команды:
		/// -- True - все описание проектной команды заменяется заданным в aTeamParticipants
		/// -- False - существующая проектная команда дополняется сотрудниками из
		/// aTeamParticipants, которых еще нет в проектной команде. Если сотурдник
		/// уже есть в команде, то для него проверяются роли; недостающие (есть в 
		/// aTeamParticipants, но нет в определении участника) - добавляются.
		/// </param>
		/// <returns>
		/// -- True - если указанный проект найден и успешно обновлен;
		/// -- False - если указанный проект не найден
		/// </returns>
		/// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
		[WebMethod(Description="Обновляет определение проектной команды для указанного проекта")]
        public bool UpdateActivityTeam(
            string sActivityID,
			ProjectTeamParticipant[] aTeamParticipants,
			bool bReplaceTeam ) 
		{
			// Проверим переданный параметр:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityID, "Идентификатор проекта (sProjectID)");
			// ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
			if (null==aTeamParticipants)
				aTeamParticipants = new ProjectTeamParticipant[0];


			// #1:
			// Загружаем указанный проект: внутренний метод проверяет корректность параметра
			ObjectOperationHelper helperProject = loadActivity(sActivityID, false, new string[] { "Participants.Roles", "Participants.Employee" });
			// ... если объект не найден - просто вернем false:
			if (null==helperProject)
				return false;

			// При замене описания проектной команды данные самого прокта не изменяются 
			// (массивное свойство Participants является обратным, его менять не надо)
			// Все что нам далее понадобится - это подгруженное описание проектной команды,
			// для анализа. Выделим все эти данные в отдельнй XML (копию), а описание 
			// проекта, во избежание, зачистим:
			XmlElement xmlParticipants = (XmlElement)helperProject.PropertyXml( "Participants" ).CloneNode( true );
			helperProject.Clear();

			// ДАЛЕЕ, В ЗАВИСИМОСТИ ОТ РЕЖИМА:
			if ( bReplaceTeam )
			{
				#region Случай "Замена"

				// #2: 
				// Создаем новые описания участников проектной команды:
				ObjectOperationHelper[] arrNewParticipants = new ObjectOperationHelper[ aTeamParticipants.Length ];
				// "Болванка" нового описания
				ObjectOperationHelper helperParicipantTemplate = ObjectOperationHelper.GetInstance( "ProjectParticipant" );

				List<XmlElement> changedParticipants = new List<XmlElement>();
                List<XmlElement> participantsToDelete = new List<XmlElement>();
				List<ObjectOperationHelper> newParticipants = new List<ObjectOperationHelper>();

				#region Вспомогательные функции
				Func<ObjectOperationHelper> GetNewParicipantStub =
					delegate()
					{
						if (!helperParicipantTemplate.IsLoaded)
							helperParicipantTemplate.LoadObject();
						return ObjectOperationHelper.CloneFrom(helperParicipantTemplate, false);
					};

				Func<Guid, ObjectOperationHelper> GetExistingParicipantStub =
					delegate(Guid objectID)
					{
						ObjectOperationHelper helper = ObjectOperationHelper.GetInstance(
							"ProjectParticipant",
							objectID);
						helper.LoadObject();
						helper.DropPropertiesXmlExcept("Roles");
						return helper;
					};

				Func<ProjectTeamParticipant[], Guid, ProjectTeamParticipant> GetNewParticipantByEmployeeID =
					delegate(ProjectTeamParticipant[] participants, Guid objectID)
					{
						foreach (ProjectTeamParticipant participant in participants)
						{
							Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(participant.EmployeeID, "Идентификатора сотрудника");
							if (employeeID.Equals(objectID))
								return participant;
						}
						return null;
					};

				Func<XmlElement, Guid, XmlElement> GetExistingParticipantByEmployeeID =
					delegate(XmlElement participants, Guid objectID)
					{
						foreach (XmlNode p in participants.SelectNodes("ProjectParticipant"))
						{
							XmlElement participant = p as XmlElement;
							XmlNode e = participant.SelectSingleNode("Employee/Employee");
							if (e != null)
							{
								XmlElement employee = e as XmlElement;
								Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(employee.GetAttribute("oid"), "Идентификатора сотрудника");
								if (employeeID.Equals(objectID))
									return participant;
							}
						}
						return null;
					};

				Func<XmlElement, Guid, bool> ExistingParticipantHasRole =
					delegate(XmlElement participant, Guid objectID)
					{
						foreach (XmlNode r in participant.SelectNodes("Roles/UserRoleInProject"))
						{
							XmlElement role = r as XmlElement;
							Guid roleID = ObjectOperationHelper.ValidateRequiredArgumentAsID(role.GetAttribute("oid"), "Идентификатор роли участника в параметрах метода");
							if (roleID.Equals(objectID))
								return true;
						}
						return false;
					};

				Func<ProjectTeamParticipant, Guid, bool> NewParticipantHasRole =
					delegate(ProjectTeamParticipant participant, Guid objectID)
					{
						foreach (string oid in participant.RoleIDs)
						{
							Guid roleID = ObjectOperationHelper.ValidateRequiredArgumentAsID(oid, "Идентификатор роли участника в ITracker");
							if (roleID.Equals(objectID))
								return true;
						}
						return false;
					};
				#endregion

                //Вначале добавим данные удаляемых участников:
                foreach (XmlNode p in xmlParticipants.SelectNodes("ProjectParticipant"))
                {
                    XmlElement participant = p as XmlElement;
                    XmlNode e = participant.SelectSingleNode("Employee/Employee");
                    if (e != null)
                    {
                        XmlElement employee = e as XmlElement;
                        Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(employee.GetAttribute("oid"), "Идентификатора сотрудника");

                        if (GetNewParticipantByEmployeeID(aTeamParticipants, employeeID) == null)
                        {
                            XmlElement xmlParticipant =(XmlElement)participant.CloneNode(true);
                            xmlParticipant.InnerXml = "";
                            xmlParticipant.SetAttribute("delete", "1");
                            participantsToDelete.Add(xmlParticipant);
                        }
                    }
                    else
                    {
                        XmlElement xmlParticipant = (XmlElement)participant.CloneNode(true);
                        xmlParticipant.InnerXml = "";
                        xmlParticipant.SetAttribute("delete", "1");
                        participantsToDelete.Add(xmlParticipant);
                    }
                }

                // Для всех участников
				foreach (ProjectTeamParticipant participant in aTeamParticipants)
				{
					// Проверяем идентификатор заданного сотрудника
					Guid uidEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(participant.EmployeeID, "Идентификатор сотрудника");
					// Проверим, есть ли такой
					XmlElement existingParticipant 
						= GetExistingParticipantByEmployeeID(xmlParticipants, uidEmployeeID);
					// Если есть - поменяем роли, если надо
					if (existingParticipant != null)
					{
						bool rolesChanged = false;
						XmlElement roles = existingParticipant.SelectSingleNode("Roles") as XmlElement;

						foreach (string roleID in participant.RoleIDs)
						{
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(roleID, "Идентификатор роли");
							
							// Если новая роль
							if (!ExistingParticipantHasRole(existingParticipant, objectID))
							{
								rolesChanged = true;
								XmlElement role = roles.OwnerDocument.CreateElement("UserRoleInProject");
								role.SetAttribute("oid", roleID);
								roles.AppendChild(role);
							}
						}

						List<XmlNode> oldRoles = new List<XmlNode>();
						foreach (XmlNode r in roles.SelectNodes("UserRoleInProject"))
						{
							oldRoles.Add(r);
						}

						foreach (XmlNode r in oldRoles)
						{
							XmlElement role = r as XmlElement;
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(role.GetAttribute("oid"), "Идентификатор роли участника в ITracker");
							// Если роли больше нет
							if (!NewParticipantHasRole(participant, objectID))
							{
								rolesChanged = true;
								roles.RemoveChild(role);
							}
						}

						// Если роли поменялись
						if (rolesChanged)
						{
							List<XmlNode> propsToDrop = new List<XmlNode>();
							foreach (XmlNode p in existingParticipant.SelectNodes("*"))
							{
								if (p.Name != "Roles")
									propsToDrop.Add(p);
							}
							foreach (XmlNode p in propsToDrop)
							{
								existingParticipant.RemoveChild(p);
							}
							changedParticipants.Add(existingParticipant);
						}
					}
					// Если нету такого - добавим нового
					else
					{
						ObjectOperationHelper participantHelper = GetNewParicipantStub();
						participantHelper.SetPropScalarRef("Employee", "Employee", uidEmployeeID);
						participantHelper.SetPropScalarRef("Folder", "Folder", uidProjectID);
						participantHelper.SetPropValue("Privileges", XPropType.vt_i4, 0);
						foreach (string roleID in participant.RoleIDs)
						{
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(roleID, "Идентификатор роли");
							participantHelper.AddArrayPropRef("Roles", "UserRoleInProject", objectID);
						}
						newParticipants.Add(participantHelper);
					}
				}

				// #3:
				// Строим комплексную датаграмму для записи. Здесь: (а) данные 
				// новых участников проектов, (в) данные старых, удаляемых 
				// участников проектов:
				// ... сначала в датаграмме - только новые
				XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(newParticipants.ToArray());
				newParticipants.Clear();
				newParticipants = null;
				// ... добавим данные измененных:
				foreach (XmlElement participant in changedParticipants)
				{
					xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(participant, true));
				}
				changedParticipants.Clear();
				changedParticipants = null;

                // ... добавим данные удаленных:
                foreach (XmlElement participant in participantsToDelete)
                {
                    xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(participant, true));
                }
                participantsToDelete.Clear();
                participantsToDelete = null;
			
				// #4: 
				// Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
				// будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
				// FolderDirection, обновлены данные папки-проекта
				ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );

				#endregion
			}
			else
			{
				#region Случай "Добавление"

				// #2:
				// Суть обновления: сравниваем заданное описание проектной команды
				// с реальными данными проекта. При этом собираем две коллекции 
				// описаний "участников проектной команды": (а) новых, которые 
				// заданы, но не найдены в проекте, (б) измененных - которых нашли,
				// но у которых нет ролей, заданных в исходном массиве. 
				// Далее (см. #3) из этих коллекций соберем единый массив, котрый
				// передается на запись "комплексной" датаграммой

				ArrayList arrNewParticipants = new ArrayList();
				ArrayList arrUpdatedParticipants = new ArrayList();

				// "Болванка" нового описания участника проектной команды, пока не загруженная
				ObjectOperationHelper helperParicipantTemplate = ObjectOperationHelper.GetInstance( "ProjectParticipant" );

				// идем по массиву:
				for( int nIndex = 0; nIndex < aTeamParticipants.Length; nIndex++ )
				{
					// Проверяем идентификатор заданного сотрудника
					Guid uidEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].EmployeeID, String.Format("Идентификатор сотрудника aTeamParticipants[{0}].EmployeeID", nIndex) );
					
					// Данные есть?..
					XmlElement xmlParticipant = (XmlElement)xmlParticipants.SelectSingleNode( 
						String.Format( "ProjectParticipant[Employee/Employee/@oid='{0}']", uidEmployeeID ) );

					// Нет; создаем нового участника:
					if (null==xmlParticipant)
					{
						// Загружаем "болванку" нового ds-объекта ProjectParticipant
						if ( !helperParicipantTemplate.IsLoaded )
							helperParicipantTemplate.LoadObject();
						// ... все объекты ObjectOperationHelper создаются из одной "болванки":
						ObjectOperationHelper helperNewParticipant = ObjectOperationHelper.CloneFrom( helperParicipantTemplate, false );

						// ... проставляем ссылку на сотудника:
						helperNewParticipant.SetPropScalarRef( "Employee", "Employee", uidEmployeeID );
						// ... сразу проставляем ссылку на проект:
						helperNewParticipant.SetPropScalarRef( "Folder", "Folder", uidProjectID );
						// ... "местные" привилегии - в ноль:
						helperNewParticipant.SetPropValue( "Privileges", XPropType.vt_i4, 0 );
						// ... ссылки на роли:
						for( int nRoleIndex = 0; nRoleIndex < aTeamParticipants[nIndex].RoleIDs.Length; nRoleIndex++ )
						{
							Guid uidRoleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].RoleIDs[nRoleIndex], String.Format("Идентификатор сотрудника aTeamParticipants[{0}].RoleIDs[{1}]", nIndex, nRoleIndex ) );
							helperNewParticipant.AddArrayPropRef( "Roles", "UserRoleInProject", uidRoleID );
						}
						
						// Добавляем в коллекцию описаний новых участниов проектов:
						arrNewParticipants.Add( helperNewParticipant );
					}
					else
					{
						// Участник есть; проверим роли: для этого пойдем по заданому массиву 
						// идентификаторов ролей, и если заданную роль не найдем среди уже 
						// назначенных - то копируем идентификатор в массив "отсутствующих":
						Guid uidParticipantID = new Guid( xmlParticipant.GetAttribute("oid") ); 
						// ...это - массив идентификаторов отсутствующих у участника ролей
						// (его размерность берется по максимуму - как если бы все заданные
						// роли у сотрудника отсуствуют):
						Guid[] aAbsentRoles = new Guid[aTeamParticipants[nIndex].RoleIDs.Length];
						// ...это - кол-во действительно отсутвующих ролей:
						int nAbsentRolesQnt = 0;

						for( int nRoleIndex = 0; nRoleIndex < aTeamParticipants[nIndex].RoleIDs.Length; nRoleIndex++ )
						{
							Guid uidRoleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].RoleIDs[nRoleIndex], String.Format("Идентификатор сотрудника aTeamParticipants[{0}].RoleIDs[{1}]", nIndex, nRoleIndex ) );
							XmlElement xmlParticipantRole = (XmlElement)xmlParticipant.SelectSingleNode(
								String.Format( "Roles/UserRoleInProject[@oid='{0}']", uidRoleID ) );
							if (null==xmlParticipantRole)
								aAbsentRoles[ nAbsentRolesQnt++ ] = uidRoleID;
						}
						
						// Среди заданных нашли такие роли, что у сотрудника еще не заданы:
						if (nAbsentRolesQnt > 0)
						{
							// Прогружаем данные объекта, описывающего участника, сразу с данными по ролям:
							ObjectOperationHelper helperUpdatedParticipant = ObjectOperationHelper.GetInstance( "ProjectParticipant", uidParticipantID );
							helperUpdatedParticipant.LoadObject( new string[]{ "Roles" } );
							
							// Изменяться будут только роли - все остальные свойства сбрасываем
							// Т.к. при этом в массиве должны остаться только указание ссылок 
							// на роли (как существовшие ранее, так и новые), то вырежем данные 
							// и по ролям тоже - в отдельную копию XML. 
							helperUpdatedParticipant.DropPropertiesXmlExcept( "Roles" );
							XmlElement xmlExistsRoles = (XmlElement)helperUpdatedParticipant.PropertyXml("Roles").CloneNode(true);
							helperUpdatedParticipant.ClearArrayProp( "Roles" );

							// Все ранее существовавшие роли - восстановим обратно, только 
							// уже как ссылки (без детальных данных по самой роли):
							foreach( XmlNode xmlRole in xmlExistsRoles.SelectNodes("UserRoleInProject") )
								helperUpdatedParticipant.AddArrayPropRef( 
									"Roles", "UserRoleInProject", 
									new Guid( ((XmlElement)xmlRole).GetAttribute("oid") ) );
							
							// ...и допишем в массив идентификаторы тех ролей, что ранее не нашли:
							for ( int nRoleIndex=0; nRoleIndex < nAbsentRolesQnt; nRoleIndex++ )
								helperUpdatedParticipant.AddArrayPropRef( "Roles", "UserRoleInProject", aAbsentRoles[nRoleIndex] );

							// Обновленное описание участника проектной команды 
							// добавляем в коллекцию "обновленных":
							arrUpdatedParticipants.Add( helperUpdatedParticipant );
						}
					}
				}

				// #3:
				// Из (а) новых описаний участников проектной команды,
				// и (б) измененных участников проектной команды (с изменнным 
				// массивом ролей) собираем общий массив, который передаем
				// на "комплексную" запись:
				int nHelpersQnt = arrNewParticipants.Count + arrUpdatedParticipants.Count;
				ObjectOperationHelper[] helpers = new ObjectOperationHelper[ nHelpersQnt ];
				arrNewParticipants.CopyTo( helpers );
				arrUpdatedParticipants.CopyTo( helpers, arrNewParticipants.Count );

				// ФИНИТА - записываем данные:
				ObjectOperationHelper.SaveComplexDatagram( helpers );

				#endregion
			}

			return true;
		}

		
		/// <summary>
		/// Удаляет описание указанного проекта из системы Incident Tracker
		/// </summary>
		/// <param name="sProjectID">Строковое представление идентификатора проекта</param>
		///	<exception cref="ArgumentNullException">Если sProlectID задан в null</exception>
		///	<exception cref="ArgumentException">Если sProlectID задан в String.Empty</exception>
		[WebMethod(Description="Удаляет описание указанного проекта из системы Incident Tracker")]
		public void DeleteProject( string sProjectID ) 
		{
			// Проверяем корректность параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "Идентификатор удаляемого проекта (sProjectID)" );
			
			// Удаление объекта:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder",uidProjectID );
			helperProject.DeleteObject();
		}

        /// <summary>
        /// Используется для изменения состояния активностей. Вложенные активности так же меняют свое  состояние. 
        /// </summary>
        /// <param name="sActivityID">Идентификатор активности</param>
        /// <param name="nActivitySate">Состояние активности</param>
        /// <param name="sActivityDescription">Комментарий к описанию</param>
        /// <returns>возвращает true в случае успеха, иначе false</returns>
        [WebMethod(Description = "Изменяет состояния активностей")]
        public bool UpdateActivityState(string sActivityID, int nActivitySate, string sActivityDescription, string sInitiatorEmployeeID)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
				sActivityID, 
				"Идентификатор обновляемой активности (sActivityID)"
				);

			if (!string.IsNullOrEmpty(sInitiatorEmployeeID)) ObjectOperationHelper.ValidateOptionalArgument(sInitiatorEmployeeID, "sInitiatorEmployeeID", typeof(Guid));


			ObjectOperationHelper.AppServerFacade.ExecCommand(
				new UpdateActivityStateRequest()
				{
					Activity = uidActivityID,
					Description = sActivityDescription,
					Initiator = !string.IsNullOrEmpty(sInitiatorEmployeeID) ? new Guid(sInitiatorEmployeeID) : Guid.Empty,
					NewState = (FolderStates)nActivitySate
				});

			return true;
        }
        /// <summary>
        /// Метод возвращает информацию о состоянии инцидентов в активности.
        /// Инциденты активности и всех вложенных активностей, проверяются в каком состоянии находятся, 
        /// если все инциденты находятся в состоянии отличном от состояний с типом «В работе» и «На проверке», 
        /// тогда считается что инциденты активности «Закрыты».
        /// </summary>
        /// <param name="sActivityID">Идентификатор активности</param>
        /// <returns>информация о состоянии инцидентов в активности</returns>
        [WebMethod(Description = "Возвращает информацию о состоянии инцидентов в активности")]
        public bool GetActivityIncidentStates(string sActivityID)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                           sActivityID, "Идентификатор обновляемой активности (sActivityID)");
            
            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder", uidActivityID);
            // Пробуем загрузить активность, если не загрузится, то выдаем Exception
            helperActivity.LoadObject();
            // Формируем коллекцию параметров для запроса
            XParamsCollection dsParams = new XParamsCollection();
            dsParams.Add("FolderID", uidActivityID);
            object oValue = ObjectOperationHelper.ExecAppDataSourceScalar("CommonService-BP-HasOpenIncidentsInActivity", dsParams);
            if (oValue == null)
                return true;
            return false;
        }
        /// <summary>
        /// Используется для изменения состояния всех «Открытых» инцидентов относящихся к указанной активности. 
        /// Инциденты подчиненных активностей также изменяются.
        /// </summary>
        /// <param name="sActivityID">Идентификатор активности</param>
        /// <param name="nIncidentStatesCategory">Категория состояний для инцидентов </param>
        /// <param name="sIncidentSolution">Описание решения в инцидентах</param>
        /// <returns>возвращает true в случае успеха, иначе false</returns>
        [WebMethod (Description = "Обновляет статусы инцидентов в заданной активности") ]
        public bool UpdateIncidentStateInActivity(string sActivityID,
                    int nIncidentStatesCategory,
                    string sIncidentSolution)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                            sActivityID, "Идентификатор обновляемой активности (sActivityID)");
			if (
				!Enum.IsDefined(
					typeof(IncidentStateCat), 
					Convert.ChangeType(nIncidentStatesCategory, Enum.GetUnderlyingType(typeof(IncidentStateCat)))
					)
				) throw new ArgumentOutOfRangeException("nIncidentStatesCategory");

            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder", uidActivityID);
            // Пробуем загрузить активность, если не загрузится, то выдастся Exception
			if (!helperActivity.SafeLoadObject(null, null))
				return false;

            XParamsCollection dsParams = new XParamsCollection();
            dsParams.Add("FolderID", uidActivityID);
            dsParams.Add("NewCat", nIncidentStatesCategory);
            // Получаем список обновляемых инцидентов и их новых статусов, вычисленных по категории инц-та
            DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("CommonService-BP-GetList-OpenIncidents", dsParams);
			foreach (DataRow row in oDataTable.Rows)
			{
				if (
						(DBNull.Value == row["NewState"])
                        || (Guid)row["NewState"] == Guid.Empty)
					throw new ApplicationException("Не удалось получить новое состояние для инцидента");
			}
            for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
            {
                Guid uidIncidentID = (Guid)oDataTable.Rows[nRowIndex]["Incident"];
                Guid uidNewState = (Guid)oDataTable.Rows[nRowIndex]["NewState"];
				ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance("Incident", uidIncidentID);
				// Загружаем инцидент
				if (helperIncident.SafeLoadObject(null, null))
				{
					// Если задан параметр sIncidentSolution тогда прогрузим св-во Solution
					if (!String.IsNullOrEmpty(sIncidentSolution))
					{
						helperIncident.UploadBinaryProp("Solution");
						string sNewSolution = String.Empty;
						// Далее добавим наше описание решения к уже существующему
						sNewSolution = helperIncident.PropertyXml("Solution") + Environment.NewLine + sIncidentSolution;
						// Обновим свойство "Solution" в текущем инциденте
						helperIncident.SetPropValue("Solution", XPropType.vt_text, sNewSolution);
					}
					// Обновляем состояние инцидента
					helperIncident.SetPropScalarRef("State", "IncidentSate", uidNewState);
					// Оставляем только те свойства, который точно менялись
					helperIncident.DropPropertiesXmlExcept(new string[] { "Solution", "State" });
					// Сохраняем
					helperIncident.SaveObject();
				}
            }
            return true;
        }

		#endregion
		
		#region Методы, используемые для синхронизации данных Возможностей (пресейлов)

		/// <summary>
		/// Внутренний служебный метод загрузки данных Папки (Folder) типа 
		/// "Пресейл" (Возможность), по заданному идентификатору. 
		/// Проверяет корректность задания идентификатора, а так же тип папки.
		/// </summary>
		/// <param name="sPresaleID">Идентификатор папки-пресейла, в строке</param>
		/// <param name="arrPreloadProperties">
		/// Массив наименований прогружаемых параметров, м.б. null
		/// </param>
		/// <param name="bIsStrictLoad">
		/// Признак "жесткой" загрузки - если указанный объект не будет найден, будет
		/// сгенерировано исклбчение; если параметр задан в false, и объект не будет 
		/// найден, то в кач. результата метод вернет null;
		/// </param>
		/// <returns>
		/// Инициализированный объект - helper или null если объект не найден, 
		/// и признак "жесткой" загрузки (bIsStrictLoad) сброшен
		/// </returns>
		/// <exception cref="ArgumentNullException">Если sPresaleID есть null</exception>
		/// <exception cref="ArgumentException">Если sPresaleID есть пустая строка</exception>
		/// <exception cref="ArgumentException">Если проекта с ID sPresaleID нет и bIsStrictLoad=true</exception>
		/// <exception cref="ArgumentException">Если sPresaleID задает папку - НЕ персейл</exception>
		private ObjectOperationHelper loadPresale( string sPresaleID, bool bIsStrictLoad, string[] arrPreloadProperties ) 
		{
			// Проверяем корректность входных параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sPresaleID, "Идентификатор возможности (sPresaleID)" );
			
			// Загружаем данные: в любом случае испрользуем "мягкую" загрузку
			// при этом проверяем, загрузилось или нет: дальнейшая реакция зависит 
			// от значения флага bIsStrictLoad:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			if ( !helper.SafeLoadObject( null, arrPreloadProperties ) )
			{
				if (bIsStrictLoad)
					throw new ArgumentException( "Возможность с указанным идентификатором (" + sPresaleID + ") не найдена", "sPresaleID" );
				else
					return null;
			}

			// Проверяем, что загруженное описание, представленное объектом типа 
			// "Folder" есть возможность - проверим значение "типа" папки:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				throw new ArgumentException( "Заданный идентификатор (sProjectID) не является идентификатором возможности" );
			
			return helper;			
		}

		
		/// <summary>
		/// Метод преобразования значения состояния папки в соответствующее 
		/// состояние проекта по ведению возможности
		/// </summary>
		/// <param name="enFolderState">Состояние папки</param>
		/// <returns>Соответствующее состояние проекта</returns>
		private PresaleStates getFolder2PresaleState( FolderStates enFolderState ) 
		{
			PresaleStates enPresaleStates;
			switch (enFolderState)
			{
				case FolderStates.Open: enPresaleStates = PresaleStates.Open; break;
				case FolderStates.WaitingToClose: enPresaleStates = PresaleStates.WaitingToClose; break;
				case FolderStates.Closed: enPresaleStates = PresaleStates.Closed; break;
				case FolderStates.Frozen: enPresaleStates = PresaleStates.Frozen; break;
				default:
					throw new ArgumentException( "Неизвестное состояние папки (enFolderState)","enFolderState" );
			}
			return enPresaleStates;
		}
		

		/// <summary>
		/// Метод преобразования значения состояния проекта по ведению возможности
		/// в соответствующее состояние папки 
		/// </summary>
		/// <param name="enPresaleState">Состояние проекта</param>
		/// <returns>Соответствующее состояние папки</returns>
		private FolderStates getPresale2FolderState( PresaleStates enPresaleState ) 
		{
			FolderStates enFolderStates;
			switch (enPresaleState)
			{
				case PresaleStates.Open: enFolderStates = FolderStates.Open; break;
				case PresaleStates.WaitingToClose: enFolderStates = FolderStates.WaitingToClose; break;
				case PresaleStates.Closed: enFolderStates = FolderStates.Closed; break;
				case PresaleStates.Frozen: enFolderStates = FolderStates.Frozen; break;
				default:
					throw new ArgumentException( "Неизвестное состояние проекта по ведению возможности (enPresaleState)","enPresaleState" );
			}
			return enFolderStates;
			
		}
		
		
		/// <summary>
		/// Внутренний метод перевода данных из загруженного объекта-описателя
		/// в объект типа PresaleInfo
		/// </summary>
		/// <param name="helper">Объект описатель, должен представлять данные типа Folder и д.б. загружен</param>
		/// <returns>Объект ProjectInfo с описанием данных проекта</returns>
		private PresaleInfo getPresaleInfoFromHelper( ObjectOperationHelper helper ) 
		{
			// Проверки корректности полученных данных + доразвертывание необходимых 
			// объектных представлений: (1) проверим, что это heler-объект задан 
			// и представляет данные объекта типа "Папка" (Folder):
			if (null==helper)
				throw new ArgumentNullException( "helper", "Перевод в PresaleInfo невозможен: вспомогательный объект-описатель не задан" );
			if ("Folder"!=helper.TypeName)
				throw new ArgumentException( "Перевод в PresaleInfo невозможен: вспомогательный объект-описатель представляет данные типа, отличного от Folder (" + helper.TypeName + ")", "helper" );
			// (2) проверим, что это - возможность:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				throw new ApplicationException( String.Format(
					"Некорректные данные: указанный объект с идентификатором {0} не является возможностью (тип папки - {1})",
					helper.ObjectID.ToString(), 
					((FolderTypeEnum)helper.GetPropValue("Type",XPropType.vt_i2)).ToString() ) );

			
			ObjectOperationHelper helperOrg = helper.GetInstanceFromPropScalarRef( "Customer", false );
			if (null==helperOrg)
				throw new ApplicationException( String.Format(
					"Некорректные данные: для указанной возможности с идентификатором {0} " +
					"не задана организация Клиента, к которому относится данная возможность",
					helper.ObjectID.ToString() ) );
	
			
			PresaleInfo info = new PresaleInfo();
			// Заполняем свойства класса - описателя соотв. значениями объекта:
			info.ObjectID = helper.ObjectID.ToString(); 
			info.CustomerID = helperOrg.ObjectID.ToString();
			info.Name = helper.GetPropValue( "Name", XPropType.vt_string ).ToString();
			//info.Code = safeReadData( helper, "ProjectCode" ).ToString();
			info.NavisionID = safeReadData( helper, "ExternalID" );
			// Статус проекта
			info.State = getFolder2PresaleState( (FolderStates)helper.GetPropValue( "State", XPropType.vt_i2) );
			// Указание идентификатора порожденного проекта - если таковой задан, иначе - null;
			/*
			ObjectOperationHelper helperTargetProject = helper.GetInstanceFromPropScalarRef( ???, false );
			info.TargetProjectID = (null==helperTargetProject ? null : helperTargetProject.ObjectID.ToString());
			*/
			info.TargetProjectID = null;
			
			// Коррекция данных: если код проекта или код Navision есть пустая строка, то делаем их null:
			if (String.Empty == info.Code)
				info.Code = null;
			if (String.Empty == info.NavisionID)
				info.NavisionID = null;
			
			return info;
		}
		
		
		/// <summary>
		/// Возвращает данные всех возможностей (presales), представленных 
		/// в системе Incident Tracker, как массив экземпляров класса 
		/// Croc.IncidentTracker.Services.PresaleInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.PresaleInfo"/>  
		/// </summary>
		[ WebMethod( Description = "Возвращает данные всех возможностей (presale), представленных в системе Incident Tracker" ) ]
		public PresaleInfo[] GetPresalesInfo() 
		{
			// Получам данные всех проектов:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-Presales", null );

			if ( null == oDataTable )
				return new PresaleInfo[0];

			PresaleInfo[] arrPresalesInfo = new PresaleInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// Убедимся, что рассматриваем папку типа "Возможность"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if ( FolderTypeEnum.Presale != enType )
					continue;
				
				PresaleInfo info = new PresaleInfo();

				// Переносим данные обязательных полей
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				info.CustomerID = oDataTable.Rows[nRowIndex]["CustomerID"].ToString();
				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();
				
				// Код проекта и код в Navision в общем случае могут быть и не заданы;
				// более того, случай задания значения как пустой строки нельзя отличить
				// от случая значения null - поэтому случай пустой строки всегда сводим
				// к null-у:
				if ( String.Empty == info.Code )
					info.Code = null;
				
				if ( DBNull.Value==oDataTable.Rows[nRowIndex]["NavisionID"] )
					info.NavisionID = null;
				else
					info.NavisionID = oDataTable.Rows[nRowIndex]["NavisionID"].ToString();
				if ( String.Empty == info.NavisionID )
					info.NavisionID = null;
				
				// Состояние проекта: здесь требуется коррекция - значения из IT 
				// нужно приводить в значения для НСИ:
				info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// Ссылка на порожденный проект может быть и не задана:
				/*
				if ( DBNull.Value == oDataTable.Rows[nRowIndex]["MasterProjectID"] )
					info.TargetProjectID = null;
				else
					info.TargetProjectID = oDataTable.Rows[nRowIndex]["MasterProjectID"].ToString();
				*/
				info.TargetProjectID = null;

				// Добавлем данные в массив
				arrPresalesInfo[nRowIndex] = info;
			}
			return arrPresalesInfo;
		}
	
		
		/// <summary>
		/// Возвращает данные возможности (presale), представленной в системе 
		/// Incident Tracker, по её уникальному идентификатору.
		/// </summary>
		/// <param name="sPresaleID">
		/// Строка с идентификатором возможности, для которой требуется получение 
		/// данных. Если указанная возможность в системе не описана, метод возвращает
		/// null (см. описание результатов)
		/// </param>
		/// <returns>
		/// -- Экземпляр PresaleInfo с описанием возможности, если указанная 
		///		возможность представлена в системе;
		///	-- null, если описание указанной возможности в системе не найдено
		/// </returns>
		[ WebMethod( Description = "Возвращает данные возможности, представленной в системе Incident Tracker, по её идентификатору" ) ]
		public PresaleInfo GetPresaleInfoByID( string sPresaleID ) 
		{
			// Проверка переданного параметра, с его одновременным приведением:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "Идентификатор возможности (sPresaleID)" );

			// Пробуем загрузить данные указанного объекта типа "Папка" (Folder)
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidPresaleID );

			// Объект не найден - в соответствии со спецификацией возвращаем null:
			if ( !helper.SafeLoadObject(null) )
				return null;
			else
				return getPresaleInfoFromHelper(helper);
		}
		
		
	
		/// <summary>
		/// Возвращает детальные данные указанной возможности (presale). 
		/// Данные возвращаются в виде экземпляра класса PresaleAdditionalInfo 
		/// <seealso cref="Croc.IncidentTracker.Services.PresaleAdditionalInfo"/>
		/// </summary>
		/// <param name="sPresaleID">
		/// Строка (System.String) с идентификатором возможности, для которой
		/// требуется получение данных. Задание значения является обязательным.
		/// </param>
		/// <returns>
		/// Данные возможности, как экземпляр класса PresaleAdditionalInfo
		/// </returns>
		///	<exception cref="ArgumentNullException">Если sPresaleID задан в null</exception>
		///	<exception cref="ArgumentException">Если sPresaleID задан в String.Empty</exception>
		///	<exception cref="ArgumentException">Если возможности с идентификатором sPresaleID нет</exception>
		[ WebMethod( Description = "Возвращает детальные (расширенные) данные возможности, заданной идентификатором" ) ]
		public PresaleAdditionalInfo GetPresaleAdditionalInfo( string sPresaleID ) 
		{
			// Проверим переданный параметр:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "Идентификатор возможности (sPresaleID)" );

			// Пробуем получть данные указанной возможности:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "PresaleID", uidPresaleID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetPresaleAdditionalInfo", paramsCollection );

			if (null != oDataTable && 0 == oDataTable.Rows.Count)
				oDataTable = null;
			if (null == oDataTable)
				throw new ArgumentException( "Указанная возможность не найдена", "Идентификатор возможности (sPresaleID)" );

			// Убедимся, что рассматриваем папку типа "Возможность" (Пресейл)
			FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[0]["Type"];
			if ( FolderTypeEnum.Presale != enType )
				throw new ArgumentException( "Указанная возможность не найдена", "Идентификатор возможности (sPresaleID)" );

			// Создаем объект описания, и перезаписываем в него данные:
			PresaleAdditionalInfo info = new PresaleAdditionalInfo();

			info.ObjectID = sPresaleID; 
			info.CustomerID = oDataTable.Rows[0]["CustomerID"].ToString();
			info.Name = oDataTable.Rows[0]["Name"].ToString();
			info.Comments = oDataTable.Rows[0]["Comments"].ToString();
			
			// Код проекта и код в Navision в общем случае могут быть и не заданы;
			// более того, случай задания значения как пустой строки нельзя отличить
			// от случая значения null - поэтому случай пустой строки всегда сводим
			// к null-у:
			if ( DBNull.Value==oDataTable.Rows[0]["NavisionID"] )
				info.NavisionID = null;
			else
				info.NavisionID = oDataTable.Rows[0]["NavisionID"].ToString();
			if ( String.Empty == info.NavisionID )
				info.NavisionID = null;

			// Статус проекта
			info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[0]["State"] );

			// Ссылка на порожденный проект - может быть и не задана:
			if ( DBNull.Value == oDataTable.Rows[0]["TargetProjectID"] )
				info.TargetProjectID = null;
			else
				info.TargetProjectID = oDataTable.Rows[0]["MasterProjectID"].ToString();
			
			// Ссылка на сотрудника - инициатора создания проекта
			if ( DBNull.Value == oDataTable.Rows[0]["InitiatorEmployeeID"] )
				info.InitiatorEmployeeID = null;
			else
				info.InitiatorEmployeeID = oDataTable.Rows[0]["InitiatorEmployeeID"].ToString();
			
			// Дата закрытия возможности - м.б. null, если возможность на момент вызова не закрыта:
			if ( DBNull.Value == oDataTable.Rows[0]["EndDate"] )
				info.EndDate = DateTime.MinValue;
			else
				info.EndDate = (DateTime)oDataTable.Rows[0]["EndDate"];

			// Ссылка на сотрудника, закрывшего возможность (если оно закрыто, конечно)
			if ( PresaleStates.Closed == info.State && DBNull.Value != oDataTable.Rows[0]["EnderEmployeeID"] )
				info.EnderEmployeeID = oDataTable.Rows[0]["EnderEmployeeID"].ToString();
			else
				info.EnderEmployeeID = null;

			return info;
		}
		
		
		/// <summary>
		/// Возвращает данные о направлениях, соотнесенных с указанной возможностью.
		/// Данные о направлениях возвращаются как массив идентификаторов описаний 
		/// направлений в системе Incident Tracker.
		/// </summary>
		/// <param name="sPresaleID">
		/// Строка (System.String) с идентификатором возможности, для которой
		/// требуется получение данных. Задание значения является обязательным.
		/// </param>
		/// <returns>
		/// Массив идентификаторов объектов направлений, заданных для указанной
		/// возможности. Если для возможности направления не заданы, то в качестве 
		/// результата возвращается массив нулевой длины.
		/// </returns>
		///	<exception cref="ArgumentNullException">Если sPresaleID задан в null</exception>
		///	<exception cref="ArgumentException">Если sPresaleID задан в String.Empty</exception>
		///	<exception cref="ArgumentException">Если возможности с идентификатором sPresaleID нет</exception>
		[ WebMethod( Description = "Возвращает данные о направлениях, соотнесенных с указанной возможностью" ) ]
		public string[] GetPresaleDirectionsInfo( string sPresaleID ) 
		{
			// Проверим переданный параметр:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "Идентификатор возможности (sPresaleID)" );

			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "PresaleID", uidPresaleID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-PresaleDirections", paramsCollection );

			// Если запрос не вернул ВООБЩЕ НИЧЕГО, значит указанная возможность 
			// в системе не найдена; в этом случае генерируем исключение:
			if (null == oDataTable || 0 == oDataTable.Columns.Count)
				throw new ArgumentException( "Указанная возможность не найдена", "Идентификатор возможности (sPresaleID)" );
			
			// Если количество строк в результирующем рекордсете - нулевое, 
			// то в соотв. со спецификацией, возвращаем массив нулевй длины:
			if (null != oDataTable && 0 == oDataTable.Rows.Count)
				return new string[0];

			// Формируем итоговый массив с идентификаторами направлений:
			string[] arrProjectDirectionIDs = new string[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
				arrProjectDirectionIDs[nRowIndex] = oDataTable.Rows[nRowIndex]["DirectionID"].ToString();
			return  arrProjectDirectionIDs;
		}
		
		
		/// <summary>
		/// Создает в системе Incident Tracker описание возможности (presale) 
		/// с заданными параметрами.
		/// </summary>
		/// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
		/// <param name="sCode">Строка с уникальным кодом возможности</param>
		/// <param name="sName">Строка с наименованием возможности</param>
		/// <param name="sNavisionID">Строка с кодом возможности в Navision</param>
		/// <param name="enInitialState">Начальное состояние проекта возможности</param>
		/// <param name="sProjectID">Строка с идентификатором проекта, порожденного в рез-те возможности</param>
		/// <param name="sDescription">Строка с текстом описания / комментария</param>
		/// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора создания</param>
		/// <returns>Строка с идентификатором созданного описания возможности</returns>
		[ WebMethod( Description = "Создает в системе Incident Tracker описание возможности (presale) с заданными параметрами" ) ]
		public string CreatePresale(
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			PresaleStates enInitialState,
			string sProjectID,
			string sDescription,
			string sInitiatorEmployeeID ) 
		{
			// Проверяем корректность входных параметров:
			ObjectOperationHelper.ValidateRequiredArgument( sCustomerID, "Идентификатор организации - Клиента (sCustomerID)", typeof(Guid) );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "Уникальный код возможности (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "Наименование возможности (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sProjectID, "Идентификатор порожденного проекта (sProjectID)", typeof(Guid) );
			ObjectOperationHelper.ValidateRequiredArgument( sInitiatorEmployeeID, "Идентификатор сотрудника-инициатора создания возможности (sInitiatorEmployeeID)", typeof(Guid) );

			// Генерируем идентификатор новой возможности и вызываем спец. 
			// метод, создающий возможность с ЯВНО ЗАДАННЫМ идентификатором:
			string sNewProjectID = Guid.NewGuid().ToString();
			CreateIdentifiedPresale( sNewProjectID, sCustomerID, sCode, sName, sNavisionID, enInitialState, sProjectID, sDescription, sInitiatorEmployeeID );
			
			return sNewProjectID;
		}
		
		
		/// <summary>
		/// Создает в системе Incident Tracker описание возможности (presale) 
		/// с указанными параметрами и ЗАДАННЫМ уникальным идентификатором.
		/// </summary>
		/// <param name="sNewPresaleID">Строка с идентификатором для создаваемой возможности</param>
		/// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
		/// <param name="sCode">Строка с кодом проекта</param>
		/// <param name="sName">Строка с наименованием проекта</param>
		/// <param name="sNavisionID">Строка с кодом проекта в сист. Navision</param>
		/// <param name="enInitialState">Начальное состояние создаваемой возможности</param>
		/// <param name="sProjectID">Строка с идентификатором связанного "порожденного" проекта</param>
		/// <param name="sDescription">Текст описания (комментария) возможности</param>
		/// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора проекта</param>
		[ WebMethod( Description = "Создает в системе Incident Tracker описание возможности с заданными параметрами и заранее указанным уникальным идентификатором" ) ]
		public void CreateIdentifiedPresale( 
			string sNewPresaleID,
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			PresaleStates enInitialState,
			string sProjectID,
			string sDescription,
			string sInitiatorEmployeeID ) 
		{
			// Проверяем корректность входных параметров:
			Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewPresaleID, "Уникальный идентификатор создаваемой возможности (sNewPresaleID)" );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "Уникальный код возможности (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "Наименование возможности (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sProjectID, "Идентификатор порожденного проекта (sProjectID)", typeof(Guid) );
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sCustomerID, "Идентификатор организации - Клиента (sCustomerID)" );
			Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "Идентификатор сотрудника - инициатора создания возможности (sInitiatorEmployeeID)" );

			// ОСОБЕННАЯ ПРОВЕРКА: 
			// Бизнес-правило: Создание возможностей под КРОК-ом при помощи сервиса 
			// запрещено. Следовательно: проверяем, что заданная организация не есть 
			// КРОК; идентификатор последнего д.б. задан в прикладном конфигурационном 
			// файле сервисов (и, соотв. представлен в объекте - описателе конфигурации,
			// ServiceConfig)
			if ( uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID )
				throw new ArgumentException( 
					String.Format(
						"Создание возможностей для организации - владельца системы \"{0}\" при помощи метода сервиса " +
						"запрещено. Создание таких возможностей должно выполняться непосредственно в системе Incident " +
						"Tracker, пользователем системы, обладающим необходимыми полномочиями.",
						ServiceConfig.Instance.OwnOrganization.GetPropValue( "ShortName", XPropType.vt_string )
					), "sCustomerID" );

			// Болванка нового объекта - возможности: загружаем, и ПОСЛЕ загрузки 
			// болваник переставляем идентификатор объекта на заданный:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder" );
			helperProject.LoadObject();
			helperProject.NewlySetObjectID = uidNewProjectID;
			
			// Задаем свойства возможности, в соотв. с заданными значениями параметров:
			// ... возможность - это папка с типом "Пресейл":
			helperProject.SetPropValue( "Type", XPropType.vt_i2, FolderTypeEnum.Presale );
			// ... и ВСЕГДА (при создании проекта через сервис) - указываем тип проектных 
			// затрат как "Пресейлы"; идентификатор соотв. Activity Type берем из конфигурации:
			helperProject.SetPropScalarRef( 
				"ActivityType", 
				ServiceConfig.Instance.PresaleProjectsActivityType.TypeName, 
				ServiceConfig.Instance.PresaleProjectsActivityType.ObjectID );

			// ... задаем все скаляры, указанные параметарми:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sName );
			// ... идентификатор проекта в Navision для треккера не является обязательным;
			// в кач. значения может быть задан null или пустая строка - сведем все 
			// к пустой строке - при записи в БД будет NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNavisionID? String.Empty : sNavisionID) );
			// ... статус проекта при создании соотносим явно: 
			helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getPresale2FolderState(enInitialState));

			// Проставляем ссылки:
			// ...на сотрудника - инициатора проекта 
			helperProject.SetPropScalarRef( "Initiator", "Employee", uidInitEmployeeID );
			// ...на организацию:
			helperProject.SetPropScalarRef( "Customer", "Organization", uidOrganizationID );
			
			// Записываем новый объект:
			helperProject.SaveObject();
		}
		
		
		/// <summary>
		/// Изменение параметров описания указанной возможности (presale) в системе Incident Tracker.
		/// </summary>
		/// <param name="sPresaleID">Строковое представление идентификатора описания изменяемой возожности</param>
		/// <param name="sNewCustomerID">Строковое представление идентификатора организации - Клиента</param>
		/// <param name="sNewCode">Строка с новым кодом возможности</param>
		/// <param name="sNewName">Строка с новым наименованием возможности</param>
		/// <param name="sNewNavisionID">Строка с новым кодом возможности в Navision</param>
		/// <returns>
		/// -- True - если указанная возможность найдена и успешно обновлена;
		/// -- False - если указанная возможность не найдена.
		/// </returns>
		/// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
		[ WebMethod( Description = "Изменение параметров описания указанной возможности в системе Incident Tracker" ) ]
		public bool UpdatePresale( 
			string sPresaleID,
			string sNewCustomerID, 
			string sNewCode,
			string sNewName,
			string sNewNavisionID ) 
		{
			// Проверяем парамтры
			//ObjectOperationHelper.ValidateRequiredArgument( sNewCode, "Уникальный код возможности (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sNewName, "Наименование возможности (sName)" );
			Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewCustomerID, "Идентификатор организации - Клиента (sCustomerID)" );

			// Загружаем указанную возможность: внутренний метод проверяет корректность параметра
			ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, null );
			// ... если объект не найден - просто вернем false:
			if (null==helperPresale)
				return false;

			// Заменяем заданные данные возможности:
			//helperPresale.SetPropValue( "ProjectCode", XPropType.vt_string, sNewCode );
			helperPresale.SetPropValue( "Name", XPropType.vt_string, sNewName );
			// Идентификатор проекта в Navision для треккера не является обязательным;
			// поэтому в кач. допустимых значений параметра принимаются и null, и пустая
			// строка; null сводится к пустой строке - при записи в БД будет NULL:
			helperPresale.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNewNavisionID? String.Empty : sNewNavisionID) );
			
			// Перестановка организации клиента: проверим, какая организация указана сейчас:
			ObjectOperationHelper helperOrg = helperPresale.GetInstanceFromPropScalarRef( "Customer" );
			// ...изменяем значение только если оно действительно изменилось:
			if (helperOrg.ObjectID!=uidNewCustomerOrgID)
				helperPresale.SetPropScalarRef( "Customer", "Organization", uidNewCustomerOrgID );

			// Сбросим в датаграмме все свойства, которые точно не изменяются:
            helperPresale.DropPropertiesXml(new string[] { "ActivityType", "Type", "State", "IsLocked", "Parent" });
			// Записываем измененные данные:
			helperPresale.SaveObject();

			return true;
		}
		

		/// <summary>
		/// Изменяет данные о соотнесении указанной возможности с заданными направлениями.
		/// </summary>
		/// <param name="sPresaleID">
		/// Строковое представление идентификатора изменяемого описания проекта. 
		/// Задание значения яв-ся обязательным. 
		/// </param>
		/// <param name="aDirectionsIDs">
		/// Массив строк с идентификаторами направлений, соотносимых с возможностью. 
		/// Все ранее заданные направления будут отменены. В качестве значения может 
		/// быть задан пустой массив - в этом случае все направления для указанной
		/// возможности отменяются.
		/// Задаваемые направления должны быть представлены в системе Incident Tracker.
		/// </param>
		/// <returns>
		/// -- True - если указанна возможность найдена и успешно обновлен;
		/// -- False - если указанна возможность не найдена.
		/// </returns>
		/// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
		[ WebMethod( Description = "Изменяет данные о соотнесении указанной возможности с заданными направлениями" ) ]
		public bool UpdatePresaleDirections( string sPresaleID, string[] aDirectionsIDs ) 
		{
			// Проверим переданный параметр:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "Идентификатор возможности (sPresaleID)" );
			// ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
			if (null==aDirectionsIDs)
				aDirectionsIDs = new string[0];


			// #1:
			// Загружаем указанную возможность: внутренний метод проверяет корректность параметра
			ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, new string[]{ "FolderDirections" }  );
			// ... если объект не найден - просто вернем false:
			if (null==helperPresale)
				return false;
			// Сразу изымем из датаграммы все свойства, кроме изменяемого - FolderDirections,
			// для упрошения работы с XML датаграммы и просто параноии ради
			helperPresale.DropPropertiesXmlExcept( "FolderDirections" );


			// #2:
			// Связь возможности и направления выполняется при помощи спец. служебного 
			// объекта FolderDirection, который также хранит значение доли затрат
			// по направлению. 
			//
			// Для каждого заданного направления создадим описатель данных нового 
			// FolderDirection; всего их будет столько же, сколько и идентификаторов
			// заданных направлений - создавать будем массивом. При этом в массиве 
			// выделим на один элемент больше - в последний потом загрузим данные 
			// самой возможности; все вместе в одном массиве - потому что так удобнее 
			// комплексную датаграмму (см. далее #4)
			ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ aDirectionsIDs.Length + 1 ];
			for( int nIndex = 0; nIndex < aDirectionsIDs.Length; nIndex++ )
			{
				// Проверяем идентификатор заданного направления
				Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aDirectionsIDs[nIndex], String.Format("Идентификатор направления aDirectionsIDs[{0}]",nIndex) );

				// Поищем среди существующих направлений
				foreach( XmlElement xmlFolderDirection in helperPresale.PropertyXml( "FolderDirections" ).ChildNodes )
				{
					if( ( (XmlElement)xmlFolderDirection.SelectSingleNode( "Direction/Direction" ) ).GetAttribute("oid").Equals(aDirectionsIDs[nIndex], StringComparison.InvariantCultureIgnoreCase) )
					{
						arrHelpers[nIndex] = ObjectOperationHelper.GetInstance( "FolderDirection", new Guid( xmlFolderDirection.GetAttribute("oid") ) );
						helperPresale.PropertyXml( "FolderDirections" ).RemoveChild( xmlFolderDirection );
						break;
					}
				}
				if( arrHelpers[nIndex] == null )
				{
					// Загружаем "болванку" нового служебного ds-объекта FolderDirection
					arrHelpers[nIndex] = ObjectOperationHelper.GetInstance( "FolderDirection" );	
				}
				arrHelpers[nIndex].LoadObject();
				// ... проставляем ссылку на направление:
				arrHelpers[nIndex].SetPropScalarRef( "Direction", "Direction", uidDirectionID );
				// ... и сразу проставляем ссылку на возможность:
				arrHelpers[nIndex].SetPropScalarRef( "Folder", "Folder", uidProjectID );
				// ... "доля затрат" - 100 если направление одно, или 0 если направлений несколько:
                if (aDirectionsIDs.Length == 1)
                {
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 100);
                }
                else
                {
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 0);
                }
			}
			// ... последний элемент массива - сама возможность (см. далее #4):
			arrHelpers[aDirectionsIDs.Length] = helperPresale;


			// #3:
			// Если для возможности были определены направления, то, соотв., существуют 
			// служебные объекты FolderDirection, связывающие проект и направления. 
			// 
			// Для снятия связи м/у возможностью и направлением эти служебные объекты надо
			// удалить. Удаление выполним одновременно с записью измененной датаграммы самой
			// возможности, как "комплексной" датаграммы, в которой все FolderDirection
			// будут помечены как удаленные - для них будет задан атрибут delete="1".
			// 
			// Изымаем XML-данные свойства FolderDirection, сохранив при этом их клон -
			// далее при создании комплексной датаграммы данные из клона используем
			// для формирования записией об удаляемых объектах (см #4). В самом объекте
			// "Папка" все старые ссылки на FolderDirections удалим, а новые - добавим:

			XmlElement xmlFolderDirections = (XmlElement)helperPresale.PropertyXml( "FolderDirections" ).CloneNode( true );
			// ... удаляем старые ссылки:
			helperPresale.ClearArrayProp( "FolderDirections" );
			// ... новые - добавляем:
			// Идем по массиву вспомогательных объектов, и помним при этом:
			// -- что последний элемент - сама возможность, её учитывать на надо, 
			//		поэтому цикл до длины массива минус один;
			// -- что данные вспомогательных объектов в массиве еще не записаны, 
			//		поэтому для получения идентификатора пользуемся NewlySetObjectID
			for( int nIndex=0; nIndex<arrHelpers.Length-1; nIndex++ )
				helperPresale.AddArrayPropRef( "FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID );

						
			// #4:
			// Строим комплексную датаграмму для записи. Здесь: (а) данные самой
			// изменной возможности, (б) данные новых FolderDirection-ов, (в) данные 
			// старых, удаляемых FolderDirection-ов
			XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm( arrHelpers );
			// ... в датаграмме уже есть измененный и новые объекты - их данные 
			// перенесены из helper-ов. Добавим данные удаляемых:
			foreach( XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection") )
			{
				XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild( xmlDatagrammRoot.OwnerDocument.ImportNode( xmlFolderDirection, true) );
				// содержимое данных удаляемого FolderDirection уже не важно - удаляем (грубо)
				xmlDeletedFolderDirection.InnerXml = "";
				// ... устанавливаем атриубут delete="1", ключ для сервера, 
				// указывающий что соответствующий объект в БД надо удалить
				xmlDeletedFolderDirection.SetAttribute( "delete", "1" );
			}

			
			// #5: 
			// Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
			// будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
			// FolderDirection, обновлены данные папки-возомжности
			ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );
			
			return true;
		}

        /* Новая версия web-сервиса UpdatePresaleDirections. Пока отключена
         * 
         * 
        /// <summary>
        /// Изменяет данные о соотнесении указанного пресейла с заданными направлениями.
        /// </summary>
        /// <param name="sPresaleID">
        /// Строковое представление идентификатора изменяемого описания пресейла. 
        /// Задание значения яв-ся обязательным. 
        /// </param>
        /// <param name="PresaleDirections">
        /// Массив классов PresaleDirection, в котором содержится информация по направлениям 
        /// соотносимых с пресейлом. 
        /// Все ранее заданные направления для пресейла будут отменены. В качестве 
        /// значения может быть задан пустой массив - в этом случае все направления
        /// для указанного пресейла отменяются.
        /// Задаваемые направления должны быть представлены в системе Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - если указанна возможность найдена и успешно обновлен;
        /// -- False - если указанна возможность не найдена.
        /// </returns>
        /// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
        [ WebMethod( Description = "Изменяет данные о соотнесении указанного пресейла с заданными направлениями" ) ]
        public bool UpdatePresaleDirections(string sPresaleID, ProjectDirection[] PresaleDirections) 
        {
            // Проверим переданный параметр:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "Идентификатор возможности (sPresaleID)" );
            // ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
            if (null == PresaleDirections)
                PresaleDirections = new ProjectDirection[0];


            // #1:
            // Загружаем указанный пресейл: внутренний метод проверяет корректность параметра
            ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, new string[]{ "FolderDirections" }  );
            // ... если объект не найден - просто вернем false:
            if (null==helperPresale)
                return false;
            // Сразу изымем из датаграммы все свойства, кроме изменяемого - FolderDirections,
            // для упрошения работы с XML датаграммы и просто параноии ради
            helperPresale.DropPropertiesXmlExcept( "FolderDirections" );

            // Сумма всех переданных процентов аккамулируется
            int nTotalPercentage = 0;

            // #2:
            // Связь пресейла и направления выполняется при помощи спец. служебного 
            // объекта FolderDirection, который также хранит значение доли затрат
            // по направлению. 
            //
            // Для каждого заданного направления создадим описатель данных нового 
            // FolderDirection; всего их будет столько же, сколько и идентификаторов
            // заданных направлений - создавать будем массивом. При этом в массиве 
            // выделим на один элемент больше - в последний потом загрузим данные 
            // самого пресейла; все вместе в одном массиве - потому что так удобнее 
            // комплексную датаграмму (см. далее #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[PresaleDirections.Length + 1];
            for (int nIndex = 0; nIndex < PresaleDirections.Length; nIndex++)
            {
                // Проверяем идентификатор заданного направления
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(PresaleDirections[nIndex].DirectionID, String.Format("Идентификатор направления ProjectDirections[{0}].DirectionID", nIndex));

                // Проверяем процент заданного направления.
                int nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(PresaleDirections[nIndex].Percentage, String.Format("Процент распределения затрат по направлению ProjectDirections[{0}].Percentage", nIndex));


                // Поищем среди существующих направлений
                foreach (XmlElement xmlFolderDirection in helperPresale.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(PresaleDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperPresale.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // Загружаем "болванку" нового служебного ds-объекта FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... проставляем ссылку на направление:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... и сразу проставляем ссылку на проект:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "доля затрат" - в ноль:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                nTotalPercentage += nPercentage;
            }
            // Если передано хотя бы одно направление, сумма процентных долей должна быть равна 100
            if ((PresaleDirections.Length > 0) && (nTotalPercentage != 100))
                throw new ArgumentException("Сумма процентных долей по направлениям должна быть равна 100");
            
            // ... последний элемент массива - сам пресейл (см. далее #4):
            arrHelpers[PresaleDirections.Length] = helperPresale;


            // #3:
            // Если для пресейла были определены направления, то, соотв., существуют 
            // служебные объекты FolderDirection, связывающие пресейл и направления. 
            // 
            // Для снятия связи м/у пресейлом и направлением эти служебные объекты надо
            // удалить. Удаление выполним одновременно с записью измененной датаграммы самой
            // возможности, как "комплексной" датаграммы, в которой все FolderDirection
            // будут помечены как удаленные - для них будет задан атрибут delete="1".
            // 
            // Изымаем XML-данные свойства FolderDirection, сохранив при этом их клон -
            // далее при создании комплексной датаграммы данные из клона используем
            // для формирования записией об удаляемых объектах (см #4). В самом объекте
            // "Папка" все старые ссылки на FolderDirections удалим, а новые - добавим:

            XmlElement xmlFolderDirections = (XmlElement)helperPresale.PropertyXml( "FolderDirections" ).CloneNode( true );
            // ... удаляем старые ссылки:
            helperPresale.ClearArrayProp( "FolderDirections" );
            // ... новые - добавляем:
            // Идем по массиву вспомогательных объектов, и помним при этом:
            // -- что последний элемент - сама возможность, её учитывать на надо, 
            //		поэтому цикл до длины массива минус один;
            // -- что данные вспомогательных объектов в массиве еще не записаны, 
            //		поэтому для получения идентификатора пользуемся NewlySetObjectID
            for( int nIndex=0; nIndex<arrHelpers.Length-1; nIndex++ )
                helperPresale.AddArrayPropRef( "FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID );

						
            // #4:
            // Строим комплексную датаграмму для записи. Здесь: (а) данные самой
            // изменной возможности, (б) данные новых FolderDirection-ов, (в) данные 
            // старых, удаляемых FolderDirection-ов
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm( arrHelpers );
            // ... в датаграмме уже есть измененный и новые объекты - их данные 
            // перенесены из helper-ов. Добавим данные удаляемых:
            foreach( XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection") )
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild( xmlDatagrammRoot.OwnerDocument.ImportNode( xmlFolderDirection, true) );
                // содержимое данных удаляемого FolderDirection уже не важно - удаляем (грубо)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... устанавливаем атриубут delete="1", ключ для сервера, 
                // указывающий что соответствующий объект в БД надо удалить
                xmlDeletedFolderDirection.SetAttribute( "delete", "1" );
            }

			
            // #5: 
            // Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
            // будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
            // FolderDirection, обновлены данные папки-возомжности
            ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );
			
            return true;
        }
        */

   		/// <summary>
		/// Удаляет описание указанной возможности из системы Incident Tracker
		/// </summary>
		/// <param name="sPresaleID">Строковое представление идентификатора удаляемой возможности</param>
		///	<exception cref="ArgumentNullException">Если sProlectID задан в null</exception>
		///	<exception cref="ArgumentException">Если sProlectID задан в String.Empty</exception>
		[ WebMethod( Description = "Удаляет описание указанной возможности из системы Incident Tracker" ) ]
		public void DeletePresale( string sPresaleID ) 
		{
			// Проверяем корректность параметров:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sPresaleID, "Идентификатор удаляемой возможности (sPresaleID)" );
			
			// Удаление объекта:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			helperProject.DeleteObject();
		}
		
		
		
		
		
		/// <summary>
		/// Изменяет состояние возможности, описание которой представлено в системе.
		/// </summary>
		/// <param name="sPresaleID">
		/// Строка (System.String) с указанием идентификатора возможности в системе 
		/// Incident Tracker (если значение параметра bIsExternalID есть False), или 
		/// идентификатора возможности в системе CRM (если значение параметра 
		/// bIsExternalID есть True).
		/// </param>
		/// <param name="bIsExternalID">
		/// Признак, указывающий смысл идентификатора, задаваемого в sPresaleID:
		///		- false - идентификатор возможности в системе Incident Tracker;
		///		- true – идентификатор возможности в системе CRM;
		/// </param>
		/// <param name="enNewState">
		/// Значение состояния, задаваемого для возможности, заданной идентификатором 
		/// sPresaleID; одно из значений перечисления <see ref="PresaleStates"/>
		/// </param>
		/// <returns></returns>
		//[WebMethod( Description="Изменяет состояние возможности, описание которой представлено в системе Incident Tracker." )]		
		[Obsolete]
		public bool UpdatePresaleState(
			string sPresaleID,
			bool bIsExternalID, 
			PresaleStates enNewState ) 
		{
			// TODO: ПОКА ПРЕСЕЙЛ НЕ МОЖЕТ БЫТЬ ЗАДАН СВОИМ ВНЕШНИМ ИДЕНТИФИКАТОРОМ 
			// (идентификатором в CRM) - так как этих данных нет в системе!
			if (bIsExternalID)
				throw new ArgumentException("В данной реализации возможность не может быть задана внешним идентификатором (идентификатором в CRM), так как этих данных нет в системе Incident Tracker", "bIsExternalID" );

			// Проверяем корректность параметров: если заданный идентификатор - 
			// это идентификатор возможности в IT, то это должен быть Guid:
			Guid uidPresaleID = Guid.Empty;
			if (!bIsExternalID)
				uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sPresaleID, "Идентификатор возможности в системе IT (sOrganizationID)" );

			// Загружаем данные указанной возможности (папки) во вспомогательный 
			// объект; при этом используем "мягкий" способ загрузки - т.к. если 
			// объекта нет, то нам нужно вернуть корректный результат:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder" );
			XParamsCollection identityParams = new XParamsCollection();
			// TODO: при корректной обработке bIsExternalID здесь д.б. "вилка":
			identityParams.Add( "ObjectID", uidPresaleID );
			
			// ... если загрузить не получилось - в соотв. с требованиями выходим с результатом false:
			if ( !helper.SafeLoadObject(identityParams) )
				return false;
			// ... проверим, что загруженные данные - действительно проект 
			// по ведению возможности; если это не так, то "сделаем вид", 
			// что указанного объекта нет в системе - в соотв. с требованиями
			// выйдем с false:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				return false; 

			// Изменяем состояние на указанное:
			helper.SetPropValue( "State", XPropType.vt_i2, (int)getPresale2FolderState(enNewState) );
			// ...все остальные свойства не меняются:
			helper.DropPropertiesXmlExcept( "State" );
			// ...ЗАПИСЫВАЕМ ИЗМЕНЕНИЯ:
			helper.SaveObject();

			return true;
		}
		
		
		/// <summary>
		/// Предоставляет перечень всех идентификаторов всех возможностей, 
		/// описанных в системе Incident Tracker
		/// </summary>
		/// <param name="bListAsExternalIDs">
		/// Логический признак, определяющий тип идентификаторов, возвращаемых 
		/// в результирующем массиве: если значение параметра задано в false, 
		/// то в результате метод возвращает массив идентификаторов возможностей 
		/// в системе Incident Tracker. Если значение параметра задано как true, 
		/// то значения результирующего массива есть идентификаторы возможностей 
		/// в системе CRM.
		/// </param>
		/// <param name="bListFrozen">
		/// Логический признак, определяющий, будут ли включаться в результирующий 
		/// массив идентификаторы возможностей, состояние которых на момент вызова 
		/// определено как "Заморожено"
		/// </param>
		/// <param name="bListClosed">
		/// Логический признак, определяющий, будут ли включаться в результирующий 
		/// массив идентификаторы возможностей, состояние которых на момент вызова 
		/// определено как "Закрыто"
		/// </param>
		/// <returns></returns>
		//[WebMethod( Description="Предоставляет перечень всех идентификаторов всех возможностей, описанных в системе Incident Tracker." )]
		[Obsolete]
		public string[] ListPresales(
			bool bListAsExternalIDs,
			bool bListFrozen,
			bool bListClosed ) 
		{
			// TODO: ПОКА СПИСОК ВНЕШНИХ ИДЕНТИФИКАТОРОВ (идентификаторов в CRM)
			// не может быть получен - так как этих данных нет в системе!
			if (bListAsExternalIDs)
				throw new ArgumentException("В данной реализации список внешних идентификаторов возможности (идентификаторов в CRM) не может быть получен, так как этих данных нет в системе Incident Tracker", "bListAsExternalIDs" );
			
			// Получам данные всех проектов:
			// ...формируем параметры источника данных:
			XParamsCollection srcParams = new XParamsCollection();
			// Параметр "InState" - это массив с указанием состяний отбираемых
			// папок: открытые и в ожидании закрытия - отбираются безусловно:
			srcParams.Add( "InState", FolderStatesItem.Open.IntValue );
			srcParams.Add( "InState", FolderStatesItem.WaitingToClose.IntValue );
			// "замороженные" и "закрытые" - в зависимости от параметров метода:
			if (bListFrozen)
				srcParams.Add( "InState", FolderStatesItem.Frozen.IntValue );
			if (bListClosed)
				srcParams.Add( "InState", FolderStatesItem.Closed.IntValue );

			// ... вызываем источник данных:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Presales-GetIDsList", srcParams );

			if ( null == oDataTable )
				return null;
			if ( 0 == oDataTable.Rows.Count)
				return null;

			// Переводим в массив строк:
			string[] arrPresaleIDs = new string[ oDataTable.Rows.Count ];
			for( int nIndex=0; nIndex<oDataTable.Rows.Count; nIndex++ )
				arrPresaleIDs[nIndex] = oDataTable.Rows[nIndex][0].ToString();
			
			return arrPresaleIDs;
		}
		
		
		/// <summary>
		/// Предоставляет данные всех возможностей, описанных в системе.
		/// </summary>
		/// <param name="sTargetOrganizationID">
		/// Идентификатор целевой организации, для которой выбираются данные возможностей;
		/// Не обязаьльный параметр; если не задан (null), метод возвращает данные по всем
		/// возможностям всех организаций Клиентов, представленных в системе
		/// </param>
		/// <param name="bReadFrozen">
		/// Логический признак, определяющий, будут ли включаться в результирующий 
		/// массив описания возможностей, состояние которых на момент вызова 
		/// определено как "Заморожено" (см. так же описание PresaleInfo.State)
		/// </param>
		/// <param name="bReadClosed">
		/// Логический признак, определяющий, будут ли включаться в результирующий 
		/// массив описания возможностей, состояние которых на момент вызова 
		/// определено как "Закрыто" (см. описание PresaleInfo.State)
		/// </param>
		/// <returns>
		/// Массив описаний возможностей – экземпляров типа PresaleInfo. Если 
		/// в системе IT нет описаний возможностей (соответствующих указанным 
		/// условиям перечня, задаваемым параметрами bReadFrozen и bReadClosed),
		/// метод возвращает null.
		/// </returns>
		//[WebMethod( Description="Предоставляет данные всех возможностей, описанных в системе Incident Tracker." )]
		[Obsolete]
		public PresaleInfo[] ReadAllPresales(
			string sTargetOrganizationID,
			bool bReadFrozen,
			bool bReadClosed ) 
		{
			Guid uidTargetOrganizationID = Guid.Empty;
			if ( null != sTargetOrganizationID )
				uidTargetOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sTargetOrganizationID, "Идентификатор целевой организации (sTargetOrganizationID)" );
			
			// Получам данные всех проектов:
			// ...формируем параметры источника данных:
			XParamsCollection srcParams = new XParamsCollection();
			// Параметр "InState" - это массив с указанием состяний отбираемых
			// папок: открытые и в ожидании закрытия - отбираются безусловно:
			srcParams.Add( "InState", FolderStatesItem.Open.IntValue );
			srcParams.Add( "InState", FolderStatesItem.WaitingToClose.IntValue );
			// "замороженные" и "закрытые" - в зависимости от параметров метода:
			if (bReadFrozen)
				srcParams.Add( "InState", FolderStatesItem.Frozen.IntValue );
			if (bReadClosed)
				srcParams.Add( "InState", FolderStatesItem.Closed.IntValue );
			// ...Если задан идентификатор целевой организации - добавляем его:
			if ( Guid.Empty != uidTargetOrganizationID )
				srcParams.Add( "TargetOrgID", uidTargetOrganizationID );

			// ... вызываем источник данных:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Presales-GetList", srcParams );

			if ( null == oDataTable )
				return null;
			if ( 0 == oDataTable.Rows.Count)
				return null;

			// Получаем данные всех описаний возможностей в IT, на основании 
			// данных формируем массив объектных описаний:
			PresaleInfo[] arrPresalesInfo = new PresaleInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// Очередное описание возможности:
				PresaleInfo info = new PresaleInfo();

				// Переносим данные полей:
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				//info.RefCodePresale =  safeDbString2String( oDataTable.Rows[nRowIndex]["RefCodePresale"] );; // TODO: ПОКА ЭТИХ ДАННЫХ В СИСТЕМЕ НЕТ, всегда будет NULL - см. запрос

				info.CustomerID = safeDbString2String( oDataTable.Rows[nRowIndex]["CustomerID"] );
				info.Name = safeDbString2String( oDataTable.Rows[nRowIndex]["Name"] );
				info.Code = safeDbString2String( oDataTable.Rows[nRowIndex]["Code"] );
				info.NavisionID = safeDbString2String( oDataTable.Rows[nRowIndex]["NavisionID"] );
				
				// ... состояние папки переводим в состояние пресейла, и на
				// основании этих данных проставляем синтетические флаги:
				info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// ... инициатор:
				info.InitiatorID = safeDbString2String( oDataTable.Rows[nRowIndex]["InitiatorID"] );

				// Добавляем описание в результирующий массив всех описаний
				arrPresalesInfo[nRowIndex] = info;
			}

			return arrPresalesInfo;
		}
		
		#endregion

		#region Методы, используемые для синхронизации данных Тендеров

		/// <summary>
		/// Возвращает данные папок тендеров, представленных в системе Incident Tracker, 
		/// как массив экземпляров класса Croc.IncidentTracker.Services.ProjectInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.TenderInfo"/>
		/// </summary>
		[WebMethod(Description = "Возвращает данные папок тендеров, представленных в системе Incident Tracker")]
		public TenderInfo[] GetTendersInfo(Guid[] objectIDs)
		{
			XParamsCollection dsParams = new XParamsCollection();
			if (objectIDs != null)
			{
				foreach (Guid objectID in objectIDs)
				{
					dsParams.Add("ObjectID", objectID);
				}
			}

			// Получам данные всех проектов:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-TenderFolders", dsParams);

			dsParams.Clear();
			dsParams = null;

			if (null == oDataTable)
                return new TenderInfo[0];

			TenderInfo[] arrProjectsInfo = new TenderInfo[oDataTable.Rows.Count];
			for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
			{
				// Убедимся, что рассматриваем папку типа "Тендер"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if (FolderTypeEnum.Tender != enType)
					continue;

				TenderInfo info = new TenderInfo();

				// Переносим данные полей
				info.ObjectID = new Guid(oDataTable.Rows[nRowIndex]["ObjectID"].ToString());

				info.FinishDate =
					DBNull.Value != oDataTable.Rows[nRowIndex]["FinishDate"]
					? DateTime.Parse(oDataTable.Rows[nRowIndex]["FinishDate"].ToString())
					: new DateTime?();

				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();

				/*info.ProjectCode =
					DBNull.Value != oDataTable.Rows[nRowIndex]["ProjectCode"]
					? oDataTable.Rows[nRowIndex]["ProjectCode"].ToString()
					: null;*/

				info.StartDate =
					DBNull.Value != oDataTable.Rows[nRowIndex]["StartDate"]
					? DateTime.Parse(oDataTable.Rows[nRowIndex]["StartDate"].ToString())
					: new DateTime?();

				info.State = (TenderFolderStates)((int)Math.Log(int.Parse(oDataTable.Rows[nRowIndex]["State"].ToString()), 2) + 1);

				info.Customer = new Guid(oDataTable.Rows[nRowIndex]["Customer"].ToString());

				info.Initiator = 
					DBNull.Value != oDataTable.Rows[nRowIndex]["Initiator"]
					? new Guid(oDataTable.Rows[nRowIndex]["Initiator"].ToString())
					: new Guid?();

				info.Parent =
					DBNull.Value != oDataTable.Rows[nRowIndex]["Parent"]
					? new Guid(oDataTable.Rows[nRowIndex]["Parent"].ToString())
					: new Guid?();

				info.NavisionID =
					DBNull.Value != oDataTable.Rows[nRowIndex]["ExternalID"]
					? oDataTable.Rows[nRowIndex]["ExternalID"].ToString()
					: null;

				// Добавлем данные в массив
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		/// <summary>
		/// Возвращает данные направлений папок тендеров, представленных в системе Incident Tracker, 
		/// как массив экземпляров класса Croc.IncidentTracker.Services.FolderDirectionInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.FolderDirectionInfo"/>
		/// </summary>
		[WebMethod(Description = "Возвращает данные направлений для папок тендеров, представленных в системе Incident Tracker")]
		public FolderDirectionInfo[] GetTenderDirectionsInfo(Guid[] objectIDs)
		{
			XParamsCollection dsParams = new XParamsCollection();
			if (objectIDs != null)
			{
				foreach (Guid objectID in objectIDs)
				{
					dsParams.Add("ObjectID", objectID);
				}
			}

			// Получам данные всех проектов:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-TenderFolderDirections", dsParams);

			dsParams.Clear();
			dsParams = null;

			if (null == oDataTable)
				return new FolderDirectionInfo[0];

			FolderDirectionInfo[] arrProjectsInfo = new FolderDirectionInfo[oDataTable.Rows.Count];
			for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
			{
				FolderDirectionInfo info = new FolderDirectionInfo();

				// Переносим данные полей
				info.Direction = new Guid(oDataTable.Rows[nRowIndex]["Direction"].ToString());

				info.Folder = new Guid(oDataTable.Rows[nRowIndex]["Folder"].ToString());

				// Добавлем данные в массив
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		#endregion

		#region Методы, используемые для синхронизации данных Организаций

		/// <summary>
		/// Переносит описание организации, заданное структорой <see cref="OrganizationInfo"/>
		/// как данные вспомогательного объекта - helper-а
		/// </summary>
		/// <param name="orgInfo">Исходные данные организации</param>
		/// <param name="helperOrg">Helper-объект (д.б. инициализирован)</param>
		private static void setOrganizationData( OrganizationInfo orgInfo, ObjectOperationHelper helperOrg )
		{
			// Задаем скалярные значения объекта:
			// ... код организации в НСИ
			helperOrg.SetPropValue( "RefCodeNSI", XPropType.vt_string, 
				null!=orgInfo.RefCodeNSI? orgInfo.RefCodeNSI : String.Empty );
			// ... краткое наименование организации:			
			helperOrg.SetPropValue( "ShortName", XPropType.vt_string, 
				null!=orgInfo.ShortName? orgInfo.ShortName : String.Empty );
			// ... полное наименование
			helperOrg.SetPropValue( "Name", XPropType.vt_string, orgInfo.Name );
			// ... комментарий / примечание к описанию
			helperOrg.SetPropValue( "Comment", XPropType.vt_string, orgInfo.Comment );
			// ... идентификатор организации в Navision:
			helperOrg.SetPropValue( "ExternalID", XPropType.vt_string, 
				null!=orgInfo.NavisionID ? orgInfo.NavisionID : String.Empty );
			// ... признаки "своей организации" и "участника тендеров от нас":
			helperOrg.SetPropValue( "Home", XPropType.vt_boolean, orgInfo.IsOwnOrganization );
			helperOrg.SetPropValue( "OwnTenderParticipant", XPropType.vt_boolean, orgInfo.IsOwnTenderParticipant );
	
			// Объектные свойства (устанавливаются для объекта, если заданы значения):
			// ... идентификатор сотрудника - Директора Клиента:
			if ( null!=orgInfo.DirectorEmployeeID )
				helperOrg.SetPropScalarRef( 
					"Director", "Employee", 
					ObjectOperationHelper.ValidateRequiredArgumentAsID( orgInfo.DirectorEmployeeID, "Идентификатор сотрудника - Директора Клиента" ) );
			else
				helperOrg.PropertyXml("Director").InnerXml = String.Empty;
			
			// ... ссылки на отрасли, с которыми соотнесена данная организация:
			helperOrg.ClearArrayProp( "Branch" );
			if ( null!=orgInfo.BranchesIDs )
			{
				foreach( string sBranchID in orgInfo.BranchesIDs )
					helperOrg.AddArrayPropRef( 
						"Branch", "Branch", 
						ObjectOperationHelper.ValidateRequiredArgumentAsID(sBranchID,"Идентификатор отрасли") );
			}
			
			// ...ссылка на вышестоящую организацию:
			if ( null!=orgInfo.ParentOrganizationID )
				helperOrg.SetPropScalarRef(
					"Parent", "Organization",
					ObjectOperationHelper.ValidateRequiredArgumentAsID( orgInfo.ParentOrganizationID, "Идентификатор вышестоящей организации" ) );
			else
				helperOrg.PropertyXml("Parent").InnerXml = String.Empty;
		}


		/// <summary>
		/// Создает в системе Incident Tracker описание организации с заданными параметрами.
		/// </summary>
		/// <param name="sOrganizationID">Идентификатор Организации в системе IT</param>
		/// <param name="orgInfo">Описание новой Организации</param>
		/// <remarks>
		/// Значение поля <see cref="OrganizationInfo.ObjectID"/> игнорируется; при 
		/// создании описания в качестве идентификатора Организации используется 
		/// значение параметра sOrganizationID. Идентификатор описания Организации 
		/// в НСИ - код НСИ - задается как значение поля <see cref="OrganizationInfo.RefCodeNSI"/>
		/// </remarks>
		///	<exception cref="ArgumentNullException">Если sOrganizationID задан в null</exception>
		///	<exception cref="ArgumentException">Если sOrganizationID задан в String.Empty</exception>
		[WebMethod( Description="Создает в системе Incident Tracker описание организации с заданными параметрами." )]
		public void CreateOrganization(
			string sOrganizationID,
			OrganizationInfo orgInfo ) 
		{
			// Проверяем параметры:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sOrganizationID, "Идентификатор создаваемой организации (sOrganizationID)" );
			orgInfo.Validate( false );
			
			// Загружаем "болванку" объекта в вспомогательный объект и ПОСЛЕ 
			// загрузки переставляем идентификатор на заданный:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			helper.LoadObject();
			helper.NewlySetObjectID = uidOrganizationID;
			// Переносим данные из описания в helper:
			setOrganizationData(orgInfo, helper);

			// Уберем из датаграммы поля, которые не должны записываться:
			helper.DropPropertiesXml( "ExternalRefID" );

			// Записываем данные новой организации: успешное выполнение
			// метода (без исключений) - значит данные записаны
			helper.SaveObject();
		}


		/// <summary>
		/// Обновляет описание Организации, представленное в системе Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">Идентификатор Организации в системе IT</param>
		/// <param name="orgInfo">Измененное описание Организации</param>
		/// <returns>
		/// Логический признак успешного обновления описания:
		///		- true - описание успешно обновлено;
		///		- false - указанная организация не найдена;
		///	В случае ошибки обновления существующего описания генерируется исключение.
		/// </returns>
		/// <remarks>Значение поля <see cref="OrganizationInfo.ObjectID"/> игнорируется</remarks>
		///	<exception cref="ArgumentNullException">Если sOrganizationID задан в null</exception>
		///	<exception cref="ArgumentException">Если sOrganizationID задан в String.Empty</exception>
		[WebMethod( Description="Обновляет описание Организации, представленное в системе Incident Tracker." )]
		public bool UpdateOrganization(
			string sOrganizationID, 
			OrganizationInfo orgInfo )
		{
			// Проверяем параметры:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sOrganizationID, "Идентификатор обновляемой организации (sOrganizationID)" );
			orgInfo.Validate( false );

			// Загружаем данные указанной организации во вспомогательный объект:
			// Используем "мягкий" способ загрузки - т.к. если объекта нет, то нам
			// нужно вернуть корректный результат:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			XParamsCollection identityParams = new XParamsCollection();
			identityParams.Add( "ObjectID", uidOrganizationID );
			// ... если загрузить не получилось - в соотв. с требованиями выходим с результатом false:
			if ( !helper.SafeLoadObject(identityParams) )
				return false;
			
			// Переносим данные из описания в helper:
			setOrganizationData(orgInfo, helper);

			// Уберем из датаграммы поля, которые не должны записываться:
			helper.DropPropertiesXml( 
				"ExternalRefID"
			);
			
			// Записываем данные измененной организации:
			helper.SaveObject();
			return true;
		}

		
		/// <summary>
		/// Проверяет наличие описания указанной Организации в системе Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">Идентификатор Организации в системе IT</param>
		/// <param name="bIsExternalID">
		///	Признак, указывающий смысл идентификатора, задаваемого параметром sOrganizationID:
		///		- false - идентификатор в системе Incident Tracker
		///		- true - идентификатор НСИ
		/// </param>
		/// <returns>
		/// Если описание указанной Организации существует, возвращает строку
		/// с идентификатором Организации в системе IT (вне зависимости от значения
		/// параметра bIsExternalID). В противном случае - если описания указанной
		/// организации не существует - возвращает пустую строку (строка нулевой 
		/// длины).
		/// </returns>
		///	<exception cref="ArgumentNullException">Если sOrganizationID задан в null</exception>
		///	<exception cref="ArgumentException">Если sOrganizationID задан в String.Empty</exception>
		[WebMethod( Description="Проверяет наличие описания указанной Организации в системе Incident Tracker." )]
		public string IsOrganizationExists(
			string sOrganizationID,
			bool bIsExternalID ) 
		{
			// Проверяем корректность параметров: если заданный идентификатор - 
			// это идентификатор организации в IT, то это должен быть Guid:
			Guid uidOrganizationID = Guid.Empty;
			if (!bIsExternalID)
				uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sOrganizationID, "Идентификатор организации в системе IT (sOrganizationID)" );
			
			// Используем метод "мягкой" загрузки вспомогательного объекта, 
			// идентифицирующий объект "внешним" ключом:
			// ... коллекция параметров, задаюших ключ
			XParamsCollection identityParams = new XParamsCollection();
			if (bIsExternalID)
				identityParams.Add( "RefCodeNSI", sOrganizationID );
			else
				identityParams.Add( "ObjectID", uidOrganizationID );
			// ... сам вспомогательный объект:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			// ... операция "мягкой" загрузки данных объекта:
			// если объект загружен, вернет true:
			bool bLoaded = helper.SafeLoadObject( identityParams );

			if (bLoaded)
				return helper.ObjectID.ToString();
			else
				return String.Empty;
		}


		/// <summary>
		/// Удаление описания указанной Организации из системы Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">Идентификатор Организации в системе IT</param>
		/// <returns>
		/// Логический признак успешного удаления описания указанной Организации:
		///		- true - описание успешно удалено;
		///		- false - указанная организация не найдена;
		///	В случае ошибки удаления существующего описания генерируется исключение.
		/// </returns>
		///	<exception cref="ArgumentNullException">Если sOrganizationID задан в null</exception>
		///	<exception cref="ArgumentException">Если sOrganizationID задан в String.Empty</exception>
		[WebMethod( Description="Удаление описания указанной Организации из системы Incident Tracker." )]
		public bool DeleteOrganization( string sOrganizationID ) 
		{
			// Проверяем корректность параметров:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sOrganizationID, "Идентификатор удаляемой организации (sOrganizationID)" );
			
			// Используем метод удаления вспомогательного объекта, идентифицирующий 
			// объект "внешним" ключом: хотя наш ключ первичный, такой метод вызывает
			// "мягкую" операцию удаления DeleteObjectByExKey, которая позволяет 
			// сначала проверить наличие объекта
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			XParamsCollection identityParams = new XParamsCollection();
			identityParams.Add( "ObjectID", uidOrganizationID );
			// ... здесь важен последний параметр, управляющий поведением операции
			// в случае отсутствия объекта - см. реализацию DeleteObjectByExKey:
			return helper.DeleteObject( identityParams, true);
		}

        /// <summary>
        /// Получение описания указанной Организации, представленной в системе Incident Tracker.
        /// </summary>
        /// <param name="sOrganizationID">Идентификатор Организации в системе IT</param>
        /// <returns>
        /// В случае успешного получения описания указанной Организации возвращает
        /// инициализированный экземпляр <see cref="OrganizationInfo"/>; если описания
        /// указанной Организации в IT не существует - возвращает null.
        /// В случае ошибки получения существующего описания Организации генерируется
        /// исключение.
        /// </returns>
        ///	<exception cref="ArgumentNullException">Если sOrganizationID задан в null</exception>
        ///	<exception cref="ArgumentException">Если sOrganizationID задан в String.Empty</exception>
        [WebMethod(Description = "Получение описания указанной Организации, представленной в системе Incident Tracker.")]
        public OrganizationInfo ReadOrganization(string sOrganizationID)
        {
            // Проверяем корректность параметров:
            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sOrganizationID, "Идентификатор организации (sOrganizationID)");

            // Загружаем данные указанной организации во вспомогательный объект:
            // Используем "мягкий" способ загрузки - т.к. если объекта нет, то нам
            // нужно вернуть корректный результат:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Organization");
            XParamsCollection identityParams = new XParamsCollection();
            identityParams.Add("ObjectID", uidOrganizationID);
            // ... если загрузить не получилось - в соотв. с требованиями выходим с результатом null:
            if (!helper.SafeLoadObject(identityParams))
                return null;

            // Результирующее описание организации, как объект:
            OrganizationInfo orgInfo = new OrganizationInfo();

            // Переносим данные 
            // ... все не-объектные скаляры:
            orgInfo.ObjectID = helper.ObjectID.ToString();
            orgInfo.RefCodeNSI = safeReadData(helper, "RefCodeNSI");
            orgInfo.ShortName = safeReadData(helper, "ShortName");
            orgInfo.Name = safeReadData(helper, "Name");
            orgInfo.Comment = safeReadData(helper, "Comment");
            orgInfo.NavisionID = safeReadData(helper, "ExternalID");
            orgInfo.IsOwnOrganization = (bool)(helper.GetPropValue("Home", XPropType.vt_boolean));
            orgInfo.IsOwnTenderParticipant = (bool)(helper.GetPropValue("OwnTenderParticipant", XPropType.vt_boolean));
            // "нормализуем" все необязательные скаляры: если значение - пустая 
            // строка, то переводим его (зачение) в null:
            if (String.Empty == orgInfo.RefCodeNSI)
                orgInfo.RefCodeNSI = null;
            if (String.Empty == orgInfo.ShortName)
                orgInfo.ShortName = null;
            if (String.Empty == orgInfo.Comment)
                orgInfo.Comment = null;
            if (String.Empty == orgInfo.NavisionID)
                orgInfo.NavisionID = null;

            // ... объектные ссылки:
            ObjectOperationHelper helperRef = helper.GetInstanceFromPropScalarRef("Director", false);
            orgInfo.DirectorEmployeeID = (null == helperRef ? null : helperRef.ObjectID.ToString());
            helperRef = helper.GetInstanceFromPropScalarRef("Parent", false);
            orgInfo.ParentOrganizationID = (null == helperRef ? null : helperRef.ObjectID.ToString());

            // ... массив ссылок:
            helper.UploadArrayProp("Branch");
            XmlNodeList xmlArray = helper.PropertyXml("Branch").SelectNodes("Branch[@oid]");
            if (0 != xmlArray.Count)
            {
                orgInfo.BranchesIDs = new string[xmlArray.Count];
                int nIndex = 0;
                foreach (XmlNode xmlNode in xmlArray)
                    orgInfo.BranchesIDs[nIndex++] = ((XmlElement)xmlNode).GetAttribute("oid");
            }
            else
                orgInfo.BranchesIDs = null;

            return orgInfo;
        }

		/// <summary>
		/// Получение перечня идентификаторов всех Организаций, представленных 
		/// в системе Incident Tracker.
		/// </summary>
		/// <returns>
		/// Возвращается массив строк, содержащий идентификаторы Организаций 
		/// в системе Incident Tracker. Если организаций нет, возвращает null.
		/// </returns>
		[WebMethod( Description="Получение перечня идентификаторов всех Организаций, представленных в системе Incident Tracker." )]
		public string[] ListOrganization()
		{
			// Получаем список идентификаторов организаций:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Organizations-GetIDsList", null );
			if ( null==oDataTable )
				return null;
			if ( 0==oDataTable.Rows.Count )
				return null;

			// Переводим в массив строк:
			string[] arrOrgIDs = new string[ oDataTable.Rows.Count ];
			for( int nIndex=0; nIndex<oDataTable.Rows.Count; nIndex++ )
				arrOrgIDs[nIndex] = oDataTable.Rows[nIndex][0].ToString();
			
			return arrOrgIDs;
		}


		/// <summary>
		/// Выполнение процедуры слияния описаний Организаций, представленных 
		/// в системе Incident Tracker.
		/// </summary>
		/// <param name="sMasterOrganizationID">
		/// Идентификатор мастер-организации (описание которой остается при 
		/// успешном завершении процедуры слияния)
		/// </param>
		/// <param name="sMergedOrganizationID">
		/// Идентификатор организации, описание которой замещается описанием
		/// мастер-организации
		/// </param>
		/// <param name="sFullName">Полное наименование</param>
		/// <param name="sShortName">Сокращенное наименование</param>
		/// <remarks>
		/// В случае отсутствия описания любой из указанных операций, а так же 
		/// в случае ошибки процедуры слияния - генерируются исключения.
		/// </remarks>
		[WebMethod( Description="Выполнение процедуры слияния описаний Организаций, представленных в системе Incident Tracker." )]
		public void MergeOrganizations( 
			string sMasterOrganizationID, 
			string sMergedOrganizationID,
			string sFullName, 
			string sShortName ) 
		{
			// Проверка параметров:
			Guid uidMasterOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sMasterOrganizationID, "Идентификатор мастер-организации (sMasterOrganizationID)" );
			Guid uidMergedOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sMergedOrganizationID, "Идентификатор замещаемой организации (sMergedOrganizationID)" );
			ObjectOperationHelper.ValidateRequiredArgument( sFullName, "Наименование целевой мастер-организации (sFullName)" );
			ObjectOperationHelper.ValidateRequiredArgument( sShortName, "Краткое наименование целевой мастер-организации (sShortName)" );
			
			// Подготовим параметры:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "MasterOrganizationID", uidMasterOrgID );
			paramsCollection.Add( "DuplicatedOrganizationID", uidMergedOrgID );
			paramsCollection.Add( "sFullName", sFullName );
			paramsCollection.Add( "sShortName", sShortName );
			// ... параметры, которые есть в унаследованной логике, но в данном случае не используются:
			paramsCollection.Add( "AccChiefID", Guid.Empty );	// - идентификатор сотрудника, назначаемого Директором для "объединенной" организации
			paramsCollection.Add( "ParentID", Guid.Empty );		// - идентификатор вышестоящей оргганизации для "объединенной" организации
			
			// Вызываем процедуру, через "источник данных":
			ObjectOperationHelper.ExecAppDataSourceScalar( "SyncNSI-Exec-MergeOrganization", paramsCollection );
		}

		#endregion

		#region Сервис получения информации о списаниях пользователей IT за период
		
		/// <summary>
		/// Получение информации о списаниях пользователей Системы IT в заданнй период времени.
		/// </summary>
		/// <param name="enIdentificationMethod">
		/// Метод идентификации пользователя ("вид" идентификаторов в массиве arrEmployeesIDs).
		/// Возможные варианты идентификации определяются перечислением IdentificationMethod.
		/// </param>
		/// <param name="arrEmployeesIDs">
		/// Массив идентификаторов пользователей IT; формат идентификаторов определяется в соотв.
		///		c методом идентификации, задаваемым параметром enIdentificationMethod. Пустые 
		///		строки, null, идентификаторы, для которых в IT соотв. записи пользователей не 
		///		найдены - игнорируются.
		/// ВНИМАНИЕ! ДЛЯ ПАРАМЕТРА ЗАДАНЫ АТРИБУТЫ УПРАВЛЕНИЯ СЕРИАЛИЗАЦИЕЙ ДАННЫХ В XML!
		///		Цель задания атрибутов - уменьшение объема XML-сериализованного вызова метода.
		/// </param>
		/// <param name="dtPeriodBegin">Дата начала рассматриваемого периода (включительно)</param>
		/// <param name="dtPeriodEnd">Дата окнчания рассматриваемого периода (включительно)</param>
		/// <returns></returns>
		[ WebMethod( Description="Метод получение информации о списаниях пользователей в заданнй период времени" ) ]
		public EmployeeExpenseInfo[] GetEmployeesExpenses(
			IdentificationMethod enIdentificationMethod,
			[XmlArray( ElementName ="IDs" ), XmlArrayItem( ElementName="ID", Type=typeof(string) ) ]
			string[] arrEmployeesIDs,
			DateTime dtPeriodBegin,
			DateTime dtPeriodEnd )
		{
			// Проверка параметров:
			if ( null == arrEmployeesIDs )
				throw new ArgumentNullException( "arrEmployeesIDs", "Массив идентификаторов сотрудников не задан (null)" );
			if ( 0 == arrEmployeesIDs.Length )
				throw new ArgumentException( "Массив идентификаторов сотрудников не задан (пустой массив)", "arrEmployeesIDs" );
			if ( DateTime.MinValue == dtPeriodBegin )
				throw new ArgumentException( "Дата начала отчетного периода не задана", "dtPeriodBegin" );
			if ( DateTime.MinValue == dtPeriodEnd )
				throw new ArgumentException( "Дата окончания отчетного периода не задана", "dtPeriodEnd" );
			
			// Формирование списка идентификаторов, для задания в запросе операции
			StringBuilder sbIDsList = new StringBuilder();
			int nIndex = 0;
			foreach ( string sEmpID in arrEmployeesIDs )
			{
				// Проверка корректности значения конечного идентификатора
				if ( IdentificationMethod.ByTrackerEmployeeID == enIdentificationMethod )
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sEmpID, "Идентификатор arrEmployeesIDs[" + nIndex + "]" );
				else
					ObjectOperationHelper.ValidateRequiredArgument( sEmpID, "Идентификатор arrEmployeesIDs[" + nIndex + "]" );
				
				sbIDsList.Append( sEmpID ).Append( "," );
				nIndex += 1;
			}
			
			if ( sbIDsList.Length > 1 )
				sbIDsList.Remove( sbIDsList.Length-1, 1 );
			if ( 0 == sbIDsList.Length )
				throw new ArgumentException( "Список идентификаторов сотрудников не задан (arrEmployeesIDs)" );
			
			// Формирование запроса операции
			GetEmployeesExpensesRequest request = new GetEmployeesExpensesRequest();
			request.IdentificationMethod = enIdentificationMethod;
			request.EmployeesIDsList = sbIDsList.ToString();
			request.ExceptDepartmentIDsList = ServiceConfig.Instance.CommonServiceParams.ExpensesProcess.EmpExpenses_ExceptedDepsList;
			request.PeriodBegin = dtPeriodBegin;
			request.PeriodEnd = dtPeriodEnd;
			
			GetEmployeesExpensesResponse response =
                (GetEmployeesExpensesResponse)ObjectOperationHelper.AppServerFacade.ExecCommand(request);
			if (null==response)
				throw new InvalidOperationException("Ошибка выполнения операции сервера приложения: в качестве результата получен null");

			return ( null == response.Expenses ? new EmployeeExpenseInfo[0] : response.Expenses );
		}


        #endregion

		#region Методы взаимодействия с системой HPOVSD
		/// <summary>
		/// HPOVSD. Метод предоставляет информацию по проектам с указанными направлениями.
		/// </summary>
		/// <param name="xmlDirections">
		/// Список направлений 
		/// </param>
		[WebMethod( Description="Получение проектов по заданным направлениям " )]
		public XmlDocument HPOVSD_GetProjectList( XmlDocument xmlDirections
			)
		{
			// Данные - результат:
			XmlDocument xmlResult = null; 

			try 
			{
				// Формируем параметры для вызова источника данных (в котором прописан 
				// вызов хранимой процедуры - см. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "Directions",xmlDirections.OuterXml); 
				// Вызов источника данных и формирование специального XML-результата
				// вида <Data><row FolderID='...' FolderName='...' FolderName='...' Open='...'
				// DirectionID='...' DirectionName='...' OrganizationID='...' OrganizationName='...' 
				// ManagerID='...' ManagerLogin='...'> </Data>
				// Форматирование XML-результата осуществляется на основании специальных
				// наименований колонок результирующего набора форматтером 
				// DataTableXmlFormatter - см. комментарии к реализации
				DataTable data = ObjectOperationHelper.ExecAppDataSource("CommonService-GetProjectsByDirections", procParams );
				//DataTableXmlFormatter formatter = new DataTableXmlFormatter();
				XmlDocument xmlData = DataTableXmlFormatter.GetXmlFromDataTable(data,"Data","row");
				// Формируем результирующие данные: изначально загружаем XML-текст,
				// описывающий результат с "хорошим" статусом - нулевым кодом и пустыми
				// элементами, описывающими ошибку (Descr и Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... импортируем данные, полученные в результате вызова 
				// источника данных и отформатированные:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" ) );
			}
			catch( Exception err )
			{
				// Формируем результат, описывающий ошибку: элемент Code задан в (-1),
				// элементы Descr и Stack содержат описание и стек ошибки соответственно:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... саму ошибку при этом - ДАВИМ! */
			}
			return xmlResult;
		}
		/// <summary>
		/// HPOVSD. Метод заносит списания времени из SD.
		/// </summary>
		/// <param name="sUserID">
		/// Идентификатор инженера в ИТ
		/// </param>
		/// <param name="sProjectID">
		/// Идентификатор проекта в ИТ
		/// </param>
		/// <param name="sDirectionID">
		/// Идентификатор направления в ИТ
		/// </param>
		/// <param name="iTimeLoss">
		/// Списываемое время(в минутах)
		/// </param>
        /// <param name="sDescription">
        /// Описание заявки
        /// </param>
        /// <param name="dtDateLoss">
        /// Время списания по заявке
        /// </param> 
        /// <param name="sOfferSDID">
        /// Идентификатор в SD
        /// </param>
        
		[WebMethod( Description="Заносит списание времени из SD" )]
		public void HPOVSD_INTEROP_InsertTimeLossFromSD(
			string sUserID,
			string sProjectID,
			string sDirectionID,
			int iTimeLoss,
            string sDescription,
            DateTime dtDateLoss,
            string sOfferSDID)
		{
			// Проверка параметров:
			//Guid uidUserID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sUserID, "Идентификатор  (sUserID)" );
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "Идентификатор  (sProjectID)");
			Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sDirectionID, "Идентификатор  (sDirectionID)");
			// Подготовим параметры:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "UserID", sUserID  );
			paramsCollection.Add( "ProjectID", uidProjectID );
			paramsCollection.Add( "DirectionID", uidDirectionID);
			paramsCollection.Add( "TimeLoss", iTimeLoss);
            paramsCollection.Add("DateLoss", dtDateLoss);
            if (!String.IsNullOrEmpty(sDescription))
            {
                paramsCollection.Add("Description", sDescription);
            }
            else
            {
                throw new ApplicationException("Не возможно перенести списание, т.к. не заполнено описание заявки");
            }
            if (!String.IsNullOrEmpty(sOfferSDID))
            {
                paramsCollection.Add("ExternalID", sOfferSDID);
            }
            else
            {
                throw new ApplicationException("Не передан Идентификатор в SD");
            }
			// Вызываем процедуру, через "источник данных":
			ObjectOperationHelper.ExecAppDataSourceScalar( "CommonService-InsertTimeLossFromSD", paramsCollection );
		}
		#endregion

        #region Методы взаимодействия системы  для синхронизации с  "Системой Учета Тендеров" 


        /// <summary>
        /// Метод преобразования значения состояния Тендера (в Incident Tracker) в соответствующее 
        /// состояние папки
        /// </summary>
        /// <param name="enTenderState">Состояние Тендера</param>
        /// <returns>Соответствующее состояние папки</returns>
        private FolderStates getTender2FolderState(TenderFolderStates enTenderState)
        {
            FolderStates enFolderState;
            switch (enTenderState)
            {
                case TenderFolderStates.Open: enFolderState = FolderStates.Open; break;
                case TenderFolderStates.WaitingToClose: enFolderState = FolderStates.WaitingToClose; break;
                case TenderFolderStates.Closed: enFolderState = FolderStates.Closed; break;
                case TenderFolderStates.Frozen: enFolderState = FolderStates.Frozen; break;
                default:
                    throw new ArgumentException("Неизвестное состояние Тендера (enTenderState)", "enTenderState");
            }
            return enFolderState;
        }

        /// <summary>
        /// Внутренний служебный метод загрузки данных Папки (Folder) типа 
        /// "Тендер" , по заданному идентификатору. 
        /// Проверяет корректность задания идентификатора, а так же тип папки.
        /// </summary>
        /// <param name="sTenderID">Идентификатор папки-пресейла, в строке</param>
        /// <param name="arrPreloadProperties">
        /// Массив наименований прогружаемых параметров, м.б. null
        /// </param>
        /// <param name="bIsStrictLoad">
        /// Признак "жесткой" загрузки - если указанный объект не будет найден, будет
        /// сгенерировано исклбчение; если параметр задан в false, и объект не будет 
        /// найден, то в кач. результата метод вернет null;
        /// </param>
        /// <returns>
        /// Инициализированный объект - helper или null если объект не найден, 
        /// и признак "жесткой" загрузки (bIsStrictLoad) сброшен
        /// </returns>
        /// <exception cref="ArgumentNullException">Если sTenderID есть null</exception>
        /// <exception cref="ArgumentException">Если sTenderID есть пустая строка</exception>
        /// <exception cref="ArgumentException">Если проекта с ID sTenderID нет и bIsStrictLoad=true</exception>
        /// <exception cref="ArgumentException">Если sTenderID задает папку - НЕ персейл</exception>
        private ObjectOperationHelper loadTender(string sTenderID, bool bIsStrictLoad, string[] arrPreloadProperties)
        {
            // Проверяем корректность входных параметров:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sTenderID, "Идентификатор возможности (sTenderID)");

            // Загружаем данные: в любом случае испрользуем "мягкую" загрузку
            // при этом проверяем, загрузилось или нет: дальнейшая реакция зависит 
            // от значения флага bIsStrictLoad:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            if (!helper.SafeLoadObject(null, arrPreloadProperties))
            {
                if (bIsStrictLoad)
                    throw new ArgumentException("Тендер с указанным идентификатором (" + sTenderID + ") не найдена", "sPresaleID");
                else
                    return null;
            }

            // Проверяем, что загруженное описание, представленное объектом типа 
            // "Folder" есть возможность - проверим значение "типа" папки:
            if (FolderTypeEnum.Tender != getFolderType(helper))
                throw new ArgumentException("Заданный идентификатор (sTenderID) не является идентификатором Тендера");

            return helper;
        }

        /// <summary>
        /// Создает в системе Incident Tracker описание Тендера (Tender)
        /// с заданными параметрами.
        /// </summary>
        /// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
        /// <param name="sCode">Строка с уникальным кодом тендера</param>
        /// <param name="sName">Строка с наименованием тендера</param>
        /// <param name="sNavisionID">Строка с кодом тендера в Navision</param>
        /// <param name="enInitialState">Начальное состояние проекта тендера</param>
        /// <param name="sDescription">Строка с текстом описания / комментария</param>
        /// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора создания</param>
        /// <returns>Строка с идентификатором созданного описания тендера</returns>
        [WebMethod(Description = "Создает в системе Incident Tracker описание Тендера (Tender) с заданными параметрами")]
        public string CreateTender(
            string sCustomerID,
            string sCode,
            string sName,
            string sNavisionID,
            TenderFolderStates enInitialState,
            string sDescription,
            string sInitiatorEmployeeID)
        {
            // Проверяем корректность входных параметров:
            ObjectOperationHelper.ValidateRequiredArgument(sCustomerID, "Идентификатор организации - Клиента (sCustomerID)", typeof(Guid));
            ObjectOperationHelper.ValidateRequiredArgument(sName, "Наименование тендера (sName)");
            ObjectOperationHelper.ValidateRequiredArgument(sInitiatorEmployeeID, "Идентификатор сотрудника-инициатора создания тендера (sInitiatorEmployeeID)", typeof(Guid));

            // Генерируем идентификатор новой возможности и вызываем спец. 
            // метод, создающий возможность с ЯВНО ЗАДАННЫМ идентификатором:
            string sNewProjectID = Guid.NewGuid().ToString();
            CreateIdentifiedTender(sNewProjectID, sCustomerID, sCode, sName, sNavisionID, enInitialState, sDescription, sInitiatorEmployeeID);

            return sNewProjectID;
        }


        /// <summary>
        /// Создает в системе Incident Tracker описание Тендера (Tender) 
        /// с указанными параметрами и ЗАДАННЫМ уникальным идентификатором.
        /// </summary>
        /// <param name="sNewTenderID">Строка с идентификатором для создаваемой тендера</param>
        /// <param name="sCustomerID">Строка с идентификатором организации - Клиента</param>
        /// <param name="sCode">Строка с кодом проекта</param>
        /// <param name="sName">Строка с наименованием проекта</param>
        /// <param name="sNavisionID">Строка с кодом проекта в сист. Navision</param>
        /// <param name="enInitialState">Начальное состояние создаваемого тендера</param>
        /// <param name="sDescription">Текст описания (комментария) тендера</param>
        /// <param name="sInitiatorEmployeeID">Строка с идентификатором сотрудника - инициатора проекта</param>
        public void CreateIdentifiedTender(
            string sNewTenderID,
            string sCustomerID,
            string sCode,
            string sName,
            string sNavisionID,
            TenderFolderStates enInitialState,
            string sDescription,
            string sInitiatorEmployeeID)
        {
            // Проверяем корректность входных параметров:
            Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewTenderID, "Уникальный идентификатор создаваемого тендера (sNewTenderID)");
            ObjectOperationHelper.ValidateRequiredArgument(sName, "Наименование тендера (sName)");
            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCustomerID, "Идентификатор организации - Клиента (sCustomerID)");
            Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiatorEmployeeID, "Идентификатор сотрудника - инициатора создания возможности (sInitiatorEmployeeID)");

            // ОСОБЕННАЯ ПРОВЕРКА: 
            // Бизнес-правило: Создание Тендеров под КРОК-ом при помощи сервиса 
            // запрещено. Следовательно: проверяем, что заданная организация не есть 
            // КРОК; идентификатор последнего д.б. задан в прикладном конфигурационном 
            // файле сервисов (и, соотв. представлен в объекте - описателе конфигурации,
            // ServiceConfig)
            if (uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID)
                throw new ArgumentException(
                    String.Format(
                        "Создание Тендеров для организации - владельца системы \"{0}\" при помощи метода сервиса " +
                        "запрещено. Создание таких возможностей должно выполняться непосредственно в системе Incident " +
                        "Tracker, пользователем системы, обладающим необходимыми полномочиями.",
                        ServiceConfig.Instance.OwnOrganization.GetPropValue("ShortName", XPropType.vt_string)
                    ), "sCustomerID");

            // Болванка нового объекта - возможности: загружаем, и ПОСЛЕ загрузки 
            // болваник переставляем идентификатор объекта на заданный:
            ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance("Folder");
            helperProject.LoadObject();
            helperProject.NewlySetObjectID = uidNewProjectID;

            // Задаем свойства возможности, в соотв. с заданными значениями параметров:
            // ... возможность - это папка с типом "Пресейл":
            helperProject.SetPropValue("Type", XPropType.vt_i2, FolderTypeEnum.Tender);
            // ... и ВСЕГДА (при создании проекта через сервис) - указываем тип проектных 
            // затрат как "Пресейлы"; идентификатор соотв. Activity Type берем из конфигурации:
            helperProject.SetPropScalarRef(
                "ActivityType",
                ServiceConfig.Instance.TenderProjectsActivityType.TypeName,
                ServiceConfig.Instance.TenderProjectsActivityType.ObjectID);

            // ... задаем все скаляры, указанные параметарми:
            //if (!String.IsNullOrEmpty(sCode))
            //    helperProject.SetPropValue("ProjectCode", XPropType.vt_string, sCode);
            helperProject.SetPropValue("Name", XPropType.vt_string, sName);
            // ... идентификатор проекта в Navision для треккера не является обязательным;
            // в кач. значения может быть задан null или пустая строка - сведем все 
            // к пустой строке - при записи в БД будет NULL:
            helperProject.SetPropValue("ExternalID", XPropType.vt_string, (null == sNavisionID ? String.Empty : sNavisionID));
            // ... статус проекта при создании соотносим явно: 
            helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getTender2FolderState(enInitialState));

            // Проставляем ссылки:
            // ...на сотрудника - инициатора проекта 
            helperProject.SetPropScalarRef("Initiator", "Employee", uidInitEmployeeID);
            // ...на организацию:
            helperProject.SetPropScalarRef("Customer", "Organization", uidOrganizationID);

            // Записываем новый объект:
            helperProject.SaveObject();
        }

        /// <summary>
        /// Изменение параметров описания указанного Тендера (Tender) в системе Incident Tracker.
        /// </summary>
        /// <param name="sTenderID">Строковое представление идентификатора описания Тендера</param>
        /// <param name="sNewCustomerID">Строковое представление идентификатора организации - Клиента</param>
        /// <param name="sNewCode">Строка с новым кодом возможности</param>
        /// <param name="sNewName">Строка с новым наименованием возможности</param>
        /// <param name="sNewNavisionID">Строка с новым кодом возможности в Navision</param>
        /// <returns>
        /// -- True - если указанная возможность найдена и успешно обновлена;
        /// -- False - если указанная возможность не найдена.
        /// </returns>
        /// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
        [WebMethod(Description = "Изменение параметров описания указанной возможности в системе Incident Tracker")]
        public bool UpdateTender(
            string sTenderID,
            string sNewCustomerID,
            string sNewCode,
            string sNewName,
            string sNewNavisionID)
        {
            // Проверяем парамтры
            ObjectOperationHelper.ValidateRequiredArgument(sNewName, "Наименование Тендера (sName)");
            Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewCustomerID, "Идентификатор организации - Клиента (sCustomerID)");

            // Загружаем указанную возможность: внутренний метод проверяет корректность параметра
            ObjectOperationHelper helperTender = loadTender(sTenderID, false, null);
            // ... если объект не найден - просто вернем false:
            if (null == helperTender)
                return false;

            // Заменяем заданные данные возможности:
            //if (!String.IsNullOrEmpty(sNewCode))
            //    helperTender.SetPropValue("ProjectCode", XPropType.vt_string, sNewCode);
            helperTender.SetPropValue("Name", XPropType.vt_string, sNewName);
            // Идентификатор проекта в Navision для треккера не является обязательным;
            // поэтому в кач. допустимых значений параметра принимаются и null, и пустая
            // строка; null сводится к пустой строке - при записи в БД будет NULL:
            helperTender.SetPropValue("ExternalID", XPropType.vt_string, (null == sNewNavisionID ? String.Empty : sNewNavisionID));

            // Перестановка организации клиента: проверим, какая организация указана сейчас:
            ObjectOperationHelper helperOrg = helperTender.GetInstanceFromPropScalarRef("Customer");
            // ...изменяем значение только если оно действительно изменилось:
            if (helperOrg.ObjectID != uidNewCustomerOrgID)
                helperTender.SetPropScalarRef("Customer", "Organization", uidNewCustomerOrgID);

            // Сбросим в датаграмме все свойства, которые точно не изменяются:
            helperTender.DropPropertiesXml(new string[] { "ActivityType", "Type", "State", "Parent", "IsLocked" });
            // Записываем измененные данные:
            helperTender.SaveObject();

            return true;
        }
        /// <summary>
        /// Удаляет описание указанного Тендера из системы Incident Tracker
        /// </summary>
        /// <param name="sTenderID">Строковое представление идентификатора удаляемого Тендера</param>
        ///	<exception cref="ArgumentNullException">Если sTenderID задан в null</exception>
        ///	<exception cref="ArgumentException">Если sTenderID задан в String.Empty</exception>
        [WebMethod(Description = "Удаляет описание указанной возможности из системы Incident Tracker")]
        public void DeleteTender(string sTenderID)
        {
            // Проверяем корректность параметров:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sTenderID, "Идентификатор удаляемой возможности (sPresaleID)");

            // Удаление объекта:
            ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            helperProject.DeleteObject();
        }

   	
        #endregion

		#region Обеспечение взаимодействия с системой CRM
        private enum ActivityFolderContainDirection
        {
            /// <summary>
            /// Одна из старших активностей не первого уровня содержит другое направление
            /// </summary>
            ParentActivityContainOtherDirection,
            /// <summary>
            /// Старшая активность содержит переданное направление направление
            /// </summary>
            ParentActivityContainDirection,
            /// <summary>
            /// Ни одна старшая активность не содержит направления
            /// </summary>
            ParentActivityDontContainThisDirection,
            /// <summary>
            /// Cтаршая активность не содержит ни одного направления
            /// </summary>
            ParentActivityDontContainAnyDirection,
        }

        /// <summary>
        /// Проверяет направления у старшей активности
        /// </summary>
        /// <param name="helperActivity">Объект - Активность, чьи родителськие активности проверяем на соответствие направлений</param>
        /// <param name="uidDirection">Guid направления</param>
        /// <returns>
        /// Возвращает состояние направления для текущей активности
        /// </returns>
        private ActivityFolderContainDirection CheckActivityFolderContainDirection(
            ObjectOperationHelper helperActivity,
            Guid uidDirection
            )
        {
            // Находим старшую активность
            ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
            // Если есть вышестоящая активность, то направление может быть только 1
            bool bExistParentActivity = (null != helperParentActivity);
            if (bExistParentActivity)
            {
                helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });
            }
            // Поищем среди существующих нправлений
            bool bExistDirection = false;
            foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
            {
                if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(uidDirection.ToString(), StringComparison.InvariantCultureIgnoreCase))
                {
                    // Если одно из направлений активности совпадает с переданным направлением, возвращаем значение, что 
                    // такое направление у активности существует
                    return ActivityFolderContainDirection.ParentActivityContainDirection;
                }
                else if (bExistParentActivity) 
                {
                    //Если направление не совпадает и у активности есть родительская активность, то так как у текущей активности 
                    // может быть всего одно направление, возвращаем значение не совпадения направлений
                    return ActivityFolderContainDirection.ParentActivityContainOtherDirection;
                }
                bExistDirection = true;
            }
            // Если существует родительская активность, а мы пока не определились с существующими направлениями, то осуществляем 
            // проверку и у родительских активностей.
            if (bExistParentActivity)
                return CheckActivityFolderContainDirection(helperParentActivity, uidDirection);
            else
            {
                if (bExistDirection)
                    return ActivityFolderContainDirection.ParentActivityDontContainThisDirection;
                else
                    return ActivityFolderContainDirection.ParentActivityDontContainAnyDirection;
            }
        }

        /// <summary>
        /// Возвращает родительскую активность 1-ого уровня
        /// </summary>
        /// <param name="helperActivity">Объект - Активность, чью родителськую активность ищем</param>        
        /// <returns>
        /// Возвращает Guid старшей активности
        /// </returns>
        private Guid GetFirstLevelParentActivity(
            ObjectOperationHelper helperActivity
            )
        {
            // Находим старшую активность
            ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
            // Проверяем есть ли страшая активность
            bool bExistParentActivity = (null != helperParentActivity);
            if (bExistParentActivity)
            {
                helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });

            }

            // Если существует родительская активность, а мы пока не определились с существующими направлениями, то осуществляем 
            // проверку и у родительских активностей.
            if (bExistParentActivity)
                return GetFirstLevelParentActivity(helperParentActivity);
            else
            {
                return helperActivity.ObjectID;
            }
        }

        /// <summary>
        /// Возвращает массив направлений активности
        /// </summary>
        /// <param name="helperActivity">Строка - Активность, чьи направление возвращаем</param>        
        /// <returns>
        /// Возвращает массив направлений активности
        /// </returns>
        private ProjectDirection[] GetFirstLevelParentActivityDirections(
            String sActivityID
            )
        {
            // Загружаем указанный проект: внутренний метод проверяет корректность параметра
            ObjectOperationHelper helperActivity = loadActivity(sActivityID, false, new string[] { "FolderDirections" });
            // ... если объект не найден - просто вернем false:
            if (null == helperActivity)
                throw new ArgumentException("Переданная Активность не представлена в системе Incident Tracker");

            ProjectDirection[] ActivityDirections = new ProjectDirection[helperActivity.PropertyXml("FolderDirections").ChildNodes.Count + 1];
            int index = 0;
            foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
            {
                ActivityDirections[index] = new ProjectDirection();
                ActivityDirections[index].DirectionID = ((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").ToString();
                ActivityDirections[index].ExpenseRatio = int.Parse(((XmlElement)xmlFolderDirection.SelectSingleNode("ExpenseRatio")).InnerText.ToString());
                index++;
            }
            return ActivityDirections;
        }

		/// <summary>
		/// Метод создает объект типа Инцидент в системе ITracker
		/// </summary>
		/// <param name="sName">Название, обязательное</param>
		/// <param name="sDescr">Описание</param>
		/// <param name="sSolution">Решение</param>
		/// <param name="nPriority">Приоритет (1, 2, 3), обязательное</param>
		/// <param name="dtDeadLine">Крайний срок, обязательное</param>
		/// <param name="sFolder">Папка, GUID, обязательное</param>
		/// <param name="sType">Тип инцидента, GUID, обязательное</param>
		/// <param name="sInitiator">Инициатор, GUID, обязательное</param>
		/// <returns>Xml следующего вида
		/// <Result>
		/// <Status><Code>0, если все хорошо или -1</Code><Descr>Описание ошибки</Descr><Stack>Стектрейс</Stack></Status>
		/// <Data><IncidentNumber>Номер инцидента</IncidentNumber><IncidentGUID>Идентификатор инцидента в трекере</IncidentGUID></Data>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "Метод создает объект типа Инцидент в системе ITracker")]
		public XmlDocument CreateIncident(
			String sName,
			String sDescr,
			String sSolution,
			Int32 nPriority,
			DateTime? dtDeadLine,
			String sFolder,
			String sType,
			String sInitiator
			)
		{
			try
			{
				// Проверка значений параметров
				ObjectOperationHelper.ValidateRequiredArgument(sName, "sName");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sFolder, "sFolder");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sType, "sType");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiator, "sInitiator");

				if (nPriority < 1 || nPriority > 3)
					throw new ArgumentOutOfRangeException("nPriority", "Значение аргумента nPriority должно принимать одно из значений: 1, 2 или 3");

				ObjectOperationHelper employeeHelper = ObjectOperationHelper.GetInstance("Employee", new Guid(sInitiator));
				employeeHelper.LoadObject();

				// Заполняем данные нового инцидента
				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				incidentHelper.LoadObject();

				incidentHelper.SetPropValue("Name", XPropType.vt_string, sName);

				incidentHelper.SetPropValue("Descr", XPropType.vt_text,
					!string.IsNullOrEmpty(sDescr)
					? string.Format(
						"{0}\n[{1} {2}, {3}]",
						sDescr,
						employeeHelper.GetPropValue("LastName", XPropType.vt_string),
						employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
						DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
					: sDescr
					);

				incidentHelper.SetPropValue("Solution", XPropType.vt_text,
					!string.IsNullOrEmpty(sSolution)
					? string.Format(
						"{0}\n[{1} {2}, {3}]",
						sSolution,
						employeeHelper.GetPropValue("LastName", XPropType.vt_string),
						employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
						DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
					: sSolution
					);

				incidentHelper.SetPropValue("Priority", XPropType.vt_i2, nPriority);

				incidentHelper.SetPropValue("DeadLine", XPropType.vt_date, dtDeadLine);

				incidentHelper.SetPropScalarRef("Folder", "Folder", new Guid(sFolder));

				incidentHelper.SetPropScalarRef("Type", "IncidentType", new Guid(sType));

				ObjectOperationHelper systemUserHelper = employeeHelper.GetInstanceFromPropScalarRef("SystemUser");

				incidentHelper.SetPropScalarRef("Initiator", "SystemUser", systemUserHelper.ObjectID);

				ObjectOperationHelper incidentStateHelper = ObjectOperationHelper.GetInstance("IncidentState");
				XParamsCollection incidentStateParams = new XParamsCollection();
				incidentStateParams.Add("IsStartState", 1);
				incidentStateParams.Add("IncidentType", new Guid(sType));

				incidentStateHelper.LoadObject(incidentStateParams);

				incidentHelper.SetPropScalarRef("State", "IncidentState", incidentStateHelper.ObjectID);

				// Сохраняем инцидент
				incidentHelper.SaveObject();

				// Прогружаем инцидент, чтобы получить его номер
				incidentHelper.LoadObject();

				// Формируем сообщение об успехе
				XmlDocument doc = new XmlDocument();
				doc.LoadXml(
					string.Format(
						"<Result><Status><Code>0</Code><Descr/><Stack/></Status><Data><IncidentNumber>{0}</IncidentNumber><IncidentGUID>{1}</IncidentGUID></Data></Result>",
						incidentHelper.GetPropValue("Number", XPropType.vt_i4),
						incidentHelper.ObjectID
						));

				return doc;
			}
			catch (Exception e)
			{
				// Формируем сообщение об ошибке
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
				((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
				XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
				data.AppendChild(doc.CreateElement("IncidentNumber"));
				data.AppendChild(doc.CreateElement("IncidentGUID"));

				return doc;
			}
		}

		/// <summary>
		/// Изменение расположения инцидента в системе ITracker
		/// </summary>
		/// <param name="nIncidentNumber">Номер инцидента, обязательное</param>
		/// <param name="sTagretFolder">Новая папка, обязательное</param>
		/// <returns>Xml следующего вида
		/// <Result>
		/// <Code>0, если все хорошо или -1</Code><Descr>Описание ошибки</Descr><Stack>Стектрейс</Stack>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "Изменение расположения инцидента в системе ITracker")]
		public XmlDocument MoveIncident(
			Int32 nIncidentNumber,
			String sTagretFolder
		)
		{
			try
			{
				// Проверка значений параметров
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sTagretFolder, "sTagretFolder");

				// Получим инцидент по его номеру
				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				XParamsCollection incidentParams = new XParamsCollection();
				incidentParams.Add("Number", nIncidentNumber);
				incidentHelper.LoadObject(incidentParams);

				// Изменим ссылку на папку и сохраним
				incidentHelper.SetPropScalarRef("Folder", "Folder", new Guid(sTagretFolder));
				incidentHelper.DropPropertiesXmlExcept("Folder");
				incidentHelper.SaveObject();

				// Формируем сообщение об успехе
				XmlDocument doc = new XmlDocument();
				doc.LoadXml("<Result><Code>0</Code><Descr/><Stack/></Result>");
				return doc;
			}
			catch (Exception e)
			{
				// Формируем сообщение об ошибке
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				((XmlElement)result.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)result.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)result.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;

				return doc;
			}
		}

		/// <summary>
		/// Назначение задания сотруднику в указанном инциденте
		/// </summary>
		/// <param name="nIncidentNumber">Номер инцидента, обязательное</param>
		/// <param name="sInitiator">Планировщик, GUID, обязательное</param>
		/// <param name="sWorker">Исполнитель, GUID, обязательное</param>
		/// <param name="sRole">Роль, GUID, обязательное</param>
		/// <param name="nPlannedTime">Планируемое время в минутах</param>
		/// <returns>Xml следующего вида
		/// <Result>
		/// <Code>0, если все хорошо или -1</Code><Descr>Описание ошибки</Descr><Stack>Стектрейс</Stack>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "Назначение задания сотруднику в указанном инциденте")]
		public XmlDocument CreateTask (
			Int32 nIncidentNumber,
			String sInitiator,
			String sWorker,
			String sRole,
			Int32? nPlannedTime
		)
		{
			try
			{
				// Проверка значений параметров
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiator, "sInitiator");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sWorker, "sWorker");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sRole, "sRole");

				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				XParamsCollection incidentParams = new XParamsCollection();
				incidentParams.Add("Number", nIncidentNumber);
				incidentHelper.LoadObject(incidentParams);

				ObjectOperationHelper roleHelper = ObjectOperationHelper.GetInstance("UserRoleInIncident", new Guid(sRole));
				roleHelper.LoadObject();

				// Заполняем задание
				ObjectOperationHelper taskHelper = ObjectOperationHelper.GetInstance("Task");
				taskHelper.LoadObject();

				taskHelper.SetPropScalarRef("Incident", "Incident", incidentHelper.ObjectID);

				taskHelper.SetPropScalarRef("Planner", "Employee", new Guid(sInitiator));

				taskHelper.SetPropScalarRef("Worker", "Employee", new Guid(sWorker));

				taskHelper.SetPropScalarRef("Role", "Employee", roleHelper.ObjectID);

				taskHelper.SetPropValue("PlannedTime", XPropType.vt_i4, nPlannedTime.HasValue ? nPlannedTime : roleHelper.GetPropValue("DefDuration", XPropType.vt_i4));

                taskHelper.SetPropValue("LeftTime", XPropType.vt_i4, nPlannedTime.HasValue ? nPlannedTime : roleHelper.GetPropValue("DefDuration", XPropType.vt_i4));

				// Сохраняем
				taskHelper.SaveObject();

				// Формируем сообщение об успехе
				XmlDocument doc = new XmlDocument();
				doc.LoadXml("<Result><Code>0</Code><Descr/><Stack/></Result>");
				return doc;
			}
			catch (Exception e)
			{
				// Формируем сообщение об ошибке
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				((XmlElement)result.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)result.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)result.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;

				return doc;
			}
        }

        /// <summary>
        /// Метод возвращает список активностей, относящихся к переданной организации 
        /// </summary>
        /// <param name="sOrganizationID">Строка с указанием идентификатора описания организации</param>
        /// <param name="bIncludeSubActivity">Признак, показывающий будут ли включены в результат подчиненные активности</param>
        /// <param name="sActivityType">Строка с указанием идентификатора типа активности</param>
        /// <param name="nActivityState">Число с указанием "Состояния" активностей, которые будут включены в результат</param>
        /// <returns>Xml следующего вида
        /// <Result>
        /// <Status>
        ///     <Code>0, если все хорошо или -1</Code>
        ///     <Descr>Описание ошибки</Descr>
        ///     <Stack>Стектрейс</Stack>
        /// </Status>
        /// <Data>
        ///     <ActivityGUID>Идентификатор активности</ActivityGUID>
        ///     <ActivityName>Наименование активности</ActivityName>
        ///     <ActivityType>Идентификатор типа активности</ActivityType>
        ///     <ActivityFolderType>Тип папки</ActivityFolderType>
        ///     <ActivityParent>Идентификатор вышестоящей активности</ActivityParent>
        /// </Data>
        /// </Result>
        /// </returns>
        [WebMethod(Description = "Метод возвращает список активностей, относящихся к переданной организации")]
        public XmlDocument GetActivityList(
            String sOrganizationID,
            String sActivityID,
            String sActivityType,
            Int32 nActivityState
            )
        {
            try
            {

                // Проверяем корректность входных параметров:
                sOrganizationID = (String.Empty == sOrganizationID ? null : sOrganizationID);
                sActivityID = (String.Empty == sActivityID ? null : sActivityID);
                ObjectOperationHelper.ValidateOptionalArgument(sOrganizationID, "Идентификатор организации (sOrganizationID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sActivityID, "Идентификатор активности (sActivityID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sActivityType, "Идентификатор типа активности (sActivityType)", typeof(Guid));

                // Пробуем получть данные указанного проекта:
                XParamsCollection paramsCollection = new XParamsCollection();
                paramsCollection.Add("OrganizationID", sOrganizationID);
                paramsCollection.Add("ActivityID", sActivityID);
                paramsCollection.Add("ActivityType", sActivityType);
                paramsCollection.Add("ActivityState", (Int16)nActivityState);
                DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("CommonService-GetOrganizationActivity", paramsCollection);

                if (null == oDataTable)
                    // Выдаем сообщение об ошибке
                    throw new ArgumentException("Организация не найдена");

                // Формируем сообщение об успехе
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "0";
                status.AppendChild(doc.CreateElement("Descr"));
                status.AppendChild(doc.CreateElement("Stack"));
                for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
                {
                    XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityOrganization"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityOrganization"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityID"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityID"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityName"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityName"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityType"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityType"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityFolderType"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityFolderType"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityParent"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityParent"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityState"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityState"].ToString();
                }
                return doc;
            }
            catch (Exception e)
            {
                // Формируем сообщение об ошибке
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
                data.AppendChild(doc.CreateElement("ActivityOrganization"));
                data.AppendChild(doc.CreateElement("ActivityID"));
                data.AppendChild(doc.CreateElement("ActivityName"));
                data.AppendChild(doc.CreateElement("ActivityType"));
                data.AppendChild(doc.CreateElement("ActivityFolderType"));
                data.AppendChild(doc.CreateElement("ActivityParent"));
                data.AppendChild(doc.CreateElement("ActivityState"));

                return doc;
            }
        }

        /// <summary>
        /// Создает в системе Incident Tracker описание активности с заданными параметрами
        /// </summary>
        /// <param name="sOrganizationID">Строка с идентификатором организации - Клиента</param>
        /// <param name="sName">Строка с наименованием активности</param>
        /// <param name="sDescription">Строка с описанием активности</param>
        /// <param name="sNavisionID">Строка с кодом проекта в Navision</param>
        /// <param name="sActivityType">Строка с идентификатором типа активности</param>
        /// <param name="nFolderType">Число с указанием "Типа папки" созаваемой активности</param>
        /// <param name="nActivityState">Число с указанием состояния активности</param>
        /// <param name="sParentActivityID">Строка с идентификатором старшей активности</param>
        /// <param name="sDefaultIncidentType">Строка с идентификатором типа инцидента по умолчанию в создаваемой активности</param>
        /// <param name="bIsLocked">Признак указывающий запрещена ли регистрация списаний времени на активность</param>
        /// <param name="sInitiatorID">Строка с идентификатором сотрудника - инициатора активности</param>
        /// <returns>Строка с идентификатором созданной активности</returns>
        [WebMethod(Description = "Создает в системе Incident Tracker описание проекта с заданными параметрами")]
        public XmlDocument CreateActivity(
            String sOrganizationID,
            String sName,
            String sDescription,
            String sNavisionID,
            String sActivityType,
            Int32 nFolderType,
            Int32 nActivityState,
            String sParentActivityID,
            String sDefaultIncidentType,
            Boolean bIsLocked,
            String sInitiatorID)
        {
            try
            {
                // Проверяем корректность входных параметров:
                sParentActivityID = (String.Empty == sParentActivityID ? null : sParentActivityID);
                sDefaultIncidentType = (String.Empty == sDefaultIncidentType ? null : sDefaultIncidentType);
                ObjectOperationHelper.ValidateRequiredArgument(sOrganizationID, "Идентификатор организации - Клиента (sOrganizationID)", typeof(Guid));
                ObjectOperationHelper.ValidateRequiredArgument(sName, "Наименование проекта (sName)");
                ObjectOperationHelper.ValidateRequiredArgument(sActivityType, "Идентификатор типа активности (sActivityType)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sParentActivityID, "Идентификатор старшей активности (sParentActivityID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sDefaultIncidentType, "Идентификатор типа инцидента (sDefaultIncidentType)", typeof(Guid));
                ObjectOperationHelper.ValidateRequiredArgument(sInitiatorID, "Идентификатор сотрудника - инициатора создания проекта (sInitiatorEmployeeID)", typeof(Guid));

                // Далее - генерируем идентификатор новой активности, и вызываем спец. 
                // метод, создающий активность с ЯВНО ЗАДАННЫМ идентификатором:
                string sNewActivityID = Guid.NewGuid().ToString();
                CreateIdentifiedActivity(
                    sNewActivityID,
                    sOrganizationID,
                    sName,
                    sDescription,
                    sNavisionID,
                    sActivityType,
                    nFolderType,
                    nActivityState,
                    sParentActivityID,
                    sDefaultIncidentType,
                    bIsLocked,
                    sInitiatorID);

                // Формируем сообщение об успехе
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(
                    string.Format(
                    "<Result><Status><Code>0</Code><Descr/><Stack/></Status><Data><ActivityOrganization>{0}</ActivityOrganization></Data></Result>",
                    sNewActivityID
                    ));
                return doc;
            }
            catch (Exception e)
            {
                // Формируем сообщение об ошибке
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                return doc;
            }
        }


        /// <summary>
        /// Создает в системе Incident Tracker описание активности с заданными параметрами 
        /// и заранее указанным уникальным идентификатором
        /// </summary>
        /// <param name="sNewActivityID">Строка с идентификатором создаваемой активности</param>
        /// <param name="sOrganizationID">Строка с идентификатором организации - Клиента</param>
        /// <param name="sName">Строка с наименованием активности</param>
        /// <param name="sDescription">Строка с описанием активности</param>
        /// <param name="sNavisionID">Строка с кодом проекта в Navision</param>
        /// <param name="sActivityType">Строка с идентификатором типа активности</param>
        /// <param name="nFolderType">Число с указанием "Типа папки" созаваемой активности</param>
        /// <param name="nActivityState">Число с указанием состояния активности</param>
        /// <param name="sParentActivityID">Строка с идентификатором старшей активности</param>
        /// <param name="sDefaultIncidentType">Строка с идентификатором типа инцидента по умолчанию в создаваемой активности</param>
        /// <param name="bIsLocked">Признак указывающий запрещена ли регистрация списаний времени на активность</param>
        /// <param name="sInitiatorID">Строка с идентификатором сотрудника - инициатора активности</param>
        [WebMethod(Description = "Создает в системе Incident Tracker описание активности с заданными параметрами и заранее указанным уникальным идентификатором")]
        public void CreateIdentifiedActivity(
            String sNewActivityID,
            String sOrganizationID,
            String sName,
            String sDescription,
            String sNavisionID,
            String sActivityType,
            Int32 nFolderType,
            Int32 nActivityState,
            String sParentActivityID,
            String sDefaultIncidentType,
            Boolean bIsLocked,
            String sInitiatorID)
        {
            // Проверяем корректность входных параметров:
            Guid uidNewActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewActivityID, "Уникальный идентификатор создаваемой активности (sNewActivityID)");
            ObjectOperationHelper.ValidateRequiredArgument(sName, "Наименование проекта (sName)");

            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sOrganizationID, "Идентификатор организации (sOrganizationID)");
            Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiatorID, "Идентификатор сотрудника - инициатора создания активности (sInitiatorID)");
            Guid uidActivityType = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityType, "Идентификатор типа активности (sActivityType)");
            ObjectOperationHelper.ValidateOptionalArgument(sDefaultIncidentType, "Идентификатор типа инцидента (sDefaultIncidentType)", typeof(Guid));
            ObjectOperationHelper.ValidateOptionalArgument(sParentActivityID, "Идентификатор старшей активности (sParentActivityID)", typeof(Guid));

            // Болванка нового объекта - проекта - загружаем, и ПОСЛЕ загрузки 
            // переставляем идентификатор на заданный:
            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder");
            helperActivity.LoadObject();
            helperActivity.NewlySetObjectID = uidNewActivityID;

            // Задаем свойства проекта, в соотв. с заданными значениями параметров:
            // ... проект - это папка с типом "Проект":
            helperActivity.SetPropValue("Type", XPropType.vt_i2, (Int16)nFolderType);

            // ... задаем все переданные скаляры: 
            helperActivity.SetPropValue("Name", XPropType.vt_string, sName);

            // ... задаем описание и добавляем теги инициатора
            ObjectOperationHelper employeeHelper = ObjectOperationHelper.GetInstance("Employee", uidInitEmployeeID);
            employeeHelper.LoadObject();

            helperActivity.SetPropValue("Description", XPropType.vt_string,
                !string.IsNullOrEmpty(sDescription)
                ? string.Format(
                    "{0}\n[{1} {2}, {3}]",
                    sDescription,
                    employeeHelper.GetPropValue("LastName", XPropType.vt_string),
                    employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
                    DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
                : sDescription
                );
            helperActivity.SetPropValue("IsLocked", XPropType.vt_boolean, bIsLocked);
            // ... идентификатор проекта в Navision для треккера не является обязательным;
            // в кач. значения может быть задан null или пустая строка - сведем все 
            // к пустой строке - при записи в БД будет NULL:
            helperActivity.SetPropValue("ExternalID", XPropType.vt_string, (null == sNavisionID ? String.Empty : sNavisionID));
            // ... статус активности при создании соотносим явно: 
            helperActivity.SetPropValue("State", XPropType.vt_i2, (Int16)nActivityState);

            // Проставляем ссылки:
            // ...на сотрудника - инициатора проекта 
            helperActivity.SetPropScalarRef("Initiator", "Employee", uidInitEmployeeID);
            // ...на организацию:
            helperActivity.SetPropScalarRef("Customer", "Organization", uidOrganizationID);
            // ...на тип активности
            helperActivity.SetPropScalarRef("ActivityType", "ActivityType", uidActivityType);


            // ...на старший проект (если таковой задан):
            if (null != sParentActivityID)
                helperActivity.SetPropScalarRef(
                    "Parent", "Folder",
                    ObjectOperationHelper.ValidateRequiredArgumentAsID(sParentActivityID, "Идентификатор старшей активности (sParentActivityID)")
                );
            // ...на тип инцидента по умолчанию (если таковой задан):
            if (null != sDefaultIncidentType)
                helperActivity.SetPropScalarRef(
                    "DefaultIncidentType", "IncidentType",
                    ObjectOperationHelper.ValidateRequiredArgumentAsID(sDefaultIncidentType, "Тип инцидента по умолчанию (sDefaultIncidentType)")
                );

            // Записываем новый объект:
            helperActivity.SaveObject();
        }

        /// <summary>
        /// Изменяет данные о соотнесении указанной активности с заданными направлениями.
        /// </summary>
        /// <param name="sProjectID">
        /// Строковое представление идентификатора изменяемого описания активности. 
        /// Задание значения яв-ся обязательным. 
        /// </param>
        /// <param name="ProjectDirections">
        /// Массив классов ProjectDirection, в котором содержится информация по направлениям 
        /// соотносимых с активностью. 
        /// Все ранее заданные направления для активности будут отменены. В качестве 
        /// значения может быть задан пустой массив - в этом случае все направления
        /// для указанной активности отменяются.
        /// Задаваемые направления должны быть представлены в системе Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - если указанная активность найдена и успешно обновлена;
        /// -- False - если указанная активность не найдена
        /// </returns>
        /// <exception cref="ArgumentException">При некорректных значениях параметров</exception>
        [WebMethod(Description = "Изменяет данные о соотнесении указанной активности с заданными направлениями")]
        public XmlDocument UpdateActivityDirectionsAndExpenseRatio(
            String sActivityID,
            ProjectDirection[] ActivityDirections)
        {
            try
            {
                // Проверим переданный параметр:
                Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityID, "Идентификатор активности (sActivityID)");
                // ...второй параметр - кооректируем случай, если вместо пустого массива задан null:
                if (null == ActivityDirections)
                    ActivityDirections = new ProjectDirection[0];


                // #1:
                // Загружаем указанный проект: внутренний метод проверяет корректность параметра
                ObjectOperationHelper helperActivity = loadActivity(sActivityID, false, new string[] { "FolderDirections" });
                // ... если объект не найден - просто вернем false:
                if (null == helperActivity)
                    throw new ArgumentException("Переданная Активность не представлена в системе Incident Tracker");

                // Находим старшую активность
                ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
                // Если есть вышестоящая активность, то направление может быть только 1
                bool bExistParentActivity = (null != helperParentActivity);
                if (bExistParentActivity)
                {
                    helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                    helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });

                }

                // У активности, имеющий родительскую активность может быть только одно направление
                if ((ActivityDirections.Length > 1) && bExistParentActivity)
                    throw new ArgumentException("Подчиненная активность может иметь только одно направление");

                // Сразу изымем из датаграммы все свойства, кроме изменяемого - FolderDirections,
                // для упрошения работы с XML датаграммы и просто параноии ради
                helperActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections" , "Parent" });

                // Сумма всех переданных процентов аккамулируется
                int nTotalPercentage = 0;

                // #2:
                // Связь активности и направления выполняется при помощи спец. служебного 
                // объекта FolderDirection, который также хранит значение доли затрат
                // по направлению. 
                //
                // Для каждого заданного направления создадим описатель данных нового 
                // FolderDirection; всего их будет столько же, сколько и идентификаторов
                // заданных направлений - создавать будем массивом. При этом в массиве 
                // выделим на один элемент больше - в последний потом загрузим данные 
                // самого проекта; все вместе в одном массиве, потому что так удобнее 
                // потом создать комплексную датаграмму (см. далее #4)
                ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ActivityDirections.Length + 1];
                for (int nIndex = 0; nIndex < ActivityDirections.Length; nIndex++)
                {
                    // Проверяем идентификатор заданного направления
                    Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(ActivityDirections[nIndex].DirectionID, String.Format("Идентификатор направления ProjectDirections[{0}].DirectionID", nIndex));

                    // Проверяем процент заданного направления.
                    int nPercentage;
                    if (bExistParentActivity)
                        nPercentage = 100;
                    else
                        nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(ActivityDirections[nIndex].ExpenseRatio, String.Format("Процент распределения затрат по направлению ProjectDirections[{0}].Percentage", nIndex));

                    if (bExistParentActivity)
                    {
                        ProjectDirection[] ParentActivityDirection;
                        XmlDocument ParentUpdateResult = new XmlDocument();
                        XmlNode ParentResultCode;
                        switch (CheckActivityFolderContainDirection(helperParentActivity, uidDirectionID))
                        {
                            case ActivityFolderContainDirection.ParentActivityContainDirection:
                                break;
                            case ActivityFolderContainDirection.ParentActivityContainOtherDirection:
                                throw new ArgumentException("Запрещено указывать направление отличное от направления вышестоящей активности.");
                                break;
                            case ActivityFolderContainDirection.ParentActivityDontContainAnyDirection:
                                ParentActivityDirection = new ProjectDirection[1];
                                ParentActivityDirection[0] = new ProjectDirection();
                                ParentActivityDirection[0].DirectionID = ActivityDirections[nIndex].DirectionID;
                                ParentActivityDirection[0].ExpenseRatio = 100;
                                ParentUpdateResult = UpdateActivityDirectionsAndExpenseRatio(GetFirstLevelParentActivity(helperActivity).ToString(), ParentActivityDirection);
                                ParentResultCode = ParentUpdateResult.DocumentElement;
                                if (((XmlElement)ParentResultCode.SelectSingleNode("Status/Code")).InnerText.ToString() == "-1")
                                    throw new ArgumentException(ParentResultCode.InnerText);
                                break;
                            case ActivityFolderContainDirection.ParentActivityDontContainThisDirection:                                
                                string sFirstLevelParentActivity = GetFirstLevelParentActivity(helperActivity).ToString();
                                ParentActivityDirection = 
                                    GetFirstLevelParentActivityDirections(sFirstLevelParentActivity);
                                ParentActivityDirection[ParentActivityDirection.Length-1] = new ProjectDirection();
                                ParentActivityDirection[ParentActivityDirection.Length-1].DirectionID = ActivityDirections[nIndex].DirectionID;
                                ParentActivityDirection[ParentActivityDirection.Length-1].ExpenseRatio = 0;
                                ParentUpdateResult = UpdateActivityDirectionsAndExpenseRatio(sFirstLevelParentActivity, ParentActivityDirection);
                                ParentResultCode = ParentUpdateResult.DocumentElement;                                
                                if (((XmlElement)ParentResultCode.SelectSingleNode("Status/Code")).InnerText.ToString() == "-1")
                                    throw new ArgumentException(ParentResultCode.InnerText);
                                break;
                        };

                    }

                    // Поищем среди существующих направлений
                    foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
                    {
                        if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(ActivityDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                        {
                            arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                            helperActivity.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                            break;
                        }
                    }
                    if (arrHelpers[nIndex] == null)
                    {
                        // Загружаем "болванку" нового служебного ds-объекта FolderDirection
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                    }
                    arrHelpers[nIndex].LoadObject();
                    // ... проставляем ссылку на направление:
                    arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                    // ... и сразу проставляем ссылку на проект:
                    arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidActivityID);
                    // ... "доля затрат" - в ноль:
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                    nTotalPercentage += nPercentage;
                }
                // Если передано хотя бы одно направление, сумма процентных долей должна быть равна 100
                if ((ActivityDirections.Length > 0) && (nTotalPercentage != 100))
                    throw new ArgumentException("Сумма процентных долей по направлениям должна быть равна 100");


                //  изымем из датаграммы все свойства, кроме изменяемого - FolderDirections
                helperActivity.DropPropertiesXmlExcept("FolderDirections");

                // ... последний элемент массива - сам проект (см. далее #4):
                arrHelpers[ActivityDirections.Length] = helperActivity;


                // #3:
                // Если для проекта были определены направления, то, соотв., существуют 
                // служебные объекты FolderDirection, связывающие проект и направления. 
                // 
                // Для снятия связи м/у проектом и направлением эти служебные объекты надо
                // удалить. Удаление выполним одновременно с записью измененной датаграммы 
                // самого проекта, как "комплексной" датаграммы, в которой все FolderDirection
                // будут помечены как удаленные - для них будет задан атрибут delete="1".
                // 
                // Изымаем XML-данные свойства FolderDirection, сохранив при этом их клон -
                // далее при создании комплексной датаграммы данные из клона используем
                // для формирования записией об удаляемых объектах (см #4). В самом объекте
                // "Папка" все старые ссылки на FolderDirections удалим, а новые - добавим:

                XmlElement xmlFolderDirections = (XmlElement)helperActivity.PropertyXml("FolderDirections").CloneNode(true);
                // ... удаляем старые ссылки:
                helperActivity.ClearArrayProp("FolderDirections");
                // ... новые - добавляем:
                // Идем по массиву вспомогательных объектов, и помним при этом:
                // -- что последний там - сам проект, его учитывать на надо, поэтому 
                //		цикл до длины массива минус один;
                // -- что данные вспомогательных объектов в массиве еще не записаны, 
                //		поэтому для получения идентификатора пользуемся NewlySetObjectID
                for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                    helperActivity.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


                // #4:
                // Строим комплексную датаграмму для записи. Здесь: (а) данные самого 
                // изменного проекта, (б) данные новых FolderDirection-ов, (в) данные 
                // старых, удаляемых FolderDirection-ов
                XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
                // ... в датаграмме уже есть измененный и новые объекты - их данные 
                // перенесены из helper-ов. Добавим данные удаляемых:
                foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
                {
                    XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                    // содержимое данных удаляемого FolderDirection уже не важно - удаляем (грубо)
                    xmlDeletedFolderDirection.InnerXml = "";
                    // ... устанавливаем атриубут delete="1", ключ для сервера, 
                    // указывающий что соответствующий объект в БД надо удалить
                    xmlDeletedFolderDirection.SetAttribute("delete", "1");
                }

                // #5: 
                // Финита: записываем комплексную датаграмму; в момент записи в одной транзакции
                // будут выполнены все действия - удалены старыне FolderDirection, созданы новые 
                // FolderDirection, обновлены данные папки
                ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

                // Формируем сообщение об успехе
                XmlDocument doc = new XmlDocument();
                doc.LoadXml("<Result><Status><Code>0</Code><Descr/><Stack/></Status></Result>");
                return doc;
            }
            catch (Exception e)
            {
                // Формируем сообщение об ошибке
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                return doc;
            }
        }

		#endregion
	}
}