//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using System.Text;
using Croc.XmlFramework.XUtils;
using System.Collections;
using System.Collections.Specialized;
using System.Data;

namespace Croc.IncidentTracker.Utility
{
	/// <summary>
	/// Общие утилиты
	/// </summary>
	public sealed class Utils
	{
		private Utils()
		{}
        
		/// <summary>
		/// Форматирует заданное количество минут в строку вида "Х дней Y часов Z минут"
		/// </summary>
		/// <param name="nMinutes">Количество минут</param>
		/// <param name="nWorkdayDurationInMinutes">Количество минут в дне</param>
		/// <returns>Строка с форматированным представлением заданного времени</returns>
		public static string FormatTimeDuration(int nMinutes, int nWorkdayDurationInMinutes)
		{
			if (nWorkdayDurationInMinutes <= 0)
				throw new ArgumentException( "Параметр nWorkdayDurationInMinutes должен быть больше нуля", "nWorkdayDurationInMinutes" );
			
			// Формально, конечно, сам факт форматирования отрицательных значений в 
			// определенных случаях сомнителен; но бывает что и нужно. В принципе сам 
			// метод это не запрещает - дописывает "-" перед строковым представлением: 
			// для этого запомним что изначально число было отрицательным, и возьмем
			// абсолютное значение числа:
			bool bIsNegativeDuration = (nMinutes < 0);
			if (bIsNegativeDuration)
				nMinutes = -nMinutes ;
			int nTimeInADay = nMinutes % nWorkdayDurationInMinutes;
			int nTimeInDays = nMinutes / nWorkdayDurationInMinutes;
			int nTimeInHours = nTimeInADay / 60;
			int nTimeInMinutes = nTimeInADay % 60;

			StringBuilder bld = new StringBuilder();
			if (nTimeInDays > 0)
			{
				bld.Append(nTimeInDays);
				bld.Append(GetNumericEnding(nTimeInDays, " день", " дня", " дней"));
			}
			if (nTimeInHours > 0)
			{
				if (nTimeInDays > 0)
					bld.Append(" ");
				bld.Append(nTimeInHours);
				bld.Append(GetNumericEnding(nTimeInHours, " час", " часа", " часов"));
			}
			if (nTimeInMinutes > 0)
			{
				if (nTimeInDays + nTimeInHours > 0)
					bld.Append(" ");
				bld.Append(nTimeInMinutes);
				bld.Append(GetNumericEnding(nTimeInMinutes, " минута", " минуты", " минут"));
			}
			if (bld.Length == 0)
				bld.Append("0 часов");

			if (bIsNegativeDuration)
				bld.Insert( 0, "- ");

			return bld.ToString();
		}
        public static string GetNumericEnding(int val, string word1, string word2, string word5)
        {
            int nCnt10;	// Число десятков
            int nCnt1;	// Число единиц

            val = val % 100;	// отбросим кол-во сотен
            nCnt10 = val / 10;	// получим количество десятков
            nCnt1 = val % 10;	// получим количество единиц

            if (nCnt10 == 1)
                return word5;
            else if (nCnt1 == 1)
                return word1;
            else if (nCnt1 > 1 && nCnt1 < 5)
                return word2;
            else
                return word5;
        }

        /// <summary>
        /// Преобразует строку БД в число с плавающей запятой
        /// с обработкой исключений
        /// </summary>
        /// <param name="sIn">строка содержащая число</param>
        /// <returns>резултирующее число</returns>
        public static double ParseDBString(string sIn)
        {
            if (sIn.Length <= 0) return 0;
            double dblResult = 0;
            try
            {
                dblResult = double.Parse(sIn);
            }
            catch (FormatException)
            {
                dblResult = double.Parse(sIn.Replace(".", ","));
            }
            return dblResult;
        }

        /// <summary>
        ///  считывает строку результата из рекордсета
        /// </summary>
        /// <param name="r">ридер</param>
        /// <returns>Словарь с результирующей строкой</returns>
        public static IDictionary _GetDataFromDataRow(IDataRecord r)
        {
            int max = r.FieldCount;
            HybridDictionary hd = new HybridDictionary(max, true);
            for (int i = 0; i < max; i++)
                if (r.IsDBNull(i))
                    hd.Add(r.GetName(i), null);
                else
                    hd.Add(r.GetName(i), r.GetValue(i));
            return hd;
        }

        /// <summary>
        /// зачитывает данные рекордсета в массив
        /// </summary>
        /// <param name="reader">ридер</param>
        /// <returns>результирующий массив данных</returns>
        public static ArrayList _GetDataAsArrayList(IDataReader reader)
        {
            ArrayList data = new ArrayList();
            IDictionary row;
            while (reader.Read())
            {
                row = _GetDataFromDataRow(reader);
                data.Add(row);
            }
            return (0 != data.Count ? data : null);
        }
    }
}
