//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Diagnostics;
using System.Xml;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	class PreloadsNavigator
	{
		protected int m_nIndex;
		protected int m_nMaxIndex;
		protected string[][] m_aPreloads;

		public PreloadsNavigator(string[] aPreloadProperties)
		{
			m_aPreloads = new string[aPreloadProperties.Length][];
			m_nMaxIndex = -1;
			for(int i=0;i<aPreloadProperties.Length;++i)
			{
				m_aPreloads[i] = aPreloadProperties[i].Split('.');
				if (m_aPreloads[i].Length > m_nMaxIndex)
					m_nMaxIndex = m_aPreloads[i].Length;
			}
			m_nIndex = -1;
		}

		public bool MoveNext()
		{
			if (m_nIndex < m_nMaxIndex)
				++m_nIndex;
			else
				return false;
			return true;
		}

		public void MoveBack()
		{
			if (m_nIndex > 0)
				--m_nIndex;
		}

		public bool HasProp(string sPropName)
		{
			if (m_nIndex < 0 || m_nIndex > m_nMaxIndex)
				return false;
			foreach(string[] aProps in m_aPreloads)
			{
				if (aProps.Length > m_nIndex && aProps[m_nIndex] == sPropName)
					return true;
			}
			return false;
		}
	}

	/// <summary>
	/// 
	/// </summary>
	public class DomainObjectDataXmlFormatter
	{
		private XMetadataManager m_mdManager;

		public DomainObjectDataXmlFormatter(XMetadataManager mdManager)
		{
			m_mdManager = mdManager;
		}

		public XmlElement SerializeObject(DomainObjectData xobj)
		{
			XmlDocument xmlDoc = new XmlDocument();
			XmlElement xmlObject = SerializeObject(xobj, xmlDoc);
			return (XmlElement )xmlDoc.AppendChild(xmlObject);
		}

		public XmlElement SerializeObject(DomainObjectData xobj, string[] aPreloadProperties)
		{
			XmlDocument xmlDoc = new XmlDocument();
			XmlElement xmlObject = SerializeObject(xobj, xmlDoc, aPreloadProperties);
			return (XmlElement )xmlDoc.AppendChild(xmlObject);
		}

		public XmlElement SerializeObject(DomainObjectData xobj, XmlDocument xmlDoc)
		{
			return SerializeObject(xobj, xmlDoc, null);
		}

		public XmlElement SerializeObject(DomainObjectData xobj, XmlDocument xmlDoc, string[] aPreloadProperties)
		{
			PreloadsNavigator nav = null;
			if (aPreloadProperties != null)
				nav = new PreloadsNavigator(aPreloadProperties);
			return serializeObject(xobj, xmlDoc, nav);
		}

		public XmlElement SerializeProperty(DomainObjectData xobj, string sPropName)
		{
			XmlDocument xmlDoc = new XmlDocument();
			XmlElement xmlProp;						// ���� �� ��������� ��������
			xmlDoc.AppendChild(xmlProp = xmlDoc.CreateElement( sPropName));	// ������� �������� �������
			// ��������� ������������ ���� urn:schemas-microsoft-com:datatypes
			xmlDoc.DocumentElement.SetAttribute("xmlns:dt", "urn:schemas-microsoft-com:datatypes");

			serializePropertyInternal(xobj, xmlProp, new PreloadsNavigator(new string[] {sPropName}));
			return xmlProp;
		}

		private void serializePropertyInternal(DomainObjectData xobj, XmlElement xmlProp, PreloadsNavigator nav)
		{
			DomainObjectDataSet dataSet = xobj.Context;
			string sPropName;
			object vPropValue;

			sPropName = xmlProp.LocalName;
			XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
			switch(propInfo.VarType)
			{
				case XPropType.vt_bin:
				case XPropType.vt_text:
					writeLOBProp(xobj, xmlProp, propInfo);
					break;                    
				case XPropType.vt_object		:
					if (propInfo is XPropInfoObjectScalar)
					{
						// ��������� ��������
						if (xobj.IsNew)
							vPropValue = xobj.GetUpdatedPropValue(sPropName);
						else
							vPropValue = xobj.GetLoadedPropValue(sPropName);
						
						if (vPropValue != null && !(vPropValue is DBNull))
							addValueIntoObjectProp(dataSet, xmlProp, (XPropInfoObjectScalar)propInfo, (Guid)vPropValue, nav);
					}
					else
					{
						// ��������� ��������
						if (xobj.IsNew)
							vPropValue = xobj.GetUpdatedPropValue(sPropName);
						else
							vPropValue = xobj.GetLoadedPropValue(sPropName);
						
						writeArrayProp(xobj, xmlProp, vPropValue, (XPropInfoObject)propInfo, nav);
					}
					break;
				default:
					if (xobj.IsNew)
						vPropValue = xobj.GetUpdatedPropValue(sPropName);
					else
						vPropValue = xobj.GetLoadedPropValue(sPropName);
					
					if (vPropValue != null && !(vPropValue is DBNull))
						xmlProp.InnerText = XmlPropValueWriter.GetXmlTypedValue(vPropValue, propInfo.VarType);
					else
						xmlProp.InnerText = String.Empty;
					break;
			}
		}

		/// <summary>
		/// ���������� ������ LOB-��������
		/// </summary>
		/// <param name="xobj">������-�������� ��������</param>
		/// <param name="xmlProp">xml-��������</param>
		/// <param name="propInfo">�������� ��������</param>
		private void writeLOBProp(DomainObjectData xobj, XmlElement xmlProp, XPropInfoBase propInfo)
		{
			string  sPropName = propInfo.Name;
			XPropType vt = propInfo.VarType;
			object vPropValue;
			int nDataSize = 0;
			if (xobj.IsNew)
			{
				vPropValue = xobj.GetUpdatedPropValue(sPropName);
				if (vPropValue == null || vPropValue == DBNull.Value)
				{
					nDataSize = 0;
				}
				else
					xmlProp.InnerText = XmlPropValueWriter.GetXmlTypedValue(vPropValue, vt);
			}
			else
			{
				nDataSize  = xobj.GetLoadedPropDataSize(sPropName);
				if (nDataSize > 0)
				{
					vPropValue = xobj.GetLoadedPropValue(sPropName);
					if (vPropValue == null)
						// ������ � �������� ����, �� �� ���������
						xmlProp.SetAttribute("loaded", "0");
					else 
						xmlProp.InnerText = XmlPropValueWriter.GetXmlTypedValue(vPropValue, vt);
				}
			}
			xmlProp.SetAttribute("data-size", XmlConvert.ToString(nDataSize));
		}

		/// <summary>
		/// ���������� ������ ���������� ���������� ��������
		/// </summary>
		/// <param name="xobjOwner">�������� ��������</param>
		/// <param name="xmlProp">xml-��������</param>
		/// <param name="vPropValue">�������� ���������� �������� (null ��� Guid[])</param>
		/// <param name="nav">��������� �� ������ ������������ �������</param>
		private void writeArrayProp(DomainObjectData xobjOwner, XmlElement xmlProp, object vPropValue, XPropInfoObject propInfo, PreloadsNavigator nav)
		{
			if (vPropValue == null)
			{
				if (!xobjOwner.IsNew)
					xmlProp.SetAttribute("loaded", "0");
			}
			else
			{
				// �������� ���� � �����������
				Guid[] oids = (Guid[])vPropValue;
				foreach(Guid valueOID in oids)
				{
					addValueIntoObjectProp(xobjOwner.Context, xmlProp, propInfo, valueOID, nav);
				}
			}
		}

		/// <summary>
		/// ��������� �������� � ��������� ��������.
		/// ���� ������-�������� ������������ � ���������, �� ��������� ��� ������������ (serializeObject), ����� ������� �������� (���+�������������)
		/// </summary>
		/// <param name="dataSet"></param>
		/// <param name="xmlProp">������� ��������� �������� (��������� ��� ���������)</param>
		/// <param name="propInfo">���������� ��������</param>
		/// <param name="valueOID">������������� �������-��������</param>
		private void addValueIntoObjectProp(DomainObjectDataSet dataSet, XmlElement xmlProp, XPropInfoObject propInfo, Guid valueOID, PreloadsNavigator nav)
		{
			XmlElement xmlObjectValue;			// xml-������������� ������-�������� 
			DomainObjectData xobjValue = null;	// ������-�������� �������� � ���������

			// ������������ ��������� ����� �� ����
			if (dataSet != null && nav != null)
				xobjValue = dataSet.Find(propInfo.ReferedType.Name, valueOID);
			if (xobjValue != null && nav != null)
			{
				// ������-�������� �������� �������� � �������� � ����� ��������� - �������� ���������� ��� ������������
				xmlObjectValue = serializeObject(xobjValue, xmlProp.OwnerDocument, nav);
			}
			else
			{
				xmlObjectValue = xmlProp.OwnerDocument.CreateElement(propInfo.ReferedType.Name);
				xmlObjectValue.SetAttribute("oid", valueOID.ToString());
			}
			// ������� ������-�������� (����-�� ������ ��� ������ ������)
			xmlProp.AppendChild(xmlObjectValue);
		}

		private XmlElement serializeObject(DomainObjectData xobj, XmlDocument xmlDoc, PreloadsNavigator nav)
		{
            XmlElement xmlObject = XMetadataManager.CreateObjectTemplate(xobj.TypeInfo, xmlDoc, false);//m_mdManager.CreateObjectTemplate(xobj.TypeInfo, xmlDoc, false);
			xmlObject.SetAttribute("oid", XmlConvert.ToString(xobj.ObjectID));
			if (xobj.IsNew)
				xmlObject.SetAttribute("new", "1");
			else if (xobj.TS > -1)
				xmlObject.SetAttribute("ts", XmlConvert.ToString(xobj.TS));
			if (nav != null)
				nav.MoveNext();
			foreach(XmlElement xmlProp in xmlObject.ChildNodes)
			{
				if (nav != null && nav.HasProp(xmlProp.LocalName))
					// ���������� ������� � ��������
					serializePropertyInternal(xobj, xmlProp, nav);
				else
					// � �������� ������ ��������
					serializePropertyInternal(xobj, xmlProp, null);
			}
			if (nav != null)
				nav.MoveBack();
			return xmlObject;
		}

		
		#region Deserialization
		public DomainObjectDataSet DeserializeForSave(XmlElement xmlDatagram)
		{
			DomainObjectDataSet dataSet = new DomainObjectDataSet(m_mdManager.XModel);
			parseXmlForest(xmlDatagram, dataSet);
			checkAndSyncReverseProps(dataSet);
			return dataSet;
		}

		/// <summary>
		/// ���������� ������� xml-������ � ��������� �� ��������� �������. 
		/// ������ ������ ����������� �� ��������� ������� Add.
		/// </summary>
		/// <param name="xmlRoot">��� xml-��������, ����������� ����� x-datagram, ���� ��������� ������</param>
		private void parseXmlForest(XmlElement xmlRoot, DomainObjectDataSet dataSet)
		{
			// ���������� ��������� �������� ���������� �������, ���������� � ��������
			if (xmlRoot.LocalName == "x-datagram")
			{
				foreach(XmlElement xmlObject in xmlRoot.SelectNodes("*"))
					walkThroughXmlObjects(xmlObject, dataSet, true);
			}
			else
			{
				// �� �������� ������ �� x-datagram, �������, ��� ��� ��������� ������
				walkThroughXmlObjects(xmlRoot, dataSet, true);
			}
		}

		/// <summary>
		/// ���������� ������� ������ �������� � ��������� �� � ��������� objSet
		/// </summary>
		/// <param name="xmlObject">������� xml-������</param>
		/// <param name="bIsRoot">������� ��������� ������� � ������ (x-datagram)</param>
		private void walkThroughXmlObjects(XmlElement xmlObject, DomainObjectDataSet dataSet, bool bIsRoot)
		{
			string sParentTypeName;		// ������������ ���� ������������� �������
			string sParentPropName;		// ������������ ������������� ��������
			XmlElement xmlProp;

			XTypeInfo typeInfo = m_mdManager.XModel.FindTypeByName(xmlObject.LocalName);
			if (!typeInfo.IsTemporary)
			{
				// ���� � ������� ��� �������� oid, �� ��������� ���, ������������ ����� ����
				if (!xmlObject.HasAttribute("oid"))
					xmlObject.SetAttribute("oid", XmlConvert.ToString( Guid.NewGuid() ) );
				
				if (!bIsRoot)
				{
					Debug.Assert(xmlObject.ParentNode != null);
					Debug.Assert(xmlObject.ParentNode.ParentNode != null);
					// ��� ���������� ������� �������� �������� ��������, ���� ��� ���, 
					// ��� ��������, ��� � ��� ���� ������ �� ��������, ���� ��� ����.
					// ������� � �������� � ������� ����������.
					// ������� ������������ ���� ������������� �������
					sParentTypeName = xmlObject.ParentNode.ParentNode.LocalName;
					// ������� ������������ ������������� ��������
					sParentPropName = xmlObject.ParentNode.LocalName;
					// ������� ���������� ������������� ��������
					XPropInfoObject xpropParent = (XPropInfoObject)m_mdManager.XModel.FindTypeByName(sParentTypeName).GetProp(sParentPropName);
					//if (xpropParent != null && xpropParent.Capacity != XPropCapacity.ArrayMembership && xpropParent.Capacity != XPropCapacity.Array)
					if (xpropParent != null && (xpropParent.Capacity == XPropCapacity.Collection || xpropParent.Capacity == XPropCapacity.CollectionMembership))
					{
						if (xpropParent.ReverseProp != null)
						{
							XPropInfoObject xprop = (XPropInfoObject)xpropParent.ReverseProp;
							// �������� �������� ���� - ������ ��� � ������� �������
							xmlProp = (XmlElement)xmlObject.SelectSingleNode(xpropParent.ReverseProp.Name);

							if (xmlProp == null)
							{
								// �� ����� - ���� ������� � ��������� ���� �������� ������������� �������
								xmlProp = xmlObject.OwnerDocument.CreateElement( xprop.Name );
								xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
								xmlObject.AppendChild( xmlProp );
							}
							else if (xmlProp.GetAttribute("loaded").Length > 0 || !xmlProp.HasChildNodes && xmlObject.HasAttribute("new"))
							{
								// �����, �� ��� ��������� ��� �������������� ��� ������ ������ ������� - ������ ���
								xmlProp.ParentNode.RemoveChild( xmlProp );
							}
							else if (!xmlProp.HasChildNodes)
							{
								// �����, �� ������ - ������� �������� ������������� �������
								xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
								xmlObject.AppendChild( xmlProp );
							}
							else
							{
								// ����� �������� �������� � ��� �� ������- ��������, ��� � ��� ���� ������ �� ������������ ������
								// ���� ������ ���, �� ������� ��
								string sParentObjectID = xmlObject.ParentNode.ParentNode.Attributes["oid"].Value;
								if (xmlProp.SelectSingleNode( String.Format("{0}[@oid='{1}']", sParentTypeName, sParentObjectID) ) == null)
									xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
							}
							// ������� �������� ����������� ��������� �������� �� ��������� ������� ����� �������
							xmlProp.SetAttribute(XObject.MERGE_ACTION_WEAK, "1");
						}
					}
				}
				
				DeserializeObject(xmlObject, typeInfo, dataSet);
			}
			// �� ���� �������� (�� ���������!) � ��������� ��������� ����������� xml-�������
			foreach(XmlElement xmlChildObject in xmlObject.SelectNodes("*/*[*]"))
				walkThroughXmlObjects(xmlChildObject, dataSet, false);
		}

		private DomainObjectData DeserializeObject(XmlElement xmlObject, XTypeInfo typeInfo, DomainObjectDataSet dataSet)
		{
			DomainObjectData xobj;
			Guid oid = new Guid(xmlObject.GetAttribute("oid"));
            bool bIsNew = xmlObject.HasAttribute("new");
			bool bToDelete = xmlObject.HasAttribute("delete");
			bool bNeedMerge = false;
			object vPropValue;
			xobj = dataSet.Find(typeInfo.Name, oid);
			if (xobj == null)
			{
				// ������ ������� ��� � ���������: �������� ��� � ��������
				if (bToDelete)
					xobj = dataSet.CreateToDelete(typeInfo.Name, oid); 
				else
				{
					bIsNew = xmlObject.HasAttribute("new");
					xobj = dataSet.CreateStub(typeInfo.Name, oid, bIsNew);
				}
			}
			else
			{
				// ������ ��� ������������
				if (bIsNew != xobj.IsNew)
					throw new XMergeConflictException("������ " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] ������������ � ���������� ��������������� �����������: ���� ������� new='1', � ������ ��� ");
				if (bToDelete != xobj.ToDelete)
					throw new XMergeConflictException("������ " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] ������������ � ���������� ��������������� �����������: ���� ������� delete='1', � ������ ��� ");
				bNeedMerge = true;
			}
			if (xmlObject.HasAttribute("ts"))
				xobj.SetTS(Int64.Parse( xmlObject.GetAttribute("ts") ));
			// �� ���� ��������� ��� �������� loaded="0"
			foreach(XmlElement xmlProp in xmlObject.SelectNodes("*[not(@loaded)]"))
			{
				XPropInfoBase propInfo = typeInfo.GetProp(xmlProp.LocalName);
				// xml-���� �� ��������������� ��������� �� �� ����������
				if (propInfo == null)
					continue;

				if (!bToDelete && xmlProp.HasAttribute(XDatagram.ATTR_CHUNCK_CHAIN_ID))
					xobj.PropertiesWithChunkedData.Add(propInfo.Name, new Guid(xmlProp.GetAttribute(XDatagram.ATTR_CHUNCK_CHAIN_ID)));
				
				// �������� � ������� �������������
				if (propInfo is XPropInfoObjectArray)
					if (((XPropInfoObjectArray)propInfo).Capacity == XPropCapacity.ArrayMembership)
						continue;
				// ������ ��������� �������� ����� �������� �������������
				if (bIsNew)
					if (propInfo is XPropInfoObjectArray || propInfo is XPropInfoObjectLink)
						if (!xmlProp.HasChildNodes)
							continue;
				vPropValue = getPropValue(xmlProp, propInfo);
				if (bNeedMerge && xobj.HasUpdatedProp(propInfo.Name))
				{
					bool bNeedScalarCheck = true;
					object vPropValueExist = xobj.GetUpdatedPropValue(propInfo.Name);
					if (propInfo is XPropInfoObject && !(propInfo is XPropInfoObjectScalar) )
					{
						// ��������� ��������� ��������
						bNeedScalarCheck = false;
						XPropCapacity capacity = ((XPropInfoObject)propInfo).Capacity;
						Guid[] valuesOld = (Guid[])vPropValueExist;
						Guid[] valuesCur = (Guid[])vPropValue;
						if (capacity == XPropCapacity.Array || (capacity == XPropCapacity.Link && ((XPropInfoObjectLink)propInfo).OrderByProp != null) )
						{
							// ������� � ������������� ����� �� ������������ ������� - ������ �������� �� ���������� ��������
							if (valuesOld.Length != valuesCur.Length)
								throw new XMergeConflictException("�� ��������� ���������� ��������� � �������� " + propInfo.Name);
							for(int i = 0;i<valuesOld.Length;++i)
								if (valuesOld[i] != valuesCur[i])
									throw new XMergeConflictException("�� ��������� �������� �������� " + propInfo.Name);
						}
						else
						{
							// ��������� � �������� � ��������� - ���������� �������
							ArrayList aValuesNew = new ArrayList(valuesOld.Length + valuesCur.Length);
							aValuesNew.AddRange(valuesOld);
							foreach(Guid value in valuesCur)
								if (aValuesNew.IndexOf(value) < 0)
									aValuesNew.Add(value);

							Guid[] valuesNew = new Guid[aValuesNew.Count];
							aValuesNew.CopyTo(valuesNew);
							vPropValue = valuesNew;
						}
					}
					else if (propInfo is XPropInfoNumeric)
					{
						// �������� �������� - ����� ���������� ��������, ���� ��� �� ��������� �������� �����
						if (((XPropInfoNumeric)propInfo).OrderedLinkProp != null)
							bNeedScalarCheck = false;
					}
					if (bNeedScalarCheck)
					{
						// ���� �������� �������� ���������� ��������
						// �.�. Equals - ����������� �����, �� ������ ��������
						if (!vPropValueExist.Equals(vPropValue))
							throw new XMergeConflictException("�������� �������� " + propInfo.Name + " �� ���������");
					}
				}
				xobj.SetUpdatedPropValue(propInfo.Name, vPropValue);
				// �������: �������� �������� (xmlProp.HasAttribute(ATTR_CHUNCK_CHAIN_ID))
			}
			return xobj;
		}

		/// <summary>
		/// ���������� �������������� �������� �������� �� xml-����.
		/// ����������: ������� loaded=0 �� ���������
		/// </summary>
		/// <param name="xmlProp">xml-���� ��������</param>
		/// <param name="propInfo">���������� ��������</param>
		/// <returns></returns>
		private static object getPropValue(XmlElement xmlProp, XPropInfoBase propInfo)
		{
			object propValue;
			if (propInfo is XPropInfoObjectScalar)
			{
				if (!xmlProp.HasChildNodes)
					propValue = DBNull.Value;
				else
					propValue = new Guid(xmlProp.FirstChild.Attributes["oid"].Value);
			}
			else if (propInfo is IXPropInfoScalar)
			{
				// ��������� ����������� ��������
				propValue = XmlPropValueReader.GetTypedValueFromXml(xmlProp, propInfo.VarType);
				if (propValue == null)
					propValue = DBNull.Value;
			}
			else
			{
				// ��������� ��������� ��������
				XmlNodeList xmlChildren = xmlProp.SelectNodes("*");
				Guid[] oids = new Guid[xmlChildren.Count];
				int i = -1;
				foreach(XmlElement xmlChildObj in xmlChildren)
					oids[++i] = new Guid(xmlChildObj.GetAttribute("oid"));
				propValue = oids;
			}
			return propValue;
		}	

		private void checkAndSyncReverseProps(DomainObjectDataSet dataSet)
		{
			IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(true);
			object vPropValue;
			while (enumerator.MoveNext())
			{
				DomainObjectData xobj = (DomainObjectData)enumerator.Current;
				foreach(string sPropName in xobj.UpdatedPropNames)
				{
					XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
					Debug.Assert(propInfo != null);
					if (propInfo.VarType != XPropType.vt_object)
						continue;
					
					XPropInfoObject propInfoObj = (XPropInfoObject)propInfo;
					if (propInfoObj.Capacity == XPropCapacity.CollectionMembership || propInfoObj.Capacity == XPropCapacity.Link)
					{
						Guid[] values = (Guid[])xobj.GetUpdatedPropValue(sPropName);
						if (values.Length > 0)
						{
							foreach(Guid valueObjectID in values)
							{
								bool bError = false;
								DomainObjectData xobjValue = dataSet.Find(propInfoObj.ReferedType.Name,  valueObjectID);
								// ������-�������� ���������� �������� sPropName ���� � ��������� � �� ����� �����������
								if (xobjValue != null && xobjValue.HasNewData)
								{
									// ���� ������� �������� "�������� � ���������" � � �������-�������� ���� �������� �������� (���������),
									// ��������, ��� �������� �������� �������� ������ �� ������� ������ (xobj)
									if (propInfoObj.Capacity == XPropCapacity.CollectionMembership && xobjValue.HasUpdatedProp(propInfoObj.ReverseProp.Name))
									{
										Guid[] propRevValues = (Guid[])xobjValue.GetUpdatedPropValue(propInfoObj.ReverseProp.Name);
										Debug.Assert(propRevValues != null);
										// ���� �������� �������� (���������) �� �������� ������ �� ������� ������ - ����������
										if (Array.IndexOf(propRevValues, xobj.ObjectID) == -1)
											bError = true;
									}
									// ���� ������� �������� ����, �� ��������� �������� �������� - ��������� ������
									else if (propInfoObj.Capacity == XPropCapacity.Link)
									{
										vPropValue = xobjValue.GetUpdatedPropValue(propInfoObj.ReverseProp.Name);
										// ���� �������� �������� (������) �����������, �� ��������, ��� ��� ��������� �� ������� ������
										if (vPropValue != null)
										{
											Debug.Assert(vPropValue is Guid);
											if ((vPropValue is DBNull) || ((Guid)vPropValue) != xobj.ObjectID)
												bError = true;
										}
										// �������� �������� ������������� - ��������� ��� �� ������� ������
										else
										{
											xobjValue.SetUpdatedPropValue(propInfoObj.ReverseProp.Name, xobj.ObjectID);
										}
									}
									if (bError)
									{
										throw new XInvalidXmlForestException( 
											String.Format("�� ����������� �������� ��������: {0}[ID='{1}'], �������� {2} � {3}[ID='{4}'], �������� {5}",
												xobj.ObjectType,			// 0
												xobj.ObjectID,				// 1
												sPropName,					// 2
												xobjValue.ObjectType,		// 3
												xobjValue.ObjectID,			// 4
												propInfoObj.ReverseProp.Name	// 5
											));
																
									}
								}
							}
						}
					}
				}
			}
		}
		#endregion
	}
}
