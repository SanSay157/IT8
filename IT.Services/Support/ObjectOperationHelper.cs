//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Globalization;
using System.Xml;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Класс, реализующий вспомогательную логику выполнения "стандартных" 
	/// операций сервера приложения - чтения (GetObject), записи изменений и 
	/// новых объектов (SaveObject), удаления (DeleteObject), а так же 
	/// операции выполнения "источников данных" (ExecuteDataSource)
	/// 
	/// Класс так же реализует вспомогательную логику формирования, анализа 
	/// и изменения данных датаграммы ds-объекта - XML-документа представления
	/// данных ds-объектов на клиентской стороне, используемого в операциях 
	/// получения и записи данных
	/// </summary>
	public class ObjectOperationHelper 
	{
		/// <summary>
		/// Константный текст с описанием ошибки инициализации интерфейса доступа к серверу приложения
		/// </summary>
		private static readonly string ERR_INVALID_APPSERVERFACADE = "Интерфейс доступа к серверу приложения не инициализирован!";
		/// <summary>
		/// Константный текст с описанием ошибки выполнения операции
		/// </summary>
		private static readonly string ERRFMT_INVALID_NULL_OPERATION_RESULT = "Ошибка выполнения операции {0} сервера приложения: в качестве результата получен null";
		/// <summary>
		/// Константный текст с описанием ошибки отсутствия данных
		/// </summary>
		private static readonly string ERRFMT_INVALID_DATA_NOTLOAD = "Данные объекта {0} не загружены";
		
		#region Внутренние переменные и методы класса
		
		/// <summary>
		/// Ссылка на Фасад сервера приложений - реализацию интерфейса IXFacade.
		/// Ссылка должна быть инициализированна ДО создания экземпляра объекта
		/// или вызова какого-либо статического метода класса
		/// <seealso cref="IXFacade"/>
		/// </summary>
		private static IXFacade m_appServerFacade = null;
		
		/// <summary>
		/// Признак, отражающий тот факт, что объект, обслуживаемый helper-ом,
		/// есть новый объект (в датаграмме есть атрибут new="1")
		/// </summary>
		private bool m_bIsNewObject;
		/// <summary>
		/// Наименование ds-типа объекта, данные которого обслуживаются helper-ом
		/// </summary>
		private string m_sTypeName;
		/// <summary>
		/// Идентификатор ds-объекта, данные которого обслуживаются helper-ом
		/// </summary>
		private Guid m_uidObjectID;
		/// <summary>
		/// XML-данные (датаграмма) ds-объекта, обслуживаемого helper-ом
		/// </summary>
		private XmlElement m_xmlDatagram;

		/// <summary>
		/// Внутренний конструктор объекта
		/// ЗАКРЫТ, т.к. для конструирования (а) используются "фабричные" методы
		/// (б) потому что сначала надо инициализировать интерфейс к серверу 
		/// приложения и здесь выполняется отдельная проверка его наличия
		/// </summary>
		private ObjectOperationHelper() 
		{
			if (null==m_appServerFacade)
				throw new InvalidOperationException( ERR_INVALID_APPSERVERFACADE );

			m_bIsNewObject = true;
			m_sTypeName = null;
			m_uidObjectID = Guid.NewGuid();
			m_xmlDatagram = null;
		}

		
		#endregion

		/// <summary>
		/// Ссылка на интерфейс доступа к серверу приложения
		/// ВНИМАНИЕ! ДАННОЕ СВОЙСТВО ДОЛЖНО БЫТЬ ИНИЦИАЛИЗИРОВАННО ПЕРЕД ВЫЗОВОМ
		/// ЛЮБОГО ФАБРИЧНОГО ИЛИ ИНОГО СТАТИЧЕСКОГО МЕТОДА КЛАССА!
		/// </summary>
		/// <exception cref="InvalidOperationException">
		/// Если при чтении значения свойства оно есть null;
		/// </exception>
		/// <exception cref="ArgumentNullException">
		/// Если в качестве значения свойства устанавливается null;
		/// </exception>
		public static IXFacade AppServerFacade 
		{
			get 
			{
				if (null==m_appServerFacade)
					throw new InvalidOperationException( ERR_INVALID_APPSERVERFACADE );
				return m_appServerFacade;
			}
			set
			{
				if (null==value)
					throw new ArgumentNullException( ERR_INVALID_APPSERVERFACADE, "AppServerFacade");
				m_appServerFacade = value;
			}
		}


		#region Фабричные методы получения экземпляра объекта ObjectOperationHelper 

		/// <summary>
		/// "Фабричный" метод получения экземпляра класса 
		/// </summary>
		/// <returns>
		/// Экземпляр класса, для которого значения свойств "Наименование типа" и 
		/// "Идентификатор объекта" (TypeName и ObjectID) не инциализированны
		/// </returns>
		public static ObjectOperationHelper GetInstance() 
		{
			return new ObjectOperationHelper();
		}

		
		/// <summary>
		/// "Фабричный" метод получения экземпляра класса 
		/// Задает наименование типа ds-объекта
		/// </summary>
		/// <param name="sTypeName">Наименование ds-типа</param>
		/// <returns>
		/// Экземпляр класса, для которого значения свойства "Наименование типа"
		/// (TypeName) задано в соотв. с переданным параметром; Значение свойства
		/// "Идентификатор объекта" (ObjectID) не инциализированно
		/// </returns>
		public static ObjectOperationHelper GetInstance( string sTypeName ) 
		{
			ObjectOperationHelper helper = new ObjectOperationHelper();
			helper.TypeName = sTypeName;
			helper.ObjectID = Guid.Empty;
			return helper;
		}


		/// <summary>
		/// "Фабричный" метод получения экземпляра класса 
		/// Задает наименование типа и идентификатор ds-объекта
		/// </summary>
		/// <param name="sTypeName">Наименование ds-типа</param>
		/// <param name="uidObjectID">Идентификатор ds-объекта</param>
		/// <returns>
		/// Экземпляр класса, для которого значения свойств "Наименование типа"
		/// (TypeName) и "Идентификатор объекта" (ObjectID) инциализированно в
		/// соответствии с переданными параметрами.
		/// Если в качестве идентификатора объекта передан Guid.Empty, свойство
		/// IsNew устанавливается в значение true;
		/// </returns>
		public static ObjectOperationHelper GetInstance( string sTypeName, Guid uidObjectID ) 
		{
			ObjectOperationHelper helper = new ObjectOperationHelper();
			helper.TypeName = sTypeName;
			helper.ObjectID = uidObjectID;
			return helper;
		}

		
		/// <summary>
		/// Метод получения "копии" исходного вспомогательного объекта, которую 
		/// можно редактировать независимо; для новой копии может быть проставлен
		/// новый идентификатор, в этом случае данные описания объекта отмечаются 
		/// как "новые" (соответственно, свойство ObjectID возвращает Guid.Empty,
		/// а новый ID можно получить как значение свойства NewlySetObjectID)
		/// </summary>
		/// <param name="helperSrc">Исходный, "клонируемый" описатель</param>
		/// <param name="bKeepObjectID">Признак сохранения исходного идентификатора объекта</param>
		/// <returns>Описатель, "раздельная" копия</returns>
		public static ObjectOperationHelper CloneFrom( ObjectOperationHelper helperSrc, bool bKeepObjectID ) 
		{
			ObjectOperationHelper helperClone = new ObjectOperationHelper();
			
			// Переносим данные исходного описания:
			helperClone.m_sTypeName = helperSrc.m_sTypeName;
			helperClone.m_uidObjectID = helperSrc.m_uidObjectID;
			helperClone.m_bIsNewObject = helperSrc.m_bIsNewObject;
			// датаграмму клонируем полностью (если она, конечно, есть):
			if (null!=helperSrc.m_xmlDatagram)
				helperClone.m_xmlDatagram = (XmlElement)helperSrc.m_xmlDatagram.CloneNode(true);
			else
				helperClone.m_xmlDatagram = null;
			
			// Далее все зависит от флага bKeepObjectID: если идентификатор 
			// НЕ сохраняем, то принудительно помечаем объект как "новый", 
			// но при этом сохраняем XML-данные объекта (и в этих данных, 
			// соответственно, проставляем new="1"):
			if (!bKeepObjectID)
			{
				// Признак "новый" надо изменить СНАЧАЛА (т.к. на него завязаны
				// проверки в свойстве NewlySetObjectID):
				helperClone.m_bIsNewObject = true;
				helperClone.NewlySetObjectID = Guid.Empty; // ...там сгенерируется новый
				helperClone.m_xmlDatagram.SetAttribute( "new","1" );
			}
			
			// вот и получили клона:
			return helperClone;
		}
		
		
		#endregion 

		#region Публичные свойства - описание характеристик и данных обслуживаемого ds-объекта
		
		/// <summary>
		/// Наименование типа ds-объекта, обслуживаемого объектом-helper-ом.
		/// Задаваемое значение не можеть быть пустой строкой или null-значением
		/// </summary>
		public string TypeName 
		{
			get { return m_sTypeName; }
			set
			{
				ValidateRequiredArgument( value, "TypeName" );
				// Если заданный тип отличается от уже существующего, то датаграмма, 
				// если таковая была загружена, уже некорректна, т.к. описывает
				// объект другого типа; сбросим ее:
				if (value!=m_sTypeName && IsLoaded)
					m_xmlDatagram = null;
				m_sTypeName = value;
			}
		}

		
		/// <summary>
		/// Идентификатор ds-объекта, обслуживаемого объектом-helper-ом.
		/// </summary>
		/// <remarks>
		/// Если в качестве значения свойства задается Guid.Empty, то значение
		/// свойства IsNew устанавливается в true; если датаграмма объекта 
		/// загружена (значение свойства Datagram != null), то для атрибута
		/// oid корневого элемента датаграммы автоматически генерируется новое 
		/// значение, а так же задает атрибут new="1"
		/// </remarks>
		public Guid ObjectID 
		{
			get { return (m_bIsNewObject? Guid.Empty : m_uidObjectID); }
			set 
			{
				if (value!=m_uidObjectID && IsLoaded)
					m_xmlDatagram = null;
				
				m_bIsNewObject = (Guid.Empty == value);
				m_uidObjectID = (Guid.Empty == value? Guid.NewGuid() : value);
			}
		}

		
		/// <summary>
		/// Идентификатор НОВОГО объекта
		/// </summary>
		public Guid NewlySetObjectID 
		{
			get { return m_uidObjectID; }
			set 
			{
				if (!m_bIsNewObject)
					throw new ArgumentException( "Идентификатор нового экземпляра не может быть задан для уже существующего объекта!","NewObjectID" );
			
				m_uidObjectID = (value==Guid.Empty? Guid.NewGuid() : value);

				// Если датаграмма уже есть (для нового объекта, см. проверку выше), 
				// то скорректируем указание идентификатора объекта в датаграмме:
				if (null!=m_xmlDatagram)
					m_xmlDatagram.SetAttribute( "oid", m_uidObjectID.ToString() );
			}
		}
		
		/// <summary>
		/// Признак того, что helper-объект обслуживает данные нового ds-объекта
		/// Свойство только для чтения 
		/// </summary>
		public bool IsNewObject 
		{
			get { return m_bIsNewObject; }
			set
			{
				if (IsLoaded && value!=m_bIsNewObject)
					m_xmlDatagram = null;
				m_bIsNewObject = value;
			}
		}


		/// <summary>
		/// Признак того, что данные ds-объекта загружены в helper-объект
		/// </summary>
		public bool IsLoaded 
		{
			get { return (null!=m_xmlDatagram); }
		}

		
		/// <summary>
		/// Данные ds-объекта, загруженного в helper-объект
		/// Могут быть сброшены установкой свойства в null - ЭТО ДЕЙСТВИЕ НЕ 
		/// ПРИВОДИТ К ВЫЗОВУ КАКОЙ-ЛИБО ОПЕРАЦИИ СЕРВЕРА!
		/// </summary>
		public XmlElement Datagram 
		{
			get { return m_xmlDatagram; }
		}


		#endregion
		
		#region Методы работы с загруженными данным датаграмм обслуживаемых ds-объектов
		
		/// <summary>
		/// Сбрасывает данные, представленные helper-объектом; никаких явных 
		/// операций с сервером приложения (запись / удаление) НЕ ВЫПОЛНЯЕТСЯ
		/// </summary>
		public void Clear() 
		{
			m_bIsNewObject = true;
			m_sTypeName = null;
			m_uidObjectID = Guid.NewGuid();
			m_xmlDatagram = null;
		}
		
		
		/// <summary>
		/// Получение XML-элемента датаграммы с данными указанного свойства 
		/// ds-объекта, обслуживаемого helper-объектом
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <returns>XML-элемент, описывающий данные указанного свойства</returns>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		public XmlElement PropertyXml( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			XmlElement xmlProp = (XmlElement)Datagram.SelectSingleNode( sPropName );
			if (null==xmlProp)
				throw new ArgumentException( String.Format( 
					"Указанное свойство {0} не представлено в объекте {1} (oid:{2})",
					sPropName, TypeName, ObjectID.ToString().ToUpper()) 
				);

			return xmlProp;
		}

		
		/// <summary>
		/// Прогружает данные скалярного необъектного свойства ds-объекта, 
		/// содержащего бинарные данные (LOB/BLOB). Загруженные данные будут
		/// представлены в датаграмме объекта; доступ к ним может быть получен
		/// через метод <see cref="PropertyXml"/>
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		public void UploadBinaryProp( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// Проверим, что свойсво действительно типа bin.base64,
			XmlElement xmlBinaryProp = PropertyXml( sPropName );
			string sXmlTypeName = xmlBinaryProp.GetAttribute("dt:dt"); 
			if ( "bin.base64"!=sXmlTypeName && "text"!=sXmlTypeName && "string"!=sXmlTypeName )
				throw new ArgumentException("Не тот тип свойства");
			// Если свойство уже прогружено - просто выходим
			if ( "0" != xmlBinaryProp.GetAttribute("loaded") )
				return;

			// Форимруем запрос:
			XGetPropertyRequest request = new XGetPropertyRequest( TypeName, ObjectID, sPropName );
			XGetPropertyResponse response = (XGetPropertyResponse)AppServerFacade.ExecCommand( request );

			xmlBinaryProp.RemoveAll();
			xmlBinaryProp.InnerXml = response.XmlProperty.InnerXml;
		}

		
		/// <summary>
		/// Получение типизированного значения указанного скалярного необъектного 
		/// свойства ds-объекта; данные получаются из датаграммы, обслуживаемой
		/// данным экземпляром helper-а
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="vtPropType">Тип получаемого значения</param>
		/// <returns>Значение свойства</returns>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public object GetPropValue( string sPropName, XPropType vtPropType ) 
		{
			return XmlPropValueReader.GetTypedValueFromXml( PropertyXml(sPropName), vtPropType );
		}

		/// <summary>
		/// Получение типизированного значения указанного скалярного необъектного 
		/// свойства ds-объекта; данные получаются из датаграммы, обслуживаемой
		/// данным экземпляром helper-а
		/// ПЕРЕГРУЖЕННЫЙ МЕТОД
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="vtPropType">Тип получаемого значения</param>
		/// <param name="bMustExists">Флаг строгой проверки наличия свойства</param>
		/// <returns></returns>
		public object GetPropValue( string sPropName, XPropType vtPropType, bool bMustExists )
		{
			XmlElement xmlData = PropertyXml(sPropName);
			// Проверяем наличие каких-либо данных:
			if (String.Empty != xmlData.InnerText)
				return XmlPropValueReader.GetTypedValueFromXml( PropertyXml(sPropName), vtPropType );
			else
			{
				if (bMustExists)
					throw new ArgumentException( String.Format( 
						"Указанное свойство {0} объекта {1} (oid:{2}) не содержит данных (null)",
						sPropName, TypeName, ObjectID.ToString().ToUpper() ) 
					);
				else
					return null;
			}
		}

		
		/// <summary>
		/// Установка типизированного значения для указанного скалярного 
		/// необъектного свойства ds-объекта; данные записываются в датаграмму,
		/// обслуживаемую данным экземпляром helper-а
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="vtPropType">Тип устанавливаемого значения</param>
		/// <param name="oValue">Устанавливаемое значение</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public void SetPropValue( string sPropName, XPropType vtPropType, object oValue ) 
		{
			PropertyXml(sPropName).InnerText = XmlPropValueWriter.GetXmlTypedValue( oValue, vtPropType );
		}

		
		/// <summary>
		/// Установка скалярной объектной ссылки для указанного свойства 
		/// ds-объекта; данные записываются в датаграмму, обслуживаемую данным
		/// экземпляром helper-а
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="sRefTypeName">Наименование ds-типа по ссылке</param>
		/// <param name="oRefObjectID">Идентификатор ds-объекта по ссылке</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public void SetPropScalarRef( string sPropName, string sRefTypeName, Guid oRefObjectID ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "Не задан идентификатор объекта по ссылке (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// Этап #1: Формируем данные заглушки заданного объекта по ссылке:
			XmlElement xmlProxy = Datagram.OwnerDocument.CreateElement( sRefTypeName );
			xmlProxy.SetAttribute( "oid", oRefObjectID.ToString() );

			// Этап #2: Записываем заглушку как данные указанного свойства:
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			// удаляем все вложенные узлы
			xmlRefProperty.RemoveAll();
			xmlRefProperty.AppendChild( xmlProxy );
		}
		

		/// <summary>
		/// Прогружает данные массивного объектного свойства ds-объекта, 
		/// содержащего ссылки на объекта. Загруженные данные будут
		/// представлены в датаграмме объекта; доступ к ним может быть получен
		/// через метод <see cref="PropertyXml"/>
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		public void UploadArrayProp( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// Форимруем запрос:
			XGetPropertyRequest request = new XGetPropertyRequest( TypeName, ObjectID, sPropName );
			XGetPropertyResponse response = (XGetPropertyResponse)AppServerFacade.ExecCommand( request );

			XmlElement xmlArrayProp = PropertyXml( sPropName );
			xmlArrayProp.RemoveAll();
			xmlArrayProp.InnerXml = response.XmlProperty.InnerXml;
		}

		
		/// <summary>
		/// Добавляет заданную объектную ссылку в массивное объектное свойство
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="sRefTypeName">Наименование ds-типа по ссылке</param>
		/// <param name="oRefObjectID">Идентификатор ds-объекта по ссылке</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public void AddArrayPropRef( string sPropName, string sRefTypeName, Guid oRefObjectID )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "Не задан идентификатор объекта по ссылке (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// Этап #1: Формируем данные заглушки заданного объекта по ссылке:
			XmlElement xmlProxy = Datagram.OwnerDocument.CreateElement( sRefTypeName );
			xmlProxy.SetAttribute( "oid", oRefObjectID.ToString() );

			// Этап #2: Дописываем заглушку как данные указанного свойства:
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			xmlRefProperty.AppendChild( xmlProxy );
		}


		/// <summary>
		/// Удаляет заданную объектную ссылку из массивного объектного свойства
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="sRefTypeName">Наименование ds-типа по ссылке</param>
		/// <param name="oRefObjectID">Идентификатор ds-объекта по ссылке</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public void RemoveArrayPropRef( string sPropName, string sRefTypeName, Guid oRefObjectID )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "Не задан идентификатор объекта по ссылке (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );
			
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			XmlNode xmlRefArrayItem = xmlRefProperty.SelectSingleNode( String.Format("{0}[oid='{1}']", sRefTypeName, oRefObjectID.ToString()) );
			if ( null!=xmlRefArrayItem )
				xmlRefProperty.RemoveChild( xmlRefArrayItem );
		}


		/// <summary>
		/// Удаляет все ссылки в указанном массивном объектном свойстве
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public void ClearArrayProp( string sPropName )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			// удаляем все вложенные узлы
			xmlRefProperty.RemoveAll();
		}

		
		/// <summary>
		/// Возвращает новый экземпляр объекта-heler-а, инициализированный 
		/// в соответствии с данными скалярной объектной ссылки указанного 
		/// свойства ds-объекта. Данные получаются из датаграммы, обслуживаемой
		/// данным экземпляром helper-а.
		/// Если данных по ссылке нет, то результат вызова зависит от флага
		/// bStrictExistenceCheck - если он задан, то генерируется исключение;
		/// если сброшен - то в качестве результата возвращается null;
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <param name="bStrictExistenceCheck">Режим "жесткой" проверки</param>
		/// <returns>
		///		-- Инициализированный объект-helper 
		///		-- null, если данных по сслыке нет и bStrictExistenceCheck задан
		///		в false
		///	</returns>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public ObjectOperationHelper GetInstanceFromPropScalarRef( string sPropName, bool bStrictExistenceCheck ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			XmlElement xmlPropRef = PropertyXml( sPropName );
			XmlElement xmlPropRefStub = (XmlElement)xmlPropRef.FirstChild;
			
			// Проверяем наличие данных объектной ссылки
			// если данных нет и метод выполняется с жесткой проверкой наличия - 
			// генерируем исключение; иначе - просто возвращаем null
			if ( null == xmlPropRefStub )
			{
				if (bStrictExistenceCheck)
					throw new ArgumentException("Свойство " + sPropName + " не содержит данных скалярной объектной ссылки!");
				else 
					return null;
			}
			
			ObjectOperationHelper helperRef = new ObjectOperationHelper();
			helperRef.IsNewObject = false;
			helperRef.TypeName = xmlPropRefStub.Name;

			string sObjectRefID = xmlPropRefStub.GetAttribute("oid");
			if ( null!=sObjectRefID || String.Empty!=sObjectRefID )
			{
				helperRef.ObjectID = new Guid(sObjectRefID);
			}
			else
			{
				// Если идентификатор объекта по ссылке не задан, и при этом задана
				// жесткая проверкой наличия - генерируем исключение; иначе - просто 
				// возвращаем null:
				if (bStrictExistenceCheck)
					throw new ArgumentException("Объектная ссылка по свойству " + sPropName + " не содержит идентификатора объекта!");
				else
					return null;
			}

			return helperRef;
		}


		/// <summary>
		/// Возвращает новый экземпляр объекта-heler-а, инициализированный 
		/// в соответствии с данными скалярной объектной ссылки указанного 
		/// свойства ds-объекта. данные получаются из датаграммы, обслуживаемой
		/// данным экземпляром helper-а.
		/// ПЕРЕГРУЖЕННЫЙ МЕТОД
		/// </summary>
		/// <param name="sPropName">Наименование свойства ds-объекта</param>
		/// <returns>Инициализированный объект-helper</returns>
		/// <exception cref="ArgumentException">
		/// Если данных для указанного свойства в датаграмме нет
		/// </exception>
		/// <remarks>
		/// ВНИМАНИЕ!
		/// Реализация helper-объекта НЕ ПРОВЕРЯЕТ соответствие указанного 
		/// типа / значения определениям типа и значения свойства, заданным
		/// в метаданным приложения!
		/// </remarks>
		public ObjectOperationHelper GetInstanceFromPropScalarRef( string sPropName ) 
		{
			return GetInstanceFromPropScalarRef( sPropName, true );
		}


		/// <summary>
		/// Удаляет указанный набора свойств из датаграммы объекта - данные 
		/// вместе с описаниями самих свойств. В случае записи такой датаграммы
		/// все "удаленные" свойства будут проигнорированы Storage-м, и в итоге
		/// изменяться не будут. Именно для этого - блокировки изменений - и 
		/// используется метод "удаления свойств"
		/// </summary>
		/// <param name="arrPropNames">
		/// Массив наименований свойств, описания и данные которых удаляются 
		/// из датаграммы
		/// </param>
		public void DropPropertiesXml( params string[] arrPropNames ) 
		{
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			foreach( string sPropName in arrPropNames )
				Datagram.RemoveChild( PropertyXml(sPropName) );
		}
		
		
		/// <summary>
		/// Удаляет все свойства из датаграммы КРОМЕ указанных. Из датаграммы
		/// удаляются данные вместе с описаниями самих свойств. В случае записи 
		/// такой датаграммы все "удаленные" свойства будут проигнорированы 
		/// Storage-м, и в итоге не будут изменяться в БД. Именно для этого - 
		/// блокировки изменений - и используется метод "удаления свойств"
		/// </summary>
		/// <param name="arrPropNames">
		/// Массив наименований свойств, описания и данные которых НЕ должны 
		/// удаляться из датаграммы
		/// </param>
		public void DropPropertiesXmlExcept( params string[] arrPropNames ) 
		{
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			ArrayList arrDoppingPropNames = new ArrayList();
			
			// Переберем все свойства, существующие в датаграмме: если 
			// рассматриваемое свойство не входит в массив тех, которые
			// удалять не надо - то включим его в перечень удаляемых
			foreach( XmlNode xmlChild in Datagram.ChildNodes )
				if ( Array.IndexOf(arrPropNames, xmlChild.Name) < arrPropNames.GetLowerBound(0) )
					arrDoppingPropNames.Add( xmlChild.Name );
			
			foreach( string sPropName in arrDoppingPropNames )
				Datagram.RemoveChild( PropertyXml(sPropName) );
		}
		
		
		/// <summary>
		/// Метод конструирования комплексной датаграммы, включающей данные 
		/// нескольких ds-объектов, представленных в заданных helper-ах.
		/// Полученная датаграмма используется для единовременной записи 
		/// данных нескольких объектов, а также может использоваться для 
		/// создания и удаления данных объектов.
		/// </summary>
		/// <param name="helpers">
		/// Массив helper-объектов, данные котороых будут переданы на запись
		/// в составе общей датаграммы. Элементы массива могут быть null-ами;
		/// такие при сборе датаграммы будут игнорироваться.
		/// </param>
		/// <returns>
		/// XML-элемент с данными комплексной датаграммы.
		/// </returns>
		public static XmlElement MakeComplexDatagarmm( ObjectOperationHelper[] helpers ) 
		{
			// Конструируем датграмму: в этом - комплексном - случае в качестве
			// корневого элемента д.б. элемент со специальным наименованием - 
			// так Storage понимает, что в датаграмме представленны данные 
			// нескольких объектов:
			XmlDocument xmlComplexDatagram = new XmlDocument();
			XmlElement xmlComplexDatagramRoot = xmlComplexDatagram.CreateElement("x-datagram");
			xmlComplexDatagram.AppendChild( xmlComplexDatagramRoot );
			foreach( ObjectOperationHelper helper in helpers )
			{
				// Если элемент массива есть null - пропускаем:
				if (null==helper)
					continue;
				// ...Иначе - проверяем по полной: задание типа и наличие XML-данных:
				ValidateRequiredArgument( helper.TypeName, "helper.TypeName" );
				if (null==helper.Datagram)
					throw new InvalidOperationException( "Данные объекта типа " + helper.TypeName + " не загружены" );
				xmlComplexDatagramRoot.AppendChild( xmlComplexDatagram.ImportNode( helper.Datagram, true ) );
			}
			
			return xmlComplexDatagramRoot;
		}

		
		#endregion

		#region Методы работы с сервером приложения - чтение, запись и удаление данных ds-объектов
		
		/// <summary>
		/// Проверяет сущестоввание ds-обхекта, описываемого экземпляром, не 
		/// прогружая данные этого объекта
		/// </summary>
		/// <param name="bIsStrictCheck">
		/// Строгая проверка: если параметр задан в true, и ds-объекта в системе нет, 
		/// метод проверки генерирует исключение; Если задан в false, то наличе объекта
		/// отражается результатом метода
		/// </param>
		/// <returns>
		/// Логический признак наличия объекта в БД на момент вызова
		/// </returns>
		public bool CheckExistence( bool bIsStrictCheck ) 
		{
			// Наименование типа искомого объекта д.б. задано через экземпляр
			// объекта-helper-а
			ValidateRequiredArgument( TypeName,"TypeName" );
			ValidateRequiredArgument( ObjectID,"ObjectID" );

			// Формируем запрос на выполнение операции "GetObjectIdByExKey" - 
			// операции получения идентификатора объекта по его "ключевым" 
			// свойствам:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest( );
			requestGetId.TypeName = TypeName;
			requestGetId.Params = new XParamsCollection();
			requestGetId.Params.Add( "ObjectID", ObjectID );

			// Выполняем операцию - вызываем сервер приложения
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			// Результат должен быть всегда:
			if ( null==responseGetId )
				throw new ApplicationException("Ошибка выполнения операции сервера приложения (GetObjectIdByExKey) - в качестве результата получен null!" );
			if ( responseGetId.ObjectID != Guid.Empty )
				return true;
			else if (!bIsStrictCheck)
				return false;
			else
				throw new InvalidOperationException( String.Format(
					"Указанный объект типа {0} c идентификатором {1} не существует",
					TypeName, ObjectID.ToString()
				));
		}
		

		/// <summary>
		/// Получение идентификатора ds-обхекта, заданного значениями своих 
		/// "ключевых" свойств. Использует операцию сервера, GetObjectIdByExKey
		/// </summary>
		/// <param name="keyPropsCollection">
		/// Коллекция значений "ключевых" свойств объекта, как объект типа 
		/// XParamsCollection. Здесь наименование параметра есть наименование
		/// свойства, значение параметра - значение свойства
		/// </param>
		/// <returns>Идентификатор ds-объекта</returns>
		/// <remarks>
		/// (1) Наименование типа искомого объекта д.б. задано через экземпляр
		///		объекта-helper-а; см. свойство TypeName и "фабричные" методы
		/// (2) Если искомый идентификатор (объект) найден не будет, будет 
		///		сгенерировано исключение типа ArgumentException, см. реализацию 
		///		операции GetObjectIdByExKeyCommand
		/// (3) Полученный идентификатор так же устанавливается как значение
		///		свойства ObjectID текущего объекта-helper-а
		/// </remarks>
		public Guid GetObjectIdByExtProp( XParamsCollection keyPropsCollection ) 
		{
			// Наименование типа искомого объекта д.б. задано через экземпляр
			// объекта-helper-а
			ValidateRequiredArgument( TypeName,"TypeName" );

			// Формируем запрос на выполнение операции "GetObjectIdByExKey" - 
			// операции получения идентификатора объекта по его "ключевым" 
			// свойствам:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest( );
			requestGetId.TypeName = TypeName;
			requestGetId.Params = keyPropsCollection;

			// Выполняем операцию - вызываем сервер приложения
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			if ( null==responseGetId )
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObjectIdByExKey") );

			// Полученный в результате идентификатор не только возвращаем 
			// в качестве результата, но и устанавливаем как значение соотв.
			// свойства helper-а:
			ObjectID = responseGetId.ObjectID;
			return ObjectID;
		}

		
		/// <summary>
		/// Загружает данные ds-объекта, заданного свойствами TypeName и ObjectID
		/// данного экземпляра helper-объекта. Использует операцию сервера, 
		/// GetObject. 
		/// </summary>
		/// <remarks>
		/// (1) Идентификатор объекта может быть задан как Guid.Empty - 
		///		в этом случае будет загружен ШАБЛОН датаграммы ds-объекта 
		///		с предустановленным значением атрибута new и сгенерированным
		///		значением атрибута oid; после выполнения операции это значение
		///		будет представлено чепез свойство ObjectID.
		/// (2) Изменяет значения свойств:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject() 
		{
			// Вызываем перегруженный вариант
			LoadObject( (string[])null );
		}

			
		/// <summary>
		/// Перегруженный вариант - загружает данные ds-объекта, заданного 
		/// свойствами TypeName и ObjectID, и заданный набор его свойств
		/// Использует операцию сервера, GetObject. 
		/// </summary>
		/// <param name="arrPreloadProperties">Массив наименований прогружаемых параметров, м.б. null</param>
		/// <remarks>
		/// (1) Идентификатор объекта может быть задан как Guid.Empty - 
		///		в этом случае будет загружен ШАБЛОН датаграммы ds-объекта 
		///		с предустановленным значением атрибута new и сгенерированным
		///		значением атрибута oid; после выполнения операции это значение
		///		будет представлено чепез свойство ObjectID.
		/// (2) Изменяет значения свойств:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject( string[] arrPreloadProperties ) 
		{
			// Наименование типа искомого объекта д.б. задано 
			ValidateRequiredArgument( TypeName,"TypeName" );

			// Формируем запрос на выполнение операции получения данных 
			// ds-объекта, GetObject. В соотв. со спецификацией операции,
			// идентификатор объекта может быть задан как Guid.Empty - 
			// в этом случае будет загружен ШАБЛОН датаграммы ds-объекта 
			// с предустановленным значением атрибута new и сгенерированным
			// значением атрибута oid
			XGetObjectRequest requestGet = new XGetObjectRequest( TypeName, ObjectID );
			requestGet.PreloadProperties = arrPreloadProperties;
			XGetObjectResponse responseGet = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGet );
			if (null==responseGet)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObject") );

			// Корректируем значения свойств с соотв. с полученными данными:
			m_xmlDatagram = responseGet.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );
		}

		
		/// <summary>
		/// Загружает данные ds-объекта, заданного свойствами TypeName - и
		/// ВМЕСТО ObjectID - значениями своих "ключевых" свойств. 
		/// Использует операцию сервера, GetObjectByExKey		
		/// </summary>
		/// <param name="keyPropsCollection">
		/// Коллекция значений "ключевых" свойств объекта, как объект типа 
		/// XParamsCollection. Здесь наименование параметра есть наименование
		/// свойства, значение параметра - значение свойства
		/// </param>
		/// <remarks>
		/// (1) Наименование типа искомого объекта д.б. задано через экземпляр
		///		объекта-helper-а; см. свойство TypeName и "фабричные" методы
		/// (2) Если искомый (объект) найден не будет, будет сгенерировано 
		///		исключение типа ArgumentException, см. реализацию операции 
		///		GetObjectByExKeyCommand
		/// (3) Метод изменяет значения свойств:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject( XParamsCollection keyPropsCollection ) 
		{
			// Наименование типа должно быть задано
			ValidateRequiredArgument( TypeName,"TypeName" );

			// Формируем запрос на выполнение операции "GetObjectByExKey" - 
			// операции загрузки данных объекта, заданного значениями
			// своих свойств:
			GetObjectByExKeyRequest requestGetEx = new GetObjectByExKeyRequest( TypeName, keyPropsCollection );

			// Выполняем операцию - вызываем сервер приложения
			XGetObjectResponse responseGet = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGetEx );
			if (null==responseGet)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObject") );

			// Устанавливаем значения свойств в соотв. со значениями параметров 
			// (технически, операция может быть переопределена и может вернуть
			// произвольную датаграмму - так что перепишем значения всех свойств
			// в соотв. с атрибутами из датаграммы)
			m_xmlDatagram = responseGet.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );
		}

		
		/// <summary>
		/// "Безопасная" загрузка данных ds-объекта, заданного свойствами 
		/// TypeName - и ВМЕСТО ObjectID - значениями своих "ключевых" 
		/// свойств. В отличии от LoadObject, сначала выполняет операцию 
		/// получения идентификатора, и загружает данные только в том случае
		/// если идентификатор будет получен.
		/// Использует операции сервера GetObjectIdByExKey и GetObject
		/// </summary>
		/// <param name="keyPropsCollection">
		/// Коллекция значений "ключевых" свойств объекта, как объект типа 
		/// XParamsCollection. Здесь наименование параметра есть наименование
		/// свойства, значение параметра - значение свойства
		/// </param>
		/// <returns>
		/// Логический признак: true, если объект, заданный значениями своих
		/// свойств, был найден и его данные успешно загружены; иначе - false
		/// </returns>
		/// <remarks>
		/// (1) Наименование типа искомого объекта д.б. задано через экземпляр
		///		объекта-helper-а; см. свойство TypeName и "фабричные" методы
		/// (2) Метод изменяет значения свойств:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public bool SafeLoadObject( XParamsCollection keyPropsCollection ) 
		{
			// Наименование типа объекта должно быть задано
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ...вызываем перегруженный метод
			return SafeLoadObject( keyPropsCollection, null );
		}


		/// <summary>
		/// Перегруженая версия метода SafeLoadObject; добавляет возможность 
		/// прогрузки доп. свойств.
		/// </summary>
		/// <param name="keyPropsCollection">
		/// Коллекция значений "ключевых" свойств объекта, как объект типа 
		/// XParamsCollection. Здесь наименование параметра есть наименование
		/// свойства, значение параметра - значение свойства
		/// </param>
		/// <param name="arrPreloadProperties">
		/// Массив наименований прогружаемых параметров, м.б. null
		/// </param>
		/// <returns>
		/// Логический признак: true, если объект, заданный значениями своих
		/// свойств, был найден и его данные успешно загружены; иначе - false
		/// </returns>
		/// <remarks>
		/// (1) Наименование типа искомого объекта д.б. задано через экземпляр
		///		объекта-helper-а; см. свойство TypeName и "фабричные" методы
		/// (2) Метод изменяет значения свойств:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public bool SafeLoadObject( XParamsCollection keyPropsCollection, string[] arrPreloadProperties ) 
		{
			// Наименование типа объекта должно быть задано
			ValidateRequiredArgument( TypeName,"TypeName" );

			// Если коллекция внешних идентификаторов не задана - то в этом качестве 
			// ("внешнего" идентификатора) пробуем сам ObjectID; понятно, что либо 
			// коллекция, либо идентификатор д.б. заданы:
			if (null == keyPropsCollection)
			{
				if (Guid.Empty==ObjectID)
					throw new ArgumentException( "Не заданы ни коллекция \"внешних\" идентификаторов, ни сам идентификатор объекта!" );
				keyPropsCollection = new XParamsCollection();
				keyPropsCollection.Add( "ObjectID", ObjectID );
			}

			// #1: Формируем запрос на определение идентификатора объекта 
			// заданного значениями его "ключевых" свойств:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest();
			requestGetId.TypeName = TypeName;
			requestGetId.Params = keyPropsCollection;
			// Выполняем операцию - вызываем сервер приложений
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			if (null==responseGetId)
				return false;
			// Если идентификатор объекта определить не удалось - выходим
			if (Guid.Empty==responseGetId.ObjectID)
				return false; 
			
			// #2: Формируем запрос на загрузку данным полностью 
			// идентифицированного ds-объекта:
			XGetObjectRequest requestGetObject = new XGetObjectRequest( TypeName, responseGetId.ObjectID );
			requestGetObject.PreloadProperties = arrPreloadProperties;
			XGetObjectResponse responseGetObject = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGetObject );
			if (null==responseGetObject)
				return false;
			if (null==responseGetObject.XmlObject)
				return false;

			// Устанавливаем значения свойств в соотв. с полученными ds-данными:
			m_xmlDatagram = responseGetObject.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );

			return true;
		}

		
		/// <summary>
		/// Записывает данные ds-объекта, представленные датаграммой, 
		/// обслуживаемой helper-объектом. Использует операцию сервера 
		/// приложения SaveObject
		/// </summary>
		/// <remarks>
		/// Если записывались данные нового объекта - то после записи
		/// атрибут new в датаграмме объекта будет снят
		/// </remarks>
		public void SaveObject() 
		{
            // Наименование типа и идентификатор объекта должны быть заданы
            ValidateRequiredArgument(TypeName, "TypeName");
            if (null == Datagram)
                throw new InvalidOperationException(ERRFMT_INVALID_DATA_NOTLOAD);

            // Формируем запрос на выполнение операции записи данных
            XSaveObjectRequest requestSave = new XSaveObjectRequest();
            requestSave.XmlSaveData = Datagram;
            // ...и выполняем операцию - вызываем сервер приложения
            AppServerFacade.ExecCommand(requestSave);

            // Если запись прошла без ошибки - снимем атрибут "new" в датаграмме
            // и соотв. скорректируем значение свойства IsNewObject - при этом 
            // меняем значение члена класса, НЕ ЧЕРЕЗ СВОЙСТВО (т.к. изменение
            // свойства "убъет" датаграмму):
            Datagram.RemoveAttribute("new");
            m_bIsNewObject = false;
		}
		
        /// <summary>
		/// Выполняет КОМПЛЕКСНУЮ запись данных нескольких объектов за одно 
		/// выполнение операции SaveObject; перегруженный метод
		/// </summary>
		/// <param name="helpers">
		/// Массив helper-объектов, данные котороых будут переданы на запись
		/// в составе общей датаграммы. Элементы массива могут быть null-ами;
		/// такие при сборе датаграммы будут игнорироваться.
		/// </param>
		/// <remarks>
		/// (1) ВНИМАНИЕ! Метод НЕ РЕАЛИЗУЕТ каких-либо проверок несоответствия
		///		данных датаграмм, представленных в helper-объектах. При записи 
		///		связанных объектв контроль корректности ссылок, представленных 
		///		в датаграммах, должен выполняться прикладынм кодом!
		/// (2) Если записывались данные нового объекта - то после записи
		///		атрибут new в соответствующей датаграмме будет снят
		/// </remarks>
		public static void SaveComplexDatagram( params ObjectOperationHelper[] helpers ) 
		{
            SaveComplexDatagram(helpers, null, null);
		}

		/// <summary>
		/// Выполняет КОМПЛЕКСНУЮ запись данных нескольких объектов за одно 
		/// выполнение операции SaveObject; перегруженный метод
		/// </summary>
		/// <param name="helpers">
		/// Массив helper-объектов, данные котороых будут переданы на запись
		/// в составе общей датаграммы. Элементы массива могут быть null-ами;
		/// такие при сборе датаграммы будут игнорироваться.
		/// </param>
        /// <param name="rootObjectID">
        /// TODO: Описать параметр
        /// </param>
        /// <param name="sContext">
        /// TODO: Описать параметр
        /// </param>
		/// <remarks>
		/// (1) ВНИМАНИЕ! Метод НЕ РЕАЛИЗУЕТ каких-либо проверок несоответствия
		///		данных датаграмм, представленных в helper-объектах. При записи 
		///		связанных объектв контроль корректности ссылок, представленных 
		///		в датаграммах, должен выполняться прикладынм кодом!
		/// (2) Если записывались данные нового объекта - то после записи
		///		атрибут new в соответствующей датаграмме будет снят
		/// </remarks>
		public static void SaveComplexDatagram( ObjectOperationHelper[] helpers, XObjectIdentity rootObjectID, string sContext ) 
		{
            // Конструируем датграмму: 
            XmlElement xmlComplexDatagramRoot = MakeComplexDatagarmm(helpers);

            // ... и вызываем перегруженный метод, принимающий датаграмму:
            SaveComplexDatagram(xmlComplexDatagramRoot, rootObjectID, sContext);

            // Если запись выполнилась без ошибки - убираем атрибуты "new" у всех
            // датаграмм всех helper-ов, участвующих в записи; при этом меняем 
            // значение члена класса, НЕ ЧЕРЕЗ СВОЙСТВО (т.к. изменение свойства 
            // "убъет" датаграмму):
            foreach (ObjectOperationHelper helper in helpers)
            {
                if (null != helper)
                {
                    helper.m_xmlDatagram.RemoveAttribute("new");
                    helper.m_bIsNewObject = false;
                }
            }
		}
		
		/// <summary>
		/// Выполняет КОМПЛЕКСНУЮ запись данных нескольких объектов за одно 
		/// выполнение операции SaveObject; перегруженный метод
		/// </summary>
		/// <param name="xmlComplexDatagramRoot">XML-данные комплексной датаграммы</param>
        /// <param name="rootObjectID">TODO: Описать параметр</param>
        /// <param name="sContext">Контекст</param>
		/// <remarks>
		/// (1) ВНИМАНИЕ! Метод НЕ РЕАЛИЗУЕТ каких-либо проверок несоответствия
		///		данных датаграмм, представленных в helper-объектах. При записи 
		///		связанных объектв контроль корректности ссылок, представленных 
		///		в датаграммах, должен выполняться прикладынм кодом!
		/// (2) После записи исходная датаграмма никак не корректируется! Если
		///		данные датаграммы формировались на основании данных helper-объектов,
		///		то последние д.б. перегружены или скорректированы
		/// </remarks>
        public static void SaveComplexDatagram(XmlElement xmlComplexDatagramRoot, XObjectIdentity rootObjectID, string sContext) 
		{

			// Формируем запрос и выполняем операцию - вызываем сервер приложения
			XSaveObjectRequest requestSave = new XSaveObjectRequest();
			requestSave.XmlSaveData = xmlComplexDatagramRoot;
            requestSave.RootObjectId = rootObjectID;
            requestSave.Context = sContext;
			AppServerFacade.ExecCommand( requestSave );
		}


		/// <summary>
		/// Удаляет данные ds-объекта, заданного наименованием типа и 
		/// идентификатором, представленными текущим helper-объектом. 
		/// Использует операцию сервера приложения DeleteObject
		/// </summary>
		/// <returns>True, если объект был удален, false - иначе</returns>
		/// <remarks>
		/// Если helper-объект содержал данные ds-объекта, то после
		/// успешного выполнения операции эти данные будут сброшены
		/// </remarks>
		public bool DeleteObject() 
		{
			ValidateRequiredArgument( TypeName, "TypeName" );
			if (Guid.Empty==ObjectID)
				throw new ArgumentException("Идентификатор удаляемого объекта не задан", "ObjectID");

			XDeleteObjectRequest requestDelete = new XDeleteObjectRequest( TypeName, ObjectID );
			XDeleteObjectResponse responseDelete = (XDeleteObjectResponse)AppServerFacade.ExecCommand( requestDelete );

			if ( 0!=responseDelete.DeletedObjectQnt)
				m_xmlDatagram = null;
			return ( 0!=responseDelete.DeletedObjectQnt );
		}

		
		/// <summary>
		/// Удаляет данные ds-объекта, заданного наименованием типа и -
		/// ВМЕСТО ObjectID - значениями своих "ключевых" свойств.
		/// Использует операцию сервера, DeleteObjectByExKey
		/// </summary>
		/// <param name="keyPropsCollection">
		/// Коллекция значений "ключевых" свойств объекта, как объект типа 
		/// XParamsCollection. Здесь наименование параметра есть наименование
		/// свойства, значение параметра - значение свойства
		/// </param>
		/// <param name="bTreatNotExistsAsDeleted">
		/// Флаг, управляющий поведением метода в случае отсутствия указанного 
		/// объекта: если true, то "удаление" отсутствующего выполняется успешно
		/// (но метод при этом возвращает false), если false - то при попытке
		/// удаления отсутствующего генерируется исключение.
		/// </param>
		/// <returns>True, если объект был удален, false - иначе</returns>
		/// <remarks>
		/// (1) Наименование типа искомого объекта д.б. задано через экземпляр
		///		объекта-helper-а; см. свойство TypeName и "фабричные" методы
		/// (2) Если заданные объект найден не будет, будет сгенерировано 
		///		исключение типа ArgumentException, см. реализацию операции 
		///		DeleteObjectByExKeyCommand
		/// (3) Если helper-объект содержал данные ds-объекта, то после
		///		успешного выполнения операции эти данные будут сброшены
		/// </remarks>
		public bool DeleteObject( XParamsCollection keyPropsCollection, bool bTreatNotExistsAsDeleted ) 
		{
			ValidateRequiredArgument( TypeName,"sTypeName" );
			if (null==keyPropsCollection)
				throw new ArgumentNullException( "keyPropsCollection", "Коллекция альтернативных идентификаторов объектов должна быть задана!" );

			DeleteObjectByExKeyRequest requestDeleteEx = new DeleteObjectByExKeyRequest( TypeName, keyPropsCollection );
			requestDeleteEx.TreatNotExistsObjectAsDeleted = bTreatNotExistsAsDeleted;
			XDeleteObjectResponse responseDelete = (XDeleteObjectResponse)AppServerFacade.ExecCommand( requestDeleteEx );

			if ( 0!=responseDelete.DeletedObjectQnt )
				m_xmlDatagram = null;
			return ( 0!=responseDelete.DeletedObjectQnt );
		}


		#endregion

		#region Методы работы с сервером приложения - выполнение "источников данных" (data-sources)
		
		/// <summary>
		/// Выподняет операцию сервера приложения "Выполнить источник данных" 
		/// (ExecuteDataSource) и возвращает полученные данные как DataTable
		/// </summary>
		/// <param name="sDataSourceName">Наименование источника данных</param>
		/// <param name="dataSourceParams">Коллекция значений параметров источника данных</param>
		/// <returns>Результат выполнения, как DataTable</returns>
		public static DataTable ExecAppDataSource( string sDataSourceName, XParamsCollection dataSourceParams ) 
		{
			// "Защитные" проверки входных параметров 
			if (null==sDataSourceName)
				throw new ArgumentNullException("Некорректное значение параметра sDataSourceName");
			if (0==sDataSourceName.Length)
				throw new ArgumentException("Некорректное значение параметра sDataSourceName");

			// Формируем запрос на выполнение операции ExecuteDataSource - выполнение
			// предопределенной SQL-операции, заданной в метаданных приложения
			XExecuteDataSourceRequest request = new XExecuteDataSourceRequest();
			request.DataSourceName = sDataSourceName;
			request.Params = dataSourceParams;

			XExecuteDataSourceResponse response = (XExecuteDataSourceResponse)AppServerFacade.ExecCommand( request );
			if (null==response)
				throw new InvalidOperationException("Ошибка выполнения операции сервера приложения: в качестве результата получен null");

			return response.Data;
		}


		/// <summary>
		/// Выподняет операцию сервера приложения "Выполнить источник данных" 
		/// (ExecuteDataSource) и возвращает скалярное значение (соответствует
		/// значению первой строки первого столбца итогового DataTable)
		/// </summary>
		/// <param name="sDataSourceName">Наименование источника данных</param>
		/// <param name="dataSourceParams">Коллекция значений параметров источника данных</param>
		/// <returns>
		/// Итоговое скалярное значение. Если в результате DataTable получен
		/// не будет или не будет содержать данных, метод возвращает null
		/// </returns>
		public static object ExecAppDataSourceScalar( string sDataSourceName, XParamsCollection dataSourceParams ) 
		{
			DataTable resultData = ExecAppDataSource( sDataSourceName, dataSourceParams );

			// Нас интересует только первый элемент первой строки полученного 
			// результата (если, конечно, таковой присутствует):
			object oResult = null;
			if (null!=resultData)
			{
				if (resultData.Rows.Count>0 && resultData.Columns.Count>0)
					oResult = resultData.Rows[0][0];
			}

			return oResult;
		}
	
		
		/// <summary>
		/// Выподняет операцию сервера приложения "Выполнить источник данных" 
		/// (ExecuteDataSource) и возвращает данные в виде документа XML, 
		/// отформатированного при помощи вспомогательного класса-преобразователя
		/// <see cref="DataTableXmlFormatter"/>
		/// </summary>
		/// <param name="sDataSourceName">Наименование источника данных</param>
		/// <param name="dataSourceParams">Коллекция значений параметров источника данных</param>
		/// <param name="sResultItemName">Наименование элемента XML-документа, соотв. одному элементу списка</param>
		/// <returns>Документ XML с данными итогового списка</returns>
		public static XmlDocument ExecAppDataSourceSpecial( 
			string sDataSourceName, 
			XParamsCollection dataSourceParams, 
			string sResultItemName ) 
		{
			// "Защитные" проверки входных параметров 
			if (null==sDataSourceName)
				throw new ArgumentNullException("Некорректное значение параметра sDataSourceName");
			if (0==sDataSourceName.Length)
				throw new ArgumentException("Некорректное значение параметра sDataSourceName");
			if (null==sResultItemName)
				throw new ArgumentNullException("Некорректное значение параметра sResultItemName");
			if (0==sResultItemName.Length)
				throw new ArgumentNullException("Некорректное значение параметра sResultItemName");

			// Формируем запрос на выполнение операции ExecuteDataSource - выполнение
			// предопределенной SQL-операции, заданной в метаданных приложения
			XExecuteDataSourceRequest request = new XExecuteDataSourceRequest();
			request.DataSourceName = sDataSourceName;
			// Если параметры заданы - подставляем их:
			if (null!=dataSourceParams)
				request.Params = dataSourceParams;

			XExecuteDataSourceResponse response = (XExecuteDataSourceResponse)AppServerFacade.ExecCommand( request );
			if (null==response)
				throw new InvalidOperationException("Ошибка выполнения операции сервера приложения: в качестве результата получен null");

			// Для получения итогового XML-документа используем класс-форматировщик:
			return DataTableXmlFormatter.GetXmlFromDataTable( 
				response.Data,
				DataTableXmlFormatter.DEFAULT_ROOT_ELEMENT_NAME,
				sResultItemName
			);
		}

		
		#endregion

		#region Общие вспомогательные методы - конвертирование форматов представления данных

		/// <summary>
		/// Конвертирует бинарные данные, закодированные в виде строки в формате
		/// bin.hex, в строку, закодированную в формате bin.base64
		/// </summary>
		/// <param name="sDataBinHex">Исходная строка с данными в bin.hex-формате</param>
		/// <returns>Результирующая строка с данными в bin.base64</returns>
		/// <remarks>
		/// Если в качестве исходной строки задан null, метод возращает пустую строку
		/// </remarks>
		public static string ConvertBinHexToBinBase64( string sDataBinHex ) 
		{
			string sResultDataBinBase64 = String.Empty;
			if (null!=sDataBinHex && sDataBinHex.Length>0)
			{
				// формируем массив байт, на основании переданной строки
				int nSize = (sDataBinHex.Length/2);
				byte[] arrPictureData = new byte[nSize];
				for( int nIndex=0; nIndex<nSize; nIndex++ )
					arrPictureData[nIndex] = byte.Parse( sDataBinHex.Substring(nIndex*2, 2), NumberStyles.HexNumber );
				
				// на основании полученного массива (потока) байт формируем
				// строку в представлении bin.base64:
				sResultDataBinBase64 = Convert.ToBase64String(arrPictureData);
			}
			return sResultDataBinBase64;
		}


		/// <summary>
		/// Конвертирует бинарные данные, закодированные в виде строки в формате
		/// bin.base64, в строку, закодированную в формате bin.hex
		/// </summary>
		/// <param name="sDataBinBase64">Исходная строка с данными в формате bin.base64</param>
		/// <returns>Результирующая строка с данными в bin.hex</returns>
		/// <remarks>
		/// Если в качестве исходной строки задан null, метод возращает пустую строку
		/// </remarks>
		public static string ConvertBinBase64ToBinHex( string sDataBinBase64 ) 
		{
			string sResultDataBinHex = String.Empty;
			if (null!=sDataBinBase64 && 0!=sDataBinBase64.Length)
			{
				// Получаем массив байт
				byte[] arrPictureData = Convert.FromBase64String( sDataBinBase64 );
				// Сразу выделяем соответствующих размеров строковый буфер
				System.Text.StringBuilder sPictureBinHex = new System.Text.StringBuilder( arrPictureData.Length*2 );
				// ... и заполняем его 16-ричным представлением 
				for( int nIndex=0; nIndex<arrPictureData.Length; nIndex++)
					sPictureBinHex.Append( arrPictureData[nIndex].ToString("x2") );
				sResultDataBinHex = sPictureBinHex.ToString();
			}
			return sResultDataBinHex;
		}
	

		#endregion 

		#region Методы проверки типичных параметров запросов

		/// <summary>
		/// Формат сообщения о пустом аргументе (String.Empty, Guid.Empty и т.п.)
		/// </summary>
		private const string ERR_ARG_EMPTY_MSG_FMT = "Значение аргумента {0} должно быть задано!";
		/// <summary>
		/// Формат сообщения об аргументе, который не может быть установлен в null
		/// </summary>
		private const string ERR_ARG_NOTNULL_MSG_FMT = "Агрумент {0} не может быть задан в null!";
		/// <summary>
		/// Формат сообщения об формате строчного аргумента, задающего GUID-идентификатор оьъекта
		/// </summary>
		private const string ERR_ARG_INVALID_GUID_FMT = "Значение аргумента {0} не является GUID-идентификатором объекта!";
        /// <summary>
        /// Формат сообщения об формате целочисленного аргумента, задающего процент
        /// </summary>
        private const string ERR_ARG_INVALID_PERCENTAGE_FMT = "Значение аргумента {0} должно быть целым положительным числом не более 100!";
		

		/// <summary>
		/// Метод формальной проверки обязательного строчного аргумента - в случае,
		/// если аргумент равен null или String.Empty, возбуждает соответствующее 
		/// исключение
		/// </summary>
		/// <param name="sArgValue">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <exception cref="ArgumentNullException">Если null == sArgValue</exception>
		/// <exception cref="ArgumentException">Если String.Empty == sArgValue</exception>
		public static void ValidateRequiredArgument( string sArgValue, string sArgName ) 
		{
			ValidateRequiredArgument( sArgValue, sArgName, null );
		}

       
		
		/// <summary>
		/// Метод формальной проверки обязательного строчного аргумента - в случае,
		/// если аргумент равен null или String.Empty, возбуждает соответствующее 
		/// исключение; метод так же выполняет проверку соответствия заданного 
		/// значения некоторому типу, одному из: Int32, Bool, Guid;
		/// </summary>
		/// <param name="sArgValue">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <param name="oTreatAsType">
		/// Тип, на соответствие которому проверяется заданное значение; может быть 
		/// одно из значений Int32, Bool, Guid, или null - в последнем случае 
		/// проверка на соответствие типу не выполняется
		/// </param>
		/// <exception cref="ArgumentNullException">Если null == sArgValue</exception>
		/// <exception cref="ArgumentException">Если String.Empty == sArgValue</exception>
		public static void ValidateRequiredArgument( string sArgValue, string sArgName, Type oTreatAsType ) 
		{
			if (null == sArgValue)
				throw new ArgumentNullException( sArgName, String.Format( ERR_ARG_NOTNULL_MSG_FMT,sArgName ) );
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		
			if (null != oTreatAsType)
			{
				bool bIsAcceptableType = true;
				try
				{
					if (oTreatAsType.Equals( typeof(Int32) ))
					{
						Int32.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Boolean) ))
					{
						Boolean.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Guid) ))
					{
						new Guid( sArgValue );
					}
					else
						bIsAcceptableType = false;
				}
				catch(Exception err)
				{
					throw new ArgumentException( 
						String.Format(
							"Значение аргумета {0} ({1}) не может быть приведено к требуемому типу {2}",
							sArgName, sArgValue, oTreatAsType.Name
						), sArgName, err );
				}
				if (!bIsAcceptableType)
					throw new ArgumentException(
						"Заданое значение не может быть проверено на соответствие типу " + oTreatAsType.Name + " - указанный тип не поддерживается!",
						"oTreatAsType" );
			}
		}

		
		/// <summary>
		/// Метод формальной проверки аргумента типа System.Guid - в случае, если 
		/// аргумент равен Guid.Empty, возбуждает соответствующее исключение
		/// </summary>
		/// <param name="uidArgValue">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <exception cref="ArgumentException">Если Guid.Empty == uidArgValue</exception>
		public static void ValidateRequiredArgument( Guid uidArgValue, string sArgName ) 
		{
			if (Guid.Empty == uidArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		}

		
		/// <summary>
		/// Метод формальной проверки необязательного строкового аргумента - 
		/// в случае, если аргумент равен String.Empty, возбуждает 
		/// соответствующее исключение
		/// </summary>
		/// <param name="sArgValue">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <exception cref="ArgumentException">Если String.Empty == sArgValue</exception>
		public static void ValidateOptionalArgument( string sArgValue, string sArgName ) 
		{
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		}

		
		/// <summary>
		/// Метод формальной проверки необязательного строкового аргумента - 
		/// в случае, если аргумент равен String.Empty, возбуждает 
		/// соответствующее исключение
		/// </summary>
		/// <param name="sArgValue">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <param name="oTreatAsType">
		/// Тип, на соответствие которому проверяется заданное значение; может быть 
		/// одно из значений Int32, Bool, Guid, или null - в последнем случае 
		/// проверка на соответствие типу не выполняется
		/// </param>
		/// <exception cref="ArgumentException">Если String.Empty == sArgValue</exception>
		/// <exception cref="ArgumentException">Если заданное значение не соотв. указанному типу</exception>
		public static void ValidateOptionalArgument( string sArgValue, string sArgName, Type oTreatAsType ) 
		{
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );

			if (null!=oTreatAsType && null!=sArgValue)
			{
				bool bIsAcceptableType = true;
				try
				{
					if (oTreatAsType.Equals( typeof(Int32) ))
					{
						Int32.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Boolean) ))
					{
						Boolean.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Guid) ))
					{
						new Guid( sArgValue );
					}
					else
						bIsAcceptableType = false;
				}
				catch(Exception err)
				{
					throw new ArgumentException( 
						String.Format(
							"Значение аргумета {0} ({1}) не может быть приведено к требуемому типу {2}",
							sArgName, sArgValue, oTreatAsType.Name
						), sArgName, err );
				}
				if (!bIsAcceptableType)
					throw new ArgumentException(
						"Заданое значение не может быть проверено на соответствие типу " + oTreatAsType.Name + " - указанный тип не поддерживается!",
						"oTreatAsType" );
			}
		}

		
		/// <summary>
		/// Проверка корректности строкового параметра, задающего GUID-идентификатор
		/// </summary>
		/// <param name="sObjectID">Значение аргумента</param>
		/// <param name="sArgName">Наименование аргумента</param>
		/// <exception cref="ArgumentNullException">Если null == sObjectID</exception>
		/// <exception cref="ArgumentException">Если String.Empty == sObjectID</exception>
		/// <exception cref="ArgumentException">Если sObjectID не может быть приведен в GUID</exception>
		public static Guid ValidateRequiredArgumentAsID( string sObjectID, string sArgName ) 
		{
			// #1: Проверяем, что строка вообще зедана (не null и не пустая):
			ValidateRequiredArgument(sObjectID, sArgName);

			// #2: Пробуем перевести в Guid:
			Guid uidResulGuid;
			try { uidResulGuid = new Guid( sObjectID.ToLower().Trim() ); }
			catch( Exception err )
			{
				throw new ArgumentException( String.Format(ERR_ARG_INVALID_GUID_FMT,sArgName), sArgName, err );
			}

			// #3: Проверяем, что полученный Guid не есть Guid.Empty:
			if (Guid.Empty == uidResulGuid)			
				throw new ArgumentException( String.Format(ERR_ARG_EMPTY_MSG_FMT,sArgName), sArgName );

			return uidResulGuid;
		}


        /// <summary>
        /// Проверка корректности целочисленного параметра, задающего процент
        /// </summary>
        /// <param name="nPercent">Значение аргумента</param>
        /// <param name="sArgName">Наименование аргумента</param>
        /// <exception cref="ArgumentNullException">Если null == nPercent</exception>
        /// <exception cref="ArgumentException">Если nPercent меньше 0 </exception>
        /// <exception cref="ArgumentException">Если nPercent больше 100 </exception>
        public static int ValidateRequiredArgumentAsPercentage(int nPercent, string sArgName)
        {
            // #2: Проверяем, что процент больше или равен 0 и не более 100
            if ( (nPercent < 0 ) || (nPercent > 100 ) )
                throw new ArgumentException(String.Format(ERR_ARG_INVALID_PERCENTAGE_FMT, sArgName), sArgName);

            return nPercent;
        }
		
		#endregion 
	}
}