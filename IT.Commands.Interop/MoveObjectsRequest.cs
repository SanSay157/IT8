//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ������� �������� ��������
	/// </summary>
	[Serializable]
	public class MoveObjectsRequest: XRequest
	{
		/// <summary>
		/// ������������ ���� ������������ �������
		/// </summary>
		public string SelectedObjectType;
		/// <summary>
		/// ������ ��������������� ����������� ��������
		/// </summary>
		public Guid[] SelectedObjectsID;
		/// <summary>
		/// ������������� ������ �������� ��� Guid.Empty ��� �������� �� ������
		/// </summary>
		public Guid NewParent;
		/// <summary>
		/// ������������ �������� - ������ �� ������������ ������
		/// </summary>
		public string ParentPropName;
		/// <summary>
		/// ������������ �������� - ������ �� ��������� "����" - ��� ���������������� ������������ ��������,
		/// �.�. ����� ��� SelectedObjectType �������� �� ������������, 
		/// � ������� ��� ������� ����� ���������� �������� �������� SubTreeSelectorPropName.
		/// ��������� L/R-�������� �������������� � �������� ���� �����������.
		/// </summary>
		public string SubTreeSelectorPropName;
	}
}
