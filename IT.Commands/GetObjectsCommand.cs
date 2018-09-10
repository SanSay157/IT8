//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� ��������� XML-��������� � ������� ������ �������� ds-��������
	/// ������ ������, ������������� �� ��������������� ������� ������ ���������� ��������� ����� �� ������� � �� ��������
	/// � ������������� �� �������� � �������� �������� ����������� �������
	/// <seealso cref="XGetObjectsRequest"/>
	/// <seealso cref="XGetObjectsResponse"/>
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectsCommand : XCommand
	{
		/// <summary>
		/// �������� ��������� XML-��������� � ������� ������ �������� ds-��������
		/// �������������� ������ ������
		/// ������������� ���������� �����
		/// </summary>
		/// <param name="request">������ �� ��������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������� ��������</returns>
		public XGetObjectsResponse Execute(XGetObjectsRequest request, IXExecutionContext context) 
		{
			// �������� ��������� - ������ � �������� ����������������� ������
			// �������� ������ ���� �����, � �� ������ ���� ������:
			if ( null==request.List )
				throw new ArgumentNullException("request.List");
			if ( 0==request.List.Length )
				throw new ArgumentException("request.List");

			XmlDocument xmlDoc = new XmlDocument();
			XmlElement xmlRootElement = xmlDoc.CreateElement("root");
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			DomainObjectData xobj;

			foreach(XObjectIdentity i in request.List)
			{
				if (i.ObjectID== Guid.Empty)
				{
					xmlRootElement.AppendChild(context.Connection.Create(i.ObjectType, xmlDoc));
				}
				else
				{
					try
					{
						xobj = dataSet.Load(context.Connection, i.ObjectType, i.ObjectID);
						xmlRootElement.AppendChild( formatter.SerializeObject(xobj, xmlDoc) );
					}
					catch(XObjectNotFoundException)
					{
						XmlElement xmlStub = (XmlElement) xmlRootElement.AppendChild(
							context.Connection.CreateStub(i.ObjectType, i.ObjectID, xmlDoc) );
						xmlStub.SetAttribute("not-found", "1");
					}
				}
			}
			// �� ���� ����������� ��������
			foreach(XmlElement xmlObject in xmlRootElement.SelectNodes("*[*]"))
			{
				// ���������� ������ � ��� ��������� ������� � ������������ ��������, ��������� �������� ����������� �������
				if (!xmlObject.HasAttribute("new"))
				{
					DomainObjectData xobjValue = dataSet.Find(xmlObject.LocalName, new Guid(xmlObject.GetAttribute("oid")));
					if (xobjValue == null)
						throw new ApplicationException("�� ������� ����� � ��������� ��������������� ������� DomainObjectData ��� xml �������: " + xmlObject.OuterXml);
					
					XmlObjectRightsProcessor.ProcessObject(xobjValue, xmlObject);
				}
			}

			return new XGetObjectsResponse(xmlRootElement);
		}
	}
}
