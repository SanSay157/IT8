using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Запрос для команды "MoveObject"
	/// </summary>
	[Serializable]
	public class MoveFolderRequest: XRequest
	{
		/// <summary>
		/// Массив идентификаторов переносимых папок
		/// </summary>
		public Guid[] ObjectsID;
		/// <summary>
		/// Сссылка на родительскую папку или Guid.Empty для переноса в корень
		/// </summary>
		public Guid NewParent;
		/// <summary>
		/// Ссылка на организацию-клиента
		/// </summary>
		public Guid NewCustomer;
		/// <summary>
		/// Ссылка на тип проектных затрат
		/// </summary>
		public Guid NewActivityType;
	}
}
