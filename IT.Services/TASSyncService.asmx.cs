using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Services
{
    /// <summary>
    /// Сервис синхронизации данных справочников, представленных в корпоративной 
    /// Системе Учета Тендеров (СУТ)
    /// </summary>
    [WebService(
         Name = "TASSyncService",
         Namespace = "http://www.croc.ru/Namespaces/IncientTracker/WebServices/TASSync/1.0",
         Description =
            "Система Учета Тендеров :  " +
            "Cервис синхронизации данных справочников, представленных  " +
            "в корпоративной системе ведения Нормативной Справочной Информации (НСИ)")
    ]
    public class TASSyncService : System.Web.Services.WebService
    {
        /// <summary>
		/// Конструктор объекта
		/// </summary>
        public TASSyncService() 
		{
			ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
		}

        /// <summary>
        /// Предоставляет данные тендеров, описанных в системе (СУТ).
        /// </summary>
        /// <param name="objectIDs">
        /// Массив идентификаторов тендеров
        /// Не обязаьльный параметр; если не задан (null), метод возвращает данные по всем тендерам
        /// </param>
        /// <returns>
        /// Массив описаний тендеровю
        /// </returns>
        [WebMethod(Description = "Получение описания Тендеров (Tender) в Системе Учета Тендеров (СУТ)")]
        public TASTenderInfo[] GetTendersInfo( Guid[] objectIDs)
        {
            XParamsCollection dsParams = new XParamsCollection();
            // Если заданы идентификаторы Тендеров, то добавим их в параметры источника данных
            if (objectIDs != null)
            {
                foreach (Guid objectID in objectIDs)
                {
                    dsParams.Add("ObjectID", objectID);
                }
            }

            // Зачитаем данные о тендерах:
            DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncTAS-TendersInfo", dsParams);
            if (null == oDataTable)
                return new TASTenderInfo[0];

            TASTenderInfo[] arrTenderInfo = new TASTenderInfo[oDataTable.Rows.Count];
            // Пробежимся по всем строкам и сформируем результат
            for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
            {
                TASTenderInfo info = new TASTenderInfo();
                info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
                info.ProjectCode = (DBNull.Value != oDataTable.Rows[nRowIndex]["Number"]) 
                                        ? oDataTable.Rows[nRowIndex]["Number"].ToString() : null;
                info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();
                info.Director = (DBNull.Value != oDataTable.Rows[nRowIndex]["Director"])
                                        ? oDataTable.Rows[nRowIndex]["Director"].ToString() : null;
                info.Customer = (DBNull.Value != oDataTable.Rows[nRowIndex]["TenderCustomer"])
                                        ? oDataTable.Rows[nRowIndex]["TenderCustomer"].ToString() : null;
                info.Folder = (DBNull.Value != oDataTable.Rows[nRowIndex]["Folder"])
                                        ? oDataTable.Rows[nRowIndex]["Folder"].ToString() : null;
                info.Initiator = (DBNull.Value != oDataTable.Rows[nRowIndex]["Initiator"])
                                        ? oDataTable.Rows[nRowIndex]["Initiator"].ToString() : null;
                info.InputDate = (DBNull.Value != oDataTable.Rows[nRowIndex]["InputDate"])
                                        ? ((DateTime)oDataTable.Rows[nRowIndex]["InputDate"]).ToString("yyyy-MM-ddTHH:mm:ss") : null;
               
                // Добавим считанные данные в массив
                arrTenderInfo[nRowIndex] = info;
            }
            return arrTenderInfo;
        }
        /// <summary>
        /// Обновляет данные тендеров, описанных в системе (СУТ).
        /// </summary>
        /// <param name="sTenderID">
        /// Идентификатор тендера в СУТ
        /// </param>
        /// <param name="sNewFolderID">
        /// Идентификатор тендера в ITracker
        /// </param>
        /// <returns>
        /// Признак того, что значение поменялось
        /// </returns>
        [WebMethod (Description = "Получение описания Тендеров (Tender) в Системе Учета Тендеров (СУТ)")]
        public bool UpdateTender( string sTenderID, string sNewFolderID)
        {
            // Проверяем параметры
            Guid uidTenderID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sTenderID, "Идентификатор Тендера (sTenderID)");
            Guid uidFolderID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewFolderID, "Идентификатор Тендера в ITracker (sNewFolderID)");
            // Загрузим объект типа "Тендер"
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Tender", uidTenderID);
            bool bExists  = helper.SafeLoadObject(null, null);

            //Если данного тендера в системе СУТ нет,то выходим
            if (!bExists)
            {
                return false;
            }

			ObjectOperationHelper folderHelper = helper.GetInstanceFromPropScalarRef("Folder", false);

			if (folderHelper == null || folderHelper.ObjectID != uidFolderID)
			{
				// Проставляем свойство "Тендер в Трекере"
				helper.SetPropScalarRef("Folder", "Folder", uidFolderID);
				helper.DropPropertiesXmlExcept("Folder");
				helper.SaveObject();
				return true;
			}
			else
			{
				return true;
			}
        }

    }
}
