using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// Карточка просмотра проекта
	/// </summary>
	public class r_Folder:CustomITrackerReport
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            Guid folderID = (Guid)data.Params.GetParam("ID").Value;
            IDictionary f = null;

              

            using (IDataReader r = data.DataProvider.GetDataReader("dsMain", data.CustomData))
            {
                if (r.Read())
                    f = _GetDataFromDataRow(r);
            }
            
            if (null == f)
            {
                // Проект не найден
                writeEmptyBody(data.RepGen, "Проект не найден");
                return;
            }
            data.RepGen.WriteLayoutMaster();
            data.RepGen.StartPageSequence();
            data.RepGen.StartPageBody();

            data.RepGen.Header("<fo:basic-link color=\"#ffffff\" external-destination=\"x-tree.aspx?METANAME=Main&amp;LocateFolderByID=" + folderID.ToString() + "\" target=\"_blank\" show-destination=\"new\">" + xmlEncode(f["Name"]) + "</fo:basic-link>");
            data.RepGen.TStart(false, "CELL_CLASS", false);
            data.RepGen.TAddColumn(null, align.ALIGN_LEFT, valign.VALIGN_TOP, "30%");
            data.RepGen.TAddColumn(null, align.ALIGN_LEFT, valign.VALIGN_TOP, "70%");

            // основные свойства проекта	
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Клиент", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(f["CustomerName"]), null);
            data.RepGen.TREnd();
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Название", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(_GetFolderAnchor(f["Name"], (Guid)f["ObjectID"], false), null);
            data.RepGen.TREnd();
            if (null != f["Description"])
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Описание", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(_LongText(f["Description"]), null);
                data.RepGen.TREnd();
            }
            if (null != f["FirstDate"])
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Дата начала", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(xmlEncode(((DateTime)f["FirstDate"]).ToLongDateString()) + " (" + getUserMailAnchor(f["FirstName"] + ", " + f["FirstDep"], f["FirstMail"], (Guid)f["FirstID"], folderID) + ")", null);
                data.RepGen.TREnd();
            }
            if (null != f["LastDate"])
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Дата последней активности", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(xmlEncode(((DateTime)f["LastDate"]).ToLongDateString()) + " (" + getUserMailAnchor(f["LastName"] + ", " + f["LastDep"], f["LastMail"], (Guid)f["LastID"], folderID) + ")", null);
                data.RepGen.TREnd();
            }

            FolderStates folderState = (FolderStates)f["State"];
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Состояние", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(FolderStatesItem.GetItem(folderState).Description), null);
            data.RepGen.TREnd();

            FolderTypeEnum folderType = (FolderTypeEnum)f["Type"];
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Тип", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(FolderTypeEnumItem.GetItem(folderType).Description), null);
            data.RepGen.TREnd();

            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Тип проектной активности", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(f["ActivityTypeName"]), null);
            data.RepGen.TREnd();

            // Код проекта: 
            //	- только для активности; 
            //	- м.б. не задан: в этом случае показываем что данных нет
            if (folderType != FolderTypeEnum.Directory)
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Код", null, 1, 1, "BOLD");
                if (null != f["ExternalID"])
                    data.RepGen.TRAddCell(xmlEncode(f["ExternalID"]), null);
                else
                    data.RepGen.TRAddCell(xmlEncode("(не задан)"), null);
                data.RepGen.TREnd();
            }

            if (null != f["DefaultIncidentTypeName"])
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Тип инцидента по умолчанию", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(xmlEncode(f["DefaultIncidentTypeName"]), null);
                data.RepGen.TREnd();
            }
            if ("0" != f["IsLocked"].ToString())
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell("Списания на папку заблокированы", null, 1, 1, "BOLD-RED");
                data.RepGen.TREnd();

            }
            int nTotalSpent = (int)f["SummarySpent"];
            if (0 != nTotalSpent)
            {
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Суммарные трудозатраты", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(
                    string.Format("<fo:basic-link external-destination=\"x-get-report.aspx?name=r-ProjectIncidentsAndExpenses.xml&amp;Folder={1}\">{0}</fo:basic-link>", xmlEncode(_FormatTimeStringAtServer(nTotalSpent, int.MaxValue)), folderID)
                    , null);
                data.RepGen.TREnd();
            }

            // Направления
            StringBuilder directions = new StringBuilder();
            
            using (IDataReader r = data.DataProvider.GetDataReader("dsDirections",data.CustomData))
            {
                while (r.Read())
                    directions.AppendFormat("<fo:block>{0}</fo:block>", xmlEncode(r.GetString(0)));
             }
            if (directions.Length != 0)
            {
                // Шапка
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Направления", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(directions.ToString(), null);
                data.RepGen.TREnd();
            }

            data.RepGen.TEnd();

            // проектная команда
            insertAdditionalProjectReports(data, folderID);

            // история
            insertFolderHistory(data, folderID);

            // инциденты
            insertWorkStaff(data, folderID);

            data.RepGen.EndPageBody();
            data.RepGen.EndPageSequence();
        }
		public r_Folder(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}

		private void insertFolderHistory(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, Guid folderID)
		{
		
				using(IDataReader r = data.DataProvider.GetDataReader("dsFolderHistory", data.CustomData))
				{
					bool first=true;
					while(r.Read())
					{
						if(first)
						{
							_TableSeparator(data.RepGen);
							data.RepGen.TStart(true,"CELL_CLASS", false);
                            int col = data.RepGen.TAddColumn("История активности", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Дата", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Событие", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Изменение выполнил", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "50%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
							first=false;
						}
						data.RepGen.TRStart();
						data.RepGen.TRAddCell(xmlEncode(r.GetDateTime(0)),null);
						data.RepGen.TRAddCell(xmlEncode(FolderHistoryEventsItem.GetItem((FolderHistoryEvents)r.GetInt16(1)).Description),null);
						if(r.GetBoolean(2))
						{
							data.RepGen.TRAddCell("&lt; Система &gt;",null, 1 , 1, "BOLD-RED");
						}
						else
						{
							data.RepGen.TRAddCell(getUserMailAnchor(r.GetString(3),r.GetString(4),r.GetGuid(5), folderID), null);
						}
						data.RepGen.TREnd();
					}
					if(!first)
						data.RepGen.TEnd();
				}
			
		}

        private void insertWorkStaff(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, Guid folderID)
		{
				using(IDataReader r = data.DataProvider.GetDataReader("dsFolderWorkStuff", data.CustomData))
				{
					bool first=true;
					while(r.Read())
					{
						if(first)
						{
							_TableSeparator(data.RepGen);
							data.RepGen.TStart(true,"CELL_CLASS", false);
                            int col = data.RepGen.TAddColumn("Инциденты проекта", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Тип инцидентов", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "50%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                            data.RepGen.TAddSubColumn(col, "Открыто", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "10%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                            data.RepGen.TAddSubColumn(col, "На проверке", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "10%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                            data.RepGen.TAddSubColumn(col, "Закрыто", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "10%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                            data.RepGen.TAddSubColumn(col, "Заморожено", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "10%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                            data.RepGen.TAddSubColumn(col, "Отклонено", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER", "10%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
							first=false;
						}
						data.RepGen.TRStart();
						data.RepGen.TRAddCell(xmlEncode(r.GetString(0)),null);
						data.RepGen.TRAddCell(xmlEncode(r.GetInt32(1)),null);
						data.RepGen.TRAddCell(xmlEncode(r.GetInt32(2)),null);
						data.RepGen.TRAddCell(xmlEncode(r.GetInt32(3)),null);
						data.RepGen.TRAddCell(xmlEncode(r.GetInt32(4)),null);
						data.RepGen.TRAddCell(xmlEncode(r.GetInt32(5)),null);
						data.RepGen.TREnd();
					}
					if(!first)
						data.RepGen.TEnd();
				}			
		}


		private string getUserMailAnchor(object stringRepresentation, object mail, Guid EmployeeID, Guid FolderID)
		{
			return _GetUserMailAnchor(stringRepresentation, mail, EmployeeID, Guid.Empty, FolderID);
		}

        private void insertAdditionalProjectReports(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, Guid folderID)
		{
			
				using(IDataReader r = data.DataProvider.GetDataReader("dsFolderAdditional", data.CustomData))
				{
					bool first=true;
					while(r.Read())
					{
						if(first)
						{
							_TableSeparator(data.RepGen);
							data.RepGen.TStart(true,"CELL_CLASS", false);
                            int col = data.RepGen.TAddColumn("Проектная команда", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Роль", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "30%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                            data.RepGen.TAddSubColumn(col, "Сотрудник", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "70%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
							first=false;
						}
						data.RepGen.TRStart();
						data.RepGen.TRAddCell( r.IsDBNull(0) ? "-- Не определена --" : xmlEncode(r.GetString(0) ),null);
						// EMail может быть не задан: если его нет, выводим просто ФИО
						if ( !r.IsDBNull(3) )
							data.RepGen.TRAddCell( getUserMailAnchor( r.GetString(1), r.GetString(3), r.GetGuid(2), folderID ),null);
						else
							data.RepGen.TRAddCell( xmlEncode(r.GetString(1)), null );
						data.RepGen.TREnd();
					}
					if(!first)
						data.RepGen.TEnd();
		        }
			
		}

	}
}
