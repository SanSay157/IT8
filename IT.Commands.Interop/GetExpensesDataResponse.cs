//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// Перечисление, задающее "цвет", соответствующий полноте списаний для 
	/// контроллируемого периода; Здесь "цвет" - некая градация кол-ва 
	/// несписанного времени: если несписано много, то"цвет" красный, если 
	/// не очень - то синий; если списано все - то "зеленый". Разделение на 
	/// градации достаточно условно и определяется для каждого периода кодом
	/// </summary>
	[Serializable]
	public enum ExpensesCompleteness 
	{
		/// <summary>
		/// красный - списаний крайне недостаточно
		/// </summary>
		RedZone = 1,
		
		/// <summary>
		/// синий - неполное количество списаний 
		/// </summary>
		BlueZone = 2,
		
		/// <summary>
		/// зеленый - полное количество списаний
		/// </summary>
		GreenZone = 3
	}


	/// <summary>
	/// Представление продолжительности заданного периода
	/// Экземпляр описывает продолжиьтельность через количество минут, а так же
	/// числом полных дней / часов / минут. Реализует логику для получения 
	/// строкового представления периода с соответствующими подписями (например,
	/// "2 дня 5 часов 41 минута")
	/// </summary>
	[Serializable]
	public class DurationInfo 
	{
		/// <summary>
		/// Константный текст сообщения об ошибке
		/// </summary>
		const string DEF_ERR_NULL_VALUE = "Указанное значение не может быть NULL";
		const string DEF_ERR_CANNOT_BE_SET = "Значение свойства не может быть изменено явно";
		
		#region Внутренние переменные и методы класса
		
		/// <summary>
		/// Продолжительность периода, в минутах (т.к. минимальное дробление 
		/// при строковом представлении дается в минутах)
		/// </summary>
		private int m_nFullDuration = 0;
		
		/// <summary>
		/// Продолжительность рабочего дня: днем может считаться рабочий день 
		/// (т.е. 8/10 часов), а может полные сутки - 24 часа - ЗНАЧЕНИЕ ПО 
		/// УМОЛЧАНИЮ; Значение задается в минутах, и в общем случае может 
		/// различаться для каждого сотрудника
		/// </summary>
		private int m_nWorkDayDuration = 24 * 60; // 24 часа по 60 минут

		/// <summary>
		/// Полное количество дней в заданном периоде; данное значение зависит от 
		/// "продолжительности рабочего дня": днем может считаться рабочий день 
		/// (т.е. 8/10 часов), а может полные сутки - 24 часа; 
		/// </summary>
		private int m_nDays;

		/// <summary>
		/// Полное количество часов в заданном периоде, за вычитом часов, 
		/// составляющих полные дни (т.е. вошедших в m_nDays); т.к. определение
		/// кол-ва дней в заданном периоде зависит от "продолжительности рабочего 
		/// дня", то и остаток в часах так же зависит
		/// </summary>
		private int m_nHours; 
		
		/// <summary>
		/// Кол-во минут в заданном периоде, оставшихся при вычите полного числа 
		/// дней (m_nDays) и часов (m_nHours)
		/// </summary>
		private int m_nMinutes;

		/// <summary>
		/// Внутренний метод, пересчитывающий значения внутренних перемнных класса в
		/// зависимости от значений продолжительности периода (m_nFullDuration)
		/// и "продолжительности рабочего дня" (m_nWorkDayDuration)
		/// </summary>
		private void convertDuration() 
		{
			m_nDays = m_nHours = m_nMinutes = 0;

			m_nMinutes = m_nFullDuration % 60;
			m_nHours = ((m_nFullDuration - m_nMinutes) % m_nWorkDayDuration) / 60;
			m_nDays = (m_nFullDuration - m_nMinutes - 60 * m_nHours) / m_nWorkDayDuration;
		}
		

		/// <summary>
		/// Выбор подписи для указанного целочисленного значения
		/// </summary>
		/// <param name="nValue">Значение </param>
		/// <param name="sSingleNominativ">Подпись, в ед. числе, именительный падеж (nominativus)</param>
		/// <param name="sSingleGenitiv">Подпись, в ед. числе, родительный падеж (genitivus)</param>
		/// <param name="sPluralGenitiv">Подпись во множ. числе, родительный падеж (genitivus)</param>
		/// <returns>Строка с подписью</returns>
		private string getLabelString( int nValue, string sSingleNominativ, string sSingleGenitiv, string sPluralGenitiv ) 
		{
			if ( null==sSingleNominativ )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sSingleNominativ" );
			if ( null==sSingleGenitiv )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sSingleGenitiv" );
			if ( null==sPluralGenitiv )
				throw new ArgumentNullException( DEF_ERR_NULL_VALUE, "sPluralGenitiv" );
			
			int nProbedValue = nValue % 100;
			
			if ( nProbedValue > 4 && nProbedValue < 20 )
				return sPluralGenitiv;
			else
			{
				nProbedValue = nProbedValue % 10;
				if ( 1 == nProbedValue )
					return sSingleNominativ;
				else if (nProbedValue > 1 && nProbedValue < 5)
					return sSingleGenitiv;
				else
					return sPluralGenitiv;
			}
		}
		
		#endregion

		/// <summary>
		/// Конструктор по умолчанию
		/// Необходим для корректной де-сериализации
		/// </summary>
		public DurationInfo() 
		{
			Duration = 0;
		}


		/// <summary>
		/// Продолжительность периода, в минутах (т.к. минимальное дробление 
		/// при строковом представлении дается в минутах). При изменении значения
		/// свойства АВТОМАТИЧЕСКИ изменяются значения свойств Days, Hours, 
		/// Minutes, DaysString, HoursString, MinutesString и DurationString
		/// </summary>
		public int Duration 
		{
			get { return m_nFullDuration; }	
			set
			{
				m_nFullDuration = value;
				// запускаем пересчет всех зависимых значений
				convertDuration();
			}
		}

		
		/// <summary>
		/// Продолжительность рабочего дня: днем может считаться рабочий день 
		/// (т.е. 8/10 часов), а может полные сутки - 24 часа - ЗНАЧЕНИЕ ПО 
		/// УМОЛЧАНИЮ; Значение задается в минутах, и в общем случае может 
		/// различаться для каждого сотрудника. 
		/// При изменении значения свойства АВТОМАТИЧЕСКИ изменяются значения 
		/// свойств Days, Hours, Minutes, DaysString, HoursString, MinutesString
		/// и DurationString.
		/// Задаваеме значение должно быть больше 0 и меньше или равно 24*60.
		/// </summary>
		public int WorkDayDuration 
		{
			get { return m_nWorkDayDuration; }
			set
			{
				if (0==value || value > 24*60)
					throw new ArgumentException( "Значение свойства WorkDayDuration должно быть больше 0 и меньше или равно 24*60", "WorkDayDuration");
				m_nWorkDayDuration = value;
				// запускаем пересчет всех зависимых значений
				convertDuration();
			}
		}


		/// <summary>
		/// Полное количество дней в заданном периоде; данное значение зависит от 
		/// "продолжительности рабочего дня": днем может считаться рабочий день 
		/// (т.е. 8/10 часов), а может полные сутки - 24 часа; 
		/// </summary>
		public int Days 
		{
			get { return m_nDays; }
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}
		
		
		/// <summary>
		/// Полное количество часов в заданном периоде, за вычитом часов, 
		/// составляющих полные дни (т.е. вошедших в Days); т.к. определение
		/// кол-ва дней в заданном периоде зависит от "продолжительности рабочего 
		/// дня", то и остаток в часах так же зависит
		/// </summary>
		public int Hours 
		{
			get { return m_nHours; }
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// Кол-во минут в заданном периоде, оставшихся при вычите полного числа 
		/// дней (Days) и часов (Hours)
		/// </summary>
		public int Minutes 
		{
			get { return m_nMinutes; }
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// Подпись для строкового представления полного количество дней, вида 
		/// "NNN дней"; Если кол-во продолжительность исходного периода меньше 
		/// дня, свойство возвращает пустую строку
		/// </summary>
		public string DaysLabel 
		{
			get
			{
				return (0 == m_nDays? String.Empty : getLabelString(m_nDays, "день", "дня", "дней") );
			}
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// Подпись для строкового представление полного количества часов, за 
		/// вычетом полного кол-ва дней, вида "NNN часов"; если продолжительность 
		/// исходного периода меньше часа, свойство возвращает пустую строку
		/// </summary>
		public string HoursLabel 
		{
			get 
			{ 
				return (0 == m_nHours? String.Empty : getLabelString(m_nHours, "час", "часа", "часов") );
			}
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}

		
		/// <summary>
		/// Подпись для строкового представление количества минут, за вычетом 
		/// полного кол-ва часов и дней, вида "NNN минут"; продолжительность 
		/// исходного периода не содержит "остатка" в минутах (тоько ровное 
		/// кол-во дней / часов), свойство возвращает пустую строку
		/// </summary>
		public string MinutesLabel 
		{
			get
			{
				return ( 0==m_nMinutes? String.Empty : getLabelString(m_nMinutes, "минута", "минуты", "минут") );
			}	
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}


		/// <summary>
		/// Возвращает строковое представление ВСЕГО периода. 
		/// Если период нулевой - возвращает пустую строку
		/// </summary>
		public string DurationString 
		{
			get
			{
				string sReturnValue = String.Empty;
				if (Days!=0)
					sReturnValue = Days.ToString() + " " + DaysLabel;
				if (Hours != 0)
					sReturnValue += (Days!=0? " " : "") + Hours.ToString() + " " + HoursLabel;
				if (Minutes != 0)
					sReturnValue += (Days!=0 || Hours!=0? " " : "") + Minutes.ToString() + " " + MinutesLabel;
				if (0 == sReturnValue.Length)
					sReturnValue = "0 дней";
				return sReturnValue;
			}
			set
			{
				// Установить явно свойство нельзя; set-модификатор реализован
				// для обеспечения сериализуемости объекта в XML
				throw new NotSupportedException( DEF_ERR_CANNOT_BE_SET );
			}
		}
	}
	
	
	/// <summary>
	/// Данные по затратам (по списаниям) для одного периода (в целом 
	/// рассматриваются три периода - <seealso cref="GetExpensesDataResponse"/>)
	/// </summary>
	[Serializable]
	public class PeriodExpensesInfo 
	{
		/// <summary>
		/// Начальная дата периода (включительно)
		/// </summary>
		public DateTime PeriodStartDate;
		
		/// <summary>
		/// Конечная дата периода (включительно); Для периода в один день значение
		/// не задается (null)
		/// </summary>
		public DateTime PerionEndDate;

		/// <summary>
		/// Признак задания периода продолжительностью в один день; для одного дня 
		/// сама дата задается как значение свойства PeriodStartDate
		/// </summary>
		public bool IsOneDayPeriod;
		
		/// <summary>
		/// Наименование периода - или наименование календарного месяца или "Сегодня"
		/// </summary>
		public string PeriodName;		

		/// <summary>
		/// Ожидаемое (требуемое) количество списаний для рассматриваемого периода
		/// </summary>
		public DurationInfo ExpectedExpense = new DurationInfo();

		/// <summary>
		/// Реальное количество списаний для рассматриваемого периода
		/// </summary>
		public DurationInfo RealExpense = new DurationInfo();

		/// <summary>
		/// Остаток списаний для рассматриваемого периода
		/// </summary>
		public DurationInfo RemainsExpense = new DurationInfo();

		/// <summary>
		/// "Цвет", соответствующий полноте списаний для контроллируемого периода
		/// </summary>
		public ExpensesCompleteness Completeness;
	}


	/// <summary>
	/// Результат операции получения данных, отображаемых на панели контроля списаний
	/// (обслуживается HTC-компонентой it-TimingPanel.htc)
	/// </summary>
	[Serializable]
	public class GetExpensesDataResponse : XResponse 
	{
		/// <summary>
		/// Идентификатор сотрудника (НЕ пользователя!) для которого 
		/// были получены все данные по затратам:
		/// </summary>
		public Guid EmployeeID;
		
		/// <summary>
		/// Информация о списании на предыдущий месяц
		/// </summary>
		public PeriodExpensesInfo PreviousMonth = new PeriodExpensesInfo();
		
		/// <summary>
		/// Информация о списании на текущий месяц
		/// </summary>
		public PeriodExpensesInfo CurrentMonth = new PeriodExpensesInfo();
		
		/// <summary>
		/// Информация о списании на текущий день
		/// </summary>
		public PeriodExpensesInfo CurrentDay = new PeriodExpensesInfo();
	}
}
