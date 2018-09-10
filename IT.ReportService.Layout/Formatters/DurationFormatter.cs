using System;
using System.ComponentModel;
using System.Xml.Schema;
using System.Xml.Serialization;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;
using Croc.XmlFramework.ReportService.Utility;

namespace Croc.IncidentTracker.ReportService.Layouts.Formatters
{
	/// <summary>
	/// �����-������������� ��� �������������� xml-�������� duration-evaluator
	/// </summary>
	[XmlTypeAttribute(Namespace="http://www.croc.ru/Schemas/IncidentTracker/ReportService")]
	public class durationevaluatorClass : abstractformatterClass
	{
        public durationevaluatorClass()
            : base("Croc.IncidentTracker.ReportService.Layouts.Formatters.DurationEvaluator", @"Croc.IncidentTracker.ReportService.Layouts.dll") 
		{
		}
        [XmlAttributeAttribute("workday-duration", Form = XmlSchemaForm.Qualified)]
        [DefaultValueAttribute("600")]
        public string workdayDuration;

        [XmlAttributeAttribute("format", Form = XmlSchemaForm.Qualified)]
        [DefaultValueAttribute("0")]
        public string format;
	}
	
	/// <summary>
	/// ����������� ������� �����
	/// </summary>
	public sealed class DurationEvaluator : ReportAbstractFormatter
	{
		/// <summary>
		/// ������ ����������� ������
		/// </summary>
		public enum Format
		{
			DaysHoursMinutes = 0,
			Hours = 1
		}
	
		/// <summary>
		/// ���������� �������������� ������ �������
		/// </summary>
		/// <param name="profile">�������</param>
		/// <param name="data">����� �������� ������ ��� ��������������</param>
		protected override void DoExecute( abstractformatterClass profile, ReportFormatterData data)
        {
            // ���� ��� ��������, ������ �� ������
            string sValue = data.CurrentValue as string;
            if (sValue == null || sValue == string.Empty)
                return;
            int nValue = 0;
            nValue = Convert.ToInt32(sValue);
            
            // �������������� �������
            durationevaluatorClass durationEvaluatorProfile = (durationevaluatorClass)profile;
            MacroProcessor processor = new MacroProcessor(data, true);

            // ������� ������ �����������
            Format format = (Format)processInt(durationEvaluatorProfile.format, (int)Format.DaysHoursMinutes, processor);

            // ��������� ������� �������� � ����������� �� �������
            switch (format)
            {
                case Format.DaysHoursMinutes:
                    // ����������������� �������� ��� � �������
                    // ��������!!! ���� �� ������, �������, ��� 600
                    int workdayDuration = processInt(durationEvaluatorProfile.workdayDuration, 600, processor);
                    data.CurrentValue = Utils.FormatTimeDuration(nValue, workdayDuration);
                    break;

                case Format.Hours:
                    data.CurrentValue = string.Format("{0:0.##}", nValue / 60.0);
                    break;

            }
        }

		/// <summary>
		/// ����������� �������� � ������� ���������������
		/// </summary>
		/// <param name="value">��������, ������� ����� �������������</param>
		/// <param name="defaultValue">������������ �������� �� ���������</param>
		/// <param name="processor">��������������</param>
		/// <returns>����� ��������, ���������� ����� ������ ���������������</returns>
		private int processInt(string value, int defaultValue, MacroProcessor processor)
		{
			if (value == null || value == string.Empty)
				return defaultValue;
       
			string processedValue = processor.Process(value);
			if (processedValue == null || processedValue == string.Empty)
				return defaultValue;
            return Convert.ToInt32(processedValue);
            
		}
	}
}
