using System;
using Croc.IncidentTracker.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// Summary description for StorageConnection.
	/// </summary>
	public class StorageConnection: XStorageConnectionMsSql
	{
		/// <summary>
		/// ������� "��� �������� ���������� ��������� �� ��������� ������� ������������� ������������"
		/// </summary>
		private bool m_bTrackUserLogin = false;

		/// <summary>
		/// ���������� ������� "��� �������� ���������� ��������� �� ��������� ������� ������������� ������������"
		/// </summary>
		public bool TrackUserLogin
		{
			get { return m_bTrackUserLogin; }
		}

		/// <summary>
		/// ��������� ���������� �� ����� ������������
		/// </summary>
		/// <param name="sParamName"></param>
		/// <param name="sValue"></param>
		/// <returns></returns>
		public override bool SetParameter(string sParamName, string sValue)
		{
			if (sParamName == "XS_TrackUserLogin")
			{
				m_bTrackUserLogin = (sValue == "1");
				return true;
			}
			else
				return base.SetParameter(sParamName, sValue);
		}

		/// <summary>
		/// ���������������� ����� �������� ����������. 
		/// ���� ����� ���� TrackUserLogin, �� �� �������� ������� #UserLogin ����������� ������ 
		/// � ����������� � ������� ������������ ����������
		/// </summary>
		public override void Open()
		{
			base.Open();
			if (TrackUserLogin)
			{
				string sUserName = XSecurityManager.Instance.CurrentUserName;
				// ��������: ����� ������ �������:
				// (ITUser)XSecurityManager.Instance.GetCurrentUser();
				// �.�. ��� �������� � �������� � ���������� ���� ����������� � ����!, ��� 
				// GetCurrentUser �������� � ���� ������ � �� ����� ������ ��������� StorageConnection
				ITUser user = (ITUser)XSecurityManager.Instance.Users[sUserName];
				if (user != null)
				{
					// ��������! ������ � ������, ���� XSecurityManager ��� �������� �������� �������� ������������, ��
					// ������� ��� ��������, �.�. ������ � ���� ������ �� ���������� ������ � �� � ����������� �������� ����������
					CreateCommand(
						String.Format(
							"SELECT '{0}' AS EmployeeID, '{1}' AS SystemUserID, '{2}' AS Login INTO #UserLogin",
							user.EmployeeID,
							user.SystemUserID,
							user.Name
							)
						).ExecuteNonQuery();
				}
			}
		}
	}
}
