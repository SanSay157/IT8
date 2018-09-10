//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using Croc.IncidentTracker.Hierarchy;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Public;
using XTreeLevelInfoIT = Croc.IncidentTracker.Hierarchy.XTreeLevelInfoIT;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// Executor для структуры иерархии "Дерево ДКП".
	/// Выбирает корневые узлы в зависимости от параметра Mode
	/// </summary>
	public class DKPTreeStructExecutor : XTreeStructExecutorStd
	{
		protected override XTreeLevelInfoIT[] getRootsInternal(XTreeStructInfo treeStruct, XParamsCollection treeParams, XTreePath treePath)
		{
			DKPTreeModes mode;
			// получение корней при загрузке корней будем определять по параметру Mode,
			if (treePath == null)
			{
				int nMode;
				if (!treeParams.Contains("Mode"))
					throw new ArgumentException("Не задан обязательный параметр Mode - режим иерархии");
				string sMode = treeParams["Mode"].ToString();
				try
				{
					nMode = Int32.Parse(sMode);
				}
				catch(FormatException)
				{
					throw new ApplicationException("Некорректный формат параметра \"режим иерархии\": " + sMode);
				}
				mode = (DKPTreeModes)nMode;
			}
			// а получение корней в других случаях (при поиске описания узла, соответствующего пути) по типу 1-ой ноды в пути
			else
			{
				string sRootTypeName = treePath[treePath.Length-1].ObjectType;
				if (sRootTypeName == "Folder")
					mode = DKPTreeModes.Activities;
				else if (sRootTypeName == "Organization" || sRootTypeName == "HomeOrganization")
					mode = DKPTreeModes.Organizations;
				else
					throw new ArgumentException("Неизвестный тип корневого узла: " + sRootTypeName);
			}
			bool bAcceptOrganization = (mode == DKPTreeModes.Organizations);

			ArrayList aList = new ArrayList();
			foreach(XTreeLevelInfoIT levelInfo in treeStruct.RootTreeLevels)
			{
				if (
					(bAcceptOrganization && (levelInfo.ObjectType == "Organization" || levelInfo.ObjectType == "HomeOrganization"))
					|| 
					!bAcceptOrganization && levelInfo.ObjectType == "Folder"
					)
					aList.Add(levelInfo);
			}
			XTreeLevelInfoIT[] roots = new XTreeLevelInfoIT[aList.Count];
			aList.CopyTo(roots);
			return roots;
		}
	}
}
