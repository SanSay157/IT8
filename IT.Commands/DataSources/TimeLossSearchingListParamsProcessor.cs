//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Xml;
using Croc.XmlFramework.Data;
using System.Collections.Generic;
using System.Text;

namespace Croc.IncidentTracker.DataSources
{
	/// <summary>
	/// Процессов параметров для источника данных списка TimeLossSearchingList.
	/// </summary>
	public class TimeLossSearchingListParamsProcessor: XDataSourceParamsProcessor
	{
		public TimeLossSearchingListParamsProcessor(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}

		public override void ProcessParams(IDictionary paramsValues, Dictionary<string,StringBuilder> hashConditions, XDbCommand cmd)
		{
			// если клиент не задал параметр Folders - список идентификаторов проектов, 
			// то выкусим параметр RecursiveFolderSearch, определяющий режим подстановки параметра Folders 
			if (!paramsValues.Contains("Folders"))
				paramsValues.Remove("RecursiveFolderSearch");

			// Если задан признак "Только мои списания" (только в списке TimeLossSearchingListAdm), 
			// то массивный параметр со списком сотрудников анализироваться не должен
			if (paramsValues.Contains("OnlyOwnTimeLoss") && (bool)paramsValues["OnlyOwnTimeLoss"])
				paramsValues.Remove("Employees");
		}
	}
}
