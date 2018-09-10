//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// Провайдер конструирования описания страницы иерархии (objects-tree, objects-tree-selector)
	/// </summary>
	public class TreePageWithAccessCheckInfoProvider : XTreePageInfoProviderStd
	{
		public TreePageWithAccessCheckInfoProvider(XMetadataManager mdManager)
			: base(mdManager)
		{}

		public override XTreePageInfo CreateTreePageInfo(XmlElement xmlTreePage)
		{
			TreePageWithAccessCheckInfo treePage = new TreePageWithAccessCheckInfo();
			base.initTreePageInfo(treePage, xmlTreePage);
			XPrivilegeSet privSet = new XPrivilegeSet();
			foreach(XmlElement xmlNode in xmlTreePage.SelectNodes("it-sec:access-requirements/*", m_mdManager.NamespaceManager))
			{
				string sPrivName = xmlNode.GetAttribute("n");
				ITSystemPrivilege priv = new ITSystemPrivilege( SystemPrivilegesItem.GetItem(sPrivName) );
				privSet.Add(priv);
			}
			treePage.AccessSecurity.SetRequiredPrivileges(privSet);
			return treePage;
		}
	}
}
