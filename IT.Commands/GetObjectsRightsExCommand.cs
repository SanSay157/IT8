//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System.Collections;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда проверки наличия прав на объекты.
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectsRightsExCommand : XCommand 
	{
		protected XObjectRightsDescr createObjectRightsDescr(XObjectRights rights)
		{
			XObjectRightsDescr rightsDescr = new XObjectRightsDescr();
			rightsDescr.DenyDelete = !rights.AllowDelete;
			rightsDescr.DenyChange = !rights.AllowParticalOrFullChange;
			ICollection readOnlyPropNames = rights.GetReadOnlyPropNames();
			rightsDescr.ReadOnlyProps = new string[readOnlyPropNames.Count];
			readOnlyPropNames.CopyTo(rightsDescr.ReadOnlyProps, 0);
			return rightsDescr;
		}

		protected XObjectRightsDescr createObjectRightsDescr(XNewObjectRights rights)
		{
			XObjectRightsDescr rightsDescr = new XObjectRightsDescr();
			rightsDescr.DenyCreate = !rights.AllowCreate;
			ICollection readOnlyPropNames = rights.GetReadOnlyPropNames();
			rightsDescr.ReadOnlyProps = new string[readOnlyPropNames.Count];
			readOnlyPropNames.CopyTo(rightsDescr.ReadOnlyProps, 0);
			return rightsDescr;
		}

		public GetObjectsRightsExResponse Execute( CheckDatagramRequest request, IXExecutionContext context )
		{
			XObjectRightsDescr[] objectPermissionCheckList = new XObjectRightsDescr[request.ObjectsToCheck.Length];
			
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			DomainObjectDataSet dataSet = formatter.DeserializeForSave(request.XmlDatagram);

			int nIndex = -1;
			foreach(XObjectIdentity obj_id in request.ObjectsToCheck)
			{
				DomainObjectData xobj = dataSet.Find(obj_id.ObjectType, obj_id.ObjectID);
				//if (xobj.IsNew && xobj == null)
				//	throw new ArgumentException("Датаграмма не содержит нового объекта, для которого требуется вычислить права: " +obj_id.ObjectType + "[" + obj_id.ObjectType + "]");
				if (xobj == null)
					xobj = dataSet.Load(context.Connection, obj_id.ObjectType, obj_id.ObjectID);
				if (xobj.IsNew)
					objectPermissionCheckList[++nIndex] = createObjectRightsDescr(XSecurityManager.Instance.GetRightsOnNewObject(xobj));
				else
					objectPermissionCheckList[++nIndex] = createObjectRightsDescr(XSecurityManager.Instance.GetObjectRights(xobj));
			}

			// Формируем результат операции
			return new GetObjectsRightsExResponse(objectPermissionCheckList);
		}
	}
}