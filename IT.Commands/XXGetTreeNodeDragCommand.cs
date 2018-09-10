using System;
using System.Xml;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Commands;

namespace Croc.XmlFramework.Extension.Commands
{
	/// <summary>
	/// Операция получения XML-описания операции переноса, соответствующего выбранному узлу
	/// иерархии объектов, отображаемой при помощи интерфейса
	/// полнофункционального Web-клиента.
	/// </summary>
	/// <remarks>
	/// Стандартная реализация полнофункционального Web-клиента в XFW .NET
	/// включает интерфейс иерархического представления данных объектов. Само
	/// иерархическое представление обеспечивается ActiveX-компонентой CROC.XTreeView
	/// библиотеки CROC.XControls; но кроме
	/// этого интерфейс включает механизмы выполнения операций переноса узлов в
	/// соответствии с выбранным узлом в иерархии.
	/// </remarks>                                                                                  
	public class XXGetTreeNodeDragCommand : XCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции. 
		/// Перегруженный, строго типизированный метод. Вызывается Ядром.
		/// </summary>
		/// <param name="oRequest">Запрос на выполнение операции.</param>
		/// <param name="oContext">Контекст выполнения операции.</param>
		/// <returns>Результат выполнения.</returns>
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance", "CA1822:MarkMembersAsStatic")]
		public XXGetNodeDragResponse Execute(XXGetTreeNodeDragRequest oRequest, IXExecutionContext oContext)
		{
			if (null == oRequest)
				throw new ArgumentNullException("oRequest");
			if (null == oContext)
				throw new ArgumentNullException("oContext");

			// Получаем описание иерархии
			XTreeInfo treeInfo = XInterfaceObjectsHolder.Instance.GetTreeInfo(oRequest.MetaName, oContext.Connection);

			// Получаем уровень иерархии
			XTreeLevelInfo treeLevelInfo = treeInfo.GetTreeLevel(oRequest.Path.GetNodeTypes());

			// Описатель операции переноса: 
			XXTreeNodeDrag treeNodeDrag = new XXTreeNodeDrag(treeLevelInfo, oContext.Connection.MetadataManager);

			if (treeNodeDrag.IsEmpty)
			{
				// нет меню для уровня иерархии
				return new XXGetNodeDragResponse(null);
			}
			else
			{
				// Нашли описания операции переноса; склонируем его, т.к. ссылки указывают 
				// непосредственно на XML, который держит менеджер метаданных
				XmlElement xmlNodeDragNode = (XmlElement)treeNodeDrag.XmlNodeDrag.CloneNode(true);

				// Проставим признак кешируемости операции переноса для клиента - атрибут 
				// cache-for узла i:node-drag; Сам атрибут определяется для операции переноса в 
				// метаданных; если не объявлен, считается, что кеширование 
				// задано для уровня (т.е. в качестве ключа используется путь):
				XTreeMenuCacheMode cacheMode = treeNodeDrag.CacheMode;
				if (cacheMode == XTreeMenuCacheMode.Unknow)
					cacheMode = XTreeMenuCacheMode.Level;
				xmlNodeDragNode.SetAttribute("cache-for", XTreeMenuCacheModeParser.ToString(cacheMode));

				return new XXGetNodeDragResponse(xmlNodeDragNode);
			}
		}
	}
}
