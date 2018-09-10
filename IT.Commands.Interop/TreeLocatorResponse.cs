using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Ответ команд поиска объектов в дереве
	/// </summary>
	[Serializable]
	public class TreeLocatorResponse: XResponse
	{
		/// <summary>
		/// Путь в дереве от искомого объекта до корня в формате CROC.XTreeView
		/// </summary>
		public string TreePath;
		/// <summary>
		/// Идентификатор найденного объекта. Если объект не найден, то Guid.Empty
		/// </summary>
		public Guid ObjectID;
		/// <summary>
		/// Признак, что в БД есть еще объекты удовлетворяющиее условиям поиска
		/// </summary>
		public bool More;

		/// <summary>
		/// Обязательный конструктор для десериализации
		/// </summary>
		public TreeLocatorResponse()
		{}

		/// <summary>
		/// ctor
		/// </summary>
		/// <param name="sTreePath">Путь в дереве</param>
		/// <param name="oid">Идентификатор найденного объекта</param>
		/// <param name="bMore">Признак, что в БД есть еще объекты удовлетворяющиее условиям поиска</param>
		public TreeLocatorResponse(string sTreePath, Guid oid, bool bMore)
		{
			TreePath = sTreePath;
			ObjectID = oid;
			More = bMore;
		}
	}
}
