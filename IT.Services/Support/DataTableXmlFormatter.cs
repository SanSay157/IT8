//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Data;
using System.Diagnostics;
using System.Xml;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Класс-форматировщик, реализующий логику перевода данных заданного 
	/// экземпляра DataTable в XML-документ.
	/// Итоговый XML-документ включает каждую строку DataTable как отдельный
	/// элемент с заданным фиксированным наименованием. Все значения строки 
	/// отражаются как значения атрибутов этого элемента; При этом наименования 
	/// атрибутов соответствуют наименованиям столбцов DataTable.
	/// </summary>
	public class DataTableXmlFormatter
	{
		/// <summary>
		/// Константное наименование корневого элемента XML-списка
		/// </summary>
		public static readonly string DEFAULT_ROOT_ELEMENT_NAME = "Root";
		/// <summary>
		/// Константное наименование элемента XML-списка
		/// </summary>
		public static readonly string DEFAULT_ITEM_ELEMENT_NAME = "Item";
		
		#region Внутренние переменные и методы класса

		/// <summary>
		/// Выполняет явное приведение заданного типизированного значения к строке
		/// </summary>
		/// <param name="vValue">Значение, как object</param>
		/// <param name="valueType">Исходеый тип значения</param>
		/// <returns>Строковое представление заданного типизированного значения</returns>
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
						throw new ArgumentException( "Неподдерживаемый тип значения: " + valueType.FullName );
				}
			}
			return sResult;
		}

		
		/// <summary>
		/// Выполняет явное приведение заданного типизированного значения 
		/// к логическому типу (true/false);
		/// </summary>
		/// <param name="vValue">Значение, как object</param>
		/// <param name="valueType">Исходеый тип значения</param>
		/// <returns>
		/// Логическое значение, соотв. исходному типизированному:
		///	-- для всех числовых типов: false - если 0, иначе true;
		///	-- для сторокового типа: false - если null или пустая строка, иначе true;
		///	-- для даты/времени: false, если значение соотв. MinValue, иначе true;
		///	-- для периодов (TimeSpan): false, если значение есть TimeSpan.Zero;
		///	-- для GUID-ов: false, если значение есть Guig.Empty; иначе true;
		///	-- для null: всегда false;
		/// </returns>
		/// <exception cref="ArgumentException">
		/// В случае значений, тип которого не соотносится ни с одним из указанных
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
					default: throw new ArgumentException( "Неподдерживаемый тип значения: " + valueType.FullName );
				}
			}
			return bResult;
		}

		
		#endregion

		/// <summary>
		/// Массив наименований столбцов преобразуемого DataTable, значения 
		/// которых будут явно приводится к логическому типу, и будут 
		/// представлены в результирующем XML-списке атрибутами со значениями
		/// "true" / "false";
		/// </summary>
		public static string[] DirectBooleanFieldNames;

		
		/// <summary>
		/// Метод форматирования заданного экземпляра DataTable в XML-документ
		/// </summary>
		/// <param name="oDataTable">Исходный DataTable, отражаемый в XML-документ</param>
		/// <param name="sRootElementName">Наименование корневого элемента</param>
		/// <param name="sItemElementName">Наименование элемента, соотв. строке DataTable</param>
		/// <returns>
		/// Итоговый XML-документ включает каждую строку DataTable как отдельный
		/// элемент с наименованием, заданным параметром sItemElementName. Все 
		/// значения строки отражаются как значения атрибутов этого элемента.
		/// При этом наименования атрибутов соотв. наименованиям столбцов 
		/// DataTable. Все эдементы являются подчиненными корневому элементу,
		/// наименование которого задает параметр sRootElementName.
		/// Если исходный DataTable есть null, или не содержить строк / столбцов, 
		/// то результирующий XML-документ будет содрежать только корневой элемент
		/// </returns>
		public static XmlDocument GetXmlFromDataTable( 
			DataTable oDataTable, 
			string sRootElementName,
			string sItemElementName ) 
		{
			// "Защитная" проверка обязательных входных параметров:
			if (null == sRootElementName || String.Empty == sRootElementName) throw new ApplicationException("Значение параметра sRootElementName не задано!");
			if (null == sItemElementName || String.Empty == sItemElementName) throw new ApplicationException("Значение параметра sItemElementName не задано!");

			XmlDocument xmlResultDocument = new XmlDocument();
			// Создаем корневой элемент результирующего XML-документа:
			XmlElement xmlRootElement = xmlResultDocument.CreateElement( sRootElementName );
			xmlResultDocument.AppendChild( xmlRootElement );

			if (null!=oDataTable)
			{
				// Делаем ЛОКАЛЬНУЮ копию массива наименований столбцов, значения 
				// которых д.б. представлены в виде значений true/false. 
				// Все время копирования исходный статический массив доступен только
				// для одной нити процесса - а далее работа ведется только с локальной
				// копией массива. Копия будет создана, даже если исходный статический
				// вариант не задан - будет массив нулевой длины (для упрощения 
				// проверок далее)
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
					// Создаем элемент, соответствующей строке DataTable
					XmlElement xmlItemElement = xmlResultDocument.CreateElement( sItemElementName );
					for( int nFieldIndex=0; nFieldIndex<oDataTable.Columns.Count; nFieldIndex++ )
					{
						if ( !oDataTable.Rows[nRowIndex].IsNull(nFieldIndex) )
						{
							// Значение элемента 
							object oValue = oDataTable.Rows[nRowIndex][nFieldIndex];
							
							if (null!=oValue && DBNull.Value!=oValue)
							{
								// Наименование элемента - и оно же наименование атрибута
								string sName = oDataTable.Columns[nFieldIndex].ColumnName;
								// Тип значения элемента
								Type typeValue = oDataTable.Columns[nFieldIndex].DataType;
								// Значение в строковом виде, для атрибута: 
								string sAttributeValue = null;

								if ( -1!=Array.IndexOf(local_arrDirectBooleanFieldNames,sName) )
									sAttributeValue = (typedValueToBoolen(oValue,typeValue)? "true" : "false");
								else
									sAttributeValue = typedValueToString( oValue,typeValue );

								// Значение атрибута проставляем только если оно не пустое:
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