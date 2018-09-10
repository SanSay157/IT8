using System.ComponentModel;
using System.Xml.Schema;
using System.Xml.Serialization;
using Croc.IncidentTracker.ReportService.Reports;
using Croc.XmlFramework.ReportService.Layouts.Formatters;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Layouts.Formatters
{
	/// <summary>
	/// Класс-представитель для десериализации xml-элемента bigtext-evaluator
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
	/// Форматирует длинный текст (выполняет перенос строк и автоформатирование ссылок)
	/// </summary>
	public sealed class BigTextEvaluator : ReportAbstractFormatter
	{
		/// <summary>
		/// Производит форматирование ячейки таблицы
		/// </summary>
		/// <param name="profile">Профиль</param>
		/// <param name="data">Набор исходных данных для форматировщика</param>
		protected override void DoExecute( abstractformatterClass profile, ReportFormatterData data)
		{
			// если нет значения, ничего не делаем
			if(null==data.CurrentValue) return;
			string sValue;
			data.CurrentValue = (sValue = "" + data.CurrentValue);
			if (sValue.Length==0) return;
			// типизированный профиль
			//bigtextevaluatorClass durationEvaluatorProfile = (bigtextevaluatorClass) profile;
			data.CurrentValue =  CustomITrackerReport._LongText(sValue);
		}

	}
}
