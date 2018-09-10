using System;
using System.Xml;
using Croc.XmlFramework.Core.Configuration;

namespace Croc.IncidentTracker.Commands.Trees
{
	enum CASES
	{
		Nominative,		// ������������:  ���? ���?
		Genitive,		// �����������: ����? ����?
		Dative,			// ���������: ����? ����? (�)
		Accusative,		// �����������: ����? ���?
		Instrumental,	// ������������: ���? � ���? ("�����", "���" � "���")
		Prepositional	// ����������: � ���? � ���? ("�", � "�", � "���")
	}
	public class StdActions
	{
		public static readonly string DoCreate = "DoCreate";
		public static readonly string DoEdit = "DoEdit";
		public static readonly string DoDelete = "DoDelete";
		public static readonly string DoMove = "DoMove";
		public static readonly string DoNodeRefresh = "DoNodeRefresh";
		public static readonly string DoView = "DoView";
	}

	public class StdMenuUtils
	{
		public static string GetEmployeeReportURL(XConfig config, Guid EmployeeID)
		{
			// ���� �� �������� ���� � ���, �� ����� �������� ���������� �� IT
			object oConf = new object();
			if (config!=null)
				oConf = config.SelectNode("it:app-data/it:services-location/it:service-location[@service-type='NSI-Rep']").InnerText;
			if (oConf!=null & oConf.ToString()!=String.Empty) 
				return "nsi-redirect.aspx?OT=SystemUser&amp;ID=" + EmployeeID + "&amp;FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&amp;COMMAND=CARD";
			else
				return "x-get-report.aspx?NAME=r-Employee.xml&DontCacheXslfo=true&ID=" + EmployeeID;
		}
	}
}
