Option Explicit

' Определение глобальных переменных, сохраняющих (кеширующих) ссылки на объекты,
' обслуживающие редактор объекта
Dim g_oObjectEditor	' Объект-редактор объекта (ObjectEditorClass)

Private Const CASE_NOMINATIVE 	= 1	' Именительный падеж
Private Const CASE_INSTRUMENTAL	= 2	' Творительный падеж

'==============================================================================
' Формирует наименования видов активностей, заданный маской (nActivityTypes) в зависимости от падежа (nCase)
' Только для использования в функции GetFilterStateDescription!
'	[in] nActivityTypes - маска видов активностей
'	[in] nCase - падеж (CASE_NOMINATIVE или CASE_INSTRUMENTAL)
'	[out] s1
'	[out] s2
'	[out] s3
Private Function initActivityNameParts(nActivityTypes, nCase, ByRef s1, ByRef s2, ByRef s3)
	Dim nParts				' количество заданных форм (0,1,2,3)
	Dim sProjectName		' форма слова "проекты"
	Dim sTenderName			' форма слова "тендеры"
	Dim sPresaleName		' форма слова "пресейлы"
	Dim sActivitiesName		' форма слова "активности"
	
	If nCase = CASE_NOMINATIVE Then
		sProjectName	= "проекты"
		sTenderName		= "тендеры"
		sPresaleName	= "пресейлы"
		sActivitiesName	= "активности"
	Else
		sProjectName	= "проектами"
		sTenderName		= "тендерами"
		sPresaleName	= "пресейлами"
		sActivitiesName	= "активностями"
	End If
	
	nParts = 0
	If nActivityTypes = 0 Then
		s1	= sActivitiesName
		nParts = 1
	Else
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_PROJECT)) > 0 Then
			s1 = sProjectName
			nParts = nParts + 1
		End If
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_TENDER)) > 0 Then
			If IsEmpty(s1) Then 
				s1 = sTenderName
			Else
				s2 = sTenderName
			End If
			nParts = nParts + 1
		End If
		If (nActivityTypes AND CLng(FOLDERTYPEFLAGS_PRESALE)) > 0 Then
			If IsEmpty(s1) Then 
				s1 = sPresaleName
			ElseIf IsEmpty(s2) Then
				s2 = sPresaleName
			Else
				s3 = sPresaleName
			End If
			nParts = nParts + 1
		End If
		If nParts = 3 Then
		    s1	= sActivitiesName
		    nParts = 1
		End If
	End If
	initActivityNameParts = nParts
End Function


'==============================================================================
' Вызывается из XSL для вывода информации о состоянии фильтра
Function GetFilterStateDescription()
	
	Dim sResult						' Формируемая строка
	Dim nMode						'
	Dim bOnlyOwnActivities			' Значение свойства-флага "Только мои активности"
	Dim bShowOrgWithoutActivities	' Значение свойства-флага "Отображать организации без активностей"
	Dim oDirections                 ' Направления 
	Dim nActivityState              ' Состояния активностей 
	Dim nFolderState                ' Состояния папок
	Dim nActivityTypes              '
	Dim s1, s2, s3
	Dim nParts						' 
	Dim sOrgName					' наименование организации
	Dim sFolderName 				' наименование папки
	Dim nCase						' падеж  
	Dim bFilterExists               ' Выбраны дополнительные фильтры
	nMode = g_oObjectEditor.XmlObject.selectSingleNode("Mode").nodeTypedValue
	nActivityState = g_oObjectEditor.XmlObject.selectSingleNode("ActivityState").nodeTypedValue
	nFolderState = g_oObjectEditor.XmlObject.selectSingleNode("FolderState").nodeTypedValue
	Set oDirections = g_oObjectEditor.XmlObject.selectSingleNode("Directions/Direction[@oid]")
	bOnlyOwnActivities  = g_oObjectEditor.XmlObject.selectSingleNode("OnlyOwnActivity").nodeTypedValue
	bShowOrgWithoutActivities = g_oObjectEditor.XmlObject.selectSingleNode("ShowOrgWithoutActivities").nodeTypedValue
	nActivityTypes		= CLng( g_oObjectEditor.XmlObject.selectSingleNode("ActivityTypes").nodeTypedValue )
	sOrgName 	= g_oObjectEditor.XmlObject.selectSingleNode("OrganizationName").nodeTypedValue
	sFolderName = g_oObjectEditor.XmlObject.selectSingleNode("FolderName").nodeTypedValue
	If nMode = DKPTREEMODES_ORGANIZATIONS Then
		If bShowOrgWithoutActivities Then
			sResult = "Все организации"
			nParts = -1
		Else
			' Режим "Организации"
			sResult = "Организации"
			sResult = sResult & " с"
			If bOnlyOwnActivities Then
				sResult = sResult & " моими"
			End if
			sResult = sResult & " "
			nCase = CASE_INSTRUMENTAL
			nParts = initActivityNameParts(nActivityTypes, CASE_INSTRUMENTAL, s1, s2, s3)
		End If
	Else
		' Режим "Активности"
		If bOnlyOwnActivities Then
			sResult = sResult & "Мои "
		End if
		nCase = CASE_NOMINATIVE
		nParts = initActivityNameParts(nActivityTypes, CASE_NOMINATIVE, s1, s2, s3)
		If IsEmpty(sResult) Then
			s1 = UCase( Left(s1,1) ) & Mid(s1, 2)
		End If
	End If
	' добавим сочетание слов "проекты, тендеры и пресейлы"
	Select Case nParts
	    Case 1
	        sResult = sResult & s1
	    Case 2
	        sResult = sResult & s1 & " и " & s2
	    Case 3
	        sResult = sResult & s1 & ", " & s2 & " и " & s3
	End Select
	IF (Not oDirections Is Nothing) Or (nActivityState <> 0) Or (nFolderState <> 0) Or (Len("" & sFolderName) > 0) Or (Len("" & sOrgName) > 0) Then 
	   sResult = sResult & " (согласно выбранным фильтрам)" 
	End If
	GetFilterStateDescription = "" & sResult
End Function


'==============================================================================
Sub usrXEditor_OnLoad( oSender, oEventArgs )
    ' Сохраним ссылку на экземпляр класса редактора объекта ObjectEditorClass
	Set g_oObjectEditor = oSender
	' подпишемся на событие "AfterEnableControls" 1-ой страницы
	oSender.Pages.Items()(0).EventEngine.AddHandlerForEvent "AfterEnableControls", Null, "OnAfterEnableControls"
End Sub


'==============================================================================
' Назначение:	Обработчик события редактора PageStart
' Результат:    -
' Параметры:	oSender - объект, генерирующий событие; здесь - редактор объекта
'				oEventArgs - объект, описывающий параметры события, здесь Null
' Примечание:	Процедура-обработчик события вызывается по завершению "отрисовки"
'				страницы редактора; 
Sub usrXEditor_OnPageStart( oSender, oEventArgs )
	Dim bIsFilterSet			' Признак того, что в фильтре заданы данные
	Dim oBtnOpenFilterDialog	' Ссылка на HTML-DOM объект кнопки "Установить"
	Dim oBtnClearFilter			' Ссылка на HTML-DOM объект кнопки "Сбросить"
    
	' Определяем ссылки на HTML-конопки и "навешиваем" обработчики соыбтия клика 
	With g_oObjectEditor.CurrentPage.HtmlDivElement
		' Кнопка "Установить (фильтр)"		
		Set oBtnOpenFilterDialog = .all.item("btnOpenFilterDialog")
		If Not(oBtnOpenFilterDialog Is Nothing) Then 
			Set oBtnOpenFilterDialog.onClick = GetRef("OnOpenFilterDialog")
		End If
	End With
	updateTreeModeDescription
	updateIncidentSortModeDescription
End Sub


'==============================================================================
' Назначение:	Обработчик события нажатия кнопки "Установить (фильтр)"
'				Вызывает "внешний" диалог редактирования временного объекта,
'				задающего параметры фильтра; при получении таких параметров
'				вызывает перерисовку страницы текущего редактора (фильтра в 
'				списке) и перезагрузку списка, зависимого от фильтра 
' Результат:    -
' Параметры:	-
Sub OnOpenFilterDialog()
	Dim oFilterDialog	' Параметры диалога редактора (временного объекта)
	Dim vResult			' Результат работы редактора 
	Dim nOldTS			' ts до вызова редактора в диалге
	
	' Создаем служебный объект, задающий параметры диалога редактора:
	Set oFilterDialog = new ObjectEditorDialogClass
	' ...в вызываемый редактр передается объект данного редактора (через него 
	' осуществляется запись данных редактируемого временного объекта в общий
	' пул):
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	' ...указываем при этом тип и идентификатор редактируемого объекта - это 
	' тот же объект, что отображается данным редактором:
	oFilterDialog.ObjectType = "FilterDKP"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	' ...указываем метанаименование описания редактора, используемого при 
	' построении интерфейса диалога (см. определения в метаданных):
	oFilterDialog.MetaName = "EditorInDialog"
	oFilterDialog.IsNewObject = true
	nOldTS = SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts"))
	
	' Вызываем отображение диалога редактора:
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	If ( nOldTS <> SafeCLng(g_oObjectEditor.XmlObject.getAttribute("ts")) ) Then
		' изменился ts объекта. Это значит в диалоге нажали кнопку "Закрыть"
		updateTreeModeDescription
	Else
		' Если получили в результате Empty, это означает, что редактор был закрыт
		' без внесения изменений (по кнопке "Отменить" или явно); в этом случае, 
		' ничего не изменяя, просто выходим из обработчика
		If Not hasValue(vResult) Then Exit Sub

		updateTreeModeDescription		
		
		' Вызываем внутренний метод, приводящий к перегрузке списка, зависящего 
		' от фильтра:
		ReloadTree
	End If
End Sub


'==============================================================================
' Обновляет описание текущего режима дерева
Sub updateTreeModeDescription
    oTreeModeDescription.innerText = GetFilterStateDescription
End Sub


'==============================================================================
' Назначение:	Вызывает перезагрузку дереве посленаложения фильтра
' Результат:    -
' Параметры:	-
Sub ReloadTree()
    window.parent.Reload()
	XService.DoEvents()
End Sub



'==============================================================================
' Обработчик клика на кнопке открытия диалога настройки сортировки инцидентов
Sub OnOpenIncidentSortDialog()
	Dim oFilterDialog	' Параметры диалога редактора (временного объекта)
	Dim vResult			' Результат работы редактора 

	Set oFilterDialog = new ObjectEditorDialogClass
	Set oFilterDialog.ParentObjectEditor = g_oObjectEditor
	oFilterDialog.ObjectType = "FilterDKP"
	oFilterDialog.ObjectID = g_oObjectEditor.ObjectID
	oFilterDialog.MetaName = "IncidentSortEditorInDialog"
	oFilterDialog.IsNewObject = true
	vResult = ObjectEditorDialogClass_Show(oFilterDialog)
	If Not IsEmpty(vResult) Then
		InitIncidentSortMode
		updateIncidentSortModeDescription
		ReloadTree
	End If
End Sub


'==============================================================================
' Обработчик клика на кнопке сброса сортировки с состояние "по умолчанию"
Sub OnSetIncidentSortDefault
	g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*").removeAll
	g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = ""
	updateIncidentSortModeDescription
	ReloadTree
End Sub


'==============================================================================
Function InitIncidentSortMode
	Dim oItems
	Dim oItem
	Dim sParamValue
	
	Set oItems = g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*")
	For Each oItem In oItems
		Set oItem = g_oObjectEditor.Pool.GetXmlObjectByXmlElement(oItem, Null)
		If oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_DESC Then
			If Not IsEmpty(sParamValue) Then sParamValue = sParamValue & ":"
			sParamValue = sParamValue & oItem.selectSingleNode("Field").text &	"-"
		ElseIf oItem.selectSingleNode("Direction").nodeTypedValue = SORTDIRECTIONS_ASC Then
			If Not IsEmpty(sParamValue) Then sParamValue = sParamValue & ":"
			sParamValue = sParamValue & oItem.selectSingleNode("Field").text &	"+"
		ENd If
	Next
	g_oObjectEditor.XmlObject.selectSingleNode("IncidentSortMode").nodeTypedValue = sParamValue
End Function


'==============================================================================
' Формирует описание режима сортировки инцидентов
Function GetIncidentSortMode()
	Dim oItems
	Dim oItem
	Dim sDesc
	Dim nMode
	
	Set oItems = g_oObjectEditor.XmlObject.selectNodes("IncidentSortOrder/*")
	For Each oItem In oItems
		Set oItem = g_oObjectEditor.Pool.GetXmlObjectByXmlElement(oItem, Null)
		nMode = oItem.selectSingleNode("Direction").nodeTypedValue
		If nMode = SORTDIRECTIONS_ASC OR nMode = SORTDIRECTIONS_DESC Then
			If Not IsEmpty(sDesc) Then sDesc = sDesc & ", "
			sDesc = sDesc & NameOf_IncidentSortFields( oItem.selectSingleNode("Field").text )
		End If
	Next

	If IsEmpty(sDesc) Then sDesc = "по умолчанию"	
	GetIncidentSortMode = sDesc
End Function


'==============================================================================
' Обновляет поле отображения режимов сортировки инцидентов
Sub updateIncidentSortModeDescription
	oIncidentSortModeDescription.innerText = GetIncidentSortMode()
End Sub


'==========================================================================
' Обработчик события "AfterEnableControls" страницы редактора
'	[in] oEventArgs As EnableControlsEventArgs
Public Sub OnAfterEnableControls(oSender, oEventArgs)
	document.all("btnOpenFilterDialog").disabled = Not oEventArgs.Enable
	document.all("btnOpenIncidentSortDialog").disabled = Not oEventArgs.Enable
	document.all("btnSetIncidentSortDefault").disabled = Not oEventArgs.Enable
End Sub
