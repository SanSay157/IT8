//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Text;
using System.Web.Services;
using System.Xml;
using System.Xml.Serialization;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;
using System.Security.Principal;
using System.Threading;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ����� ������ ������� Incident Tracker
	/// </summary>
	[WebService(
		 Name="CommonService",
		 Namespace="http://www.croc.ru/Namespaces/IncientTracker/WebServices/CommonService/1.0",
		 Description=
			"������� ������������ ���������� ��������� Incident Tracker : " +
			"����� ������ ����������� �������������� � �������� ���������" )
	]
	public class CommonService
	{
        /// <summary>
		/// ����������� �������
		/// </summary>
		public CommonService() 
		{
			ObjectOperationHelper.AppServerFacade = ApplicationServerProxy.Facade;
		}

		#region ���������� ��������������� ������

		/// <summary>
		/// "����������" ������ ������ ��������� �������, �������� ������� ����� 
		/// ���� NULL-��: � ���� ������ ����� ��� �� ���������� null.
		/// </summary>
		/// <param name="helper">��������������� ������ � �������</param>
		/// <param name="sPropName">������������ �������� (�.�. � �������!)</param>
		private static string safeReadData( ObjectOperationHelper helper, string sPropName ) 
		{
			object oData = helper.GetPropValue( sPropName, XPropType.vt_string, false );
			return ( null==oData ? null : oData.ToString() );
		}

      	/// <summary>
		/// "����������" ���������� ������ ������� �� �� � ������.
		/// ���������� �������� DBNull � ������ ������ ��� null.
		/// </summary>
		/// <param name="oDbData"></param>
		/// <returns></returns>
		private string safeDbString2String( object oDbData ) 
		{
			if ( null==oDbData || DBNull.Value == oDbData )
				return null;
			string sResult = oDbData.ToString();
			return ( String.Empty==sResult? null : sResult );
		}

		
		#endregion

		#region ������ ��������� ������ ��������, �������������� � ������� Incident Tracker

		/// <summary>
		/// �������� ��������, �������� ������� �������� � ������� IT
		/// </summary>
		public enum ITConstants 
		{
			/// <summary>
			/// ������� URL-����� ��������� �������� ������� IT, 
			/// ��� ���������� �������� ����
			/// </summary>
			UnsecuredInternalSystemBaseURL,

			/// <summary>
			/// ������� URL-����� ��������� �������� ������� IT, 
			/// ��� �������� Internet-������� 
			/// </summary>
			SecuredExternalSystemBaseURL
		}
		

		#endregion
		#region ����� ������ ������� CommonService
		/// <summary>
		/// ��������� ������ �������� ����������� ������������ (� ������ 5.� 
		/// ���������� "������ ������������")
		/// </summary>
		/// <returns>
		/// �������� XML � ������� ������ �����������; ������ ������ ��������:
		///		- ���������� ������������� ����������� � ������� IT (� ������� GUID)
		///		- ������������� ����������� � ������� ��� (������� �����)
		///		- ������������ ����������� (������)
		/// </returns>
		[WebMethod]
        public string[] GetDirectionsList()
        {

            // �������� ������ ���� �����������:
            DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-Directions", null);
            if (null == oDataTable)
                return new string[0];
            String[] Directions = new String[oDataTable.Rows.Count];
            for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
            {
                Directions[nRowIndex] = oDataTable.Rows[nRowIndex]["DirectionID"].ToString();
            }
            return Directions;

        }
        #endregion

		#region ������ �������������� � �������� Oracle HRMS

		/// <summary>
		/// �������� "������" XML-��������� - ����������, ������������� ��� ������
		/// ������ GetProjectsParticipants. ������ �������� ������� XML-���������� 
		/// ��������� � �� "�������������� � �������� ���������".
		/// </summary>
		/// <param name="nCode"></param>
		/// <param name="sErrDescription"></param>
		/// <param name="sErrSatck"></param>
		/// <returns></returns>
		private XmlDocument createHrmsResultBlank( int nCode, string sErrDescription, string sErrSatck )
		{
			XmlDocument xmlBlank = new XmlDocument();
			
			// �������� �������:
			XmlElement xmlRoot = xmlBlank .CreateElement( "Result" );
			xmlBlank.AppendChild(xmlRoot);

			// ������ ������� (Result/Status):
			XmlElement xmlSection = xmlBlank.CreateElement( "Status" );
			xmlRoot.AppendChild( xmlSection );
			
			// ���������� ������ �������:
			// ... ��� (Result/Status/Code):
			XmlElement xmlElement = xmlBlank.CreateElement( "Code" );
			xmlElement.InnerText = nCode.ToString();
			xmlSection.AppendChild( xmlElement );
			// ... �������� ������ (Result/Status/Descr):
			xmlElement = xmlBlank.CreateElement( "Descr" );
			if ( null!=sErrDescription )
				xmlElement.AppendChild( xmlBlank.CreateCDataSection( sErrDescription ) );
			xmlSection.AppendChild( xmlElement );
			// ... ���� ������ (Result/Status/Stack):
			xmlElement = xmlBlank.CreateElement( "Stack" );
			if ( null!=sErrSatck )
				xmlElement.AppendChild( xmlBlank.CreateCDataSection( sErrSatck ) );
			xmlSection.AppendChild( xmlElement );

			// ������ ������ (Result/Data):
			xmlSection = xmlBlank.CreateElement( "Data" );
			xmlRoot.AppendChild( xmlSection );

			return xmlBlank;
		}

		
		/// <summary>
		/// ��������� ������ ���������� ��������� ������ �����������, � ������� 
		/// � �������� ������ ������� ������� �������� (�������) ���������.
		/// </summary>
		/// <param name="uidTargetEmployeeID">������������� �������� ����������</param>
		/// <param name="dtPeriodBeginDate">���� ������ �������������� ������� (������������)</param>
		/// <param name="dtPeriodEndDate">���� ���������� �������������� ������� (������������)</param>
		/// <returns>
		/// ��������������� XML-��������, �������������� ������ �� �������� � �� 
		/// ����������. ������ �������� ������� XML-���������� ��������� � ��
		/// "�������������� � �������� ���������".
		/// </returns>
		[WebMethod( Description="��������� ������ �������� � �� ����������, � ������� ��������� ��������� � �������� ������ �������� �������" )]
		public XmlDocument GetProjectsParticipants(
			Guid uidTargetEmployeeID,
			DateTime dtPeriodBeginDate,
			DateTime dtPeriodEndDate ) 
		{
			// ������ - ���������:
			XmlDocument xmlResult = null; 

			try 
			{
				// �������� ����������:
				ObjectOperationHelper.ValidateRequiredArgument( uidTargetEmployeeID, "���������, ��� �������� ����������� ������ (uidTargetEmployeeID)" );

				// ��������� ��������� ��� ������ ��������� ������ (� ������� �������� 
				// ����� �������� ��������� - ��. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "uidEmployee", uidTargetEmployeeID );	// ������������� �������� ����������
				procParams.Add( "dtPeriodBegin", dtPeriodBeginDate );	// ���� ������ �������������� �������
				procParams.Add( "dtPeriodEnd", dtPeriodEndDate );		// ���� ���������� �������������� �������
				procParams.Add( "nThresholdForTargetEmp", 600 );		// ����� ������ ��� �������� ����������� (NB! ���������!)
				procParams.Add( "nThresholdForOtherEmp", 60 );			// ����� ������ ��� ��. ������������ ������� (NB! ���������!)
				procParams.Add( "nFolderTypeMask", 1 );					// ���� ������������� ����������� (NB! ���������!)
				procParams.Add( "bPassOwnOrg", 0 );						// ������� �������� ������ ����������� - ���������(NB! ���������!)
			
				// ����� ��������� ������ � ������������ ������������ XML-����������
				// ���� <Data><p id='...' user='...' role='...'/> ... <Data>
				// �������������� XML-���������� �������������� �� ��������� �����������
				// ������������ ������� ��������������� ������ ����������� 
				// DataTableCodeNamedXmlFormatter - ��. ����������� � ����������
				DataTable data = ObjectOperationHelper.ExecAppDataSource( "CommonService-Interop-GetProjectsParticipants", procParams );
				DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter( "Data" );
				XmlDocument xmlData = formatter.FormatNamedDataTable( data, "p" );

				// ��������� �������������� ������: ���������� ��������� XML-�����,
				// ����������� ��������� � "�������" �������� - ������� ����� � �������
				// ����������, ������������ ������ (Descr � Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... ����������� ������, ���������� � ���������� ������ 
				// ��������� ������ � �����������������:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" )
				);
			}
			catch( Exception err )
			{
				// ��������� ���������, ����������� ������: ������� Code ����� � (-1),
				// �������� Descr � Stack �������� �������� � ���� ������ ��������������:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... ���� ������ ��� ���� - �����! */
			}
			return xmlResult;
		}

		
		/// <summary>
		/// ��������� �������� ��������� ������� ��� �������� ����������, ����� �������
		/// ������������ �������� � �������� ������ �������.
		/// </summary>
		/// <param name="uidTargetActivityID">������������� ������� ����������</param>
		/// <param name="dtPeriodBeginDate">���� ������ �������������� ������� (������������)</param>
		/// <param name="dtPeriodEndDate">���� ���������� �������������� ������� (������������)</param>
		/// <returns>
		/// ��������������� XML-��������, �������������� ������ �� ��������� ���������
		/// �������, ������������ ��� ��������� ����������. ������ �������� ������� 
		/// XML-���������� ��������� � �� "�������������� � �������� ���������".
		/// </returns>
		[WebMethod( Description="��������� �������� ��������� ������� ��� ����������, ����� ������� ������������ �������� � �������� ������ �������" )]
		public XmlDocument GetAllProjectParticipants(
			Guid uidTargetActivityID,
			DateTime dtPeriodBeginDate,
			DateTime dtPeriodEndDate )
		{
			// ������ - ���������:
			XmlDocument xmlResult = null; 

			try 
			{
				// �������� ����������:
				ObjectOperationHelper.ValidateRequiredArgument( uidTargetActivityID, "����������, ��� ������� ������������ ��������� ������� (uidTargetActivityID)" );

				// ��������� ��������� ��� ������ ��������� ������ (� ������� �������� 
				// ����� �������� ��������� - ��. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "uidActivity", uidTargetActivityID );	// ������������� ������� ����������
				procParams.Add( "dtPeriodBegin", dtPeriodBeginDate );	// ���� ������ �������������� �������
				procParams.Add( "dtPeriodEnd", dtPeriodEndDate );		// ���� ���������� �������������� �������
			
				// ����� ��������� ������ � ������������ ������������ XML-����������
				// ���� <Data><p user='...' role='...'/> ... <Data>
				// �������������� XML-���������� �������������� �� ��������� �����������
				// ������������ ������� ��������������� ������ ����������� 
				// DataTableCodeNamedXmlFormatter - ��. ����������� � ����������
				DataTable data = ObjectOperationHelper.ExecAppDataSource( "CommonService-Interop-GetAllProjectParticipants", procParams );
				DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter( "Data" );
				XmlDocument xmlData = formatter.FormatNamedDataTable( data, "p" );

				// ��������� �������������� ������: ���������� ��������� XML-�����,
				// ����������� ��������� � "�������" �������� - ������� ����� � �������
				// ����������, ������������ ������ (Descr � Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... ����������� ������, ���������� � ���������� ������ 
				// ��������� ������ � �����������������:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" ) );
			}
			catch( Exception err )
			{
				// ��������� ���������, ����������� ������: ������� Code ����� � (-1),
				// �������� Descr � Stack �������� �������� � ���� ������ ��������������:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... ���� ������ ��� ���� - �����! */
			}
			return xmlResult;
		}
        /// <summary>
        /// ��������� �������� ����������� �� �������� ������� ��������, � �������� �������� �������.
        /// </summary>
        /// <param name="sCauseID">������������� ������� ��������</param>
        /// <param name="dtPeriodBegin">������ �������</param>
        /// <param name="dtPeriodEnd">����� �������</param>
        /// <returns></returns>
        [WebMethod(Description = "����� ��������� ���������� � ��������� ������������� � ������� ������ ������� �� �������� ������� ��������")]
        public XmlDocument GetEmployeesExpensesWithCause(
            string sCauseID,
            DateTime dtPeriodBegin,
            DateTime dtPeriodEnd)
        {
            // ������ - ���������:
            XmlDocument xmlResult = null;
            try
            {
                Guid uidCauseID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCauseID, "������������� ������� ��������");
                XParamsCollection procParams = new XParamsCollection();
                procParams.Add("uidCauseID", uidCauseID);	// ������������� ������� ��������
                procParams.Add("dtPeriodBeginDate", dtPeriodBegin);	// ���� ������  �������
                procParams.Add("dtPeriodEndDate", dtPeriodEnd); // ���� ����� �������

                DataTable data = ObjectOperationHelper.ExecAppDataSource("GetEmployeeExpensesWithCause", procParams);
                DataTableCodeNamedXmlFormatter formatter = new DataTableCodeNamedXmlFormatter("Data");
                XmlDocument xmlData = DataTableXmlFormatter.GetXmlFromDataTable(data, "Data", "row");
                // ��������� �������������� ������: ���������� ��������� XML-�����,
                // ����������� ��������� � "�������" �������� - ������� ����� � �������
                // ����������, ������������ ������ (Descr � Stack):
                xmlResult = createHrmsResultBlank(0, null, null);
                // ... ����������� ������, ���������� � ���������� ������ 
                // ��������� ������ � �����������������:
                xmlResult.DocumentElement.ReplaceChild(
                    xmlResult.ImportNode(xmlData.DocumentElement, true),
                    xmlResult.SelectSingleNode("Result/Data"));
            }
            catch (Exception e)
            {
                // ��������� ���������, ����������� ������: ������� Code ����� � (-1),
                // �������� Descr � Stack �������� �������� � ���� ������ ��������������:
                xmlResult = createHrmsResultBlank(-1, e.Message, e.StackTrace);
            }

            return xmlResult;
        }
		


		#endregion
	
	
		#region ������ ����������� �������������� � ������������������� ������-����������

		/// <summary>
		/// ���������� �����; ��������� ���������������� ������, �����������
		/// ������� "��������������� ��������" ���������, �������� ��������
		/// �������� ���������� ����������
		/// </summary>
		/// <param name="helperIncident">��������������� ������ � ������� ���������</param>
		/// <param name="helperPropType">��������������� ������ � ������� ���� ���. ��������</param>
		/// <param name="helperPropValueTemplate">��������������� ������ � "���������" ���. �������� - �� ��������</param>
		/// <param name="oRealPropValue">�������� ������� - ��� ������, ��� ����/�����, ��� null</param>
		/// <returns>
		///	��������� ������� �� ��������� ��������:
		/// -- ���� �������� �������� ���� null, �� � ��������� ���� null;
		/// -- ���� �������� �������� ���� DateTime.MinValue, �� ��������� ���� null;
		/// -- ����� - ��������� ������������ �������, ������������ �������� 
		/// ���������; ��������! � ���� ������ ��� �� �������� ������ ���������
		/// ��������������� helper-�� helperIncident - ��� ������������� ������
		/// � ��������� �������� �������� Props!
		/// </returns>
		private static ObjectOperationHelper applayAdditionalIncidentProp( 
			ObjectOperationHelper helperIncident,
			ObjectOperationHelper helperPropType,
			ObjectOperationHelper helperPropValueTemplate,
			object oRealPropValue ) 
		{
			// ���� �������� �������� �������� ���� null, �� � ���������� null:
			if ( null==oRealPropValue )
				return null;
			
			// � �������� ��������� �������� ����������� ��� ������ ��� ����-�����:
			Type realPropValueType = oRealPropValue.GetType();
			if ( realPropValueType!=typeof(string) && realPropValueType!=typeof(DateTime) && realPropValueType!= typeof(decimal))
				throw new ArgumentException( 
					"� �������� ��������� �������� ��������������� �������� ����������� ��� ������ " +
					"��� ����/�����; �������� �������� ����� ��� " + realPropValueType.Name, 
					"oRealPropValue" );
			// ���� �������� �������� ���� ����/����� � ��� ������ � MinValue, �� 
			// �������������� ��� ��� "null"-��������, � ������ ���������� null:
			if ( typeof(DateTime)==realPropValueType && DateTime.MinValue==(DateTime)oRealPropValue )
				return null;
			
			// #1: �������� "��������"; ���� �������� ��� ���� ����� �� ������
			if (null == helperPropValueTemplate) throw new ApplicationException();
			if (!helperPropValueTemplate.IsLoaded) throw new ApplicationException();
			ObjectOperationHelper helperPropValue = ObjectOperationHelper.CloneFrom( helperPropValueTemplate, false );
			if (!helperPropValue.IsLoaded) throw new ApplicationException();
			
			// #2: ���������� ���� �������� ��������:
			if ( realPropValueType==typeof(DateTime) )
            {
				helperPropValue.SetPropValue( "DateData", XPropType.vt_dateTime, oRealPropValue );
            }
            else if (realPropValueType==typeof(decimal))
            {
                helperPropValue.SetPropValue("NumericData", XPropType.vt_fixed, oRealPropValue);
            }
			else 
            {
				helperPropValue.SetPropValue( "StringData", XPropType.vt_string, oRealPropValue );
            }
				
			// #3: ������:
			// ������ �� ��� ��������:
            
            helperPropValue.SetPropScalarRef("IncidentProp", helperPropType.TypeName, helperPropType.ObjectID);
            // ������ �� ��������:
            helperPropValue.SetPropScalarRef("Incident", helperIncident.TypeName, helperIncident.NewlySetObjectID);
            // ������ �� �������� � ����� ���������:
            helperIncident.AddArrayPropRef("Props", helperPropValue.TypeName, helperPropValue.NewlySetObjectID);
        	return helperPropValue;
		}

		
		/// <summary>
		/// ����� �������� ������� �� ��������, ��� ��������� ���������������� ����.
		/// </summary>
		/// <param name="sInitiatorEmployeeID"></param>
		/// <param name="sTrainedEmployeeID"></param>
		/// <param name="sRequestFormalName"></param>
		/// <param name="sRequestDescription"></param>
		/// <param name="dtDeadLine"></param>
		/// <param name="sPropCourseOrExamNumber"></param>
		/// <param name="sPropGoalStatus"></param>
		/// <param name="dtPropCourseBeginningDate"></param>
		/// <param name="sPropTrainingDirection"></param>
		/// <param name="sPropTrainingCenter"></param>
        /// <param name="sCategoryID"></param>
        /// <param name="dSum"></param>
		/// <returns></returns>
		[WebMethod( Description="" )]
		public BP_EducationRequestResult CreateEducationRequest(
			string sInitiatorEmployeeID,
			string sTrainedEmployeeID,
			string sRequestFormalName,
			string sRequestDescription,
			DateTime dtDeadLine,
			string sPropCourseOrExamNumber,
			string sPropGoalStatus,
			DateTime dtPropCourseBeginningDate,
			string sPropTrainingDirection,
			string sPropTrainingCenter, 
            string sCategoryID,
            decimal dSum) 
		{
			BP_EducationRequestResult result = new BP_EducationRequestResult();
			try 
			{
				// ������ ����� - �������� ������������ ������� ����������:
				Guid uidInitiatorEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "������������ ���������� - ���������� ������ �� �������� (sInitiatorEmployeeID)" );
				Guid uidTrainedEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sTrainedEmployeeID, "������������� ���������� - ������������ (sTrainedEmployeeID)" );
                Guid uidCategoryID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCategoryID, "������������� ��������� ��������� (sCategoryID)");
                ObjectOperationHelper.ValidateRequiredArgument( sRequestFormalName, "���������� ������������ ������ �� �������� (sRequestFormalName)" );
			
				#region #1: ��������� ������:
				// ... "��������" ds-������� "��������":
				ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance( "Incident" );
				helperIncident.LoadObject();
				if (!helperIncident.IsLoaded) throw new ApplicationException();
				#endregion
				
				#region #2: ��������� ������ ���������:
				// ������� - ��������� ������, ������������ �����/������, ��� 
				// ���������, ��� �������������� - ��� �� ��������� ������ ��
				// ������������:
				// ... �����, � ������� ����� ������ ��������:
                // ... ��� ���������:
				helperIncident.SetPropScalarRef(
					"Type",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.TypeName,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.ObjectID );
				// ... ��������� ��������� ��������� (������������ �� ��������� 
				// ����, ��. ���������� TrainingRequestProcess.DelayLoad):
				helperIncident.SetPropScalarRef(
					"State",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.TypeName,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.ObjectID );
				// ... ��������� ��������� �� ��������� (�� ��������� ����) - �� 
				// ���� ��������� �� ��������� ������, ����� - �� ������:
				helperIncident.SetPropValue( 
					"Priority", 
					XPropType.vt_i2, 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_DefaultPriority );

				// ������, �������� ����������� ������: 
				// ... ������������...
				helperIncident.SetPropValue( "Name", XPropType.vt_string, sRequestFormalName );
				// ... ���� ������ - ��������:
				if (null!=sRequestDescription && String.Empty!=sRequestDescription)
					helperIncident.SetPropValue( "Descr", XPropType.vt_string, sRequestDescription );
				// ... ���� ����� - ������� ����:
				if (DateTime.MinValue != dtDeadLine)
					helperIncident.SetPropValue( "DeadLine", XPropType.vt_date, dtDeadLine );
				// ��������� ���-��
                helperIncident.SetPropScalarRef("Category", "IncidentCategory", uidCategoryID);

				// ... ���������-���������: �� ����� ���� � ��������� �������� ������
				// �� ������������, � �� ���������� (��� ����������� �������); �������
				// ������� ��������� ������������ ��� ���������� ����������: ���������
				// ������ ����������:
				ObjectOperationHelper helperIniciator = ObjectOperationHelper.GetInstance( "Employee", uidInitiatorEmployeeID );
				helperIniciator.LoadObject(); // (���� ������ ��������������, ����� ����� ����������)
				if (!helperIniciator.IsLoaded) throw new ApplicationException();
				// ...�������� ����������������� ������ ������������ (�� ����������!)
				// � ��������� �� ��������� ������ �� ���������� � ���������:
				ObjectOperationHelper helperIniciatorUser = helperIniciator.GetInstanceFromPropScalarRef( "SystemUser" );
				helperIncident.SetPropScalarRef( 
					"Initiator",
					helperIniciatorUser.TypeName,
					helperIniciatorUser.ObjectID );
				#endregion
				
				#region #3: ��������� ������ �������:
				// ... ��������� "��������" ���������� ds-������� "�������":
				ObjectOperationHelper helperTrainedTask = ObjectOperationHelper.GetInstance("Task");
                helperTrainedTask.LoadObject();
				if (!helperTrainedTask.IsLoaded) throw new ApplicationException();
				
				int nDefaultDuration = ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.DefaultDuration_for_ManagerRole;
				
				// ...��� ���������� (��������� ����������):
				// (���������������, ��� �� ���������� ����� �� �������, �� ���������)
				nDefaultDuration = ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.DefaultDuration_for_TrainedRole;
				helperTrainedTask.SetPropValue( "PlannedTime", XPropType.vt_i4, nDefaultDuration );	
				helperTrainedTask.SetPropValue( "LeftTime", XPropType.vt_i4, nDefaultDuration );
				// ... ����� �������� � ��������� ������� �� �������:
				helperTrainedTask.SetPropValue( "InputDate", XPropType.vt_date, DateTime.Today );
				helperTrainedTask.SetPropValue( "LeftTimeChanged", XPropType.vt_dateTime, DateTime.Now );
				// ... ������: �� ��������:
				helperTrainedTask.SetPropScalarRef( 
					"Incident", 
					helperIncident.TypeName, 
					helperIncident.NewlySetObjectID );
				// ... �� ���� ����������� � ���������; ����� �� ������������, ��� ����������:
				helperTrainedTask.SetPropScalarRef( 
					"Role",
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Role_Trained.TypeName, 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Role_Trained.ObjectID );
				// ... ��� ������ ��������� � ������ ���� - ����� �� ����������:
				helperTrainedTask.SetPropScalarRef( 
					"Worker",
					"Employee",
					uidTrainedEmployeeID );
				// ... ��� �������� ������������� ������� - ��� ��, ��� ����� ��� ���������:
				helperTrainedTask.SetPropScalarRef( 
					"Planner",
					"Employee",
					uidInitiatorEmployeeID );
				// NB! -- ��������� ������ � ������ � ��������:
				helperIncident.AddArrayPropRef( "Tasks", helperTrainedTask.TypeName, helperTrainedTask.NewlySetObjectID );
				#endregion

				#region #4: �������������� ��������:
				// ���� ������ ���� �� ���� ��������������� �������� (���, 
				// ������, �� �������� ������������), �� �������� "��������", 
				// � ������� ����� ����� ������ ����� "��������" ��� ��������
				// �������:
				ObjectOperationHelper helperProp_Base = ObjectOperationHelper.GetInstance("IncidentPropValue");
				if ( DateTime.MinValue!=dtPropCourseBeginningDate 
					|| null!=sPropCourseOrExamNumber
				    || null!=sPropGoalStatus
					|| null!=sPropTrainingDirection
					|| null!=sPropTrainingCenter || dSum!=0)
				{
					helperProp_Base.LoadObject();
					if (!helperProp_Base.IsLoaded) throw new ApplicationException();
				}
				
				// �����, �� ������� �������� ��������: ���� ������ ��� �����.
				// �������� ������, �� (�) �������� "��������", (�) ���������
				// ������, � �.�. � ������ �� ��������, (�) � ������ ���������
				// ��������� ������ �� �������� � �������� ��������� ��������.
				// ���� ������ �� ������, �� ��������������� ������ �� ����� 
				// ������������� - ������ ���� ����� null; ����� ��� �����������
				// ��� ������������ ����� ���������� �� ������.
				// ��� �������� ����������� ��������������� ������� - ��. 
				// ����������:

                // ... "��������� ��������"
                ObjectOperationHelper helperProp_Sum = applayAdditionalIncidentProp(
                    helperIncident,
                    ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_Summ,
                    helperProp_Base,
                    dSum);
				// ... "����� ����� / ��������":
				ObjectOperationHelper helperProp_CourseNumber = applayAdditionalIncidentProp( 
						helperIncident, 
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_CourseNumber,
						helperProp_Base,
						sPropCourseOrExamNumber );
				
				// ... "��� ��������� �������":
				ObjectOperationHelper helperProp_GoalStatus = applayAdditionalIncidentProp( 
						helperIncident,
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_GoalStatus,
						helperProp_Base,
						sPropGoalStatus );
				
				// ... "���� ������ ��������":
				ObjectOperationHelper helperProp_CourseBeginningDate = applayAdditionalIncidentProp(
						helperIncident,
						ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_CourseBeginningDate,
						helperProp_Base,
						dtPropCourseBeginningDate );
				
				// ... "����������� ��������/������������":
				ObjectOperationHelper helperProp_TrainingDirection = applayAdditionalIncidentProp(
					helperIncident,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_TrainingDirection,
					helperProp_Base,
					sPropTrainingDirection );
				
				// ... "������� �����":
				ObjectOperationHelper helperProp_TrainingCenter = applayAdditionalIncidentProp(
					helperIncident,
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.Prop_TrainingCenter,
					helperProp_Base,
					sPropTrainingCenter );
				
                #endregion				
                #region #5: 
                // �������� ������ "IncidentCategory"
                ObjectOperationHelper helperIncidentCategory = ObjectOperationHelper.GetInstance("IncidentCategory");
                XParamsCollection paramsIncidentCategory = new XParamsCollection();
                paramsIncidentCategory.Add("ObjectID", uidCategoryID);
                // ������� ������ "IncidentCategory" �� ��� ��������������
                helperIncidentCategory.LoadObject(paramsIncidentCategory);
                // �������� �������� "��������� ���-��"
                string sCategoryName = (string)helperIncidentCategory.GetPropValue("Name", XPropType.vt_string);
                // ����� ���� ID ����� � ���������, ����� �� ��� � ��������� ������������ ���-�� � ������������ ������,
                // ��������������� ������� �������� � ������� [itws:target-folder]
                ObjectOperationHelper helperFolder = ObjectOperationHelper.GetInstance("Folder");
                XParamsCollection paramsIncFolder = new XParamsCollection();
                paramsIncFolder.Add("Parent", ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.TargetFolder.ObjectID);
                paramsIncFolder.Add("Name", sCategoryName);
                Guid uidFolderID = helperFolder.GetObjectIdByExtProp(paramsIncFolder);
                if (uidFolderID == Guid.Empty)
                    throw new ApplicationException(String.Format("����� � ������������� {0} �� �������", sCategoryName));
                helperIncident.SetPropScalarRef( 
					"Folder", 
					ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.TargetFolder.TypeName,
                    uidFolderID);
                #endregion
                #region #6: ������ ������; ������������ ����������:
                ObjectOperationHelper.SaveComplexDatagram( 
					new ObjectOperationHelper[]
						{
							helperIncident,				// ��� ��������
							helperTrainedTask,			// ������� ��� ����������
							helperProp_CourseNumber,	// ����� - �������� (�.�. null-���)...
							helperProp_GoalStatus,
							helperProp_CourseBeginningDate,
							helperProp_TrainingDirection,
							helperProp_TrainingCenter,
                            helperProp_Sum              // ����� ��������
						} 
					);
				
				// ������������ ��������� � ������������ ����������:
				// ... ����������, ����� �������� �����:
				helperIncident.LoadObject();
				if (!helperIncident.IsLoaded) throw new ApplicationException();
				// ���������: ������������� � ����� ���������:
				result.EducationIncidentID = helperIncident.ObjectID.ToString();
				result.EducationIncidentNumber = helperIncident.GetPropValue( "Number", XPropType.vt_i4 ).ToString();
				#endregion
			}
			catch( Exception err )
			{
				// �������� ���������� � ������ ������ - ��� �������� � ���� ������:
				result.ErrorDescription = err.Message;
				result.ErrorStack = err.ToString();
				// ... ��� ��������� ���� - ������ ������:
				result.EducationIncidentID = String.Empty;
				result.EducationIncidentNumber = String.Empty;
			}
			return result;
		}
        /// <summary>
        /// ����� ��������� ��������� ���-�� �� ��������.
        /// </summary>
        /// <param name="nIncidentNumber"></param>
        /// <param name="sIncidentStatusID"></param>
        /// <param name="sDescription"></param>
        /// <param name="dtDeadLine"></param> 
        /// <returns></returns>
        [WebMethod(Description = "��������� ��������� �� ��������")]
        public BP_EducationRequestResult UpdateIncidentStatus(int nIncidentNumber , 
                                                                string sIncidentStatusID, 
                                                                string sDescription,
                                                                DateTime dtDeadLine)
        {

            BP_EducationRequestResult result = new BP_EducationRequestResult();
            try
            {
                Guid uidIncidentStatus = ObjectOperationHelper.ValidateRequiredArgumentAsID(sIncidentStatusID, "������������ ��������� ���������");
                ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance("Incident");
                XParamsCollection keyIncidentParams = new XParamsCollection();
                // ��������� � ��������� ����� ���-��
                keyIncidentParams.Add("Number", nIncidentNumber);
                keyIncidentParams.Add("Type", ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.IncidentType.ObjectID);
                // �������� ������ � ������������ ����������� ��� ������
                helperIncident.LoadObject(keyIncidentParams);
                // ������� �������� �������, ������� ����� �� ����������
                helperIncident.DropPropertiesXml(new string[] {"Number", "Type" });
                helperIncident.SetPropScalarRef(
                    "State",
                    ServiceConfig.Instance.CommonServiceParams.TrainingRequestProcess.EduIncident_StartState.TypeName,
                    uidIncidentStatus);
                // "��������" ���������
                string sDescr = String.Empty;
                if (!String.IsNullOrEmpty(sDescription))
                {
                    helperIncident.UploadBinaryProp("Solution");
                    sDescr = helperIncident.PropertyXml("Solution").InnerText + "\n" + sDescription;
                    helperIncident.SetPropValue("Solution", XPropType.vt_text, sDescr);
                }
                // "���� �������� �����" 
                if (dtDeadLine != DateTime.MinValue)
                    helperIncident.SetPropValue("DeadLine", XPropType.vt_date, dtDeadLine);
                else
                    helperIncident.SetPropValue("DeadLine", XPropType.vt_date, null);
                // �������� �������� � ����� ����������
                helperIncident.SaveObject();
                result.EducationIncidentID = helperIncident.ObjectID.ToString();
                result.EducationIncidentNumber = nIncidentNumber.ToString();

                
            }
            catch (Exception err)
            {
                // �������� ���������� � ������ ������ - ��� �������� � ���� ������:
                result.ErrorDescription = err.Message;
                result.ErrorStack = err.ToString();
                // ... ��� ��������� ���� - ������ ������:
                result.EducationIncidentID = String.Empty;
                result.EducationIncidentNumber = String.Empty;
            }
            return result;
        }
		#endregion
		
		#region ������, ������������ ��� ������������� ������ ��������

		/// <summary>
		/// ���������� ��������� ����� �������� ������ ����� (Folder) ���� 
		/// "������", �������� ��������������� � ��������� �������������. 
		/// ��������� ������������ ������� ��������������, � ��� �� ��� �����
		/// </summary>
		/// <param name="sProjectID">������������� �����-�������, � ������</param>
		/// <param name="arrPreloadProperties">
		/// ������ ������������ ������������ ����������, �.�. null
		/// </param>
		/// <param name="bIsStrictLoad">
		/// ������� "�������" �������� - ���� ��������� ������ �� ����� ������, �����
		/// ������������� ����������; ���� �������� ����� � false, � ������ �� ����� 
		/// ������, �� � ���. ���������� ����� ������ null;
		/// </param>
		/// <returns>
		/// ������������������ ������ - helper ��� null ���� ������ �� ������, 
		/// � ������� "�������" �������� (bIsStrictLoad) �������
		/// </returns>
		/// <exception cref="ArgumentNullException">���� sProjectID ���� null</exception>
		/// <exception cref="ArgumentException">���� sProjectID ���� ������ ������</exception>
		/// <exception cref="ArgumentException">���� ������� � ID sProjectID ��� � bIsStrictLoad=true</exception>
		/// <exception cref="ArgumentException">���� sProjectID ������ ����� - �� ������</exception>
		private ObjectOperationHelper loadProject( string sProjectID, bool bIsStrictLoad, string[] arrPreloadProperties ) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "������������� ������� (sProjectID)" );
			
			// ��������� ������: � ����� ������ ����������� "������" ��������
			// ��� ���� ���������, ����������� ��� ���: ���������� ������� ������� 
			// �� �������� ����� bIsStrictLoad:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			if ( !helper.SafeLoadObject( null, arrPreloadProperties ) )
			{
				if (bIsStrictLoad)
					throw new ArgumentException( "������ � ��������� ��������������� (" + sProjectID + ") �� ������", "sProjectID" );
				else
					return null;
			}

			// ���������, ��� ����������� ��������, �������������� �������� ���� 
			// "Folder" ���� ������ - �������� �������� "����" �����:
			if ( FolderTypeEnum.Project != getFolderType(helper) )
				throw new ArgumentException( "�������� ������������� (sProjectID) �� �������� ��������������� �������" );
			
			return helper;			
		}



        /// <summary>
        /// ���������� ��������� ����� �������� ������ ����� (Folder) ���� �����
        /// , �������� ��������������� � ��������� �������������. 
        /// ��������� ������������ ������� ��������������, � ��� �� ��� �����
        /// </summary>
        /// <param name="sActivityID">������������� �����-�������, � ������</param>
        /// <param name="arrPreloadProperties">
        /// ������ ������������ ������������ ����������, �.�. null
        /// </param>
        /// <param name="bIsStrictLoad">
        /// ������� "�������" �������� - ���� ��������� ������ �� ����� ������, �����
        /// ������������� ����������; ���� �������� ����� � false, � ������ �� ����� 
        /// ������, �� � ���. ���������� ����� ������ null;
        /// </param>
        /// <returns>
        /// ������������������ ������ - helper ��� null ���� ������ �� ������, 
        /// � ������� "�������" �������� (bIsStrictLoad) �������
        /// </returns>
        /// <exception cref="ArgumentNullException">���� sActivityID ���� null</exception>
        /// <exception cref="ArgumentException">���� sActivityID ���� ������ ������</exception>
        /// <exception cref="ArgumentException">���� ������� � ID sActivityID ��� � bIsStrictLoad=true</exception>
        /// <exception cref="ArgumentException">���� sActivityID ������ ����� - �� ������</exception>
        private ObjectOperationHelper loadActivity(string sActivityID, bool bIsStrictLoad, string[] arrPreloadProperties)
        {
            // ��������� ������������ ������� ����������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sActivityID, "������������� ������� (sActivityID)");

            // ��������� ������: � ����� ������ ����������� "������" ��������
            // ��� ���� ���������, ����������� ��� ���: ���������� ������� ������� 
            // �� �������� ����� bIsStrictLoad:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            if (!helper.SafeLoadObject(null, arrPreloadProperties))
            {
                if (bIsStrictLoad)
                    throw new ArgumentException("������ � ��������� ��������������� (" + sActivityID + ") �� ������", "sActivityID");
                else
                    return null;
            }
            return helper;
        }

	
		/// <summary>
		/// ���������� ����� ��������� �������� "���� �����" (Folder.Type) ���
		/// �������� ������������ FolderTypeEnum, ��� ������ ������� "�����",
		/// ���������� �� ��������������� �������-heler-�
		/// </summary>
		/// <param name="helperProject">��������������� ������ � ������� ������� "�����"</param>
		/// <returns>��� �����, ��� �������� ������������ FolderTypeEnum</returns>
		private FolderTypeEnum getFolderType( ObjectOperationHelper helperProject ) 
		{
			if (null == helperProject) throw new ApplicationException("��������� ������ ObjectOperationHelper �� �������!");
			if ("Folder" != helperProject.TypeName) throw new ApplicationException("������ �� �������� ������; ����������� ���� ����� ����������!");

			return (FolderTypeEnum)helperProject.GetPropValue( "Type", XPropType.vt_i2 );
		}
		

		/// <summary>
		/// ����� �������������� �������� ��������� ����� � ��������������� 
		/// ��������� �������
		/// </summary>
		/// <param name="enFolderState">��������� �����</param>
		/// <returns>��������������� ��������� �������</returns>
		private ProjectStates getFolder2ProjectState( FolderStates enFolderState ) 
		{
			ProjectStates enProjectState;
			switch (enFolderState)
			{
				case FolderStates.Open: enProjectState = ProjectStates.Open; break;
				case FolderStates.WaitingToClose: enProjectState = ProjectStates.WaitingToClose; break;
				case FolderStates.Closed: enProjectState = ProjectStates.Closed; break;
				case FolderStates.Frozen: enProjectState = ProjectStates.Frozen; break;
				default:
					throw new ArgumentException( "����������� ��������� ����� (enFolderState)","enFolderState" );
			}
			return enProjectState;
		}

		/// <summary>
		/// ����� �������������� �������� ��������� ������� � ��������������� 
		/// ��������� �����
		/// </summary>
		/// <param name="enProjectState">��������� �������</param>
		/// <returns>��������������� ��������� �����</returns>
		private FolderStates getProject2FolderState(ProjectStates enProjectState)
		{
			FolderStates enFolderState;
			switch (enProjectState)
			{
				case ProjectStates.Open: enFolderState = FolderStates.Open; break;
				case ProjectStates.WaitingToClose: enFolderState = FolderStates.WaitingToClose; break;
				case ProjectStates.Closed: enFolderState = FolderStates.Closed; break;
				case ProjectStates.Frozen: enFolderState = FolderStates.Frozen; break;
				default:
					throw new ArgumentException("����������� ��������� ������� (enProjectState)", "enProjectState");
			}
			return enFolderState;
		}
		
		/// <summary>
		/// ���������� ����� �������� ������ �� ������������ ������� - ���������
		/// � ������ ���� ProjectInfo
		/// </summary>
		/// <param name="helper">������ ���������, ������ ������������ ������ ���� Folder � �.�. ��������</param>
		/// <returns>������ ProjectInfo � ��������� ������ �������</returns>
		private ProjectInfo getProjectInfoFromHelper( ObjectOperationHelper helper ) 
		{
			// �������� ������������ ���������� ������ + ��������������� ����������� 
			// ��������� �������������: 
			// (1) ��������, ��� ��� heler-������ ����� � ������������ ������ ������� ���� "�����" (Folder):
			if (null==helper)
				throw new ArgumentNullException( "helper", "������� � ProjectInfo ����������: ��������������� ������-��������� �� �����" );
			if ("Folder"!=helper.TypeName)
				throw new ArgumentException( "������� � ProjectInfo ����������: ��������������� ������-��������� ������������ ������ ����, ��������� �� Folder (" + helper.TypeName + ")", "helper" );
			// (2) ��������, ��� ��� - ������:
			if ( FolderTypeEnum.Project != getFolderType(helper) )
				throw new ApplicationException( String.Format(
					"������������ ������: ��������� ������ � ��������������� {0} �� �������� �������� (��� ����� - {1})",
					helper.ObjectID.ToString(), 
					((FolderTypeEnum)helper.GetPropValue("Type",XPropType.vt_i2)).ToString() )
				);

			ObjectOperationHelper helperParentFolder = helper.GetInstanceFromPropScalarRef( "Parent", false );
			ObjectOperationHelper helperOrg = helper.GetInstanceFromPropScalarRef( "Customer", false );
			if (null==helperOrg)
				throw new ApplicationException( String.Format(
					"������������ ������: ��� ���������� ������� � ��������������� {0} " +
					"�� ������ ����������� �������, � �������� ��������� ������ ������",
					helper.ObjectID.ToString() )
				);
	
			ProjectInfo info = new ProjectInfo();
			// ��������� �������� ������ - ��������� �����. ���������� �������:
			info.ObjectID = helper.ObjectID.ToString(); 
			info.CustomerID = helperOrg.ObjectID.ToString();
			info.Name = helper.GetPropValue( "Name", XPropType.vt_string ).ToString();
			//info.Code = safeReadData( helper, "ProjectCode" ).ToString();
			info.NavisionID = safeReadData( helper, "ExternalID" );
            ObjectOperationHelper helperActivityType = helper.GetInstanceFromPropScalarRef("ActivityType", false);
            Guid uidActType = Guid.Empty;
            if (helperActivityType != null)
            {
                uidActType = helperActivityType.ObjectID;
                info.IsPilot = (uidActType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            }
          	// ������ �������
			info.State = getFolder2ProjectState( (FolderStates)helper.GetPropValue( "State", XPropType.vt_i2) );
			// �������� �������������� ������������ ������� - ���� ������� �����, ����� - null;
			info.MasterProjectID = (null==helperParentFolder ? null : helperParentFolder.ObjectID.ToString());
			// ...��������� ������: ���� ��� ������� ��� ��� Navision ���� ������ ������, �� ������ �� null:
			if (String.Empty == info.Code)
				info.Code = null;
			if (String.Empty == info.NavisionID)
				info.NavisionID = null;
			
			return info;
		}

		
		/// <summary>
		/// ���������� ������ ���� ��������, �������������� � ������� Incident Tracker, 
		/// ��� ������ ����������� ������ Croc.IncidentTracker.Services.ProjectInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.ProjectInfo"/>
		/// </summary>
		[WebMethod(Description="���������� ������ ���� ��������, �������������� � ������� Incident Tracker")]
		public ProjectInfo[] GetProjectsInfo() 
		{
			// ������� ������ ���� ��������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-Projects", null );

			if ( null == oDataTable )
				return new ProjectInfo[0];
            Guid uidActivityType = Guid.Empty;
			ProjectInfo[] arrProjectsInfo = new ProjectInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// ��������, ��� ������������� ����� ���� "������"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if ( FolderTypeEnum.Project != enType )
					continue;
				
				ProjectInfo info = new ProjectInfo();

				// ��������� ������ ������������ �����
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				info.CustomerID = oDataTable.Rows[nRowIndex]["CustomerID"].ToString();
				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();
                uidActivityType = new Guid(oDataTable.Rows[nRowIndex]["ActivityType"].ToString());
                info.IsPilot = (uidActivityType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
				// ��� ������� � ��� � Navision � ����� ������ ����� ���� � �� ������;
				// ����� ����, ������ ������� �������� ��� ������ ������ ������ ��������
				// �� ������ �������� null - ������� ������ ������ ������ ������ ������
				// � null-�:
				if ( String.Empty == info.Code )
					info.Code = null;
				
				if ( DBNull.Value==oDataTable.Rows[nRowIndex]["NavisionID"] )
					info.NavisionID = null;
				else
					info.NavisionID = oDataTable.Rows[nRowIndex]["NavisionID"].ToString();
				if ( String.Empty == info.NavisionID )
					info.NavisionID = null;
				
				// ��������� �������: ����� ��������� ��������� - �������� �� IT 
				// ����� ��������� � �������� ��� ���:
				info.State = getFolder2ProjectState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// ������ �� ������� ������ - ����� ���� � �� ������:
				if ( DBNull.Value == oDataTable.Rows[nRowIndex]["MasterProjectID"] )
					info.MasterProjectID = null;
				else
					info.MasterProjectID = oDataTable.Rows[nRowIndex]["MasterProjectID"].ToString();

				// �������� ������ � ������
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		/// <summary>
		/// ���������� ������ �������, ��������������� � ������� Incident Tracker
		/// </summary>
		/// <param name="sProjectID">
		/// ������ � ��������������� �������, ��� �������� ��������� ��������� 
		/// ������. ���� ��������� ������ � ������� �� ������, ����� ����������
		/// null (��. �������� �����������)
		/// </param>
		/// <returns>
		/// -- ��������� ProjectInfo � ��������� �������, ���� ��������� ������ 
		///		����������� � �������;
		///	-- null, ���� �������� ���������� ������� � ������� �� �������
		/// </returns>
		[WebMethod(Description="���������� ������ �������, ��������������� � ������� Incident Tracker")]
		public ProjectInfo GetProjectInfoByID( string sProjectID ) 
		{
			// �������� ����������� ���������, � ��� ������������� �����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sProjectID, "������������� ������� (sObjectID)" );

			// ������� ��������� ������ ���������� ������� ���� "�����" (Folder)
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder",uidProjectID );

			// ������ �� ������ - � ������������ �� ������������� ���������� null:
			if ( !helper.SafeLoadObject(null) )
				return null;
			else
				return getProjectInfoFromHelper(helper);
		}

		
		/// <summary>
		/// ���������� ������ � ��������� �������, ������������ ��� ���������� �������
		/// </summary>
		/// <param name="sProjectID">
		/// ������ (System.String) � ��������������� �������, ��� �������� 
		/// ��������� ��������� ������. ������� �������� �������� ������������
		/// </param>
		/// <returns> 
		/// �������� ��������� �������, ��� ������ ����������� ������ 
		/// ProjectTeamParticipant.
		/// <seealso cref="Croc.IncidentTracker.Services.ProjectTeamParticipant"/>
		/// </returns>
		///	<exception cref="ArgumentNullException">���� sProlectID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sProlectID ����� � String.Empty</exception>
		///	<exception cref="ArgumentException">���� ������� � ��������������� sProlectID ���</exception>
		[WebMethod(Description="���������� ������ � ��������� �������, ������������ ��� ���������� �������")]
        public ProjectTeamParticipant[] GetActivityTeam(string sActivity) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sActivity, "������������� ������� (sProjectID)" );
			
			// ������� ������� ������ ���������� �������:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "ProjectID", uidProjectID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-ProjectTeam", paramsCollection );

			if (null == oDataTable)
				return new ProjectTeamParticipant[0];

			// ��������� ���������, � ������� ����� ��������:
			// ... ���������� �� ���� ����������
			ArrayList listProjectParticipants = new ArrayList();
			// ... ���������� �� ����� ���������������� ���������
			ArrayList listParticipantRoles = new ArrayList();

			string sCurrEmployee = String.Empty;
			string sPrevEmployee = String.Empty;
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				sCurrEmployee = oDataTable.Rows[nRowIndex]["EmployeeID"].ToString();
				if (sCurrEmployee!=sPrevEmployee)
				{
					if (String.Empty == sPrevEmployee)
						sPrevEmployee = sCurrEmployee;
					else
					{
						ProjectTeamParticipant itemTeamInfo = new ProjectTeamParticipant();
						itemTeamInfo.EmployeeID = sPrevEmployee;
						itemTeamInfo.RoleIDs = new string[ listParticipantRoles.Count ];
						if (listParticipantRoles.Count>0)
							listParticipantRoles.CopyTo( itemTeamInfo.RoleIDs, 0 );

						listProjectParticipants.Add( itemTeamInfo );

						sPrevEmployee = sCurrEmployee;
						listParticipantRoles.Clear();
					}
				}
				if ( DBNull.Value != oDataTable.Rows[nRowIndex]["RoleID"] )
					listParticipantRoles.Add( oDataTable.Rows[nRowIndex]["RoleID"].ToString() );
			}
			if (String.Empty != sCurrEmployee)
			{
				ProjectTeamParticipant itemTeamInfo = new ProjectTeamParticipant();
				itemTeamInfo.EmployeeID = sCurrEmployee;
				itemTeamInfo.RoleIDs = new string[ listParticipantRoles.Count ];
				if (listParticipantRoles.Count>0)
					listParticipantRoles.CopyTo( itemTeamInfo.RoleIDs, 0 );

				listProjectParticipants.Add( itemTeamInfo );
			}
			
			ProjectTeamParticipant[] arrTeamInfo = new ProjectTeamParticipant[ listProjectParticipants.Count ];
			if (listProjectParticipants.Count > 0)
				listProjectParticipants.CopyTo( arrTeamInfo, 0 );
			return arrTeamInfo;
		}


		/// <summary>
		/// ������� � ������� Incident Tracker �������� ������� � ��������� �����������
		/// </summary>
		/// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
		/// <param name="sCode">������ � ����� �������</param>
		/// <param name="sName">������ � ������������� �������</param>
		/// <param name="sNavisionID">������ � ����� ������� � Navision</param>
		/// <param name="bIsPilot">������� �������, ������������ �� ���� "������"</param>
		/// <param name="enInitialState">��������� ��������� �������</param>
		/// <param name="sMastrProjectID">������ � ��������������� �������� �������</param>
		/// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� �������</param>
		/// <returns>������ � ��������������� ���������� �������</returns>
		[WebMethod(Description="������� � ������� Incident Tracker �������� ������� � ��������� �����������")]
		public string CreateProject(
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			bool bIsPilot,
			ProjectStates enInitialState,
			string sMastrProjectID,
			string sInitiatorEmployeeID ) 
		{
			// ��������� ������������ ������� ����������:
			ObjectOperationHelper.ValidateRequiredArgument( sCustomerID, "������������� ����������� - ������� (sCustomerID)", typeof(Guid) );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "���������� ��� ������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "������������ ������� (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sMastrProjectID, "������������� �������� ������� (sMasterProjectID)", typeof(Guid) );
			ObjectOperationHelper.ValidateRequiredArgument( sInitiatorEmployeeID, "������������� ���������� - ���������� �������� ������� (sInitiatorEmployeeID)", typeof(Guid) );

			// ����� - ���������� ������������� ������ �������, � �������� ����. 
			// �����, ��������� ������ � ���� �������� ���������������:
			string sNewProjectID = Guid.NewGuid().ToString();
			CreateIdentifiedProject( sNewProjectID, sCustomerID, sCode, sName, sNavisionID, bIsPilot, enInitialState, sMastrProjectID, sInitiatorEmployeeID );
			
			return sNewProjectID;
		}

		/// <summary>
		/// ������� � ������� Incident Tracker �������� ������� � ��������� ����������� 
		/// � ������� ��������� ���������� ���������������
		/// </summary>
		/// <param name="sNewProjectID">������ � ��������������� ������������ �������</param>
		/// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
		/// <param name="sCode">������ � ����� �������</param>
		/// <param name="sName">������ � ������������� �������</param>
		/// <param name="sNavisionID">������ � ����� ������� � ����. Navision</param>
		/// <param name="bIsPilot">������� �������, ������������ �� ���� "������"</param>
		/// <param name="enInitialState">��������� ��������� �������</param>
		/// <param name="sMastrProjectID">������ � ��������������� �������� �������</param>
		/// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� �������</param>
		[WebMethod(Description="������� � ������� Incident Tracker �������� ������� � ��������� ����������� � ������� ��������� ���������� ���������������")]
		public void CreateIdentifiedProject(
			string sNewProjectID,
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			bool bIsPilot,
			ProjectStates enInitialState,
			string sMastrProjectID,
			string sInitiatorEmployeeID ) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewProjectID,"���������� ������������� ������������ ������� (sNewProjectID)" );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "���������� ��� ������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "������������ ������� (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sMastrProjectID, "������������� �������� ������� (sMasterProjectID)", typeof(Guid) );
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sCustomerID, "������������� ����������� - ������� (sCustomerID)" );
			Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "������������� ���������� - ���������� �������� ������� (sInitiatorEmployeeID)" );

			// ��������� ��������: 
			// ������-�������: �������� �������� ��� ����-�� ��� ������ ������� ���������
			// ������� ���������, ��� �������� ����������� �� ���� ����; ������������� 
			// ���������� �.�. ����� � ���������� ���������������� ����� �������� (�, �����.
			// ����������� � ������� - ��������� ������������, ServiceConfig)
			if ( uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID )
				throw new ArgumentException( 
					String.Format(
						"�������� �������� ��� ����������� - ��������� ������� \"{0}\" ��� ������ ������ ������� " +
						"���������. �������� ����� �������� ������ ����������� ��������������� � ������� Incident " +
						"Tracker, ������������� �������, ���������� ������������ ������������.",
						ServiceConfig.Instance.OwnOrganization.GetPropValue( "ShortName", XPropType.vt_string )
					), "sCustomerID" 
				);

			// �������� ������ ������� - ������� - ���������, � ����� �������� 
			// ������������ ������������� �� ��������:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder" );
			helperProject.LoadObject();
			helperProject.NewlySetObjectID = uidNewProjectID;
			
			// ������ �������� �������, � �����. � ��������� ���������� ����������:
			// ... ������ - ��� ����� � ����� "������":
			helperProject.SetPropValue( "Type", XPropType.vt_i2, FolderTypeEnum.Project );
            // ���� � ��� ������� ��������� �������, �� ��������� ��� ��������� ������ "��������/�������������� �������",
			// ����� "������� �������"; ������������� �����. Activity Type ����� �� ������������:
            if (bIsPilot)
                helperProject.SetPropScalarRef(
                        "ActivityType",
                        ServiceConfig.Instance.PilotProjectsActivityType.TypeName,
                        ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            else
			    helperProject.SetPropScalarRef( 
				    "ActivityType", 
				    ServiceConfig.Instance.ExternalProjectsActivityType.TypeName, 
				    ServiceConfig.Instance.ExternalProjectsActivityType.ObjectID );

			// ... ������ ��� ���������� �������:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sName );
			// ... ������������� ������� � Navision ��� �������� �� �������� ������������;
			// � ���. �������� ����� ���� ����� null ��� ������ ������ - ������ ��� 
			// � ������ ������ - ��� ������ � �� ����� NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNavisionID? String.Empty : sNavisionID) );
			// ... ������ ������� ��� �������� ��������� ����: 
			helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getProject2FolderState(enInitialState));

			// ����������� ������:
			// ...�� ���������� - ���������� ������� 
			helperProject.SetPropScalarRef( "Initiator", "Employee", uidInitEmployeeID );
			// ...�� �����������:
			helperProject.SetPropScalarRef( "Customer", "Organization", uidOrganizationID );
			// ...�� ������� ������ (���� ������� �����):
			if (null!=sMastrProjectID)
				helperProject.SetPropScalarRef( 
					"Parent", "Folder", 
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sMastrProjectID, "������������� �������� ������� (sMasterProjectID)" )
				);
			
			// ���������� ����� ������:
			helperProject.SaveObject();
		}

		/// <summary>
		/// ��������� ���������� �������� ���������� ������� � ������� Incident Tracker.
		/// </summary>
		/// <param name="sProjectID">��������� ������������� �������������� ����������� �������� �������</param>
		/// <param name="sNewCustomerID">��������� ������������� �������������� ����������� - �������</param>
		/// <param name="sNewCode">������ � ����� ����� �������</param>
		/// <param name="sNewName">������ � ����� ������������� �������</param>
		/// <param name="sNewNavisionID">������ � ����� ����� ������� � Navision</param>
		/// <param name="bIsPilot">������� ��������� �������</param>
		/// <returns>
		/// -- True - ���� ��������� ������ ������ � ������� ��������;
		/// -- False - ���� ��������� ������ �� ������.
		/// </returns>
		/// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
		[WebMethod(Description="��������� ���������� �������� ���������� ������� � ������� Incident Tracker")]
		public bool UpdateProject(
			string sProjectID,
			string sNewCustomerID,
			string sNewCode,
			string sNewName,
			string sNewNavisionID,
			bool bIsPilot ) 
		{
			// ��������� ��������
			//ObjectOperationHelper.ValidateRequiredArgument( sNewCode, "���������� ��� ������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sNewName, "������������ ������� (sName)" );
			Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewCustomerID, "������������� ����������� - ������� (sCustomerID)" );

			// ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
			ObjectOperationHelper helperProject = loadProject( sProjectID, false, null );
			// ... ���� ������ �� ������ - ������ ������ false:
			if (null==helperProject)
				return false;

			// �������� �������� ������ �������:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sNewCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sNewName );
			// ������������� ������� � Navision ��� �������� �� �������� ������������;
			// ������� � ���. ���������� �������� ��������� ����������� � null, � ������
			// ������; null �������� � ������ ������ - ��� ������ � �� ����� NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNewNavisionID? String.Empty : sNewNavisionID) );
			
			// ������� ��������� �������
            bool bIsPilotNow = false;
            ObjectOperationHelper helperActivityType = helperProject.GetInstanceFromPropScalarRef("ActivityType", false);
            Guid uidActType = Guid.Empty;
            if (helperActivityType != null)
            {
                uidActType = helperActivityType.ObjectID;
                bIsPilotNow = (uidActType == ServiceConfig.Instance.PilotProjectsActivityType.ObjectID);
            }
            if (bIsPilot != bIsPilotNow)
			{
				// ���� ������ �� �������� "�������", �� ������� "�������" ������:
				if (!bIsPilotNow)	
					throw new ArgumentException( 
						"��������� �������� \"������\" ��� �������� ������� ���������!",
						"����� �������� �������� \"���������\" ������� (bIsPilot)" 
					);
				else // bIsPilotNow, � ���� ������� ���������:
                    helperProject.SetPropScalarRef(
                        "ActivityType",
                        ServiceConfig.Instance.ExternalProjectsActivityType.TypeName,
                        ServiceConfig.Instance.ExternalProjectsActivityType.ObjectID);
			}
           	
			// ������������ ����������� �������: ��������, ����� ����������� ������� ������:
			ObjectOperationHelper helperOrg = helperProject.GetInstanceFromPropScalarRef( "Customer" );
			if (helperOrg.ObjectID!=uidNewCustomerOrgID)
				helperProject.SetPropScalarRef( "Customer", "Organization", uidNewCustomerOrgID );

			// ������� � ���������� ��� ��������, ������� ����� �� ����������:
			helperProject.DropPropertiesXml( new string[]{"Type", "State", "IsLocked", "Parent" } );
			// ���������� ���������� ������:
			helperProject.SaveObject();

			return true;
		}

		
		/// <summary>
		/// �������� ������ �� "�������" ������ ��� ���������� �������. 
		/// ����� ������������ ��� �� ��� ������ ������ �� "�������" ������.
		/// </summary>
		/// <param name="sProjectID">
		/// ��������� ������������� �������������� ����������� �������� �������
		/// </param>
		/// <param name="sNewMasterProjectID">
		/// ��������� ������������� �������������� "��������" ������� ��� null
		/// </param>
		[WebMethod(Description="�������� ������ �� ������� ������ ��� ���������� �������")]
		public void UpdateMasterProjectRef(
			string sProjectID, 
			string sNewMasterProjectID ) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "������������� ������������ ������� (sProjectID)" );
			
			Guid uidNewMasterProjectID = Guid.Empty;
			if ( null != sNewMasterProjectID )
				uidNewMasterProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
					sNewMasterProjectID, "������������� �������� ������� (sNewMasterProjectID)" );
			
			// ��������� ��������� ������:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			helperProject.LoadObject();

			if (Guid.Empty == uidNewMasterProjectID)
				helperProject.PropertyXml("Parent").RemoveAll();
			else
			{
				// ����������� ������ ��������:
				XmlElement xmlRefProp = (XmlElement)helperProject.PropertyXml("Parent").SelectSingleNode("Folder");
				// ������ � ����������� ������� ��� ������ - ������� ������:
				if (null==xmlRefProp)
					helperProject.SetPropScalarRef( "Parent", "Folder", uidNewMasterProjectID );
				else
				{
					// �������� - ��������, ������������� ����������� ����������� � �� ���������:
					ObjectOperationHelper helperMasterProject = helperProject.GetInstanceFromPropScalarRef( "Parent" );
					if (helperMasterProject.ObjectID != uidNewMasterProjectID)
						// ���������: ����������� ������ ������
						helperProject.SetPropScalarRef( "Parent","Folder",uidNewMasterProjectID );
					else
						// �� ���������: ������� �������� ������ - Storage ������ ��������� �� �����
						helperProject.DropPropertiesXml( "Parent" );
				}
			}

			helperProject.DropPropertiesXmlExcept( "Parent" );
			helperProject.SaveObject();
		}

        /// <summary>
        /// �������� ������ � ����������� ���������� ������� � ��������� �������������.
        /// </summary>
        /// <param name="sProjectID">
        /// ��������� ������������� �������������� ����������� �������� �������. 
        /// ������� �������� ��-�� ������������. 
        /// </param>
        /// <param name="aDirectionsIDs">
        /// ������ ����� � ���������������� �����������, ����������� � ��������. 
        /// ��� ����� �������� ����������� ��� ������� ����� ��������. � �������� 
        /// �������� ����� ���� ����� ������ ������ - � ���� ������ ��� �����������
        /// ��� ���������� ������� ����������.
        /// ���������� ����������� ������ ���� ������������ � ������� Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - ���� ��������� ������ ������ � ������� ��������;
        /// -- False - ���� ��������� ������ �� ������
        /// </returns>
        /// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
        [WebMethod(Description = "�������� ������ � ����������� ���������� ������� � ��������� �������������")]
        [System.Obsolete("use method UpdateProjectDirectionsAndExpenseRatio")]
        public bool UpdateProjectDirections(
            string sProjectID,
            string[] aDirectionsIDs)
        {
            // �������� ���������� ��������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "������������� ������� (sProjectID)");
            // ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
            if (null == aDirectionsIDs)
                aDirectionsIDs = new string[0];


            // #1:
            // ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
            ObjectOperationHelper helperProject = loadProject(sProjectID, false, new string[] { "FolderDirections" });
            // ... ���� ������ �� ������ - ������ ������ false:
            if (null == helperProject)
                return false;

            // ����� ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections,
            // ��� ��������� ������ � XML ���������� � ������ �������� ����
            helperProject.DropPropertiesXmlExcept("FolderDirections");


            // #2:
            // ����� ������� � ����������� ����������� ��� ������ ����. ���������� 
            // ������� FolderDirection, ������� ����� ������ �������� ���� ������
            // �� �����������. 
            //
            // ��� ������� ��������� ����������� �������� ��������� ������ ������ 
            // FolderDirection; ����� �� ����� ������� ��, ������� � ���������������
            // �������� ����������� - ��������� ����� ��������. ��� ���� � ������� 
            // ������� �� ���� ������� ������ - � ��������� ����� �������� ������ 
            // ������ ������; ��� ������ � ����� �������, ������ ��� ��� ������� 
            // ����� ������� ����������� ���������� (��. ����� #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[aDirectionsIDs.Length + 1];
            for (int nIndex = 0; nIndex < aDirectionsIDs.Length; nIndex++)
            {
                // ��������� ������������� ��������� �����������
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(aDirectionsIDs[nIndex], String.Format("������������� ����������� aDirectionsIDs[{0}]", nIndex));

                // ������ ����� ������������ �����������
                foreach (XmlElement xmlFolderDirection in helperProject.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(aDirectionsIDs[nIndex], StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperProject.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // ��������� "��������" ������ ���������� ds-������� FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... ����������� ������ �� �����������:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... � ����� ����������� ������ �� ������:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "���� ������" - � ����:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 0);
            }
            // ... ��������� ������� ������� - ��� ������ (��. ����� #4):
            arrHelpers[aDirectionsIDs.Length] = helperProject;


            // #3:
            // ���� ��� ������� ���� ���������� �����������, ��, �����., ���������� 
            // ��������� ������� FolderDirection, ����������� ������ � �����������. 
            // 
            // ��� ������ ����� �/� �������� � ������������ ��� ��������� ������� ����
            // �������. �������� �������� ������������ � ������� ���������� ���������� 
            // ������ �������, ��� "�����������" ����������, � ������� ��� FolderDirection
            // ����� �������� ��� ��������� - ��� ��� ����� ����� ������� delete="1".
            // 
            // ������� XML-������ �������� FolderDirection, �������� ��� ���� �� ���� -
            // ����� ��� �������� ����������� ���������� ������ �� ����� ����������
            // ��� ������������ �������� �� ��������� �������� (�� #4). � ����� �������
            // "�����" ��� ������ ������ �� FolderDirections ������, � ����� - �������:

            XmlElement xmlFolderDirections = (XmlElement)helperProject.PropertyXml("FolderDirections").CloneNode(true);
            // ... ������� ������ ������:
            helperProject.ClearArrayProp("FolderDirections");
            // ... ����� - ���������:
            // ���� �� ������� ��������������� ��������, � ������ ��� ����:
            // -- ��� ��������� ��� - ��� ������, ��� ��������� �� ����, ������� 
            //		���� �� ����� ������� ����� ����;
            // -- ��� ������ ��������������� �������� � ������� ��� �� ��������, 
            //		������� ��� ��������� �������������� ���������� NewlySetObjectID
            for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                helperProject.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


            // #4:
            // ������ ����������� ���������� ��� ������. �����: (�) ������ ������ 
            // ��������� �������, (�) ������ ����� FolderDirection-��, (�) ������ 
            // ������, ��������� FolderDirection-��
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
            // ... � ���������� ��� ���� ���������� � ����� ������� - �� ������ 
            // ���������� �� helper-��. ������� ������ ���������:
            foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                // ���������� ������ ���������� FolderDirection ��� �� ����� - ������� (�����)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... ������������� �������� delete="1", ���� ��� �������, 
                // ����������� ��� ��������������� ������ � �� ���� �������
                xmlDeletedFolderDirection.SetAttribute("delete", "1");
            }


            // #5: 
            // ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
            // ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
            // FolderDirection, ��������� ������ �����-�������
            ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

            return true;
        }

       	/// <summary>
		/// �������� ������ � ����������� ���������� ������� � ��������� �������������.
		/// </summary>
		/// <param name="sProjectID">
		/// ��������� ������������� �������������� ����������� �������� �������. 
		/// ������� �������� ��-�� ������������. 
		/// </param>
        /// <param name="ProjectDirections">
        /// ������ ������� ProjectDirection, � ������� ���������� ���������� �� ������������ 
        /// ����������� � ��������. 
		/// ��� ����� �������� ����������� ��� ������� ����� ��������. � �������� 
		/// �������� ����� ���� ����� ������ ������ - � ���� ������ ��� �����������
		/// ��� ���������� ������� ����������.
		/// ���������� ����������� ������ ���� ������������ � ������� Incident Tracker.
		/// </param>
		/// <returns>
		/// -- True - ���� ��������� ������ ������ � ������� ��������;
		/// -- False - ���� ��������� ������ �� ������
		/// </returns>
		/// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
        [WebMethod(Description = "�������� ������ � ����������� ���������� ������� � ��������� �������������")]
        public bool UpdateProjectDirectionsAndExpenseRatio(
            string sProjectID,
            ProjectDirection[] ProjectDirections)
        {
            // �������� ���������� ��������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "������������� ������� (sProjectID)");
            // ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
            if (null == ProjectDirections)
                ProjectDirections = new ProjectDirection[0];


            // #1:
            // ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
            ObjectOperationHelper helperProject = loadProject(sProjectID, false, new string[] { "FolderDirections" });
            // ... ���� ������ �� ������ - ������ ������ false:
            if (null == helperProject)
                return false;

            // ����� ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections,
            // ��� ��������� ������ � XML ���������� � ������ �������� ����
            helperProject.DropPropertiesXmlExcept("FolderDirections");

            // ����� ���� ���������� ��������� ��������������
            int nTotalPercentage = 0;

            // #2:
            // ����� ������� � ����������� ����������� ��� ������ ����. ���������� 
            // ������� FolderDirection, ������� ����� ������ �������� ���� ������
            // �� �����������. 
            //
            // ��� ������� ��������� ����������� �������� ��������� ������ ������ 
            // FolderDirection; ����� �� ����� ������� ��, ������� � ���������������
            // �������� ����������� - ��������� ����� ��������. ��� ���� � ������� 
            // ������� �� ���� ������� ������ - � ��������� ����� �������� ������ 
            // ������ �������; ��� ������ � ����� �������, ������ ��� ��� ������� 
            // ����� ������� ����������� ���������� (��. ����� #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ProjectDirections.Length + 1];
            for (int nIndex = 0; nIndex < ProjectDirections.Length; nIndex++)
            {
                // ��������� ������������� ��������� �����������
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(ProjectDirections[nIndex].DirectionID, String.Format("������������� ����������� ProjectDirections[{0}].DirectionID", nIndex));

                // ��������� ������� ��������� �����������.
                int nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(ProjectDirections[nIndex].ExpenseRatio, String.Format("������� ������������� ������ �� ����������� ProjectDirections[{0}].Percentage", nIndex));


                // ������ ����� ������������ �����������
                foreach (XmlElement xmlFolderDirection in helperProject.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(ProjectDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperProject.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // ��������� "��������" ������ ���������� ds-������� FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... ����������� ������ �� �����������:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... � ����� ����������� ������ �� ������:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "���� ������" - � ����:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                nTotalPercentage += nPercentage;
            }
            // ���� �������� ���� �� ���� �����������, ����� ���������� ����� ������ ���� ����� 100
            if ((ProjectDirections.Length > 0) && (nTotalPercentage != 100))
                throw new ArgumentException("����� ���������� ����� �� ������������ ������ ���� ����� 100");

            // ... ��������� ������� ������� - ��� ������ (��. ����� #4):
            arrHelpers[ProjectDirections.Length] = helperProject;


            // #3:
            // ���� ��� ������� ���� ���������� �����������, ��, �����., ���������� 
            // ��������� ������� FolderDirection, ����������� ������ � �����������. 
            // 
            // ��� ������ ����� �/� �������� � ������������ ��� ��������� ������� ����
            // �������. �������� �������� ������������ � ������� ���������� ���������� 
            // ������ �������, ��� "�����������" ����������, � ������� ��� FolderDirection
            // ����� �������� ��� ��������� - ��� ��� ����� ����� ������� delete="1".
            // 
            // ������� XML-������ �������� FolderDirection, �������� ��� ���� �� ���� -
            // ����� ��� �������� ����������� ���������� ������ �� ����� ����������
            // ��� ������������ �������� �� ��������� �������� (�� #4). � ����� �������
            // "�����" ��� ������ ������ �� FolderDirections ������, � ����� - �������:

            XmlElement xmlFolderDirections = (XmlElement)helperProject.PropertyXml("FolderDirections").CloneNode(true);
            // ... ������� ������ ������:
            helperProject.ClearArrayProp("FolderDirections");
            // ... ����� - ���������:
            // ���� �� ������� ��������������� ��������, � ������ ��� ����:
            // -- ��� ��������� ��� - ��� ������, ��� ��������� �� ����, ������� 
            //		���� �� ����� ������� ����� ����;
            // -- ��� ������ ��������������� �������� � ������� ��� �� ��������, 
            //		������� ��� ��������� �������������� ���������� NewlySetObjectID
            for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                helperProject.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


            // #4:
            // ������ ����������� ���������� ��� ������. �����: (�) ������ ������ 
            // ��������� �������, (�) ������ ����� FolderDirection-��, (�) ������ 
            // ������, ��������� FolderDirection-��
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
            // ... � ���������� ��� ���� ���������� � ����� ������� - �� ������ 
            // ���������� �� helper-��. ������� ������ ���������:
            foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                // ���������� ������ ���������� FolderDirection ��� �� ����� - ������� (�����)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... ������������� �������� delete="1", ���� ��� �������, 
                // ����������� ��� ��������������� ������ � �� ���� �������
                xmlDeletedFolderDirection.SetAttribute("delete", "1");
            }


            // #5: 
            // ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
            // ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
            // FolderDirection, ��������� ������ �����-�������
            ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

            return true;
        }

		delegate TRes Func<TRes>();
		delegate TRes Func<TParam, TRes>(TParam param);
		delegate TRes Func<TParam1, TParam2, TRes>(TParam1 param1, TParam2 param2);
		/// <summary>
		/// ��������� ����������� ��������� ������� ��� ���������� �������.
		/// </summary>
		/// <param name="sProjectID">
		/// ��������� ������������� �������������� ����������� �������� �������. 
		/// ������� �������� ��-�� ������������. 
		/// </param>
		/// <param name="aTeamParticipants">
		/// ������ �������� ���������� ��������� �������, ��� ����������� ���� 
		/// ProjectTeamParticipant. ����� ���� ����� ������ ������.
		/// </param>
		/// <param name="bReplaceTeam">
		/// ���������� ����� ���������� ������ ��������� �������:
		/// -- True - ��� �������� ��������� ������� ���������� �������� � aTeamParticipants
		/// -- False - ������������ ��������� ������� ����������� ������������ ��
		/// aTeamParticipants, ������� ��� ��� � ��������� �������. ���� ���������
		/// ��� ���� � �������, �� ��� ���� ����������� ����; ����������� (���� � 
		/// aTeamParticipants, �� ��� � ����������� ���������) - �����������.
		/// </param>
		/// <returns>
		/// -- True - ���� ��������� ������ ������ � ������� ��������;
		/// -- False - ���� ��������� ������ �� ������
		/// </returns>
		/// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
		[WebMethod(Description="��������� ����������� ��������� ������� ��� ���������� �������")]
        public bool UpdateActivityTeam(
            string sActivityID,
			ProjectTeamParticipant[] aTeamParticipants,
			bool bReplaceTeam ) 
		{
			// �������� ���������� ��������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityID, "������������� ������� (sProjectID)");
			// ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
			if (null==aTeamParticipants)
				aTeamParticipants = new ProjectTeamParticipant[0];


			// #1:
			// ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
			ObjectOperationHelper helperProject = loadActivity(sActivityID, false, new string[] { "Participants.Roles", "Participants.Employee" });
			// ... ���� ������ �� ������ - ������ ������ false:
			if (null==helperProject)
				return false;

			// ��� ������ �������� ��������� ������� ������ ������ ������ �� ���������� 
			// (��������� �������� Participants �������� ��������, ��� ������ �� ����)
			// ��� ��� ��� ����� ����������� - ��� ������������ �������� ��������� �������,
			// ��� �������. ������� ��� ��� ������ � �������� XML (�����), � �������� 
			// �������, �� ���������, ��������:
			XmlElement xmlParticipants = (XmlElement)helperProject.PropertyXml( "Participants" ).CloneNode( true );
			helperProject.Clear();

			// �����, � ����������� �� ������:
			if ( bReplaceTeam )
			{
				#region ������ "������"

				// #2: 
				// ������� ����� �������� ���������� ��������� �������:
				ObjectOperationHelper[] arrNewParticipants = new ObjectOperationHelper[ aTeamParticipants.Length ];
				// "��������" ������ ��������
				ObjectOperationHelper helperParicipantTemplate = ObjectOperationHelper.GetInstance( "ProjectParticipant" );

				List<XmlElement> changedParticipants = new List<XmlElement>();
                List<XmlElement> participantsToDelete = new List<XmlElement>();
				List<ObjectOperationHelper> newParticipants = new List<ObjectOperationHelper>();

				#region ��������������� �������
				Func<ObjectOperationHelper> GetNewParicipantStub =
					delegate()
					{
						if (!helperParicipantTemplate.IsLoaded)
							helperParicipantTemplate.LoadObject();
						return ObjectOperationHelper.CloneFrom(helperParicipantTemplate, false);
					};

				Func<Guid, ObjectOperationHelper> GetExistingParicipantStub =
					delegate(Guid objectID)
					{
						ObjectOperationHelper helper = ObjectOperationHelper.GetInstance(
							"ProjectParticipant",
							objectID);
						helper.LoadObject();
						helper.DropPropertiesXmlExcept("Roles");
						return helper;
					};

				Func<ProjectTeamParticipant[], Guid, ProjectTeamParticipant> GetNewParticipantByEmployeeID =
					delegate(ProjectTeamParticipant[] participants, Guid objectID)
					{
						foreach (ProjectTeamParticipant participant in participants)
						{
							Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(participant.EmployeeID, "�������������� ����������");
							if (employeeID.Equals(objectID))
								return participant;
						}
						return null;
					};

				Func<XmlElement, Guid, XmlElement> GetExistingParticipantByEmployeeID =
					delegate(XmlElement participants, Guid objectID)
					{
						foreach (XmlNode p in participants.SelectNodes("ProjectParticipant"))
						{
							XmlElement participant = p as XmlElement;
							XmlNode e = participant.SelectSingleNode("Employee/Employee");
							if (e != null)
							{
								XmlElement employee = e as XmlElement;
								Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(employee.GetAttribute("oid"), "�������������� ����������");
								if (employeeID.Equals(objectID))
									return participant;
							}
						}
						return null;
					};

				Func<XmlElement, Guid, bool> ExistingParticipantHasRole =
					delegate(XmlElement participant, Guid objectID)
					{
						foreach (XmlNode r in participant.SelectNodes("Roles/UserRoleInProject"))
						{
							XmlElement role = r as XmlElement;
							Guid roleID = ObjectOperationHelper.ValidateRequiredArgumentAsID(role.GetAttribute("oid"), "������������� ���� ��������� � ���������� ������");
							if (roleID.Equals(objectID))
								return true;
						}
						return false;
					};

				Func<ProjectTeamParticipant, Guid, bool> NewParticipantHasRole =
					delegate(ProjectTeamParticipant participant, Guid objectID)
					{
						foreach (string oid in participant.RoleIDs)
						{
							Guid roleID = ObjectOperationHelper.ValidateRequiredArgumentAsID(oid, "������������� ���� ��������� � ITracker");
							if (roleID.Equals(objectID))
								return true;
						}
						return false;
					};
				#endregion

                //������� ������� ������ ��������� ����������:
                foreach (XmlNode p in xmlParticipants.SelectNodes("ProjectParticipant"))
                {
                    XmlElement participant = p as XmlElement;
                    XmlNode e = participant.SelectSingleNode("Employee/Employee");
                    if (e != null)
                    {
                        XmlElement employee = e as XmlElement;
                        Guid employeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(employee.GetAttribute("oid"), "�������������� ����������");

                        if (GetNewParticipantByEmployeeID(aTeamParticipants, employeeID) == null)
                        {
                            XmlElement xmlParticipant =(XmlElement)participant.CloneNode(true);
                            xmlParticipant.InnerXml = "";
                            xmlParticipant.SetAttribute("delete", "1");
                            participantsToDelete.Add(xmlParticipant);
                        }
                    }
                    else
                    {
                        XmlElement xmlParticipant = (XmlElement)participant.CloneNode(true);
                        xmlParticipant.InnerXml = "";
                        xmlParticipant.SetAttribute("delete", "1");
                        participantsToDelete.Add(xmlParticipant);
                    }
                }

                // ��� ���� ����������
				foreach (ProjectTeamParticipant participant in aTeamParticipants)
				{
					// ��������� ������������� ��������� ����������
					Guid uidEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(participant.EmployeeID, "������������� ����������");
					// ��������, ���� �� �����
					XmlElement existingParticipant 
						= GetExistingParticipantByEmployeeID(xmlParticipants, uidEmployeeID);
					// ���� ���� - �������� ����, ���� ����
					if (existingParticipant != null)
					{
						bool rolesChanged = false;
						XmlElement roles = existingParticipant.SelectSingleNode("Roles") as XmlElement;

						foreach (string roleID in participant.RoleIDs)
						{
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(roleID, "������������� ����");
							
							// ���� ����� ����
							if (!ExistingParticipantHasRole(existingParticipant, objectID))
							{
								rolesChanged = true;
								XmlElement role = roles.OwnerDocument.CreateElement("UserRoleInProject");
								role.SetAttribute("oid", roleID);
								roles.AppendChild(role);
							}
						}

						List<XmlNode> oldRoles = new List<XmlNode>();
						foreach (XmlNode r in roles.SelectNodes("UserRoleInProject"))
						{
							oldRoles.Add(r);
						}

						foreach (XmlNode r in oldRoles)
						{
							XmlElement role = r as XmlElement;
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(role.GetAttribute("oid"), "������������� ���� ��������� � ITracker");
							// ���� ���� ������ ���
							if (!NewParticipantHasRole(participant, objectID))
							{
								rolesChanged = true;
								roles.RemoveChild(role);
							}
						}

						// ���� ���� ����������
						if (rolesChanged)
						{
							List<XmlNode> propsToDrop = new List<XmlNode>();
							foreach (XmlNode p in existingParticipant.SelectNodes("*"))
							{
								if (p.Name != "Roles")
									propsToDrop.Add(p);
							}
							foreach (XmlNode p in propsToDrop)
							{
								existingParticipant.RemoveChild(p);
							}
							changedParticipants.Add(existingParticipant);
						}
					}
					// ���� ���� ������ - ������� ������
					else
					{
						ObjectOperationHelper participantHelper = GetNewParicipantStub();
						participantHelper.SetPropScalarRef("Employee", "Employee", uidEmployeeID);
						participantHelper.SetPropScalarRef("Folder", "Folder", uidProjectID);
						participantHelper.SetPropValue("Privileges", XPropType.vt_i4, 0);
						foreach (string roleID in participant.RoleIDs)
						{
							Guid objectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(roleID, "������������� ����");
							participantHelper.AddArrayPropRef("Roles", "UserRoleInProject", objectID);
						}
						newParticipants.Add(participantHelper);
					}
				}

				// #3:
				// ������ ����������� ���������� ��� ������. �����: (�) ������ 
				// ����� ���������� ��������, (�) ������ ������, ��������� 
				// ���������� ��������:
				// ... ������� � ���������� - ������ �����
				XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(newParticipants.ToArray());
				newParticipants.Clear();
				newParticipants = null;
				// ... ������� ������ ����������:
				foreach (XmlElement participant in changedParticipants)
				{
					xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(participant, true));
				}
				changedParticipants.Clear();
				changedParticipants = null;

                // ... ������� ������ ���������:
                foreach (XmlElement participant in participantsToDelete)
                {
                    xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(participant, true));
                }
                participantsToDelete.Clear();
                participantsToDelete = null;
			
				// #4: 
				// ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
				// ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
				// FolderDirection, ��������� ������ �����-�������
				ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );

				#endregion
			}
			else
			{
				#region ������ "����������"

				// #2:
				// ���� ����������: ���������� �������� �������� ��������� �������
				// � ��������� ������� �������. ��� ���� �������� ��� ��������� 
				// �������� "���������� ��������� �������": (�) �����, ������� 
				// ������, �� �� ������� � �������, (�) ���������� - ������� �����,
				// �� � ������� ��� �����, �������� � �������� �������. 
				// ����� (��. #3) �� ���� ��������� ������� ������ ������, ������
				// ���������� �� ������ "�����������" �����������

				ArrayList arrNewParticipants = new ArrayList();
				ArrayList arrUpdatedParticipants = new ArrayList();

				// "��������" ������ �������� ��������� ��������� �������, ���� �� �����������
				ObjectOperationHelper helperParicipantTemplate = ObjectOperationHelper.GetInstance( "ProjectParticipant" );

				// ���� �� �������:
				for( int nIndex = 0; nIndex < aTeamParticipants.Length; nIndex++ )
				{
					// ��������� ������������� ��������� ����������
					Guid uidEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].EmployeeID, String.Format("������������� ���������� aTeamParticipants[{0}].EmployeeID", nIndex) );
					
					// ������ ����?..
					XmlElement xmlParticipant = (XmlElement)xmlParticipants.SelectSingleNode( 
						String.Format( "ProjectParticipant[Employee/Employee/@oid='{0}']", uidEmployeeID ) );

					// ���; ������� ������ ���������:
					if (null==xmlParticipant)
					{
						// ��������� "��������" ������ ds-������� ProjectParticipant
						if ( !helperParicipantTemplate.IsLoaded )
							helperParicipantTemplate.LoadObject();
						// ... ��� ������� ObjectOperationHelper ��������� �� ����� "��������":
						ObjectOperationHelper helperNewParticipant = ObjectOperationHelper.CloneFrom( helperParicipantTemplate, false );

						// ... ����������� ������ �� ���������:
						helperNewParticipant.SetPropScalarRef( "Employee", "Employee", uidEmployeeID );
						// ... ����� ����������� ������ �� ������:
						helperNewParticipant.SetPropScalarRef( "Folder", "Folder", uidProjectID );
						// ... "�������" ���������� - � ����:
						helperNewParticipant.SetPropValue( "Privileges", XPropType.vt_i4, 0 );
						// ... ������ �� ����:
						for( int nRoleIndex = 0; nRoleIndex < aTeamParticipants[nIndex].RoleIDs.Length; nRoleIndex++ )
						{
							Guid uidRoleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].RoleIDs[nRoleIndex], String.Format("������������� ���������� aTeamParticipants[{0}].RoleIDs[{1}]", nIndex, nRoleIndex ) );
							helperNewParticipant.AddArrayPropRef( "Roles", "UserRoleInProject", uidRoleID );
						}
						
						// ��������� � ��������� �������� ����� ��������� ��������:
						arrNewParticipants.Add( helperNewParticipant );
					}
					else
					{
						// �������� ����; �������� ����: ��� ����� ������ �� �������� ������� 
						// ��������������� �����, � ���� �������� ���� �� ������ ����� ��� 
						// ����������� - �� �������� ������������� � ������ "�������������":
						Guid uidParticipantID = new Guid( xmlParticipant.GetAttribute("oid") ); 
						// ...��� - ������ ��������������� ������������� � ��������� �����
						// (��� ����������� ������� �� ��������� - ��� ���� �� ��� ��������
						// ���� � ���������� ����������):
						Guid[] aAbsentRoles = new Guid[aTeamParticipants[nIndex].RoleIDs.Length];
						// ...��� - ���-�� ������������� ����������� �����:
						int nAbsentRolesQnt = 0;

						for( int nRoleIndex = 0; nRoleIndex < aTeamParticipants[nIndex].RoleIDs.Length; nRoleIndex++ )
						{
							Guid uidRoleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aTeamParticipants[nIndex].RoleIDs[nRoleIndex], String.Format("������������� ���������� aTeamParticipants[{0}].RoleIDs[{1}]", nIndex, nRoleIndex ) );
							XmlElement xmlParticipantRole = (XmlElement)xmlParticipant.SelectSingleNode(
								String.Format( "Roles/UserRoleInProject[@oid='{0}']", uidRoleID ) );
							if (null==xmlParticipantRole)
								aAbsentRoles[ nAbsentRolesQnt++ ] = uidRoleID;
						}
						
						// ����� �������� ����� ����� ����, ��� � ���������� ��� �� ������:
						if (nAbsentRolesQnt > 0)
						{
							// ���������� ������ �������, ������������ ���������, ����� � ������� �� �����:
							ObjectOperationHelper helperUpdatedParticipant = ObjectOperationHelper.GetInstance( "ProjectParticipant", uidParticipantID );
							helperUpdatedParticipant.LoadObject( new string[]{ "Roles" } );
							
							// ���������� ����� ������ ���� - ��� ��������� �������� ����������
							// �.�. ��� ���� � ������� ������ �������� ������ �������� ������ 
							// �� ���� (��� ������������ �����, ��� � �����), �� ������� ������ 
							// � �� ����� ���� - � ��������� ����� XML. 
							helperUpdatedParticipant.DropPropertiesXmlExcept( "Roles" );
							XmlElement xmlExistsRoles = (XmlElement)helperUpdatedParticipant.PropertyXml("Roles").CloneNode(true);
							helperUpdatedParticipant.ClearArrayProp( "Roles" );

							// ��� ����� �������������� ���� - ����������� �������, ������ 
							// ��� ��� ������ (��� ��������� ������ �� ����� ����):
							foreach( XmlNode xmlRole in xmlExistsRoles.SelectNodes("UserRoleInProject") )
								helperUpdatedParticipant.AddArrayPropRef( 
									"Roles", "UserRoleInProject", 
									new Guid( ((XmlElement)xmlRole).GetAttribute("oid") ) );
							
							// ...� ������� � ������ �������������� ��� �����, ��� ����� �� �����:
							for ( int nRoleIndex=0; nRoleIndex < nAbsentRolesQnt; nRoleIndex++ )
								helperUpdatedParticipant.AddArrayPropRef( "Roles", "UserRoleInProject", aAbsentRoles[nRoleIndex] );

							// ����������� �������� ��������� ��������� ������� 
							// ��������� � ��������� "�����������":
							arrUpdatedParticipants.Add( helperUpdatedParticipant );
						}
					}
				}

				// #3:
				// �� (�) ����� �������� ���������� ��������� �������,
				// � (�) ���������� ���������� ��������� ������� (� ��������� 
				// �������� �����) �������� ����� ������, ������� ��������
				// �� "�����������" ������:
				int nHelpersQnt = arrNewParticipants.Count + arrUpdatedParticipants.Count;
				ObjectOperationHelper[] helpers = new ObjectOperationHelper[ nHelpersQnt ];
				arrNewParticipants.CopyTo( helpers );
				arrUpdatedParticipants.CopyTo( helpers, arrNewParticipants.Count );

				// ������ - ���������� ������:
				ObjectOperationHelper.SaveComplexDatagram( helpers );

				#endregion
			}

			return true;
		}

		
		/// <summary>
		/// ������� �������� ���������� ������� �� ������� Incident Tracker
		/// </summary>
		/// <param name="sProjectID">��������� ������������� �������������� �������</param>
		///	<exception cref="ArgumentNullException">���� sProlectID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sProlectID ����� � String.Empty</exception>
		[WebMethod(Description="������� �������� ���������� ������� �� ������� Incident Tracker")]
		public void DeleteProject( string sProjectID ) 
		{
			// ��������� ������������ ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sProjectID, "������������� ���������� ������� (sProjectID)" );
			
			// �������� �������:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder",uidProjectID );
			helperProject.DeleteObject();
		}

        /// <summary>
        /// ������������ ��� ��������� ��������� �����������. ��������� ���������� ��� �� ������ ����  ���������. 
        /// </summary>
        /// <param name="sActivityID">������������� ����������</param>
        /// <param name="nActivitySate">��������� ����������</param>
        /// <param name="sActivityDescription">����������� � ��������</param>
        /// <returns>���������� true � ������ ������, ����� false</returns>
        [WebMethod(Description = "�������� ��������� �����������")]
        public bool UpdateActivityState(string sActivityID, int nActivitySate, string sActivityDescription, string sInitiatorEmployeeID)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
				sActivityID, 
				"������������� ����������� ���������� (sActivityID)"
				);

			if (!string.IsNullOrEmpty(sInitiatorEmployeeID)) ObjectOperationHelper.ValidateOptionalArgument(sInitiatorEmployeeID, "sInitiatorEmployeeID", typeof(Guid));


			ObjectOperationHelper.AppServerFacade.ExecCommand(
				new UpdateActivityStateRequest()
				{
					Activity = uidActivityID,
					Description = sActivityDescription,
					Initiator = !string.IsNullOrEmpty(sInitiatorEmployeeID) ? new Guid(sInitiatorEmployeeID) : Guid.Empty,
					NewState = (FolderStates)nActivitySate
				});

			return true;
        }
        /// <summary>
        /// ����� ���������� ���������� � ��������� ���������� � ����������.
        /// ��������� ���������� � ���� ��������� �����������, ����������� � ����� ��������� ���������, 
        /// ���� ��� ��������� ��������� � ��������� �������� �� ��������� � ����� �� ������ � ��� ��������, 
        /// ����� ��������� ��� ��������� ���������� ���������.
        /// </summary>
        /// <param name="sActivityID">������������� ����������</param>
        /// <returns>���������� � ��������� ���������� � ����������</returns>
        [WebMethod(Description = "���������� ���������� � ��������� ���������� � ����������")]
        public bool GetActivityIncidentStates(string sActivityID)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                           sActivityID, "������������� ����������� ���������� (sActivityID)");
            
            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder", uidActivityID);
            // ������� ��������� ����������, ���� �� ����������, �� ������ Exception
            helperActivity.LoadObject();
            // ��������� ��������� ���������� ��� �������
            XParamsCollection dsParams = new XParamsCollection();
            dsParams.Add("FolderID", uidActivityID);
            object oValue = ObjectOperationHelper.ExecAppDataSourceScalar("CommonService-BP-HasOpenIncidentsInActivity", dsParams);
            if (oValue == null)
                return true;
            return false;
        }
        /// <summary>
        /// ������������ ��� ��������� ��������� ���� ���������� ���������� ����������� � ��������� ����������. 
        /// ��������� ����������� ����������� ����� ����������.
        /// </summary>
        /// <param name="sActivityID">������������� ����������</param>
        /// <param name="nIncidentStatesCategory">��������� ��������� ��� ���������� </param>
        /// <param name="sIncidentSolution">�������� ������� � ����������</param>
        /// <returns>���������� true � ������ ������, ����� false</returns>
        [WebMethod (Description = "��������� ������� ���������� � �������� ����������") ]
        public bool UpdateIncidentStateInActivity(string sActivityID,
                    int nIncidentStatesCategory,
                    string sIncidentSolution)
        {
            Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                            sActivityID, "������������� ����������� ���������� (sActivityID)");
			if (
				!Enum.IsDefined(
					typeof(IncidentStateCat), 
					Convert.ChangeType(nIncidentStatesCategory, Enum.GetUnderlyingType(typeof(IncidentStateCat)))
					)
				) throw new ArgumentOutOfRangeException("nIncidentStatesCategory");

            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder", uidActivityID);
            // ������� ��������� ����������, ���� �� ����������, �� �������� Exception
			if (!helperActivity.SafeLoadObject(null, null))
				return false;

            XParamsCollection dsParams = new XParamsCollection();
            dsParams.Add("FolderID", uidActivityID);
            dsParams.Add("NewCat", nIncidentStatesCategory);
            // �������� ������ ����������� ���������� � �� ����� ��������, ����������� �� ��������� ���-��
            DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("CommonService-BP-GetList-OpenIncidents", dsParams);
			foreach (DataRow row in oDataTable.Rows)
			{
				if (
						(DBNull.Value == row["NewState"])
                        || (Guid)row["NewState"] == Guid.Empty)
					throw new ApplicationException("�� ������� �������� ����� ��������� ��� ���������");
			}
            for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
            {
                Guid uidIncidentID = (Guid)oDataTable.Rows[nRowIndex]["Incident"];
                Guid uidNewState = (Guid)oDataTable.Rows[nRowIndex]["NewState"];
				ObjectOperationHelper helperIncident = ObjectOperationHelper.GetInstance("Incident", uidIncidentID);
				// ��������� ��������
				if (helperIncident.SafeLoadObject(null, null))
				{
					// ���� ����� �������� sIncidentSolution ����� ��������� ��-�� Solution
					if (!String.IsNullOrEmpty(sIncidentSolution))
					{
						helperIncident.UploadBinaryProp("Solution");
						string sNewSolution = String.Empty;
						// ����� ������� ���� �������� ������� � ��� �������������
						sNewSolution = helperIncident.PropertyXml("Solution") + Environment.NewLine + sIncidentSolution;
						// ������� �������� "Solution" � ������� ���������
						helperIncident.SetPropValue("Solution", XPropType.vt_text, sNewSolution);
					}
					// ��������� ��������� ���������
					helperIncident.SetPropScalarRef("State", "IncidentSate", uidNewState);
					// ��������� ������ �� ��������, ������� ����� ��������
					helperIncident.DropPropertiesXmlExcept(new string[] { "Solution", "State" });
					// ���������
					helperIncident.SaveObject();
				}
            }
            return true;
        }

		#endregion
		
		#region ������, ������������ ��� ������������� ������ ������������ (���������)

		/// <summary>
		/// ���������� ��������� ����� �������� ������ ����� (Folder) ���� 
		/// "�������" (�����������), �� ��������� ��������������. 
		/// ��������� ������������ ������� ��������������, � ��� �� ��� �����.
		/// </summary>
		/// <param name="sPresaleID">������������� �����-��������, � ������</param>
		/// <param name="arrPreloadProperties">
		/// ������ ������������ ������������ ����������, �.�. null
		/// </param>
		/// <param name="bIsStrictLoad">
		/// ������� "�������" �������� - ���� ��������� ������ �� ����� ������, �����
		/// ������������� ����������; ���� �������� ����� � false, � ������ �� ����� 
		/// ������, �� � ���. ���������� ����� ������ null;
		/// </param>
		/// <returns>
		/// ������������������ ������ - helper ��� null ���� ������ �� ������, 
		/// � ������� "�������" �������� (bIsStrictLoad) �������
		/// </returns>
		/// <exception cref="ArgumentNullException">���� sPresaleID ���� null</exception>
		/// <exception cref="ArgumentException">���� sPresaleID ���� ������ ������</exception>
		/// <exception cref="ArgumentException">���� ������� � ID sPresaleID ��� � bIsStrictLoad=true</exception>
		/// <exception cref="ArgumentException">���� sPresaleID ������ ����� - �� �������</exception>
		private ObjectOperationHelper loadPresale( string sPresaleID, bool bIsStrictLoad, string[] arrPreloadProperties ) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sPresaleID, "������������� ����������� (sPresaleID)" );
			
			// ��������� ������: � ����� ������ ����������� "������" ��������
			// ��� ���� ���������, ����������� ��� ���: ���������� ������� ������� 
			// �� �������� ����� bIsStrictLoad:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			if ( !helper.SafeLoadObject( null, arrPreloadProperties ) )
			{
				if (bIsStrictLoad)
					throw new ArgumentException( "����������� � ��������� ��������������� (" + sPresaleID + ") �� �������", "sPresaleID" );
				else
					return null;
			}

			// ���������, ��� ����������� ��������, �������������� �������� ���� 
			// "Folder" ���� ����������� - �������� �������� "����" �����:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				throw new ArgumentException( "�������� ������������� (sProjectID) �� �������� ��������������� �����������" );
			
			return helper;			
		}

		
		/// <summary>
		/// ����� �������������� �������� ��������� ����� � ��������������� 
		/// ��������� ������� �� ������� �����������
		/// </summary>
		/// <param name="enFolderState">��������� �����</param>
		/// <returns>��������������� ��������� �������</returns>
		private PresaleStates getFolder2PresaleState( FolderStates enFolderState ) 
		{
			PresaleStates enPresaleStates;
			switch (enFolderState)
			{
				case FolderStates.Open: enPresaleStates = PresaleStates.Open; break;
				case FolderStates.WaitingToClose: enPresaleStates = PresaleStates.WaitingToClose; break;
				case FolderStates.Closed: enPresaleStates = PresaleStates.Closed; break;
				case FolderStates.Frozen: enPresaleStates = PresaleStates.Frozen; break;
				default:
					throw new ArgumentException( "����������� ��������� ����� (enFolderState)","enFolderState" );
			}
			return enPresaleStates;
		}
		

		/// <summary>
		/// ����� �������������� �������� ��������� ������� �� ������� �����������
		/// � ��������������� ��������� ����� 
		/// </summary>
		/// <param name="enPresaleState">��������� �������</param>
		/// <returns>��������������� ��������� �����</returns>
		private FolderStates getPresale2FolderState( PresaleStates enPresaleState ) 
		{
			FolderStates enFolderStates;
			switch (enPresaleState)
			{
				case PresaleStates.Open: enFolderStates = FolderStates.Open; break;
				case PresaleStates.WaitingToClose: enFolderStates = FolderStates.WaitingToClose; break;
				case PresaleStates.Closed: enFolderStates = FolderStates.Closed; break;
				case PresaleStates.Frozen: enFolderStates = FolderStates.Frozen; break;
				default:
					throw new ArgumentException( "����������� ��������� ������� �� ������� ����������� (enPresaleState)","enPresaleState" );
			}
			return enFolderStates;
			
		}
		
		
		/// <summary>
		/// ���������� ����� �������� ������ �� ������������ �������-���������
		/// � ������ ���� PresaleInfo
		/// </summary>
		/// <param name="helper">������ ���������, ������ ������������ ������ ���� Folder � �.�. ��������</param>
		/// <returns>������ ProjectInfo � ��������� ������ �������</returns>
		private PresaleInfo getPresaleInfoFromHelper( ObjectOperationHelper helper ) 
		{
			// �������� ������������ ���������� ������ + ��������������� ����������� 
			// ��������� �������������: (1) ��������, ��� ��� heler-������ ����� 
			// � ������������ ������ ������� ���� "�����" (Folder):
			if (null==helper)
				throw new ArgumentNullException( "helper", "������� � PresaleInfo ����������: ��������������� ������-��������� �� �����" );
			if ("Folder"!=helper.TypeName)
				throw new ArgumentException( "������� � PresaleInfo ����������: ��������������� ������-��������� ������������ ������ ����, ��������� �� Folder (" + helper.TypeName + ")", "helper" );
			// (2) ��������, ��� ��� - �����������:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				throw new ApplicationException( String.Format(
					"������������ ������: ��������� ������ � ��������������� {0} �� �������� ������������ (��� ����� - {1})",
					helper.ObjectID.ToString(), 
					((FolderTypeEnum)helper.GetPropValue("Type",XPropType.vt_i2)).ToString() ) );

			
			ObjectOperationHelper helperOrg = helper.GetInstanceFromPropScalarRef( "Customer", false );
			if (null==helperOrg)
				throw new ApplicationException( String.Format(
					"������������ ������: ��� ��������� ����������� � ��������������� {0} " +
					"�� ������ ����������� �������, � �������� ��������� ������ �����������",
					helper.ObjectID.ToString() ) );
	
			
			PresaleInfo info = new PresaleInfo();
			// ��������� �������� ������ - ��������� �����. ���������� �������:
			info.ObjectID = helper.ObjectID.ToString(); 
			info.CustomerID = helperOrg.ObjectID.ToString();
			info.Name = helper.GetPropValue( "Name", XPropType.vt_string ).ToString();
			//info.Code = safeReadData( helper, "ProjectCode" ).ToString();
			info.NavisionID = safeReadData( helper, "ExternalID" );
			// ������ �������
			info.State = getFolder2PresaleState( (FolderStates)helper.GetPropValue( "State", XPropType.vt_i2) );
			// �������� �������������� ������������ ������� - ���� ������� �����, ����� - null;
			/*
			ObjectOperationHelper helperTargetProject = helper.GetInstanceFromPropScalarRef( ???, false );
			info.TargetProjectID = (null==helperTargetProject ? null : helperTargetProject.ObjectID.ToString());
			*/
			info.TargetProjectID = null;
			
			// ��������� ������: ���� ��� ������� ��� ��� Navision ���� ������ ������, �� ������ �� null:
			if (String.Empty == info.Code)
				info.Code = null;
			if (String.Empty == info.NavisionID)
				info.NavisionID = null;
			
			return info;
		}
		
		
		/// <summary>
		/// ���������� ������ ���� ������������ (presales), �������������� 
		/// � ������� Incident Tracker, ��� ������ ����������� ������ 
		/// Croc.IncidentTracker.Services.PresaleInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.PresaleInfo"/>  
		/// </summary>
		[ WebMethod( Description = "���������� ������ ���� ������������ (presale), �������������� � ������� Incident Tracker" ) ]
		public PresaleInfo[] GetPresalesInfo() 
		{
			// ������� ������ ���� ��������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-Presales", null );

			if ( null == oDataTable )
				return new PresaleInfo[0];

			PresaleInfo[] arrPresalesInfo = new PresaleInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// ��������, ��� ������������� ����� ���� "�����������"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if ( FolderTypeEnum.Presale != enType )
					continue;
				
				PresaleInfo info = new PresaleInfo();

				// ��������� ������ ������������ �����
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				info.CustomerID = oDataTable.Rows[nRowIndex]["CustomerID"].ToString();
				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();
				
				// ��� ������� � ��� � Navision � ����� ������ ����� ���� � �� ������;
				// ����� ����, ������ ������� �������� ��� ������ ������ ������ ��������
				// �� ������ �������� null - ������� ������ ������ ������ ������ ������
				// � null-�:
				if ( String.Empty == info.Code )
					info.Code = null;
				
				if ( DBNull.Value==oDataTable.Rows[nRowIndex]["NavisionID"] )
					info.NavisionID = null;
				else
					info.NavisionID = oDataTable.Rows[nRowIndex]["NavisionID"].ToString();
				if ( String.Empty == info.NavisionID )
					info.NavisionID = null;
				
				// ��������� �������: ����� ��������� ��������� - �������� �� IT 
				// ����� ��������� � �������� ��� ���:
				info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// ������ �� ����������� ������ ����� ���� � �� ������:
				/*
				if ( DBNull.Value == oDataTable.Rows[nRowIndex]["MasterProjectID"] )
					info.TargetProjectID = null;
				else
					info.TargetProjectID = oDataTable.Rows[nRowIndex]["MasterProjectID"].ToString();
				*/
				info.TargetProjectID = null;

				// �������� ������ � ������
				arrPresalesInfo[nRowIndex] = info;
			}
			return arrPresalesInfo;
		}
	
		
		/// <summary>
		/// ���������� ������ ����������� (presale), �������������� � ������� 
		/// Incident Tracker, �� � ����������� ��������������.
		/// </summary>
		/// <param name="sPresaleID">
		/// ������ � ��������������� �����������, ��� ������� ��������� ��������� 
		/// ������. ���� ��������� ����������� � ������� �� �������, ����� ����������
		/// null (��. �������� �����������)
		/// </param>
		/// <returns>
		/// -- ��������� PresaleInfo � ��������� �����������, ���� ��������� 
		///		����������� ������������ � �������;
		///	-- null, ���� �������� ��������� ����������� � ������� �� �������
		/// </returns>
		[ WebMethod( Description = "���������� ������ �����������, �������������� � ������� Incident Tracker, �� � ��������������" ) ]
		public PresaleInfo GetPresaleInfoByID( string sPresaleID ) 
		{
			// �������� ����������� ���������, � ��� ������������� �����������:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "������������� ����������� (sPresaleID)" );

			// ������� ��������� ������ ���������� ������� ���� "�����" (Folder)
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder", uidPresaleID );

			// ������ �� ������ - � ������������ �� ������������� ���������� null:
			if ( !helper.SafeLoadObject(null) )
				return null;
			else
				return getPresaleInfoFromHelper(helper);
		}
		
		
	
		/// <summary>
		/// ���������� ��������� ������ ��������� ����������� (presale). 
		/// ������ ������������ � ���� ���������� ������ PresaleAdditionalInfo 
		/// <seealso cref="Croc.IncidentTracker.Services.PresaleAdditionalInfo"/>
		/// </summary>
		/// <param name="sPresaleID">
		/// ������ (System.String) � ��������������� �����������, ��� �������
		/// ��������� ��������� ������. ������� �������� �������� ������������.
		/// </param>
		/// <returns>
		/// ������ �����������, ��� ��������� ������ PresaleAdditionalInfo
		/// </returns>
		///	<exception cref="ArgumentNullException">���� sPresaleID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sPresaleID ����� � String.Empty</exception>
		///	<exception cref="ArgumentException">���� ����������� � ��������������� sPresaleID ���</exception>
		[ WebMethod( Description = "���������� ��������� (�����������) ������ �����������, �������� ���������������" ) ]
		public PresaleAdditionalInfo GetPresaleAdditionalInfo( string sPresaleID ) 
		{
			// �������� ���������� ��������:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "������������� ����������� (sPresaleID)" );

			// ������� ������� ������ ��������� �����������:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "PresaleID", uidPresaleID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetPresaleAdditionalInfo", paramsCollection );

			if (null != oDataTable && 0 == oDataTable.Rows.Count)
				oDataTable = null;
			if (null == oDataTable)
				throw new ArgumentException( "��������� ����������� �� �������", "������������� ����������� (sPresaleID)" );

			// ��������, ��� ������������� ����� ���� "�����������" (�������)
			FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[0]["Type"];
			if ( FolderTypeEnum.Presale != enType )
				throw new ArgumentException( "��������� ����������� �� �������", "������������� ����������� (sPresaleID)" );

			// ������� ������ ��������, � �������������� � ���� ������:
			PresaleAdditionalInfo info = new PresaleAdditionalInfo();

			info.ObjectID = sPresaleID; 
			info.CustomerID = oDataTable.Rows[0]["CustomerID"].ToString();
			info.Name = oDataTable.Rows[0]["Name"].ToString();
			info.Comments = oDataTable.Rows[0]["Comments"].ToString();
			
			// ��� ������� � ��� � Navision � ����� ������ ����� ���� � �� ������;
			// ����� ����, ������ ������� �������� ��� ������ ������ ������ ��������
			// �� ������ �������� null - ������� ������ ������ ������ ������ ������
			// � null-�:
			if ( DBNull.Value==oDataTable.Rows[0]["NavisionID"] )
				info.NavisionID = null;
			else
				info.NavisionID = oDataTable.Rows[0]["NavisionID"].ToString();
			if ( String.Empty == info.NavisionID )
				info.NavisionID = null;

			// ������ �������
			info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[0]["State"] );

			// ������ �� ����������� ������ - ����� ���� � �� ������:
			if ( DBNull.Value == oDataTable.Rows[0]["TargetProjectID"] )
				info.TargetProjectID = null;
			else
				info.TargetProjectID = oDataTable.Rows[0]["MasterProjectID"].ToString();
			
			// ������ �� ���������� - ���������� �������� �������
			if ( DBNull.Value == oDataTable.Rows[0]["InitiatorEmployeeID"] )
				info.InitiatorEmployeeID = null;
			else
				info.InitiatorEmployeeID = oDataTable.Rows[0]["InitiatorEmployeeID"].ToString();
			
			// ���� �������� ����������� - �.�. null, ���� ����������� �� ������ ������ �� �������:
			if ( DBNull.Value == oDataTable.Rows[0]["EndDate"] )
				info.EndDate = DateTime.MinValue;
			else
				info.EndDate = (DateTime)oDataTable.Rows[0]["EndDate"];

			// ������ �� ����������, ���������� ����������� (���� ��� �������, �������)
			if ( PresaleStates.Closed == info.State && DBNull.Value != oDataTable.Rows[0]["EnderEmployeeID"] )
				info.EnderEmployeeID = oDataTable.Rows[0]["EnderEmployeeID"].ToString();
			else
				info.EnderEmployeeID = null;

			return info;
		}
		
		
		/// <summary>
		/// ���������� ������ � ������������, ������������ � ��������� ������������.
		/// ������ � ������������ ������������ ��� ������ ��������������� �������� 
		/// ����������� � ������� Incident Tracker.
		/// </summary>
		/// <param name="sPresaleID">
		/// ������ (System.String) � ��������������� �����������, ��� �������
		/// ��������� ��������� ������. ������� �������� �������� ������������.
		/// </param>
		/// <returns>
		/// ������ ��������������� �������� �����������, �������� ��� ���������
		/// �����������. ���� ��� ����������� ����������� �� ������, �� � �������� 
		/// ���������� ������������ ������ ������� �����.
		/// </returns>
		///	<exception cref="ArgumentNullException">���� sPresaleID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sPresaleID ����� � String.Empty</exception>
		///	<exception cref="ArgumentException">���� ����������� � ��������������� sPresaleID ���</exception>
		[ WebMethod( Description = "���������� ������ � ������������, ������������ � ��������� ������������" ) ]
		public string[] GetPresaleDirectionsInfo( string sPresaleID ) 
		{
			// �������� ���������� ��������:
			Guid uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "������������� ����������� (sPresaleID)" );

			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "PresaleID", uidPresaleID );
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "SyncNSI-GetList-PresaleDirections", paramsCollection );

			// ���� ������ �� ������ ������ ������, ������ ��������� ����������� 
			// � ������� �� �������; � ���� ������ ���������� ����������:
			if (null == oDataTable || 0 == oDataTable.Columns.Count)
				throw new ArgumentException( "��������� ����������� �� �������", "������������� ����������� (sPresaleID)" );
			
			// ���� ���������� ����� � �������������� ���������� - �������, 
			// �� � �����. �� �������������, ���������� ������ ������ �����:
			if (null != oDataTable && 0 == oDataTable.Rows.Count)
				return new string[0];

			// ��������� �������� ������ � ���������������� �����������:
			string[] arrProjectDirectionIDs = new string[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
				arrProjectDirectionIDs[nRowIndex] = oDataTable.Rows[nRowIndex]["DirectionID"].ToString();
			return  arrProjectDirectionIDs;
		}
		
		
		/// <summary>
		/// ������� � ������� Incident Tracker �������� ����������� (presale) 
		/// � ��������� �����������.
		/// </summary>
		/// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
		/// <param name="sCode">������ � ���������� ����� �����������</param>
		/// <param name="sName">������ � ������������� �����������</param>
		/// <param name="sNavisionID">������ � ����� ����������� � Navision</param>
		/// <param name="enInitialState">��������� ��������� ������� �����������</param>
		/// <param name="sProjectID">������ � ��������������� �������, ������������ � ���-�� �����������</param>
		/// <param name="sDescription">������ � ������� �������� / �����������</param>
		/// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� ��������</param>
		/// <returns>������ � ��������������� ���������� �������� �����������</returns>
		[ WebMethod( Description = "������� � ������� Incident Tracker �������� ����������� (presale) � ��������� �����������" ) ]
		public string CreatePresale(
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			PresaleStates enInitialState,
			string sProjectID,
			string sDescription,
			string sInitiatorEmployeeID ) 
		{
			// ��������� ������������ ������� ����������:
			ObjectOperationHelper.ValidateRequiredArgument( sCustomerID, "������������� ����������� - ������� (sCustomerID)", typeof(Guid) );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "���������� ��� ����������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "������������ ����������� (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sProjectID, "������������� ������������ ������� (sProjectID)", typeof(Guid) );
			ObjectOperationHelper.ValidateRequiredArgument( sInitiatorEmployeeID, "������������� ����������-���������� �������� ����������� (sInitiatorEmployeeID)", typeof(Guid) );

			// ���������� ������������� ����� ����������� � �������� ����. 
			// �����, ��������� ����������� � ���� �������� ���������������:
			string sNewProjectID = Guid.NewGuid().ToString();
			CreateIdentifiedPresale( sNewProjectID, sCustomerID, sCode, sName, sNavisionID, enInitialState, sProjectID, sDescription, sInitiatorEmployeeID );
			
			return sNewProjectID;
		}
		
		
		/// <summary>
		/// ������� � ������� Incident Tracker �������� ����������� (presale) 
		/// � ���������� ����������� � �������� ���������� ���������������.
		/// </summary>
		/// <param name="sNewPresaleID">������ � ��������������� ��� ����������� �����������</param>
		/// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
		/// <param name="sCode">������ � ����� �������</param>
		/// <param name="sName">������ � ������������� �������</param>
		/// <param name="sNavisionID">������ � ����� ������� � ����. Navision</param>
		/// <param name="enInitialState">��������� ��������� ����������� �����������</param>
		/// <param name="sProjectID">������ � ��������������� ���������� "������������" �������</param>
		/// <param name="sDescription">����� �������� (�����������) �����������</param>
		/// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� �������</param>
		[ WebMethod( Description = "������� � ������� Incident Tracker �������� ����������� � ��������� ����������� � ������� ��������� ���������� ���������������" ) ]
		public void CreateIdentifiedPresale( 
			string sNewPresaleID,
			string sCustomerID,
			string sCode,
			string sName,
			string sNavisionID,
			PresaleStates enInitialState,
			string sProjectID,
			string sDescription,
			string sInitiatorEmployeeID ) 
		{
			// ��������� ������������ ������� ����������:
			Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewPresaleID, "���������� ������������� ����������� ����������� (sNewPresaleID)" );
			//ObjectOperationHelper.ValidateRequiredArgument( sCode, "���������� ��� ����������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sName, "������������ ����������� (sName)" );
			ObjectOperationHelper.ValidateOptionalArgument( sProjectID, "������������� ������������ ������� (sProjectID)", typeof(Guid) );
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sCustomerID, "������������� ����������� - ������� (sCustomerID)" );
			Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sInitiatorEmployeeID, "������������� ���������� - ���������� �������� ����������� (sInitiatorEmployeeID)" );

			// ��������� ��������: 
			// ������-�������: �������� ������������ ��� ����-�� ��� ������ ������� 
			// ���������. �������������: ���������, ��� �������� ����������� �� ���� 
			// ����; ������������� ���������� �.�. ����� � ���������� ���������������� 
			// ����� �������� (�, �����. ����������� � ������� - ��������� ������������,
			// ServiceConfig)
			if ( uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID )
				throw new ArgumentException( 
					String.Format(
						"�������� ������������ ��� ����������� - ��������� ������� \"{0}\" ��� ������ ������ ������� " +
						"���������. �������� ����� ������������ ������ ����������� ��������������� � ������� Incident " +
						"Tracker, ������������� �������, ���������� ������������ ������������.",
						ServiceConfig.Instance.OwnOrganization.GetPropValue( "ShortName", XPropType.vt_string )
					), "sCustomerID" );

			// �������� ������ ������� - �����������: ���������, � ����� �������� 
			// �������� ������������ ������������� ������� �� ��������:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder" );
			helperProject.LoadObject();
			helperProject.NewlySetObjectID = uidNewProjectID;
			
			// ������ �������� �����������, � �����. � ��������� ���������� ����������:
			// ... ����������� - ��� ����� � ����� "�������":
			helperProject.SetPropValue( "Type", XPropType.vt_i2, FolderTypeEnum.Presale );
			// ... � ������ (��� �������� ������� ����� ������) - ��������� ��� ��������� 
			// ������ ��� "��������"; ������������� �����. Activity Type ����� �� ������������:
			helperProject.SetPropScalarRef( 
				"ActivityType", 
				ServiceConfig.Instance.PresaleProjectsActivityType.TypeName, 
				ServiceConfig.Instance.PresaleProjectsActivityType.ObjectID );

			// ... ������ ��� �������, ��������� �����������:
			//helperProject.SetPropValue( "ProjectCode", XPropType.vt_string, sCode );
			helperProject.SetPropValue( "Name", XPropType.vt_string, sName );
			// ... ������������� ������� � Navision ��� �������� �� �������� ������������;
			// � ���. �������� ����� ���� ����� null ��� ������ ������ - ������ ��� 
			// � ������ ������ - ��� ������ � �� ����� NULL:
			helperProject.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNavisionID? String.Empty : sNavisionID) );
			// ... ������ ������� ��� �������� ��������� ����: 
			helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getPresale2FolderState(enInitialState));

			// ����������� ������:
			// ...�� ���������� - ���������� ������� 
			helperProject.SetPropScalarRef( "Initiator", "Employee", uidInitEmployeeID );
			// ...�� �����������:
			helperProject.SetPropScalarRef( "Customer", "Organization", uidOrganizationID );
			
			// ���������� ����� ������:
			helperProject.SaveObject();
		}
		
		
		/// <summary>
		/// ��������� ���������� �������� ��������� ����������� (presale) � ������� Incident Tracker.
		/// </summary>
		/// <param name="sPresaleID">��������� ������������� �������������� �������� ���������� ����������</param>
		/// <param name="sNewCustomerID">��������� ������������� �������������� ����������� - �������</param>
		/// <param name="sNewCode">������ � ����� ����� �����������</param>
		/// <param name="sNewName">������ � ����� ������������� �����������</param>
		/// <param name="sNewNavisionID">������ � ����� ����� ����������� � Navision</param>
		/// <returns>
		/// -- True - ���� ��������� ����������� ������� � ������� ���������;
		/// -- False - ���� ��������� ����������� �� �������.
		/// </returns>
		/// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
		[ WebMethod( Description = "��������� ���������� �������� ��������� ����������� � ������� Incident Tracker" ) ]
		public bool UpdatePresale( 
			string sPresaleID,
			string sNewCustomerID, 
			string sNewCode,
			string sNewName,
			string sNewNavisionID ) 
		{
			// ��������� ��������
			//ObjectOperationHelper.ValidateRequiredArgument( sNewCode, "���������� ��� ����������� (sCode)" );
			ObjectOperationHelper.ValidateRequiredArgument( sNewName, "������������ ����������� (sName)" );
			Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sNewCustomerID, "������������� ����������� - ������� (sCustomerID)" );

			// ��������� ��������� �����������: ���������� ����� ��������� ������������ ���������
			ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, null );
			// ... ���� ������ �� ������ - ������ ������ false:
			if (null==helperPresale)
				return false;

			// �������� �������� ������ �����������:
			//helperPresale.SetPropValue( "ProjectCode", XPropType.vt_string, sNewCode );
			helperPresale.SetPropValue( "Name", XPropType.vt_string, sNewName );
			// ������������� ������� � Navision ��� �������� �� �������� ������������;
			// ������� � ���. ���������� �������� ��������� ����������� � null, � ������
			// ������; null �������� � ������ ������ - ��� ������ � �� ����� NULL:
			helperPresale.SetPropValue( "ExternalID", XPropType.vt_string, (null==sNewNavisionID? String.Empty : sNewNavisionID) );
			
			// ������������ ����������� �������: ��������, ����� ����������� ������� ������:
			ObjectOperationHelper helperOrg = helperPresale.GetInstanceFromPropScalarRef( "Customer" );
			// ...�������� �������� ������ ���� ��� ������������� ����������:
			if (helperOrg.ObjectID!=uidNewCustomerOrgID)
				helperPresale.SetPropScalarRef( "Customer", "Organization", uidNewCustomerOrgID );

			// ������� � ���������� ��� ��������, ������� ����� �� ����������:
            helperPresale.DropPropertiesXml(new string[] { "ActivityType", "Type", "State", "IsLocked", "Parent" });
			// ���������� ���������� ������:
			helperPresale.SaveObject();

			return true;
		}
		

		/// <summary>
		/// �������� ������ � ����������� ��������� ����������� � ��������� �������������.
		/// </summary>
		/// <param name="sPresaleID">
		/// ��������� ������������� �������������� ����������� �������� �������. 
		/// ������� �������� ��-�� ������������. 
		/// </param>
		/// <param name="aDirectionsIDs">
		/// ������ ����� � ���������������� �����������, ����������� � ������������. 
		/// ��� ����� �������� ����������� ����� ��������. � �������� �������� ����� 
		/// ���� ����� ������ ������ - � ���� ������ ��� ����������� ��� ���������
		/// ����������� ����������.
		/// ���������� ����������� ������ ���� ������������ � ������� Incident Tracker.
		/// </param>
		/// <returns>
		/// -- True - ���� �������� ����������� ������� � ������� ��������;
		/// -- False - ���� �������� ����������� �� �������.
		/// </returns>
		/// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
		[ WebMethod( Description = "�������� ������ � ����������� ��������� ����������� � ��������� �������������" ) ]
		public bool UpdatePresaleDirections( string sPresaleID, string[] aDirectionsIDs ) 
		{
			// �������� ���������� ��������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "������������� ����������� (sPresaleID)" );
			// ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
			if (null==aDirectionsIDs)
				aDirectionsIDs = new string[0];


			// #1:
			// ��������� ��������� �����������: ���������� ����� ��������� ������������ ���������
			ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, new string[]{ "FolderDirections" }  );
			// ... ���� ������ �� ������ - ������ ������ false:
			if (null==helperPresale)
				return false;
			// ����� ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections,
			// ��� ��������� ������ � XML ���������� � ������ �������� ����
			helperPresale.DropPropertiesXmlExcept( "FolderDirections" );


			// #2:
			// ����� ����������� � ����������� ����������� ��� ������ ����. ���������� 
			// ������� FolderDirection, ������� ����� ������ �������� ���� ������
			// �� �����������. 
			//
			// ��� ������� ��������� ����������� �������� ��������� ������ ������ 
			// FolderDirection; ����� �� ����� ������� ��, ������� � ���������������
			// �������� ����������� - ��������� ����� ��������. ��� ���� � ������� 
			// ������� �� ���� ������� ������ - � ��������� ����� �������� ������ 
			// ����� �����������; ��� ������ � ����� ������� - ������ ��� ��� ������� 
			// ����������� ���������� (��. ����� #4)
			ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ aDirectionsIDs.Length + 1 ];
			for( int nIndex = 0; nIndex < aDirectionsIDs.Length; nIndex++ )
			{
				// ��������� ������������� ��������� �����������
				Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID( aDirectionsIDs[nIndex], String.Format("������������� ����������� aDirectionsIDs[{0}]",nIndex) );

				// ������ ����� ������������ �����������
				foreach( XmlElement xmlFolderDirection in helperPresale.PropertyXml( "FolderDirections" ).ChildNodes )
				{
					if( ( (XmlElement)xmlFolderDirection.SelectSingleNode( "Direction/Direction" ) ).GetAttribute("oid").Equals(aDirectionsIDs[nIndex], StringComparison.InvariantCultureIgnoreCase) )
					{
						arrHelpers[nIndex] = ObjectOperationHelper.GetInstance( "FolderDirection", new Guid( xmlFolderDirection.GetAttribute("oid") ) );
						helperPresale.PropertyXml( "FolderDirections" ).RemoveChild( xmlFolderDirection );
						break;
					}
				}
				if( arrHelpers[nIndex] == null )
				{
					// ��������� "��������" ������ ���������� ds-������� FolderDirection
					arrHelpers[nIndex] = ObjectOperationHelper.GetInstance( "FolderDirection" );	
				}
				arrHelpers[nIndex].LoadObject();
				// ... ����������� ������ �� �����������:
				arrHelpers[nIndex].SetPropScalarRef( "Direction", "Direction", uidDirectionID );
				// ... � ����� ����������� ������ �� �����������:
				arrHelpers[nIndex].SetPropScalarRef( "Folder", "Folder", uidProjectID );
				// ... "���� ������" - 100 ���� ����������� ����, ��� 0 ���� ����������� ���������:
                if (aDirectionsIDs.Length == 1)
                {
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 100);
                }
                else
                {
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, 0);
                }
			}
			// ... ��������� ������� ������� - ���� ����������� (��. ����� #4):
			arrHelpers[aDirectionsIDs.Length] = helperPresale;


			// #3:
			// ���� ��� ����������� ���� ���������� �����������, ��, �����., ���������� 
			// ��������� ������� FolderDirection, ����������� ������ � �����������. 
			// 
			// ��� ������ ����� �/� ������������ � ������������ ��� ��������� ������� ����
			// �������. �������� �������� ������������ � ������� ���������� ���������� �����
			// �����������, ��� "�����������" ����������, � ������� ��� FolderDirection
			// ����� �������� ��� ��������� - ��� ��� ����� ����� ������� delete="1".
			// 
			// ������� XML-������ �������� FolderDirection, �������� ��� ���� �� ���� -
			// ����� ��� �������� ����������� ���������� ������ �� ����� ����������
			// ��� ������������ �������� �� ��������� �������� (�� #4). � ����� �������
			// "�����" ��� ������ ������ �� FolderDirections ������, � ����� - �������:

			XmlElement xmlFolderDirections = (XmlElement)helperPresale.PropertyXml( "FolderDirections" ).CloneNode( true );
			// ... ������� ������ ������:
			helperPresale.ClearArrayProp( "FolderDirections" );
			// ... ����� - ���������:
			// ���� �� ������� ��������������� ��������, � ������ ��� ����:
			// -- ��� ��������� ������� - ���� �����������, � ��������� �� ����, 
			//		������� ���� �� ����� ������� ����� ����;
			// -- ��� ������ ��������������� �������� � ������� ��� �� ��������, 
			//		������� ��� ��������� �������������� ���������� NewlySetObjectID
			for( int nIndex=0; nIndex<arrHelpers.Length-1; nIndex++ )
				helperPresale.AddArrayPropRef( "FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID );

						
			// #4:
			// ������ ����������� ���������� ��� ������. �����: (�) ������ �����
			// �������� �����������, (�) ������ ����� FolderDirection-��, (�) ������ 
			// ������, ��������� FolderDirection-��
			XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm( arrHelpers );
			// ... � ���������� ��� ���� ���������� � ����� ������� - �� ������ 
			// ���������� �� helper-��. ������� ������ ���������:
			foreach( XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection") )
			{
				XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild( xmlDatagrammRoot.OwnerDocument.ImportNode( xmlFolderDirection, true) );
				// ���������� ������ ���������� FolderDirection ��� �� ����� - ������� (�����)
				xmlDeletedFolderDirection.InnerXml = "";
				// ... ������������� �������� delete="1", ���� ��� �������, 
				// ����������� ��� ��������������� ������ � �� ���� �������
				xmlDeletedFolderDirection.SetAttribute( "delete", "1" );
			}

			
			// #5: 
			// ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
			// ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
			// FolderDirection, ��������� ������ �����-�����������
			ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );
			
			return true;
		}

        /* ����� ������ web-������� UpdatePresaleDirections. ���� ���������
         * 
         * 
        /// <summary>
        /// �������� ������ � ����������� ���������� �������� � ��������� �������������.
        /// </summary>
        /// <param name="sPresaleID">
        /// ��������� ������������� �������������� ����������� �������� ��������. 
        /// ������� �������� ��-�� ������������. 
        /// </param>
        /// <param name="PresaleDirections">
        /// ������ ������� PresaleDirection, � ������� ���������� ���������� �� ������������ 
        /// ����������� � ���������. 
        /// ��� ����� �������� ����������� ��� �������� ����� ��������. � �������� 
        /// �������� ����� ���� ����� ������ ������ - � ���� ������ ��� �����������
        /// ��� ���������� �������� ����������.
        /// ���������� ����������� ������ ���� ������������ � ������� Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - ���� �������� ����������� ������� � ������� ��������;
        /// -- False - ���� �������� ����������� �� �������.
        /// </returns>
        /// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
        [ WebMethod( Description = "�������� ������ � ����������� ���������� �������� � ��������� �������������" ) ]
        public bool UpdatePresaleDirections(string sPresaleID, ProjectDirection[] PresaleDirections) 
        {
            // �������� ���������� ��������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sPresaleID, "������������� ����������� (sPresaleID)" );
            // ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
            if (null == PresaleDirections)
                PresaleDirections = new ProjectDirection[0];


            // #1:
            // ��������� ��������� �������: ���������� ����� ��������� ������������ ���������
            ObjectOperationHelper helperPresale = loadPresale( sPresaleID, false, new string[]{ "FolderDirections" }  );
            // ... ���� ������ �� ������ - ������ ������ false:
            if (null==helperPresale)
                return false;
            // ����� ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections,
            // ��� ��������� ������ � XML ���������� � ������ �������� ����
            helperPresale.DropPropertiesXmlExcept( "FolderDirections" );

            // ����� ���� ���������� ��������� ��������������
            int nTotalPercentage = 0;

            // #2:
            // ����� �������� � ����������� ����������� ��� ������ ����. ���������� 
            // ������� FolderDirection, ������� ����� ������ �������� ���� ������
            // �� �����������. 
            //
            // ��� ������� ��������� ����������� �������� ��������� ������ ������ 
            // FolderDirection; ����� �� ����� ������� ��, ������� � ���������������
            // �������� ����������� - ��������� ����� ��������. ��� ���� � ������� 
            // ������� �� ���� ������� ������ - � ��������� ����� �������� ������ 
            // ������ ��������; ��� ������ � ����� ������� - ������ ��� ��� ������� 
            // ����������� ���������� (��. ����� #4)
            ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[PresaleDirections.Length + 1];
            for (int nIndex = 0; nIndex < PresaleDirections.Length; nIndex++)
            {
                // ��������� ������������� ��������� �����������
                Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(PresaleDirections[nIndex].DirectionID, String.Format("������������� ����������� ProjectDirections[{0}].DirectionID", nIndex));

                // ��������� ������� ��������� �����������.
                int nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(PresaleDirections[nIndex].Percentage, String.Format("������� ������������� ������ �� ����������� ProjectDirections[{0}].Percentage", nIndex));


                // ������ ����� ������������ �����������
                foreach (XmlElement xmlFolderDirection in helperPresale.PropertyXml("FolderDirections").ChildNodes)
                {
                    if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(PresaleDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                    {
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                        helperPresale.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                        break;
                    }
                }
                if (arrHelpers[nIndex] == null)
                {
                    // ��������� "��������" ������ ���������� ds-������� FolderDirection
                    arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                }
                arrHelpers[nIndex].LoadObject();
                // ... ����������� ������ �� �����������:
                arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                // ... � ����� ����������� ������ �� ������:
                arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidProjectID);
                // ... "���� ������" - � ����:
                arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                nTotalPercentage += nPercentage;
            }
            // ���� �������� ���� �� ���� �����������, ����� ���������� ����� ������ ���� ����� 100
            if ((PresaleDirections.Length > 0) && (nTotalPercentage != 100))
                throw new ArgumentException("����� ���������� ����� �� ������������ ������ ���� ����� 100");
            
            // ... ��������� ������� ������� - ��� ������� (��. ����� #4):
            arrHelpers[PresaleDirections.Length] = helperPresale;


            // #3:
            // ���� ��� �������� ���� ���������� �����������, ��, �����., ���������� 
            // ��������� ������� FolderDirection, ����������� ������� � �����������. 
            // 
            // ��� ������ ����� �/� ��������� � ������������ ��� ��������� ������� ����
            // �������. �������� �������� ������������ � ������� ���������� ���������� �����
            // �����������, ��� "�����������" ����������, � ������� ��� FolderDirection
            // ����� �������� ��� ��������� - ��� ��� ����� ����� ������� delete="1".
            // 
            // ������� XML-������ �������� FolderDirection, �������� ��� ���� �� ���� -
            // ����� ��� �������� ����������� ���������� ������ �� ����� ����������
            // ��� ������������ �������� �� ��������� �������� (�� #4). � ����� �������
            // "�����" ��� ������ ������ �� FolderDirections ������, � ����� - �������:

            XmlElement xmlFolderDirections = (XmlElement)helperPresale.PropertyXml( "FolderDirections" ).CloneNode( true );
            // ... ������� ������ ������:
            helperPresale.ClearArrayProp( "FolderDirections" );
            // ... ����� - ���������:
            // ���� �� ������� ��������������� ��������, � ������ ��� ����:
            // -- ��� ��������� ������� - ���� �����������, � ��������� �� ����, 
            //		������� ���� �� ����� ������� ����� ����;
            // -- ��� ������ ��������������� �������� � ������� ��� �� ��������, 
            //		������� ��� ��������� �������������� ���������� NewlySetObjectID
            for( int nIndex=0; nIndex<arrHelpers.Length-1; nIndex++ )
                helperPresale.AddArrayPropRef( "FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID );

						
            // #4:
            // ������ ����������� ���������� ��� ������. �����: (�) ������ �����
            // �������� �����������, (�) ������ ����� FolderDirection-��, (�) ������ 
            // ������, ��������� FolderDirection-��
            XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm( arrHelpers );
            // ... � ���������� ��� ���� ���������� � ����� ������� - �� ������ 
            // ���������� �� helper-��. ������� ������ ���������:
            foreach( XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection") )
            {
                XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild( xmlDatagrammRoot.OwnerDocument.ImportNode( xmlFolderDirection, true) );
                // ���������� ������ ���������� FolderDirection ��� �� ����� - ������� (�����)
                xmlDeletedFolderDirection.InnerXml = "";
                // ... ������������� �������� delete="1", ���� ��� �������, 
                // ����������� ��� ��������������� ������ � �� ���� �������
                xmlDeletedFolderDirection.SetAttribute( "delete", "1" );
            }

			
            // #5: 
            // ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
            // ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
            // FolderDirection, ��������� ������ �����-�����������
            ObjectOperationHelper.SaveComplexDatagram( xmlDatagrammRoot, null, null );
			
            return true;
        }
        */

   		/// <summary>
		/// ������� �������� ��������� ����������� �� ������� Incident Tracker
		/// </summary>
		/// <param name="sPresaleID">��������� ������������� �������������� ��������� �����������</param>
		///	<exception cref="ArgumentNullException">���� sProlectID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sProlectID ����� � String.Empty</exception>
		[ WebMethod( Description = "������� �������� ��������� ����������� �� ������� Incident Tracker" ) ]
		public void DeletePresale( string sPresaleID ) 
		{
			// ��������� ������������ ����������:
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sPresaleID, "������������� ��������� ����������� (sPresaleID)" );
			
			// �������� �������:
			ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance( "Folder", uidProjectID );
			helperProject.DeleteObject();
		}
		
		
		
		
		
		/// <summary>
		/// �������� ��������� �����������, �������� ������� ������������ � �������.
		/// </summary>
		/// <param name="sPresaleID">
		/// ������ (System.String) � ��������� �������������� ����������� � ������� 
		/// Incident Tracker (���� �������� ��������� bIsExternalID ���� False), ��� 
		/// �������������� ����������� � ������� CRM (���� �������� ��������� 
		/// bIsExternalID ���� True).
		/// </param>
		/// <param name="bIsExternalID">
		/// �������, ����������� ����� ��������������, ����������� � sPresaleID:
		///		- false - ������������� ����������� � ������� Incident Tracker;
		///		- true � ������������� ����������� � ������� CRM;
		/// </param>
		/// <param name="enNewState">
		/// �������� ���������, ����������� ��� �����������, �������� ��������������� 
		/// sPresaleID; ���� �� �������� ������������ <see ref="PresaleStates"/>
		/// </param>
		/// <returns></returns>
		//[WebMethod( Description="�������� ��������� �����������, �������� ������� ������������ � ������� Incident Tracker." )]		
		[Obsolete]
		public bool UpdatePresaleState(
			string sPresaleID,
			bool bIsExternalID, 
			PresaleStates enNewState ) 
		{
			// TODO: ���� ������� �� ����� ���� ����� ����� ������� ��������������� 
			// (��������������� � CRM) - ��� ��� ���� ������ ��� � �������!
			if (bIsExternalID)
				throw new ArgumentException("� ������ ���������� ����������� �� ����� ���� ������ ������� ��������������� (��������������� � CRM), ��� ��� ���� ������ ��� � ������� Incident Tracker", "bIsExternalID" );

			// ��������� ������������ ����������: ���� �������� ������������� - 
			// ��� ������������� ����������� � IT, �� ��� ������ ���� Guid:
			Guid uidPresaleID = Guid.Empty;
			if (!bIsExternalID)
				uidPresaleID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sPresaleID, "������������� ����������� � ������� IT (sOrganizationID)" );

			// ��������� ������ ��������� ����������� (�����) �� ��������������� 
			// ������; ��� ���� ���������� "������" ������ �������� - �.�. ���� 
			// ������� ���, �� ��� ����� ������� ���������� ���������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Folder" );
			XParamsCollection identityParams = new XParamsCollection();
			// TODO: ��� ���������� ��������� bIsExternalID ����� �.�. "�����":
			identityParams.Add( "ObjectID", uidPresaleID );
			
			// ... ���� ��������� �� ���������� - � �����. � ������������ ������� � ����������� false:
			if ( !helper.SafeLoadObject(identityParams) )
				return false;
			// ... ��������, ��� ����������� ������ - ������������� ������ 
			// �� ������� �����������; ���� ��� �� ���, �� "������� ���", 
			// ��� ���������� ������� ��� � ������� - � �����. � ������������
			// ������ � false:
			if ( FolderTypeEnum.Presale != getFolderType(helper) )
				return false; 

			// �������� ��������� �� ���������:
			helper.SetPropValue( "State", XPropType.vt_i2, (int)getPresale2FolderState(enNewState) );
			// ...��� ��������� �������� �� ��������:
			helper.DropPropertiesXmlExcept( "State" );
			// ...���������� ���������:
			helper.SaveObject();

			return true;
		}
		
		
		/// <summary>
		/// ������������� �������� ���� ��������������� ���� ������������, 
		/// ��������� � ������� Incident Tracker
		/// </summary>
		/// <param name="bListAsExternalIDs">
		/// ���������� �������, ������������ ��� ���������������, ������������ 
		/// � �������������� �������: ���� �������� ��������� ������ � false, 
		/// �� � ���������� ����� ���������� ������ ��������������� ������������ 
		/// � ������� Incident Tracker. ���� �������� ��������� ������ ��� true, 
		/// �� �������� ��������������� ������� ���� �������������� ������������ 
		/// � ������� CRM.
		/// </param>
		/// <param name="bListFrozen">
		/// ���������� �������, ������������, ����� �� ���������� � �������������� 
		/// ������ �������������� ������������, ��������� ������� �� ������ ������ 
		/// ���������� ��� "����������"
		/// </param>
		/// <param name="bListClosed">
		/// ���������� �������, ������������, ����� �� ���������� � �������������� 
		/// ������ �������������� ������������, ��������� ������� �� ������ ������ 
		/// ���������� ��� "�������"
		/// </param>
		/// <returns></returns>
		//[WebMethod( Description="������������� �������� ���� ��������������� ���� ������������, ��������� � ������� Incident Tracker." )]
		[Obsolete]
		public string[] ListPresales(
			bool bListAsExternalIDs,
			bool bListFrozen,
			bool bListClosed ) 
		{
			// TODO: ���� ������ ������� ��������������� (��������������� � CRM)
			// �� ����� ���� ������� - ��� ��� ���� ������ ��� � �������!
			if (bListAsExternalIDs)
				throw new ArgumentException("� ������ ���������� ������ ������� ��������������� ����������� (��������������� � CRM) �� ����� ���� �������, ��� ��� ���� ������ ��� � ������� Incident Tracker", "bListAsExternalIDs" );
			
			// ������� ������ ���� ��������:
			// ...��������� ��������� ��������� ������:
			XParamsCollection srcParams = new XParamsCollection();
			// �������� "InState" - ��� ������ � ��������� �������� ����������
			// �����: �������� � � �������� �������� - ���������� ����������:
			srcParams.Add( "InState", FolderStatesItem.Open.IntValue );
			srcParams.Add( "InState", FolderStatesItem.WaitingToClose.IntValue );
			// "������������" � "��������" - � ����������� �� ���������� ������:
			if (bListFrozen)
				srcParams.Add( "InState", FolderStatesItem.Frozen.IntValue );
			if (bListClosed)
				srcParams.Add( "InState", FolderStatesItem.Closed.IntValue );

			// ... �������� �������� ������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Presales-GetIDsList", srcParams );

			if ( null == oDataTable )
				return null;
			if ( 0 == oDataTable.Rows.Count)
				return null;

			// ��������� � ������ �����:
			string[] arrPresaleIDs = new string[ oDataTable.Rows.Count ];
			for( int nIndex=0; nIndex<oDataTable.Rows.Count; nIndex++ )
				arrPresaleIDs[nIndex] = oDataTable.Rows[nIndex][0].ToString();
			
			return arrPresaleIDs;
		}
		
		
		/// <summary>
		/// ������������� ������ ���� ������������, ��������� � �������.
		/// </summary>
		/// <param name="sTargetOrganizationID">
		/// ������������� ������� �����������, ��� ������� ���������� ������ ������������;
		/// �� ����������� ��������; ���� �� ����� (null), ����� ���������� ������ �� ����
		/// ������������ ���� ����������� ��������, �������������� � �������
		/// </param>
		/// <param name="bReadFrozen">
		/// ���������� �������, ������������, ����� �� ���������� � �������������� 
		/// ������ �������� ������������, ��������� ������� �� ������ ������ 
		/// ���������� ��� "����������" (��. ��� �� �������� PresaleInfo.State)
		/// </param>
		/// <param name="bReadClosed">
		/// ���������� �������, ������������, ����� �� ���������� � �������������� 
		/// ������ �������� ������������, ��������� ������� �� ������ ������ 
		/// ���������� ��� "�������" (��. �������� PresaleInfo.State)
		/// </param>
		/// <returns>
		/// ������ �������� ������������ � ����������� ���� PresaleInfo. ���� 
		/// � ������� IT ��� �������� ������������ (��������������� ��������� 
		/// �������� �������, ���������� ����������� bReadFrozen � bReadClosed),
		/// ����� ���������� null.
		/// </returns>
		//[WebMethod( Description="������������� ������ ���� ������������, ��������� � ������� Incident Tracker." )]
		[Obsolete]
		public PresaleInfo[] ReadAllPresales(
			string sTargetOrganizationID,
			bool bReadFrozen,
			bool bReadClosed ) 
		{
			Guid uidTargetOrganizationID = Guid.Empty;
			if ( null != sTargetOrganizationID )
				uidTargetOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sTargetOrganizationID, "������������� ������� ����������� (sTargetOrganizationID)" );
			
			// ������� ������ ���� ��������:
			// ...��������� ��������� ��������� ������:
			XParamsCollection srcParams = new XParamsCollection();
			// �������� "InState" - ��� ������ � ��������� �������� ����������
			// �����: �������� � � �������� �������� - ���������� ����������:
			srcParams.Add( "InState", FolderStatesItem.Open.IntValue );
			srcParams.Add( "InState", FolderStatesItem.WaitingToClose.IntValue );
			// "������������" � "��������" - � ����������� �� ���������� ������:
			if (bReadFrozen)
				srcParams.Add( "InState", FolderStatesItem.Frozen.IntValue );
			if (bReadClosed)
				srcParams.Add( "InState", FolderStatesItem.Closed.IntValue );
			// ...���� ����� ������������� ������� ����������� - ��������� ���:
			if ( Guid.Empty != uidTargetOrganizationID )
				srcParams.Add( "TargetOrgID", uidTargetOrganizationID );

			// ... �������� �������� ������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Presales-GetList", srcParams );

			if ( null == oDataTable )
				return null;
			if ( 0 == oDataTable.Rows.Count)
				return null;

			// �������� ������ ���� �������� ������������ � IT, �� ��������� 
			// ������ ��������� ������ ��������� ��������:
			PresaleInfo[] arrPresalesInfo = new PresaleInfo[ oDataTable.Rows.Count ];
			for( int nRowIndex=0; nRowIndex<oDataTable.Rows.Count; nRowIndex++ )
			{
				// ��������� �������� �����������:
				PresaleInfo info = new PresaleInfo();

				// ��������� ������ �����:
				info.ObjectID = oDataTable.Rows[nRowIndex]["ObjectID"].ToString();
				//info.RefCodePresale =  safeDbString2String( oDataTable.Rows[nRowIndex]["RefCodePresale"] );; // TODO: ���� ���� ������ � ������� ���, ������ ����� NULL - ��. ������

				info.CustomerID = safeDbString2String( oDataTable.Rows[nRowIndex]["CustomerID"] );
				info.Name = safeDbString2String( oDataTable.Rows[nRowIndex]["Name"] );
				info.Code = safeDbString2String( oDataTable.Rows[nRowIndex]["Code"] );
				info.NavisionID = safeDbString2String( oDataTable.Rows[nRowIndex]["NavisionID"] );
				
				// ... ��������� ����� ��������� � ��������� ��������, � ��
				// ��������� ���� ������ ����������� ������������� �����:
				info.State = getFolder2PresaleState( (FolderStates)oDataTable.Rows[nRowIndex]["State"] );

				// ... ���������:
				info.InitiatorID = safeDbString2String( oDataTable.Rows[nRowIndex]["InitiatorID"] );

				// ��������� �������� � �������������� ������ ���� ��������
				arrPresalesInfo[nRowIndex] = info;
			}

			return arrPresalesInfo;
		}
		
		#endregion

		#region ������, ������������ ��� ������������� ������ ��������

		/// <summary>
		/// ���������� ������ ����� ��������, �������������� � ������� Incident Tracker, 
		/// ��� ������ ����������� ������ Croc.IncidentTracker.Services.ProjectInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.TenderInfo"/>
		/// </summary>
		[WebMethod(Description = "���������� ������ ����� ��������, �������������� � ������� Incident Tracker")]
		public TenderInfo[] GetTendersInfo(Guid[] objectIDs)
		{
			XParamsCollection dsParams = new XParamsCollection();
			if (objectIDs != null)
			{
				foreach (Guid objectID in objectIDs)
				{
					dsParams.Add("ObjectID", objectID);
				}
			}

			// ������� ������ ���� ��������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-TenderFolders", dsParams);

			dsParams.Clear();
			dsParams = null;

			if (null == oDataTable)
                return new TenderInfo[0];

			TenderInfo[] arrProjectsInfo = new TenderInfo[oDataTable.Rows.Count];
			for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
			{
				// ��������, ��� ������������� ����� ���� "������"
				FolderTypeEnum enType = (FolderTypeEnum)oDataTable.Rows[nRowIndex]["Type"];
				if (FolderTypeEnum.Tender != enType)
					continue;

				TenderInfo info = new TenderInfo();

				// ��������� ������ �����
				info.ObjectID = new Guid(oDataTable.Rows[nRowIndex]["ObjectID"].ToString());

				info.FinishDate =
					DBNull.Value != oDataTable.Rows[nRowIndex]["FinishDate"]
					? DateTime.Parse(oDataTable.Rows[nRowIndex]["FinishDate"].ToString())
					: new DateTime?();

				info.Name = oDataTable.Rows[nRowIndex]["Name"].ToString();

				/*info.ProjectCode =
					DBNull.Value != oDataTable.Rows[nRowIndex]["ProjectCode"]
					? oDataTable.Rows[nRowIndex]["ProjectCode"].ToString()
					: null;*/

				info.StartDate =
					DBNull.Value != oDataTable.Rows[nRowIndex]["StartDate"]
					? DateTime.Parse(oDataTable.Rows[nRowIndex]["StartDate"].ToString())
					: new DateTime?();

				info.State = (TenderFolderStates)((int)Math.Log(int.Parse(oDataTable.Rows[nRowIndex]["State"].ToString()), 2) + 1);

				info.Customer = new Guid(oDataTable.Rows[nRowIndex]["Customer"].ToString());

				info.Initiator = 
					DBNull.Value != oDataTable.Rows[nRowIndex]["Initiator"]
					? new Guid(oDataTable.Rows[nRowIndex]["Initiator"].ToString())
					: new Guid?();

				info.Parent =
					DBNull.Value != oDataTable.Rows[nRowIndex]["Parent"]
					? new Guid(oDataTable.Rows[nRowIndex]["Parent"].ToString())
					: new Guid?();

				info.NavisionID =
					DBNull.Value != oDataTable.Rows[nRowIndex]["ExternalID"]
					? oDataTable.Rows[nRowIndex]["ExternalID"].ToString()
					: null;

				// �������� ������ � ������
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		/// <summary>
		/// ���������� ������ ����������� ����� ��������, �������������� � ������� Incident Tracker, 
		/// ��� ������ ����������� ������ Croc.IncidentTracker.Services.FolderDirectionInfo.
		/// <seealso cref="Croc.IncidentTracker.Services.FolderDirectionInfo"/>
		/// </summary>
		[WebMethod(Description = "���������� ������ ����������� ��� ����� ��������, �������������� � ������� Incident Tracker")]
		public FolderDirectionInfo[] GetTenderDirectionsInfo(Guid[] objectIDs)
		{
			XParamsCollection dsParams = new XParamsCollection();
			if (objectIDs != null)
			{
				foreach (Guid objectID in objectIDs)
				{
					dsParams.Add("ObjectID", objectID);
				}
			}

			// ������� ������ ���� ��������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("SyncNSI-GetList-TenderFolderDirections", dsParams);

			dsParams.Clear();
			dsParams = null;

			if (null == oDataTable)
				return new FolderDirectionInfo[0];

			FolderDirectionInfo[] arrProjectsInfo = new FolderDirectionInfo[oDataTable.Rows.Count];
			for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
			{
				FolderDirectionInfo info = new FolderDirectionInfo();

				// ��������� ������ �����
				info.Direction = new Guid(oDataTable.Rows[nRowIndex]["Direction"].ToString());

				info.Folder = new Guid(oDataTable.Rows[nRowIndex]["Folder"].ToString());

				// �������� ������ � ������
				arrProjectsInfo[nRowIndex] = info;
			}
			return arrProjectsInfo;
		}

		#endregion

		#region ������, ������������ ��� ������������� ������ �����������

		/// <summary>
		/// ��������� �������� �����������, �������� ���������� <see cref="OrganizationInfo"/>
		/// ��� ������ ���������������� ������� - helper-�
		/// </summary>
		/// <param name="orgInfo">�������� ������ �����������</param>
		/// <param name="helperOrg">Helper-������ (�.�. ���������������)</param>
		private static void setOrganizationData( OrganizationInfo orgInfo, ObjectOperationHelper helperOrg )
		{
			// ������ ��������� �������� �������:
			// ... ��� ����������� � ���
			helperOrg.SetPropValue( "RefCodeNSI", XPropType.vt_string, 
				null!=orgInfo.RefCodeNSI? orgInfo.RefCodeNSI : String.Empty );
			// ... ������� ������������ �����������:			
			helperOrg.SetPropValue( "ShortName", XPropType.vt_string, 
				null!=orgInfo.ShortName? orgInfo.ShortName : String.Empty );
			// ... ������ ������������
			helperOrg.SetPropValue( "Name", XPropType.vt_string, orgInfo.Name );
			// ... ����������� / ���������� � ��������
			helperOrg.SetPropValue( "Comment", XPropType.vt_string, orgInfo.Comment );
			// ... ������������� ����������� � Navision:
			helperOrg.SetPropValue( "ExternalID", XPropType.vt_string, 
				null!=orgInfo.NavisionID ? orgInfo.NavisionID : String.Empty );
			// ... �������� "����� �����������" � "��������� �������� �� ���":
			helperOrg.SetPropValue( "Home", XPropType.vt_boolean, orgInfo.IsOwnOrganization );
			helperOrg.SetPropValue( "OwnTenderParticipant", XPropType.vt_boolean, orgInfo.IsOwnTenderParticipant );
	
			// ��������� �������� (��������������� ��� �������, ���� ������ ��������):
			// ... ������������� ���������� - ��������� �������:
			if ( null!=orgInfo.DirectorEmployeeID )
				helperOrg.SetPropScalarRef( 
					"Director", "Employee", 
					ObjectOperationHelper.ValidateRequiredArgumentAsID( orgInfo.DirectorEmployeeID, "������������� ���������� - ��������� �������" ) );
			else
				helperOrg.PropertyXml("Director").InnerXml = String.Empty;
			
			// ... ������ �� �������, � �������� ���������� ������ �����������:
			helperOrg.ClearArrayProp( "Branch" );
			if ( null!=orgInfo.BranchesIDs )
			{
				foreach( string sBranchID in orgInfo.BranchesIDs )
					helperOrg.AddArrayPropRef( 
						"Branch", "Branch", 
						ObjectOperationHelper.ValidateRequiredArgumentAsID(sBranchID,"������������� �������") );
			}
			
			// ...������ �� ����������� �����������:
			if ( null!=orgInfo.ParentOrganizationID )
				helperOrg.SetPropScalarRef(
					"Parent", "Organization",
					ObjectOperationHelper.ValidateRequiredArgumentAsID( orgInfo.ParentOrganizationID, "������������� ����������� �����������" ) );
			else
				helperOrg.PropertyXml("Parent").InnerXml = String.Empty;
		}


		/// <summary>
		/// ������� � ������� Incident Tracker �������� ����������� � ��������� �����������.
		/// </summary>
		/// <param name="sOrganizationID">������������� ����������� � ������� IT</param>
		/// <param name="orgInfo">�������� ����� �����������</param>
		/// <remarks>
		/// �������� ���� <see cref="OrganizationInfo.ObjectID"/> ������������; ��� 
		/// �������� �������� � �������� �������������� ����������� ������������ 
		/// �������� ��������� sOrganizationID. ������������� �������� ����������� 
		/// � ��� - ��� ��� - �������� ��� �������� ���� <see cref="OrganizationInfo.RefCodeNSI"/>
		/// </remarks>
		///	<exception cref="ArgumentNullException">���� sOrganizationID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sOrganizationID ����� � String.Empty</exception>
		[WebMethod( Description="������� � ������� Incident Tracker �������� ����������� � ��������� �����������." )]
		public void CreateOrganization(
			string sOrganizationID,
			OrganizationInfo orgInfo ) 
		{
			// ��������� ���������:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sOrganizationID, "������������� ����������� ����������� (sOrganizationID)" );
			orgInfo.Validate( false );
			
			// ��������� "��������" ������� � ��������������� ������ � ����� 
			// �������� ������������ ������������� �� ��������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			helper.LoadObject();
			helper.NewlySetObjectID = uidOrganizationID;
			// ��������� ������ �� �������� � helper:
			setOrganizationData(orgInfo, helper);

			// ������ �� ���������� ����, ������� �� ������ ������������:
			helper.DropPropertiesXml( "ExternalRefID" );

			// ���������� ������ ����� �����������: �������� ����������
			// ������ (��� ����������) - ������ ������ ��������
			helper.SaveObject();
		}


		/// <summary>
		/// ��������� �������� �����������, �������������� � ������� Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">������������� ����������� � ������� IT</param>
		/// <param name="orgInfo">���������� �������� �����������</param>
		/// <returns>
		/// ���������� ������� ��������� ���������� ��������:
		///		- true - �������� ������� ���������;
		///		- false - ��������� ����������� �� �������;
		///	� ������ ������ ���������� ������������� �������� ������������ ����������.
		/// </returns>
		/// <remarks>�������� ���� <see cref="OrganizationInfo.ObjectID"/> ������������</remarks>
		///	<exception cref="ArgumentNullException">���� sOrganizationID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sOrganizationID ����� � String.Empty</exception>
		[WebMethod( Description="��������� �������� �����������, �������������� � ������� Incident Tracker." )]
		public bool UpdateOrganization(
			string sOrganizationID, 
			OrganizationInfo orgInfo )
		{
			// ��������� ���������:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sOrganizationID, "������������� ����������� ����������� (sOrganizationID)" );
			orgInfo.Validate( false );

			// ��������� ������ ��������� ����������� �� ��������������� ������:
			// ���������� "������" ������ �������� - �.�. ���� ������� ���, �� ���
			// ����� ������� ���������� ���������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			XParamsCollection identityParams = new XParamsCollection();
			identityParams.Add( "ObjectID", uidOrganizationID );
			// ... ���� ��������� �� ���������� - � �����. � ������������ ������� � ����������� false:
			if ( !helper.SafeLoadObject(identityParams) )
				return false;
			
			// ��������� ������ �� �������� � helper:
			setOrganizationData(orgInfo, helper);

			// ������ �� ���������� ����, ������� �� ������ ������������:
			helper.DropPropertiesXml( 
				"ExternalRefID"
			);
			
			// ���������� ������ ���������� �����������:
			helper.SaveObject();
			return true;
		}

		
		/// <summary>
		/// ��������� ������� �������� ��������� ����������� � ������� Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">������������� ����������� � ������� IT</param>
		/// <param name="bIsExternalID">
		///	�������, ����������� ����� ��������������, ����������� ���������� sOrganizationID:
		///		- false - ������������� � ������� Incident Tracker
		///		- true - ������������� ���
		/// </param>
		/// <returns>
		/// ���� �������� ��������� ����������� ����������, ���������� ������
		/// � ��������������� ����������� � ������� IT (��� ����������� �� ��������
		/// ��������� bIsExternalID). � ��������� ������ - ���� �������� ���������
		/// ����������� �� ���������� - ���������� ������ ������ (������ ������� 
		/// �����).
		/// </returns>
		///	<exception cref="ArgumentNullException">���� sOrganizationID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sOrganizationID ����� � String.Empty</exception>
		[WebMethod( Description="��������� ������� �������� ��������� ����������� � ������� Incident Tracker." )]
		public string IsOrganizationExists(
			string sOrganizationID,
			bool bIsExternalID ) 
		{
			// ��������� ������������ ����������: ���� �������� ������������� - 
			// ��� ������������� ����������� � IT, �� ��� ������ ���� Guid:
			Guid uidOrganizationID = Guid.Empty;
			if (!bIsExternalID)
				uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
					sOrganizationID, "������������� ����������� � ������� IT (sOrganizationID)" );
			
			// ���������� ����� "������" �������� ���������������� �������, 
			// ���������������� ������ "�������" ������:
			// ... ��������� ����������, �������� ����
			XParamsCollection identityParams = new XParamsCollection();
			if (bIsExternalID)
				identityParams.Add( "RefCodeNSI", sOrganizationID );
			else
				identityParams.Add( "ObjectID", uidOrganizationID );
			// ... ��� ��������������� ������:
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			// ... �������� "������" �������� ������ �������:
			// ���� ������ ��������, ������ true:
			bool bLoaded = helper.SafeLoadObject( identityParams );

			if (bLoaded)
				return helper.ObjectID.ToString();
			else
				return String.Empty;
		}


		/// <summary>
		/// �������� �������� ��������� ����������� �� ������� Incident Tracker.
		/// </summary>
		/// <param name="sOrganizationID">������������� ����������� � ������� IT</param>
		/// <returns>
		/// ���������� ������� ��������� �������� �������� ��������� �����������:
		///		- true - �������� ������� �������;
		///		- false - ��������� ����������� �� �������;
		///	� ������ ������ �������� ������������� �������� ������������ ����������.
		/// </returns>
		///	<exception cref="ArgumentNullException">���� sOrganizationID ����� � null</exception>
		///	<exception cref="ArgumentException">���� sOrganizationID ����� � String.Empty</exception>
		[WebMethod( Description="�������� �������� ��������� ����������� �� ������� Incident Tracker." )]
		public bool DeleteOrganization( string sOrganizationID ) 
		{
			// ��������� ������������ ����������:
			Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID( 
				sOrganizationID, "������������� ��������� ����������� (sOrganizationID)" );
			
			// ���������� ����� �������� ���������������� �������, ���������������� 
			// ������ "�������" ������: ���� ��� ���� ���������, ����� ����� ��������
			// "������" �������� �������� DeleteObjectByExKey, ������� ��������� 
			// ������� ��������� ������� �������
			ObjectOperationHelper helper = ObjectOperationHelper.GetInstance( "Organization" );
			XParamsCollection identityParams = new XParamsCollection();
			identityParams.Add( "ObjectID", uidOrganizationID );
			// ... ����� ����� ��������� ��������, ����������� ���������� ��������
			// � ������ ���������� ������� - ��. ���������� DeleteObjectByExKey:
			return helper.DeleteObject( identityParams, true);
		}

        /// <summary>
        /// ��������� �������� ��������� �����������, �������������� � ������� Incident Tracker.
        /// </summary>
        /// <param name="sOrganizationID">������������� ����������� � ������� IT</param>
        /// <returns>
        /// � ������ ��������� ��������� �������� ��������� ����������� ����������
        /// ������������������ ��������� <see cref="OrganizationInfo"/>; ���� ��������
        /// ��������� ����������� � IT �� ���������� - ���������� null.
        /// � ������ ������ ��������� ������������� �������� ����������� ������������
        /// ����������.
        /// </returns>
        ///	<exception cref="ArgumentNullException">���� sOrganizationID ����� � null</exception>
        ///	<exception cref="ArgumentException">���� sOrganizationID ����� � String.Empty</exception>
        [WebMethod(Description = "��������� �������� ��������� �����������, �������������� � ������� Incident Tracker.")]
        public OrganizationInfo ReadOrganization(string sOrganizationID)
        {
            // ��������� ������������ ����������:
            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sOrganizationID, "������������� ����������� (sOrganizationID)");

            // ��������� ������ ��������� ����������� �� ��������������� ������:
            // ���������� "������" ������ �������� - �.�. ���� ������� ���, �� ���
            // ����� ������� ���������� ���������:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Organization");
            XParamsCollection identityParams = new XParamsCollection();
            identityParams.Add("ObjectID", uidOrganizationID);
            // ... ���� ��������� �� ���������� - � �����. � ������������ ������� � ����������� null:
            if (!helper.SafeLoadObject(identityParams))
                return null;

            // �������������� �������� �����������, ��� ������:
            OrganizationInfo orgInfo = new OrganizationInfo();

            // ��������� ������ 
            // ... ��� ��-��������� �������:
            orgInfo.ObjectID = helper.ObjectID.ToString();
            orgInfo.RefCodeNSI = safeReadData(helper, "RefCodeNSI");
            orgInfo.ShortName = safeReadData(helper, "ShortName");
            orgInfo.Name = safeReadData(helper, "Name");
            orgInfo.Comment = safeReadData(helper, "Comment");
            orgInfo.NavisionID = safeReadData(helper, "ExternalID");
            orgInfo.IsOwnOrganization = (bool)(helper.GetPropValue("Home", XPropType.vt_boolean));
            orgInfo.IsOwnTenderParticipant = (bool)(helper.GetPropValue("OwnTenderParticipant", XPropType.vt_boolean));
            // "�����������" ��� �������������� �������: ���� �������� - ������ 
            // ������, �� ��������� ��� (�������) � null:
            if (String.Empty == orgInfo.RefCodeNSI)
                orgInfo.RefCodeNSI = null;
            if (String.Empty == orgInfo.ShortName)
                orgInfo.ShortName = null;
            if (String.Empty == orgInfo.Comment)
                orgInfo.Comment = null;
            if (String.Empty == orgInfo.NavisionID)
                orgInfo.NavisionID = null;

            // ... ��������� ������:
            ObjectOperationHelper helperRef = helper.GetInstanceFromPropScalarRef("Director", false);
            orgInfo.DirectorEmployeeID = (null == helperRef ? null : helperRef.ObjectID.ToString());
            helperRef = helper.GetInstanceFromPropScalarRef("Parent", false);
            orgInfo.ParentOrganizationID = (null == helperRef ? null : helperRef.ObjectID.ToString());

            // ... ������ ������:
            helper.UploadArrayProp("Branch");
            XmlNodeList xmlArray = helper.PropertyXml("Branch").SelectNodes("Branch[@oid]");
            if (0 != xmlArray.Count)
            {
                orgInfo.BranchesIDs = new string[xmlArray.Count];
                int nIndex = 0;
                foreach (XmlNode xmlNode in xmlArray)
                    orgInfo.BranchesIDs[nIndex++] = ((XmlElement)xmlNode).GetAttribute("oid");
            }
            else
                orgInfo.BranchesIDs = null;

            return orgInfo;
        }

		/// <summary>
		/// ��������� ������� ��������������� ���� �����������, �������������� 
		/// � ������� Incident Tracker.
		/// </summary>
		/// <returns>
		/// ������������ ������ �����, ���������� �������������� ����������� 
		/// � ������� Incident Tracker. ���� ����������� ���, ���������� null.
		/// </returns>
		[WebMethod( Description="��������� ������� ��������������� ���� �����������, �������������� � ������� Incident Tracker." )]
		public string[] ListOrganization()
		{
			// �������� ������ ��������������� �����������:
			DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource( "CommonService-Sync-Organizations-GetIDsList", null );
			if ( null==oDataTable )
				return null;
			if ( 0==oDataTable.Rows.Count )
				return null;

			// ��������� � ������ �����:
			string[] arrOrgIDs = new string[ oDataTable.Rows.Count ];
			for( int nIndex=0; nIndex<oDataTable.Rows.Count; nIndex++ )
				arrOrgIDs[nIndex] = oDataTable.Rows[nIndex][0].ToString();
			
			return arrOrgIDs;
		}


		/// <summary>
		/// ���������� ��������� ������� �������� �����������, �������������� 
		/// � ������� Incident Tracker.
		/// </summary>
		/// <param name="sMasterOrganizationID">
		/// ������������� ������-����������� (�������� ������� �������� ��� 
		/// �������� ���������� ��������� �������)
		/// </param>
		/// <param name="sMergedOrganizationID">
		/// ������������� �����������, �������� ������� ���������� ���������
		/// ������-�����������
		/// </param>
		/// <param name="sFullName">������ ������������</param>
		/// <param name="sShortName">����������� ������������</param>
		/// <remarks>
		/// � ������ ���������� �������� ����� �� ��������� ��������, � ��� �� 
		/// � ������ ������ ��������� ������� - ������������ ����������.
		/// </remarks>
		[WebMethod( Description="���������� ��������� ������� �������� �����������, �������������� � ������� Incident Tracker." )]
		public void MergeOrganizations( 
			string sMasterOrganizationID, 
			string sMergedOrganizationID,
			string sFullName, 
			string sShortName ) 
		{
			// �������� ����������:
			Guid uidMasterOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sMasterOrganizationID, "������������� ������-����������� (sMasterOrganizationID)" );
			Guid uidMergedOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sMergedOrganizationID, "������������� ���������� ����������� (sMergedOrganizationID)" );
			ObjectOperationHelper.ValidateRequiredArgument( sFullName, "������������ ������� ������-����������� (sFullName)" );
			ObjectOperationHelper.ValidateRequiredArgument( sShortName, "������� ������������ ������� ������-����������� (sShortName)" );
			
			// ���������� ���������:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "MasterOrganizationID", uidMasterOrgID );
			paramsCollection.Add( "DuplicatedOrganizationID", uidMergedOrgID );
			paramsCollection.Add( "sFullName", sFullName );
			paramsCollection.Add( "sShortName", sShortName );
			// ... ���������, ������� ���� � �������������� ������, �� � ������ ������ �� ������������:
			paramsCollection.Add( "AccChiefID", Guid.Empty );	// - ������������� ����������, ������������ ���������� ��� "������������" �����������
			paramsCollection.Add( "ParentID", Guid.Empty );		// - ������������� ����������� ������������ ��� "������������" �����������
			
			// �������� ���������, ����� "�������� ������":
			ObjectOperationHelper.ExecAppDataSourceScalar( "SyncNSI-Exec-MergeOrganization", paramsCollection );
		}

		#endregion

		#region ������ ��������� ���������� � ��������� ������������� IT �� ������
		
		/// <summary>
		/// ��������� ���������� � ��������� ������������� ������� IT � ������� ������ �������.
		/// </summary>
		/// <param name="enIdentificationMethod">
		/// ����� ������������� ������������ ("���" ��������������� � ������� arrEmployeesIDs).
		/// ��������� �������� ������������� ������������ ������������� IdentificationMethod.
		/// </param>
		/// <param name="arrEmployeesIDs">
		/// ������ ��������������� ������������� IT; ������ ��������������� ������������ � �����.
		///		c ������� �������������, ���������� ���������� enIdentificationMethod. ������ 
		///		������, null, ��������������, ��� ������� � IT �����. ������ ������������� �� 
		///		������� - ������������.
		/// ��������! ��� ��������� ������ �������� ���������� ������������� ������ � XML!
		///		���� ������� ��������� - ���������� ������ XML-���������������� ������ ������.
		/// </param>
		/// <param name="dtPeriodBegin">���� ������ ���������������� ������� (������������)</param>
		/// <param name="dtPeriodEnd">���� �������� ���������������� ������� (������������)</param>
		/// <returns></returns>
		[ WebMethod( Description="����� ��������� ���������� � ��������� ������������� � ������� ������ �������" ) ]
		public EmployeeExpenseInfo[] GetEmployeesExpenses(
			IdentificationMethod enIdentificationMethod,
			[XmlArray( ElementName ="IDs" ), XmlArrayItem( ElementName="ID", Type=typeof(string) ) ]
			string[] arrEmployeesIDs,
			DateTime dtPeriodBegin,
			DateTime dtPeriodEnd )
		{
			// �������� ����������:
			if ( null == arrEmployeesIDs )
				throw new ArgumentNullException( "arrEmployeesIDs", "������ ��������������� ����������� �� ����� (null)" );
			if ( 0 == arrEmployeesIDs.Length )
				throw new ArgumentException( "������ ��������������� ����������� �� ����� (������ ������)", "arrEmployeesIDs" );
			if ( DateTime.MinValue == dtPeriodBegin )
				throw new ArgumentException( "���� ������ ��������� ������� �� ������", "dtPeriodBegin" );
			if ( DateTime.MinValue == dtPeriodEnd )
				throw new ArgumentException( "���� ��������� ��������� ������� �� ������", "dtPeriodEnd" );
			
			// ������������ ������ ���������������, ��� ������� � ������� ��������
			StringBuilder sbIDsList = new StringBuilder();
			int nIndex = 0;
			foreach ( string sEmpID in arrEmployeesIDs )
			{
				// �������� ������������ �������� ��������� ��������������
				if ( IdentificationMethod.ByTrackerEmployeeID == enIdentificationMethod )
					ObjectOperationHelper.ValidateRequiredArgumentAsID( sEmpID, "������������� arrEmployeesIDs[" + nIndex + "]" );
				else
					ObjectOperationHelper.ValidateRequiredArgument( sEmpID, "������������� arrEmployeesIDs[" + nIndex + "]" );
				
				sbIDsList.Append( sEmpID ).Append( "," );
				nIndex += 1;
			}
			
			if ( sbIDsList.Length > 1 )
				sbIDsList.Remove( sbIDsList.Length-1, 1 );
			if ( 0 == sbIDsList.Length )
				throw new ArgumentException( "������ ��������������� ����������� �� ����� (arrEmployeesIDs)" );
			
			// ������������ ������� ��������
			GetEmployeesExpensesRequest request = new GetEmployeesExpensesRequest();
			request.IdentificationMethod = enIdentificationMethod;
			request.EmployeesIDsList = sbIDsList.ToString();
			request.ExceptDepartmentIDsList = ServiceConfig.Instance.CommonServiceParams.ExpensesProcess.EmpExpenses_ExceptedDepsList;
			request.PeriodBegin = dtPeriodBegin;
			request.PeriodEnd = dtPeriodEnd;
			
			GetEmployeesExpensesResponse response =
                (GetEmployeesExpensesResponse)ObjectOperationHelper.AppServerFacade.ExecCommand(request);
			if (null==response)
				throw new InvalidOperationException("������ ���������� �������� ������� ����������: � �������� ���������� ������� null");

			return ( null == response.Expenses ? new EmployeeExpenseInfo[0] : response.Expenses );
		}


        #endregion

		#region ������ �������������� � �������� HPOVSD
		/// <summary>
		/// HPOVSD. ����� ������������� ���������� �� �������� � ���������� �������������.
		/// </summary>
		/// <param name="xmlDirections">
		/// ������ ����������� 
		/// </param>
		[WebMethod( Description="��������� �������� �� �������� ������������ " )]
		public XmlDocument HPOVSD_GetProjectList( XmlDocument xmlDirections
			)
		{
			// ������ - ���������:
			XmlDocument xmlResult = null; 

			try 
			{
				// ��������� ��������� ��� ������ ��������� ������ (� ������� �������� 
				// ����� �������� ��������� - ��. it-metadata-data-sources.xml):
				XParamsCollection procParams = new XParamsCollection();
				procParams.Add( "Directions",xmlDirections.OuterXml); 
				// ����� ��������� ������ � ������������ ������������ XML-����������
				// ���� <Data><row FolderID='...' FolderName='...' FolderName='...' Open='...'
				// DirectionID='...' DirectionName='...' OrganizationID='...' OrganizationName='...' 
				// ManagerID='...' ManagerLogin='...'> </Data>
				// �������������� XML-���������� �������������� �� ��������� �����������
				// ������������ ������� ��������������� ������ ����������� 
				// DataTableXmlFormatter - ��. ����������� � ����������
				DataTable data = ObjectOperationHelper.ExecAppDataSource("CommonService-GetProjectsByDirections", procParams );
				//DataTableXmlFormatter formatter = new DataTableXmlFormatter();
				XmlDocument xmlData = DataTableXmlFormatter.GetXmlFromDataTable(data,"Data","row");
				// ��������� �������������� ������: ���������� ��������� XML-�����,
				// ����������� ��������� � "�������" �������� - ������� ����� � �������
				// ����������, ������������ ������ (Descr � Stack):
				xmlResult = createHrmsResultBlank( 0, null, null );
				// ... ����������� ������, ���������� � ���������� ������ 
				// ��������� ������ � �����������������:
				xmlResult.DocumentElement.ReplaceChild( 
					xmlResult.ImportNode( xmlData.DocumentElement, true ),
					xmlResult.SelectSingleNode( "Result/Data" ) );
			}
			catch( Exception err )
			{
				// ��������� ���������, ����������� ������: ������� Code ����� � (-1),
				// �������� Descr � Stack �������� �������� � ���� ������ ��������������:
				xmlResult = createHrmsResultBlank( -1, err.Message, err.StackTrace );
				/* ... ���� ������ ��� ���� - �����! */
			}
			return xmlResult;
		}
		/// <summary>
		/// HPOVSD. ����� ������� �������� ������� �� SD.
		/// </summary>
		/// <param name="sUserID">
		/// ������������� �������� � ��
		/// </param>
		/// <param name="sProjectID">
		/// ������������� ������� � ��
		/// </param>
		/// <param name="sDirectionID">
		/// ������������� ����������� � ��
		/// </param>
		/// <param name="iTimeLoss">
		/// ����������� �����(� �������)
		/// </param>
        /// <param name="sDescription">
        /// �������� ������
        /// </param>
        /// <param name="dtDateLoss">
        /// ����� �������� �� ������
        /// </param> 
        /// <param name="sOfferSDID">
        /// ������������� � SD
        /// </param>
        
		[WebMethod( Description="������� �������� ������� �� SD" )]
		public void HPOVSD_INTEROP_InsertTimeLossFromSD(
			string sUserID,
			string sProjectID,
			string sDirectionID,
			int iTimeLoss,
            string sDescription,
            DateTime dtDateLoss,
            string sOfferSDID)
		{
			// �������� ����������:
			//Guid uidUserID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sUserID, "�������������  (sUserID)" );
			Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sProjectID, "�������������  (sProjectID)");
			Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID( sDirectionID, "�������������  (sDirectionID)");
			// ���������� ���������:
			XParamsCollection paramsCollection = new XParamsCollection();
			paramsCollection.Add( "UserID", sUserID  );
			paramsCollection.Add( "ProjectID", uidProjectID );
			paramsCollection.Add( "DirectionID", uidDirectionID);
			paramsCollection.Add( "TimeLoss", iTimeLoss);
            paramsCollection.Add("DateLoss", dtDateLoss);
            if (!String.IsNullOrEmpty(sDescription))
            {
                paramsCollection.Add("Description", sDescription);
            }
            else
            {
                throw new ApplicationException("�� �������� ��������� ��������, �.�. �� ��������� �������� ������");
            }
            if (!String.IsNullOrEmpty(sOfferSDID))
            {
                paramsCollection.Add("ExternalID", sOfferSDID);
            }
            else
            {
                throw new ApplicationException("�� ������� ������������� � SD");
            }
			// �������� ���������, ����� "�������� ������":
			ObjectOperationHelper.ExecAppDataSourceScalar( "CommonService-InsertTimeLossFromSD", paramsCollection );
		}
		#endregion

        #region ������ �������������� �������  ��� ������������� �  "�������� ����� ��������" 


        /// <summary>
        /// ����� �������������� �������� ��������� ������� (� Incident Tracker) � ��������������� 
        /// ��������� �����
        /// </summary>
        /// <param name="enTenderState">��������� �������</param>
        /// <returns>��������������� ��������� �����</returns>
        private FolderStates getTender2FolderState(TenderFolderStates enTenderState)
        {
            FolderStates enFolderState;
            switch (enTenderState)
            {
                case TenderFolderStates.Open: enFolderState = FolderStates.Open; break;
                case TenderFolderStates.WaitingToClose: enFolderState = FolderStates.WaitingToClose; break;
                case TenderFolderStates.Closed: enFolderState = FolderStates.Closed; break;
                case TenderFolderStates.Frozen: enFolderState = FolderStates.Frozen; break;
                default:
                    throw new ArgumentException("����������� ��������� ������� (enTenderState)", "enTenderState");
            }
            return enFolderState;
        }

        /// <summary>
        /// ���������� ��������� ����� �������� ������ ����� (Folder) ���� 
        /// "������" , �� ��������� ��������������. 
        /// ��������� ������������ ������� ��������������, � ��� �� ��� �����.
        /// </summary>
        /// <param name="sTenderID">������������� �����-��������, � ������</param>
        /// <param name="arrPreloadProperties">
        /// ������ ������������ ������������ ����������, �.�. null
        /// </param>
        /// <param name="bIsStrictLoad">
        /// ������� "�������" �������� - ���� ��������� ������ �� ����� ������, �����
        /// ������������� ����������; ���� �������� ����� � false, � ������ �� ����� 
        /// ������, �� � ���. ���������� ����� ������ null;
        /// </param>
        /// <returns>
        /// ������������������ ������ - helper ��� null ���� ������ �� ������, 
        /// � ������� "�������" �������� (bIsStrictLoad) �������
        /// </returns>
        /// <exception cref="ArgumentNullException">���� sTenderID ���� null</exception>
        /// <exception cref="ArgumentException">���� sTenderID ���� ������ ������</exception>
        /// <exception cref="ArgumentException">���� ������� � ID sTenderID ��� � bIsStrictLoad=true</exception>
        /// <exception cref="ArgumentException">���� sTenderID ������ ����� - �� �������</exception>
        private ObjectOperationHelper loadTender(string sTenderID, bool bIsStrictLoad, string[] arrPreloadProperties)
        {
            // ��������� ������������ ������� ����������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sTenderID, "������������� ����������� (sTenderID)");

            // ��������� ������: � ����� ������ ����������� "������" ��������
            // ��� ���� ���������, ����������� ��� ���: ���������� ������� ������� 
            // �� �������� ����� bIsStrictLoad:
            ObjectOperationHelper helper = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            if (!helper.SafeLoadObject(null, arrPreloadProperties))
            {
                if (bIsStrictLoad)
                    throw new ArgumentException("������ � ��������� ��������������� (" + sTenderID + ") �� �������", "sPresaleID");
                else
                    return null;
            }

            // ���������, ��� ����������� ��������, �������������� �������� ���� 
            // "Folder" ���� ����������� - �������� �������� "����" �����:
            if (FolderTypeEnum.Tender != getFolderType(helper))
                throw new ArgumentException("�������� ������������� (sTenderID) �� �������� ��������������� �������");

            return helper;
        }

        /// <summary>
        /// ������� � ������� Incident Tracker �������� ������� (Tender)
        /// � ��������� �����������.
        /// </summary>
        /// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
        /// <param name="sCode">������ � ���������� ����� �������</param>
        /// <param name="sName">������ � ������������� �������</param>
        /// <param name="sNavisionID">������ � ����� ������� � Navision</param>
        /// <param name="enInitialState">��������� ��������� ������� �������</param>
        /// <param name="sDescription">������ � ������� �������� / �����������</param>
        /// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� ��������</param>
        /// <returns>������ � ��������������� ���������� �������� �������</returns>
        [WebMethod(Description = "������� � ������� Incident Tracker �������� ������� (Tender) � ��������� �����������")]
        public string CreateTender(
            string sCustomerID,
            string sCode,
            string sName,
            string sNavisionID,
            TenderFolderStates enInitialState,
            string sDescription,
            string sInitiatorEmployeeID)
        {
            // ��������� ������������ ������� ����������:
            ObjectOperationHelper.ValidateRequiredArgument(sCustomerID, "������������� ����������� - ������� (sCustomerID)", typeof(Guid));
            ObjectOperationHelper.ValidateRequiredArgument(sName, "������������ ������� (sName)");
            ObjectOperationHelper.ValidateRequiredArgument(sInitiatorEmployeeID, "������������� ����������-���������� �������� ������� (sInitiatorEmployeeID)", typeof(Guid));

            // ���������� ������������� ����� ����������� � �������� ����. 
            // �����, ��������� ����������� � ���� �������� ���������������:
            string sNewProjectID = Guid.NewGuid().ToString();
            CreateIdentifiedTender(sNewProjectID, sCustomerID, sCode, sName, sNavisionID, enInitialState, sDescription, sInitiatorEmployeeID);

            return sNewProjectID;
        }


        /// <summary>
        /// ������� � ������� Incident Tracker �������� ������� (Tender) 
        /// � ���������� ����������� � �������� ���������� ���������������.
        /// </summary>
        /// <param name="sNewTenderID">������ � ��������������� ��� ����������� �������</param>
        /// <param name="sCustomerID">������ � ��������������� ����������� - �������</param>
        /// <param name="sCode">������ � ����� �������</param>
        /// <param name="sName">������ � ������������� �������</param>
        /// <param name="sNavisionID">������ � ����� ������� � ����. Navision</param>
        /// <param name="enInitialState">��������� ��������� ������������ �������</param>
        /// <param name="sDescription">����� �������� (�����������) �������</param>
        /// <param name="sInitiatorEmployeeID">������ � ��������������� ���������� - ���������� �������</param>
        public void CreateIdentifiedTender(
            string sNewTenderID,
            string sCustomerID,
            string sCode,
            string sName,
            string sNavisionID,
            TenderFolderStates enInitialState,
            string sDescription,
            string sInitiatorEmployeeID)
        {
            // ��������� ������������ ������� ����������:
            Guid uidNewProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewTenderID, "���������� ������������� ������������ ������� (sNewTenderID)");
            ObjectOperationHelper.ValidateRequiredArgument(sName, "������������ ������� (sName)");
            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sCustomerID, "������������� ����������� - ������� (sCustomerID)");
            Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiatorEmployeeID, "������������� ���������� - ���������� �������� ����������� (sInitiatorEmployeeID)");

            // ��������� ��������: 
            // ������-�������: �������� �������� ��� ����-�� ��� ������ ������� 
            // ���������. �������������: ���������, ��� �������� ����������� �� ���� 
            // ����; ������������� ���������� �.�. ����� � ���������� ���������������� 
            // ����� �������� (�, �����. ����������� � ������� - ��������� ������������,
            // ServiceConfig)
            if (uidOrganizationID == ServiceConfig.Instance.OwnOrganization.ObjectID)
                throw new ArgumentException(
                    String.Format(
                        "�������� �������� ��� ����������� - ��������� ������� \"{0}\" ��� ������ ������ ������� " +
                        "���������. �������� ����� ������������ ������ ����������� ��������������� � ������� Incident " +
                        "Tracker, ������������� �������, ���������� ������������ ������������.",
                        ServiceConfig.Instance.OwnOrganization.GetPropValue("ShortName", XPropType.vt_string)
                    ), "sCustomerID");

            // �������� ������ ������� - �����������: ���������, � ����� �������� 
            // �������� ������������ ������������� ������� �� ��������:
            ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance("Folder");
            helperProject.LoadObject();
            helperProject.NewlySetObjectID = uidNewProjectID;

            // ������ �������� �����������, � �����. � ��������� ���������� ����������:
            // ... ����������� - ��� ����� � ����� "�������":
            helperProject.SetPropValue("Type", XPropType.vt_i2, FolderTypeEnum.Tender);
            // ... � ������ (��� �������� ������� ����� ������) - ��������� ��� ��������� 
            // ������ ��� "��������"; ������������� �����. Activity Type ����� �� ������������:
            helperProject.SetPropScalarRef(
                "ActivityType",
                ServiceConfig.Instance.TenderProjectsActivityType.TypeName,
                ServiceConfig.Instance.TenderProjectsActivityType.ObjectID);

            // ... ������ ��� �������, ��������� �����������:
            //if (!String.IsNullOrEmpty(sCode))
            //    helperProject.SetPropValue("ProjectCode", XPropType.vt_string, sCode);
            helperProject.SetPropValue("Name", XPropType.vt_string, sName);
            // ... ������������� ������� � Navision ��� �������� �� �������� ������������;
            // � ���. �������� ����� ���� ����� null ��� ������ ������ - ������ ��� 
            // � ������ ������ - ��� ������ � �� ����� NULL:
            helperProject.SetPropValue("ExternalID", XPropType.vt_string, (null == sNavisionID ? String.Empty : sNavisionID));
            // ... ������ ������� ��� �������� ��������� ����: 
            helperProject.SetPropValue("State", XPropType.vt_i2, (Int16)getTender2FolderState(enInitialState));

            // ����������� ������:
            // ...�� ���������� - ���������� ������� 
            helperProject.SetPropScalarRef("Initiator", "Employee", uidInitEmployeeID);
            // ...�� �����������:
            helperProject.SetPropScalarRef("Customer", "Organization", uidOrganizationID);

            // ���������� ����� ������:
            helperProject.SaveObject();
        }

        /// <summary>
        /// ��������� ���������� �������� ���������� ������� (Tender) � ������� Incident Tracker.
        /// </summary>
        /// <param name="sTenderID">��������� ������������� �������������� �������� �������</param>
        /// <param name="sNewCustomerID">��������� ������������� �������������� ����������� - �������</param>
        /// <param name="sNewCode">������ � ����� ����� �����������</param>
        /// <param name="sNewName">������ � ����� ������������� �����������</param>
        /// <param name="sNewNavisionID">������ � ����� ����� ����������� � Navision</param>
        /// <returns>
        /// -- True - ���� ��������� ����������� ������� � ������� ���������;
        /// -- False - ���� ��������� ����������� �� �������.
        /// </returns>
        /// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
        [WebMethod(Description = "��������� ���������� �������� ��������� ����������� � ������� Incident Tracker")]
        public bool UpdateTender(
            string sTenderID,
            string sNewCustomerID,
            string sNewCode,
            string sNewName,
            string sNewNavisionID)
        {
            // ��������� ��������
            ObjectOperationHelper.ValidateRequiredArgument(sNewName, "������������ ������� (sName)");
            Guid uidNewCustomerOrgID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewCustomerID, "������������� ����������� - ������� (sCustomerID)");

            // ��������� ��������� �����������: ���������� ����� ��������� ������������ ���������
            ObjectOperationHelper helperTender = loadTender(sTenderID, false, null);
            // ... ���� ������ �� ������ - ������ ������ false:
            if (null == helperTender)
                return false;

            // �������� �������� ������ �����������:
            //if (!String.IsNullOrEmpty(sNewCode))
            //    helperTender.SetPropValue("ProjectCode", XPropType.vt_string, sNewCode);
            helperTender.SetPropValue("Name", XPropType.vt_string, sNewName);
            // ������������� ������� � Navision ��� �������� �� �������� ������������;
            // ������� � ���. ���������� �������� ��������� ����������� � null, � ������
            // ������; null �������� � ������ ������ - ��� ������ � �� ����� NULL:
            helperTender.SetPropValue("ExternalID", XPropType.vt_string, (null == sNewNavisionID ? String.Empty : sNewNavisionID));

            // ������������ ����������� �������: ��������, ����� ����������� ������� ������:
            ObjectOperationHelper helperOrg = helperTender.GetInstanceFromPropScalarRef("Customer");
            // ...�������� �������� ������ ���� ��� ������������� ����������:
            if (helperOrg.ObjectID != uidNewCustomerOrgID)
                helperTender.SetPropScalarRef("Customer", "Organization", uidNewCustomerOrgID);

            // ������� � ���������� ��� ��������, ������� ����� �� ����������:
            helperTender.DropPropertiesXml(new string[] { "ActivityType", "Type", "State", "Parent", "IsLocked" });
            // ���������� ���������� ������:
            helperTender.SaveObject();

            return true;
        }
        /// <summary>
        /// ������� �������� ���������� ������� �� ������� Incident Tracker
        /// </summary>
        /// <param name="sTenderID">��������� ������������� �������������� ���������� �������</param>
        ///	<exception cref="ArgumentNullException">���� sTenderID ����� � null</exception>
        ///	<exception cref="ArgumentException">���� sTenderID ����� � String.Empty</exception>
        [WebMethod(Description = "������� �������� ��������� ����������� �� ������� Incident Tracker")]
        public void DeleteTender(string sTenderID)
        {
            // ��������� ������������ ����������:
            Guid uidProjectID = ObjectOperationHelper.ValidateRequiredArgumentAsID(
                sTenderID, "������������� ��������� ����������� (sPresaleID)");

            // �������� �������:
            ObjectOperationHelper helperProject = ObjectOperationHelper.GetInstance("Folder", uidProjectID);
            helperProject.DeleteObject();
        }

   	
        #endregion

		#region ����������� �������������� � �������� CRM
        private enum ActivityFolderContainDirection
        {
            /// <summary>
            /// ���� �� ������� ����������� �� ������� ������ �������� ������ �����������
            /// </summary>
            ParentActivityContainOtherDirection,
            /// <summary>
            /// ������� ���������� �������� ���������� ����������� �����������
            /// </summary>
            ParentActivityContainDirection,
            /// <summary>
            /// �� ���� ������� ���������� �� �������� �����������
            /// </summary>
            ParentActivityDontContainThisDirection,
            /// <summary>
            /// C������ ���������� �� �������� �� ������ �����������
            /// </summary>
            ParentActivityDontContainAnyDirection,
        }

        /// <summary>
        /// ��������� ����������� � ������� ����������
        /// </summary>
        /// <param name="helperActivity">������ - ����������, ��� ������������ ���������� ��������� �� ������������ �����������</param>
        /// <param name="uidDirection">Guid �����������</param>
        /// <returns>
        /// ���������� ��������� ����������� ��� ������� ����������
        /// </returns>
        private ActivityFolderContainDirection CheckActivityFolderContainDirection(
            ObjectOperationHelper helperActivity,
            Guid uidDirection
            )
        {
            // ������� ������� ����������
            ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
            // ���� ���� ����������� ����������, �� ����������� ����� ���� ������ 1
            bool bExistParentActivity = (null != helperParentActivity);
            if (bExistParentActivity)
            {
                helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });
            }
            // ������ ����� ������������ ����������
            bool bExistDirection = false;
            foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
            {
                if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(uidDirection.ToString(), StringComparison.InvariantCultureIgnoreCase))
                {
                    // ���� ���� �� ����������� ���������� ��������� � ���������� ������������, ���������� ��������, ��� 
                    // ����� ����������� � ���������� ����������
                    return ActivityFolderContainDirection.ParentActivityContainDirection;
                }
                else if (bExistParentActivity) 
                {
                    //���� ����������� �� ��������� � � ���������� ���� ������������ ����������, �� ��� ��� � ������� ���������� 
                    // ����� ���� ����� ���� �����������, ���������� �������� �� ���������� �����������
                    return ActivityFolderContainDirection.ParentActivityContainOtherDirection;
                }
                bExistDirection = true;
            }
            // ���� ���������� ������������ ����������, � �� ���� �� ������������ � ������������� �������������, �� ������������ 
            // �������� � � ������������ �����������.
            if (bExistParentActivity)
                return CheckActivityFolderContainDirection(helperParentActivity, uidDirection);
            else
            {
                if (bExistDirection)
                    return ActivityFolderContainDirection.ParentActivityDontContainThisDirection;
                else
                    return ActivityFolderContainDirection.ParentActivityDontContainAnyDirection;
            }
        }

        /// <summary>
        /// ���������� ������������ ���������� 1-��� ������
        /// </summary>
        /// <param name="helperActivity">������ - ����������, ��� ������������ ���������� ����</param>        
        /// <returns>
        /// ���������� Guid ������� ����������
        /// </returns>
        private Guid GetFirstLevelParentActivity(
            ObjectOperationHelper helperActivity
            )
        {
            // ������� ������� ����������
            ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
            // ��������� ���� �� ������� ����������
            bool bExistParentActivity = (null != helperParentActivity);
            if (bExistParentActivity)
            {
                helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });

            }

            // ���� ���������� ������������ ����������, � �� ���� �� ������������ � ������������� �������������, �� ������������ 
            // �������� � � ������������ �����������.
            if (bExistParentActivity)
                return GetFirstLevelParentActivity(helperParentActivity);
            else
            {
                return helperActivity.ObjectID;
            }
        }

        /// <summary>
        /// ���������� ������ ����������� ����������
        /// </summary>
        /// <param name="helperActivity">������ - ����������, ��� ����������� ����������</param>        
        /// <returns>
        /// ���������� ������ ����������� ����������
        /// </returns>
        private ProjectDirection[] GetFirstLevelParentActivityDirections(
            String sActivityID
            )
        {
            // ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
            ObjectOperationHelper helperActivity = loadActivity(sActivityID, false, new string[] { "FolderDirections" });
            // ... ���� ������ �� ������ - ������ ������ false:
            if (null == helperActivity)
                throw new ArgumentException("���������� ���������� �� ������������ � ������� Incident Tracker");

            ProjectDirection[] ActivityDirections = new ProjectDirection[helperActivity.PropertyXml("FolderDirections").ChildNodes.Count + 1];
            int index = 0;
            foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
            {
                ActivityDirections[index] = new ProjectDirection();
                ActivityDirections[index].DirectionID = ((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").ToString();
                ActivityDirections[index].ExpenseRatio = int.Parse(((XmlElement)xmlFolderDirection.SelectSingleNode("ExpenseRatio")).InnerText.ToString());
                index++;
            }
            return ActivityDirections;
        }

		/// <summary>
		/// ����� ������� ������ ���� �������� � ������� ITracker
		/// </summary>
		/// <param name="sName">��������, ������������</param>
		/// <param name="sDescr">��������</param>
		/// <param name="sSolution">�������</param>
		/// <param name="nPriority">��������� (1, 2, 3), ������������</param>
		/// <param name="dtDeadLine">������� ����, ������������</param>
		/// <param name="sFolder">�����, GUID, ������������</param>
		/// <param name="sType">��� ���������, GUID, ������������</param>
		/// <param name="sInitiator">���������, GUID, ������������</param>
		/// <returns>Xml ���������� ����
		/// <Result>
		/// <Status><Code>0, ���� ��� ������ ��� -1</Code><Descr>�������� ������</Descr><Stack>���������</Stack></Status>
		/// <Data><IncidentNumber>����� ���������</IncidentNumber><IncidentGUID>������������� ��������� � �������</IncidentGUID></Data>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "����� ������� ������ ���� �������� � ������� ITracker")]
		public XmlDocument CreateIncident(
			String sName,
			String sDescr,
			String sSolution,
			Int32 nPriority,
			DateTime? dtDeadLine,
			String sFolder,
			String sType,
			String sInitiator
			)
		{
			try
			{
				// �������� �������� ����������
				ObjectOperationHelper.ValidateRequiredArgument(sName, "sName");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sFolder, "sFolder");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sType, "sType");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiator, "sInitiator");

				if (nPriority < 1 || nPriority > 3)
					throw new ArgumentOutOfRangeException("nPriority", "�������� ��������� nPriority ������ ��������� ���� �� ��������: 1, 2 ��� 3");

				ObjectOperationHelper employeeHelper = ObjectOperationHelper.GetInstance("Employee", new Guid(sInitiator));
				employeeHelper.LoadObject();

				// ��������� ������ ������ ���������
				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				incidentHelper.LoadObject();

				incidentHelper.SetPropValue("Name", XPropType.vt_string, sName);

				incidentHelper.SetPropValue("Descr", XPropType.vt_text,
					!string.IsNullOrEmpty(sDescr)
					? string.Format(
						"{0}\n[{1} {2}, {3}]",
						sDescr,
						employeeHelper.GetPropValue("LastName", XPropType.vt_string),
						employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
						DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
					: sDescr
					);

				incidentHelper.SetPropValue("Solution", XPropType.vt_text,
					!string.IsNullOrEmpty(sSolution)
					? string.Format(
						"{0}\n[{1} {2}, {3}]",
						sSolution,
						employeeHelper.GetPropValue("LastName", XPropType.vt_string),
						employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
						DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
					: sSolution
					);

				incidentHelper.SetPropValue("Priority", XPropType.vt_i2, nPriority);

				incidentHelper.SetPropValue("DeadLine", XPropType.vt_date, dtDeadLine);

				incidentHelper.SetPropScalarRef("Folder", "Folder", new Guid(sFolder));

				incidentHelper.SetPropScalarRef("Type", "IncidentType", new Guid(sType));

				ObjectOperationHelper systemUserHelper = employeeHelper.GetInstanceFromPropScalarRef("SystemUser");

				incidentHelper.SetPropScalarRef("Initiator", "SystemUser", systemUserHelper.ObjectID);

				ObjectOperationHelper incidentStateHelper = ObjectOperationHelper.GetInstance("IncidentState");
				XParamsCollection incidentStateParams = new XParamsCollection();
				incidentStateParams.Add("IsStartState", 1);
				incidentStateParams.Add("IncidentType", new Guid(sType));

				incidentStateHelper.LoadObject(incidentStateParams);

				incidentHelper.SetPropScalarRef("State", "IncidentState", incidentStateHelper.ObjectID);

				// ��������� ��������
				incidentHelper.SaveObject();

				// ���������� ��������, ����� �������� ��� �����
				incidentHelper.LoadObject();

				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				doc.LoadXml(
					string.Format(
						"<Result><Status><Code>0</Code><Descr/><Stack/></Status><Data><IncidentNumber>{0}</IncidentNumber><IncidentGUID>{1}</IncidentGUID></Data></Result>",
						incidentHelper.GetPropValue("Number", XPropType.vt_i4),
						incidentHelper.ObjectID
						));

				return doc;
			}
			catch (Exception e)
			{
				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
				((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
				XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
				data.AppendChild(doc.CreateElement("IncidentNumber"));
				data.AppendChild(doc.CreateElement("IncidentGUID"));

				return doc;
			}
		}

		/// <summary>
		/// ��������� ������������ ��������� � ������� ITracker
		/// </summary>
		/// <param name="nIncidentNumber">����� ���������, ������������</param>
		/// <param name="sTagretFolder">����� �����, ������������</param>
		/// <returns>Xml ���������� ����
		/// <Result>
		/// <Code>0, ���� ��� ������ ��� -1</Code><Descr>�������� ������</Descr><Stack>���������</Stack>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "��������� ������������ ��������� � ������� ITracker")]
		public XmlDocument MoveIncident(
			Int32 nIncidentNumber,
			String sTagretFolder
		)
		{
			try
			{
				// �������� �������� ����������
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sTagretFolder, "sTagretFolder");

				// ������� �������� �� ��� ������
				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				XParamsCollection incidentParams = new XParamsCollection();
				incidentParams.Add("Number", nIncidentNumber);
				incidentHelper.LoadObject(incidentParams);

				// ������� ������ �� ����� � ��������
				incidentHelper.SetPropScalarRef("Folder", "Folder", new Guid(sTagretFolder));
				incidentHelper.DropPropertiesXmlExcept("Folder");
				incidentHelper.SaveObject();

				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				doc.LoadXml("<Result><Code>0</Code><Descr/><Stack/></Result>");
				return doc;
			}
			catch (Exception e)
			{
				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				((XmlElement)result.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)result.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)result.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;

				return doc;
			}
		}

		/// <summary>
		/// ���������� ������� ���������� � ��������� ���������
		/// </summary>
		/// <param name="nIncidentNumber">����� ���������, ������������</param>
		/// <param name="sInitiator">�����������, GUID, ������������</param>
		/// <param name="sWorker">�����������, GUID, ������������</param>
		/// <param name="sRole">����, GUID, ������������</param>
		/// <param name="nPlannedTime">����������� ����� � �������</param>
		/// <returns>Xml ���������� ����
		/// <Result>
		/// <Code>0, ���� ��� ������ ��� -1</Code><Descr>�������� ������</Descr><Stack>���������</Stack>
		/// </Result>
		/// </returns>
		[WebMethod(Description = "���������� ������� ���������� � ��������� ���������")]
		public XmlDocument CreateTask (
			Int32 nIncidentNumber,
			String sInitiator,
			String sWorker,
			String sRole,
			Int32? nPlannedTime
		)
		{
			try
			{
				// �������� �������� ����������
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiator, "sInitiator");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sWorker, "sWorker");
				ObjectOperationHelper.ValidateRequiredArgumentAsID(sRole, "sRole");

				ObjectOperationHelper incidentHelper = ObjectOperationHelper.GetInstance("Incident");
				XParamsCollection incidentParams = new XParamsCollection();
				incidentParams.Add("Number", nIncidentNumber);
				incidentHelper.LoadObject(incidentParams);

				ObjectOperationHelper roleHelper = ObjectOperationHelper.GetInstance("UserRoleInIncident", new Guid(sRole));
				roleHelper.LoadObject();

				// ��������� �������
				ObjectOperationHelper taskHelper = ObjectOperationHelper.GetInstance("Task");
				taskHelper.LoadObject();

				taskHelper.SetPropScalarRef("Incident", "Incident", incidentHelper.ObjectID);

				taskHelper.SetPropScalarRef("Planner", "Employee", new Guid(sInitiator));

				taskHelper.SetPropScalarRef("Worker", "Employee", new Guid(sWorker));

				taskHelper.SetPropScalarRef("Role", "Employee", roleHelper.ObjectID);

				taskHelper.SetPropValue("PlannedTime", XPropType.vt_i4, nPlannedTime.HasValue ? nPlannedTime : roleHelper.GetPropValue("DefDuration", XPropType.vt_i4));

                taskHelper.SetPropValue("LeftTime", XPropType.vt_i4, nPlannedTime.HasValue ? nPlannedTime : roleHelper.GetPropValue("DefDuration", XPropType.vt_i4));

				// ���������
				taskHelper.SaveObject();

				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				doc.LoadXml("<Result><Code>0</Code><Descr/><Stack/></Result>");
				return doc;
			}
			catch (Exception e)
			{
				// ��������� ��������� �� ������
				XmlDocument doc = new XmlDocument();
				XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
				((XmlElement)result.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
				((XmlElement)result.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
				((XmlElement)result.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;

				return doc;
			}
        }

        /// <summary>
        /// ����� ���������� ������ �����������, ����������� � ���������� ����������� 
        /// </summary>
        /// <param name="sOrganizationID">������ � ��������� �������������� �������� �����������</param>
        /// <param name="bIncludeSubActivity">�������, ������������ ����� �� �������� � ��������� ����������� ����������</param>
        /// <param name="sActivityType">������ � ��������� �������������� ���� ����������</param>
        /// <param name="nActivityState">����� � ��������� "���������" �����������, ������� ����� �������� � ���������</param>
        /// <returns>Xml ���������� ����
        /// <Result>
        /// <Status>
        ///     <Code>0, ���� ��� ������ ��� -1</Code>
        ///     <Descr>�������� ������</Descr>
        ///     <Stack>���������</Stack>
        /// </Status>
        /// <Data>
        ///     <ActivityGUID>������������� ����������</ActivityGUID>
        ///     <ActivityName>������������ ����������</ActivityName>
        ///     <ActivityType>������������� ���� ����������</ActivityType>
        ///     <ActivityFolderType>��� �����</ActivityFolderType>
        ///     <ActivityParent>������������� ����������� ����������</ActivityParent>
        /// </Data>
        /// </Result>
        /// </returns>
        [WebMethod(Description = "����� ���������� ������ �����������, ����������� � ���������� �����������")]
        public XmlDocument GetActivityList(
            String sOrganizationID,
            String sActivityID,
            String sActivityType,
            Int32 nActivityState
            )
        {
            try
            {

                // ��������� ������������ ������� ����������:
                sOrganizationID = (String.Empty == sOrganizationID ? null : sOrganizationID);
                sActivityID = (String.Empty == sActivityID ? null : sActivityID);
                ObjectOperationHelper.ValidateOptionalArgument(sOrganizationID, "������������� ����������� (sOrganizationID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sActivityID, "������������� ���������� (sActivityID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sActivityType, "������������� ���� ���������� (sActivityType)", typeof(Guid));

                // ������� ������� ������ ���������� �������:
                XParamsCollection paramsCollection = new XParamsCollection();
                paramsCollection.Add("OrganizationID", sOrganizationID);
                paramsCollection.Add("ActivityID", sActivityID);
                paramsCollection.Add("ActivityType", sActivityType);
                paramsCollection.Add("ActivityState", (Int16)nActivityState);
                DataTable oDataTable = ObjectOperationHelper.ExecAppDataSource("CommonService-GetOrganizationActivity", paramsCollection);

                if (null == oDataTable)
                    // ������ ��������� �� ������
                    throw new ArgumentException("����������� �� �������");

                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "0";
                status.AppendChild(doc.CreateElement("Descr"));
                status.AppendChild(doc.CreateElement("Stack"));
                for (int nRowIndex = 0; nRowIndex < oDataTable.Rows.Count; nRowIndex++)
                {
                    XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityOrganization"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityOrganization"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityID"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityID"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityName"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityName"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityType"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityType"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityFolderType"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityFolderType"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityParent"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityParent"].ToString();
                    ((XmlElement)data.AppendChild(doc.CreateElement("ActivityState"))).InnerText = oDataTable.Rows[nRowIndex]["ActivityState"].ToString();
                }
                return doc;
            }
            catch (Exception e)
            {
                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                XmlElement data = (XmlElement)result.AppendChild(doc.CreateElement("Data"));
                data.AppendChild(doc.CreateElement("ActivityOrganization"));
                data.AppendChild(doc.CreateElement("ActivityID"));
                data.AppendChild(doc.CreateElement("ActivityName"));
                data.AppendChild(doc.CreateElement("ActivityType"));
                data.AppendChild(doc.CreateElement("ActivityFolderType"));
                data.AppendChild(doc.CreateElement("ActivityParent"));
                data.AppendChild(doc.CreateElement("ActivityState"));

                return doc;
            }
        }

        /// <summary>
        /// ������� � ������� Incident Tracker �������� ���������� � ��������� �����������
        /// </summary>
        /// <param name="sOrganizationID">������ � ��������������� ����������� - �������</param>
        /// <param name="sName">������ � ������������� ����������</param>
        /// <param name="sDescription">������ � ��������� ����������</param>
        /// <param name="sNavisionID">������ � ����� ������� � Navision</param>
        /// <param name="sActivityType">������ � ��������������� ���� ����������</param>
        /// <param name="nFolderType">����� � ��������� "���� �����" ���������� ����������</param>
        /// <param name="nActivityState">����� � ��������� ��������� ����������</param>
        /// <param name="sParentActivityID">������ � ��������������� ������� ����������</param>
        /// <param name="sDefaultIncidentType">������ � ��������������� ���� ��������� �� ��������� � ����������� ����������</param>
        /// <param name="bIsLocked">������� ����������� ��������� �� ����������� �������� ������� �� ����������</param>
        /// <param name="sInitiatorID">������ � ��������������� ���������� - ���������� ����������</param>
        /// <returns>������ � ��������������� ��������� ����������</returns>
        [WebMethod(Description = "������� � ������� Incident Tracker �������� ������� � ��������� �����������")]
        public XmlDocument CreateActivity(
            String sOrganizationID,
            String sName,
            String sDescription,
            String sNavisionID,
            String sActivityType,
            Int32 nFolderType,
            Int32 nActivityState,
            String sParentActivityID,
            String sDefaultIncidentType,
            Boolean bIsLocked,
            String sInitiatorID)
        {
            try
            {
                // ��������� ������������ ������� ����������:
                sParentActivityID = (String.Empty == sParentActivityID ? null : sParentActivityID);
                sDefaultIncidentType = (String.Empty == sDefaultIncidentType ? null : sDefaultIncidentType);
                ObjectOperationHelper.ValidateRequiredArgument(sOrganizationID, "������������� ����������� - ������� (sOrganizationID)", typeof(Guid));
                ObjectOperationHelper.ValidateRequiredArgument(sName, "������������ ������� (sName)");
                ObjectOperationHelper.ValidateRequiredArgument(sActivityType, "������������� ���� ���������� (sActivityType)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sParentActivityID, "������������� ������� ���������� (sParentActivityID)", typeof(Guid));
                ObjectOperationHelper.ValidateOptionalArgument(sDefaultIncidentType, "������������� ���� ��������� (sDefaultIncidentType)", typeof(Guid));
                ObjectOperationHelper.ValidateRequiredArgument(sInitiatorID, "������������� ���������� - ���������� �������� ������� (sInitiatorEmployeeID)", typeof(Guid));

                // ����� - ���������� ������������� ����� ����������, � �������� ����. 
                // �����, ��������� ���������� � ���� �������� ���������������:
                string sNewActivityID = Guid.NewGuid().ToString();
                CreateIdentifiedActivity(
                    sNewActivityID,
                    sOrganizationID,
                    sName,
                    sDescription,
                    sNavisionID,
                    sActivityType,
                    nFolderType,
                    nActivityState,
                    sParentActivityID,
                    sDefaultIncidentType,
                    bIsLocked,
                    sInitiatorID);

                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                doc.LoadXml(
                    string.Format(
                    "<Result><Status><Code>0</Code><Descr/><Stack/></Status><Data><ActivityOrganization>{0}</ActivityOrganization></Data></Result>",
                    sNewActivityID
                    ));
                return doc;
            }
            catch (Exception e)
            {
                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                return doc;
            }
        }


        /// <summary>
        /// ������� � ������� Incident Tracker �������� ���������� � ��������� ����������� 
        /// � ������� ��������� ���������� ���������������
        /// </summary>
        /// <param name="sNewActivityID">������ � ��������������� ����������� ����������</param>
        /// <param name="sOrganizationID">������ � ��������������� ����������� - �������</param>
        /// <param name="sName">������ � ������������� ����������</param>
        /// <param name="sDescription">������ � ��������� ����������</param>
        /// <param name="sNavisionID">������ � ����� ������� � Navision</param>
        /// <param name="sActivityType">������ � ��������������� ���� ����������</param>
        /// <param name="nFolderType">����� � ��������� "���� �����" ���������� ����������</param>
        /// <param name="nActivityState">����� � ��������� ��������� ����������</param>
        /// <param name="sParentActivityID">������ � ��������������� ������� ����������</param>
        /// <param name="sDefaultIncidentType">������ � ��������������� ���� ��������� �� ��������� � ����������� ����������</param>
        /// <param name="bIsLocked">������� ����������� ��������� �� ����������� �������� ������� �� ����������</param>
        /// <param name="sInitiatorID">������ � ��������������� ���������� - ���������� ����������</param>
        [WebMethod(Description = "������� � ������� Incident Tracker �������� ���������� � ��������� ����������� � ������� ��������� ���������� ���������������")]
        public void CreateIdentifiedActivity(
            String sNewActivityID,
            String sOrganizationID,
            String sName,
            String sDescription,
            String sNavisionID,
            String sActivityType,
            Int32 nFolderType,
            Int32 nActivityState,
            String sParentActivityID,
            String sDefaultIncidentType,
            Boolean bIsLocked,
            String sInitiatorID)
        {
            // ��������� ������������ ������� ����������:
            Guid uidNewActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sNewActivityID, "���������� ������������� ����������� ���������� (sNewActivityID)");
            ObjectOperationHelper.ValidateRequiredArgument(sName, "������������ ������� (sName)");

            Guid uidOrganizationID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sOrganizationID, "������������� ����������� (sOrganizationID)");
            Guid uidInitEmployeeID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sInitiatorID, "������������� ���������� - ���������� �������� ���������� (sInitiatorID)");
            Guid uidActivityType = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityType, "������������� ���� ���������� (sActivityType)");
            ObjectOperationHelper.ValidateOptionalArgument(sDefaultIncidentType, "������������� ���� ��������� (sDefaultIncidentType)", typeof(Guid));
            ObjectOperationHelper.ValidateOptionalArgument(sParentActivityID, "������������� ������� ���������� (sParentActivityID)", typeof(Guid));

            // �������� ������ ������� - ������� - ���������, � ����� �������� 
            // ������������ ������������� �� ��������:
            ObjectOperationHelper helperActivity = ObjectOperationHelper.GetInstance("Folder");
            helperActivity.LoadObject();
            helperActivity.NewlySetObjectID = uidNewActivityID;

            // ������ �������� �������, � �����. � ��������� ���������� ����������:
            // ... ������ - ��� ����� � ����� "������":
            helperActivity.SetPropValue("Type", XPropType.vt_i2, (Int16)nFolderType);

            // ... ������ ��� ���������� �������: 
            helperActivity.SetPropValue("Name", XPropType.vt_string, sName);

            // ... ������ �������� � ��������� ���� ����������
            ObjectOperationHelper employeeHelper = ObjectOperationHelper.GetInstance("Employee", uidInitEmployeeID);
            employeeHelper.LoadObject();

            helperActivity.SetPropValue("Description", XPropType.vt_string,
                !string.IsNullOrEmpty(sDescription)
                ? string.Format(
                    "{0}\n[{1} {2}, {3}]",
                    sDescription,
                    employeeHelper.GetPropValue("LastName", XPropType.vt_string),
                    employeeHelper.GetPropValue("FirstName", XPropType.vt_string),
                    DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"))
                : sDescription
                );
            helperActivity.SetPropValue("IsLocked", XPropType.vt_boolean, bIsLocked);
            // ... ������������� ������� � Navision ��� �������� �� �������� ������������;
            // � ���. �������� ����� ���� ����� null ��� ������ ������ - ������ ��� 
            // � ������ ������ - ��� ������ � �� ����� NULL:
            helperActivity.SetPropValue("ExternalID", XPropType.vt_string, (null == sNavisionID ? String.Empty : sNavisionID));
            // ... ������ ���������� ��� �������� ��������� ����: 
            helperActivity.SetPropValue("State", XPropType.vt_i2, (Int16)nActivityState);

            // ����������� ������:
            // ...�� ���������� - ���������� ������� 
            helperActivity.SetPropScalarRef("Initiator", "Employee", uidInitEmployeeID);
            // ...�� �����������:
            helperActivity.SetPropScalarRef("Customer", "Organization", uidOrganizationID);
            // ...�� ��� ����������
            helperActivity.SetPropScalarRef("ActivityType", "ActivityType", uidActivityType);


            // ...�� ������� ������ (���� ������� �����):
            if (null != sParentActivityID)
                helperActivity.SetPropScalarRef(
                    "Parent", "Folder",
                    ObjectOperationHelper.ValidateRequiredArgumentAsID(sParentActivityID, "������������� ������� ���������� (sParentActivityID)")
                );
            // ...�� ��� ��������� �� ��������� (���� ������� �����):
            if (null != sDefaultIncidentType)
                helperActivity.SetPropScalarRef(
                    "DefaultIncidentType", "IncidentType",
                    ObjectOperationHelper.ValidateRequiredArgumentAsID(sDefaultIncidentType, "��� ��������� �� ��������� (sDefaultIncidentType)")
                );

            // ���������� ����� ������:
            helperActivity.SaveObject();
        }

        /// <summary>
        /// �������� ������ � ����������� ��������� ���������� � ��������� �������������.
        /// </summary>
        /// <param name="sProjectID">
        /// ��������� ������������� �������������� ����������� �������� ����������. 
        /// ������� �������� ��-�� ������������. 
        /// </param>
        /// <param name="ProjectDirections">
        /// ������ ������� ProjectDirection, � ������� ���������� ���������� �� ������������ 
        /// ����������� � �����������. 
        /// ��� ����� �������� ����������� ��� ���������� ����� ��������. � �������� 
        /// �������� ����� ���� ����� ������ ������ - � ���� ������ ��� �����������
        /// ��� ��������� ���������� ����������.
        /// ���������� ����������� ������ ���� ������������ � ������� Incident Tracker.
        /// </param>
        /// <returns>
        /// -- True - ���� ��������� ���������� ������� � ������� ���������;
        /// -- False - ���� ��������� ���������� �� �������
        /// </returns>
        /// <exception cref="ArgumentException">��� ������������ ��������� ����������</exception>
        [WebMethod(Description = "�������� ������ � ����������� ��������� ���������� � ��������� �������������")]
        public XmlDocument UpdateActivityDirectionsAndExpenseRatio(
            String sActivityID,
            ProjectDirection[] ActivityDirections)
        {
            try
            {
                // �������� ���������� ��������:
                Guid uidActivityID = ObjectOperationHelper.ValidateRequiredArgumentAsID(sActivityID, "������������� ���������� (sActivityID)");
                // ...������ �������� - ������������ ������, ���� ������ ������� ������� ����� null:
                if (null == ActivityDirections)
                    ActivityDirections = new ProjectDirection[0];


                // #1:
                // ��������� ��������� ������: ���������� ����� ��������� ������������ ���������
                ObjectOperationHelper helperActivity = loadActivity(sActivityID, false, new string[] { "FolderDirections" });
                // ... ���� ������ �� ������ - ������ ������ false:
                if (null == helperActivity)
                    throw new ArgumentException("���������� ���������� �� ������������ � ������� Incident Tracker");

                // ������� ������� ����������
                ObjectOperationHelper helperParentActivity = helperActivity.GetInstanceFromPropScalarRef("Parent", false);
                // ���� ���� ����������� ����������, �� ����������� ����� ���� ������ 1
                bool bExistParentActivity = (null != helperParentActivity);
                if (bExistParentActivity)
                {
                    helperParentActivity.LoadObject(new string[] { "FolderDirections" });
                    helperParentActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections", "Parent" });

                }

                // � ����������, ������� ������������ ���������� ����� ���� ������ ���� �����������
                if ((ActivityDirections.Length > 1) && bExistParentActivity)
                    throw new ArgumentException("����������� ���������� ����� ����� ������ ���� �����������");

                // ����� ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections,
                // ��� ��������� ������ � XML ���������� � ������ �������� ����
                helperActivity.DropPropertiesXmlExcept(new string[] { "FolderDirections" , "Parent" });

                // ����� ���� ���������� ��������� ��������������
                int nTotalPercentage = 0;

                // #2:
                // ����� ���������� � ����������� ����������� ��� ������ ����. ���������� 
                // ������� FolderDirection, ������� ����� ������ �������� ���� ������
                // �� �����������. 
                //
                // ��� ������� ��������� ����������� �������� ��������� ������ ������ 
                // FolderDirection; ����� �� ����� ������� ��, ������� � ���������������
                // �������� ����������� - ��������� ����� ��������. ��� ���� � ������� 
                // ������� �� ���� ������� ������ - � ��������� ����� �������� ������ 
                // ������ �������; ��� ������ � ����� �������, ������ ��� ��� ������� 
                // ����� ������� ����������� ���������� (��. ����� #4)
                ObjectOperationHelper[] arrHelpers = new ObjectOperationHelper[ActivityDirections.Length + 1];
                for (int nIndex = 0; nIndex < ActivityDirections.Length; nIndex++)
                {
                    // ��������� ������������� ��������� �����������
                    Guid uidDirectionID = ObjectOperationHelper.ValidateRequiredArgumentAsID(ActivityDirections[nIndex].DirectionID, String.Format("������������� ����������� ProjectDirections[{0}].DirectionID", nIndex));

                    // ��������� ������� ��������� �����������.
                    int nPercentage;
                    if (bExistParentActivity)
                        nPercentage = 100;
                    else
                        nPercentage = ObjectOperationHelper.ValidateRequiredArgumentAsPercentage(ActivityDirections[nIndex].ExpenseRatio, String.Format("������� ������������� ������ �� ����������� ProjectDirections[{0}].Percentage", nIndex));

                    if (bExistParentActivity)
                    {
                        ProjectDirection[] ParentActivityDirection;
                        XmlDocument ParentUpdateResult = new XmlDocument();
                        XmlNode ParentResultCode;
                        switch (CheckActivityFolderContainDirection(helperParentActivity, uidDirectionID))
                        {
                            case ActivityFolderContainDirection.ParentActivityContainDirection:
                                break;
                            case ActivityFolderContainDirection.ParentActivityContainOtherDirection:
                                throw new ArgumentException("��������� ��������� ����������� �������� �� ����������� ����������� ����������.");
                                break;
                            case ActivityFolderContainDirection.ParentActivityDontContainAnyDirection:
                                ParentActivityDirection = new ProjectDirection[1];
                                ParentActivityDirection[0] = new ProjectDirection();
                                ParentActivityDirection[0].DirectionID = ActivityDirections[nIndex].DirectionID;
                                ParentActivityDirection[0].ExpenseRatio = 100;
                                ParentUpdateResult = UpdateActivityDirectionsAndExpenseRatio(GetFirstLevelParentActivity(helperActivity).ToString(), ParentActivityDirection);
                                ParentResultCode = ParentUpdateResult.DocumentElement;
                                if (((XmlElement)ParentResultCode.SelectSingleNode("Status/Code")).InnerText.ToString() == "-1")
                                    throw new ArgumentException(ParentResultCode.InnerText);
                                break;
                            case ActivityFolderContainDirection.ParentActivityDontContainThisDirection:                                
                                string sFirstLevelParentActivity = GetFirstLevelParentActivity(helperActivity).ToString();
                                ParentActivityDirection = 
                                    GetFirstLevelParentActivityDirections(sFirstLevelParentActivity);
                                ParentActivityDirection[ParentActivityDirection.Length-1] = new ProjectDirection();
                                ParentActivityDirection[ParentActivityDirection.Length-1].DirectionID = ActivityDirections[nIndex].DirectionID;
                                ParentActivityDirection[ParentActivityDirection.Length-1].ExpenseRatio = 0;
                                ParentUpdateResult = UpdateActivityDirectionsAndExpenseRatio(sFirstLevelParentActivity, ParentActivityDirection);
                                ParentResultCode = ParentUpdateResult.DocumentElement;                                
                                if (((XmlElement)ParentResultCode.SelectSingleNode("Status/Code")).InnerText.ToString() == "-1")
                                    throw new ArgumentException(ParentResultCode.InnerText);
                                break;
                        };

                    }

                    // ������ ����� ������������ �����������
                    foreach (XmlElement xmlFolderDirection in helperActivity.PropertyXml("FolderDirections").ChildNodes)
                    {
                        if (((XmlElement)xmlFolderDirection.SelectSingleNode("Direction/Direction")).GetAttribute("oid").Equals(ActivityDirections[nIndex].DirectionID, StringComparison.InvariantCultureIgnoreCase))
                        {
                            arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection", new Guid(xmlFolderDirection.GetAttribute("oid")));
                            helperActivity.PropertyXml("FolderDirections").RemoveChild(xmlFolderDirection);
                            break;
                        }
                    }
                    if (arrHelpers[nIndex] == null)
                    {
                        // ��������� "��������" ������ ���������� ds-������� FolderDirection
                        arrHelpers[nIndex] = ObjectOperationHelper.GetInstance("FolderDirection");
                    }
                    arrHelpers[nIndex].LoadObject();
                    // ... ����������� ������ �� �����������:
                    arrHelpers[nIndex].SetPropScalarRef("Direction", "Direction", uidDirectionID);
                    // ... � ����� ����������� ������ �� ������:
                    arrHelpers[nIndex].SetPropScalarRef("Folder", "Folder", uidActivityID);
                    // ... "���� ������" - � ����:
                    arrHelpers[nIndex].SetPropValue("ExpenseRatio", XPropType.vt_i2, nPercentage);

                    nTotalPercentage += nPercentage;
                }
                // ���� �������� ���� �� ���� �����������, ����� ���������� ����� ������ ���� ����� 100
                if ((ActivityDirections.Length > 0) && (nTotalPercentage != 100))
                    throw new ArgumentException("����� ���������� ����� �� ������������ ������ ���� ����� 100");


                //  ������ �� ���������� ��� ��������, ����� ����������� - FolderDirections
                helperActivity.DropPropertiesXmlExcept("FolderDirections");

                // ... ��������� ������� ������� - ��� ������ (��. ����� #4):
                arrHelpers[ActivityDirections.Length] = helperActivity;


                // #3:
                // ���� ��� ������� ���� ���������� �����������, ��, �����., ���������� 
                // ��������� ������� FolderDirection, ����������� ������ � �����������. 
                // 
                // ��� ������ ����� �/� �������� � ������������ ��� ��������� ������� ����
                // �������. �������� �������� ������������ � ������� ���������� ���������� 
                // ������ �������, ��� "�����������" ����������, � ������� ��� FolderDirection
                // ����� �������� ��� ��������� - ��� ��� ����� ����� ������� delete="1".
                // 
                // ������� XML-������ �������� FolderDirection, �������� ��� ���� �� ���� -
                // ����� ��� �������� ����������� ���������� ������ �� ����� ����������
                // ��� ������������ �������� �� ��������� �������� (�� #4). � ����� �������
                // "�����" ��� ������ ������ �� FolderDirections ������, � ����� - �������:

                XmlElement xmlFolderDirections = (XmlElement)helperActivity.PropertyXml("FolderDirections").CloneNode(true);
                // ... ������� ������ ������:
                helperActivity.ClearArrayProp("FolderDirections");
                // ... ����� - ���������:
                // ���� �� ������� ��������������� ��������, � ������ ��� ����:
                // -- ��� ��������� ��� - ��� ������, ��� ��������� �� ����, ������� 
                //		���� �� ����� ������� ����� ����;
                // -- ��� ������ ��������������� �������� � ������� ��� �� ��������, 
                //		������� ��� ��������� �������������� ���������� NewlySetObjectID
                for (int nIndex = 0; nIndex < arrHelpers.Length - 1; nIndex++)
                    helperActivity.AddArrayPropRef("FolderDirections", "FolderDirection", arrHelpers[nIndex].NewlySetObjectID);


                // #4:
                // ������ ����������� ���������� ��� ������. �����: (�) ������ ������ 
                // ��������� �������, (�) ������ ����� FolderDirection-��, (�) ������ 
                // ������, ��������� FolderDirection-��
                XmlElement xmlDatagrammRoot = ObjectOperationHelper.MakeComplexDatagarmm(arrHelpers);
                // ... � ���������� ��� ���� ���������� � ����� ������� - �� ������ 
                // ���������� �� helper-��. ������� ������ ���������:
                foreach (XmlNode xmlFolderDirection in xmlFolderDirections.SelectNodes("FolderDirection"))
                {
                    XmlElement xmlDeletedFolderDirection = (XmlElement)xmlDatagrammRoot.AppendChild(xmlDatagrammRoot.OwnerDocument.ImportNode(xmlFolderDirection, true));
                    // ���������� ������ ���������� FolderDirection ��� �� ����� - ������� (�����)
                    xmlDeletedFolderDirection.InnerXml = "";
                    // ... ������������� �������� delete="1", ���� ��� �������, 
                    // ����������� ��� ��������������� ������ � �� ���� �������
                    xmlDeletedFolderDirection.SetAttribute("delete", "1");
                }

                // #5: 
                // ������: ���������� ����������� ����������; � ������ ������ � ����� ����������
                // ����� ��������� ��� �������� - ������� ������� FolderDirection, ������� ����� 
                // FolderDirection, ��������� ������ �����
                ObjectOperationHelper.SaveComplexDatagram(xmlDatagrammRoot, null, null);

                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                doc.LoadXml("<Result><Status><Code>0</Code><Descr/><Stack/></Status></Result>");
                return doc;
            }
            catch (Exception e)
            {
                // ��������� ��������� �� ������
                XmlDocument doc = new XmlDocument();
                XmlElement result = (XmlElement)doc.AppendChild(doc.CreateElement("Result"));
                XmlElement status = (XmlElement)result.AppendChild(doc.CreateElement("Status"));
                ((XmlElement)status.AppendChild(doc.CreateElement("Code"))).InnerText = "-1";
                ((XmlElement)status.AppendChild(doc.CreateElement("Descr"))).InnerText = e.Message;
                ((XmlElement)status.AppendChild(doc.CreateElement("Stack"))).InnerText = e.StackTrace;
                return doc;
            }
        }

		#endregion
	}
}