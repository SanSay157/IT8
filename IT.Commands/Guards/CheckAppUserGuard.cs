//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System.Security;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands.Guards
{
	/// <summary>
	/// �����, 
	/// </summary>
	public class CheckAppUserGuard: XGuard
	{
		public override bool HasRightsToExecute(XRequest request, IXExecutionContextGuard context)
		{
			try
			{
				XSecurityManager.Instance.GetCurrentUser();
				return true;
			}
			catch(SecurityException)
			{
				return false;
			}
			catch
			{
				throw;
			}
		}
	}
}
