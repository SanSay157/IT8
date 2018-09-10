using System;
using System.Collections.Generic;
using System.Web;

namespace Croc.IncidentTracker.Services
{
    /// <summary>
    /// Класс представляющий информацию о Тендере в "Системе Учета Тендеров" (СУТ)
    /// </summary>
    [Serializable]
    public class TASTenderInfo
    {
        /// <summary>
        /// Идентификатор Тендера в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string ObjectID;

        /// <summary>
        /// Значение свойства «Номер» (Tender.Number) объекта «Тендер» (Tender)
        /// в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string ProjectCode;

        /// <summary>
        /// Значение свойства «Наименование» (Tender.Name) объекта «Тендер» (Tender)
        /// в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string Name;

        /// <summary>
        /// Значение свойства «Клиент» (Tender.Customer) объекта «Тендер» (Tender)
        /// в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string Customer;

        /// <summary>
        /// Значение свойства «Директор клиента»  (Tender.Director) объекта «Тендер» (Tender)
        /// в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string Director;

        /// <summary>
        /// Значение свойства «"Тендер в Трекере"»  
        /// в "Системе Учета Тендеров" (СУТ)
        /// </summary>
        public string Folder;

        /// <summary>
        /// Значение свойства соответствует значению свойства «Инициатор» (Tender.Initiator) объекта «Тендер» (Tender), 
        /// представляющего в системе данные тендера.
        /// </summary>
        public string Initiator;

        /// <summary>
        /// Значение свойства "Дата регистрации" Тендера
        /// </summary>
        public string InputDate;
    }
}
