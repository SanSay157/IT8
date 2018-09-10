//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Data;
using System.Diagnostics;
using System.Xml;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// �����-�������������, ����������� ������ �������� ������ ��������� 
	/// ���������� DataTable � XML-��������.
	/// �������� XML-�������� �������� ������ ������ DataTable ��� ���������
	/// ������� � �������� ������������� �������������. ��� �������� ������ 
	/// ���������� ��� �������� ��������� ����� ��������; ��� ���� ������������ 
	/// ��������� ������������� ������������� �������� DataTable.
	/// </summary>
	public class DataTableXmlFormatter
	{
		/// <summary>
		/// ����������� ������������ ��������� �������� XML-������
		/// </summary>
		public static readonly string DEFAULT_ROOT_ELEMENT_NAME = "Root";
		/// <summary>
		/// ����������� ������������ �������� XML-������
		/// </summary>
		public static readonly string DEFAULT_ITEM_ELEMENT_NAME = "Item";
		
		#region ���������� ���������� � ������ ������

		/// <summary>
		/// ��������� ����� ���������� ��������� ��������������� �������� � ������
		/// </summary>
		/// <param name="vValue">��������, ��� object</param>
		/// <param name="valueType">�������� ��� ��������</param>
		/// <returns>��������� ������������� ��������� ��������������� ��������</returns>
		private static string typedValueToString( object vValue, Type valueType ) 
		{
			string sResult = String.Empty;
			if ( null!=vValue && DBNull.Value!=vValue )
			{	
				switch(valueType.FullName)
				{
					case "System.Boolean":	sResult = XmlConvert.ToString((bool)vValue);		break;
					case "System.Byte":		sResult = XmlConvert.ToString((Byte)vValue);		break;
					case "System.Char":		sResult = XmlConvert.ToString((Char)vValue);		break;
					case "System.DateTime":	sResult = XmlConvert.ToString((DateTime)vValue, XmlDateTimeSerializationMode.Unspecified);	break;
					case "System.Decimal":	sResult = XmlConvert.ToString((Decimal)vValue);		break;
					case "System.Double":	sResult = XmlConvert.ToString((Double)vValue);		break;
					case "System.Guid":		sResult = XmlConvert.ToString((Guid)vValue);		break;
					case "System.Int16":	sResult = XmlConvert.ToString((Int16)vValue);		break;
					case "System.Int32":	sResult = XmlConvert.ToString((Int32)vValue);		break;
					case "System.Int64":	sResult = XmlConvert.ToString((Int64)vValue);		break;
					case "System.SByte":	sResult = XmlConvert.ToString((SByte)vValue);		break;
					case "System.Single":	sResult = XmlConvert.ToString((Single)vValue);		break;
					case "System.TimeSpan":	sResult = XmlConvert.ToString((TimeSpan)vValue);	break;
					case "System.UInt16":	sResult = XmlConvert.ToString((UInt16)vValue);		break;
					case "System.UInt32":	sResult = XmlConvert.ToString((UInt32)vValue);		break;
					case "System.UInt64":	sResult = XmlConvert.ToString((UInt64)vValue);		break;
					case "System.String":	sResult = vValue.ToString();break;
					default:
						throw new ArgumentException( "���������������� ��� ��������: " + valueType.FullName );
				}
			}
			return sResult;
		}

		
		/// <summary>
		/// ��������� ����� ���������� ��������� ��������������� �������� 
		/// � ����������� ���� (true/false);
		/// </summary>
		/// <param name="vValue">��������, ��� object</param>
		/// <param name="valueType">�������� ��� ��������</param>
		/// <returns>
		/// ���������� ��������, �����. ��������� ���������������:
		///	-- ��� ���� �������� �����: false - ���� 0, ����� true;
		///	-- ��� ����������� ����: false - ���� null ��� ������ ������, ����� true;
		///	-- ��� ����/�������: false, ���� �������� �����. MinValue, ����� true;
		///	-- ��� �������� (TimeSpan): false, ���� �������� ���� TimeSpan.Zero;
		///	-- ��� GUID-��: false, ���� �������� ���� Guig.Empty; ����� true;
		///	-- ��� null: ������ false;
		/// </returns>
		/// <exception cref="ArgumentException">
		/// � ������ ��������, ��� �������� �� ����������� �� � ����� �� ���������
		/// </exception>
		private static bool typedValueToBoolen( object vValue, Type valueType ) 
		{
			bool bResult = false;
			if ( null!=vValue && DBNull.Value!=vValue )
			{	
				switch(valueType.FullName)
				{
					case "System.Boolean":	bResult = ( true == (bool)vValue );	 break;
					case "System.Byte":		bResult = ( (Byte)vValue > 0 ); break;
					case "System.Char":		bResult = ( (Char)vValue!='0' ); break;
					case "System.DateTime":	bResult = ( (DateTime)vValue!=DateTime.MinValue ); break;
					case "System.Decimal":	bResult = ( (Decimal)vValue > 0 ); break;
					case "System.Double":	bResult = ( (Double)vValue > 0 ); break;
					case "System.Guid":		bResult = ( (Guid)vValue != Guid.Empty); break;
					case "System.Int16":	bResult = ( (Int16)vValue > 0 ); break;
					case "System.Int32":	bResult = ( (Int32)vValue > 0 ); break;
					case "System.Int64":	bResult = ( (Int64)vValue > 0 ); break;
					case "System.SByte":	bResult = ( (SByte)vValue > 0 ); break;
					case "System.Single":	bResult = ( (Single)vValue > 0 ); break;
					case "System.TimeSpan":	bResult = ( (TimeSpan)vValue != TimeSpan.Zero ); break;
					case "System.UInt16":	bResult = ( (UInt16)vValue > 0 ); break;
					case "System.UInt32":	bResult = ( (UInt32)vValue > 0 ); break;
					case "System.UInt64":	bResult = ( (UInt64)vValue > 0 ); break;
					case "System.String":	bResult = ( null!=vValue && String.Empty!=vValue.ToString() );	break;
					default: throw new ArgumentException( "���������������� ��� ��������: " + valueType.FullName );
				}
			}
			return bResult;
		}

		
		#endregion

		/// <summary>
		/// ������ ������������ �������� �������������� DataTable, �������� 
		/// ������� ����� ���� ���������� � ����������� ����, � ����� 
		/// ������������ � �������������� XML-������ ���������� �� ����������
		/// "true" / "false";
		/// </summary>
		public static string[] DirectBooleanFieldNames;

		
		/// <summary>
		/// ����� �������������� ��������� ���������� DataTable � XML-��������
		/// </summary>
		/// <param name="oDataTable">�������� DataTable, ���������� � XML-��������</param>
		/// <param name="sRootElementName">������������ ��������� ��������</param>
		/// <param name="sItemElementName">������������ ��������, �����. ������ DataTable</param>
		/// <returns>
		/// �������� XML-�������� �������� ������ ������ DataTable ��� ���������
		/// ������� � �������������, �������� ���������� sItemElementName. ��� 
		/// �������� ������ ���������� ��� �������� ��������� ����� ��������.
		/// ��� ���� ������������ ��������� �����. ������������� �������� 
		/// DataTable. ��� �������� �������� ������������ ��������� ��������,
		/// ������������ �������� ������ �������� sRootElementName.
		/// ���� �������� DataTable ���� null, ��� �� ��������� ����� / ��������, 
		/// �� �������������� XML-�������� ����� ��������� ������ �������� �������
		/// </returns>
		public static XmlDocument GetXmlFromDataTable( 
			DataTable oDataTable, 
			string sRootElementName,
			string sItemElementName ) 
		{
			// "��������" �������� ������������ ������� ����������:
			if (null == sRootElementName || String.Empty == sRootElementName) throw new ApplicationException("�������� ��������� sRootElementName �� ������!");
			if (null == sItemElementName || String.Empty == sItemElementName) throw new ApplicationException("�������� ��������� sItemElementName �� ������!");

			XmlDocument xmlResultDocument = new XmlDocument();
			// ������� �������� ������� ��������������� XML-���������:
			XmlElement xmlRootElement = xmlResultDocument.CreateElement( sRootElementName );
			xmlResultDocument.AppendChild( xmlRootElement );

			if (null!=oDataTable)
			{
				// ������ ��������� ����� ������� ������������ ��������, �������� 
				// ������� �.�. ������������ � ���� �������� true/false. 
				// ��� ����� ����������� �������� ����������� ������ �������� ������
				// ��� ����� ���� �������� - � ����� ������ ������� ������ � ���������
				// ������ �������. ����� ����� �������, ���� ���� �������� �����������
				// ������� �� ����� - ����� ������ ������� ����� (��� ��������� 
				// �������� �����)
				string[] local_arrDirectBooleanFieldNames = null;
				if ( null!=DirectBooleanFieldNames && 0!=DirectBooleanFieldNames.Length)
				{
					lock(DirectBooleanFieldNames)
					{
						local_arrDirectBooleanFieldNames = new string[DirectBooleanFieldNames.Length];
						DirectBooleanFieldNames.CopyTo(local_arrDirectBooleanFieldNames,0);
					}
				}
				else
					local_arrDirectBooleanFieldNames = new string[0];

				for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
				{
					// ������� �������, ��������������� ������ DataTable
					XmlElement xmlItemElement = xmlResultDocument.CreateElement( sItemElementName );
					for( int nFieldIndex=0; nFieldIndex<oDataTable.Columns.Count; nFieldIndex++ )
					{
						if ( !oDataTable.Rows[nRowIndex].IsNull(nFieldIndex) )
						{
							// �������� �������� 
							object oValue = oDataTable.Rows[nRowIndex][nFieldIndex];
							
							if (null!=oValue && DBNull.Value!=oValue)
							{
								// ������������ �������� - � ��� �� ������������ ��������
								string sName = oDataTable.Columns[nFieldIndex].ColumnName;
								// ��� �������� ��������
								Type typeValue = oDataTable.Columns[nFieldIndex].DataType;
								// �������� � ��������� ����, ��� ��������: 
								string sAttributeValue = null;

								if ( -1!=Array.IndexOf(local_arrDirectBooleanFieldNames,sName) )
									sAttributeValue = (typedValueToBoolen(oValue,typeValue)? "true" : "false");
								else
									sAttributeValue = typedValueToString( oValue,typeValue );

								// �������� �������� ����������� ������ ���� ��� �� ������:
								if ( 0!=sAttributeValue.Length )
									xmlItemElement.SetAttribute( sName, sAttributeValue );
							}
						}
					}
					xmlRootElement.AppendChild( xmlItemElement );
				}
			}
			return xmlResultDocument;
		}
	}
}