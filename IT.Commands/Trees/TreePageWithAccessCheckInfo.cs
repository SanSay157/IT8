//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using Croc.IncidentTracker.Commands;
using Croc.IncidentTracker.Hierarchy;

namespace Croc.IncidentTracker.Trees
{
	/// <summary>
	/// �������� �������� �������� � ������������ �������
	/// </summary>
	public class TreePageWithAccessCheckInfo : XTreePageInfoStd
	{
		protected InterfaceSecurityAceessContainer m_security = new InterfaceSecurityAceessContainer();
		
		public InterfaceSecurityAceessContainer AccessSecurity
		{
			get { return m_security; }
		}
	}
}
