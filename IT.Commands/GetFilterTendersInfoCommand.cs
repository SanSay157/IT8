using System;
using System.Data;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда получения данных для фильтра списка тендеров
	/// </summary>
	public class GetFilterTendersInfoCommand: XCommand
	{
		public override XResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			request.ValidateRequestType( typeof( GetFilterTendersInfoRequest));

			// Вызывается частная, полностью типизированная реализация
			return this.Execute( (GetFilterTendersInfoRequest)request, context );
		}
        /// <summary>
        /// Команда получения данных для фильтра списка тендеров
        /// </summary>
		public GetFilterTendersInfoResponse Execute(GetFilterTendersInfoRequest request, IXExecutionContext context)
		{
			GetFilterTendersInfoResponse resp = new GetFilterTendersInfoResponse();

			using (XDbCommand cmd = context.Connection.CreateCommand())
			{
                // Если идентификатор тендера не задан
				if (request.SelectedTenderID == Guid.Empty)
				{
					cmd.CommandText = 
					@"SELECT TOP 1 ObjectID
						FROM dbo.Organization with (nolock)
						WHERE Home <> 0";
					object temp = cmd.ExecuteScalar();
					resp.OrganizationID = (temp == null) ?
						Guid.Empty : (Guid) temp;
				}
                // Если задан
                else
				{
					cmd.CommandText =
                    @"SELECT TOP 1 O.ObjectID, T.DocFeedingDate
						FROM dbo.Tender AS T with (nolock)
						LEFT JOIN dbo.Lot AS L with (nolock) ON L.Tender = T.ObjectID
						LEFT JOIN dbo.LotParticipant AS P with (nolock) ON P.Lot = L.ObjectID
						LEFT JOIN dbo.Organization AS O with (nolock) ON O.ObjectID = P.ParticipantOrganization
						WHERE O.OwnTenderParticipant <> 0
							AND T.ObjectID = @SelectedTenderID";
                    // Передадим в параметр ID тендера
					cmd.Parameters.Add("SelectedTenderID",
						DbType.Guid,
						ParameterDirection.Input,
						false,
						request.SelectedTenderID);
					
					using (IDataReader reader = cmd.ExecuteReader())
					{
                        
						if (reader.Read())
						{
                            // Проставим значения ID огранизации и "даты подачи документов"
							resp.OrganizationID = reader.IsDBNull(0) ?
								Guid.Empty : reader.GetGuid(0);
							resp.DocFeedingDate = reader.IsDBNull(1) ?
								DateTime.MinValue : reader.GetDateTime(1);
						}
						else
						{
							resp.OrganizationID = Guid.Empty;
							resp.DocFeedingDate = DateTime.MinValue;
						}
					}
				}
			}

			return resp;
		}
	}
}
