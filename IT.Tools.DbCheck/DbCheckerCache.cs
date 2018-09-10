using System;
using System.Collections;
using System.Data;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Кэш экземпляров IDbChecker.
	/// </summary>
	public class DbCheckerCache : IDisposable
	{
		private IDbConnection m_oConnection;

		private DbCheckConfig m_oConfig;

		private Hashtable m_oHashtable;

		/// <summary>
		/// Конструктор
		/// </summary>
		public DbCheckerCache(IDbConnection connection, DbCheckConfig config)
		{
			this.m_oConnection = connection;
			this.m_oConfig = config;
			this.m_oHashtable = new Hashtable();
		}

		/// <summary>
		/// Возвращает экземпляр IDbChecker по описанию объекта в БД.
		/// Если соответствующий экземпляр IDbCheck еще не создавался,
		///  то он создается.
		/// </summary>
		public IDbChecker this[DbObject dbobj]
		{
			get
			{
				Type key = dbobj.GetType();
				IDbChecker dbchecker = this.m_oHashtable[key] as IDbChecker;
				if (dbchecker == null)
				{
					dbchecker = createDbChecker(dbobj);
					this.m_oHashtable[key] = dbchecker;
				}
				return dbchecker;
			}
		}

		/// <summary>
		/// Создает класс проверки наличия объектов в БД
		/// </summary>
		/// <param name="dbobj"></param>
		/// <returns></returns>
		private IDbChecker createDbChecker(DbObject dbobj)
		{
			// ищем подходящее описание в конфиге
			foreach (DbCheckerDescription descr in this.m_oConfig.DbCheckerDescriptions)
			{
				if (descr.DbObjectType == dbobj.Type)
				{
					return descr.CreateDbChecker(this.m_oConnection);
				}
			}

			// если дошли до сюда, значит не нашли ничего подходящего
			throw new ArgumentException(
				"Данный тип объектов БД не поддерживается",
				"dbobj" );
		}

		#region IDisposable Members

		public void Dispose()
		{
			foreach (IDbChecker dbchecker in this.m_oHashtable.Values)
			{
				IDisposable disp = dbchecker as IDisposable;
				if (disp != null)
				{
					disp.Dispose();
				}
			}
		}

		#endregion
	}
}
