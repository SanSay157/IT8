using System;
using System.Data;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
    /// <summary>
    /// Команда факторизации плановых платежей
    /// Алгоритм следующий:
    /// 1. Если есть плановые платежи:
    ///     а) Уменьшаем первый по дате плановый платеж на сумму факта, остаток переносим на 10 дней вперед
    ///     б) Если факт больше очередного планового платежа: удаляем (проставляем флаг "факторизовано") плановые платежи 
    /// 2. Если нет запланированных платежей, просто добавим факт
    /// </summary>
    public class FactorizeProjectOutcomeCommand : XCommand
    {
        public override XResponse Execute(XRequest request, IXExecutionContext context)
        {
            request.ValidateRequestType(typeof(FactorizeProjectOutcomeRequest));

            // Вызывается частная, полностью типизированная реализация
            return this.Execute((FactorizeProjectOutcomeRequest)request, context);
        }
        /// <summary>
        /// Команда факторизации плановых платежей
        /// </summary>
		public FactorizeProjectOutcomeResponse Execute(FactorizeProjectOutcomeRequest request, IXExecutionContext context)
        {
            FactorizeProjectOutcomeResponse resp = new FactorizeProjectOutcomeResponse();

            using (XDbCommand cmd = context.Connection.CreateCommand())
            {
                /*
                // Если идентификатор тендера не задан
                if (request.ContractID != Guid.Empty)
                {
                    cmd.CommandText =
                    @"SELECT TOP 1 O.ObjectID, T.DocFeedingDate
						FROM dbo.Tender AS T with (nolock)
						LEFT JOIN dbo.Lot AS L with (nolock) ON L.Tender = T.ObjectID
						LEFT JOIN dbo.LotParticipant AS P with (nolock) ON P.Lot = L.ObjectID
						LEFT JOIN dbo.Organization AS O with (nolock) ON O.ObjectID = P.ParticipantOrganization
						WHERE O.OwnTenderParticipant <> 0
							AND T.ObjectID = @ContractID";
                    // Передадим в параметр ID тендера
                    cmd.Parameters.Add("SelectedTenderID",
                        DbType.Guid,
                        ParameterDirection.Input,
                        false,
                        request.ContractID);

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
                */
            }

            return resp;
        }
    }
}
