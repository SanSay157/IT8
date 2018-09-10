using System;
using System.Xml;
using System.Collections.Generic;
using System.Collections;
using System.Text;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Core;

namespace Croc.IncidentTracker.DataSources
{
    /// <summary>
    /// Процессор параметров для добавления значения параметра "ViewAllOrganizations" (признак наличия прав на просмотр организаций)
    /// </summary>
    class DKPParamsProcessor_Folder: XDataSourceParamsProcessor
    {
        public DKPParamsProcessor_Folder(XDataSourceInfo dsInfo, XmlElement xml, XmlNamespaceManager NSManager) 
			: base(dsInfo, xml, NSManager)
		{}
        public override void ProcessParams(IDictionary paramsValues, Dictionary<string, StringBuilder> hashConditions, XDbCommand cmd)
        {
            //
            if (!paramsValues.Contains("ViewAllOrganizations"))
            {
                ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
                paramsValues.Add("ViewAllOrganizations", user.HasPrivilege(SystemPrivilegesItem.ViewAllOrganizations.Name));
            }
        }
    }
}
