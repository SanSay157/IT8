//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос команды переноса объектов
	/// </summary>
	[Serializable]
	public class MoveObjectsRequest: XRequest
	{
		/// <summary>
		/// Наименование типа переносимого объекта
		/// </summary>
		public string SelectedObjectType;
		/// <summary>
		/// Массив идентификаторов переносимых объектов
		/// </summary>
		public Guid[] SelectedObjectsID;
		/// <summary>
		/// Идентификатор нового родителя или Guid.Empty при переносе на корень
		/// </summary>
		public Guid NewParent;
		/// <summary>
		/// наименование свойства - ссылка на родительский объект
		/// </summary>
		public string ParentPropName;
		/// <summary>
		/// Наименование свойства - ссылка на владельца "рощи" - для секционированной конфигурации иерархии,
		/// т.е. когда тип SelectedObjectType разделен на подмножества, 
		/// в которых все объекты имеют одинаковое значение свойства SubTreeSelectorPropName.
		/// Нумерация L/R-индексов осуществляется в пределах этих подмножеств.
		/// </summary>
		public string SubTreeSelectorPropName;
	}
}
