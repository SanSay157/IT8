using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Globalization;
using System.Xml;

using Croc.XmlFramework.ReportService.ReportRenderer;

namespace Croc.IncidentTracker.ReportService.Layouts.ReportRenderer.Excel
{
    // Кастомный рендерер в Excel
    // Не рендерит ссылки (external-destination, internal-destination)
    public class ReportRenderer : IRenderer
    {
        public void Render(
            Stream inputStream, 
            Stream outputStream, 
            Encoding textEncoding, 
            CultureInfo cultureInfo, 
            string[] aOutputFormats, 
            string customInfo)
        {
            XmlDocument document = new XmlDocument();

            // проверка на то, что входной поток не пустой и открыт
            if (!inputStream.CanRead)
                throw new ArgumentException("Не возможно произвести чтение из потока с XSL-FO.");

            if (inputStream.Length == 0)
                throw new ArgumentException("Передан пустой поток с XSL-FO.");

            // Установим позицию на начало
            inputStream.Position = 0;

            // Проверим кодировку
            if (cultureInfo == null)
                cultureInfo = System.Globalization.CultureInfo.CurrentCulture;

            // Прогрузим документ
            document.Load(inputStream);

            // Удалим ненужные атрибуты
            foreach (XmlAttribute node in document.SelectNodes("//@*[local-name(.) = 'external-destination' or local-name(.) = 'internal-destination']"))
                node.OwnerElement.Attributes.Remove(node);

            // Сохраним документ в новый поток
            Stream newInputStream = new MemoryStream();
            
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.CloseOutput = false;
            
            XmlWriter writer = XmlWriter.Create(newInputStream, settings);

            document.Save(writer);

            writer.Close();

            // Отрендерим стандартным рендерером
            new MSExcelRenderer().Render(
                newInputStream, 
                outputStream, 
                textEncoding, 
                cultureInfo, 
                aOutputFormats, 
                customInfo);
        }
    }
}
