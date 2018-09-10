using System;
using System.Data;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Интерфейс проверки существования объекта в БД
	/// </summary>
	public interface IDbChecker
	{
		bool IsDbObjectExists(DbObject dbobj);
	}
	
	/// <summary>
	/// Класс проверки существования объекта в БД
	/// </summary>
	public class DbChecker : IDbChecker, IDisposable
	{
		private IDbConnection m_oConnection;

		private IDbCommand m_oCommand;

		/// <summary>
		/// Соединение с БД
		/// </summary>
		public IDbConnection Connection
		{
			get { return this.m_oConnection; }
		}

		/// <summary>
		/// SQL-команда для проверки существования объекта
		/// </summary>
		protected IDbCommand Command
		{
			get { return this.m_oCommand; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="connection"></param>
		/// <param name="commandText"></param>
		public DbChecker(IDbConnection connection, string commandText)
		{
			this.m_oConnection = connection;

			this.m_oCommand = this.m_oConnection.CreateCommand();
			this.m_oCommand.CommandText = commandText;
			
			Init();
			
			this.m_oCommand.Prepare();
		}

		/// <summary>
		/// Дополнительная инициализация
		/// </summary>
		protected virtual void Init()
		{
		}
		
		/// <summary>
		/// Проверяет, существует ли объект в БД
		/// </summary>
		/// <param name="dbobj"></param>
		/// <returns></returns>
		public bool IsDbObjectExists(DbObject dbobj)
		{
			Substitute(dbobj);

			object exists = this.m_oCommand.ExecuteScalar();
			
			return (exists != null);
		}

		/// <summary>
		/// Подставляет в команду параметры, соответствующие описанию объекта
		/// </summary>
		/// <param name="dbobj"></param>
		protected virtual void Substitute(DbObject dbobj)
		{
		}

		#region IDisposable Members

		public void Dispose()
		{
			this.m_oCommand.Dispose();
		}

		#endregion
	}
}
