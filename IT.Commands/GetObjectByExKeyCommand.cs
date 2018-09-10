//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� ��������� ������ ds-�������, ��������� ���������� ����� ����������
	/// <seealso cref="GetObjectByExKeyRequest"/>
	/// </summary>
	/// <remarks>
	/// ���������� ����������� �������� GetObject (������ ���� ���������� � 
	/// ������������ ����������), �������� �������������� �������� ���� ����������� 
	/// ��������. � �������� ���������� ���������� ����������� �� ���������:
	/// <seealso cref="XGetObjectResponse"/>
	/// �������� - ��� ������ ����� ��� �� ���������� guard-������, �����������
	/// ��� �������� GetObject!
	/// </remarks>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectByExKeyCommand : GetObjectIdByExKeyCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public XGetObjectResponse Execute( GetObjectByExKeyRequest request, IXExecutionContext context ) 
		{
			// ������: ������� ������������� �������: ������������� �������,
			// ������������� � ������� ������:
			Guid uidResultObjectID = Guid.Empty;

			// ���� � ������� ������ ������������ ��������� ������, �� ��� ��������� 
			// �������������� ������� ���������� ������ ���:
			if (null!=request.DataSourceName && 0!=request.DataSourceName.Length)
				uidResultObjectID = processDataSource(
					request.DataSourceName,
					request.Params,
					context.Connection );
			else 
				// ����� (������������ ��������� ������ �� ������) ��������� ����� 
				// ������ �� ��������� ObjectID
				uidResultObjectID = processExplicitObjectIdRequest( 
					request.TypeName,
					request.Params,
					context.Connection );
			
			// ���� � ����� ������������� ������� �� �������� - ���������� 
			// ����������, �.�. � ���� ������ ���������� ��������� ������ �������
			if (Guid.Empty==uidResultObjectID)
				throw new ArgumentException("������, �������� ���������� ����� �������, �� ������!");

			
			// ������: �������� ����������� �������� �������� ������
			// �������� - ��� ������ ����� ��� �� ���������� guard-������, �����������
			// ��� �������� GetObject!
			XGetObjectRequest requestGetObject = new XGetObjectRequest( request.TypeName, uidResultObjectID );
			// ��������� ��������� �������� �� ��������� �������
			requestGetObject.SessionID = request.SessionID;
			requestGetObject.Headers.Add( request.Headers );
			
			return (XGetObjectResponse)context.ExecCommand( requestGetObject, true );
		}
	}
}