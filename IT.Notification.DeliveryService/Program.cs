using System;
using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;

namespace Croc.IncidentTracker.Notification.DeliveryService
{
	static class Program
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		static void Main()
		{

			ServiceBase[] ServicesToRun;
			ServicesToRun = new ServiceBase[] 
			{ 
				new DeliveryService() 
			};
			ServiceBase.Run(ServicesToRun);
		}
	}
}
