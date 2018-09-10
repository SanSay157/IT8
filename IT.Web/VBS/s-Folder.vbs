'���������� ��������� ��� ������� "Folder"
Option Explicit

Dim g_oObjectEditor			' ������� �������� (��������������� ���� ��� � OnLoad)
Dim g_oPool					' ������� ��� (��������������� ���� ��� � OnLoad)
Dim g_nFolderType			' As Integer - ��� �����
Dim g_sActivityTypeID		' ������������� ���� ��������� ������
Dim g_sActivityTypePath		' ���� �� ������������ ����� ��������� ������
Dim g_sOrgPath				' ���� �� ������������ �����������
Dim g_sParentFolderPath		' ���� �� ������������ ����������� ��������
Dim g_bUserIsAdmin          ' ������� 
Dim g_bIsLocked             ' ������� ���������� ��������
g_bIsLocked = False
'==============================================================================
' ::�������� ���������
Sub usrXEditor_OnLoad(oSender, oEventArgs)
	Set g_oObjectEditor = oSender
	Set g_oPool = oSender.Pool
	
	g_nFolderType = oSender.Pool.GetPropertyValue(oSender.XmlObject, "Type")
	If oSender.Metaname = "Universal" Then
		' � "�������������" ������� �� ������ ���� ����������� ����� "���� ��������� 
		' ������", �� ���� ����������� �������� ��� �����
	Else
		' ��������, ��� � ������� ����� ��� ����� � ������ �� �������
		If oSender.IsObjectCreationMode Then
			If CLng(g_nFolderType) = 0 Then
				Err.Raise -1, "", "�� ����� ��� �����"
			End If
			
			' ��� ���������� ����� ������� 
			If oSender.XmlObject.selectSingleNode("ActivityType").hasChildNodes Then
				g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
			' �����, ���� ������ ������������ �����, ������� �� ��� ����������
			ElseIf oSender.XmlObject.selectSingleNode("Parent").hasChildNodes Then
				g_sActivityTypeID = g_oPool.GetXmlObjectByOPath(oSender.XmlObject, "Parent").selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
			Else
				' ����� ������� ������� ���������� �� ��������� ���� ����� - ��� ������ ���� ����
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
					Alert "�� ������� ���������������� ��� ��������� ������" & vbCr & "��� �����: " & g_nFolderType
					window.close
				End If
			End If
		Else
			g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
		End If
	End If
End Sub


'==============================================================================
' :: ��������� ������ ��������
'	[in] oEventArgs As oEditorStateChangedArgs
Sub usrXEditor_OnValidatePage(oSender, oEventArgs)
	Dim vbRet	' ��������� ������ ������������, � ���������� �������������
	Dim sMsg	' ����� ���������
  	' ��������� ����� � 1-�� ���� "��������������" ������� � ������� ���� ��������� ������ �� 1-�� ����
	If oSender.Metaname = "Universal" And oSender.CurrentPage.PageName = "SelectActivityType" Then
		g_sActivityTypeID = oSender.XmlObject.selectSingleNode("ActivityType/ActivityType").getAttribute("oid")
		g_nFolderType = CLng(oSender.Pool.GetPropertyValue(oSender.XmlObject, "ActivityType.FolderType"))
		g_nFolderType = (g_nFolderType AND FOLDERTYPEENUM_PROJECT) OR (g_nFolderType AND FOLDERTYPEENUM_TENDER) OR (g_nFolderType AND FOLDERTYPEENUM_PRESALE)
		If g_nFolderType = 0 Then
			oEventArgs.ErrorMessage = "�� ������� ���������������� ��� ����� �� ��������� ���������� ���� ��������� ������"
			oEventArgs.ReturnValue = False
		End If
		oSender.XmlObject.selectSingleNode("Type").nodeTypedValue = g_nFolderType
	End If

	If oSender.CurrentPage.PageName = "Directions" Then
        If (g_bDirectionHasBeenChanged) Then
            If (Not IsEmpty(g_sDirectionNewValue)) Then
                If (g_bChildDirectionChange) Then              
                    vbRet = MsgBox ( _
					    "������� ����������� � ���� ��������� �����������/��������� � ��������� ��������� ��� ����������/��������?", _
					    vbYesNo + vbExclamation, "��������!" )
		            If ( vbNo = vbRet ) Then
				        oEventArgs.ReturnValue = False
		    	    End If
                 End If
            ElseIf (Not IsEmpty(g_sDirectionOldValue) And IsEmpty(g_sDirectionNewValue)) Then
                If (g_bChildDirectionChange) Then              
                    vbRet = MsgBox ( _
					    "������� ����������� � ���� ��������� �����������/���������?", _
					    vbYesNo + vbExclamation, "��������!" )
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
					"��������!" & vbCrLf & _
					vbCrLf & _
					"����� ����� ������, �������� ��� ��������� �����������, ��������� 100%!" & vbCrLf & _
					"����� ����������� ����� �������� ������������, � �� ����� ���� ��������."  & vbCrLf & _
					vbCrLf & _
					"����������, ������� ���������� ����������� ����� ������."
				
			ElseIf g_nHasIncorectExpenseRatioSum < 100 Then
				oEventArgs.ReturnValue = False

				sMsg = _
					"��������!" & vbCrLf & vbCrLf & _
					"����� ����� ������, �������� ��� ��������� �����������, ����� 100%!" & vbCrLf & _
					"����� ����������� ����� �������� ������������, � �� ����� ���� ��������."  & vbCrLf & vbCrLf
				
				vbRet = MsgBox ( _
					sMsg & "���������� ������������� ������� �� ������������?", _
					vbYesNo + vbQuestion, "��������!" )	
				If ( vbNo = vbRet ) Then
					oEventArgs.ErrorMessage = sMsg & "����������, ������� ���������� ����������� ����� ������."
					
				Else
					' ���������� ����������
					RecalculateFolderDirections oSender, g_nHasIncorectExpenseRatioSum
					oSender.CurrentPage.SetData
					CheckExpcenseRatioSum oSender

					' ... �.�. oEventArgs.ReturnValue ���������� � False, �� 
					' �� ���������� ����������� ��� ����� ��������� � ���������
				End If
				
			End If
		End If
	End If
	
End Sub


'==============================================================================
' ���������� ����������
Sub RecalculateFolderDirections( oObjectEditor, nCurrentSum )
	Dim nDelta: nDelta = 100 - nCurrentSum
	Dim oDirections: Set oDirections = oObjectEditor.Pool.GetXmlObjectsByOPath(oObjectEditor.XmlObject, "FolderDirections")
	Dim nCount
	Dim nInc
    Dim oNavigator
	Set oNavigator =  oObjectEditor.CreateXmlObjectNavigatorFor(oObjectEditor.XmlObject)
	oNavigator.ExpandProperty "FolderDirections.Direction"
	' ��������� ���������� ������������ �����������
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
' :: ��������� ��������� ���������
Sub usrXEditor_OnSetCaption( oSender, oEventArgs )
	Dim oInitiator			' As IXMLDOMElement - xml-������ Employee - ����������� �������� ���������
	Dim aValues				' As Array - ������ �������� �� ��������� ������
	Dim sOrgID 				' ������������� 
	Dim sFolderID			' ������������� 
	Dim sCaption  
	Dim oXmlObject 
	Dim nParentFolderType

	' �� 1-�� ���� ������� � ������� ���� ��������� ������ ��������� ����������� (��� ������ �� �������� ���)
	If oSender.Metaname = "Universal" And oSender.CurrentPageNo = 1 Then Exit Sub
	
	If IsEmpty(g_sActivityTypePath) Then
		If g_oObjectEditor.XmlObject.selectSingleNode("Customer").hasChildNodes Then
			sOrgID = g_oObjectEditor.XmlObject.selectSingleNode("Customer/Organization").getAttribute("oid")
		End If
		' ����������� ����� (���� ����)
		If g_oObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
			' ������� ��������
			Set oXmlObject = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
			sFolderID = oXmlObject.getAttribute("oid")
		End If
		aValues = GetFirstRowValuesFromDataSource("GetFolderPaths", Array("FolderID", "OrgID", "ActivityTypeID"), Array(sFolderID, sOrgID, g_sActivityTypeID) )
		g_sParentFolderPath = aValues(0)
		g_sOrgPath = aValues(1)
		g_sActivityTypePath = aValues(2)
	' ������ �� ����������� ����� ������� � ��������� ��� ��������� ��������
	ElseIf Not hasValue(g_sOrgPath) Then
		If g_oObjectEditor.XmlObject.selectSingleNode("Customer").hasChildNodes Then
			sOrgID = g_oObjectEditor.XmlObject.selectSingleNode("Customer/Organization").getAttribute("oid")
			g_sOrgPath = GetScalarValueFromDataSource("GetOrganizationPath", Array("OrgID"), Array(sOrgID) )
		End If
	End If
	
	sCaption = "<TABLE CELLPADDING='0' CELLSPACING='0' STYLE='color:#fff;' WIDTH='100%'>" & _
				"<TR><TD COLSPAN=3 STYLE='font-size:12pt;'>"
	' ��������: ������������� NameOf_FolderTypeEnum(g_nFolderType) �������� ������ 
	' ������, ��� ��� ���� (������, ������, �������, �������) �������� ����!
	If g_oObjectEditor.IsObjectCreationMode Then
		sCaption = sCaption & "����� " & LCase(NameOf_FolderTypeEnum(g_nFolderType)) & "</TD></TR>"
	Else
		sCaption = sCaption & "�������������� " & LCase(NameOf_FolderTypeEnum(g_nFolderType)) & "�</TD></TR>"
	End If
	
	' ������
	If hasValue(g_sOrgPath) Then
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top>������:&nbsp;&nbsp;</TD><TD style='font-size:12pt;' width='100%'>" & g_sOrgPath & "</TD></TR>"
	End If
	
	' ����������� ����� (���� ����)
	If g_oObjectEditor.XmlObject.selectSingleNode("Parent").hasChildNodes Then
		' ������� ��������
		Set oXmlObject = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
		nParentFolderType = oXmlObject.selectSingleNode("Type").nodeTypedValue
		sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top><NOBR>����������� " & LCase(NameOf_FolderTypeEnum(nParentFolderType)) & ":&nbsp;&nbsp;</NOBR></TD><TD style='font-size:12pt;' width='100%'>" & g_sParentFolderPath & "</TD></TR>"
	End If
	
	' ��� ��������� ������
	sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD style='font-size:10pt;' valign=top><NOBR>��� ������:&nbsp;&nbsp;</NOBR></TD><TD style='font-size:12pt;' width='100%'>" & g_sActivityTypePath & "</TD></TR>"
			
	If Not g_oObjectEditor.IsObjectCreationMode Then
		Set oInitiator = g_oPool.GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Initiator")
		If Not oInitiator Is Nothing Then
			sCaption = sCaption & "<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=2 style='font-size:9pt;'>���������: " & g_oPool.GetPropertyValue(oInitiator, "LastName") & " " & g_oPool.GetPropertyValue(oInitiator, "FirstName")
			' ����
			Dim oNavigator
			Dim oXmlEvent
			Set oNavigator = g_oObjectEditor.CreateXmlObjectNavigatorFor(g_oObjectEditor.XmlObject)
			oNavigator.ExpandProperty "History"
			Set oXmlEvent = oNavigator.SelectNode("History/FolderHistory[Event='" & FolderHistoryEvents_Creating & "']/EventDate")
			If Not oXmlEvent Is Nothing Then
				sCaption = sCaption & ", ����: " & GetDateValue(oXmlEvent.nodeTypedValue)
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
' ������������ ������ � �������� ����� ��� ���������� - ��������� ��������� 
' �������. ������� ���������� ��� ������������ ������ ������ "��������� �������"
' �� ����������� �������� ���������, ��� ��������� ������������ ������ �������
' "��������� ����" - ��. ����������� �������� Participants ���� Folder � ����-
' ������ it-metadata-main.xml
' ���������:
'	[in] oPool - ��������� ������� ����, � ������� �������������� ������� 
'	[in] oParticipantItem - IXMLElement � ������� ��������� (ProjectParticipant),
'			��������������� ������ ������, ��� ������� ��������� ��������� ������
' ��������� 
'	������ � �������� �����, ����������� ��������. 
Function getProjectPaticipantRoles( oPool, oParticipantItem )
	Dim oRoles		' ��� ���� ���������������� ��������� (XML-������)
	Dim oRole		' ���� �� ����� (XML-������), �������� �����
	Dim sRolesList	' �������������� ������ � �������� �����
	
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
' ������������ ������ �� ��������� ��������� ���� ������.
' ������� ���������� ��� ������������ ������ ������ "�����������",  �� 
' ����������� �������� ���������, ��� ��������� ������������ ������ �������
' "��������� ���� %" - ��. ����������� �������� FolderDirections ���� Folder 
' � ���������� it-metadata-main.xml
' ���������:
'	[in] oPool - ��������� ������� ����, � ������� �������������� ������� 
'	[in] oParticipantItem - IXMLElement � ������� ����� �����-����������� 
'			(FolderDireciton), ��������������� ������ ������
' ��������� 
'	������ � ��������� ��������� ����, ��� ������ ������, ���� �������� 
'	��������� ����� ��� �� �����������.
Function getDirectionPrecomputedExpensesRatio( oPool, oFolderDirectionItem )
	Dim oDirection		' ������ ����������� ��� FolderDirection, ������������ � ������
	Dim sDirectionID	' ������������� ����������� ��� FolderDirection, ������������ � ������
	Dim nIndex			' �������� �����
	
	getDirectionPrecomputedExpensesRatio = ""
	' ���-���� ������ ����� ����� ���� ������ �������� ���������������� �������
	' ��� ����������� � � ��� ���� ������ (��. ��������� �������� DoCalculate �
	' DirectionsList_MenuExecutionHandler); ���� ������ ��� - �������:
	If Not hasValue(g_aPrecomputedExpensesRatios) Then Exit Function
 	' ���������� ������������� �����������: 
	Set oDirection = oPool.LoadXmlProperty( oFolderDirectionItem, "Direction" )
	If Not (oDirection Is Nothing) Then Set oDirection = oDirection.selectSingleNode("Direction/@oid")
	If Not (oDirection Is Nothing) Then sDirectionID = oDirection.nodeValue
	' ...���� ������������� �� ��������, �� � ����� �����. ���� �� ���������
	If Not hasValue(sDirectionID) Then Err.Raise -1, "s-Folder.vbs", "������ ��������� �������������� �����������!"
	
	' ��������� ����� ���� "����������� - �������� ����" � �������, ����������
	' � ���������� ���������� �������� ���������������� �������:
	For nIndex = 0 To UBound(g_aPrecomputedExpensesRatios)
		' ���� �������� ��������� ���� ��� ����������� �����, �� ����� �������:
		If sDirectionID = g_aPrecomputedExpensesRatios(nIndex)(0) Then
			getDirectionPrecomputedExpensesRatio = CStr( g_aPrecomputedExpensesRatios(nIndex)(1) ) & "%"
			Exit Function
		End If
	Next
End Function

Dim g_bDirectionsHadShown			' �������, ��� ���. ������ �� ������������ ���� ��������
Dim g_bDirectionHasBeenChanged		' ������� �������� ��������� � ��������� ����������� - ��������� ��������� 
									' ��������� �����, �� - ��� ����������, ��. DirectionsList_MenuExecutionHandler
Dim g_bHasParentDirectionsSet		' �������, ��� ������������� ����� ����� ������������, 
									' ��� ������� ������ �����������
									
Dim g_sDirectionChangeHistoryInfo	' ������ � ������� �� ������� ��������� �����������
Dim g_sDirectionStructError			' ������ � ������� �������������� � ����������� �������.
Dim g_oTempFolderDirection			' ������ �� ����������� ��������� ������ � ������� FolderDirection
Dim g_nSingleFolderDirectionMode	' ������� ������ ������� ������ ������ �����������
Dim g_nHasIncorectExpenseRatioSum	' ����� ����� �� ���� ������������ - ��� �������� (�.�. <= 100)

Dim g_sRedundantDirectionsIDs		' �������� ��������������� "������" �����������, �������, 
									' �� ����, �� ������ ���� ������ (�.�. �� ���������� ���
									' ����������� �����), �� ��� �� ����� ������������. ���������
									' ��� ����������� ����������� ������� �����������.
									
Dim g_aPrecomputedExpensesRatios	' ������ �������� ��������� �����; �.�. Empty ���� ��������
									' ���������������� ������� �� ����������. ������������ ���
									' ����������� ��������� ����� ����� ���������� ������ �
									' elements-list (��. getDirectionPrecomputedExpensesRatio)
Dim g_bShowDirections				'������� ����������� �����������	

Dim g_sDirectionOldValue            '������ �������� ����������� ��� ������ � �������� �����
Dim g_sDirectionNewValue			'����� �������� ����������� ��� ������ � �������� �����	
Dim g_bChildDirectionChange         '������� ����, ��� � ����� ���� ��������, � ������������� ��������� �� ������ 

Dim g_sParentID                     '������������� ������������ �����. ��������� ��� �������� 
Dim g_bHasParent                    '������� ����, ��� � ����� ���� �������� 
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
	' ��������: 
	'	(�) ��� ������� ��������, � ��� ����� ����� "�����" - ����� ����������� 
	'	������� ������ ����������� ������������ ���, ��� ������ ����� - �� �������,
	'	� ��� "������������" ����������� �����������;
	'	(�) ��� "�������������" ������, ��� �� ������ �������� �������� ��� 
	'	���������� - �� �� �������. ����������� ������� ������ � ���� ������ 
	'	������������ ������ ������ ���������� ����������� ������ ��� ����������� 
	'	���������� (if any)
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
		GetDirectionsHisoryInfo = "(�/�)"
	End If
End Function

'===============================================================================
Function GetDirectionStructError()
	If hasValue( g_sDirectionStructError ) Then
		GetDirectionStructError = _
			"<B>��������! ������� �������������� � ����������� �����������:</B><BR/>" & _
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
' :: ���������� ������� ������������� �������� ���������
'	������������ ��� �������� �������������� ������ �� ������������, �������� 
'	��� ������������� �����. ��� �������� ����������� ������ � ��� ������, ���� 
'	������������ ������� �� �������� "�����������", � ������ ���� ���. 
'
Sub usrXEditorPage_OnInit( oSender, oEventArgs )
	Dim aResults ' ��������� ���������� �������� ExecDataSourc�, ����������� ���. ����������
	Dim sParentID ' ������������� ������������ �����
	' ���������� EditorPage_OnInit ����� ���������� ������, ��� Editor_OnLoad:
	' �� ������ ������ �������� ����������� ������ �� ObjectEditor - � ���� ���
	' ��� �� ��������� - �������� (�.�. ��� ������������ ����� � ����������� 
	' �������):
	If Not hasValue(g_oObjectEditor) Then Set g_oObjectEditor = oSender.ObjectEditor
	If (oSender.PageName = "Main") Then
	    Dim aUserInfo
	    ' ������� ���������� � ������ �������� ������������
	    aUserInfo = GetFirstRowValuesFromDataSource("HomePage-GetCurrentEmployeeInfo", Null, Null)
        g_bUserIsAdmin = CBool(aUserInfo(4))
    End If    
	' ����������� ��������� ����������� ������ ��� �������� "�����������"
	
	If (oSender.PageName <> "Directions" ) Then Exit Sub
	' ... � ���� ��� ��� �� ���� �� �����������
	
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
  	' ��� ��������, ���� ���� ����������� �����, �� ��������� ������� "IsLocked" ��� � ��������
  	If oSender.ObjectEditor.IsObjectCreationMode Then
  	    oSender.ObjectEditor.XmlObject.selectSingleNode("IsLocked").nodeTypedValue = g_bIsLocked
  	End If
	Dim g_nState 
	g_nState = oSender.ObjectEditor.XmlObject.selectSingleNode("State").nodeTypedValue
	' ��������� ������: ����������� ����������� � ������, ���� ��� ����������� 
	' ����� ��� ��� ������: GetXmlObjectByOPath(g_oObjectEditor.XmlObject, "Parent")
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
		   ' ���������, ��� � ���� �� ��� ��� ���������� ���� �������������� FolderDirection, �������� �� ��� ��� ������
		    Set oXmlObject = oSender.XmlObjectPool.selectSingleNode("FolderDirection" & "[@oid='" & g_oTempFolderDirection.getAttribute("oid") & "']")
		    If oXmlObject is Nothing  Then Exit Sub
			Dim oDirection 
			Set oDirection = g_oTempFolderDirection.selectSingleNode( "Direction/Direction[@oid]" )
			If oDirection Is Nothing Then
				' ������� ������ �� FolderDirection; �������� RemoveRelation ��� �������� FolderDirections �� ���� - ��� ������ ����� ��������� ������� � MarkObjectAsDeleted 
				oSender.Pool.MarkObjectAsDeleted "FolderDirection", g_oTempFolderDirection.getAttribute("oid"), Nothing, false, Nothing 
			End If
		End If
	End If
End Sub

'==============================================================================
' ::
' oEventArgs - ���� Nothing
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
			nAnswer = MsgBox( "���������� ����������� ����� ������ �����������! �������?", vbYesNo + vbDefaultButton1 + vbExclamation, "�������������" )
			If ( vbNo = nAnswer ) Then
				MsgBox "����������� ����������� ��������� ������������!", vbExclamation, "��������������"
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

' �������������� ���������� ��������� ���� � ������ "���������� �����"
'	[in] oSender As XPEObjectsElementsListClass - ���������-�������� ���� (PE)
'	[in] oEventArgs As MenuEventArgsClass 		- ��������� �������
Sub DirectionsList_MenuVisibilityHandler( oSender, oEventArgs )
	Dim oNode
	Dim bIsObsolete     ' ������� ����������� �����������
	Dim oCurrDirection  '������� �����������
	Dim bHidden
	Dim sDirectionID
	' ���� ����������� ������, �� �������� �� �� ������� "�����������" ("IsObsolete")
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
		    ' ���� ����������� "����������" ��� �� ������ ������, �� ������ ���� "������ ���� ������..."
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

' ���������� ������ ������ ���� � ������ "���������� �����"
Sub DirectionsList_MenuExecutionHandler( oSender, oEventArgs )
	Dim vResult		' �������� ������ ������������ � ����� �� ��������������
	
	oEventArgs.Cancel = True
	Select Case oEventArgs.Action
		' ���������� ���������������� ������� ����� ������, ����������� ����������� � ������
		Case "DoCalculate"
			
			' ���� ���� �������� ��������� �����������, �� ��������������� ������ ����� ����
			' �������� ���������, �.�. ����������� �� ������ �� ��. ������� �������������� 
			' �� ����� ������, � ������������ ���������� �� ���������� ��������:
			If (g_bDirectionHasBeenChanged) Then
				vResult = MsgBox( _
					"��������!" & vbCrLf & _
					"����������� ����������� ��� ������ ���������� ���� ��������, �� ��� �� ��������." & vbCrLf & _
					"��������������� ������ ����� ������ � ���� ������ ����� ���� ������������ ����������." & vbCrLf & _
					"��� ����������� ������� ���������� ������� �������� ��������� ����������� �����������." & vbCrLf & _
					vbCrLf & "���������� ��������������� ������?", _
					vbExclamation + vbYesNo + vbDefaultButton2, "��������������" )
				If (vbNo = vResult) Then Exit Sub
			End If
			
			' ��������� ��������; ��������� ���������� - �� ����� �������������� � ��. �����
			oSender.ObjectEditor.EnableControls False
			g_aPrecomputedExpensesRatios = GetValuesFromDataSource( "GetCalculatedExpensesRatio", Array("FolderID"), Array(oSender.ObjectEditor.ObjectID) )
            If (Not hasValue(g_aPrecomputedExpensesRatios(0)(0)) And Not hasValue(g_aPrecomputedExpensesRatios(0)(1) )) Then
	            MsgBox "���������� ���������� ��������������� ������ ����� ������"& vbCrLf & _
                    "��������� �� ������� �� ���������������� ������������.", vbExclamation, "��������!"
	        Else
	     	' ���������� ���������� ������: �������� � ������� "��������� ���� %" 
			' ����������� �������� getDirectionPrecomputedExpensesRatio, �������
			' ���������� "�����������" ���������� �������:
			oSender.SetData
			End If
			oSender.ObjectEditor.EnableControls True
			
		Case Else
			oEventArgs.Cancel = False
	End Select
End Sub

' ���������� ������� BeforeMarkDelete, ������������� � �������� ����������� 
' ��������� ������ ���� DoMarkDelete, ����������� ��� ������ "�����������"
'	[in] oSender - PE-��������� - �������� ����; ����� - XPEObjectsElementsListClass
'	[in] oEventArgs - ��������� OperationEventEventArgs
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
	    vRet = MsgBox ("������� ����������� � ����������/�������� � ���� ��������� �����������/���������? "& vbCrLf & _
		"����������?", vbYesNo + vbExclamation) 
		If ( vbNo = vRet ) Then oEventArgs.ReturnValue = false
	End If 
	oEventArgs.Prompt = _
		"� ���������� �������� "& iif( IsDirectory(), "�������", "����������" ) & " �� ����� ����� ������������ � ���������" & vbCrLf & _
		"������������, ��� ������� ��������� ������ � ������� �����������." & vbCrLf & _
		"����������?"
End Sub 

Sub usr_FolderDirections_ObjectsElementsList_OnAfterMarkDelete( oSender, oEventArgs )
	' ��������, ��� ��������� ����������� ���������� - ��� ������ �������� 
	' ���������������� ������� ����������� ��� �������� ������� �������������� 
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
	' ������: ��������� ��� ����� ����� == 100%
	Dim nCount
	g_nHasIncorectExpenseRatioSum = 0
	
	GetExpcenseRatioSum oObjectEditor, g_nHasIncorectExpenseRatioSum, nCount
	
	if ( nCount = 0 ) Then g_nHasIncorectExpenseRatioSum = 100
	
	if ( 0 <> g_nSingleFolderDirectionMode ) Then
		' ���� ����� ����� ������ ������� ��  100%, �� �������� ����������� ����������� ���������:
		With oObjectEditor.CurrentPage.HtmlDivElement.all.item("divPercentWarningText",0)
			If (g_nHasIncorectExpenseRatioSum) <> 100 Then
				.style.display = "block"
			Else
				.style.display = "none"
			End If
		End With
	End If
End Sub

' ���������� ������� ����-�������� ������ �������� ������ FolderDirection
' ���������� ��� ��� �������� FolderDirection "�������" � ����������� ������� 
' ������ ������ ����������� (������� ����� ����������� ��� ���������� �������)
' ������������ ������� BeforeCreate, �.�. ��� ��������� "��������" ��� �����������
' ������� � �� ����������� - ��� ����� �.�. ���� ���������� ���������� OnCreate
' (��. it-security.vbs), ���������� �������� � ������ ������ ������ ������
Sub usr_FolderDirections_ObjectsElementsList_OnBeforeCreate( oSender, oEventArgs )
	Dim oXmlProperty		' xml-��������
	Dim oNewObject			' ����� ������-��������
  	With oEventArgs
		' ������ �������������� ����������
		oSender.ObjectEditor.Pool.BeginTransaction True
		' �����: ������ oXmlProperty �������� ����� ������ BeginTransaction, ������� �� ����� 
		' ������������ � ����� CommitTransaction
		Set oXmlProperty = oSender.XmlProperty
		
		' ������� ����� ������, �������� ��� � ���, ������� �� ���� ������ �� �������� � - ������� - ��������� �������� ����������� �������
		Set oNewObject = CreateXmlObjectInProp( oSender.ObjectEditor.Pool, oSender.ValueObjectTypeName, oXmlProperty )

		' �������� ��� ���������� ������� - �� ��������!
		' ������ ����� �������� ����� �� ������ ����������� - ��� ������ �����������
		
		' �������� ������, �� ������
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
			' ������ ������ - ������� ����������
			oSender.ObjectEditor.Pool.RollbackTransaction
		Else 
		
			Dim oXmlDirectionProperty
			Dim oNewItem
            Dim oXmlExpenseRatio
			Set oXmlDirectionProperty = oNewObject.SelectSingleNode( "Direction" )
			If oXmlDirectionProperty Is Nothing Then
				MsgBox "������ ��������� ������� Folder Direction - �������� Direction �� �������!", vbCritical, "������"
				Err.Raise -1, "s-Folder.vbs", "������ ��������� ������� Folder Direction - �������� Direction �� �������!"
			End If
			Set oXmlExpenseRatio = oNewObject.SelectSingleNode( "ExpenseRatio" )
			'Set oXmlExpenseRatio.nodeTypedValue = 0 
			If oXmlExpenseRatio Is Nothing Then
				MsgBox "������ ��������� ������� Folder Direction - �������� ExpenseRatio �� �������!", vbCritical, "������"
				Err.Raise -1, "s-Folder.vbs", "������ ��������� ������� Folder Direction - �������� ExpenseRatio �� �������!"
			End If
			
			With oSender.ObjectEditor.Pool
				' �������� ��������� ������ � ���, �����, ��-������, ��������� ��� �� ���� 
				' �, ��-������, ��� ����� �� ����� �������� ��� ��������� �������� � SetData
				Set oNewItem = .GetXmlObject( "Direction", sObjectID, Null )
				If X_WasErrorOccured Then
					If X_GetLastError.IsObjectNotFoundException Then
						MsgBox "��������� ������ '" & sObjectID & "' �� ��� �������� � ��������, �.�. ��� ������ ������ �������������", vbOKOnly + vbInformation
					Else
						' ���� ���� ������ ��������� ������, ������� ���������
						X_GetLastError.Show
						' ������� ����������
						oSender.ObjectEditor.Pool.RollbackTransaction
						Exit Sub
					End If
				Else
					.AddRelation Nothing, oXmlDirectionProperty, oNewItem
					If (Not g_bHasParentDirectionsSet) Then
					    '���� ��� ���� �����������, �� ������� ���� ������ 0
					    If HasAnyDirections (oSender.ObjectEditor.Pool,oXmlProperty) Then
					        .SetPropertyValue oXmlExpenseRatio, 0
					    Else ' �����, � ��� ����� ���� �����������, ������� ���� 100
					        .SetPropertyValue oXmlExpenseRatio, 100
					    End If
					End If    
				End If
			End With	
			
			' ���� �������� ����������� - ������� ���������� � �������� � ������ ����������
			If oSender.IsOrdered Then
				oSender.OrderObjectInProp _
					oXmlProperty.selectSingleNode("FolderDirection[@oid='" & oNewObject.getAttribute("oid") & "']")				
			End If
			
			' ������ �� - ���������
			oSender.ObjectEditor.Pool.CommitTransaction
			' ������� ������������� PE
			oSender.SetData
			
			' ��������, ��� ��������� ����������� ���������� - ��� ������ �������� 
			' ���������������� ������� ����������� ��� �������� ������� �������������� 
			g_bDirectionHasBeenChanged = True
			
			CheckExpcenseRatioSum oSender.ObjectEditor
		End If 

	End With
	
	' ��� ����������� ����� - �� ��������!
	oEventArgs.ReturnValue = false
End Sub


'	oEventArgs - ��������� GetRestrictionsEventArgsClass
Sub usr_FolderDirection_Direction_OnGetRestrictions( oSender, oEventArgs )
    If hasValue(g_sParentID) And g_bHasParentDirectionsSet Then
        oEventArgs.ReturnValue = "FolderID=" & oSender.ObjectEditor.ObjectID & "&ParentFolderID=" & g_sParentID
    Else
        oEventArgs.ReturnValue = "FolderID=" & oSender.ObjectEditor.ObjectID 
    End If
End Sub

Sub usr_Folder_IsLocked_OnChanged( oSender, oEventArgs )
					
	' - "� ��� ������� � ����� ��� ������� �� ����������� � ���� �� ��������� ������
	' ������ ���� ����� �������� �������� ��� ��������� ������� ����������
	' � ����-�� ��� ���� ����������� �������� ����� 1 ��������� (������ ����������)
	' ��� ��������� ������� ���������" (����������� �������) 
	Dim oObjectEditor: Set oObjectEditor = oSender.ObjectEditor
	Dim oObjectPool: Set oObjectPool = oObjectEditor.Pool
	Dim oFolder: Set oFolder = oObjectEditor.XmlObject
	Dim vRet 
	
	If oObjectPool.LoadXmlProperty( oFolder, "Children").HasChildNodes Then
		vRet = MsgBox( _
			"���������� �������� ����� �� ��������� �����?" & vbCrLf & vbCrLf & _
			"��������!" & vbCrLf & "��������������� �������� � ��������� ��������� ����� ����� ������ �����!", _
			vbYesNo + vbQuestion, _
			"��������� ���������� ��������" )
		
		If (vbYes = vRet) Then
		
			' ������� �������� ��������� ����� ��� ������� �������� ����� 
			' �������� ���������� ���������� �����; ���� � ���� ������ �������
			' ��������, �� ���� �� ����� ��������� �� ���� ��������� ������.
			' ������� - ��� �������� ���������� ����������� + ����������� 
			' �������� ������ ������� ����������:
			g_oObjectEditor.EnableControls False		
			On Error Resume Next
			vRet = processInnerFolders( oObjectEditor, oObjectPool, oFolder, oEventArgs.NewValue)
			If X_ErrOccured() Then
				XService.CreateErrorDialog( _
					"������ ������� ����������", ERRDLG_ICON_ERROR, _
					"������ ��������� �������� ����������", Err.Description ).ShowModal
				On Error Goto 0
				X_ErrReRaise "������ ��������� �������� ����������", "usr_Folder_IsLocked_OnChanged"
				Exit Sub
			End If
			g_oObjectEditor.EnableControls True
		
			If vRet Then
				XService.CreateErrorDialog( _
					"��������������", ERRDLG_ICON_SECURITY, _
						"<b>��������!</b><br/>" & _
						"��������������� ��������� �������� �����<br/>" & _
						"<i>""�������� �� ����� �������������""</i> �������������� �� �� ��� ��������� �����, " & _
						"��-�� ����������� ���� � ������.", _
					"" ).ShowModal
			End If
		
		End If
	End If
End Sub


' ������������� IsLocked = bValue
Function processInnerFolders(oObjectEditor, oObjectPool, oFolder, bValue)
	Dim oSubFolders: Set oSubFolders = oObjectPool.GetXmlObjectsByOPath(oFolder, "Children")
	Dim oSubFolder
	Dim oIsLockedProperty
	Dim bCanChange
	
	processInnerFolders = False
	
	If oSubFolders Is Nothing Then Exit Function ' ����� �� ��������� ����
	
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
' �������� �� ������������ ����������� ������������ ����� � ���� �� ��������
Function processInnerFoldersDirections(oObjectEditor, oObjectPool, oFolder,sDirectionID, nEqual)
  Dim sFolderID ' ������������� �����
  Dim sDifferenceOrEqualID ' ������������� ����������� �������� �����, ��� ������� ������� �������������� � ������������
  sFolderID = oFolder.getAttribute("oid")
  processInnerFoldersDirections = False
  sDifferenceOrEqualID = GetScalarValueFromDataSource("GetDifferentOrEqualDirection-ForChildFolder", Array("FolderID","DirectionID","bEqual"), Array(sFolderID,sDirectionID, nEqual))
  ' ���� ���-�� �������, ������, ����������� �� ��������� ������ ���������� �� ������������
  processInnerFoldersDirections = HasValue(sDifferenceOrEqualID)  
End Function
' �������� ����, ��� ��� ����� ������ ����� 1-�� �����������
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


' ���������� ������ ����������� ��� ��������� �����
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
    ' �.�. � ��� ����������� �������� ������ ���� �����������, �� ���� ������ ��� ���� ����� 100%
    oSender.ObjectEditor.Pool.SetPropertyValue oXmlExpenseRatio, 100
    g_bDirectionHasBeenChanged = True
    g_sDirectionNewValue = oEventArgs.NewValue
    ' ���� ����������� ����������, �� ���� ��������� ��������� �����
    If (g_sDirectionNewValue <> g_sDirectionOldValue) Then
        g_bChildDirectionChange = processInnerFoldersDirections(oObjectEditor, oObjectPool, oFolder, g_sDirectionNewValue, 0)
    End If
End Sub
' ���������� ������ ����������� ��� ��������� �����
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
' ������� ������� ����������� ��� � ����� �������� ����������/�����, ���� ����������� ������ ��� ������������ ����������/�����
Sub InsertParentDirection(oSender, oParentFolder)
    Dim oNewObject  ' ����� ������ ��� �������� "FolderDirection"
    Dim oNewItem    ' ���������� �����������
    Dim oXmlDirectionProperty ' �������� "FolderDirection" ��� �����
    Dim oFolderDirections ' ����������� �����
    Dim oParentDirections ' ����������� ������������ �����
    Dim sObjectID         ' ������������� ������������ �������
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
' ��������� ����� EmploymentParticipantProject �� ������� ����, ���������� ������� �������� 
' TODO: ��� ���������� ������������������ � ���������� ��������� �������� i:preload ��� Participants.Employment
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


