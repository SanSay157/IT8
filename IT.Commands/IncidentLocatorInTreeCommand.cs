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
	public class IncidentLocatorInTreeCommand: XCommand
	{
		public DKPLocatorResponse Execute(IncidentLocatorInTreeRequest request, IXExecutionContext context)
		{
			DKPTreeObjectLocator locator = new DKPTreeObjectLocator();
			DKPLocatorResponse response = new DKPLocatorResponse();
			XTreePath path;
			if (request.IncidentOID == Guid.Empty)
				path = locator.GetIncidentFullPath(context.Connection, request.IncidentNumber);
			else
				path = locator.GetIncidentFullPath(context.Connection, request.IncidentOID);

			response.Path = path.ToString();
			if (path.Length > 0)
				response.ObjectID = path[0].ObjectID;

			return response;
		}
	}
}
