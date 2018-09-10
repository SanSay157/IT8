//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Вспомогательный класс для управления привилегиями
	/// </summary>
	internal sealed class PrivilegesHelper
	{
		public static XPrivilege[] GetPrivileges(SystemPrivileges nPrivilegesMask)
		{
			SystemPrivilegesItem[] items = SystemPrivilegesItem.GetItems(nPrivilegesMask);
			ITSystemPrivilege[] privileges = new ITSystemPrivilege[items.Length];
			for(int i=0;i<items.Length;++i)
				privileges[i] = new ITSystemPrivilege(items[i]);
			return privileges;
		}
		public static XPrivilegeSet CreatePrivilegeSet(SystemPrivileges nPrivilegeMask)
		{
			SystemPrivilegesItem[] items = SystemPrivilegesItem.GetItems(nPrivilegeMask);
			return CreatePrivilegeSet(items);
		}
		public static XPrivilegeSet CreatePrivilegeSet(SystemPrivilegesItem[] values)
		{
			XPrivilegeSet set = new XPrivilegeSet();
			for(int i=0;i<values.Length;++i)
				set.Add( new ITSystemPrivilege(values[i]) );
			return set;
		}

		public static XPrivilegeSet CreatePrivilegeSet(FolderPrivileges nPrivilegeMask)
		{
			FolderPrivilegesItem[] items = FolderPrivilegesItem.GetItems(nPrivilegeMask);
			return CreatePrivilegeSet(items);
		}
		public static XPrivilegeSet CreatePrivilegeSet(FolderPrivilegesItem[] values)
		{
			XPrivilegeSet set = new XPrivilegeSet();
			for(int i=0;i<values.Length;++i)
				set.Add( new ITFolderPrivilege(values[i]) );
			return set;
		}
	}
}

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Описатель привилегии пользователя на папку
	/// </summary>
	public class ITFolderPrivilege: XPrivilege
	{
		private FolderPrivileges m_value;

		public ITFolderPrivilege(FolderPrivilegesItem value)
			: base(value.Name, value.Description)
		{
			m_value = value.Value;
		}
		public FolderPrivileges Value
		{
			get { return m_value; }
		}
	}
}

namespace Croc.IncidentTracker.Core
{
	/// <summary>
	/// Описатель системной привилегии пользователя
	/// </summary>
	public class ITSystemPrivilege: XPrivilege
	{
		private SystemPrivileges m_value;

		public ITSystemPrivilege(SystemPrivilegesItem value)
			: base(value.Name, value.Description)
		{
			m_value = value.Value;
		}
		public SystemPrivileges Value
		{
			get { return m_value; }
		}
	}
}