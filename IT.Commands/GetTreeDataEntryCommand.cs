using System;
using System.Collections;
using System.IO;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	///  оманда получени€ данных иерархии
	/// </summary>
	public class GetTreeDataEntryCommand: XCommand
	{
		public XResponse Execute(XGetTreeDataRequest request, IXExecutionContext context)
		{
            
			XTreePageInfo treePage = XTreeController.Instance.GetPageInfo(request.MetaName);
            XTreeLoadData treeData= treePage.GetData(request, context);
                
            
			if (treeData == null)
				throw new ApplicationException("XTreePageInfo.GetData вернул null");
			
            return new XGetTreeDataResponse(treeData.Nodes.ToArray(), !treePage.OffShowIcons ? treePage.IconTemplateURI : String.Empty);
		}
	}
}
