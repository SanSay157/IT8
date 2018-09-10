//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ����� ������ ��� ������ FolderLocatorInTreeCommand � IncidentLocatorInTreeCommand
	/// </summary>
	[Serializable]
	public class DKPLocatorResponse: XResponse
	{
		/// <summary>
		/// ������ ���� � ������ "������� � �������" �� ��������� ������� � ������� ActiveX CROC.IXTreeView
		/// </summary>
		public string Path;
		/// <summary>
		/// ������������� �������� ������� (�������, ���� ����� ������������ �� �� ��������������)
		/// </summary>
		public Guid ObjectID;
	}
}