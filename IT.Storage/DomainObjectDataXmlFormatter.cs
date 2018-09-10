//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
			XmlElement xmlProp;						// Узел со значением свойства
			xmlDoc.AppendChild(xmlProp = xmlDoc.CreateElement( sPropName));	// Создаем корневой элемент
			// Указываем пространство имен urn:schemas-microsoft-com:datatypes
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
						// скалярное свойство
						if (xobj.IsNew)
							vPropValue = xobj.GetUpdatedPropValue(sPropName);
						else
							vPropValue = xobj.GetLoadedPropValue(sPropName);
						
						if (vPropValue != null && !(vPropValue is DBNull))
							addValueIntoObjectProp(dataSet, xmlProp, (XPropInfoObjectScalar)propInfo, (Guid)vPropValue, nav);
					}
					else
					{
						// массивное свойство
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
		/// Записывает данные LOB-свойства
		/// </summary>
		/// <param name="xobj">объект-владелец свойства</param>
		/// <param name="xmlProp">xml-свойство</param>
		/// <param name="propInfo">описание свойства</param>
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
						// данные в свойстве есть, но не загружены
						xmlProp.SetAttribute("loaded", "0");
					else 
						xmlProp.InnerText = XmlPropValueWriter.GetXmlTypedValue(vPropValue, vt);
				}
			}
			xmlProp.SetAttribute("data-size", XmlConvert.ToString(nDataSize));
		}

		/// <summary>
		/// Записывает данные объектного массивного свойства
		/// </summary>
		/// <param name="xobjOwner">владелец свойства</param>
		/// <param name="xmlProp">xml-свойство</param>
		/// <param name="vPropValue">Значение массивного свойства (null или Guid[])</param>
		/// <param name="nav">навигатор по список прогружаемых свойств</param>
		private void writeArrayProp(DomainObjectData xobjOwner, XmlElement xmlProp, object vPropValue, XPropInfoObject propInfo, PreloadsNavigator nav)
		{
			if (vPropValue == null)
			{
				if (!xobjOwner.IsNew)
					xmlProp.SetAttribute("loaded", "0");
			}
			else
			{
				// свойство есть и загруженное
				Guid[] oids = (Guid[])vPropValue;
				foreach(Guid valueOID in oids)
				{
					addValueIntoObjectProp(xobjOwner.Context, xmlProp, propInfo, valueOID, nav);
				}
			}
		}

		/// <summary>
		/// Добавляет значение в объектное свойство.
		/// Если объект-значение присутствует в контексте, то запускаем его сериализацию (serializeObject), иначе создаем болванку (тип+идентификатор)
		/// </summary>
		/// <param name="dataSet"></param>
		/// <param name="xmlProp">Текущее объектное свойство (скалярное или массивное)</param>
		/// <param name="propInfo">Метаданные свойства</param>
		/// <param name="valueOID">Идентификатор объекта-значения</param>
		private void addValueIntoObjectProp(DomainObjectDataSet dataSet, XmlElement xmlProp, XPropInfoObject propInfo, Guid valueOID, PreloadsNavigator nav)
		{
			XmlElement xmlObjectValue;			// xml-представление объект-значение 
			DomainObjectData xobjValue = null;	// объект-значение свойства в контексте

			// теоретически контекста может не быть
			if (dataSet != null && nav != null)
				xobjValue = dataSet.Find(propInfo.ReferedType.Name, valueOID);
			if (xobjValue != null && nav != null)
			{
				// Объект-значение свойства загружен в контекст и задан навигатор - запустим рекурсивно его сериализацию
				xmlObjectValue = serializeObject(xobjValue, xmlProp.OwnerDocument, nav);
			}
			else
			{
				xmlObjectValue = xmlProp.OwnerDocument.CreateElement(propInfo.ReferedType.Name);
				xmlObjectValue.SetAttribute("oid", valueOID.ToString());
			}
			// добавим объект-значение (буть-то ссылка или полный объект)
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
					// развернуть объекты в свойстве
					serializePropertyInternal(xobj, xmlProp, nav);
				else
					// в свойстве только заглушки
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
		/// Рекурсивно обходит xml-дерево и разбирает на отдельные объекты. 
		/// Каждый объект добавляется во множество методом Add.
		/// </summary>
		/// <param name="xmlRoot">лес xml-объектов, скрепленный тегом x-datagram, либо одиночный объект</param>
		private void parseXmlForest(XmlElement xmlRoot, DomainObjectDataSet dataSet)
		{
			// сформируем множество объектов подлежащих вставке, обновлению и удалению
			if (xmlRoot.LocalName == "x-datagram")
			{
				foreach(XmlElement xmlObject in xmlRoot.SelectNodes("*"))
					walkThroughXmlObjects(xmlObject, dataSet, true);
			}
			else
			{
				// на корневом уровне не x-datagram, считаем, что это одиночный объект
				walkThroughXmlObjects(xmlRoot, dataSet, true);
			}
		}

		/// <summary>
		/// Рекурсивно обходит дерево объектов и добавляет их в множество objSet
		/// </summary>
		/// <param name="xmlObject">текущий xml-объект</param>
		/// <param name="bIsRoot">Признак корневого объекта в пакете (x-datagram)</param>
		private void walkThroughXmlObjects(XmlElement xmlObject, DomainObjectDataSet dataSet, bool bIsRoot)
		{
			string sParentTypeName;		// наименование типа родительского объекта
			string sParentPropName;		// наименование родительского свойства
			XmlElement xmlProp;

			XTypeInfo typeInfo = m_mdManager.XModel.FindTypeByName(xmlObject.LocalName);
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
					XPropInfoObject xpropParent = (XPropInfoObject)m_mdManager.XModel.FindTypeByName(sParentTypeName).GetProp(sParentPropName);
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
				
				DeserializeObject(xmlObject, typeInfo, dataSet);
			}
			// по всем объектам (не заглушкам!) в объектных свойствах переданного xml-объекта
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
				// такого объекта нет в множестве: создадим его и добавить
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
				// объект уже присутствует
				if (bIsNew != xobj.IsNew)
					throw new XMergeConflictException("Объект " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] присутствует в нескольких несогласованных экземплярах: один помечен new='1', а другой нет ");
				if (bToDelete != xobj.ToDelete)
					throw new XMergeConflictException("Объект " + xobj.TypeInfo.Name + " [" + xobj.ObjectID + "] присутствует в нескольких несогласованных экземплярах: один помечен delete='1', а другой нет ");
				bNeedMerge = true;
			}
			if (xmlObject.HasAttribute("ts"))
				xobj.SetTS(Int64.Parse( xmlObject.GetAttribute("ts") ));
			// по всем свойствам без признака loaded="0"
			foreach(XmlElement xmlProp in xmlObject.SelectNodes("*[not(@loaded)]"))
			{
				XPropInfoBase propInfo = typeInfo.GetProp(xmlProp.LocalName);
				// xml-узлы не соответствующие свойствам из МД игнорируем
				if (propInfo == null)
					continue;

				if (!bToDelete && xmlProp.HasAttribute(XDatagram.ATTR_CHUNCK_CHAIN_ID))
					xobj.PropertiesWithChunkedData.Add(propInfo.Name, new Guid(xmlProp.GetAttribute(XDatagram.ATTR_CHUNCK_CHAIN_ID)));
				
				// членство в массиве проигнорируем
				if (propInfo is XPropInfoObjectArray)
					if (((XPropInfoObjectArray)propInfo).Capacity == XPropCapacity.ArrayMembership)
						continue;
				// пустые массивные свойства новых объектов проигнорируем
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
						// объектное массивное свойство
						bNeedScalarCheck = false;
						XPropCapacity capacity = ((XPropInfoObject)propInfo).Capacity;
						Guid[] valuesOld = (Guid[])vPropValueExist;
						Guid[] valuesCur = (Guid[])vPropValue;
						if (capacity == XPropCapacity.Array || (capacity == XPropCapacity.Link && ((XPropInfoObjectLink)propInfo).OrderByProp != null) )
						{
							// массивы и упорядоченные линки не подвергаются слиянию - только проверке на совпадение значений
							if (valuesOld.Length != valuesCur.Length)
								throw new XMergeConflictException("Не совпадает количество элементов в свойстве " + propInfo.Name);
							for(int i = 0;i<valuesOld.Length;++i)
								if (valuesOld[i] != valuesCur[i])
									throw new XMergeConflictException("Не совпадает значение свойства " + propInfo.Name);
						}
						else
						{
							// коллекция и членство в коллекции - произведем слияние
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
						// числовое свойтсво - будем сравнивать значения, если это не индексное свойство линка
						if (((XPropInfoNumeric)propInfo).OrderedLinkProp != null)
							bNeedScalarCheck = false;
					}
					if (bNeedScalarCheck)
					{
						// надо сравнить значения скалярного свойства
						// т.к. Equals - виртуальный метод, то должно работать
						if (!vPropValueExist.Equals(vPropValue))
							throw new XMergeConflictException("Значения свойства " + propInfo.Name + " не совпадают");
					}
				}
				xobj.SetUpdatedPropValue(propInfo.Name, vPropValue);
				// Удалено: кусочная загрузка (xmlProp.HasAttribute(ATTR_CHUNCK_CHAIN_ID))
			}
			return xobj;
		}

		/// <summary>
		/// Вовзращает типизированное значение свойства из xml-узла.
		/// Примечание: признак loaded=0 не проверяет
		/// </summary>
		/// <param name="xmlProp">xml-узел свойства</param>
		/// <param name="propInfo">метаданные свойства</param>
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
				// скалярное необъектное свойство
				propValue = XmlPropValueReader.GetTypedValueFromXml(xmlProp, propInfo.VarType);
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
								// объект-значение объектного свойства sPropName есть в контексте и он будет сохраняться
								if (xobjValue != null && xobjValue.HasNewData)
								{
									// если текущее свойство "членство в коллекции" и в объекте-значении есть обратное свойство (коллекция),
									// проверим, что обратное свойство содержит ссылку на текущий объект (xobj)
									if (propInfoObj.Capacity == XPropCapacity.CollectionMembership && xobjValue.HasUpdatedProp(propInfoObj.ReverseProp.Name))
									{
										Guid[] propRevValues = (Guid[])xobjValue.GetUpdatedPropValue(propInfoObj.ReverseProp.Name);
										Debug.Assert(propRevValues != null);
										// если обратное свойство (коллекция) не содержит ссылку на текущий объект - исключение
										if (Array.IndexOf(propRevValues, xobj.ObjectID) == -1)
											bError = true;
									}
									// если текущее свойство линк, то установим обратное свойство - объектный скаляр
									else if (propInfoObj.Capacity == XPropCapacity.Link)
									{
										vPropValue = xobjValue.GetUpdatedPropValue(propInfoObj.ReverseProp.Name);
										// если обратное свойство (скаляр) установлено, то проверим, что оно ссылается на текущий объект
										if (vPropValue != null)
										{
											Debug.Assert(vPropValue is Guid);
											if ((vPropValue is DBNull) || ((Guid)vPropValue) != xobj.ObjectID)
												bError = true;
										}
										// обратное свойство неустановлено - установим его на текущий объект
										else
										{
											xobjValue.SetUpdatedPropValue(propInfoObj.ReverseProp.Name, xobj.ObjectID);
										}
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
