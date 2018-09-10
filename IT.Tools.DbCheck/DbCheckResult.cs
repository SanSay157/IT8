using System;
using System.Collections.Specialized;
using System.Text;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// ��������� ���������� �������� ������������ ��
	/// </summary>
	public struct DbCheckResult
	{
		private bool m_bSuccess;

		private StringCollection m_aErrors;

		/// <summary>
		/// ����, ������������, ��� �������� ��������� �������
		/// </summary>
		public bool Success
		{
			get { return this.m_bSuccess; }
			set { this.m_bSuccess = value; }
		}

		/// <summary>
		/// ������ ������, ��������� � ���������� ��������
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
		/// ��������� ����� ������
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
					sb.Append("�������� ���� � �� ������� ������:");

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
