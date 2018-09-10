using System;
using System.Collections;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Core.Triggers
{
	/// <summary>
	/// Summary description for Trigger_ProcessNewObjectsForTests.
	/// </summary>
	[XTriggerDefinitionAttribute(XTriggerActions.Insert, XTriggerFireTimes.Before, XTriggerFireTypes.ForWholeDataSet, null)]
	public class Trigger_ProcessNewObjectsForTests: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			IEnumerator enumerator = args.DataSet.GetModifiedObjectsEnumerator(true);
			while(enumerator.MoveNext())
			{
				DomainObjectData xobj = (DomainObjectData)enumerator.Current;
				if (xobj.IsNew)
				{
				    //TODO Метод ChangeObjectIdentifier(изменение идентификатора нового объекта) был убран из solution
                }
			}
		}
	}
}
