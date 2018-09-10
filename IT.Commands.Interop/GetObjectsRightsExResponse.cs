using System;
using System.Diagnostics;
using System.Xml.Serialization;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ��������� ����������� ����� �������� ������������ ��� �������� (� ��� ����� �����)
	/// ��� �������� �� ������� �������
	/// </summary>
	[Serializable]
	public class XObjectRightsDescr
	{
		/// <summary>
		/// ������ �������, ����������� ��� ��������� �������
		/// </summary>
		public string[] ReadOnlyProps;
		/// <summary>
		/// ������ �������� �������
		/// </summary>
		public bool DenyDelete;
		/// <summary>
		/// ������ ��������� �������
		/// </summary>
		public bool DenyChange;
		/// <summary>
		/// ������ �������� (������ ��� ����� ��������)
		/// </summary>
		public bool DenyCreate;
	}

	[Serializable]
	public class GetObjectsRightsExResponse: XResponse
	{
		/// <summary>
		/// ����� ����������� �������� (� �.�. �����)
		/// </summary>
		[XmlArrayItem(typeof(XObjectRightsDescr))]
		public XObjectRightsDescr[] ObjectsRights;

		/// <summary>
		/// ctor for XmlSerializer
		/// </summary>
		public GetObjectsRightsExResponse()
		{}

		/// <summary>
		/// ���������������� �����������
		/// </summary>
		/// <param name="rights"></param>
		public GetObjectsRightsExResponse(XObjectRightsDescr[] rights)
		{
			if (rights != null)
			{
				foreach(XObjectRightsDescr descr in rights)
				{
					if (descr.ReadOnlyProps != null && descr.ReadOnlyProps.Length > 0)
					{
						foreach(string sPropName in descr.ReadOnlyProps)
							if (sPropName == null || sPropName.Length == 0)
							{
								Debugger.Break();
								throw new ApplicationException("������ read-only ������� �� ������ ��������� null � ������ ������");
							}
					}
				}
			}
			ObjectsRights = rights;
		}
	}
}
