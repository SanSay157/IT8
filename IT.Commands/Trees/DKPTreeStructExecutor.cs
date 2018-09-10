//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
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
	/// Executor ��� ��������� �������� "������ ���".
	/// �������� �������� ���� � ����������� �� ��������� Mode
	/// </summary>
	public class DKPTreeStructExecutor : XTreeStructExecutorStd
	{
		protected override XTreeLevelInfoIT[] getRootsInternal(XTreeStructInfo treeStruct, XParamsCollection treeParams, XTreePath treePath)
		{
			DKPTreeModes mode;
			// ��������� ������ ��� �������� ������ ����� ���������� �� ��������� Mode,
			if (treePath == null)
			{
				int nMode;
				if (!treeParams.Contains("Mode"))
					throw new ArgumentException("�� ����� ������������ �������� Mode - ����� ��������");
				string sMode = treeParams["Mode"].ToString();
				try
				{
					nMode = Int32.Parse(sMode);
				}
				catch(FormatException)
				{
					throw new ApplicationException("������������ ������ ��������� \"����� ��������\": " + sMode);
				}
				mode = (DKPTreeModes)nMode;
			}
			// � ��������� ������ � ������ ������� (��� ������ �������� ����, ���������������� ����) �� ���� 1-�� ���� � ����
			else
			{
				string sRootTypeName = treePath[treePath.Length-1].ObjectType;
				if (sRootTypeName == "Folder")
					mode = DKPTreeModes.Activities;
				else if (sRootTypeName == "Organization" || sRootTypeName == "HomeOrganization")
					mode = DKPTreeModes.Organizations;
				else
					throw new ArgumentException("����������� ��� ��������� ����: " + sRootTypeName);
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
