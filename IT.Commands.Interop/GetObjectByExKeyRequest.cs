//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;
namespace Croc.IncidentTracker.Commands 
{
	/// <summary>
	/// ������ �������� ��������� ������ ds-�������, ��������� ���������� 
	/// ����� ����������
	/// </summary>
	[Serializable]
	public class GetObjectByExKeyRequest : GetObjectIdByExKeyRequest
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetObjectByExKey";
			
		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public GetObjectByExKeyRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

		
		/// <summary>
		/// ������������������� �����������
		/// </summary>
		/// <param name="sTypeName">������������ ds-����</param>
		/// <param name="paramsCollection">
		/// ��������� ����������, �������� �������� �������, �� ������� 
		/// ������������ ����������� ��������� ds-�������
		/// </param>
		public GetObjectByExKeyRequest( string sTypeName, XParamsCollection paramsCollection ) 
		{
			Name = DEF_COMMAND_NAME;
			TypeName = sTypeName;
			Params = paramsCollection;
		}

		
		/// <summary>
		/// ��������� ������������ ���������� ������ �������
		/// </summary>
		public override void Validate() 
		{
			// ����������� �������� ������� ���������� - ��� �����������
			// ��������, ������������ ������� �� ����������� 
            XRequest.ValidateOptionalArgument(SessionID, "SessionID");

			// � ������� �� ������� ���� GetObjectIdByExKeyRequest, �����
			// ������������ ds-���� ������ ���� ������ ������. ��� ���� ���������
			// ������� ������������ ��������� ������ ������ � ��������� ds-���� -
			// ����� ������ �������� ����� �������������� ��� ����������� 
			// ��������������
			ValidateRequiredArgument( TypeName, "TypeName" );
		}
	}
}