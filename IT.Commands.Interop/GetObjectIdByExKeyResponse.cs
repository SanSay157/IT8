//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Результат выполнения операции получения идентификатора ds-объекта, 
	/// заданного значениями своих реквизитов
	/// <seealso cref="GetObjectIdByExKeyRequest"/>
	/// </summary>
	[Serializable]
	public class GetObjectIdByExKeyResponse : XResponse 
	{
		/// <summary>
		/// Результирующее значение - идентификатор ds-объекта
		/// </summary>
		private Guid m_uidObjectID = Guid.Empty;

		/// <summary>
		/// Результирующее значение - идентификатор ds-объекта
		/// Если объект не найден, значений свойства устанавливается в Guid.Empty
		/// </summary>
		public Guid ObjectID 
		{
			get { return m_uidObjectID; }
			set { m_uidObjectID = value; }
		}

		
		/// <summary>
		/// Конструктор по умолчанию, для корректной (де)сериализации
		/// </summary>
		public GetObjectIdByExKeyResponse() 
		{}
		
		
		/// <summary>
		/// Параметризированный конструктор
		/// </summary>
		/// <param name="uidObjectID">Результирующее значение</param>
		public GetObjectIdByExKeyResponse( Guid uidObjectID ) 
		{
			ObjectID = uidObjectID;
		}
	}
}