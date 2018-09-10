//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ���������� ������������� �� xml-������� �������� �������ybz �������
	/// ����� �� ������, ��������� � ��������. ��������, ����������� ��� ������, ��������� �� xml-�������.
	/// ��������, ����������� ��� ���������, ���������� ��������� read-only. 
	/// ������� ����������� ��� �������� ���������� ��������� deny-delete. 
	/// �������, ����������� ��� ���������, ���������� ��������� deny-change.
	/// </summary>
	public class XmlObjectRightsProcessor
	{
		public const string ATTR_READONLY	= "read-only";		// ������� �������� - ��������� ��������
		public const string ATTR_DELETE_RIGHT = "delete-right";	// ������� ������� - ��������� �������
		public const string ATTR_CHANGE_RIGHT = "change-right";	// ������� ������� - ��������� �������� ���� ������

		public static void ProcessObject(DomainObjectData xobj, XmlElement xmlObject)
		{
			if (xobj == null)
				throw new ArgumentNullException("xobj", "�� ������ �������������� ������������� �������");
			if (xmlObject == null)
				throw new ArgumentNullException("xmlObject");
			if (xobj.Context == null)
				throw new ArgumentException("��������� DomainObjectData ������ ���������� � ��������� (DomainObjectDataSet)");
			XmlElement xmlProp;
			
			// ������� ����� �������� ������������ ���������� �� ����������� ������
			XObjectRights rights = XSecurityManager.Instance.GetObjectRights(xobj);
			if (!rights.AllowParticalOrFullRead)
				throw new XSecurityException("������ ������� " + xobj.ObjectType + "[" + xobj.ObjectID.ToString() + "] ���������");
			// ����� �� �������� �������
			xmlObject.SetAttribute(ATTR_DELETE_RIGHT, rights.AllowDelete ? "1" : "0");
			// ���� ������ ��������� �������� (���� �� ���� ��������) - ������� ���������
			xmlObject.SetAttribute(ATTR_CHANGE_RIGHT, rights.AllowParticalOrFullChange ? "1" : "0");
			if (rights.AllowParticalOrFullChange && rights.HasReadOnlyProps)
			{
				// ����� �������� ������, �� ���� read-only ��������
				foreach(string sProp in rights.GetReadOnlyPropNames())
				{
					xmlProp = (XmlElement)xmlObject.SelectSingleNode(sProp);
					/* ������ �� ������������� 
                      if (xmlProp == null)
						throw new ApplicationException("���������� ����������� ������� ������� � �������� ���� �� ������ " + xmlObject.LocalName + " read-only ��������, ������� ����������� � xml-�������: " + sProp); */
                    if (xmlProp != null)
                    xmlProp.SetAttribute(ATTR_READONLY, "1");
				}
			}

			if (rights.HasHiddenProps)
			{
				foreach(string sProp in rights.GetHiddenPropNames())
				{
					xmlProp = (XmlElement)xmlObject.SelectSingleNode(sProp);
					if (xmlProp != null)
						xmlObject.RemoveChild(xmlProp);
				}
			}
			// �� ���� ��������-��������� � ������������ ��������� 
			foreach(XmlElement xmlObjectValue in xmlObject.SelectNodes("*/*[*]"))
			{
				DomainObjectData xobjValue = xobj.Context.Find(xmlObjectValue.LocalName, new Guid(xmlObjectValue.GetAttribute("oid")));
				if (xobjValue == null)
					throw new ApplicationException("�� ������� ����� � ��������� ��������������� ������� DomainObjectData ��� xml-�������-�������� �������� " + xmlObjectValue.ParentNode.LocalName + " ������� " + xmlObject.LocalName);
				ProcessObject(xobjValue, xmlObjectValue);
			}
		}
	}
}
