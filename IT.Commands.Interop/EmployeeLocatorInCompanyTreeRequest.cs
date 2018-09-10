using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ �� ����� ���������� � ������ "��������� ��������"
	/// </summary>
	[Serializable]
	public class EmployeeLocatorInCompanyTreeRequest: XRequest
	{
		/// <summary>
		/// �������
		/// </summary>
		public string LastName;
		/// <summary>
		/// ������ ��������������� ������������ �����������
		/// </summary>
		public Guid[] IgnoredObjects;
		/// <summary>
		/// ��������� �������� �����������
		/// </summary>
		public bool AllowArchive;
	}
}
