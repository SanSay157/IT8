//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
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
	/// ����� �������
	/// </summary>
	public sealed class Utils
	{
		private Utils()
		{}
        
		/// <summary>
		/// ����������� �������� ���������� ����� � ������ ���� "� ���� Y ����� Z �����"
		/// </summary>
		/// <param name="nMinutes">���������� �����</param>
		/// <param name="nWorkdayDurationInMinutes">���������� ����� � ���</param>
		/// <returns>������ � ��������������� �������������� ��������� �������</returns>
		public static string FormatTimeDuration(int nMinutes, int nWorkdayDurationInMinutes)
		{
			if (nWorkdayDurationInMinutes <= 0)
				throw new ArgumentException( "�������� nWorkdayDurationInMinutes ������ ���� ������ ����", "nWorkdayDurationInMinutes" );
			
			// ���������, �������, ��� ���� �������������� ������������� �������� � 
			// ������������ ������� ����������; �� ������ ��� � �����. � �������� ��� 
			// ����� ��� �� ��������� - ���������� "-" ����� ��������� ��������������: 
			// ��� ����� �������� ��� ���������� ����� ���� �������������, � �������
			// ���������� �������� �����:
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
				bld.Append(GetNumericEnding(nTimeInDays, " ����", " ���", " ����"));
			}
			if (nTimeInHours > 0)
			{
				if (nTimeInDays > 0)
					bld.Append(" ");
				bld.Append(nTimeInHours);
				bld.Append(GetNumericEnding(nTimeInHours, " ���", " ����", " �����"));
			}
			if (nTimeInMinutes > 0)
			{
				if (nTimeInDays + nTimeInHours > 0)
					bld.Append(" ");
				bld.Append(nTimeInMinutes);
				bld.Append(GetNumericEnding(nTimeInMinutes, " ������", " ������", " �����"));
			}
			if (bld.Length == 0)
				bld.Append("0 �����");

			if (bIsNegativeDuration)
				bld.Insert( 0, "- ");

			return bld.ToString();
		}
        public static string GetNumericEnding(int val, string word1, string word2, string word5)
        {
            int nCnt10;	// ����� ��������
            int nCnt1;	// ����� ������

            val = val % 100;	// �������� ���-�� �����
            nCnt10 = val / 10;	// ������� ���������� ��������
            nCnt1 = val % 10;	// ������� ���������� ������

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
        /// ����������� ������ �� � ����� � ��������� �������
        /// � ���������� ����������
        /// </summary>
        /// <param name="sIn">������ ���������� �����</param>
        /// <returns>������������� �����</returns>
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
        ///  ��������� ������ ���������� �� ����������
        /// </summary>
        /// <param name="r">�����</param>
        /// <returns>������� � �������������� �������</returns>
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
        /// ���������� ������ ���������� � ������
        /// </summary>
        /// <param name="reader">�����</param>
        /// <returns>�������������� ������ ������</returns>
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
