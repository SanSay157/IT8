using System;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Объект в БД
	/// </summary>
	public abstract class DbObject
	{
		private string m_sName;

		private string m_sDescription;
		
		/// <summary>
		/// Название объекта
		/// </summary>
		public string Name
		{
			get { return this.m_sName; }
		}
		
		/// <summary>
		/// Описание объекта
		/// </summary>
		public string Description
		{
			get { return this.m_sDescription; }
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public abstract string Type
		{
			get;
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObject(string name, string description)
		{
			this.m_sName = name;
			this.m_sDescription = description;
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public virtual string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует объект [{0}] ({1}).",
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует объект [{0}].",
					Name);
			}
		}
	}

	/// <summary>
	/// Объект в БД с указанием владельца
	/// </summary>
	public abstract class DbObjectOwned : DbObject
	{
		private string m_sOwner;

		/// <summary>
		/// Владелец объекта
		/// </summary>
		public string Owner
		{
			get { return this.m_sOwner; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectOwned(string name, string description, string owner)
			: base(name, description)
		{
			this.m_sOwner = owner;
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует объект [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует объект [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Объект в БД, дочерний по отношению к таблице
	/// </summary>
	public abstract class DbObjectTableChild : DbObject
	{
		private DbObjectTable m_oParentTable;

		/// <summary>
		/// Родительская таблица
		/// </summary>
		public DbObjectTable ParentTable
		{
			get { return this.m_oParentTable; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectTableChild(string name, string description, DbObjectTable parentTable)
			: base(name, description)
		{
			this.m_oParentTable = parentTable;
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД для таблицы [{0}].[{1}] отсутствует дочерний объект [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"В БД для таблицы [{0}].[{1}] отсутствует дочерний объект [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}

	/// <summary>
	/// Таблица в БД
	/// </summary>
	public class DbObjectTable : DbObjectOwned
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectTable(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "table"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует таблица [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует таблица [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Представление в БД
	/// </summary>
	public class DbObjectView : DbObjectOwned
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectView(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "view"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует представление [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует представление [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Хранимая процедура в БД
	/// </summary>
	public class DbObjectProcedure : DbObjectOwned
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectProcedure(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "procedure"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует хранимая процедура [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует хранимая процедура [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Функция в БД
	/// </summary>
	public class DbObjectFunction : DbObjectOwned
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectFunction(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "function"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует функция [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует функция [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Триггер в БД
	/// </summary>
	public class DbObjectTrigger : DbObjectOwned
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectTrigger(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "trigger"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД отсутствует или выключен триггер [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"В БД отсутствует или выключен триггер [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// Индекс в БД
	/// </summary>
	public class DbObjectIndex : DbObjectTableChild
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectIndex(string name, string description, DbObjectTable parentTable)
			: base(name, description, parentTable)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "index"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД на таблице [{0}].[{1}] отсутствует индекс [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"В БД на таблице [{0}].[{1}] отсутствует индекс [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}

	/// <summary>
	/// CHECK CONSTRAINT
	/// </summary>
	public class DbObjectCheckConstraint : DbObjectTableChild
	{
		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectCheckConstraint(string name, string description, DbObjectTable parentTable)
			: base(name, description, parentTable)
		{
		}

		/// <summary>
		/// Тип объекта в БД
		/// </summary>
		public override string Type
		{
			get { return "check-constraint"; }
		}

		/// <summary>
		/// Возвращает сообщение об ошибке
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"В БД для таблицы [{0}].[{1}] отсутствует или выключен CHECK CONSTRAINT [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"В БД для таблицы [{0}].[{1}] отсутствует или выключен CHECK CONSTRAINT [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}
}
