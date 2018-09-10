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
		/// ���������� �������������� �������� ��������� ������ (��� � ���������������� ��-�������� ��� ����) �������� ������ ��������
		/// </summary>
		/// <param name="con">���������� XStorageConnection</param>
		/// <returns></returns>
		XDataSource GetDataSource(XTreeLevelInfoIT treeLevelInfo, XStorageConnection con);

		XTreeLevelInfoIT[] GetChildTreeLevels(XTreeLevelInfoIT treeLevelInfo, XParamsCollection treeParams);
	}

	public class XTreeLevelExecutorStd : IXTreeLevelExecutor
	{
		/// <summary>
		/// ���������� �������������� �������� ��������� ������ (��� � ���������������� ��-�������� ��� ����) �������� ������ ��������
		/// </summary>
		/// <param name="con">���������� XStorageConnection</param>
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
	/// ��������� ������ �������� �������� (i:tree-level)
	/// </summary>
	public class XTreeLevelInfoIT : XMetadataInfoBase 
	{
		/// <summary>
		/// ������������ ������
		/// </summary>
		protected string m_sLevelName;
		/// <summary>
		/// �������� ������ ��������
		/// </summary>
		protected XTreeLevelInfoIT[] m_ChildTreeLevels;
		/// <summary>
		/// ������������ ��������� ������. 
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
		/// ���������� ������������ ������. ����� ���� �� ������ (String.Empty)
		/// </summary>
		public string Name
		{
			get { return m_sLevelName; }
		}

		/// <summary>
		/// ���������� ������� ������������� �������� ������
		/// </summary>
		public bool IsRecursive 
		{
			get { return m_bIsRecursive; }
			set { m_bIsRecursive = value; }
		}

		/// <summary>
		/// ��������� ������� ������������� �������� ������
		/// </summary>
		public bool IsVirtual 
		{
			get { return m_bIsVirtual; }
			set { m_bIsVirtual = value; }
		}

		/// <summary>
		/// ���������� ������������ ���� ��������, ������ �������� ������������
		/// �� ������ ������ �������� (� �����. � ���������; ���������� ���� 
		/// ������ ����� ���������� ������������ ������)
		/// </summary>
		public string ObjectType 
		{
			get { return m_sTypeName; }
			set { m_sTypeName = value; }
		}

		/// <summary>
		/// ���������� ����� ������
		/// ����� ��������������, ���� ������������ ���� �������� ����������������� 
		/// ������; ���� �� ������������ - ���������� ������ ������
		/// </summary>
		public string Alias 
		{
			get { return m_sAlias; }
			set { m_sAlias = value; }
		}


		/// <summary>
		/// ���������� XML-���� � ��������� ��������� ������ �������� ������ 
		/// ��������, �������������� ��������� ���� ����
		/// </summary>
		public XDataSourceInfo GetDataSourceInfo( DBMSType dbType ) 
		{
			return m_dsInfoCollection.Get( m_sDataSourceName, dbType );
		}

		/// <summary>
		/// ���������� �������������� �������� ��������� ������ (��� � ���������������� ��-�������� ��� ����) �������� ������ ��������
		/// </summary>
		/// <param name="con">���������� XStorageConnection</param>
		/// <returns></returns>
		public XDataSource GetDataSource(XStorageConnection con)
		{
			return m_executor.GetDataSource(this, con);
		}

		/// <summary>
		/// ���������� ������ �������������� �������� �������� ������� �������� �� ���������� (design-time)
		/// ��� ��������� ����������� ������� � runtime ������������ getRuntimeChildTreeLevels
		/// </summary>
		public XTreeLevelInfoIT[] ChildTreeLevelsInfoMetadata 
		{
			get { return m_ChildTreeLevels; }
			set { m_ChildTreeLevels = value; }
		}

		/// <summary>
		/// ���������� ������ ���������� �������������� �������� �������� ������� ��������.
		/// �.�. �������������� executor'�� � runtime'� �� ��������� ���������� � (��������) ���������� (ChildTreeLevelsInfoMetadata)
		/// </summary>
		/// <param name="treeParams"></param>
		/// <returns></returns>
		public virtual XTreeLevelInfoIT[] GetChildTreeLevelsRuntime(XParamsCollection treeParams)
		{
			return m_executor.GetChildTreeLevels(this, treeParams);
		}

		/// <summary>
		/// ���������� ������ �������������� �������� �������� ������� ��������
		/// ���� ������� ������� �����������, �� � � ������������ ��������� 
		/// ������������ �� ���
		/// </summary>
		/// <returns>������ �������������� �������� ������� ��������</returns>
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
		/// �������� ���� �� ����������
		/// </summary>
		public XTreeMenuHandler MenuHandler
		{
			get { return m_menuHandler; }
			set { m_menuHandler = value; }
		}

		/// <summary>
		/// ���������� �������������� �������� ���� ������.
		/// ����� ���� null, ���� ���� ��� ������ �� ����������.
		/// ��� ������������ null ������ ��������� �������� ���� �������� (XTreeMenuLoadProvider)
		/// </summary>
		/// <returns>��������� �������� ���� ������ ��������</returns>
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
