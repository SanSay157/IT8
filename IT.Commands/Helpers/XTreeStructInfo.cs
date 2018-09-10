using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Hierarchy
{
	public class XTreeLevelInfoITRef
	{
		private XTreeLevelInfoIT m_levelInfo;
		private XTreeStructInfo m_ownerTreeStruct;
		private XTreeLevelInfoITRef m_parent;
		private XTreeLevelInfoITRef[] m_children;

		public XTreeLevelInfoITRef(XTreeLevelInfoITRef parent, XTreeLevelInfoIT levelInfo)
		{
			LevelInfo = levelInfo;
			m_parent = parent;
			m_ownerTreeStruct = parent.OwnerTreeStruct;
		}

		public XTreeLevelInfoITRef(XTreeStructInfo ownerTreeStruct, XTreeLevelInfoIT levelInfo)
		{
			LevelInfo = levelInfo;
			m_ownerTreeStruct = ownerTreeStruct;
			m_children = new XTreeLevelInfoITRef[levelInfo.ChildTreeLevelsInfoMetadata.Length];
			int i = -1;
			foreach(XTreeLevelInfoIT childLevelInfo in levelInfo.ChildTreeLevelsInfoMetadata)
			{
				m_children[++i] = new XTreeLevelInfoITRef(this, childLevelInfo);
			}
		}

		public XTreeLevelInfoIT LevelInfo
		{
			get { return m_levelInfo; }
			set
			{
				if (value == null)
					throw new ArgumentNullException();
				m_levelInfo = value;
			}
		}

		public XTreeStructInfo OwnerTreeStruct
		{
			get { return m_ownerTreeStruct; }
		}

		public XTreeLevelInfoITRef Parent
		{
			get { return m_parent; }
		}

		public XTreeLevelInfoITRef[] Children
		{
			get { return m_children; }
		}
	}

	public interface IXTreeStructExecutor
	{
		XTreeLevelInfoIT[] GetRoots(XTreeStructInfo treeStruct, XParamsCollection treeParams);
		XTreeLevelInfoIT GetTreeLevel(XTreeStructInfo treeStruct, XParamsCollection treeParams, XTreePath treePath);
	}

	public class XTreeStructExecutorStd : IXTreeStructExecutor
	{
		public virtual XTreeLevelInfoIT[] GetRoots(XTreeStructInfo treeStruct, XParamsCollection treeParams)
		{
			return getRootsInternal(treeStruct, treeParams, null);
		}

		protected virtual XTreeLevelInfoIT[] getRootsInternal(XTreeStructInfo treeStruct, XParamsCollection treeParams, XTreePath treePath)
		{
			return treeStruct.RootTreeLevels;
		}

		/// <summary>
		/// Возвращает метаописание уровня (i:tree-level) иерархии, соответствующего "пути"
		/// </summary>
		/// <returns>Объект-описатель уровня иерархии</returns>
		public virtual XTreeLevelInfoIT GetTreeLevel(XTreeStructInfo treeStruct, XParamsCollection treeParams, XTreePath treePath) 
		{
			string[] nodesTypes = treePath.GetNodeTypes();
			string sIgnoreType = String.Empty;	// наименование игнорируемого типа из переданного пути (в случае рекурсии)
			XTreeLevelInfoIT treelevel = null;
			XTreeLevelInfoIT[] treelevels;
			bool bFound;
			for (int i = nodesTypes.Length-1; i>=0; i--)
			{
				if (sIgnoreType != nodesTypes[i])
				{
					bFound = false;
					if (treelevel == null)
						treelevels = getRootsInternal(treeStruct, treeParams, treePath);
					else
						treelevels = treelevel.GetChildTreeLevelsRuntime(treeParams);
					foreach(XTreeLevelInfoIT childLevel in treelevels)
						if (childLevel.ObjectType == nodesTypes[i])
						{
							treelevel = childLevel;
							bFound = true;
							break;
						}
					if (!bFound)
						throw new XTreeStructException("Не найдено описания уровня иерархии, соответствующего заданному пути");
					// если у текущего уровня стоит признак рекурсии, то надо пропускать все 
					// последующие типы в пути до тех пор, пока не встретится другой тип:
					if (treelevel.IsRecursive)
						sIgnoreType = nodesTypes[i];
					else
						sIgnoreType = String.Empty;
				}
			}
			return treelevel;
		}
	}

	/// <summary>
	/// Описатель иерархии объектов (i:objects-tree)
	/// </summary>
	public class XTreeStructInfo : XMetadataInfoBase 
	{
		/// <summary>
		/// Метанаименование иерархии.
		/// Соответствует значению атрибута n элемента описания иреархии
		/// объектов, objects-tree
		/// </summary>
		protected string m_sName;
		/// <summary>
		/// Массив описателей корневых уровней иерархии
		/// </summary>
		protected XTreeLevelInfoIT[] m_rootLevels;
		/// <summary>
		/// Ссылка на инциализированный объект XMetadataManager, описатель метаданных. 
		/// </summary>
		protected XMetadataManager m_mdManager;
		protected IXTreeStructExecutor m_executor;

		public XTreeStructInfo(string sName, XTreeLevelInfoIT[] roots, IXTreeStructExecutor executor)
		{
			if (sName == null)
				throw new ArgumentNullException("sName");
			if (roots == null)
				throw new ArgumentNullException("root");
			if (executor == null)
				throw new ArgumentNullException("executor");

			m_sName = sName;
			m_rootLevels = roots;
			m_executor = executor;
		}


		public IXTreeStructExecutor Executor
		{
			get { return m_executor; }
		}

		/// <summary>
		/// Возвращает массив типизированных описаний корневых узлов иерархии
		/// </summary>
		/// <returns></returns>
		public XTreeLevelInfoIT[] RootTreeLevels 
		{
			get { return m_rootLevels; }
		}
		
		/// <summary>
		/// Метанаименование иерархии.
		/// Соответствует значению атрибута n элемента описания иреархии
		/// объектов, objects-tree
		/// </summary>
		public string Name 
		{
			get { return m_sName; }
		}
	}
}
