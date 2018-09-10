using System;
using System.Collections;
using System.Xml;
using Croc.XmlFramework.Data;
using System.Collections.Generic;
using System.Text;

namespace Croc.IncidentTracker.DataSources
{
	/// <summary>
	/// ��������� ���������� ��� ��������� ������ ������ IncidentSearchingList
	/// </summary>
	public class IncidentSearchingListParamsProcessor: XDataSourceParamsProcessor
	{
		public IncidentSearchingListParamsProcessor(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}

        public override void ProcessParams(IDictionary paramsValues, Dictionary<string, StringBuilder> hashConditions, XDbCommand cmd)
		{
            string searchString_1 = "i.Type = it.ObjectID";

            // ���� ������ �� ����� �������� Folders - ������ ��������������� ��������, 
			// �� ������� �������� RecursiveFolderSearch, ������������ ����� ����������� ��������� Folders 
			if (!paramsValues.Contains("Folders"))
				paramsValues.Remove("RecursiveFolderSearch");

            // ���� ������ �� ����� �������� Participants- ������ ��������������� ������������ � �������� �������� ExceptParticipants ����� false, 
            // �� ������� �������� ExceptParticipants, ������������ ����� ����������� ��������� Participants 
            if (!paramsValues.Contains("Participants"))
            {
                if (!paramsValues.Contains("ExceptParticipants")) paramsValues.Remove("ExceptParticipants");
                else if ((bool)paramsValues["ExceptParticipants"]==false) paramsValues.Remove("ExceptParticipants");
            }
              

            

		}
	}
}
