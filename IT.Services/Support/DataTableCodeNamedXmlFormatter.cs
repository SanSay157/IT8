//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Xml;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// �����-�������������, ����������� ������ �������� ������ ��������� 
	/// ���������� DataTable � ����������������� XML-��������
	/// </summary>
	public class DataTableCodeNamedXmlFormatter 
	{
		/// <summary>
		/// ���������� ����� - ���������� ������� ������������, ���������� ���
		/// ����������� �������� ��������� DataTable
		/// </summary>
		internal class CodeNamedElement 
		{
			/// <summary>
			/// �������� ������������, ����������� ����������� ������
			/// </summary>
			public string OwnOriginalName = null;
			/// <summary>
			/// �������, ����������� ��� �������� ������������ ���� ������� 
			/// ������������; ������������ ��������� �������, ���� ���������� 
			/// � ������� �����
			/// </summary>
			public bool IsCodeNamed = false;
			/// <summary>
			/// �������, �����������, ��� ������� ���� ������������ "���������" 
			/// �������� (�.�. ��������, ���� ����������� �������� ������)
			/// </summary>
			public bool IsRootName = true;
			/// <summary>
			/// �������, �����������, ��� ������� ���� ������������ ��������; 
			/// ������� ������������ ��������, � �������� ����������� �������,
			/// �������� ��������� ParentCodeName
			/// </summary>
			public bool IsAttributeName = false;
			/// <summary>
			/// ������� ������������ "�������������" ��������, �������� ��������
			/// ������; ���� ��������������� ������� ���� ��������, �� ��������
			/// ����� �������� ���� ������ ������; 
			/// </summary>
			public string ParentCodeName = null;
			/// <summary>
			/// ����������� ������������ ��������, "���������" �� ����. ��������.
			/// ��� �������� ���� ������������ ��� ����, ��� �������� - ������������ 
			/// ��������
			/// </summary>
			public string OwnName  = null;

			/// <summary>
			/// ������������������� ����������� ������; 
			/// ������ �������� ������������ ��������, ��� �������� ����������� ������
			/// </summary>
			/// <param name="sElementName">�������� ������������ ��������</param>
			public CodeNamedElement( string sElementName ) 
			{
				OwnOriginalName = sElementName;
				IsCodeNamed = sElementName.StartsWith(".");
				if ( !IsCodeNamed ) 
				{
					// ��� ��-������� ������������ ��������� ������ ��������, 
					// "�����������" ������������; ��� ���������� ��������� �� ������:
					IsRootName = false;
					IsAttributeName = false;
					ParentCodeName = null;
					OwnName  = null;
				}
				else
				{
					string[] arrNameElements = sElementName.Split('.');
					int nElementsQnt = arrNameElements.Length;
						
					IsAttributeName = arrNameElements[nElementsQnt-1].StartsWith("@");
					if (IsAttributeName)
						OwnName = arrNameElements[nElementsQnt-1].Substring(1);
					else
						OwnName = arrNameElements[nElementsQnt-1];
					
					// ��� ��� ��� ��� "�������" �������, �� ���-�� ����������� ������ � ���
					// ����� ���� (�.�. "�������" ���������� � �����); ���� �� ������ ���� -
					// ������ � ���������������� ���� "������������":
					IsRootName = (nElementsQnt<=2);
					if ( !IsRootName )
					{
						ParentCodeName = OwnOriginalName.Substring( 0, OwnOriginalName.Length - OwnName.Length - (IsAttributeName? 1:0) - 1 );
						// �������� �� ������������ ������������: � "������������" 
						// ������������ �� ������ ���� ������������ ��������
						if ( -1!=ParentCodeName.IndexOf('@') )
							throw new ApplicationException( 
								String.Format(
									"������������ ������������ �������� {0}: ������������ ��������-�������� " +
									"�� ����� �������������� ��� ������� ���������, ���������� ���������! " +
									"������ ������� ������������ ������������ �������� {1}!",
									OwnOriginalName, ParentCodeName )
							);
					}
					else
						ParentCodeName = String.Empty;
				}
			}
		}
			
		
		/// <summary>
		/// ���������� ����� - �������������, ����������� ������ �������� ������
		/// ����� ������ DataTable � ����������������� XML-�������
		/// </summary>
		internal class DataRowFormatter 
		{
			/// <summary>
			/// "��������" XML-�������, �������������� ������ DataTable
			/// </summary>
			private XmlElement m_xmlRowElement = null;
			/// <summary>
			/// ��������� XML-���������, �������� � XML-���������, ���������������
			/// ��������� ������� ������������ �������� DataTable; 
			/// ���� � ���� - ��� ������� ������������, �������� - ��������������� 
			/// XML-������� � ��������� 
			/// </summary>
			private Hashtable m_elements = new Hashtable();
				
			/// <summary>
			/// ���������� ����� - ��� ��������� �������� ������������ ������� 
			/// ��������������� XML-������� (� ��������� XML-��������� ������ - 
			/// ��� �������� ��������� �������� m_xmlRowElement), ���� ��� 
			/// ��������. ������� �� ���������, ����
			/// -- ���������� ������������ �� ���� ������� ������������
			/// -- ���������� ������������ ���� ������������ �������� ��������� 
			///		�������� ��� ��������, ������� ��� ������
			///	-- ���������� ������������ ���� ������������ ��������, ������� 
			///		��� ������ �����
			/// </summary>
			/// <param name="element">������� ������������, ��� ��������� CodeNamedElement</param>
			/// <returns>
			/// ���� ��������������� XML-������� ������ - ���������� true, 
			/// ����� - false.
			/// </returns>
			protected bool createXmlElement( CodeNamedElement element ) 
			{
				bool bHasProcessSmth = false;

				// ���������� ������������ - ��� ������������ ��������?
				if (element.IsAttributeName)
				{
					if (element.IsRootName)
						// ���� ��� ������������ �������� ��������� ��������, 
						// ������� ���������� ���������� - �������
						return bHasProcessSmth ;
					else
						// ���� �� ��� �� �������� ������� - ������� ��� 
						// (����������� �����)
						element = new CodeNamedElement( element.ParentCodeName );
				}

				// ��������, ���������� �� ������� ����� ��������� 
				if ( null==m_elements[element.OwnOriginalName] )
				{
					// ���, ������ �������� ��� ���; ���� ������� - ��������, 
					// �������� ��� � �������� ����������� �������� ������:
					if (element.IsRootName)
					{
						
						XmlElement xmlElement = m_xmlRowElement.OwnerDocument.CreateElement( element.OwnName );
						m_elements[element.OwnOriginalName] = xmlElement;
						m_xmlRowElement.AppendChild( xmlElement );
						bHasProcessSmth = true;
					}
						// ����� ��������, ���������� �� ��� ���������������� 
						// ������������ �������. ���� ��, �� �������� �������
						// ��� ����������� ��� ������������� 
					else if ( null!=m_elements[element.ParentCodeName] )
					{
						XmlElement xmlElement = m_xmlRowElement.OwnerDocument.CreateElement( element.OwnName );
						m_elements[element.OwnOriginalName] = xmlElement;
						((XmlElement)m_elements[element.ParentCodeName]).AppendChild( xmlElement );
						bHasProcessSmth = true;
					}
					else
					{
						// ���� � ������������� �������� ��� - �� ������� 
						// �������� ������������ (��� ����� �������� �������
						// �������� ������������ ������������� ��������)
						CodeNamedElement implicitNamedElement = new CodeNamedElement( element.ParentCodeName );
						bHasProcessSmth = createXmlElement( implicitNamedElement );
						// ...����� ����� ��������� ������� ��������������� - 
						// ������� ��� ����� ����������� �����
						bHasProcessSmth = bHasProcessSmth | createXmlElement(element);
					}
				}
				return bHasProcessSmth;
			}

			
			/// <summary>
			/// ������������������� �����������
			/// ����� �� ��������� ���������� ���� ��������� XML-���������, 
			/// ����������� ��������� XML-�������� ������, � ������������ 
			/// � ���������� ���������� ������� ������������
			/// </summary>
			/// <param name="xmlRowElement"></param>
			/// <param name="arrCodeNamedElements"></param>
			public DataRowFormatter( XmlElement xmlRowElement, CodeNamedElement[] arrCodeNamedElements ) 
			{
				m_xmlRowElement = xmlRowElement;
				
				// ����� �� ��������� ���������� ���� ��������� ����������� 
				// XML-���������, ����������� ��� ����, ��� �� ��������� 
				// ������ ������ DataTable
				// ���������� ��������� ����������� � ������������ � ��������
				// ������� ������������, ���������� ���������� ������������.

				// �� ������ ������ ���� ������: ���� ���� ��� ������������, 
				// ������������:
				for( bool bHasProcessSmth=true; bHasProcessSmth; )
				{
					bHasProcessSmth = false;
					// �� ������ ������: ��������� �� ����� ������� ������� 
					// ������������, � ��� ��� ��� �������� - �������� �����.
					// ������� (��. ���������� ������ createXmlElement):
					for( int nIndex=0; nIndex<arrCodeNamedElements.Length; nIndex++ )
					{
						CodeNamedElement element = arrCodeNamedElements[nIndex];
						if (element.IsCodeNamed)
							bHasProcessSmth = createXmlElement( element );
					}
				}
			}


			/// <summary>
			/// ������������� �������� �������������� �������� ��� �������� 
			/// XML-��������/�������� � ��������� XML-���������, ��������������� 
			/// ����� ������ DataTable. ������������� ������� XML-��������/��������
			/// ����������� �� ��������� �������� ������������ 
			/// </summary>
			/// <param name="element">������� ������������ ����������� ��������</param>
			/// <param name="value">���������� ��������</param>
			/// <remarks>
			/// ��� ���������� �������� � ������ ���������� ���������� � ������ ����,
			/// ����� ToString!
			/// </remarks>
			public void SetNamedElementValue( CodeNamedElement element, object value ) 
			{
				if ( !element.IsCodeNamed )
					throw new ArgumentException( "������� � ������������� " + element.OwnOriginalName + " �� �������� ���������� ����������� ���������!" );
					
				string sXmlElementName = (element.IsAttributeName? element.ParentCodeName : element.OwnOriginalName);
				if ( String.Empty!=sXmlElementName && !m_elements.ContainsKey(sXmlElementName) )
					throw new ArgumentException( "�������� � ������������� " + sXmlElementName + " � ��������� XML ���!" );
					
				XmlElement xmlElement = null;
				if ( String.Empty!=sXmlElementName )
					xmlElement = (XmlElement)m_elements[sXmlElementName];
				else
					xmlElement = m_xmlRowElement;

				if (element.IsAttributeName)
					xmlElement.SetAttribute( element.OwnName, value.ToString() );
				else
					xmlElement.InnerText = value.ToString();
			}

			
			/// <summary>
			/// ���������� XML-������� ������
			/// </summary>
			public XmlElement RowXmlElement 
			{
				get { return m_xmlRowElement; }
			}	
		}
			
			
		#region ���������� ���������� � ������ ������ 
		
		/// <summary>
		/// �������������� XML-��������
		/// </summary>
		private XmlDocument m_xmlDocument = new XmlDocument();
		/// <summary>
		/// �������� ������� ��������������� ���������
		/// </summary>
		private XmlElement m_xmlRootElement = null;

		#endregion

		/// <summary>
		/// ������������������� ����������� �������-��������������
		/// </summary>
		/// <param name="sRootElementName">������������ ��������� �������� ���������</param>
		public DataTableCodeNamedXmlFormatter( string sRootElementName ) 
		{
			m_xmlRootElement = m_xmlDocument.CreateElement(sRootElementName);
			m_xmlDocument.AppendChild(m_xmlRootElement);
		}
			
			
		/// <summary>
		/// ��������� �������������� ��������� DataTable � XML-��������
		/// </summary>
		/// <param name="sourceData">�������� DataTable</param>
		/// <param name="sRowElementName">������������ ��������� ��������</param>
		/// <returns>
		/// ���� �������� DataTable ������ ��� �� �������� ������ (�������
		/// ���������� �����/��������), ����� ��� ����� ���������� XML-�������� 
		/// � ������������ - �������� - ���������
		/// </returns>
		public XmlDocument FormatNamedDataTable( DataTable sourceData, string sRowElementName ) 
		{
			if (null==sourceData)
				return m_xmlDocument;
			if (0==sourceData.Rows.Count || 0==sourceData.Columns.Count)
				return m_xmlDocument;
				
			// ��������� ������ �������� - �������� ������������ �������� ��������� DataTable
			CodeNamedElement[] arrNamedElements = new CodeNamedElement[sourceData.Columns.Count];
			for( int nColIndex=0; nColIndex<sourceData.Columns.Count; nColIndex++ )
				arrNamedElements[nColIndex] =  new CodeNamedElement(sourceData.Columns[nColIndex].ColumnName);

			for ( int nRowIndex=0; nRowIndex<sourceData.Rows.Count; nRowIndex++ )
			{
				// ��� ������ ����� ������ �� DataTable ������� "����������" ������ - 
				// ������������� ������; ��� � ������������ ���� ������ ������� 
				// ����������� XML-��������� ��� ���������� ������ ������
				XmlElement xmlRowElement = m_xmlDocument.CreateElement( sRowElementName );
				DataRowFormatter rowFormatter = new DataRowFormatter( xmlRowElement, arrNamedElements );
				
				// � ��������� ��������� ��������� ������...
				for( int nColIndex=0; nColIndex<sourceData.Columns.Count; nColIndex++ )
					rowFormatter.SetNamedElementValue( arrNamedElements[nColIndex], sourceData.Rows[nRowIndex][nColIndex] );
				
				// ...� ��� ��� ������ ������ - ��������� � �������� ��������
				m_xmlRootElement.AppendChild( rowFormatter.RowXmlElement );
			}

			return m_xmlDocument;
		}
	}
}