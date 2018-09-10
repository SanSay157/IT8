using System;
using System.Collections;
using System.Data;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Commands
{

	/// Получение балланса ДС в кассе.
	[XTransaction(XTransactionRequirement.Supported)]
    public class GetKassBallanceCommand : XCommand 
	{		
        public GetKassBallanceResponse Execute(GetKassBallanceRequest request, IXExecutionContext context) 
		{
			using( XDbCommand cmd = context.Connection.CreateCommand() )
			{
				
				cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "[dbo].[app_GetKassBallance]";
                GetKassBallanceResponse response = new GetKassBallanceResponse();
				using( IDataReader reader = cmd.ExecuteReader() )
				{
					if ( 0 != reader.FieldCount )
					{
						while ( reader.Read() )
						{
                            response.sKassBallance = reader.GetString(0);
						}
					}              
                    return response;
                }
			}
		}
	}
}