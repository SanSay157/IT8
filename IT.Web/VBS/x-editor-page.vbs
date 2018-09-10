'===============================================================================
'@@!!FILE_x-editor-page
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor-page - ����������� �������� ���������>
':����������:	����������� �������� ���������.
'===============================================================================
'@@!!CLASSES_x-editor-page
'<GROUP !!FILE_x-editor-page><TITLE ������>
Option Explicit

'===============================================================================
'@@EditorPageClass
'<GROUP !!CLASSES_x-editor-page><TITLE EditorPageClass>
':����������:	����� �������� ���������. �������� ����� ������, � ������� �������� �������� HTML-����������. 
'               �������� ������� ������ ��������� � ������� <LINK points_wc1_02-1,�������>
'<P/> 
'@@!!MEMBERTYPE_Methods_EditorPageClass
'<GROUP EditorPageClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_EditorPageClass
'<GROUP EditorPageClass><TITLE ��������>
Class EditorPageClass
' �������:
'	EnableControls
'	AfterEnableControls
'	Init
'	PreRender
'	Render
'	AfterBinding
'	Load
'	AfterLoad
'	SetDefaultFocus


	'------------------------------------------------------------------------------
	'@@EditorPageClass.CanBeCached
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE CanBeCached>
	':����������:	
	'	������� ����, ��� ���������� �������� ����� ������������. 
	':���������:	
	'	Public CanBeCached [As Boolean]
	Public CanBeCached
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.NeedBuilding
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE NeedBuilding>
	':����������:	
	'	������� ����, ��� ��� ����������� �������� ���� ��������� �� ����������. 
	':���������:	
	'	Public NeedBuilding [As Boolean]
	Public NeedBuilding
	
	Private m_sPageName			' As String - ������������� ��������
	Private m_sPageTitle		' As String - ��������� ��������
	Private m_sPageHint			' As String	- ����
	Private m_oObjectEditor		' As ObjectEditor - ������ �� ��������
	Private m_oBuilder			' As IEditorPageBuilder - PageBuilder ��� �������� �������� ��������
	Private m_oPropertyEditors	' As Scripting.Dictionary - ������� ���������� �������, ���� - html-id ��������, �������� ������ PropertyEditor'��
	Private m_oHTMLDIVElement	' As IHTMLDIVElement - ������ �� DIV, � ������� �������� ������� ��������
	Private m_oMetadata			' As XMLDOMElement - ���������� �������� - ���� i:page ��
	Private m_oEventEngine		' As EventEngineClass
	Private EVENTS				' ������ ������� ��������
	Private m_nBackMode			' ���������������� ����� ��������� ������� ��� ����������� � ������ ��������. ���� ������, �������������� BackMode ���������
	Private m_bHidden			' As Boolean - ������� ����, ��� �������� � ������ ������ ������

	
	'==========================================================================
	' "�����������" ����������
	Private Sub Class_Initialize
		Set m_oPropertyEditors = CreateObject("Scripting.Dictionary")
		Set m_oEventEngine = X_CreateEventEngine
		Set m_oBuilder = Nothing
		Set m_oObjectEditor = Nothing
		Set m_oHTMLDIVElement = Nothing
		CanBeCached = True
		NeedBuilding = True
		EVENTS = "EnableControls,AfterEnableControls,Init,PreRender,Render,AfterBinding,Load,AfterLoad,SetDefaultFocus"
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Dispose>
	':����������:	
	'	��������� ��������� ������������ ������.
	':���������:
	'	Public Sub Dispose () 
	Public Sub Dispose
		On Error Resume Next
		
		Set m_oObjectEditor = Nothing
		
		m_oBuilder.Dispose
		Set m_oBuilder = Nothing
		
		DisposePropertyEditors
		Set m_oPropertyEditors = Nothing
		On Error GoTo 0
	End Sub
	
	
	'==========================================================================
	' �������� Dispose � ���� ���������� �������
	Private Sub DisposePropertyEditors
		Dim aPropertyEditor		'
		Dim i
		If Not IsObject(m_oPropertyEditors) Then Exit Sub
		If Nothing Is m_oPropertyEditors Then Exit Sub
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				On Error Resume Next
				aPropertyEditor(i).Dispose
				On Error GoTo 0
			Next
		Next
		m_oPropertyEditors.RemoveAll
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Init
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Init>
	':����������:	
	'	������������� �������� �� ������ ����������.
	':���������:
	'	oObjectEditor - 
	'       [in] ��������� ������ ObjectEditorClass.
	'	oMetadata - 
	'       [in] ���������� �������� (���� <b>i:page</b>).
	':���������:
	'	Public Sub Init ( 
	'		oObjectEditor [As ObjectEditorClass], 
	'		oMetadata [As IXMLDOMElement]
	'	)
	Public Sub Init(oObjectEditor, oMetadata)
		Dim oBuilder		' As IEditorPageBuilder
		
		Set m_oMetadata = oMetadata
		CanBeCached = IsNull( oMetadata.getAttribute("off-cache") )
		If oObjectEditor.IsWizard Then
			' ���� ��� �������� ����� ����� ������� ������� ���, ����� ������� ����� ������� �� ��������� �� ���������
			If Not IsNull( oMetadata.GetAttribute("wizard-mode") ) Then
				BackMode = ParseWizardBackMode( oMetadata.getAttribute("wizard-mode") )
			Else
				BackMode = oObjectEditor.DefaultBackMode
			End If
		End If
		Set oBuilder = Eval("New " & X_GetAttributeDef(oMetadata, "builder", "EditorPageXsltBuilderClass") )
		oBuilder.Init oObjectEditor, oMetadata
		InitIndirect oObjectEditor, oBuilder, oMetadata.getAttribute("n"), oMetadata.getAttribute("t")
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.InitIndirect
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE InitIndirect>
	':����������:	
	'	������������� �������� �� ������ ����������.
	':���������:
	'	oObjectEditor - 
	'       [in] ��������� ������ ObjectEditorClass.
	'	oPageBuilder - 
	'       [in] ������ ����������� ��������.
	'	sPageName - 
	'       [in] ������������ ��������.
	'	sPageTitle - 
	'       [in] ��������� ��������.
	':���������:
	'	Public Sub InitIndirect ( 
	'		oObjectEditor [As ObjectEditorClass], 
	'		oPageBuilder [As IEditorPageBuilder],
	'       sPageName [As String],
	'       sPageTitle [As String]
	'	)
	Public Sub InitIndirect(oObjectEditor, oPageBuilder, sPageName, sPageTitle)
		Dim oPageDiv		' IHTMLDIVElement
		
		Set m_oObjectEditor = oObjectEditor
		Set m_oBuilder = oPageBuilder
		' �������� DIV, ��� ����� ������ ������� ��������
		With m_oObjectEditor.HtmlPageContainer
			Set oPageDiv = .appendChild( .ownerDocument.createElement("DIV") )
			oPageDiv.style.display = "none"
		End With
		Set m_oHTMLDIVElement =  oPageDiv
		m_sPageName  = sPageName
		m_sPageTitle = sPageTitle
		m_oEventEngine.InitHandlers EVENTS, "usrXEditorPage_On"
		fireEvent "Init", Nothing
	End Sub


	'==========================================================================
	' ���������� �������
	Private Sub fireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageName
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageName>
	':����������:	
	'	������������ (�������������) ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PageName [As String]
	Public Property Get PageName		' As String
		PageName = m_sPageName
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageTitle>
	':����������:	
	'	��������� ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PageTitle [As String]
	Public Property Get PageTitle		' As String
		PageTitle = m_sPageTitle
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageHint
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageHint>
	':����������:	
	'	���������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PageHint [As String]
	Public Property Get PageHint		' As String
		PageHint = m_sPageHint
	End Property 


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PageBuilder
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PageBuilder>
	':����������:	
	'	������ ����������� ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PageBuilder [As IEditorPageBuilder]
	Public Property Get PageBuilder		' As IEditorPageBuilder
		Set PageBuilder = m_oBuilder
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE ObjectEditor>
	':����������:	
	'	��������� ������ ObjectEditorClass.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get ObjectEditor [As ObjectEditorClass]
	Public Property Get ObjectEditor	' As ObjectEditorClass
		Set ObjectEditor = m_oObjectEditor
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Metadata
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE Metadata>
	':����������:	
	'	���������� �������� (���� <b>i:page</b>).
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get Metadata [As IXMLDOMElement]
	Public Property Get Metadata		' As XmlElement - ���������� ��������
		Set Metadata = m_oMetadata
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.BackMode
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE BackMode>
	':����������:	
	'	��������� ������� ��� ����������� ����� � ������ ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get BackMode [As Int]
	Public Property Get BackMode
		BackMode = m_nBackMode
	End Property
	Public Property Let BackMode(nBackMode)
		m_nBackMode = nBackMode
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.IsHidden
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE IsHidden>
	':����������:	
	'	������� ����, ��� �������� � ������ ������ ������.
	':���������:	
	'	Public Property Get IsHidden [As Boolean]
	'   Public Property Let IsHidden(bIsHidden [As Boolean])
	Public Property Get IsHidden
		IsHidden = m_bHidden
	End Property
	Public Property Let IsHidden(bIsHidden)
		m_bHidden = bIsHidden
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.HtmlDivElement
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE HtmlDivElement>
	':����������:	
	'	C����� �� DIV-�������, � ������� ���������� ������� ��������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get HtmlDivElement [As IHTMLElement]
	Public Property Get HtmlDivElement	' As IHTMLElement - ���� DIV ��������
		Set HtmlDivElement = m_oHTMLDIVElement
	End Property 


	'------------------------------------------------------------------------------
	'@@EditorPageClass.IsReady
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE IsReady>
	':����������:	
	'	������� ���������� �������� (���������� ���� ��������� �� ��������).
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get IsReady [As Boolean]
	Public Property Get IsReady			' As Boolean
		IsReady = X_IsDocumentReady( HtmlDivElement )
	End Property
	
	
	'==========================================================================
	Private Property Get IsInterrupted
		IsInterrupted = m_oObjectEditor.IsInterrupted
	End Property


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE EventEngine>
	':����������:	
	'	��������� ������ EventEngineClass.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Clear>
	':����������:	
	'	��������� ������� ���������� ��������.
	':���������:
	'	Public Sub Clear () 
	Public Sub Clear()
		HtmlDivElement.InnerHtml = ""
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.PrepareForRender
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE PrepareForRender>
	':����������:	
	'	��������� ��������� ������������� HTML-�������� DIV, � ������ �������� 
	'   ����������� ���������� ��������: �������� ��������������� �����������, 
	'   ��������� �������� <b>visibility</b> � �������� "hidden".
	':���������:
	'	Public Sub PrepareForRender () 
	Public Sub PrepareForRender()
		Clear
		HtmlDivElement.style.visibility = "hidden"
	End Sub
	

	'------------------------------------------------------------------------------
	'@@EditorPageClass.VisibilityTurnOn
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE VisibilityTurnOn>
	':����������:	
	'	��������� ������������� ������� <b>visibility</b> � �������� "visible".
	':���������:
	'	Public Sub VisibilityTurnOn () 
	Public Sub VisibilityTurnOn
		HtmlDivElement.style.visibility = "visible"
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.Build
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Build>
	':����������:	
	'	������� ��������� ���������� ����������� ��������.
	':���������:
	'	Public Function Build () [As Boolean]
	Public Function Build()
		Dim sHtmlString		' As String
		fireEvent "PreRender", Nothing
		' ���� ���� ���������� ������� Render, �� ������� ���, ����� ������� Html �� builder'a
		If m_oEventEngine.IsHandlerExists("Render") Then
			fireEvent "Render", Nothing
			Build = True
		Else
			On Error Resume Next
			sHtmlString = PageBuilder.GetHtml()
			If Err Then
				MsgBox "������ � �������� ������������ HTML ��������:" & vbCr & Err.Description & vbCr & "��������: " & Err.Source, vbCritical 
				Exit Function
			End If
			On Error GoTo 0
			If Not IsEmpty(sHtmlString) Then
				HtmlDivElement.InnerHtml = sHtmlString
				NeedBuilding = False
				Build = True
			Else
				Build = False
			End If	
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PostBuild
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE PostBuild>
	':����������:	
	'	��������� ��������� ����-������������� ��������. �������������� ��������� 
	'   ���������� ������� � ��������� �� �������.
	':���������:
	'	Public Sub PostBuild () 
	Public Sub PostBuild
		Dim oElement			' IHTMLElement
		Dim vPEClassName		' �������� �������� X_PROPERTY_EDITOR
		Dim oPropertyEditor		' �������� ��������
		Dim oXmlProperty		' Xml-��������
		Dim sHtmlKey			' ������������� Html-�������� ��������� ��������, ���������������� �������� �������
		Dim aPropertyEditor 	' ������ ���������� �������
		Dim i
		DisposePropertyEditors
		For Each oElement In HtmlDivElement.all
			vPEClassName = oElement.getAttribute("X_PROPERTY_EDITOR")
			If Not IsNull(vPEClassName) Then
				sHtmlKey = GetHtmlIdFromFullHtmlId(oElement.id)
				Set oXmlProperty = m_oObjectEditor.GetPropByHtmlID(sHtmlKey)
				If Not oXmlProperty Is Nothing Then
					On Error Resume Next
					Set oPropertyEditor = Eval("New " & vPEClassName)
					If Err Then 
						Alert "�� ������� ������� ������ ��������� ��������:" & vPEClassName & vbCr & Err.Description
						Exit Sub
					End If
					On Error GoTo 0
					If m_oPropertyEditors.Exists(sHtmlKey) Then
						' ���� PE � ����� ������ ��� ����, �� ������� �������� � ������
						aPropertyEditor = m_oPropertyEditors.Item(sHtmlKey)
						addRefIntoArray aPropertyEditor, oPropertyEditor
						m_oPropertyEditors.Item(sHtmlKey) = aPropertyEditor
					Else
						' ����� �������� ����� ������� �������
						m_oPropertyEditors.Add sHtmlKey, Array(oPropertyEditor)
					End If
					On Error Resume Next
					oPropertyEditor.Init Me, oXmlProperty, oElement
					If Err Then
						Alert "������ ������������� ��������� �������� " & vPEClassName & " ��� �������� " & oXmlProperty.tagName & vbCr & Err.Description
						Exit Sub
					End If
					On Error GoTo 0
				End If
			End If
		Next
		InitPropertyEditorsUI
		fireEvent "AfterBinding", Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.InitPropertyEditorsUI
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE InitPropertyEditorsUI>
	':����������:	
	'	��������� ��������� ������ ���� ����-������������� ��������. ��� ������� 
	'   ��������� ������� ���������� ��������� <b>FillD�ta</b>.
	':����������:	
	'	��������� ���� ������� ��-�� ����, ��� ���������� ������� ��������� ��������
	'   (��������� <b>FillD�ta</b>) ����� �������� �� ������ ���������� �������.
	'   ������� ����� �������� ���������� ������� � ������������� ���������.<P/>
	'   ��������� ����� ������ ��-�� ����, ��� ��������� ������ ��������� 
	'   �������������������� ��������� ��� ���������� ��������� ���������� �������.
	':���������:
	'	Public Sub InitPropertyEditorsUI () 
	Public Sub InitPropertyEditorsUI
		Dim aPropertyEditor 	' ������ ���������� �������
		Dim i
		
		' ������� �� ���� PE � ������� FillData
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				aPropertyEditor(i).FillData
			Next
		Next
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetData
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetData>
	':����������:	
	'	��������� ��������� ��������� ������� ������� �������� �� XML. 
	':���������:
	'	Public Sub SetData () 
	Public Sub SetData
		Dim aPropertyEditor
		Dim i
		
		If m_oEventEngine.IsHandlerExists("Load") Then
			fireEvent "Load", Nothing
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					aPropertyEditor(i).SetData
				Next
			Next
		End If
		fireEvent "AfterLoad", Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetDefaultFocus>
	':����������:	
	'	������� ������������� ����� �� ������ ��������� �������� �������� �� ��������.
	':���������:
	'	Public Function SetDefaultFocus () [As Boolean]
	Public Function SetDefaultFocus()
		Dim aPropertyEditor
		Dim i

		SetDefaultFocus = True
		If m_oEventEngine.IsHandlerExists("SetDefaultFocus") Then
			' TODO: ����� �����-�� EventArgs
			fireEvent "SetDefaultFocus", Nothing
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					' ����� ���� ��� �������...
					If IsInterrupted Then Exit Function
					If aPropertyEditor(i).SetFocus Then Exit Function
				Next
			Next
			SetDefaultFocus = False		
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetData
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetData>
	':����������:	
	'	��������� ��������� ������ �� ����� � ����������� XML-������ � ���������� 
	'   ������� <b>OnPageLoad</b>.
	':���������:
	'	oGetDataArgs - 
	'       [in] ��������� ������ GetDataArgsClass.
	':���������:
	'	Public Sub GetData ( 
	'		oGetDataArgs [As GetDataArgsClass]
	'	) 
	Public Sub GetData(oGetDataArgs)
		Dim aPropertyEditor		' �������� ��������
		Dim i
		
' TODO: �������!
		' ������������ ��� html-�������� � ������� ��������������
		For Each aPropertyEditor In m_oPropertyEditors.Items
			For i=0 To UBound(aPropertyEditor)
				With oGetDataArgs.Clone
					aPropertyEditor(i).GetData .Self()
					If .ReturnValue <> True And Not oGetDataArgs.SilentMode Then
						' ����������!
						If HasValue(.ErrorMessage) Then
							Alert .ErrorMessage
						End If
						EnablePropertyEditor aPropertyEditor(i), True
						' ��������� ����� �� PE
						' ��������: �������� ��� ���������� (������ ����, ��� ������ ������� aPropertyEditor(i).SetFocus)
						' ��-�� ��������� ��������� IE:
						' ��� ����������� ���������� �������� ������� (window.event.srcElement), 
						' ���� � ������ ���������� ����������� ActiveX-������� �� �������� �������� ������� (�.�. ������� focus).
						' HTML-�������, ��������������� ��������������� ActiveX (��������, OnKeyUp) ������ � document 
						' (�.�. � ���������� document_onKeyUp) �� ��������� srcElement ������������� ��� �� ����� ������� (� ���������� focus)
						window.setTimeout ObjectEditor.UniqueID & ".CurrentPage.GetPropertyEditorByFullHtmlID(""" & aPropertyEditor(i).HtmlElement.id & """).SetFocus", 1, "VBScript"
						oGetDataArgs.ReturnValue = False
						Exit Sub
					End If
				End With
			Next
		Next
					
' TODO: ������� (OnPageEnd)
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.SetEnable
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE SetEnable>
	':����������:	
	'	��������� ���������/������������ ��� ��������� ������� �� �������� � ���������� 
	'   ������� <b>EnableControls</b> � <b>AfterEnableControls</b>.
	':���������:
	'	bEnable - 
	'       [in] ������� ����������/������������� ���� ���������� ������� �� ��������.
	':���������:
	'	Public Sub SetEnable ( 
	'		bEnable [As Boolean]
	'	) 
	Public Sub SetEnable(bEnable)
		Dim aPropertyEditor 
		Dim i
		
		If m_oEventEngine.IsHandlerExists("EnableControls") Then
			With New EnableControlsEventArgsClass
				.Enable = bEnable
				fireEvent "EnableControls", .Self()
			End With
		Else
			For Each aPropertyEditor In m_oPropertyEditors.Items
				For i=0 To UBound(aPropertyEditor)
					EnablePropertyEditor aPropertyEditor(i), bEnable
				Next
			Next
		End If
		' ��� ����������� ��������, ���� �� ����������, ����� ��� �� ��������� ������
		If m_oEventEngine.IsHandlerExists("AfterEnableControls") Then
			With New EnableControlsEventArgsClass
				.Enable = bEnable
				fireEvent "AfterEnableControls", .Self()
			End With
		End If
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EnablePropertyEditor
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE EnablePropertyEditor>
	':����������:	
	'	������� ���������/��������� ������� ����������.
	':���������:
	'	oPropertyEditor - 
	'       [in] �������� ��������.
	'	bEnable - 
	'       [in] ������� ����������� ��������.
	':����������:	
	'	� ����� ������ ��� ������ �������/��������� ���������� ����� ���������
	'   �������� ���������� ����������������. ��� ���� ���������� ���������� �
	'   �����������  �������������� �� ������ ��������  ���������������  �����
	'   ��������������� ���������. ������� ����������� ���������������  ��������
	'   <b>X_DISABLED</b> ����������� ������� ����� "�����������". ��� ������� 
	'   �������������� �������, ���������� ������ ���������, ��������� 
	'   ��������������� �� ����������, � ������� ���������.
	':���������:
	'	Public Function EnablePropertyEditor ( 
	'       oPropertyEditor [As Object],
	'		bEnable [As Boolean]
	'	) [As Boolean]
	Public Function EnablePropertyEditor(oPropertyEditor, bEnable)
		EnablePropertyEditor = EnablePropertyEditorEx(oPropertyEditor, bEnable, False)
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.EnablePropertyEditorEx
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE EnablePropertyEditorEx>
	':����������:	
	'	������� ���������/��������� ������� ����������.
	':���������:
	'	oPropertyEditor - 
	'       [in] �������� ��������.
	'	bEnable - 
	'       [in] ������� ����������� ��������.
	'	bForce - 
	'       [in] ������� ��������������� �������� � ������ ��������� ���
	'       ������� ����� "�����������".
	':����������:	
	'	� ����� ������ ��� ������ �������/��������� ���������� ����� ���������
	'   �������� ���������� ����������������. ��� ���� ���������� ���������� �
	'   �����������  �������������� �� ������ ��������  ���������������  �����
	'   ��������������� ���������. ������� ����������� ���������������  ��������
	'   <b>X_DISABLED</b> ����������� ������� ����� "�����������". ��� ������� 
	'   �������������� �������, ���������� ������ ���������, ��������� 
	'   ��������������� �� ����������, � ������� ���������.
	':���������:
	'	Public Function EnablePropertyEditorEx ( 
	'       oPropertyEditor [As Object],
	'		bEnable [As Boolean],
	'		bForce [As Boolean]
	'	) [As Boolean]
	Public Function EnablePropertyEditorEx(oPropertyEditor, bEnable, bForce)
		Dim oIHtmlElement		' IHtmlElement PE
		Dim nDisableDepth		' ������� ����� ���������
		Dim nDisableDepthOrigin	' �������������� �������� nDisableDepth
		
		EnablePropertyEditorEx = False
		Set oIHtmlElement = oPropertyEditor.HtmlElement

		nDisableDepth = CLng("0" & oIHtmlElement.GetAttribute("X_DISABLED"))
		nDisableDepthOrigin = nDisableDepth
		If bForce Then
			If bEnable Then
				nDisableDepth =  0
			Else	
				nDisableDepth =  1
			End If	
		Else
			' ���� ������� ��� ������������ � ����� ���, �� �� ����
			If Not (nDisableDepth = 0 And bEnable) Then
				nDisableDepth = nDisableDepth + Iif(bEnable, -1, +1)
			End If
		End If

		EnablePropertyEditorEx = True 
		oIHtmlElement.SetAttribute "X_DISABLED", nDisableDepth
		If nDisableDepth = 0 And nDisableDepthOrigin>0 Then
			oPropertyEditor.Enabled = True
		ElseIf nDisableDepth = 1 And nDisableDepthOrigin=0 Then
			oPropertyEditor.Enabled = False
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Hide
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Hide>
	':����������:	
	'	��������� �������� DIV ��������. 
	':���������:
	'	Public Sub Hide () 
	Public Sub Hide
		HTMLDIVElement.style.display = "none"
	End Sub


	'------------------------------------------------------------------------------
	'@@EditorPageClass.Show
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE Show>
	':����������:	
	'	��������� ���������� DIV ��������. 
	':���������:
	'	Public Sub Show () 
	Public Sub Show
		HTMLDIVElement.style.display = "block"
	End Sub	


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditors
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditors>
	':����������:	
	'	������� ���������� ������ ���������� ������� ��� ��������� �������� ���
	'   Empty, ���� ��� ��������� �������� �� ������� ��������� ��������.
	':���������:
	'	oXmlProperty - 
	'       [in] ������ �� XML-��������.
	':���������:
	'	Public Function GetPropertyEditors ( 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Array]
	Public Function GetPropertyEditors(oXmlProperty)
		Dim sHtmlId		' ������� html-id
		
		sHtmlId = m_oObjectEditor.GetHtmlID( oXmlProperty )
		If Not IsNull(sHtmlId) Then
			If m_oPropertyEditors.Exists( sHtmlId ) Then
				GetPropertyEditors = m_oPropertyEditors.Item(sHtmlId)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditor
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditor>
	':����������:	
	'	������� ���������� ������ ������� �� ������� ���������� ������� ��� ��������� 
	'   �������� ��� Nothing, ���� ��� ��������� �������� �� ������� ��������� ��������.
	':���������:
	'	oXmlProperty - 
	'       [in] ������ �� XML-��������.
	':���������:
	'	Public Function GetPropertyEditor ( 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Object]
	Public Function GetPropertyEditor(oXmlProperty)
		Dim sHtmlId		' ������� html-id
		
		Set GetPropertyEditor = Nothing
		sHtmlId = m_oObjectEditor.GetHtmlID( oXmlProperty )
		If Not IsNull(sHtmlId) Then
			If m_oPropertyEditors.Exists( sHtmlId ) Then
				Set GetPropertyEditor = m_oPropertyEditors.Item(sHtmlId)(0)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.GetPropertyEditorByFullHtmlID
	'<GROUP !!MEMBERTYPE_Methods_EditorPageClass><TITLE GetPropertyEditorByFullHtmlID>
	':����������:	
	'	������� ���������� ��������� ��������� �������� ��� HTML-�������� � �������� 
	'   ���������������.
	':���������:
	'	sFullHtmlId - 
	'       [in] ������������� HTML-��������.
	':���������:
	'	Public Function GetPropertyEditorByFullHtmlID ( 
	'		sFullHtmlId [As String]
	'	) [As Object]
	Public Function GetPropertyEditorByFullHtmlID(sFullHtmlId)
		Dim oPropertyEditor		' As IPropertyEditor
		Dim sKey				' As String - ���� � ������� PropertyEditor'��
		
		Set GetPropertyEditorByFullHtmlID = Nothing
		sKey = GetHtmlIdFromFullHtmlId(sFullHtmlId)
		If Not m_oPropertyEditors.Exists(sKey) Then Exit Function
		
		For Each oPropertyEditor In m_oPropertyEditors.Item( sKey )
			If oPropertyEditor.HtmlElement.id = sFullHtmlId Then
				Set GetPropertyEditorByFullHtmlID = oPropertyEditor
				Exit For
			End If
		Next
	End Function


	'==========================================================================
	' ���������� �������� ����� html-id �� ������� �������������� Html ��������,
	' ������� ��������� #���� (37 ��������), ����������� ��� ����������� ������������ ��������������� ���������
	'	[in] sFullHtmlId As String - ������������� Html ��������
	'	[retval] �������� ����� html-id
	Private Function GetHtmlIdFromFullHtmlId(sFullHtmlId)
		' 37 - ��� ����� ����� + ������ "#" ���������� �������� ����� html-id �� �����, 
		' ������������ ��� ����������� ������������
		GetHtmlIdFromFullHtmlId = Left(sFullHtmlId, Len(sFullHtmlId) - 37)
	End Function


	'------------------------------------------------------------------------------
	'@@EditorPageClass.PropertyEditors
	'<GROUP !!MEMBERTYPE_Properties_EditorPageClass><TITLE PropertyEditors>
	':����������:	
	'	��������� ���������� �������.
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get PropertyEditors [As Scripting.Dictionary]
	Public Property Get PropertyEditors
		Set PropertyEditors = m_oPropertyEditors
	End Property
End Class


'==============================================================================
' ������� ���� XSL ������� (g_oXsltPageCacheStatic).
Class XslCacheEntry
	Private m_sUserDataNamePrefix	' ������� ����� � UserData, ��� ������� �������� Xsl
	
	Public Xsl						' As IXMLDOMDocument - �������� � XSLT-��������
	
	' ������������� ������� ����� � UserData, ��� ������� ����� ��������� Xsl
	Public Sub SetUserDataNamePrefix(sName)
		m_sUserDataNamePrefix = "XSL." & sName & "."
	End Sub
	
	' ���������� ������� ����� � UserData, ��� ������� �������� Xsl
	Public Property Get UserDataNamePrefix
		UserDataNamePrefix = m_sUserDataNamePrefix
	End Property
End Class

Private g_oXsltPageCacheStatic ' As Scripting.Dictionary - ��� xsl. ���� - ������������ xsl, �������� - ��������� XslCacheEntry
Set g_oXsltPageCacheStatic = CreateObject("Scripting.Dictionary")

'==============================================================================
' �������� ������������ ����������� �������
' ��. EditorPageXsltBuilderClass::InitIndirect
Function X_CreateXsltPageBuilder(oObjectEditor, sXsltFileName, sExpandPropertyPath)
	Set X_CreateXsltPageBuilder = New EditorPageXsltBuilder
	X_CreateXsltPageBuilder.InitIndirect oObjectEditor, sXsltFileName, sExpandPropertyPath
End Function


'==============================================================================
'implements interface IEditorPageBuilder:
'GetHtml(oObjectEditor As ObjectEditor)
'Init(PageMetadata As XMLDOMElement)
'IsEqual(oBuilder As IEditorPageBuilder) As Boolean
Class EditorPageXsltBuilderClass	' : IEditorPageBuilder
	Private m_sXsltFileName		' As String
	Private m_sExpandProperty	' As String
	Private m_oObjectEditor
	
	'==========================================================================
	Public Sub Dispose()
		Set m_oObjectEditor = Nothing
	End Sub
	
	'==========================================================================
	Public Sub Init(oObjectEditor, oPageMetadata)
		InitIndirect oObjectEditor, Trim(oPageMetadata.text), oPageMetadata.GetAttribute("expand")
	End Sub
	
	'==========================================================================
	' ������������� ����������� HTML-������� ���������
	' [in] oObjectEditor - ��������
	' [in] sXsltFileName - ��� Xslt - ����� ������������� ��� ���������� ��������
	' [in] sExpandProperty - ������ ������� ������������ ������������� � Xml (��. XmlObjectNavigatorClass::ExpandProperty)
	Public Sub InitIndirect(oObjectEditor, sXsltFileName, sExpandProperty)
		Set m_oObjectEditor = oObjectEditor
		m_sXsltFileName = sXsltFileName
		m_sExpandProperty = trim("" & sExpandProperty)
	End Sub

	'==========================================================================
	Public Property Get XsltFileName
		XsltFileName = m_sXsltFileName
	End Property


	'==========================================================================
	Public Function IsEqual(oBuilder) 'As Boolean
		IsEqual = False
		If TypeName(Me)<>TypeName(oBuilder) Then Exit Function
		If XsltFileName <> oBuilder.XsltFileName Then Exit Function
		IsEqual = True
	End Function


	'==========================================================================
	Private Property Get IsInterrupted
		IsInterrupted = m_oObjectEditor.IsInterrupted
	End Property


	'==========================================================================
	' ���������� XmlDomDocument, ���������� Xsl
	' [In] sName  - ��� ������������ Xsl
	Public Function GetXsl(sName)
		Set GetXsl = InternalGetXsl(sName).Xsl
	End Function
	

	'==========================================================================
	' ���������� XmlDomDocument, ���������� Xsl, ����������� �������
	' [In] sName				- ��� ������������ Xsl
	' [In] oContextDictionary	- �������� ��� �������������� ������������ ���������
	Private Function InternalGetXsl(sName)
		Dim oEntry
		Dim oXsl					' IXMLDOMDocument, ���������� Xsl
		Dim sXslMD5					' MD5 �������� � XSL
		Dim bSave
		Dim sXslLocalFileName		' ��� XSL �� ��������� �����
		Dim sXslToIncludeName		' ������������ ������� XSL, ���������� ���������
		Dim oXslIncludeEntry		' IXMLDOMElement, ������ �� ������� XSL (xsl:include ��� xsl:import)
		Dim oIncludedEntry
		Dim bReload
		Dim oNewEntry
		
		If g_oXsltPageCacheStatic.Exists(sName) Then
			' ���� ����� - ����� �� ����
			Set oEntry = g_oXsltPageCacheStatic.Item (sName)
		Else
			Set oEntry = New XslCacheEntry
			oEntry.SetUserDataNamePrefix sName
			
			bSave = False
			sXslMD5 = X_GetMD().GetAttribute("xsl-md5")
					
			If XService.GetUserData( oEntry.UserDataNamePrefix & sXslMD5 , oXsl) Then
				Set oEntry.Xsl = oXsl.ownerDocument
				If Not IsNothing(oEntry.Xsl.DocumentElement.SelectSingleNode("@*[local-name()='off-cache']")) Then
					' ����������� � �������
					Set oEntry.Xsl = XService.XmlGetDocument( "Xsl/" & sName)
					bSave = True 
				End If
			Else
				' �������� ��� XSL-��
				internal_ClearDataCache oEntry.UserDataNamePrefix
				' ������� � �������
				Set oEntry.Xsl = XService.XmlGetDocument( "Xsl/" & sName)
				bSave = True
			End If
			g_oXsltPageCacheStatic.Add sName, oEntry
			If bSave Then
				bReload = False
				Set oNewEntry = oEntry.Xsl.CreateElement("xsl:import")
				For Each oXslIncludeEntry In oEntry.Xsl.documentElement.selectNodes("xsl:import[@href]|xsl:include[@href]")
					bReload = True
					sXslToIncludeName = oXslIncludeEntry.GetAttribute("href")
					Set oIncludedEntry = InternalGetXsl(sXslToIncludeName)
					sXslLocalFileName = "file://" & Replace( XService.GetAppDataPath() , "\", "/") & "/" & XService.UrlEncode( oIncludedEntry.UserDataNamePrefix & sXslMD5 & ".xml")
					Set oNewEntry = oEntry.Xsl.CreateElement("xsl:import")
					oNewEntry.SetAttribute "href", sXslLocalFileName
					oEntry.Xsl.documentElement.InsertBefore oNewEntry.CloneNode(True), oEntry.Xsl.documentElement.firstChild
					oXslIncludeEntry.parentNode.RemoveChild oXslIncludeEntry
				Next
				' ������� � ���
				XService.SetUserData oEntry.UserDataNamePrefix & sXslMD5 , oEntry.Xsl.documentElement				
				If bReload Then
					Call XService.GetUserData( oEntry.UserDataNamePrefix & sXslMD5 , oXsl)
					Set oEntry.Xsl = oXsl.ownerDocument
				End If
			End If
		End If
		Set InternalGetXsl = oEntry
	End Function


	'==========================================================================
	' ���������� Html �������� ��������
	Public Function GetHtml()
		Dim oStyle			' Xsl-������ (XmlDOMDocument)
		Dim oTemplate		' XslTemplate
		Dim oProcessor		' XslProcessor
		Dim nOffset			' ������� ������� "?" � ����� Xsl
		Dim oQS				' CQueryString - ������ ���������� Xsl-��������
		Dim oXmlNavigator
		Dim oXmlObject
		Dim sStyleSheet
		
		sStyleSheet = m_sXsltFileName

		' ������������ ������ �� ������� �������
		Set oQS = X_GetEmptyQueryString
		
		' ���� �������� �������� ����� ��� XSL-����, �� ������� ��� ������������ 
		' ��� ���������� ��� ����������� ����������� �������� �� ���� (� ����� -
		' ��� ���������� � ���� - � �������). 
		' ��� �����, ��� ��� ��������� ��� XSL-������� ����� ������ �� �������.
		' ���� �� �������� ����� ��� ��������� ������, �� ������ ������ �� ������ 
		' ���������, ������� query-string. ��� ��� ������ ���������� �� �������
		' ���������� .xsl � ������������ �������������� �������
		
		' ���������� ���������� ������� ������ ������� � ����� Xsl
		nOffset  = InStr( sStyleSheet, "?")
		' �����...
		If nOffset > 0 Then
			' ������ ������ ������� � ��������
			oQS.QueryString = MID( sStyleSheet, nOffset + 1 )
			' ��� "������" XSL-������� �� ����� ������ ���������� ���������
			' �� ������ - ������ ��. "������" �������� ��������� �� �������
			' ���������� .xsl � ������������ �������������� �������:
			If (nOffset - Len(".xsl")) = InStr( LCase(sStyleSheet), ".xsl?") Then
				sStyleSheet = MID( sStyleSheet, 1, nOffset - 1 )
			End If
		End If
		oQS.AddValues m_oObjectEditor.QueryString
		
		' ��������� ������
		On Error Resume Next
		Set oStyle = GetXsl( sStyleSheet)
		If Err Then
			X_ErrReport
			Exit Function
		End If
		On Error GoTo 0
		If IsInterrupted = True Then 
			Exit Function
		End If	
		' ������� XslTemplate
		Set oTemplate = CreateObject( "MSXml2.XslTemplate.3.0")
		' ��������� ������������ ������
		oTemplate.stylesheet = oStyle
		' ������� ���������
		Set oProcessor = oTemplate.createProcessor
		Set oXmlNavigator = m_oObjectEditor.CreateXmlObjectNavigator()
		
		If IsInterrupted = True Then 
			Exit Function
		End If	
		
		If 0<>Len(m_sExpandProperty) Then
			oXmlNavigator.ExpandProperty m_sExpandProperty
		End If
		
		If IsInterrupted = True Then 
			Exit Function
		End If	
		
		Set oXmlObject = oXmlNavigator.XmlObject
		' �������� ���������� ���������������� �������� - ������
		oProcessor.input = oXmlObject
		oProcessor.addObject oXmlNavigator, "urn:xml-object-navigator-access"
		' �������� ���������� ������ ������� � ������ ���������/�������
		oProcessor.addObject m_oObjectEditor, "urn:object-editor-access"
		' �������� ���������� ������ ������� � ���� ���������/�������
		oProcessor.addObject window, "urn:editor-window-access"
		' �������� ���������� ������ ������� � ������ ���������� Xsl
		oProcessor.addObject oQS, "urn:query-string-access"
		' �������� ���������� ������ ������� � IXClientService
		oProcessor.addObject XService, "urn:x-client-service"
		' �������� ���������� ������ ������� � ����
		oProcessor.addObject Me, "urn:x-page-builder"
		On Error Resume Next
		' ��������������
		oProcessor.transform
		' ����� ���� ��� �������...
		If IsInterrupted = True Then 
			' ��� ���� ��� ������� - ������� ��������� ������!
			err.Clear 
			Exit Function
		End If		
		If Err Then
			' TODO: Alert !!!
			Alert "������ ��� �������������� �������� ��������� ����������� Xsl!" & vbNewLine & Err.Description
			Exit Function
		End If
		GetHtml = oProcessor.output
	End Function
	
	'==================================================================
	' ���������� �������� �������� ����������, ����������� XPath-��������, 
	' ����������� � ��������� ���������� �������� ���������� ����
	' ������������ �� xslt-��������.
	' [In] oProp  - IXmlDOMElement c� ��������� ��� 
	'				IXmlDOMNodeList, ������ ������� �������� ���� �������� ��� 
	'				��� �������� � �������� �������
	' [In] sQuery - ����� XPath-�������...
	Public Function MDQueryProp( oProp, sQuery)
		MDQueryProp = MDQueryPropDef(oProp, sQuery, "")
	End Function	


	'==================================================================
	' ���������� �������� �������� ����������, ����������� XPath-��������, 
	' ����������� � ��������� ���������� �������� ���������� ����.
	' ������������ �� xslt-��������.
	'	[in] oProp  - IXmlDOMElement c� ��������� ��� 
	'				IXmlDOMNodeList, ������ ������� �������� ���� �������� ��� 
	'				��� �������� � �������� �������
	'	[in] sQuery - ����� XPath-�������...
	'	[in] sDefValue - �������� �� ���������, ������������, ���� ������������� ���� �� ������
	Public Function MDQueryPropDef( oProp, sQuery, sDefValue)
		Dim vVal	' �������� ��-��
		MDQueryPropDef = sDefValue
		If 0=StrComp(  typename(oProp), "IXmlDomNodeList", vbTextCompare) Then
			Set vVal = m_oObjectEditor.PropMD(oProp.item(0)).selectSingleNode( sQuery)
		Else
			Set vVal = m_oObjectEditor.PropMD(oProp).selectSingleNode( sQuery)
		End If 
		If vVal Is Nothing Then Exit Function
		vVal = vVal.nodeTypedValue
		If IsNull( vVal) Then Exit Function
		MDQueryPropDef = vVal
	End Function	

	
	'==================================================================
	' ����������� True/False ���� � ���������� �������� �������� XPath ���-�� �����
	Public Function IsMDPropExists( oProp, sQuery)
		If 0=StrComp(  typename(oProp), "IXmlDomNodeList", vbTextCompare) Then
			IsMDPropExists = Not m_oObjectEditor.PropMD(oProp.item(0)).selectSingleNode( sQuery ) Is Nothing
		Else
			IsMDPropExists = Not m_oObjectEditor.PropMD(oProp).selectSingleNode( sQuery ) Is Nothing
		End If 
	End Function


	'==================================================================
	' ��������� ��������� � ���������� ���������� ��������
	' ������������� ��� ������������� � Xsl-�������� ��� ����������
	' ���� �������� ������ ��������, �� �� ������ ���� ����� ������ ��������
	Public Function Evaluate( sExpression)
		Dim vResult	' ��������� ����������
		If Len("" & sExpression) > 0 Then
			vResult = Eval( sExpression)
			If Err.number Then
				Alert  sExpression  & vbNewLine & Err.number & vbNewLine & Err.Description & vbNewLine  & Err.Source 
			End If	
		Else
			vResult = ""
		End If
		Evaluate = vResult
	End Function	


	'==========================================================================
	' ���������� �������� ��������� �������� ���������� ��������, ����������� ������������ ��� �������� ������� 
	' �������� ������ ��� ��������� ��������
	'	<!-- ��� ��������, �� ������� ��������� ����������� ��������� �������� -->
	'   <xsl:variable name="build-on-name" select="b:Evaluate('eval( iif(IsIncludedEditor,&quot;&quot;&quot;&quot;&quot; &amp; PropMD( XmlObject.parentNode).getAttribute(&quot;&quot;built-on&quot;&quot;)&quot; ,&quot;0&quot; ))')"/>
	'	<!-- ��� ���������� �������� ����� -->
	'	<xsl:variable name="order-by-name" select="b:Evaluate('eval( iif(IsIncludedEditor,&quot;&quot;&quot;&quot;&quot; &amp; PropMD( XmlObject.parentNode).getAttribute(&quot;&quot;order-by&quot;&quot;)&quot; ,&quot;0&quot; ))')"/>	
	Public Function GetSpecialName(sName)
		GetSpecialName = ""
		If Not IsNothing(m_oObjectEditor.ParentXmlProperty) Then
			GetSpecialName = "" & m_oObjectEditor.PropMD(m_oObjectEditor.ParentXmlProperty).getAttribute(sName)	
		End If
	End Function


	'==========================================================================
	' ���������� ������ HtmlId ��� ��������� �������� �� ��������� ���� xml-��������.
	' ������������ �� XSLT ��������
	'	[in] oNode - IXMLNodeList
	Public Function GetHtmlID(oNode)
		GetHtmlID = m_oObjectEditor.GetHtmlID(oNode.item(0)) & "#" & XService.NewGuidString
	End Function


	'==========================================================================
	' ���������� ���������� ������������ ��� PropertyEditor'a, ��������� PageNameManager �� ���������
	'	[in] xslt �������� 
	Public Function GetUniqueNameFor(oXSLTContext)
		GetUniqueNameFor = m_oObjectEditor.GetUniqueNameFor( oXSLTContext.item(0) )
	End Function

	
	'==========================================================================
	' ���������� xml-���� ds:prop ���������� �������
	' "�����������" ������ ��� ������������� �� XSLT-������� - ���������� ����� ��������, 
	' �.�. XSLT �������� ��� XMLDocument'� ��� read-only � �������� ��� ���� ���������� �� �� �����, 
	' �.�. ��� ����� ���������������� (������������ �� ���� �������� ����� �����)
	'	[in]  oXSLTContext - XSLT-��������. xml-���� �������� ��������
	Public Function GetPropMD(oXSLTContext)
		Dim oXmlDoc		' As IXMLDOMDocument - ����� ��������, ��� �������� � XSLT
		Dim oXmlPropMD	' As IXMLDOMElement - ���� ds:prop
		
		Set oXmlPropMD = m_oObjectEditor.PropMD( oXSLTContext.item(0) )
		Set oXmlDoc = oXmlPropMD.ownerDocument.cloneNode( false) 
		oXmlDoc.appendChild oXmlPropMD.CloneNode( true)
		oXmlDoc.SetProperty "SelectionNamespaces", oXmlPropMD.ownerDocument.GetProperty("SelectionNamespaces")
		oXmlDoc.SetProperty "SelectionLanguage", oXmlPropMD.ownerDocument.GetProperty("SelectionLanguage")
		Set GetPropMD = oXmlDoc.documentElement
	End Function


	'==========================================================================
	' ���������� xml-���� ds:type ���������� ����
	' "�����������" ������ ��� ������������� �� XSLT-������� - ���������� ����� ��������, 
	' �.�. XSLT �������� ��� XMLDocument'� ��� read-only � �������� ��� ���� ���������� �� �� �����, 
	' �.�. ��� ����� ���������������� (������������ �� ���� �������� ����� �����)
	'	[in] sTypeName - ������������ ����
	Public Function GetTypeMD(sTypeName)
		Dim oXmlDoc		' As IXMLDOMDocument - ����� ��������, ��� �������� � XSLT
		Dim oXmlTypeMD	' As IXMLDOMElement - ���� ds:type
		
		Set oXmlTypeMD = X_GetTypeMD(sTypeName)
		Set oXmlDoc = oXmlTypeMD.ownerDocument.cloneNode( false) 
		oXmlDoc.appendChild oXmlTypeMD.CloneNode( true)
		oXmlDoc.SetProperty "SelectionNamespaces", oXmlTypeMD.ownerDocument.GetProperty("SelectionNamespaces")
		oXmlDoc.SetProperty "SelectionLanguage", oXmlTypeMD.ownerDocument.GetProperty("SelectionLanguage")
		Set GetTypeMD = oXmlDoc.documentElement
	End Function
	
	
	'==========================================================================
	' ����������:	Returns the first nonnull expression among its arguments
	' ������� �� ����������� ������� � x-vbs.vbs � ���, ��� ���� ��� ���������� �������� ������, �� ������������ ������ ������
	Public Function nvl(a,b)
		nvl = Coalesce(Array(a,b))
		If IsEmpty(nvl) Then nvl=""
	End Function


	'==========================================================================
	' ���������� ������ � �������������� XML ������� �������� ���������
	'	[in] oNodeList As IXMLNodeList
	'	[retval] As String
	Public Function GetXmlString(oNodeList)
		GetXmlString = ""
		If oNodeList Is Nothing Then Exit Function
		If oNodeList.length = 0 Then Exit Function
		GetXmlString = XService.UrlEncode(oNodeList.item(0).cloneNode(true).xml)
	End Function
End Class


'===============================================================================
'@@GetDataArgsClass
'<GROUP !!CLASSES_x-editor-page><TITLE GetDataArgsClass>
':����������:	����� ���������� ��������� ����� ������ �� ���������� �������.
'
'@@!!MEMBERTYPE_Methods_GetDataArgsClass
'<GROUP GetDataArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_GetDataArgsClass
'<GROUP GetDataArgsClass><TITLE ��������>
Class GetDataArgsClass
	'@@GetDataArgsClass.Reason
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE Reason>
	':����������:	������� �������� ����� ������.
	':����������:	�������� �������� ���� ��������� ���� REASON_nnnn
	'				(��. x-editor.vbs).
	':���������:	Public Reason [As Int]
	Public Reason
	
	'@@GetDataArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE ReturnValue>
	':����������:	������� ��������� ���������� ����� ������ �� ���������
	'				��������. �����:
	'				* True - ��������� ������ ������� ���������;
	'				* False - ������� ����� ������ ���������� �������.
	':��. �����:	GetDataArgsClass.ErrorMessage
	':���������:	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'@@GetDataArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE SilentMode>
	':����������:	������� "������" ������ ����� ������ (��. ���������).
	':����������:
	'	���� � �������� ����� ������ ��������� ������, �� � ����� ������ XPE
	'	�������� ���� ������ ���������� �������� GetDataArgsClass.ReturnValue
	'	� �������� False. �������� ������ ��� ���� ������������ � ErrorMessage.
	'	������ �������� ����� ������ ���������� XPE, ����� ������ ������������ 
	'	����� ���������� ��������.<P/>
	'	��� ���� ���������� ��������, ����� �����-���� ����������� �� ��������� 
	'	(��������, ��� ������� ����� ������ ��������� ���������� �������, 
	'	������������� ��� ������� ���������� �������, ��� ���������� ���������� 
	'	���� ���������� ��� �������� �� ������ ��������).<P/>
	'	�������� SilentMode ��������� ��������� �������� ������ ������ ��������: 
	'	���� �������� ����������� � True, �� ������ ��������� �������� ������ 
	'	����������� ����� �����-���� ���������. ��� ���� ��� ���������� �� ������ 
	'	����� ���� �������� ����� �������� ReturnValue � ErrorMessage.
	':��. �����:	GetDataArgsClass.ReturnValue, GetDataArgsClass.ErrorMessage
	':���������:	Public SilentMode [As Boolean]
	Public SilentMode
	
	'@@GetDataArgsClass.ErrorMessage
	'<GROUP !!MEMBERTYPE_Properties_GetDataArgsClass><TITLE ErrorMessage>
	':����������:	
	'	����� ��������� �� ������, ��������� � ��������� �������� � �������� 
	'	����� ������ (��. ���������).
	':����������:			
	'	�������� �������� ������������� ������� ��������� ������ � ��� ������,
	'	����� �������� GetDataArgsClass.ReturnValue ����������� � �������� False.
	'	� ���� ������ �������� ���������� �������� ����� � ���� ��������� �� ������.
	':���������:	Public ErrorMessage [As String]
	Public ErrorMessage
	
	' ���������� ����� �������������, "�����������"
	Private Sub Class_Initialize
		ReturnValue = True
		SilentMode = False
	End Sub
	
	'@@GetDataArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetDataArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As GetDataArgsClass]
	Public Function Self
		Set Self = Me
	End Function
	
	'@@GetDataArgsClass.Clone
	'<GROUP !!MEMBERTYPE_Methods_GetDataArgsClass><TITLE Clone>
	':����������:	������� ������ ����� ������� ���������� �������.
	':���������:	Public Function Clone() [As GetDataArgsClass]
	Public Function Clone
		Dim o
		Set o = New GetDataArgsClass
		o.ErrorMessage = ErrorMessage
		o.Reason = Reason
		o.ReturnValue = ReturnValue
		o.SilentMode = SilentMode
		Set Clone = o
	End Function
End Class


'===============================================================================
'@@EnableControlsEventArgsClass
'<GROUP !!CLASSES_x-editor-page><TITLE EnableControlsEventArgsClass>
':����������:	
'	����� ���������� ������� "EnableControls", ������������� ���������� ��� 
'	���������� ����� ���������� / ������������� ��������� (��������) ���������.
'
'@@!!MEMBERTYPE_Methods_EnableControlsEventArgsClass
'<GROUP EnableControlsEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_EnableControlsEventArgsClass
'<GROUP EnableControlsEventArgsClass><TITLE ��������>
Class EnableControlsEventArgsClass
	'@@EnableControlsEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EnableControlsEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@EnableControlsEventArgsClass.Enable
	'<GROUP !!MEMBERTYPE_Properties_EnableControlsEventArgsClass><TITLE Enable>
	':����������:	������� ������������� ��������� (��������) ���������:
	'				* True - ���������� ��� ��������� ���������;
	'				* False - ���������� ���������������.
	':���������:	Public Enable [As Boolean]
	Public Enable
	
	'@@EnableControlsEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EnableControlsEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As EnableControlsEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class
