//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Xml;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Класс-форматировщик, реализующий логику перевода данных заданного 
	/// экземпляра DataTable в структурированный XML-документ
	/// </summary>
	public class DataTableCodeNamedXmlFormatter 
	{
		/// <summary>
		/// Внутренний класс - анализатор кодовых наименований, задаваемых как
		/// наименоания столбцов исходного DataTable
		/// </summary>
		internal class CodeNamedElement 
		{
			/// <summary>
			/// Исходное наименование, разбираемое экземпляром класса
			/// </summary>
			public string OwnOriginalName = null;
			/// <summary>
			/// Признак, указывающий что исходное наименование есть кодовое 
			/// наименование; наименование считается кодовым, если начинается 
			/// с символа точки
			/// </summary>
			public bool IsCodeNamed = false;
			/// <summary>
			/// Признак, указывающий, что элемент есть наименование "корневого" 
			/// элемента (т.е. элемента, явно подчиненног элементу строки)
			/// </summary>
			public bool IsRootName = true;
			/// <summary>
			/// Признак, указывающий, что эдемент есть наименование атрибута; 
			/// кодовое наименование элемента, к которому применяется атрибут,
			/// задается свойством ParentCodeName
			/// </summary>
			public bool IsAttributeName = false;
			/// <summary>
			/// Кодовое наименование "родительского" элемента, которому подчинен
			/// данный; если рассматриваемый элемент есть корневой, то значение
			/// этого свойства есть пустая строка; 
			/// </summary>
			public string ParentCodeName = null;
			/// <summary>
			/// Собственное наименование элемента, "очищенное" от спец. символов.
			/// Для элемента есть наименование его тега, для атрибута - наименование 
			/// атрибута
			/// </summary>
			public string OwnName  = null;

			/// <summary>
			/// Параметризированный конструктор класса; 
			/// задает исходное наименование элемента, для которого выполняется разбор
			/// </summary>
			/// <param name="sElementName">Исходное наименование элемента</param>
			public CodeNamedElement( string sElementName ) 
			{
				OwnOriginalName = sElementName;
				IsCodeNamed = sElementName.StartsWith(".");
				if ( !IsCodeNamed ) 
				{
					// Для не-кодовых наименований сохраняем только исходное, 
					// "собственное" наименование; все оставльные параметры не заданы:
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
					
					// Так как это уже "кодовый" элемент, то кол-во именованных частей в нем
					// более двух (т.к. "кодовые" начинаются с точки); если их больше двух -
					// значит у рассматриваемого есть "родительский":
					IsRootName = (nElementsQnt<=2);
					if ( !IsRootName )
					{
						ParentCodeName = OwnOriginalName.Substring( 0, OwnOriginalName.Length - OwnName.Length - (IsAttributeName? 1:0) - 1 );
						// Проверка на корректность наименований: в "родительском" 
						// наименовании не должно быть наименования атрибута
						if ( -1!=ParentCodeName.IndexOf('@') )
							throw new ApplicationException( 
								String.Format(
									"Некорректное наименование элемента {0}: наименование элемента-атрибута " +
									"не может использоваться для задания элементов, содержащих вложенные! " +
									"Ошибка задания наименования вышестоящего элемента {1}!",
									OwnOriginalName, ParentCodeName )
							);
					}
					else
						ParentCodeName = String.Empty;
				}
			}
		}
			
		
		/// <summary>
		/// Внутренний класс - форматировщик, реализующий логику перевода данных
		/// ОДНОЙ СТРОКИ DataTable в структурированный XML-элемент
		/// </summary>
		internal class DataRowFormatter 
		{
			/// <summary>
			/// "Корневой" XML-элемент, соответвтующий строке DataTable
			/// </summary>
			private XmlElement m_xmlRowElement = null;
			/// <summary>
			/// Коллекция XML-элементов, входящих в XML-структуру, соответствующую
			/// коллекции кодовых наименований столбцов DataTable; 
			/// ключ в хэше - это кодовое наименование, значение - соответствующий 
			/// XML-элемент в структуре 
			/// </summary>
			private Hashtable m_elements = new Hashtable();
				
			/// <summary>
			/// Внутренний метод - для заданного кодового наименования создает 
			/// соответствующий XML-элемент (в структуре XML-элементов строки - 
			/// все элементы подчинены элементу m_xmlRowElement), ЕСЛИ ЭТО 
			/// ВОЗМОЖНО. Элемент не создается, если
			/// -- переданное наименование не есть кодовое наименование
			/// -- переданное наименование есть наименование атрибута корневого 
			///		элемента или элемента, который уже создан
			///	-- переданное наименование есть наименование элемента, который 
			///		уже создан ранее
			/// </summary>
			/// <param name="element">Кодовое наименование, как экземпляр CodeNamedElement</param>
			/// <returns>
			/// Если соответствующий XML-элемент создан - возвращает true, 
			/// иначе - false.
			/// </returns>
			protected bool createXmlElement( CodeNamedElement element ) 
			{
				bool bHasProcessSmth = false;

				// Переданное наименование - это наименование атрибута?
				if (element.IsAttributeName)
				{
					if (element.IsRootName)
						// Если это наименование атрибута корневого элемента, 
						// который существует изначально - выходим
						return bHasProcessSmth ;
					else
						// если же это не корневой элемент - содадим его 
						// (рекурсивный вызов)
						element = new CodeNamedElement( element.ParentCodeName );
				}

				// Проверим, существует ли элемент среди созданных 
				if ( null==m_elements[element.OwnOriginalName] )
				{
					// Нет, такого элемента еще нет; Если элемент - корневой, 
					// создадим его и пропишем подчиненным элементу строки:
					if (element.IsRootName)
					{
						
						XmlElement xmlElement = m_xmlRowElement.OwnerDocument.CreateElement( element.OwnName );
						m_elements[element.OwnOriginalName] = xmlElement;
						m_xmlRowElement.AppendChild( xmlElement );
						bHasProcessSmth = true;
					}
						// Иначе проверим, существует ли для рассматриваемого 
						// родительский элемент. Если да, то создадим элемент
						// как подчиненный его родительскому 
					else if ( null!=m_elements[element.ParentCodeName] )
					{
						XmlElement xmlElement = m_xmlRowElement.OwnerDocument.CreateElement( element.OwnName );
						m_elements[element.OwnOriginalName] = xmlElement;
						((XmlElement)m_elements[element.ParentCodeName]).AppendChild( xmlElement );
						bHasProcessSmth = true;
					}
					else
					{
						// Если и родительского элемента нет - то сначала 
						// создадим родительский (для этого выполним парсинг
						// кодового наименования родительского элемента)
						CodeNamedElement implicitNamedElement = new CodeNamedElement( element.ParentCodeName );
						bHasProcessSmth = createXmlElement( implicitNamedElement );
						// ...затем снова попробуем создать рассматриваемый - 
						// сделаем это через рекурсивный вызов
						bHasProcessSmth = bHasProcessSmth | createXmlElement(element);
					}
				}
				return bHasProcessSmth;
			}

			
			/// <summary>
			/// Параметризированный конструктор
			/// Сразу же выполняет построение всей структуры XML-элементов, 
			/// подчиненных заданному XML-элементу строки, в соответствии 
			/// с переданной коллекцией кодовых наименований
			/// </summary>
			/// <param name="xmlRowElement"></param>
			/// <param name="arrCodeNamedElements"></param>
			public DataRowFormatter( XmlElement xmlRowElement, CodeNamedElement[] arrCodeNamedElements ) 
			{
				m_xmlRowElement = xmlRowElement;
				
				// Сразу же выполняем построение всей структуры подчиненных 
				// XML-элементов, необходимых для того, что бы сохранить 
				// данные строки DataTable
				// Построение структуры выполняется в соответствии с массивом
				// кодовых наименований, переданных параметром конструктора.

				// На первом уровне идея проста: пока есть что обрабатывать, 
				// обрабатываем:
				for( bool bHasProcessSmth=true; bHasProcessSmth; )
				{
					bHasProcessSmth = false;
					// На втором уровне: пройдемся по всему массиву кодовых 
					// наименований, и там где это возможно - создадим соотв.
					// элемент (см. реализацию метода createXmlElement):
					for( int nIndex=0; nIndex<arrCodeNamedElements.Length; nIndex++ )
					{
						CodeNamedElement element = arrCodeNamedElements[nIndex];
						if (element.IsCodeNamed)
							bHasProcessSmth = createXmlElement( element );
					}
				}
			}


			/// <summary>
			/// Устанавливает заданное типизированное значение как значение 
			/// XML-элемента/атрибута в структуре XML-элементов, соответствующих 
			/// одной строке DataTable. Идентификация нужного XML-элемента/атрибута
			/// выполняется по заданному кодовому наименованию 
			/// </summary>
			/// <param name="element">Кодовое наименование задаваемого элемента</param>
			/// <param name="value">Задаваемое значение</param>
			/// <remarks>
			/// Все задаваемые значения в данной реализации приводятся к строке явно,
			/// через ToString!
			/// </remarks>
			public void SetNamedElementValue( CodeNamedElement element, object value ) 
			{
				if ( !element.IsCodeNamed )
					throw new ArgumentException( "Элемент с наименованием " + element.OwnOriginalName + " не является специально именованным элементом!" );
					
				string sXmlElementName = (element.IsAttributeName? element.ParentCodeName : element.OwnOriginalName);
				if ( String.Empty!=sXmlElementName && !m_elements.ContainsKey(sXmlElementName) )
					throw new ArgumentException( "Элемента с наименованием " + sXmlElementName + " в структуре XML нет!" );
					
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
			/// Возвращает XML-элемент строки
			/// </summary>
			public XmlElement RowXmlElement 
			{
				get { return m_xmlRowElement; }
			}	
		}
			
			
		#region Внутренние переменные и методы класса 
		
		/// <summary>
		/// Результирующий XML-документ
		/// </summary>
		private XmlDocument m_xmlDocument = new XmlDocument();
		/// <summary>
		/// Корневой элемент результирующего документа
		/// </summary>
		private XmlElement m_xmlRootElement = null;

		#endregion

		/// <summary>
		/// Параметризированный конструктор объекта-форматировщика
		/// </summary>
		/// <param name="sRootElementName">Наименование корневого элемента документа</param>
		public DataTableCodeNamedXmlFormatter( string sRootElementName ) 
		{
			m_xmlRootElement = m_xmlDocument.CreateElement(sRootElementName);
			m_xmlDocument.AppendChild(m_xmlRootElement);
		}
			
			
		/// <summary>
		/// Выполняет преобразование исходного DataTable в XML-документ
		/// </summary>
		/// <param name="sourceData">Исходный DataTable</param>
		/// <param name="sRowElementName">Наименование корневого элемента</param>
		/// <returns>
		/// Если исходный DataTable пустой или не содержит данных (нулевое
		/// количество строк/столбцов), метод все равно возвращает XML-документ 
		/// с единственным - корневым - элементом
		/// </returns>
		public XmlDocument FormatNamedDataTable( DataTable sourceData, string sRowElementName ) 
		{
			if (null==sourceData)
				return m_xmlDocument;
			if (0==sourceData.Rows.Count || 0==sourceData.Columns.Count)
				return m_xmlDocument;
				
			// Формируем массив объектов - парсеров наименований столбцов исходного DataTable
			CodeNamedElement[] arrNamedElements = new CodeNamedElement[sourceData.Columns.Count];
			for( int nColIndex=0; nColIndex<sourceData.Columns.Count; nColIndex++ )
				arrNamedElements[nColIndex] =  new CodeNamedElement(sourceData.Columns[nColIndex].ColumnName);

			for ( int nRowIndex=0; nRowIndex<sourceData.Rows.Count; nRowIndex++ )
			{
				// Для каждой новой строки из DataTable создаем "внутренний" объект - 
				// форматировщик строки; уже в конструкторе этот объект создает 
				// необходимую XML-структуру для размещения данных строки
				XmlElement xmlRowElement = m_xmlDocument.CreateElement( sRowElementName );
				DataRowFormatter rowFormatter = new DataRowFormatter( xmlRowElement, arrNamedElements );
				
				// В созданную структуру записыаем данные...
				for( int nColIndex=0; nColIndex<sourceData.Columns.Count; nColIndex++ )
					rowFormatter.SetNamedElementValue( arrNamedElements[nColIndex], sourceData.Rows[nRowIndex][nColIndex] );
				
				// ...и все это вместе взятое - добавляем в итоговый документ
				m_xmlRootElement.AppendChild( rowFormatter.RowXmlElement );
			}

			return m_xmlDocument;
		}
	}
}