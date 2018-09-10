//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� ��������� XML-������ ������� "��������� ������������", 
	/// ��������������� �������� ������������. ���� ������� �� ����������, 
	/// �������� ��������� ������, � ������� ����� ����������� ������ �� 
	/// ������������ (SystemUser). ��� �� � ���������� ������������ ������ 
	/// ���������� (Employee, �� ���������� ����� - �� SystemUser � Employee)
	/// 
	/// ��� ���������� - ����� ��, ��� � ��� �������� GetObject,
	/// <seealso cref="XGetObjectResponse"/>
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetCurrentUserProfileCommand : XCommand 
	{
		/// <summary>
		/// ����������� ������������ ��������� ������
		/// </summary>
		const string DEF_DATASOURCE_NAME = "GetEmployeeUsersProfileID";
		
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public XGetObjectResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			// #1: ���������� ������������� �������� ������������ 
			// ���������� ���������� ��������� ��������������
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			XParamsCollection datasourceParams = new XParamsCollection();
			datasourceParams.Add( "UserID", user.SystemUserID );

			
			// #2: ������ ������������� ������� - �������, ���������� � ������� 
			// �������������: ��������� ��� ����� ����������� ������, �������� 
			// � "��������� ������" 
			XDataSource dataSource = context.Connection.GetDataSource( DEF_DATASOURCE_NAME );
			dataSource.SubstituteNamedParams( datasourceParams, true );
			dataSource.SubstituteOrderBy();
			object oResult = dataSource.ExecuteScalar();
			// ���������, ��� � ���������� �� �������� GUID:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = context.Connection.Behavior.CastGuidValueFromDB( oResult );

			
			// #3: �������� ������ ������� � ���� ������������� ��������:
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj;

			if (Guid.Empty != uidResult)
			{
				// ������ ������� ��� ����; ��������� ������������
				xobj = dataSet.Load(context.Connection, "UserProfile", uidResult);
			}
			else
			{
				xobj = dataSet.CreateNew("UserProfile", false);
				// � ����� ������� �������� ������� ����� ����������� �������� �� �������� ������������
				xobj.SetUpdatedPropValue( "SystemUser", user.SystemUserID );
				// ������ "�����������" ��������� �������� �� ��������� - ������ ������� ����������
				xobj.SetUpdatedPropValue( "StartPage", StartPages.CurrentTaskList );
			}
			// ��������� ������ ������������ (SystemUser) � ���������� (Employee)
			dataSet.PreloadProperty(context.Connection, xobj, "SystemUser.Employee");

			// ����������� ������� � ������������ ��������� � ������ ��� Web-�������
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			// ... ��� ���� ���������, ��� � ��������������� ������ ������ ��� �� �������
			// ������ � ��������� ������������ � ����������:
			XmlElement xmlObject = formatter.SerializeObject( xobj, new string[]{"SystemUser.Employee"} );
			if (Guid.Empty!=uidResult)
			{
				// ..���������� ������ � ��� ��������� ������� � ������������ ��������, ��������� �������� ����������� �������
				XmlObjectRightsProcessor.ProcessObject(xobj, xmlObject);
			}

			return new XGetObjectResponse(xmlObject);
		}
	}
}