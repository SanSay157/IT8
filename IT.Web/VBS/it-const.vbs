Option Explicit
'----------------------------------------------------------
'	ActivityDetalizationLevel - Уровень детализации активностей
const ACTIVITYDETALIZATIONLEVEL_SUBPROJECT	= 1		' до подпроекта 1 уровня
const ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER	= 2		' до менеджера проекта
const ACTIVITYDETALIZATIONLEVEL_PROJECTCODE	= 3		' до кода проекта

const NameOf_ACTIVITYDETALIZATIONLEVEL_SUBPROJECT	= "до подпроекта 1 уровня"
const NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTMANAGER	= "до менеджера проекта"
const NameOf_ACTIVITYDETALIZATIONLEVEL_PROJECTCODE	= "до кода проекта"

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
'	BranchFilterType - Тип фильтрации по отраслям
const BRANCHFILTERTYPE_ANYBRANCHES	= 0		' Любые отрасли
const BRANCHFILTERTYPE_ALLSELECTED	= 1		' Все указанные
const BRANCHFILTERTYPE_ANYSELECTED	= 2		' Хотя бы одна из указанных

const NameOf_BRANCHFILTERTYPE_ANYBRANCHES	= "Любые отрасли"
const NameOf_BRANCHFILTERTYPE_ALLSELECTED	= "Все указанные"
const NameOf_BRANCHFILTERTYPE_ANYSELECTED	= "Хотя бы одна из указанных"

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
'	TimeLossCauseTypes - Тип причины списания
const TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER	= 1		' Требует применение к папке
const TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER	= 2		' Не может быть применена к папке
const TIMELOSSCAUSETYPES_APPLICABLETOFOLDER	= 3		' Может быть применена к папке

const NameOf_TIMELOSSCAUSETYPES_MUSTAPPLICABLETOFOLDER	= "Требует применение к папке"
const NameOf_TIMELOSSCAUSETYPES_NOTAPPLICABLETOFOLDER	= "Не может быть применена к папке"
const NameOf_TIMELOSSCAUSETYPES_APPLICABLETOFOLDER	= "Может быть применена к папке"

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
'	SortExpences - Сортировка затрат сотрудников
const SORTEXPENCES_NOSORT	= 0		' произвольно
const SORTEXPENCES_BYEMPLOYEE	= 1		' по сотруднику
const SORTEXPENCES_BYNORM	= 2		' по норме

const NameOf_SORTEXPENCES_NOSORT	= "произвольно"
const NameOf_SORTEXPENCES_BYEMPLOYEE	= "по сотруднику"
const NameOf_SORTEXPENCES_BYNORM	= "по норме"

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
'	IncidentViewModes - Режимы отображения инцидентов
const INCIDENTVIEWMODES_ALL	= 1		' Все инциденты
const INCIDENTVIEWMODES_OPEN	= 2		' Открытые
const INCIDENTVIEWMODES_NOTCLOSED	= 3		' Не закрытые
const INCIDENTVIEWMODES_CLOSED	= 4		' Закрытые
const INCIDENTVIEWMODES_MINE	= 5		' Мои инциденты

const NameOf_INCIDENTVIEWMODES_ALL	= "Все инциденты"
const NameOf_INCIDENTVIEWMODES_OPEN	= "Открытые"
const NameOf_INCIDENTVIEWMODES_NOTCLOSED	= "Не закрытые"
const NameOf_INCIDENTVIEWMODES_CLOSED	= "Закрытые"
const NameOf_INCIDENTVIEWMODES_MINE	= "Мои инциденты"

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
'	TenderSortType - Тип сортировки в отчете Тендеры
const TENDERSORTTYPE_RANDOM	= 0		' Произвольно
const TENDERSORTTYPE_BYTENDERNAME	= 1		' По наименованию конкурса
const TENDERSORTTYPE_BYCUSTOMERNAME	= 2		' По наименованию заказчика
const TENDERSORTTYPE_BYDOCFEEDINGDATE	= 3		' По дате подачи документов

const NameOf_TENDERSORTTYPE_RANDOM	= "Произвольно"
const NameOf_TENDERSORTTYPE_BYTENDERNAME	= "По наименованию конкурса"
const NameOf_TENDERSORTTYPE_BYCUSTOMERNAME	= "По наименованию заказчика"
const NameOf_TENDERSORTTYPE_BYDOCFEEDINGDATE	= "По дате подачи документов"

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
'	RepDepartmentExpensesStructure_AnalysisDepth - Объем анализируемых данных отчета "Структура затрат подразделений"
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED	= 0		' Только указанные подразделения / организации
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS	= 1		' Включать данные непосредственно подчиненных подразделений
const REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS	= 2		' Включать данные всех подчиненных подразделений

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ONLYSELECTED	= "Только указанные подразделения / организации"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_FIRSTLEVELDEPENDS	= "Включать данные непосредственно подчиненных подразделений"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_ANALYSISDEPTH_ALLLEVELDEPENDS	= "Включать данные всех подчиненных подразделений"

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
'	StartPages - Стартовые страницы
const STARTPAGES_CURRENTTASKLIST	= 1		' Список текущих задач (Мои инциденты)
const STARTPAGES_DKP	= 2		' Иерархия Клиентов и проектов
const STARTPAGES_REPORTS	= 3		' Отчеты
const STARTPAGES_TMS	= 4		' Стартовая страница Системы учета тендеров
const STARTPAGES_TENDERLIST	= 5		' Список тендеров

const NameOf_STARTPAGES_CURRENTTASKLIST	= "Список текущих задач (Мои инциденты)"
const NameOf_STARTPAGES_DKP	= "Иерархия Клиентов и проектов"
const NameOf_STARTPAGES_REPORTS	= "Отчеты"
const NameOf_STARTPAGES_TMS	= "Стартовая страница Системы учета тендеров"
const NameOf_STARTPAGES_TENDERLIST	= "Список тендеров"

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
'	SortOrder - Порядок сортировки
const SORTORDER_ASC	= 1		' По возрастанию
const SORTORDER_DESC	= 2		' По убыванию

const NameOf_SORTORDER_ASC	= "По возрастанию"
const NameOf_SORTORDER_DESC	= "По убыванию"

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
'	SectioningByActivity - Секционирование по активностям 1
const SECTIONINGBYACTIVITY_NOSECTIONING	= 0		' без секционирования
const SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY	= 1		' по активностям верхнего уровня

const NameOf_SECTIONINGBYACTIVITY_NOSECTIONING	= "без секционирования"
const NameOf_SECTIONINGBYACTIVITY_SECTIONINGBYTOPLEVELACTIVITY	= "по активностям верхнего уровня"

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
'	GENDER - Пол
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
'	PresentationModes - Формат отображения ссылки
const PRESENTATIONMODES_DISPLAYDESCR	= 1		' Отображать наименование
const PRESENTATIONMODES_DISPLAYDATA	= 2		' Отображать данные

const NameOf_PRESENTATIONMODES_DISPLAYDESCR	= "Отображать наименование"
const NameOf_PRESENTATIONMODES_DISPLAYDATA	= "Отображать данные"

Function NameOf_PresentationModes(ByVal vVal)
	Dim sResult
	If Not IsNumeric(vVal) Then Exit Function
	vVal = CLng(vVal)
	If vVal AND CLng(PRESENTATIONMODES_DISPLAYDESCR) Then sResult = sResult & NameOf_PRESENTATIONMODES_DISPLAYDESCR & ","
	If vVal AND CLng(PRESENTATIONMODES_DISPLAYDATA) Then sResult = sResult & NameOf_PRESENTATIONMODES_DISPLAYDATA & ","
	If Not IsEmpty(sResult) Then NameOf_PresentationModes = Left(sResult, Len(sResult) - 1)
End Function

'----------------------------------------------------------
'	RepDepartmentExpensesStructure_ReportForm - Форма отчета "Структура затрат подразделений"
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT	= 0		' Суммарные данные подразделений
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE	= 1		' Данные по каждому сотруднику подразделения
const REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI	= 2		' Данные по каждому сотруднику, с данными по заданиям

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYDEPARTMENT	= "Суммарные данные подразделений"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEE	= "Данные по каждому сотруднику подразделения"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_REPORTFORM_BYEMPLOYEEWITHTASKSDETALI	= "Данные по каждому сотруднику, с данными по заданиям"

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
'	SectionByActivity - Секционирование по активностям
const SECTIONBYACTIVITY_NOSECTION	= 0		' без секционирования
const SECTIONBYACTIVITY_STAGE1SECTION	= 1		' по подчиненным активностям 1 уровня
const SECTIONBYACTIVITY_ALLSTAGESSECTION	= 2		' по подчиненным активностям всех уровней

const NameOf_SECTIONBYACTIVITY_NOSECTION	= "без секционирования"
const NameOf_SECTIONBYACTIVITY_STAGE1SECTION	= "по подчиненным активностям 1 уровня"
const NameOf_SECTIONBYACTIVITY_ALLSTAGESSECTION	= "по подчиненным активностям всех уровней"

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
'	FolderTypeEnum - Тип папки enum
const FOLDERTYPEENUM_PROJECT	= 1		' Проект
const FOLDERTYPEENUM_TENDER	= 4		' Тендер
const FOLDERTYPEENUM_PRESALE	= 8		' Пресейл
const FOLDERTYPEENUM_DIRECTORY	= 16		' Каталог

const NameOf_FOLDERTYPEENUM_PROJECT	= "Проект"
const NameOf_FOLDERTYPEENUM_TENDER	= "Тендер"
const NameOf_FOLDERTYPEENUM_PRESALE	= "Пресейл"
const NameOf_FOLDERTYPEENUM_DIRECTORY	= "Каталог"

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
'	FolderStatesFlags - Состояние папки flags
const FOLDERSTATESFLAGS_OPEN	= 1		' Открыто
const FOLDERSTATESFLAGS_WAITINGTOCLOSE	= 2		' Ожидание закрытия
const FOLDERSTATESFLAGS_CLOSED	= 4		' Закрыто
const FOLDERSTATESFLAGS_FROZEN	= 8		' Заморожено

const NameOf_FOLDERSTATESFLAGS_OPEN	= "Открыто"
const NameOf_FOLDERSTATESFLAGS_WAITINGTOCLOSE	= "Ожидание закрытия"
const NameOf_FOLDERSTATESFLAGS_CLOSED	= "Закрыто"
const NameOf_FOLDERSTATESFLAGS_FROZEN	= "Заморожено"

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
'	ExpencesType - Вид трудозатрат
const EXPENCESTYPE_INCIDENTS	= 0		' затраты на инциденты
const EXPENCESTYPE_DISCARDING	= 1		' списания
const EXPENCESTYPE_BOTH	= 2		' затраты на инциденты и списания

const NameOf_EXPENCESTYPE_INCIDENTS	= "затраты на инциденты"
const NameOf_EXPENCESTYPE_DISCARDING	= "списания"
const NameOf_EXPENCESTYPE_BOTH	= "затраты на инциденты и списания"

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
'	ExpenseDetalization - Детализация затрат
const EXPENSEDETALIZATION_BYEXPENCES	= 0		' по затратам
const EXPENSEDETALIZATION_BYINCIDENT	= 1		' по инцидентам
const EXPENSEDETALIZATION_BYSUBACTIVITY	= 2		' по активностям нижнего уровня

const NameOf_EXPENSEDETALIZATION_BYEXPENCES	= "по затратам"
const NameOf_EXPENSEDETALIZATION_BYINCIDENT	= "по инцидентам"
const NameOf_EXPENSEDETALIZATION_BYSUBACTIVITY	= "по активностям нижнего уровня"

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
'	DKPTreeModes - Режимы дерева ДКП
const DKPTREEMODES_ORGANIZATIONS	= 1		' Организации
const DKPTREEMODES_ACTIVITIES	= 2		' Активности

const NameOf_DKPTREEMODES_ORGANIZATIONS	= "Организации"
const NameOf_DKPTREEMODES_ACTIVITIES	= "Активности"

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
'	IncidentStateCategoryFlags - Категория состояния
const INCIDENTSTATECATEGORYFLAGS_OPEN	= 1		' В работе
const INCIDENTSTATECATEGORYFLAGS_ONCHECK	= 2		' На проверке
const INCIDENTSTATECATEGORYFLAGS_FINISHED	= 4		' Работа окончена
const INCIDENTSTATECATEGORYFLAGS_FROZEN	= 8		' Заморожен
const INCIDENTSTATECATEGORYFLAGS_DECLINED	= 16		' Отклонен

const NameOf_INCIDENTSTATECATEGORYFLAGS_OPEN	= "В работе"
const NameOf_INCIDENTSTATECATEGORYFLAGS_ONCHECK	= "На проверке"
const NameOf_INCIDENTSTATECATEGORYFLAGS_FINISHED	= "Работа окончена"
const NameOf_INCIDENTSTATECATEGORYFLAGS_FROZEN	= "Заморожен"
const NameOf_INCIDENTSTATECATEGORYFLAGS_DECLINED	= "Отклонен"

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
'	ReportExpensesByDirectionsSortType - Тип сортировки в отчете "Затраты в разрезе направлений"
const REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION	= 0		' По направлению
const REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES	= 1		' По сумме затрат

const NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYDIRECTION	= "По направлению"
const NameOf_REPORTEXPENSESBYDIRECTIONSSORTTYPE_BYEXPENSES	= "По сумме затрат"

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
'	PROJECT_RISK_PRIORITY - Приоритет проектного риска
const PROJECT_RISK_PRIORITY_HIGH	= 0		' Высокий
const PROJECT_RISK_PRIORITY_MEDIUM	= 1		' Средний
const PROJECT_RISK_PRIORITY_LOW	= 2		' Низкий

const NameOf_PROJECT_RISK_PRIORITY_HIGH	= "Высокий"
const NameOf_PROJECT_RISK_PRIORITY_MEDIUM	= "Средний"
const NameOf_PROJECT_RISK_PRIORITY_LOW	= "Низкий"

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
'	IncidentStateCat - Категория состояния инцидента
const INCIDENTSTATECAT_OPEN	= 1		' В работе
const INCIDENTSTATECAT_ONCHECK	= 2		' На проверке
const INCIDENTSTATECAT_FINISHED	= 3		' Работа окончена
const INCIDENTSTATECAT_FROZEN	= 4		' Заморожен
const INCIDENTSTATECAT_DECLINED	= 5		' Отклонен

const NameOf_INCIDENTSTATECAT_OPEN	= "В работе"
const NameOf_INCIDENTSTATECAT_ONCHECK	= "На проверке"
const NameOf_INCIDENTSTATECAT_FINISHED	= "Работа окончена"
const NameOf_INCIDENTSTATECAT_FROZEN	= "Заморожен"
const NameOf_INCIDENTSTATECAT_DECLINED	= "Отклонен"

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
'	FolderPrivileges - Привилегии для папки
const FOLDERPRIVILEGES_MANAGEINCIDENTS	= 1		' Управление инцидентами
const FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS	= 2		' Управление составом участников инцидента
const FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT	= 4		' Управление чужими списаниями
const FOLDERPRIVILEGES_CHANGEFOLDER	= 64		' Редактирование реквизитов проектов
const FOLDERPRIVILEGES_MANAGECATALOG	= 128		' Управление каталогами
const FOLDERPRIVILEGES_SPENTTIMEBYPROJECT	= 256		' Создание списания на проект
const FOLDERPRIVILEGES_MANAGETEAM	= 512		' Управление проектной командой
const FOLDERPRIVILEGES_CLOSEFOLDER	= 1024		' Закрытие активности
const FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION	= 2048		' Разрешение списания на папку с неоднозначным определением направления

const NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTS	= "Управление инцидентами"
const NameOf_FOLDERPRIVILEGES_MANAGEINCIDENTPARTICIPANTS	= "Управление составом участников инцидента"
const NameOf_FOLDERPRIVILEGES_EDITINCIDENTTIMESPENT	= "Управление чужими списаниями"
const NameOf_FOLDERPRIVILEGES_CHANGEFOLDER	= "Редактирование реквизитов проектов"
const NameOf_FOLDERPRIVILEGES_MANAGECATALOG	= "Управление каталогами"
const NameOf_FOLDERPRIVILEGES_SPENTTIMEBYPROJECT	= "Создание списания на проект"
const NameOf_FOLDERPRIVILEGES_MANAGETEAM	= "Управление проектной командой"
const NameOf_FOLDERPRIVILEGES_CLOSEFOLDER	= "Закрытие активности"
const NameOf_FOLDERPRIVILEGES_TIMELOSSONUNSPECIFIEDDIRECTION	= "Разрешение списания на папку с неоднозначным определением направления"

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
'	EventClass - Класс события
const EVENTCLASS_EVENT_TYPE_01	= 1		' Создание инцидента
const EVENTCLASS_EVENT_TYPE_02	= 2		' Изменение состояние инцидента
const EVENTCLASS_EVENT_TYPE_03	= 3		' Удаление инцидента
const EVENTCLASS_EVENT_TYPE_04	= 4		' Создание описания нового задания по инциденту
const EVENTCLASS_EVENT_TYPE_05	= 5		' Изменение роли исполнителя в задании по инциденту
const EVENTCLASS_EVENT_TYPE_06	= 6		' Удаление задания по инциденту
const EVENTCLASS_EVENT_TYPE_07	= 7		' Изменение наименования, описания или описания решения инцидента
const EVENTCLASS_EVENT_TYPE_08	= 8		' Изменение приоритета или крайнего срока инцидента
const EVENTCLASS_EVENT_TYPE_09	= 9		' Перенос инцидента в другую активность - экспорт
const EVENTCLASS_EVENT_TYPE_10	= 10		' Перенос инцидента в другую активность - импорт
const EVENTCLASS_EVENT_TYPE_11	= 11		' Добавление участника проектной команды
const EVENTCLASS_EVENT_TYPE_12	= 12		' Удаление участника проектной команды
const EVENTCLASS_EVENT_TYPE_13	= 13		' Снятие роли для участника проектной команды
const EVENTCLASS_EVENT_TYPE_14	= 14		' Добавление роли для участника проектной команды
const EVENTCLASS_EVENT_TYPE_15	= 15		' Удаление организации
const EVENTCLASS_EVENT_TYPE_16	= 16		' Снятие Директора Клиента (организации)
const EVENTCLASS_EVENT_TYPE_17	= 17		' Задание Директора Клиента (организации)
const EVENTCLASS_EVENT_TYPE_18	= 18		' Изменение наименования проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_19	= 19		' Изменение внешнего ID проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_20	= 20		' Изменение блокировки списаний по проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_21	= 21		' Удаление корневой проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_22	= 22		' Удаление некорневой проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_23	= 23		' Создание корневой проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_24	= 24		' Создание некорневой проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_25	= 25		' Изменение Клиента у проектной активности - экспорт
const EVENTCLASS_EVENT_TYPE_26	= 26		' Изменение Клиента у проектной активности - импорт
const EVENTCLASS_EVENT_TYPE_27	= 27		' Перенос проектной активности в другую папку - экспорт
const EVENTCLASS_EVENT_TYPE_28	= 28		' Перенос проектной активности в другую папку - импорт
const EVENTCLASS_EVENT_TYPE_29	= 29		' Изменение состояния у проектной активности
const EVENTCLASS_EVENT_TYPE_30	= 30		' Изменение типа активности у проектной активности
const EVENTCLASS_EVENT_TYPE_31	= 31		' Перенос организации - экспорт
const EVENTCLASS_EVENT_TYPE_32	= 32		' Перенос организации - импорт
const EVENTCLASS_EVENT_TYPE_33	= 33		' Изменение наименования или сокращённого наименования организации
const EVENTCLASS_EVENT_TYPE_34	= 34		' Создание организации
const EVENTCLASS_EVENT_TYPE_65	= 65		' Нарушение плана занятости сотрудником
const EVENTCLASS_EVENT_TYPE_35	= 35		' Изменение запланированного времени
const EVENTCLASS_EVENT_TYPE_36	= 36		' Изменение оставшегося времени
const EVENTCLASS_EVENT_TYPE_37	= 37		' Установка (изменение) общесистемной блокировки списаний
const EVENTCLASS_EVENT_TYPE_38	= 38		' Создание временной организации
const EVENTCLASS_EVENT_TYPE_39	= 39		' Замена временного описания организации постоянным
const EVENTCLASS_EVENT_TYPE_40	= 40		' Создание нового тендера
const EVENTCLASS_EVENT_TYPE_41	= 41		' Создание участия в лоте
const EVENTCLASS_EVENT_TYPE_42	= 42		' Модификация участника в лоте
const EVENTCLASS_EVENT_TYPE_43	= 43		' Удаление участника в лоте
const EVENTCLASS_EVENT_TYPE_44	= 44		' Изменение директора тендера - снятие
const EVENTCLASS_EVENT_TYPE_45	= 45		' Изменение директора тендера - назначение
const EVENTCLASS_EVENT_TYPE_46	= 46		' Удаление тендера
const EVENTCLASS_EVENT_TYPE_47	= 47		' Изменение состояния лота
const EVENTCLASS_EVENT_TYPE_48	= 48		' Превышение запланированного времени по инциденту
const EVENTCLASS_EVENT_TYPE_63	= 63		' Изменение плана занятости сотрудника
const EVENTCLASS_EVENT_TYPE_49	= 49		' Приближение крайнего срока инцидента
const EVENTCLASS_EVENT_TYPE_50	= 50		' Истечение крайнего срока инцидента
const EVENTCLASS_EVENT_TYPE_51	= 51		' Создание нового лота
const EVENTCLASS_EVENT_TYPE_64	= 64		' Превышение плановой занятости сотрудника на проектах
const EVENTCLASS_EVENT_TYPE_52	= 52		' Изменение лота
const EVENTCLASS_EVENT_TYPE_53	= 53		' Удаление лота
const EVENTCLASS_EVENT_TYPE_54	= 54		' Изменение описание тендера
const EVENTCLASS_EVENT_TYPE_55	= 55		' Измененме состояния тендера
const EVENTCLASS_EVENT_TYPE_56	= 56		' Добавления сотрудника в список лиц, принимающих участие в подготовке тендера
const EVENTCLASS_EVENT_TYPE_57	= 57		' Исключение сотрудника из списока лиц, принимающих участие в подготовке тендера
const EVENTCLASS_EVENT_TYPE_58	= 58		' Добавление направления у проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_59	= 59		' Удаление направления у проектной активности (папки)
const EVENTCLASS_EVENT_TYPE_60	= 60		' Изменение доли затрат направления у проектной активности
const EVENTCLASS_EVENT_TYPE_61	= 61		' Изменение нормы рабочего времени сотрудника
const EVENTCLASS_EVENT_TYPE_62	= 62		' Переход проектной активности в состояние "Ожидание закрытия"

const NameOf_EVENTCLASS_EVENT_TYPE_01	= "Создание инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_02	= "Изменение состояние инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_03	= "Удаление инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_04	= "Создание описания нового задания по инциденту"
const NameOf_EVENTCLASS_EVENT_TYPE_05	= "Изменение роли исполнителя в задании по инциденту"
const NameOf_EVENTCLASS_EVENT_TYPE_06	= "Удаление задания по инциденту"
const NameOf_EVENTCLASS_EVENT_TYPE_07	= "Изменение наименования, описания или описания решения инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_08	= "Изменение приоритета или крайнего срока инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_09	= "Перенос инцидента в другую активность - экспорт"
const NameOf_EVENTCLASS_EVENT_TYPE_10	= "Перенос инцидента в другую активность - импорт"
const NameOf_EVENTCLASS_EVENT_TYPE_11	= "Добавление участника проектной команды"
const NameOf_EVENTCLASS_EVENT_TYPE_12	= "Удаление участника проектной команды"
const NameOf_EVENTCLASS_EVENT_TYPE_13	= "Снятие роли для участника проектной команды"
const NameOf_EVENTCLASS_EVENT_TYPE_14	= "Добавление роли для участника проектной команды"
const NameOf_EVENTCLASS_EVENT_TYPE_15	= "Удаление организации"
const NameOf_EVENTCLASS_EVENT_TYPE_16	= "Снятие Директора Клиента (организации)"
const NameOf_EVENTCLASS_EVENT_TYPE_17	= "Задание Директора Клиента (организации)"
const NameOf_EVENTCLASS_EVENT_TYPE_18	= "Изменение наименования проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_19	= "Изменение внешнего ID проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_20	= "Изменение блокировки списаний по проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_21	= "Удаление корневой проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_22	= "Удаление некорневой проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_23	= "Создание корневой проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_24	= "Создание некорневой проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_25	= "Изменение Клиента у проектной активности - экспорт"
const NameOf_EVENTCLASS_EVENT_TYPE_26	= "Изменение Клиента у проектной активности - импорт"
const NameOf_EVENTCLASS_EVENT_TYPE_27	= "Перенос проектной активности в другую папку - экспорт"
const NameOf_EVENTCLASS_EVENT_TYPE_28	= "Перенос проектной активности в другую папку - импорт"
const NameOf_EVENTCLASS_EVENT_TYPE_29	= "Изменение состояния у проектной активности"
const NameOf_EVENTCLASS_EVENT_TYPE_30	= "Изменение типа активности у проектной активности"
const NameOf_EVENTCLASS_EVENT_TYPE_31	= "Перенос организации - экспорт"
const NameOf_EVENTCLASS_EVENT_TYPE_32	= "Перенос организации - импорт"
const NameOf_EVENTCLASS_EVENT_TYPE_33	= "Изменение наименования или сокращённого наименования организации"
const NameOf_EVENTCLASS_EVENT_TYPE_34	= "Создание организации"
const NameOf_EVENTCLASS_EVENT_TYPE_65	= "Нарушение плана занятости сотрудником"
const NameOf_EVENTCLASS_EVENT_TYPE_35	= "Изменение запланированного времени"
const NameOf_EVENTCLASS_EVENT_TYPE_36	= "Изменение оставшегося времени"
const NameOf_EVENTCLASS_EVENT_TYPE_37	= "Установка (изменение) общесистемной блокировки списаний"
const NameOf_EVENTCLASS_EVENT_TYPE_38	= "Создание временной организации"
const NameOf_EVENTCLASS_EVENT_TYPE_39	= "Замена временного описания организации постоянным"
const NameOf_EVENTCLASS_EVENT_TYPE_40	= "Создание нового тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_41	= "Создание участия в лоте"
const NameOf_EVENTCLASS_EVENT_TYPE_42	= "Модификация участника в лоте"
const NameOf_EVENTCLASS_EVENT_TYPE_43	= "Удаление участника в лоте"
const NameOf_EVENTCLASS_EVENT_TYPE_44	= "Изменение директора тендера - снятие"
const NameOf_EVENTCLASS_EVENT_TYPE_45	= "Изменение директора тендера - назначение"
const NameOf_EVENTCLASS_EVENT_TYPE_46	= "Удаление тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_47	= "Изменение состояния лота"
const NameOf_EVENTCLASS_EVENT_TYPE_48	= "Превышение запланированного времени по инциденту"
const NameOf_EVENTCLASS_EVENT_TYPE_63	= "Изменение плана занятости сотрудника"
const NameOf_EVENTCLASS_EVENT_TYPE_49	= "Приближение крайнего срока инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_50	= "Истечение крайнего срока инцидента"
const NameOf_EVENTCLASS_EVENT_TYPE_51	= "Создание нового лота"
const NameOf_EVENTCLASS_EVENT_TYPE_64	= "Превышение плановой занятости сотрудника на проектах"
const NameOf_EVENTCLASS_EVENT_TYPE_52	= "Изменение лота"
const NameOf_EVENTCLASS_EVENT_TYPE_53	= "Удаление лота"
const NameOf_EVENTCLASS_EVENT_TYPE_54	= "Изменение описание тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_55	= "Измененме состояния тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_56	= "Добавления сотрудника в список лиц, принимающих участие в подготовке тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_57	= "Исключение сотрудника из списока лиц, принимающих участие в подготовке тендера"
const NameOf_EVENTCLASS_EVENT_TYPE_58	= "Добавление направления у проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_59	= "Удаление направления у проектной активности (папки)"
const NameOf_EVENTCLASS_EVENT_TYPE_60	= "Изменение доли затрат направления у проектной активности"
const NameOf_EVENTCLASS_EVENT_TYPE_61	= "Изменение нормы рабочего времени сотрудника"
const NameOf_EVENTCLASS_EVENT_TYPE_62	= "Переход проектной активности в состояние ""Ожидание закрытия"""

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
'	IncidentFinderBehavior - Поведение IncidentFinder
const INCIDENTFINDERBEHAVIOR_OPENVIEW	= 1		' Открыть просмотр
const INCIDENTFINDERBEHAVIOR_OPENEDITOR	= 2		' Открыть редактор
const INCIDENTFINDERBEHAVIOR_OPENINTREE	= 3		' Открыть в дереве

const NameOf_INCIDENTFINDERBEHAVIOR_OPENVIEW	= "Открыть просмотр"
const NameOf_INCIDENTFINDERBEHAVIOR_OPENEDITOR	= "Открыть редактор"
const NameOf_INCIDENTFINDERBEHAVIOR_OPENINTREE	= "Открыть в дереве"

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
'	ReportActivityListSortType - Тип сортировки в отчете "Список активностей"
const REPORTACTIVITYLISTSORTTYPE_RANDOM	= 0		' Произвольно
const REPORTACTIVITYLISTSORTTYPE_BYNAME	= 1		' По наименованию
const REPORTACTIVITYLISTSORTTYPE_BYCODE	= 2		' По коду
const REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID	= 3		' По идентификатору для Navision

const NameOf_REPORTACTIVITYLISTSORTTYPE_RANDOM	= "Произвольно"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAME	= "По наименованию"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYCODE	= "По коду"
const NameOf_REPORTACTIVITYLISTSORTTYPE_BYNAVISIONID	= "По идентификатору для Navision"

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
'	UserRoleInProjectFlags - Тип роли пользователя в папке
const USERROLEINPROJECTFLAGS_PROJECTMANAGER	= 1		' Менеджер проекта
const USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR	= 2		' Администратор проекта
const USERROLEINPROJECTFLAGS_CLIENTDIRECTOR	= 4		' Директор клиента

const NameOf_USERROLEINPROJECTFLAGS_PROJECTMANAGER	= "Менеджер проекта"
const NameOf_USERROLEINPROJECTFLAGS_PROJECTADMINISTRATOR	= "Администратор проекта"
const NameOf_USERROLEINPROJECTFLAGS_CLIENTDIRECTOR	= "Директор клиента"

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
'	STATE_CONTRACT_BUDGET - Состояние бюджета проекта
const STATE_CONTRACT_BUDGET_WORKING	= 0		' В разработке
const STATE_CONTRACT_BUDGET_TO_FIN_DEP	= 1		' Передано на согласование в финансовую службу
const STATE_CONTRACT_BUDGET_FIN_ACCEPTED	= 2		' Согласовано финансовой службой
const STATE_CONTRACT_BUDGET_TO_GD	= 3		' Передано на согласование ГД
const STATE_CONTRACT_BUDGET_GD_ACCEPTED	= 4		' Согласовано ГД
const STATE_CONTRACT_BUDGET_ACCEPTED	= 5		' Утверждено

const NameOf_STATE_CONTRACT_BUDGET_WORKING	= "В разработке"
const NameOf_STATE_CONTRACT_BUDGET_TO_FIN_DEP	= "Передано на согласование в финансовую службу"
const NameOf_STATE_CONTRACT_BUDGET_FIN_ACCEPTED	= "Согласовано финансовой службой"
const NameOf_STATE_CONTRACT_BUDGET_TO_GD	= "Передано на согласование ГД"
const NameOf_STATE_CONTRACT_BUDGET_GD_ACCEPTED	= "Согласовано ГД"
const NameOf_STATE_CONTRACT_BUDGET_ACCEPTED	= "Утверждено"

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
'	ReportProjectParticipantsAndExpensesSortType - Тип сортировки в отчете "Список участников и затрат проекта"
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM	= 0		' Произвольно
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= 1		' По сотруднику
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE	= 2		' По выполненным заданиям
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT	= 3		' По оставшимся заданиям
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME	= 4		' По списанному времени
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME	= 5		' По затраченному времени
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= 6		' По запланированному времени
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME	= 7		' По общим трудозатратам
const REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME	= 8		' По оставшемуся времени

const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_RANDOM	= "Произвольно"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= "По сотруднику"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSDONE	= "По выполненным заданиям"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYTASKSLEFT	= "По оставшимся заданиям"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLOSTTIME	= "По списанному времени"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSPENTTIME	= "По затраченному времени"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= "По запланированному времени"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYSUMMARYTIME	= "По общим трудозатратам"
const NameOf_REPORTPROJECTPARTICIPANTSANDEXPENSESSORTTYPE_BYLEFTTIME	= "По оставшемуся времени"

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
'	ALBUM_TYPE - Тип альбома
const ALBUM_TYPE_STUDIO	= 0		' Студийный
const ALBUM_TYPE_CONCERT	= 1		' Концертный
const ALBUM_TYPE_COLLECTION	= 2		' Сборник
const ALBUM_TYPE_COVER	= 3		' Каверы

const NameOf_ALBUM_TYPE_STUDIO	= "Студийный"
const NameOf_ALBUM_TYPE_CONCERT	= "Концертный"
const NameOf_ALBUM_TYPE_COLLECTION	= "Сборник"
const NameOf_ALBUM_TYPE_COVER	= "Каверы"

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
'	PeriodType - Период времени
const PERIODTYPE_DATEINTERVAL	= 1		' Интервал дат
const PERIODTYPE_CURRENTWEEK	= 2		' На текущую неделю
const PERIODTYPE_CURRENTMONTH	= 3		' На текущий месяц
const PERIODTYPE_PREVIOUSMONTH	= 5		' На предыдущий месяц
const PERIODTYPE_SELECTEDQUARTER	= 4		' На заданный квартал

const NameOf_PERIODTYPE_DATEINTERVAL	= "Интервал дат"
const NameOf_PERIODTYPE_CURRENTWEEK	= "На текущую неделю"
const NameOf_PERIODTYPE_CURRENTMONTH	= "На текущий месяц"
const NameOf_PERIODTYPE_PREVIOUSMONTH	= "На предыдущий месяц"
const NameOf_PERIODTYPE_SELECTEDQUARTER	= "На заданный квартал"

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
'	LossDetalization - Детализация списаний сотрудников
const LOSSDETALIZATION_BYLOSSES	= 1		' по отдельным списаниям
const LOSSDETALIZATION_BYDATES	= 2		' по датам

const NameOf_LOSSDETALIZATION_BYLOSSES	= "по отдельным списаниям"
const NameOf_LOSSDETALIZATION_BYDATES	= "по датам"

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
'	OBJ_TYPE - Тип сущности
const OBJ_TYPE_CONTRACT	= 0		' Договор
const OBJ_TYPE_OUT_CONTRACT	= 1		' Расходный договор
const OBJ_TYPE_LOAN	= 2		' Займ
const OBJ_TYPE_OUT_DOC	= 3		' Расходный документ
const OBJ_TYPE_INC_DOC	= 4		' Приходный документ
const OBJ_TYPE_OUTCOME	= 5		' Расход
const OBJ_TYPE_INCOME	= 6		' Приход
const OBJ_TYPE_GENOUT_DOC	= 7		' Общий расходный документ
const OBJ_TYPE_GENOUTCOME	= 8		' Общий расход
const OBJ_TYPE_GENINCOME	= 9		' Общий приход
const OBJ_TYPE_BUDGET_OUT	= 10		' Бюджетный расход
const OBJ_TYPE_KASS_TRANS	= 30		' Движение ДС в кассе
const OBJ_TYPE_EMP_MONEY_MOVE	= 31		' Передача ДС
const OBJ_TYPE_AO	= 32		' АО

const NameOf_OBJ_TYPE_CONTRACT	= "Договор"
const NameOf_OBJ_TYPE_OUT_CONTRACT	= "Расходный договор"
const NameOf_OBJ_TYPE_LOAN	= "Займ"
const NameOf_OBJ_TYPE_OUT_DOC	= "Расходный документ"
const NameOf_OBJ_TYPE_INC_DOC	= "Приходный документ"
const NameOf_OBJ_TYPE_OUTCOME	= "Расход"
const NameOf_OBJ_TYPE_INCOME	= "Приход"
const NameOf_OBJ_TYPE_GENOUT_DOC	= "Общий расходный документ"
const NameOf_OBJ_TYPE_GENOUTCOME	= "Общий расход"
const NameOf_OBJ_TYPE_GENINCOME	= "Общий приход"
const NameOf_OBJ_TYPE_BUDGET_OUT	= "Бюджетный расход"
const NameOf_OBJ_TYPE_KASS_TRANS	= "Движение ДС в кассе"
const NameOf_OBJ_TYPE_EMP_MONEY_MOVE	= "Передача ДС"
const NameOf_OBJ_TYPE_AO	= "АО"

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
'	ActivityAnalysDepth - Глубина анализа активностей
const ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY	= 0		' только выбранная активность
const ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES	= 1		' подчиненные активности 1 уровня
const ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES	= 2		' подчиненные активности всех уровней

const NameOf_ACTIVITYANALYSDEPTH_ONLYCURRENTACTIVITY	= "только выбранная активность"
const NameOf_ACTIVITYANALYSDEPTH_FIRSTSTAGESUBACTIVITIES	= "подчиненные активности 1 уровня"
const NameOf_ACTIVITYANALYSDEPTH_ALLSTAGESSUBACTIVITIES	= "подчиненные активности всех уровней"

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
'	LotsAndParticipantsSortType - Тип сортировки лотов и участников
const LOTSANDPARTICIPANTSSORTTYPE_RANDOM	= 0		' Произвольно
const LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME	= 1		' По наименованию конкурса
const LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME	= 2		' По наименованию заказчика
const LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE	= 3		' По дате проведения

const NameOf_LOTSANDPARTICIPANTSSORTTYPE_RANDOM	= "Произвольно"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYTENDERNAME	= "По наименованию конкурса"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYCUSTOMERNAME	= "По наименованию заказчика"
const NameOf_LOTSANDPARTICIPANTSSORTTYPE_BYRESULTANNOUNCEDATE	= "По дате проведения"

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
'	DateDetalization - Детализация по датам
const DATEDETALIZATION_NODATE	= 0		' без дат (только сводные данные)
const DATEDETALIZATION_EXPENCESDATE	= 1		' даты с затратами (все колонки, имеющие данные)
const DATEDETALIZATION_ALLDATE	= 2		' все даты (все колонки отчета)

const NameOf_DATEDETALIZATION_NODATE	= "без дат (только сводные данные)"
const NameOf_DATEDETALIZATION_EXPENCESDATE	= "даты с затратами (все колонки, имеющие данные)"
const NameOf_DATEDETALIZATION_ALLDATE	= "все даты (все колонки отчета)"

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
'	PARTICIPATIONS - Тип участия
const PARTICIPATIONS_PARTICIPANT	= 1		' Участник
const PARTICIPATIONS_COMPETITOR	= 2		' Конкурент
const PARTICIPATIONS_HELPER	= 3		' Подигрывающий

const NameOf_PARTICIPATIONS_PARTICIPANT	= "Участник"
const NameOf_PARTICIPATIONS_COMPETITOR	= "Конкурент"
const NameOf_PARTICIPATIONS_HELPER	= "Подигрывающий"

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
'	StdObjectPrivileges - Стандартные объектные привилегии
const STDOBJECTPRIVILEGES_CREATE	= 1		' Создание
const STDOBJECTPRIVILEGES_EDIT	= 2		' Редактирование
const STDOBJECTPRIVILEGES_DELETE	= 4		' Удаление
const STDOBJECTPRIVILEGES_READ	= 8		' Чтение

const NameOf_STDOBJECTPRIVILEGES_CREATE	= "Создание"
const NameOf_STDOBJECTPRIVILEGES_EDIT	= "Редактирование"
const NameOf_STDOBJECTPRIVILEGES_DELETE	= "Удаление"
const NameOf_STDOBJECTPRIVILEGES_READ	= "Чтение"

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
'	RepDepartmentExpensesStructure_OptColsFlags - Отображаемые колонки отчета "Структура затрат подразделений"
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE	= 1		' Норма рабочего времени
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE	= 2		' Дисбаланс
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION	= 4		' Коэффициент утилизации
const REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION	= 8		' Причины списания

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODRATE	= "Норма рабочего времени"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWPERIODDISBALANCE	= "Дисбаланс"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWUTILIZATION	= "Коэффициент утилизации"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_OPTCOLSFLAGS_SHOWCAUSEDETAILIZATION	= "Причины списания"

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
'	IncidentPriority - Приоритет инцидента
const INCIDENTPRIORITY_HIGH	= 1		' Высокий
const INCIDENTPRIORITY_NORMAL	= 2		' Средний
const INCIDENTPRIORITY_LOW	= 3		' Низкий

const NameOf_INCIDENTPRIORITY_HIGH	= "Высокий"
const NameOf_INCIDENTPRIORITY_NORMAL	= "Средний"
const NameOf_INCIDENTPRIORITY_LOW	= "Низкий"

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
'	IncidentSortFields - Поля сортировки инцидентов
const INCIDENTSORTFIELDS_NAME	= "Name"		' Наименование
const INCIDENTSORTFIELDS_NUMBER	= "Number"		' Номер
const INCIDENTSORTFIELDS_PRIORITY	= "Priority"		' Приоритет
const INCIDENTSORTFIELDS_CATEGORY	= "Category"		' Категория состояния

const NameOf_INCIDENTSORTFIELDS_NAME	= "Наименование"
const NameOf_INCIDENTSORTFIELDS_NUMBER	= "Номер"
const NameOf_INCIDENTSORTFIELDS_PRIORITY	= "Приоритет"
const NameOf_INCIDENTSORTFIELDS_CATEGORY	= "Категория состояния"

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
'	EmployeeHistoryEvents - Тип события сотрудника
const EMPLOYEEHISTORYEVENTS_WORKBEGINDAY	= 1		' Выход на работу
const EMPLOYEEHISTORYEVENTS_WORKENDDAY	= 2		' Окончание работы
const EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY	= 3		' Временно нетрудоспособен
const EMPLOYEEHISTORYEVENTS_CHANGERATE	= 4		' Изменение нормы рабочего времени
const EMPLOYEEHISTORYEVENTS_CHANGESECURITY	= 5		' Изменение параметров безопасности

const NameOf_EMPLOYEEHISTORYEVENTS_WORKBEGINDAY	= "Выход на работу"
const NameOf_EMPLOYEEHISTORYEVENTS_WORKENDDAY	= "Окончание работы"
const NameOf_EMPLOYEEHISTORYEVENTS_TEMPORARYDISABILITY	= "Временно нетрудоспособен"
const NameOf_EMPLOYEEHISTORYEVENTS_CHANGERATE	= "Изменение нормы рабочего времени"
const NameOf_EMPLOYEEHISTORYEVENTS_CHANGESECURITY	= "Изменение параметров безопасности"

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
'	ServiceSystemType - Тип системы обслуживания
const SERVICESYSTEMTYPE_URL	= 1		' Ссылка URL
const SERVICESYSTEMTYPE_FILELINK	= 2		' Ссылка на файл
const SERVICESYSTEMTYPE_DIRECTORYLINK	= 3		' Ссылка на папку
const SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	= 4		' Ссылка на файл в Documentum
const SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	= 5		' Ссылка на папку в Documentum

const NameOf_SERVICESYSTEMTYPE_URL	= "Ссылка URL"
const NameOf_SERVICESYSTEMTYPE_FILELINK	= "Ссылка на файл"
const NameOf_SERVICESYSTEMTYPE_DIRECTORYLINK	= "Ссылка на папку"
const NameOf_SERVICESYSTEMTYPE_DOCUMENTUMFILELINK	= "Ссылка на файл в Documentum"
const NameOf_SERVICESYSTEMTYPE_DOCUMENTUMDIRECTORYLINK	= "Ссылка на папку в Documentum"

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
'	GK_INSTR_LOCATION - Местоположение инструмента
const GK_INSTR_LOCATION_WAITING	= 0		' В ожидании
const GK_INSTR_LOCATION_IN_COLLECTION	= 1		' В коллекции
const GK_INSTR_LOCATION_FOR_SALE	= 2		' На продажу
const GK_INSTR_LOCATION_SALED	= 3		' Продана

const NameOf_GK_INSTR_LOCATION_WAITING	= "В ожидании"
const NameOf_GK_INSTR_LOCATION_IN_COLLECTION	= "В коллекции"
const NameOf_GK_INSTR_LOCATION_FOR_SALE	= "На продажу"
const NameOf_GK_INSTR_LOCATION_SALED	= "Продана"

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
'	SortDirections - Направления сортировки
const SORTDIRECTIONS_ASC	= 1		' По возрастанию
const SORTDIRECTIONS_DESC	= 2		' По убыванию
const SORTDIRECTIONS_IGNORE	= 3		' Игнорировать

const NameOf_SORTDIRECTIONS_ASC	= "По возрастанию"
const NameOf_SORTDIRECTIONS_DESC	= "По убыванию"
const NameOf_SORTDIRECTIONS_IGNORE	= "Игнорировать"

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
'	ReportDepartmentCostSort - Сортировка отчета "Затраты в разрезе Департаментов"
const REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT	= 0		' По департаментам
const REPORTDEPARTMENTCOSTSORT_COSTSORT	= 1		' По затратам

const NameOf_REPORTDEPARTMENTCOSTSORT_DEPARTMENTSORT	= "По департаментам"
const NameOf_REPORTDEPARTMENTCOSTSORT_COSTSORT	= "По затратам"

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
'	LotState - Состояние лота
const LOTSTATE_PARTICIPATING	= 2		' Участие
const LOTSTATE_PARTICIPATEREJECTION	= 3		' Отказ от участия
const LOTSTATE_UNDERCONSIDERATION	= 4		' Рассмотрение предложения
const LOTSTATE_WASGAIN	= 5		' Выигран
const LOTSTATE_WASLOSS	= 6		' Проигран
const LOTSTATE_WASABOLISH	= 7		' Отменен

const NameOf_LOTSTATE_PARTICIPATING	= "Участие"
const NameOf_LOTSTATE_PARTICIPATEREJECTION	= "Отказ от участия"
const NameOf_LOTSTATE_UNDERCONSIDERATION	= "Рассмотрение предложения"
const NameOf_LOTSTATE_WASGAIN	= "Выигран"
const NameOf_LOTSTATE_WASLOSS	= "Проигран"
const NameOf_LOTSTATE_WASABOLISH	= "Отменен"

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
'	DepartmentAnalysDepth - Глубина анализа подразделений
const DEPARTMENTANALYSDEPTH_ONLYSELECTED	= 0		' только выбранное подразделение
const DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL	= 1		' подчиненные подразделения 1 уровня
const DEPARTMENTANALYSDEPTH_ALLSUBLEVELS	= 2		' подчиненные подразделения всех уровней

const NameOf_DEPARTMENTANALYSDEPTH_ONLYSELECTED	= "только выбранное подразделение"
const NameOf_DEPARTMENTANALYSDEPTH_FIRSTSUBLEVEL	= "подчиненные подразделения 1 уровня"
const NameOf_DEPARTMENTANALYSDEPTH_ALLSUBLEVELS	= "подчиненные подразделения всех уровней"

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
'	FolderHistoryEvents - Тип события папки
const FOLDERHISTORYEVENTS_WAITINGTOCLOSE	= 1		' Ожидание закрытия
const FOLDERHISTORYEVENTS_CLOSING	= 2		' Закрытие
const FOLDERHISTORYEVENTS_OPENING	= 3		' Открытие
const FOLDERHISTORYEVENTS_FROZING	= 4		' Замороживание
const FOLDERHISTORYEVENTS_UPGRADEFROMPILOT	= 6		' Переход из пилотной стадии
const FOLDERHISTORYEVENTS_BLOCKDATECHANGING	= 7		' Изменение даты блокирования списаний
const FOLDERHISTORYEVENTS_LINKTOFOLLOWING	= 8		' Установление связи с порожденной активностью
const FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING	= 9		' Разрыв связи с порожденной активностью
const FOLDERHISTORYEVENTS_CREATING	= 10		' Создание
const FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING	= 11		' Изменение данных по направлениям
const FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE	= 12		' Блокировка списаний на папку
const FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE	= 13		' Разрешение списаний на папку

const NameOf_FOLDERHISTORYEVENTS_WAITINGTOCLOSE	= "Ожидание закрытия"
const NameOf_FOLDERHISTORYEVENTS_CLOSING	= "Закрытие"
const NameOf_FOLDERHISTORYEVENTS_OPENING	= "Открытие"
const NameOf_FOLDERHISTORYEVENTS_FROZING	= "Замороживание"
const NameOf_FOLDERHISTORYEVENTS_UPGRADEFROMPILOT	= "Переход из пилотной стадии"
const NameOf_FOLDERHISTORYEVENTS_BLOCKDATECHANGING	= "Изменение даты блокирования списаний"
const NameOf_FOLDERHISTORYEVENTS_LINKTOFOLLOWING	= "Установление связи с порожденной активностью"
const NameOf_FOLDERHISTORYEVENTS_UNLINKTOFOLLOWING	= "Разрыв связи с порожденной активностью"
const NameOf_FOLDERHISTORYEVENTS_CREATING	= "Создание"
const NameOf_FOLDERHISTORYEVENTS_DIRECTIONINFOCHANGING	= "Изменение данных по направлениям"
const NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOTRUE	= "Блокировка списаний на папку"
const NameOf_FOLDERHISTORYEVENTS_ISLOCKEDSETTOFALSE	= "Разрешение списаний на папку"

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
'	ReportEmployeesBusynessInProjectsSortType - Тип сортировки в отчете "Занятость сотрудников в проектах"
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM	= 0		' произвольно
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER	= 1		' по аккаунту
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER	= 2		' по активности
const REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE	= 3		' по трудозатратам

const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_RANDOM	= "произвольно"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYCUSTOMER	= "по аккаунту"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYFOLDER	= "по активности"
const NameOf_REPORTEMPLOYEESBUSYNESSINPROJECTSSORTTYPE_BYEXPENSE	= "по трудозатратам"

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
'	DepartmentType - Тип подразделения
const DEPARTMENTTYPE_COSTSCENTER	= 1		' Центр затрат
const DEPARTMENTTYPE_PROFITCENTER	= 2		' Центр прибыли
const DEPARTMENTTYPE_DIRECTION	= 3		' Отдел

const NameOf_DEPARTMENTTYPE_COSTSCENTER	= "Центр затрат"
const NameOf_DEPARTMENTTYPE_PROFITCENTER	= "Центр прибыли"
const NameOf_DEPARTMENTTYPE_DIRECTION	= "Отдел"

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
'	IPROP_TYPE - Тип свойства инцидента
const IPROP_TYPE_IPROP_TYPE_LONG	= 1		' Целое число
const IPROP_TYPE_IPROP_TYPE_DOUBLE	= 2		' Число с плавающей точкой
const IPROP_TYPE_IPROP_TYPE_DATE	= 3		' Дата
const IPROP_TYPE_IPROP_TYPE_TIME	= 4		' Время
const IPROP_TYPE_IPROP_TYPE_DATEANDTIME	= 5		' Дата и время
const IPROP_TYPE_IPROP_TYPE_BOOLEAN	= 6		' Логический признак
const IPROP_TYPE_IPROP_TYPE_STRING	= 7		' Строка (до 4000 символов)
const IPROP_TYPE_IPROP_TYPE_TEXT	= 8		' Текст (более 4000 символов)
const IPROP_TYPE_IPROP_TYPE_PICTURE	= 9		' Изображение
const IPROP_TYPE_IPROP_TYPE_FILE	= 10		' Файл

const NameOf_IPROP_TYPE_IPROP_TYPE_LONG	= "Целое число"
const NameOf_IPROP_TYPE_IPROP_TYPE_DOUBLE	= "Число с плавающей точкой"
const NameOf_IPROP_TYPE_IPROP_TYPE_DATE	= "Дата"
const NameOf_IPROP_TYPE_IPROP_TYPE_TIME	= "Время"
const NameOf_IPROP_TYPE_IPROP_TYPE_DATEANDTIME	= "Дата и время"
const NameOf_IPROP_TYPE_IPROP_TYPE_BOOLEAN	= "Логический признак"
const NameOf_IPROP_TYPE_IPROP_TYPE_STRING	= "Строка (до 4000 символов)"
const NameOf_IPROP_TYPE_IPROP_TYPE_TEXT	= "Текст (более 4000 символов)"
const NameOf_IPROP_TYPE_IPROP_TYPE_PICTURE	= "Изображение"
const NameOf_IPROP_TYPE_IPROP_TYPE_FILE	= "Файл"

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
'	ShowedAttrs - Отображаемые атрибуты
const SHOWEDATTRS_PRIORITY	= 1		' Приоритет

const NameOf_SHOWEDATTRS_PRIORITY	= "Приоритет"

Function NameOf_ShowedAttrs(ByVal vVal)
	If Not IsNumeric(vVal) Then Exit Function
	Select Case CLng(vVal)
		Case SHOWEDATTRS_PRIORITY :
			NameOf_ShowedAttrs = NameOf_SHOWEDATTRS_PRIORITY
	End Select
End Function

'----------------------------------------------------------
'	AnalysDirection - Направление анализа
const ANALYSDIRECTION_LASTYEAREXPENSES	= 0		' за прошедший период
const ANALYSDIRECTION_OPENEDINCIDENTS	= 1		' открытые инциденты

const NameOf_ANALYSDIRECTION_LASTYEAREXPENSES	= "за прошедший период"
const NameOf_ANALYSDIRECTION_OPENEDINCIDENTS	= "открытые инциденты"

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
'	ReportTimeLossesSortType - Тип сортировки в отчете "Списание времени сотрудниками"
const REPORTTIMELOSSESSORTTYPE_RANDOM	= 0		' произвольно
const REPORTTIMELOSSESSORTTYPE_BYCAUSE	= 1		' по причине списания
const REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE	= 2		' по сотруднику
const REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED	= 3		' по дате списания

const NameOf_REPORTTIMELOSSESSORTTYPE_RANDOM	= "произвольно"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYCAUSE	= "по причине списания"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYEMPLOYEE	= "по сотруднику"
const NameOf_REPORTTIMELOSSESSORTTYPE_BYLOSSFIXED	= "по дате списания"

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
'	ReportProjectIncidentsAndExpensesSortType - Тип сортировки в отчете "Список инцидентов и затрат проекта"
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM	= 0		' Произвольно
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT	= 1		' По инциденту/списанию
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION	= 2		' По решению
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE	= 3		' По состоянию
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY	= 4		' По приоритету
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE	= 5		' По дате крайнего срока
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE	= 6		' По дате открытия
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE	= 7		' По дате последней смены состояния
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT	= 8		' По дате последней затраты времени
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE	= 9		' По роли
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= 10		' По сотруднику
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= 11		' По запланированному времени
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME	= 12		' По общим трудозатратам
const REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME	= 13		' По оставшемуся времени

const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_RANDOM	= "Произвольно"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINCIDENT	= "По инциденту/списанию"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSOLUTION	= "По решению"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSTATE	= "По состоянию"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPRIORITY	= "По приоритету"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYDEADLINE	= "По дате крайнего срока"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYINPUTDATE	= "По дате открытия"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTCHANGE	= "По дате последней смены состояния"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLASTSPENT	= "По дате последней затраты времени"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYROLE	= "По роли"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYEMPLOYEE	= "По сотруднику"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYPLANNEDTIME	= "По запланированному времени"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYSPENTTIME	= "По общим трудозатратам"
const NameOf_REPORTPROJECTINCIDENTSANDEXPENSESSORTTYPE_BYLEFTTIME	= "По оставшемуся времени"

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
'	TimeMeasureUnits - Единицы измерения времени
const TIMEMEASUREUNITS_DAYS	= 0		' Дни, часы, минуты
const TIMEMEASUREUNITS_HOURS	= 1		' Часы

const NameOf_TIMEMEASUREUNITS_DAYS	= "Дни, часы, минуты"
const NameOf_TIMEMEASUREUNITS_HOURS	= "Часы"

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
'	Quarter - Квартал
const QUARTER_FIRST	= 1		' 1-й
const QUARTER_SECOND	= 2		' 2-й
const QUARTER_THIRD	= 3		' 3-й
const QUARTER_FOURTH	= 4		' 4-й

const NameOf_QUARTER_FIRST	= "1-й"
const NameOf_QUARTER_SECOND	= "2-й"
const NameOf_QUARTER_THIRD	= "3-й"
const NameOf_QUARTER_FOURTH	= "4-й"

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
'	DepartmentDetalization - Детализация отчета «Затраты в разрезе Департаментов»» 
const DEPARTMENTDETALIZATION_WITHOUTDETALIZATION	= 0		' Без детализации
const DEPARTMENTDETALIZATION_BYDEPARTMENT	= 1		' По департаментам

const NameOf_DEPARTMENTDETALIZATION_WITHOUTDETALIZATION	= "Без детализации"
const NameOf_DEPARTMENTDETALIZATION_BYDEPARTMENT	= "По департаментам"

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
'	NDS_PRICE - Все цены
const NDS_PRICE_NO_NDS	= 0		' без НДС
const NDS_PRICE_NDS	= 1		' c НДС

const NameOf_NDS_PRICE_NO_NDS	= "без НДС"
const NameOf_NDS_PRICE_NDS	= "c НДС"

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
'	SystemPrivileges - Системные привилегии
const SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW	= 1		' Настройка workflow инцидентов
const SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD	= 2		' Установка глобального периода блокирования списаний
const SYSTEMPRIVILEGES_MANAGEUSERS	= 4		' Управление пользователями
const SYSTEMPRIVILEGES_MANAGETIMELOSS	= 8		' Управление чужими списаниями
const SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT	= 16		' Управление временным описанием организации
const SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT	= 32		' Управление организациями
const SYSTEMPRIVILEGES_MANAGEREFOBJECTS	= 64		' Управление справочниками
const SYSTEMPRIVILEGES_ACCESSINTOTMS	= 128		' Доступ к Системе учета тендеров
const SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS	= 256		' Перенос папок и инцидентов
const SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS	= 512		' Просмотр всех Организаций
const SYSTEMPRIVILEGES_CHANGETEMPORGONCONST	= 4096		' Замена временного описания Организации постоянным
const SYSTEMPRIVILEGES_DECIDINGMANINTMS	= 8192		' Принимающий решение в СУТ
const SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS	= 16384		' Управление справочниками СУТ
const SYSTEMPRIVILEGES_CLOSEANYFOLDER	= 32768		' Закрытие активностей
const SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT	= 65536		' Управление ролью Директор Аккаунта
const SYSTEMPRIVILEGES_MANAGEPROJECTTEAM	= 131072		' Управление проектной командой
const SYSTEMPRIVILEGES_MANAGECONTRACTS	= 262144		' Управление контрактами
const SYSTEMPRIVILEGES_MANAGEPROJINCOUT	= 524288		' Управление проектными приходами и расходами
const SYSTEMPRIVILEGES_MANAGEINCOUT	= 1048576		' Управление приходами и расходами
const SYSTEMPRIVILEGES_MANAGELOAN	= 2097152		' Управление займами
const SYSTEMPRIVILEGES_MANAGEFOT	= 4194304		' Управление ФОТ
const SYSTEMPRIVILEGES_ACCESSFINREPORTS	= 8388608		' Финансовая отчетность
const SYSTEMPRIVILEGES_CASHMANAGEMENT	= 16777216		' Управление кассой

const NameOf_SYSTEMPRIVILEGES_SETUPINCIDENTWORKFLOW	= "Настройка workflow инцидентов"
const NameOf_SYSTEMPRIVILEGES_SETUPGLOBALBLOCKPERIOD	= "Установка глобального периода блокирования списаний"
const NameOf_SYSTEMPRIVILEGES_MANAGEUSERS	= "Управление пользователями"
const NameOf_SYSTEMPRIVILEGES_MANAGETIMELOSS	= "Управление чужими списаниями"
const NameOf_SYSTEMPRIVILEGES_TEMPORGANIZATIONMANAGMENT	= "Управление временным описанием организации"
const NameOf_SYSTEMPRIVILEGES_ORGANIZATIONMANAGEMENT	= "Управление организациями"
const NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTS	= "Управление справочниками"
const NameOf_SYSTEMPRIVILEGES_ACCESSINTOTMS	= "Доступ к Системе учета тендеров"
const NameOf_SYSTEMPRIVILEGES_MOVEFOLDERSANDINCIDENTS	= "Перенос папок и инцидентов"
const NameOf_SYSTEMPRIVILEGES_VIEWALLORGANIZATIONS	= "Просмотр всех Организаций"
const NameOf_SYSTEMPRIVILEGES_CHANGETEMPORGONCONST	= "Замена временного описания Организации постоянным"
const NameOf_SYSTEMPRIVILEGES_DECIDINGMANINTMS	= "Принимающий решение в СУТ"
const NameOf_SYSTEMPRIVILEGES_MANAGEREFOBJECTSINTMS	= "Управление справочниками СУТ"
const NameOf_SYSTEMPRIVILEGES_CLOSEANYFOLDER	= "Закрытие активностей"
const NameOf_SYSTEMPRIVILEGES_MANAGEDIRECTORACCOUNT	= "Управление ролью Директор Аккаунта"
const NameOf_SYSTEMPRIVILEGES_MANAGEPROJECTTEAM	= "Управление проектной командой"
const NameOf_SYSTEMPRIVILEGES_MANAGECONTRACTS	= "Управление контрактами"
const NameOf_SYSTEMPRIVILEGES_MANAGEPROJINCOUT	= "Управление проектными приходами и расходами"
const NameOf_SYSTEMPRIVILEGES_MANAGEINCOUT	= "Управление приходами и расходами"
const NameOf_SYSTEMPRIVILEGES_MANAGELOAN	= "Управление займами"
const NameOf_SYSTEMPRIVILEGES_MANAGEFOT	= "Управление ФОТ"
const NameOf_SYSTEMPRIVILEGES_ACCESSFINREPORTS	= "Финансовая отчетность"
const NameOf_SYSTEMPRIVILEGES_CASHMANAGEMENT	= "Управление кассой"

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
'	DateIntervalType - Тип временного интервала
const DATEINTERVALTYPE_DATERATIOINTERVAL	= 1		' Выбрать из списка
const DATEINTERVALTYPE_SETDATEINTERVAL	= 2		' Указать интервал дат

const NameOf_DATEINTERVALTYPE_DATERATIOINTERVAL	= "Выбрать из списка"
const NameOf_DATEINTERVALTYPE_SETDATEINTERVAL	= "Указать интервал дат"

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
'	RepDepartmentExpensesStructure_SortingMode - Сортировка в отчете "Структура затрат подразделений"
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME	= 0		' По подразделению / сотруднику
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES	= 1		' По трудозатратам
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE	= 2		' По значению дисбаланса
const REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION	= 3		' По значению коэффициента утилизации

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYNAME	= "По подразделению / сотруднику"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYEXPENSES	= "По трудозатратам"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYDISBALANCE	= "По значению дисбаланса"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_SORTINGMODE_BYUTILIZATION	= "По значению коэффициента утилизации"

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
'	ActivitySelection - Выборка активностей
const ACTIVITYSELECTION_HAVEEXPENSES	= 1		' с затратами за период
const ACTIVITYSELECTION_WAITINGFORCLOSE	= 2		' переведенные в ожидание закрытия
const ACTIVITYSELECTION_CLOSED	= 3		' закрытые за период

const NameOf_ACTIVITYSELECTION_HAVEEXPENSES	= "с затратами за период"
const NameOf_ACTIVITYSELECTION_WAITINGFORCLOSE	= "переведенные в ожидание закрытия"
const NameOf_ACTIVITYSELECTION_CLOSED	= "закрытые за период"

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
'	ReportLastExpenseDatesSortType - Тип сортировки в отчете "Даты последнего учета затрат сотрудниками"
const REPORTLASTEXPENSEDATESSORTTYPE_RANDOM	= 0		' произвольно
const REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE	= 1		' по сотруднику
const REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME	= 2		' по дате и времени

const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_RANDOM	= "произвольно"
const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYEMPLOYEE	= "по сотруднику"
const NameOf_REPORTLASTEXPENSEDATESSORTTYPE_BYDATETIME	= "по дате и времени"

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
'	RepDepartmentExpensesStructure_DataFormat - Форма представления данных отчета "Структура затрат подразделений"
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT	= 0		' Время и проценты
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME	= 1		' Только время
const REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT	= 2		' Только проценты

const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_TIMEANDPERCENT	= "Время и проценты"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYTIME	= "Только время"
const NameOf_REPDEPARTMENTEXPENSESSTRUCTURE_DATAFORMAT_ONLYPERCENT	= "Только проценты"

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
'	FolderTypeFlags - Тип папки flags
const FOLDERTYPEFLAGS_PROJECT	= 1		' Проект
const FOLDERTYPEFLAGS_TENDER	= 4		' Тендер
const FOLDERTYPEFLAGS_PRESALE	= 8		' Пресейл
const FOLDERTYPEFLAGS_DIRECTORY	= 16		' Каталог

const NameOf_FOLDERTYPEFLAGS_PROJECT	= "Проект"
const NameOf_FOLDERTYPEFLAGS_TENDER	= "Тендер"
const NameOf_FOLDERTYPEFLAGS_PRESALE	= "Пресейл"
const NameOf_FOLDERTYPEFLAGS_DIRECTORY	= "Каталог"

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
'	TYPE_MONEY_TRANS - Тип движения ДС в кассе
const TYPE_MONEY_TRANS_INCOME	= 0		' Поступление
const TYPE_MONEY_TRANS_OUT_EMP	= 1		' Выдача сотруднику
const TYPE_MONEY_TRANS_INC_EMP	= 2		' Возврат сотрудником

const NameOf_TYPE_MONEY_TRANS_INCOME	= "Поступление"
const NameOf_TYPE_MONEY_TRANS_OUT_EMP	= "Выдача сотруднику"
const NameOf_TYPE_MONEY_TRANS_INC_EMP	= "Возврат сотрудником"

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
'	SortIncidentExpenses - Сортировка инцидентов и затрат
const SORTINCIDENTEXPENSES_BYDATETIME	= 0		' по дате и времени
const SORTINCIDENTEXPENSES_BYLOSSREASON	= 1		' по причине списания
const SORTINCIDENTEXPENSES_BYSPENTTIME	= 2		' по затраченному времени

const NameOf_SORTINCIDENTEXPENSES_BYDATETIME	= "по дате и времени"
const NameOf_SORTINCIDENTEXPENSES_BYLOSSREASON	= "по причине списания"
const NameOf_SORTINCIDENTEXPENSES_BYSPENTTIME	= "по затраченному времени"

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
'	TYPE_SUPPLAING - Тип комплектации
const TYPE_SUPPLAING_PROC_FROM_DIFF	= 0		' Процент от разницы
const TYPE_SUPPLAING_PROC_FROM_SUM	= 1		' Процент от суммы
const TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL	= 2		' Процент от суммы поставки

const NameOf_TYPE_SUPPLAING_PROC_FROM_DIFF	= "Процент от разницы"
const NameOf_TYPE_SUPPLAING_PROC_FROM_SUM	= "Процент от суммы"
const NameOf_TYPE_SUPPLAING_PROC_FROM_SUM_SUPPL	= "Процент от суммы поставки"

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
'	ACTION_TYPE - Тип операции
const ACTION_TYPE_INSERT	= 0		' Создание
const ACTION_TYPE_UPDATE	= 1		' Измененние
const ACTION_TYPE_DELETE	= 2		' Удаление

const NameOf_ACTION_TYPE_INSERT	= "Создание"
const NameOf_ACTION_TYPE_UPDATE	= "Измененние"
const NameOf_ACTION_TYPE_DELETE	= "Удаление"

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
'	MC_TYPE_OF_MUS_ACTION - Тип участия музыканта
const MC_TYPE_OF_MUS_ACTION_VOCAL	= 1		' Вокал
const MC_TYPE_OF_MUS_ACTION_GUITAR	= 2		' Гитара
const MC_TYPE_OF_MUS_ACTION_BASS	= 4		' Бас
const MC_TYPE_OF_MUS_ACTION_DRUMS	= 8		' Ударные
const MC_TYPE_OF_MUS_ACTION_PERCISSION	= 16		' Перкуссия
const MC_TYPE_OF_MUS_ACTION_KEYS	= 32		' Клавишные
const MC_TYPE_OF_MUS_ACTION_SM	= 64		' Смычковые
const MC_TYPE_OF_MUS_ACTION_DUH	= 128		' Духовые
const MC_TYPE_OF_MUS_ACTION_PRODUCER	= 131071		' Продюсер

const NameOf_MC_TYPE_OF_MUS_ACTION_VOCAL	= "Вокал"
const NameOf_MC_TYPE_OF_MUS_ACTION_GUITAR	= "Гитара"
const NameOf_MC_TYPE_OF_MUS_ACTION_BASS	= "Бас"
const NameOf_MC_TYPE_OF_MUS_ACTION_DRUMS	= "Ударные"
const NameOf_MC_TYPE_OF_MUS_ACTION_PERCISSION	= "Перкуссия"
const NameOf_MC_TYPE_OF_MUS_ACTION_KEYS	= "Клавишные"
const NameOf_MC_TYPE_OF_MUS_ACTION_SM	= "Смычковые"
const NameOf_MC_TYPE_OF_MUS_ACTION_DUH	= "Духовые"
const NameOf_MC_TYPE_OF_MUS_ACTION_PRODUCER	= "Продюсер"

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
'	FolderStates - Состояние папки
const FOLDERSTATES_OPEN	= 1		' Открыто
const FOLDERSTATES_WAITINGTOCLOSE	= 2		' Ожидание закрытия
const FOLDERSTATES_CLOSED	= 4		' Закрыто
const FOLDERSTATES_FROZEN	= 8		' Заморожено

const NameOf_FOLDERSTATES_OPEN	= "Открыто"
const NameOf_FOLDERSTATES_WAITINGTOCLOSE	= "Ожидание закрытия"
const NameOf_FOLDERSTATES_CLOSED	= "Закрыто"
const NameOf_FOLDERSTATES_FROZEN	= "Заморожено"

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
'	IncidentStateDetalization - Детализация состояний инцидента
const INCIDENTSTATEDETALIZATION_ALLSTATES	= 0		' по всем состояниям
const INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES	= 1		' по открытию и закрытию
const INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY	= 2		' без детализации (только открытые)

const NameOf_INCIDENTSTATEDETALIZATION_ALLSTATES	= "по всем состояниям"
const NameOf_INCIDENTSTATEDETALIZATION_OPENANDCLOSEDSTATES	= "по открытию и закрытию"
const NameOf_INCIDENTSTATEDETALIZATION_OFFDETALIZATIONOPENSTATESONLY	= "без детализации (только открытые)"

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
'	FilterReportEmploymentPlannedSortType - Тип сортировки в отчете "Плановая занятость сотрудников"
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION	= 0		' Без детализации
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD	= 1		' По периодам
const FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT	= 2		' По периодам и проектам

const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_WITHOUTSPECIFICATION	= "Без детализации"
const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD	= "По периодам"
const NameOf_FILTERREPORTEMPLOYMENTPLANNEDSORTTYPE_PERIOD_PROJECT	= "По периодам и проектам"

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

