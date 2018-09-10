//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Операция удаления данных ds-объекта с заданным типом и идентификатром из СУБД
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	public class DeleteObjectCommand: XCommand 
	{
		/// <summary>
		/// Метод выполнения операции, типизированная реализация
		/// </summary>
		///	<param name="oRequest">Объект-запрос на выполнение операции</param>
		/// <param name="oContext">Представление контекста выполнения операции</param>
		/// <returns>
		/// Экземпляр объекта-результата выполнения операции
		/// </returns>
		public XResponse Execute( XDeleteObjectRequest oRequest, IXExecutionContext oContext ) 
		{
			// Проверка параметров запроса
			XRequest.ValidateRequiredArgument( oRequest.TypeName, "XDeleteObjectRequest.TypeName");
			XRequest.ValidateRequiredArgument( oRequest.ObjectID, "XDeleteObjectRequest.ObjectID");

			DomainObjectData objData = DomainObjectData.CreateStubLoaded( oContext.Connection, oRequest.TypeName, oRequest.ObjectID );
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights( objData );
			if (!rights.AllowDelete)
				throw new XSecurityException( String.Format(
						"Выполнение операции невозможно: нет прав на удаление объекта \"{0}\" ({1}[oid='{2}'])", 
						objData.TypeInfo.Description,
						oRequest.TypeName,
						oRequest.ObjectID
					) );
			
			// Вызываем метод подсистемы Storage (уровень Level-2); экземпляр 
			// Storage представлен в рамках контекста выполнения опеарции
			return new XDeleteObjectResponse( XStorageGateway.Delete(oContext, oRequest.TypeName, oRequest.ObjectID) );
		}
	}
}
