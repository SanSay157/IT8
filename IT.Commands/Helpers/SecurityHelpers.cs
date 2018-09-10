//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System.Collections;
using System.Text;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Hierarchy;

namespace Croc.IncidentTracker.Commands.Security
{
	/// <summary>
	/// Содержит статические методы записи прав  на новые/существующие объектов
	/// в параметры объекта - исполняемого пункта меню
	/// </summary>
    class MenuObjectRightsFormatter
	{
		/// <summary>
        /// Метод записи прав на новый объект в параметр "ObjectRights" объекта-пункта меню
		/// </summary>
		/// <param name="menuitem">объект - пункт меню</param>
		/// <param name="create_rights">объект прав на новый объект</param>
        public static void Write(XMenuActionItem menuitem, XNewObjectRights create_rights)
		{
            //если есть свойства,доступные только для чтения - то записываем их
            if (create_rights.HasReadOnlyProps)
			{
				StringBuilder bld = new StringBuilder();
				writeReadOnlyProps(bld, create_rights.GetReadOnlyPropNames());
				menuitem.Parameters.Add("ObjectRights", bld.ToString());
			}
		}

        /// <summary>
        /// Метод записи прав на существующий объект в параметр "ObjectRights" объекта-пункта меню
        /// </summary>
        /// <param name="menuitem">объект - пункт меню</param>
        /// <param name="rights">права на существующий объект</param>
		public static void Write(XMenuActionItem menuitem, XObjectRights rights)
		{
			StringBuilder bld = new StringBuilder();
            //права на удаление
			if (!rights.AllowDelete)
				bld.Append(".deny-delete:1;");
            //права на изменение свойств
			if (!rights.AllowParticalOrFullChange)
				bld.Append(".deny-change:1;");
            //если есть свойства,доступные только для чтения - также записываем их
			else if (rights.HasReadOnlyProps)
			{
				writeReadOnlyProps(bld, rights.GetReadOnlyPropNames());
			}
			if (bld.Length > 0)
				menuitem.Parameters.Add("ObjectRights", bld.ToString());
		}

        /// <summary>
        /// Метод записи свойств доступных только для чтения
        /// </summary>
        /// <param name="bld">строка для записи</param>
        /// <param name="props">коллекция наименований свойств,доступных только для чтения</param>
		private static void writeReadOnlyProps(StringBuilder bld, ICollection props)
		{
			bld.Append(".read-only-props:");
			foreach(string sProp in props)
			{
				bld.Append(sProp);
				bld.Append(",");
			}
			bld.Length--;
			bld.Append(";");
		}
	}
}
