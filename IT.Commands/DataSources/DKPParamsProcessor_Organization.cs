//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
	/// Процессор параметров для упаковывания значений массивного параметра в DB-параметр типа image
	/// </summary>
	public class DKPParamsProcessor_Organization: XDataSourceParamsProcessor
	{
		public DKPParamsProcessor_Organization(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}

        public override void ProcessParams(IDictionary paramsValues, Dictionary<string, StringBuilder> hashConditions, XDbCommand cmd)
		{ 
			// из текста param-selector'a достанем наименование DB-параметра, который надо создать
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
				// иначе в качестве значения параметра передадим NULL
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
