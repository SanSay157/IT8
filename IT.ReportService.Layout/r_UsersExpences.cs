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
	/// Summary description for r_UsersExpences.
	/// </summary>
	public class r_UsersExpences: CustomITrackerReport
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider);
        }
		protected const string fixed_14_4 = null; // "fixed.14.4";

		public r_UsersExpences(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}
    	private void buildThisReport(XslFOProfileWriter w, ReportParams Params, IReportDataProvider Provider)
		{

			
				DateTime dtActualBegin;
				DateTime dtActualEnd;
				DateTime dtBegin;
				DateTime dtEnd;
				string OrganizationName;
				ArrayList arrDates = new ArrayList();
                object IntervalBegin = Params.GetParam("IntervalBegin").Value;
                object IntervalEnd = Params.GetParam("IntervalEnd").Value;
                object Folder = Params.GetParam("Folder").Value;
                object Customer = Params.GetParam("Customer").Value;
                int ActivityAnalysDepth = (int)Params.GetParam("ActivityAnalysDepth").Value;
                int InsertRestrictions = (int)Params.GetParam("InsertRestrictions").Value;
                int FolderType = (int)Params.GetParam("FolderType").Value;
                int SectionByActivity = (int)Params.GetParam("SectionByActivity").Value;
                int DateDetalization = (int)Params.GetParam("DateDetalization").Value;
                int TimeMeasureUnits = (int)Params.GetParam("TimeMeasureUnits").Value;
                int ExpencesType = (int)Params.GetParam("ExpensesType").Value;
                int IncludeSubProjects = (int)Params.GetParam("IncludeSubProjects").Value;
		
                int SortType = (int)Params.GetParam("SortType").Value;
                int SortOrder = (int)Params.GetParam("SortOrder").Value;
                int ShowColumnWorkTimeNorm = (int)Params.GetParam("ShowColumnWorkTimeNorm").Value;
                /*int ShowColumnOverheads = (int)Params.GetParam("ShowColumnOverheads").Value;
                int ShowColumnSalaryExpenses = (int)Params.GetParam("ShowColumnSalaryExpenses").Value;*/
                CustomDataForDS oCustomData = new CustomDataForDS();
                oCustomData.sTempTableName = "##UsersExpences_" + Guid.NewGuid().ToString("n");
                // Первый запрос возвращает 2 рекордсета
				// 1 - Папка, Организация, Начало, Конец
				// 2 - Даты для которых строится отчёт
                using (IDataReader rdr = Provider.GetDataReader("dsUserExpencesPrimary", oCustomData))
                {
				
					rdr.Read(); // По любому одна строка :)
					OrganizationName = rdr.GetString(1);
					dtActualBegin = rdr.IsDBNull(2)?DateTime.MinValue:rdr.GetDateTime(2);
					dtActualEnd = rdr.IsDBNull(3)?DateTime.MaxValue:rdr.GetDateTime(3);
                    oCustomData.dtActualBegin = dtActualBegin;
                    oCustomData.dtActualEnd = dtActualEnd;
					dtBegin = IntervalBegin==null?dtActualBegin:(DateTime)IntervalBegin;
					dtEnd = IntervalEnd==null?dtActualEnd:(DateTime)IntervalEnd;
					StringBuilder sb=new StringBuilder("<fo:block>Динамика затрат сотрудников</fo:block>");
					// Создадим заголовок
					if(0!=InsertRestrictions)
					{
						sb.Append("<fo:block/>");

						sb.Append("<fo:block font-size='14px'>Параметры отчета:</fo:block>");
						sb.Append("<fo:table color='#FFFFFF' text-align='left' font-size='12px' font-family='MS Sans-serif'>");
						sb.Append("<fo:table-column/>");
						sb.Append("<fo:table-column/>");
						sb.Append("<fo:table-body>");
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Период времени:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode(rdr.GetString(4))+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Клиент:</fo:block></fo:table-cell>");
						if(null==Customer)
							sb.Append("<fo:table-cell><fo:block>" + xmlEncode(OrganizationName)+"</fo:block></fo:table-cell>");
						else
							//																							ShowContextForOrganization(sID, sExtID, sDirectorEMail)
							sb.Append("<fo:table-cell><fo:block><fo:basic-link color=\"#ffffff\" external-destination=\"vbscript:ShowContextForOrganization(&quot;" + Customer + "&quot;,&quot;" + rdr.GetString(6) + "&quot;,&quot;" + rdr.GetString(7) + "&quot;)\">" + xmlEncode(OrganizationName)+"</fo:basic-link></fo:block></fo:table-cell>");

						sb.Append("</fo:table-row>");

						
						if(!rdr.IsDBNull(5))
						{
							sb.Append("<fo:table-row>");
							sb.Append("<fo:table-cell width='35%'><fo:block>Активность:</fo:block></fo:table-cell>");
							sb.Append("<fo:table-cell><fo:block><fo:basic-link color=\"#ffffff\" external-destination=\"vbscript:ShowContextForFolderEx(&quot;" + rdr.GetGuid(5) + "&quot;,true, " + ((dtBegin==DateTime.MinValue)?"NULL":dtBegin.ToString("#MM'/'dd'/'yyyy#")) + ", " + ((dtEnd==DateTime.MaxValue)?"NULL":dtEnd.ToString("#MM'/'dd'/'yyyy#")) + ")\">" + xmlEncode(rdr.GetString(0))+"</fo:basic-link></fo:block></fo:table-cell>");
							sb.Append("</fo:table-row>");
						}
						
						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Тип активности:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( FolderTypeEnumItem.ToStringOfDescriptions((FolderTypeEnum) FolderType) )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");


						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Глубина анализа активностей:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( ActivityAnalysDepthItem.GetItem((ActivityAnalysDepth)ActivityAnalysDepth).Description )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Секционирование по активностям:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( SectionByActivityItem.GetItem((SectionByActivity)SectionByActivity).Description )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Детализация по датам:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( DateDetalizationItem.GetItem((DateDetalization)DateDetalization).Description )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Виды трудозатрат:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( ExpencesTypeItem.GetItem((ExpencesType)ExpencesType).Description )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Включать в проект затраты подпроектов:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + ((IncludeSubProjects==0)?"нет":"да") +"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Сортировка:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( SortExpencesItem.GetItem((SortExpences)SortType).Description )+", " + xmlEncode( SortOrderItem.GetItem((SortOrder)SortOrder).Description ) + "</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("<fo:table-row>");
						sb.Append("<fo:table-cell width='35%'><fo:block>Единицы измерения времени:</fo:block></fo:table-cell>");
						sb.Append("<fo:table-cell><fo:block>" + xmlEncode( TimeMeasureUnitsItem.GetItem((TimeMeasureUnits)TimeMeasureUnits).Description )+"</fo:block></fo:table-cell>");
						sb.Append("</fo:table-row>");

						sb.Append("</fo:table-body>");
						sb.Append("</fo:table>");
					}
					if(rdr.NextResult())
						while(rdr.Read())
							arrDates.Add(rdr.GetDateTime(0));
                    oCustomData.arrDates = arrDates;
                    w.WriteLayoutMaster();
					w.StartPageSequence();
					w.StartPageBody();
					w.Header(sb.ToString());
				}

				if(dtActualBegin==DateTime.MinValue)
				{
					// Пустой отчёт, данные не нужны, табличка дропнута
					w.EmptyBody("Нет данных");
				}
				else
				{
					// Теперь сформируем вторичный запрос на получение данных
                    using (IDataReader rdr2 = Provider.GetDataReader("dsUserExpencesSecondary", oCustomData))
                    {
						int nActivityColSpan = 2;
						int nTotalColspan = 1;
						int nFieldCount = rdr2.FieldCount;
						const int nFirstDateColumn = 9;
						// Выведем тело отчёта
						w.TStart(true, "CELL_CLASS", false);
						/*
						if(HideGroupColumns)
						{
							++nActivityColSpan;
							w.TAddColumn("Активность", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER");
						}
						*/
						w.TAddColumn("Сотрудник", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, "TABLE_HEADER");
						if(0!=ShowColumnWorkTimeNorm)
						{
							w.TAddColumn("Норма рабочего времени", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER");
							++nActivityColSpan;
							++nTotalColspan;
						}
						w.TAddColumn("Сумма затрат (час)", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER");
						//w.TAddColumn("Сумма затрат", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, "TABLE_HEADER");
						/*if(0!=ShowColumnOverheads)
						{
							w.TAddColumn("Накладные расходы", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, "TABLE_HEADER");
							++nActivityColSpan;
						}
						if(0!=ShowColumnSalaryExpenses)
						{
							w.TAddColumn("Затраты на з/п", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, "TABLE_HEADER");
							++nActivityColSpan;
						} */

						for(int i=nFirstDateColumn; i<nFieldCount;++i)
						{
                                w.TAddColumn(rdr2.GetName(i), align.ALIGN_CENTER, valign.VALIGN_MIDDLE, "TABLE_HEADER");
                                ++nActivityColSpan;
                            
						}

						Guid prevFolderID = Guid.Empty;
						int[] arrLocalTotals =  new int[nFieldCount];
						int[] arrGlobalTotals = new int[nFieldCount];
						int nLocalTotalTime = 0;
						int nGlobalTotalTime = 0;
				
						int nTimeFormatValue = (TimeMeasureUnits==(int)IncidentTracker.TimeMeasureUnits.Hours)?int.MaxValue:/*rdr.GetInt32(5)*/600;

						while(rdr2.Read())
						{
							if(SectionByActivity!=(int)Croc.IncidentTracker.SectionByActivity.NoSection)
							{
								Guid thisFolderID = rdr2.GetGuid(0);
								if(thisFolderID!=prevFolderID)
								{
									if(prevFolderID!=Guid.Empty)
									{
										// Итого ;)
										w.TRStart("SUBTOTAL");
										w.TRAddCell("Итого по активности:", null, nTotalColspan, 1);
										w.TRAddCell(xmlEncode(_FormatTimeStringAtServer(nLocalTotalTime, nTimeFormatValue)), null);
										//w.TRAddCell(rLocalTotalCost, fixed_14_4);
										/*if(0!=ShowColumnOverheads)
											w.TRAddCell( rLocalTotalOverheads, fixed_14_4);
										if(0!=ShowColumnSalaryExpenses)
											w.TRAddCell( rLocalTotalSalaryExpenses, fixed_14_4);*/
										for(int i=nFirstDateColumn; i<nFieldCount;++i)
										{
											w.TRAddCell( xmlEncode(_FormatTimeStringAtServer( arrLocalTotals[i], nTimeFormatValue)), null);
										}
										w.TREnd();
										// Почистим локальный "ИТОГО"
										nLocalTotalTime = 0;
										System.Array.Clear(arrLocalTotals, 0, arrLocalTotals.Length);
									}
									prevFolderID = thisFolderID;
									// Сформируем подзаголовок
									w.TRStart("SUBTITLE");
									w.TRAddCell( this._GetFolderAnchor(rdr2.GetString(1),thisFolderID, Guid.Empty, true, dtBegin, dtEnd) , null, nActivityColSpan, 1);
									w.TREnd();
								}
							}

							bool bIncludeInGlobals = rdr2.GetInt32(7)==0;

							w.TRStart("CELL_CLASS");
							w.TRAddCell( _GetUserMailAnchor(rdr2.GetString(3), rdr2.GetString(4), rdr2.GetGuid(2), Guid.Empty, rdr2.IsDBNull(0)?(Folder==null?Guid.Empty:((Guid)Folder)):rdr2.GetGuid(0)) ,null);
							if(0!=ShowColumnWorkTimeNorm)
							{
								w.TRAddCell( xmlEncode( this._FormatTimeStringAtServer(rdr2.GetInt32(8), nTimeFormatValue)) , null);
							}
							int nTempInt32 = rdr2.GetInt32(6);
							w.TRAddCell(xmlEncode(_FormatTimeStringAtServer(nTempInt32, nTimeFormatValue)), null);
							if(bIncludeInGlobals) nGlobalTotalTime += nTempInt32;
							nLocalTotalTime += nTempInt32;

							/*decimal rTempDecimal = rdr2.GetDecimal(11);
							w.TRAddCell( rTempDecimal, fixed_14_4);
							if(bIncludeInGlobals) rGlobalTotalCost += rTempDecimal;
							rLocalTotalCost += rTempDecimal;*/

							/*if(0!=ShowColumnOverheads)
							{
								rTempDecimal = rdr2.GetDecimal(7);
								w.TRAddCell( rTempDecimal, fixed_14_4);
								if(bIncludeInGlobals) rGlobalTotalOverheads += rTempDecimal;
								rLocalTotalOverheads += rTempDecimal;
							}
							if(0!=ShowColumnSalaryExpenses)
							{
								rTempDecimal = rdr2.GetDecimal(8);
								w.TRAddCell( rTempDecimal, fixed_14_4);
								if(bIncludeInGlobals) rGlobalTotalSalaryExpenses += rTempDecimal;
								rLocalTotalSalaryExpenses += rTempDecimal;
							}*/
							for(int i=nFirstDateColumn; i<nFieldCount;++i)
							{
								nTempInt32 = rdr2.GetInt32(i);
								w.TRAddCell( xmlEncode(_FormatTimeStringAtServer( nTempInt32, nTimeFormatValue)), null);
								if(bIncludeInGlobals) arrGlobalTotals[i] = arrGlobalTotals[i]+ nTempInt32;
								arrLocalTotals[i] = arrLocalTotals[i]+ nTempInt32;
							}

							w.TREnd();
						}
						if(SectionByActivity!=(int)Croc.IncidentTracker.SectionByActivity.NoSection)
						{
							if(prevFolderID!=Guid.Empty)
							{
								// Итого ;)
								w.TRStart("SUBTOTAL");
								w.TRAddCell("Итого по активности:", null, nTotalColspan, 1);
								w.TRAddCell(xmlEncode(_FormatTimeStringAtServer(nLocalTotalTime, nTimeFormatValue)), null);
								//w.TRAddCell(rLocalTotalCost, fixed_14_4);
								/*if(0!=ShowColumnOverheads)
									w.TRAddCell( rLocalTotalOverheads, fixed_14_4);
								if(0!=ShowColumnSalaryExpenses)
									w.TRAddCell( rLocalTotalSalaryExpenses, fixed_14_4); */ 
								for(int i=nFirstDateColumn; i<nFieldCount;++i)
								{
									w.TRAddCell( xmlEncode(_FormatTimeStringAtServer( arrLocalTotals[i], nTimeFormatValue)), null);
								}
								w.TREnd();
							}
						}
						// Итого ;)
						w.TRStart("TABLE_FOOTER");
						w.TRAddCell("Итого:", null, nTotalColspan, 1);
						w.TRAddCell(xmlEncode(_FormatTimeStringAtServer(nGlobalTotalTime, nTimeFormatValue)), null);
						//w.TRAddCell(rGlobalTotalCost, fixed_14_4);
						/*if(0!=ShowColumnOverheads)
							w.TRAddCell( rGlobalTotalOverheads, fixed_14_4);
						if(0!=ShowColumnSalaryExpenses)
							w.TRAddCell( rGlobalTotalSalaryExpenses, fixed_14_4); */
						for(int i=nFirstDateColumn; i<nFieldCount;++i)
						{
							w.TRAddCell( xmlEncode(_FormatTimeStringAtServer( arrGlobalTotals[i], nTimeFormatValue)), null);
						}
						w.TREnd();

						w.TEnd();
					}

				}
				w.EndPageBody();
				w.EndPageSequence();
			}
		}
    public class CustomDataForDS
    {
        public CustomDataForDS()
        {
            dtActualBegin = new DateTime();
            dtActualEnd = new DateTime();
            arrDates = new ArrayList();
            sTempTableName = string.Empty;
        }
        public DateTime dtActualBegin;
        public DateTime dtActualEnd;
        public ArrayList arrDates;
        public string sTempTableName;
    }
}
