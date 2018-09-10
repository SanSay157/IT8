//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� �������� ������ ds-������� � �������� ����� � �������������� �� ����
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	public class DeleteObjectCommand: XCommand 
	{
		/// <summary>
		/// ����� ���������� ��������, �������������� ����������
		/// </summary>
		///	<param name="oRequest">������-������ �� ���������� ��������</param>
		/// <param name="oContext">������������� ��������� ���������� ��������</param>
		/// <returns>
		/// ��������� �������-���������� ���������� ��������
		/// </returns>
		public XResponse Execute( XDeleteObjectRequest oRequest, IXExecutionContext oContext ) 
		{
			// �������� ���������� �������
			XRequest.ValidateRequiredArgument( oRequest.TypeName, "XDeleteObjectRequest.TypeName");
			XRequest.ValidateRequiredArgument( oRequest.ObjectID, "XDeleteObjectRequest.ObjectID");

			DomainObjectData objData = DomainObjectData.CreateStubLoaded( oContext.Connection, oRequest.TypeName, oRequest.ObjectID );
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights( objData );
			if (!rights.AllowDelete)
				throw new XSecurityException( String.Format(
						"���������� �������� ����������: ��� ���� �� �������� ������� \"{0}\" ({1}[oid='{2}'])", 
						objData.TypeInfo.Description,
						oRequest.TypeName,
						oRequest.ObjectID
					) );
			
			// �������� ����� ���������� Storage (������� Level-2); ��������� 
			// Storage ����������� � ������ ��������� ���������� ��������
			return new XDeleteObjectResponse( XStorageGateway.Delete(oContext, oRequest.TypeName, oRequest.ObjectID) );
		}
	}
}
