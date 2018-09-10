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
	/// Summary description for r_EmployeeExpensesList.
	/// </summary>
	public class r_EmployeeExpensesList: CustomITrackerReport
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
		public r_EmployeeExpensesList(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}
		private object NullToDBNull(object o)
		{
			return null==o?DBNull.Value:o;
		}

		protected void buildThisReport(XslFOProfileWriter w, ReportParams Params, IReportDataProvider Provider, object CustomData)
		{
			// Получим параметры
			object	IntervalBegin = Params.GetParam("IntervalBegin").Value;
			object	IntervalEnd = Params.GetParam("IntervalEnd").Value;
			Guid Employee = (Guid) Params.GetParam("Employee").Value;

			int NonProjectExpences = (int) Params.GetParam("NonProjectExpences").Value;
			int IncludeParams = (int) Params.GetParam("IncludeParams").Value;
			int AnalysDirection = (int) Params.GetParam("AnalysDirection").Value;
			int TimeLossReason = (int) Params.GetParam("TimeLossReason").Value;
			int SectionByActivity = (int) Params.GetParam("SectionByActivity").Value;
			int ExepenseDetalization = (int) Params.GetParam("ExepenseDetalization").Value;
			int TimeMeasureUnits = (int) Params.GetParam("TimeMeasureUnits").Value;
			object ActivityType = Params.GetParam("ActivityType").Value;
			object ExpenseType = Params.GetParam("ExpenseType").Value;
			object IncidentState = Params.GetParam("IncidentState").Value;
		    
			int Sort = (int) Params.GetParam("Sort").Value;
			int SortOrder = (int) Params.GetParam("SortOrder").Value;

			bool bIncidentAttributes = 0!=(int) Params.GetParam("IncidentAttributes").Value;
			bool bDate =  0!=(int) Params.GetParam("Date").Value;
			bool bNumberOfTasks =  0!=(int) Params.GetParam("NumberOfTasks").Value;
			bool bRemaining =  0!=(int) Params.GetParam("Remaining").Value;
			bool bNewState =  0!=(int) Params.GetParam("NewState").Value;
			bool bComment =  0!=(int) Params.GetParam("Comment").Value;
            StringBuilder sb = new StringBuilder();
            switch (ExepenseDetalization) 
            {
             case (int)ExpenseDetalization.ByExpences:
                bNumberOfTasks = false;
                break;
            
             case (int)ExpenseDetalization.BySubActivity:
          
                    bNewState = bComment = bIncidentAttributes = false;
                    break;
            }
				using(IDataReader r= Provider.GetDataReader("dsMain",null))
				{
					IDictionary headerData;
                    w.WriteLayoutMaster();
					w.StartPageSequence();
					w.StartPageBody();
					sb.Append("<fo:block>Список инцидентов и затрат сотрудника</fo:block>");
					if(!r.Read())
					{
						//TODO: EmptyBody	
					}

					headerData = _GetDataFromDataRow(r);
					IntervalBegin = headerData["IntervalBegin"];
					IntervalEnd = headerData["IntervalEnd"];
					// Создадим заголовок
					if(0!=IncludeParams)
					{

						sb.Append("<fo:block/>");

						sb.Append("<fo:block font-size='14px'>Параметры отчета:</fo:block>");
						sb.Append("<fo:table color='#FFFFFF' text-align='left' font-size='12px' font-family='MS Sans-serif'>");
						sb.Append("<fo:table-column/>");
						sb.Append("<fo:table-column/>");
						sb.Append("<fo:table-body>");
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Направление анализа:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["AnalysDirection"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Период времени:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["DateInterval"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Сотрудник:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block><fo:basic-link color=\"#ffffff\" external-destination=\"vbscript:ShowContextForEmployeeLite(&quot;" + Employee + "&quot;,&quot;" + xmlEncode(headerData["EMail"]) + "&quot;)\">" + headerData["EmployeeName"] + "</fo:basic-link></fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Тип активности:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["ActivityType"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Детализация затрат:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["ExepenseDetalization"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Вид трудозатрат:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["ExpenseType"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Состояние инцидента:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["IncidentState"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Единицы измерения времени:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" +  xmlEncode(TimeMeasureUnitsItem.GetItem((Croc.IncidentTracker.TimeMeasureUnits)TimeMeasureUnits).Description)+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>&#160;</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(headerData["NonProjectExpences"])+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("</fo:table-body>");
						sb.Append("</fo:table>");
					}

					int nActivityColspan = 9;

					int nWorkDayDuration = (int)headerData["WorkDayDuration"];
					int nReportWorkDayDuration = TimeMeasureUnits==(int)IncidentTracker.TimeMeasureUnits.Hours?int.MaxValue:nWorkDayDuration;
					w.Header(sb.ToString());

					int nRowNum=0;

					if(! r.NextResult())
						throw new ApplicationException("Отсутствует основной рекордсет");
					nActivityColspan = 9;
					w.TStart(0==SectionByActivity, "CELL_CLASS", false);
                    w.TAddColumn("№ п/п", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					if(bIncidentAttributes)
                        w.TAddColumn("Причина списания", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;
                    w.TAddColumn("Наименование активности", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					if(bDate)
                        w.TAddColumn("Дата", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;
					int nTotalColspan = nActivityColspan - 5 - 1;
					if(bNumberOfTasks)
                        w.TAddColumn("Кол-во заданий", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;
                    w.TAddColumn("Затрачено/Списано", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					if(bRemaining)
                        w.TAddColumn("Осталось", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;
					if(bNewState)
                        w.TAddColumn(ExepenseDetalization == (int)ExpenseDetalization.ByExpences ? "Новое состояние" : "Состояние", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;
					if(bComment)
                        w.TAddColumn("Комментарии", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					else
						--nActivityColspan;

					Guid currentTopActivityID = Guid.Empty;

					int totalSpent = 0;
					int totalLeft = 0;
					int totalTasks =0;
					int totalLost=0;
					int totalSpentPerActivity=0;
					int totalLeftPerActivity=0;
					int totalTasksPerActivity=0;

					int previousCauseType=-1;
					int nCauseType = -1;

					while(r.Read())
					{
						IDictionary rec = _GetDataFromDataRow(r);
						previousCauseType = nCauseType;
						nCauseType = (int)rec["CauseType"];
						bool bMergeIncidentAttributes = (3==nCauseType) && bIncidentAttributes;

						if(0!=SectionByActivity)
						{
							Guid topActivityID = (Guid) rec["topFolder"];
							if(currentTopActivityID!=topActivityID)
							{
								if(currentTopActivityID!=Guid.Empty)
								{
									w.TRStart();
									w.TRAddCell("&#160;",null);
									w.TRAddCell(previousCauseType==3?"Всего по непроектным списаниям":"Всего по активности:", null, nTotalColspan,1);
									if(bNumberOfTasks)
										w.TRAddCell(totalTasksPerActivity, "i4");
									w.TRAddCell(this._FormatTimeStringAtServer(totalSpentPerActivity, nReportWorkDayDuration),null);
									if(bRemaining)
										w.TRAddCell( this._FormatTimeStringAtServer(totalLeftPerActivity, nReportWorkDayDuration),null);
									if(bNewState) w.TRAddCell("&#160;",null);
									if(bComment) w.TRAddCell("&#160;",null);
									w.TREnd();

									totalSpentPerActivity=0;
									totalLeftPerActivity=0;
									totalTasksPerActivity=0;
								}

								currentTopActivityID = topActivityID;
								w.TRStart();
								w.TROmitCell();
								w.TRAddCell(3==nActivityColspan?xmlEncode(rec["topName"]):this._GetFolderAnchor(rec["topName"], (Guid) rec["ActivityID"], Employee, true, IntervalBegin!=null?(DateTime)IntervalBegin:DateTime.MinValue, IntervalEnd!=null?(DateTime)IntervalEnd:DateTime.MaxValue ),null, nActivityColspan, 1, "TABLE_HEADER" );
								w.TREnd();
								w.TRStart();
								w.TRAddCell("№ п/п", null, 1, 1, "TABLE_HEADER");
								if(bIncidentAttributes)
									w.TRAddCell("Причина списания", null, bMergeIncidentAttributes?2:1, 1, "TABLE_HEADER");
								if(!bMergeIncidentAttributes)
									w.TRAddCell(3==nCauseType?"Причина списания":"Наименование активности", null, 1, 1, "TABLE_HEADER");
								if(bDate)
									w.TRAddCell("Дата", null, 1, 1, "TABLE_HEADER");
								if(bNumberOfTasks)
									w.TRAddCell(3==nCauseType?"Кол-во списаний":"Кол-во заданий", null, 1, 1, "TABLE_HEADER");
								w.TRAddCell(3==nCauseType?"Списано":"Затрачено/Списано", null, 1, 1, "TABLE_HEADER");
								if(bRemaining)
									w.TRAddCell("Осталось", null, 1, 1, "TABLE_HEADER");
								if(bNewState)
									w.TRAddCell("Новое состояние", null, 1, 1, "TABLE_HEADER");
								if(bComment)
									w.TRAddCell("Комментарии", null, 1, 1, "TABLE_HEADER");
								w.TREnd();
							}

						}

						if(3==nCauseType||4==nCauseType)
						{
							totalLost += (int)rec["Spent"];
						}
						else
						{
							totalSpent += (int)rec["Spent"];
						}
						totalSpentPerActivity  += (int) rec["Spent"];
						totalTasks += (3==nCauseType ? 0 : ( null!=rec["NumberOfTasks"]?(int)rec["NumberOfTasks"]:0 ) );
						totalTasksPerActivity += ((1!=nCauseType && 2!=nCauseType)? 0 : null!=rec["NumberOfTasks"]? (int)rec["NumberOfTasks"] : 0);
						totalLeft += 3==nCauseType?0:(null!=rec["LeftTime"]?(int)rec["LeftTime"]:0);
						totalLeftPerActivity += 3==nCauseType?0:(null!=rec["LeftTime"]?(int)rec["LeftTime"]:0);

						w.TRStart();
						w.TRAddCell(++nRowNum ,"i4");
						if (bIncidentAttributes) 
						{
							w.TRAddCell( 
								1==nCauseType? // только для инцидентов 
									this._GetIncidentAnchor( rec["CauseName"], (Guid)rec["CauseID"],true ) : 
									xmlEncode(rec["CauseName"]),
								null, 
								bMergeIncidentAttributes? 2 : 1, 
								1 );
						}
						if (!bMergeIncidentAttributes)
						{
							if (3!=nCauseType)
								w.TRAddCell( this._GetFolderAnchor( rec["ActivityName"], (Guid)rec["ActivityID"], Employee, true, IntervalBegin!=null?(DateTime)IntervalBegin : DateTime.MinValue, IntervalEnd!=null?(DateTime)IntervalEnd:DateTime.MaxValue ), null );
							else
								w.TRAddCell( xmlEncode(rec["ActivityName"]), null );
						}
						if (bDate) 
							w.TRAddCell(xmlEncode(rec["DateSpent"]),null);
						
						if (bNumberOfTasks)
						{
							// Кол-во инцидентов показваем только для инцидентов или проектов
							if (1==nCauseType || 2==nCauseType)
								w.TRAddCell( "" + rec["NumberOfTasks"], "i4" );	
							else
								w.TRAddCell( " - ", "string" );	
						}
						
						w.TRAddCell( this._FormatTimeStringAtServer( (int)rec["Spent"],nReportWorkDayDuration),null );
						if(bRemaining)
						{
							object objLeftTime = rec["LeftTime"];
							w.TRAddCell( objLeftTime==null?string.Empty:this._FormatTimeStringAtServer((int)objLeftTime,nReportWorkDayDuration) ,null);
						}
						if(bNewState) w.TRAddCell(xmlEncode(rec["NewState"]),null);
						if(bComment) w.TRAddCell(xmlEncode(rec["Comments"]),null);
						w.TREnd();								
					}

					if(0!=SectionByActivity && currentTopActivityID!=Guid.Empty)
					{
						w.TRStart();
						w.TRAddCell("&#160;",null);
						w.TRAddCell(nCauseType==3?"Всего по непроектным списаниям":"Всего по активности:", null, nTotalColspan,1);
						if(bNumberOfTasks)
							w.TRAddCell(totalTasksPerActivity, "i4");
						w.TRAddCell(this._FormatTimeStringAtServer(totalSpentPerActivity, nReportWorkDayDuration),null);
						if(bRemaining)
							w.TRAddCell( this._FormatTimeStringAtServer(totalLeftPerActivity, nReportWorkDayDuration),null);
						if(bNewState)w.TRAddCell("&#160;",null);
						if(bComment) w.TRAddCell("&#160;",null);
						w.TREnd();
					}

					// Итого
					if((int)ExpencesType.Both==(int)ExpenseType || (int)ExpencesType.Incidents==(int)ExpenseType)
					{
						w.TRStart();
						w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");

						w.TRAddCell("Итого затрачено на задания по инцидентам", null, nTotalColspan,1, "TABLE_HEADER");
						if(bNumberOfTasks)
							w.TRAddCell(totalTasks, "i4", 1, 1, "TABLE_HEADER");
						w.TRAddCell(this._FormatTimeStringAtServer(totalSpent, nReportWorkDayDuration),null, 1, 1, "TABLE_HEADER");
						if(bRemaining)
							w.TRAddCell( this._FormatTimeStringAtServer(totalLeft, nReportWorkDayDuration),null, 1, 1, "TABLE_HEADER");
						if(bNewState) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						if(bComment) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TREnd();
					}

					if((int)ExpencesType.Both==(int)ExpenseType || (int)ExpencesType.Discarding==(int)ExpenseType)
					{
						w.TRStart();
						w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TRAddCell("Итого списано ", null, nTotalColspan,1, "TABLE_HEADER");
						if(bNumberOfTasks)
							w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TRAddCell(this._FormatTimeStringAtServer(totalLost, nReportWorkDayDuration),null, 1, 1, "TABLE_HEADER");
						if(bRemaining) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						if(bNewState) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						if(bComment) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TREnd();
					}

					if((int)ExpencesType.Both==(int)ExpenseType)
					{
						w.TRStart();
						w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TRAddCell("Общие трудозатраты  ", null, nTotalColspan, 1, "TABLE_HEADER");
						if(bNumberOfTasks)
							w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TRAddCell(this._FormatTimeStringAtServer(totalLost + totalSpent, nReportWorkDayDuration),null, 1, 1, "TABLE_HEADER");
						if(bRemaining) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						if(bNewState) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						if(bComment) w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
						w.TREnd();
					}

					w.TRStart();
					w.TRAddCell("&#160;",null, 1, 1, "TABLE_HEADER");
					w.TRAddCell(xmlEncode(string.Format("Всего рабочих дней за период - {0}, Норма рабочего времени за период - {1}", headerData["WorkDays"], this._FormatTimeStringAtServer((int)headerData["WorkDays"]*nWorkDayDuration, int.MaxValue))), null, nActivityColspan-1 ,1, "TABLE_HEADER");
					w.TREnd();

					w.TEnd();
					w.EndPageBody();
					w.EndPageSequence();
				}
		}
	}
}
