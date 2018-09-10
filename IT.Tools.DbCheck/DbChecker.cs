using System;
using System.Data;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// ��������� �������� ������������� ������� � ��
	/// </summary>
	public interface IDbChecker
	{
		bool IsDbObjectExists(DbObject dbobj);
	}
	
	/// <summary>
	/// ����� �������� ������������� ������� � ��
	/// </summary>
	public class DbChecker : IDbChecker, IDisposable
	{
		private IDbConnection m_oConnection;

		private IDbCommand m_oCommand;

		/// <summary>
		/// ���������� � ��
		/// </summary>
		public IDbConnection Connection
		{
			get { return this.m_oConnection; }
		}

		/// <summary>
		/// SQL-������� ��� �������� ������������� �������
		/// </summary>
		protected IDbCommand Command
		{
			get { return this.m_oCommand; }
		}

		/// <summary>
		/// �����������
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
		/// �������������� �������������
		/// </summary>
		protected virtual void Init()
		{
		}
		
		/// <summary>
		/// ���������, ���������� �� ������ � ��
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
		/// ����������� � ������� ���������, ��������������� �������� �������
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
