//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Data;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Commands.Trees
{
	/// <summary>
	/// ������, ����������� ���� � ������ "������� � �������" �� ��������� ��������
	/// </summary>
	public class DKPTreeObjectLocator
	{
		/// <summary>
		/// ������������ ����� ����� � ������.
		/// ����������: ���� ��� �������� ����� � ��� �� �����, �� ����������� � ������ ������ ������, ����� ����� ������ ����,
		///		�.�. ��� ������� �� ������ ������������� ���� ���� ������/
		/// </summary>
		public const string TYPE_Organization = "Organization";
		public const string TYPE_HomeOrganization = "HomeOrganization";
		public const string TYPE_ActivityType = "ActivityType";
		public const string TYPE_ActivityTypeInternalUnderHomeOrg = "ActivityTypeInternal";
		public const string TYPE_ActivityTypeExternalUnderHomeOrg = "ActivityTypeExternal";
		public const string TYPE_Folder = "Folder";
		public const string TYPE_Incident = "Incident";
        public const string TYPE_Contract = "Contract";

		/// <summary>
		/// ���������� ������ ���� �� ���������, ��������� ���������������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="IncidentOID">������������� ��������� ��� Guid.Empty</param>
		/// <returns></returns>
		public XTreePath GetIncidentFullPath(XStorageConnection con, Guid IncidentOID)
		{
			return GetIncidentFullPath(con, -1, IncidentOID);
		}

		/// <summary>
		/// ���������� ������ ���� �� ���������, ��������� �������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="IncidentNumber">����� ���������</param>
		/// <returns></returns>
		public XTreePath GetIncidentFullPath(XStorageConnection con, Int32 IncidentNumber)
		{
			return GetIncidentFullPath(con, IncidentNumber, Guid.Empty);
		}

		/// <summary>
		/// ���������� ������ ���� �� ���������, ��������� ���������������, ���� �������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="IncidentNumber">����� ���������</param>
		/// <param name="IncidentOID">������������� ��������� ��� Guid.Empty</param>
		/// <returns></returns>
		private XTreePath GetIncidentFullPath(XStorageConnection con, Int32 IncidentNumber, Guid IncidentOID)
		{
			Guid organizationID = Guid.Empty;		// ������������� �����������, � ������� ���������� ��������
			Guid activityTypeID = Guid.Empty;		// ������������� ���� ����������,�� ������� ��������� �����, � ������� ���������� ��������

			// ��������� ���� �� ���������
			string sQuery = String.Format(
                @"SELECT i.ObjectID AS IncidentID, f.ObjectID, f_s.Customer, f_s.ActivityType
				FROM Incident i with (nolock)
					JOIN Folder f_s with (nolock) ON i.Folder = f_s.ObjectID
						JOIN Folder f with (nolock) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer
				WHERE {0}
				ORDER BY f.LRLevel DESC", 
				IncidentOID == Guid.Empty ? 
					"i.Number = @Number" : 
					"i.ObjectID = @ObjectID"
				);
			XDbCommand cmd = con.CreateCommand(sQuery);
			if (IncidentOID == Guid.Empty)
				cmd.Parameters.Add("Number", DbType.Int32, ParameterDirection.Input, false, IncidentNumber);
			else
				cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, IncidentOID);

			XTreePath path = new XTreePath();	// ����
			using(IDataReader reader = cmd.ExecuteReader())
			{
				int nObjectIDIndex = -1;			// ������ ���� ObjectID
				while (reader.Read())
				{
					if (nObjectIDIndex < 0)
					{
						// ������ ��������
						IncidentOID		= reader.GetGuid( reader.GetOrdinal("IncidentID") );
						organizationID = reader.GetGuid( reader.GetOrdinal("Customer") );
						activityTypeID  = reader.GetGuid( reader.GetOrdinal("ActivityType"));
						nObjectIDIndex	= reader.GetOrdinal("ObjectID");
					}
					path.Append(TYPE_Folder, reader.GetGuid(nObjectIDIndex));
				}
			}
			if (path.Length > 0)
			{
				path.Append(GetPathToFolder(con, organizationID, activityTypeID));
				path.InsertAtBeginning(TYPE_Incident, IncidentOID);
			}
			
			return path;
		}


        /// <summary>
        /// ���������� ������ ���� �� ���������� �������, ��������� ���������������
        /// </summary>
        /// <param name="con"></param>
        /// <param name="ContractOID">������������� ���������� ������� ��� Guid.Empty</param>
        /// <returns></returns>
        public XTreePath GetContractFullPath(XStorageConnection con, Guid ContractOID)
        {
            return GetContractFullPath(con, string.Empty, ContractOID);
        }

        /// <summary>
        /// ���������� ������ ���� �� ���������� �������, ��������� ����� �������
        /// </summary>
        /// <param name="con"></param>
        /// <param name="ExternalID">��� �������</param>
        /// <returns></returns>
        public XTreePath GetContractFullPath(XStorageConnection con, string ExternalID)
        {
            return GetContractFullPath(con, ExternalID, Guid.Empty);
        }

        /// <summary>
        /// ���������� ������ ���� � ��������, ��������� ���������������, ���� ����� �������
        /// </summary>
        /// <param name="con"></param>
        /// <param name="ExternalID">��� �������</param>
        /// <param name="ContractID">������������� ���������� �������� ��� Guid.Empty</param>
        /// <returns></returns>
        private XTreePath GetContractFullPath(XStorageConnection con, string ExternalID, Guid ContractID)
        {
            Guid organizationID = Guid.Empty;		// ������������� �����������, � ������� ���������� ��������
            Guid activityTypeID = Guid.Empty;		// ������������� ���� ����������,�� ������� ��������� �����, � ������� ���������� ��������

            // ��������� ���� �� ���������
            string sQuery = String.Format(
                @"SELECT c.ObjectID AS ContractID, f.ObjectID, f_s.Customer, f_s.ActivityType
				FROM Contract c with (nolock)
					JOIN Folder f_s with (nolock) ON c.Project = f_s.ObjectID
						JOIN Folder f with (nolock) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer
				WHERE {0}
				ORDER BY f.LRLevel DESC",
                ContractID == Guid.Empty ?
                    "f.ExternalID = @ExternalID" :
                    "c.ObjectID = @ObjectID"
                );
            XDbCommand cmd = con.CreateCommand(sQuery);
            if (ContractID == Guid.Empty)
                cmd.Parameters.Add("ExternalID", DbType.String, ParameterDirection.Input, false, ExternalID);
            else
                cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, ContractID);

            XTreePath path = new XTreePath();	// ����
            using (IDataReader reader = cmd.ExecuteReader())
            {
                int nObjectIDIndex = -1;			// ������ ���� ObjectID
                while (reader.Read())
                {
                    if (nObjectIDIndex < 0)
                    {
                        // ������ ��������
                        ContractID = reader.GetGuid(reader.GetOrdinal("ContractID"));
                        organizationID = reader.GetGuid(reader.GetOrdinal("Customer"));
                        activityTypeID = reader.GetGuid(reader.GetOrdinal("ActivityType"));
                        nObjectIDIndex = reader.GetOrdinal("ObjectID");
                    }
                    path.Append(TYPE_Folder, reader.GetGuid(nObjectIDIndex));
                }
            }
            if (path.Length > 0)
            {
                path.Append(GetPathToFolder(con, organizationID, activityTypeID));
                path.InsertAtBeginning(TYPE_Contract, ContractID);
            }

            return path;
        }

		/// <summary>
		/// ���������� ������ ���� �� �����: Folder|oid|..|Folder|{oid}|ActivitType|{oid}|Organization|{oid}
		/// </summary>
		/// <param name="con"></param>
		/// <param name="FolderOID"></param>
		/// <returns></returns>
		public XTreePath GetFolderFullPath(XStorageConnection con, Guid FolderOID)
		{
			// ��������� ���� �� ���������
			XDbCommand cmd = con.CreateCommand(@"
				SELECT f.ObjectID, f.Customer, f_s.ActivityType
				FROM Folder f_s with (nolock)
						JOIN Folder f with (nolock) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer
				WHERE f_s.ObjectID = @ObjectID
				ORDER BY f.LRLevel DESC"
                );
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, FolderOID);
			XTreePath path = new XTreePath();		// ����
			Guid organizationID = Guid.Empty;		// ������������� �����������, � ������� ���������� ��������
			Guid activityTypeID = Guid.Empty;		// ������������� ���� ����������,�� ������� ��������� �����, � ������� ���������� ��������
			using(IDataReader reader = cmd.ExecuteReader())
			{
				int nObjectIDIndex = -1;			// ������ ���� ObjectID
				while (reader.Read())
				{
					if (nObjectIDIndex < 0)
					{
						organizationID = reader.GetGuid( reader.GetOrdinal("Customer") );
						activityTypeID  = reader.GetGuid( reader.GetOrdinal("ActivityType"));
						nObjectIDIndex	= reader.GetOrdinal("ObjectID");
					}
					path.Append(TYPE_Folder, reader.GetGuid(nObjectIDIndex));
				}
			}
			// ���������� ���� �� ����������� � ����� ��������� ������
			if (path.Length > 0)
			{
				XTreePath pathToFolder = GetPathToFolder(con, organizationID, activityTypeID);
				path.Append(pathToFolder);
			}
			return path;
		}

        /// <summary>
        /// ���������� ������ ���� � �������: Folder|oid|..|Folder|{oid}|ActivitType|{oid}|Organization|{oid}
        /// </summary>
        /// <param name="con"></param>
        /// <param name="FolderExID">��� �������</param>
        /// <returns></returns>
        public XTreePath GetFolderFullPath(XStorageConnection con, string FolderExID)
        {
            // ��������� ���� �� ���������
            XDbCommand cmd = con.CreateCommand(@"
				SELECT f.ObjectID, f.Customer, f_s.ActivityType
				FROM Folder f_s with (nolock)
						JOIN Folder f with (nolock) ON f.LIndex <= f_s.LIndex AND f.RIndex >= f_s.RIndex AND f.Customer = f_s.Customer
				WHERE f_s.ExternalID = @FolderExID
				ORDER BY f.LRLevel DESC"
                );
            cmd.Parameters.Add("FolderExID", DbType.String, ParameterDirection.Input, false, FolderExID);
            XTreePath path = new XTreePath();		// ����
            Guid organizationID = Guid.Empty;		// ������������� �����������, � ������� ���������� ��������
            Guid activityTypeID = Guid.Empty;		// ������������� ���� ����������,�� ������� ��������� �����, � ������� ���������� ��������
            using (IDataReader reader = cmd.ExecuteReader())
            {
                int nObjectIDIndex = -1;			// ������ ���� ObjectID
                while (reader.Read())
                {
                    if (nObjectIDIndex < 0)
                    {
                        organizationID = reader.GetGuid(reader.GetOrdinal("Customer"));
                        activityTypeID = reader.GetGuid(reader.GetOrdinal("ActivityType"));
                        nObjectIDIndex = reader.GetOrdinal("ObjectID");
                    }
                    path.Append(TYPE_Folder, reader.GetGuid(nObjectIDIndex));
                }
            }
            // ���������� ���� �� ����������� � ����� ��������� ������
            if (path.Length > 0)
            {
                XTreePath pathToFolder = GetPathToFolder(con, organizationID, activityTypeID);
                path.Append(pathToFolder);
            }
            return path;
        }

		/// <summary>
		/// ���������� ���� �� ����� ��������� ������ � �����������
		/// </summary>
		/// <param name="con"></param>
		/// <param name="organizationID"></param>
		/// <param name="activityTypeID"></param>
		/// <returns></returns>
		public XTreePath GetPathToFolder(XStorageConnection con, Guid organizationID, Guid activityTypeID)
		{
			XTreePath path = new XTreePath();		// ����
			XDbCommand cmd;
			bool bIsHome = false;					// ������� �����������-���������

			// ���������� ���� �� �����������
			// ����������: ������ ��� ����� ������������ ���� �� ����� ��������� ������ �� ����, ����� ������� ������� "������" �����������
			cmd = con.CreateCommand(@"
				SELECT o.ObjectID, o.Home
				FROM Organization o with (nolock)
					JOIN Organization o_s with (nolock) ON o.LIndex <= o_s.LIndex AND o.RIndex >= o_s.RIndex
				WHERE o_s.ObjectID = @ObjectID
				ORDER BY o.LRLevel DESC"
                );
			cmd.Parameters.Add("ObjectID", DbType.Guid, ParameterDirection.Input, false, organizationID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				int nObjectIDIndex = -1;
				while (reader.Read())
				{
					if (nObjectIDIndex < 0)
					{
						bIsHome = reader.GetBoolean( reader.GetOrdinal("Home") );
						nObjectIDIndex = reader.GetOrdinal("ObjectID");
					}
					if (bIsHome)
						path.Append(TYPE_HomeOrganization, reader.GetGuid(nObjectIDIndex));
					else
						path.Append(TYPE_Organization, reader.GetGuid(nObjectIDIndex));
				}
			}


			// ���������� ���� �� ����� �����������
			// ����������: ���������� ���������� �� ����������� �������, �.�. ���� ����� ��������� � ������ ���� 
			//				(�.�. � �������� ������������������ ������������ �����������)
			cmd = con.CreateCommand(@"
				SELECT at.ObjectID
				FROM ActivityType at_s with (nolock)
					JOIN ActivityType at with (nolock) ON at.LIndex <= at_s.LIndex AND at.RIndex >= at_s.RIndex
				WHERE at_s.ObjectID = @ActivityTypeID
				ORDER BY at.LRLevel"
                );
			cmd.Parameters.Add("ActivityTypeID", DbType.Guid, ParameterDirection.Input, false, activityTypeID);
			using(IDataReader reader = cmd.ExecuteReader())
			{
				while (reader.Read())
				{
					if (bIsHome)
						path.InsertAtBeginning(TYPE_ActivityTypeInternalUnderHomeOrg, reader.GetGuid(0));
					else
						path.InsertAtBeginning(TYPE_ActivityType, reader.GetGuid(0));
				}
			}
				
			return path;
		}
	}
}
