//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� �������� �������� ��������
	/// ������ ������, ������������� �� ��������������� ������� ������ ���������� ��������� ����� �� ������� � �� ��������
	/// � ������������� �� �������� � �������� �������� ����������� �������
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetPropertyCommand : XCommand
	{
		/// <summary>
		/// ���������� �������
		/// </summary>
		/// <param name="request">������ �������, ������ ����� ��� XGetPropertyRequest</param>
		/// <param name="context">�������� ���������� �������</param>
		/// <returns>XGetPropertyResponse</returns>
		public override XResponse Execute( XRequest request, IXExecutionContext context )
		{
			request.ValidateRequestType( typeof( XGetPropertyRequest));

			return this.Execute ( (XGetPropertyRequest)request, context );
		}

		/// <summary>
		/// ���������� ������� - �������������� �������
		/// </summary>
		/// <param name="request">������ �������, ������ ����� ��� XGetPropertyRequest</param>
		/// <param name="context">�������� ���������� �������</param>
		/// <returns>XGetPropertyResponse</returns>
		public new XGetPropertyResponse Execute( XGetPropertyRequest request, IXExecutionContext context )
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			// �������� �������� �������
			DomainObjectData xobj = dataSet.GetLoadedStub(request.TypeName, request.ObjectID);
			// �������� ��������
			dataSet.LoadProperty(context.Connection, xobj, request.PropName);
			// �������� �������������
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			// � ����������� �������� � XML
			XmlElement xmlProperty = formatter.SerializeProperty(xobj, request.PropName);
			// �� ���� �������� � �������� (LoadProperty ���������� �� ������ ��� ��������� ������� - ��� ��� bin � text)
			// ���������� ������ � ��� ��������� ������� � ������������ ��������, ��������� �������� ����������� �������
			foreach(XmlElement xmlObject in xmlProperty.SelectNodes("*[*]"))
			{
				DomainObjectData xobjValue = xobj.Context.Find(xmlObject.LocalName, new Guid(xmlObject.GetAttribute("oid")));
				if (xobjValue == null)
					throw new ApplicationException("�� ������� ����� � ��������� ��������������� ������� DomainObjectData ��� xml-�������-�������� �������� " + xmlProperty.LocalName + " ������� " + xmlObject.LocalName);
				XmlObjectRightsProcessor.ProcessObject(xobjValue, xmlObject);
			}
			XGetPropertyResponse response = new XGetPropertyResponse(xmlProperty);
			return response;
		}
	}
}
