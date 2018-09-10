using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������� ��� ������� IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class ContractLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// ������������� ��������
		/// </summary>
		public Guid ContractOID;
		/// <summary>
		/// ��� �������
		/// </summary>
		public string ExternalID;

        public ContractLocatorInTreeRequest()
            : base("ContractLocatorInTreeRequest")
		{}

		/// <summary>
		/// �������� ���������� �������
		/// </summary>
		public override void Validate()
		{
			// ���� IncidentOID � IncidentNumber ��� �� ������ ��� ��� ������
			if (ContractOID == Guid.Empty && ExternalID == string.Empty || ContractOID != Guid.Empty && ExternalID != string.Empty)
				throw new ArgumentException("������ ���� ����� ���� ��� �������, ���� ������������� ���������� ��������");
		}

	}
}
