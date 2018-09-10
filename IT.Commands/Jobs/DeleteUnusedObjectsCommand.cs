using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Удаляет неиспользуемые объекты из БД
	/// </summary>
	public class DeleteUnusedObjectsCommand : XCommand
	{
		private const string DATASOURCE_NAME = "DeleteUnusedObjects";

		public override XResponse Execute(XRequest request, IXExecutionContext context) 
		{
			XDataSource ds = context.Connection.GetDataSource(DATASOURCE_NAME);
			ds.ExecuteScalar();
			
			return new XResponse();
		}
	}
}
