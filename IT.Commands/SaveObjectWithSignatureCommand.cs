//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Diagnostics;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Команда сохранения объекта с добавлением подписи к текстовым свойствам,
	/// помеченным элементом auto-signature в метаданных
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	[XRequiredRequestType(typeof(SaveObjectInternalRequest))]
	public class SaveObjectWithSignatureCommand : XCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public virtual XResponse Execute( SaveObjectInternalRequest request, IXExecutionContext context ) 
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			if (!user.IsServiceAccount)
			{
				string signature = getSignatureText(user);
				// если текущий пользователь не сервисный аккаунт, то можно добавлять подписи к текстовым полям
				// изменяем модифицируемые объекты
				IEnumerator enumerator = request.DataSet.GetModifiedObjectsEnumerator(true);
				while (enumerator.MoveNext())
				{
					DomainObjectData xobj = (DomainObjectData)enumerator.Current;
					modifyObjectProps(xobj, signature);
				}
			}
			
			// вызываем стандартную команду SaveObject
			request.Name = "SaveObject";
			return context.ExecCommand(request, true);
		}

		/// <summary>
		/// Изменяет помеченные свойства объекта, добавляя к ним подпись
		/// </summary>
		/// <param name="xobj">текущий объект</param>
		/// <param name="signature">подпись</param>
		private void modifyObjectProps(DomainObjectData xobj, string signature)
		{
			// пройдемся по всем свойствам объекта
			foreach (string sPropName in xobj.UpdatedPropNames)
			{
				// получим информацию о свойстве по его названию
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				
				// если подпись для данного свойства не нужна, пропускаем его
				if (hasPropSignature(propInfo))
				{
					object vPropValue = xobj.GetUpdatedPropValue(sPropName);
					if (vPropValue != null && vPropValue != DBNull.Value)
					{
						string sText = null;
						if (propInfo.VarType == XPropType.vt_string || propInfo.VarType == XPropType.vt_text)
							sText = (string)vPropValue;
						else
							throw new ApplicationException("Механизм автоподписи применим только к строковым и текстовым полям");

						if (sText != null)
							xobj.SetUpdatedPropValue(sPropName, addSignature(sText, signature));
					}
				}
			}
		}

		/// <summary>
		/// Проверяет, должно ли свойство иметь подпись
		/// </summary>
		/// <param name="propInfo">метаданные свойства</param>
		/// <returns>true - свойство должно иметь подпись</returns>
		private bool hasPropSignature(XPropInfoBase propInfo)
		{
			// если свойство не текстовое, подпись не нужна
			if (propInfo.VarType != XPropType.vt_string &&
				propInfo.VarType != XPropType.vt_text)
				return false;

			// если свойство содержит элемент auto-signature, равный true,
			// то подпись нужна
			if (propInfo.SelectSingleNode("itds:auto-signature[.='true']") != null)
				return true;

			// иначе подпись не нужна
			return false;
		}

		/// <summary>
		/// Добавляет подпись к тексту
		/// </summary>
		/// <param name="text">исходный текст</param>
		/// <param name="signature"></param>
		/// <returns></returns>
		private string addSignature(string text, string signature)
		{
			Debug.Assert(text != null);
			Debug.Assert(signature != null);

			// если в конце нет перевода строки, то добавим его
			if (!text.EndsWith(Environment.NewLine))
				text += Environment.NewLine;

			// добавим саму подпись
			text += signature;

			return text;
		}

		/// <summary>
		/// Возвращает текст подписи
		/// </summary>
		/// <param name="user">Текущий пользователь</param>
		/// <returns>текст подписи (не null)</returns>
		private string getSignatureText(ITUser user)
		{
			return String.Format("[ {0}, {1} ]", user.LastName + " " + user.FirstName,
				DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"));
		}
	}
}
