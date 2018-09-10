//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Text;
using System.Data;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� �������� ������� � ������ ��������
	/// </summary>
	public class MoveFolderCommand : XCommand
	{
		public XResponse Execute(MoveFolderRequest request, IXExecutionContext context)
		{
			XDbCommand cmd;
			DomainObjectDataSet dataSet = new DomainObjectDataSet(context.Connection.MetadataManager.XModel);
			foreach(Guid oid in request.ObjectsID)
			{
				DomainObjectData xobj = dataSet.CreateStubLoaded("Folder", oid, -1);
				if (request.NewParent != Guid.Empty)
				{
					// ������ ������������ �����
					xobj.SetUpdatedPropValue("Parent", request.NewParent);
					// ������������ ����� ������, ������, ��� ����� ������������ ������� ������� �/��� ���� ��������� ������
					cmd = context.Connection.CreateCommand(@"
						SELECT 
							CASE WHEN f1.Customer <> f2.Customer THEN f1.Customer ELSE cast(NULL as uniqueidentifier) END AS Customer, 
							CASE WHEN f1.ActivityType <> f2.ActivityType THEN f1.ActivityType ELSE cast(NULL as uniqueidentifier) END AS ActivityType
						FROM Folder f1, Folder f2
						WHERE f1.ObjectID = @NewParentID AND f2.ObjectID = @ObjectID 
							AND (f1.Customer <> f2.Customer OR f1.ActivityType <> f2.ActivityType)
						");
					cmd.Parameters.Add("NewParentID", DbType.Guid, ParameterDirection.Input, false, request.NewParent);
					cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid);
					using(IDataReader reader = cmd.ExecuteReader())
					{
						int nIndex;
						if (reader.Read())
						{
							nIndex = reader.GetOrdinal("Customer");
							if (!reader.IsDBNull(nIndex))
								xobj.SetUpdatedPropValue("Customer", reader.GetGuid(nIndex));
							nIndex = reader.GetOrdinal("ActivityType");
							if (!reader.IsDBNull(nIndex))
								xobj.SetUpdatedPropValue("ActivityType", reader.GetGuid(nIndex));
						}
					}
					// ����� �� ��������� ���������:
					//	������� ����� ���� �������� ����� ������ ����, ������ ������ ������ �������, 
					//	� ������� � ������ ������ ������
					cmd.CommandText = @"
						SELECT f1.Type AS FolderType, f2.Type AS ParentFolderType, 
							f1.LIndex, f1.RIndex,
							f2.LIndex AS ParentLIndex, f2.RIndex AS ParentRIndex
						FROM Folder f1, Folder f2
						WHERE f1.ObjectID = @ObjectID AND f2.ObjectID = @NewParentID
						";
					// ����������: ���������� ��������� ����� ������� � ����������� NewParentID � ObjectID
					using(IDataReader reader = cmd.ExecuteReader())
					{
						if (reader.Read())
						{
							FolderTypeEnum folderType = (FolderTypeEnum)reader.GetInt16(reader.GetOrdinal("FolderType"));
							FolderTypeEnum parentFolderType = (FolderTypeEnum)reader.GetInt16(reader.GetOrdinal("ParentFolderType"));
							// ���� � ����� �� ���������� ������ �� ����������� �������, �� ��������, ��� �� �� ��������� � ���� �� �������� �����
							if (!xobj.HasUpdatedProp("Customer"))
							{
								// ����������: LIndex/RIndex ����� ��������������� � ��������
								int nLIndex = reader.GetInt32(reader.GetOrdinal("LIndex"));
								int nRIndex = reader.GetInt32(reader.GetOrdinal("RIndex"));
								int nParentLIndex = reader.GetInt32(reader.GetOrdinal("ParentLIndex"));
								int nParentRIndex = reader.GetInt32(reader.GetOrdinal("ParentRIndex"));
								// ��������, ��� ����� �������� �� �������� �������� (����������) ����� ����������� �����
								if (nParentLIndex >= nLIndex && nParentRIndex <= nRIndex)
									throw new XBusinessLogicException(FolderTypeEnumItem.GetItem(folderType).Description + " �� ����� ���� ��������� � ����������� " + FolderTypeEnumItem.GetItem(parentFolderType).Description.ToLower());
							}
							if (folderType == FolderTypeEnum.Project)
							{
								if (parentFolderType != FolderTypeEnum.Project)
									throw new XBusinessLogicException("������ �� ����� ���� ��������� � " + FolderTypeEnumItem.GetItem(parentFolderType).Description.ToLower());
							}
							else if (folderType == FolderTypeEnum.Tender || folderType == FolderTypeEnum.Presale)
							{
								throw new XBusinessLogicException("������ (��������� ����������) � ������� (�������-���������) �� ����� ���� ���������� � �����");	
							}
						}
					}
				}
				else
				{
					// ������� � ������
					xobj.SetUpdatedPropValue("Parent", DBNull.Value);
					// ������ ��� ���� ��� ���������� ������ ��� ��� ��������� ������
					if (request.NewActivityType != Guid.Empty)
					{
						// ���� ��������� ��� ��������� ������, �� ������ �� ������� ����� ������ ���� ������ (���� ���� �� �� ���������)
						if (request.NewCustomer == Guid.Empty)
							throw new ArgumentException("���� ������ ������ �� ��� ��������� ������, �� ������ ���� ������ ������ �� �����������-�������");

						// ����� ����� ���������, ��� ��������� ���� ��������� ������ ������������ ��� ����������� ����� 
						cmd = context.Connection.CreateCommand(@"
							SELECT 1 FROM ActivityType 
							WHERE ObjectID = @ActivityTypeID AND FolderType & (SELECT [Type] FROM Folder WHERE ObjectID = @ObjectID) > 0
							");
						cmd.Parameters.Add("ActivityTypeID", DbType.Guid, ParameterDirection.Input, false, request.NewActivityType);
						cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid);
						if (cmd.ExecuteScalar() == null)
							throw new XBusinessLogicException("������� ����� ����������. ��������� ��� ��������� ������ �� ����� ��������� ����� ������������ ����.");

						xobj.SetUpdatedPropValue("ActivityType", request.NewActivityType);
						xobj.SetUpdatedPropValue("Customer", request.NewCustomer);
					}
					else if (request.NewCustomer != Guid.Empty)
					{
						// ���� ������� ����������� ��� ��������� ���� ��������� ������, �� ���������������, ��� �� (ActivityTyoe) �������� �������, 
						// ������ ����� �������� ������ ��� �������� ���� ����� �������������-���������, ���� ����� �������������-�����������.
						cmd = context.Connection.CreateCommand(@"
							SELECT 1 FROM Organization c1, Organization c2 
							WHERE c1.ObjectID = (SELECT Customer FROM Folder WHERE ObjectID = @ObjectID)
								AND c2.ObjectID = @NewCustomerID AND c1.Home <> c2.Home
							");
						cmd.Parameters.Add("NewCustomerID", DbType.Guid, ParameterDirection.Input, false, request.NewCustomer);
						cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid);
						if (cmd.ExecuteScalar() != null)
							throw new XBusinessLogicException("������� ����� ����������. ��� �������� ����� ����� ������� ������ ��������� ������ ������� ������� ����, ��������������� ���������� ���� ��������� ������.");
						
						xobj.SetUpdatedPropValue("Customer", request.NewCustomer);
					}
					else
					{
						// Parent = Null, Customer = Null, ActivityType = Null - ������ ���� �� �����
						throw new ArgumentException("��� ���������� ������ �� ������������ ����� ������ ���� ������ ������ �� ������� �/��� ��� ��������� ������");
					}
				}

				XSecurityManager.Instance.DemandSaveObjectPrivilege(xobj);
			}
			XStorageGateway.Save(context, dataSet, Guid.NewGuid());

			// ���� ��� ����������� ������, �� ���������� ��������, ���������� LIndex/RIndex, � �������� Customer.
			// ���� � ����������� ����� ���������� ������ �� ��� ��������� ������ , 
			// �� ���������� �������� ��� ������ ���� ����������� ������ (���� ��� ����)
			StringBuilder cmdBuilder = new StringBuilder();
			cmdBuilder.AppendFormat(
@"UPDATE f
SET f.ActivityType = p.ActivityType
FROM Folder f
	JOIN Folder p ON f.LIndex > p.LIndex AND f.RIndex < p.RIndex AND f.Customer = p.Customer
WHERE p.ObjectID IN ("
				);
			cmd = context.Connection.CreateCommand();
			string sParamName;
			int nParamIndex = 0;
			foreach(Guid oid in request.ObjectsID)
			{
				++nParamIndex;
				sParamName = "ObjectID" + nParamIndex; 
				cmd.Parameters.Add(sParamName, XPropType.vt_uuid, ParameterDirection.Input, false, oid);
				cmdBuilder.Append( context.Connection.GetParameterName(sParamName) );
				cmdBuilder.Append(",");
			}
			// ������� ��������� �������
			cmdBuilder.Length--;
			cmdBuilder.Append(")");
			cmd.CommandText = cmdBuilder.ToString();
			cmd.ExecuteNonQuery();

            // ���� � ����������� ����� ���� ������ �����������, ������� �� ������������� ������������ �����
            // ������������ �����, �� ������ ��� �����������
            if (request.NewParent != Guid.Empty)
            {
                cmdBuilder = new StringBuilder();
                        
                  
                cmd = context.Connection.CreateCommand();
                nParamIndex = 0;
                foreach (Guid oid in request.ObjectsID)
                {
                    ++nParamIndex;
                    sParamName = "FolderID" + nParamIndex;
                    cmd.Parameters.Add(sParamName, XPropType.vt_uuid, ParameterDirection.Input, false, oid);
                    cmdBuilder.Append(context.Connection.GetParameterName(sParamName));
                    cmdBuilder.Append(",");
                }
                // ������� ��������� �������
                cmdBuilder.Length--;
                cmd.CommandText = @"IF (EXISTS(
	                    SELECT top 1 fd.Direction
	                    FROM dbo.FolderDirection fd
	                    WHERE (fd.Direction not in 
	                    	(
		                    SELECT Direction
		                    FROM dbo.FolderDirection
		                    WHERE  Folder = @ParentID) 
	                        AND fd.Folder IN (" + cmdBuilder.ToString() + @"))  OR
                        EXISTS(
                            SELECT COUNT(*) 
                            FROM dbo.FolderDirection
                            WHERE Folder IN (" + cmdBuilder.ToString() + @")
                            HAVING COUNT(*)>1))) AND EXISTS( SELECT TOP 1 * FROM dbo.Folder WHERE ObjectID = @ParentID )
                                               
                        BEGIN
	                        DELETE fd
	                        FROM
	                        FolderDirection fd
	                        WHERE fd.Folder IN (" + cmdBuilder.ToString() + 
                        @")
                        END" 
                ;
                cmd.Parameters.Add("ParentID", DbType.Guid, ParameterDirection.Input, false, request.NewParent);
                cmd.ExecuteNonQuery();
            }

			return new XResponse();
		}
	}
}
