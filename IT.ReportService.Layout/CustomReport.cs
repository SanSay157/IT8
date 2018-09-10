using System;
using System.Collections.Specialized;
using System.IO;
using System.Text;
using System.Web;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	public abstract class CustomReport : Report
	{
		public CustomReport(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}
       
        protected override void WriteReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildReport(data);
        }
       internal static string xmlEncode(object s)
		{
			return HttpUtility.HtmlEncode("" + s);
		}
       protected abstract void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data);
		
      
	}
}