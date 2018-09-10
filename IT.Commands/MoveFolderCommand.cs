//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
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
	/// Команда переноса объетов в нового родителя
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
					// задана родительская папка
					xobj.SetUpdatedPropValue("Parent", request.NewParent);
					// родительская папка задана, однако, она может принадлежать другому клиенту и/или типу проектных затрат
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
					// Далее мы проверяем следующее:
					//	каталог может быть подчинен папке любого типа, однако проект только проекту, 
					//	а пресейл и тендер вообще никому
					cmd.CommandText = @"
						SELECT f1.Type AS FolderType, f2.Type AS ParentFolderType, 
							f1.LIndex, f1.RIndex,
							f2.LIndex AS ParentLIndex, f2.RIndex AS ParentRIndex
						FROM Folder f1, Folder f2
						WHERE f1.ObjectID = @ObjectID AND f2.ObjectID = @NewParentID
						";
					// Примечание: используем созданную ранее команду с параметрами NewParentID и ObjectID
					using(IDataReader reader = cmd.ExecuteReader())
					{
						if (reader.Read())
						{
							FolderTypeEnum folderType = (FolderTypeEnum)reader.GetInt16(reader.GetOrdinal("FolderType"));
							FolderTypeEnum parentFolderType = (FolderTypeEnum)reader.GetInt16(reader.GetOrdinal("ParentFolderType"));
							// Если у папки не изменилась ссылка на организацию клиента, то проверим, что ее не переносят в одну из дочерних папок
							if (!xobj.HasUpdatedProp("Customer"))
							{
								// Примечание: LIndex/RIndex будут пересчитываться в триггере
								int nLIndex = reader.GetInt32(reader.GetOrdinal("LIndex"));
								int nRIndex = reader.GetInt32(reader.GetOrdinal("RIndex"));
								int nParentLIndex = reader.GetInt32(reader.GetOrdinal("ParentLIndex"));
								int nParentRIndex = reader.GetInt32(reader.GetOrdinal("ParentRIndex"));
								// Проверим, что новый родитель не является дочерним (рекурсивно) узлом переносимой папки
								if (nParentLIndex >= nLIndex && nParentRIndex <= nRIndex)
									throw new XBusinessLogicException(FolderTypeEnumItem.GetItem(folderType).Description + " не может быть перенесен в подчиненный " + FolderTypeEnumItem.GetItem(parentFolderType).Description.ToLower());
							}
							if (folderType == FolderTypeEnum.Project)
							{
								if (parentFolderType != FolderTypeEnum.Project)
									throw new XBusinessLogicException("Проект не может быть перенесен в " + FolderTypeEnumItem.GetItem(parentFolderType).Description.ToLower());
							}
							else if (folderType == FolderTypeEnum.Tender || folderType == FolderTypeEnum.Presale)
							{
								throw new XBusinessLogicException("Тендер (тендерная активность) и пресейл (пресейл-активноть) не могут быть перенесены в папку");	
							}
						}
					}
				}
				else
				{
					// перенос в корень
					xobj.SetUpdatedPropValue("Parent", DBNull.Value);
					// однако при этом мог измениться клиент или тип проектных затрат
					if (request.NewActivityType != Guid.Empty)
					{
						// если изменился тип проектных затрат, то ссылка на клиента также должна быть задана (даже если он не изменился)
						if (request.NewCustomer == Guid.Empty)
							throw new ArgumentException("Если задана ссылка на тип проектных затрат, то должна быть задана ссылка на организацию-клиента");

						// также нужно проверить, что выбранный типа проектных затрат поддерживает тип переносимой папки 
						cmd = context.Connection.CreateCommand(@"
							SELECT 1 FROM ActivityType 
							WHERE ObjectID = @ActivityTypeID AND FolderType & (SELECT [Type] FROM Folder WHERE ObjectID = @ObjectID) > 0
							");
						cmd.Parameters.Add("ActivityTypeID", DbType.Guid, ParameterDirection.Input, false, request.NewActivityType);
						cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid);
						if (cmd.ExecuteScalar() == null)
							throw new XBusinessLogicException("Перенос папки невозможен. Выбранный тип проектных затрат не может содержать папку переносимого типа.");

						xobj.SetUpdatedPropValue("ActivityType", request.NewActivityType);
						xobj.SetUpdatedPropValue("Customer", request.NewCustomer);
					}
					else if (request.NewCustomer != Guid.Empty)
					{
						// Если выбрали организацию без изменения типа проектных затрат, то подразумевается, что он (ActivityTyoe) остается прежним, 
						// однако такое возможно только при переносе либо между организациями-клиентами, либо между организациями-владельцами.
						cmd = context.Connection.CreateCommand(@"
							SELECT 1 FROM Organization c1, Organization c2 
							WHERE c1.ObjectID = (SELECT Customer FROM Folder WHERE ObjectID = @ObjectID)
								AND c2.ObjectID = @NewCustomerID AND c1.Home <> c2.Home
							");
						cmd.Parameters.Add("NewCustomerID", DbType.Guid, ParameterDirection.Input, false, request.NewCustomer);
						cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, oid);
						if (cmd.ExecuteScalar() != null)
							throw new XBusinessLogicException("Перенос папки невозможен. Для переноса папок между разными типами проектных затрат следует выбрать узел, соответствующий требуемому типу проектных затрат.");
						
						xobj.SetUpdatedPropValue("Customer", request.NewCustomer);
					}
					else
					{
						// Parent = Null, Customer = Null, ActivityType = Null - такого быть не может
						throw new ArgumentException("При незаданной ссылке на родительскую папку должны быть заданы ссылки на Клиента и/или Тип проектных затрат");
					}
				}

				XSecurityManager.Instance.DemandSaveObjectPrivilege(xobj);
			}
			XStorageGateway.Save(context, dataSet, Guid.NewGuid());

			// если все сохранилось хорошо, то отработали триггеры, изменяющие LIndex/RIndex, и возможно Customer.
			// Если у переносимой папки изменилась ссылка на тип проектных затрат , 
			// то необходимо изменить эту ссылку всем подчиненным папкам (если они есть)
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
			// Отрежим последнюю запятую
			cmdBuilder.Length--;
			cmdBuilder.Append(")");
			cmd.CommandText = cmdBuilder.ToString();
			cmd.ExecuteNonQuery();

            // Если у переносимой папки были заданы направления, которые не соответствуют направлениям новой
            // родительской папки, то удалим эти направления
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
                // Отрежим последнюю запятую
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
