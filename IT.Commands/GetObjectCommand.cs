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
	/// ���������������� ������� GetObject.
	/// ������ ������, ������������� �� ��������������� ������� ������ ���������� ��������� ����� �� ������� � �� ��������
	/// � ������������� �� �������� � �������� �������� ����������� �������
	/// </summary>
	[XTransaction(XTransactionRequirement.Supported)]
    [Serializable]
	public class GetObjectCommand: XCommand
	{
		// ��������� � ������� � ������� Request.PreloadProperties ������ �����
		private const string ERR_EMPTY_PRELOAD_PATH = "� ������� ����� �� ������ ���� ������ �����";

		/// <summary>
		/// ����� ���������� ��������, ���������� IXCommand.Execute
		/// </summary>
		///	<param name="request">������-������ �� ���������� ��������</param>
		/// <param name="context">������������� ��������� ���������� ��������</param>
		/// <returns>
		/// ��������� �������-���������� ���������� ��������
		/// </returns>
		public override XResponse Execute( XRequest request, IXExecutionContext context ) 
		{
			request.ValidateRequestType( typeof( XGetObjectRequest));

			// ���������� �������, ��������� �������������� ����������
			return this.Execute( (XGetObjectRequest)request, context );
		}

		/// <summary>
		/// ���������� ������� - �������������� �������
		/// </summary>
		/// <param name="request">������ �������, ������ ����� ��� XGetPropertyRequest</param>
		/// <param name="context">�������� ���������� �������</param>
		public XGetObjectResponse Execute( XGetObjectRequest request, IXExecutionContext context )
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			DomainObjectData xobj;
			if (request.ObjectID != Guid.Empty)
			{
				xobj = dataSet.Load(context.Connection, request.TypeName, request.ObjectID);
				// ���� ������ ������� ������������ �������, �������� � ��� ������:
				if (request.PreloadProperties != null)
				{
					// ...�� ������� ������ ������������ �������
					foreach(string sPropList in request.PreloadProperties)
					{
						// ���������, ��� � ������� �� �������� null � ������ ������
						if( null == sPropList)
							throw new ArgumentNullException( "PreloadProperties");
						if( String.Empty == sPropList)
							throw new ArgumentException( ERR_EMPTY_PRELOAD_PATH, "PreloadProperties");

						dataSet.PreloadProperty(context.Connection, xobj, sPropList);
					}
				}
			}
			else
			{
				xobj = dataSet.CreateNew(request.TypeName, false);
			}
			// ����������� ������� � ������������ ��������� � ������ ��� Web-�������
			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			XmlElement xmlObject = formatter.SerializeObject(xobj, request.PreloadProperties);
			if (request.ObjectID != Guid.Empty)
			{
				// ..���������� ������ � ��� ��������� ������� � ������������ ��������, ��������� �������� ����������� �������
				XmlObjectRightsProcessor.ProcessObject(xobj, xmlObject);
			}
			return new XGetObjectResponse(xmlObject);
		}
	}
}
