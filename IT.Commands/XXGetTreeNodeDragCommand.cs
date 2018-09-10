using System;
using System.Xml;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Commands;

namespace Croc.XmlFramework.Extension.Commands
{
	/// <summary>
	/// �������� ��������� XML-�������� �������� ��������, ���������������� ���������� ����
	/// �������� ��������, ������������ ��� ������ ����������
	/// �������������������� Web-�������.
	/// </summary>
	/// <remarks>
	/// ����������� ���������� �������������������� Web-������� � XFW .NET
	/// �������� ��������� �������������� ������������� ������ ��������. ����
	/// ������������� ������������� �������������� ActiveX-����������� CROC.XTreeView
	/// ���������� CROC.XControls; �� �����
	/// ����� ��������� �������� ��������� ���������� �������� �������� ����� �
	/// ������������ � ��������� ����� � ��������.
	/// </remarks>                                                                                  
	public class XXGetTreeNodeDragCommand : XCommand 
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������. 
		/// �������������, ������ �������������� �����. ���������� �����.
		/// </summary>
		/// <param name="oRequest">������ �� ���������� ��������.</param>
		/// <param name="oContext">�������� ���������� ��������.</param>
		/// <returns>��������� ����������.</returns>
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance", "CA1822:MarkMembersAsStatic")]
		public XXGetNodeDragResponse Execute(XXGetTreeNodeDragRequest oRequest, IXExecutionContext oContext)
		{
			if (null == oRequest)
				throw new ArgumentNullException("oRequest");
			if (null == oContext)
				throw new ArgumentNullException("oContext");

			// �������� �������� ��������
			XTreeInfo treeInfo = XInterfaceObjectsHolder.Instance.GetTreeInfo(oRequest.MetaName, oContext.Connection);

			// �������� ������� ��������
			XTreeLevelInfo treeLevelInfo = treeInfo.GetTreeLevel(oRequest.Path.GetNodeTypes());

			// ��������� �������� ��������: 
			XXTreeNodeDrag treeNodeDrag = new XXTreeNodeDrag(treeLevelInfo, oContext.Connection.MetadataManager);

			if (treeNodeDrag.IsEmpty)
			{
				// ��� ���� ��� ������ ��������
				return new XXGetNodeDragResponse(null);
			}
			else
			{
				// ����� �������� �������� ��������; ���������� ���, �.�. ������ ��������� 
				// ��������������� �� XML, ������� ������ �������� ����������
				XmlElement xmlNodeDragNode = (XmlElement)treeNodeDrag.XmlNodeDrag.CloneNode(true);

				// ��������� ������� ������������ �������� �������� ��� ������� - ������� 
				// cache-for ���� i:node-drag; ��� ������� ������������ ��� �������� �������� � 
				// ����������; ���� �� ��������, ���������, ��� ����������� 
				// ������ ��� ������ (�.�. � �������� ����� ������������ ����):
				XTreeMenuCacheMode cacheMode = treeNodeDrag.CacheMode;
				if (cacheMode == XTreeMenuCacheMode.Unknow)
					cacheMode = XTreeMenuCacheMode.Level;
				xmlNodeDragNode.SetAttribute("cache-for", XTreeMenuCacheModeParser.ToString(cacheMode));

				return new XXGetNodeDragResponse(xmlNodeDragNode);
			}
		}
	}
}
