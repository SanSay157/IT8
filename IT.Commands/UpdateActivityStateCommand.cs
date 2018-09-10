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
using System.Security.Principal;
using System.Threading;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ��������� ��������� ����������
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	public class UpdateActivityStateCommand : XCommand 
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context ) 
		{
			return Execute((UpdateActivityStateRequest)request, context);
		}

		/// <summary>
		/// �������������� ����������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public XResponse Execute(UpdateActivityStateRequest request, IXExecutionContext context)
		{
			//��� ����, ����� ��������� ������ �� ����� ����������, ����������� � request.Initiator, 
			//��������� ��������� CurrentPrincipal 

			// ��� ������ �������� �������
			IPrincipal originalPrincipal = Thread.CurrentPrincipal;

			try
			{
				// ���� ��������� ��� ����������, ������� ��� ������������ � �������� CurrentPrincipal
				{
					var ds = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);

					if (request.Initiator != Guid.Empty)
					{
						var employee = ds.Load(context.Connection, "Employee", request.Initiator);
						var userID = employee.GetLoadedPropValue("SystemUser");
						if (userID == DBNull.Value) throw new XBusinessLogicException("��������� �� �������� ������������� �������");
						var user = ds.Load(context.Connection, "SystemUser", (Guid)userID);

						Thread.CurrentPrincipal = new GenericPrincipal(
							new GenericIdentity((string)user.GetLoadedPropValue("Login")),
							new string[] { "XUser" });
					}
				}

				// ���������� ������ ���������
				{
					var ds = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);

					// �������� ������
					var activity = ds.Load(context.Connection, "Folder", request.Activity);
					
					activity.SetUpdatedPropValue("State", request.NewState);
					// ���� ������, �� � �������� �������
					if (!String.IsNullOrEmpty(request.Description))
					{
						var description = activity.GetLoadedPropValueOrLoad(context.Connection, "Description");

						activity.SetUpdatedPropValue(
							"Description", 
							description == DBNull.Value || string.IsNullOrEmpty((string)description)
								? request.Description
								: string.Format("{0}\n{1}", (string)description, request.Description)
							);
					}

					XStorageGateway.Save(context, ds, Guid.NewGuid());
				}
			}
			finally
			{
				// � ����� ������ ������ ��� ��� ����
				Thread.CurrentPrincipal = originalPrincipal;
			}

			return new XResponse();
		}
	}
}
