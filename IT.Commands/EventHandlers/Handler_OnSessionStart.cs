using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Events;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.EventHandlers
{
	/// <summary>
	/// Обработчик старта сессии
	/// </summary>
	public class Handler_OnSessionStart: IXEventHandler
	{
		public void HandleEvent(XEventArgs args, IXExecutionContextHandler context)
		{
			XSecurityManager.Instance.GetCurrentUser();
		}
	}
}