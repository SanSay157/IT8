using System.Data;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Класс проверки существования объекта в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSql : DbChecker
	{
		public DbCheckerMsSql(IDbConnection connection, string commandText)
			: base(connection, commandText)
		{
		}

		protected override void Init()
		{
			base.Init();

			IDbDataParameter paramName = Command.CreateParameter();
			paramName.ParameterName = "@Name";
			paramName.DbType = DbType.String;
			paramName.Size = 128;
			Command.Parameters.Add(paramName);
		}

		protected override void Substitute(DbObject dbobj)
		{
			base.Substitute(dbobj);

			IDbDataParameter paramName = (IDbDataParameter) Command.Parameters["@Name"];
			paramName.Value = dbobj.Name;
		}
	}

	/// <summary>
	/// Класс проверки существования объекта в БД с указанием владельца
	/// (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlOwned : DbCheckerMsSql
	{
		public DbCheckerMsSqlOwned(IDbConnection connection, string commandText)
			: base(connection, commandText)
		{
		}

		protected override void Init()
		{
			base.Init();

			IDbDataParameter paramOwner = Command.CreateParameter();
			paramOwner.ParameterName = "@Owner";
			paramOwner.DbType = DbType.String;
			paramOwner.Size = 128;
			Command.Parameters.Add(paramOwner);
		}

		protected override void Substitute(DbObject dbobj)
		{
			base.Substitute(dbobj);

			DbObjectOwned dbobjTyped = (DbObjectOwned) dbobj;

			IDbDataParameter paramOwner = (IDbDataParameter) Command.Parameters["@Owner"];
			paramOwner.Value = dbobjTyped.Owner;
		}
	}

	/// <summary>
	/// Класс проверки существования объекта, дочернего по отношению к таблице
	/// (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlTableChild : DbCheckerMsSql
	{
		public DbCheckerMsSqlTableChild(IDbConnection connection, string commandText)
			: base(connection, commandText)
	{
	}

		protected override void Init()
		{
			base.Init();

			IDbDataParameter paramName = Command.CreateParameter();
			paramName.ParameterName = "@ParentName";
			paramName.DbType = DbType.String;
			paramName.Size = 128;
			Command.Parameters.Add(paramName);

			IDbDataParameter paramOwner = Command.CreateParameter();
			paramOwner.ParameterName = "@ParentOwner";
			paramOwner.DbType = DbType.String;
			paramOwner.Size = 128;
			Command.Parameters.Add(paramOwner);
		}

		protected override void Substitute(DbObject dbobj)
		{
			base.Substitute(dbobj);

			DbObjectTableChild dbobjTyped = (DbObjectTableChild) dbobj;

			IDbDataParameter paramName = (IDbDataParameter) Command.Parameters["@ParentName"];
			paramName.Value = dbobjTyped.ParentTable.Name;

			IDbDataParameter paramOwner = (IDbDataParameter) Command.Parameters["@ParentOwner"];
			paramOwner.Value = dbobjTyped.ParentTable.Owner;
		}
	}

	/// <summary>
	/// Класс проверки существования таблицы в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlTable : DbCheckerMsSqlOwned
	{
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysobjects where id = object_id(N'[' + @Owner + '].[' + @Name + ']') and OBJECTPROPERTY(id, N'IsTable') = 1";

		public DbCheckerMsSqlTable(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования таблицы в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlView : DbCheckerMsSqlOwned
	{
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysobjects where id = object_id(N'[' + @Owner + '].[' + @Name + ']') and OBJECTPROPERTY(id, N'IsView') = 1";

		public DbCheckerMsSqlView(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования хранимой процедуры в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlProcedure : DbCheckerMsSqlOwned
	{
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysobjects where id = object_id(N'[' + @Owner + '].[' + @Name + ']') and OBJECTPROPERTY(id, N'IsProcedure') = 1";

		public DbCheckerMsSqlProcedure(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования функции (UDF) в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlFunction : DbCheckerMsSqlOwned
	{
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysobjects where id = object_id(N'[' + @Owner + '].[' + @Name + ']') and xtype in (N'FN', N'IF', N'TF')";

		public DbCheckerMsSqlFunction(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования триггера в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlTrigger : DbCheckerMsSqlOwned
	{
		// проверяем что триггер не только существует, но и включен
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysobjects where id = object_id(N'[' + @Owner + '].[' + @Name + ']') and OBJECTPROPERTY(id, N'IsTrigger') = 1 and OBJECTPROPERTY(id, N'ExecIsTriggerDisabled') = 0";

		public DbCheckerMsSqlTrigger(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования индекса в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlIndex : DbCheckerMsSqlTableChild
	{
		private const string COMMAND_TEXT = 
			@"select top 1 1 from dbo.sysindexes where id = object_id(N'[' + @ParentOwner + '].[' + @ParentName + ']') and name = @Name";

		public DbCheckerMsSqlIndex(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}

	/// <summary>
	/// Класс проверки существования check constraint в БД (реализация для MS SQL)
	/// </summary>
	public class DbCheckerMsSqlCheckConstraint : DbCheckerMsSqlTableChild
	{
		private const string COMMAND_TEXT = 
			@"select top 1 *
				from dbo.sysobjects as so
				inner join dbo.sysobjects as pso on pso.id = so.parent_obj
				where so.id = object_id(N'[' + @ParentOwner + '].[' + @Name + ']') and OBJECTPROPERTY(so.id, N'IsCheckCnst') = 1 and OBJECTPROPERTY(so.id, N'CnstIsDisabled') = 0
					and pso.id = object_id(N'[' + @ParentOwner + '].[' + @ParentName + ']') and OBJECTPROPERTY(pso.id, N'IsTable') = 1";

		public DbCheckerMsSqlCheckConstraint(IDbConnection connection)
			: base(connection, COMMAND_TEXT)
		{
		}
	}
}
