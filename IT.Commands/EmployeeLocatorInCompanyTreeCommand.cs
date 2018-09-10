using System;
using System.Data;
using System.Text;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Commands
{

	/// <summary>
	/// ������� ������ ���������� � ��������� ��� ���� ���� � ������ "��������� ��������"
	/// </summary>
	public class EmployeeLocatorInCompanyTreeCommand: XCommand
	{
		/// <summary>
		/// ����� ������ ������� �����
		/// </summary>
		public TreeLocatorResponse Execute(EmployeeLocatorInCompanyTreeRequest request, IXExecutionContext context)
		{
			string sTreePath = "";		// ���� � ������ �� ���������� �������
			Guid foundOID = Guid.Empty;	// ������������� ���������� �������
			bool bMore = false;			// ������� ����, ��� ���� ��� ������� ��������������� ��������� �������
			XStorageConnection con = context.Connection;

			string sQuery = 
@"SELECT emp.ObjectID, d.ObjectID as DepID, d.LIndex, d.RIndex, emp.Organization
FROM Employee emp 
	LEFT JOIN Department d ON emp.Department = d.ObjectID
WHERE emp.LastName LIKE " + con.GetParameterName("LastName");

			// ���� ����� ������ ������������ ��������, ������� �����������
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
			// �� ��������� ������� (�, �������������, ���� �����) ���������� ����������� � ����������� ��� ��������� ������������������.
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
						// ���� ��������� ������ � �������������, �� ���������� ���� �� ���� �������������� � ���������
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
					// �� �������� ������ �����������
					sTreePath = sTreePath + "|Organization|" + OrgOID.ToString();
				}
			}			
			return new TreeLocatorResponse(sTreePath, foundOID, bMore);
		}
	}
}
