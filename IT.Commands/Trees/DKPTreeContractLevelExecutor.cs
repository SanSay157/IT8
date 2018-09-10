//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
//******************************************************************************
using System.Collections;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Trees
{
    /// <summary>
    /// Executor уровня tree-level с приходными договорами иерархии "ДКП"
    /// </summary>
    public class DKPTreeContractLevelExecutor : XTreeLevelExecutorStd
    {
        public override XTreeLevelInfoIT[] GetChildTreeLevels(XTreeLevelInfoIT treeLevelInfo, XParamsCollection treeParams)
        {

            //treeLevelInfo.GetChildTreeLevelsRuntime(treeParams);
            
            //Add(new XUserCodeWeb("DKP_ContractMenu_ExecutionHandler"));
                /*
                ArrayList aList = new ArrayList(treeLevelInfo.ChildTreeLevelsInfoMetadata.Length);
                foreach (XTreeLevelInfoIT levelInfo in treeLevelInfo.ChildTreeLevelsInfoMetadata)
                    if (levelInfo.ObjectType == "Contract")
                        aList.Add(levelInfo);
                if (aList.Count == 0)
                    return XTreeLevelInfoIT.EmptyLevels;
                else
                {
                    XTreeLevelInfoIT[] levels = new XTreeLevelInfoIT[aList.Count];
                    aList.CopyTo(levels);
                    return levels;
                }
                 */

            return base.GetChildTreeLevels(treeLevelInfo, treeParams);
        }
    }
}
