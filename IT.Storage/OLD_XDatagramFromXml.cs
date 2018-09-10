using System;
using System.Collections;
using System.Diagnostics;
using System.Xml;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	public class XDatagramFromXml: XDatagram
	{
		private ArrayList m_objects = new ArrayList();
		private Hashtable m_objectsDictionary = new Hashtable();

		public XDatagramFromXml(XmlElement xmlRoot, XMetadataManager mdManager)
		{
			m_xmodel = mdManager.XModel;
			parseXmlForest(xmlRoot);
			checkReverseProps();
			foreach(XStorageObjectBase xobj in m_objects)
			{
				// � ������� ������ normalizeObject ��������� m_objects � ������� m_objectsDictionary �� �����������:
				// normalizeObject ��������� ��� ����������� ������� � m_objectsDictionary, �� �� ��������� � ��������� m_objects
				ArrayList aNewObject = normalizeObject(xobj);	
				// ���� ���-�� ������, �� ��� ����� ������ "�����" ����������� ��������, 
				// �.�. ������� ������� ���� ������������ � ���������� ��������� ������ �� ��� � ����� �������� �������
				if (aNewObject != null)
					foreach(XStorageObjectToSave xobjDetached in aNewObject)
						addUpdatedInternal(xobjDetached);
				if (xobj is XStorageObjectToDelete)
				{
					addDeletedInternal((XStorageObjectToDelete)xobj);
				}
				else
				{
					XStorageObjectToSave xobjSave = (XStorageObjectToSave)xobj;
					if (xobjSave.IsToInsert)
						addInsertedInternal(xobjSave);
					else
						addUpdatedInternal(xobjSave);
				}
			}
		}

		/// <summary>
		/// ���������� ������� xml-������ � ��������� �� ��������� �������. 
		/// ������ ������ ����������� �� ��������� ������� Add.
		/// </summary>
		/// <param name="xmlRoot">��� xml-��������, ����������� ����� x-datagram, ���� ��������� ������</param>
		private void parseXmlForest(XmlElement xmlRoot)
		{
			// ��������� ������������� ����������
			/*
			if (xmlRoot.HasAttribute("transaction-id"))
				m_TransactionID = new Guid(xmlRoot.GetAttribute("transaction-id"));
			else
				m_TransactionID = Guid.NewGuid();
*/
			// ���������� ��������� �������� ���������� �������, ���������� � ��������
			if (xmlRoot.LocalName == "x-datagram")
			{
				foreach(XmlElement xmlObject in xmlRoot.SelectNodes("*"))
					walkThroughXmlObjects(xmlObject, true);
			}
			else
			{
				// �� �������� ������ �� x-datagram, �������, ��� ��� ��������� ������
				walkThroughXmlObjects(xmlRoot, true);
			}
		}
		/// <summary>
		/// ���������� ������� ������ �������� � ��������� �� � ��������� objSet
		/// </summary>
		/// <param name="xmlObject">������� xml-������</param>
		/// <param name="bIsRoot">������� ��������� ������� � ������ (x-datagram)</param>
		private void walkThroughXmlObjects(XmlElement xmlObject, bool bIsRoot)
		{
			string sParentTypeName;		// ������������ ���� ������������� �������
			string sParentPropName;		// ������������ ������������� ��������
			XmlElement xmlProp;

			XTypeInfo typeInfo = m_xmodel.GetTypeByName(xmlObject.LocalName);
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
					XPropInfoObject xpropParent = (XPropInfoObject)m_xmodel.GetTypeByName(sParentTypeName).GetProp(sParentPropName);
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
				
				Add(xmlObject, typeInfo);
			}
			// �� ���� �������� (�� ���������!) � ��������� ��������� ����������� xml-�������
			foreach(XmlElement xmlChildObject in xmlObject.SelectNodes("*/*[*]"))
				walkThroughXmlObjects(xmlChildObject, false);
		}

		/// <summary>
		/// ��������� �� ��������� xml-������
		/// </summary>
		/// <param name="xmlObject"></param>
		private void Add(XmlElement xmlObject, XTypeInfo typeInfo)
		{
			XStorageObjectBase xobj = CreateXStorageObject(xmlObject, typeInfo);
			XStorageObjectBase xobjExists = (XStorageObjectBase)m_objectsDictionary[xobj.ObjectID];
			if (xobjExists != null)
			{
				merge(xobjExists, xobj);
			}
			else
			{
				m_objects.Add(xobj);
				m_objectsDictionary.Add(xobj.ObjectID, xobj);
			}
		}
		public static XStorageObjectBase CreateXStorageObject(XmlElement xmlObject, XTypeInfo typeInfo)
		{
			XStorageObjectBase xobj;
			Guid oid = new Guid(xmlObject.GetAttribute("oid"));
			Int64 nTS;
			if (xmlObject.HasAttribute("ts"))
				nTS = Int32.Parse( xmlObject.GetAttribute("ts") );
			else
				nTS = -1;
			bool bIsNew = false;
			if (xmlObject.HasAttribute("delete"))
				xobj = new XStorageObjectToDelete(typeInfo, oid, nTS, true);
			else
			{
				bIsNew = xmlObject.HasAttribute("new");
				xobj = new XStorageObjectToSave(typeInfo, oid, nTS, bIsNew);
			}
			bool bNeedTrackUniqueIndexParticipation = typeInfo.HasUniqueIndexes && typeInfo.DeferrableIndexes && xobj is XStorageObjectToSave;
			// �� ���� ��������� ��� �������� loaded="0"
			foreach(XmlElement xmlProp in xmlObject.SelectNodes("*[not(@loaded)]"))
			{
				XPropInfoBase xprop = typeInfo.GetProp(xmlProp.LocalName);
				if (xprop == null)
					continue;
				// ���� �� xml-�������� ������������ ������� ���� ������� � ��������������� ������� �������� ������, �� ������� ��� � ����������� �������
				if (xobj is XStorageObjectToSave && xmlProp.HasAttribute(ATTR_CHUNCK_CHAIN_ID))
				{
					((XStorageObjectToSave)xobj).PropertiesWithChunkedData.Add(xprop.Name, new Guid(xmlProp.GetAttribute(ATTR_CHUNCK_CHAIN_ID)));
				}
				// �������� � ������� �������������
				if (xprop is XPropInfoObjectArray)
					if (((XPropInfoObjectArray)xprop).Capacity == XPropCapacity.ArrayMembership)
						continue;
				// ������ ��������� �������� ����� �������� �������������
				if (bIsNew)
					if (xprop is XPropInfoObjectArray || xprop is XPropInfoObjectLink)
						if (!xmlProp.HasChildNodes)
							continue;
				xobj.Props.Add(xprop.Name, getPropValue(xmlProp, xprop));
				// ���� �������� ��������� � ���������� �������, �������� ���
				if (bNeedTrackUniqueIndexParticipation)
					if (typeInfo.IsPropIncludedIntoUniqueIndex(xprop.Name))
						((XStorageObjectToSave)xobj).ParticipateInUniqueIndex = true;
			}
			return xobj;
		}

		private void merge(XStorageObjectBase xobjExists, XStorageObjectBase xobj)
		{
			if (xobjExists.GetType() != xobj.GetType())
				throw new XMergeConflictException("������ " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] ������������ � ���������� ��������������� �����������: ���� ������� delete='1', � ������ ���");
			if (xobjExists is XStorageObjectToSave)
			{
				if ( ((XStorageObjectToSave)xobjExists).IsToInsert != ((XStorageObjectToSave)xobj).IsToInsert)
					throw new XMergeConflictException("������ " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] ������������ � ���������� ��������������� �����������: ���� ������� new='1', � ������ ��� ");
			}
			if (xobjExists.TS != xobj.TS && xobjExists.AnalyzeTS && xobj.AnalyzeTS)
				throw new XMergeConflictException("���������� ��� ����� ������� � ������������� ts");

			foreach(DictionaryEntry entry in xobj.Props)
			{
				string sPropName = (string)entry.Key;
				if (!xobjExists.Props.Contains(sPropName))
					xobjExists.Props.Add(sPropName, entry.Value);
				else
				{
					bool bNeedScalarCheck = true;
					// ������� �������� ��� ���� - ���� ��� ���������, �� merge
					XPropInfoBase propInfo = xobjExists.TypeInfo.GetProp(sPropName);
					if (propInfo is XPropInfoObject && !(propInfo is XPropInfoObjectScalar) )
					{
						bNeedScalarCheck = false;
						XPropCapacity capacity = ((XPropInfoObject)propInfo).Capacity;
						Guid[] valuesOld = (Guid[])xobjExists.Props[sPropName];
						Guid[] valuesCur = (Guid[])entry.Value;
						if (capacity == XPropCapacity.Array || (capacity == XPropCapacity.Link && ((XPropInfoObjectLink)propInfo).OrderByProp != null) )
						{
							// ������� � ������������� ����� �� ������������ ������� - ������ �������� �� ���������� ��������
							if (valuesOld.Length != valuesCur.Length)
								throw new XMergeConflictException("�� ��������� ���������� ��������� � �������� " + sPropName);
							for(int i = 0;i<valuesOld.Length;++i)
								if (valuesOld[i] != valuesCur[i])
									throw new XMergeConflictException("�� ��������� �������� �������� " + sPropName);
						}
						else
						{
							// ��������� � �������� � ���������
							ArrayList aValuesNew = new ArrayList(valuesOld.Length + valuesCur.Length);
							aValuesNew.AddRange(valuesOld);
							foreach(Guid value in valuesCur)
								if (aValuesNew.IndexOf(value) < 0)
									aValuesNew.Add(value);

							Guid[] valuesNew = new Guid[aValuesNew.Count];
							aValuesNew.CopyTo(valuesNew);
							xobjExists.Props[sPropName] = valuesNew;
						}
					}
					else if (propInfo is XPropInfoNumeric)
					{
						//��������� - ������� ��������, ���� ��� �� ��������� ��������
						if (((XPropInfoNumeric)propInfo).OrderedLinkProp != null)
							bNeedScalarCheck = false;
					}
					if (bNeedScalarCheck)
						if (!xobjExists.Props[sPropName].Equals(entry.Value))
							throw new XMergeConflictException("�������� �������� " + sPropName + " �� ���������");
				}
			}
		}

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
				//				if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
				//					propValue = XStorageLOBPropHandle.Create(propInfo.VarType, propValue);
				//else 
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
				//propValue = new XStorageObjectArrayPropHandle(oids);
			}
			return propValue;
		}
		private ArrayList normalizeObject(XStorageObjectBase xobj)
		{
			if (xobj is XStorageObjectToDelete)
				return null;
			XStorageObjectToSave xobjSave = (XStorageObjectToSave)xobj;
			ArrayList aNewObjects = null;
			foreach(DictionaryEntry entry in xobjSave.GetPropsByCapacity(XPropCapacity.Link, XPropCapacity.LinkScalar))
			{
				Guid[] valueOIDs = (Guid[])entry.Value;
				if (valueOIDs.Length == 0)
					continue;
				string sPropName = (string)entry.Key;
				XPropInfoObjectLink propInfo = (XPropInfoObjectLink)xobj.TypeInfo.GetProp(sPropName);
				
				int nIndex = 0;
				foreach(Guid valueOID in valueOIDs)
				{
					XStorageObjectBase xobjValue = (XStorageObjectBase)m_objectsDictionary[valueOID];
					if (xobjValue == null)
					{
						// � ���������� ��� �������, �� ������� ����������� ������ � ����� - ������ ��������, ���� ������ ����� �� �����
						xobjValue = new XStorageObjectToSave(propInfo.ReferedType, valueOID, -1, false);
						if (aNewObjects == null)
							aNewObjects = new ArrayList();
						aNewObjects.Add(xobjValue);
						// �� ������ ���� ������ ������ ���������� ��� � �����-������ �����
						m_objectsDictionary.Add(valueOID, xobjValue);
					}
					else
					{
						object vValue = xobjValue.Props[propInfo.ReverseProp.Name];
						if (vValue == null || vValue == DBNull.Value)
						{
							// ��� ������ - �������� �������� (��������� ������) ������ - ��������� ��� �� ������� ������ (xobj)
							xobjValue.Props[propInfo.ReverseProp.Name] = xobj.ObjectID;
						}
						else
						{
							Debug.Assert(vValue is Guid);	// ������ ������ ������� ���� �� ������!
							// �������� �������� ��� ���������, �������� ��� ��� ��������� �� ������� ������. ���� ��� �� ��� - ��������
							if ( ((Guid)vValue) != xobj.ObjectID )
								throw new XInvalidXmlForestException("������ ��� ��������� �������� " + propInfo.ReverseProp.Name + " ������� " + xobjValue.TypeInfo.Name + " [" + xobjValue.ObjectID + "]: ��������� ��������������� �� ��������� " + sPropName + " ������� " + xobj.TypeInfo.Name + " [" + xobj.ObjectID +"]");
						}
					}
					// ������������� ���� ? - ��������� ��������� ��������
					if (propInfo.OrderByProp != null)
						xobjValue.Props[propInfo.OrderByProp.Name] = nIndex++;
				}
			}
			return aNewObjects;
		}

		private void checkReverseProps()
		{
			foreach(XStorageObjectBase xobj in m_objects)
				if (xobj is XStorageObjectToSave)
				{
					
					foreach(DictionaryEntry entry in ((XStorageObjectToSave)xobj).GetPropsByCapacity(XPropCapacity.CollectionMembership /*, XPropCapacity.Link, XPropCapacity.LinkScalar*/))
					{
						string sPropName = (string)entry.Key;
						Guid[] valueOIDs = (Guid[])entry.Value;
						if (valueOIDs.Length == 0)
							continue;
						XPropInfoObject propInfo = (XPropInfoObject)xobj.TypeInfo.GetProp(sPropName);
						bool bError = false;
						foreach(Guid valueOID in valueOIDs)
						{
							XStorageObjectBase xobjValue = (XStorageObjectBase)m_objectsDictionary[valueOID];
							if (xobjValue == null)
								continue;
							// �������� ��������� �������� ���� � ����������

							if (!xobjValue.Props.Contains(propInfo.ReverseProp.Name))
								continue;
							// �������� ��������� �������� �������� ��� �������� ��������

							object vValue = xobjValue.Props[propInfo.ReverseProp.Name];
							Debug.Assert(vValue != null);
							if (propInfo.ReverseProp is XPropInfoObjectScalar)
							{
								if (vValue == DBNull.Value || (Guid)vValue != xobj.ObjectID)
									bError = true;
							}
							else
							{
								// �������� �������� - ���������, � �������� ������ �����
								Guid[] valueOIDsReverse = (Guid[])vValue;
								// � ���� ������� ������ ���� ������ �� ������� ������ (xobj)
								bool bFound = false;
								foreach(Guid valueOIDReverse in valueOIDsReverse)
									if (valueOIDReverse == xobj.ObjectID)
									{
										bFound = true;
										break;
									}
								if (!bFound)
									bError = true;
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
									propInfo.ReverseProp.Name	// 5
									)
									);
							}
						}
					}
				}
		}
	}

}
