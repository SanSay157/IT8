//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ��������� ���������� �������� ��������� �������������� ds-�������, 
	/// ��������� ���������� ����� ����������
	/// <seealso cref="GetObjectIdByExKeyRequest"/>
	/// </summary>
	[Serializable]
	public class GetObjectIdByExKeyResponse : XResponse 
	{
		/// <summary>
		/// �������������� �������� - ������������� ds-�������
		/// </summary>
		private Guid m_uidObjectID = Guid.Empty;

		/// <summary>
		/// �������������� �������� - ������������� ds-�������
		/// ���� ������ �� ������, �������� �������� ��������������� � Guid.Empty
		/// </summary>
		public Guid ObjectID 
		{
			get { return m_uidObjectID; }
			set { m_uidObjectID = value; }
		}

		
		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public GetObjectIdByExKeyResponse() 
		{}
		
		
		/// <summary>
		/// ������������������� �����������
		/// </summary>
		/// <param name="uidObjectID">�������������� ��������</param>
		public GetObjectIdByExKeyResponse( Guid uidObjectID ) 
		{
			ObjectID = uidObjectID;
		}
	}
}