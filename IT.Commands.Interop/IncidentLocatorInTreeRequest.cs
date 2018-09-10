using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������� ��� ������� IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class IncidentLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// ������������� ���������
		/// </summary>
		public Guid IncidentOID;
		/// <summary>
		/// ����� ���������
		/// </summary>
		public int IncidentNumber;

		public IncidentLocatorInTreeRequest()
			:base("IncidentLocatorInTree")
		{}

		/// <summary>
		/// �������� ���������� �������
		/// </summary>
		public override void Validate()
		{
			// ���� IncidentOID � IncidentNumber ��� �� ������ ��� ��� ������
			if (IncidentOID == Guid.Empty && IncidentNumber == 0 || IncidentOID != Guid.Empty && IncidentNumber > 0)
				throw new ArgumentException("������ ���� ����� ���� ������������� ���������, ���� ����� ���������");
		}

	}
}
