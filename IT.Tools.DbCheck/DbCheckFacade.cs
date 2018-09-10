using System.Collections.Specialized;
using System.Data;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// "Фасад" для вызова проверки корректности БД
	/// </summary>
	public class DbCheckFacade
	{
		private DbCheckFacade()
		{
		}

		/// <summary>
		/// Выполняет проверку наличия объектов в БД
		/// </summary>
		/// <param name="connection">Соединение с БД</param>
		/// <param name="configFileName">Полное имя файла конфигурации</param>
		/// <returns>Результаты проверки</returns>
		public static DbCheckResult Check(IDbConnection connection, string configFileName)
		{
			DbCheckConfig config = new DbCheckConfig(configFileName);

			DbObject[] dbobjects = config.DbObjects;

			DbCheckResult result = new DbCheckResult(
				true, new StringCollection() );

			using (DbCheckerCache cache = new DbCheckerCache(connection, config))
			{
				foreach (DbObject dbobj in dbobjects)
				{
					IDbChecker dbchecker = cache[dbobj];
				
					if (!dbchecker.IsDbObjectExists(dbobj))
					{
						result.Success = false;
						result.Errors.Add(dbobj.GetErrorMessage());
					}
				}
			}

			return result;
		}
	}
}
