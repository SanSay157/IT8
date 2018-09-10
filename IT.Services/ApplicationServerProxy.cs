//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
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
		/// ������������ ��������� Remoting-������ ������ ���� (������ ���������� IT)
		/// </summary>
		private static IXFacade m_Facade = null;

		/// <summary>
		/// ���������� ������� ����������� �����������
		/// </summary>
		static ApplicationServerProxy() 
		{
            //string sConfigFileName = Path.Combine( System.AppDomain.CurrentDomain.BaseDirectory, "Web.config" );
            //System.Runtime.Remoting.RemotingConfiguration.Configure( sConfigFileName, true );
			m_Facade = XFacadeClientFactory.GetXFacadeClient(XFacadeServiceInterfaceType.Remoting, null);

			ObjectOperationHelper.AppServerFacade = m_Facade ;
		}
		
		/// <summary>
		/// ���������� ������������ ��������� Remoting-������ ������ ���� (������ ���������� IT)
		/// </summary>
		internal static IXFacade Facade 
		{
			get { return m_Facade; }
		}
	}
}