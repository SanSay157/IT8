//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
	/// Сервис синхронизации данных справочников, представленных в корпоративной 
	/// системе ведения Нормативной Справочной Информации (НСИ)
	/// </summary>
	[WebService(
		 Name="NSISyncService",
		 Namespace="http://www.croc.ru/Namespaces/IncientTracker/WebServices/NSISync/1.0",
		 Description=
			"Система оперативного управления проектами Incident Tracker : " +
			"Cервис синхронизации данных справочников, представленных " +
			"в корпоративной системе ведения Нормативной Справочной Информации (НСИ)" )
	]
	public class NSISyncService : WebService 
	{
		#region Общие константы, перечисления, флаги

		/// <summary>
		/// Константный текст сообщения об ошибке
		/// </summary>
		private const string DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE = "Для заданного подразделения ссылка на вышестоящее подразделение не может быть изменена указанным образом";
		/// <summary>
		/// Константные определения флагов, задаваемых для пользователей в НСИ:
		/// </summary>
		[Flags]
		private enum NsiConst_UserFlags 
		{
			/// <summary>
			/// Наличие административных полномочий в системе
			/// </summary>
			Administrator = 1,
			/// <summary>
			/// Пользователь в данный момент не работает (в системе)
			/// </summary>
			ArchiveUser = 2,
			/// <summary>
			/// Менеджер проекта (для тендеров) - флаг СУТ
			/// </summary>
			TmsTenderManager = 4,
			/// <summary>
			/// Исполнитель от департамента (для тендеров) - флаг СУТ
			/// </summary>
			TmsTenderResponsible = 16,
			/// <summary>
			/// Исполнитель по справкам (для тендеров) - флаг СУТ
			/// </summary>
			TmsInquiryResponsible = 32,
			/// <summary>
			/// Принятие решения (для тендеров) - флаг СУТ
			/// </summary>
			TmsDecidingMan= 64,
			/// <summary>
			/// Админ. справочников (тендерных) - флаг СУТ
			/// </summary>
			TmsAdministrator = 128,
			/// <summary>
			/// Директор accounta (для тендеров) - флаг СУТ
			/// </summary>
			TmsDirector = 256,
			/// <summary>
			/// Имеет доступ к системе тендеров - флаг СУТ
			/// </summary>
			TmsUser = 512,
			/// <summary>
			/// Внешний пользователь
			/// </summary>
			ExternalUser = 1024,
			/// <summary>
			/// Получает системные сообщения
			/// </summary>
			ReceiveSysMessages = 2048,
			/// <summary>
			/// Не получает никаких сообщений
			/// </summary>
			DoNotReceiveMessages = 4096,
			/// <summary>
			/// Административные права на все проекты
			/// </summary>
			ProjectAdministration = 8192,
			/// <summary>
			/// На испытательном сроке
			/// </summary>
			OnTrailPeriod = 16384,
			/// <summary>
			/// Директор компании
			/// </summary>
			Cheif = 65536,
			/// <summary>
			/// Видит всю финансовую информацию
			/// </summary>
			CanViewFinancialInfo = 131072
		}


		#endregion

		/// <summary>
		/// Конструктор объекта 
		/// </summary>
		public NSISyncService() 
		{
           ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
           DataTableXmlFormatter.DirectBooleanFieldNames = new string[]{ "TimeReporting" };
		}

		
		/// <summary>
		/// Выполняет тестирование работоспособности сервиса, доступности 
		/// сервера приложения системы Incident Tracker
		/// </summary>
		[WebMethod (Description=@"Выполняет тестирование работоспособности сервиса, доступности сервера приложения системы Incident Tracker")]
		public void TestTran() 
		{
			// Для проверки работоспособности требуется убедиться:
			//	(а) в досутпности сервера приложений;
			//	(б) в том, что возможно выполнение операций;
			//	(в) в том, что при выполнений операций выполняются операции с БД

			// Для всего этого выполняем операцию получения идентификатора объекта 
			// "SystemUser", используя в качестве ключа собственный логин - если,
			// конечно, мы его можем получить:
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
				if(Guid.Empty == responseGetId.ObjectID) throw new ApplicationException("Некорректный идентификатор пользователя системы!"); 
			}
		}


		#region Методы, используемые для синхронизации справочника "Подразделения"

		/// <summary>
		/// Загружает вспомогательный объект - helper, содержащий данные 
		/// "вышестоящего подразделения", заданного "внешней ссылкой"
		/// Здесь следующая сложность: это может быть действительно вышестоящее 
		/// подразделение, а может быть и организация - т.к. в НСИ (вслед за ITv5)
		/// для указания ссылки на организацию данные последней так же вводятся как 
		/// подразделение (sic!) корневого уровня.
		/// </summary>
		/// <param name="nPseudoDepartmentExtRefId">"Внешняя" ссылка на "подпазделение"</param>
		/// <returns>
		/// Инициализированный helper-объект, c загруженными данными объекта.
		/// Тип объекта представлен свойством TypeName
		/// </returns>
		protected ObjectOperationHelper findPseudoDepartmentRef( int nPseudoDepartmentExtRefId ) 
		{
			XParamsCollection keyPropCollection = new XParamsCollection();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse(nPseudoDepartmentExtRefId.ToString()) );
			
			// Что бы понять что именно в данном случае передано, сначала 
			// попробуем найти именно подразделение, у которого "внешний" 
			// идентификатор соотв. заданному: для этого выполняем 
			// специальный "источник данных", возращающий наименование типа 
			// и идентификатор (guid) правильного объекта. 
			// В качестве параметра передаем "внешний" идентификатор:
			DataTable data = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-Special-FindRealParentDepartment", keyPropCollection );
			if ((data==null) || (null!=data && 0==data.Rows.Count))
				throw new ArgumentException( 
					String.Format( 
						"Некорректный идентификатор вышестоящего подразделения (ParentOrgUnit={0}); "+
						"указанное подразделение в справочниках системы Incident Tracker не найдено!", 
						nPseudoDepartmentExtRefId ), 
					"ParentOrgUnit" );

			// Загружаем данные соотв. объекта - все идентификационные данные
			// (наименование типа и идентификатор) есть в полученных данных:
			ObjectOperationHelper helperRef = ObjectOperationHelper.GetInstance( 
				(string)data.Rows[0][0],	// в первой ячейке данных - наименование типа
				(Guid)data.Rows[0][1]		// во второй ячейке данных - идентификатор
			);
			helperRef.LoadObject();

			return helperRef;
		}
		
		
		/// <summary>
		/// Возвращает список всех записей справочника "Подразделения", 
		/// представленных в системе Incident Tracker
		/// </summary>
		/// <returns>
		/// Документ XML с данными всех записей списка
		/// </returns>
		[WebMethod (Description = @"Возвращает список всех записей справочника ""Подразделения"", представленном в системе Incident Tracker")]
		public XmlDocument GetOrgUnits() 
		{
			// Возврaщает данные в виде XML-документа следующего формата (в примере
			// приведен случай отображения данных только для одного подразделения; 
			// регистр символов имеет значение):
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
		/// Добавляет описание нового подразделения в справочник "Подразделения", 
		/// представленный в системе Incident Tracker
		/// </summary>
		/// <param name="Address">Адрес</param>
		/// <param name="Descr">Описание</param>
		/// <param name="eMail">eMail</param>
		/// <param name="Head">Идентификатор руководителя отдела</param>
		/// <param name="Name">Название</param>
		/// <param name="ParentOrgUnit">Идентификатор родительского подразделения</param>
		/// <param name="Phone">Телефон</param>
		/// <param name="TimeReporting">Подразделения должно отчитываться</param>
		/// <param name="Code">Кодовое наименование подразделения</param>
		/// <param name="ObjectGUID">GUID подразделения</param>
		/// <returns>Идентификатор добаленной записи</returns>
		[WebMethod (Description = @"Добавляет описание нового подразделения в справочник ""Подразделения"", представленном в системе Incident Tracker")]
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
            // Предварительная проверка данных:
			ObjectOperationHelper.ValidateRequiredArgument( Name,"Name" );

            ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
			// Вспомогательные объекты для работы с ds-данными
            ObjectOperationHelper helper = null;	
			ObjectOperationHelper helperRef = null;
			// ...и для идентификации ds-объекта по набору значений его свойств
			XParamsCollection keyPropCollection = new XParamsCollection();
			
			if ( 0 == ParentOrgUnit )
			{
				// Если идентификатор родительского подразделения не задан - то тогда
				// подразумевается создание корневого подразделения, играющего роль 
				// описания организации; именно в таком качестве - как организацию -
				// и создаем новый объект.
				
				// #1: Прежде чем создать такую организацию - проверим, может как организация
				// она уже в IT описана (в этом случае _создавать_ уже ничено не надо); в качестве
				// ключа используем наименования (краткое и полное) организации:
				helper = ObjectOperationHelper.GetInstance( "Organization" );
				keyPropCollection.Add( "ShortName", Code );
				keyPropCollection.Add( "Name", Name );

				if ( helper.SafeLoadObject( keyPropCollection ) )
				{
					// #2.1: Организацию нашли; полное и кратное наименования у нее такие
					// какие нужно (потому и нашли). Комментарий в этом случае править
					// не будем; проставим явно признак, показывающий что у этой организации
					// есть описание структуры:
					helper.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );

					// т.к. в данном случае мы ИЗМЕНЯЕМ данные организации, то уберем
					// из датаграммы те свойства, которые изменять не стоит (или нет прав):
					helper.DropPropertiesXml("Home" );
				}
				else
				{
					// Организация не найдена - загружаем "болванку" описания новой организации
					helper.LoadObject();

					// Устанавливаем скалярные необъектные значения для нового объекта:
					helper.SetPropValue( "ShortName", XPropType.vt_string, Code );
					helper.SetPropValue( "Name", XPropType.vt_string, Name );
					helper.SetPropValue( "Comment", XPropType.vt_string, Descr );
					// Это не организация - "владелец"
					helper.SetPropValue( "Home", XPropType.vt_boolean, false );
					// Указываем, что у организации "определена структура" (ибо только для 
					// этого - для описания структуры - ее здесь и создают):
					helper.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );
				}
				// Есть еще объектная ссылка на руководителя - будет установлена далее
			}
			else
			{
				// Создаем вспомогательный объект; в процессе выполняется
				// получение датаграммы нового объекта типа "Отрасль"
				helper = ObjectOperationHelper.GetInstance( "Department" );
				helper.LoadObject();

				// Устанавливаем скалярные необъектные значения для нового объекта:
				helper.SetPropValue( "Code", XPropType.vt_string, Code );
				helper.SetPropValue( "Name", XPropType.vt_string, Name );
				helper.SetPropValue( "Comment", XPropType.vt_string, Descr );

				helper.SetPropValue( "Type", XPropType.vt_i2, DepartmentType.Direction ); // просто как отдел
				helper.SetPropValue( "TimeReporting", XPropType.vt_boolean, TimeReporting );

				// Скалярные объектные свойства:

				// ССЫЛКА НА ВЫШЕСТОЯЩЕЕ ПОДРАЗДЕЛЕНИЕ; Здесь следующая сложность: 
				// это может быть действительно вышестоящее подразделение, а может 
				// быть и организация - т.к. в НСИ для указания ссылки на 
				// организацию данные последней так же вводятся как подразделение
				// корневого уровня.
				// 
				// Для загрузки данных этого объекта используем специальный 
				// внутренний метод, который сначала определяет что именно 
				// используется в данном случае. Реальный тип объекта будет в 
				// helperRef.TypeName:
				helperRef = findPseudoDepartmentRef( ParentOrgUnit );
				
				// Теперь добавляем ссылки во вновь создаваемый объект:
				// Если изначально указанное "вышестоящее" - это действительно 
				// подразделение, то из его данных (загруженных в helperRef) 
				// скопируем во вновь создаваемый объект ссылку на организацию; 
				// если же это и была организация - то в этом случае ссылка на
				// вышестоящее подразделение останется неинициализированной, 
				// т.е. в БД будет записано NULL
				if ( "Department" == helperRef.TypeName )
				{
					helper.SetPropScalarRef( "Parent", "Department", helperRef.ObjectID );
					// копирование ссылки на организацию:
					XmlElement xmlPropOrgRef = helper.PropertyXml( "Organization" );
					xmlPropOrgRef.RemoveAll();
					xmlPropOrgRef.InnerXml = helperRef.PropertyXml("Organization").InnerXml;
				}
				else if ( "Organization" == helperRef.TypeName )
					helper.SetPropScalarRef( "Organization", "Organization", helperRef.ObjectID );
				else
					throw new ApplicationException("Неизвестный тип объекта - " + helperRef.TypeName);
			}

			// Ссылка на руководителя подразделения:
			if ( 0!=Head )
			{
				keyPropCollection.Clear();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(Head.ToString()) );

				helperRef = ObjectOperationHelper.GetInstance( "Employee" );
				helperRef.LoadObject( keyPropCollection );

				//В случае если создавали не организацию - проставим значение свойства "Директор Клиента" 
                //ВОЗМОЖНО здесь потом поменяем и будем также устанавливать свойство "Директор Клиента" для организаций
                if (helper.TypeName != "Organization")
                    helper.SetPropScalarRef("Director", "Employee", helperRef.ObjectID);
                else
                {
                    helper.DropPropertiesXml("Director");
                }
			}
			// Перед записью уберем из датаграммы описания свойств, 
			// которые вообще не должны записываться:
			helper.DropPropertiesXml( "ExternalRefID" );

			// Записываем данные объекта
			helper.SaveObject();
			
			// Перезагрузим объект еще раз - уже как существующий в БД - для того, 
			// что бы получить "внешний" идентификатор:
			helper.LoadObject();
			// Запоминаем внутренний идентификатор (это можно сделать и до записи, 
			// но тогда идентификатор нвого объекта надо читать в NewObjectID):
			ObjectGUID = helper.ObjectID.ToString().ToUpper();
			return (int)helper.GetPropValue( "ExternalRefID",XPropType.vt_i4 );
		}

		
		/// <summary>
		/// Обновляет описание подразделения в справочнике "Подразделения", 
		/// представленном в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectID">Идентификатор обновляемого подразделения</param>
		/// <param name="Address">Адрес</param>
		/// <param name="Descr">Описание</param>
		/// <param name="eMail">eMail</param>
		/// <param name="Head">Идентификатор руководителя подразделения</param>
		/// <param name="Name">Название подразделения</param>
		/// <param name="ParentOrgUnit">Идентификатор родительского подразделения</param>
		/// <param name="Phone">Телефон</param>
		/// <param name="TimeReporting">Подразделения должно отчитываться по затратам времени</param>
		/// <param name="Flags">Флаги</param>
		/// <param name="Code">Код организации</param>
        /// <param name="IsArchive">Архивное</param>
        [WebMethod(Description = @"Обновляет описание подразделения в справочнике ""Подразделения"", представленном в системе Incident Tracker")]
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
				throw new ArgumentException("Не задан идентификатор целевого подразделения/организации", "ObjectID");

			// Загружаем данные указанного подразделения в объект-helper.
			// Здесь следующая сложность: это может быть действительно вышестоящее 
			// подразделение, а может быть и организация - т.к. в НСИ (вслед за ITv5)
			// для указания ссылки на организацию данные последней так же вводятся как 
			// подразделение (sic!) корневого уровня.
			// "Настоящий" тип объекта будет в helperDepartment.TypeName
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( ObjectID );
			helperDepartment.LoadObject();


			// РАЗРЕШЕНИЕ ССЫЛКИ НА ВЫШЕСТОЯЩЕЕ ПОДРАЗДЕЛЕНИЕ
			// Проблема вот в чем: ссылка м.б. переставлена только если
			//	(а) исходное подразделение - есть "настоящее", а не организация, 
			//	(б) задано новое вышестоящее подразделение (не важно - "настоящее" или нет)

			// Получим идентификацонные данные исходного вышестоящего подразделения:
			ObjectOperationHelper helperParentDepartment = null;
			// ...которая может быть установлена только у "настоящего" подразделения:
			if ( "Department" == helperDepartment.TypeName )
			{
				if (0!=helperDepartment.PropertyXml("Parent").ChildNodes.Count)
				{
					helperParentDepartment = helperDepartment.GetInstanceFromPropScalarRef( "Parent" );
					if (Guid.Empty == helperParentDepartment.ObjectID)
						helperParentDepartment = null;
				}
			}
			// Получим идентификационные данные "нового" вышестоящего подразделения
			ObjectOperationHelper helperNewParentDep = null;
			if ( 0!=ParentOrgUnit )
				helperNewParentDep = findPseudoDepartmentRef( ParentOrgUnit );
			
			// Если данные объекта и параметра не соотв. условиям (см. выше), 
			// генерируем исключение:
			if ( "Organization"==helperDepartment.TypeName && null!=helperNewParentDep )
				throw new ArgumentException( 
					DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE + 
					": корневое подразделение (организация) не может быть подчинено другому поразделению / организации", 
					"ParentOrgUnit" );
			if ( "Department"==helperDepartment.TypeName && null==helperNewParentDep )
				throw new ArgumentException(
					DEF_ERRMSG_INCORECT_ORGUNIT_UPDATE + 
					": подчиненное подразделение не может представлено как корневое (организация)", 
					"ParentOrgUnit" );
			
			// Выполним перестановку ссылок на "вышестоящее" (если только 
			// редактируемый объект - "настоящее подразделение):
			if ( "Department"==helperDepartment.TypeName )
			{
				// Если новое вышестоящее - "настоящее" подразделение: переставим
				// у редактируемого ссылку на подразделение и скопируем ссылку на 
				// организацию (для чего сначала прогрузим данные нового "вышестоящего"):
				if ( "Department"==helperNewParentDep.TypeName )
				{
					helperDepartment.SetPropScalarRef( "Parent", "Department", helperNewParentDep.ObjectID );
					// копирование ссылки на организацию:
					helperNewParentDep.LoadObject();
					XmlElement xmlPropOrgRef = helperDepartment.PropertyXml( "Organization" );
					xmlPropOrgRef.RemoveAll();
					xmlPropOrgRef.InnerXml = helperNewParentDep.PropertyXml("Organization").InnerXml;
				}
				// Если же новое вышестоящее - организация и есть, то у редактируемого
				// (а) сбросим ссылку на вышестоящее подразделение,
				// (б) установим ссылку на новую организацию
				else
				{
					helperDepartment.PropertyXml("Parent").RemoveAll();
					helperDepartment.SetPropScalarRef( "Organization", "Organization", helperNewParentDep.ObjectID );
				}
			}
			else
			{
				// В случае редактирования "песвдо"-подразделения, которая на 
				// самом деле организация - выбросим ссылки на вышестоящие (здесь
				// уже - организации) из датаграммы - что бы Storage ничего не 
				// обновлял:
				helperDepartment.DropPropertiesXml("Parent");
			}
			
			
			// РАЗРЕШЕНИЕ ССЫЛКИ НА СОТРУДНИКА - РУКОВОДИТЕЛЯ ПОДРАЗДЕЛЕНИЯ
			if ( 0!=Head )
			{
				// Для установки ссылки нужен внутренний ObjectID объекта; получим
				// его на основании заданного "внешнего", используя логику 
				// вспомогательного объекта:
				XParamsCollection keyPropCollection = new XParamsCollection();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(Head.ToString()) );

				ObjectOperationHelper helperNewDirector = ObjectOperationHelper.GetInstance( "Employee" );
				helperNewDirector.GetObjectIdByExtProp(keyPropCollection);
				
				// Устанавливаем новую ссылку - директора клиента в случае если объект является подразделением
                //Возможно здесь также будем устанавливать свойство "Директор клиента" для организаций
				if (helperDepartment.TypeName!="Organization") helperDepartment.SetPropScalarRef( 
	            "Director","Employee", helperNewDirector.ObjectID);
				else
				{
				    helperDepartment.DropPropertiesXml("Director");
				}
				
			}
			else
			{
				// Идентификатор сотрудника - руководителя нулевой - значит 
				// ссылка не задана - сбросим данные ссылки в датаграмме; при 
				// ее обработке Stroage проставит в соотв. поле NULL:
				helperDepartment.PropertyXml("Director").RemoveAll();
			}


			// ЗАДАЕМ НОВЫЕ ЗНАЧЕНИЯ СКАЛЯРНЫХ НЕОБЪЕКТНЫХ СВОЙСТВ
			if ( "Department"==helperDepartment.TypeName )
			{
				// Для случая, если подразделение есть "настоящее" подразделение:
				helperDepartment.SetPropValue("Code", XPropType.vt_string, Code );
				helperDepartment.SetPropValue("Name", XPropType.vt_string, Name );
				helperDepartment.SetPropValue("Comment", XPropType.vt_string, Descr );
				helperDepartment.SetPropValue("TimeReporting", XPropType.vt_boolean, TimeReporting );
                helperDepartment.SetPropValue("IsArchive", XPropType.vt_boolean, IsArchive);

				// Сбросим свойства, значения которых изменяться не должны
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

				// Для организации всегда принудительно проставляем признак наличия описания
				// структуры организации (хотя оно и не должно меняться, просто т.о. усиливаем
				// условия):
				helperDepartment.SetPropValue( "StructureHasDefined", XPropType.vt_boolean, true );

				// Сбросим свойства, значения которых изменяться не должны
				helperDepartment.DropPropertiesXml( 
					"Home", 
					"ExternalID", 
					"ExternalRefID"  );
			}


			// ЗАПИСЫВАЕМ ДАННЫЕ ИЗМЕНЕННОГО ОБЪЕКТА
			helperDepartment.SaveObject();
		}

	
		/// <summary>
		/// Удаляет описание подразделение из справочника "Подразделения", 
		/// представленного в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectID">Идентификатор подразделения</param>
		[WebMethod (Description = @"Удаляет описание подразделение из справочника ""Подразделения"", представленного в системе Incident Tracker")]
		public void DeleteOrgUnitITracker( int ObjectID ) 
		{
            ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
			// Вспомогательный объект для работы с ds-данными
			ObjectOperationHelper helper = null;	
			// ...и для идентификации ds-объекта по набору значений его свойств
			XParamsCollection keyPropCollection = new XParamsCollection();

			// РАЗРЕШАЕМ ИДЕНТИФИКАТОР ПОДРАЗДЕЛЕНИЯ
			// Здесь следующая сложность: это может быть действительно 
			// подразделение, а может быть и организация - т.к. в НСИ для указания 
			// ссылки на организацию данные последней так же вводятся как 
			// подразделение (sic!) корневого уровня.

			// Что бы понять что именно в данном случае передано, сначала 
			// попробуем определить тип и идентификатор объекта (подразделение 
			// или орагнизацию), у которого "внешний" идентификатор соотв. 
			// заданному: для этого выполняем специальный "источник данных", 
			// возращающий наименование типа и идентификатор (guid) правильного 
			// объекта. В качестве параметра передаем "внешний" идентификатор:
			keyPropCollection.Clear();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse(ObjectID.ToString()) );
				
			DataTable data = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-Special-FindRealParentDepartment", keyPropCollection );
			if ((data==null) || (null!=data && 0==data.Rows.Count))
				throw new ArgumentException( 
					String.Format( 
					"Некорректный идентификатор подразделения (ObjectID={0}); "+
					"указанное подразделение в справочниках системы Incident Tracker не найдено!", ObjectID ), 
					"ObjectID" );

			// Загружаем данные соотв. объекта - все идентификационные данные
			// (наименование типа и идентификатор) есть в полученных данных:
			helper = ObjectOperationHelper.GetInstance( 
				(string)data.Rows[0][0],	// в первой ячейке данных - наименование типа
				(Guid)data.Rows[0][1]		// во второй ячейке данных - идентификатор
			);
			
			// Вызываем удаление объекта (что бы это ни было)
			helper.DeleteObject();
		}

		
		#endregion

		#region Методы, используемые для синхронизации справочников "Сотрудники" и "Пользователи"

		/// <summary>
		/// Возвращает всех сотрудников/пользователей, представленных 
		/// в справочнике "Пользователи" системы Incident Tracker
		/// </summary>
		/// <param name="loadPict">Должно быть всегда false</param>
		/// <returns>
		/// Документ XML c данными сотрудников / пользователей
		/// </returns>
		[WebMethod (Description=@"Возвращает всех сотрудников/пользователей, представленных в справочнике ""Пользователи"" системы Incident Tracker")]
		public XmlDocument GetUsers( bool loadPict ) 
		{
			// Получить весь список пользователей сразу с фото нельзя - серверу 
			// не хватает памяти для сериализации результирующего документа 
			// ПОТОМУ: т.к. сигнатуру изменять нельзя - оставим ее как есть.
			// Но при этом запрещаем вызов метода с параметром loadPict, заданным
			// в true:
			if (loadPict)
				throw new ArgumentException( 
					"Получить список всех сотрудников, содержащих фотографии, невозможно! " +
					"Рекомендуется ипользовать метод GetPhoto(...)",
					"loadPict"
				);
			
			// Возврaщает данные в виде XML-документа следующего формата (в примере
			// приведен случай отображения данных только для одного пользователя; 
			// регистр символов имеет значение):
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
			//				Picture="..." <<<-- включается, только если задан флаг loadPict
			//				Phone="..."
			//				EMail="..."
			//				MobilePhone="..."
			//				PhoneExt="..."
			//			/>
			//		</Root>

			// ВСЕГДА передаем такой параметр, который запрещает загрузку
			// фотографий сотрудников - в противном случае попытка системы 
			// "поднять" результирующий XML при сериализации результата
			// приводит к исключению вида OutOfMemoryException
			XParamsCollection dataSourceParams = new XParamsCollection();
			dataSourceParams.Add( "DoPictureLoad", false );
			return ObjectOperationHelper.ExecAppDataSourceSpecial( "SyncNSI-GetList-Employees", dataSourceParams, "user" );
		}

		/// <summary>
		/// Добавляет описание нового сотрудника в справочник "Сотрудники", 
		/// представленном в системе Incident Tracker; так же создает 
		/// соответствующее описание справочника "Пользователи"
		/// </summary>
		/// <param name="Address">Адрес</param>
		/// <param name="eMail">eMail</param>
		/// <param name="FirstName">Имя</param>
		/// <param name="LastName">Фамилия</param>
		/// <param name="MiddleName">Отчество</param>
		/// <param name="MobilePhone">Мобильный телефон</param>
		/// <param name="OrgUnit">Идентификатор подразделения, где сотрудник работает</param>
		/// <param name="Phone">Телефон</param>
		/// <param name="PhoneExt">Внутренний телефон</param>
		/// <param name="SystemUserPosition">Идентификатор должности сотрудника</param>
		/// <param name="UID">Идентификатор сотрудника (эккаунт)</param>
		/// <param name="ObjectGUID">GUID сотрудника</param>
		/// <param name="Flags">Флаги</param>
		/// <param name="Picture">Фотография сотрудника в виде строки bin.hex</param>
		/// <returns>Идентификатор добавленной записи</returns>
		[WebMethod (Description = @"Добавляет описание нового сотрудника в справочник ""Сотрудники"", представленном в системе Incident Tracker; так же создает соответствующее описание справочника ""Пользователи""")]
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
			// Изначально устанавливаем out-параметр в "нейтральное" занчение
			ObjectGUID = String.Empty;

			// Получим реальные идентификаторы объектов "Подразделение" и
			// "Должность". Используем для этого вспомогательные объекты. 
			
			// -- ССЫЛКА НА ПОДРАЗДЕЛЕНИЕ; Здесь следующая сложность: 
			// это может быть действительно подразделение, а может быть и 
			// организация - т.к. в НСИ (вслед за ITv5) для указания ссылки на 
			// организацию данные последней так же вводятся как подразделение
			// (sic!) корневого уровня.
			// 
			// Для загрузки данных этого объекта используем специальный 
			// внутренний метод, который сначала определяет что именно 
			// используется в данном случае. Реальный тип объекта будет в 
			// helperDepartment.TypeName:
			if ( 0==OrgUnit )
				throw new ArgumentException("Идентификатор подразделения / организации не задан", "OrgUnit");
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( OrgUnit );

			// -- ССЫЛКА НА ДОЛЖНОСТЬ (может не задаваться)
			// Сами данные указанной должности нам не нужны - нужен только 
			// реальный идентификатор объекта:
			ObjectOperationHelper helperPosition = ObjectOperationHelper.GetInstance( "Position" );
			// идентифицируем объект "внешним" идентификатором - если он, конечно, задан:
			if ( 0!=SystemUserPosition )
			{
				XParamsCollection keyPropCollection = new XParamsCollection();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(SystemUserPosition.ToString()) );
				helperPosition.GetObjectIdByExtProp( keyPropCollection );
			}


			// Используя вспомогательный объекты получим шаблоны датаграмм для 
            // объектов типа "Пользователь" (SystemUser), "Сотрудник" (Employee), 
            // "Норма рабочего времени" (EmployeeRate)
            // SystemUser используется для сохранения информации, необходимой для 
			// входа в систему (логин, представленный параметром UID), 
            // Employee представляет все данные сотрудника
            // EmployeeRate данные по норме рабочего времени сотрудника
            // Organization представляет данные по организации в которой создается сотрудник
			ObjectOperationHelper helperSystemUser = ObjectOperationHelper.GetInstance( "SystemUser" );
			helperSystemUser.LoadObject();
			ObjectOperationHelper helperEmployee = ObjectOperationHelper.GetInstance( "Employee" );
			helperEmployee.LoadObject();
            ObjectOperationHelper helperEmployeeRate = ObjectOperationHelper.GetInstance("EmployeeRate");
            helperEmployeeRate.LoadObject();
            ObjectOperationHelper helperOrganization = ObjectOperationHelper.GetInstance("Organization");
  
         
            // Сразу задаем связь м/у объектами - "Сотрудник" ссылается на "Пользователя":
			helperEmployee.SetPropScalarRef( "SystemUser", "SystemUser", helperSystemUser.NewlySetObjectID );

			// Определим ссылки на организацию и подразделение (если последняя задана):
			// Если указанное "поразделение" - это действительно подразделение, 
			// то из его данных (загруженных в helperDepartment) скопируем во 
			// вновь создаваемый объект ссылку на организацию; если же это и 
			// была организация - то в этом случае ссылка на подразделение 
			// останется неинициализированной, т.е. в БД будет записано NULL
			if ( "Department" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Department", "Department", helperDepartment.ObjectID );
				// копирование ссылки на организацию:
				XmlElement xmlPropOrgRef = helperEmployee.PropertyXml( "Organization" );
				xmlPropOrgRef.RemoveAll();
				xmlPropOrgRef.InnerXml = helperDepartment.PropertyXml("Organization").InnerXml;
                //Организация, в которой создаем сотрудника - это организация,на которую ссылается департамент 
			    helperOrganization = helperDepartment.GetInstanceFromPropScalarRef("Organization");
			}
            else if ("Organization" == helperDepartment.TypeName)
            {
                helperEmployee.SetPropScalarRef("Organization", "Organization", helperDepartment.ObjectID);
                //Изначально передавали идентификатор организации,поэтому helperOrganization это и есть helperDepartment
                helperOrganization = helperDepartment;
            }
            else
                throw new ApplicationException("Неизвестный тип объекта - " + helperDepartment.TypeName);
			
            //Если сотрудник создается в организации - владельце системы,то устанавливаем для него системные роли,
            //которые нужно задавать по умолчанию (признак IsDefaultRole=1)
            helperOrganization.LoadObject();
            if ((bool)helperOrganization.GetPropValue("Home", XPropType.vt_boolean, true))
            {
                foreach (string item in ServiceConfig.Instance.DefaultSystemRoles)
                {
                    helperSystemUser.AddArrayPropRef("SystemRoles", "SystemRole", new Guid(item)); 
                }
                
            }

		    // Ссылка на должность (если такая задана)
			if ( Guid.Empty != helperPosition.ObjectID )
				helperEmployee.SetPropScalarRef( "Position", "Position", helperPosition.ObjectID );


			// ЗАДЕМ ЗНАЧЕНИЯ НЕОБЪЕКТНЫХ СКАЛЯРНЫХ СВОЙСТВ:
			// -- Для SystemUser:
			helperSystemUser.SetPropValue( "Login", XPropType.vt_string, UID );
			helperSystemUser.SetPropValue( "IsServiceAccount", XPropType.vt_boolean, false );

			// Все "права", задаваемые в ITv5 флажками, в ITv6 задаются привилегиями,
			// заданными непосредственно для пользователя, или опосредованно - через 
			// объект системной роли (которые по сути - именованные наборы привилегий)
			//
			// В сервисе синхронизации флаги ITv5 разрешаются как ссылки на предопределенные
			// объекты ролей, задаваемые для пользователя. Карта ссылок (какой флаг какую
			// роль задает) описывается в прикладном конфигурационном файле сервисов.
			// 
			// Здесь: Системные привилегии НЕ устанавливаются:
			helperSystemUser.SetPropValue( "SystemPrivileges", XPropType.vt_i4, 0 );
			// Признак сброса всех ролей пользователя: 		
			bool bIsClearRoles = false;
			// Роли: идем от флагов, заданных для конфигурации; если рассматриваемый флаг
			// задан для пользователя и этому флагу в конфигурации соотв. определенная роль,
			// то установим эту роль:
			foreach( int nFlag in ServiceConfig.Instance.RolesMap.Flags )
			{
				// Если рассматриваемый флаг - не тот, что задан - пропускаем:
				if ( nFlag != (Flags & nFlag) )
					continue;
					
				// Получаем опистель ссылки
				UserFlagToRoleLink link = ServiceConfig.Instance.RolesMap[nFlag];
				// Проверяем, что это не "зачищающий" - если так, то запоминаем это 
				// и выходим из цикла - далее анализировать флаги не имеет смысла
				if ( (bIsClearRoles = link.IsClearRolesFlag) )
					break;
					
				// Если ссылка указыает какую-то роль - добаляем соотв. объектную ссылку
				// в свойство объекта (при этом в описателе ссылки используем св-во 
				// RoleObject - при первом доступе это дело зачитает реальные данные 
				// с сервера приложения)
				if (Guid.Empty != link.RoleID)
					helperSystemUser.AddArrayPropRef( "SystemRoles", link.RoleObject.TypeName, link.RoleObject.ObjectID ) ;
			}
			if ( bIsClearRoles )
				helperSystemUser.ClearArrayProp( "SystemRoles" );
			
			// -- Для Employee:
			helperEmployee.SetPropValue( "LastName", XPropType.vt_string, LastName );
			helperEmployee.SetPropValue( "FirstName", XPropType.vt_string, FirstName );
			helperEmployee.SetPropValue( "MiddleName", XPropType.vt_string, MiddleName );
			// Дата начала работы задается от момента создания описания:
			helperEmployee.SetPropValue( "WorkBeginDate", XPropType.vt_date, DateTime.Today );
			// Флагом (параметр Flags) может быть указано, что сотрудник/пользователь 
			// является АРХИВНЫМ. В ITv6 факт "архивности" задается датой завершения 
			// работы, WorkEndDate. Если флаг "архивный" задан, то установим
			// дату завершения работы; при этом используем текущую дату:
			if ( 0x2 == (Flags & 0x2)) // Флаг "Архивный"
				helperEmployee.SetPropValue( "WorkEndDate", XPropType.vt_date, DateTime.Today );
			helperEmployee.SetPropValue( "Phone", XPropType.vt_string, Phone );
			helperEmployee.SetPropValue( "PhoneExt", XPropType.vt_string, PhoneExt );
			helperEmployee.SetPropValue( "MobilePhone", XPropType.vt_string, MobilePhone );
			helperEmployee.SetPropValue( "Address", XPropType.vt_string, Address );
			helperEmployee.SetPropValue( "EMail", XPropType.vt_string, eMail );
			// данные картинки фотографии сотрудника - если заданы
			if (null!=Picture && 0!=Picture.Length)
			{
				helperEmployee.PropertyXml("Picture").RemoveAll();
				helperEmployee.PropertyXml("Picture").InnerText = ObjectOperationHelper.ConvertBinHexToBinBase64( Picture );
			}
			// NB: Все исходные флаги как они есть сохраним в ExternalID - что бы 
			// потом вернуть их в первозданном виде обратно, при запросе из НСИ
			// (см. реализацию GetUsers и SQL-операцию в описании источника данных 
			// SyncNSI-GetList-Employees:
			helperEmployee.SetPropValue( "ExternalID", XPropType.vt_string, Flags.ToString() );

			// Сбросим реквизиты, данные которых не должны записываться в БД:
			helperEmployee.DropPropertiesXml( "ExternalRefID" );

            // Создадим запись в таблице EmployeeRate - норма рабочего времени по умолчанию для всех новых сотрудников
            // "Норма рабочего времени" ссылается на "Сотрудник"
            helperEmployeeRate.SetPropScalarRef("Employee", "Employee", helperEmployee.NewlySetObjectID);
            // Норма начинает действовать с момента приема сотрудника на работу (WorkBeginDate)
            // Значение берется из свойства, если в будущем дата выхода на работу будет отлична от константы "текущая дата"
            helperEmployeeRate.SetPropValue("Date", XPropType.vt_date, helperEmployee.GetPropValue("WorkBeginDate", XPropType.vt_date));
            // В поле "коментарий" указываем "Прием на работу"
            helperEmployeeRate.SetPropValue("Comment", XPropType.vt_text, EmployeeHistoryEventsItem.WorkBeginDay.Description);
            // В поле "Норма" указываем значение по умолчанию из базы данных.
            DataTable data = ObjectOperationHelper.ExecAppDataSource("GetWorkdayGlobalDuration", null);
            if ((data == null) || (null != data && 1 != data.Rows.Count))
                throw new ApplicationException("GetWorkdayGlobalDuration: Ошибка получения нормы по умолчанию. Запрос не вернул данных или вернул более одной строки.");

            helperEmployeeRate.SetPropValue("Rate", XPropType.vt_i2, data.Rows[0][0]);


			// ЗАПИСЫВАЕМ ДАННЫЕ ОБОИХ ОБЪЕКТОВ одновременно, в рамках одной 
			// "сложной" датаграммы; Это необходимо для обеспечения ссылочной
			// целостности, заданной м/у объектами
            ObjectOperationHelper.SaveComplexDatagram(helperSystemUser, helperEmployee, helperEmployeeRate);

			// В качестве результирующего GUID-а возвращаем идентификатор объекта
			// типа "Сотрудник" (Employee) - т.к. везде при синхронизации данных
			// "Сотрудников" используются идентфикационные данные именно этих 
			// объектов:
			ObjectGUID = helperEmployee.ObjectID.ToString();

			// Соответственно в качестве результирующего "внешнего" идентификатора
			// возрвщваем ExternalRefId объекта "Сотрудник"; что бы его получить, 
			// сначала перегрузим данные объекта:
			helperEmployee.LoadObject();
			return int.Parse( helperEmployee.GetPropValue("ExternalRefID", XPropType.vt_i4).ToString() );
		}
		
		
		/// <summary>
		/// Обновляет описание сотрудника в справочнике "Сотрудники", 
		/// представленном в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectID">Идентификатор сотрудника в таблице SystemUser</param>
		/// <param name="Address">Адрес</param>
		/// <param name="eMail">eMail</param>
		/// <param name="FirstName">Имя</param>
		/// <param name="LastName">Фамилия</param>
		/// <param name="MiddleName">Отчество</param>
		/// <param name="MobilePhone">Мобильный телефон</param>
		/// <param name="OrgUnit">Идентификатор подразделения, в котором сотрудник работает</param>
		/// <param name="Phone">Телефон</param>
		/// <param name="PhoneExt">Внутренний телефон</param>
		/// <param name="SystemUserPosition">Идентификатор должности сотрудника</param>
		/// <param name="UID">Идентификатор сотрудника (эккаунт)</param>
		/// <param name="Flags">Флаги</param>
		/// <param name="Picture">Фотограция сотрудника, если параметр равен null - фотогрвфия не обновляется</param>
		[WebMethod (Description=@"Обновляет описание сотрудника в справочнике ""Сотрудники"", представленном в системе Incident Tracker")]
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
			// TODO: Проверка входных параметров:

			// ЗАГРУЖАЕМ ДАННЫЕ ОБЪЕКТОВ
			// Загружаем данные объекта "Сотрудник"
			ObjectOperationHelper helperEmployee = ObjectOperationHelper.GetInstance( "Employee" );
			XParamsCollection keyPropCollection = new XParamsCollection();
			keyPropCollection.Add( "ExternalRefID", Int32.Parse( ObjectID.ToString() ) );
			helperEmployee.LoadObject( keyPropCollection );
			
			// Загружаем данные объекта "Пользователь"; идентификационные данные
			// объекта берем из объектной ссылки SystemUser
			ObjectOperationHelper helperSystemUser = helperEmployee.GetInstanceFromPropScalarRef( "SystemUser" );
			helperSystemUser.LoadObject( new string[]{ "SystemRoles"} );
			
			// ЗАДЕМ ЗНАЧЕНИЯ НЕОБЪЕКТНЫХ СКАЛЯРНЫХ СВОЙСТВ:
			
			// -- Для SystemUser:
			helperSystemUser.SetPropValue( "Login", XPropType.vt_string, UID );

			// Все "права", задаваемые в ITv5 флажками, в ITv6 задаются привилегиями,
			// заданными непосредственно для пользователя, или опосредованно - через 
			// объект системной роли (которые по сути - именованные наборы привилегий)
			//
			// В сервисе синхронизации флаги ITv5 разрешаются как ссылки на предопределенные
			// объекты ролей, задаваемые для пользователя. Карта ссылок (какой флаг какую
			// роль задает) описывается в прикладном конфигурационном файле сервисов.

			// Здесь:
			// #0: Отдельно выделяем два признака: "Архивный пользователь"...
			bool bHasArchivedFlag = ( NsiConst_UserFlags.ArchiveUser == ((NsiConst_UserFlags)Flags & NsiConst_UserFlags.ArchiveUser) );
			// ...и признак "не получает сообщения" (в IT6 это означает принудительную "отписку"):
			bool bHasNoMessageFlag = ( NsiConst_UserFlags.DoNotReceiveMessages == ((NsiConst_UserFlags)Flags & NsiConst_UserFlags.DoNotReceiveMessages) );
			
			// #1: Проверим, что флаги изменились (предыдущее значение сохранено в
			// ExternalRefID сотрудника) - если флаги не менялись, то и права трогать 
			// не будем:
			string sPrevFlags = (string)helperEmployee.GetPropValue( "ExternalID", XPropType.vt_string );

			if (null==sPrevFlags || String.Empty==sPrevFlags)
				sPrevFlags = "0";
			if ( Flags.ToString() != sPrevFlags )
			{
				// #2: Предварительно сбросим ВСЕ роли:
				helperSystemUser.ClearArrayProp( "SystemRoles" );

				// #3: идем от флагов, заданных для конфигурации; если рассматриваемый флаг
				// задан для пользователя и этому флагу в конфигурации соотв. определенная роль,
				// то установим эту роль:
				bool bIsClearRoles = false;
				foreach( int nFlag in ServiceConfig.Instance.RolesMap.Flags )
				{
					// Если рассматриваемый флаг - не тот, что задан - пропускаем:
					if ( nFlag != (Flags & nFlag) )
						continue;
					
					// Получаем опистель ссылки
					UserFlagToRoleLink link = ServiceConfig.Instance.RolesMap[nFlag];
					// Проверяем, что это не "зачищающий" - если так, то запоминаем это 
					// и выходим из цикла - далее анализировать флаги не имеет смысла
					if ( (bIsClearRoles = link.IsClearRolesFlag) )
						break;
					
					// Если ссылка указыает какую-то роль - добаляем соотв. объектную ссылку
					// в свойство объекта (при этом в описателе ссылки используем св-во 
					// RoleObject - при первом доступе это дело зачитает реальные данные 
					// с сервера приложения)
					if (Guid.Empty != link.RoleID)
						helperSystemUser.AddArrayPropRef( "SystemRoles", link.RoleObject.TypeName, link.RoleObject.ObjectID ) ;
				}
				if ( bIsClearRoles )
					helperSystemUser.ClearArrayProp( "SystemRoles" );
				
				// #4: Системные привилегии:
				// ... если сотрудник уволен (есть флаг "Архивный") - СБРАСЫВАЮТСЯ:
				if ( bHasArchivedFlag )
					helperSystemUser.SetPropValue( "SystemPrivileges", XPropType.vt_i4, 0 );
				// ... если сотрудник работает - НЕ ИЗМЕНЯЮТСЯ (выбросим из 
				// датаграммы поле, чтобы его не перезаписать):
				else
					helperSystemUser.DropPropertiesXml( "SystemPrivileges" );
			}

			
			// -- Для Employee:
			helperEmployee.SetPropValue( "LastName", XPropType.vt_string, LastName );
			helperEmployee.SetPropValue( "FirstName", XPropType.vt_string, FirstName );
			helperEmployee.SetPropValue( "MiddleName", XPropType.vt_string, MiddleName );
			
			// Дата начала работы с момента задания более не изменяется; соотв., 
			// helperEmployee.SetPropValue( "WorkBeginDate", ... ) НЕ ВЫПОЛНЯЕМ; 
			// Но - флагом (параметр Flags) может быть указано, что сотрудник
			// (пользователь) является АРХИВНЫМ. В ITv6 факт "архивности" задается 
			// датой завершения работы, WorkEndDate. 
			if ( bHasArchivedFlag ) 
			{
				// Если этот параметр ЕЩЕ НЕ ЗАДАВАЛСЯ, и при этом флаг "архивный" 
				// задан, то установим дату завершения работы; при этом используем 
				// текущую дату:
				if ( 0 == helperEmployee.PropertyXml("WorkEndDate").InnerText.Length )
					helperEmployee.SetPropValue( "WorkEndDate", XPropType.vt_date, DateTime.Today );
				else
					// иначе - если дата уже была задана - сбросим свойство вообще, 
					// что бы не перезаписать его ненароком в БД:
					helperEmployee.DropPropertiesXml( "WorkEndDate" );
			}
			else
			{
				// ФЛАГ "АРХИВНЫЙ" СБРОШЕН: 
				// сбросим в IT6 дату увольнения - так в системе оражается 
				// отсутствие признака "архивный":
				helperEmployee.PropertyXml("WorkEndDate").InnerText = String.Empty;
			}
			
			helperEmployee.SetPropValue( "Phone", XPropType.vt_string, Phone );
			helperEmployee.SetPropValue( "PhoneExt", XPropType.vt_string, PhoneExt );
			helperEmployee.SetPropValue( "MobilePhone", XPropType.vt_string, MobilePhone );
			helperEmployee.SetPropValue( "Address", XPropType.vt_string, Address );
			helperEmployee.SetPropValue( "EMail", XPropType.vt_string, eMail );
			// данные картинки фотографии сотрудника - если не заданы, то
			// метод конвертации вернет пустую строку, которая при записи будет
			// интерпретирована Storage-ем как NULL - данные в БД будут сброшены
			helperEmployee.PropertyXml("Picture").RemoveAll();
			helperEmployee.PropertyXml("Picture").InnerText = ObjectOperationHelper.ConvertBinHexToBinBase64( Picture );

			// NB: Все исходные флаги как они есть сохраним в ExternalID - что бы 
			// потом вернуть их в первозданном виде обратно, при запросе из НСИ
			// (см. реализацию GetUsers и SQL-операцию в описании источника данных 
			// SyncNSI-GetList-Employees:
			helperEmployee.SetPropValue( "ExternalID", XPropType.vt_string, Flags.ToString() );

			
			// ОБНОВЛЕНИЕ ОБЪЕКТНЫХ ссылок на подразделение, организацию, должность

			// -- ССЫЛКА НА ПОДРАЗДЕЛЕНИЕ; Здесь следующая сложность: 
			// это может быть действительно подразделение, а может быть и 
			// организация - т.к. в НСИ (вслед за ITv5) для указания ссылки на 
			// организацию данные последней так же вводятся как подразделение
			// (sic!) корневого уровня.
			// 
			// Для загрузки данных этого объекта используем специальный 
			// внутренний метод, который сначала определяет что именно 
			// используется в данном случае. Реальный тип объекта будет в 
			// helperDepartment.TypeName:
			if ( 0==OrgUnit )
				throw new ArgumentException("Идентификатор подразделения / организации не задан", "OrgUnit");
			ObjectOperationHelper helperDepartment = findPseudoDepartmentRef( OrgUnit );

			// -- ССЫЛКА НА ДОЛЖНОСТЬ (может не задаваться)
			// Сами данные указанной должности нам не нужны - нужен только 
			// реальный идентификатор объекта:
			ObjectOperationHelper helperPosition = ObjectOperationHelper.GetInstance( "Position" );
			// идентифицируем объект "внешним" идентификатором - если он, конечно, задан:
			if ( 0!=SystemUserPosition )
			{
				keyPropCollection.Clear();
				keyPropCollection.Add( "ExternalRefID", Int32.Parse(SystemUserPosition.ToString()) );
				helperPosition.GetObjectIdByExtProp( keyPropCollection );
			}

			// Определим ссылки на организацию и подразделение (если последняя задана):
			// Если указанное "поразделение" - это действительно подразделение, 
			// то из его данных (загруженных в helperDepartment) скопируем во 
			// вновь создаваемый объект ссылку на организацию; если же это и 
			// была организация - то в этом случае ссылку на подразделение
			// сбрасываем - удаляем данные свойства, т.о. в БД будет записано NULL
			if ( "Department" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Department", "Department", helperDepartment.ObjectID );
				// копирование ссылки на организацию:
				XmlElement xmlPropOrgRef = helperEmployee.PropertyXml( "Organization" );
				xmlPropOrgRef.RemoveAll();
				xmlPropOrgRef.InnerXml = helperDepartment.PropertyXml("Organization").InnerXml;
			}
			else if ( "Organization" == helperDepartment.TypeName )
			{
				helperEmployee.SetPropScalarRef( "Organization", "Organization", helperDepartment.ObjectID );
				// Удаляем данные ссылки на подразделение
				helperEmployee.PropertyXml( "Department" ).RemoveAll();
			}
			else
				throw new ApplicationException("Неизвестный тип объекта - " + helperDepartment.TypeName);
			
			// Ссылка на должность (если такая задана)
			if ( Guid.Empty != helperPosition.ObjectID )
				helperEmployee.SetPropScalarRef( "Position", "Position", helperPosition.ObjectID );
			else
				// В противном случае удаляем данные свойства - в БД будет записано NULL
				helperEmployee.PropertyXml("Position").RemoveAll();


			// Сбросим реквизиты, данные которых не должны записываться в БД:
			helperEmployee.DropPropertiesXml( "WorkBeginDate", "ExternalRefID", "TemporaryDisability" );

			
			// ЗАПИСЫВАЕМ ДАННЫЕ ОБОИХ ОБЪЕКТОВ одновременно, в рамках одной 
			// "сложной" датаграммы; Это необходимо для обеспечения ссылочной
			// целостности, заданной м/у объектами. 
			// Если при этом для сотрудника в НСИ задан флаг "не получает никаких
			// сообщении", то в IT6 для этого выполняем принудительную "отписку"
			// сотрудника ото всех сообщений; эта логика реализована в специальной
			// хранимой процедуре, которая будет вызвана сразу после записи данных
			// сотрудника, в той же транзакции БД (т.н. post-call процедура)
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
        #region Методы, используемые для синхронизации справочника "Должности"

        /// <summary>
        /// Возвращает список всех записей справочника "Должности", 
        /// представленного в системе Incident Tracker
        /// </summary>
        /// <returns></returns>
        [WebMethod(Description = @"Возвращает список всех записей справочника ""Должности"", представленного в системе Incident Tracker")]
        public XmlDocument GetUserPosition()
        {
            // Возврaщает данные в виде XML-документа следующего формата (в примере
            // приведен случай отображения данных только для одной отрасли; регистр
            // символов имеет значение):
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
        /// Добавляет новое описание должности в справочник "Должности", 
        /// представленный в системе Incident Tracker
        /// </summary>
        /// <param name="Name">Название должности</param>
        /// <param name="Flags">Флаги</param>
        /// <param name="ObjectGUID">GUID должности</param>
        /// <returns>Идентификатор добавленной записи</returns>
        /// <remarks>
        /// ВНИМАНИЕ: Значение параметра Flags здесь игнорируется - 
        /// в системе Incident Tracker версии 6 соответствующих полей НЕТ
        /// </remarks>
        [WebMethod(Description = @"Добавляет новое описание должности в справочник ""Должности"", представленный в системе Incident Tracker")]
        public int InsertPositionITracker(string Name, int Flags, out string ObjectGUID)
        {
            // Создаем вспомогательный объект; в процессе выполняется
            // получение датаграммы нового объекта типа "Отрасль"
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Position");
            helper.LoadObject();

            // Устанавливаем необходимые значения свойств нового объекта,
            // запоминаем внутренний идентификатор (здесь он - ObjectGUID):
            // ВНИМАНИЕ: Значение параметра Flags здесь игнорируется - 
            // в системе Incident Tracker версии 6 соответствующих полей НЕТ
            helper.SetPropValue("Name", XPropType.vt_string, Name);
            // ... и записываем данные объекта
            helper.SaveObject();
            ObjectGUID = helper.ObjectID.ToString();

            // Перезагрузим объект еще раз - уже как существующий в БД
            helper.LoadObject();
            // ... для того, что бы получить "внешний" идентификатор:
            return (int)helper.GetPropValue("ExternalRefID", XPropType.vt_i4);
        }


        /// <summary>
        /// Обновляет описание должности в справочнике "Должности", 
        /// представленном в системе Incident Tracker
        /// </summary>
        /// <param name="ObjectID">Идентификатор обновляемой записи</param>
        /// <param name="Name">Название должности</param>
        /// <param name="Flags">Флаги</param>
        /// <remarks>
        /// ВНИМАНИЕ: Значение параметра Flags здесь игнорируется - 
        /// в системе Incident Tracker версии 6 соответствующих полей НЕТ
        /// </remarks>
        [WebMethod(Description = @"Обновляет описание должности в справочнике ""Должности"", представленном в системе Incident Tracker")]
        public void UpdatePositionITracker(int ObjectID, string Name, int Flags)
        {
            // Создаем вспомогательный объект; в процессе выполняется
            // получение датаграммы указанного объекта типа "Отрасль"
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Position");

            XParamsCollection keyPropCollection = new XParamsCollection();
            keyPropCollection.Add("ExternalRefID", Int32.Parse(ObjectID.ToString()));
            helper.LoadObject(keyPropCollection);

            // Устанавливаем необходимые значения свойств объекта:
            // ВНИМАНИЕ: Значение параметра Flags здесь игнорируется - 
            // в системе Incident Tracker версии 6 соответствующих полей НЕТ
            helper.SetPropValue("Name", XPropType.vt_string, Name);

            // Убираем из датаграммы все данные свойств, за исключением Name
            // - эти свойства обновляться не должны:
            helper.DropPropertiesXmlExcept("Name");

            // записываем обновленные данные объекта
            helper.SaveObject();
        }


        #endregion


        #region Методы, используемые для синхронизации справочника "Организации"
		
		/// <summary>
		/// Возвращает список всех записей справочника "Организации", 
		/// представленного в системе Incident Tracker
		/// </summary>
		/// <returns>
		/// Список всех организаций из ITracker в виде XML документа
		/// </returns>
		[WebMethod (Description=@"Возвращает список всех записей справочника ""Организации"", представленного в системе Incident Tracker")]
		public XmlDocument GetOrganizations() 
		{
			// Возврaщает данные в виде XML-документа следующего формата (в примере
			// приведен случай отображения данных только для одной организации; 
			// регистр символов имеет значение):
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
		/// Возвращает описание указанной организации, представленной в 
		/// справочнике "Организации" системы Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">id организации</param>
		/// <returns>Организация из базы ITracker в виде XML документа</returns>
		[WebMethod (Description=@"Возвращает описание указанной организации, представленной в справочнике ""Организации"" системы Incident Tracker")]
		public XmlDocument GetOrganization( Guid ObjectGUID ) 
		{
			// Используя вспомогательный объект, загрузим данные указанной организации
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// Формируем рузельтирующеи данные в виде XML-документа следующего формата 
			// (регистр символов имеет значение):
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
			
			// Записываем данные, представленные в датаграмме, в результирующий XML;
			// ...сначала все необъектные свойства:
			xmlRoot.SetAttribute( "ObjectGUID", helper.ObjectID.ToString()	);
			xmlRoot.SetAttribute( "Type", "1" ); // NB! Пока - всегда константа

			if (helper.PropertyXml("Name").InnerText.Length > 0)
				xmlRoot.SetAttribute( "sName", helper.GetPropValue("Name",XPropType.vt_string).ToString() );
			if (helper.PropertyXml("ShortName").InnerText.Length > 0)
				xmlRoot.SetAttribute( "ShortName", helper.GetPropValue("ShortName",XPropType.vt_string).ToString() );
			if (helper.PropertyXml("ExternalID").InnerText.Length > 0)
				xmlRoot.SetAttribute( "NavisionID", helper.GetPropValue("ExternalID",XPropType.vt_string).ToString() );

			// ...теперь - объектные ссылки:
			XmlElement xmlRefElement = (XmlElement)(helper.PropertyXml("Parent").SelectSingleNode("Organization"));
			if ( null != xmlRefElement )
				xmlRoot.SetAttribute( "Parent", xmlRefElement.GetAttribute("oid") );

			xmlRefElement = (XmlElement)(helper.PropertyXml("Director").SelectSingleNode("Employee"));
			if ( null != xmlRefElement )
				xmlRoot.SetAttribute( "AccChiefGUID", xmlRefElement.GetAttribute("oid") );

			// Возвращаем результат:
			return xmlResult;
		}

		
		/// <summary>
		/// Добавляет новое описание организации в справочник "Организации", 
		/// представленный в системе Incident Tracker
		/// </summary>
		/// <param name="Name">Название</param>
		/// <param name="Type">Тип</param>
		/// <param name="ShortName">Короткое наименование</param>
		/// <param name="NavisionID">Идентификатор в Navision</param>
		/// <param name="AccChief">Идентификатор сотрудника - директора клиента</param>
		/// <param name="ObjectGUID">ID созданной организации</param>
		[WebMethod (Description = @"Добавляет новое описание организации в справочник ""Организации"", представленный в системе Incident Tracker")]
		public void CreateOrganization(
			string Name, 
			int Type, 
			string ShortName, 
			string NavisionID, 
			Guid AccChief, 
			out Guid ObjectGUID ) 
		{
			ObjectGUID = Guid.Empty;
			
			// Используя вспомогательный объект, получим шаблон датаграммы нового объекта:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			helper.LoadObject();

			// Установим значения свойств; сначала - необъектных:
			// (при этом - ПОКА - игнорируем значение параметра Type)
			helper.SetPropValue( "Name", XPropType.vt_string, Name );
			helper.SetPropValue( "ShortName", XPropType.vt_string, ShortName );
			helper.SetPropValue( "ExternalID", XPropType.vt_string, NavisionID );
			// Если задан идентификатор сотрудника - директора клиента, то установим 
			// соответствующую объектную ссылку:
			if (Guid.Empty!=AccChief)
				helper.SetPropScalarRef( "Director", "Employee", AccChief );

			// Уберем из датаграммы поля, которые не должны записываться:
			helper.DropPropertiesXml( 
				"Home",
				"Comment",
				"ExternalRefID" );

			// Выполняем запись данных:
			helper.SaveObject();

			// Если дошли до этой точки - то это значит, что данные успешно записались
			// Вернем "наружу" номальный идентификатор созданного объекта:
			ObjectGUID = helper.ObjectID;
		}


		/// <summary>
		/// Обновляет описание организации в справочнике "Организации", 
		/// представленном в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">ID организации</param>
		/// <param name="Name">Название</param>
		/// <param name="Type">Тип</param>
		/// <param name="ShortName">Короткое наименование</param>
		/// <param name="NavisionID">Идентификатор в Navision</param>
		/// <param name="AccChief">Идентификатор сотрудника - директора клиента</param>
		[WebMethod (Description=@"Обновляет описание организации в справочнике ""Организации"", представленном в системе Incident Tracker")]
		public void UpdateOrganization(
			Guid ObjectGUID, 
			string Name, 
			int Type, 
			string ShortName, 
			string NavisionID, 
			Guid AccChief ) 
		{
			// Используя вспомогательный объект, загрузим данные указанного объекта:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// Обновляем данные необъектных скалярных свойств
			// (при этом - ПОКА - игнорируем значение параметра Type)
			helper.SetPropValue( "Name", XPropType.vt_string, Name );
			helper.SetPropValue( "ShortName", XPropType.vt_string, ShortName );
			helper.SetPropValue( "ExternalID", XPropType.vt_string, NavisionID );

			// Если идентификатор сотрудника - директора клиента не задан, сбросим
			// ДАННЫЕ свойства Director: при записи Storage очистит ссылку:
			if (Guid.Empty == AccChief)
				helper.PropertyXml("Director").RemoveAll();
			else
			{
				// Анализируем данные заглушки:
				XmlElement xmlRefProp = (XmlElement)helper.PropertyXml("Director").SelectSingleNode("Employee");

				// Данных о сотруднике нет вообще - значит ссылку создаем:
				if (null==xmlRefProp)
					helper.SetPropScalarRef( "Director", "Employee", AccChief );
				else
				{
					// Проверим - возможно, идентификатор сотрудника и не изменился:
					if ( AccChief.ToString().ToUpper() != xmlRefProp.GetAttribute("oid").ToUpper() )
						// изменился: перезапишем данные ссылки
						helper.SetPropScalarRef( "Director", "Employee", AccChief );
					else
						// не изменился: сбросим свойство вообще - Storage ничего обновлять не будет
						helper.DropPropertiesXml( "Director" );
				}
			}

			// Уберем из датаграммы поля, которые не должны записываться:
			helper.DropPropertiesXml( 
				"Comment", 
				"Home", 
				"OwnTenderParticipant",
				"Parent", 
				"Children",
				"ExternalRefID",
				"RefCodeNSI"
			);
			// Выполняем запись данных:
			helper.SaveObject();
		}
		

		/// <summary>
		/// Изменяет определение вышестоящей организации, для указанной 
		/// организации из справочника "Организации", представленного 
		/// в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">ID организации</param>
		/// <param name="ParentObjectGUID">ID родительской организации</param>
		[WebMethod (Description=@"Изменяет определение вышестоящей организации, для указанной организации из справочника ""Организации"", представленного в системе Incident Tracker")]
		public void UpdateOrganizationParent( Guid ObjectGUID, Guid ParentObjectGUID ) 
		{
			// Используя вспомогательный объект, загрузим данные указанного объекта:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.LoadObject();

			// Если идентификатор вышестоящей организации не задан, сбросим
			// ДАННЫЕ свойства Parent: при записи Storage очистит ссылку:
			if (Guid.Empty == ParentObjectGUID)
				helper.PropertyXml("Parent").RemoveAll();
			else
			{
				// Анализируем данные заглушки:
				XmlElement xmlRefProp = (XmlElement)helper.PropertyXml("Parent").SelectSingleNode("Organization");
				// Данных о вышестоящей организации нет вообще - создаем ссылку:
				if (null==xmlRefProp)
					helper.SetPropScalarRef( "Parent", "Organization", ParentObjectGUID );
				else
				{
					// Проверим - возможно, идентификатор вышестоящей организации и не изменился:
					if ( ParentObjectGUID.ToString().ToUpper() != xmlRefProp.GetAttribute("oid").ToUpper() )
						// изменился: перезапишем данные ссылки
						helper.SetPropScalarRef( "Parent", "Organization", ParentObjectGUID );
					else
						// не изменился: сбросим свойство вообще - Storage ничего обновлять не будет
						helper.DropPropertiesXml( "Parent" );
				}
			}

			// Уберем из датаграммы все поля, за исключением Parent - все эти 
			// данные не должны обновляться:
			helper.DropPropertiesXmlExcept( "Parent" );
			// Выполняем запись данных:
			helper.SaveObject();
		}


		/// <summary>
		/// Удаляет указанное описание организации из справочника "Организации", 
		/// представленного в системе Incident Tracker
		/// </summary>
		/// <param name="ObjectGUID">id организации</param>
		[WebMethod (Description=@"Удаляет указанное описание организации из справочника ""Организации"", представленного в системе Incident Tracker")]
		public void DeleteOrganization( Guid ObjectGUID ) 
		{
			// Используя вспомогательный объект, удалим данные указанного объекта:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization", ObjectGUID );
			helper.DeleteObject();
		}
        #endregion 

	
		#region Методы получения данных для формы бизнес-процесса "Заказ денежных средств"
		// Временные методы, до реализации аналогичных функций в НСИ
		// Комментарии и вопросы по постановке - к Волкову Дмитрию, Савенкову Вадиму
		
		#endregion

        #region Методы, используемые для синхронизации справочника "Отрасли" (Система Учета Тендеров)

        /// <summary>
        /// Возвращает список всех записей справочника "Отрасли", 
        /// представленного в Системе Учета Тендеров
        /// </summary>
        /// <returns>Список всех отраслей из базы Тендерной системы в виде XML документа</returns>
        [WebMethod(Description = @"Возвращает список всех записей справочника ""Отрасли"", представленного в Системе Учета Тендеров")]
        public XmlDocument GetBranches()
        {
            // Возврaщает данные в виде XML-документа следующего формата (в примере
            // приведен случай отображения данных только для одной отрасли; регистр
            // символов имеет значение):
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