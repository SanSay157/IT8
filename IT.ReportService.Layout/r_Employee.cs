using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;
using System.IO;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// Карточка просмотра Сотрудника
	/// </summary>
	public class r_Employee:CustomITrackerReport
	{
		public r_Employee(reportClass ReportProfile, string ReportName) : base(ReportProfile, ReportName)
		{
		}
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            IDictionary f = null;
            IDataReader r = data.DataProvider.GetDataReader("dsMain", data.CustomData);
            if (r.Read())
                f = _GetDataFromDataRow(r);

            if (null == f)
            {
                // Сотрудник не найден
                writeEmptyBody(data.RepGen, "Сотрудник не найден");
                return;
            }
            data.RepGen.WriteLayoutMaster();
            data.RepGen.StartPageSequence();
            data.RepGen.StartPageBody();
            StringBuilder sb = new StringBuilder("");
            sb.AppendFormat("<fo:block font-weight='bold' font-size='18px'> {0}</fo:block>", f["EmpName"]);
            sb.Append("<fo:block/>");
            sb.Append("<fo:table color='#FFFFFF' text-align='left' font-size='12px' font-family='MS Sans-serif'>");
            sb.Append("<fo:table-column/>");
            sb.Append("<fo:table-column/>");
            sb.Append("<fo:table-column/>");
            sb.Append("<fo:table-body>");

            sb.Append("<fo:table-row>");
            sb.AppendFormat("<fo:table-cell width='25%'><fo:block><fo:external-graphic src=\"x-get-image.aspx?OT=Employee&amp;PN=Picture&amp;ID={0}\" height=\"240\" width=\"240\" /> </fo:block></fo:table-cell>", xmlEncode(f["ObjectID"]));
            sb.Append("<fo:table-cell width='35%'>");
            sb.AppendFormat("<fo:block> {0} </fo:block>", xmlEncode(f["DepName"]));
            sb.AppendFormat("<fo:block padding-top='10px'> Дата выхода на работу: {0} </fo:block>", r.GetDateTime(2).ToShortDateString());
            sb.Append("</fo:table-cell>");
            sb.Append("</fo:table-row>");
            sb.Append("<fo:table-row>");
            //sb.AppendFormat("<fo:table-cell width='35%'><fo:block> Дата выхода на работу: {0} </fo:block></fo:table-cell>",xmlEncode(f["WorkBeginDate"]));
            sb.Append("<fo:table-cell><fo:block> </fo:block></fo:table-cell>");
            sb.Append("</fo:table-row>");

            sb.Append("</fo:table-body>");
            sb.Append("</fo:table>");
            sb.Append("<fo:table color='#FFFFFF' text-align='left' font-size='12px' font-family='MS Sans-serif'>");
            sb.Append("<fo:table-column/>");
            sb.Append("<fo:table-column/>");
            sb.Append("<fo:table-body>");
            sb.Append("<fo:table-row>");
            sb.Append("<fo:table-cell width='50%'>");
            sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'> Место работы: </fo:block>");
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> Адрес: {0} </fo:block>", xmlEncode(f["Address"]));
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> Тел.: {0} </fo:block>", xmlEncode(f["APhone"]));
            sb.AppendFormat("</fo:table-cell>");
            sb.Append("<fo:table-cell width='50%'>");
            sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'> Номера телефонов: </fo:block>");
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> Рабочие: {0} </fo:block>", xmlEncode(f["PhoneExt"]));
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> Мобильный: {0} </fo:block>", xmlEncode(f["MobilePhone"]));
            sb.AppendFormat("</fo:table-cell>");
            sb.Append("</fo:table-row>");
            sb.Append("<fo:table-row>");
            sb.Append("<fo:table-cell width='50%'>");
            sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'> E-Mail: </fo:block>");
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> {0} </fo:block>", xmlEncode(f["Email"]));
            sb.AppendFormat("</fo:table-cell>");
            sb.Append("<fo:table-cell width='50%'>");
            sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'>Мгновенные сообщения </fo:block>");
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'>CROC Messenger: {0} </fo:block>", xmlEncode(f["Email"]));
            sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'>SMS: {0} </fo:block>", xmlEncode(f["MobilePhone"]));
            sb.AppendFormat("</fo:table-cell>");
            sb.Append("</fo:table-row>");
            sb.Append("</fo:table-body>");
            sb.Append("</fo:table>");
            sb.AppendFormat("<fo:block font-weight='bold' font-size='14px' padding-top='15px'>Участие в проектах </fo:block>");
            // Проекты сотрудника 
            if (r.NextResult())
            {
                sb.Append("<fo:table color='#FFFFFF' text-align='left' font-size='12px' font-family='MS Sans-serif'>");
                sb.Append("<fo:table-column/>");
                sb.Append("<fo:table-column/>");
                sb.Append("<fo:table-body>");
                while (r.Read())
                {
                    f = _GetDataFromDataRow(r);
                    sb.Append("<fo:table-row>");
                    sb.Append("<fo:table-cell width='50%'>");
                    sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'>Проект: </fo:block>");
                    sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> {0} </fo:block>", xmlEncode(f["Project"]));
                    sb.AppendFormat("</fo:table-cell>");
                    sb.Append("<fo:table-cell width='50%'>");
                    sb.Append("<fo:block font-weight='bold' text-align='left' padding-top='10px'>Роль в Проекте: </fo:block>");
                    sb.AppendFormat("<fo:block padding-left='15px' padding-top='10px'> {0} </fo:block>", xmlEncode(f["ProjectRole"]));
                    sb.AppendFormat("</fo:table-cell>");
                    sb.Append("</fo:table-row>");
                }
                sb.Append("</fo:table-body>");
                sb.Append("</fo:table>");
            }

            data.RepGen.Header(sb.ToString());
            data.RepGen.EndPageBody();
            data.RepGen.EndPageSequence();
          
        }
	}
}

