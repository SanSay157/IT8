using System;
using System.Collections.Specialized;
using System.Text;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Результат выполнения проверки корректности БД
	/// </summary>
	public struct DbCheckResult
	{
		private bool m_bSuccess;

		private StringCollection m_aErrors;

		/// <summary>
		/// Флаг, показывающий, что проверка выполнена успешно
		/// </summary>
		public bool Success
		{
			get { return this.m_bSuccess; }
			set { this.m_bSuccess = value; }
		}

		/// <summary>
		/// Список ошибок, возникших в результате проверки
		/// </summary>
		public StringCollection Errors
		{
			get { return this.m_aErrors; }
			set { this.m_aErrors = value; }
		}

		public DbCheckResult(bool success, StringCollection errors)
		{
			this.m_bSuccess = success;
			this.m_aErrors = errors;
		}

		/// <summary>
		/// Суммарный текст ошибок
		/// </summary>
		public string ErrorsText
		{
			get
			{
				if (Success)
				{
					return null;
				}
				else
				{
					StringBuilder sb = new StringBuilder();
					sb.Append("Проверка кода в БД выявила ошибки:");

					foreach (string error in Errors)
					{
						sb.Append(Environment.NewLine);
						sb.Append(error);
					}

					return sb.ToString();
				}
			}
		}
	}
}
