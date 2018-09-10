//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
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
	/// ��������� ���������� ��� ��������� ������ ������ TimeLossSearchingList.
	/// </summary>
	public class TimeLossSearchingListParamsProcessor: XDataSourceParamsProcessor
	{
		public TimeLossSearchingListParamsProcessor(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}

		public override void ProcessParams(IDictionary paramsValues, Dictionary<string,StringBuilder> hashConditions, XDbCommand cmd)
		{
			// ���� ������ �� ����� �������� Folders - ������ ��������������� ��������, 
			// �� ������� �������� RecursiveFolderSearch, ������������ ����� ����������� ��������� Folders 
			if (!paramsValues.Contains("Folders"))
				paramsValues.Remove("RecursiveFolderSearch");

			// ���� ����� ������� "������ ��� ��������" (������ � ������ TimeLossSearchingListAdm), 
			// �� ��������� �������� �� ������� ����������� ��������������� �� ������
			if (paramsValues.Contains("OnlyOwnTimeLoss") && (bool)paramsValues["OnlyOwnTimeLoss"])
				paramsValues.Remove("Employees");
		}
	}
}
