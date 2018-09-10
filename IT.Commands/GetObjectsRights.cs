//******************************************************************************
// Инструментальная среда CROC XML Framework .NET
// ЗАО КРОК инкорпорейтед, 2004
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Specialized;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда проверки наличия прав на объекты.
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectsRightsCommand : XCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		/// <remarks>
		/// -- ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД, ВЫЗЫВАЕТСЯ ЯДРОМ
		/// -- Проверка параметров запроса реализована в методе Validate запроса, 
		/// который автоматически вызывается Ядром при получении запроса
		/// </remarks>
		public XGetObjectsRightsResponse Execute( XGetObjectsRightsRequest request, IXExecutionContext context ) 
		{
			Boolean[] objectPermissionCheckList = new Boolean[request.Permissions.Length];
			IDictionary checkedObjects = new HybridDictionary();
			IDictionary checkedTypes = new Hashtable();
			XObjectRights rights;

			int nIndex = -1;
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			foreach( XObjectPermission permission in request.Permissions )
			{
				bool bHasRight = true; 
				
				if ((permission.Action & XObjectActionEnum.Create)==XObjectActionEnum.Create)
				{
					if (checkedTypes.Contains(permission.TypeName))
						bHasRight = (bool)checkedTypes[permission.TypeName];
					else
					{
						bHasRight = XSecurityManager.Instance.GetRightsOnNewObject(
							dataSet.CreateStubNew(permission.TypeName)
							).AllowCreate;
						checkedTypes[permission.TypeName] = bHasRight;
					}
				}

				if ( bHasRight && (
					((permission.Action & XObjectActionEnum.Change) > 0) || 
					((permission.Action & XObjectActionEnum.Delete) > 0) ||
					((permission.Action & XObjectActionEnum.Read) > 0)
					))
				{
					rights = (XObjectRights)checkedObjects[permission.TypeName + ":" + permission.ObjectID];
					if (rights == null)
					{
						rights = XSecurityManager.Instance.GetObjectRights(
							dataSet.GetLoadedStub(permission.TypeName, permission.ObjectID)
							);
						checkedObjects[permission.TypeName + ":" + permission.ObjectID] = rights;
					}
					bHasRight = ((permission.Action & XObjectActionEnum.Change) > 0) && rights.AllowParticalOrFullChange ||
								((permission.Action & XObjectActionEnum.Delete) > 0) && rights.AllowDelete ||
								((permission.Action & XObjectActionEnum.Read) > 0) && rights.AllowParticalOrFullRead;
				}
				// Записываем полученный флаг в результирующий массив
				objectPermissionCheckList[++nIndex] = bHasRight;
			}

			// Формируем результат операции
			return new XGetObjectsRightsResponse(objectPermissionCheckList);
		}
	}
}