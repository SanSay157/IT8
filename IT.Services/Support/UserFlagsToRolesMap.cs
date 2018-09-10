//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections.Specialized;
using System.Xml;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// Служебный объект - описатель связи м/у флагом, задаваемым для пользователя
	/// в системе НСИ и соответствующей ссылкой на системную роль с Incident Tracker.
	/// Все связи представлены объектом типа UserFlagToRolesMap.
	/// Данные в описатель загружаются на основании данных, заданных в прикладном 
	/// конфигурационном файле сервисов. 
	/// </summary>
	public class UserFlagToRoleLink 
	{
		/// <summary>
		/// Вспомогательный объект, представляющий XML-данные ds-объекта "Системная 
		/// роль" (SystemRole), представленные сервером приложений
		/// </summary>
		private ObjectOperationHelper m_oRolerObject = null;
		
		/// <summary>
		/// Значение флага (задаваемого для пользователя в системе НСИ)
		/// </summary>
		public int Flag;
		/// <summary>
		/// Идентификатор системной роли (ds-объекта SystemRole), соответствующего
		/// флагу в системе IT. Если флагу не поставлена в соответствие ни одна роль
		/// значение свойства есть Guid.Empty
		/// </summary>
		public Guid RoleID;
		/// <summary>
		/// Признак, указывающий, что флаг, заданный для пользователя в НСИ, 
		/// СБРАСЫВАЕТ все роли, заданные для пользователя в системе IT, вне 
		/// зависимости от значения RoleID. Используется для случаев таких 
		/// флагов как "2" (Уволен) и "16384" (На испытательном сроке)
		/// </summary>
		public bool IsClearRolesFlag;

		/// <summary>
		/// Вспомогательный объект, представляющий XML-данные ds-объекта "Системная 
		/// роль" (SystemRole), представленные сервером приложений. Загрузка данных
		/// объекта выполняется при первом обращении к свойству.
		/// </summary>
		public ObjectOperationHelper RoleObject 
		{
			get
			{
				if (Guid.Empty == RoleID)
					throw new ApplicationException("Не задан идентификатор для получения объекта \"Роль\"");
				if (null == m_oRolerObject)
					m_oRolerObject = ObjectOperationHelper.GetInstance( "SystemRole", RoleID );
				if ( !m_oRolerObject.IsLoaded )
					m_oRolerObject.LoadObject();
				if ( m_oRolerObject.IsNewObject )
					throw new ApplicationException("Заданный идентификатор определяет новый объект \"Роль\" и не может быть использован");

				return m_oRolerObject;
			}
		}
	}

	
	/// <summary>
	/// Объект-описатель КАРТЫ связей м/у флагами, задаваемым для пользователя
	/// в системе НСИ и соответствующей ссылкой на системную роль с Incident Tracker.
	/// Каждая связь представлена объектом типа UserFlagToRoleLink.
	/// </summary>
	public class UserFlagsToRolesMap
	{
		/// <summary>
		/// Коллекция всех описателей связей; получена на основании описания 
		/// в конфигурационном файле
		/// </summary>
		private HybridDictionary m_rolesLinks = new HybridDictionary();
		/// <summary>
		/// Массив флагов, полученных на основании описания в конфиг. файле
		/// </summary>
		private int[] m_arrFlags = new int[0];

		/// <summary>
		/// Выполняет загрузку описаний связей из конфигурационного файла, данные 
		/// которого представлеят спец. объект типа XConfigurationFile
		/// </summary>
		/// <param name="config">Конфигурационныфй файл</param>
		/// <remarks>
		/// Изменяет данные во внутренних переменных объекта - m_rolesLinks и
		/// m_arrFlags
		/// </remarks>
		public void LoadFormConfigXml( XConfigurationFile config ) 
		{
			// Зачищаем данные
			m_rolesLinks.Clear();
			m_arrFlags = new int[0];
			
			// Если конфигурация не задана - то и карты связей нет:
			if (null == config) 
				return;
			
			XmlNodeList xmlRoleLinks = config.SelectNodes( "itws:nsi-sync-service/itws:flags-to-roles-map/itws:role-link" );
			if (null==xmlRoleLinks)
				return;
			
			foreach( XmlNode xmlNodeLink in xmlRoleLinks )
			{
				XmlElement xmlRoleLink = (XmlElement)xmlNodeLink ;
				UserFlagToRoleLink link = new UserFlagToRoleLink();

				// #1: какой флаг
				string sAttribute = xmlRoleLink.GetAttribute("for-flag");
				if (null==sAttribute || String.Empty == sAttribute)
					throw new ApplicationException( String.Format( 
						"{0}: не задано значение флага (атрибут for-flag элемента itws:role-link)", 
						ServiceConfig.ERR_INCORRECT_CONFIG_DATA 
					));

				try { link.Flag = Int32.Parse(sAttribute); }
				catch( Exception err )
				{
					throw new ApplicationException( String.Format( 
						"{0}: указанное значение {1} для атрибута for-flag элемента itws:role-link не является целым", 
						ServiceConfig.ERR_INCORRECT_CONFIG_DATA, sAttribute
					), err );
				}

				// #2: в какую именно роль - идентификатор роли 
				sAttribute = xmlRoleLink.GetAttribute("to-role");
				if (null==sAttribute || String.Empty == sAttribute)
					link.RoleID = Guid.Empty;
				else
				{
					try { link.RoleID = new Guid(sAttribute); }
					catch( Exception err )
					{
						throw new ApplicationException( String.Format( 
							"{0}: указанное значение {1} для атрибута to-role элемента itws:role-link не является идентификатором типа GUID", 
							ServiceConfig.ERR_INCORRECT_CONFIG_DATA, sAttribute
						), err );
					}
				}
				
				// #3: признак зачишать все роли
				sAttribute = xmlRoleLink.GetAttribute("clear-roles");
				link.IsClearRolesFlag = !(null==sAttribute || String.Empty == sAttribute);

				// ИТОГО: Добавалем в коллекцию:
				m_rolesLinks.Add( link.Flag, link );
			}
			
			// Формируем массив флагов:
			m_arrFlags = new int[m_rolesLinks.Keys.Count];
			if (0!=m_rolesLinks.Keys.Count)
				m_rolesLinks.Keys.CopyTo(m_arrFlags,0);
		}

		
		/// <summary>
		/// Возвращает массив флагов, полученных на основании описания в 
		/// прикладном конфигурационном файле
		/// </summary>
		/// <remarks>При отсутствии описания возвращает пустой массив</remarks>
		public int[] Flags 
		{
			get { return m_arrFlags; }
		}
		
		
		/// <summary>
		/// Возвращает описатель связи, соответствующий заданному флагу.
		/// Если для указанного флага описателя нет, возвращает null
		/// </summary>
		public UserFlagToRoleLink this[int nFlag] 
		{
			get
			{
				object oLink = m_rolesLinks[nFlag];
				if (null==oLink)
					return null;
				return (oLink as UserFlagToRoleLink);
			}
		}
	}
}