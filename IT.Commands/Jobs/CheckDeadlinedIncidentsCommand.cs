using System.Data;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Удаляет неиспользуемые объекты из БД
	/// </summary>
	[XTransaction(XTransactionRequirement.Required)]
	public class CheckDeadlinedIncidentsCommand : XCommand
	{
		public override XResponse Execute(XRequest request, IXExecutionContext context) 
		{
			using(XDbCommand cmd = context.Connection.CreateCommand())
			{
				cmd.CommandType=CommandType.StoredProcedure;
				cmd.CommandText="dbo.app_messagingCheckIncidentsDeadline";
				cmd.CommandTimeout = int.MaxValue-128;
				cmd.ExecuteNonQuery();
			}
			return new XResponse();
		}
	}
}
