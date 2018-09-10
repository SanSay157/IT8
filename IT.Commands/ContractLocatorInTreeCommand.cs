//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Commands.Trees;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения полного пути в дереве "Клиенты и Проекты" для заданного инцидента
	/// </summary>
    public class ContractLocatorInTreeCommand : XCommand
	{
		public DKPLocatorResponse Execute(ContractLocatorInTreeRequest request, IXExecutionContext context)
		{
			DKPTreeObjectLocator locator = new DKPTreeObjectLocator();
			DKPLocatorResponse response = new DKPLocatorResponse();
			XTreePath path;
			if (request.ContractOID == Guid.Empty)
                path = locator.GetContractFullPath(context.Connection, request.ExternalID);
			else
				path = locator.GetIncidentFullPath(context.Connection, request.ContractOID);

			response.Path = path.ToString();
			if (path.Length > 0)
				response.ObjectID = path[0].ObjectID;

			return response;
		}
	}
}
