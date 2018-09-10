namespace Croc.IncidentTracker.Messaging
{
	/// <summary>
	/// Класс, выполняющий доставку сообщений.
	/// </summary>
	public abstract class MessageSender
	{
		/// <summary>
		/// Отправка набора сообщений
		/// </summary>
		/// <param name="messages">Набор сообщений, подлежащий отправке</param>
		public abstract void Send(EventNotificationMessage[] messages);
	}
}
