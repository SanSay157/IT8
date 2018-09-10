//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2007
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	
	/// <summary>
	/// ������ �������� ��������� ������ � ��������� ��������� ������������� 
	/// ������� � �������� ������ �������
	/// </summary>
	[Serializable]
	public class FactorizeProjectOutcomeRequest : XRequest
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "FactorizeProjectOutcome";
		
		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public FactorizeProjectOutcomeRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

        /// <summary>
        /// ������������� ���������� ��������
        /// </summary>
        public Guid ContractID;

        /// <summary>
        /// ��������� ������������ ���������� ������ �������
        /// </summary>
        public override void Validate() 
		{
			// ����������� �������� ������� ���������� - ��� �����������
			// ��������, ������������ ������� �� ����������� 
			base.Validate();

			// ������ ��������������� ����������� ������ ���� �����:
			ValidateRequiredArgument(ContractID, "ContractID");
		}
	}
}
