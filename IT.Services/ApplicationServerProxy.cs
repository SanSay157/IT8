//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.IO;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Remoting;
using Croc.XmlFramework.Client;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// 
	/// </summary>
    internal class ApplicationServerProxy
	{
		/// <summary>
		/// Единственный экземпляр Remoting-прокси фасада Ядра (сервер приложения IT)
		/// </summary>
		private static IXFacade m_Facade = null;

		/// <summary>
		/// Внутренний скрытый статический конструктор
		/// </summary>
		static ApplicationServerProxy() 
		{
            //string sConfigFileName = Path.Combine( System.AppDomain.CurrentDomain.BaseDirectory, "Web.config" );
            //System.Runtime.Remoting.RemotingConfiguration.Configure( sConfigFileName, true );
			m_Facade = XFacadeClientFactory.GetXFacadeClient(XFacadeServiceInterfaceType.Remoting, null);

			ObjectOperationHelper.AppServerFacade = m_Facade ;
		}
		
		/// <summary>
		/// Возвращает единственный экземпляр Remoting-прокси фасада Ядра (сервер приложения IT)
		/// </summary>
		internal static IXFacade Facade 
		{
			get { return m_Facade; }
		}
	}
}