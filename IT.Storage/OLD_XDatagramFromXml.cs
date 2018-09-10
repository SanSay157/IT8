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
				// с момента вызова normalizeObject коллекция m_objects и словарь m_objectsDictionary не согласованы:
				// normalizeObject добавляет все создаваемые объекты в m_objectsDictionary, но не добавляет в коллекцию m_objects
				ArrayList aNewObject = normalizeObject(xobj);	
				// если что-то вернут, то это будет список "новых" обновляемых объектов, 
				// т.е. объекты которые надо проапдейтить в результате помещения ссылок на них в линки текущего объекта
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
		/// Рекурсивно обходит xml-дерево и разбирает на отдельные объекты. 
		/// Каждый объект добавляется во множество методом Add.
		/// </summary>
		/// <param name="xmlRoot">лес xml-объектов, скрепленный тегом x-datagram, либо одиночный объект</param>
		private void parseXmlForest(XmlElement xmlRoot)
		{
			// установим идентификатор транзакции
			/*
			if (xmlRoot.HasAttribute("transaction-id"))
				m_TransactionID = new Guid(xmlRoot.GetAttribute("transaction-id"));
			else
				m_TransactionID = Guid.NewGuid();
*/
			// сформируем множество объектов подлежащих вставке, обновлению и удалению
			if (xmlRoot.LocalName == "x-datagram")
			{
				foreach(XmlElement xmlObject in xmlRoot.SelectNodes("*"))
					walkThroughXmlObjects(xmlObject, true);
			}
			else
			{
				// на корневом уровне не x-datagram, считаем, что это одиночный объект
				walkThroughXmlObjects(xmlRoot, true);
			}
		}
		/// <summary>
		/// Рекурсивно обходит дерево объектов и добавляет их в множество objSet
		/// </summary>
		/// <param name="xmlObject">текущий xml-объект</param>
		/// <param name="bIsRoot">Признак корневого объекта в пакете (x-datagram)</param>
		private void walkThroughXmlObjects(XmlElement xmlObject, bool bIsRoot)
		{
			string sParentTypeName;		// наименование типа родительского объекта
			string sParentPropName;		// наименование родительского свойства
			XmlElement xmlProp;

			XTypeInfo typeInfo = m_xmodel.GetTypeByName(xmlObject.LocalName);
			if (!typeInfo.IsTemporary)
			{
				// если у объекта нет атрибута oid, то установим его, сгенерировав новый гуид
				if (!xmlObject.HasAttribute("oid"))
					xmlObject.SetAttribute("oid", XmlConvert.ToString( Guid.NewGuid() ) );
				
				if (!bIsRoot)
				{
					Debug.Assert(xmlObject.ParentNode != null);
					Debug.Assert(xmlObject.ParentNode.ParentNode != null);
					// для вложенного объекта создадим обратное свойство, если его нет, 
					// или проверим, что в нем есть ссылка на родителя, если оно есть.
					// Массивы и членство в массиве игнорируем.
					// получим наименование типа родительского объекта
					sParentTypeName = xmlObject.ParentNode.ParentNode.LocalName;
					// получим наименование родительского свойства
					sParentPropName = xmlObject.ParentNode.LocalName;
					// получим метаданные родительского свойства
					XPropInfoObject xpropParent = (XPropInfoObject)m_xmodel.GetTypeByName(sParentTypeName).GetProp(sParentPropName);
					//if (xpropParent != null && xpropParent.Capacity != XPropCapacity.ArrayMembership && xpropParent.Capacity != XPropCapacity.Array)
					if (xpropParent != null && (xpropParent.Capacity == XPropCapacity.Collection || xpropParent.Capacity == XPropCapacity.CollectionMembership))
					{
						if (xpropParent.ReverseProp != null)
						{
							XPropInfoObject xprop = (XPropInfoObject)xpropParent.ReverseProp;
							// обратное свойство есть - поищем его в текущем объекте
							xmlProp = (XmlElement)xmlObject.SelectSingleNode(xpropParent.ReverseProp.Name);

							if (xmlProp == null)
							{
								// не нашли - надо создать и поместить туда заглушку родительского объекта
								xmlProp = xmlObject.OwnerDocument.CreateElement( xprop.Name );
								xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
								xmlObject.AppendChild( xmlProp );
							}
							else if (xmlProp.GetAttribute("loaded").Length > 0 || !xmlProp.HasChildNodes && xmlObject.HasAttribute("new"))
							{
								// нашли, но оно помеченно как непрогруженное или пустое нового объекта - удалим его
								xmlProp.ParentNode.RemoveChild( xmlProp );
							}
							else if (!xmlProp.HasChildNodes)
							{
								// нашли, но пустое - добавим заглушку родительского объекта
								xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
								xmlObject.AppendChild( xmlProp );
							}
							else
							{
								// нашли обратное свойство и оно не пустое- проверим, что в нем есть ссылка на родительский объект
								// если ссылки нет, то добавим ее
								string sParentObjectID = xmlObject.ParentNode.ParentNode.Attributes["oid"].Value;
								if (xmlProp.SelectSingleNode( String.Format("{0}[@oid='{1}']", sParentTypeName, sParentObjectID) ) == null)
									xmlProp.AppendChild( XStorageUtils.CreateStubFromObject((XmlElement)xmlObject.ParentNode.ParentNode) );
							}
							// пометим свойство специальным атрибутом влияющим на процедуру слияния копий объекта
							xmlProp.SetAttribute(XObject.MERGE_ACTION_WEAK, "1");
						}
					}
				}
				
				Add(xmlObject, typeInfo);
			}
			// по всем объектам (не заглушкам!) в объектных свойствах переданного xml-объекта
			foreach(XmlElement xmlChildObject in xmlObject.SelectNodes("*/*[*]"))
				walkThroughXmlObjects(xmlChildObject, false);
		}

		/// <summary>
		/// Добавляет ко множеству xml-объект
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
			// по всем свойствам без признака loaded="0"
			foreach(XmlElement xmlProp in xmlObject.SelectNodes("*[not(@loaded)]"))
			{
				XPropInfoBase xprop = typeInfo.GetProp(xmlProp.LocalName);
				if (xprop == null)
					continue;
				// если на xml-свойстве неудаляемого объекта есть атрибут с идентификатором цепочки кусочных данных, то занесем его в специальный словарь
				if (xobj is XStorageObjectToSave && xmlProp.HasAttribute(ATTR_CHUNCK_CHAIN_ID))
				{
					((XStorageObjectToSave)xobj).PropertiesWithChunkedData.Add(xprop.Name, new Guid(xmlProp.GetAttribute(ATTR_CHUNCK_CHAIN_ID)));
				}
				// членство в массиве проигнорируем
				if (xprop is XPropInfoObjectArray)
					if (((XPropInfoObjectArray)xprop).Capacity == XPropCapacity.ArrayMembership)
						continue;
				// пустые массивные свойства новых объектов проигнорируем
				if (bIsNew)
					if (xprop is XPropInfoObjectArray || xprop is XPropInfoObjectLink)
						if (!xmlProp.HasChildNodes)
							continue;
				xobj.Props.Add(xprop.Name, getPropValue(xmlProp, xprop));
				// если свойство участвует в уникальном индексе, запомним это
				if (bNeedTrackUniqueIndexParticipation)
					if (typeInfo.IsPropIncludedIntoUniqueIndex(xprop.Name))
						((XStorageObjectToSave)xobj).ParticipateInUniqueIndex = true;
			}
			return xobj;
		}

		private void merge(XStorageObjectBase xobjExists, XStorageObjectBase xobj)
		{
			if (xobjExists.GetType() != xobj.GetType())
				throw new XMergeConflictException("Объект " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] присутствует в нескольких несогласованных экземплярах: один помечен delete='1', а другой нет");
			if (xobjExists is XStorageObjectToSave)
			{
				if ( ((XStorageObjectToSave)xobjExists).IsToInsert != ((XStorageObjectToSave)xobj).IsToInsert)
					throw new XMergeConflictException("Объект " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] присутствует в нескольких несогласованных экземплярах: один помечен new='1', а другой нет ");
			}
			if (xobjExists.TS != xobj.TS && xobjExists.AnalyzeTS && xobj.AnalyzeTS)
				throw new XMergeConflictException("Обнаружены две копии объекта с различающимся ts");

			foreach(DictionaryEntry entry in xobj.Props)
			{
				string sPropName = (string)entry.Key;
				if (!xobjExists.Props.Contains(sPropName))
					xobjExists.Props.Add(sPropName, entry.Value);
				else
				{
					bool bNeedScalarCheck = true;
					// текущее свойство уже есть - если оно массивное, то merge
					XPropInfoBase propInfo = xobjExists.TypeInfo.GetProp(sPropName);
					if (propInfo is XPropInfoObject && !(propInfo is XPropInfoObjectScalar) )
					{
						bNeedScalarCheck = false;
						XPropCapacity capacity = ((XPropInfoObject)propInfo).Capacity;
						Guid[] valuesOld = (Guid[])xobjExists.Props[sPropName];
						Guid[] valuesCur = (Guid[])entry.Value;
						if (capacity == XPropCapacity.Array || (capacity == XPropCapacity.Link && ((XPropInfoObjectLink)propInfo).OrderByProp != null) )
						{
							// массивы и упорядоченные линки не подвергаются слиянию - только проверке на совпадение значений
							if (valuesOld.Length != valuesCur.Length)
								throw new XMergeConflictException("Не совпадает количество элементов в свойстве " + sPropName);
							for(int i = 0;i<valuesOld.Length;++i)
								if (valuesOld[i] != valuesCur[i])
									throw new XMergeConflictException("Не совпадает значение свойства " + sPropName);
						}
						else
						{
							// коллекция и членство в коллекции
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
						//скалярное - сравним значения, если это не индексное свойство
						if (((XPropInfoNumeric)propInfo).OrderedLinkProp != null)
							bNeedScalarCheck = false;
					}
					if (bNeedScalarCheck)
						if (!xobjExists.Props[sPropName].Equals(entry.Value))
							throw new XMergeConflictException("Значения свойства " + sPropName + " не совпадают");
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
				// скалярное необъектное свойство
				propValue = XmlPropValueReader.GetTypedValueFromXml(xmlProp, propInfo.VarType);
				//				if (propInfo.VarType == XPropType.vt_bin || propInfo.VarType == XPropType.vt_text)
				//					propValue = XStorageLOBPropHandle.Create(propInfo.VarType, propValue);
				//else 
				if (propValue == null)
					propValue = DBNull.Value;
			}
			else
			{
				// массивное объектное свойство
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
						// в датаграмме нет объекта, на который установлена ссылка в линке - значит создадим, этот объект точно не новый
						xobjValue = new XStorageObjectToSave(propInfo.ReferedType, valueOID, -1, false);
						if (aNewObjects == null)
							aNewObjects = new ArrayList();
						aNewObjects.Add(xobjValue);
						// на случай если данный объект содержится еще в каком-нибудь линке
						m_objectsDictionary.Add(valueOID, xobjValue);
					}
					else
					{
						object vValue = xobjValue.Props[propInfo.ReverseProp.Name];
						if (vValue == null || vValue == DBNull.Value)
						{
							// все хорошо - обратное свойство (объектный скаляр) пустое - установим его на текущий объект (xobj)
							xobjValue.Props[propInfo.ReverseProp.Name] = xobj.ObjectID;
						}
						else
						{
							Debug.Assert(vValue is Guid);	// больше ничего другого быть не должно!
							// обратное свойство уже заполнено, проверим что оно ссылается на текущий объект. если это не так - ругаемся
							if ( ((Guid)vValue) != xobj.ObjectID )
								throw new XInvalidXmlForestException("Ошибка при установке свойства " + propInfo.ReverseProp.Name + " объекта " + xobjValue.TypeInfo.Name + " [" + xobjValue.ObjectID + "]: нарушение согласованности со свойством " + sPropName + " объекта " + xobj.TypeInfo.Name + " [" + xobj.ObjectID +"]");
						}
					}
					// упорядоченный линк ? - установим индексное свойство
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
							// владелец обратного свойства есть в датаграмме

							if (!xobjValue.Props.Contains(propInfo.ReverseProp.Name))
								continue;
							// владелец обратного свойства содержит это обратное свойство

							object vValue = xobjValue.Props[propInfo.ReverseProp.Name];
							Debug.Assert(vValue != null);
							if (propInfo.ReverseProp is XPropInfoObjectScalar)
							{
								if (vValue == DBNull.Value || (Guid)vValue != xobj.ObjectID)
									bError = true;
							}
							else
							{
								// обратное свойство - коллекция, в свойстве массив гидов
								Guid[] valueOIDsReverse = (Guid[])vValue;
								// в этом массиве должна быть ссылка на текущий объект (xobj)
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
									String.Format("Не согласованы свойства объектов: {0}[ID='{1}'], свойство {2} и {3}[ID='{4}'], свойство {5}",
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
