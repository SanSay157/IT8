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
	/// �������� �������� ������ ds-�������, ��������� ���������� ����� ����������
	/// <seealso cref="DeleteObjectByExKeyRequest"/>
	/// </summary>
	/// <remarks>
	/// ���������� ����������� �������� DeleteObject (������ ���� ���������� � 
	/// ������������ ����������), �������� �������������� �������� ���� ����������� 
	/// ��������. � �������� ���������� ���������� ����������� �� ���������:
	/// <seealso cref="XDeleteObjectResponse"/>
	/// ��������!
	///		(1) ��� ������ ����� ��� �� ���������� guard-������, �����������
	///			��� �������� DeleteObject!
	///		(2) �������� ������� ������ ����� ���������� (��. ��������� ��������
	///			XTransaction); ��� ���� ����������� �������� DeleteObject ����� 
	///			������� � ��� �� ����������
	/// </remarks>
	[XTransaction(XTransactionRequirement.Required)]
    [Serializable]
	public class DeleteObjectByExKeyCommand : GetObjectIdByExKeyCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public XDeleteObjectResponse Execute( DeleteObjectByExKeyRequest request, IXExecutionContext context ) 
		{
			// ������: ������� ������������� ���������� �������: ������������� 
			// �������, ������������� � ������� ������:
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
			
			// ���������, �������� �� � ����� ������������� ������� (������ ��� 
			// ������ ��� ��� ������ ������������ ������������� ����� ��������):
			if (Guid.Empty==uidResultObjectID)
			{
				// ������� �������� ������� �� ������������ ����� � �������:
				// ���� ���������, ��� ������������� ������ - ��� ��������� 
				// ������, �� ���������� ������� ���������, �� � ����� � ���-��
				// ���-�� ������� ��������� ��������; ����� (����� ��� �� �������)
				// ���������� ����������:
				if (request.TreatNotExistsObjectAsDeleted)
					return new XDeleteObjectResponse( 0 );
				else
					throw new ArgumentException("������, �������� ���������� ����� �������, �� ������!");
			}

			// ������: �������� ����������� �������� �������� ������ ds-�������
			// �������� - ��� ������ ����� ��� �� ���������� guard-������, �����������
			// ��� �������� DeleteObject!
			XDeleteObjectRequest requestDeleteObject = new XDeleteObjectRequest( request.TypeName, uidResultObjectID );
			// ��������� ��������� �������� �� ��������� �������
			requestDeleteObject.SessionID = request.SessionID;
			requestDeleteObject.Headers.Add( request.Headers );
			
			return (XDeleteObjectResponse)context.ExecCommand( requestDeleteObject, true );
		}
	}
}