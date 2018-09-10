//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ���������� (SaveObject)
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	[XRequiredRequestType(typeof(SaveObjectInternalRequest))]
	public class SaveObjectCommand : XSaveObjectCommand 
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public virtual XResponse Execute( SaveObjectInternalRequest request, IXExecutionContext context ) 
		{
			// #1: �������� ����
			// ����������: ������ ��� �����, � �� � ������, ���� ������������ �����������
			XSecurityManager sec_man = XSecurityManager.Instance;
			IEnumerator enumerator = request.DataSet.GetModifiedObjectsEnumerator(false);
			DomainObjectData xobj;
			while(enumerator.MoveNext())
			{
				xobj = (DomainObjectData)enumerator.Current;
				if (xobj.ToDelete)
					sec_man.DemandDeleteObjectPrivilege(xobj);
				else 
					sec_man.DemandSaveObjectPrivilege(xobj);
			}

			// #2: ������ ������
			XStorageGateway.Save(context, request.DataSet, request.TransactionID);

			// #3: ������� post-call-��������� (���� ������� ����������)
			//executePostCalls(request.PostCalls, context);

			// ������������ ���������� �������� �� ����������
			return new XResponse();
		}
	}
}
