//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
// ��� ������������ ������ "��������� ������ �������������"
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Text;
using Croc.IncidentTracker.Utility;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.ReportService;
using Croc.XmlFramework.ReportService.FOWriter;
using Croc.XmlFramework.ReportService.Types;

namespace Croc.IncidentTracker.ReportService.Reports
{
	/// <summary>
	/// ���������� ������ "��������� ������ �������������"
	/// </summary>
	public class r_DepartmentExpensesStructure: CustomITrackerReport 
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
		/// <summary>
		/// "����" ��������
		/// </summary>
		internal enum ExpTypes 
		{
			OnIncident = 0,			// �������� �� ���������, ��� ���������� �� "�������" / "����������"
			OnIncidentExternal = 1,	// �������� �� ��������� �� "�������" �����������
			OnIncidentInternal = 2,	// �������� �� ��������� �� "����������" �����������
			OnCauseFolder = 3,		// �������� �� ����������, ��� ���������� �� "�������" / "����������"
			OnCauseExternal = 4,	// �������� �� "�������" ����������
			OnCauseInternal = 5,	// �������� �� "����������" ����������
			OnCauseLoss = 6			// ������������ ��������
		}
		
		
		/// <summary>
		/// ���������� ����� ������������� �������� ������ ��������. ������������ ��� ��������� 
		/// ������ ����������� �� �������� �������� (�) ��� ������������ ���������,
		/// (�) ��� ����������� ������������ �/� �������� � GUID-�� ������� ��������
		/// �� ��������������� ������.
		/// </summary>
		internal class ExpenseCausesMapper 
		{
			/// <summary>
			/// �������� ����� ������� ��������
			/// </summary>
			private struct ExpenseCauseInfo 
			{
				/// <summary>
				/// ������������� ������� ��������;
				/// </summary>
				public Guid CauseID;
				/// <summary>
				/// "���" ������� �������� (�������� / ����������� / ���������
				/// ��������� � ������ �������� �� ������)
				/// </summary>
				public TimeLossCauseTypes CauseType;
				/// <summary>
				/// ������������ ������� ��������
				/// </summary>
				public string Name;
			}
			
			
			/// <summary>
			/// �������� "���������" ������ �������� (��������, ����������� � ������)
			/// </summary>
			private ArrayList m_aActivityExpenses = new ArrayList();
			/// <summary>
			/// �������� "�����������" ������ �������� (��������, �� ����������� � ������)
			/// </summary>
			private ArrayList m_aNonActivityExpenses = new ArrayList();

			/// <summary>
			/// ��������� ������������� 
			/// </summary>
			/// <param name="cn">���������� � ��</param>
			public void Init( IReportDataProvider dataProvider) 
			{
                using (IDataReader reader = dataProvider.GetDataReader("dsExpencesCauses", null))
					{
						if ( !reader.Read() )
							throw new ApplicationException("������ ��������� ������� �������� ������ �������� - ������� ������ �����!");
						do
						{
							ExpenseCauseInfo info = new ExpenseCauseInfo();
							info.CauseID = reader.GetGuid( reader.GetOrdinal("ObjectID") );
							info.CauseType = (TimeLossCauseTypes)( (int)reader.GetValue(reader.GetOrdinal("Type")) );
							info.Name = reader.GetString( reader.GetOrdinal("Name") );

							ExpTypes enExpType = (ExpTypes)( (int)reader.GetValue(reader.GetOrdinal("CauseExpType")) );
							if ( ExpTypes.OnCauseFolder == enExpType )
								m_aActivityExpenses.Add( info );
							else if ( ExpTypes.OnCauseLoss == enExpType )
								m_aNonActivityExpenses.Add( info );
							else
								throw new ApplicationException("������ ����������� ���� �������� (��������� / �����������) - ���, �� ���������� ���������: " + enExpType.ToString() );
						}
						while( reader.Read());
					}
			}

			
			/// <summary>
			/// ��������� ������� ������������ ������� ��� ������ ������ ��������,
			/// � ������������ � ��������� ����� (��������� / �����������)
			/// </summary>
			/// <param name="enExpType">��� ��������</param>
			/// <returns>������ ����� � ������������� �������</returns>
			public ArrayList GetColumnsNames( ExpTypes enExpType ) 
			{
				ArrayList aInfos = null;
				if ( ExpTypes.OnCauseFolder == enExpType )
					aInfos = m_aActivityExpenses;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					aInfos = m_aNonActivityExpenses; 
				else
					throw new ArgumentException( 
						String.Format(
						"������������ ���� �������� enExpType (���������/�����������) - " + 
						"��������� ��� {0} �� �������� ���������", enExpType ),
						"enExpType" );

				ArrayList aNames = new ArrayList();
				foreach( ExpenseCauseInfo item in aInfos )
					aNames.Add( item.Name );
				return aNames;
			}


			/// <summary>
			/// ���������� ��������� ������ � ����� ������� ���� ��������, �����������
			/// �� ��������, � ����������� �� �������������� "��������� / ���-���������
			/// ��������"
			/// </summary>
			/// <param name="enExpType">��� ��������</param>
			/// <returns>��������� ������</returns>
			public int GetColumnsIndexesBase( ExpTypes enExpType ) 
			{
				if ( ExpTypes.OnCauseFolder == enExpType )
					return 0;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					return m_aActivityExpenses.Count; 
				else
					throw new ArgumentException( 
						String.Format(
							"������������ ���� �������� enExpType (���������/�����������) - " + 
							"��������� ��� {0} �� �������� ���������", enExpType ),
						"enExpType" );
			}
			
			
			/// <summary>
			/// ���������� ������ � ����� ������� ���� ��������, ����������� �� ��������, 
			/// � ����������� �� �������������� ������� �������� � �������������� � ����
			/// "��������� / ���-��������� ��������"
			/// </summary>
			/// <param name="uidExpenseCauseID">������������� ������� ��������</param>
			/// <param name="enExpType">��� ��������</param>
			/// <returns>������ � ������� � ������� ��������</returns>
			public int GetColumnIndex( Guid uidExpenseCauseID, ExpTypes enExpType ) 
			{
				if ( ExpTypes.OnCauseExternal == enExpType || ExpTypes.OnCauseInternal == enExpType )
					enExpType = ExpTypes.OnCauseFolder;

				ArrayList aInfos = null;
				int nIndexBase = ( ExpTypes.OnCauseLoss == enExpType? m_aActivityExpenses.Count : 0 );
				if ( ExpTypes.OnCauseFolder == enExpType )
					aInfos = m_aActivityExpenses;
				else if ( ExpTypes.OnCauseLoss == enExpType )
					aInfos = m_aNonActivityExpenses;
				else 
					return -1;

				int nRetIndex=0; 
				foreach( ExpenseCauseInfo item in aInfos )
				{
					if ( item.CauseID == uidExpenseCauseID)
						return nIndexBase + nRetIndex;
					else
						nRetIndex++;
				}
				return -1;
			}
		
			
			/// <summary>
			/// ����� ���������� ��������� � ������� ���� ��������, ����������� �� ��������
			/// </summary>
			public int ColumnQnt 
			{
				get { return m_aActivityExpenses.Count + m_aNonActivityExpenses.Count; }
			}

		}
		
		
		/// <summary>
		/// ���������� �����, �������������� ��� ���������� ��������� ������
		/// </summary>
		public class ThisReportParams 
		{
			#region ��������� ������
			
			/// <summary>
			/// ����� ������
			/// </summary>
			public RepDepartmentExpensesStructure_ReportForm ReportForm;
			
			/// <summary>
			/// ���� ������ ��������� ������� (������������)
			/// </summary>
			public object IntervalBegin;
			/// <summary>
			/// �������, ��� ���� ������ ��������� ������� ������
			/// </summary>
			public bool IsSpecifiedIntervalBegin;
			/// <summary>
			/// ���� ����� ��������� ������� (������������)
			/// </summary>
			public object IntervalEnd;
			/// <summary>
			/// �������, ��� ���� ����� ��������� ������� ������
			/// </summary>
			public bool IsSpecifiedIntervalEnd; 

			/// <summary>
			/// �������� ��������������� �����������
			/// </summary>
			public string OrganizationIDs;
			/// <summary>
			/// �������� ��������������� �������������
			/// </summary>
			public string DepartmentIDs;
			/// <summary>
			/// ����� ������������� ������
			/// </summary>
			public RepDepartmentExpensesStructure_AnalysisDepth AnalysisDepth;

			/// <summary>
			/// ��������� ������������ ������� (������� �����, ���� ���� �����)
			/// </summary>
			public RepDepartmentExpensesStructure_OptColsFlags ShownColumns;

			/// <summary>
			/// ������� ���������� ������ �����������, ��������� �� ����� ���������
			/// ��������� �������
			/// </summary>
			public bool PassRedundant;

            /// <summary>
            /// ������� ���������� ������ ���������������� �����������
            /// </summary>
            public bool PassDisabled;

			/// <summary>
			/// ����� ������������ ������
			/// </summary>
			public RepDepartmentExpensesStructure_DataFormat DataFormat;
			/// <summary>
			/// ����� �� ������� ��� ���� ������� ��������� (����� �� ������� 
			/// ������� �� 100%; ���� ���� ����� � False, �� ������� ����� ��
			/// ������). ����� �����, ���� DataFormat ������ ����������� ������
			/// � ���������.
			/// </summary>
			public bool ColumnSumAsPercentBase;
			/// <summary>
			/// ����� ������������� �������: 0 - ���, ����, ������; 1 - ����. 
			/// ����� �����, ���� DataFormat ������ ����������� ������ � ����
			/// �������.
			/// </summary>
			public TimeMeasureUnits TimeMeasure;

			/// <summary>
			/// �������� ��������������� ����� ����������� (������� ActivityType),
			/// ������� �� ������� ����� ��������������� ��� "�������". ������������
			/// ��� �������� �������� ������� "����������� ����������" (��. ShownColumns)
			/// � ���� ������ ������ ���� ����� ���� �� ���� ��� �����������; ����� 
			/// �������� ��������� ������������.
			/// </summary>
			public string ActivityTypesAsExternalIDs;

			/// <summary>
			/// ������� ����������� ������ � ������ �� ��������������.
			/// </summary>
			public bool DoGroup;
			/// <summary>
			/// ���������� ������ � ������. ���������� ByDisbalance � ByUtilization �����
			/// ����� ������ � ������ ��������� � ����� ��������������� �������; 
			/// </summary>
			public RepDepartmentExpensesStructure_SortingMode SortingMode;
			/// <summary>
			/// ������� ��������� � ��������� ������ �������� ����������
			/// </summary>
			public bool ShowRestrictions;

			#endregion

			/// <summary>
			/// ������������������� �����������. �������������� �������� ������ �� 
			/// ��������� ������ ����������, �������������� � ��������� ReportParams. 
			/// </summary>
			/// <param name="Params">������ ���������, ������������ � �����</param>
			/// <remarks>
			/// ��� ������������� ��������� ��������� �������� ����������, ��������� 
			/// �� ���������, � ��� �� ������ ������������� ���������� (����� ��� 
			/// "����������� ����������")
			/// </remarks>
			public ThisReportParams( ReportParams Params ) 
			{
				// #1: ���������� ���������

				ReportParams.ReportParam oParam;

				// ����������� ����� ������
				ReportForm = (RepDepartmentExpensesStructure_ReportForm)((int)Params.GetParam("ReportForm").Value);
				
				// ������� ��� ������ � ����� ��������� �������
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );

				// ����������� �������� ������: �������������� ����������� / �������������
				OrganizationIDs = String.Empty;
				if ( Params.IsParamExists("Organizations") )
				{
					oParam = Params.GetParam("Organizations");
					OrganizationIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString().Trim() );
				}
				DepartmentIDs = String.Empty;
				if ( Params.IsParamExists("Departments") )
				{
					oParam = Params.GetParam("Departments");
					DepartmentIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString().Trim() );
				}
				// ����� ������������� ������
				AnalysisDepth = (RepDepartmentExpensesStructure_AnalysisDepth)((int)Params.GetParam("AnalysisDepth").Value);

				// ��������� ������������ �������:
				ShownColumns = (RepDepartmentExpensesStructure_OptColsFlags)((int)Params.GetParam("ShownColumns").Value);

				// ������� ���������� ������ ��������� �����������
				PassRedundant = ( 0!= (int)Params.GetParam("PassRedundant").Value );

                //������� ���������� ������ ���������������� �����������
			    PassDisabled = (0 != (int) Params.GetParam("PassDisabled").Value);

				// ����� ������������ ������
				DataFormat = (RepDepartmentExpensesStructure_DataFormat)((int)Params.GetParam("DataFormat").Value);
				// ����, ������������ ������ ������� ���������� ���������
				ColumnSumAsPercentBase = ( 0 != (int)Params.GetParam("ExpensesSumAsPercentBase").Value );
				// ������������� �������
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);

				// ���� �����������, ������� �� ������� ��������������� ��� "�������" 
				ActivityTypesAsExternalIDs = String.Empty;
				if ( Params.IsParamExists("ActivityTypesAsExternal") )
				{
					oParam = Params.GetParam("ActivityTypesAsExternal");
					ActivityTypesAsExternalIDs = ( oParam.IsNull? String.Empty : oParam.Value.ToString() );
				}

				// ����������
				SortingMode = (RepDepartmentExpensesStructure_SortingMode)((int)Params.GetParam("SortingMode").Value);
				// ������� ����������� ������ �� ��������������
				DoGroup = ( 0 != (int)Params.GetParam("DoGroup").Value );
				// ������� ����������� ���������� ������ � ���������
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );


				// #2: �������� ���������� ������������ �������� ����������:
				// TODO!
			}

			
			/// <summary>
			/// ��������������� ����� -�������: �������� "������������" ������������
			/// ������� ������, ��������� ������ 
			/// </summary>
			/// <param name="flag">����, �����. ����������� �������</param>
			/// <returns>1, ���� ������� ��������, 0 - �����</returns>
			public int IsShowColumn( RepDepartmentExpensesStructure_OptColsFlags flag ) 
			{
				return ( ((int)(ShownColumns & flag)) > 0? 1 : 0 );
			}
			
			
			/// <summary>
			/// ��������� ����� XSL-FO, �������������� ������ �������� ����������, � 
			/// ���������� ��� ��� ����� ������������ ������������ ������
			/// </summary>
			/// <param name="foWriter"></param>
			/// <param name="cn"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter, IReportDataProvider dataProvider ) 
			{
				// XSL-FO � �������� ���������� ����� �������� ����:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;				// ��������� ������ � �������������� �������� ���������
				string sActivityTypesNames;		// ������ � �������� ������������ ����� �����������

				// #1: ����� ������:
				sbBlock.Append( getParamValueAsFoBlock( 
						"����� ������", 
						RepDepartmentExpensesStructure_ReportFormItem.GetItem(ReportForm).Description
					));
				
				// #2: ���� ������ � ��������� ��������� �������. 
				// ����� �� ���� ��� ����� ���� �� ������; ���� ��� ���, �� 
				// � ��������� ������ ��������� ��������������� ��������:
				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = "(�� ������)";
				sbBlock.Append( getParamValueAsFoBlock( "���� ������ ��������� �������", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = "(�� ������)";
				sbBlock.Append( getParamValueAsFoBlock( "���� ��������� ��������� �������", sParamValue ) );
				
				// #3: ������� �����: �������� ����������� � �������������
				// ������ �������� ������������ ����� �����������
				sParamValue = String.Empty;
				sActivityTypesNames = String.Empty;

                using (IDataReader reader = dataProvider.GetDataReader("dsOrganizationAndDepartments", this))
						while( reader.Read() )
						{
							if ( 0 == reader.GetInt32(0) ) 
								sActivityTypesNames += reader.GetString(1) + ", ";
							else
								sParamValue += reader.GetString(1) + ", ";
						}
				if (sActivityTypesNames != String.Empty)
					sActivityTypesNames = sActivityTypesNames.TrimEnd( ',', ' ' );
				if (sParamValue != String.Empty)
					sParamValue = sParamValue.TrimEnd( ',', ' ' );
				sbBlock.Append( getParamValueAsFoBlock( "������������� ������", sParamValue ) );

				// �������� ������� ������� (�� ����� ��� ��� �� "����������"):
				sbBlock.Append( getParamValueAsFoBlock( 
						"������� ������� ������", 
						RepDepartmentExpensesStructure_AnalysisDepthItem.GetItem(AnalysisDepth).Description
					));

				
				// #4: ��������� ������������ ������� 
				sParamValue = RepDepartmentExpensesStructure_OptColsFlagsItem.ToStringOfDescriptions( ShownColumns );
				sbBlock.Append( getParamValueAsFoBlock( 
						"������������ �������",
						( sParamValue.Length > 0 ? sParamValue : "(��� ������������ ������� ������)" )
					));

				
				// #5: ���� ������ ��������� �����������:
				sbBlock.Append( getParamValueAsFoBlock(
                        "��������� ������ ��������� �����������",
						( PassRedundant ? "��" : "���" )
					));

                // #6: ���� ������ ���������������� �����������:
                sbBlock.Append(getParamValueAsFoBlock(
                        "��������� ������ ���������������� �����������",
                        (PassDisabled ? "��" : "���")
                    ));

				// #7: ������ ������������� ������: 
				sbBlock.Append( getParamValueAsFoBlock( 
						"������������� ������",
						RepDepartmentExpensesStructure_DataFormatItem.GetItem(DataFormat).Description
					));
				// ...���� ����� ������������� ������ �� �������� ��������, 
				// �� ����������� ���������� ���� �� ������������:
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyTime == DataFormat )
					sParamValue = "(�� ������������)";
				else
					sParamValue = ( ColumnSumAsPercentBase? "����� ������ �� �������" : "����� ������ �� ������" );
				sbBlock.Append( getParamValueAsFoBlock( "�� 100% �����", sParamValue ) ); 
				// ...����������, ���� ����� ������������� ������� �� �������� ����� 
				// ����������� �������, �� ����� ��� ������������� - �� ������������:
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyPercent == DataFormat )
					sParamValue = "(�� ������������)";
				else
					sParamValue = TimeMeasureUnitsItem.GetItem(TimeMeasure).Description;
				sbBlock.Append( getParamValueAsFoBlock( "������������� �������", sParamValue ) );

				// #8: ���� ����� ������������ ������������ ������� ���� (��������)
				// "����������� ����������", �� ����� ����� ��� �� ������� �������
				// ����� ����������� (NB: ��� �������� ������������ �������� ����� 
				// ��� ����������� �� ������� - ��� ����� ����������� ������):
				if ( (int)(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization & ShownColumns) > 0 )
					sbBlock.Append( getParamValueAsFoBlock( "���� ��������� �����������", sActivityTypesNames ) );

				// #9: ����� ���������: 
				// ...����������:
				sbBlock.Append( getParamValueAsFoBlock( 
						"����������", 
						RepDepartmentExpensesStructure_SortingModeItem.GetItem(SortingMode).Description
					));
				// ...����������� ������ �� �������������:
				sbBlock.Append( getParamValueAsFoBlock( 
						"������������ ������ �� ��������������", 
						(DoGroup? "��" : "���") 
					));

				
				// ����� ������������:
				foWriter.AddSubHeader( 
					@"<fo:block text-align=""left"" font-weight=""bold"">��������� ������:</fo:block>" + 
					sbBlock.ToString()
				);
			}


			/// <summary>
			/// ���������� �����, ��������� ����� XSL-FO ����� ������������� ���������,
			/// �������������� ���� "������������ ���������" � "�������� ���������".
			/// ������������ ��� ������������ XSL-FO-������ � �������� �������� ����������
			/// </summary>
			/// <param name="sParamName">������������ ���������</param>
			/// <param name="sParamValueText">����� �� ��������� ���������</param>
			/// <returns>������ � ������� XSL-FO �����</returns>
			private string getParamValueAsFoBlock(   string sParamName, string sParamValueText ) 
			{
				return String.Format(
					"<fo:block text-align=\"left\"><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
					xmlEncode(sParamName),
					xmlEncode(sParamValueText)
				);
			}
		}


		/// <summary>
		/// ��� ��������� ������� ������
		/// </summary>
		private ThisReportParams m_oParams;
		/// <summary>
		/// ��������� ������������� �������� ������ ��������
		/// </summary>
		private ExpenseCausesMapper m_oMapper;

		/// <summary>
		/// ����������������� �����������, ��������� ����������� ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_DepartmentExpensesStructure( reportClass ReportProfile, string ReportName ) 
			: base(ReportProfile, ReportName) 
		{}
		/// <summary>
		/// ����� ������������ ������. ���������� �� ReportService
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="Params"></param>
		/// <param name="Provider"></param>
		/// <param name="cn"></param>
		/// <param name="CustomData"></param>
		protected  void buildThisReport( XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData ) 
		{
			// ������� ���������:
			m_oParams = new ThisReportParams( Params);

			// ������������ �������� ������ �������� - ������ ���� ��� ����������:
			m_oMapper = new ExpenseCausesMapper();
			if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				m_oMapper.Init( Provider );
			
			// ������������ ������
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ���������
			foWriter.Header( "��������� ������ �������������" );
			// ��������� ������ � ���������?
			if (m_oParams.ShowRestrictions)
				m_oParams.WriteParamsInHeader( foWriter, Provider );

            writeBody(foWriter, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}
	

		/// <summary>
		/// ������������ "����" ������ 
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter fo, IReportDataProvider dataProvider ) 
		{
			// ��������� ������� ������� ������: 
            IDataReader reader = getReportData(dataProvider, m_oParams);
			if ( !reader.Read() )
			{
				writeEmptyBody( fo, "��� ������" );
				return;
			}

			fo.TStart( true, ITRepStyles.TABLE, false );

			// ��������� ��������� ������:
			int nColumnQnt = writeHeader( fo );

			if (RepDepartmentExpensesStructure_ReportForm.ByEmployee == m_oParams.ReportForm ||
				RepDepartmentExpensesStructure_ReportForm.ByDepartment == m_oParams.ReportForm)
			{
				#region �����-1 � �����-2

				ThisReportRow_Form1 rowTotal = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );
				rowTotal.FixedRowName = "�����";
				ThisReportRow_Form1 rowSubTotal = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );
				rowSubTotal.FixedRowName = "����� �� ������������� (�����������)";
				ThisReportRow_Form1 rowCurr = new ThisReportRow_Form1( reader, m_oParams, m_oMapper );

				int nOrdIsGroupRow = reader.GetOrdinal("IsGroupRow");

				int nRowNum = 1;
				bool bMoreRows = rowTotal.ReadRow(reader);
				for( ; bMoreRows; )
				{
					bool bIsGroupRow = reader.GetBoolean(nOrdIsGroupRow);
					
					if (bIsGroupRow)
					{
						// ��������������� ������ - ��������������
						if (m_oParams.DoGroup)
						{
							if (rowSubTotal.HasSome)
								rowSubTotal.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR, rowTotal );
							
							rowSubTotal.Zeroing();
							bMoreRows = rowSubTotal.ReadRow(reader);
							
							// ��������� ��������� ������
							fo.TRStart();
							fo.TRAddCell( xmlEncode(rowSubTotal.RowName), "string", nColumnQnt, 1, ITRepStyles.GROUP_HEADER );
							fo.TREnd();
						}
						else
							throw new ApplicationException("������ ��������� ������: ��� ����������� ����������� �������� �������������� ������");
					}
					else
					{
						// �������� ������ ����� ������ � ������� � �����:
						bMoreRows = rowCurr.ReadRow( reader );
						rowCurr.RowNum = nRowNum++;
						rowCurr.WriteRow( fo, ITRepStyles.TABLE_CELL, ITRepStyles.TABLE_CELL_COLOR_GREEN, m_oParams.DoGroup? rowSubTotal : rowTotal );
						rowCurr.Zeroing();
					}
				}
				if (m_oParams.DoGroup && rowSubTotal.HasSome)
					rowSubTotal.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR, rowTotal );
				// ������� ������ � �������:
				rowTotal.WriteRow( fo, ITRepStyles.TABLE_FOOTER, null, rowTotal );

				#endregion
			}
			else if (RepDepartmentExpensesStructure_ReportForm.ByEmployeeWithTasksDetali == m_oParams.ReportForm)
			{
				#region �����-3 

				ThisReportRow_Form2 rowTotal = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowTotal.Name = "�����";
				ThisReportRow_Form2 rowSub = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowSub.Name = "����� �� �������������";  
				ThisReportRow_Form2 rowCurr = new ThisReportRow_Form2( reader, "EmpID", m_oParams.TimeMeasure );
				rowCurr.NameColumn = "EmpName";

				int nTrackGroupID = -1;
				if ( m_oParams.DoGroup )
					nTrackGroupID = reader.GetInt32( reader.GetOrdinal("UnitID") );
                int nCurrGroupID = -1;

				int nRowNum = 1;
				for( bool bMoreRows = true; bMoreRows; )
				{
					// "��������������" ������ �������� � �������������� ����� 
					// ��� ���������� ����������� (����� ��� ������ �� �����):
                    if (m_oParams.DoGroup && ((nCurrGroupID != nTrackGroupID) || (nCurrGroupID==-1)))
					{
						// ��������� ����. ������:
						fo.TRStart();
						fo.TRAddCell( reader.GetString(reader.GetOrdinal("GrpName")), "string", nColumnQnt, 1, ITRepStyles.GROUP_HEADER );
						fo.TREnd();
                        if (nCurrGroupID != -1)
                        {
                            nTrackGroupID = nCurrGroupID;
                        }
					}

					// �������� ������ �� ������ ���������� � ������� �����. ������ ������:
					bMoreRows = rowCurr.ReadRow( reader );
					rowCurr.RowNum = nRowNum++;
					rowCurr.WriteRow( fo, ITRepStyles.TABLE_CELL, ITRepStyles.TABLE_CELL_COLOR_GREEN );

					// �������� �����:
					if ( m_oParams.DoGroup )					
						rowSub.Summarize( rowCurr );
					rowTotal.Summarize( rowCurr );
					rowCurr.Zeroing();

					// ���� (�) ���� �����������, � (�.1) ����� �� ����. ������ 
					// ��� (�.2) ������ ���� �����, �� -- ������� �������:
					if ( m_oParams.DoGroup && bMoreRows )
						nCurrGroupID = reader.GetInt32( reader.GetOrdinal("UnitID") );	
					if ( m_oParams.DoGroup && (nCurrGroupID!=nTrackGroupID || !bMoreRows) )
					{
						rowSub.WriteRow( fo, ITRepStyles.GROUP_FOOTER, ITRepStyles.GROUP_FOOTER_COLOR );
						rowSub.Zeroing();
					}
				}
				// ������� ������ � �������:
				rowTotal.WriteRow( fo, ITRepStyles.TABLE_FOOTER, null );

				#endregion
			}
			else 
				throw new ApplicationException("����������� ����� ������ " + m_oParams.ReportForm.ToString());

			fo.TEnd();
		}

		
		#region ������ ������������� ����� ������ ������

		/// <summary>
		/// �����, ��� ���� � ������������� ����� ������� ���� ����
		/// </summary>
		internal abstract class ThisReportRow 
		{
			public bool HasSome = false;

			public int RowNum;
			public int DayRate; 

			protected int m_nOrdDayRate;
			
			protected TimeMeasureUnits m_enTimeMeasure;
			protected string m_sExpenseCellType;

			/// <summary>
			/// ������������������� �����������
			/// </summary>
			/// <param name="enTimeMeasure"></param>
			public ThisReportRow( TimeMeasureUnits enTimeMeasure ) 
			{
				m_enTimeMeasure = enTimeMeasure;
				m_sExpenseCellType = ( TimeMeasureUnits.Days==m_enTimeMeasure? "string" : "r8" );
			}
			
			protected int safeGetInt( IDataReader reader, int nOrdinal ) 
			{
				if ( reader.IsDBNull(nOrdinal) )
					return 0;
				else
					return reader.GetInt32(nOrdinal);
			}

			
			protected string formatExpenseValue( int nValue ) 
			{
				return 
					TimeMeasureUnits.Days == m_enTimeMeasure ?
						Utils.FormatTimeDuration( nValue, (0==nValue && 0==DayRate? 1 : DayRate) ) :
					(nValue/60.0).ToString("0.00");
			}


			protected void writeExpenseCell( XslFOProfileWriter fo, int nValue, string sCellClassName ) 
			{
				fo.TRAddCell( formatExpenseValue(nValue), m_sExpenseCellType, 1, 1, sCellClassName);
			}
		}

		
		/// <summary>
		/// ������������� ������ ������ ������ � ������ ����
		/// </summary>
		internal class ThisReportRow_Form1 : ThisReportRow 
		{
			public string FixedRowName = null;

			public bool IsGroupRow = false;
			public string TrackRowID;
			public string RowName;
			public string RowLinkInfo;

			public int PeriodRate;
			
			public int ExpOnTasksExt;
			public int ExpOnTasksInt;
			public int ExpOnCausesExt;
			public int ExpOnCausesInt;
			public int ExpOnCausesLoss;
			public int[] ExpsOnCausesDetail;

			private RepDepartmentExpensesStructure_OptColsFlags m_enShownColumn;
			private RepDepartmentExpensesStructure_DataFormat m_enDataFormat;
			private bool m_bColumnSumAsPercentBase = false;
			private ExpenseCausesMapper m_oMapper;

			private int m_nOrdIsGroupRow;
			private int m_nOrdTrackRowID;
			private int m_nOrdRowName;
			private int m_nOrdRowLinkInfo;

			private int m_nOrdPeriodRate;

			private int m_nOrdExpType;
			private int m_nOrdExpCause;
			private int m_nOrdExpenses;
			public int m_nDisbalance;
			public int Disbalance;
			public 	ThisReportRow_Form1( 
				IDataReader reader, 
				ThisReportParams oParams, 
				ExpenseCausesMapper oMapper ) : base(oParams.TimeMeasure)
			{
				m_enShownColumn = oParams.ShownColumns;
				m_enDataFormat = oParams.DataFormat;
				m_bColumnSumAsPercentBase = oParams.ColumnSumAsPercentBase;
				m_oMapper = oMapper;

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
					ExpsOnCausesDetail = new int[oMapper.ColumnQnt];

				// �������� �������� ��� ���� �������� ������� ����������:
				m_nOrdIsGroupRow = reader.GetOrdinal("IsGroupRow");
				m_nOrdTrackRowID = reader.GetOrdinal("RowID");
				m_nOrdRowName = reader.GetOrdinal("RowName");
				try { m_nOrdRowLinkInfo = reader.GetOrdinal("RowLinkInfo"); }
				catch( IndexOutOfRangeException ) { m_nOrdRowLinkInfo = -1; }

				m_nOrdDayRate = reader.GetOrdinal("DayRate");
				m_nOrdPeriodRate = reader.GetOrdinal("PeriodRate");
				m_nOrdExpType = reader.GetOrdinal("ExpType");
				m_nOrdExpCause = reader.GetOrdinal("ExpCause");
				m_nOrdExpenses = reader.GetOrdinal("Expenses");
				try { m_nDisbalance = reader.GetOrdinal("Disbalance"); }
				catch( IndexOutOfRangeException ) { m_nDisbalance = -1;}
				
			}

			
			/// <summary>
			/// ��� ����...
			/// </summary>
			/// <param name="reader"></param>
			/// <returns></returns>
			public bool ReadRow( IDataReader reader ) 
			{
				bool bGetCauseDetalization = isShowColumn( RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization );
				if ( bGetCauseDetalization && (null==ExpsOnCausesDetail || null==m_oMapper) ) 
					throw new ApplicationException( "������ ������ ������ ����������� ������ �� ��������: ��� ����������� ����� ���������!" );

				// ������� �������������� ������:
				IsGroupRow = reader.GetBoolean(m_nOrdIsGroupRow);

				// ������������� ������ �����, ����������� � ����� ���������� "������" ������:
				if ( !reader.IsDBNull(m_nOrdTrackRowID) )
					TrackRowID = reader.GetValue(m_nOrdTrackRowID).ToString();
				else
					TrackRowID = String.Empty;

				// ������������ ��� ������ � ���� �� ������������� / ���������� - ���������:
				RowName = (reader.IsDBNull(m_nOrdRowName) ? String.Empty : reader.GetString(m_nOrdRowName));
				// ... ��� � ��������� ������:
				if (-1!=m_nOrdRowLinkInfo)
					RowLinkInfo = (reader.IsDBNull(m_nOrdRowLinkInfo) ? null : reader.GetString(m_nOrdRowLinkInfo));
				// ... ��� � �������� ����:
				DayRate = safeGetInt( reader, m_nOrdDayRate );
				PeriodRate = safeGetInt( reader, m_nOrdPeriodRate );
				
				bool bMoreRows = true;
				for( ; bMoreRows; )
				{
					int nValue = safeGetInt( reader, m_nOrdExpenses );
					if ( 0!=nValue && 0==DayRate )
						throw new ApplicationException( "������ ������� ������ ������: �������� �������� �� ���� ����� ��������, ��� ������� ����� �������� ���!" );

					// ���� ExpType ���� NULL, �� ������������� ��� ��� 0 ���� �� ��������, 
					// ��� ��� � ���� ������ � Expenses - NULL, �.�. 0
					ExpTypes enExpType = (ExpTypes)safeGetInt( reader, m_nOrdExpType ); 
					switch ( enExpType )
					{
						case ExpTypes.OnIncident:
						case ExpTypes.OnIncidentExternal:
							ExpOnTasksExt += nValue; break;
						
						case ExpTypes.OnIncidentInternal:
							ExpOnTasksInt += nValue; break;

						case ExpTypes.OnCauseFolder:
						case ExpTypes.OnCauseExternal:
							ExpOnCausesExt += nValue; break;

						case ExpTypes.OnCauseInternal:
							ExpOnCausesInt += nValue; break;

						case ExpTypes.OnCauseLoss:
							ExpOnCausesLoss += nValue; break;
					}
					if (m_nDisbalance!= -1)
					{
						
						Disbalance += safeGetInt(reader,m_nDisbalance);
						
					}
					// ����������� �� ����������� �� �������� ��������?..
					if (bGetCauseDetalization)
					{
						Guid uidExpenseCauseId = Guid.Empty;
						if (!reader.IsDBNull(m_nOrdExpCause))
							uidExpenseCauseId = reader.GetGuid(m_nOrdExpCause);
						if (Guid.Empty!=uidExpenseCauseId)
							ExpsOnCausesDetail[ m_oMapper.GetColumnIndex(uidExpenseCauseId,enExpType) ] += nValue;
					}

					// ��������� � ��������� ������ ������:
					bMoreRows = reader.Read();
					if ( bMoreRows )
						if ( TrackRowID != reader.GetValue( m_nOrdTrackRowID ).ToString() )
							break;
				}

				HasSome = true;
				return bMoreRows;
			}


			public void Summarize( ThisReportRow_Form1 row ) 
			{
				// ���������:
				// �� ���� ���, �������, �� ������������. �� � ������� �������
				// "��� ������� ������� �������� ���" ��� ������������ ������
				// ������� ���������� ����������� (� ��������, � ������, �����
				// ���� ������ �����) - �� ����� � ��������. ���� ��� �������� 
				// ������� ��, ��� ����� ��� ���� ���������� � �������������. 
				// ������ �� ����� ��� ������������ ������ ���� ����� - ������
				// ���������� (������ �������� �� ������� ���� ������, �.�. 
				// ��� ������������ ������ ������ � ���������� ������� ���� 
				// ���-�� ���������� ������� � "���, ����, ������")
				DayRate = row.DayRate;

				PeriodRate += row.PeriodRate;

				ExpOnTasksExt += row.ExpOnTasksExt;
				ExpOnTasksInt += row.ExpOnTasksInt;
				ExpOnCausesExt += row.ExpOnCausesExt;
				ExpOnCausesInt += row.ExpOnCausesInt;
				ExpOnCausesLoss += row.ExpOnCausesLoss;

				if (null!=ExpsOnCausesDetail && null!=row.ExpsOnCausesDetail)
				{
					// ..."��������������" ��������:
					if (ExpsOnCausesDetail.Length != row.ExpsOnCausesDetail.Length) 
						throw new ApplicationException( "������ ������������ �������� �����: ������������ ����������� ������ �������� �����������!" );
					
					for( int nIdx = 0; nIdx < ExpsOnCausesDetail.Length; nIdx++ )
						ExpsOnCausesDetail[nIdx] += row.ExpsOnCausesDetail[nIdx];
				}

				HasSome = true;
			}

			
			public void Zeroing() 
			{
				IsGroupRow = false;
				TrackRowID = null;
				RowName = null;
				RowLinkInfo = null;
				
				DayRate = 0;
				PeriodRate = 0;
				Disbalance = 0;
				ExpOnTasksExt = 0;
				ExpOnTasksInt = 0;
				ExpOnCausesExt = 0;
				ExpOnCausesInt = 0;
				ExpOnCausesLoss = 0;

				if (null!=ExpsOnCausesDetail)
					for( int nIdx = 0; nIdx < ExpsOnCausesDetail.Length; nIdx++ )
						ExpsOnCausesDetail[nIdx] = 0;
				
				HasSome = false;
			}

			
			public void WriteRow( 
				XslFOProfileWriter fo, 
				string sCellClassName, 
				string sEmphCellClassName, 
				ThisReportRow_Form1 oPercentBaseRow ) 
			{
				if (null==sCellClassName)
					throw new ArgumentNullException( "sCellClassName", "�� ������ ������������ ��������� ������" );
				if (null==sEmphCellClassName || String.Empty==sEmphCellClassName)
					sEmphCellClassName = sCellClassName;
				if (m_bColumnSumAsPercentBase && null==oPercentBaseRow)
					throw new ArgumentNullException( "oPercentBaseRow", "������ ���� ������� ���������� �������� �� ������" );

				// #1: ���������� ������
				
				// ��������� �������� �� ��������:
				int nExpOnTaskAll = ExpOnTasksExt + ExpOnTasksInt;				// ��� ������� �� ����������
				int nExpOnCausesOnFolder = ExpOnCausesExt + ExpOnCausesInt;		// �������� �� �����
				int nExpOnActivity = nExpOnTaskAll + nExpOnCausesOnFolder;		// ������� ���������, �����
				int nExpOnCausesAll = nExpOnCausesOnFolder + ExpOnCausesLoss;	// �������� ���
				int nExpAll = nExpOnTaskAll + nExpOnCausesAll;					// ��� �������� � �����
				int nDisbalance = PeriodRate - nExpAll;							// �������� ���������� 
				if (Disbalance < 0)
					Disbalance = 0;

				// �������� �� ��������, ������������ � ���. ���� ������� ��������� (=100%)
				int nPBExpOnTaskAll = 0;			// ��� ������� �� ����������
				int nPBExpOnCausesOnFolder = 0;		// �������� �� �����
				int nPBExpOnActivity = 0;			// ������� ��������, �����
				int nPBExpOnCausesLoss = 0;			// ������������ ��������
				int nPBExpOnCausesAll = 0;			// �������� ���
				int nPBExpAll = 0;					// ��� �������� � �����
				int nPBDisbalance = 0;				// �������� ���������� 
				int[] nPBExpCausesDetails = null;

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
					nPBExpCausesDetails = new int[m_oMapper.ColumnQnt];

				// ...���������� ��� ��������: ��� ����� �����, ���� �������� ������ ������������
				if ( RepDepartmentExpensesStructure_DataFormat.OnlyTime != m_enDataFormat )
				{
					if (m_bColumnSumAsPercentBase)
					{
						// � �������� ���� ������� ��������� ����������� ������ � (���)������:
						nPBExpOnTaskAll = oPercentBaseRow.ExpOnTasksExt + oPercentBaseRow.ExpOnTasksInt;
						nPBExpOnCausesOnFolder = oPercentBaseRow.ExpOnCausesExt + oPercentBaseRow.ExpOnCausesInt;
						nPBExpOnActivity = nPBExpOnTaskAll + nPBExpOnCausesOnFolder;
						nPBExpOnCausesLoss = oPercentBaseRow.ExpOnCausesLoss;
						nPBExpOnCausesAll = nPBExpOnCausesOnFolder + nPBExpOnCausesLoss;
						nPBExpAll = nPBExpOnTaskAll + nPBExpOnCausesAll;
						nPBDisbalance = oPercentBaseRow.Disbalance;

						// �������� ����������� ����������� �� �������� ��������?
						if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
							for( int nIdx=0; nIdx<m_oMapper.ColumnQnt; nIdx++ )
								nPBExpCausesDetails[nIdx] = oPercentBaseRow.ExpsOnCausesDetail[nIdx];
					}
					else
					{
						// � �������� ���� ������� ��������� ����������� ����� ������ � ������:
						nPBExpOnTaskAll = nExpAll;
						nPBExpOnCausesOnFolder = nExpAll;
						nPBExpOnActivity = nExpAll;
						nPBExpOnCausesLoss = nExpAll;
						nPBExpOnCausesAll = nExpAll;
						nPBExpAll = nExpAll;
						// ...%% ���������� � ���� ������ ��������� �� ����� � ������:
						nPBDisbalance = PeriodRate;

						// �������� ����������� ����������� �� �������� ��������?
						if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
							for( int nIdx=0; nIdx<m_oMapper.ColumnQnt; nIdx++ )
								nPBExpCausesDetails[nIdx] = nExpAll;
					}
					if (nPBDisbalance < 0)
						nPBDisbalance = 0;
				}


				// #2: ����� ������
				fo.TRStart();

				// ����� ������ � ������� � �������������:
				if ( RowNum > 0 )
					fo.TRAddCell( RowNum, "i4", 1, 1, sCellClassName );

				string sNameCellContent;
				if (null!=FixedRowName && String.Empty!=FixedRowName)
					sNameCellContent = xmlEncode(FixedRowName);
				else if (null!=RowLinkInfo && String.Empty!=RowLinkInfo && null!=TrackRowID && String.Empty!=TrackRowID)
				{
					Guid uidRowID = Guid.Empty;
					try { uidRowID = new Guid(TrackRowID); }
					catch(Exception) { uidRowID = Guid.Empty; }
					sNameCellContent = _GetUserMailAnchor( RowName, RowLinkInfo, uidRowID, Guid.Empty, Guid.Empty );
				}
				else
					sNameCellContent = xmlEncode(RowName);

				fo.TRAddCell( sNameCellContent, "string", (RowNum>0 ? 1 : 2), 1, sCellClassName );

				// ����������� ����� ������; ������������ �������, ������ ������ � ����� �������:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodRate) )
					writeExpenseCell( fo, PeriodRate, sCellClassName );
				
				// ������ �� ���������� ��������; ������������ �������:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodDisbalance) )
					writeExpenseCellEx( fo, Disbalance, nPBDisbalance, sEmphCellClassName );

				// ������������ ����������; ������������ ������ �������, ��� �������� - ��������:
				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization) ) 
				{
					int nExpExternal = ExpOnTasksExt + ExpOnCausesExt;	// ������� �� "�������" ����������
					int nExpInternal = ExpOnTasksInt + ExpOnCausesInt;	// ������� �� "����������" ����������
					double fUtlization;

					// ...������� �������:
					fUtlization = ( 0==PeriodRate? 0 : (nExpExternal * 100.0) / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
					// ...���������� �������:
					fUtlization = ( 0==PeriodRate? 0 : (nExpInternal * 100.0) / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
					// ...�����:
					fUtlization = ( 0==PeriodRate? 0 : (nExpExternal + nExpInternal)*100.0 / (float)PeriodRate );
					fo.TRAddCell( fUtlization.ToString("0.0000"), "r8", 1, 1, sCellClassName );
				}

				// ������� �������:
				// ...�����:
				writeExpenseCellEx( fo, nExpAll, nPBExpAll, sEmphCellClassName );
				// ...��������� �� �������:
				writeExpenseCellEx( fo, nExpOnTaskAll, nPBExpOnTaskAll, sCellClassName );
				// ...������� �� ��������:
				writeExpenseCellEx( fo, nExpOnCausesAll, nPBExpOnCausesAll, sCellClassName );
				
				// ������� ���������, �����:
				writeExpenseCellEx( fo, nExpOnActivity, nPBExpOnActivity, sCellClassName );

				if ( isShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) )
				{
					int nLossBaseIndex = m_oMapper.GetColumnsIndexesBase( ExpTypes.OnCauseLoss );
					int nColumnsQnt = m_oMapper.ColumnQnt;
					
					// ��������� ��������
					writeExpenseCellEx( fo, nExpOnCausesOnFolder, nPBExpOnCausesOnFolder, sCellClassName );
					for( int nIndex = 0; nIndex < nLossBaseIndex; nIndex++ )
						writeExpenseCellEx( fo, ExpsOnCausesDetail[nIndex], nPBExpCausesDetails[nIndex], sCellClassName );

					// ����������� ��������
					writeExpenseCellEx( fo, ExpOnCausesLoss, nPBExpOnCausesLoss, sCellClassName );
					for( int nIndex = nLossBaseIndex; nIndex < nColumnsQnt; nIndex++ )
						writeExpenseCellEx( fo, ExpsOnCausesDetail[nIndex], nPBExpCausesDetails[nIndex], sCellClassName );
				}
				else
				{
					writeExpenseCellEx( fo, nExpOnCausesOnFolder, nPBExpOnCausesOnFolder, sCellClassName );
					writeExpenseCellEx( fo, ExpOnCausesLoss, nPBExpOnCausesLoss, sCellClassName );
				}

				fo.TREnd();
			}

			
			protected void writeExpenseCellEx( XslFOProfileWriter fo, int nValue, int nPercentBaseValue, string sCellClassName ) 
			{
				double dPercentValue = 0.0;
				if (RepDepartmentExpensesStructure_DataFormat.OnlyTime != m_enDataFormat && 0 != nPercentBaseValue)
					dPercentValue = ( nValue*100.0 ) / ((float)nPercentBaseValue);
				
				switch(m_enDataFormat)
				{
					case RepDepartmentExpensesStructure_DataFormat.OnlyTime:
						// ����� ������ �������:
						base.writeExpenseCell( fo, nValue, sCellClassName );
						break;

					case RepDepartmentExpensesStructure_DataFormat.OnlyPercent:
						// ����� ������ ���������:
						fo.TRAddCell( dPercentValue.ToString("0.0000"), "r8", 1, 1, sCellClassName );
						break;

					case RepDepartmentExpensesStructure_DataFormat.TimeAndPercent:
						// ����� � ������� � ���������:
						base.writeExpenseCell( fo, nValue, sCellClassName );
						fo.TRAddCell( dPercentValue.ToString("0.0000"), "r8", 1, 1, sCellClassName );
						break;

					default:
						throw new ApplicationException("������ ������������ ������ ������ ������: ����������������� ����� ������ ������ " + m_enDataFormat.ToString());
				}
			}

			
			private bool isShowColumn( RepDepartmentExpensesStructure_OptColsFlags flagColumn ) 
			{
				return ( ((int)(m_enShownColumn & flagColumn)) > 0 );
			}

		}
		
		
		/// <summary>
		/// ������������� ������ ������ ������� �����
		/// </summary>
		internal class ThisReportRow_Form2 : ThisReportRow 
		{
			public string TrackId = null;
			
			public string Name = null;			//
			public string NameColumn = null;	//
			public string Mail = null;			//

			public int ExpOnTask = 0;			// ������� �� ��������� (�������)
			public int ExpOnActivity = 0;		// �������� �� ���������� 
			public int ExpOnLoss = 0;			// �������� ��� �����������
			public int ExpPlan = 0;				// ����������� ����� �� ����������
			public int ExpLeft = 0;				// ���������� ����� �� ����������
			public int TaskDoneQnt = 0;			// ���������� ����������� ���������� (�� ������)
			public int TaskInWorkQnt = 0;		// ���������� �������� ����������

			private int m_nOrdTrackId;

			private int m_nOrdName;				
			private int m_nOrdMail;				
			private int m_nOrdExpType;
			private int m_nOrdExpenses;
			private int m_nOrdExpPlan;
			private int m_nOrdExpLeft;
			private int m_nOrdTaskDoneQnt;
			private int m_nOrdTaskInWorkQnt;

			public ThisReportRow_Form2( IDataReader reader, string sTrackIdColumn, TimeMeasureUnits enTimeMeasure ) 
				: base( enTimeMeasure ) 
			{
				// �������� �������� ��� ���� �������� ������� ����������:
				m_nOrdTrackId = reader.GetOrdinal(sTrackIdColumn);

				m_nOrdName = ( null==NameColumn || String.Empty==NameColumn ? -1 : reader.GetOrdinal(NameColumn) );
				m_nOrdMail = reader.GetOrdinal("EmpMail");
				m_nOrdDayRate = reader.GetOrdinal("DayRate");
				m_nOrdExpType = reader.GetOrdinal("ExpType");
				m_nOrdExpenses = reader.GetOrdinal("Expenses");
				m_nOrdExpPlan = reader.GetOrdinal("ExpPlan");
				m_nOrdExpLeft = reader.GetOrdinal("ExpLeft");
				m_nOrdTaskDoneQnt = reader.GetOrdinal("TaskDoneQnt");
				m_nOrdTaskInWorkQnt = reader.GetOrdinal("TaskInWorkQnt");
			}

			
			/// <summary>
			/// ��� ����...
			/// </summary>
			/// <param name="reader"></param>
			public bool ReadRow( IDataReader reader ) 
			{
				if ( NameColumn==null || String.Empty==NameColumn )
					m_nOrdName = -1;
				else if (-1 == m_nOrdName )
					m_nOrdName = reader.GetOrdinal( NameColumn );
				
				if ( !reader.IsDBNull(m_nOrdTrackId) )
					TrackId = reader.GetValue( m_nOrdTrackId ).ToString();
				else
					TrackId = String.Empty;

				// ����� ��� ���� �����, ����������� � ������ � ���� �� ���������� - ����������
				DayRate = safeGetInt( reader, m_nOrdDayRate );
				// ... ��� � ������������:
				if (-1!=m_nOrdName)
					Name = reader.GetString( m_nOrdName );	
				// �������� ����� ���������, ������ ���� �� ���� � �������������� ������:
				Mail = ( reader.IsDBNull(m_nOrdMail) ? null : reader.GetString(m_nOrdMail) );
				
				bool bMoreRows = true;
				for( ; bMoreRows; )
				{
					int nValue = safeGetInt( reader, m_nOrdExpenses );
					if ( 0!=nValue && 0==DayRate )
						throw new ApplicationException( "������ ������� ������ ������: �������� �������� �� ���� ����� ��������, ��� ������� ����� �������� ���!" );

					// ���� ExpType ���� NULL, �� ������������� ��� ��� 0 ���� �� ��������, 
					// ��� ��� � ���� ������ � Expenses - NULL, �.�. 0
					ExpTypes enExpType = (ExpTypes)safeGetInt( reader, m_nOrdExpType ); 
					switch ( enExpType )
					{
						case ExpTypes.OnIncident:
						case ExpTypes.OnIncidentExternal:
						case ExpTypes.OnIncidentInternal:
							ExpOnTask += nValue; 
							break;

						case ExpTypes.OnCauseFolder:
						case ExpTypes.OnCauseExternal:
						case ExpTypes.OnCauseInternal:
							ExpOnActivity += nValue; 
							break;

						case ExpTypes.OnCauseLoss:
							ExpOnLoss += nValue; 
							break;
					}
				
					ExpPlan += safeGetInt( reader, m_nOrdExpPlan );
					ExpLeft += safeGetInt( reader, m_nOrdExpLeft );
					TaskDoneQnt += safeGetInt( reader, m_nOrdTaskDoneQnt );
					TaskInWorkQnt += safeGetInt( reader, m_nOrdTaskInWorkQnt );
					
					// ��������� � ��������� ������ ������:
					bMoreRows = reader.Read();
					if ( bMoreRows )
						if ( TrackId != reader.GetValue( m_nOrdTrackId ).ToString() )
							break;
				}

				HasSome = true; 
				return bMoreRows;
			}

			
			/// <summary>
			/// 
			/// </summary>
			/// <param name="row"></param>
			public void Summarize( ThisReportRow_Form2 row ) 
			{
				// ���������:
				// �� ���� ���, �������, �� ������������. �� � ������� �������
				// "��� ������� ������� �������� ���" ��� ������������ ������
				// ������� ���������� ����������� (� ��������, � ������, �����
				// ���� ������ �����) - �� ����� � ��������. ���� ��� �������� 
				// ������� ��, ��� ����� ��� ���� ���������� � �������������. 
				// ������ �� ����� ��� ������������ ������ ���� ����� - ������
				// ���������� (������ �������� �� ������� ���� ������, �.�. 
				// ��� ������������ ������ ������ � ���������� ������� ���� 
				// ���-�� ���������� ������� � "���, ����, ������")
				DayRate = row.DayRate;
				
				ExpOnTask += row.ExpOnTask;
				ExpOnActivity += row.ExpOnActivity;
				ExpOnLoss += row.ExpOnLoss;
				ExpPlan += row.ExpPlan;
				ExpLeft += row.ExpLeft;
				TaskDoneQnt += row.TaskDoneQnt;
				TaskInWorkQnt += row.TaskInWorkQnt;

				HasSome = true;
			}

			
			/// <summary>
			/// 
			/// </summary>
			public void Zeroing() 
			{
				ExpOnTask = 0;
				ExpOnActivity = 0;
				ExpOnLoss = 0;
				ExpPlan = 0;
				ExpLeft = 0;
				TaskDoneQnt = 0;
				TaskInWorkQnt = 0;
				
				HasSome = false;
			}
			
			
			/// <summary>
			/// 
			/// </summary>
			/// <param name="fo"></param>
			/// <param name="sCellClassName"></param>
			/// <param name="sEmphCellClassName"></param>
			public void WriteRow( XslFOProfileWriter fo, string sCellClassName, string sEmphCellClassName ) 
			{
				int nLeadColSpan = ( RowNum>0 ? 1 : 2 );
				if (null==sEmphCellClassName || String.Empty==sEmphCellClassName)
					sEmphCellClassName = sCellClassName;
				
				string sNameCellContent;
				if (null!=TrackId && String.Empty!=TrackId) 
					sNameCellContent = _GetUserMailAnchor( Name, Mail, new Guid(TrackId), Guid.Empty, Guid.Empty );
				else
					sNameCellContent = xmlEncode(Name);

				fo.TRStart();
				
				if ( RowNum > 0 )
					fo.TRAddCell( RowNum, "i4", 1, 1, sCellClassName );
				fo.TRAddCell( sNameCellContent, "string", nLeadColSpan, 1, sCellClassName );
					
				fo.TRAddCell( TaskDoneQnt, "i4", 1, 1, sCellClassName );
				fo.TRAddCell( TaskInWorkQnt, "i4", 1, 1, sCellClassName ); 

				writeExpenseCell( fo, ExpOnTask + ExpOnActivity + ExpOnLoss, sEmphCellClassName );
				writeExpenseCell( fo, ExpOnTask, sCellClassName );
				writeExpenseCell( fo, ExpOnActivity + ExpOnLoss, sCellClassName );
				writeExpenseCell( fo, ExpOnActivity, sCellClassName );
				writeExpenseCell( fo, ExpOnLoss, sCellClassName );

				writeExpenseCell( fo, ExpPlan, sCellClassName );
				writeExpenseCell( fo, ExpOnTask, sCellClassName );
				writeExpenseCell( fo, ExpLeft, sCellClassName );

				fo.TREnd();
			}
		}


		#endregion
		
		/// <summary>
		/// ������ � ��������� ��������� ������ ������ ������.
		/// </summary>
		/// <param name="cn"></param>
		/// <param name="oParams"></param>
		/// <returns>
		/// ������ ������, ��� IDataReader
		/// </returns>
		private IDataReader getReportData(IReportDataProvider dataProvider , ThisReportParams oParams ) 
		{
            return dataProvider.GetDataReader("dsMain", oParams);
		}

		
		/// <summary>
		/// ������������ ����� ������� ������
		/// </summary>
		/// <param name="fo"></param>
		/// <returns>���-�� �������������� �������</returns>
		private int writeHeader( XslFOProfileWriter fo ) 
		{
			string sColName;
			align enExpColAlign = ( TimeMeasureUnits.Days == m_oParams.TimeMeasure? align.ALIGN_LEFT : align.ALIGN_RIGHT );
			int nColL1;
			int nColL2;
			int nRetColumnsQnt = 0;

			if ( RepDepartmentExpensesStructure_ReportForm.ByEmployeeWithTasksDetali != m_oParams.ReportForm )
			{					
				#region ����� ������ - "C�������� ������ �� �������������" ��� "������ �� ������� ����������"
				
				sColName = 
					RepDepartmentExpensesStructure_ReportForm.ByDepartment == m_oParams.ReportForm ?
					"������������ �������������" : 
					"��������� / ������������ �������������";

                fo.TAddColumn("�", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "3%", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddColumn(sColName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "27%", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
				nRetColumnsQnt = 2;
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodRate) > 0 )
				{
					fo.TAddColumn( "����� �������� �������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px",align.ALIGN_NONE, valign.VALIGN_NONE , null );
					nRetColumnsQnt += 1;
				}
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowPeriodDisbalance) > 0 )
					nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, 0, "���������" );
				
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowUtilization) > 0 )
				{
					nColL1 = fo.TAddColumn( "����������� ���������� (%)", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                    fo.TAddSubColumn(nColL1, "����. �������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                    fo.TAddSubColumn(nColL1, "�����. �������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                    fo.TAddSubColumn(nColL1, "�����", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
					nRetColumnsQnt += 3;
				}
				
				nColL1 = fo.TAddColumn( "������� �������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "�����" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "��������� �� �������" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "������� �� ��������" );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "������� ���������, �����" );

				nColL1 = fo.TAddColumn( "����������� ��������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "�������� ���������, �����" );
				// ����������� ��������� �������� �� �������� (�����������):
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				{
					nColL2 = fo.TAddSubColumn( nColL1, "�� �������� ��������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
					foreach( string sName in m_oMapper.GetColumnsNames(ExpTypes.OnCauseFolder) )
						nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL2, sName );
				}
					
				nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL1, "�������� �� ���������, �����" );
				// ����������� �� ��������� �������� �� �������� (�����������):
				if ( m_oParams.IsShowColumn(RepDepartmentExpensesStructure_OptColsFlags.ShowCauseDetailization) > 0 )
				{
					nColL2 = fo.TAddSubColumn( nColL1, "�� �������� ��������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
					foreach( string sName in m_oMapper.GetColumnsNames(ExpTypes.OnCauseLoss) )
						nRetColumnsQnt += writeHeadExpensesSubColumns( fo, m_oParams, nColL2, sName );
				}

				#endregion
			}
			else
			{
				#region ����� ������ - "������ �� ������� ����������, � ������� �� ��������"

                fo.TAddColumn("�", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "3%", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddColumn("���������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "27%", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "�������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "���������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "��������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "������� �������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "�����", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER);
                fo.TAddSubColumn(nColL1, "��������� �� �������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
				nColL2 = fo.TAddSubColumn( nColL1, "�������", align.ALIGN_CENTER, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL2, "�����", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL2, "�� �������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL2, "��� ��������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nColL1 = fo.TAddColumn( "������ �� ��������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER );
                fo.TAddSubColumn(nColL1, "�������������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "���������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);
                fo.TAddSubColumn(nColL1, "��������", enExpColAlign, valign.VALIGN_MIDDLE, ITRepStyles.TABLE_HEADER, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, null);

				nRetColumnsQnt = 12;

				#endregion
			}

			return nRetColumnsQnt;
		}

		
		/// <summary>
		/// ��������������� ����� ������������ ����� ������� ������ - ���������
		/// �������� ����� ��� ������� � ���������: � ����������� �� ��������� 
		/// ������������� (������� �������, ��������� ����������� %%) ���������
		/// ������ ��� / �������� / ���������� �������
		/// </summary>
		/// <param name="fo"></param>
		/// <param name="oParams">���������</param>
		/// <param name="nGenColIndex">������ ����������� ������� (���� ���, �� 0)</param>
		/// <param name="sName">����� � �����</param>
		/// <returns>���-�� �������������� �������</returns>
		private int writeHeadExpensesSubColumns( 
			XslFOProfileWriter fo, 
			ThisReportParams oParams, 
			int nGenColIndex, 
			string sName ) 
		{
			int nColumnIndex;
			int nRetColumnQnt = 0;
			align enExpColAlign = ( TimeMeasureUnits.Days == oParams.TimeMeasure? align.ALIGN_LEFT : align.ALIGN_RIGHT );

			switch( oParams.DataFormat )
			{
				case RepDepartmentExpensesStructure_DataFormat.TimeAndPercent:
                    nColumnIndex = fo.TAddSubColumn(nGenColIndex, sName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty,align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
                    fo.TAddSubColumn(nColumnIndex, "�����", enExpColAlign, valign.VALIGN_MIDDLE, null, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
                    fo.TAddSubColumn(nColumnIndex, "%%", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 2;
					break;

				case RepDepartmentExpensesStructure_DataFormat.OnlyTime:
                    fo.TAddSubColumn(nGenColIndex, sName, enExpColAlign, valign.VALIGN_MIDDLE, null, "100px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 1;
					break;

				case RepDepartmentExpensesStructure_DataFormat.OnlyPercent:
                    fo.TAddSubColumn(nGenColIndex, sName + " (%%)", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "80px", align.ALIGN_NONE, valign.VALIGN_NONE, ITRepStyles.TABLE_HEADER);
					nRetColumnQnt = 1;
					break;
			}

			return nRetColumnQnt;
		}
	}
}