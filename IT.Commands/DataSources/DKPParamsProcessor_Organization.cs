//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Xml;
using System.Text;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Core;

namespace Croc.IncidentTracker.DataSources
{
	/// <summary>
	/// ��������� ���������� ��� ������������ �������� ���������� ��������� � DB-�������� ���� image
	/// </summary>
	public class DKPParamsProcessor_Organization: XDataSourceParamsProcessor
	{
		public DKPParamsProcessor_Organization(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}

        public override void ProcessParams(IDictionary paramsValues, Dictionary<string, StringBuilder> hashConditions, XDbCommand cmd)
		{ 
			// �� ������ param-selector'a �������� ������������ DB-���������, ������� ���� �������
            string sPackedParamName = this.DataSourceInfo.Params["Directions"].GetParamProcessors()[0].Xml.InnerText;
			
			if (paramsValues.Contains("Directions"))
			{
				SQLUniqueidentifierListCreator listCreator = new SQLUniqueidentifierListCreator();
				foreach(Guid value in (IList)paramsValues["Directions"])
				{
					listCreator.AddValue(value);
				}
				paramsValues.Remove("Directions");
				byte[] data = listCreator.GetListAndReset();
				cmd.Parameters.Add(sPackedParamName, XPropType.vt_bin, ParameterDirection.Input, false, data);
			}
			else
			{
				// ����� � �������� �������� ��������� ��������� NULL
				cmd.Parameters.Add(sPackedParamName, XPropType.vt_bin, ParameterDirection.Input, false, DBNull.Value);
			}
            if (!paramsValues.Contains("ViewAllOrganizations"))
            {
                ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
                paramsValues.Add("ViewAllOrganizations", user.HasPrivilege(SystemPrivilegesItem.ViewAllOrganizations.Name));
            }
		}
	}
}
