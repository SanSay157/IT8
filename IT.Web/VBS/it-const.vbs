Option Explicit
'----------------------------------------------------------
'	ActivityDetalizationLevel - ������� ����������� �����������
const ACTIVITYDETALIZATIONLEVEL_SUBPROJECT	= 1		' �� ���������� 1 ������
const ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER	= 2		' �� ��������� �������
const ACTIVITYDETALIZATIONLEVEL_PROJECTCODE	= 3		' �� ���� �������

const NameOf_ACTIVITYDETALIZATIONLEVEL_SUBPROJECT	= "�� ���������� 1 ������"
const NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER	= "�� ��������� �������"
const NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTCODE	= "�� ���� �������"

Function NameOf_ActivityDetalizationLevel(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ACTIVITYDETALIZATIONLEVEL_SUBPROJECT :
			NameOf_ActivityDetalizationLevel = NameOf_ACTIVITYDETALIZATIONLEVEL_SUBPROJECT
		Case ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER :
			NameOf_ActivityDetalizationLevel = NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER
		Case ACTIVITYDETALIZATIONLEVEL_PROJECTCODE :
			NameOf_ActivityDetalizationLevel = NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTCODE
	End Select
End Function

'----------------------------------------------------------
'	BranchFilterType - ��� ���������� �� ��������
const BRANCHFILTERTYPE_ANYBRANCHES	= 0		' ����� �������
const BRANCHFILTERTYPE_ALLSELECTED	= 1		' ��� ���������
const BRANCHFILTERTYPE_ANYSELECTED	= 2		' ���� �� ���� �� ���������

const NameOf_BRANCHFILTERTYPE_ANYBRANCHES	= "����� �������"
const NameOf_BRANCHFILTERTYPE_ALLSELECTED	= "��� ���������"
const NameOf_BRANCHFILTERTYPE_ANYSELECTED	= "���� �� ���� �� ���������"

Function NameOf_BranchFilterType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case BRANCHFILTERTYPE_ANYBRANCHES :
			NameOf_BranchFilterType = NameOf_BRANCHFILTERTYPE_ANYBRANCHES
		Case BRANCHFILTERTYPE_ALLSELECTED :
			NameOf_BranchFilterType = NameOf_BRANCHFILTERTYPE_ALLSELECTED
		Case BRANCHFILTERTYPE_ANYSELECTED :
			NameOf_BranchFilterType = NameOf_BRANCHFILTERTYPE_ANYSELECTED
	End Select
End Function

'----------------------------------------------------------
'	TimeLossCauseTypes - ��� ������� ��������
const TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER	= 1		' ������� ���������� � �����
const TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER	= 2		' �� ����� ���� ��������� � �����
const TIMELOSSCAUSETYPES_APPLICABLETOFOLDER	= 3		' ����� ���� ��������� � �����

const NameOf_TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER	= "������� ���������� � �����"
const NameOf_TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER	= "�� ����� ���� ��������� � �����"
const NameOf_TIMELOSSCAUSETYPES_APPLICABLETOFOLDER	= "����� ���� ��������� � �����"

Function NameOf_TimeLossCauseTypes(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER :
			NameOf_TimeLossCauseTypes = NameOf_TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER
		Case TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER :
			NameOf_TimeLossCauseTypes = NameOf_TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER
		Case TIMELOSSCAUSETYPES_APPLICABLETOFOLDER :
			NameOf_TimeLossCauseTypes = NameOf_TIMELOSSCAUSETYPES_APPLICABLETOFOLDER
	End Select
End Function

'----------------------------------------------------------
'	SortExpences - ���������� ������ �����������
const SORTEXPENCES_NOSORT	= 0		' �����������
const SORTEXPENCES_BYEMPLOYEE	= 1		' �� ����������
const SORTEXPENCES_BYNORM	= 2		' �� �����

const NameOf_SORTEXPENCES_NOSORT	= "�����������"
const NameOf_SORTEXPENCES_BYEMPLOYEE	= "�� ����������"
const NameOf_SORTEXPENCES_BYNORM	= "�� �����"

Function NameOf_SortExpences(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SORTEXPENCES_NOSORT :
			NameOf_SortExpences = NameOf_SORTEXPENCES_NOSORT
		Case SORTEXPENCES_BYEMPLOYEE :
			NameOf_SortExpences = NameOf_SORTEXPENCES_BYEMPLOYEE
		Case SORTEXPENCES_BYNORM :
			NameOf_SortExpences = NameOf_SORTEXPENCES_BYNORM
	End Select
End Function

'----------------------------------------------------------
'	IncidentViewModes - ������ ����������� ����������
const INCIDENTVIEWMODES_ALL	= 1		' ��� ���������
const INCIDENTVIEWMODES_OPEN	= 2		' ��������
const INCIDENTVIEWMODES_NOTCLOSED	= 3		' �� ��������
const INCIDENTVIEWMODES_CLOSED	= 4		' ��������
const INCIDENTVIEWMODES_MINE	= 5		' ��� ���������

const NameOf_INCIDENTVIEWMODES_ALL	= "��� ���������"
const NameOf_INCIDENTVIEWMODES_OPEN	= "��������"
const NameOf_INCIDENTVIEWMODES_NOTCLOSED	= "�� ��������"
const NameOf_INCIDENTVIEWMODES_CLOSED	= "��������"
const NameOf_INCIDENTVIEWMODES_MINE	= "��� ���������"

Function NameOf_IncidentViewModes(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case INCIDENTVIEWMODES_ALL :
			NameOf_IncidentViewModes = NameOf_INCIDENTVIEWMODES_ALL
		Case INCIDENTVIEWMODES_OPEN :
			NameOf_IncidentViewModes = NameOf_INCIDENTVIEWMODES_OPEN
		Case INCIDENTVIEWMODES_NOTCLOSED :
			NameOf_IncidentViewModes = NameOf_INCIDENTVIEWMODES_NOTCLOSED
		Case INCIDENTVIEWMODES_CLOSED :
			NameOf_IncidentViewModes = NameOf_INCIDENTVIEWMODES_CLOSED
		Case INCIDENTVIEWMODES_MINE :
			NameOf_IncidentViewModes = NameOf_INCIDENTVIEWMODES_MINE
	End Select
End Function

'----------------------------------------------------------
'	TenderSortType - ��� ���������� � ������ �������
const TENDERSORTTYPE_RANDOM	= 0		' �����������
const TENDERSORTTYPE_BYTENDERNAME	= 1		' �� ������������ ��������
const TENDERSORTTYPE_BYCUSTOMERNAME	= 2		' �� ������������ ���������
const TENDERSORTTYPE_BYDOCFEEDINGDATE	= 3		' �� ���� ������ ����������

const NameOf_TENDERSORTTYPE_RANDOM	= "�����������"
const NameOf_TENDERSORTTYPE_BYTENDERNAME	= "�� ������������ ��������"
const NameOf_TENDERSORTTYPE_BYCUSTOMERNAME	= "�� ������������ ���������"
const NameOf_TENDERSORTTYPE_BYDOCFEEDINGDATE	= "�� ���� ������ ����������"

Function NameOf_TenderSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case TENDERSORTTYPE_RANDOM :
			NameOf_TenderSortType = NameOf_TENDERSORTTYPE_RANDOM
		Case TENDERSORTTYPE_BYTENDERNAME :
			NameOf_TenderSortType = NameOf_TENDERSORTTYPE_BYTENDERNAME
		Case TENDERSORTTYPE_BYCUSTOMERNAME :
			NameOf_TenderSortType = NameOf_TENDERSORTTYPE_BYCUSTOMERNAME
		Case TENDERSORTTYPE_BYDOCFEEDINGDATE :
			NameOf_TenderSortType = NameOf_TENDERSORTTYPE_BYDOCFEEDINGDATE
	End Select
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_AnalysisDepth - ����� ������������� ������ ������ "��������� ������ �������������"
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED	= 0		' ������ ��������� ������������� / �����������
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS	= 1		' �������� ������ ��������������� ����������� �������������
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS	= 2		' �������� ������ ���� ����������� �������������

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED	= "������ ��������� ������������� / �����������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS	= "�������� ������ ��������������� ����������� �������������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS	= "�������� ������ ���� ����������� �������������"

Function NameOf_RepDepartmentExpensesStructure_AnalysisDepth(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED :
			NameOf_RepDepartmentExpensesStructure_AnalysisDepth = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED
		Case REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS :
			NameOf_RepDepartmentExpensesStructure_AnalysisDepth = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS
		Case REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS :
			NameOf_RepDepartmentExpensesStructure_AnalysisDepth = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS
	End Select
End Function

'----------------------------------------------------------
'	StartPages - ��������� ��������
const STARTPAGES_CURRENTTASKLIST	= 1		' ������ ������� ����� (��� ���������)
const STARTPAGES_DKP	= 2		' �������� �������� � ��������
const STARTPAGES_REPORTS	= 3		' ������
const STARTPAGES_TMS	= 4		' ��������� �������� ������� ����� ��������
const STARTPAGES_TENDERLIST	= 5		' ������ ��������

const NameOf_STARTPAGES_CURRENTTASKLIST	= "������ ������� ����� (��� ���������)"
const NameOf_STARTPAGES_DKP	= "�������� �������� � ��������"
const NameOf_STARTPAGES_REPORTS	= "������"
const NameOf_STARTPAGES_TMS	= "��������� �������� ������� ����� ��������"
const NameOf_STARTPAGES_TENDERLIST	= "������ ��������"

Function NameOf_StartPages(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case STARTPAGES_CURRENTTASKLIST :
			NameOf_StartPages = NameOf_STARTPAGES_CURRENTTASKLIST
		Case STARTPAGES_DKP :
			NameOf_StartPages = NameOf_STARTPAGES_DKP
		Case STARTPAGES_REPORTS :
			NameOf_StartPages = NameOf_STARTPAGES_REPORTS
		Case STARTPAGES_TMS :
			NameOf_StartPages = NameOf_STARTPAGES_TMS
		Case STARTPAGES_TENDERLIST :
			NameOf_StartPages = NameOf_STARTPAGES_TENDERLIST
	End Select
End Function

'----------------------------------------------------------
'	SortOrder - ������� ����������
const SORTORDER_ASC	= 1		' �� �����������
const SORTORDER_DESC	= 2		' �� ��������

const NameOf_SORTORDER_ASC	= "�� �����������"
const NameOf_SORTORDER_DESC	= "�� ��������"

Function NameOf_SortOrder(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SORTORDER_ASC :
			NameOf_SortOrder = NameOf_SORTORDER_ASC
		Case SORTORDER_DESC :
			NameOf_SortOrder = NameOf_SORTORDER_DESC
	End Select
End Function

'----------------------------------------------------------
'	SectioningByActivity - ��������������� �� ����������� 1
const SECTIONINGBYACTIVITY_NOSECTIONING	= 0		' ��� ���������������
const SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY	= 1		' �� ����������� �������� ������

const NameOf_SECTIONINGBYACTIVITY_NOSECTIONING	= "��� ���������������"
const NameOf_SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY	= "�� ����������� �������� ������"

Function NameOf_SectioningByActivity(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SECTIONINGBYACTIVITY_NOSECTIONING :
			NameOf_SectioningByActivity = NameOf_SECTIONINGBYACTIVITY_NOSECTIONING
		Case SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY :
			NameOf_SectioningByActivity = NameOf_SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY
	End Select
End Function

'----------------------------------------------------------
'	GENDER - ���
const GENDER_MALE	= 1		' M
const GENDER_FEMALE	= 0		' F

const NameOf_GENDER_MALE	= "M"
const NameOf_GENDER_FEMALE	= "F"

Function NameOf_GENDER(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case GENDER_MALE :
			NameOf_GENDER = NameOf_GENDER_MALE
		Case GENDER_FEMALE :
			NameOf_GENDER = NameOf_GENDER_FEMALE
	End Select
End Function

'----------------------------------------------------------
'	PresentationModes - ������ ����������� ������
const PRESENTATIONMODES_DISPLAYDESCR	= 1		' ���������� ������������
const PRESENTATIONMODES_DISPLAYDATA	= 2		' ���������� ������

const NameOf_PRESENTATIONMODES_DISPLAYDESCR	= "���������� ������������"
const NameOf_PRESENTATIONMODES_DISPLAYDATA	= "���������� ������"

Function NameOf_PresentationModes(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(PRESENTATIONMODES_DISPLAYDESCR) Then sResult = sResult & NameOf_PRESENTATIONMODES_DISPLAYDESCR & ","
	If vVal AND CLng(PRESENTATIONMODES_DISPLAYDATA) Then sResult = sResult & NameOf_PRESENTATIONMODES_DISPLAYDATA & ","
	If Not IsEmpty(sResult) Then NameOf_PresentationModes = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_ReportForm - ����� ������ "��������� ������ �������������"
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT	= 0		' ��������� ������ �������������
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE	= 1		' ������ �� ������� ���������� �������������
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI	= 2		' ������ �� ������� ����������, � ������� �� ��������

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT	= "��������� ������ �������������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE	= "������ �� ������� ���������� �������������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI	= "������ �� ������� ����������, � ������� �� ��������"

Function NameOf_RepDepartmentExpensesStructure_ReportForm(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT :
			NameOf_RepDepartmentExpensesStructure_ReportForm = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT
		Case REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE :
			NameOf_RepDepartmentExpensesStructure_ReportForm = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE
		Case REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI :
			NameOf_RepDepartmentExpensesStructure_ReportForm = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI
	End Select
End Function

'----------------------------------------------------------
'	SectionByActivity - ��������������� �� �����������
const SECTIONBYACTIVITY_NOSECTION	= 0		' ��� ���������������
const SECTIONBYACTIVITY_STAGE1SECTION	= 1		' �� ����������� ����������� 1 ������
const SECTIONBYACTIVITY_ALLSTAGESSECTION	= 2		' �� ����������� ����������� ���� �������

const NameOf_SECTIONBYACTIVITY_NOSECTION	= "��� ���������������"
const NameOf_SECTIONBYACTIVITY_STAGE1SECTION	= "�� ����������� ����������� 1 ������"
const NameOf_SECTIONBYACTIVITY_ALLSTAGESSECTION	= "�� ����������� ����������� ���� �������"

Function NameOf_SectionByActivity(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SECTIONBYACTIVITY_NOSECTION :
			NameOf_SectionByActivity = NameOf_SECTIONBYACTIVITY_NOSECTION
		Case SECTIONBYACTIVITY_STAGE1SECTION :
			NameOf_SectionByActivity = NameOf_SECTIONBYACTIVITY_STAGE1SECTION
		Case SECTIONBYACTIVITY_ALLSTAGESSECTION :
			NameOf_SectionByActivity = NameOf_SECTIONBYACTIVITY_ALLSTAGESSECTION
	End Select
End Function

'----------------------------------------------------------
'	FolderTypeEnum - ��� ����� enum
const FOLDERTYPEENUM_PROJECT	= 1		' ������
const FOLDERTYPEENUM_TENDER	= 4		' ������
const FOLDERTYPEENUM_PRESALE	= 8		' �������
const FOLDERTYPEENUM_DIRECTORY	= 16		' �������

const NameOf_FOLDERTYPEENUM_PROJECT	= "������"
const NameOf_FOLDERTYPEENUM_TENDER	= "������"
const NameOf_FOLDERTYPEENUM_PRESALE	= "�������"
const NameOf_FOLDERTYPEENUM_DIRECTORY	= "�������"

Function NameOf_FolderTypeEnum(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case FOLDERTYPEENUM_PROJECT :
			NameOf_FolderTypeEnum = NameOf_FOLDERTYPEENUM_PROJECT
		Case FOLDERTYPEENUM_TENDER :
			NameOf_FolderTypeEnum = NameOf_FOLDERTYPEENUM_TENDER
		Case FOLDERTYPEENUM_PRESALE :
			NameOf_FolderTypeEnum = NameOf_FOLDERTYPEENUM_PRESALE
		Case FOLDERTYPEENUM_DIRECTORY :
			NameOf_FolderTypeEnum = NameOf_FOLDERTYPEENUM_DIRECTORY
	End Select
End Function

'----------------------------------------------------------
'	FolderStatesFlags - ��������� ����� flags
const FOLDERSTATESFLAGS_OPEN	= 1		' �������
const FOLDERSTATESFLAGS_WAITINGTOCLOSE	= 2		' �������� ��������
const FOLDERSTATESFLAGS_CLOSED	= 4		' �������
const FOLDERSTATESFLAGS_FROZEN	= 8		' ����������

const NameOf_FOLDERSTATESFLAGS_OPEN	= "�������"
const NameOf_FOLDERSTATESFLAGS_WAITINGTOCLOSE	= "�������� ��������"
const NameOf_FOLDERSTATESFLAGS_CLOSED	= "�������"
const NameOf_FOLDERSTATESFLAGS_FROZEN	= "����������"

Function NameOf_FolderStatesFlags(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(FOLDERSTATESFLAGS_OPEN) Then sResult = sResult & NameOf_FOLDERSTATESFLAGS_OPEN & ","
	If vVal AND CLng(FOLDERSTATESFLAGS_WAITINGTOCLOSE) Then sResult = sResult & NameOf_FOLDERSTATESFLAGS_WAITINGTOCLOSE & ","
	If vVal AND CLng(FOLDERSTATESFLAGS_CLOSED) Then sResult = sResult & NameOf_FOLDERSTATESFLAGS_CLOSED & ","
	If vVal AND CLng(FOLDERSTATESFLAGS_FROZEN) Then sResult = sResult & NameOf_FOLDERSTATESFLAGS_FROZEN & ","
	If Not IsEmpty(sResult) Then NameOf_FolderStatesFlags = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	ExpencesType - ��� �����������
const EXPENCESTYPE_INCIDENTS	= 0		' ������� �� ���������
const EXPENCESTYPE_DISCARDING	= 1		' ��������
const EXPENCESTYPE_BOTH	= 2		' ������� �� ��������� � ��������

const NameOf_EXPENCESTYPE_INCIDENTS	= "������� �� ���������"
const NameOf_EXPENCESTYPE_DISCARDING	= "��������"
const NameOf_EXPENCESTYPE_BOTH	= "������� �� ��������� � ��������"

Function NameOf_ExpencesType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case EXPENCESTYPE_INCIDENTS :
			NameOf_ExpencesType = NameOf_EXPENCESTYPE_INCIDENTS
		Case EXPENCESTYPE_DISCARDING :
			NameOf_ExpencesType = NameOf_EXPENCESTYPE_DISCARDING
		Case EXPENCESTYPE_BOTH :
			NameOf_ExpencesType = NameOf_EXPENCESTYPE_BOTH
	End Select
End Function

'----------------------------------------------------------
'	ExpenseDetalization - ����������� ������
const EXPENSEDETALIZATION_BYEXPENCES	= 0		' �� ��������
const EXPENSEDETALIZATION_BYINCIDENT	= 1		' �� ����������
const EXPENSEDETALIZATION_BYSUBACTIVITY	= 2		' �� ����������� ������� ������

const NameOf_EXPENSEDETALIZATION_BYEXPENCES	= "�� ��������"
const NameOf_EXPENSEDETALIZATION_BYINCIDENT	= "�� ����������"
const NameOf_EXPENSEDETALIZATION_BYSUBACTIVITY	= "�� ����������� ������� ������"

Function NameOf_ExpenseDetalization(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case EXPENSEDETALIZATION_BYEXPENCES :
			NameOf_ExpenseDetalization = NameOf_EXPENSEDETALIZATION_BYEXPENCES
		Case EXPENSEDETALIZATION_BYINCIDENT :
			NameOf_ExpenseDetalization = NameOf_EXPENSEDETALIZATION_BYINCIDENT
		Case EXPENSEDETALIZATION_BYSUBACTIVITY :
			NameOf_ExpenseDetalization = NameOf_EXPENSEDETALIZATION_BYSUBACTIVITY
	End Select
End Function

'----------------------------------------------------------
'	DKPTreeModes - ������ ������ ���
const DKPTREEMODES_ORGANIZATIONS	= 1		' �����������
const DKPTREEMODES_ACTIVITIES	= 2		' ����������

const NameOf_DKPTREEMODES_ORGANIZATIONS	= "�����������"
const NameOf_DKPTREEMODES_ACTIVITIES	= "����������"

Function NameOf_DKPTreeModes(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DKPTREEMODES_ORGANIZATIONS :
			NameOf_DKPTreeModes = NameOf_DKPTREEMODES_ORGANIZATIONS
		Case DKPTREEMODES_ACTIVITIES :
			NameOf_DKPTreeModes = NameOf_DKPTREEMODES_ACTIVITIES
	End Select
End Function

'----------------------------------------------------------
'	IncidentStateCategoryFlags - ��������� ���������
const INCIDENTSTATECATEGORYFLAGS_OPEN	= 1		' � ������
const INCIDENTSTATECATEGORYFLAGS_ONCHECK	= 2		' �� ��������
const INCIDENTSTATECATEGORYFLAGS_FINISHED	= 4		' ������ ��������
const INCIDENTSTATECATEGORYFLAGS_FROZEN	= 8		' ���������
const INCIDENTSTATECATEGORYFLAGS_DECLINED	= 16		' ��������

const NameOf_INCIDENTSTATECATEGORYFLAGS_OPEN	= "� ������"
const NameOf_INCIDENTSTATECATEGORYFLAGS_ONCHECK	= "�� ��������"
const NameOf_INCIDENTSTATECATEGORYFLAGS_FINISHED	= "������ ��������"
const NameOf_INCIDENTSTATECATEGORYFLAGS_FROZEN	= "���������"
const NameOf_INCIDENTSTATECATEGORYFLAGS_DECLINED	= "��������"

Function NameOf_IncidentStateCategoryFlags(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(INCIDENTSTATECATEGORYFLAGS_OPEN) Then sResult = sResult & NameOf_INCIDENTSTATECATEGORYFLAGS_OPEN & ","
	If vVal AND CLng(INCIDENTSTATECATEGORYFLAGS_ONCHECK) Then sResult = sResult & NameOf_INCIDENTSTATECATEGORYFLAGS_ONCHECK & ","
	If vVal AND CLng(INCIDENTSTATECATEGORYFLAGS_FINISHED) Then sResult = sResult & NameOf_INCIDENTSTATECATEGORYFLAGS_FINISHED & ","
	If vVal AND CLng(INCIDENTSTATECATEGORYFLAGS_FROZEN) Then sResult = sResult & NameOf_INCIDENTSTATECATEGORYFLAGS_FROZEN & ","
	If vVal AND CLng(INCIDENTSTATECATEGORYFLAGS_DECLINED) Then sResult = sResult & NameOf_INCIDENTSTATECATEGORYFLAGS_DECLINED & ","
	If Not IsEmpty(sResult) Then NameOf_IncidentStateCategoryFlags = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	ReportExpensesByDirectionsSortType - ��� ���������� � ������ "������� � ������� �����������"
const REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION	= 0		' �� �����������
const REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES	= 1		' �� ����� ������

const NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION	= "�� �����������"
const NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES	= "�� ����� ������"

Function NameOf_ReportExpensesByDirectionsSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION :
			NameOf_ReportExpensesByDirectionsSortType = NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION
		Case REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES :
			NameOf_ReportExpensesByDirectionsSortType = NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES
	End Select
End Function

'----------------------------------------------------------
'	PROJECT_RISK_PRIORITY - ��������� ���������� �����
const PROJECT_RISK_PRIORITY_HIGH	= 0		' �������
const PROJECT_RISK_PRIORITY_MEDIUM	= 1		' �������
const PROJECT_RISK_PRIORITY_LOW	= 2		' ������

const NameOf_PROJECT_RISK_PRIORITY_HIGH	= "�������"
const NameOf_PROJECT_RISK_PRIORITY_MEDIUM	= "�������"
const NameOf_PROJECT_RISK_PRIORITY_LOW	= "������"

Function NameOf_PROJECT_RISK_PRIORITY(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case PROJECT_RISK_PRIORITY_HIGH :
			NameOf_PROJECT_RISK_PRIORITY = NameOf_PROJECT_RISK_PRIORITY_HIGH
		Case PROJECT_RISK_PRIORITY_MEDIUM :
			NameOf_PROJECT_RISK_PRIORITY = NameOf_PROJECT_RISK_PRIORITY_MEDIUM
		Case PROJECT_RISK_PRIORITY_LOW :
			NameOf_PROJECT_RISK_PRIORITY = NameOf_PROJECT_RISK_PRIORITY_LOW
	End Select
End Function

'----------------------------------------------------------
'	IncidentStateCat - ��������� ��������� ���������
const INCIDENTSTATECAT_OPEN	= 1		' � ������
const INCIDENTSTATECAT_ONCHECK	= 2		' �� ��������
const INCIDENTSTATECAT_FINISHED	= 3		' ������ ��������
const INCIDENTSTATECAT_FROZEN	= 4		' ���������
const INCIDENTSTATECAT_DECLINED	= 5		' ��������

const NameOf_INCIDENTSTATECAT_OPEN	= "� ������"
const NameOf_INCIDENTSTATECAT_ONCHECK	= "�� ��������"
const NameOf_INCIDENTSTATECAT_FINISHED	= "������ ��������"
const NameOf_INCIDENTSTATECAT_FROZEN	= "���������"
const NameOf_INCIDENTSTATECAT_DECLINED	= "��������"

Function NameOf_IncidentStateCat(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case INCIDENTSTATECAT_OPEN :
			NameOf_IncidentStateCat = NameOf_INCIDENTSTATECAT_OPEN
		Case INCIDENTSTATECAT_ONCHECK :
			NameOf_IncidentStateCat = NameOf_INCIDENTSTATECAT_ONCHECK
		Case INCIDENTSTATECAT_FINISHED :
			NameOf_IncidentStateCat = NameOf_INCIDENTSTATECAT_FINISHED
		Case INCIDENTSTATECAT_FROZEN :
			NameOf_IncidentStateCat = NameOf_INCIDENTSTATECAT_FROZEN
		Case INCIDENTSTATECAT_DECLINED :
			NameOf_IncidentStateCat = NameOf_INCIDENTSTATECAT_DECLINED
	End Select
End Function

'----------------------------------------------------------
'	FolderPrivileges - ���������� ��� �����
const FOLDERPRIVILEGES_MANAGEINCIDENTS	= 1		' ���������� �����������
const FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS	= 2		' ���������� �������� ���������� ���������
const FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT	= 4		' ���������� ������ ����������
const FOLDERPRIVILEGES_CHANGEFOLDER	= 64		' �������������� ���������� ��������
const FOLDERPRIVILEGES_MANAGECATALOG	= 128		' ���������� ����������
const FOLDERPRIVILEGES_SPENTTIMEBYPROJECT	= 256		' �������� �������� �� ������
const FOLDERPRIVILEGES_MANAGETEAM	= 512		' ���������� ��������� ��������
const FOLDERPRIVILEGES_CLOSEFOLDER	= 1024		' �������� ����������
const FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION	= 2048		' ���������� �������� �� ����� � ������������� ������������ �����������

const NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTS	= "���������� �����������"
const NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS	= "���������� �������� ���������� ���������"
const NameOf_FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT	= "���������� ������ ����������"
const NameOf_FOLDERPRIVILEGES_CHANGEFOLDER	= "�������������� ���������� ��������"
const NameOf_FOLDERPRIVILEGES_MANAGECATALOG	= "���������� ����������"
const NameOf_FOLDERPRIVILEGES_SPENTTIMEBYPROJECT	= "�������� �������� �� ������"
const NameOf_FOLDERPRIVILEGES_MANAGETEAM	= "���������� ��������� ��������"
const NameOf_FOLDERPRIVILEGES_CLOSEFOLDER	= "�������� ����������"
const NameOf_FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION	= "���������� �������� �� ����� � ������������� ������������ �����������"

Function NameOf_FolderPrivileges(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(FOLDERPRIVILEGES_MANAGEINCIDENTS) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTS & ","
	If vVal AND CLng(FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS & ","
	If vVal AND CLng(FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT & ","
	If vVal AND CLng(FOLDERPRIVILEGES_CHANGEFOLDER) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_CHANGEFOLDER & ","
	If vVal AND CLng(FOLDERPRIVILEGES_MANAGECATALOG) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_MANAGECATALOG & ","
	If vVal AND CLng(FOLDERPRIVILEGES_SPENTTIMEBYPROJECT) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_SPENTTIMEBYPROJECT & ","
	If vVal AND CLng(FOLDERPRIVILEGES_MANAGETEAM) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_MANAGETEAM & ","
	If vVal AND CLng(FOLDERPRIVILEGES_CLOSEFOLDER) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_CLOSEFOLDER & ","
	If vVal AND CLng(FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION) Then sResult = sResult & NameOf_FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION & ","
	If Not IsEmpty(sResult) Then NameOf_FolderPrivileges = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	EventClass - ����� �������
const EVENTCLASS_EVENT_TYPE_01	= 1		' �������� ���������
const EVENTCLASS_EVENT_TYPE_02	= 2		' ��������� ��������� ���������
const EVENTCLASS_EVENT_TYPE_03	= 3		' �������� ���������
const EVENTCLASS_EVENT_TYPE_04	= 4		' �������� �������� ������ ������� �� ���������
const EVENTCLASS_EVENT_TYPE_05	= 5		' ��������� ���� ����������� � ������� �� ���������
const EVENTCLASS_EVENT_TYPE_06	= 6		' �������� ������� �� ���������
const EVENTCLASS_EVENT_TYPE_07	= 7		' ��������� ������������, �������� ��� �������� ������� ���������
const EVENTCLASS_EVENT_TYPE_08	= 8		' ��������� ���������� ��� �������� ����� ���������
const EVENTCLASS_EVENT_TYPE_09	= 9		' ������� ��������� � ������ ���������� - �������
const EVENTCLASS_EVENT_TYPE_10	= 10		' ������� ��������� � ������ ���������� - ������
const EVENTCLASS_EVENT_TYPE_11	= 11		' ���������� ��������� ��������� �������
const EVENTCLASS_EVENT_TYPE_12	= 12		' �������� ��������� ��������� �������
const EVENTCLASS_EVENT_TYPE_13	= 13		' ������ ���� ��� ��������� ��������� �������
const EVENTCLASS_EVENT_TYPE_14	= 14		' ���������� ���� ��� ��������� ��������� �������
const EVENTCLASS_EVENT_TYPE_15	= 15		' �������� �����������
const EVENTCLASS_EVENT_TYPE_16	= 16		' ������ ��������� ������� (�����������)
const EVENTCLASS_EVENT_TYPE_17	= 17		' ������� ��������� ������� (�����������)
const EVENTCLASS_EVENT_TYPE_18	= 18		' ��������� ������������ ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_19	= 19		' ��������� �������� ID ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_20	= 20		' ��������� ���������� �������� �� ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_21	= 21		' �������� �������� ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_22	= 22		' �������� ���������� ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_23	= 23		' �������� �������� ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_24	= 24		' �������� ���������� ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_25	= 25		' ��������� ������� � ��������� ���������� - �������
const EVENTCLASS_EVENT_TYPE_26	= 26		' ��������� ������� � ��������� ���������� - ������
const EVENTCLASS_EVENT_TYPE_27	= 27		' ������� ��������� ���������� � ������ ����� - �������
const EVENTCLASS_EVENT_TYPE_28	= 28		' ������� ��������� ���������� � ������ ����� - ������
const EVENTCLASS_EVENT_TYPE_29	= 29		' ��������� ��������� � ��������� ����������
const EVENTCLASS_EVENT_TYPE_30	= 30		' ��������� ���� ���������� � ��������� ����������
const EVENTCLASS_EVENT_TYPE_31	= 31		' ������� ����������� - �������
const EVENTCLASS_EVENT_TYPE_32	= 32		' ������� ����������� - ������
const EVENTCLASS_EVENT_TYPE_33	= 33		' ��������� ������������ ��� ������������ ������������ �����������
const EVENTCLASS_EVENT_TYPE_34	= 34		' �������� �����������
const EVENTCLASS_EVENT_TYPE_65	= 65		' ��������� ����� ��������� �����������
const EVENTCLASS_EVENT_TYPE_35	= 35		' ��������� ���������������� �������
const EVENTCLASS_EVENT_TYPE_36	= 36		' ��������� ����������� �������
const EVENTCLASS_EVENT_TYPE_37	= 37		' ��������� (���������) ������������� ���������� ��������
const EVENTCLASS_EVENT_TYPE_38	= 38		' �������� ��������� �����������
const EVENTCLASS_EVENT_TYPE_39	= 39		' ������ ���������� �������� ����������� ����������
const EVENTCLASS_EVENT_TYPE_40	= 40		' �������� ������ �������
const EVENTCLASS_EVENT_TYPE_41	= 41		' �������� ������� � ����
const EVENTCLASS_EVENT_TYPE_42	= 42		' ����������� ��������� � ����
const EVENTCLASS_EVENT_TYPE_43	= 43		' �������� ��������� � ����
const EVENTCLASS_EVENT_TYPE_44	= 44		' ��������� ��������� ������� - ������
const EVENTCLASS_EVENT_TYPE_45	= 45		' ��������� ��������� ������� - ����������
const EVENTCLASS_EVENT_TYPE_46	= 46		' �������� �������
const EVENTCLASS_EVENT_TYPE_47	= 47		' ��������� ��������� ����
const EVENTCLASS_EVENT_TYPE_48	= 48		' ���������� ���������������� ������� �� ���������
const EVENTCLASS_EVENT_TYPE_63	= 63		' ��������� ����� ��������� ����������
const EVENTCLASS_EVENT_TYPE_49	= 49		' ����������� �������� ����� ���������
const EVENTCLASS_EVENT_TYPE_50	= 50		' ��������� �������� ����� ���������
const EVENTCLASS_EVENT_TYPE_51	= 51		' �������� ������ ����
const EVENTCLASS_EVENT_TYPE_64	= 64		' ���������� �������� ��������� ���������� �� ��������
const EVENTCLASS_EVENT_TYPE_52	= 52		' ��������� ����
const EVENTCLASS_EVENT_TYPE_53	= 53		' �������� ����
const EVENTCLASS_EVENT_TYPE_54	= 54		' ��������� �������� �������
const EVENTCLASS_EVENT_TYPE_55	= 55		' ��������� ��������� �������
const EVENTCLASS_EVENT_TYPE_56	= 56		' ���������� ���������� � ������ ���, ����������� ������� � ���������� �������
const EVENTCLASS_EVENT_TYPE_57	= 57		' ���������� ���������� �� ������� ���, ����������� ������� � ���������� �������
const EVENTCLASS_EVENT_TYPE_58	= 58		' ���������� ����������� � ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_59	= 59		' �������� ����������� � ��������� ���������� (�����)
const EVENTCLASS_EVENT_TYPE_60	= 60		' ��������� ���� ������ ����������� � ��������� ����������
const EVENTCLASS_EVENT_TYPE_61	= 61		' ��������� ����� �������� ������� ����������
const EVENTCLASS_EVENT_TYPE_62	= 62		' ������� ��������� ���������� � ��������� "�������� ��������"

const NameOf_EVENTCLASS_EVENT_TYPE_01	= "�������� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_02	= "��������� ��������� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_03	= "�������� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_04	= "�������� �������� ������ ������� �� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_05	= "��������� ���� ����������� � ������� �� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_06	= "�������� ������� �� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_07	= "��������� ������������, �������� ��� �������� ������� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_08	= "��������� ���������� ��� �������� ����� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_09	= "������� ��������� � ������ ���������� - �������"
const NameOf_EVENTCLASS_EVENT_TYPE_10	= "������� ��������� � ������ ���������� - ������"
const NameOf_EVENTCLASS_EVENT_TYPE_11	= "���������� ��������� ��������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_12	= "�������� ��������� ��������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_13	= "������ ���� ��� ��������� ��������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_14	= "���������� ���� ��� ��������� ��������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_15	= "�������� �����������"
const NameOf_EVENTCLASS_EVENT_TYPE_16	= "������ ��������� ������� (�����������)"
const NameOf_EVENTCLASS_EVENT_TYPE_17	= "������� ��������� ������� (�����������)"
const NameOf_EVENTCLASS_EVENT_TYPE_18	= "��������� ������������ ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_19	= "��������� �������� ID ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_20	= "��������� ���������� �������� �� ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_21	= "�������� �������� ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_22	= "�������� ���������� ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_23	= "�������� �������� ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_24	= "�������� ���������� ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_25	= "��������� ������� � ��������� ���������� - �������"
const NameOf_EVENTCLASS_EVENT_TYPE_26	= "��������� ������� � ��������� ���������� - ������"
const NameOf_EVENTCLASS_EVENT_TYPE_27	= "������� ��������� ���������� � ������ ����� - �������"
const NameOf_EVENTCLASS_EVENT_TYPE_28	= "������� ��������� ���������� � ������ ����� - ������"
const NameOf_EVENTCLASS_EVENT_TYPE_29	= "��������� ��������� � ��������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_30	= "��������� ���� ���������� � ��������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_31	= "������� ����������� - �������"
const NameOf_EVENTCLASS_EVENT_TYPE_32	= "������� ����������� - ������"
const NameOf_EVENTCLASS_EVENT_TYPE_33	= "��������� ������������ ��� ������������ ������������ �����������"
const NameOf_EVENTCLASS_EVENT_TYPE_34	= "�������� �����������"
const NameOf_EVENTCLASS_EVENT_TYPE_65	= "��������� ����� ��������� �����������"
const NameOf_EVENTCLASS_EVENT_TYPE_35	= "��������� ���������������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_36	= "��������� ����������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_37	= "��������� (���������) ������������� ���������� ��������"
const NameOf_EVENTCLASS_EVENT_TYPE_38	= "�������� ��������� �����������"
const NameOf_EVENTCLASS_EVENT_TYPE_39	= "������ ���������� �������� ����������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_40	= "�������� ������ �������"
const NameOf_EVENTCLASS_EVENT_TYPE_41	= "�������� ������� � ����"
const NameOf_EVENTCLASS_EVENT_TYPE_42	= "����������� ��������� � ����"
const NameOf_EVENTCLASS_EVENT_TYPE_43	= "�������� ��������� � ����"
const NameOf_EVENTCLASS_EVENT_TYPE_44	= "��������� ��������� ������� - ������"
const NameOf_EVENTCLASS_EVENT_TYPE_45	= "��������� ��������� ������� - ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_46	= "�������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_47	= "��������� ��������� ����"
const NameOf_EVENTCLASS_EVENT_TYPE_48	= "���������� ���������������� ������� �� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_63	= "��������� ����� ��������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_49	= "����������� �������� ����� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_50	= "��������� �������� ����� ���������"
const NameOf_EVENTCLASS_EVENT_TYPE_51	= "�������� ������ ����"
const NameOf_EVENTCLASS_EVENT_TYPE_64	= "���������� �������� ��������� ���������� �� ��������"
const NameOf_EVENTCLASS_EVENT_TYPE_52	= "��������� ����"
const NameOf_EVENTCLASS_EVENT_TYPE_53	= "�������� ����"
const NameOf_EVENTCLASS_EVENT_TYPE_54	= "��������� �������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_55	= "��������� ��������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_56	= "���������� ���������� � ������ ���, ����������� ������� � ���������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_57	= "���������� ���������� �� ������� ���, ����������� ������� � ���������� �������"
const NameOf_EVENTCLASS_EVENT_TYPE_58	= "���������� ����������� � ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_59	= "�������� ����������� � ��������� ���������� (�����)"
const NameOf_EVENTCLASS_EVENT_TYPE_60	= "��������� ���� ������ ����������� � ��������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_61	= "��������� ����� �������� ������� ����������"
const NameOf_EVENTCLASS_EVENT_TYPE_62	= "������� ��������� ���������� � ��������� ""�������� ��������"""

Function NameOf_EventClass(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case EVENTCLASS_EVENT_TYPE_01 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_01
		Case EVENTCLASS_EVENT_TYPE_02 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_02
		Case EVENTCLASS_EVENT_TYPE_03 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_03
		Case EVENTCLASS_EVENT_TYPE_04 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_04
		Case EVENTCLASS_EVENT_TYPE_05 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_05
		Case EVENTCLASS_EVENT_TYPE_06 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_06
		Case EVENTCLASS_EVENT_TYPE_07 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_07
		Case EVENTCLASS_EVENT_TYPE_08 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_08
		Case EVENTCLASS_EVENT_TYPE_09 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_09
		Case EVENTCLASS_EVENT_TYPE_10 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_10
		Case EVENTCLASS_EVENT_TYPE_11 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_11
		Case EVENTCLASS_EVENT_TYPE_12 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_12
		Case EVENTCLASS_EVENT_TYPE_13 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_13
		Case EVENTCLASS_EVENT_TYPE_14 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_14
		Case EVENTCLASS_EVENT_TYPE_15 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_15
		Case EVENTCLASS_EVENT_TYPE_16 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_16
		Case EVENTCLASS_EVENT_TYPE_17 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_17
		Case EVENTCLASS_EVENT_TYPE_18 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_18
		Case EVENTCLASS_EVENT_TYPE_19 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_19
		Case EVENTCLASS_EVENT_TYPE_20 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_20
		Case EVENTCLASS_EVENT_TYPE_21 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_21
		Case EVENTCLASS_EVENT_TYPE_22 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_22
		Case EVENTCLASS_EVENT_TYPE_23 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_23
		Case EVENTCLASS_EVENT_TYPE_24 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_24
		Case EVENTCLASS_EVENT_TYPE_25 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_25
		Case EVENTCLASS_EVENT_TYPE_26 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_26
		Case EVENTCLASS_EVENT_TYPE_27 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_27
		Case EVENTCLASS_EVENT_TYPE_28 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_28
		Case EVENTCLASS_EVENT_TYPE_29 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_29
		Case EVENTCLASS_EVENT_TYPE_30 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_30
		Case EVENTCLASS_EVENT_TYPE_31 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_31
		Case EVENTCLASS_EVENT_TYPE_32 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_32
		Case EVENTCLASS_EVENT_TYPE_33 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_33
		Case EVENTCLASS_EVENT_TYPE_34 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_34
		Case EVENTCLASS_EVENT_TYPE_65 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_65
		Case EVENTCLASS_EVENT_TYPE_35 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_35
		Case EVENTCLASS_EVENT_TYPE_36 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_36
		Case EVENTCLASS_EVENT_TYPE_37 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_37
		Case EVENTCLASS_EVENT_TYPE_38 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_38
		Case EVENTCLASS_EVENT_TYPE_39 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_39
		Case EVENTCLASS_EVENT_TYPE_40 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_40
		Case EVENTCLASS_EVENT_TYPE_41 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_41
		Case EVENTCLASS_EVENT_TYPE_42 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_42
		Case EVENTCLASS_EVENT_TYPE_43 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_43
		Case EVENTCLASS_EVENT_TYPE_44 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_44
		Case EVENTCLASS_EVENT_TYPE_45 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_45
		Case EVENTCLASS_EVENT_TYPE_46 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_46
		Case EVENTCLASS_EVENT_TYPE_47 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_47
		Case EVENTCLASS_EVENT_TYPE_48 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_48
		Case EVENTCLASS_EVENT_TYPE_63 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_63
		Case EVENTCLASS_EVENT_TYPE_49 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_49
		Case EVENTCLASS_EVENT_TYPE_50 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_50
		Case EVENTCLASS_EVENT_TYPE_51 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_51
		Case EVENTCLASS_EVENT_TYPE_64 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_64
		Case EVENTCLASS_EVENT_TYPE_52 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_52
		Case EVENTCLASS_EVENT_TYPE_53 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_53
		Case EVENTCLASS_EVENT_TYPE_54 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_54
		Case EVENTCLASS_EVENT_TYPE_55 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_55
		Case EVENTCLASS_EVENT_TYPE_56 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_56
		Case EVENTCLASS_EVENT_TYPE_57 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_57
		Case EVENTCLASS_EVENT_TYPE_58 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_58
		Case EVENTCLASS_EVENT_TYPE_59 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_59
		Case EVENTCLASS_EVENT_TYPE_60 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_60
		Case EVENTCLASS_EVENT_TYPE_61 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_61
		Case EVENTCLASS_EVENT_TYPE_62 :
			NameOf_EventClass = NameOf_EVENTCLASS_EVENT_TYPE_62
	End Select
End Function

'----------------------------------------------------------
'	IncidentFinderBehavior - ��������� IncidentFinder
const INCIDENTFINDERBEHAVIOR_OPENVIEW	= 1		' ������� ��������
const INCIDENTFINDERBEHAVIOR_OPENEDITOR	= 2		' ������� ��������
const INCIDENTFINDERBEHAVIOR_OPENINTREE	= 3		' ������� � ������

const NameOf_INCIDENTFINDERBEHAVIOR_OPENVIEW	= "������� ��������"
const NameOf_INCIDENTFINDERBEHAVIOR_OPENEDITOR	= "������� ��������"
const NameOf_INCIDENTFINDERBEHAVIOR_OPENINTREE	= "������� � ������"

Function NameOf_IncidentFinderBehavior(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case INCIDENTFINDERBEHAVIOR_OPENVIEW :
			NameOf_IncidentFinderBehavior = NameOf_INCIDENTFINDERBEHAVIOR_OPENVIEW
		Case INCIDENTFINDERBEHAVIOR_OPENEDITOR :
			NameOf_IncidentFinderBehavior = NameOf_INCIDENTFINDERBEHAVIOR_OPENEDITOR
		Case INCIDENTFINDERBEHAVIOR_OPENINTREE :
			NameOf_IncidentFinderBehavior = NameOf_INCIDENTFINDERBEHAVIOR_OPENINTREE
	End Select
End Function

'----------------------------------------------------------
'	ReportActivityListSortType - ��� ���������� � ������ "������ �����������"
const REPORTACTIVITYLISTSORTTYPE_RANDOM	= 0		' �����������
const REPORTACTIVITYLISTSORTTYPE_BYNAME	= 1		' �� ������������
const REPORTACTIVITYLISTSORTTYPE_BYCODE	= 2		' �� ����
const REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID	= 3		' �� �������������� ��� Navision

const NameOf_REPORTACTIVITYLISTSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAME	= "�� ������������"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYCODE	= "�� ����"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID	= "�� �������������� ��� Navision"

Function NameOf_ReportActivityListSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTACTIVITYLISTSORTTYPE_RANDOM :
			NameOf_ReportActivityListSortType = NameOf_REPORTACTIVITYLISTSORTTYPE_RANDOM
		Case REPORTACTIVITYLISTSORTTYPE_BYNAME :
			NameOf_ReportActivityListSortType = NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAME
		Case REPORTACTIVITYLISTSORTTYPE_BYCODE :
			NameOf_ReportActivityListSortType = NameOf_REPORTACTIVITYLISTSORTTYPE_BYCODE
		Case REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID :
			NameOf_ReportActivityListSortType = NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID
	End Select
End Function

'----------------------------------------------------------
'	UserRoleInProjectFlags - ��� ���� ������������ � �����
const USERROLEINPROJECTFLAGS_PROJECTMANAGER	= 1		' �������� �������
const USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR	= 2		' ������������� �������
const USERROLEINPROJECTFLAGS_CLIENTDIRECTOR	= 4		' �������� �������

const NameOf_USERROLEINPROJECTFLAGS_PROJECTMANAGER	= "�������� �������"
const NameOf_USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR	= "������������� �������"
const NameOf_USERROLEINPROJECTFLAGS_CLIENTDIRECTOR	= "�������� �������"

Function NameOf_UserRoleInProjectFlags(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(USERROLEINPROJECTFLAGS_PROJECTMANAGER) Then sResult = sResult & NameOf_USERROLEINPROJECTFLAGS_PROJECTMANAGER & ","
	If vVal AND CLng(USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR) Then sResult = sResult & NameOf_USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR & ","
	If vVal AND CLng(USERROLEINPROJECTFLAGS_CLIENTDIRECTOR) Then sResult = sResult & NameOf_USERROLEINPROJECTFLAGS_CLIENTDIRECTOR & ","
	If Not IsEmpty(sResult) Then NameOf_UserRoleInProjectFlags = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	STATE_CONTRACT_BUDGET - ��������� ������� �������
const STATE_CONTRACT_BUDGET_WORKING	= 0		' � ����������
const STATE_CONTRACT_BUDGET_TO_FIN_DEP	= 1		' �������� �� ������������ � ���������� ������
const STATE_CONTRACT_BUDGET_FIN_ACCEPTED	= 2		' ����������� ���������� �������
const STATE_CONTRACT_BUDGET_TO_GD	= 3		' �������� �� ������������ ��
const STATE_CONTRACT_BUDGET_GD_ACCEPTED	= 4		' ����������� ��
const STATE_CONTRACT_BUDGET_ACCEPTED	= 5		' ����������

const NameOf_STATE_CONTRACT_BUDGET_WORKING	= "� ����������"
const NameOf_STATE_CONTRACT_BUDGET_TO_FIN_DEP	= "�������� �� ������������ � ���������� ������"
const NameOf_STATE_CONTRACT_BUDGET_FIN_ACCEPTED	= "����������� ���������� �������"
const NameOf_STATE_CONTRACT_BUDGET_TO_GD	= "�������� �� ������������ ��"
const NameOf_STATE_CONTRACT_BUDGET_GD_ACCEPTED	= "����������� ��"
const NameOf_STATE_CONTRACT_BUDGET_ACCEPTED	= "����������"

Function NameOf_STATE_CONTRACT_BUDGET(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case STATE_CONTRACT_BUDGET_WORKING :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_WORKING
		Case STATE_CONTRACT_BUDGET_TO_FIN_DEP :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_TO_FIN_DEP
		Case STATE_CONTRACT_BUDGET_FIN_ACCEPTED :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_FIN_ACCEPTED
		Case STATE_CONTRACT_BUDGET_TO_GD :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_TO_GD
		Case STATE_CONTRACT_BUDGET_GD_ACCEPTED :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_GD_ACCEPTED
		Case STATE_CONTRACT_BUDGET_ACCEPTED :
			NameOf_STATE_CONTRACT_BUDGET = NameOf_STATE_CONTRACT_BUDGET_ACCEPTED
	End Select
End Function

'----------------------------------------------------------
'	ReportProjectParticipantsAndExpensesSortType - ��� ���������� � ������ "������ ���������� � ������ �������"
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM	= 0		' �����������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= 1		' �� ����������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE	= 2		' �� ����������� ��������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT	= 3		' �� ���������� ��������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME	= 4		' �� ���������� �������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME	= 5		' �� ������������ �������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= 6		' �� ���������������� �������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME	= 7		' �� ����� �������������
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME	= 8		' �� ����������� �������

const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= "�� ����������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE	= "�� ����������� ��������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT	= "�� ���������� ��������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME	= "�� ���������� �������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME	= "�� ������������ �������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= "�� ���������������� �������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME	= "�� ����� �������������"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME	= "�� ����������� �������"

Function NameOf_ReportProjectParticipantsAndExpensesSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME
		Case REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME :
			NameOf_ReportProjectParticipantsAndExpensesSortType = NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME
	End Select
End Function

'----------------------------------------------------------
'	ALBUM_TYPE - ��� �������
const ALBUM_TYPE_STUDIO	= 0		' ���������
const ALBUM_TYPE_CONCERT	= 1		' ����������
const ALBUM_TYPE_COLLECTION	= 2		' �������
const ALBUM_TYPE_COVER	= 3		' ������

const NameOf_ALBUM_TYPE_STUDIO	= "���������"
const NameOf_ALBUM_TYPE_CONCERT	= "����������"
const NameOf_ALBUM_TYPE_COLLECTION	= "�������"
const NameOf_ALBUM_TYPE_COVER	= "������"

Function NameOf_ALBUM_TYPE(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ALBUM_TYPE_STUDIO :
			NameOf_ALBUM_TYPE = NameOf_ALBUM_TYPE_STUDIO
		Case ALBUM_TYPE_CONCERT :
			NameOf_ALBUM_TYPE = NameOf_ALBUM_TYPE_CONCERT
		Case ALBUM_TYPE_COLLECTION :
			NameOf_ALBUM_TYPE = NameOf_ALBUM_TYPE_COLLECTION
		Case ALBUM_TYPE_COVER :
			NameOf_ALBUM_TYPE = NameOf_ALBUM_TYPE_COVER
	End Select
End Function

'----------------------------------------------------------
'	PeriodType - ������ �������
const PERIODTYPE_DATEINTERVAL	= 1		' �������� ���
const PERIODTYPE_CURRENTWEEK	= 2		' �� ������� ������
const PERIODTYPE_CURRENTMONTH	= 3		' �� ������� �����
const PERIODTYPE_PREVIOUSMONTH	= 5		' �� ���������� �����
const PERIODTYPE_SELECTEDQUARTER	= 4		' �� �������� �������

const NameOf_PERIODTYPE_DATEINTERVAL	= "�������� ���"
const NameOf_PERIODTYPE_CURRENTWEEK	= "�� ������� ������"
const NameOf_PERIODTYPE_CURRENTMONTH	= "�� ������� �����"
const NameOf_PERIODTYPE_PREVIOUSMONTH	= "�� ���������� �����"
const NameOf_PERIODTYPE_SELECTEDQUARTER	= "�� �������� �������"

Function NameOf_PeriodType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case PERIODTYPE_DATEINTERVAL :
			NameOf_PeriodType = NameOf_PERIODTYPE_DATEINTERVAL
		Case PERIODTYPE_CURRENTWEEK :
			NameOf_PeriodType = NameOf_PERIODTYPE_CURRENTWEEK
		Case PERIODTYPE_CURRENTMONTH :
			NameOf_PeriodType = NameOf_PERIODTYPE_CURRENTMONTH
		Case PERIODTYPE_PREVIOUSMONTH :
			NameOf_PeriodType = NameOf_PERIODTYPE_PREVIOUSMONTH
		Case PERIODTYPE_SELECTEDQUARTER :
			NameOf_PeriodType = NameOf_PERIODTYPE_SELECTEDQUARTER
	End Select
End Function

'----------------------------------------------------------
'	LossDetalization - ����������� �������� �����������
const LOSSDETALIZATION_BYLOSSES	= 1		' �� ��������� ���������
const LOSSDETALIZATION_BYDATES	= 2		' �� �����

const NameOf_LOSSDETALIZATION_BYLOSSES	= "�� ��������� ���������"
const NameOf_LOSSDETALIZATION_BYDATES	= "�� �����"

Function NameOf_LossDetalization(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case LOSSDETALIZATION_BYLOSSES :
			NameOf_LossDetalization = NameOf_LOSSDETALIZATION_BYLOSSES
		Case LOSSDETALIZATION_BYDATES :
			NameOf_LossDetalization = NameOf_LOSSDETALIZATION_BYDATES
	End Select
End Function

'----------------------------------------------------------
'	OBJ_TYPE - ��� ��������
const OBJ_TYPE_CONTRACT	= 0		' �������
const OBJ_TYPE_OUT_CONTRACT	= 1		' ��������� �������
const OBJ_TYPE_LOAN	= 2		' ����
const OBJ_TYPE_OUT_DOC	= 3		' ��������� ��������
const OBJ_TYPE_INC_DOC	= 4		' ��������� ��������
const OBJ_TYPE_OUTCOME	= 5		' ������
const OBJ_TYPE_INCOME	= 6		' ������
const OBJ_TYPE_GENOUT_DOC	= 7		' ����� ��������� ��������
const OBJ_TYPE_GENOUTCOME	= 8		' ����� ������
const OBJ_TYPE_GENINCOME	= 9		' ����� ������
const OBJ_TYPE_BUDGET_OUT	= 10		' ��������� ������
const OBJ_TYPE_KASS_TRANS	= 30		' �������� �� � �����
const OBJ_TYPE_EMP_MONEY_MOVE	= 31		' �������� ��
const OBJ_TYPE_AO	= 32		' ��

const NameOf_OBJ_TYPE_CONTRACT	= "�������"
const NameOf_OBJ_TYPE_OUT_CONTRACT	= "��������� �������"
const NameOf_OBJ_TYPE_LOAN	= "����"
const NameOf_OBJ_TYPE_OUT_DOC	= "��������� ��������"
const NameOf_OBJ_TYPE_INC_DOC	= "��������� ��������"
const NameOf_OBJ_TYPE_OUTCOME	= "������"
const NameOf_OBJ_TYPE_INCOME	= "������"
const NameOf_OBJ_TYPE_GENOUT_DOC	= "����� ��������� ��������"
const NameOf_OBJ_TYPE_GENOUTCOME	= "����� ������"
const NameOf_OBJ_TYPE_GENINCOME	= "����� ������"
const NameOf_OBJ_TYPE_BUDGET_OUT	= "��������� ������"
const NameOf_OBJ_TYPE_KASS_TRANS	= "�������� �� � �����"
const NameOf_OBJ_TYPE_EMP_MONEY_MOVE	= "�������� ��"
const NameOf_OBJ_TYPE_AO	= "��"

Function NameOf_OBJ_TYPE(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case OBJ_TYPE_CONTRACT :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_CONTRACT
		Case OBJ_TYPE_OUT_CONTRACT :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_OUT_CONTRACT
		Case OBJ_TYPE_LOAN :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_LOAN
		Case OBJ_TYPE_OUT_DOC :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_OUT_DOC
		Case OBJ_TYPE_INC_DOC :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_INC_DOC
		Case OBJ_TYPE_OUTCOME :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_OUTCOME
		Case OBJ_TYPE_INCOME :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_INCOME
		Case OBJ_TYPE_GENOUT_DOC :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_GENOUT_DOC
		Case OBJ_TYPE_GENOUTCOME :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_GENOUTCOME
		Case OBJ_TYPE_GENINCOME :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_GENINCOME
		Case OBJ_TYPE_BUDGET_OUT :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_BUDGET_OUT
		Case OBJ_TYPE_KASS_TRANS :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_KASS_TRANS
		Case OBJ_TYPE_EMP_MONEY_MOVE :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_EMP_MONEY_MOVE
		Case OBJ_TYPE_AO :
			NameOf_OBJ_TYPE = NameOf_OBJ_TYPE_AO
	End Select
End Function

'----------------------------------------------------------
'	ActivityAnalysDepth - ������� ������� �����������
const ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY	= 0		' ������ ��������� ����������
const ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES	= 1		' ����������� ���������� 1 ������
const ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES	= 2		' ����������� ���������� ���� �������

const NameOf_ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY	= "������ ��������� ����������"
const NameOf_ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES	= "����������� ���������� 1 ������"
const NameOf_ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES	= "����������� ���������� ���� �������"

Function NameOf_ActivityAnalysDepth(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY :
			NameOf_ActivityAnalysDepth = NameOf_ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY
		Case ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES :
			NameOf_ActivityAnalysDepth = NameOf_ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES
		Case ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES :
			NameOf_ActivityAnalysDepth = NameOf_ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES
	End Select
End Function

'----------------------------------------------------------
'	LotsAndParticipantsSortType - ��� ���������� ����� � ����������
const LOTSANDPARTICIPANTSSORTTYPE_RANDOM	= 0		' �����������
const LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME	= 1		' �� ������������ ��������
const LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME	= 2		' �� ������������ ���������
const LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE	= 3		' �� ���� ����������

const NameOf_LOTSANDPARTICIPANTSSORTTYPE_RANDOM	= "�����������"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME	= "�� ������������ ��������"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME	= "�� ������������ ���������"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE	= "�� ���� ����������"

Function NameOf_LotsAndParticipantsSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case LOTSANDPARTICIPANTSSORTTYPE_RANDOM :
			NameOf_LotsAndParticipantsSortType = NameOf_LOTSANDPARTICIPANTSSORTTYPE_RANDOM
		Case LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME :
			NameOf_LotsAndParticipantsSortType = NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME
		Case LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME :
			NameOf_LotsAndParticipantsSortType = NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME
		Case LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE :
			NameOf_LotsAndParticipantsSortType = NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE
	End Select
End Function

'----------------------------------------------------------
'	DateDetalization - ����������� �� �����
const DATEDETALIZATION_NODATE	= 0		' ��� ��� (������ ������� ������)
const DATEDETALIZATION_EXPENCESDATE	= 1		' ���� � ��������� (��� �������, ������� ������)
const DATEDETALIZATION_ALLDATE	= 2		' ��� ���� (��� ������� ������)

const NameOf_DATEDETALIZATION_NODATE	= "��� ��� (������ ������� ������)"
const NameOf_DATEDETALIZATION_EXPENCESDATE	= "���� � ��������� (��� �������, ������� ������)"
const NameOf_DATEDETALIZATION_ALLDATE	= "��� ���� (��� ������� ������)"

Function NameOf_DateDetalization(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DATEDETALIZATION_NODATE :
			NameOf_DateDetalization = NameOf_DATEDETALIZATION_NODATE
		Case DATEDETALIZATION_EXPENCESDATE :
			NameOf_DateDetalization = NameOf_DATEDETALIZATION_EXPENCESDATE
		Case DATEDETALIZATION_ALLDATE :
			NameOf_DateDetalization = NameOf_DATEDETALIZATION_ALLDATE
	End Select
End Function

'----------------------------------------------------------
'	PARTICIPATIONS - ��� �������
const PARTICIPATIONS_PARTICIPANT	= 1		' ��������
const PARTICIPATIONS_COMPETITOR	= 2		' ���������
const PARTICIPATIONS_HELPER	= 3		' �������������

const NameOf_PARTICIPATIONS_PARTICIPANT	= "��������"
const NameOf_PARTICIPATIONS_COMPETITOR	= "���������"
const NameOf_PARTICIPATIONS_HELPER	= "�������������"

Function NameOf_PARTICIPATIONS(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case PARTICIPATIONS_PARTICIPANT :
			NameOf_PARTICIPATIONS = NameOf_PARTICIPATIONS_PARTICIPANT
		Case PARTICIPATIONS_COMPETITOR :
			NameOf_PARTICIPATIONS = NameOf_PARTICIPATIONS_COMPETITOR
		Case PARTICIPATIONS_HELPER :
			NameOf_PARTICIPATIONS = NameOf_PARTICIPATIONS_HELPER
	End Select
End Function

'----------------------------------------------------------
'	StdObjectPrivileges - ����������� ��������� ����������
const STDOBJECTPRIVILEGES_CREATE	= 1		' ��������
const STDOBJECTPRIVILEGES_EDIT	= 2		' ��������������
const STDOBJECTPRIVILEGES_DELETE	= 4		' ��������
const STDOBJECTPRIVILEGES_READ	= 8		' ������

const NameOf_STDOBJECTPRIVILEGES_CREATE	= "��������"
const NameOf_STDOBJECTPRIVILEGES_EDIT	= "��������������"
const NameOf_STDOBJECTPRIVILEGES_DELETE	= "��������"
const NameOf_STDOBJECTPRIVILEGES_READ	= "������"

Function NameOf_StdObjectPrivileges(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(STDOBJECTPRIVILEGES_CREATE) Then sResult = sResult & NameOf_STDOBJECTPRIVILEGES_CREATE & ","
	If vVal AND CLng(STDOBJECTPRIVILEGES_EDIT) Then sResult = sResult & NameOf_STDOBJECTPRIVILEGES_EDIT & ","
	If vVal AND CLng(STDOBJECTPRIVILEGES_DELETE) Then sResult = sResult & NameOf_STDOBJECTPRIVILEGES_DELETE & ","
	If vVal AND CLng(STDOBJECTPRIVILEGES_READ) Then sResult = sResult & NameOf_STDOBJECTPRIVILEGES_READ & ","
	If Not IsEmpty(sResult) Then NameOf_StdObjectPrivileges = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_OptColsFlags - ������������ ������� ������ "��������� ������ �������������"
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE	= 1		' ����� �������� �������
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE	= 2		' ���������
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION	= 4		' ����������� ����������
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION	= 8		' ������� ��������

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE	= "����� �������� �������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE	= "���������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION	= "����������� ����������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION	= "������� ��������"

Function NameOf_RepDepartmentExpensesStructure_OptColsFlags(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE) Then sResult = sResult & NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE & ","
	If vVal AND CLng(REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE) Then sResult = sResult & NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE & ","
	If vVal AND CLng(REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION) Then sResult = sResult & NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION & ","
	If vVal AND CLng(REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION) Then sResult = sResult & NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION & ","
	If Not IsEmpty(sResult) Then NameOf_RepDepartmentExpensesStructure_OptColsFlags = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	IncidentPriority - ��������� ���������
const INCIDENTPRIORITY_HIGH	= 1		' �������
const INCIDENTPRIORITY_NORMAL	= 2		' �������
const INCIDENTPRIORITY_LOW	= 3		' ������

const NameOf_INCIDENTPRIORITY_HIGH	= "�������"
const NameOf_INCIDENTPRIORITY_NORMAL	= "�������"
const NameOf_INCIDENTPRIORITY_LOW	= "������"

Function NameOf_IncidentPriority(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case INCIDENTPRIORITY_HIGH :
			NameOf_IncidentPriority = NameOf_INCIDENTPRIORITY_HIGH
		Case INCIDENTPRIORITY_NORMAL :
			NameOf_IncidentPriority = NameOf_INCIDENTPRIORITY_NORMAL
		Case INCIDENTPRIORITY_LOW :
			NameOf_IncidentPriority = NameOf_INCIDENTPRIORITY_LOW
	End Select
End Function

'----------------------------------------------------------
'	IncidentSortFields - ���� ���������� ����������
const INCIDENTSORTFIELDS_NAME	= "Name"		' ������������
const INCIDENTSORTFIELDS_NUMBER	= "Number"		' �����
const INCIDENTSORTFIELDS_PRIORITY	= "Priority"		' ���������
const INCIDENTSORTFIELDS_CATEGORY	= "Category"		' ��������� ���������

const NameOf_INCIDENTSORTFIELDS_NAME	= "������������"
const NameOf_INCIDENTSORTFIELDS_NUMBER	= "�����"
const NameOf_INCIDENTSORTFIELDS_PRIORITY	= "���������"
const NameOf_INCIDENTSORTFIELDS_CATEGORY	= "��������� ���������"

Function NameOf_IncidentSortFields(ByVal vVal)
	Select Case vVal
		Case INCIDENTSORTFIELDS_NAME :
			NameOf_IncidentSortFields = NameOf_INCIDENTSORTFIELDS_NAME
		Case INCIDENTSORTFIELDS_NUMBER :
			NameOf_IncidentSortFields = NameOf_INCIDENTSORTFIELDS_NUMBER
		Case INCIDENTSORTFIELDS_PRIORITY :
			NameOf_IncidentSortFields = NameOf_INCIDENTSORTFIELDS_PRIORITY
		Case INCIDENTSORTFIELDS_CATEGORY :
			NameOf_IncidentSortFields = NameOf_INCIDENTSORTFIELDS_CATEGORY
	End Select
End Function

'----------------------------------------------------------
'	EmployeeHistoryEvents - ��� ������� ����������
const EMPLOYEEHISTORYEVENTS_WORKBEGINDAY	= 1		' ����� �� ������
const EMPLOYEEHISTORYEVENTS_WORKENDDAY	= 2		' ��������� ������
const EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY	= 3		' �������� ���������������
const EMPLOYEEHISTORYEVENTS_CHANGERATE	= 4		' ��������� ����� �������� �������
const EMPLOYEEHISTORYEVENTS_CHANGESECURITY	= 5		' ��������� ���������� ������������

const NameOf_EMPLOYEEHISTORYEVENTS_WORKBEGINDAY	= "����� �� ������"
const NameOf_EMPLOYEEHISTORYEVENTS_WORKENDDAY	= "��������� ������"
const NameOf_EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY	= "�������� ���������������"
const NameOf_EMPLOYEEHISTORYEVENTS_CHANGERATE	= "��������� ����� �������� �������"
const NameOf_EMPLOYEEHISTORYEVENTS_CHANGESECURITY	= "��������� ���������� ������������"

Function NameOf_EmployeeHistoryEvents(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case EMPLOYEEHISTORYEVENTS_WORKBEGINDAY :
			NameOf_EmployeeHistoryEvents = NameOf_EMPLOYEEHISTORYEVENTS_WORKBEGINDAY
		Case EMPLOYEEHISTORYEVENTS_WORKENDDAY :
			NameOf_EmployeeHistoryEvents = NameOf_EMPLOYEEHISTORYEVENTS_WORKENDDAY
		Case EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY :
			NameOf_EmployeeHistoryEvents = NameOf_EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY
		Case EMPLOYEEHISTORYEVENTS_CHANGERATE :
			NameOf_EmployeeHistoryEvents = NameOf_EMPLOYEEHISTORYEVENTS_CHANGERATE
		Case EMPLOYEEHISTORYEVENTS_CHANGESECURITY :
			NameOf_EmployeeHistoryEvents = NameOf_EMPLOYEEHISTORYEVENTS_CHANGESECURITY
	End Select
End Function

'----------------------------------------------------------
'	ServiceSystemType - ��� ������� ������������
const SERVICESYSTEMTYPE_URL	= 1		' ������ URL
const SERVICESYSTEMTYPE_FILELINK	= 2		' ������ �� ����
const SERVICESYSTEMTYPE_DIRECTORYLINK	= 3		' ������ �� �����
const SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	= 4		' ������ �� ���� � Documentum
const SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	= 5		' ������ �� ����� � Documentum

const NameOf_SERVICESYSTEMTYPE_URL	= "������ URL"
const NameOf_SERVICESYSTEMTYPE_FILELINK	= "������ �� ����"
const NameOf_SERVICESYSTEMTYPE_DIRECTORYLINK	= "������ �� �����"
const NameOf_SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	= "������ �� ���� � Documentum"
const NameOf_SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	= "������ �� ����� � Documentum"

Function NameOf_ServiceSystemType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SERVICESYSTEMTYPE_URL :
			NameOf_ServiceSystemType = NameOf_SERVICESYSTEMTYPE_URL
		Case SERVICESYSTEMTYPE_FILELINK :
			NameOf_ServiceSystemType = NameOf_SERVICESYSTEMTYPE_FILELINK
		Case SERVICESYSTEMTYPE_DIRECTORYLINK :
			NameOf_ServiceSystemType = NameOf_SERVICESYSTEMTYPE_DIRECTORYLINK
		Case SERVICESYSTEMTYPE_DOCUMENTUMFILELINK :
			NameOf_ServiceSystemType = NameOf_SERVICESYSTEMTYPE_DOCUMENTUMFILELINK
		Case SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK :
			NameOf_ServiceSystemType = NameOf_SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK
	End Select
End Function

'----------------------------------------------------------
'	GK_INSTR_LOCATION - �������������� �����������
const GK_INSTR_LOCATION_WAITING	= 0		' � ��������
const GK_INSTR_LOCATION_IN_COLLECTION	= 1		' � ���������
const GK_INSTR_LOCATION_FOR_SALE	= 2		' �� �������
const GK_INSTR_LOCATION_SALED	= 3		' �������

const NameOf_GK_INSTR_LOCATION_WAITING	= "� ��������"
const NameOf_GK_INSTR_LOCATION_IN_COLLECTION	= "� ���������"
const NameOf_GK_INSTR_LOCATION_FOR_SALE	= "�� �������"
const NameOf_GK_INSTR_LOCATION_SALED	= "�������"

Function NameOf_GK_INSTR_LOCATION(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case GK_INSTR_LOCATION_WAITING :
			NameOf_GK_INSTR_LOCATION = NameOf_GK_INSTR_LOCATION_WAITING
		Case GK_INSTR_LOCATION_IN_COLLECTION :
			NameOf_GK_INSTR_LOCATION = NameOf_GK_INSTR_LOCATION_IN_COLLECTION
		Case GK_INSTR_LOCATION_FOR_SALE :
			NameOf_GK_INSTR_LOCATION = NameOf_GK_INSTR_LOCATION_FOR_SALE
		Case GK_INSTR_LOCATION_SALED :
			NameOf_GK_INSTR_LOCATION = NameOf_GK_INSTR_LOCATION_SALED
	End Select
End Function

'----------------------------------------------------------
'	SortDirections - ����������� ����������
const SORTDIRECTIONS_ASC	= 1		' �� �����������
const SORTDIRECTIONS_DESC	= 2		' �� ��������
const SORTDIRECTIONS_IGNORE	= 3		' ������������

const NameOf_SORTDIRECTIONS_ASC	= "�� �����������"
const NameOf_SORTDIRECTIONS_DESC	= "�� ��������"
const NameOf_SORTDIRECTIONS_IGNORE	= "������������"

Function NameOf_SortDirections(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SORTDIRECTIONS_ASC :
			NameOf_SortDirections = NameOf_SORTDIRECTIONS_ASC
		Case SORTDIRECTIONS_DESC :
			NameOf_SortDirections = NameOf_SORTDIRECTIONS_DESC
		Case SORTDIRECTIONS_IGNORE :
			NameOf_SortDirections = NameOf_SORTDIRECTIONS_IGNORE
	End Select
End Function

'----------------------------------------------------------
'	ReportDepartmentCostSort - ���������� ������ "������� � ������� �������������"
const REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT	= 0		' �� �������������
const REPORTDEPARTMENTCOSTSORT_COSTSORT	= 1		' �� ��������

const NameOf_REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT	= "�� �������������"
const NameOf_REPORTDEPARTMENTCOSTSORT_COSTSORT	= "�� ��������"

Function NameOf_ReportDepartmentCostSort(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT :
			NameOf_ReportDepartmentCostSort = NameOf_REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT
		Case REPORTDEPARTMENTCOSTSORT_COSTSORT :
			NameOf_ReportDepartmentCostSort = NameOf_REPORTDEPARTMENTCOSTSORT_COSTSORT
	End Select
End Function

'----------------------------------------------------------
'	LotState - ��������� ����
const LOTSTATE_PARTICIPATING	= 2		' �������
const LOTSTATE_PARTICIPATEREJECTION	= 3		' ����� �� �������
const LOTSTATE_UNDERCONSIDERATION	= 4		' ������������ �����������
const LOTSTATE_WASGAIN	= 5		' �������
const LOTSTATE_WASLOSS	= 6		' ��������
const LOTSTATE_WASABOLISH	= 7		' �������

const NameOf_LOTSTATE_PARTICIPATING	= "�������"
const NameOf_LOTSTATE_PARTICIPATEREJECTION	= "����� �� �������"
const NameOf_LOTSTATE_UNDERCONSIDERATION	= "������������ �����������"
const NameOf_LOTSTATE_WASGAIN	= "�������"
const NameOf_LOTSTATE_WASLOSS	= "��������"
const NameOf_LOTSTATE_WASABOLISH	= "�������"

Function NameOf_LotState(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case LOTSTATE_PARTICIPATING :
			NameOf_LotState = NameOf_LOTSTATE_PARTICIPATING
		Case LOTSTATE_PARTICIPATEREJECTION :
			NameOf_LotState = NameOf_LOTSTATE_PARTICIPATEREJECTION
		Case LOTSTATE_UNDERCONSIDERATION :
			NameOf_LotState = NameOf_LOTSTATE_UNDERCONSIDERATION
		Case LOTSTATE_WASGAIN :
			NameOf_LotState = NameOf_LOTSTATE_WASGAIN
		Case LOTSTATE_WASLOSS :
			NameOf_LotState = NameOf_LOTSTATE_WASLOSS
		Case LOTSTATE_WASABOLISH :
			NameOf_LotState = NameOf_LOTSTATE_WASABOLISH
	End Select
End Function

'----------------------------------------------------------
'	DepartmentAnalysDepth - ������� ������� �������������
const DEPARTMENTANALYSDEPTH_ONLYSELECTED	= 0		' ������ ��������� �������������
const DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL	= 1		' ����������� ������������� 1 ������
const DEPARTMENTANALYSDEPTH_ALLSUBLEVELS	= 2		' ����������� ������������� ���� �������

const NameOf_DEPARTMENTANALYSDEPTH_ONLYSELECTED	= "������ ��������� �������������"
const NameOf_DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL	= "����������� ������������� 1 ������"
const NameOf_DEPARTMENTANALYSDEPTH_ALLSUBLEVELS	= "����������� ������������� ���� �������"

Function NameOf_DepartmentAnalysDepth(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DEPARTMENTANALYSDEPTH_ONLYSELECTED :
			NameOf_DepartmentAnalysDepth = NameOf_DEPARTMENTANALYSDEPTH_ONLYSELECTED
		Case DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL :
			NameOf_DepartmentAnalysDepth = NameOf_DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL
		Case DEPARTMENTANALYSDEPTH_ALLSUBLEVELS :
			NameOf_DepartmentAnalysDepth = NameOf_DEPARTMENTANALYSDEPTH_ALLSUBLEVELS
	End Select
End Function

'----------------------------------------------------------
'	FolderHistoryEvents - ��� ������� �����
const FOLDERHISTORYEVENTS_WAITINGTOCLOSE	= 1		' �������� ��������
const FOLDERHISTORYEVENTS_CLOSING	= 2		' ��������
const FOLDERHISTORYEVENTS_OPENING	= 3		' ��������
const FOLDERHISTORYEVENTS_FROZING	= 4		' �������������
const FOLDERHISTORYEVENTS_UPGRADEFROMPILOT	= 6		' ������� �� �������� ������
const FOLDERHISTORYEVENTS_BLOCKDATECHANGING	= 7		' ��������� ���� ������������ ��������
const FOLDERHISTORYEVENTS_LINKTOFOLLOWING	= 8		' ������������ ����� � ����������� �����������
const FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING	= 9		' ������ ����� � ����������� �����������
const FOLDERHISTORYEVENTS_CREATING	= 10		' ��������
const FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING	= 11		' ��������� ������ �� ������������
const FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE	= 12		' ���������� �������� �� �����
const FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE	= 13		' ���������� �������� �� �����

const NameOf_FOLDERHISTORYEVENTS_WAITINGTOCLOSE	= "�������� ��������"
const NameOf_FOLDERHISTORYEVENTS_CLOSING	= "��������"
const NameOf_FOLDERHISTORYEVENTS_OPENING	= "��������"
const NameOf_FOLDERHISTORYEVENTS_FROZING	= "�������������"
const NameOf_FOLDERHISTORYEVENTS_UPGRADEFROMPILOT	= "������� �� �������� ������"
const NameOf_FOLDERHISTORYEVENTS_BLOCKDATECHANGING	= "��������� ���� ������������ ��������"
const NameOf_FOLDERHISTORYEVENTS_LINKTOFOLLOWING	= "������������ ����� � ����������� �����������"
const NameOf_FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING	= "������ ����� � ����������� �����������"
const NameOf_FOLDERHISTORYEVENTS_CREATING	= "��������"
const NameOf_FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING	= "��������� ������ �� ������������"
const NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE	= "���������� �������� �� �����"
const NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE	= "���������� �������� �� �����"

Function NameOf_FolderHistoryEvents(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case FOLDERHISTORYEVENTS_WAITINGTOCLOSE :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_WAITINGTOCLOSE
		Case FOLDERHISTORYEVENTS_CLOSING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_CLOSING
		Case FOLDERHISTORYEVENTS_OPENING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_OPENING
		Case FOLDERHISTORYEVENTS_FROZING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_FROZING
		Case FOLDERHISTORYEVENTS_UPGRADEFROMPILOT :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_UPGRADEFROMPILOT
		Case FOLDERHISTORYEVENTS_BLOCKDATECHANGING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_BLOCKDATECHANGING
		Case FOLDERHISTORYEVENTS_LINKTOFOLLOWING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_LINKTOFOLLOWING
		Case FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING
		Case FOLDERHISTORYEVENTS_CREATING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_CREATING
		Case FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING
		Case FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE
		Case FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE :
			NameOf_FolderHistoryEvents = NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE
	End Select
End Function

'----------------------------------------------------------
'	ReportEmployeesBusynessInProjectsSortType - ��� ���������� � ������ "��������� ����������� � ��������"
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM	= 0		' �����������
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER	= 1		' �� ��������
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER	= 2		' �� ����������
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE	= 3		' �� �������������

const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER	= "�� ��������"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER	= "�� ����������"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE	= "�� �������������"

Function NameOf_ReportEmployeesBusynessInProjectsSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM :
			NameOf_ReportEmployeesBusynessInProjectsSortType = NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM
		Case REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER :
			NameOf_ReportEmployeesBusynessInProjectsSortType = NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER
		Case REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER :
			NameOf_ReportEmployeesBusynessInProjectsSortType = NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER
		Case REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE :
			NameOf_ReportEmployeesBusynessInProjectsSortType = NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE
	End Select
End Function

'----------------------------------------------------------
'	DepartmentType - ��� �������������
const DEPARTMENTTYPE_COSTSCENTER	= 1		' ����� ������
const DEPARTMENTTYPE_PROFITCENTER	= 2		' ����� �������
const DEPARTMENTTYPE_DIRECTION	= 3		' �����

const NameOf_DEPARTMENTTYPE_COSTSCENTER	= "����� ������"
const NameOf_DEPARTMENTTYPE_PROFITCENTER	= "����� �������"
const NameOf_DEPARTMENTTYPE_DIRECTION	= "�����"

Function NameOf_DepartmentType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DEPARTMENTTYPE_COSTSCENTER :
			NameOf_DepartmentType = NameOf_DEPARTMENTTYPE_COSTSCENTER
		Case DEPARTMENTTYPE_PROFITCENTER :
			NameOf_DepartmentType = NameOf_DEPARTMENTTYPE_PROFITCENTER
		Case DEPARTMENTTYPE_DIRECTION :
			NameOf_DepartmentType = NameOf_DEPARTMENTTYPE_DIRECTION
	End Select
End Function

'----------------------------------------------------------
'	IPROP_TYPE - ��� �������� ���������
const IPROP_TYPE_IPROP_TYPE_LONG	= 1		' ����� �����
const IPROP_TYPE_IPROP_TYPE_DOUBLE	= 2		' ����� � ��������� ������
const IPROP_TYPE_IPROP_TYPE_DATE	= 3		' ����
const IPROP_TYPE_IPROP_TYPE_TIME	= 4		' �����
const IPROP_TYPE_IPROP_TYPE_DATEANDTIME	= 5		' ���� � �����
const IPROP_TYPE_IPROP_TYPE_BOOLEAN	= 6		' ���������� �������
const IPROP_TYPE_IPROP_TYPE_STRING	= 7		' ������ (�� 4000 ��������)
const IPROP_TYPE_IPROP_TYPE_TEXT	= 8		' ����� (����� 4000 ��������)
const IPROP_TYPE_IPROP_TYPE_PICTURE	= 9		' �����������
const IPROP_TYPE_IPROP_TYPE_FILE	= 10		' ����

const NameOf_IPROP_TYPE_IPROP_TYPE_LONG	= "����� �����"
const NameOf_IPROP_TYPE_IPROP_TYPE_DOUBLE	= "����� � ��������� ������"
const NameOf_IPROP_TYPE_IPROP_TYPE_DATE	= "����"
const NameOf_IPROP_TYPE_IPROP_TYPE_TIME	= "�����"
const NameOf_IPROP_TYPE_IPROP_TYPE_DATEANDTIME	= "���� � �����"
const NameOf_IPROP_TYPE_IPROP_TYPE_BOOLEAN	= "���������� �������"
const NameOf_IPROP_TYPE_IPROP_TYPE_STRING	= "������ (�� 4000 ��������)"
const NameOf_IPROP_TYPE_IPROP_TYPE_TEXT	= "����� (����� 4000 ��������)"
const NameOf_IPROP_TYPE_IPROP_TYPE_PICTURE	= "�����������"
const NameOf_IPROP_TYPE_IPROP_TYPE_FILE	= "����"

Function NameOf_IPROP_TYPE(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case IPROP_TYPE_IPROP_TYPE_LONG :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_LONG
		Case IPROP_TYPE_IPROP_TYPE_DOUBLE :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_DOUBLE
		Case IPROP_TYPE_IPROP_TYPE_DATE :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_DATE
		Case IPROP_TYPE_IPROP_TYPE_TIME :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_TIME
		Case IPROP_TYPE_IPROP_TYPE_DATEANDTIME :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_DATEANDTIME
		Case IPROP_TYPE_IPROP_TYPE_BOOLEAN :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_BOOLEAN
		Case IPROP_TYPE_IPROP_TYPE_STRING :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_STRING
		Case IPROP_TYPE_IPROP_TYPE_TEXT :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_TEXT
		Case IPROP_TYPE_IPROP_TYPE_PICTURE :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_PICTURE
		Case IPROP_TYPE_IPROP_TYPE_FILE :
			NameOf_IPROP_TYPE = NameOf_IPROP_TYPE_IPROP_TYPE_FILE
	End Select
End Function

'----------------------------------------------------------
'	ShowedAttrs - ������������ ��������
const SHOWEDATTRS_PRIORITY	= 1		' ���������

const NameOf_SHOWEDATTRS_PRIORITY	= "���������"

Function NameOf_ShowedAttrs(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SHOWEDATTRS_PRIORITY :
			NameOf_ShowedAttrs = NameOf_SHOWEDATTRS_PRIORITY
	End Select
End Function

'----------------------------------------------------------
'	AnalysDirection - ����������� �������
const ANALYSDIRECTION_LASTYEAREXPENSES	= 0		' �� ��������� ������
const ANALYSDIRECTION_OPENEDINCIDENTS	= 1		' �������� ���������

const NameOf_ANALYSDIRECTION_LASTYEAREXPENSES	= "�� ��������� ������"
const NameOf_ANALYSDIRECTION_OPENEDINCIDENTS	= "�������� ���������"

Function NameOf_AnalysDirection(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ANALYSDIRECTION_LASTYEAREXPENSES :
			NameOf_AnalysDirection = NameOf_ANALYSDIRECTION_LASTYEAREXPENSES
		Case ANALYSDIRECTION_OPENEDINCIDENTS :
			NameOf_AnalysDirection = NameOf_ANALYSDIRECTION_OPENEDINCIDENTS
	End Select
End Function

'----------------------------------------------------------
'	ReportTimeLossesSortType - ��� ���������� � ������ "�������� ������� ������������"
const REPORTTIMELOSSESSORTTYPE_RANDOM	= 0		' �����������
const REPORTTIMELOSSESSORTTYPE_BYCAUSE	= 1		' �� ������� ��������
const REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE	= 2		' �� ����������
const REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED	= 3		' �� ���� ��������

const NameOf_REPORTTIMELOSSESSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYCAUSE	= "�� ������� ��������"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE	= "�� ����������"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED	= "�� ���� ��������"

Function NameOf_ReportTimeLossesSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTTIMELOSSESSORTTYPE_RANDOM :
			NameOf_ReportTimeLossesSortType = NameOf_REPORTTIMELOSSESSORTTYPE_RANDOM
		Case REPORTTIMELOSSESSORTTYPE_BYCAUSE :
			NameOf_ReportTimeLossesSortType = NameOf_REPORTTIMELOSSESSORTTYPE_BYCAUSE
		Case REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE :
			NameOf_ReportTimeLossesSortType = NameOf_REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE
		Case REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED :
			NameOf_ReportTimeLossesSortType = NameOf_REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED
	End Select
End Function

'----------------------------------------------------------
'	ReportProjectIncidentsAndExpensesSortType - ��� ���������� � ������ "������ ���������� � ������ �������"
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM	= 0		' �����������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT	= 1		' �� ���������/��������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION	= 2		' �� �������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE	= 3		' �� ���������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY	= 4		' �� ����������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE	= 5		' �� ���� �������� �����
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE	= 6		' �� ���� ��������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE	= 7		' �� ���� ��������� ����� ���������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT	= 8		' �� ���� ��������� ������� �������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE	= 9		' �� ����
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= 10		' �� ����������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= 11		' �� ���������������� �������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME	= 12		' �� ����� �������������
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME	= 13		' �� ����������� �������

const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT	= "�� ���������/��������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION	= "�� �������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE	= "�� ���������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY	= "�� ����������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE	= "�� ���� �������� �����"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE	= "�� ���� ��������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE	= "�� ���� ��������� ����� ���������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT	= "�� ���� ��������� ������� �������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE	= "�� ����"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= "�� ����������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= "�� ���������������� �������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME	= "�� ����� �������������"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME	= "�� ����������� �������"

Function NameOf_ReportProjectIncidentsAndExpensesSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME
		Case REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME :
			NameOf_ReportProjectIncidentsAndExpensesSortType = NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME
	End Select
End Function

'----------------------------------------------------------
'	TimeMeasureUnits - ������� ��������� �������
const TIMEMEASUREUNITS_DAYS	= 0		' ���, ����, ������
const TIMEMEASUREUNITS_HOURS	= 1		' ����

const NameOf_TIMEMEASUREUNITS_DAYS	= "���, ����, ������"
const NameOf_TIMEMEASUREUNITS_HOURS	= "����"

Function NameOf_TimeMeasureUnits(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case TIMEMEASUREUNITS_DAYS :
			NameOf_TimeMeasureUnits = NameOf_TIMEMEASUREUNITS_DAYS
		Case TIMEMEASUREUNITS_HOURS :
			NameOf_TimeMeasureUnits = NameOf_TIMEMEASUREUNITS_HOURS
	End Select
End Function

'----------------------------------------------------------
'	Quarter - �������
const QUARTER_FIRST	= 1		' 1-�
const QUARTER_SECOND	= 2		' 2-�
const QUARTER_THIRD	= 3		' 3-�
const QUARTER_FOURTH	= 4		' 4-�

const NameOf_QUARTER_FIRST	= "1-�"
const NameOf_QUARTER_SECOND	= "2-�"
const NameOf_QUARTER_THIRD	= "3-�"
const NameOf_QUARTER_FOURTH	= "4-�"

Function NameOf_Quarter(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case QUARTER_FIRST :
			NameOf_Quarter = NameOf_QUARTER_FIRST
		Case QUARTER_SECOND :
			NameOf_Quarter = NameOf_QUARTER_SECOND
		Case QUARTER_THIRD :
			NameOf_Quarter = NameOf_QUARTER_THIRD
		Case QUARTER_FOURTH :
			NameOf_Quarter = NameOf_QUARTER_FOURTH
	End Select
End Function

'----------------------------------------------------------
'	DepartmentDetalization - ����������� ������ �������� � ������� ������������⻻ 
const DEPARTMENTDETALIZATION_WITHOUTDETALIZATION	= 0		' ��� �����������
const DEPARTMENTDETALIZATION_BYDEPARTMENT	= 1		' �� �������������

const NameOf_DEPARTMENTDETALIZATION_WITHOUTDETALIZATION	= "��� �����������"
const NameOf_DEPARTMENTDETALIZATION_BYDEPARTMENT	= "�� �������������"

Function NameOf_DepartmentDetalization(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DEPARTMENTDETALIZATION_WITHOUTDETALIZATION :
			NameOf_DepartmentDetalization = NameOf_DEPARTMENTDETALIZATION_WITHOUTDETALIZATION
		Case DEPARTMENTDETALIZATION_BYDEPARTMENT :
			NameOf_DepartmentDetalization = NameOf_DEPARTMENTDETALIZATION_BYDEPARTMENT
	End Select
End Function

'----------------------------------------------------------
'	NDS_PRICE - ��� ����
const NDS_PRICE_NO_NDS	= 0		' ��� ���
const NDS_PRICE_NDS	= 1		' c ���

const NameOf_NDS_PRICE_NO_NDS	= "��� ���"
const NameOf_NDS_PRICE_NDS	= "c ���"

Function NameOf_NDS_PRICE(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case NDS_PRICE_NO_NDS :
			NameOf_NDS_PRICE = NameOf_NDS_PRICE_NO_NDS
		Case NDS_PRICE_NDS :
			NameOf_NDS_PRICE = NameOf_NDS_PRICE_NDS
	End Select
End Function

'----------------------------------------------------------
'	SystemPrivileges - ��������� ����������
const SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW	= 1		' ��������� workflow ����������
const SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD	= 2		' ��������� ����������� ������� ������������ ��������
const SYSTEMPRIVILEGES_MANAGEUSERS	= 4		' ���������� ��������������
const SYSTEMPRIVILEGES_MANAGETIMELOSS	= 8		' ���������� ������ ����������
const SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT	= 16		' ���������� ��������� ��������� �����������
const SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT	= 32		' ���������� �������������
const SYSTEMPRIVILEGES_MANAGEREFOBJECTS	= 64		' ���������� �������������
const SYSTEMPRIVILEGES_ACCESSINTOTMS	= 128		' ������ � ������� ����� ��������
const SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS	= 256		' ������� ����� � ����������
const SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS	= 512		' �������� ���� �����������
const SYSTEMPRIVILEGES_CHANGETEMPORGONCONST	= 4096		' ������ ���������� �������� ����������� ����������
const SYSTEMPRIVILEGES_DECIDINGMANINTMS	= 8192		' ����������� ������� � ���
const SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS	= 16384		' ���������� ������������� ���
const SYSTEMPRIVILEGES_CLOSEANYFOLDER	= 32768		' �������� �����������
const SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT	= 65536		' ���������� ����� �������� ��������
const SYSTEMPRIVILEGES_MANAGEPROJECTTEAM	= 131072		' ���������� ��������� ��������
const SYSTEMPRIVILEGES_MANAGECONTRACTS	= 262144		' ���������� �����������
const SYSTEMPRIVILEGES_MANAGEPROJINCOUT	= 524288		' ���������� ���������� ��������� � ���������
const SYSTEMPRIVILEGES_MANAGEINCOUT	= 1048576		' ���������� ��������� � ���������
const SYSTEMPRIVILEGES_MANAGELOAN	= 2097152		' ���������� �������
const SYSTEMPRIVILEGES_MANAGEFOT	= 4194304		' ���������� ���
const SYSTEMPRIVILEGES_ACCESSFINREPORTS	= 8388608		' ���������� ����������
const SYSTEMPRIVILEGES_CASHMANAGEMENT	= 16777216		' ���������� ������

const NameOf_SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW	= "��������� workflow ����������"
const NameOf_SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD	= "��������� ����������� ������� ������������ ��������"
const NameOf_SYSTEMPRIVILEGES_MANAGEUSERS	= "���������� ��������������"
const NameOf_SYSTEMPRIVILEGES_MANAGETIMELOSS	= "���������� ������ ����������"
const NameOf_SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT	= "���������� ��������� ��������� �����������"
const NameOf_SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT	= "���������� �������������"
const NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTS	= "���������� �������������"
const NameOf_SYSTEMPRIVILEGES_ACCESSINTOTMS	= "������ � ������� ����� ��������"
const NameOf_SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS	= "������� ����� � ����������"
const NameOf_SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS	= "�������� ���� �����������"
const NameOf_SYSTEMPRIVILEGES_CHANGETEMPORGONCONST	= "������ ���������� �������� ����������� ����������"
const NameOf_SYSTEMPRIVILEGES_DECIDINGMANINTMS	= "����������� ������� � ���"
const NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS	= "���������� ������������� ���"
const NameOf_SYSTEMPRIVILEGES_CLOSEANYFOLDER	= "�������� �����������"
const NameOf_SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT	= "���������� ����� �������� ��������"
const NameOf_SYSTEMPRIVILEGES_MANAGEPROJECTTEAM	= "���������� ��������� ��������"
const NameOf_SYSTEMPRIVILEGES_MANAGECONTRACTS	= "���������� �����������"
const NameOf_SYSTEMPRIVILEGES_MANAGEPROJINCOUT	= "���������� ���������� ��������� � ���������"
const NameOf_SYSTEMPRIVILEGES_MANAGEINCOUT	= "���������� ��������� � ���������"
const NameOf_SYSTEMPRIVILEGES_MANAGELOAN	= "���������� �������"
const NameOf_SYSTEMPRIVILEGES_MANAGEFOT	= "���������� ���"
const NameOf_SYSTEMPRIVILEGES_ACCESSFINREPORTS	= "���������� ����������"
const NameOf_SYSTEMPRIVILEGES_CASHMANAGEMENT	= "���������� ������"

Function NameOf_SystemPrivileges(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEUSERS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEUSERS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGETIMELOSS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGETIMELOSS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEREFOBJECTS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_ACCESSINTOTMS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_ACCESSINTOTMS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_CHANGETEMPORGONCONST) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_CHANGETEMPORGONCONST & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_DECIDINGMANINTMS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_DECIDINGMANINTMS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_CLOSEANYFOLDER) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_CLOSEANYFOLDER & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEPROJECTTEAM) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEPROJECTTEAM & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGECONTRACTS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGECONTRACTS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEPROJINCOUT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEPROJINCOUT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEINCOUT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEINCOUT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGELOAN) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGELOAN & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_MANAGEFOT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_MANAGEFOT & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_ACCESSFINREPORTS) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_ACCESSFINREPORTS & ","
	If vVal AND CLng(SYSTEMPRIVILEGES_CASHMANAGEMENT) Then sResult = sResult & NameOf_SYSTEMPRIVILEGES_CASHMANAGEMENT & ","
	If Not IsEmpty(sResult) Then NameOf_SystemPrivileges = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	DateIntervalType - ��� ���������� ���������
const DATEINTERVALTYPE_DATERATIOINTERVAL	= 1		' ������� �� ������
const DATEINTERVALTYPE_SETDATEINTERVAL	= 2		' ������� �������� ���

const NameOf_DATEINTERVALTYPE_DATERATIOINTERVAL	= "������� �� ������"
const NameOf_DATEINTERVALTYPE_SETDATEINTERVAL	= "������� �������� ���"

Function NameOf_DateIntervalType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case DATEINTERVALTYPE_DATERATIOINTERVAL :
			NameOf_DateIntervalType = NameOf_DATEINTERVALTYPE_DATERATIOINTERVAL
		Case DATEINTERVALTYPE_SETDATEINTERVAL :
			NameOf_DateIntervalType = NameOf_DATEINTERVALTYPE_SETDATEINTERVAL
	End Select
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_SortingMode - ���������� � ������ "��������� ������ �������������"
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME	= 0		' �� ������������� / ����������
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES	= 1		' �� �������������
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE	= 2		' �� �������� ����������
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION	= 3		' �� �������� ������������ ����������

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME	= "�� ������������� / ����������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES	= "�� �������������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE	= "�� �������� ����������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION	= "�� �������� ������������ ����������"

Function NameOf_RepDepartmentExpensesStructure_SortingMode(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME :
			NameOf_RepDepartmentExpensesStructure_SortingMode = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME
		Case REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES :
			NameOf_RepDepartmentExpensesStructure_SortingMode = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES
		Case REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE :
			NameOf_RepDepartmentExpensesStructure_SortingMode = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE
		Case REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION :
			NameOf_RepDepartmentExpensesStructure_SortingMode = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION
	End Select
End Function

'----------------------------------------------------------
'	ActivitySelection - ������� �����������
const ACTIVITYSELECTION_HAVEEXPENSES	= 1		' � ��������� �� ������
const ACTIVITYSELECTION_WAITINGFORCLOSE	= 2		' ������������ � �������� ��������
const ACTIVITYSELECTION_CLOSED	= 3		' �������� �� ������

const NameOf_ACTIVITYSELECTION_HAVEEXPENSES	= "� ��������� �� ������"
const NameOf_ACTIVITYSELECTION_WAITINGFORCLOSE	= "������������ � �������� ��������"
const NameOf_ACTIVITYSELECTION_CLOSED	= "�������� �� ������"

Function NameOf_ActivitySelection(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ACTIVITYSELECTION_HAVEEXPENSES :
			NameOf_ActivitySelection = NameOf_ACTIVITYSELECTION_HAVEEXPENSES
		Case ACTIVITYSELECTION_WAITINGFORCLOSE :
			NameOf_ActivitySelection = NameOf_ACTIVITYSELECTION_WAITINGFORCLOSE
		Case ACTIVITYSELECTION_CLOSED :
			NameOf_ActivitySelection = NameOf_ACTIVITYSELECTION_CLOSED
	End Select
End Function

'----------------------------------------------------------
'	ReportLastExpenseDatesSortType - ��� ���������� � ������ "���� ���������� ����� ������ ������������"
const REPORTLASTEXPENSEDATESSORTTYPE_RANDOM	= 0		' �����������
const REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE	= 1		' �� ����������
const REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME	= 2		' �� ���� � �������

const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_RANDOM	= "�����������"
const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE	= "�� ����������"
const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME	= "�� ���� � �������"

Function NameOf_ReportLastExpenseDatesSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPORTLASTEXPENSEDATESSORTTYPE_RANDOM :
			NameOf_ReportLastExpenseDatesSortType = NameOf_REPORTLASTEXPENSEDATESSORTTYPE_RANDOM
		Case REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE :
			NameOf_ReportLastExpenseDatesSortType = NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE
		Case REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME :
			NameOf_ReportLastExpenseDatesSortType = NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME
	End Select
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_DataFormat - ����� ������������� ������ ������ "��������� ������ �������������"
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT	= 0		' ����� � ��������
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME	= 1		' ������ �����
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT	= 2		' ������ ��������

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT	= "����� � ��������"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME	= "������ �����"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT	= "������ ��������"

Function NameOf_RepDepartmentExpensesStructure_DataFormat(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT :
			NameOf_RepDepartmentExpensesStructure_DataFormat = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT
		Case REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME :
			NameOf_RepDepartmentExpensesStructure_DataFormat = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME
		Case REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT :
			NameOf_RepDepartmentExpensesStructure_DataFormat = NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT
	End Select
End Function

'----------------------------------------------------------
'	FolderTypeFlags - ��� ����� flags
const FOLDERTYPEFLAGS_PROJECT	= 1		' ������
const FOLDERTYPEFLAGS_TENDER	= 4		' ������
const FOLDERTYPEFLAGS_PRESALE	= 8		' �������
const FOLDERTYPEFLAGS_DIRECTORY	= 16		' �������

const NameOf_FOLDERTYPEFLAGS_PROJECT	= "������"
const NameOf_FOLDERTYPEFLAGS_TENDER	= "������"
const NameOf_FOLDERTYPEFLAGS_PRESALE	= "�������"
const NameOf_FOLDERTYPEFLAGS_DIRECTORY	= "�������"

Function NameOf_FolderTypeFlags(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(FOLDERTYPEFLAGS_PROJECT) Then sResult = sResult & NameOf_FOLDERTYPEFLAGS_PROJECT & ","
	If vVal AND CLng(FOLDERTYPEFLAGS_TENDER) Then sResult = sResult & NameOf_FOLDERTYPEFLAGS_TENDER & ","
	If vVal AND CLng(FOLDERTYPEFLAGS_PRESALE) Then sResult = sResult & NameOf_FOLDERTYPEFLAGS_PRESALE & ","
	If vVal AND CLng(FOLDERTYPEFLAGS_DIRECTORY) Then sResult = sResult & NameOf_FOLDERTYPEFLAGS_DIRECTORY & ","
	If Not IsEmpty(sResult) Then NameOf_FolderTypeFlags = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	TYPE_MONEY_TRANS - ��� �������� �� � �����
const TYPE_MONEY_TRANS_INCOME	= 0		' �����������
const TYPE_MONEY_TRANS_OUT_EMP	= 1		' ������ ����������
const TYPE_MONEY_TRANS_INC_EMP	= 2		' ������� �����������

const NameOf_TYPE_MONEY_TRANS_INCOME	= "�����������"
const NameOf_TYPE_MONEY_TRANS_OUT_EMP	= "������ ����������"
const NameOf_TYPE_MONEY_TRANS_INC_EMP	= "������� �����������"

Function NameOf_TYPE_MONEY_TRANS(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case TYPE_MONEY_TRANS_INCOME :
			NameOf_TYPE_MONEY_TRANS = NameOf_TYPE_MONEY_TRANS_INCOME
		Case TYPE_MONEY_TRANS_OUT_EMP :
			NameOf_TYPE_MONEY_TRANS = NameOf_TYPE_MONEY_TRANS_OUT_EMP
		Case TYPE_MONEY_TRANS_INC_EMP :
			NameOf_TYPE_MONEY_TRANS = NameOf_TYPE_MONEY_TRANS_INC_EMP
	End Select
End Function

'----------------------------------------------------------
'	SortIncidentExpenses - ���������� ���������� � ������
const SORTINCIDENTEXPENSES_BYDATETIME	= 0		' �� ���� � �������
const SORTINCIDENTEXPENSES_BYLOSSREASON	= 1		' �� ������� ��������
const SORTINCIDENTEXPENSES_BYSPENTTIME	= 2		' �� ������������ �������

const NameOf_SORTINCIDENTEXPENSES_BYDATETIME	= "�� ���� � �������"
const NameOf_SORTINCIDENTEXPENSES_BYLOSSREASON	= "�� ������� ��������"
const NameOf_SORTINCIDENTEXPENSES_BYSPENTTIME	= "�� ������������ �������"

Function NameOf_SortIncidentExpenses(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SORTINCIDENTEXPENSES_BYDATETIME :
			NameOf_SortIncidentExpenses = NameOf_SORTINCIDENTEXPENSES_BYDATETIME
		Case SORTINCIDENTEXPENSES_BYLOSSREASON :
			NameOf_SortIncidentExpenses = NameOf_SORTINCIDENTEXPENSES_BYLOSSREASON
		Case SORTINCIDENTEXPENSES_BYSPENTTIME :
			NameOf_SortIncidentExpenses = NameOf_SORTINCIDENTEXPENSES_BYSPENTTIME
	End Select
End Function

'----------------------------------------------------------
'	TYPE_SUPPLAING - ��� ������������
const TYPE_SUPPLAING_PROC_FROM_DIFF	= 0		' ������� �� �������
const TYPE_SUPPLAING_PROC_FROM_SUM	= 1		' ������� �� �����
const TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL	= 2		' ������� �� ����� ��������

const NameOf_TYPE_SUPPLAING_PROC_FROM_DIFF	= "������� �� �������"
const NameOf_TYPE_SUPPLAING_PROC_FROM_SUM	= "������� �� �����"
const NameOf_TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL	= "������� �� ����� ��������"

Function NameOf_TYPE_SUPPLAING(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case TYPE_SUPPLAING_PROC_FROM_DIFF :
			NameOf_TYPE_SUPPLAING = NameOf_TYPE_SUPPLAING_PROC_FROM_DIFF
		Case TYPE_SUPPLAING_PROC_FROM_SUM :
			NameOf_TYPE_SUPPLAING = NameOf_TYPE_SUPPLAING_PROC_FROM_SUM
		Case TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL :
			NameOf_TYPE_SUPPLAING = NameOf_TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL
	End Select
End Function

'----------------------------------------------------------
'	ACTION_TYPE - ��� ��������
const ACTION_TYPE_INSERT	= 0		' ��������
const ACTION_TYPE_UPDATE	= 1		' ����������
const ACTION_TYPE_DELETE	= 2		' ��������

const NameOf_ACTION_TYPE_INSERT	= "��������"
const NameOf_ACTION_TYPE_UPDATE	= "����������"
const NameOf_ACTION_TYPE_DELETE	= "��������"

Function NameOf_ACTION_TYPE(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case ACTION_TYPE_INSERT :
			NameOf_ACTION_TYPE = NameOf_ACTION_TYPE_INSERT
		Case ACTION_TYPE_UPDATE :
			NameOf_ACTION_TYPE = NameOf_ACTION_TYPE_UPDATE
		Case ACTION_TYPE_DELETE :
			NameOf_ACTION_TYPE = NameOf_ACTION_TYPE_DELETE
	End Select
End Function

'----------------------------------------------------------
'	MC_TYPE_OF_MUS_ACTION - ��� ������� ���������
const MC_TYPE_OF_MUS_ACTION_VOCAL	= 1		' �����
const MC_TYPE_OF_MUS_ACTION_GUITAR	= 2		' ������
const MC_TYPE_OF_MUS_ACTION_BASS	= 4		' ���
const MC_TYPE_OF_MUS_ACTION_DRUMS	= 8		' �������
const MC_TYPE_OF_MUS_ACTION_PERCISSION	= 16		' ���������
const MC_TYPE_OF_MUS_ACTION_KEYS	= 32		' ���������
const MC_TYPE_OF_MUS_ACTION_SM	= 64		' ���������
const MC_TYPE_OF_MUS_ACTION_DUH	= 128		' �������
const MC_TYPE_OF_MUS_ACTION_PRODUCER	= 131071		' ��������

const NameOf_MC_TYPE_OF_MUS_ACTION_VOCAL	= "�����"
const NameOf_MC_TYPE_OF_MUS_ACTION_GUITAR	= "������"
const NameOf_MC_TYPE_OF_MUS_ACTION_BASS	= "���"
const NameOf_MC_TYPE_OF_MUS_ACTION_DRUMS	= "�������"
const NameOf_MC_TYPE_OF_MUS_ACTION_PERCISSION	= "���������"
const NameOf_MC_TYPE_OF_MUS_ACTION_KEYS	= "���������"
const NameOf_MC_TYPE_OF_MUS_ACTION_SM	= "���������"
const NameOf_MC_TYPE_OF_MUS_ACTION_DUH	= "�������"
const NameOf_MC_TYPE_OF_MUS_ACTION_PRODUCER	= "��������"

Function NameOf_MC_TYPE_OF_MUS_ACTION(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_VOCAL) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_VOCAL & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_GUITAR) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_GUITAR & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_BASS) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_BASS & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_DRUMS) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_DRUMS & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_PERCISSION) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_PERCISSION & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_KEYS) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_KEYS & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_SM) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_SM & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_DUH) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_DUH & ","
	If vVal AND CLng(MC_TYPE_OF_MUS_ACTION_PRODUCER) Then sResult = sResult & NameOf_MC_TYPE_OF_MUS_ACTION_PRODUCER & ","
	If Not IsEmpty(sResult) Then NameOf_MC_TYPE_OF_MUS_ACTION = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	FolderStates - ��������� �����
const FOLDERSTATES_OPEN	= 1		' �������
const FOLDERSTATES_WAITINGTOCLOSE	= 2		' �������� ��������
const FOLDERSTATES_CLOSED	= 4		' �������
const FOLDERSTATES_FROZEN	= 8		' ����������

const NameOf_FOLDERSTATES_OPEN	= "�������"
const NameOf_FOLDERSTATES_WAITINGTOCLOSE	= "�������� ��������"
const NameOf_FOLDERSTATES_CLOSED	= "�������"
const NameOf_FOLDERSTATES_FROZEN	= "����������"

Function NameOf_FolderStates(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case FOLDERSTATES_OPEN :
			NameOf_FolderStates = NameOf_FOLDERSTATES_OPEN
		Case FOLDERSTATES_WAITINGTOCLOSE :
			NameOf_FolderStates = NameOf_FOLDERSTATES_WAITINGTOCLOSE
		Case FOLDERSTATES_CLOSED :
			NameOf_FolderStates = NameOf_FOLDERSTATES_CLOSED
		Case FOLDERSTATES_FROZEN :
			NameOf_FolderStates = NameOf_FOLDERSTATES_FROZEN
	End Select
End Function

'----------------------------------------------------------
'	IncidentStateDetalization - ����������� ��������� ���������
const INCIDENTSTATEDETALIZATION_ALLSTATES	= 0		' �� ���� ����������
const INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES	= 1		' �� �������� � ��������
const INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY	= 2		' ��� ����������� (������ ��������)

const NameOf_INCIDENTSTATEDETALIZATION_ALLSTATES	= "�� ���� ����������"
const NameOf_INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES	= "�� �������� � ��������"
const NameOf_INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY	= "��� ����������� (������ ��������)"

Function NameOf_IncidentStateDetalization(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case INCIDENTSTATEDETALIZATION_ALLSTATES :
			NameOf_IncidentStateDetalization = NameOf_INCIDENTSTATEDETALIZATION_ALLSTATES
		Case INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES :
			NameOf_IncidentStateDetalization = NameOf_INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES
		Case INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY :
			NameOf_IncidentStateDetalization = NameOf_INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY
	End Select
End Function

'----------------------------------------------------------
'	FilterReportEmploymentPlannedSortType - ��� ���������� � ������ "�������� ��������� �����������"
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION	= 0		' ��� �����������
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD	= 1		' �� ��������
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT	= 2		' �� �������� � ��������

const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION	= "��� �����������"
const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD	= "�� ��������"
const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT	= "�� �������� � ��������"

Function NameOf_FilterReportEmploymentPlannedSortType(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION :
			NameOf_FilterReportEmploymentPlannedSortType = NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION
		Case FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD :
			NameOf_FilterReportEmploymentPlannedSortType = NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD
		Case FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT :
			NameOf_FilterReportEmploymentPlannedSortType = NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT
	End Select
End Function

