using System;
using System.Data;
using System.Text;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Commands
{

	/// <summary>
	/// Команда поиска сотрудника и получения для него пути в дереве "Структура компаний"
	/// </summary>
	public class EmployeeLocatorInCompanyTreeCommand: XCommand
	{
		/// <summary>
		/// Метод вызова команды ядром
		/// </summary>
		public TreeLocatorResponse Execute(EmployeeLocatorInCompanyTreeRequest request, IXExecutionContext context)
		{
			string sTreePath = "";		// путь в дереве до найденного объекта
			Guid foundOID = Guid.Empty;	// идентификатор найденного объекта
			bool bMore = false;			// признак того, что есть еще объекты удовлетворяющие заданному условию
			XStorageConnection con = context.Connection;

			string sQuery = 
@"SELECT emp.ObjectID, d.ObjectID as DepID, d.LIndex, d.RIndex, emp.Organization
FROM Employee emp 
	LEFT JOIN Department d ON emp.Department = d.ObjectID
WHERE emp.LastName LIKE " + con.GetParameterName("LastName");

			// если задан список игнорируемых объектов, добавим ограничение
			if (request.IgnoredObjects != null && request.IgnoredObjects.Length > 0)
			{
				StringBuilder bld = new StringBuilder();
				bld.Append("\n\tAND NOT emp.ObjectID IN (");
				foreach(Guid oid in request.IgnoredObjects)
				{
					bld.Append(con.ArrangeSqlGuid(oid));
					bld.Append(", ");
				}
				bld.Length -= 2;
				bld.Append(")");
				sQuery = sQuery + bld.ToString();
			}
			// по умолчанию выводим (и, следовательно, ищем среди) неархивных сотрудников и сотрудников без временной нетрудоспособности.
			if (!request.AllowArchive)
                sQuery = sQuery + " AND (emp.WorkEndDate IS NULL) AND (emp.TemporaryDisability  = 0)";

            sQuery = sQuery + "\nORDER BY emp.Organization, emp.Department, emp.FirstName";

			XDbCommand cmd = con.CreateCommand(sQuery);
			cmd.Parameters.Add("LastName", DbType.String, ParameterDirection.Input, false, request.LastName + "%");
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					foundOID = reader.GetGuid( reader.GetOrdinal("ObjectID"));
					Guid OrgOID = reader.GetGuid( reader.GetOrdinal("Organization"));
					Guid DepID;
					int nLIndex = -1;
					int nRIndex = -1;
					sTreePath = "Employee|" + foundOID.ToString();
					
					if (!reader.IsDBNull(reader.GetOrdinal("DepID")))
					{
						// если сотрудник входит в подразделение, то сформируем путь по всем подразделениям к корневому
						int nLIndexOrdinal = reader.GetOrdinal("LIndex");
						int nRIndexOrdinal = reader.GetOrdinal("RIndex");
						if (!reader.IsDBNull(nLIndexOrdinal) && !reader.IsDBNull(nRIndexOrdinal))
						{
							nLIndex = reader.GetInt32( nLIndexOrdinal );
							nRIndex = reader.GetInt32( nRIndexOrdinal );
						}
						DepID  = reader.GetGuid( reader.GetOrdinal("DepID"));
						bMore = reader.Read();
						reader.Close();
						if (nLIndex > -1 && nRIndex > -1)
						{
							sQuery = 
								@"SELECT ObjectID FROM Department 
WHERE LIndex < @LIndex AND RIndex > @RIndex AND Organization = @OrgID
ORDER BY [LRLevel] DESC";
							cmd = context.Connection.CreateCommand(sQuery);
							cmd.Parameters.Add("LIndex", DbType.Int32, ParameterDirection.Input,  false, nLIndex);
							cmd.Parameters.Add("RIndex", DbType.Int32, ParameterDirection.Input,  false, nRIndex);
							cmd.Parameters.Add("OrgID", DbType.Guid, ParameterDirection.Input,  false, OrgOID);
							sTreePath = sTreePath + "|Department|" + DepID.ToString();
							using(IDataReader reader2 = cmd.ExecuteReader())
							{
								while(reader2.Read())
								{
									sTreePath = sTreePath + "|Department|" + reader2.GetGuid(0);
								}
							}
						}
					}
					else
						bMore = reader.Read();
					// на корневом уровне организации
					sTreePath = sTreePath + "|Organization|" + OrgOID.ToString();
				}
			}			
			return new TreeLocatorResponse(sTreePath, foundOID, bMore);
		}
	}
}
