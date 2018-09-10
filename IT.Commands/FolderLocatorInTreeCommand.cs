//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Commands.Trees;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения полного пути в дереве "Клиенты и Проекты" для заданной папки
	/// </summary>
	public class FolderLocatorInTreeCommand: XCommand
	{
		public DKPLocatorResponse Execute(FolderLocatorInTreeRequest request, IXExecutionContext context)
		{
			DKPLocatorResponse response = new DKPLocatorResponse();
			DKPTreeObjectLocator locator = new DKPTreeObjectLocator();
            XTreePath path;
            if (request.FolderExID != null)
                path = locator.GetFolderFullPath(context.Connection, request.FolderExID);
            else
                path = locator.GetFolderFullPath(context.Connection, request.FolderOID);
            
            response.Path = path.ToString();
			if (path.Length > 0)
				response.ObjectID = request.FolderOID;
			return response;
		}
	}
}
