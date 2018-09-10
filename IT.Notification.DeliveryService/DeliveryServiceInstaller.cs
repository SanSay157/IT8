using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;


namespace Croc.IncidentTracker.Notification.DeliveryService
{
	[RunInstaller(true)]
	public partial class DeliveryServiceInstaller : Installer
	{
		public DeliveryServiceInstaller()
		{
			InitializeComponent();
		}
	}
}
