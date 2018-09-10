'===============================================================================
'@@!!FILE_x-pe-object-common
'<GROUP !!SYMREF_VBS>
'<TITLE x-pe-object-common - ������� ���������� ��� ��������� ���������� �������>
':����������:	������� ���������� ��� ��������� ���������� �������.
'===============================================================================
'@@!!CLASSES_x-pe-object-common
'<GROUP !!FILE_x-pe-object-common><TITLE ������>

Option Explicit

'===============================================================================
'@@XPropertyEditorObjectBaseClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE XPropertyEditorObjectBaseClass>
':����������:	
'	"�������" ����� ��� ��������� ���������� �������.<P/>
'   ��������� ������� ������ ��������������� � ��������� ���������� �������.    
'
'@@!!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass
'<GROUP XPropertyEditorObjectBaseClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass
'<GROUP XPropertyEditorObjectBaseClass><TITLE ��������>
Class XPropertyEditorObjectBaseClass

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.EditorPage
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE EditorPage>
	':����������:	
	'	������ �� ��������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public EditorPage [As EditorPageClass]
	Public EditorPage
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectEditor>
	':����������:	
	'	������ �� ��������� ���������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectEditor [As ObjectEditorClass]
	Public ObjectEditor
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.HtmlElement
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE HtmlElement>
	':����������:	
	'	������ �� ������� HTML-�������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public HtmlElement [As IHtmlElement]
	Public HtmlElement
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyMD
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyMD>
	':����������:	
	'	���������� XML-��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public PropertyMD [As XMLDOMElement]
	Public PropertyMD
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE EventEngine>
	':����������:	
	'	��������� EventEngine, ������������ ��� ���������� � ������ ������������ 
	'   �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public EventEngine [As EventEngineClass]
	Public EventEngine
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.XmlPropertyXPath
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE XmlPropertyXPath>
	':����������:	
	'	XPath-������ ��� ��������� �������� � ����. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public XmlPropertyXPath [As String]
	Public XmlPropertyXPath

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectType>
	':����������:	
	'	������������ ���� ������� - ��������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectType [As String]
	Public ObjectType
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ObjectID>
	':����������:	
	'	������������� ������� - ��������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyName
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyName>
	':����������:	
	'	������������ ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public PropertyName [As String]
	Public PropertyName
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.ValueObjectTypeName
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE ValueObjectTypeName>
	':����������:	
	'	������������ ���� ������� �������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ValueObjectTypeName [As String]
	Public ValueObjectTypeName
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyEditorMD
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyEditorMD>
	':����������:	
	'	���������� ��������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public PropertyEditorMD [As XMLDOMElement]
	Public PropertyEditorMD
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE SelectorMetaname>
	':����������:	
	'	������� ���������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SelectorType
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE SelectorType>
	':����������:	
	'	��� ��������� ��� ������. ��������� ��������: "list", "tree".
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public SelectorType [As String]
	Public SelectorType
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.PropertyDescription
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE PropertyDescription>
	':����������:	
	'	�������� �������� � ������� ���������, ������������ � ��������� �� ������ 
	'   ��� ����� ������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public PropertyDescription [As String]
	Public PropertyDescription
	Private m_oParent			' As Object - ������ �� ������������ PropertyEditor ��� �������� � �������
	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE Init>
	':����������:	
	'	������������� ���������� ������ XPropertyEditorObjectBaseClass.
	':���������:
	'	oParentPE - 
	'       [in] �����, ����������� IObjectPropertyEditor, ������������ ������� 
	'       ��������� XPropertyEditorObjectBaseClass.
	'	oEditorPage - 
	'       [in] ��������� ������ EditorPageClass, �� ������� ���������� ��������
	'       ���������� ��������, �������������� ���������� <b><i>oParentPE</b></i>.
	'	oXmlProperty - 
	'       [in] ������������� XML-��������.
	'	oHtmlElement - 
	'       [in] ������� ������� ��������� ��������.
	'	sEvents - 
	'       [in] ������ �������������� �������.
	'	sPEShortName - 
	'       [in] ������� ������������ ��������� ��������.
	':���������:
	'	Sub Init ( 
	'		oParentPE [As Object], 
	'		oEditorPage [As EditorPageClass], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oHtmlElement [As IHTMLDOMElement], 
	'		sEvents [As String], 
	'		sPEShortName [As String] 
	'	)
	Public Sub Init(oParentPE, oEditorPage, oXmlProperty, oHtmlElement, sEvents, sPEShortName)
		Set EventEngine = X_CreateEventEngine
		Set m_oParent		= oParentPE
		Set EditorPage		= oEditorPage
		Set ObjectEditor	= EditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		Set PropertyMD		= ObjectEditor.PropMD(oXmlProperty)
		ValueObjectTypeName = PropertyMD.GetAttribute("ot")
		Set HtmlElement		= oHtmlElement
		PropertyDescription = oHtmlElement.GetAttribute("X_DESCR")
		' ������������ propertyeditor'a, xpath ��� ��� ��������� ����� � �������� Html "PEMetadataLocator" ��������
		Set PropertyEditorMD = PropertyMD.selectSingleNode( HtmlElement.getAttribute("PEMetadataLocator") )
		If Nothing Is PropertyEditorMD Then
			Err.Raise -1, "XPropertyEditorObjectBaseClass::Init", "�� ���������� ���������� ��������� ��������. XPath-������: " & HtmlElement.getAttribute("PEMetadataLocator")
		End If
		' ����������� �������
		If Len("" & sEvents) > 0 Then
			EventEngine.InitHandlers sEvents, "usr_" & ObjectType & "_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & ObjectType & "_" & PropertyName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers sEvents, "usr_" & sPEShortName & "_On"
		End If
		
		' ��������� ��� ��������� � ��� ������/������ �� ��������� ���������� �� xsl � ����������
		SelectorType = "list"
		SelectorMetaname = Null
		If hasValue( HtmlElement.getAttribute("ListSelectorMetaname") ) Then
			SelectorType = "list"
			SelectorMetaname = HtmlElement.getAttribute("ListSelectorMetaname")
		ElseIf hasValue( HtmlElement.getAttribute("TreeSelectorMetaname") ) Then
			SelectorType = "tree"
			SelectorMetaname = HtmlElement.getAttribute("TreeSelectorMetaname")
		End If		
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.XmlProperty
	'<GROUP !!MEMBERTYPE_Properties_XPropertyEditorObjectBaseClass><TITLE XmlProperty>
	':����������:	
	'	XML-������ �������������� ��������. 
	':����������:	
	'	�������� �������� ������ ��� ������.
	':���������:	
	'	Public Property Get XmlProperty [As IXMLDOMElement]
	Public Property Get XmlProperty
		Set XmlProperty = ObjectEditor.XmlObjectPool.selectSingleNode( XmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "�� ������� �������� " & PropertyName & " � xml-�������"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = ObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If
	End Property


	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent EventEngine, sEventName, m_oParent, oEventArgs
	End Sub	


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.SetDirty
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE SetDirty>
	':����������:	
	'	��������� �������� �������� ��� ����������������.
	':���������:
	'	Public Sub SetDirty 
	Public Sub SetDirty
		ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.Dispose
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE Dispose>
	':����������:	
	'	��������� ��������� ������������ ������.
	':���������:
	'	Public Sub Dispose 
	Public Sub Dispose
		Set m_oParent = Nothing
		Set m_oObjectEditor = Nothing
		Set m_oEditorPage = Nothing
	End Sub	

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoSelectFromDb
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoSelectFromDb>
	':����������:	
	'	����������� ���������� ������� <b>DoSelectFromDb</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	':���������:
	'	Public Sub DoSelectFromDb( oValues [As Scripting.Dictionary] ) 
	Public Sub DoSelectFromDb( oValues )
		Dim oDisabler	' ��������� ������-���������� (ControlsDisablerClass)
		With New SelectEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			' ��������� ��� ��������� � ��� �������
			If IsNull(SelectorMetaname) Then
				' � xls �� ������ ���� ��������� use-list-selector/use-tree-selector � ����������� �������� ��� i:object-presentation � ��
				If oValues.Exists("ListSelectorMetaname") Then
					.SelectorType = "list"
					.SelectorMetaname = oValues.Item("ListSelectorMetaname")
				ElseIf oValues.Exists("TreeSelectorMetaname") Then
					.SelectorType = "tree"
					.SelectorMetaname = oValues.Item("TreeSelectorMetaname")
				Else
					' ������ �� ������, ������ ������ ���������� ������
					.SelectorType = "list"
					.SelectorMetaname = vbNullString
				End If
			Else
				.SelectorType = SelectorType
				.SelectorMetaname = SelectorMetaname 
			End If
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ObjectValueType = oValues.Item("ObjectType")

			Set oDisabler = X_CreateControlsDisablerEx(ObjectEditor, m_oParent)
			' 1) ����������� �������� ��������
			FireEvent "BeforeSelect", .Self()
			If .ReturnValue <> True Then Exit Sub
			' 2) �������� UI, �������� ��������� ID
			.Selection = Empty
			FireEvent "Select", .Self()
			' ���� ������ �� �������, ����
			If Not hasValue(.Selection) Then Exit Sub
			.ReturnValue = True
			' 3) ��������� ���������
			FireEvent "ValidateSelection", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "BindSelectedData", .Self()
			Set oDisabler = Nothing

			' 4) ������������
			FireEvent "AfterSelect", .Self()
			
			tryUpdateOtherPE oValues
		End With	
	End Sub	


	'==========================================================================
	' ��������������� ������� �� ���������� ��������� � ������� �����������.
	'	[in] oObjects - ��������� xml-�������� (������ ����������� For Each)
	'	[in] sRestrictions - �����������. ������������������ ���� PropName=PropValue, ����������� ";"
	'	[retval] ������ ��������������� ��������, � ������� ������ ������ ������
	Private Function FilterObjects(oObjects, sRestrictions)
        Dim sRestriction		' ������� �� �������, ����������� ���������� ������ sRestrictions �� ������� ";"
        Dim oObject				' ���� ������ �� ��������� .Objects
        Dim aParts				' ������ (����), ���������� �� ��������� ������ sRestriction �� ������� "="
        Dim sPropName			' ������������ ��������
        Dim sPropValue			' �������� ��������
        Dim oXmlProp			' As IXMLDOMElement - xml-��������
        Dim aFiltredObjects		' ������ �������� �� ��������� .Objects, ��������������� � ������� ����������� (sRestrictions)
        Dim nIndex				' ������ � ������� aFiltredObjects
        
		ReDim aFiltredObjects(oObjects.length - 1)
		nIndex = 0
		For Each oObject In oObjects
			For Each sRestriction In Split(sRestrictions, ";")
				aParts = Split(sRestriction , "=")
				If UBound(aParts) = 1 Then
					sPropName = aParts(0)
					sPropValue = aParts(1)
					Set oXmlProp = oObject.selectSingleNode(sPropName)
					If Not oXmlProp Is Nothing Then
						If oXmlProp.text = sPropValue Then
							Set aFiltredObjects(nIndex) = oObject
							nIndex = nIndex + 1
						End If
					End If
				End If
			Next
		Next
		If nIndex > 0 Then 
			ReDim Preserve aFiltredObjects(nIndex - 1)
			FilterObjects = aFiltredObjects
		Else
			' ������ �� ���������� - �������� ������ ������
			FilterObjects = Array()
		End If
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoSelectFromXml
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoSelectFromXml>
	':����������:	
	'	����������� ���������� ������� <b>DoSelectFromXml</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	':���������:
	'	Public Sub DoSelectFromXml( oValues [As Scripting.Dictionary] ) 
	Public Sub DoSelectFromXml( oValues )
		Dim sQuery          ' ������ �� ��������� �������� (xpath ��� object-path)
		Dim oNav            ' As XmlObjectNavigatorClass
		Dim sPreload        ' ������� preload'��
		Dim oDisabler	    ' ��������� ������-���������� (ControlsDisablerClass)
        Dim sRestrictions	' �������� ��������� "Restrictions"
		
		With New SelectXmlEventArgsClass
			Set .OperationValues = oValues
			' ��������� ��� ��������� � ��� �������
			If IsNull(SelectorMetaname) Then
				' � xls �� ������ ���� ��������� use-list-selector/use-tree-selector � ����������� �������� ��� i:object-presentation � ��
				If oValues.Exists("ListSelectorMetaname") Then
					.SelectorMetaname = oValues.Item("ListSelectorMetaname")
				Else
					' ������ �� ������, ������ ������ ���������� ������
					.SelectorMetaname = vbNullString
				End If
			Else
				.SelectorMetaname = SelectorMetaname 
			End If
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If

			' ���������� ��������� ��������, �� ������� ����� ������������� �����.
			' ������������ ��������� ������������ ���������� Mode ������ ����. ��� ������� ������ ���� ���� �������������� ���������.
            Select Case oValues("Mode")
                Case "ObjectsFromProp"
                    sQuery = oValues("PropPath")
                    If Not hasValue(sQuery) Then
                        Alert "��� �������� DoSelectFromXml � ������ ObjectsFromProp �� ����� ������������ �������� PropPath"
                        Exit Sub
                    End If
                    Set .Objects = ObjectEditor.Pool.GetXmlObjectsByOPath(ObjectEditor.XmlObject, sQuery)
                                        
                    sRestrictions = oValues("Restrictions")
                    If hasValue(.Objects) Then
						If hasValue(sRestrictions) And .Objects.length > 0 Then
							.Objects = FilterObjects(.Objects, sRestrictions)
						End If
                    End If
                Case "ObjectsFromPool"
                    sQuery = oValues("XPath")
                    If Not hasValue(sQuery) Then
                        Alert "��� �������� DoSelectFromXml � ������ ObjectsFromPool �� ����� ������������ �������� XPath"
                        Exit Sub
                    End If
                    Set .Objects = ObjectEditor.Pool.Xml.selectNodes(sQuery)
                Case "ObjectsFromXPathNavigator"
                    Set oNav = ObjectEditor.CreateXmlObjectNavigatorFor(ObjectEditor.XmlObject)
                    sQuery = oValues("XPath")
                    If Not hasValue(sQuery) Then
                        Alert "��� �������� DoSelectFromXml � ������ ObjectsFromXPathNavigator �� ����� ������������ �������� XPath"
                        Exit Sub
                    End If
		            For Each sPreload In Split(oValues("Preloads"), ";")
			            oNav.ExpandProperty sPreload 
		            Next
		            Set .Objects = oNav.SelectNodes(sQuery)
            End Select
			.ReturnValue = True
            .ObjectValueType = oValues.Item("ObjectType")
            
			Set oDisabler = X_CreateControlsDisablerEx(ObjectEditor, m_oParent)			
			' 1) ����������� �������� ��������
			FireEvent "BeforeSelectXml", .Self()
			If .ReturnValue <> True Then Exit Sub
			' 2) �������� UI, �������� ��������� ID
			.Selection = Empty
			FireEvent "SelectXml", .Self()
			' ���� ������ �� �������, ����
			If Not hasValue(.Selection) Then Exit Sub
			.ReturnValue = True
			' 3) ��������� ���������
			FireEvent "ValidateSelection", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "BindSelectedData", .Self()
			Set oDisabler = Nothing
			
			' 4) ������������
			FireEvent "AfterSelectXml", .Self()
			
			tryUpdateOtherPE oValues
		End With	
	End Sub	


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoCreate
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoCreate>
	':����������:	
	'	����������� ���������� ������ <b>DoCreate</b> � <b>DoCreateAndSave</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	'	bSeparateTransaction - 
	'       [in] ������� ���������� �������� � ��������� ����������. 
	':���������:
	'	Public Sub DoCreate( 
	'       oValues [As Scripting.Dictionary], 
	'       bSeparateTransaction [As Boolean]
	'   ) 
	Public Sub DoCreate(oValues, bSeparateTransaction)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForCreating")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = bSeparateTransaction
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			.ReturnValue = True
			FireEvent "BeforeCreate", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Create", .Self()
			' � ����������� "Create" � ReturnValue ���������� ObjectID ���������� �������, ���� �������� ��� ������ �� ��
			If Not hasValue(.ReturnValue) Then Exit Sub
			FireEvent "AfterCreate", .Self()
			
			tryUpdateOtherPE oValues
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoEdit
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoEdit>
	':����������:	
	'	����������� ���������� ������� <b>DoEdit</b> � <b>DoEditAndSave</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	'	bSeparateTransaction - 
	'       [in] ������� ���������� �������� � ��������� ����������. 
	':���������:
	'	Public Sub DoEdit( 
	'       oValues [As Scripting.Dictionary], 
	'       bSeparateTransaction [As Boolean]
	'   ) 
	Public Sub DoEdit(oValues, bSeparateTransaction)
		With New OpenEditorEventArgsClass
			Set .OperationValues = oValues
			.Metaname = HtmlElement.GetAttribute("EditorMetanameForEditing")
			If Not hasValue(.Metaname) And oValues.Exists("Metaname") Then
				.Metaname = oValues.Item("Metaname")
			End If
			.IsSeparateTransaction = bSeparateTransaction
			If oValues.Exists("UrlParams") Then
				.UrlArguments = oValues.Item("UrlParams")
			End If
			
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			FireEvent "BeforeEdit", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Edit", .Self()
			' � ����������� "Edit" � ReturnValue ���������� ObjectID ������������������ �������, ���� �������� ��� ������ �� ��
			If Not hasValue(.ReturnValue) Then Exit Sub
			FireEvent "AfterEdit", .Self()

			tryUpdateOtherPE oValues
		End With
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoMarkDelete
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoMarkDelete>
	':����������:	
	'	����������� ���������� ������� <b>DoMarkDelete</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	':���������:
	'	Public Sub DoMarkDelete( oValues [As Scripting.Dictionary] ) 
	Public Sub DoMarkDelete( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			If oValues.Exists("Prompt") Then
				.Prompt = oValues.Item("Prompt")
			Else
				.Prompt = "�� ������������� ������ ������� ������?"
			End If
			FireEvent "BeforeMarkDelete", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "MarkDelete", .Self()
			FireEvent "AfterMarkDelete", .Self()
			tryUpdateOtherPE oValues
		End With	
	End Sub


	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoUnlink
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoUnlink>
	':����������:	
	'	����������� ���������� ������� <b>DoUnlink</b>.
	':���������:
	'	oValue - 
	'       [in] ��������� ���������� �������� ����. 
	':���������:
	'	Public Sub DoUnlink( oValues [As Scripting.Dictionary] ) 
	Public Sub DoUnlink( oValues )
		With New OperationEventArgsClass
			Set .OperationValues = oValues
			.ReturnValue = True
			.ObjectID = oValues.Item("ObjectID")
			If oValues.Exists("Prompt") Then
				.Prompt = oValues.Item("Prompt")
			Else
				.Prompt = "�� ������������� ������ ������� ������?"
			End If
			FireEvent "BeforeUnlink", .Self()
			If .ReturnValue <> True Then Exit Sub
			FireEvent "Unlink", .Self()
			FireEvent "AfterUnlink", .Self()
			tryUpdateOtherPE oValues
		End With	
	End Sub

	'------------------------------------------------------------------------------
	'@@XPropertyEditorObjectBaseClass.DoUnlinkImplementation
	'<GROUP !!MEMBERTYPE_Methods_XPropertyEditorObjectBaseClass><TITLE DoUnlinkImplementation>
	':����������:	
	'	������� ��������� �������� "��������� �����" (<b>DoUnlink</b>) ��� �������
	'   XPEObjectPresentationClass � XPEObjectsElementsListClass.
	':���������:
	'	oXmlProperty - 
	'       [in] XML-��������, �� �������� ��������� ������.
	'	oXmlValueObject - 
	'       [in] ������-�������� ��������.
	':���������:
	'	���������� True ��� �������� �������� ������ � False � ��������� ������.
	':���������:
	'	Public Function DoUnlinkImplementation ( 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oXmlValueObject [As IXMLDOMElement] 
	'	) [As Boolean]
	Public Function DoUnlinkImplementation(oXmlProperty, ByVal oXmlValueObject)
		Dim bIsNew				' As Boolean - ������� ������ �������
		Dim oAllReferences		' As ObjectArrayListClass - ������ ���� ������ �� ��������� �������
		Dim oNotNullReferences	' As ObjectArrayListClass - ������ ������ �� ��������� ������� �� ������������ �������
		Dim oObjectsToDelete	' As ObjectArrayListClass - ������ ������ �� ������� � ����, ������� ���� �������� ��� ���������

		' ����������� ������-�������� ��� ��������� �� xml-������ � ����		
		Set oXmlValueObject = ObjectEditor.Pool.GetXmlObjectByXmlElement(oXmlValueObject, Null)
		bIsNew = Not IsNull(oXmlValueObject.getAttribute("new"))
		DoUnlinkImplementation = False
		If Not bIsNew Then
			ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlValueObject
		Else
			' ������� ������ �� ����� ������...
			' ������ ������ �� ������-��������
			Set oAllReferences = New ObjectArrayListClass
			Set oNotNullReferences = New ObjectArrayListClass
			Set oObjectsToDelete = New ObjectArrayListClass
			ObjectEditor.Pool.CheckReferences oXmlValueObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, Nothing
			If oAllReferences.Count>1 Then
				ObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlValueObject
			Else
				' �������� ��������
				ObjectEditor.Pool.Internal_DoMarkObjectAsDeleted oAllReferences, oObjectsToDelete
			End If
		End If
		DoUnlinkImplementation = True
	End Function

	
	'==============================================================================
	' ��������� ��������� ������� ��� �������, ������������ ������� ������������ � ��������� UpdatePE
	'	[in] oValues As Scripting.Duictionary - ������� ���������� �������� ����. ������������ �������� "UpdatePE"
	Private Sub tryUpdateOtherPE(oValues)
		If oValues.Exists("UpdatePE") Then
			Dim sProps				' ������ ������� ��� ���������� PE
			Dim sProp				' ������������ ��������
			Dim oXmlProp			' As XmlElement - xml-��������
			Dim aPropertyEditors	' As Array - ������ ���������� ������� ��� ������ ��������
			Dim i
			
			sProps = oValues.Item("UpdatePE")
			If hasValue(sProps) Then
				If sProps = "*" Then
					' �������� ��� ��������� ��������
					For Each aPropertyEditors In EditorPage.PropertyEditors.Items()
						For i=0 To UBound(aPropertyEditors)
							' ���� �������� ������� �� ������� 
							If Not aPropertyEditors(i) Is m_oParent Then
								aPropertyEditors(i).SetData
							End If
						Next
					Next
				Else
					For Each sProp In Split(sProps, ";")
						Set oXmlProp = ObjectEditor.XmlObject.selectSingleNode(sProp)
						If Not oXmlProp Is Nothing Then
							aPropertyEditors = EditorPage.GetPropertyEditors(oXmlProp)
							If IsArray(aPropertyEditors) Then
								For i=0 To UBound(aPropertyEditors)
									aPropertyEditors(i).SetData
								Next
							End If
						End If     
					Next
				End If
			End If
		End If
	End Sub	
End Class


'===============================================================================
'@@SelectEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE SelectEventArgsClass>
':����������:	
'	��������� ������� ������ ������� - �������� ��������.
'
'@@!!MEMBERTYPE_Methods_SelectEventArgsClass
'<GROUP SelectEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SelectEventArgsClass
'<GROUP SelectEventArgsClass><TITLE ��������>
Class SelectEventArgsClass

	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE SelectorMetaname>
	':����������:	
	'	���������������� ������ ��� ������, ������������� ��� ������ �������-��������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.SelectorType
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE SelectorType>
	':����������:	
	'	��� ��������� (������/������), ������� ������ ����� � �������� 
	'   <LINK SelectEventArgsClass.SelectorMetaname, SelectorMetaname />. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public SelectorType [As String]
	Public SelectorType
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	�������� �������� �� ������ �����������. ��� ������������� False ��������� 
	'   ������� �������, ������������ ������������ �������� ���� (��������, 
	'   BeforeSelect, Select, AfterSelect). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE UrlArguments>
	':����������:	
	'	��������� URL ��������, ����������� ��� ������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE OperationValues>
	':����������:	
	'	��������� ����������, ��������� � ��������� (action), ��������� �� ������ 
	'   ���� (�� ���� - ������ �� ��������� Values ����). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE Selection>
	':����������:	
	'	������ �� ������� ��������������� ��������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Selection [As String]
	Public Selection
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.ObjectValueType
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE ObjectValueType>
	':����������:	
	'	��� ���������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectValueType [As String]
	Public ObjectValueType
	
	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SelectEventArgsClass><TITLE Cancel>
	':����������:	
	'	���������� ������� ������������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cancel [As Boolean]
	Public Cancel

	'------------------------------------------------------------------------------
	'@@SelectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������ SelectEventArgsClass.
	':���������:
	'	Public Function Self() [As SelectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function	
End Class


'===============================================================================
'@@SelectXmlEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE SelectXmlEventArgsClass>
':����������:	
'	��������� ������� SelectXml ������ �������-�������� �� ��������� 
'   (��������� x-select-from-xml.aspx). 
'
'@@!!MEMBERTYPE_Methods_SelectXmlEventArgsClass
'<GROUP SelectXmlEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SelectXmlEventArgsClass
'<GROUP SelectXmlEventArgsClass><TITLE ��������>
Class SelectXmlEventArgsClass

	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Objects
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Objects>
	':����������:	
	'	��������� �������� ��� ������ (������ ������������ 
	'   For Each: Array, IXMLDOMNodeList). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Objects [As ICollection]
    Public Objects
    
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.SelectorMetaname
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE SelectorMetaname>
	':����������:	
	'	���������������� ������, ������������� ��� ������ �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public SelectorMetaname [As String]
	Public SelectorMetaname
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	�������� �������� �� ������ �����������. ��� ������������� False ��������� 
	'   ������� �������, ������������ ������������ �������� ���� (��������, 
	'   BeforeSelectXml, SelectXml, AfterSelectXml). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE UrlArguments>
	':����������:	
	'	��������� URL ��������, ����������� ��� ������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE OperationValues>
	':����������:	
	'	��������� ����������, ��������� � ��������� (action), ��������� �� ������ 
	'   ���� (�� ���� - ������ �� ��������� Values ����). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Selection
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Selection>
	':����������:	
	'	������ �� ������� ��������������� ��������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Selection [As String]
	Public Selection
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.ObjectValueType
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE ObjectValueType>
	':����������:	
	'	��� ���������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectValueType [As String]
	Public ObjectValueType
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SelectXmlEventArgsClass><TITLE Cancel>
	':����������:	
	'	���������� ������� ������������ ������ �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@SelectXmlEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SelectXmlEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������ SelectXmlEventArgsClass.
	':���������:
	'	Public Function Self() [As SelectXmlEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function	
End Class


'===============================================================================
'@@OpenEditorEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE OpenEditorEventArgsClass>
':����������:	
'	��������� ������� BeforeCreate, Create, AfterCreate, BeforeEdit, Edit, AfterEdit.
'
'@@!!MEMBERTYPE_Methods_OpenEditorEventArgsClass
'<GROUP OpenEditorEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_OpenEditorEventArgsClass
'<GROUP OpenEditorEventArgsClass><TITLE ��������>
Class OpenEditorEventArgsClass

	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE OperationValues>
	':����������:	
	'	��������� ���������� ��������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE Metaname>
	':����������:	
	'	������� ���������/�������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Metaname [As String]
	Public Metaname
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.IsSeparateTransaction
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE IsSeparateTransaction>
	':����������:	
	'	������� ���������� �������� � ��������� ����������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public IsSeparateTransaction [As Boolean]
	Public IsSeparateTransaction
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.UrlArguments
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE UrlArguments>
	':����������:	
	'	���������, ������������ � �������� ����� URL ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public UrlArguments [As String]
	Public UrlArguments
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE ObjectID>
	':����������:	
	'	������������� ������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	��� ������� BeforeCreate � BeforeEdit ��� ������� �������� False ��������� 
	'   ������� �������, ������������ ������������ ��������. ����� �������, 
	'   ����������� ��������� ������� Create � Edit. ��� ��������� ������� ��������
	'   �������� ������������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_OpenEditorEventArgsClass><TITLE Cancel>
	':����������:	
	'	���������� ������� ������������ ��� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@OpenEditorEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_OpenEditorEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������ OpenEditorEventArgsClass.
	':���������:
	'	Public Function Self() [As OpenEditorEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class

'===============================================================================
'@@OperationEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE OperationEventArgsClass>
':����������:	
'	��������� ��������� �������, ��������� � ��������� ����.
'
'@@!!MEMBERTYPE_Methods_OperationEventArgsClass
'<GROUP OperationEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_OperationEventArgsClass
'<GROUP OperationEventArgsClass><TITLE ��������>
Class OperationEventArgsClass

	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.OperationValues
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE OperationValues>
	':����������:	
	'	��������� ���������� ��������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public OperationValues [As Scripting.Dictionary]
	Public OperationValues
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	��� ������� BeforeCreate � BeforeEdit ��� ������� �������� False ��������� 
	'   ������� �������, ������������ ������������ ��������. ����� �������, 
	'   ����������� ��������� ������� Create � Edit. ��� ��������� ������� ��������
	'   �������� ������������.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE Cancel>
	':����������:	
	'	���������� ������� ������������ ��� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE ObjectID>
	':����������:	
	'	������������� ������� ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ObjectID [As String]
	Public ObjectID
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Prompt
	'<GROUP !!MEMBERTYPE_Properties_OperationEventArgsClass><TITLE Prompt>
	':����������:	
	'	�����������/������ ������������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Prompt [As String]
	Public Prompt
	
	'------------------------------------------------------------------------------
	'@@OperationEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_OperationEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������ OperationEventArgsClass.
	':���������:
	'	Public Function Self() [As OperationEventArgsClass]
	Public Function Self()
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@LoadListEventArgsClass
'<GROUP !!CLASSES_x-pe-object-common><TITLE LoadListEventArgsClass>
':����������:	
'	��������� ������� <b>LoadList</b>. 
'
'@@!!MEMBERTYPE_Methods_LoadListEventArgsClass
'<GROUP LoadListEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_LoadListEventArgsClass
'<GROUP LoadListEventArgsClass><TITLE ��������>
Class LoadListEventArgsClass

	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Cancel>
	':����������:	
	'	������� ������ ��� ������� ������������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cancel [As Boolean]
	Public Cancel
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Restrictions
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Restrictions>
	':����������:	
	'	��������� ��� ���������� ������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Restrictions [As GetRestrictionsEventArgsClass]
	Public Restrictions
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.TypeName
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE TypeName>
	':����������:	
	'	������������ ����, � ������� �������� ������ � ������ 
	'   <LINK LoadListEventArgsClass.ListMetaname, ListMetaname />. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public TypeName [As String]
	Public TypeName
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.ListMetaname
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE ListMetaname>
	':����������:	
	'	������� ������ ��������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ListMetaname [As String]
	Public ListMetaname
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.RequiredValues
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE RequiredValues>
	':����������:	
	'	������ ���������������, ������� ������ �������������� � ������ (�������� 
	'   <b><i>VALUEOBJECTID</b></i> ��� ��������� ������). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public RequiredValues [As String]
	Public RequiredValues
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Cache
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE Cache>
	':����������:	
	'	����� ����������� ������ ������ (��������� 
	'   <LINK CACHE_BEHAVIOR_nnnn, CACHE_BEHAVIOR_nnnn />). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Cache [As Int]
	Public Cache
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.CacheSalt
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE CacheSalt>
	':����������:	
	'	������ � ������� VBS-���������. ���� �������� �������, �� ��� 
	'   ������������ ��� �������������� ���� ��� ������������ �������� ����. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.<P/>
	'   <b><i>������:</b></i><P/>
	'   c�che-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - ������ ���� 
	'   ���������� ����������������� ��� ����� ����������.<P/>
	'	c�che-salt="clng(date())" - ������ ���� ���������� ����������������� 
	'   ��� � �����.<P/>
	'	c�che-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; 
	'   &amp; clng(date())" - ������ ���� ���������� ����������������� ��� � ����� 
	'   ��� ��� ����� ����������.<P/>
    '	c�che-salt="MyVbsFunctionName()" - ���������� ���������� �������.
	':���������:	
	'	Public CacheSalt [As String]
	Public CacheSalt

	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.HasMoreRows
	'<GROUP !!MEMBERTYPE_Properties_LoadListEventArgsClass><TITLE HasMoreRows>
	':����������:	
	'	������� ����, ��� ��� �������� ������ ��������� ����������� �� ������������ 
	'   ���������� ������� (MAXROWS). 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public HasMoreRows [As Boolean]
	Public HasMoreRows
	
	'------------------------------------------------------------------------------
	'@@LoadListEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_LoadListEventArgsClass><TITLE Self>
	':����������:	
	'	������� ���������� ������ �� ������� ��������� ������ LoadListEventArgsClass.
	':���������:
	'	Public Function Self() [As LoadListEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'==============================================================================
' ��������� ������� "Load" ��� TreeView
Class LoadTreeEventArgsClass
	Public Cancel				' ������� ������ ��� ������� ������������. 
	Public Restrictions			' ��������� ��� ���������� ������ - ��������� GetRestrictionsEventArgsClass
	Public Metaname				' ������� ���������� ������
	
	Public Function Self
		Set Self = Me
	End Function
End Class
