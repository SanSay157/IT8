using System.ComponentModel;
using System.Xml.Schema;
using System.Xml.Serialization;
using Croc.IncidentTracker.ReportService.Reports;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts.Formatters
{
	/// <summary>
	/// �����-������������� ��� �������������� xml-�������� bigtext-evaluator
	/// </summary>
	[XmlType(Namespace="http://www.croc.ru/Schemas/IncidentTracker/ReportService")]
	public class bigtextevaluatorClass : abstractformatterClass
	{
        public bigtextevaluatorClass()
            : base("Croc.IncidentTracker.ReportService.Layouts.Formatters.BigTextEvaluator", @"Croc.IncidentTracker.ReportService.Layouts.dll") 
		{
		}
	}
	
	/// <summary>
	/// ����������� ������� ����� (��������� ������� ����� � ������������������ ������)
	/// </summary>
	public sealed class BigTextEvaluator : ReportAbstractFormatter
	{
		/// <summary>
		/// ���������� �������������� ������ �������
		/// </summary>
		/// <param name="profile">�������</param>
		/// <param name="data">����� �������� ������ ��� ��������������</param>
		protected override void DoExecute( abstractformatterClass profile, ReportFormatterData data)
		{
			// ���� ��� ��������, ������ �� ������
			if(null==data.CurrentValue) return;
			string sValue;
			data.CurrentValue = (sValue = "" + data.CurrentValue);
			if (sValue.Length==0) return;
			// �������������� �������
			//bigtextevaluatorClass durationEvaluatorProfile = (bigtextevaluatorClass) profile;
			data.CurrentValue =  CustomITrackerReport._LongText(sValue);
		}

	}
}
