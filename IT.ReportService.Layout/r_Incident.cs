using System;
using System.Collections;
using System.Data;
using System.Text;
using System.Web;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;
using Croc.XmlFramework.XUtils;
using Croc.IncidentTracker.Utility;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// Карточка просмотра инцидента
	/// </summary>
	public class r_Incident:CustomITrackerReport
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            IDictionary inc;
                using (IDataReader r = data.DataProvider.GetDataReader("dsMain", data.CustomData))
                {
                    if (!r.Read())
                    {
                        writeEmptyBody(data.RepGen, "Инцидент не найден");
                        return;
                    }
                    inc = _GetDataFromDataRow(r);
                }
           
            //foWriter.RawOutput("<fo:title>№" + inc["Number"] + " " + xmlEncode( (string)inc["Name"] ) + "</fo:title>");
                data.RepGen.WriteLayoutMaster();
            data.RepGen.StartPageSequence();
            data.RepGen.StartPageBody();

            //foWriter.Header(/*"Incident Tracker", */ "<fo:basic-link color=\"#ffffff\" external-destination=\"x-tree.aspx?METANAME=Main&amp;LocateIncidentByID=" + ((Guid)inc["ObjectID"]).ToString() + "\" target=\"_blank\" show-destination=\"new\">№" + inc["Number"] + "</fo:basic-link> " + xmlEncode( (string)inc["Name"] ));
            data.RepGen.Header(
                    "<fo:basic-link color=\"#ffffff\" external-destination=\"vbscript:ShowContextForIncident(&quot;" + inc["ObjectID"] + "&quot;," + inc["Number"] + ",false)\">№" + inc["Number"] + "</fo:basic-link> " + xmlEncode(inc["Name"]));
            data.RepGen.TStart(false, "CELL_CLASS", false);

            insertMainProperties(data, inc);
            insertAdditionalProperties(data, inc);

            data.RepGen.TEnd();
            data.RepGen.EndPageBody();
            data.RepGen.EndPageSequence();
           // throw new NotImplementedException();
        }
		public r_Incident(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}

		private string getUserMailAnchor(object stringRepresentation, object mail, Guid EmployeeID, Guid IncidentID)
		{
			return _GetUserMailAnchor(stringRepresentation, mail, EmployeeID, IncidentID, Guid.Empty);
		}
        private void insertAdditionalProperties(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, IDictionary inc)
		{
            //Полный путь виртуального каталога приложения треккера - пока получаем через System.Web.
            //Он нужен для корректного экспорта отчета инцидента с картинкой в excel.
            //В проекте XFW 2.0 есть заявка на соотвествующую доработку - чтобы в ReportService также можно было использовать виртуальные относительные пути.
            //Когда это будет сделано,через System.Web полный путь получать уже не нужно будет.
            string virtualPath = HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + HttpContext.Current.Request.ApplicationPath;

            using (IDataReader r = data.DataProvider.GetDataReader("dsAdditional", inc["ObjectID"]))
				{
					Guid prev = Guid.Empty;
					StringBuilder str = new StringBuilder();
					while(r.Read())
					{
						Guid cur = r.GetGuid(0);
						if(cur!=prev)
						{
							prev = cur;
							if(str.Length!=0)
							{
                                data.RepGen.TRAddCell(str.ToString(), null, 5, 1);
                                data.RepGen.TREnd();
								str.Length = 0;
							}
                            data.RepGen.TRStart();
                            data.RepGen.TRAddCell(xmlEncode(r.GetString(1)) + ":", null, 1, 1, "BOLD");
						}
						// Соберём строчку
						switch( (IPROP_TYPE)r.GetInt32(2))
						{
							case IPROP_TYPE.IPROP_TYPE_BOOLEAN:
								str.AppendFormat("<fo:block>{0}</fo:block>",(0==r.GetDecimal(3))?"Ложь":"Истина");
								break;
							case IPROP_TYPE.IPROP_TYPE_DATE:
								str.AppendFormat("<fo:block>{0}</fo:block>",xmlEncode(r.GetDateTime(4).ToLongDateString()));
								break;
							case IPROP_TYPE.IPROP_TYPE_DATEANDTIME:
								str.AppendFormat("<fo:block>{0}</fo:block>",xmlEncode(r.GetDateTime(4)));
								break;
							case IPROP_TYPE.IPROP_TYPE_DOUBLE:
								str.AppendFormat("<fo:block>{0}</fo:block>",xmlEncode(r.GetDecimal(3)));
								break;
							case IPROP_TYPE.IPROP_TYPE_LONG:
								str.AppendFormat("<fo:block>{0}</fo:block>",xmlEncode(Convert.ToInt32(r.GetDecimal(3))));
								break;
							case IPROP_TYPE.IPROP_TYPE_TIME:
								str.AppendFormat("<fo:block>{0}</fo:block>",xmlEncode(r.GetDateTime(4).ToLongTimeString()));
								break;
							case IPROP_TYPE.IPROP_TYPE_STRING:
								str.Append(_LongText(r.GetString(5)));
								break;
							case IPROP_TYPE.IPROP_TYPE_TEXT:
								str.Append(_LongText(r.GetString(6)));
								break;
							case IPROP_TYPE.IPROP_TYPE_PICTURE:
                                str.AppendFormat("<fo:block><fo:external-graphic src=\"" + virtualPath + "/x-get-image.aspx?OT=IncidentPropValue&amp;PN=FileData&amp;ID={0}\"/></fo:block>", r.GetGuid(8));
								break;
							case IPROP_TYPE.IPROP_TYPE_FILE:
								int sizeInBytes =r.GetInt32(7);
								str.AppendFormat("<fo:block><fo:basic-link external-destination=\"x-get-image.aspx?OT=IncidentPropValue&amp;PN=FileData&amp;ID={0}\">{1}</fo:basic-link></fo:block>",r.GetGuid(8), xmlEncode((r.IsDBNull(5)?"Безымянный":r.GetString(5)) + " (" + sizeInBytes + " " + Utils.GetNumericEnding(sizeInBytes, "байт", "байтa", "байт" ) + ")"  ));
								break;
						}
					}
					if(str.Length!=0)
					{
                        data.RepGen.TRAddCell(str.ToString(), null, 5, 1);
                        data.RepGen.TREnd();
						str.Length = 0;
					}

				
			}
				
		}

		// Процедура вставляет в отчет основные свойства инцидента:
		// какому проекту принадлежит, кто и когда его зарегистрировал, класс, состояние, 
		// крайний срок, описание, приоритет, задания по инциденту и кто виновный
		private void insertMainProperties(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, IDictionary inc)
		{
			//'-----------------------------------------------------
			//' добавляем в таблицу необходимое количество колонок
            data.RepGen.TAddColumn();
            data.RepGen.TAddColumn();
            data.RepGen.TAddColumn();
            data.RepGen.TAddColumn();
            data.RepGen.TAddColumn();
            data.RepGen.TAddColumn(); 
		
			//' информация о проекте
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Проект:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(_GetFolderAnchor(inc["FolderPath"], ((Guid)inc["Folder"]), true), null, 5, 1);
            data.RepGen.TREnd();

			//' информация о сотруднике, зарегистрировавшем инцидент
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Зарегистрировал:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(_GetUserMailAnchor(inc["InitiatorString"], inc["InitiatorMail"], (Guid)inc["InitiatorID"], (Guid)inc["ObjectID"], (Guid)inc["Folder"]), null, 5, 1);
            data.RepGen.TREnd();
		
			//' дата регистрации
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Дата:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(((DateTime)inc["InputDate"]).ToLongDateString()), null, 5, 1);
            data.RepGen.TREnd();

			//	' класс инцидента
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Тип:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(inc["IncidentType"]), null, 5, 1);
            data.RepGen.TREnd();
		
			//	' состояние инцидента
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Состояние:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell(xmlEncode(inc["IncidentState"]), null, 5, 1);
            data.RepGen.TREnd();

			//	' крайний срок инцидента
			if(inc["Deadline"]!=null)
			{
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Крайний срок:", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(xmlEncode(((DateTime)inc["Deadline"]).ToLongDateString()), null, 5, 1);
                data.RepGen.TREnd();
			}

			//' описание инцидента
			if(inc["Descr"]!=null)
			{
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Описание:", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(_LongText((string)inc["Descr"]), null, 5, 1);
                data.RepGen.TREnd();				
			}
            data.RepGen.TRStart();
            data.RepGen.TRAddCell("Приоритет:", null, 1, 1, "BOLD");
            data.RepGen.TRAddCell((string)inc["IncidentPriority"], null, 5, 1);
            data.RepGen.TREnd();				



			insertTasks(data, inc);
			
			if(inc["Solution"]!=null)
			{
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Решение:", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(_LongText((string)inc["Solution"]), null, 5, 1);
                data.RepGen.TREnd();				
			}

			if(inc["IncidentCategory"]!=null)
			{
                data.RepGen.TRStart();
                data.RepGen.TRAddCell("Категория:", null, 1, 1, "BOLD");
                data.RepGen.TRAddCell(xmlEncode((string)inc["IncidentCategory"]), null, 5, 1);
                data.RepGen.TREnd();				
			}
			insertHistory(data, inc);
			insertIncidentLinks(data, inc);
		}

		private sealed class OneLinkedIncident
		{
			public string Direction;
			public int Number;
			public string Name;
			public Guid Id;

			private OneLinkedIncident(string direction, int number, string name, Guid id)
			{
				Direction = direction;
				Number = number;
				Name = name;
				Id=id;
			}

			public static ArrayList LoadLinkedIncidents(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, Guid IncidentID)
			{
				ArrayList a = new ArrayList();
			
					using(IDataReader r = data.DataProvider.GetDataReader("dsLinked", IncidentID))
					{
						while(r.Read())
							a.Add(new OneLinkedIncident(r.GetString(0), r.GetInt32(1), r.GetString(2), r.GetGuid(3)));

					}
				return a;
			}
		}

		private void insertIncidentLinks(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, IDictionary inc)
		{
			ArrayList links = OneLinkedIncident.LoadLinkedIncidents(data, (Guid)inc["ObjectID"]);
			if(0==links.Count) return;
			//' Шапка
			data.RepGen.TRStart();
			data.RepGen.TRAddCell( "Связи:", null , 1, links.Count + 1, "BOLD");
			data.RepGen.TRAddCell( "Направление", null, 1, 1 , "BOLD");
			data.RepGen.TRAddCell( "Инцидент",null, 4, 1 , "BOLD");
			data.RepGen.TREnd();
			foreach(OneLinkedIncident i in links)
			{
				string sIncidentInList = 
					"<fo:basic-link external-destination=\"vbscript:ShowContextForIncident(&quot;" + i.Id + "&quot;," + i.Number + ",true)\">№" + i.Number + "</fo:basic-link> " + xmlEncode(i.Name);
					//"<fo:basic-link external-destination=\"x-tree.aspx?METANAME=Main&amp;LocateIncidentByID=" + i.Id.ToString() + "\" target=\"_blank\" show-destination=\"new\">№" + i.Number + "</fo:basic-link> " + xmlEncode( i.Name );
				data.RepGen.TRStart();
				data.RepGen.TRAddCell(xmlEncode(i.Direction) ,null);
				data.RepGen.TRAddCell( sIncidentInList, null,4,1);
				data.RepGen.TREnd();
				
			}
		}

		private sealed class OneHistoryEntry
		{
			public string NewState;
			public DateTime When;
			public Guid WorkerID;
			public string WorkerString;
			public string WorkerMail;

			private OneHistoryEntry(string newState, DateTime when, Guid workerId, string workerString, string workerMail)
			{
				NewState = newState;
				When = when;
				WorkerID = workerId;
				WorkerString = workerString;
				WorkerMail = workerMail;
			}

            public static ArrayList LoadIncidentHistory(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, Guid incidentID)
			{
				ArrayList arr = new ArrayList();


                using (IDataReader r = data.DataProvider.GetDataReader("dsHistory", incidentID))
					{
						while(r.Read())
							arr.Add(new OneHistoryEntry(r.GetString(0), r.GetDateTime(1),r.GetGuid(2),r.GetString(3),r.GetString(4)));
					}
				
				return arr;
			}
		}
        private void insertHistory(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, IDictionary inc)
		{
			ArrayList history = OneHistoryEntry.LoadIncidentHistory(data, (Guid) inc["ObjectID"]);
			if(0==history.Count) return;
			data.RepGen.TRStart();
			data.RepGen.TRAddCell( "История:", null, 1, history.Count + 1, "BOLD");
			data.RepGen.TRAddCell( "Дата", null, 1, 1, "BOLD");
			data.RepGen.TRAddCell( "Состояние", null, 1, 1, "BOLD");
			data.RepGen.TRAddCell( "Пользователь",null, 3, 1, "BOLD");
			data.RepGen.TREnd();
			foreach(OneHistoryEntry h in history)
			{
				data.RepGen.TRStart();
				data.RepGen.TRAddCell(xmlEncode(h.When),null);
				data.RepGen.TRAddCell(xmlEncode(h.NewState), null);
				data.RepGen.TRAddCell(_GetUserMailAnchor(h.WorkerString, h.WorkerMail, h.WorkerID, (Guid) inc["ObjectID"], (Guid) inc["Folder"]),null, 3, 1);
				data.RepGen.TREnd();
			}
		}

		private sealed class OneTimeSpent
		{
			public DateTime When;
			public int HowMany;

			public OneTimeSpent(DateTime when, int howMany)
			{
				When = when;
				HowMany = howMany;
			}
		}

		private sealed class OneTask
		{
			public Guid id;
			public string Role;
			public int LeftTime;
			public int PlannedTime;
			public Guid WorkerID;
			public string WorkerString;
			public string WorkerMail;
			public ArrayList Spents;
			public int Duration;

			public int GetTotalSpent()
			{
				int i=0;
				foreach(OneTimeSpent ts in Spents)
					i+=ts.HowMany;
				return i;
			}

			private OneTask(Guid id, string role, int leftTime, int plannedTime, Guid workerId, string workerString, string workerMail, int duration )
			{
				this.id = id;
				Role = role;
				LeftTime = leftTime;
				PlannedTime = plannedTime;
				WorkerID = workerId;
				WorkerString = workerString;
				WorkerMail = workerMail;
				Duration = duration;
				Spents = new ArrayList();
			}

            public static OneTask[] LoadIncidentTasks(Guid incidentID, Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
			{
				
					ArrayList arr = new ArrayList();
					Guid prev = Guid.Empty;
					OneTask current = null;

                    using (IDataReader r = data.DataProvider.GetDataReader("dsTasks",incidentID))
					{
						while(r.Read())
						{
							if(r.GetGuid(0)!=prev)
							{
								current = new OneTask(r.GetGuid(0), r.GetString(1), r.GetInt32(2), r.GetInt32(3), r.GetGuid(4), r.GetString(5), r.IsDBNull(6)?null:r.GetString(6), r.GetInt32(7));
								arr.Add(current);
								prev = current.id;
							}
							if(!r.IsDBNull(8))
								current.Spents.Add(new OneTimeSpent(r.GetDateTime(9), r.GetInt32(8)));
						}

					}
					return (OneTask[]) arr.ToArray(typeof(OneTask));
				
			}
		}
        private void insertTasks(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data, IDictionary inc)
		{
			OneTask[] tasks = OneTask.LoadIncidentTasks((Guid) inc["ObjectID"], data);
			if(0==tasks.Length) return;
			int nTasksWithTimeS=0;
			foreach(OneTask t in tasks)
				if(t.Spents.Count!=0)
					++nTasksWithTimeS;
			//' выводим описания задач
			data.RepGen.TRStart();
			//'Формула 2*nTasks + nTasksWithTimeS показывает, на сколько подстрок будет разбита строка "Задание"
			//'Для каждого задания требуется две строки (названия колонок+информация по заданию) =>  2*nTasks 
			//'+nTasksWithTimeS - добавляется столько подстрок, сколько существует списаний времени
			data.RepGen.TRAddCell( "Задания:", null, 1, 2*tasks.Length + nTasksWithTimeS, "BOLD");
			bool notFirst = false;
			foreach(OneTask t in tasks)
			{
				if(notFirst)
					data.RepGen.TRStart(); 
				else
					notFirst=true;
				//' юзер, связанный с задачей
				//'2 + nHasTimeS - показывает, сколько строк объединяет ячейка "Ответственный за задание"
				//'Для вывода информации по заданию необходимо всегда две строки - наименование колонок+сама информация
				//'+nHasTimeS - также нужно прибавить строки для вывода списаний по задаче
				data.RepGen.TRAddCell(_GetUserMailAnchor(t.WorkerString, t.WorkerMail, t.WorkerID, (Guid) inc["ObjectID"], (Guid) inc["Folder"]), null, 1, 2 + (t.Spents.Count==0?0:1));
				data.RepGen.TRAddCell("Роль", null, 1, 1, "BOLD");
				data.RepGen.TRAddCell("Запланировано", null, 1, 1, "BOLD");
				data.RepGen.TRAddCell("Затрачено", null, 1, 1, "BOLD");
				data.RepGen.TRAddCell("Осталось", null, 1, 1, "BOLD");
				data.RepGen.TREnd();
				//' выводим информацию о запланированном и рельно потраченном времени
				data.RepGen.TRStart();
				data.RepGen.TRAddCell( xmlEncode( t.Role), null);
				//' при превышении времени используем красный цвет
				int nSpentTime = t.GetTotalSpent();
				if (t.PlannedTime < nSpentTime)
				{
					data.RepGen.TRAddCell( _FormatTimeStringAtServer(t.PlannedTime, t.Duration), null, 1, 1, "BOLD-RED");
					data.RepGen.TRAddCell( _FormatTimeStringAtServer(nSpentTime, t.Duration), null, 1, 1, "BOLD-RED");
				}
				else
				{
					data.RepGen.TRAddCell( _FormatTimeStringAtServer(t.PlannedTime, t.Duration),  null);
					data.RepGen.TRAddCell( _FormatTimeStringAtServer(nSpentTime, t.Duration), null);
				}
			
				//' оставшееся время
				data.RepGen.TRAddCell( _FormatTimeStringAtServer(t.LeftTime, t.Duration), null);
				data.RepGen.TREnd();

				//' если есть списания, то выводим их
				if(t.Spents.Count!=0)
				{
					data.RepGen.TRStart(); 
					data.RepGen.TRAddCell(getTaskSpents(t, t.Duration), null, 4, 1);
					data.RepGen.TREnd();
				}
			}
		}

		private string getTaskSpents(OneTask t, int duration)
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("<fo:block font-weight=\"bold\">Списание времени</fo:block>");
			foreach(OneTimeSpent ts in t.Spents)
				sb.AppendFormat("<fo:block>{0}&#160;&#160;&#160;&#160;&#160;&#160;{1}</fo:block>",xmlEncode(ts.When.ToString()), xmlEncode(_FormatTimeStringAtServer(ts.HowMany, duration)));
			return sb.ToString();
		}

	}
}
