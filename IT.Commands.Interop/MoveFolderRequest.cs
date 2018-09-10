using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ��� ������� "MoveObject"
	/// </summary>
	[Serializable]
	public class MoveFolderRequest: XRequest
	{
		/// <summary>
		/// ������ ��������������� ����������� �����
		/// </summary>
		public Guid[] ObjectsID;
		/// <summary>
		/// ������� �� ������������ ����� ��� Guid.Empty ��� �������� � ������
		/// </summary>
		public Guid NewParent;
		/// <summary>
		/// ������ �� �����������-�������
		/// </summary>
		public Guid NewCustomer;
		/// <summary>
		/// ������ �� ��� ��������� ������
		/// </summary>
		public Guid NewActivityType;
	}
}
