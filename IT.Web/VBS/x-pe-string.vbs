'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ����������
'				���������� �������� (��� �������� vt: string)
'*******************************************************************************

Option Explicit

' ����� ����� ��� ������ ������ ����� ������ ��� ��������� "�����" ��������� textarea

'==============================================================================
Class XPEStringLookupClass
	Private m_oPropertyEditorBase	' As XPropertyEditorBaseClass
	Private m_oRefreshButton		' As IHTMLElement - ������ �������� ���������� ����
	Private m_bUseCache				' As Boolean - ������� ������������� ���� ��� �������� ������ � ������� (�� ��������� �� ������������)
	Private m_sCacheSalt			' As String - ��������� �� VBS, ���� ������ �� ������������ ��� �������������� ���� ��� ������������ �������� ����
									'	������:
									'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;)" - ������ ���� ���������� ����������������� ��� ����� ����������
									'	cache-salt="clng(date())" - ������ ���� ���������� ����������������� ��� � �����
									'	cache-salt="X_GetMD().GetAttribute(&quot;md5&quot;) &amp; &quot;-&quot; &amp; clng(date())" - ������ ���� ���������� ����������������� ��� � ����� ��� ��� ����� ����������
									'	cache-salt="MyVbsFunctionName()" - ���������� ���������� �������
	Private m_bDisableGetData		' As Boolean - ������� ���������� ����� ������
	Private m_bKeyUpEventProcessing	' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����

	
	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "LoadList,GetRestrictions,Accel", "StringLookup"
		m_oPropertyEditorBase.EventEngine.AddHandlerForEvent "LoadList", Me, "OnLoadList"
		
		' ���� ������� ������ �������� ������������ � ���� ��������� �����������: 
		Set m_oRefreshButton = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all( HtmlElement.GetAttribute("RefreshButtonID"), 0 ) 
		m_bUseCache = "" & HtmlElement.getAttribute("UseCache") = "1"
		m_sCacheSalt = "" & HtmlElement.getAttribute("CacheSalt")		
		m_bDisableGetData = False
		ViewInitialize
	End Sub
	
	
	'==========================================================================
	' ������� ��� 
	' [in] bOnlyForCurrentRestrictions - ������� ������� �� ���� ��� ������
	'		� ������ ��� ��� ������� �����������, 
	'		���������� � ���������� ���������� ����������� ������� GetRestrictions
	Public Sub ClearCache(bOnlyForCurrentRestrictions)
		Dim oSelectorRestrictions	' �������� ������� GetRestrictions
		Dim vRestrictions			' ���������������� �����������
		
		If Not m_bUseCache Then Exit Sub
		
		vRestrictions = Null
		If bOnlyForCurrentRestrictions Then
			Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
			FireEvent "GetRestrictions", oSelectorRestrictions
			vRestrictions = X_CreateCommonRestrictions(oSelectorRestrictions.ReturnValue,oSelectorRestrictions.UrlParams,Null)
		End If
		X_ClearListDataCache m_oPropertyEditorBase.HtmlElement.getAttribute("TypeName"), m_oPropertyEditorBase.HtmlElement.getAttribute("ListMetaname"), vRestrictions
	End Sub


	'==========================================================================
	' ���������� ��������� ObjectEditorClass - ���������,
	' � ������ �������� �������� ������ �������� ��������
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oPropertyEditorBase.ObjectEditor
	End Property


	'==========================================================================
	' ���������� ��������� EditorPageClass - �������� ���������,
	' �� ������� ����������� ������ �������� ��������
	Public Property Get ParentPage
		Set ParentPage = m_oPropertyEditorBase.EditorPage
	End Property


	'==========================================================================
	' ���������� ���������� ��������
	'	[retval] As IXMLDOMElement - ���� ds:prop
	Public Property Get PropertyMD
		Set PropertyMD = m_oPropertyEditorBase.PropertyMD
	End Property


	'==========================================================================
	' ���������� ��������� EventEngineClass - �������, ���������������
	' ���������� ������ ��� ������� ��������� ��������
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property


	'==========================================================================
	' ���������� �������������� �������� �� Xml-��������
	Public Property Get Value
		Value = XmlProperty.nodeTypedValue
	End Property

	
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		Dim vHtmlValuePrev		' ���������� �������� � html
		
		vHtmlValuePrev = HtmlElement.value
		HtmlElement.value = vValue
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
			If .ReturnValue = False Then
				HtmlElement.value = vHtmlValuePrev
			End If
		End With
	End Property


	'==========================================================================
	' ���������� �������������� �������� �� input'a
	Public Property Get RawValue
		RawValue = HtmlElement.value
	End Property

	
	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		Dim oCrocComboBox		' As Croc.IXComboBox
		Dim vValue				' As String - ������� ��������
		
		Set oCrocComboBox = m_oPropertyEditorBase.HtmlElement
		vValue = XmlProperty.nodeTypedValue
		If EventEngine.IsHandlerExists("BeforeSetData") Then
			With New BeforeSetDataEventArgsClass
				.CurrentValue = vValue 
				FireEvent "BeforeSetData", .Self()
				' ���� ���������� ���������� ������� ��������, �� ������� �������� � ����
				If .CurrentValue <> vValue Then
					vValue = .CurrentValue
					XmlProperty.nodeTypedValue = vValue 
				End If
			End With
		End If
		
		' ������� ��������
		If oCrocComboBox.Editable Then
			oCrocComboBox.text	= vbNullString & vValue
		Else 
			oCrocComboBox.value = vbNullString & vValue
			
			If Not ObjectEditor.SkipInitErrorAlerts Then
				If oCrocComboBox.value <> vValue Then
					If .HasMoreRows Then
						' �������� �� ������������ � ������� �������� ������, ��� ����� ��
						ParentPage.EnablePropertyEditor Me, False
						m_bDisableGetData = True
						MsgBox "��������! �������� ��������� """ & PropertyDescription & """ �� ����� ���� ���������� ���������, " & vbCr & _
							"�.�. ���������� ������ �������� � ������� ��� ��������� �������� �� ������������ ���������� �����.", vbExclamation
					Else
						MsgBox _
							"��������! ��������� ����� �������� ��������� """ & PropertyDescription & """ ����� �� ����������; ��������, ��� ����" & vbCrLf & _
							"������� ��� �������� ������ �������������. �������� �������� ����� ��������." & vbCrLf & _
							"����������, �������� ����� ��������.", vbExclamation, "�������� - ��������� ������"
						' ������� �������� ��������, �������� combobox'a ��� ��������
						XmlProperty.nodeTypedValue = ""
					End If
				End If
			End If
		End If		
	End Sub


	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		Dim vHtmlValue		' �������� � Html
		
		If m_bDisableGetData Then Exit Sub
		vHtmlValue = HtmlElement.value
		' ��������� �� NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( vHtmlValue, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' ��������� �� ������������ ������:
		If Not ValueCheckRangeForPropertyEditor(vHtmlValue, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' �������� ���������� �������
		If Not CheckOnInvalidCharacters(vHtmlValue, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' �������� ���������� ���������
		If Not CheckOnPatternMatch(vHtmlValue, Me, oGetDataArgs) Then Exit Sub
		' ������ �������� � XML:
		GetDataFromPropertyEditor vHtmlValue, m_oPropertyEditorBase, oGetDataArgs
	End Sub

	
	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-string-lookup-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-string-lookup-field"
		End If			
	End Property

	
	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = HtmlElement.object.Enabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.object.Enabled = bEnabled
		' �� ������� ��� ������ �������� ���������� ����:
		If Not IsNothing(RefreshButton) Then RefreshButton.disabled = Not( bEnabled )
	End Property

	
	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function

	
	'==========================================================================
	' ���������� Html �������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property


	'==========================================================================
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property


	'==========================================================================
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	


	'==========================================================================
	' ��������� ���� ������ � PE
	Public Sub DisableGetData
		m_bDisableGetData = True
	End Sub


	'==========================================================================
	' �������� ������� ���� ������ � PE
	Public Sub EnableGetData
		m_bDisableGetData = False
	End Sub

	
	'==========================================================================
	' ���������� HTML-������� ������ ���������� ������
	Public Property Get RefreshButton
		Set RefreshButton = m_oRefreshButton
	End Property


	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' ��������� ������������ �������� ������ ��������, 
	' � ������������ � �������� ���� ����������� ������������� �������.
	Private Sub ViewInitialize( )
		' ��������� ������������� ������ �������� (�������� � HTML, ���� ������������
		' use-cache � ��� off-reload:
		If RefreshButton Is Nothing Then Exit Sub
		' ������������ �������� ������ �������� ����������� �� ��������� � ��������
		' ���� ����������� ������������� �������: �������� ������ �� �����. HTML-�������
		With RefreshButton 
			.style.height = HtmlElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
	End Sub


	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		Load False, XmlProperty.nodeTypedValue
	End Sub

	
	'==========================================================================
	' ��������� ������
	'	[in] bOverwriteCache - ������� ������ �������������� ��������
	'	[in] vValue - ��������� ��������, ��������������� � ����������
	Public Sub Load(bOverwriteCache, vValue)
		Dim oSelectorRestrictions	' As GetRestrictionsEventArgsClass
		
		Set oSelectorRestrictions = new GetRestrictionsEventArgsClass
		FireEvent "GetRestrictions", oSelectorRestrictions

		With New LoadListEventArgsClass
			.TypeName = m_oPropertyEditorBase.HtmlElement.getAttribute("TypeName")
			.ListMetaname = m_oPropertyEditorBase.HtmlElement.getAttribute("ListMetaname")
			.RequiredValues = vValue
			if Not UseCache then
				.Cache = CACHE_BEHAVIOR_NOT_USE
			elseif bOverwriteCache then
				.Cache = CACHE_BEHAVIOR_ONLY_WRITE
			else
				.Cache = CACHE_BEHAVIOR_USE
			end if	
			.CacheSalt = CacheSalt
			Set .Restrictions = oSelectorRestrictions
			FireEvent "LoadList", .Self()
		End With
	End Sub


	'==========================================================================
	' ���������� ������, �������� �����������
	Public Sub ReLoad
		Load True, Value
		SetData
	End Sub

	
	'==========================================================================
	' ����������� ���������� ������� "LoadList"
	'	[in] oEventArgs As LoadListEventArgsClass
	Public Sub OnLoadList(oSender, oEventArgs)
		Dim sUrlParams			' ��������� � �������� ��������� ������
		Dim sRestrictions		' ��������� � ������ �� �������� ������������
		Dim aErr				' As Array - ���� ������� Err
		Dim oCrocComboBox		'
		Dim vValue 
		Set oCrocComboBox = m_oPropertyEditorBase.HtmlElement

		With oEventArgs
			' ������� �����������
			If Not IsNothing(.Restrictions) Then
				sUrlParams = .Restrictions.UrlParams
				sRestrictions =  .Restrictions.ReturnValue
			End If
			' � ������� �� �������� ������� � RequiredValues ����� ������� � �� �������������
			'	������� � ��������� ���������� �� �����������
			vValue = .RequiredValues
			.RequiredValues = Empty
			' ������� ������� ��������
			oCrocComboBox.Clear
			' �������� ������ (����������� � ������ ���������� �������� � X_Load*ComboBox)
			On Error Resume Next
			' ���������� ���������
			.HasMoreRows = X_LoadActiveXComboBoxUseCache( .Cache, oCrocComboBox, .TypeName, .ListMetaname, sRestrictions, sUrlParams, .RequiredValues, .CacheSalt )
			If Err Then
				X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
				With X_GetLastError
					If .IsServerError Then
						On Error Goto 0
						' �� ������� ��������� ������
						If .IsSecurityException Then
							' ��������� ������ ��� ������ ��������
							ClearComboBox
							Enabled = False
						Else
							.Show
						End If
					Else
						' ������ ��������� �� ������� - ��� ������ � XFW
						aErr = Array(Err.Number, Err.Source, Err.Description)
						On Error Goto 0
						Err.Raise aErr(0), aErr(1), aErr(2)				
					End If
				End With
				Exit Sub
			End If
		End With
	End Sub
	
	
	'==========================================================================
	' ����������/������������� ������� ����������� 
	' ��. i:string-lookup/@use-cache
	Public Property Get UseCache
		UseCache = (m_bUseCache=True)
	End Property
	Public Property Let UseCache(vValue)
		m_bUseCache = (vValue=True)
	End Property

	
	'==========================================================================
	' ����������/������������� �������� �����������
	' ��. i:string-lookup/@cache-salt
	Public Property Get CacheSalt
		CacheSalt = m_sCacheSalt
	End Property
	Public Property Let CacheSalt(vValue)
		m_sCacheSalt = vValue
	End Property

	'==========================================================================
	' ���������� ���������� ��������� ��� �������� ��������
	Public Property Get RegExpPattern
		RegExpPattern = "" & HtmlElement.getAttribute("RegExpPattern")
	End Property

	'==========================================================================
	' ���������� ��������� � �������������� �������� ����������� ���������
	Public Property Get RegExpPatternMismatchMessage
		RegExpPatternMismatchMessage = "" & HtmlElement.getAttribute("RegExpPatternMsg")
	End Property	
	

	'==========================================================================
	' ���������� ActiveX-������� onKeyUp (������� �������). ����������� ��������� �� �������� 
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUpAsync(ByVal nKeyCode, ByVal nFlags)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		' �������� ����������� ���������� ��� ��������� �����
		If checkTextSpecificHotkeys(nKeyCode, CBool(nFlags and KF_ALTLTMASK), CBool(nFlags and KF_CTRLMASK), CBool(nFlags and KF_SHIFTMASK)) Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ��������� ������� ���������� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub
End Class


'==============================================================================
'
'==============================================================================
Class XPEStringClass
	Private m_oPropertyEditorBase		' As XPropertyEditorBaseClass
	Private m_bIsSmart
	Private m_nMinH						' ����������� ������ ������ �������� � ��������
	Private m_nMaxH						' ������������ ������ ������ �������� � ��������
	Private m_bKeyUpEventProcessing		' As Boolean - ������� ��������� ActiveX-������� OnKeyUp ��� �������������� ������������ �����

	'==========================================================================
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		m_bKeyUpEventProcessing = False
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel", "String"
		m_bIsSmart = Not IsNull(HtmlElement.GetAttribute("X_IS_SMART"))
		If Not m_bIsSmart  Then Exit Sub
		' �������������� "�����" TEXTAREA
		initSmartTextArea()
	End Sub

	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� ������������� ���� PE �� ��������
	Public Sub FillData()
		' Nothing to do...
	End Sub


	'==========================================================================
	' ���������� ��������� ObjectEditorClass - ���������,
	' � ������ �������� �������� ������ �������� ��������
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oPropertyEditorBase.ObjectEditor
	End Property
	
	
	'==========================================================================
	' ���������� ��������� EditorPageClass - �������� ���������,
	' �� ������� ����������� ������ �������� ��������
	Public Property Get ParentPage
		Set ParentPage = m_oPropertyEditorBase.EditorPage
	End Property
	
	
	'==========================================================================
	' ���������� ��������� EventEngineClass - �������, ���������������
	' ���������� ������ ��� ������� ��������� ��������
	Public Property Get EventEngine
		Set EventEngine = m_oPropertyEditorBase.EventEngine
	End Property


	'==========================================================================
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.XmlProperty
	End Property
	
	
	'==========================================================================
	' ���������� �������������� �������� �� input'a
	Public Property Get Value
		Value = HtmlElement.value
	End Property
	
	
	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		HtmlElement.value = vValue
		If m_bIsSmart Then Internal_SmartTextAreaOnAdjustSize
		With New GetDataArgsClass
			.SilentMode = True
			GetData .Self
		End With
	End Property

	
	'==========================================================================
	' ������������� �������� � ��������� ��������
	Public Sub SetData
		HtmlElement.value = XmlProperty.nodeTypedValue
		If m_bIsSmart Then Internal_SmartTextAreaOnAdjustSize
	End Sub

	
	'==========================================================================
	' ���� � ��������� ������
	Public Sub GetData(oGetDataArgs)
		' ��������� �� NOT NULL: 
		If Not ValueCheckOnNullForPropertyEditor( Value, m_oPropertyEditorBase, oGetDataArgs, Mandatory) Then Exit Sub
		' ��������� �� ������������ ������:
		If Not ValueCheckRangeForPropertyEditor(Value, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' �������� ���������� �������
		If Not CheckOnInvalidCharacters(Value, m_oPropertyEditorBase, oGetDataArgs) Then Exit Sub
		' �������� ���������� ���������
		If Not CheckOnPatternMatch(Value, Me, oGetDataArgs) Then Exit Sub
		' ������ �������� � XML:
		GetDataFromPropertyEditor Value, m_oPropertyEditorBase, oGetDataArgs
	End Sub
	
	
	'==========================================================================
	' �������������/���������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	Public Property Let Mandatory(bMandatory)
		If bMandatory Then
			HtmlElement.removeAttribute "X_MAYBENULL"
			HtmlElement.className = "x-editor-control-notnull x-editor-string-field"
		Else
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
			HtmlElement.className = "x-editor-control x-editor-string-field"
		End If			
	End Property
	
	
	'==========================================================================
	' �������������/���������� (��)����������� ��������� ��������
	Public Property Get Enabled
		 Enabled = Not HtmlElement.disabled
	End Property
	Public Property Let Enabled(bEnabled)
		HtmlElement.disabled = Not bEnabled
	End Property
	
	
	'==========================================================================
	' ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' ���������� Html �������
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property

	
	'==========================================================================
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property


	'==========================================================================
	' IDisposable: ��������� ������
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
	End Sub	
	
	
	'==========================================================================
	' ������������� "������" ���� �����
	Private Sub initSmartTextArea()
		AdjustTextAreaWidth
		m_nMinH = SafeClng( HtmlElement.GetAttribute("X_MinH"))
		m_nMaxH = SafeClng( HtmlElement.GetAttribute("X_MaxH"))
	End Sub
	
	
	'==========================================================================
	' ������������ ������ textarea � ������������ � ������� ���������� ������� ���������
	Public Sub AdjustTextAreaWidth()
		' #259092 ��� ���������� ������ ������� (��� ��������� ��������� � ���������� ���������)
		' clientWidth ������� ����� ����������� ��� ��� �������� ����� ������ "���������" ������
		' ������� ������� ������� ������ � 1px � ������� DoEvents ����� "�����������"
		HtmlElement.Style.Width = "1px" '#259092
		XService.DoEvents				'#259092
		HtmlElement.Style.Width = HtmlElement.parentNode.clientWidth  & "px"
	End Sub
	
	
	'==========================================================================
	' ��������� ��������� ������� "�����" ��������� TextArea
	Sub Internal_SmartTextAreaOnAdjustSize()
		const DELTA	= 8	' ��������� "�����"	�� ������ (� ��������)
		
		Dim nAvailHeight	' ��������� ������
		Dim nValue			' ������
		
		nValue = SafeClng(HtmlElement.scrollHeight) + SafeClng(HtmlElement.OffsetHeight) - SafeClng(HtmlElement.ClientHeight)
		nAvailHeight = SafeClng(ObjectEditor.HtmlPageContainer.clientHeight) - DELTA 
		
		If nValue < m_nMinH Then nValue = m_nMinH
		If nValue > m_nMaxH Then nValue = m_nMaxH
		
		If nValue > nAvailHeight Then nValue = nAvailHeight

		HtmlElement.style.Height =  nValue & "px"
	End Sub

	
	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	

	
	'==========================================================================
	' ���������� ���������� ��������� ��� �������� ��������
	Public Property Get RegExpPattern
		RegExpPattern = "" & HtmlElement.getAttribute("RegExpPattern")
	End Property

	'==========================================================================
	' ���������� ��������� � �������������� �������� ����������� ���������
	Public Property Get RegExpPatternMismatchMessage
		RegExpPatternMismatchMessage = "" & HtmlElement.getAttribute("RegExpPatternMsg")
	End Property	
	
	
	'==========================================================================
	' ���������� Html-������� OnKeyUp . ���������� ���������� �� ����-����.
	' ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUpHtmlAsync(keyCode, altKey, ctrlKey, shiftKey)
		Dim oEventArgs		' As AccelerationEventArgsClass

		If m_bKeyUpEventProcessing Then Exit Sub
		' �������� ����������� ���������� ��� ��������� �����
		If checkTextSpecificHotkeys(keyCode, altKey, ctrlKey, shiftKey) Then Exit Sub
		m_bKeyUpEventProcessing = True
		Set oEventArgs = CreateAccelerationEventArgs(keyCode, altKey, ctrlKey, shiftKey)
		Set oEventArgs.Source = Me
		Set oEventArgs.HtmlSource = HtmlElement
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ���� ������� ���������� �� ���������� - ��������� �� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
		m_bKeyUpEventProcessing = False
	End Sub
End Class


'==========================================================================
' ��������� ��������� ���������� ������, ������� � ��������� ����� ����� ��������� ��������, 
' ������� �� ����� �������������� �� ��� ����� ���������������
Function checkTextSpecificHotkeys(keyCode, altKey, ctrlKey, shiftKey)
	checkTextSpecificHotkeys = False
	' ������� Del � Backspace 
	If Not altKey And Not ctrlKey And Not shiftKey And (keyCode = VK_DEL OR keyCode = VK_BACK) Then 
		checkTextSpecificHotkeys = True
	' Ctrl + ������ � Ctrl + �����
	ElseIf ctrlKey And (keyCode = VK_LEFT Or keyCode = VK_RIGHT) Then
		checkTextSpecificHotkeys = True
	End If
End Function 

Const INVALID_XML_CHARS_PATTERN = "[^\x01-\xFF\u2116-\u2126\u0021-\u2044\u0401-\u04F9]"	' ������ ����������� ���������, ������������ ��� ������/������ ������������ ��������
Private g_oInvalidXmlCharsRegularExpressionStatic ' As RegExp
' ������������ � ����������� RegExp ��� ������ ������������ ��������
set g_oInvalidXmlCharsRegularExpressionStatic = new RegExp
g_oInvalidXmlCharsRegularExpressionStatic.Multiline = True
g_oInvalidXmlCharsRegularExpressionStatic.IgnoreCase = false
g_oInvalidXmlCharsRegularExpressionStatic.Global = true
g_oInvalidXmlCharsRegularExpressionStatic.Pattern = INVALID_XML_CHARS_PATTERN	

' �������� �� ���������� ���������
Function CheckOnPatternMatch(ByVal vValue, oPropertyEditor, oGetArgs)
	Dim sPattern
	Dim oRegEx
	CheckOnPatternMatch = True
	If 0=Len("" & vValue) Then
		Exit Function
	End If
	sPattern = "" & oPropertyEditor.RegExpPattern
	If 0=Len(sPattern) Then
		Exit Function
	End If
	
	Set oRegEx = New RegExp
	oRegEx.Pattern = sPattern
	
	If oRegEx.Test( vValue) Then
		Exit Function
	End If
		
	oGetArgs.ReturnValue = False
	oGetArgs.ErrorMessage = oPropertyEditor.RegExpPatternMismatchMessage
	CheckOnPatternMatch = False
End Function


' �������� �� ���������� Xml-�������
Function CheckOnInvalidCharacters(ByVal vValue, oPropertyEditorBase, oGetArgs)
	CheckOnInvalidCharacters = False
	' �������� ������ �� ��������� ������������ ��������...
	If g_oInvalidXmlCharsRegularExpressionStatic.Test( vValue) Then
		' ���, ���� ����� �������, ������� � ������������: ��� � ���� ���� ������
		If Not oGetArgs.SilentMode Then
			If vbOK = MsgBox(  _
				"����� ��������� """ & oPropertyEditorBase.PropertyDescription  & """ �������� ������������ �������!" & vbNewLine & vbNewLine & _
				"��� ������������ ������� ����� �������� ���������." ,_ 
				vbOKCancel or vbDefaultButton1 or vbExclamation, "��������!") _
			Then
				' ����������� - ������� ��� ���������
				vValue = g_oInvalidXmlCharsRegularExpressionStatic.Replace( vValue, " ")
				' ������� ������������ �������� ������� � HTML-�������
				oPropertyEditorBase.HtmlElement.value = vValue
				CheckOnInvalidCharacters = True
			Else
				oGetArgs.ReturnValue = False
			End If
		Else
			oGetArgs.ReturnValue = False
		End If
	Else
		CheckOnInvalidCharacters = True
	End If
End Function
