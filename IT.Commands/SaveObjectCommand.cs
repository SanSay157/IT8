//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда сохранения (SaveObject)
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	[XRequiredRequestType(typeof(SaveObjectInternalRequest))]
	public class SaveObjectCommand : XSaveObjectCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public virtual XResponse Execute( SaveObjectInternalRequest request, IXExecutionContext context ) 
		{
			// #1: Проверка прав
			// Примечание: делаем это здесь, а не в гварде, ради человеческой диагностики
			XSecurityManager sec_man = XSecurityManager.Instance;
			IEnumerator enumerator = request.DataSet.GetModifiedObjectsEnumerator(false);
			DomainObjectData xobj;
			while(enumerator.MoveNext())
			{
				xobj = (DomainObjectData)enumerator.Current;
				if (xobj.ToDelete)
					sec_man.DemandDeleteObjectPrivilege(xobj);
				else 
					sec_man.DemandSaveObjectPrivilege(xobj);
			}

			// #2: Запись данных
			XStorageGateway.Save(context, request.DataSet, request.TransactionID);

			// #3: Вызовем post-call-процедуры (если таковые определены)
			//executePostCalls(request.PostCalls, context);

			// Специального результата операция не возвращает
			return new XResponse();
		}
	}
}
