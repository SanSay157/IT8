using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.XmlFramework.Extension.Commands 
{
	/// <summary>
	/// Объект, представляющий данные запроса на выполнение операции получения
	/// XML-описания опреации переноса для узла иерархии <b>GetTreeNodeDrag</b> (см. реализацию
	/// операции XGetTreeNodeDragCommand).
	/// </summary>                                            
	[Serializable]
	public class XXGetTreeNodeDragRequest : XTreeBaseRequest 
	{
		/// <summary>
		/// Наименование операции в перечне операций по умолчанию.
		/// </summary>
		private const string DEF_COMMAND_NAME = "GetTreeNodeDrag";
		
		#region Конструкторы объекта запроса 
		
		/// <summary>
		/// Конструктор по умолчанию, инициализирует свойство MetaName />
		/// значением null, свойство Path />
		/// \- экземпляром объекта XTreePath />,
		/// представляющим пустой &quot;путь&quot;. 
		/// </summary>                                                                                                                           
		public XXGetTreeNodeDragRequest()
			: base(DEF_COMMAND_NAME) 
		{}

		
		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="metaName">Строка (System.String) с наименованием
		///                        определения структуры иерархии в метаданных;
		///                        инициализирует значение свойства MetaName.
		///                        Задание значения параметра обязательно; задание
		///                        null или пустой строки недопустимо \- в этом
		///                        случае будет сгенерировано исключение ArgumentNullException
		///                        или ArgumentException
		///                        соответственно. </param>
		/// <exception cref="ArgumentException">Если в качестве значения
		///                                     параметра <b><i>metaName</i></b>
		///                                     задана пустая строка. </exception>
		/// <exception cref="ArgumentNullException">Если параметр <b><i>metaName</i></b>
		///                                         задан в null. </exception>                                                                          
		public XXGetTreeNodeDragRequest(string metaName) 
			: base(DEF_COMMAND_NAME) 
		{
			this.MetaName = metaName;
		}

		
		/// <summary>
		/// Параметризированный конструктор.
		/// </summary>
		/// <param name="metaName">Строка (System.String) с наименованием
		///                        определения структуры иерархии в метаданных;
		///                        инициализирует значение свойства MetaName.
		///                        Задание значения параметра обязательно; задание
		///                        null или пустой строки недопустимо \- в этом
		///                        случае будет сгенерировано исключение ArgumentNullException
		///                        или ArgumentException
		///                        соответственно. </param>
		/// <param name="treePath">Экземпляр объекта XTreePath,
		///                        задающий &quot;путь&quot; для узла в иерархии,
		///                        для которого требуется получить описание меню;
		///                        инициализирует значение свойства Path.<para></para>Если
		///                        заданный объект XTreePath
		///                        описывает пустой путь (т.е. &quot;длина&quot;
		///                        пути Length
		///                        нулевая) \- то операция выполняет получение
		///                        данных для пустой иерархии (определяемое
		///                        элементом <b>i\:empty\-tree\-menu</b>). </param>
		/// <exception cref="ArgumentException">Если в качестве значения
		///                                     параметра <b><i>metaName</i></b>
		///                                     задана пустая строка. </exception>
		/// <exception cref="ArgumentNullException">Если параметр <b><i>metaName</i></b>
		///                                         задан в null. </exception>                                                                                   
		public XXGetTreeNodeDragRequest(string metaName, XTreePath treePath)
			: base(DEF_COMMAND_NAME) 
		{
			MetaName = metaName;
			Path = treePath;
		}


		#endregion


		/// <summary>
		/// Метод проверки данных запроса. 
		/// Вызывается Ядром перед передачей объекта в прикладной код.
		/// </summary>
		/// <remarks>
		/// Метод проверяет, чтобы наименование описания структуры иерархии в 
		/// метаданных было задано (явно или в результате разбора XML-запроса).
		/// </remarks>
		public override void Validate() 
		{
			// Вызываем базовую реализацию - проверка свойств базового класса
			base.Validate();

			// Наименование описания структуры иерархии в метаданных должно 
			// быть задано (явно или в результате разбора XML-запроса):
			XRequest.ValidateRequiredArgument( MetaName, "MetaName" );
		}
	}
}