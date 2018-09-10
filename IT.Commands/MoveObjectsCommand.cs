//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using System.Text;
using System.Data;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Data;
using Croc.IncidentTracker.Core;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда переноса объетов в нового родителя
	/// </summary>
	public class MoveObjectsCommand : XCommand
	{
		public XResponse Execute(MoveObjectsRequest request, IXExecutionContext context)
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
           	foreach(Guid oid in request.SelectedObjectsID)
			{
				DomainObjectData xobj = dataSet.CreateStubLoaded(request.SelectedObjectType, oid, -1);
                xobj.SetUpdatedPropValue(request.ParentPropName, request.NewParent);
				// для объекта проверим права
				XSecurityManager.Instance.DemandSaveObjectPrivilege(xobj);
			}
         	XStorageGateway.Save(context, dataSet, Guid.NewGuid());

			return new XResponse();
		}
	}
}
