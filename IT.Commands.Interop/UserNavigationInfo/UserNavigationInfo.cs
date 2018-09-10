//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections.Specialized;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������, ����������� ��� ���������� ������������� ������, ���������������
	/// ������� ���������� ������������
	/// </summary>
	[Serializable]
	public class UserNavigationInfo 
	{
		/// <summary>
		/// ����������� ������, ����� ���� ������������ � �������� ����� 
		/// ��� ���������� UserNavigationInfo � ��������� ���������� ������
		/// </summary>
		public const string CURRENT_NAVIGATION_INFO = "CURRENT_NAVIGATION_INFO";
		
		#region ���������� ���������� � ������ 

		/// <summary>
		/// ������� ������������� "�����������" ��������� �������� (�������
		/// �� "��������") - ��� ������ ������ ������� �������� ��������������
		/// redirect �� �������� �������� (����� ������ - ���������� ��������
		/// � m_enOwnStartPage)
		/// </summary>
		protected bool m_bUseOwnStartPage = false;
		/// <summary>
		/// �������� "�����������" ��������� ��������
		/// </summary>
		protected StartPages m_enOwnStartPage;
		/// <summary>
		/// ��������� ������������� ���������, ��������� �������� ������������
		/// ���� - ������������� �������� (��. NavigationItem.ItemID), �������� 
		/// URL �������� / ��������, ����������� � ������� �������������� 
		/// �������� (�.�. ����� ��� String.Empty - � ���� ������ ������������
		/// URL, �������� � NavigationItem)
		/// </summary>
		protected NameValueCollection m_UsedNavigationItems = null;
		/// <summary>
		/// ������� ����������� ������ � ������� �� �������� ������������
		/// </summary>
		protected bool m_bDoShowExpensesPanel = false;
		/// <summary>
		/// ������ �������������� ������ � ������ ����������� ������
		/// �������� 0 ��������� �� ��, ��� �������������� ���������
		/// </summary>
		protected int m_nExpensesPanelAutoUpdateDelay = 0;

		#endregion

		/// <summary>
		/// ����������� �� ���������
		/// ��������� ��� ���������� XML-��-������������
		/// </summary>
		public UserNavigationInfo() 
		{
			m_bUseOwnStartPage = false;
			m_UsedNavigationItems = new NameValueCollection();
			m_bDoShowExpensesPanel  = true;
			m_nExpensesPanelAutoUpdateDelay = 0;
		}

		
		/// <summary>
		/// ��������� ������������� ���������, ��������� �������� ������������
		/// ���� - ������������� �������� (��. NavigationItem.ItemID), �������� 
		/// URL �������� / ��������, ����������� � ������� �������������� 
		/// �������� (�.�. ����� ��� String.Empty - � ���� ������ ������������
		/// URL, �������� � NavigationItem)
		/// </summary>
		public NameValueCollection UsedNavigationItems 
		{
			get { return m_UsedNavigationItems; } 
			set
			{
				if (null==value)
					throw new ArgumentNullException("UsedNavigationItems", "��������� ��������������� ��������� ������������� ��������� �� ����� ���� ������ � null");
				m_UsedNavigationItems = value;
			}
		}
	
	
		/// <summary>
		/// ������� ������������� "�����������" ��������� �������� (�������
		/// �� "��������") - ��� ������ ������ ������� �������� ��������������
		/// redirect �� �������� �������� (����� ������ - ���������� ��������
		/// � OwnStartPage)
		/// </summary>
		public bool UseOwnStartPage 
		{
			get { return m_bUseOwnStartPage; }
			set { m_bUseOwnStartPage = value; }
		}

		
		/// <summary>
		/// �������� "�����������" ��������� ��������
		/// </summary>
		public StartPages OwnStartPage 
		{
			get { return m_enOwnStartPage; }
			set { m_enOwnStartPage = value; } // TODO: ���� �� ��������� ����������� ��������� ��������
		}

	
		/// <summary>
		/// ������� ����������� ������ � ������� �� �������� ������������
		/// </summary>
		public bool ShowExpensesPanel 
		{
			get { return m_bDoShowExpensesPanel; }
			set { m_bDoShowExpensesPanel = value; }
		}

		
		/// <summary>
		/// ������ �������������� ������ � ������ ����������� ������
		/// �������� 0 ��������� �� ��, ��� �������������� ���������
		/// </summary>
		public int ExpensesPanelAutoUpdateDelay 
		{
			get { return m_nExpensesPanelAutoUpdateDelay; }
			set { m_nExpensesPanelAutoUpdateDelay = value; }
		}


		/// <summary>
		/// ��������� ����� ��������� ���������������� �������������� �������������� 
		/// �������� ��� ��������� �������� ���� StartPages
		/// </summary>
		/// <param name="enStartPage"></param>
		/// <returns></returns>
		public static string StartPage2NavItemID( StartPages enStartPage ) 
		{
			string sOwnStartPageID = null;
			switch (enStartPage)
			{
				// "��� ���������" (������� ������)
				case StartPages.CurrentTaskList:
					sOwnStartPageID = NavigationItemIDs.IT_CurrentTasks; 
					break;
				// �������� "������� � �������"
				case StartPages.DKP:
					sOwnStartPageID = NavigationItemIDs.IT_CustomerActivityTree; 
					break;
				// �������� �������
				case StartPages.Reports:
					sOwnStartPageID = NavigationItemIDs.IT_Reports; 
					break;
				// ��������� �������� ������� ����� �������� (���)
				case StartPages.TMS:
					sOwnStartPageID = NavigationItemIDs.TMS_HomePage; 
					break;
				// ������ �������� (� ���)
				case StartPages.TenderList:
					sOwnStartPageID = NavigationItemIDs.TMS_TenderList; 
					break;
				default:
					sOwnStartPageID = null; 
					break;
			}
			return sOwnStartPageID;
		}

	}
}