//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������� ��� ������� FolderLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class FolderLocatorInTreeRequest: XRequest
	{
		/// <summary>
		/// ������������� ������� �����
		/// </summary>
		public Guid FolderOID;

        /// <summary>
        /// ��� �������
        /// </summary>
        public string FolderExID;

		public FolderLocatorInTreeRequest()
			: base("FolderLocatorInTree")
		{}
	}
}
