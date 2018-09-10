//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Core;

namespace Croc.IncidentTracker.Core
{
	// Authorization Evaluation Layer

	class CommonRightsRules
	{
		/// <summary>
		/// Проверяет не попадает ли заданная дата в период блокирования списаний (как глобальный, так и для папки)
		/// </summary>
		/// <param name="dtTimeSpentDate">Значение даты списания</param>
		/// <param name="xobjFolder">объект Папки, может быть не задан (null)</param>
		/// <returns>true - попадает, false - не попадает</returns>
		public static bool IsRegDateInBlockPeriod(DateTime dtTimeSpentDate, DomainObjectData xobjFolder)
		{
			// RULE: Создавать, редактировать и удалять списание запрещено, если его дата попадает в глобальный закрытый период
			// получим дату регистрации списания
			// Если дата списания меньше даты глобального периода блокирования списаний
			if (dtTimeSpentDate <= ApplicationSettings.GlobalBlockPeriodDate)
				return true;
			return false;
		}
        /// <summary>
        /// Функция проверяющая, влияет ли перенос инцидента, на распределения затрат проекта
        /// </summary>
        /// <param name="xobjFolderNew">Папка, в которую переносится инцидент</param>
        /// <param name="xobjFolderOld">Папка, из которой переносится инцидент</param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool CheckIncidentForBlockedPeriod(DomainObjectData xobjFolderNew, DomainObjectData xobjFolderOld, XStorageConnection con)
        {
            // Если инц-т переносится в другу активность, то это влияет на распределения затрат проекта
            if (!IsSameActivity(xobjFolderNew.ObjectID, xobjFolderOld.ObjectID, con))
                return true;
            int nDirectionCount = 0;
            nDirectionCount = DirectionsCount(con, (Guid)xobjFolderNew.ObjectID);
            // Если направление у проекта одно или не задано, то перенос инцидента не влияет на распределение затрат
            if (nDirectionCount == 1 || nDirectionCount == 0)
            {
                return false;
            }
            object vValue = null;
            XDbCommand cmd;
            // Проверка на несоответствие направлений в папках
            if ((xobjFolderOld.GetLoadedPropValue("Parent") is Guid) &&
                   (xobjFolderNew.GetLoadedPropValue("Parent") is Guid))
            {
                cmd = con.CreateCommand(@"SELECT TOP 1 1 
                                        FROM 
                                          (SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirOld
                                          INNER 
                                          JOIN 
                                          (
                                          SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirNew ON  dirOld.Direction = dirNew.Direction
                                                ");
                cmd.Parameters.Add("FolderOld", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
                cmd.Parameters.Add("FolderNew", DbType.Guid, ParameterDirection.Input, false, xobjFolderOld.ObjectID);
                vValue = cmd.ExecuteScalar();
                // Если направления в папках не совпадают, то перенос инц-та влияет на распределение затрат
                if (vValue == null)
                    return true;


            }
            vValue = null;
            cmd = con.CreateCommand(@"SELECT TOP 1 1
                                        FROM Folder f (NOLOCK)
                                          JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 
                                          JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
                                        WHERE f.ObjectID = @FolderID AND (f_s.Parent IS NOT NULL)");

            // RULE:  Если перенос идет из папки в корень активности или наоборот, 
            // то у папки не должно быть задано на правлений
            if ((xobjFolderOld.GetLoadedPropValue("Parent") is Guid) &&
                    !(xobjFolderNew.GetLoadedPropValue("Parent") is Guid))
            {
                cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, xobjFolderOld.ObjectID);
            }
            else if ((xobjFolderNew.GetLoadedPropValue("Parent") is Guid) &&
                            !(xobjFolderOld.GetLoadedPropValue("Parent") is Guid))
            {
                cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
            }
            else
                return false;
            vValue = cmd.ExecuteScalar();
            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                return true;
            return false;

        }
        /// <summary>
        /// Функция проверяющая, влияет ли перенос папки, на распределения затрат проекта
        /// </summary>
        /// <param name="xobj"></param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool CheckFolderForBlockedPeriod(DomainObjectData xobjFolderNew, DomainObjectData xobjFolder, XStorageConnection con)
        {
            // Если проект переносится в корень, то это влияет на распределения затрат проекта
            if (xobjFolderNew == null)
                return true;
            // Если папка переносится в другу активность, то это влияет на распределения затрат проекта
            if (!IsSameActivity(xobjFolderNew.ObjectID, xobjFolder.ObjectID, con))
                return true;
            int nDirectionCount =0;
            nDirectionCount = DirectionsCount(con, (Guid)xobjFolderNew.ObjectID);
            // Если направление у проекта одно или не задано, то перенос инцидента не влияет на распределение затрат
            if (nDirectionCount == 1 || nDirectionCount == 0)
            {
                return false;
            }
            object vValue = null;
            XDbCommand cmd;
            // Проверка на несоответствие направлений в папках
            cmd = con.CreateCommand(@"SELECT TOP 1 1 
                                        FROM 
                                          (SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL)
		                                        UNION 
		                                        SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex < f_s.LIndex AND f.RIndex > f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderOld ) AS dirOld
                                          INNER 
                                          JOIN 
                                          (
                                          SELECT DISTINCT f.ObjectID,Direction
		                                        FROM Folder f (NOLOCK)
			                                        JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                        JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                        WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                        ) AS dirNew ON  dirOld.Direction = dirNew.Direction
                                         UNION  -- Добавим случай, когда направлений нет у обеих папок
                                         SELECT TOP 1 1
                                         WHERE NOT EXISTS (SELECT DISTINCT f.ObjectID,Direction
		                                                   FROM Folder f (NOLOCK)
			                                                    JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                                    JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                                   WHERE f.ObjectID = @FolderNew AND (f_s.Parent IS NOT NULL)
		                                                   UNION
		                                                   SELECT DISTINCT f.ObjectID,Direction
		                                                   FROM Folder f (NOLOCK)
			                                                    JOIN Folder f_s (NOLOCK) ON f.LIndex >= f_s.LIndex AND f.RIndex <= f_s.RIndex AND f.Customer = f_s.Customer --AND f.Type != 16
			                                                    JOIN [dbo].[FolderDirection] dir (NOLOCK) ON f_s.ObjectID = dir.Folder
		                                                   WHERE f.ObjectID = @FolderOld AND (f_s.Parent IS NOT NULL) 
		                                                                                    )       
                                            
                                        ");
            cmd.Parameters.Add("FolderOld", DbType.Guid, ParameterDirection.Input, false, xobjFolder.ObjectID);
            cmd.Parameters.Add("FolderNew", DbType.Guid, ParameterDirection.Input, false, xobjFolderNew.ObjectID);
            vValue = cmd.ExecuteScalar();
                // Если направления в папках не совпадают, то перенос инц-та влияет на распределение затрат
            if (vValue == null)
                return true;
            return false;
        }

        /// <summary>
        /// Функция возвращает количество направлений для проекта, в котором содержится каталог с заданным идентификатором
        /// </summary>
        /// <param name="con">XStorageConnection</param>
        /// <param name="FolderID">Guid Идентификатор каталога</param>
        /// <returns>Количество направлений проекта</returns>
        private static int DirectionsCount(XStorageConnection con, Guid FolderID)
        {
            object vValue;
            XDbCommand cmd = con.CreateCommand(@"SELECT COUNT(*)
                                                FROM [dbo].[FolderDirection] (NOLOCK)
                                                WHERE Folder =
		                                                (SELECT TOP 1 f.ObjectID
		                                                FROM Folder f (NOLOCK)
			                                                JOIN Folder f_s (NOLOCK) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
		                                                WHERE f_s.ObjectID = @FolderID
		                                                ORDER BY f.LRLevel)");
            cmd.Parameters.Add("FolderID", DbType.Guid, ParameterDirection.Input, false, FolderID);
            vValue = cmd.ExecuteScalar();
            return Convert.ToInt32(vValue);
        }

        /// <summary>
        /// Функция проверяющая, находятся ли папки в одной активности 
        /// </summary>
        /// <param name="uidFolderNew">Идентификатор первой папки</param>
        /// <param name="uidFolderOld">Идентификатор второй папки</param>
        /// <param name="con"></param>
        /// <returns></returns>
        public static bool IsSameActivity(Guid uidFolderNew, Guid uidFolderOld, XStorageConnection con)
        {
            object vValue = null;
            XDbCommand cmd = con.CreateCommand(@"
								SELECT 1 WHERE
								(
									SELECT TOP 1 f.ObjectID
									FROM Folder f 
										JOIN Folder f_s ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
									WHERE f_s.ObjectID = @OldParent
									ORDER BY f.LRLevel DESC
								) =
								(
									SELECT TOP 1 f.ObjectID
									FROM Folder f 
										JOIN Folder f_s ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer AND f.Type != 16
									WHERE f_s.ObjectID = @NewParent
									ORDER BY f.LRLevel DESC
								)
							");
            cmd.Parameters.Add("OldParent", DbType.Guid, ParameterDirection.Input, false, uidFolderOld);
            cmd.Parameters.Add("NewParent", DbType.Guid, ParameterDirection.Input, false, uidFolderNew);
            vValue = cmd.ExecuteScalar();
            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                return true;
            return false;
        }
        
	}

	public abstract class ObjectRightsCheckerBase
	{
		protected bool m_bAllowEverythingByDefault;
		protected SecurityProvider m_provider;

		public ObjectRightsCheckerBase(SecurityProvider provider, bool bAllowEverythingByDefault)
		{
			m_provider = provider;
			m_bAllowEverythingByDefault = bAllowEverythingByDefault;
		}

		public virtual XObjectRights GetObjectRights(ITUser xuser, DomainObjectData xobj, XStorageConnection con)
		{
			if (m_bAllowEverythingByDefault)
				return XObjectRights.FullRights;
			else
				return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// Проверки при сохранении объекта
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public virtual bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (xobj.IsNew)
				return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
			else
			{
				XObjectRights rights = GetObjectRights(user, xobj, con);
				if (rights.AllowFullChange)
					return true;
				else if (rights.AllowParticalOrFullChange)
					// модифицировать можно, но не все свойства
					return ! hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);  
			}
			return false;
		}

		/// <summary>
		///  Проверки для нового объекта при сохранении. 
		///  Вызывается из ObjectRightsCheckerBase::HasSaveObjectRight
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		protected virtual bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			XNewObjectRights rights = GetRightsOnNewObject(user, xobj, con);
			if (rights.IsUnrestricted)
				return true;
			else if (rights.HasReadOnlyProps)
				// модифицировать можно, но не все свойства
				return ! hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);
			return false;
		}

		public virtual XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (m_bAllowEverythingByDefault)
				return XNewObjectRights.FullRights;
			else
				return XNewObjectRights.EmptyRights;
		}

		/// <summary>
		/// Возвращает признак содержит ли объект хотя бы одно модифицированное read-only свойство
		/// </summary>
		/// <param name="xobj"></param>
		/// <param name="rights">описание прав на объект</param>
		/// <returns>true - содержит, false - не содержит</returns>
		protected bool hasObjectChangedReadOnlyProps(DomainObjectData xobj, XObjectRightsBase rights, ref string sErrorDescription)
		{
           	ICollection props = rights.GetReadOnlyPropNames();
			foreach(string sProp in props)
				if (xobj.HasUpdatedProp(sProp))
					// пытают модифицировать read-only свойство
				{
                    sErrorDescription = "Нет прав на изменение свойства '" + xobj.TypeInfo.GetProp(sProp).Description + "'";
					return true;
				}
			return false;
		}

	}
    
	[SecurityRightsChecker("Organization")]
	public class OrganizationRightsChecker: ObjectRightsCheckerBase
	{
		public OrganizationRightsChecker(SecurityProvider provider): base(provider, false) 
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			XObjectRights rights = XObjectRights.ReadOnlyRights;
			Debug.Assert(con != null);
			// "Организация"
            if (user.ManageOrganization(xobj.ObjectID) || user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name))
                rights = XObjectRights.FullRights;
		
			return rights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: В системе может быть только одна организация со значением признака владелец системы (Home),равным true.
            if (xobj.HasUpdatedProp("Home"))
            {
                if ((bool)xobj.GetUpdatedPropValue("Home"))
                {
                    XDbCommand cmd = con.CreateCommand(@"	SELECT TOP 1 org.Name
			                                                    FROM Organization org 
			                                                    WHERE org.Home = 1
		                                           ");
                    object vValue = cmd.ExecuteScalar();
                    if (vValue != null)
                    {
                        sErrorDescription = @"Невозможно создать организацию с установленным признаком владелец - системы, так как в системе уже есть организация,
которая является владелецем системы  - " + "\"" + vValue.ToString() + "\"";
                        return false;
                    }
                }
            }
            return base.HasSaveObjectRight(user, xobj, con, out sErrorDescription);
            
        }

	    protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			bool bHasOrganizationManagementPrivilege = user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name);
			bool bHasTempOrganizationManagmentPrivilege = user.HasPrivilege(SystemPrivilegesItem.TempOrganizationManagment.Name);
            
            // RULE: Создавать организацию может пользователь, обладающий привилегией "Управление организациями" 
			if ( bHasOrganizationManagementPrivilege )
				return true;
			
			// RULE: Создавать организацию подчиненную некоторой другой могут директора родительских организаций
			// При этом описание должно быть временное во всех случаях кроме наличия привилегии "Управление организациями"/
			// Но т.к. ее наличие автоматически разрешает создание организации и мы это проверили выше, 
			// следовательно здесь организация может быть только временной
			if (xobj.GetUpdatedPropValue("Parent") is Guid)			// задана родительская организация
			{
				Guid parentID = (Guid)xobj.GetUpdatedPropValue("Parent");
				if (user.ManageOrganization(parentID))
					return true;
			}
            return false;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			bool bHasOrganizationManagementPrivilege = user.HasPrivilege(SystemPrivilegesItem.OrganizationManagement.Name);
			if (bHasOrganizationManagementPrivilege)
			{
				return new XNewObjectRights(true);
			}
			else
				return new XNewObjectRights(false);
		}
	}

	[SecurityRightsChecker("Folder")]
	public class FolderRightsChecker: ObjectRightsCheckerBase
	{
		public FolderRightsChecker(SecurityProvider provider): base(provider, false)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Debug.Assert(con != null);
			FolderTypeEnum nType;
			Guid organizationID;
			Guid activityTypeID;
			FolderStates folderState;
			
			// Убедимся, что объект загружен
			try
			{
				xobj.Load(con);
			}
			catch(XObjectNotFoundException)
			{
				// объекта нет в БД, все операции над ним запрещены
				return XObjectRights.ReadOnlyRights;
			}
			
			// Получим тип папки и идентификатор организации
			organizationID	= (Guid)xobj.GetLoadedPropValue("Customer");
			activityTypeID	= (Guid)xobj.GetLoadedPropValue("ActivityType");
			folderState		= (FolderStates)xobj.GetLoadedPropValue("State");
			nType = (FolderTypeEnum)xobj.GetLoadedPropValue("Type");
			FolderStates parentFolderState = 0;
			DomainObjectData xobjParent = null;
			if (xobj.GetLoadedPropValue("Parent") is Guid)
			{
				xobjParent = xobj.Context.GetLoadedStub("Folder", (Guid)xobj.GetLoadedPropValue("Parent"));
				parentFolderState = (FolderStates)xobjParent.GetLoadedPropValueOrLoad(con, "State");
			}
			
			// ОПРЕДЕЛЕНИЕ ПРАВ:

			XObjectRightsBuilder builder = new XObjectRightsBuilder();
			
			
			
			
			// RULE: если есть глобальные права на организацию-клиента или тип проектных затрат, 
			//		то с папкой можно делать все, если она не закрыта, иначе можно делать все, кроме удаления
			if (user.ManageOrganization(organizationID) || user.ManageActivityType(activityTypeID))
			{
				builder.SetAllowFullChange();
				builder.SetAllowDelete();
			}
			else
			{
				// ...глобальных прав на папку нет

				FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
				XPrivilegeSet priv_set = def.GetPrivileges(user, xobj.ObjectID, con);
				
				if (nType == FolderTypeEnum.Directory)
				{
					// Папка - каталог: возможно, есть права на управление каталогами в текущем проекте
					
					// RULE: При наличие привилегии "Управление каталогами" с папкой-каталогом можно делать 
					//	почти все: редактировать, удалять, переносить (за исключением признака блокировки
					//	списания - внутри if). Исключение - закрытый каталог: его нельзя удалять.
					if (priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
					{
						// RULE: Изменять флаг "Списания на папку заблокированы" можно только при наличии
						//	привилегии "Редактирование реквизитов проектов", иначе - можно менять все, 
						//	кроме значения самого флага:
						if (priv_set.Contains(FolderPrivilegesItem.ChangeFolder.Name))
							builder.SetAllowFullChange();
						else
							builder.SetAllowChangeExcept(new string[]{"IsLocked"});
						builder.SetAllowDelete();
					}
				}
				else
				{
					// Папка - НЕ каталог
					// RULE: Изменять реквизиты папки можно, если есть проектная привилегия "Редактирование 
					//	реквизитов папки"; все кроме свойств: Customer, ActivityType, Parent:
					if (priv_set.Contains(FolderPrivilegesItem.ChangeFolder.Name))
						builder.SetAllowChangeExcept(new string[] {"Customer", "ActivityType", "Parent"});
				}
			}
			// RULE: Изменять свойства Customer, ActivityType, Parent можно при наличии глобальной привилегии "Перенос папки"
			if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
				builder.SetAllowChangeProps(xobj.TypeInfo.Properties, new string[] {"Customer", "ActivityType", "Parent"});
            // RULE: если папка закрыта или в ожидании закрытия, то удалять ее нельзя никому. Менять можно только состояние

            // RULE: Если родительская папка находится в состоянии "Закрыто", то нельзя удалять, изменять состояние и 
            // переносить (т.е. менять любое из свойства:Customer, ActivityType, Parent)
            if (xobjParent != null)
            {
                if (parentFolderState == FolderStates.Closed)
                {
                    builder.SetReadOnlyPropsFinal(new string[] { "Incidents" });
                    builder.SetDenyDeleteFinal();
                    builder.SetDenyChangeFinal();
                }
				else
				{
					if (folderState == FolderStates.Closed)
                    {
                        builder.SetDenyDeleteFinal();
                        builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
                    }
				}

				if (parentFolderState == FolderStates.WaitingToClose)
				{
					if (folderState != FolderStates.Closed)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks",
                                                            "ExternalLink","IsLocked","DefaultIncidentType"});
					}
				}
				else
				{
					if (folderState == FolderStates.WaitingToClose)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType"});
					}
				}

				if (parentFolderState == FolderStates.Frozen)
				{
					builder.SetReadOnlyPropsFinal(new string[] { "Incidents" });
					builder.SetDenyDeleteFinal();
					builder.SetDenyChangeFinal();
				}
				else
				{
					if (folderState == FolderStates.Frozen)
					{
						builder.SetDenyDeleteFinal();
						builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
					}
				}

                //По идее, если родительская папка закрыта или в ожидани закрытия, то у дочерних ничего менять не будем
                //builder.SetDenyChangeFinal();
            }
            else
            {
                if (folderState == FolderStates.WaitingToClose)
                {
                    builder.SetDenyDeleteFinal();
                    builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType"});
                }
                else if (folderState == FolderStates.Closed)
                {
                    builder.SetDenyDeleteFinal();
                    builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
				}
				else if (folderState == FolderStates.Frozen)
				{
					builder.SetDenyDeleteFinal();
					builder.SetReadOnlyPropsFinal(new string[] {"Customer", "ActivityType", "Parent", "Incidents",
                                                            "Participants", "ExternalLinks","IsLocked",
                                                            "ExternalLink","DefaultIncidentType","Name",
                                                            "ExternalID","Description","FolderDirections"});
				}
            }
           	return builder.GetObjectRights();
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (xobj.IsNew)
				return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
			else
			{
                
				// ВНИМАНИЕ: внутри GetObjectRights происходит загрузка старых данных объекта, что используется далее,
				//	т.е. вызовы GetLoadedPropValue безопасны
				XObjectRights rights = GetObjectRights(user, xobj, con);
				if (!rights.AllowParticalOrFullChange)
					return false;
				// модифицировать можно, но не все свойства
				if (hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription))
					return false;

				FolderTypeEnum folderType = (FolderTypeEnum)xobj.GetLoadedPropValue("Type");
				// RULE: каталог не может быть перенесен на корневой уровень
				if (folderType == FolderTypeEnum.Directory && xobj.GetUpdatedPropValue("Parent") == DBNull.Value)
				{
					sErrorDescription = "Каталог не может быть перенесен на корневой уровень";
					return false;
				}

				// RULE: переводить активность (НЕ каталог) в состояние "Закрыто" может только юзер, 
				//	обраладающий системной привилегией "Закрытие проектных активностей" (CloseAnyFolder).
				//	ВНИМАНИЕ! Соответсвутющая ПРОЕКТНАЯ привилегия "Закрытие проектной активности" 
				//	(CloseFolder) в закрываемой папке ПОКА НЕ АНАЛИЗИРУЕТСЯ - до решения вопроса о том
				//	как будет контроллироваться ВЫДАЧА этой проектной привилегии (предпологается, что 
				//	проектную привилегию могут выдать те, у кого есть аналогичная системная привилегия)
				if (xobj.HasUpdatedProp("State") && !xobj.IsNew && folderType != FolderTypeEnum.Directory)
				{
					FolderStates folderStateOld = (FolderStates) xobj.GetLoadedPropValue("State");
					FolderStates folderStateNew = (FolderStates) xobj.GetUpdatedPropValue("State");
					bool bIsCheckStateChanging = 
						( folderStateOld != FolderStates.Closed && folderStateNew == FolderStates.Closed ) ||
						( folderStateOld == FolderStates.Closed && folderStateNew != FolderStates.Closed );

					if (bIsCheckStateChanging)
						if (!user.HasPrivilege( SystemPrivilegesItem.CloseAnyFolder.Name ))
						{
							// TODO: ПРОЕКТНАЯ ПРИВИЛЕГИЯ - ПОКА НЕ РАССМАТРИВАЕТСЯ  
							//	if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.CloseFolder, xobj, con))
							{
								sErrorDescription = "Недостаточно прав для закрытия проектной активности";
								return false;
							}
						}
				}
                // RULE: При переносе папки, надо проверить, есть ли трудозатраты в закрытом глобальном периоде
                if (xobj.HasUpdatedProp("Parent"))
                {
                    DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
                    // Если перенос папки влияет на распределение затрат, то надо проверить на наличие затрат в закрытом глобальном периоде
                    if (ApplicationSettings.GlobalBlockPeriodDate != DateTime.MinValue)
                    {
                        if (CommonRightsRules.CheckFolderForBlockedPeriod(xobjFolderNew, xobj, con))
                        {
                            XDbCommand cmd = con.CreateCommand(@"SELECT TOP 1 * FROM
                                                            (
	                                                        SELECT TOP 1 1 AS ID
	                                                        FROM [dbo].[TimeSpent] ts (NOLOCK)
		                                                        JOIN dbo.Task tsk (NOLOCK) ON tsk.ObjectID = ts.[Task]
		                                                        JOIN dbo.Incident inc (NOLOCK) ON inc.ObjectID = tsk.Incident
		                                                        JOIN dbo.Folder f (NOLOCK) ON inc.Folder = f.ObjectID
		                                                        JOIN dbo.Folder AS FF (NOLOCK) ON FF.Customer = F.Customer
			                                                      AND FF.LIndex <= F.LIndex AND F.RIndex <= FF.RIndex 
	                                                        WHERE ts.[RegDate] <= @Date AND FF.ObjectID = @FolderID  
	                                                        UNION ALL
	                                                        SELECT TOP 1 1 AS ID
	                                                        FROM dbo.TimeLoss tls (NOLOCK)
		                                                        JOIN dbo.Folder f (NOLOCK) ON tls.Folder= f.ObjectID
		                                                        JOIN dbo.Folder AS FF (NOLOCK) ON FF.Customer = F.Customer
			                                                        AND FF.LIndex <= F.LIndex AND F.RIndex <= FF.RIndex 
	                                                        WHERE tls.[LossFixed] <= @Date AND FF.ObjectID = @FolderID) Res
                                                        ");
                            cmd.Parameters.Add("@Date", DbType.Date, ParameterDirection.Input, false, ApplicationSettings.GlobalBlockPeriodDate);
                            cmd.Parameters.Add("@FolderID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
                            using (IDataReader reader = cmd.ExecuteReader())
                            {
                                bool bHasTimeSpent = false;
                                if (reader.Read())
                                {
                                    bHasTimeSpent = reader.GetBoolean(0);
                                }
                                sErrorDescription = "Папка содержит трудозатраты, зарегистрированные в закрытый период";
                                if (bHasTimeSpent)
                                    return false;
                            }
                        }
                    }
                }
				// если у папки изменился родитель, клиент или тип проектных затрат (операция переноса папки)
				// Здесь мы уже знаем, что теоретически изменять родителя,клиента и/или тип проектных затрат можно, но
				// надо проверить допустимость новых значений
				// ВНИМАНИЕ: все проверки новых значений, не связанные с Parent,Customer,ActivityType надо выполнять до следующего блока,
				//			т.к. в нем, в случае успеха проверки, делается "return true"
				if (xobj.GetUpdatedPropValue("Parent") is Guid || xobj.GetUpdatedPropValue("Customer") is Guid || xobj.GetUpdatedPropValue("ActivityType") is Guid )
				{
					// RULE: Папка не может быть перенесена в закрытую папку
					if (xobj.GetUpdatedPropValue("Parent") is Guid)
					{
						DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
						FolderStates parentFolderState = (FolderStates)xobjFolderNew.GetLoadedPropValue("State");
						if (parentFolderState == FolderStates.Closed || parentFolderState == FolderStates.WaitingToClose || parentFolderState == FolderStates.Frozen)
						{
							sErrorDescription = "Перенос папки в папку, находящуюся в состоянии \"Закрыто\" или \"Ожидание закрытия\", запрещен";
							return false;
						}
					}
                    
					// RULE: Пользователи, обладающие системной привилегией "Перенос папок", могут переносить любую папку в любое место
					if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
						return true;

					object vValue;
					vValue = xobj.GetUpdatedPropValue("ActivityType");
					if (vValue is Guid)
					{
						// изменился тип проектных затрат
						if (user.ManageActivityType((Guid)vValue))
							return true;
						// прав на тип активности нет. Поэтому, если он изменился относительно значения в БД, то сохранять нельзя.  
						// А для "папок" не важно.
						if (folderType != FolderTypeEnum.Directory && (Guid)xobj.GetLoadedPropValue("ActivityType") != (Guid)vValue)
						{
							sErrorDescription = "Недостаточно прав для изменения ссылки на тип проектных затрат";
							return false;
						}
					}
					else
					{
						// тип проектных затрат не изменился. Если были права на "старый", то можно сохранить.
						if (user.ManageActivityType((Guid)xobj.GetLoadedPropValue("ActivityType")))
							return true;
					}

					vValue = xobj.GetUpdatedPropValue("Customer");
					if (vValue is Guid)
					{
						// изменилась ссылка на клиента
						if (user.ManageOrganization((Guid)vValue))
							return true;
						// прав на организацию нет. Поэтому, если ссылка изменилaся относительно значения в БД, то сохранять нельзя
						// А для "папок" не важно.
						if (folderType != FolderTypeEnum.Directory && (Guid)xobj.GetLoadedPropValue("Customer") != (Guid)vValue)
						{
							sErrorDescription = "Недостаточно прав для изменения ссылки на организацию-клиента";
							return false;
						}
					}
					else
					{
						// ссылка на клиента не изменилась. Если были права на "сторого", то можно сохранить
						if (user.ManageOrganization((Guid)xobj.GetLoadedPropValue("Customer")))
							return true;
					}

					if (folderType == FolderTypeEnum.Directory)
					{
						// RULE: если текущая папка - каталог, то переносить его в пределах проекта может пользователь, 
						//		обладающий проектной привилегией "Управление каталогами"
						// Примечание: тип папки меняться не может, поэтому вызов GetLoadedPropValue корректен
						if (xobj.GetUpdatedPropValue("Parent") is Guid)
						{
							// ВНИМАНИЕ: т.к. системную привелегию "Перенос папок" мы проверили, а также права на организацию и тип проектных затрат,
							// но тем не менее GetObjectRights сказал нам, что свойство Parent не read-only, 
							// значит пользователь обладает проетной привилегией "Управление каталогами" - еще раз проверять это не будем!
							// Проверим то, что в новом паренте юзер имеет эту привилегию
							DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
							FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
							XPrivilegeSet priv_set = def.GetPrivileges(user, xobjFolderNew.ObjectID, con);
							if (!priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
							{
								sErrorDescription = "Недостаточно прав для переноса папки";
								return false;
							}
						}
						return true;
					}
					return false;
				}
				return true;
			}
		}

		/// <summary>
		/// Проверка на возможность создания объекта
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjParent = null;		// Родительская папка
			// RULE: если задана ссылка на родителя, то проверим его состояние. Если он "закрыт", то создание папки запрещено
			if (xobj.GetUpdatedPropValue("Parent") is Guid)
			{
				xobjParent = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
                if (
					((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.Closed)
					|| ((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.WaitingToClose)
					|| ((FolderStates)xobjParent.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps) == FolderStates.Frozen)
					)
					return XNewObjectRights.EmptyRights;
			}
			Guid activityType = Guid.Empty;
			object vValue;
			vValue = xobj.GetUpdatedPropValue("ActivityType");
			if (vValue is Guid)
			{
				activityType = (Guid)vValue;
				if (user.ManageActivityType(activityType))
					return XNewObjectRights.FullRights;
			}
			Guid orgID = Guid.Empty;
			vValue = xobj.GetUpdatedPropValue("Customer");
			if (vValue is Guid)
			{
				orgID = (Guid)vValue;
				if (user.ManageOrganization(orgID))
					return XNewObjectRights.FullRights;
			}

			vValue = xobj.GetUpdatedPropValue("Type");
			if (vValue is Int16)
			{
				FolderTypeEnum nType = (FolderTypeEnum)vValue;
				if (xobjParent != null)
				{
					// RULE: Создать каталог в другой папке может пользователь, обладающий в нем привилегией "Управление каталогами"
					// Но это не относится к новым папкам
					if (nType == FolderTypeEnum.Directory)
					{
						if (xobjParent.IsNew)
							return XNewObjectRights.FullRights;
						else
						{
							FolderPrivilegesDefinitionContainer def = (FolderPrivilegesDefinitionContainer)m_provider.ObjectPrivilegeContainers["Folder"];
							XPrivilegeSet priv_set = def.GetPrivileges(user, xobjParent.ObjectID, con);
							if (priv_set.Contains(FolderPrivilegesItem.ManageCatalog.Name))
								return XNewObjectRights.FullRights;
						}
					}
					// RULE: создавать тендеры и пресейлы можно только на корневом уровне
					else if (nType == FolderTypeEnum.Presale || nType == FolderTypeEnum.Tender)
						return XNewObjectRights.EmptyRights;
				}

				// RULE: Если не задан тип проектных затрат, но задан тип папки и ссылка на клиента, то
				//	попробуем получить тип проектных затрат с их помощью
				if (activityType == Guid.Empty && orgID != Guid.Empty && nType != FolderTypeEnum.Directory)
				{
					XDbCommand cmd = con.CreateCommand(@"
					SELECT
						at.ObjectID
					FROM dbo.ActivityType at
					WHERE at.FolderType & @FolderType > 0 AND at.AccountRelated = ABS(1-(SELECT Home FROM Organization WHERE ObjectID = @OrgID))
					");
					cmd.Parameters.Add("FolderType", DbType.Int16, ParameterDirection.Input, false, vValue);
					cmd.Parameters.Add("OrgID", DbType.Guid, ParameterDirection.Input, false, orgID);

					using(IDataReader reader = cmd.ExecuteReader())
					{
						if (reader.Read())
						{
							activityType = reader.GetGuid(0);
							// если это была последняя строка
							if (!reader.Read())
							{
								if (user.ManageActivityType(activityType))
									return XNewObjectRights.FullRights;
							}
						}
					}
				}
			}

			return XNewObjectRights.EmptyRights;
		}
	}

	[SecurityRightsChecker("ExternalLink")]
	public class ExternalLinkRightsChecker : ObjectRightsCheckerBase
	{
		public ExternalLinkRightsChecker(SecurityProvider provider) : base(provider, true) { }

		public override XObjectRights GetObjectRights(ITUser xuser, DomainObjectData xobj, XStorageConnection con)
		{
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.GetLoadedStub("Folder", (Guid)xobj.GetLoadedPropValue("Folder"));
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");

				return folderState == FolderStates.Open ? XObjectRights.FullRights : XObjectRights.ReadOnlyRights;
			}

			return base.GetObjectRights(xuser, xobj, con);
		}
	}

	[SecurityRightsChecker("SystemUser", "Employee")]
	public class UserRightsChecker: ObjectRightsCheckerBase
	{
		public UserRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
            // RULE: Если нет привелегии "управление пользователями" - доступ только на чтение
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
                return XObjectRights.ReadOnlyRights;

            return XObjectRights.FullRights;
        }

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
            // RULE: Если нет привелегии "управление пользователями" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
                return XNewObjectRights.EmptyRights;

            return XNewObjectRights.FullRights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: Если нет привелегии "управление пользователями" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
                sErrorDescription = "Управлять справочником сотрудников могут только пользователи, обладающие привилегией '" + SystemPrivilegesItem.ManageUsers.Description + "'";
                return false;
            }
            

            return true;
        }
	}

    [SecurityRightsChecker("Direction")]
    public class DirectionRightsChecker : ObjectRightsCheckerBase
    {
        public DirectionRightsChecker(SecurityProvider provider)
            : base(provider, true)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: Если нет привелегии "управление справочниками" - доступ только на чтение
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XObjectRights.ReadOnlyRights;

            if (xobj.GetUpdatedPropValue("Department") is Guid)
            {
                // RULE: Если департамент архивный - доступ только на чтение
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                        return XObjectRights.ReadOnlyRights;
                }
            }
            return XObjectRights.FullRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: Если нет привелегии "управление справочниками" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XNewObjectRights.EmptyRights;

            if (xobj.GetUpdatedPropValue("Department") is Guid)
            {

                // RULE: Если департамент архивный - доступ только на чтение
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                Guid id = xobjDepartment.ObjectID;
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetPropValueAnyhow("IsArchive", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, con);

                    if (isArchive)
                        return XNewObjectRights.EmptyRights;
                }
            }
            return XNewObjectRights.FullRights;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: Если нет привелегии "управление пользователями" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
            {
                sErrorDescription = "Управлять справочником могут только пользователи, обладающие привилегией '" + SystemPrivilegesItem.ManageRefObjects.Description + "'";
                return false;
            }

            if (xobj.GetLoadedPropValueOrLoad(con, "Department") is Guid)
            {
                // RULE: Если департамент архивный - сохранять нельзя
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Department", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                    {
                        sErrorDescription = "Департамент архивный. Редактирование запрещено.";
                        return false;
                    }
                }
            }
            return true;
        }
    }

    [SecurityRightsChecker("Department")]
    public class DepartmentRightsChecker : ObjectRightsCheckerBase
    {
        public DepartmentRightsChecker(SecurityProvider provider)
            : base(provider, true)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: Если нет привелегии "управление справочниками" - доступ только на чтение
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XObjectRights.ReadOnlyRights;

            if (xobj.GetUpdatedPropValue("Parent") is Guid)
            {
                // RULE: Если вышестоящий департамент архивный - доступ только на чтение
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                        return XObjectRights.ReadOnlyRights;
                }
            }
            return XObjectRights.FullRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            // RULE: Если нет привелегии "управление справочниками" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
                return XNewObjectRights.EmptyRights;

            if (xobj.GetUpdatedPropValue("Parent") is Guid)
            {
                // RULE: Если вышестоящий департамент архивный - доступ только на чтение
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                if (xobjDepartment != null)
                {
                        
                      bool isArchive = (bool)xobjDepartment.GetPropValueAnyhow("IsArchive",DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, con);
                      if (isArchive)
                        return XNewObjectRights.EmptyRights;
                }
                
            }
            return XNewObjectRights.FullRights;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            // RULE: Если нет привелегии "управление пользователями" - доступа нет
            if (!user.HasPrivilege(SystemPrivilegesItem.ManageRefObjects.Name))
            {
                sErrorDescription = "Управлять справочником департаментов могут только пользователи, обладающие привилегией '" + SystemPrivilegesItem.ManageRefObjects.Description + "'";
                return false;
            }

            if (xobj.GetLoadedPropValueOrLoad(con, "Parent") is Guid)
            {
                // RULE: Если департамент архивный - сохранять нельзя
                DomainObjectData xobjDepartment;
                xobjDepartment = xobj.Context.Get(con, xobj, "Parent", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);
                if (xobjDepartment != null)
                {
                    bool isArchive = (bool)xobjDepartment.GetLoadedPropValueOrLoad(con, "IsArchive");

                    if (isArchive)
                    {
                        sErrorDescription = "Вышестоящий департамент архивный. Редактирование запрещено.";
                        return false;
                    }
                }
            }
            return true;
        }
    }

    [SecurityRightsChecker("EmployeeRate")]
    public class EmployeeRateRightsChecker : ObjectRightsCheckerBase
    {
        public EmployeeRateRightsChecker(SecurityProvider provider)
            : base(provider, false)
        { }
        public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            if (user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
                DateTime dtRateDate = (DateTime)xobj.GetLoadedPropValueOrLoad(con,"Date");
                if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
                {
                    return XObjectRights.FullRights;
                }
            }
            return XObjectRights.ReadOnlyRights;
        }

        public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
        {
            if (user.HasPrivilege(SystemPrivilegesItem.ManageUsers.Name))
            {
               return XNewObjectRights.FullRights;
            }
            return XNewObjectRights.EmptyRights;
        }
        protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            DateTime dtRateDate = (DateTime)xobj.GetLoadedPropValueOrLoad(con, "Date");
            if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
            {  
                return true;
            }
            sErrorDescription = "Дата нормы (" + dtRateDate + ") попадает в закрытый период";
            return false;
        }
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            DateTime dtRateDate = new DateTime();
            // Если менялась дата нормы, либо идет вставка новой нормы, то надо проверить дату на попадание в закрытый период
            if (xobj.HasUpdatedProp("Date"))
            {
                dtRateDate = (DateTime)xobj.GetUpdatedPropValue("Date");
                if (dtRateDate > ApplicationSettings.GlobalBlockPeriodDate)
                {
                    return true;
                }
                sErrorDescription = "Дата нормы (" + dtRateDate + ") попадает в закрытый период";
                return false;
            }
            return true;
        }
    }
	[SecurityRightsChecker("Incident")]
	public class IncidentRightsChecker: ObjectRightsCheckerBase
	{
		public IncidentRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			XObjectRightsBuilder rightsBuilder = new XObjectRightsBuilder();
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
            if (!xobjFolder.IsFullyLoaded) xobjFolder.Load(con);
			// RULE: В закрытом проекте доступа к инциденту нет ни у кого
            if (
				(FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed
				|| (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose
				|| (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen
				)
				return XObjectRights.ReadOnlyRights;

			// получим два признака: в инциденте есть задания и в инциденте есть задание для текущего юзера
			XDbCommand cmd = con.CreateCommand(@"
				SELECT TOP 1
					1,
					CASE WHEN Worker = @EmployeeID THEN 1 ELSE 0 END AS HasOwnTask
				FROM Task t 
				WHERE t.Incident = @IncidentID
				ORDER BY 2 DESC
				");
			cmd.Parameters.Add("IncidentID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
			cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, user.EmployeeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				if (reader.Read())
				{
					// если запрос что-то вернул, значит в инциденте есть задания - изменять тип нельзя
					rightsBuilder.AddReadOnlyPropFinal("Type");
					// колонка HasOwnTask в результате будет не-NULL, если текущий юзер имеет задание в инциденте
					if (reader.GetInt32(reader.GetOrdinal("HasOwnTask")) == 1)
					{
						// RULE: Правом редактирования на инцидент обладает юзер, для которого в инциденте есть Задание (Task)
						//		Но он не может изменять свойствo "Folder" (т.е. переносить инцидент)
						rightsBuilder.SetAllowChangeExcept(new string[] {"Folder"});
					}
				}
			}

			// RULE: Всеми правами на любой инцидент обладают юзеры с привилегией "Управление инцидентами" в папке
			//	(там неявно проверяется наличие прав на организацию и тип проектных затрат)
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolder, con))
			{
				rightsBuilder.SetAllowFullChange();
				rightsBuilder.SetAllowDelete();
			}

			// RULE: Пользователь, обладающие системной привилегией "Перенос папок и инцидентов", может переносить инцидент
			if (user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
				rightsBuilder.SetAllowChangeProps(xobj.TypeInfo.Properties, new string[] {"Folder"});

			return rightsBuilder.GetObjectRights();

			// RULE: Если по инциденту есть списания (т.е. по хотя бы по одному заданию), то удалять его нельзя
			// Закоментировано, т.к. не ясно нужно ли такое правило. По идеи юзер и так не сможет удалить инцидент, если по нему есть списания
			/*
			cmd = con.CreateCommand("SELECT 1 FROM Task t JOIN TimeSpent ts ON ts.Task = t.ObjectID WHERE t.Incident = @ObjectID");
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
			bool bDenyDelete = false;
			if (cmd.ExecuteScalar() != null)
			{
				// Что-то вернули - значит списания на таски есть
				bDenyDelete = true;
			}
			if (!bDenyDelete)
			{ }
			return new XObjectRights(!bDenyDelete, true);
			*/
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			// RULE: если ссылка на папку еще не заданa, значит не известно где будет создаваться инцидент - разрешим 
			// (проверять будем при сохранении)
			if (!(xobj.GetUpdatedPropValue("Folder") is Guid))
				return XNewObjectRights.FullRights;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjFolder == null)
				return XNewObjectRights.FullRights;

			// RULE: Создание инцидента разрешено всем, но только, если папка НЕ находится в состоянии "Закрыто"
			FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");
            if (folderState != FolderStates.Closed && folderState != FolderStates.WaitingToClose && folderState != FolderStates.Frozen)
				return XNewObjectRights.FullRights;
			
			return XNewObjectRights.EmptyRights;
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
				return false;
			if (!xobj.IsNew)
			{	
				// RULE: Нельзя изменять тип инцидентa, если по нему есть задания
				if (xobj.HasUpdatedProp("Type"))
				{
					if (xobj.HasUpdatedProp("Tasks"))
					{
						if (((Guid[])xobj.GetUpdatedPropValue("Tasks")).Length > 0)
						{
							sErrorDescription = "Нельзя изменять тип инцидентa, если в нем назначены исполнители";
							return false;
						}
					}
				}
				// Изменилась ссылка на папку - перенос инцидента
				if (xobj.GetUpdatedPropValue("Folder") is Guid)
				{
                    DomainObjectData xobjFolderNew = xobj.Context.Get(con, xobj, "Folder",DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, true);
					xobjFolderNew.Load(con);
                    DomainObjectData xobjFolderOld = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
                    xobjFolderOld.Load(con);
                    if (ApplicationSettings.GlobalBlockPeriodDate != DateTime.MinValue)
                    {
                        if (CommonRightsRules.CheckIncidentForBlockedPeriod(xobjFolderNew, xobjFolderOld, con))
                        {
                            object vValue = null;
                            XDbCommand cmd = con.CreateCommand(@"
                            SELECT TOP 1 1
                                FROM [dbo].[TimeSpent] ts 
	                            JOIN dbo.Task tsk ON tsk.ObjectID = ts.[Task]
	                            JOIN dbo.Incident inc ON inc.ObjectID = tsk.Incident
                            WHERE ts.[RegDate] <= @Date AND inc.ObjectID = @ObjectID
                        ");
                            cmd.Parameters.Add("ObjectID", XPropType.vt_uuid, ParameterDirection.Input, false, xobj.ObjectID);
                            cmd.Parameters.Add("Date", XPropType.vt_dateTime, ParameterDirection.Input, false, ApplicationSettings.GlobalBlockPeriodDate);
                            vValue = cmd.ExecuteScalar();
                            if (vValue != null && (Convert.ToInt32(vValue) == 1))
                            {
                                sErrorDescription = "Инцидент содержит трудозатраты, зарегистрированные в закрытый период";
                                return false;
                            }
                        }
                    }
					// RULE: В закрытую папку переносить инцидент нельзя
					if ((FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.Closed || (FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.WaitingToClose || (FolderStates)xobjFolderNew.GetLoadedPropValue("State") == FolderStates.Frozen)
					{
						sErrorDescription = "Перенос инцидента в папку, находящуюся в состоянии \"Закрыто\", \"Ожидание закрытия\" или \"Заморожено\", запрещен";
						return false;
					}

					// RULE: переносить инцидент в папку может (перенос "из папки" мы проверили в GetObjectRights) пользователь: 
					//		обладающий системной привилегией "Перенос папок и инцидентов", 
					//		обладающий проектной привилегией "Управление инцидентами"
					if (!user.HasPrivilege(SystemPrivilegesItem.MoveFoldersAndIncidents.Name))
						if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidents, xobjFolderNew, con))
						{
							// TODO: сформировать sErrorDescription
							return false;
						}

					// Если здесь, то: перенесли инцидент в незакрытый проект и юзера есть глобальные права на перенос, 
					//	либо права в проекте на упраление инцидентами
				}
			}

			// TODO:
			// RULE: Изменять состояние инцидента можно только в соответствии с workflow, 
			// либо при наличии привилегии "Управление инцидентами" (ManageIncidents)
			return true;
		}

    }

	[SecurityRightsChecker("IncidentStateHistory")]
	public class IncidentStateHistoryRightsChecker: ObjectRightsCheckerBase
	{
		/// <summary>
		/// Доступ к объектам запрещен
		/// </summary>
		/// <param name="provider"></param>
		public IncidentStateHistoryRightsChecker(SecurityProvider provider): base(provider, false)
		{}
	}

	[SecurityRightsChecker("Task")]
	public class TaskRightsChecker: ObjectRightsCheckerBase
	{
		public TaskRightsChecker(SecurityProvider provider): base(provider, true)
		{}
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Debug.Assert(con != null);
			DomainObjectDataSet dataSet = xobj.Context;
			// RULE: Редактировать и удалять любое Задание может сотрудник с привилегией "Управление составом участников инцидента"
			// Получим идентификатор папки, а также идентификатор Клиента и Типа проектных затрат, 
			// т.к. по ним вычисляются привилегии юзера на папки
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Incident.Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, false);
			if (xobjFolder == null || !xobjFolder.HasLoadedProp("Customer") || !xobjFolder.HasLoadedProp("ActivityType") || !xobjFolder.HasLoadedProp("State"))
			{
				// объекта нет в контексте, либо объект есть, но одно из свойств: Customer, ActivityType, State не загружено
				// Загрузим его с помощью собственного запроса, из соображений оптимизации (DataSet грузил бы свойства отдельными запросами)
				XDbCommand cmd = con.CreateCommand(String.Format(@"
					SELECT i.Folder, f.Customer, f.ActivityType, f.State, 
						t.Worker, t.Planner
					FROM {0} i 
						JOIN {1} t ON t.Incident = i.ObjectID 
						JOIN {2} f ON f.ObjectID = i.Folder
					WHERE t.ObjectID = @ObjectID",
					con.GetTableQName("Incident"),	// 0
					con.GetTableQName("Task"),		// 1
					con.GetTableQName("Folder")		// 2
					));
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, xobj.ObjectID);
				using(IDataReader reader = cmd.ExecuteReader())
				{
					if (reader.Read())
					{
						if (xobjFolder == null)
							xobjFolder = dataSet.GetLoadedStub("Folder", reader.GetGuid(reader.GetOrdinal("Folder")) );
						xobjFolder.SetLoadedPropValue("Customer", reader.GetGuid( reader.GetOrdinal("Customer") ));
						xobjFolder.SetLoadedPropValue("ActivityType", reader.GetGuid( reader.GetOrdinal("ActivityType") ));
						xobjFolder.SetLoadedPropValue("State", (FolderStates)reader.GetInt16( reader.GetOrdinal("State") ));
						xobj.SetLoadedPropValue("Worker", reader.GetGuid(reader.GetOrdinal("Worker")));
						xobj.SetLoadedPropValue("Planner", reader.GetGuid(reader.GetOrdinal("Planner")));
					}
					else
						throw new XObjectNotFoundException("Не удалось загрузить папку для задания с идентификатором " + xobj.ObjectID);
				}
			}
		
			// Теперь у нас есть описание папки (со св-вами Customer, ActivityType, State)
			if ( (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
				return XObjectRights.ReadOnlyRights;

			// Если юзер обладает привилегией "Управление составом участников инцидента" в папке 
			// (с учетом привилегий на организацию-клиента и ActivityType)
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return XObjectRights.FullRights;
			
			// Если мы здесь, значить юзер не обладает привилегией "Управление составом участников инцидента" в папке

			// RULE: Редактировать Задание может сам исполнитель, если задание не имеет установленный признак "Заморожено"
			// Получим идентификатор сотрудника-исполнителя задания
			Guid workerID = (Guid)xobj.GetLoadedPropValue("Worker");
			// если исполнитель - это текущий сотрудник, то редактировать задание он может, кроме свойств "Роль", "Инцидент", "Исполнитель"
			if (workerID == user.EmployeeID)
			{
				if (!(bool)xobj.GetLoadedPropValueOrLoad(con, "IsFrozen"))
				{
					// RULE: если текущий пользователь является планировщиком задания (т.е. он уже менял запланированное время),
					//		прав на изменения свойства "Заплaнированное время" у него нет, иначе есть
					string[] aReadOnlyProps;
					if ((Guid)xobj.GetLoadedPropValue("Planner") == user.EmployeeID)
						aReadOnlyProps = new string[] { "Role", "Incident", "Worker", "IsFrozen", "PlannedTime" };
					else
						aReadOnlyProps = new string[] { "Role", "Incident", "Worker", "IsFrozen" };
					
					return new XObjectRights(false, aReadOnlyProps);
				}
			}

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// Сохранение нового объекта
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			DomainObjectData xobjIncident = xobj.Context.Get(con, xobj, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjIncident == null)
				return false;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			if (xobjFolder == null)
				return false;

			// RULE: Создавать Задание в Инциденте, находящемся в закрытой папке, нельзя никому
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
			{
				sErrorDescription = "Нельзя создать задание в папке, находящейся в состоянии 'Закрыто'";
				return false;
			}

			// RULE: Право на создание и редактирование Задания имеет юзер обладаюший в папке, в которой находится инцидент, привилегией "Управление составом участников инцидента"
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return true;

			// Привилегии "Управление составом участников инцидента" в папке нет, однако
			// в новом инциденте создавать Задание можно для себя (выполняется кодом автоматически)
			if (xobj.HasUpdatedProp("Worker") && (Guid)xobj.GetUpdatedPropValue("Worker") != user.EmployeeID)
				return false;

			return true;
			// TODO: еще можно проверить, что роль корректная
		}

		/// <summary>
		/// Получение прав на создание нового объекта
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjIncident = xobj.Context.Get(con, xobj, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyUpdatedProps, false);
			if (xobjIncident == null)
				return XNewObjectRights.EmptyRights;
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			if (xobjFolder == null)
				return XNewObjectRights.EmptyRights;

			// RULE: Создавать Задание в Инциденте, находящемся в закрытой папке, нельзя никому
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
				return XNewObjectRights.EmptyRights;

			// RULE: Право на создание и редактирование Задания имеет юзер обладаюший в папке, в которой находится инцидент, привилегией "Управление составом участников инцидента"
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageIncidentParticipants, xobjFolder, con))
				return XNewObjectRights.FullRights;

			// RULE: Создавать задание для себя можно в мастере инцидента (выполняется автоматически клиентской логикой)
			// Но т.к. мы не знаем для кого будет создаваться задание
			//if (xobjIncident.IsNew && xobj.HasUpdatedProp("Worker") && (Guid)xobj.GetUpdatedPropValue("Worker") == user.EmployeeID)
			return new XNewObjectRights(false, new string[] {"Role", "Incident", "Worker", "IsFrozen"});
		}
	}

	[SecurityRightsChecker("TimeSpent")]
	public class TimeSpentRightsChecker: ObjectRightsCheckerBase
	{
		public TimeSpentRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		/// <summary>
		/// Проверка прав на существующий и, ВНИМАНИЕ, на новый объект.
		/// </summary>
		/// <param name="user"></param>
		/// <param name="xobj"></param>
		/// <param name="con"></param>
		/// <returns></returns>
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			string sDummy;
			return GetObjectRightsUniversal(user, xobj, con, out sDummy);
		}

		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
				return false;

			// Получим папку. См. GetObjectRights - там мы ее уже загрузили, поэтому здесь загрузки не произойдет
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Task.Incident.Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			// Если изменилась дата списания, то проверим на непопадает в период блокирования списаний
			object vPropValue;
			vPropValue = xobj.GetUpdatedPropValue("RegDate");
			if (vPropValue is DateTime)
				if (CommonRightsRules.IsRegDateInBlockPeriod((DateTime)vPropValue, xobjFolder))
				{
					sErrorDescription = "Заданная дата списания времени по заданию попадает в заблокированный период";
					return false;
				}

			return true;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			string sErrorDescription = null;
			XObjectRights rights = GetObjectRightsUniversal(user, xobj, con, out sErrorDescription );
			if (rights.AllowParticalOrFullChange)
				return XNewObjectRights.FullRights;

			return XNewObjectRights.EmptyRights;
		}

		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			XObjectRights rights = GetObjectRightsUniversal(user, xobj, con, out sErrorDescription );
			if (rights.AllowParticalOrFullChange)
				return true;
			return false;
		}

		protected XObjectRights GetObjectRightsUniversal(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			DomainObjectDataSet dataSet = xobj.Context;
			xobj.Load(con);
			DomainObjectData xobjTask;
			DomainObjectData xobjIncident;
			DomainObjectData xobjFolder;

			// получим Задание, к которому относится списание (ссылка на задание изменяться не может)
			xobjTask = dataSet.Get(con, xobj, "Task", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjTask == null)
				return XObjectRights.NoAccess;
			// получим Инцидент, к которому относится Задание (ссылка на инцидент изменяться не может)
			xobjIncident = dataSet.Get(con, xobjTask, "Incident", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjIncident == null)
				return XObjectRights.NoAccess;
			// получим заглушку папки, в которой находится инцидент, к которому относится задание, на которое ссылается списание
			xobjFolder = dataSet.Get(con, xobjIncident, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true);
			if (xobjFolder == null)
				return XObjectRights.NoAccess;

			// RULE: Создавать, редактировать и удалять списания в закрытом проекте запрещено всем
			if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen)
				return XObjectRights.ReadOnlyRights;

			// Проверим права на основании даты списания относительно периода фиксации списаний
			// Примечание: данные метод (GetObjectRights) используется в том числе для проверки прав на возможность создания, 
			//	поэтому нельзя предполагать, что заданы все свойства.
			object vValue = xobj.GetPropValue("RegDate", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is DateTime)
			{
				DateTime dtTimeSpentDate = (DateTime)vValue;
				if (CommonRightsRules.IsRegDateInBlockPeriod(dtTimeSpentDate, xobjFolder))
				{
					sErrorDescription = "Дата списания (" + dtTimeSpentDate + ") попадает в закрытый период";
					return XObjectRights.ReadOnlyRights;
				}
			}

			// RULE: Создавать, редактировать и удалять списание запрещено, если инцидент находится в завершенном состоянии,
			//
            vValue = xobjIncident.GetPropValue("State", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is Guid)
			{
				DomainObjectData xobjIncidentState = DomainObjectRegistry.Get("IncidentState", (Guid)vValue, con);
				IncidentStateCat incidentStateCat = (IncidentStateCat)xobjIncidentState.GetLoadedPropValue("Category");
                if (incidentStateCat == IncidentStateCat.Finished || incidentStateCat == IncidentStateCat.Declined || incidentStateCat == IncidentStateCat.Frozen)
                {
                    //Если при этом изменяется состояние инцидента,то тогда создавать списание можно
                    if ((xobj.IsNew) && (xobjIncident.HasUpdatedProp("State")))
                    {
                        Guid newStateValue = (Guid) xobjIncident.GetUpdatedPropValue("State");
                        if (newStateValue == (Guid) vValue)
                        {
                            sErrorDescription = "Списание времени на инцидент в состоянии '" + xobjIncidentState.GetLoadedPropValue("Name").ToString() + "' запрещены";
                            return XObjectRights.ReadOnlyRights;
                        }

                    }
                   else
                    {
                        return XObjectRights.ReadOnlyRights;
                    }
                }

			}
			
			// RULE: Сотрудник может редактировать и удалять списания по инцидентам в папках, в которых он обладает привилегией "Управление чужими списаниями".
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.EditIncidentTimeSpent, xobjFolder, con))
				return XObjectRights.FullRights;
		
			// RULE: Сотрудник может создавать, редактировать и удалять списания для своего Задания, если у него не установлен признак "Заморожено"
			vValue = xobjTask.GetPropValue("Worker", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is Guid)
			{
				Guid userID = (Guid)vValue;
				// примечание: для нового объекта Задание признак "Заморожена" смысла не имеет, т.е. считаем, что он незадан
				vValue = xobjTask.GetPropValue("IsFrozen", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
				bool bIsFrozen = false;
				if (vValue is Boolean)
					bIsFrozen = (bool)vValue;
				if (userID == user.EmployeeID && !bIsFrozen)
					return XObjectRights.FullRights;
			}

			return XObjectRights.ReadOnlyRights;
		}
	}

	[SecurityRightsChecker("ProjectParticipant")]
	public class ProjectParticipantRightsChecker: ObjectRightsCheckerBase
	{
		public ProjectParticipantRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			Guid employeeID = (Guid)xobj.GetLoadedPropValueOrLoad(con, "Employee");
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps, true, DomainObjectDataSet.PartialObjectPropLoadStrategies.LoadOnlyRequiredProp);

			// RULE: Создание, редактирование и удаление участников папки доступно пользователям, обладающим привилегией 
			// "Управление проектной командой".
			// Примечание: т.к. это проверка прав на ProjectParticipant, сохраненный в БД, то Папка также сохранена в БД
			if (xobjFolder == null)
			{
				if (hasAllRightsByGlobalPrivileges(user, xobj, con))
					return new XObjectRights(user.EmployeeID != employeeID, new string[] {"Employee"});
				return XObjectRights.ReadOnlyRights;
			}

			// Изменять ссылки на Папки и Сотрудника запрещено
			if (hasAllRightsByFolderPrivileges(user, xobjFolder, con))
				return new XObjectRights(user.EmployeeID != employeeID, new string[] { "Employee" });

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// Проверка прав на новый объект (при сохранении и упреждающая)
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			object vValue = xobj.GetUpdatedPropValue("Employee");
            
            Guid employeeID = (vValue==null)? Guid.Empty:(Guid)vValue;
            
			DomainObjectData xobjFolder;
			// RULE: права на участника проекта для СЕБЯ проверям по наличию прав в РОДИТЕЛЬСКОЙ папке!
			// Примечание: иначе получится, что выдав пользователю привилегию "Управление проектной командой" 
			// мы дадим ему полный контроль - ведь он сможет добавить себе любую привилегию.
			if (employeeID == user.EmployeeID)
			{
				xobjFolder = xobj.Context.Get(con, xobj, "Folder.Parent", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			}
			else
			{
				// иначе права на изменения участника проекта проверяем по наличию привилегий в этом же проекте
				xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
			}

			if (xobjFolder == null)
			{
				// Создание участника в корневой папке
				if (hasAllRightsByGlobalPrivileges(user, xobj, con))
					return XNewObjectRights.FullRights;
				return XNewObjectRights.EmptyRights;
			}
			if (hasAllRightsByFolderPrivileges(user, xobjFolder, con))
				return XNewObjectRights.FullRights;
			return XNewObjectRights.EmptyRights;
		}
        public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
        {
            sErrorDescription = null;
            if (xobj.IsNew)
                return hasInsertObjectRight(user, xobj, con, out sErrorDescription);
            else 
            {
                XObjectRights rights = GetObjectRights(user, xobj, con);
                if (rights.AllowFullChange)
                    return true;
                else if (rights.AllowParticalOrFullChange)
                {
                    // модифицировать можно, но не все свойства (если объект при этом не удаляемый)
                    return !hasObjectChangedReadOnlyProps(xobj, rights, ref sErrorDescription);
                }
            }
            return false;
        }
		private bool hasAllRightsByFolderPrivileges(ITUser user, DomainObjectData xobjFolder, XStorageConnection con)
		{
            if (!xobjFolder.IsNew)
            {
                if ((FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.WaitingToClose ||
					(FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.Frozen ||
                    (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State") == FolderStates.Closed)
                    return false;
            }
			if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.ManageTeam, xobjFolder, con))
				return true;
			return false;
		}

		private bool hasAllRightsByGlobalPrivileges(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			DomainObjectData xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);

			if (xobjFolder == null)
				return false;
            if (!xobjFolder.IsFullyLoaded) xobjFolder.Load(con);
            if (!xobjFolder.IsNew)
            {
                if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose ||
					(FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen ||
                    (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed)
                    return false;
            }
			Guid orgID = (Guid)xobjFolder.GetPropValue("Customer", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
			Guid activityTypeID = (Guid)xobjFolder.GetPropValue("ActivityType", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
			if (user.ManageOrganization(orgID) || user.ManageActivityType(activityTypeID))
				return true;
			return false;
		}
	}

	[SecurityRightsChecker("TimeLoss")]
	public class TimeLossRightsChecker: ObjectRightsCheckerBase
	{
		public TimeLossRightsChecker(SecurityProvider provider): base(provider, true)
		{}

		/// <summary>
		/// Права на существующий объект
		/// </summary>
		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			xobj.Load(con);
			DateTime dtLossFixedDate = DateTime.MinValue;
			object vValue = xobj.GetPropValue("LossFixed", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (vValue is DateTime)
			{
				dtLossFixedDate = (DateTime)vValue;
			}

			// RULE: если списание относится к проекту, то
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.Get(con, "Folder", (Guid)xobj.GetLoadedPropValue("Folder"));
				if (!xobjFolder.HasLoadedProp("State"))
					xobjFolder.Load(con);
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValue("State");
				if (folderState == FolderStates.Closed || folderState == FolderStates.WaitingToClose || folderState == FolderStates.Frozen)
					return XObjectRights.ReadOnlyRights;
				if((bool)xobjFolder.GetLoadedPropValue("IsLocked"))
					return XObjectRights.DeleteOrReadRights;

				if (dtLossFixedDate > DateTime.MinValue)
					if (CommonRightsRules.IsRegDateInBlockPeriod(dtLossFixedDate, xobjFolder))
						return XObjectRights.ReadOnlyRights;
			}
			else
			{
				if (dtLossFixedDate > DateTime.MinValue)
					if (dtLossFixedDate <= ApplicationSettings.GlobalBlockPeriodDate)
						return XObjectRights.ReadOnlyRights;
			}

			// RULE: Сотрудник может редактировать и удалять любое списание, если обладает системной привилегией "Управление чужими списаниями"
			if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
                return new XObjectRights(true, new string[] { "Worker" });

			// RULE: Сотрудник может редактировать списания в папках, в которых у него есть проектная привелегия "Управление чужими списаниями"
			if (xobj.GetLoadedPropValue("Folder") is Guid)
			{
				// Поскольку нас интересуют только существующие привилегии, посмотрим в БД
				XDataSource ds = con.GetDataSource("CheckEmployeesFolderPrivilegesForFolder");
				ds.SubstituteNamedParams(
					new Dictionary<string, object>()
					{
						{ "Employee", user.EmployeeID },
						{ "Folder", xobj.GetLoadedPropValue("Folder") },
						{ "Privileges", (int)FolderPrivileges.EditIncidentTimeSpent }
					}, false);

				if ((int)ds.ExecuteScalar() == 1)
					return XObjectRights.FullRights;
			}

			// RULE: Сотрудник может редактировать и удалять своё списание времени
			Guid workerID = (Guid)xobj.GetPropValue("Worker", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
			if (workerID == user.EmployeeID)
				return new XObjectRights(true, new string[] {"Worker"} );

			return XObjectRights.ReadOnlyRights;
		}

		/// <summary>
		/// Права на новый объект, упреждающая проверка
		/// </summary>
		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (xobj.GetUpdatedPropValue("Folder") is Guid)
			{
				DomainObjectData xobjFolder = xobj.Context.Get(con, "Folder", (Guid)xobj.GetUpdatedPropValue("Folder"));
				// RULE: создавать списание на закрытый проект нельзя никому
				FolderStates folderState = (FolderStates)xobjFolder.GetLoadedPropValueOrLoad(con, "State");
				if (folderState == FolderStates.Closed || folderState == FolderStates.WaitingToClose || folderState == FolderStates.Frozen)
					return XNewObjectRights.EmptyRights;
				// RULE: создавать списание на "заблокированную" папку нельзя никому
				if((bool)xobjFolder.GetLoadedPropValueOrLoad(con, "IsLocked"))
					return XNewObjectRights.EmptyRights;

				if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
					return XNewObjectRights.FullRights;

				// RULE: если списание создается на проект, то пользователь должен обладать в проекте привилегией "Списание времение на проект"
				if (m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.SpentTimeByProject, xobjFolder, con))
					return new XNewObjectRights(true, new string[] {"Worker"} );

				return XNewObjectRights.EmptyRights;
			}
			// RULE: если пользователь не обладает привилегией "Управление чужими списаниями", 
			// то списание он может создавать только для себя, т.к. ссылка на сотрудника в интерфейсе для него недоступна
			// Ссылку на него, мы установим в команде сохранения
			if (!user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
				return new XNewObjectRights(true, new string[] {"Worker"} );

			return XNewObjectRights.FullRights;
		}

		/// <summary>
		/// Проверка объекта при сохранении (как нового, так и измененного)
		/// </summary>
		public override bool HasSaveObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			bool bAllowPotentially = false;
            if (xobj.IsNew)
			{
				// RULE: создавать списание может либо сотрудник для себя, либо сотрудник обладающий привилегией "Управление чужими списаниями"
				if (xobj.GetUpdatedPropValue("Worker") is Guid)
					if (user.EmployeeID == (Guid)xobj.GetUpdatedPropValue("Worker"))
						bAllowPotentially = true;
				if (!bAllowPotentially)
					if (user.HasPrivilege(SystemPrivilegesItem.ManageTimeLoss.Name))
						bAllowPotentially = true;
			}
			else
			{
				if (!base.HasSaveObjectRight(user, xobj, con, out sErrorDescription))
					return false;
				// если здесь, значит списание вообще можно менять,
				// теперь проверим, что новые данные корректны
				bAllowPotentially = true;
			}
			if (bAllowPotentially)
			{
				// получим папку
                
				object vValue = xobj.GetPropValue("Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
				DomainObjectData xobjFolder = null;
				if (vValue is Guid)
				{
                 	xobjFolder = xobj.Context.Get(con, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
					// проверим наличие у папки специального аттрибута, запрещающего списание
					if((bool)xobjFolder.GetPropValue("IsLocked", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps))
					{
						sErrorDescription = "Списания в данную папку запрещены. По вопросам списаний обращайтесь к менеджеру.";
						return false;
					}
					// RULE: если списание создается на проект, то пользователь должен обладать в проекте привилегией "Списание времение на проект"
					if (!m_provider.FolderPrivilegeManager.HasFolderPrivilege(user, FolderPrivileges.SpentTimeByProject, xobjFolder, con))
					{
						sErrorDescription = "Пользователь должен обладать в проекте привилегией \"Списание времени на проект\". По вопросам списаний обращайтесь к менеджеру.";
						return false;
					}
				}
             	// проверим новую дату списания на не попадание в закрытый период (как для нового, так и для измененного объекта)
				if (xobj.GetUpdatedPropValue("LossFixed") is DateTime)
				{
					DateTime dtLossFixedDate = (DateTime)xobj.GetPropValue("LossFixed", DomainObjectDataSetWalkingStrategies.UseOnlyLoadedProps);
					// получим актуальную ссылку на проект (она может меняться прям сейчас)

					if (CommonRightsRules.IsRegDateInBlockPeriod(dtLossFixedDate, xobjFolder))
					{
						sErrorDescription = "Новое значение даты списания попадает в закрытый период";
						return false;
					}
				}
				return true;
			}
			return false;
		}
	}

	#region Проверка прав объектов СУТ
	/// <summary>
	/// Проверка прав на объект Лот
	/// </summary>
	[SecurityRightsChecker("Lot")]
	public class LotRightsChecker: ObjectRightsCheckerBase
	{
		public LotRightsChecker(SecurityProvider provider) : base(provider, true)
		{}

		public override XObjectRights GetObjectRights(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			// RULE: Если у юзера нет привилегии "Доступ к СУТ", то только чтение
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return XObjectRights.ReadOnlyRights;

			// RULE: Пользователь, не обладающий привилегией "Принимающий решение" не может изменять состояние тендера
			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name))
				return new XObjectRights(true, new string[] {"State"});

			return XObjectRights.FullRights;
		}

		public override XNewObjectRights GetRightsOnNewObject(ITUser user, DomainObjectData xobj, XStorageConnection con)
		{
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return XNewObjectRights.EmptyRights;

			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name))
				return new XNewObjectRights(true, new string[] {"State"});

			return XNewObjectRights.FullRights;
		}

		protected override bool hasInsertObjectRight(ITUser user, DomainObjectData xobj, XStorageConnection con, out string sErrorDescription)
		{
			sErrorDescription = null;
			if (!user.HasPrivilege(SystemPrivilegesItem.AccessIntoTMS.Name))
				return false;

			// RULE: если нет привилегии "Принимающий решение в СУТ", то свойство "Состояние" может только иметь значение по умолчанию ("Получение документов")
			if (!user.HasPrivilege(SystemPrivilegesItem.DecidingManInTMS.Name) && xobj.HasUpdatedProp("State"))
			{
				LotState state = (LotState)xobj.GetUpdatedPropValue("State");
				if (state != LotState.DocumentGetting)
					return false;
			}

			return true;
		}

	}

	#endregion
}