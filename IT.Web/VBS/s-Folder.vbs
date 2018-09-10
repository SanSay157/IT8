'Обработчик редактора для объекта "Folder"
Option Explicit

Dim g_oObjectEditor			' текущий редактор (устанавливается один раз в OnLoad)
Dim g_oPool					' текущий пул (устанавливается один раз в OnLoad)
Dim g_nFolderType			' As Integer - тип папки
Dim g_sActivityTypeID		' идентификатор типа проектных затрат
Dim g_sActivityTypePath		' Путь из наименований типов проектных затрат
Dim g_sOrgPath				' Путь из наименований организаций
Dim g_sParentFolderPath		' Путь из наименований вышестоящих проектов
Dim g_bUserIsAdmin          ' Признак 
Dim g_bIsLocked             ' Признак блокировки списаний
g_bIsLocked = False
'==============================================================================
' ::Загрузка редактора
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	Set g_oPool = oSender.Pool
	
	g_nFolderType = oSender.Pool.GetPropertyValue(oSender.XmlObject, "Type")
	If oSender.Metaname = "Universal" Then
		' В "универсальном" мастере на первом шаге выполняется выбор "типа проектных 
		' затрат", из него планируется получить тип папки
	Else
		' Проверим, что в мастере задан тип папки и ссылка на клиента
		If oSender.IsObjectCreationMode Then
			If CLng(g_nFolderType) = 0 Then
				Err.Raise -1, "", "Не задан тип папки"
			End If
			
			' вид активности задан снаружи 
			If oSender.XmlObject.selectSingleNode("ActivityType").hasChildNodes Then
				g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
			' иначе, если задана родительская папка, возьмем ее вид активности
			ElseIf oSender.XmlObject.selectSingleNode("Parent").hasChildNodes Then
				g_sActivityTypeID = g_oPool.GetXmlObjectByOPath(oSender.XmlObject, "Parent").selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
			Else
				' иначе выберем внешнюю активность на основании типа папки - она должна быть одна
				Dim oListData
				Dim oXmlRow
				On Error Resume Next
				Set oListData = X_GetListDataFromServer("ActivityType", "ActivityTypeByFolderType", X_CreateListLoaderRestrictions("AccountRelated=1&FolderType=" & g_nFolderType,Null,Null))
				If Err Then
					Alert Err.Description
					window.close
				ElseIf Not oListData Is Nothing Then
					On Error GoTo 0
					Set oXmlRow = oListData.selectSingleNode("RS/R")
					If Not oXmlRow Is Nothing Then
						g_sActivityTypeID = oXmlRow.getAttribute("id")
						g_oPool.AddRelation oSender.XmlObject, "ActivityType", X_CreateObjectStub("ActivityType", g_sActivityTypeID)
					End If
				End If
				If Len("" & g_sActivityTypeID) = 0 Then
					Alert "Не удалось инициализировать тип проектных затрат" & vbCr & "Тип папки: " & g_nFolderType
					window.close
				End If
			End If
		Else
			g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
		End If
	End If
End Sub


'==============================================================================
' :: Валидация данных страницы
'	[in] oEventArgs As oEditorStateChangedArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim vbRet	' Результат выбора пользователя, в сообщениях подтверждения
	Dim sMsg	' Текст сообщения
  	' Обработка ухода с 1-го шага "универсального" мастера с выбором типа проектных затрат на 1-ом шаге
	If oSender.Metaname = "Universal" And oSender.CurrentPage.PageName = "SelectActivityType" Then
		g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
		g_nFolderType = CLng(oSender.Pool.GetPropertyValue(oSender.XmlObject, "ActivityType.FolderType"))
		g_nFolderType = (g_nFolderType AND FOLDERTYPEENUM_PROJECT) OR (g_nFolderType AND FOLDERTYPEENUM_TENDER) OR (g_nFolderType AND FOLDERTYPEENUM_PRESALE)
		If g_nFolderType = 0 Then
			oEventArgs.ErrorMessage = "Не удалось инициализировать тип папки на основании выбранного типа проектных затрат"
			oEventArgs.ReturnValue = False
		End If
		oSender.XmlObject.selectSingleNode("Type").nodeTypedValue = g_nFolderType
	End If

	If oSender.CurrentPage.PageName = "Directions" Then
        If (g_bDirectionHasBeenChanged) Then
            If (Not IsEmpty(g_sDirectionNewValue)) Then
                If (g_bChildDirectionChange) Then              
                    vbRet = MsgBox ( _
					    "Удалить направления у всех вложенных активностей/каталогов и назначить выбранное для активности/каталога?", _
					    vbYesNo + vbExclamation, "Внимание!" )
		            If ( vbNo = vbRet ) Then
				        oEventArgs.ReturnValue = False
		    	    End If
                 End If
            ElseIf (Not IsEmpty(g_sDirectionOldValue) And IsEmpty(g_sDirectionNewValue)) Then
                If (g_bChildDirectionChange) Then              
                    vbRet = MsgBox ( _
					    "Удалить направления у всех вложенных активностей/каталогов?", _
					    vbYesNo + vbExclamation, "Внимание!" )
		            If ( vbNo = vbRet ) Then
				        oEventArgs.ReturnValue = False
		    	    End If
                 End If
            End If
        End If
		CheckExpcenseRatioSum oSender
		If ( g_nSingleFolderDirectionMode <> 0 ) Then
		
			If g_nHasIncorectExpenseRatioSum > 100 Then
				oEventArgs.ReturnValue = False
				oEventArgs.ErrorMessage = _
					"Внимание!" & vbCrLf & _
					vbCrLf & _
					"Сумма долей затрат, заданных для указанных направлений, превышает 100%!" & vbCrLf & _
					"Такое определение долей является некорректным, и не может быть записано."  & vbCrLf & _
					vbCrLf & _
					"Пожалуйста, задайте корректные определения долей затрат."
				
			ElseIf g_nHasIncorectExpenseRatioSum < 100 Then
				oEventArgs.ReturnValue = False

				sMsg = _
					"Внимание!" & vbCrLf & vbCrLf & _
					"Сумма долей затрат, заданных для указанных направлений, менее 100%!" & vbCrLf & _
					"Такое определение долей является некорректным, и не может быть записано."  & vbCrLf & vbCrLf
				
				vbRet = MsgBox ( _
					sMsg & "Произвести распределение остатка по направлениям?", _
					vbYesNo + vbQuestion, "Внимание!" )	
				If ( vbNo = vbRet ) Then
					oEventArgs.ErrorMessage = sMsg & "Пожалуйста, задайте корректные определения долей затрат."
					
				Else
					' Произведем перерасчет
					RecalculateFolderDirections oSender, g_nHasIncorectExpenseRatioSum
					oSender.CurrentPage.SetData
					CheckExpcenseRatioSum oSender

					' ... т.к. oEventArgs.ReturnValue установлен в False, то 
					' по завершению обработчика все равно останемся в редакторе
				End If
				
			End If
		End If
	End If
	
End Sub


'==============================================================================
' Производит перерасчёт
Sub RecalculateFolderDirections( oObjectEditor, nCurrentSum )
	Dim nDelta: nDelta = 100 - nCurrentSum
	Dim oDirections: Set oDirections = oObjectEditor.Pool.GetXmlObjectsByOPath(oObjectEditor.XmlObject, "FolderDirections")
	Dim nCount
	Dim nInc
    Dim oNavigator
	Set oNavigator =  oObjectEditor.CreateXmlObjectNavigatorFor(oObjectEditor.XmlObject)
	oNavigator.ExpandProperty "FolderDirections.Direction"
	' Посчитаем количество неустаревших направлений
	nCount = oNavigator.SelectScalar("count(FolderDirections/FolderDirection/Direction/Direction/IsObsolete[.!=1])")	
	nInc = CLng( Int( nDelta/nCount))
	nDelta = nDelta - ( nInc * nCount)
	
	Dim oMaxValue
	Dim nMaxValue: nMaxValue = -1
	Dim oFolderDirection
	Dim nFolderDirection
	Dim sDirectionID
	Dim oCurrDirection
	Dim bIsObsolete: bIsObsolete = False
	For Each oFolderDirection In oDirections
		nFolderDirection = oFolderDirection.SelectSingleNode("ExpenseRatio").nodeTypedValue
		If (Not oFolderDirection.selectSingleNode("Direction/Direction") is Nothing ) Then
	        sDirectionID = oFolderDirection.selectSingleNode("Direction/Direction").getAttribute("oid")
	        Set oCurrDirection  = oObjectEditor.Pool.GetXmlObject("Direction", sDirectionID, Null)
	        bIsObsolete = oCurrDirection.selectSingleNode("IsObsolete").nodeTypedValue
	    End If
	   	If IsNull(nFolderDirection) Then nFolderDirection = 0
		nFolderDirection = nFolderDirection + nInc
		If Not bIsObsolete Then
		    If nFolderDirection > nMaxValue Then
			    nMaxValue = nFolderDirection
			    Set oMaxValue = oFolderDirection
		    End If
		    oObjectEditor.Pool.SetPropertyValue oFolderDirection.SelectSingleNode("ExpenseRatio"), nFolderDirection
		End If
	Next
	
	If nDelta > 0 Then
		oObjectEditor.Pool.SetPropertyValue oMaxValue.SelectSingleNode("ExpenseRatio"), oMaxValue.SelectSingleNode("ExpenseRatio").nodeTypedValue + nDelta
	End If
End Sub

'==============================================================================
' :: Установка заголовка редактора
Sub usrXEditor_OnSetCaption( oSender, oEventArgs )
	Dim oInitiator			' As IXMLDOMElement - xml-Объект Employee - регистратор текущего инцидента
	Dim aValues				' As Array - массив значений от источника данных
	Dim sOrgID 				' идентификатор 
	Dim sFolderID			' идентификатор 
	Dim sCaption  
	Dim oXmlObject 
	Dim nParentFolderType

	' на 1-ом шаге мастера с выбором Типа проектных затрат заголовок статический (там ничего не известно еще)
	If oSender.Metaname = "Universal" And oSender.CurrentPageNo = 1 Then Exit Sub
	
	If IsEmpty(g_sActivityTypePath) Then
		If g_oObjectEditor.XmlObject.selectSingleNode("Customer").hasChildNodes Then
			sOrgID = g_oObjectEditor.XmlObject.selectSingleNode("Customer/Organization").getAttribute("oid")
		End If
		' Вышестоящая папка (Если есть)
		If g_oObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
			' получим родителя
			Set oXmlObject = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
			sFolderID = oXmlObject.getAttribute("oid")
		End If
		aValues = GetFirstRowValuesFromDataSource("GetFolderPaths", Array("FolderID", "OrgID", "ActivityTypeID"), Array(sFolderID, sOrgID, g_sActivityTypeID) )
		g_sParentFolderPath = aValues(0)
		g_sOrgPath = aValues(1)
		g_sActivityTypePath = aValues(2)
	' Ссылку на организацию могут выбрать в редакторе при некоторых условиях
	ElseIf Not hasValue(g_sOrgPath) Then
		If g_oObjectEditor.XmlObject.selectSingleNode("Customer").hasChildNodes Then
			sOrgID = g_oObjectEditor.XmlObject.selectSingleNode("Customer/Organization").getAttribute("oid")
			g_sOrgPath = GetScalarValueFromDataSource("GetOrganizationPath", Array("OrgID"), Array(sOrgID) )
		End If
	End If
	
	sCaption = "<TABLE CELLPADDING='0' CELLSPACING='0' STYLE='color:#fff;' WIDTH='100%'>" & _
				"<TR><TD COLSPAN=3 STYLE='font-size:12pt;'>"
	' ВНИМАНИЕ: Использование NameOf_FolderTypeEnum(g_nFolderType) возможно только 
	' потому, что все типы (проект, тендер, пресейл, каталог) мужского рода!
	If g_oObjectEditor.IsObjectCreationMode Then
		sCaption = sCaption & "Новый " & LCase(NameOf_FolderTypeEnum(g_nFolderType)) & "</TD></TR>"
	Else
		sCaption = sCaption & "Редактирование " & LCase(NameOf_FolderTypeEnum(g_nFolderType)) & "а</TD></TR>"
	End If
	
	' Клиент
	If hasValue(g_sOrgPath) Then
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top>Клиент:&nbsp;&nbsp;</TD><TD style='font-size:12pt;' width='100%'>" & g_sOrgPath & "</TD></TR>"
	End If
	
	' Вышестоящая папка (Если есть)
	If g_oObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
		' получим родителя
		Set oXmlObject = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
		nParentFolderType = oXmlObject.selectSingleNode("Type").nodeTypedValue
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top><NOBR>Вышестоящий " & LCase(NameOf_FolderTypeEnum(nParentFolderType)) & ":&nbsp;&nbsp;</NOBR></TD><TD style='font-size:12pt;' width='100%'>" & g_sParentFolderPath & "</TD></TR>"
	End If
	
	' Тип проектных затрат
	sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top><NOBR>Тип затрат:&nbsp;&nbsp;</NOBR></TD><TD style='font-size:12pt;' width='100%'>" & g_sActivityTypePath & "</TD></TR>"
			
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oInitiator = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Initiator")
		If Not oInitiator Is Nothing Then
			sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=2 style='font-size:9pt;'>Инициатор: " & g_oPool.GetPropertyValue(oInitiator, "LastName") & " " & g_oPool.GetPropertyValue(oInitiator, "FirstName")
			' дата
			Dim oNavigator
			Dim oXmlEvent
			Set oNavigator = g_oObjectEditor.CreateXmlObjectNavigatorFor(g_oObjectEditor.XmlObject)
			oNavigator.ExpandProperty "History"
			Set oXmlEvent = oNavigator.SelectNode("History/FolderHistory[Event='" & FolderHistoryEvents_Creating & "']/EventDate")
			If Not oXmlEvent Is Nothing Then
				sCaption = sCaption & ", дата: " & GetDateValue(oXmlEvent.nodeTypedValue)
			End If
			sCaption = sCaption & "</TD></TR>"
		End If
	End If
	sCaption = sCaption & "</TABLE>"
	oEventArgs.EditorCaption = sCaption
End Sub


'==============================================================================
Function IsProject()
	IsProject = CBool(g_nFolderType = FOLDERTYPEENUM_PROJECT)
End Function

'==============================================================================
Function IsRootProject()
    IsRootProject = False
    If not g_oObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
	    IsRootProject = CBool(g_nFolderType = FOLDERTYPEENUM_PROJECT)
    End If
End Function

'==============================================================================
Function IsTender()
	IsTender = CBool(g_nFolderType = FOLDERTYPEENUM_TENDER)
End Function


'==============================================================================
Function IsPresale()
	IsPresale = CBool(g_nFolderType = FOLDERTYPEENUM_PRESALE)
End Function


'==============================================================================
Function IsDirectory()
	IsDirectory = CBool(g_nFolderType = FOLDERTYPEENUM_DIRECTORY)
End Function
'==============================================================================
Function IsUserAdmin()
	IsUserAdmin = g_bUserIsAdmin
End Function
'==============================================================================
' Формирование строки с перечнем ролей для сотрудника - участника проектной 
' команды. Функция вызывается при формировании данных списка "Проектная команда"
' на одноименной странице редактора, как выражение формирования данных столбца
' "Проектные роли" - см. определение свойства Participants типа Folder в мета-
' данных it-metadata-main.xml
' Параметры:
'	[in] oPool - экземпляр объекта пула, с данными редактируемого объекта 
'	[in] oParticipantItem - IXMLElement с данными участника (ProjectParticipant),
'			соответствующих строке списка, для которой требуется получение строки
' Результат 
'	Строка с перечнем ролей, разделенных запятыми. 
Function getProjectPaticipantRoles( oPool, oParticipantItem )
	Dim oRoles		' Все роли рассматриваемого участника (XML-данные)
	Dim oRole		' Одна из ролей (XML-данные), итератор цикла
	Dim sRolesList	' Результирующая строка с перечнем ролей
	
	sRolesList = ""
	Set oRoles = oPool.LoadXmlProperty( oParticipantItem, "Roles" )
	If hasValue(oRoles) Then
		For Each oRole In oRoles.SelectNodes("*")
			sRolesList = sRolesList + ", " + CStr( oPool.GetPropertyValue(oRole,"Name") )
		Next
	End If
	If Len(sRolesList)>0 Then sRolesList = Mid(sRolesList, 3)
	
	getProjectPaticipantRoles = sRolesList
End Function


'==============================================================================
' Формирование строки со значением расчетной доли затрат.
' Функция вызывается при формировании данных списка "Направления",  на 
' одноименной странице редактора, как выражение формирования данных столбца
' "Расчетная доля %" - см. определение свойства FolderDirections типа Folder 
' в метаданных it-metadata-main.xml
' Параметры:
'	[in] oPool - экземпляр объекта пула, с данными редактируемого объекта 
'	[in] oParticipantItem - IXMLElement с данными свзяи Папка-Направление 
'			(FolderDireciton), соответствующих строке списка
' Результат 
'	Строка с значением расчетной доли, или пустая строка, если значения 
'	расчетных долей еще не вычислялись.
Function getDirectionPrecomputedExpensesRatio( oPool, oFolderDirectionItem )
	Dim oDirection		' Данные направления для FolderDirection, отображемого в строке
	Dim sDirectionID	' Идентификатор направления для FolderDirection, отображемого в строке
	Dim nIndex			' Итератор цикла
	
	getDirectionPrecomputedExpensesRatio = ""
	' Что-либо делать имеет смысл если только операция предварительного расчета
	' уже выполнялась и у нас есть данные (см. обработку операции DoCalculate в
	' DirectionsList_MenuExecutionHandler); если данных нет - выходим:
	If Not hasValue(g_aPrecomputedExpensesRatios) Then Exit Function
 	' Определяем идентификатор направления: 
	Set oDirection = oPool.LoadXmlProperty( oFolderDirectionItem, "Direction" )
	If Not (oDirection Is Nothing) Then Set oDirection = oDirection.selectSingleNode("Direction/@oid")
	If Not (oDirection Is Nothing) Then sDirectionID = oDirection.nodeValue
	' ...если идентификатор не известен, то и найти соотв. долю не получится
	If Not hasValue(sDirectionID) Then Err.Raise -1, "s-Folder.vbs", "Ошибка получения идентификатора направления!"
	
	' Выполняем поиск пары "направление - значение доли" в массиве, полученном
	' в результате выполнения операции предварительного расчета:
	For nIndex = 0 To UBound(g_aPrecomputedExpensesRatios)
		' Если значение расчетной доли для направления нашли, то сразу выходим:
		If sDirectionID = g_aPrecomputedExpensesRatios(nIndex)(0) Then
			getDirectionPrecomputedExpensesRatio = CStr( g_aPrecomputedExpensesRatios(nIndex)(1) ) & "%"
			Exit Function
		End If
	Next
End Function

Dim g_bDirectionsHadShown			' Признак, что доп. данные по направлениям были получены
Dim g_bDirectionHasBeenChanged		' Признак внесения изменений в структуру направлений - блокирует получение 
									' расчетных долей, но - при выполнении, см. DirectionsList_MenuExecutionHandler
Dim g_bHasParentDirectionsSet		' Признак, что редактируемая папка имеет родительскую, 
									' для которой заданы направления
									
Dim g_sDirectionChangeHistoryInfo	' Строка с данными по истории изменения направлений
Dim g_sDirectionStructError			' Строка с текстом предупреждения о структурных несоотв.
Dim g_oTempFolderDirection			' Ссылка на добавленный временный объект с данными FolderDirection
Dim g_nSingleFolderDirectionMode	' Признак случая задания только одного направления
Dim g_nHasIncorectExpenseRatioSum	' Сумма долей по всем направлениям - для проверки (д.б. <= 100)

Dim g_sRedundantDirectionsIDs		' Перечень идентификаторов "лишних" направлений, которые, 
									' по сути, не должны быть заданы (т.к. не определены для
									' вышестоящей папки), но тем ни менее присутствуют. Требуется
									' Для корректного отображения перечня направлений.
									
Dim g_aPrecomputedExpensesRatios	' Массив значений расчетных долей; м.б. Empty если операция
									' предварительного расчета не вызывалась. Используется для
									' отображения расчетных долей после обновления списка в
									' elements-list (см. getDirectionPrecomputedExpensesRatio)
Dim g_bShowDirections				'Признак отображения направлений	

Dim g_sDirectionOldValue            'Старое значение направления для выбора у дочерних папок
Dim g_sDirectionNewValue			'Новое значение направления для выбора у дочерних папок	
Dim g_bChildDirectionChange         'Признак того, что у папки есть дочерние, с направлениями отличными от данной 

Dim g_sParentID                     'Идентиифкатор родительской папки. Необходим для создания 
Dim g_bHasParent                    'Признак того, что у папки есть родитель 
g_bShowDirections = True 
g_bDirectionsHadShown = False
g_bDirectionHasBeenChanged = False
g_bHasParentDirectionsSet = False
g_sDirectionChangeHistoryInfo = ""
g_sDirectionStructError = ""
Set g_oTempFolderDirection = Nothing
g_nSingleFolderDirectionMode = 1
g_nHasIncorectExpenseRatioSum = 0
g_sRedundantDirectionsIDs = ""
g_aPrecomputedExpensesRatios = Empty
g_bChildDirectionChange  = False 
g_sDirectionOldValue = Empty  
g_sDirectionNewValue = Empty
g_sParentID = Null
g_bHasParent = False
'===============================================================================
Function CanUseDirectionSet()
	' Вариации: 
	'	(А) это обычный редактор, и тип папки задан "извне" - тогда возможность 
	'	задания НАБОРА направлений определяется тем, что данная папка - НЕ каталог,
	'	и нет "вышестоящего" определения направлений;
	'	(Б) это "универсальный" мастер, где на первой странице задается тип 
	'	активности - но не каталог. Возможность задания набора в этом случае 
	'	определяется только фактом отсутствия определения набора для вышестоящей 
	'	активности (if any)
	CanUseDirectionSet = g_bHasParentDirectionsSet And g_bShowDirections
	If g_oObjectEditor.MetaName <> "Universal" Then 
		CanUseDirectionSet = (CanUseDirectionSet Or IsDirectory() Or g_bHasParent) And (g_bShowDirections)
	End If
End Function 

'===============================================================================
Function GetDirectionsHisoryInfo()
	If hasValue( g_sDirectionChangeHistoryInfo ) Then
		GetDirectionsHisoryInfo = g_sDirectionChangeHistoryInfo 
	Else
		GetDirectionsHisoryInfo = "(н/д)"
	End If
End Function

'===============================================================================
Function GetDirectionStructError()
	If hasValue( g_sDirectionStructError ) Then
		GetDirectionStructError = _
			"<B>Внимание! Найдены несоответствия в определении направлений:</B><BR/>" & _
			"<UL STYLE='margin:1px; margin-left:20px;'><LI>" & _
				Replace( g_sDirectionStructError, "|", "</LI><LI>" ) & _
			"</LI></UL>"
	Else
		GetDirectionStructError = ""
	End If
End Function

'===============================================================================
Function GetSingleDirection( oFolderXml)
    Set GetSingleDirection = _
		oFolderXml.item(0).selectNodes( _
			"FolderDirections/FolderDirection[@oid='" & _
				g_oTempFolderDirection.getAttribute("oid") & _
			"']/Direction" ) 
    
			
End Function


'===============================================================================
' :: Обработчик события инициализации страницы редактора
'	Используется для загрузки дополнительной данных по направлениям, заданным 
'	для редактируемой папки. Все действия выполняются только в том случае, если 
'	пользователь перешел на страницу "Направления", и только один раз. 
'
Sub usrXEditorPage_OnInit( oSender, oEventArgs )
	Dim aResults ' Результат выполнения операции ExecDataSourcе, вычисляющей доп. информацию
	Dim sParentID ' Идентификатор родительской папки
	' Обработчик EditorPage_OnInit может вызываться раньше, чем Editor_OnLoad:
	' на всякий случай проверим запомненную ссылку на ObjectEditor - и если она
	' еще не сохранена - сохраним (т.к. она используется далее в вывзываемых 
	' методах):
	If Not hasValue(g_oObjectEditor) Then Set g_oObjectEditor = oSender.ObjectEditor
	If (oSender.PageName = "Main") Then
	    Dim aUserInfo
	    ' Получим информацию о правах текущего пользователя
	    aUserInfo = GetFirstRowValuesFromDataSource("HomePage-GetCurrentEmployeeInfo", Null, Null)
        g_bUserIsAdmin = CBool(aUserInfo(4))
    End If    
	' Специальная обработка выполняется только для страницы "Направления"
	
	If (oSender.PageName <> "Directions" ) Then Exit Sub
	' ... и если она еще ни разу не выполнялась
	
	If g_bDirectionsHadShown Then Exit Sub
   	
   	g_nFolderType = oSender.ObjectEditor.Pool.GetPropertyValue( oSender.ObjectEditor.XmlObject, "Type" )
   	aResults = GetFirstRowValuesFromDataSource( "GetFolderDirectionsInfo", Array("FolderID"), Array(oSender.ObjectEditor.ObjectID) )
	g_sDirectionChangeHistoryInfo = CStr( aResults(0) )
	g_sDirectionStructError = CStr( aResults(1) )
	g_bHasParentDirectionsSet = CBool( aResults(2) )
	g_bDirectionsHadShown = True
	Dim oParent 
	If oSender.ObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
	    Set oParent = oSender.ObjectEditor.Pool.GetXmlObjectByOPath(oSender.ObjectEditor.XmlObject, "Parent")
	    g_bIsLocked = oParent.selectSingleNode("IsLocked").nodeTypedValue
	    g_sParentID = oParent.getAttribute("oid")
	    g_bHasParent = hasValue(g_sParentID) 
	    If (oSender.ObjectEditor.IsObjectCreationMode) Then
   	        g_sDirectionChangeHistoryInfo = "" 
	        g_sDirectionStructError = ""
	        g_nSingleFolderDirectionMode = 0
	        If Not (oParent is Nothing) Then
	            InsertParentDirection oSender, oParent
	        End If
	    
  	    End If
  	End If
  	' При создании, если есть вышестоящая папка, то проставим признак "IsLocked" как у родителя
  	If oSender.ObjectEditor.IsObjectCreationMode Then
  	    oSender.ObjectEditor.XmlObject.selectSingleNode("IsLocked").nodeTypedValue = g_bIsLocked
  	End If
	Dim g_nState 
	g_nState = oSender.ObjectEditor.XmlObject.selectSingleNode("State").nodeTypedValue
	' Отдельный случай: отображение направлений в случае, если для вышестоящей 
	' папки они уже заданы: GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
	If ( (CanUseDirectionSet() Or g_bHasParent) And (Not oSender.ObjectEditor.IsObjectCreationMode)) Then
		Dim oDirections
		Set oDirections = oSender.ObjectEditor.LoadXmlProperty( Nothing, oSender.ObjectEditor.GetProp("FolderDirections") )
		   				
		If ( oDirections.childNodes.length = 0 ) Then
			
			g_nSingleFolderDirectionMode = 0
			If ( oSender.ObjectEditor.XmlObject.selectSingleNode("State").nodeTypedValue = FOLDERSTATESFLAGS_CLOSED Or oSender.ObjectEditor.XmlObject.selectSingleNode("State").nodeTypedValue = FOLDERSTATESFLAGS_FROZEN ) Then
	            g_bShowDirections = false
	        Else
	            Set g_oTempFolderDirection = CreateXmlObjectInProp( oSender.ObjectEditor.Pool, "FolderDirection", oDirections)    
	        End If
	         
		ElseIf ( oDirections.childNodes.length = 1 ) Then
			g_nSingleFolderDirectionMode = 0
			Set g_oTempFolderDirection = oSender.ObjectEditor.Pool.GetXmlObject( "FolderDirection", oDirections.firstChild.getAttribute("oid"), "Direction" )
			
			
		ElseIf ( oDirections.childNodes.length > 1 ) Then
		    
			g_nSingleFolderDirectionMode = 1
			Dim oDirection
			For Each oDirection In oDirections.childNodes
				g_sRedundantDirectionsIDs = g_sRedundantDirectionsIDs & "|" & oDirection.getAttribute("oid")
			Next
			If Len(g_sRedundantDirectionsIDs) > 0 Then g_sRedundantDirectionsIDs = Mid( g_sRedundantDirectionsIDs, 2 )
			Set g_oTempFolderDirection = CreateXmlObjectInProp( oSender.ObjectEditor.Pool, "FolderDirection", oDirections )
		End If
	End If
	
End Sub

Sub usrXEditor_OnValidate( oSender, oEventArgs )
    Dim oXmlObject
	If g_bDirectionsHadShown Then 
		If Not( g_oTempFolderDirection Is Nothing ) Then
		   ' Проверяем, что в пуле до сих пор существует узел соответсвующий FolderDirection, возможно он уже был удален
		    Set oXmlObject = oSender.XmlObjectPool.selectSingleNode("FolderDirection" & "[@oid='" & g_oTempFolderDirection.getAttribute("oid") & "']")
		    If oXmlObject is Nothing  Then Exit Sub
			Dim oDirection 
			Set oDirection = g_oTempFolderDirection.selectSingleNode( "Direction/Direction[@oid]" )
			If oDirection Is Nothing Then
				' Удаляем данные по FolderDirection; вызывать RemoveRelation для свойства FolderDirections не надо - все ссылки будут корректно удалены в MarkObjectAsDeleted 
				oSender.Pool.MarkObjectAsDeleted "FolderDirection", g_oTempFolderDirection.getAttribute("oid"), Nothing, false, Nothing 
			End If
		End If
	End If
End Sub

'==============================================================================
' ::
' oEventArgs - есть Nothing
Sub usrXEditorPage_OnAfterLoad( oSender, oEventArgs )
	If (oSender.PageName <> "Directions") Then Exit Sub
	CheckExpcenseRatioSum oSender.ObjectEditor
	
	If ( CanUseDirectionSet() ) Then
		If g_nSingleFolderDirectionMode = 1 Then
			With oSender.HtmlDivElement.all
				.item("divSingleDirection",0).style.display = "none"
				.item("divLockDirectionWarningText",0).style.display = "block"
			End With 
			Dim nAnswer
			nAnswer = MsgBox( "Обнаружено определение более одного направления! Удалить?", vbYesNo + vbDefaultButton1 + vbExclamation, "Подтверждение" )
			If ( vbNo = nAnswer ) Then
				MsgBox "Определение направлений останется некорректным!", vbExclamation, "Предупреждение"
				Exit Sub
			End If
			
			Dim sDirectionID
			
			If hasValue(g_sRedundantDirectionsIDs) Then
				For Each sDirectionID In Split( g_sRedundantDirectionsIDs, "|" )
					oSender.ObjectEditor.Pool.MarkObjectAsDeleted "FolderDirection", sDirectionID, Nothing, false, Nothing 
				Next
			End If
			
			g_nSingleFolderDirectionMode = 0
		End If
		
		With oSender.HtmlDivElement.all
			.item("divLockDirectionWarningText",0).style.display = "none"
			.item("divSingleDirection",0).style.display = "block"
		End With
	End If
End Sub

' Дополнительный обработчик видимости меню в списке "Напрвления папки"
'	[in] oSender As XPEObjectsElementsListClass - компонент-владелец меню (PE)
'	[in] oEventArgs As MenuEventArgsClass 		- параметры события
Sub DirectionsList_MenuVisibilityHandler( oSender, oEventArgs )
	Dim oNode
	Dim bIsObsolete     ' Признак устаревшего направления
	Dim oCurrDirection  'Текущее направление
	Dim bHidden
	Dim sDirectionID
	' Если направления заданы, то проверим их на признак "Устаревшего" ("IsObsolete")
	If oSender.HtmlElement.Rows.Count <> 0 Then
	Set oCurrDirection = oSender.ObjectEditor.Pool.GetXmlObject("FolderDirection",oEventArgs.Menu.Macros.Item("ObjectID"), "Direction")
        If (Not oCurrDirection is Nothing) Then
            If (Not oCurrDirection.selectSingleNode("Direction/Direction") is Nothing ) Then
	            sDirectionID = oCurrDirection.selectSingleNode("Direction/Direction").getAttribute("oid")
	            Set oCurrDirection  = oSender.ObjectEditor.Pool.GetXmlObject("Direction", sDirectionID, Null)
	            bIsObsolete = oCurrDirection.selectSingleNode("IsObsolete").nodeTypedValue
	        End If
	    End If
	End If
	For Each oNode In oEventArgs.ActiveMenuItems
		Select Case oNode.getAttribute("action")
			Case "DoCalculate"
				bHidden = (oSender.HtmlElement.Rows.Count = 0)
		    Case "DoEdit"
		    ' Если направление "Устаревшее" или не заданы вообще, то скроем меню "Задать долю затрат..."
		        bHidden = bIsObsolete
		End Select
		If Not IsEmpty(bHidden) Then
			If bHidden Then 
				oNode.setAttribute "hidden", "1"
			Else
				oNode.removeAttribute "hidden"
			End If
		End If
	Next
End Sub

' Обработчик выбора пункта меню в списке "Напрвления папки"
Sub DirectionsList_MenuExecutionHandler( oSender, oEventArgs )
	Dim vResult		' Резульат выбора пользователя в ответ на предупреждение
	
	oEventArgs.Cancel = True
	Select Case oEventArgs.Action
		' Выполнение предварительного расчета долей затрат, отображение результатов в списке
		Case "DoCalculate"
			
			' Если была изменена структура направлений, то предварительный расчет может дать
			' неверный результат, т.к. выполняется по данным из БД. Выводим предупреждение 
			' по этому поводу, в предложением отказаться от выполнения операции:
			If (g_bDirectionHasBeenChanged) Then
				vResult = MsgBox( _
					"Внимание!" & vbCrLf & _
					"Определение направлений для данной активности было изменено, но еще не записано." & vbCrLf & _
					"Предварительный расчет долей затрат в этом случае может дать некорректные результаты." & vbCrLf & _
					"Для корректного расчета необходимо сначала записать изменения определений направлений." & vbCrLf & _
					vbCrLf & "Продолжить предварительный расчет?", _
					vbExclamation + vbYesNo + vbDefaultButton2, "Предупреждение" )
				If (vbNo = vResult) Then Exit Sub
			End If
			
			' Выполняем операцию; результат запоминаем - он будет использоваться в др. месте
			oSender.ObjectEditor.EnableControls False
			g_aPrecomputedExpensesRatios = GetValuesFromDataSource( "GetCalculatedExpensesRatio", Array("FolderID"), Array(oSender.ObjectEditor.ObjectID) )
            If (Not hasValue(g_aPrecomputedExpensesRatios(0)(0)) And Not hasValue(g_aPrecomputedExpensesRatios(0)(1) )) Then
	            MsgBox "Невозможно произвести предварительный расчет долей затрат"& vbCrLf & _
                    "поскольку на проекте не зарегистрированы трудозатраты.", vbExclamation, "Внимание!"
	        Else
	     	' Инициируем обновление списка: значение в колонке "Расчетная доля %" 
			' формируется функцией getDirectionPrecomputedExpensesRatio, которая
			' использует "запомненный" результаты расчета:
			oSender.SetData
			End If
			oSender.ObjectEditor.EnableControls True
			
		Case Else
			oEventArgs.Cancel = False
	End Select
End Sub

' Обработчик события BeforeMarkDelete, генерируемого в процессе стандартной 
' обработки пункта меню DoMarkDelete, вызываемого для списка "Направлений"
'	[in] oSender - PE-компонент - владелец меню; здесь - XPEObjectsElementsListClass
'	[in] oEventArgs - экземпляр OperationEventEventArgs
Sub usr_FolderDirections_ObjectsElementsList_OnBeforeMarkDelete( oSender, oEventArgs )
    Dim bSucces
	Dim oCurrDirection
	Dim vRet
	Dim oDirectionID
	Dim oObjectEditor: Set oObjectEditor = oSender.ObjectEditor
	Dim oObjectPool: Set oObjectPool = oObjectEditor.Pool
	Dim oFolder: Set oFolder = oObjectEditor.XmlObject
	Set oCurrDirection = oObjectPool.GetXmlObject("FolderDirection",oEventArgs.ObjectID, "Direction")
	If (Not oCurrDirection is Nothing) Then
	   Set oDirectionID = oCurrDirection.selectSingleNode("Direction/Direction[@oid]")
	End If
	bSucces = processInnerFoldersDirections( oObjectEditor, oObjectPool, oFolder, oDirectionID.getAttribute("oid"), 1)
	IF bSucces Then
	    vRet = MsgBox ("Удалить направления у активности/каталога и всех вложенных активностей/каталогах? "& vbCrLf & _
		"Продолжить?", vbYesNo + vbExclamation) 
		If ( vbNo = vRet ) Then oEventArgs.ReturnValue = false
	End If 
	oEventArgs.Prompt = _
		"В результате операции "& iif( IsDirectory(), "каталог", "активность" ) & " не будет более соотноситься с указанным" & vbCrLf & _
		"направлением, что изменит структуру затрат в разрезе направлений." & vbCrLf & _
		"Продолжить?"
End Sub 

Sub usr_FolderDirections_ObjectsElementsList_OnAfterMarkDelete( oSender, oEventArgs )
	' Запомним, что структура направлений изменилась - при вызове операции 
	' предварительного расчета направлений это позволит вывести предупреждение 
	g_bDirectionHasBeenChanged = True
	CheckExpcenseRatioSum oSender.ObjectEditor
End Sub


Sub usr_FolderDirections_ObjectsElementsList_OnAfterEdit( oSender, oEventArgs )
	CheckExpcenseRatioSum oSender.ObjectEditor
End Sub

Sub GetExpcenseRatioSum( oObjectEditor, ByRef nSum, ByRef nCount)
  	With oObjectEditor.CreateXmlObjectNavigatorFor(oObjectEditor.XmlObject)
		.ExpandProperty "FolderDirections"
		nSum = .SelectScalar("sum(FolderDirections/*/ExpenseRatio[normalize-space(.)!=''])")
		nSum = CLng(nSum)
		nCount = .SelectScalar("count(FolderDirections/*)")
		nCount = CLng(nCount)
	End With	
End Sub

Sub CheckExpcenseRatioSum( oObjectEditor )
	' Задача: проверить что сумма долей == 100%
	Dim nCount
	g_nHasIncorectExpenseRatioSum = 0
	
	GetExpcenseRatioSum oObjectEditor, g_nHasIncorectExpenseRatioSum, nCount
	
	if ( nCount = 0 ) Then g_nHasIncorectExpenseRatioSum = 100
	
	if ( 0 <> g_nSingleFolderDirectionMode ) Then
		' Если сумма долей затрат отлична от  100%, то включаем отображение спецального сообщения:
		With oObjectEditor.CurrentPage.HtmlDivElement.all.item("divPercentWarningText",0)
			If (g_nHasIncorectExpenseRatioSum) <> 100 Then
				.style.display = "block"
			Else
				.style.display = "none"
			End If
		End With
	End If
End Sub

' Обработчик события пред-создания нового элемента списка FolderDirection
' Используем его для создания FolderDirection "вручную" с последующим выводом 
' списка выбора направления (которое будет проставлено для созданного объекта)
' Используется событие BeforeCreate, т.к. оно позволяет "отменить" все последующие
' события и их обработчики - это нужно т.к. есть глобальный обработчик OnCreate
' (см. it-security.vbs), реализация которого в данном случае только мешает
Sub usr_FolderDirections_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
	Dim oXmlProperty		' xml-свойство
	Dim oNewObject			' Новый объект-значение
  	With oEventArgs
		' начнем агрегированную транзакцию
		oSender.ObjectEditor.Pool.BeginTransaction True
		' ВАЖНО: ссылка oXmlProperty полечена после вызова BeginTransaction, поэтому ей можно 
		' пользоваться и после CommitTransaction
		Set oXmlProperty = oSender.XmlProperty
		
		' создаем новый объект, поместим его в пул, добавим на него ссылку из свойства и - главное - установим атрибуты ограничения доступа
		Set oNewObject = CreateXmlObjectInProp( oSender.ObjectEditor.Pool, oSender.ValueObjectTypeName, oXmlProperty )

		' Редактор для созданного объекта - НЕ вызываем!
		' Вместо этого вызываем выбор из списка напарвлений - для выбора направления
		
		' Выбираем объект, из списка
		Dim sObjectID
		Dim sAlreadySelected			
		Dim nRowIndex
		sAlreadySelected = ""
		If oSender.HtmlElement.Rows.Count > 0 Then
			For nRowIndex = 0 To oSender.HtmlElement.Rows.Count - 1
				sAlreadySelected = sAlreadySelected & "HideID=" & oSender.HtmlElement.Rows.GetRow( nRowIndex ).ID & "&"
			Next
		End If
		
		sObjectID = X_SelectFromList( "NameAndDirector", "Direction", LM_SINGLE, sAlreadySelected, null )
		If Not hasValue( sObjectID ) Then 
			' нажали отмену - откатим транзакцию
			oSender.ObjectEditor.Pool.RollbackTransaction
		Else 
		
			Dim oXmlDirectionProperty
			Dim oNewItem
            Dim oXmlExpenseRatio
			Set oXmlDirectionProperty = oNewObject.SelectSingleNode( "Direction" )
			If oXmlDirectionProperty Is Nothing Then
				MsgBox "Ошибка обработки объекта Folder Direction - свойство Direction не найдено!", vbCritical, "Ошибка"
				Err.Raise -1, "s-Folder.vbs", "Ошибка обработки объекта Folder Direction - свойство Direction не найдено!"
			End If
			Set oXmlExpenseRatio = oNewObject.SelectSingleNode( "ExpenseRatio" )
			'Set oXmlExpenseRatio.nodeTypedValue = 0 
			If oXmlExpenseRatio Is Nothing Then
				MsgBox "Ошибка обработки объекта Folder Direction - свойство ExpenseRatio не найдено!", vbCritical, "Ошибка"
				Err.Raise -1, "s-Folder.vbs", "Ошибка обработки объекта Folder Direction - свойство ExpenseRatio не найдено!"
			End If
			
			With oSender.ObjectEditor.Pool
				' Загрузим выбранный объект в пул, чтобы, во-первых, убедиться что он есть 
				' и, во-вторых, все равно он будет загружен при отрисовке свойства в SetData
				Set oNewItem = .GetXmlObject( "Direction", sObjectID, Null )
				If X_WasErrorOccured Then
					If X_GetLastError.IsObjectNotFoundException Then
						MsgBox "Выбранный объект '" & sObjectID & "' не был добавлен в свойство, т.к. был удален другим пользователем", vbOKOnly + vbInformation
					Else
						' если была другая серверная ошибка, покажем сообщение
						X_GetLastError.Show
						' откатим транзакцию
						oSender.ObjectEditor.Pool.RollbackTransaction
						Exit Sub
					End If
				Else
					.AddRelation Nothing, oXmlDirectionProperty, oNewItem
					If (Not g_bHasParentDirectionsSet) Then
					    'Если уже есть направление, то зададим долю затрат 0
					    If HasAnyDirections (oSender.ObjectEditor.Pool,oXmlProperty) Then
					        .SetPropertyValue oXmlExpenseRatio, 0
					    Else ' Иначе, у нас всего одно направление, поэтому даем 100
					        .SetPropertyValue oXmlExpenseRatio, 100
					    End If
					End If    
				End If
			End With	
			
			' Если свойство сортируемое - вставим расположим в свойстве с учетом сортировки
			If oSender.IsOrdered Then
				oSender.OrderObjectInProp _
					oXmlProperty.selectSingleNode("FolderDirection[@oid='" & oNewObject.getAttribute("oid") & "']")				
			End If
			
			' нажали Ок - закомитим
			oSender.ObjectEditor.Pool.CommitTransaction
			' обновим представление PE
			oSender.SetData
			
			' Запомним, что структура направлений изменилась - при вызове операции 
			' предварительного расчета направлений это позволит вывести предупреждение 
			g_bDirectionHasBeenChanged = True
			
			CheckExpcenseRatioSum oSender.ObjectEditor
		End If 

	End With
	
	' Все обработчики далее - не вызываем!
	oEventArgs.ReturnValue = false
End Sub


'	oEventArgs - экземпляр GetRestrictionsEventArgsClass
Sub usr_FolderDirection_Direction_OnGetRestrictions( oSender, oEventArgs )
    If hasValue(g_sParentID) And g_bHasParentDirectionsSet Then
        oEventArgs.ReturnValue = "FolderID=" & oSender.ObjectEditor.ObjectID & "&ParentFolderID=" & g_sParentID
    Else
        oEventArgs.ReturnValue = "FolderID=" & oSender.ObjectEditor.ObjectID 
    End If
End Sub

Sub usr_Folder_IsLocked_OnChanged( oSender, oEventArgs )
					
	' - "Я тут подумал и решил что неплохо бы пробежаться в пуле по вложенным папкам
	' вместо того чтобы вызывать постколы или кастомную команду сохранения
	' к тому-же это даст возможность обойтись всего 1 триггером (уровня приложения)
	' для обработки истории изменения" (Александров Дмитрий) 
	Dim oObjectEditor: Set oObjectEditor = oSender.ObjectEditor
	Dim oObjectPool: Set oObjectPool = oObjectEditor.Pool
	Dim oFolder: Set oFolder = oObjectEditor.XmlObject
	Dim vRet 
	
	If oObjectPool.LoadXmlProperty( oFolder, "Children").HasChildNodes Then
		vRet = MsgBox( _
			"Установить значение также на вложенные папки?" & vbCrLf & vbCrLf & _
			"Внимание!" & vbCrLf & "Распространение значения в структуре вложенных папок может занять время!", _
			vbYesNo + vbQuestion, _
			"Изменение блокировки списания" )
		
		If (vbYes = vRet) Then
		
			' Процесс перебора вложенных папок для больших проектов может 
			' занимать достаточно длительное время; если в этот момент закрыть
			' редактор, то флаг не будет доставлен до всех вложенных папкок.
			' Поэтому - все элементы управления блокируются + реализуется 
			' контроль ошибок времени выполнения:
			g_oObjectEditor.EnableControls False		
			On Error Resume Next
			vRet = processInnerFolders( oObjectEditor, oObjectPool, oFolder, oEventArgs.NewValue)
			If X_ErrOccured() Then
				XService.CreateErrorDialog( _
					"Ошибка времени исполнения", ERRDLG_ICON_ERROR, _
					"Ошибка изменения значения блокировки", Err.Description ).ShowModal
				On Error Goto 0
				X_ErrReRaise "Ошибка изменения значения блокировки", "usr_Folder_IsLocked_OnChanged"
				Exit Sub
			End If
			g_oObjectEditor.EnableControls True
		
			If vRet Then
				XService.CreateErrorDialog( _
					"Предупреждение", ERRDLG_ICON_SECURITY, _
						"<b>Внимание!</b><br/>" & _
						"Распространение изменения значения флага<br/>" & _
						"<i>""Списания на папку заблокированы""</i> распространено не на все вложенные папки, " & _
						"из-за ограничений прав в папках.", _
					"" ).ShowModal
			End If
		
		End If
	End If
End Sub


' Устанавливает IsLocked = bValue
Function processInnerFolders(oObjectEditor, oObjectPool, oFolder, bValue)
	Dim oSubFolders: Set oSubFolders = oObjectPool.GetXmlObjectsByOPath(oFolder, "Children")
	Dim oSubFolder
	Dim oIsLockedProperty
	Dim bCanChange
	
	processInnerFolders = False
	
	If oSubFolders Is Nothing Then Exit Function ' Дошли до листового узла
	
	For Each oSubFolder In oSubFolders
		bCanChange = True
		If 0 = CLng( "0" & oSubFolder.GetAttribute("read-only")) Then
			Set oIsLockedProperty = oSubFolder.SelectSingleNode("IsLocked")
			If 0<> CLng( "0" & oSubFolder.GetAttribute("change-right")) Then
				If 0<> CLng( "0" & oIsLockedProperty.GetAttribute("read-only")) Then
					bCanChange = false
				End If
			End If
			If bCanChange Then
				oObjectPool.SetPropertyValue oIsLockedProperty, bValue
			Else
				processInnerFolders = True	
			End If
		End If
		processInnerFolders = processInnerFolders OR processInnerFolders( oObjectEditor, oObjectPool, oSubFolder, bValue )
	Next
End Function
' Проверка на соответствие направления родительской папки и всех ее дочерних
Function processInnerFoldersDirections(oObjectEditor, oObjectPool, oFolder,sDirectionID, nEqual)
  Dim sFolderID ' Идентификатор папки
  Dim sDifferenceOrEqualID ' Идентификатор направления дочерних папок, для которых найдено несоответствие в направлениях
  sFolderID = oFolder.getAttribute("oid")
  processInnerFoldersDirections = False
  sDifferenceOrEqualID = GetScalarValueFromDataSource("GetDifferentOrEqualDirection-ForChildFolder", Array("FolderID","DirectionID","bEqual"), Array(sFolderID,sDirectionID, nEqual))
  ' Если что-то нашлось, значит, направления во вложенных папках отличаются от родительской
  processInnerFoldersDirections = HasValue(sDifferenceOrEqualID)  
End Function
' Проверка того, что для папки задано более 1-го направления
Function HasAnyDirections (oObjectPool, oFolderDirections)
    HasAnyDirections = False
    Dim oFolderDirection
    Set oFolderDirection = oFolderDirections.selectNodes("FolderDirection")
    If hasValue(oFolderDirection) Then
        If oFolderDirection.length > 1 Then
            HasAnyDirections = True
        End If    
    End If
End Function


' Обработчик выбора направления для вложенных папок
Sub usr_FolderDirection_Direction_ObjectListSelector_OnSelected( oSender, oEventArgs )
    Dim oObjectEditor: Set oObjectEditor = oSender.ObjectEditor
	Dim oObjectPool: Set oObjectPool = oObjectEditor.Pool
	Dim oFolder: Set oFolder = oObjectEditor.XmlObject
    If (Not g_bDirectionHasBeenChanged) Then
       g_sDirectionOldValue  = oEventArgs.OldValue 
    End If 
    Dim oNewObject
	Dim oXmlExpenseRatio
	Dim oDirections
    g_sDirectionOldValue  = oEventArgs.OldValue 
    g_bDirectionHasBeenChanged = True
    g_sDirectionNewValue = oEventArgs.NewValue
    Set oDirections = oSender.ObjectEditor.LoadXmlProperty( Nothing, oSender.ObjectEditor.GetProp("FolderDirections") )
    Set oNewObject = oSender.ObjectEditor.Pool.GetXmlObject( "FolderDirection", oDirections.firstChild.getAttribute("oid"), "Direction" )
    Set oXmlExpenseRatio = oNewObject.SelectSingleNode("ExpenseRatio")
    ' Т.к. у нас возможность выбирать только одно направление, то доля затрат для него будет 100%
    oSender.ObjectEditor.Pool.SetPropertyValue oXmlExpenseRatio, 100
    g_bDirectionHasBeenChanged = True
    g_sDirectionNewValue = oEventArgs.NewValue
    ' Если направление изменилось, то надо проверить вложенные папки
    If (g_sDirectionNewValue <> g_sDirectionOldValue) Then
        g_bChildDirectionChange = processInnerFoldersDirections(oObjectEditor, oObjectPool, oFolder, g_sDirectionNewValue, 0)
    End If
End Sub
' Обработчик снятия направления для вложенных папок
Sub usr_FolderDirection_Direction_ObjectListSelector_OnUnSelected( oSender, oEventArgs )
    Dim oObjectEditor: Set oObjectEditor = oSender.ObjectEditor
	Dim oObjectPool: Set oObjectPool = oObjectEditor.Pool
	Dim oFolder: Set oFolder = oObjectEditor.XmlObject
	g_sDirectionNewValue = oEventArgs.NewValue
	g_sDirectionOldValue = oEventArgs.OldValue
	g_bDirectionHasBeenChanged = true
    If (g_sDirectionNewValue <> g_sDirectionOldValue) Then
        g_bChildDirectionChange = processInnerFoldersDirections(oObjectEditor, oObjectPool, oFolder, g_sDirectionOldValue, 1)
    End If
End Sub
' Функция создает направление для в моент создания активности/папки, если направление задано для родительской активности/папки
Sub InsertParentDirection(oSender, oParentFolder)
    Dim oNewObject  ' Новый объект для свойства "FolderDirection"
    Dim oNewItem    ' Задаваемое направление
    Dim oXmlDirectionProperty ' Свойство "FolderDirection" для папкм
    Dim oFolderDirections ' Направления папки
    Dim oParentDirections ' Направления родительской папки
    Dim sObjectID         ' Идентификатор создаваемого объекта
    Set oFolderDirections = oSender.ObjectEditor.LoadXmlProperty( Nothing, oSender.ObjectEditor.GetProp("FolderDirections"))
    Set oParentDirections = oSender.ObjectEditor.Pool.GetXmlProperty(oParentFolder,"FolderDirections")
    If (oParentDirections is Nothing) Then
        Exit Sub
    End If 
    If (oParentDirections.SelectNodes("FolderDirection").length > 1) Then 
        g_bHasParentDirectionsSet = True
        Set g_oTempFolderDirection = CreateXmlObjectInProp(oSender.ObjectEditor.Pool, "FolderDirection", oFolderDirections)
        Exit Sub
    End If    
    Set oParentDirections = oSender.ObjectEditor.Pool.GetXmlProperty(oParentFolder,"FolderDirections.Direction")
    Set oNewObject = CreateXmlObjectInProp(oSender.ObjectEditor.Pool, "FolderDirection", oFolderDirections)
    g_bHasParentDirectionsSet = True
    Set g_oTempFolderDirection = oNewObject
    If (oParentDirections is Nothing) Then
        Exit Sub
    End If 
    Set oXmlDirectionProperty = oNewObject.SelectSingleNode("Direction") 
    sObjectID = oParentDirections.SelectSingleNode("Direction").getAttribute("oid")
    Set oNewItem = oSender.ObjectEditor.Pool.GetXmlObject( "Direction", sObjectID, Null )
    oSender.ObjectEditor.Pool.AddRelation Nothing, oXmlDirectionProperty, oNewItem 
End Sub

'#######################################################################################################################################
' Выполняет поиск EmploymentParticipantProject на текущую дату, возвращает текущее значение 
' TODO: Для увеличения производительности в метаданные редактора добавить i:preload для Participants.Employment
Function GetParticipantEmployment( oProjectParticipant, oPool )
    Dim curDate : curDate = date()
    Dim oEmployments
    Dim i
    GetParticipantEmployment = 0
    Set oEmployments = oPool.GetXmlObjectsByOPath(oProjectParticipant, "Employment")
    If Not oEmployments Is Nothing Then
        For Each i In oEmployments
           If (i.SelectSingleNode("DateBegin").nodeTypedValue <= curDate) _
                and (i.SelectSingleNode("DateEnd").nodeTypedValue >= curDate) Then
                    GetParticipantEmployment = i.SelectSingleNode("Percent").nodeTypedValue
                    Exit Function
            End If         
        Next
    End If
End Function


