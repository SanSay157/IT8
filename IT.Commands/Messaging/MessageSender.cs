namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// �����, ����������� �������� ���������.
	/// </summary>
	public abstract class MessageSender
	{
		/// <summary>
		/// �������� ������ ���������
		/// </summary>
		/// <param name="messages">����� ���������, ���������� ��������</param>
		public abstract void Send(EventNotificationMessage[] messages);
	}
}
