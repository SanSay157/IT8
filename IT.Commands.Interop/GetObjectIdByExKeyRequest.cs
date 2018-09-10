//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос на выполнение операции получения идентификатора ds-объекта, 
	/// заданного значениями своих реквизитов
	/// <seealso cref="GetObjectIdByExKeyResponse"/>
	/// </summary>
	[Serializable]
	public class GetObjectIdByExKeyRequest : XRequest 
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetObjectIdByExKey";
		/// <summary>
		/// Текст описания ошибки некорректного задания параметров
		/// </summary>
		private static readonly string ERR_AMBIGUOUS_PARAMS = "Должно быть задано либо наименование типа, либо наименование источника данных";
		
		#region Внутренние переменные класса 

		/// <summary>
		/// Наименование ds-типа, для которого формируется запрос на получение 
		/// идентификатора экземпляра объекта; заданиче значения исключает 
		/// использование значения m_sDataSourceName
		/// </summary>
		private string m_sTypeName = null;
		/// <summary>
		/// Наименование источника данных, при выполнении которого ожидается 
		/// получение идентификатора экземпляра объекта; заданиче значения 
		/// исключает использование значения m_sTypeName 
		/// </summary>
		private string m_sDataSourceName = null;
		/// <summary>
		/// Коллекция значений именованных параметров
		/// </summary>
		private XParamsCollection m_paramsCollection = new XParamsCollection();
		#endregion

		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public GetObjectIdByExKeyRequest() : base(DEF_COMMAND_NAME) 
		{}

		
		/// <summary>
		/// Наименование ds-типа, для которого формируется запрос на получение 
		/// идентификатора экземпляра объекта; заданиче значения исключает 
		/// использование значения DataSourceName
		/// </summary>
		/// <exception cref="ArgumentException">
		/// При попытке в качестве значения свойства пустой строки</exception>
		/// <exception cref="ArgumentNullException">
		/// При попытке значения свойства в null</exception>
		public string TypeName 
		{
			get { return m_sTypeName; } 
			set
			{
				XRequest.ValidateOptionalArgument( value, "TypeName" );
				m_sTypeName = value;
			}
		}

		
		/// <summary>
		/// Наименование источника данных, при выполнении которого ожидается 
		/// получение идентификатора экземпляра объекта; заданиче значения 
		/// исключает использование значения sTypeName 
		/// </summary>
		/// <exception cref="ArgumentNullException">
		/// При попытке значения свойства в null</exception>
		public string DataSourceName 
		{
			get { return m_sDataSourceName; }
			set
			{
				XRequest.ValidateOptionalArgument( value, "DataSourceName" );
				m_sDataSourceName = value;
			}
		}


		/// <summary>
		/// Коллекция значений именованных параметров 
		/// </summary>
		/// <remarks>
		/// При задании null свойство устанавливается в значение, соответствующее
		/// "пустой" коллекции значений параметров
		/// </remarks>
		public XParamsCollection Params 
		{
			get { return m_paramsCollection; }
			set { m_paramsCollection = (null==value? new XParamsCollection() : value); }
		}


		/// <summary>
		/// Проверяет корректность заполнения данных запроса
		/// </summary>
		public override void Validate() 
		{
			// Обязательно вызываем базовую реализацию - там проверяются
			// свойства, определяемые базовой же реализацией 
			base.Validate();

			// Должно быть задано либо наименование ds-типа, либо наименование 
			// источника данных - но не оба одновременно:
			if (null!=TypeName && 0!=TypeName.Length)
			{
				if (null!=DataSourceName && 0!=DataSourceName.Length)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
			}
			else
			{
				if (null==DataSourceName)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
				if (0==DataSourceName.Length)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
			}
		}
	}
}

