//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System.Collections;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// Executor ������ tree-level � ������� �������� "������ ���"
	/// </summary>
	public class DKPTreeFolderLevelExecutor : XTreeLevelExecutorStd
	{
		public override XTreeLevelInfoIT[] GetChildTreeLevels(XTreeLevelInfoIT treeLevelInfo, XParamsCollection treeParams)
		{
			if (treeParams.Contains("OnlyFolders"))
			{
				// ������� ������ ������ � ����� Folder
				ArrayList aList = new ArrayList(treeLevelInfo.ChildTreeLevelsInfoMetadata.Length);
				foreach(XTreeLevelInfoIT levelInfo in treeLevelInfo.ChildTreeLevelsInfoMetadata)
					if (levelInfo.ObjectType == "Folder")
						aList.Add(levelInfo);
				if (aList.Count == 0)
					return XTreeLevelInfoIT.EmptyLevels;
				else
				{
					XTreeLevelInfoIT[] levels = new XTreeLevelInfoIT[aList.Count];
					aList.CopyTo(levels);
					return levels;
				}
			}
			return base.GetChildTreeLevels(treeLevelInfo, treeParams);
		}
	}
}
