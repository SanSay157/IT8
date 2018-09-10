//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands 
{
	/// <summary>
	/// ������ �������� �������� ������ ds-�������, ��������� ���������� 
	/// ����� ����������
	/// </summary>
	[Serializable]
	public class DeleteObjectByExKeyRequest : GetObjectIdByExKeyRequest 
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "DeleteObjectByExKey";

		/// <summary>
		/// ���������� ����, ����������� �������������� ���������� �������.
		/// </summary>
		/// <remarks>
		/// ���������� ������� �������� � ��� ������, ���� ������, �������� ��� 
		/// ���������, �� ������:
		///		-- ���� �������� false - �������� ���������� ����������;
		///		-- ���� �������� true - �������� ������� �����������, �� � 
		///		���������� ���������� � ���-�� ��������� �������� ����������� 
		///		���� (��. <see cref="XDeleteObjectResponse"/>)
		/// </remarks>
		public bool TreatNotExistsObjectAsDeleted = false;
			
		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public DeleteObjectByExKeyRequest() 
		{
			Name = DEF_COMMAND_NAME;
		}

		
		/// <summary>
		/// ������������������� �����������
		/// </summary>
		/// <param name="sTypeName">������������ ds-����</param>
		/// <param name="paramsCollection">
		/// ��������� ����������, �������� �������� �������, �� ������� 
		/// ������������ ��������� ��������� ds-�������
		/// </param>
		public DeleteObjectByExKeyRequest( string sTypeName, XParamsCollection paramsCollection ) 
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
			base.Validate();

			// � ������� �� ������� ���� GetObjectIdByExKeyRequest, �����
			// ������������ ds-���� ������ ���� ������ ������. ��� ���� ���������
			// ������� ������������ ��������� ������ ������ � ��������� ds-���� -
			// ����� ������ �������� ����� �������������� ��� ����������� 
			// �������������� ���������� �������
			ValidateRequiredArgument( TypeName, "TypeName" );
		}
	}
}