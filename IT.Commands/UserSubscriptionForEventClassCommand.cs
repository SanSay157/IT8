//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;


namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� ���������� ��������� ��� �������� ������������
	/// </summary>
	[XTransaction(XTransactionRequirement.Required)]
	public class UserSubscriptionForEventClassCommand:XCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public virtual XResponse Execute( UserSubscriptionForEventClassRequest request, IXExecutionContext context )
		{
			// ������ ����� ������� ������������� ������������
			Guid employeeID =((ITUser)XSecurityManager.Instance.GetCurrentUser()).EmployeeID;

			// ���������� ������
			using(XDbCommand cmd = context.Connection.CreateCommand())
			{
				string sParamEmployeeID = context.Connection.GetParameterName("emp");
				string sParamEventClass = context.Connection.GetParameterName("evt");

				// �������
				StringBuilder sb = new StringBuilder();
				sb.AppendFormat(@"
SET NOCOUNT ON
SET ROWCOUNT 0

DELETE dbo.EventSubscription
WHERE [User]={0} 
	AND
	( 
		([EventCreationRule] IN (SELECT ObjectID FROM dbo.EventType WHERE EventType={1}))
		OR
		{1}=0
	)
", sParamEmployeeID, sParamEventClass);

				if( request.Action == UserSubscriptionForEventClassAction.SwitchToDigestOnly )
				{
					sb.AppendFormat(@"
INSERT INTO dbo.EventSubscription([User], [IncludeInDigest], [InstantDelivery], [EventCreationRule])
(
	SELECT {0}, 1, 0, ObjectID
	FROM dbo.EventType
	WHERE EventType={1} OR {1}=0
)
", sParamEmployeeID, sParamEventClass);
					
				}
				else if( request.Action == UserSubscriptionForEventClassAction.Unsubscribe )
				{
					sb.AppendFormat(@"
INSERT INTO dbo.EventSubscription([User], [IncludeInDigest], [InstantDelivery], [EventCreationRule])
(
	SELECT {0}, 0, 0, ObjectID
	FROM dbo.EventType
	WHERE EventType={1} OR {1}=0
)
", sParamEmployeeID, sParamEventClass);
				}

				cmd.CommandTimeout = int.MaxValue-128;
				cmd.CommandText = sb.ToString();
				cmd.Parameters.Add(sParamEmployeeID, employeeID);
				cmd.Parameters.Add(sParamEventClass, request.EventClass);

				cmd.ExecuteNonQuery();
			}
			return new XResponse();
		}
	}
}
