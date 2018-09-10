using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Hierarchy
{
	public interface IXTreeLevelExecutor
	{
		/// <summary>
		/// Возвращает типизированное описание источника данных (уже с конструированной БД-командой для него) текущего уровня иерархии
		/// </summary>
		/// <param name="con">реализация XStorageConnection</param>
		/// <returns></returns>
		XDataSource GetDataSource(XTreeLevelInfoIT treeLevelInfo, XStorageConnection con);

		XTreeLevelInfoIT[] GetChildTreeLevels(XTreeLevelInfoIT treeLevelInfo, XParamsCollection treeParams);
	}

	public class XTreeLevelExecutorStd : IXTreeLevelExecutor
	{
		/// <summary>
		/// Возвращает типизированное описание источника данных (уже с конструированной БД-командой для него) текущего уровня иерархии
		/// </summary>
		/// <param name="con">реализация XStorageConnection</param>
		/// <returns></returns>
		public virtual XDataSource GetDataSource(XTreeLevelInfoIT treeLevelInfo, XStorageConnection con)
		{
			return new XDataSource( treeLevelInfo.GetDataSourceInfo(con.Behavior.DBMSType), con);
		}

		public virtual XTreeLevelInfoIT[] GetChildTreeLevels(XTreeLevelInfoIT treeLevelInfo, XParamsCollection treeParams)
		{
			return treeLevelInfo.ChildTreeLevelsInfoMetadata;
		}

	}


	/// <summary>
	/// Описатель уровня иерархии объектов (i:tree-level)
	/// </summary>
	public class XTreeLevelInfoIT : XMetadataInfoBase 
	{
		/// <summary>
		/// Наименование уровня
		/// </summary>
		protected string m_sLevelName;
		/// <summary>
		/// Дечернии уровни иерархии
		/// </summary>
		protected XTreeLevelInfoIT[] m_ChildTreeLevels;
		/// <summary>
		/// Наименование источника данных. 
		/// </summary>
		protected string m_sDataSourceName;
		protected XDataSourceInfoCollection m_dsInfoCollection;
		protected IXTreeLevelExecutor m_executor;
		protected XTreeMenuHandler m_menuHandler;
		protected bool m_bIsRecursive;
		protected bool m_bIsVirtual;
		protected string m_sTypeName;
		protected string m_sAlias;

		public XTreeLevelInfoIT(string sName, IXTreeLevelExecutor executor, XDataSourceInfoCollection dsInfoCollection, string sDataSourceName)
		{
			if (sName == null)
				sName = String.Empty;
			m_sLevelName = sName;

			if (executor == null)
				throw new ArgumentNullException("executor");
			if (dsInfoCollection == null)
				throw new ArgumentNullException("dsInfoCollection");
			if (sDataSourceName == null)
				throw new ArgumentNullException("sDataSourceName");

			m_executor = executor;
			m_dsInfoCollection = dsInfoCollection;
			m_sDataSourceName = sDataSourceName;
		}

		/// <summary>
		/// Возвращает наименование уровня. Может быть не задано (String.Empty)
		/// </summary>
		public string Name
		{
			get { return m_sLevelName; }
		}

		/// <summary>
		/// Возвращает признак рекурсивности текущего уровня
		/// </summary>
		public bool IsRecursive 
		{
			get { return m_bIsRecursive; }
			set { m_bIsRecursive = value; }
		}

		/// <summary>
		/// Возрашает признак виртуальности текущего уровня
		/// </summary>
		public bool IsVirtual 
		{
			get { return m_bIsVirtual; }
			set { m_bIsVirtual = value; }
		}

		/// <summary>
		/// Возвращает наименование типа объектов, данные котороых отображаются
		/// на данном уровне иерархии (в соотв. с описанием; технически узлы 
		/// уровня могут отображать произвольные данные)
		/// </summary>
		public string ObjectType 
		{
			get { return m_sTypeName; }
			set { m_sTypeName = value; }
		}

		/// <summary>
		/// Возвращает алиас уровня
		/// Может использоваться, если наименование типа является зарезервированным 
		/// словом; если не используется - возвращает пустую строку
		/// </summary>
		public string Alias 
		{
			get { return m_sAlias; }
			set { m_sAlias = value; }
		}


		/// <summary>
		/// Возвращает XML-узел с описанием источника данных текущего уровня 
		/// иерархии, соответстующий заданному типу СУБД
		/// </summary>
		public XDataSourceInfo GetDataSourceInfo( DBMSType dbType ) 
		{
			return m_dsInfoCollection.Get( m_sDataSourceName, dbType );
		}

		/// <summary>
		/// Возвращает типизированное описание источника данных (уже с конструированной БД-командой для него) текущего уровня иерархии
		/// </summary>
		/// <param name="con">реализация XStorageConnection</param>
		/// <returns></returns>
		public XDataSource GetDataSource(XStorageConnection con)
		{
			return m_executor.GetDataSource(this, con);
		}

		/// <summary>
		/// Возвращает массив типизированных описаний дочерних уровней иерархии из метаданных (design-time)
		/// Для получения подчиненных уровней в runtime используется getRuntimeChildTreeLevels
		/// </summary>
		public XTreeLevelInfoIT[] ChildTreeLevelsInfoMetadata 
		{
			get { return m_ChildTreeLevels; }
			set { m_ChildTreeLevels = value; }
		}

		/// <summary>
		/// Возвращает массив актуальных типизированных описаний дочерних уровней иерархии.
		/// Т.е. сформированных executor'ом в runtime'е на основании параметров и (возможно) метаданных (ChildTreeLevelsInfoMetadata)
		/// </summary>
		/// <param name="treeParams"></param>
		/// <returns></returns>
		public virtual XTreeLevelInfoIT[] GetChildTreeLevelsRuntime(XParamsCollection treeParams)
		{
			return m_executor.GetChildTreeLevels(this, treeParams);
		}

		/// <summary>
		/// Возвращает массив типизированных описаний дочерних уровней иерархии
		/// Если текущий уровень рекурсивный, то в в возвращаемой коллекции 
		/// присутствует он сам
		/// </summary>
		/// <returns>Массив типизированных описаний уровней иерархии</returns>
		public XTreeLevelInfoIT[] GetChildTreeLevelsAffected(XParamsCollection treeParams) 
		{
			XTreeLevelInfoIT[] levels_bydesing = GetChildTreeLevelsRuntime(treeParams);
			XTreeLevelInfoIT[] levels;
			if (IsRecursive)
			{
				levels = new XTreeLevelInfoIT[levels_bydesing.Length + 1];
				levels[0] = this;
				for(int i = 1; i <= levels_bydesing.Length; ++i)
					levels[i] = levels_bydesing[i-1];
			}
			else
				levels = levels_bydesing;
			return levels;
		}

		/// <summary>
		/// Описание меню из метаданных
		/// </summary>
		public XTreeMenuHandler MenuHandler
		{
			get { return m_menuHandler; }
			set { m_menuHandler = value; }
		}

		/// <summary>
		/// Возвращает типизированное описание меню уровня.
		/// Может быть null, если меню для уровня не определено.
		/// Как воспринимать null решает провайдер загрузки меню иерархии (XTreeMenuLoadProvider)
		/// </summary>
		/// <returns>Объектное описание меню уровня иерархии</returns>
		public XTreeMenuInfo GetMenu(XGetTreeMenuRequest request, IXExecutionContext context)
		{
			if (m_menuHandler != null)
				return m_menuHandler.GetMenu(this, request, context);
			return null;
		}

		private static XTreeLevelInfoIT[] m_emptyTreeLevelsArray = new XTreeLevelInfoIT[0];
		public static XTreeLevelInfoIT[] EmptyLevels
		{
			get
			{
				return m_emptyTreeLevelsArray;
			}
		}
	}
}
