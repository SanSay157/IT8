//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

using Croc.IncidentTracker;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ ������� ��������� ��������� ����������
	/// </summary>
	[Serializable]
	public class UpdateActivityStateRequest : XRequest
	{
		public UpdateActivityStateRequest() : base("UpdateActivityState") { }

		/// <summary>
		/// ������������� ����������
		/// </summary>
		public Guid Activity;
		/// <summary>
		/// ����� ���������
		/// </summary>
		public FolderStates NewState;
		/// <summary>
		/// ��������
		/// </summary>
		public string Description;
		/// <summary>
		/// ������������� ����������, ���������� ���������
		/// </summary>
		/// <remarks>
		/// Guid.Empty - �������� �� ������
		/// </remarks>
		public Guid Initiator;
	}
}
