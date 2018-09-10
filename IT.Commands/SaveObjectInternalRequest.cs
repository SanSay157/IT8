using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// "Внутренний" запрос команды сохранения.
	/// Приводит xml-датаграмму, полученную от клиента, в экземпляр XDatagram
	/// </summary>
    [Serializable]
	public class SaveObjectInternalRequest: XRequest
	{
		/// <summary>
		/// Наименование операции по умолчанию, используемое в файле конфигурации
		/// </summary>
		private const string DEF_COMMAND_NAME = "SaveObject";

		/// <summary>
		/// Множество описаний объектов для сохранения
		/// </summary>
		protected DomainObjectDataSet m_dataSet;

		/// <summary>
		/// Идентификатор транзакции
		/// </summary>
		protected Guid m_TransactionID;

		/// <summary>
		/// Исходный запрос на выполнение операции SaveObject
		/// <seealso cref="XSaveObjectRequest"/>
		/// </summary>
		protected XSaveObjectRequest m_originalRequest;

		public SaveObjectInternalRequest(XSaveObjectRequest originalRequest, IXExecutionContextService context)
			: base( DEF_COMMAND_NAME ) 
		{
			m_originalRequest = originalRequest;

			// установим идентификатор транзакции
			if (originalRequest.XmlSaveData.HasAttribute("transaction-id"))
				m_TransactionID = new Guid(originalRequest.XmlSaveData.GetAttribute("transaction-id"));
			else
				m_TransactionID = Guid.NewGuid();

			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			m_dataSet = formatter.DeserializeForSave(originalRequest.XmlSaveData);
		}

		#region Публичные свойства
		/// <summary>
		/// Возвращает множество описаний данных ds-объектов, предназначенных
		/// для сохранения, сформированное на основании XML-датаграммы, заданой
		/// исходным запросом 
		/// </summary>
		public DomainObjectDataSet DataSet 
		{
			get { return m_dataSet; }
		}

		/// <summary>
		/// Возвращает исходный запрос на выполнение операции SaveObject
		/// </summary>
		public XSaveObjectRequest OriginalRequest 
		{
			get { return m_originalRequest; }
		}

		/// <summary>
		/// Массив описаний post-call-процедур, которые должны быть вызваны 
		/// после сохранения данных объекта, в рамках той же транзакции
		/// </summary>
		
		/// <summary>
		/// Идентификатор логической транзакции
		/// Важен при использовании механизма кусочного сохранения
		/// </summary>
		public Guid TransactionID
		{
			get { return m_TransactionID; }
		}
		#endregion
	}
}
