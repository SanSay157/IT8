//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;
using Croc.IncidentTracker.Commands; 

namespace Croc.IncidentTracker.Commands
{

	public enum UserSubscriptionForEventClassAction
	{
		ResetToDefaults,
		Unsubscribe,
		SwitchToDigestOnly
	}

	/// <summary>
	/// ������� ��� ���������� ��������� �������� ������������
	/// </summary>
	[Serializable]	
	public class UserSubscriptionForEventClassRequest:XRequest
	{
		public UserSubscriptionForEventClassAction Action = UserSubscriptionForEventClassAction.Unsubscribe;
		public int EventClass = 0;


		public UserSubscriptionForEventClassRequest()
		{
		}

		public UserSubscriptionForEventClassRequest(string sName) : base(sName)
		{
		}

		public UserSubscriptionForEventClassRequest(string sName, int eventClass) : base(sName)
		{
			EventClass = eventClass;
		}

		public UserSubscriptionForEventClassRequest(string sName, UserSubscriptionForEventClassAction action, int eventClass) : base(sName)
		{
			Action = action;
			EventClass = eventClass;
		}
	}
}
