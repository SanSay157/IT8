using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������ ������ �������� � ������
	/// </summary>
	[Serializable]
	public class TreeLocatorResponse: XResponse
	{
		/// <summary>
		/// ���� � ������ �� �������� ������� �� ����� � ������� CROC.XTreeView
		/// </summary>
		public string TreePath;
		/// <summary>
		/// ������������� ���������� �������. ���� ������ �� ������, �� Guid.Empty
		/// </summary>
		public Guid ObjectID;
		/// <summary>
		/// �������, ��� � �� ���� ��� ������� ���������������� �������� ������
		/// </summary>
		public bool More;

		/// <summary>
		/// ������������ ����������� ��� ��������������
		/// </summary>
		public TreeLocatorResponse()
		{}

		/// <summary>
		/// ctor
		/// </summary>
		/// <param name="sTreePath">���� � ������</param>
		/// <param name="oid">������������� ���������� �������</param>
		/// <param name="bMore">�������, ��� � �� ���� ��� ������� ���������������� �������� ������</param>
		public TreeLocatorResponse(string sTreePath, Guid oid, bool bMore)
		{
			TreePath = sTreePath;
			ObjectID = oid;
			More = bMore;
		}
	}
}
