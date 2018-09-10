//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ���������� �������� "�������� ��������" (TimeLoss)
	/// </summary>
	[XRequiredRequestType(typeof(SaveObjectInternalRequest))]
	public class SaveTimeLossObjectCommand: XSaveObjectCommand
	{
		public XResponse Execute( SaveObjectInternalRequest request, IXExecutionContext context ) 
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			ArrayList aObjects = request.DataSet.GetModifiedObjectsByType("TimeLoss", true);
			foreach(DomainObjectData xobj in aObjects)
			{
				if (!xobj.HasUpdatedProp("Worker") && xobj.IsNew)
					xobj.SetUpdatedPropValue("Worker", user.EmployeeID);

				// ������� �����, �������� � ����� ���������� ����� IsLocked
				object vValue = xobj.GetPropValue("Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps);
				DomainObjectData xobjFolder = null;
				if (vValue is Guid)
				{
					xobjFolder = xobj.Context.Get(context.Connection, xobj, "Folder", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps, true);
                    // �������� ��������� �����. ���� ��� ������� ��� � �������� ��������, �� �������� ��������

                    if ((FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Closed
                         || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.WaitingToClose
                         || (FolderStates)xobjFolder.GetLoadedPropValue("State") == FolderStates.Frozen)
                    {
                        throw new XSecurityException("�������� � ����� � ��������� \"�������\" ��� \"�������� ��������\" ���������. �� �������� �������� ����������� � ���������.");
                    }
                    // �������� ������� � ����� ������������ ���������, ������������ ��������
					if ((bool)xobjFolder.GetPropValue("IsLocked", DomainObjectDataSetWalkingStrategies.UseUpdatedPropsThanLoadedProps))
					{
						throw new XSecurityException("<b>�������� � ������ ����� ���������.</b><br/>�� �������� �������� ����������� � ���������.");
					}
					FolderPrivilegeManager manager = (XSecurityManager.Instance.SecurityProvider as SecurityProvider).FolderPrivilegeManager;
					// � ������������ ������ ���� ����� �� �������� � ������ �����
					if (!manager.HasFolderPrivilege(user, FolderPrivileges.SpentTimeByProject, xobjFolder, context.Connection))
					{
						throw new XSecurityException("<b>������������ ������ �������� � ������� ����������� \"�������� �������� �� ������\".</b><br/>�� �������� �������� ����������� � ���������.");
					}

					// ���� � ������������ ��� ���������� ����������� �������� �� ����� � ������������� ������������ ������������
					// �������� - �������� �� ������ ����� ������ � ������������� ������������ �����������
					if (!manager.HasFolderPrivilege(user, FolderPrivileges.TimeLossOnUnspecifiedDirection, xobjFolder, context.Connection))
					{
						using( XDbCommand c = context.Connection.CreateCommand() )
						{
							c.CommandType = CommandType.Text;
							c.CommandText = @"
IF	(
		SELECT t.AccountRelated 
		FROM dbo.ActivityType t WITH(NOLOCK) JOIN dbo.Folder fT WITH(NOLOCK) ON fT.ActivityType = t.ObjectID 
		WHERE fT.ObjectID = @FolderID
	) = 0
	SELECT 1
ELSE
	SELECT TOP 1 t.DirsQnt
	FROM (
		SELECT
			fU.ObjectID, fU.LRLevel,
			( SELECT COUNT(*) FROM dbo.FolderDirection fd WITH(NOLOCK) WHERE fd.Folder = fU.ObjectID ) AS DirsQnt
		FROM
			dbo.Folder fT WITH(NOLOCK)
			JOIN dbo.Folder fU WITH(NOLOCK) ON fU.Customer = fT.Customer AND fU.LIndex <= fT.LIndex AND fU.RIndex >= fT.RIndex
		WHERE
			fT.ObjectID = @FolderID
	) t
	WHERE DirsQnt > 0		
	ORDER BY LRLevel DESC 
";
							c.Parameters.Add( "FolderID", DbType.Guid, ParameterDirection.Input, false, vValue );
							
							object oResult = c.ExecuteScalar();
							string sReport = null;
							
							if ( null == oResult || DBNull.Value == oResult )
							    sReport = "��� ������� �� ���������� �� ������ �����������";
							else if ( 1 != (int)oResult )
								sReport = "��� ������� ���������� ����� ������ �����������";
							
							if ( null != sReport )
								throw new XSecurityException(
									"<b>�������� � ������ ����� ���������.</b><br/>" +
									"� ��� ��� ���� ��������� � �����, " + sReport + ". " +
									"�� �������� �������� <b>����������� � ���������</b>.");
						}
					}
				}


				// ���� � ������� ������ "�����������" ��������
				if (xobj.HasUpdatedProp("LossFixedStart") && xobj.GetUpdatedPropValue("LossFixedStart") is DateTime && 
					xobj.HasUpdatedProp("LossFixedEnd") && xobj.GetUpdatedPropValue("LossFixedEnd") is DateTime )
				{
					if (!xobj.IsNew)
						throw new ApplicationException("������� ��������� ��������� ������ ��� �������� ������� \"�������� �������\"");
					// ������� ���� ������ � ��������� �������
					DateTime dtPeriodStart = (DateTime)xobj.GetUpdatedPropValue("LossFixedStart");
					DateTime dtPeriodEnd = (DateTime)xobj.GetUpdatedPropValue("LossFixedEnd");
					if (dtPeriodStart > dtPeriodEnd)
					{
						DateTime dtTemp = dtPeriodEnd;
						dtPeriodEnd = dtPeriodStart;
						dtPeriodStart = dtTemp;
					}

					Guid employeeID = (Guid)xobj.GetUpdatedPropValue("Worker");
					// ��������, ��� � ������ ������� ����������� ��������
					XDbCommand cmd = context.Connection.CreateCommand("");
					cmd.CommandText = @"SELECT DISTINCT CONVERT(varchar, x.SpentDate, 104) FROM (
						SELECT ts.RegDate AS SpentDate
						FROM TimeSpent ts
							JOIN Task t ON ts.Task = t.ObjectID
						WHERE t.Worker = @EmployeeID 
							AND ts.RegDate >= @dtPeriodStart AND ts.RegDate < @dtPeriodEnd
						UNION
						SELECT ts.LossFixed AS SpentDate
						FROM TimeLoss ts WHERE ts.Worker = @EmployeeID
							AND ts.LossFixed >= @dtPeriodStart AND ts.LossFixed < @dtPeriodEnd
						) x";
					cmd.Parameters.Add("EmployeeID", DbType.Guid, ParameterDirection.Input, false, employeeID);
					cmd.Parameters.Add("dtPeriodStart", DbType.Date, ParameterDirection.Input, false, dtPeriodStart);
					// AddDays(1) - �.�. � ������� ������� ���� "������"
					cmd.Parameters.Add("dtPeriodEnd", DbType.Date, ParameterDirection.Input, false, dtPeriodEnd.AddDays(1));
					using (IDataReader reader = cmd.ExecuteReader())
					{
						if (reader.Read())
						{
							StringBuilder bld = new StringBuilder();
							do
							{
								if (bld.Length > 0)
									bld.Append(", ");
								bld.Append(reader.GetString(0));
							} while(reader.Read());
							throw new XBusinessLogicException(
								String.Format("� ��� ��� ������� �������� �� ��������� ���� � �������� ������� ({0},{1}): {2}", 
									dtPeriodStart.ToShortDateString(), 
									dtPeriodEnd.ToShortDateString(),
									bld.ToString())
								);
						}
					}
                    // �������� "����� ���" ���� - ����� ���������� �� ���� 
					Dictionary<DateTime, int> dictDateRates = new Dictionary<DateTime, int>();
                    dictDateRates = GetDayRates(context.Connection, dtPeriodStart, dtPeriodEnd, employeeID);
					// ������ �� ���� ���� ������� (dtPeriodEnd, dtPeriodStart)
					// � ��� ������ ���� �������� ����� ������ �������� ������� � ����������� ������� ������ �������� ���
					// ��� ����, ����� ������������ ����, ���������� �� ��������/���������
					TimeSpan period = (dtPeriodEnd - dtPeriodStart);
                   	for(int nOffSet=0;nOffSet <= period.TotalDays; ++nOffSet)
					{
                        int nRate = 0;
                       	DateTime dtDate = dtPeriodStart.AddDays(nOffSet);
                        // ���� ������� �������� ����� ���������� �� �����. ����, �� �������� ������
                        if (dictDateRates.TryGetValue(dtDate, out nRate))
                        {
                            // ���� ���������� ����� ������ 0, ����� �������� ��������
                            if (nRate > 0)
                            {
                                DomainObjectData xobjNew = createTimeLossObject(request.DataSet, xobj, user);
                                xobjNew.SetUpdatedPropValue("LossFixed", dtDate);
                                // �������� ������ � ���������� ����� � ������� ���
                                xobjNew.SetUpdatedPropValue("LostTime", nRate);
                            }
                        }
					
					}
					// �������� ������ ���� �������
					request.DataSet.Remove(xobj);
				}
            }
           	
            XSecurityManager sec_man = XSecurityManager.Instance;
            IEnumerator enumerator = request.DataSet.GetModifiedObjectsEnumerator(false);
            DomainObjectData xobject;
            while (enumerator.MoveNext())
            {
                xobject = (DomainObjectData)enumerator.Current;
                if (xobject.ToDelete)
                    sec_man.DemandDeleteObjectPrivilege(xobject);
                else
                    sec_man.DemandSaveObjectPrivilege(xobject);
            }
            // #1: ������ ������
			XStorageGateway.Save(context, request.DataSet, request.TransactionID);
			// ������������ ���������� �������� �� ����������
			return new XResponse();
		}
		
		/// <summary>
		/// ������� ������ "�������� ��������" �� ��������� �������
		/// </summary>
		private DomainObjectData createTimeLossObject(DomainObjectDataSet dataSet, DomainObjectData template, ITUser user)
		{
			DomainObjectData xobj = dataSet.CreateStubNew("TimeLoss");
			xobj.SetUpdatedPropValue("Cause", template.GetUpdatedPropValue("Cause"));
			if (template.HasUpdatedProp("Worker"))
				xobj.SetUpdatedPropValue("Worker", template.GetUpdatedPropValue("Worker"));
			else
				xobj.SetUpdatedPropValue("Worker", user.EmployeeID);
			if (template.HasUpdatedProp("Folder"))
				xobj.SetUpdatedPropValue("Folder", template.GetUpdatedPropValue("Folder"));
			return xobj;
		}
	    /// <summary>
        /// ���������� ��������� ������ � �������� ���� : "����","����� ���������� �� ����"
        /// </summary>
        /// <param name="con"></param>
        /// <param name="dtStart">���� ������ �������</param>
        /// <param name="dtEnd">���� ��������� �������</param>
        /// <param name="dtEnd">������������� ����������</param>
        private Dictionary<DateTime, int> GetDayRates(XStorageConnection con, DateTime dtStart, DateTime dtEnd, Guid uidUserId)
        {
            if (dtStart > dtEnd)
				throw new ArgumentException("���� ������ ������� ������ ���� ������ ���� ��������� �������");

			XDbCommand cmd = con.CreateCommand(
				"SELECT CalendarDate, Rate FROM  dbo.GetEmployeeCalendar(@dtStart,@dtEnd,@EmpID) as empCal");
			cmd.Parameters.Add("dtStart", DbType.Date, ParameterDirection.Input, false, dtStart);
			cmd.Parameters.Add("dtEnd", DbType.Date, ParameterDirection.Input, false, dtEnd);
            cmd.Parameters.Add("EmpID", DbType.Guid, ParameterDirection.Input, false, uidUserId);
            Dictionary<DateTime,int> dictDateRates = new Dictionary<DateTime,int>(); 
            using(IXDataReader reader = cmd.ExecuteXReader())
			{
				while(reader.Read())
				{
                    DateTime dt = reader.GetDateTime(reader.GetOrdinal("CalendarDate"));
                    int nDateRate = reader.GetInt16(reader.GetOrdinal("Rate"));
                    dictDateRates.Add(dt, nDateRate);
				}
			}
            return dictDateRates;
        }
	}
}
