//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
// ��� ������������ ������ "������� � ������� �����������"
//******************************************************************************
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
	/// </summary>
	public class r_ExpensesByDirections: CustomITrackerReport 
	{
        protected override void buildReport(Croc.XmlFramework.ReportService.Layouts.ReportLayoutData data)
        {
            buildThisReport(data.RepGen, data.Params, data.DataProvider, data.CustomData);
        }
        /// <summary>
		/// ���������� �����, �������������� ��� ���������� ��������� ������
		/// </summary>
		public class ThisReportParams 
		{
			/// <summary>
			/// ��� ����������� �������; �������� ���������, ������������� �� ���������
			/// ������� �������� ���������� "�����������" (Organization) � "����������"
			/// (Folder)
			/// </summary>
			public enum AnalysisDirectionEnum 
			{
				/// <summary>
				/// ����������� ������� "����������� - �����������", ��� �����������
				/// </summary>
				ByCustomer_AllCustomners = 0,

				/// <summary>
				/// ����������� ������� "����������� - �����������", ���������� �����������
				/// </summary>
				ByCustomer_TargetCustomer = 1,

				/// <summary>
				/// ����������� ������� "���������� - �����������", ���������� ����������
				/// </summary>
				ByActivity = 2
			}

			
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
			/// ����������� �������, ����������� ��������
			/// </summary>
			public AnalysisDirectionEnum AnalysisDirection; 

			/// <summary>
			/// ������������� �����������, ��� ������� "����������� - �����������"
			/// </summary>
			public object Organization;
			/// <summary>
			/// ������������� ����������, ��� ������� "���������� - �����������"
			/// </summary>
			public object Folder;

			/// <summary>
			/// ����� ����� �����������, ������ ������� ���������� � ������
			/// (��. FolderTypesFlags) ������� �������� == "������ + ������ + �������"
			/// ����� ����� ������ ��� ����������� ������� "����������� - �����������".
			/// </summary>
			public int FolderType;
			/// <summary>
			/// ������� ����� ������ ������ �������� �����������, ��������� ������� ����
			/// "�������" � "�������� ��������". ����� ����� ������ ��� ����������� 
			/// ������� "����������� - �����������".
			/// </summary>
			public bool OnlyActiveFolders;
			/// <summary>
			/// ������� ��������� ������ � ��������� ��������� ����������� �����������
			/// ��� �������� ����������. ����� ����� ������ ��� ����������� ������� 
			/// "���������� - �����������".
			/// </summary>
			public bool ShowHistoryInfo;
			/// <summary>
			/// ������� ��������� ������ �����������
			/// </summary>
			public bool ShowDetails;
			/// <summary>
			/// ����� ������������� �������
			///		0 - ���, ����, ������;
			///		1 - ����
			/// </summary>
			public TimeMeasureUnits TimeMeasure;
			/// <summary>
			/// ��� ����������� ������ � ������: 
			///		0 - �� ������������� ����������, 
			///		1 - �� ����� ������
			/// </summary>
			public int SortBy;

			
            /// <summary>
            /// ������� ��������� � ��������� ������ �������� ����������
            /// </summary>
			public bool ShowRestrictions;

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
				// ������� ��� ������ � ����� ��������� �������
				IsSpecifiedIntervalBegin = !Params.GetParam("IntervalBegin").IsNull;
				IntervalBegin = ( IsSpecifiedIntervalBegin? Params.GetParam("IntervalBegin").Value : DBNull.Value );
				IsSpecifiedIntervalEnd = !Params.GetParam("IntervalEnd").IsNull;
				IntervalEnd = ( IsSpecifiedIntervalEnd? Params.GetParam("IntervalEnd").Value : DBNull.Value );
			
				// ��� ����������� ������� ������������ �� ��������� ������� ��������������� 
				// ����������� ��� ����������; ����� ������������ �������� ����������: ���� 
				// ��� �� ������, �� ���������� � �������� �������� DBNull:
				Organization = Guid.Empty;
				Folder = Guid.Empty;
				if ( !Params.GetParam("Folder").IsNull )
				{
					AnalysisDirection = AnalysisDirectionEnum.ByActivity;
					Folder = Params.GetParam("Folder").Value;
					Organization = DBNull.Value;
				}
				else if ( !Params.GetParam("Organization").IsNull )
				{
					AnalysisDirection = AnalysisDirectionEnum.ByCustomer_TargetCustomer;
					Organization = Params.GetParam("Organization").Value;
					Folder = DBNull.Value;
				}
				else
				{
					AnalysisDirection = AnalysisDirectionEnum.ByCustomer_AllCustomners;
					Organization = DBNull.Value;
					Folder = DBNull.Value;
				}

				// ���� �����������:
				FolderType = (int)Params.GetParam("FolderType").Value;
				if ( AnalysisDirectionEnum.ByActivity == AnalysisDirection )
					FolderType = 0;

				// ���� ������ ������ �������� �����������
				OnlyActiveFolders = ( 0 != (int)Params.GetParam("OnlyActiveFolders").Value );
				if ( AnalysisDirectionEnum.ByActivity == AnalysisDirection )
					OnlyActiveFolders = false;
		
				// ����������� ������ �� ������� ��������� ������ �� ������������ ��� ����������
				ShowHistoryInfo = ( 0 != (int)Params.GetParam("ShowHistoryInfo").Value );
				if ( AnalysisDirectionEnum.ByActivity != AnalysisDirection )
					ShowHistoryInfo = false;

				// ����������� ������ � ������
				ShowDetails = ( 0 != (int)Params.GetParam("ShowDetails").Value );
				// ����� ������������� �������;
				TimeMeasure = (TimeMeasureUnits)((int)Params.GetParam("TimeMeasureUnits").Value);
				// ��� ���������� (0 - �� ������������ �����������, 1 - �� �����)
				SortBy = (int)Params.GetParam("SortBy").Value;	
				// ������� ����������� ���������� ������ � ���������
				ShowRestrictions = ( 0 != (int)Params.GetParam("ShowRestrictions").Value );
			}

			
			/// <summary>
			/// ��������� ����� XSL-FO, �������������� ������ �������� ����������, � 
			/// ���������� ��� ��� ����� ������������ ������������ ������
			/// </summary>
			/// <param name="foWriter"></param>
			/// <param name="cn"></param>
			public void WriteParamsInHeader( XslFOProfileWriter foWriter, IReportDataProvider Provider ) 
			{
				// XSL-FO � �������� ���������� ����� �������� ����:
				StringBuilder sbBlock = new StringBuilder();
				string sParamValue;

				// #1: ���� ������ � ��������� ��������� �������. 
				// ����� �� ���� ��� ����� ���� �� ������; ���� ��� ���, ��, � ������������ 
				// � ������������, � ��������� ������ ������ ���������� ��������������� 
				// ��������� ���� - �������������� ���� ������ ������� � ���� ������ ��������
				// �������� (��� ��������� ��������, ���������� � �����. �������������, 
				// ����������� ���������� �����������). ��������� ������ ���������� ��� 
				// ������ ����������� UDF; ������ ����� ����������� ������ ���� ����������:
				
				string sPossibleIntervalBegin = "��� ������";	// ������ � ��������� ����� ������ �������
				string sPossibleIntervalEnd = "��� ������"; 	// ������ � ��������� ����� ���������� �������

				if ( !IsSpecifiedIntervalBegin || !IsSpecifiedIntervalEnd )
				{
					// ��� ������� ����� ��������� ���� ���� ��������� UDF dbo.GetMinimaxBoundingDates:
					
			
						using( IDataReader reader = Provider.GetDataReader("dsDates", this) )
						{
							if ( !reader.Read() )
								throw new ApplicationException("������ ��������� �������������� ������ (��������� ���� ������ �������)");
							
							// ��������� ���� ������ ������� (������ ������� � ����������):
							if ( !reader.IsDBNull(0) )
								sPossibleIntervalBegin = reader.GetDateTime(0).ToString("dd.MM.yyyy");
							
							// ��������� ���� ���������� ������� (������ ������� � ����������):
							if ( !reader.IsDBNull(1) )
								sPossibleIntervalEnd = reader.GetDateTime(1).ToString("dd.MM.yyyy");
						}
					
				}

				if ( IsSpecifiedIntervalBegin )
					sParamValue = ((DateTime)IntervalBegin).ToString("dd.MM.yyyy");
				else
					sParamValue = String.Format( "�� ������ (��������� ���� - {0})", sPossibleIntervalBegin );
				sbBlock.Append( getParamValueAsFoBlock( "���� ������ ��������� �������", sParamValue ) );
				
				if ( IsSpecifiedIntervalEnd )
					sParamValue = ((DateTime)IntervalEnd).ToString("dd.MM.yyyy");
				else
					sParamValue = String.Format( "�� ������ (��������� ���� - {0})", sPossibleIntervalEnd );
				sbBlock.Append( getParamValueAsFoBlock( "���� ��������� ��������� �������", sParamValue ) );


				// #2: ����������� �������:
				if (AnalysisDirectionEnum.ByActivity == AnalysisDirection)
					sParamValue = "���������� - �����������";
				else 
					sParamValue = "����������� - �����������";
				sbBlock.Append( getParamValueAsFoBlock( "����������� �������", sParamValue ) );

				
				// #3: �����������-������ ��� ����������:
				// ���� ������, �� ���-�� ���� (����������� �� ��������� "����������� �������"),
				// �������� �� ��, �� ������. ���� ������, �� ������ ������������ ������� �� ��:
				if (AnalysisDirectionEnum.ByCustomer_AllCustomners == AnalysisDirection)
					sbBlock.Append( getParamValueAsFoBlock( "�����������", "��� �����������" ) );
				else
				{
					
				    sParamValue = (string)Provider.GetValue("dsParams",this);
					if (AnalysisDirectionEnum.ByActivity == AnalysisDirection)
						sbBlock.Append( getParamValueAsFoBlock( "����������", sParamValue ) );
					else
						sbBlock.Append( getParamValueAsFoBlock( "�����������", sParamValue ) );
				}


				// #4: ���. ������� �� ���� ���������� � �� ����� ������ �������� ����������� -
				// �������� ������ � ������ ����������� ������� "����������� - �����������":
				if (AnalysisDirectionEnum.ByActivity != AnalysisDirection)
				{
					FolderTypeFlags flags = (0!=FolderType)? 
						(FolderTypeFlags)FolderType :
						(FolderTypeFlags.Project | FolderTypeFlags.Tender | FolderTypeFlags.Presale);
					sParamValue = FolderTypeFlagsItem.ToStringOfDescriptions( flags );
					sbBlock.Append( getParamValueAsFoBlock( "�������� ������ ����������� (�� �����)", sParamValue ) );

					sbBlock.Append( getParamValueAsFoBlock( 
							"�������� ������ ������ �������� �����������", 
							OnlyActiveFolders? 
								"�� (���������� � ���������� \"�������\" � \"�������� ��������\")" : 
								"��� (���������� �� ���� ����������)" 
						));
				}
				else
					sbBlock.Append( getParamValueAsFoBlock( 
							"���������� ������ � ��������� ��������� ����������� �����������", 
							ShowHistoryInfo? "��" : "���" 
						));

				
				// #5: ����� ���������: �����������:
				if (!ShowDetails) 
					sParamValue = "���";
				else
					sParamValue = (AnalysisDirectionEnum.ByCustomer_AllCustomners == AnalysisDirection)? "�� ������������" : "�� �����������";
				sbBlock.Append( getParamValueAsFoBlock( "�����������", sParamValue ) );
				
				// ...����� ������������� �������
				sbBlock.Append( getParamValueAsFoBlock( 
						"������������� �������", 
						TimeMeasureUnitsItem.GetItem(TimeMeasure).Description 
					));
				
				// ...����������:
				sbBlock.Append( getParamValueAsFoBlock( "����������", (0==SortBy? "�� �����������" : "�� ����� ������") ) );

				// ����� ������������:
				foWriter.AddSubHeader( 
					@"<fo:block text-align=""left""><fo:block font-weight=""bold"">��������� ������:</fo:block>" + 
					sbBlock.ToString() +
					@"</fo:block>"
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
					"<fo:block><fo:inline>{0}: </fo:inline><fo:inline font-weight=\"bold\">{1}</fo:inline></fo:block>",
					xmlEncode(sParamName),
					xmlEncode(sParamValueText)
				);
			}
		}

		
		/// <summary>
		/// ����������������� �����������, ��������� ����������� ReportService
		/// </summary>
		/// <param name="ReportProfile"></param>
		/// <param name="ReportName"></param>
		public r_ExpensesByDirections( reportClass ReportProfile, string ReportName ) 
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
		protected void buildThisReport( XslFOProfileWriter foWriter, ReportParams Params, IReportDataProvider Provider, object CustomData ) 
		{
			// ������� ���������:
			ThisReportParams oParams = new ThisReportParams( Params );
			
			// ������������ ������
            foWriter.WriteLayoutMaster();
			foWriter.StartPageSequence();
			foWriter.StartPageBody();

			// ���������
			foWriter.Header( "������� � ������� �����������" );
			// ��������� ������ � ���������?
			if (oParams.ShowRestrictions)
				oParams.WriteParamsInHeader( foWriter, Provider );

            writeBody(foWriter, oParams, Provider);

			foWriter.EndPageBody();
			foWriter.EndPageSequence();
		}


		/// <summary>
		/// ������������ "����" ������ 
		/// </summary>
		/// <param name="foWriter"></param>
		/// <param name="oParams"></param>
		/// <param name="cn"></param>
		private void writeBody( XslFOProfileWriter foWriter, ThisReportParams oParams, IReportDataProvider Provider )
		{
			
				using( IDataReader reader = Provider.GetDataReader("dsMain", oParams) )
				{
					// ��� ����������� �� ���������� � ���������� ������ ���� ��������� � 
					// ������������ ������� ������������ ������� - ��� ����� ��� ���� ������
					// � ������� "�������������� �� �����������" ��� ������������� ���������
					// � �������� �����������, ��� ������� ���������� ����. 
					// NB! ���� ��������� ������ ������ - ��� ������!
					if ( !reader.Read() )
						throw new ApplicationException( "������ ��������� ������ ������: ������ ��������� ������ ������ �������������� �����!");
					
					// ... �������� ����� � ������� ������� ����������: ���� ��� ������ 
					// � ���� �������, �� ��� ������� ���������; ����� - ��� ����� � ��������
					// �����������, � ������� ������� ��������������
					IDictionary rowData = _GetDataFromDataRow(reader);
					if ( 1!=rowData.Count )
					{
						#region ����������� ������ � ��������

						// ���������� ������ �������������� ���������� �������.
						// � ���������� ����:
						//	- CustomerID	- ������������� �����������, Guid
						//	- CustomerName	- ������������ �����������
						//	- FolderID		- �������������� ����������, � ������� ���������� ��������
						//	- FullName		- ������ ������������ (����) �������
						//	- ErrorType		- "���" ��������, �����:
						//					1 - ��� �����������, 
						//					2 - �� ������ ����, 
						//					3 - ��������� � ������� ����������� ��� ����������� �����������/���������, 
						//					4 - ���-�� ��� (������ � ����������� ���� ��������, �� ���� ��� ���� �� ������)

						// #1: ��������� ��������� �� ����������� ������
						foWriter.TStart( false, "WARNING_MESSAGE_TABLE", false );
						foWriter.TAddColumn( "���������" );
						foWriter.TRStart();
						foWriter.TRAddCell( 
							"��������! ���������� ������� ������ ����������: ���������� ������ ����������� ����������� ��� �����������!",
							null, 1, 1, "WARNING_MESSAGE" );
						foWriter.TREnd();
						foWriter.TEnd();

						// #2: ��������� ������� � �������� �����������, � ������� ���������� ���������
						foWriter.TStart( true, "TABLE", false );
						foWriter.TAddColumn( "����������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null,String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER"  );
                        foWriter.TAddColumn("������ �����������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, String.Empty, align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

						// ... ������ ������������� �� �����������-�������: 
						string sCustomerName = rowData["CustomerName"].ToString();
						bool bIsNextCusomerData = true;

						for( bool bMoreRows = true; bMoreRows;  )
						{
							// ...���� ��� ��������� ������ ������ ���������� ������� ��������
							// � ������ ��������� �����������-�������, �� ������� ��������� 
							// ������ - ������������ �������:
							if (bIsNextCusomerData)
							{
								foWriter.TRStart();
								foWriter.TRAddCell( xmlEncode(sCustomerName), null, 2, 1, "GROUP_HEADER" );
								foWriter.TREnd();
							}
							
							// ��������� ������������� "����" ���������:
							string sErrorDescription;
							switch ((int)rowData["ErrorType"])
							{
								case 1: sErrorDescription = "(���-1) ��� ���������� �� ������ �����������"; break;
								case 2: sErrorDescription = "(���-2) ��� ����������� ���������� �� ������ ���� ������"; break;
								case 3: sErrorDescription = "(���-3) ��� ����������� ���������� / �������� ������� �����������, �������� �� �����������, �������� ��� ����������"; break;
								default: sErrorDescription = "(������ ����������� ���� ��������������)"; break;
							}

							// ������� ������ �� ����� ����������; ��� ���� ������������ ����������
							// ����������� ��� �����, ��� ����� �� ������� ����� ������������ �����������
							// ���� � ���������� ���������� - ��������, ��������������, ������ � �.�.
							foWriter.TRStart();
							foWriter.TRAddCell( _GetFolderAnchor( rowData["FullName"], (Guid)rowData["FolderID"], true ), null, 1, 1, "TABLE_CELL" );
							foWriter.TRAddCell( sErrorDescription, null, 1, 1, "TABLE_CELL" );
							foWriter.TREnd();

							// ������ ����. ������ (���� ������ ��� ����); ��� ���� ���������� 
							// ������� �������� � ��������� ����� ������, �� ����. �������:
							bMoreRows = reader.Read();
							if (bMoreRows)
								rowData = _GetDataFromDataRow(reader);
							
							bIsNextCusomerData = ( sCustomerName != rowData["CustomerName"].ToString() );
							if (bIsNextCusomerData)
								sCustomerName = rowData["CustomerName"].ToString();
						}
						foWriter.TEnd();

						#endregion
						
						// �� ���� ����� �������������!
						return;
					}
					
					// �������������� ��� - ������� ������:
					if ( !reader.NextResult() )
						throw new ApplicationException("����������� �������� �������������� �����! ����� �������: ");

					// ��������� �������� �������
					string sDirsColumnName;
					bool bWithActivityQnt = ( ThisReportParams.AnalysisDirectionEnum.ByActivity != oParams.AnalysisDirection );

					if ( ThisReportParams.AnalysisDirectionEnum.ByCustomer_AllCustomners == oParams.AnalysisDirection && oParams.ShowDetails )
						sDirsColumnName = "����������� / �����������";
					else if ( ThisReportParams.AnalysisDirectionEnum.ByActivity == oParams.AnalysisDirection && oParams.ShowDetails )
						sDirsColumnName = "����������� / ����������";
					else
						sDirsColumnName = "�����������";

					foWriter.TStart( true, "TABLE", false );
                    foWriter.TAddColumn("�", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "5%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    foWriter.TAddColumn(sDirsColumnName, align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, (bWithActivityQnt ? "40%" : "55%"), align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
					if (bWithActivityQnt)
                        foWriter.TAddColumn("���������� �����������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "15%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    foWriter.TAddColumn("�������", (TimeMeasureUnits.Days == oParams.TimeMeasure ? align.ALIGN_LEFT : align.ALIGN_RIGHT), valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");
                    //foWriter.TAddColumn("����� ������", align.ALIGN_RIGHT, valign.VALIGN_MIDDLE, null, "20%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_HEADER");

					// ���� - ���������! TODO!
					int nWorkDayDuration = 600;

					if ( oParams.ShowDetails )
					{
						#region ������ � ������������
						//	- DirectionName - ������������ �����������;
						//	- DetailID		- ������������� �������������� �������� (����������� / ����������)
						//	- DetailName	- ������������ �������������� �������� 
						//	- ActivityQnt	- ���������� �����������
						//	- ExpensesSum	- ����� ������

						string sDirectionName = null;
						int nSubTotalTime = 0;	// ������������� ���� �� ����� ������������ �������
						int nTotalTime = 0;		// ����� ���� �� ����� ������������ �������
						int nSubTotalQnt = 0;	// ������������� ���� �� ���������� ����������� (�� �����������)
						int nTotalQnt = 0;		// ����� ���� �� ���������� �����������
						int nRowNum = 0;		// �������� ��������� ����� �����������

						// �������, ��� ������������ �������������� �������� ���� �����������:
						// ������ ��� ������������ ������ - ��� ����������� ������� "�����������..",
						// � ������ �������� ���������� ����������� - ����� � ���. ����������� 
						// ��������� ����������. ��� ��� � �������� ����� � ����������� ���� ��������:
						bool bIsDetailNameAsHref = ( ThisReportParams.AnalysisDirectionEnum.ByCustomer_TargetCustomer == oParams.AnalysisDirection );	
						
						while( reader.Read() )
						{
							IDictionary rec = _GetDataFromDataRow( reader );

							// ���� ��������� ��������������� ������ ��������� ��� � ������ ������,
							// �� ���������� ������ ������ � ������� ��������
							if ( null==sDirectionName || sDirectionName!=rec["DirectionName"].ToString() )
							{
								if ( null!=sDirectionName )
								{
									foWriter.TRStart();
									foWriter.TRAddCell( "����� �� �����������", "string", 2, 1, "GROUP_FOOTER" );
									
									if (bWithActivityQnt)
										foWriter.TRAddCell( nSubTotalQnt, "i4", 1, 1, "GROUP_FOOTER" );
									
									if (TimeMeasureUnits.Days == oParams.TimeMeasure)
										foWriter.TRAddCell( _FormatTimeStringAtServer(nSubTotalTime,nWorkDayDuration), "string", 1, 1, "GROUP_FOOTER" );
									else
										foWriter.TRAddCell( string.Format("{0:0.##}", nSubTotalTime/60.0), "r8", 1, 1, "GROUP_FOOTER" );
									
									//foWriter.TRAddCell( (nSubTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "GROUP_FOOTER" );
									foWriter.TREnd();
								}
								
								sDirectionName = rec["DirectionName"].ToString();
								nSubTotalTime = 0;
								nSubTotalQnt = 0;

								// ����� � "����������" ��������� ������:
								foWriter.TRStart();
								foWriter.TRAddCell( xmlEncode(sDirectionName), "string", ( bWithActivityQnt ? 5 : 4 ), 1, "GROUP_HEADER" );
								foWriter.TREnd();
							}
							
							// ���������� ������
							int nTime = Int32.Parse( rec["ExpensesTime"].ToString() );
							nSubTotalTime += nTime;
							nTotalTime += nTime;

							/*int nSum = Int32.Parse( rec["ExpensesSum"].ToString() );
							nSubTotalSum += nSum;
							nTotalSum += nSum;*/

							int nQnt = Int32.Parse( rec["ActivityQnt"].ToString() );
							nSubTotalQnt += nQnt;
							nTotalQnt += nQnt;

							nRowNum += 1;

							// ��������� ��������������� ������ ������:
							foWriter.TRStart();
							foWriter.TRAddCell( nRowNum, "i4", 1, 1, "TABLE_CELL_ROWNUM" );
							
							if (bIsDetailNameAsHref)
								foWriter.TRAddCell( _GetFolderAnchor( rec["DetailName"].ToString(), (Guid)rec["DetailID"], true ), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( xmlEncode(rec["DetailName"]), "string", 1, 1, "TABLE_CELL" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nQnt, "i4", 1, 1, "TABLE_CELL" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nTime,nWorkDayDuration), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}",nTime/60.0), "r8", 1, 1, "TABLE_CELL" );

							//foWriter.TRAddCell( (nSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_CELL" );
							foWriter.TREnd();
						}

						// ������ � ��������� ����������� ��������� (���� ����� ���)
						if (null!=sDirectionName)
						{
							foWriter.TRStart();
							foWriter.TRAddCell( "����� �� �����������", "string", 2, 1, "GROUP_FOOTER" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nSubTotalQnt, "i4", 1, 1, "GROUP_FOOTER" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nSubTotalTime,nWorkDayDuration), "string", 1, 1, "GROUP_FOOTER" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}", nSubTotalTime/60.0), "r8", 1, 1, "GROUP_FOOTER" );

							//foWriter.TRAddCell( (nSubTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "GROUP_FOOTER" );
							foWriter.TREnd();
						}

						// ������ � ����� ������ �� ����� ������
						foWriter.TRStart();
						foWriter.TRAddCell( "�����", "string", 2, 1, "TABLE_FOOTER" );
						
						if (bWithActivityQnt)
							foWriter.TRAddCell( nTotalQnt, "i4", 1, 1, "TABLE_FOOTER" );

						if (TimeMeasureUnits.Days == oParams.TimeMeasure)
							foWriter.TRAddCell( _FormatTimeStringAtServer(nTotalTime,nWorkDayDuration), "string", 1, 1, "TABLE_FOOTER" );
						else
							foWriter.TRAddCell( string.Format("{0:0.##}", nTotalTime/60.0), "r8", 1, 1, "TABLE_FOOTER" );

						//foWriter.TRAddCell( (nTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_FOOTER" );
						foWriter.TREnd();

						#endregion
					}
					else
					{
						#region ������ ��� �����������
						//	- DirectionName - ������������ �����������;
						//	- ActivityQnt	- ���������� �����������
						//	- ExpensesSum	- ����� ������

						int nTotalTime = 0;
						int nTotalQnt = 0;
						int nRowNum = 0;
						
						while( reader.Read() )
						{
							// ���������� �������� ������� ������:
							IDictionary rec = _GetDataFromDataRow( reader );

							int nTime = Int32.Parse( rec["ExpensesTime"].ToString() );
							nTotalTime += nTime;

							/* ������� ��� ������ �� ������
                             int nSum = Int32.Parse( rec["ExpensesSum"].ToString() );
							nTotalSum += nSum;*/

							int nQnt = Int32.Parse( rec["ActivityQnt"].ToString() );
							nTotalQnt += nQnt;

							nRowNum += 1;

							// ��������� ������������� ������ � XSL-FO:
							foWriter.TRStart();
							foWriter.TRAddCell( nRowNum, "i4", 1, 1, "TABLE_CELL" );
							foWriter.TRAddCell( xmlEncode(rec["DirectionName"]), "string", 1, 1, "TABLE_CELL" );
							
							if (bWithActivityQnt)
								foWriter.TRAddCell( nQnt, "i4", 1, 1, "TABLE_CELL" );

							if (TimeMeasureUnits.Days == oParams.TimeMeasure)
								foWriter.TRAddCell( _FormatTimeStringAtServer(nTime,nWorkDayDuration), "string", 1, 1, "TABLE_CELL" );
							else
								foWriter.TRAddCell( string.Format("{0:0.##}", nTime/60.0), "r8", 1, 1, "TABLE_CELL" );
							
							//foWriter.TRAddCell( (nSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_CELL" );
							foWriter.TREnd();
						}

						foWriter.TRStart();
						foWriter.TRAddCell( "�����", "string", 2, 1, "TABLE_FOOTER" );

						if (bWithActivityQnt)
							foWriter.TRAddCell( nTotalQnt, "i4", 1, 1, "TABLE_FOOTER" );

						if (TimeMeasureUnits.Days == oParams.TimeMeasure)
							foWriter.TRAddCell( _FormatTimeStringAtServer(nTotalTime,nWorkDayDuration), "string", 1, 1, "TABLE_FOOTER" );
						else
							foWriter.TRAddCell( string.Format("{0:0.##}", nTotalTime/60.0), "r8", 1, 1, "TABLE_FOOTER" );

						//foWriter.TRAddCell( (nTotalSum / 100.0).ToString("F2"), "fixed.14.4", 1, 1, "TABLE_FOOTER" );
																				 
						foWriter.TREnd();

						#endregion
					}

					foWriter.TEnd();
                }
				#region ������������� ������
				// ���� ����������� ������� - "����������-�����������" � ����� ������� �����������
				// ������ � ��������� ��������� ����������� ����������� ��� ����������:
				if ( ThisReportParams.AnalysisDirectionEnum.ByActivity == oParams.AnalysisDirection && oParams.ShowHistoryInfo )
				{
					// ��������� ������������ ���������� - ����� � ��� ��������� ��� ������� ����������� �����������
                    object oScalar = Provider.GetValue("dsHistory", oParams);
					string sNoteText = String.Format( 
							"<fo:inline>��������� ��������� ����������� �����������: </fo:inline><fo:inline font-weight=\"bold\">{0}</fo:inline>",
							(null!=oScalar? xmlEncode(oScalar.ToString()) : "(��� ������")
						);
					
					// ��������� ������� � "������������ ��������":
					// NB! ��������� ����� �� ������������!
					foWriter.TStart( false, "TABLE_NOTE", false );
                    foWriter.TAddColumn("���������", align.ALIGN_LEFT, valign.VALIGN_MIDDLE, null, "100%", align.ALIGN_NONE, valign.VALIGN_NONE, "TABLE_NOTE_HEADER");

					foWriter.TRStart();
					foWriter.TRAddCell( sNoteText, null, 1, 1, "TABLE_NOTE_CELL" );
					foWriter.TREnd();

					foWriter.TEnd();
				}
				#endregion
		}
	}
}