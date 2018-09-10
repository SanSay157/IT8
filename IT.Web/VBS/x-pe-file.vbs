'*******************************************************************************
' ����������:	
' ����������:	����������� ���������� ������������ UI-������������� ���������� 
'				�������� ��������� ������ (vt="bin") �����
'*******************************************************************************
Option Explicit
'==============================================================================
'	BINARY-PRESENTATION (2 � read-only-���� + ������ � ���� ��������)
'==============================================================================
' �������:
'	Accel (EventArg: AccelerationEventArgsClass)
'		- ������� ���������� ������ 
Class XPEBinaryPresentationClass
	Private m_oPropertyEditorBase 	' As XPropertyEditorBaseClass
	Private m_oFileNameHtmlElement	' As IHtmlElement	- Html-������� � ������ �����
	Private m_oFileSizeHtmlElement	' As IHtmlElement	- Html-������� � ��������
	Private m_bIsImage				' As Boolean		- ������� ������������� �����������
	Private IMG_LOCAL_FILE_NAME 	' �������� � ������ ���������� ����� � �������� bin.hex, ���������� ��������
	Private m_oPopUpMenu			' CROC.XPopupMenu
	Private m_nMaxFileSize			' ������������ ������ �����, ������� ����� ��������� � ��������
	
	Private Sub Class_Initialize
		IMG_LOCAL_FILE_NAME = "local-file-name"
	End Sub

	'--------------------------------------------------------------------------
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oPropertyEditorBase = New XPropertyEditorBaseClass
		m_oPropertyEditorBase.Init oEditorPage, oXmlProperty, oHtmlElement, "Accel", "BinaryPresentation"
		
		Set m_oFileNameHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("FileNameID"), 0) 
		Set m_oFileSizeHtmlElement = m_oPropertyEditorBase.EditorPage.HtmlDivElement.all(HtmlElement.GetAttribute("FileSizeID"), 0) 
		m_bIsImage = SafeCLng(HtmlElement.GetAttribute("IsPicture"))<>0
		m_nMaxFileSize = SafeCLng(HtmlElement.GetAttribute("MaxFileSize"))
		' �������� ���� smallBin �� ����� ������� ������ 2000 ����
		If m_oPropertyEditorBase.PropertyMD.getAttribute("vt") = "smallBin" Then
			If m_nMaxFileSize > 2000 Or m_nMaxFileSize = 0 Then
				m_nMaxFileSize = 2000
			End If
		End If
		ViewInitialize
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

	'--------------------------------------------------------------------------
	' ���������� Html ������� � ������ �����
	Private Property Get FileNameHtmlElement
		Set FileNameHtmlElement = m_oFileNameHtmlElement
	End Property

	'--------------------------------------------------------------------------
	' ���������� Html ������� � ��������
	Private Property Get FileSizeHtmlElement
		Set FileSizeHtmlElement = m_oFileSizeHtmlElement
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get PropertyNameToStoreFileName
		PropertyNameToStoreFileName = vbNullString & HtmlElement.GetAttribute("PropertyNameToStoreFileName")
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get DataSize
		Dim vValue
		vValue = XmlProperty.GetAttribute("data-size")
		DataSize = 0
		If IsNull(vValue) Then
			vValue = XmlProperty.nodeTypedValue
			If Not IsNull(vValue) Then
				DataSize = UBound(vValue)
			End If
		Else
			DataSize = SafeCLng(XmlProperty.GetAttribute("data-size"))
		End If
	End Property

	'--------------------------------------------------------------------------
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = m_oPropertyEditorBase.GetXmlProperty(False)
	End Property
	
	'--------------------------------------------------------------------------
	Public Property Get Value
		Value = m_oPropertyEditorBase.XmlProperty.NodeTypedValue
	End Property

	'--------------------------------------------------------------------------
	' ������������� �������� 
	Public Sub SetData
		Dim sFileName	' ������������ ����� ������ �������� ������������ ��������
		Dim nFilesize	' ������ �����
		Dim sPropName	' ������������ ��������, � ������� �������� ������������ �����

		' �������� ������������ �����; ��� �.�. (�) ���������� ��������������� ��� 
		' ������ �����, ����� ������������ �������� � IMG_LOCAL_FILE_NAME, (�)
		' �������� ��������� �������� �������, ������������ �������� � ���� �������
		' ������ ��������� X_FILE_NAME_IN (��, ��� ������ ��������� file-name-in ���
		' i:binary-presentation � ����������). 
		sFileName = XmlProperty.GetAttribute(IMG_LOCAL_FILE_NAME) 
		If Not hasValue(sFileName) Then
			sPropName = PropertyNameToStoreFileName
			If HasValue(sPropName) Then
				sFileName = vbNullString & XmlProperty.parentNode.selectSingleNode(sPropName).nodeTypedValue
			End If
		End If
		nFileSize = DataSize
		' ���� ������������ ����� �� ���������� - �� ���� ������ ����� ������������,
		If nFilesize>0 Then
			If (Not HasValue(sFileName)) Then _
				sFileName = Iif(IsPicture, "[ ����������� ]", "[ ���� ]")
		Else
			sFileName = "[ ����� ]"	
		End If
			
		' ����������� ������������ �����:
		FileNameHtmlElement.Value = sFileName
		FileSizeHtmlElement.Value = Iif( nFileSize>0, nFileSize, vbNullString )
	End Sub

	'--------------------------------------------------------------------------
	' ���� � �������� ������
	Public Sub GetData(oGetDataArgs)
		' �������� ������� ������ ���� ��� ������
		If 0>=DataSize Then
			ValueCheckOnNullForPropertyEditor Null, Me, oGetDataArgs, Mandatory
		End If	
	End Sub
	
	'--------------------------------------------------------------------------
	' ���������� ������� (��)�������������� ��������
	Public Property Get Mandatory
		Mandatory = IsNull( HtmlElement.GetAttribute("X_MAYBENULL"))
	End Property
	
	'--------------------------------------------------------------------------
	' ��������� (��)��������������
	Public Property Let Mandatory(bMandatory)
		If (bMandatory) Then
			HtmlElement.removeAttribute "X_MAYBENULL"
		Else	
			HtmlElement.setAttribute "X_MAYBENULL", "YES"
		End If
		If (bMandatory) Then
			FileSizeHtmlElement.className = "x-editor-control-notnull"
			FileNameHtmlElement.className = "x-editor-control-notnull"
		Else
			FileSizeHtmlElement.className = "x-editor-control"
			FileNameHtmlElement.className = "x-editor-control"
		End If
		ViewInitialize
	End Property
	
	'--------------------------------------------------------------------------
	' ��������� (��)�����������
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property
	Public Property Let Enabled(bEnabled)
		' �����������/������������ ������
		HtmlElement.disabled = Not( bEnabled )
		' �����������/������������ read-only-����
		FileSizeHtmlElement.disabled = Not( bEnabled )
		FileNameHtmlElement.disabled = Not( bEnabled )
	End Property
	
	'--------------------------------------------------------------------------
	' ��������� ������
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	'--------------------------------------------------------------------------
	Public Property Get HtmlElement
		Set HtmlElement = m_oPropertyEditorBase.HtmlElement
	End Property

	'--------------------------------------------------------------------------
	Public Sub Dispose
		m_oPropertyEditorBase.Dispose
		Set m_oPropertyEditorBase = Nothing
	End Sub

	'-------------------------------------------------------------------------------
	' ��������� ������������ �������� ������ ��������, 
	' � ������������ � �������� ���� ����������� ������������� �������.
	Private Sub ViewInitialize( )
		' ������������ �������� ������ �������� ����������� �� ��������� � ��������
		' ���� ����������� ������������� �������: �������� ������ �� �����. HTML-�������
		With HtmlElement
			.style.height = FileNameHtmlElement.offsetHeight
			.style.width = .style.height
			.style.lineHeight = (.offsetHeight \ 2) & "px"
		End With
	End Sub


	'--------------------------------------------------------------------------
	Public Property Get IsSmallBin
		IsSmallBin = ( HtmlElement.GetAttribute("PropertyType")="smallBin")
	End Property


	'--------------------------------------------------------------------------
	Public Property Get IsLoaded
		IsLoaded = IsNull(XmlProperty.getAttribute("loaded"))
	End Property


	'-------------------------------------------------------------------------------
	Public Property Get IsPicture
		IsPicture = m_bIsImage
	End Property


	'==========================================================================
	' ����������/������������� �������� ��������
	Public Property Get PropertyDescription
		PropertyDescription = m_oPropertyEditorBase.PropertyDescription
	End Property	
	Public Property Let PropertyDescription(sValue)
		m_oPropertyEditorBase.PropertyDescription = sValue
	End Property
	
	
	'-------------------------------------------------------------------------------
	' ���������� ������ �� �������� �� ��������� ����
	' [in] sFileExt - ���������� ��������� �����
	' [retval] ������ ��� ���������� ����
	Private Function WriteToTempFileEx(sFileExt)
		Dim sFileName ' ��� �����
		' ��������� ��� ���������� �����
		sFileName = XService.GetTempPath & XService.NewGUIDString
		If hasValue(sFileExt) Then sFileName = sFileName & "." & sFileExt

		' �������� ���� �� ���� �� ��������� �������,
		' ������� ����������� ��� ��������� ������:
		On Error Resume Next
		XService.SaveFileData sFileName, XmlProperty.nodeTypedValue
		' ���� ���� ������ - ���������� ��������� 
		If 0<>Err.Number Then
			X_ErrReportEx "������ ��� ������� ������ � ���� '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
			On Error Goto 0
			Exit Function
		End If	
		On Error Goto 0
		WriteToTempFileEx = sFileName
	End Function

	
	'-------------------------------------------------------------------------------
	' ���������� ������ �� �������� �� ��������� ����
	' [retval] ������ ��� ���������� ����
	Private Function WriteToTempFile()
		WriteToTempFile = WriteToTempFileEx(Null)
	End Function

	
	'-------------------------------------------------------------------------------
	Private Sub KillTempFile(sFileName)
		' ��������� ������� ����
		On Error Resume Next
		XService.CreateObject("Scripting.FileSystemObject").DeleteFile sFileName, True
		' ���� ���� ������ - ���������� ��������� 
		If 0<>Err.Number Then
			X_ErrReportEx  "������ ��� ������� �������� ���������� ����� '" & sFileName &  "'" & vbNewLine & err.Description, err.Source 
			On Error Goto 0
			Exit Sub	
		End If
		On Error Goto 0	
	End Sub


	'-------------------------------------------------------------------------------
	' Url ��� �������� ��������
	Private Property Get PropertyUrl
		PropertyUrl = _
					XService.BaseURL & "x-get-image.aspx" & _
					"?ID=" & m_oPropertyEditorBase.ObjectID & _
					"&OT=" & m_oPropertyEditorBase.ObjectType & _
					"&PN=" & m_oPropertyEditorBase.PropertyName & _
					"&TM=" & XService.NewGuidString			
	End Property


	'-------------------------------------------------------------------------------
	' ���������� ����� ������ "..." ��� �����������
	Private Sub ShowPictureMenu()
		Dim sTempFileName	' ������ ��� ���������� �����
		Dim sTitle			' ���������
		Dim sImageLocation	' ���������� ��������
		Dim sNewFileName	' ��� ����� � ����� ��������� ��������

		If DataSize>0 Then
			' ���� ������
			If IsLoaded Then
				' �������� ��� ��������� � ������ ��������� � XML
				' ������� �������� � ��� ��������� ����
				sTempFileName = WriteToTempFile
				sImageLocation = sTempFileName
			Else
				sImageLocation = PropertyUrl
			End If
		End If
		' �������� ���������
		sTitle = toString( HtmlElement.getAttribute("ChooseFileTitle") )
		If Not hasValue(sTitle) Then 
			sTitle = "����� ����������� """ & PropertyDescription & """"
		End If
		' ��������� ������
		sNewFileName = X_SelectImage(	_
				sTitle, _
				sImageLocation, _ 
				Trim(toString(HtmlElement.getAttribute("FileNameFilters"))), _ 
				m_nMaxFileSize, _
				SafeCLng(HtmlElement.getAttribute("MinImageWidth")), _
				SafeCLng(HtmlElement.getAttribute("MaxImageHeight")), _ 
				SafeCLng(HtmlElement.getAttribute("MinImageWidth")), _ 
				SafeCLng(HtmlElement.getAttribute("MaxImageWidth")) _ 
		)
		' ��������� �� �����
		If Not IsEmpty(sTempFileName) Then 
			KillTempFile sTempFileName
		End If	
								
		' ���� ������ ������ "������" - ������ �� ������, ������� �� ���������
		If IsEmpty(sNewFileName) Then 
			Exit Sub
		' ���� ������ ������ "��������" - ������� ��������...
		ElseIf IsNull(sNewFileName) Then
			ClearValue
		' ���� ���� ������ - ��������� ���� �� ������
		Else
			UploadFile sNewFileName
		End If		
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' ������� �������� (�������� � UI-��������)
	Public Sub ClearValue
		' ������ �������� � XML
		With XmlProperty
			.removeAttribute "loaded"
			.setAttribute "data-size", 0
			.removeAttribute IMG_LOCAL_FILE_NAME
			.text = ""
		End With
		setFileNamePropValue Null
		SetDirty
		SetData	
	End Sub


	'-------------------------------------------------------------------------------
	' �������� �������� �� �����
	Private Sub UploadFile(sFileName)
		Dim nFileSize		' ������ �����
		Dim aFileData		' ������ �����
		
		' ��������� ������ ����� (��� ��������� ������)
		On Error Resume Next
		nFileSize = XService.CreateObject("Scripting.FileSystemObject").GetFile(sFileName).Size
		If Err Then
			X_ErrReportEx _
				"������ ��� ������� ����������� ������� �����:" & vbNewLine & _
				vbTab & sFileName & vbNewLine & _
				"�������� �� ������������ ������ �����������.", _
				Err.Description & vbNewLine & Err.Source 
			On Error Goto 0
			Exit Sub
		End If

		' �������� �� ������������
		If 0 = nFileSize Then 
			MsgBox "���� """ & sFileName & """ ����� ������� ������!", vbCritical
			On Error Goto 0
			Exit Sub
		End If

		If (m_nMaxFileSize > 0) And (nFileSize > m_nMaxFileSize) Then
			MsgBox _
				"������������ ���������� ������ ����� � ������ ����� " & m_nMaxFileSize & vbNewLine & _
				"������ ���������� ����� """ & sFileName & """ ����� " & nFileSize
			On Error Goto 0
			Exit Sub
		End If
		
		' ���������� ��������� ���� � �����
		aFileData = XService.GetFileData(sFileName)
		If Err Then
			X_ErrReportEx "������ ��� ������� ������ �� �����:" & vbNewLine & vbTab & sFileName & vbNewLine & "�������� �� ������������ ������ �����������."  ,err.Description & vbNewLine & err.Source 
			On Error Goto 0
			Exit Sub
		End If
		On Error Goto 0	
		
		' ������ �������� � XML
		With XmlProperty
			.removeAttribute "loaded"
			.setAttribute "data-size", nFileSize
			.setAttribute IMG_LOCAL_FILE_NAME, sFileName
			.nodeTypedValue = aFileData
			
			' ���� ������ �������� ��� �������� ������������ �����, �� �������� ��� (��� ����)
			setFileNamePropValue XService.GetFileTitle(sFileName)
		End With	
		SetDirty
		SetData			
	End Sub
	

	'-------------------------------------------------------------------------------
	' ������������� �������� �������� � ������������� �����
	'	[in] sFileName - ������������ ����� ��� Null - �������� ��������
	Private Sub setFileNamePropValue(sFileName)	
		Dim sPropNameWithFileName	' ������������ �������� ��� �������� ������������ ����a
		
		sPropNameWithFileName = PropertyNameToStoreFileName
		If HasValue(sPropNameWithFileName) Then
			m_oPropertyEditorBase.ObjectEditor.SetPropertyValue XmlProperty.parentNode.selectSingleNode(sPropNameWithFileName), sFileName
		End If
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' ���������� ����� ������ "..." ��� �����. �������� ����� ���� ��������.
	Private Sub ShowFileMenu
		const FM_DOWNLOAD	= 1002	' ��� ������� ��������
		const FM_UPLOAD		= 1003	' ��� ������� ��������
		const FM_CLEAR		= 1004	' ��� ������� �������
		const FM_VIEW		= 1005	' ��� ������� ���������
		
		Dim sFileName		' ��� �����
		Dim nFileSize		' ������ ����� � ������
		Dim oFileName		' ������� � ������ �����
		Dim sTitle			' ��������� ������� ������
		Dim nCMD			' ��� ����������� �������
		Dim sFilters		' ������
		Dim sFileExt		' ���������� ����� ����
		Dim nPosX			' "��������" ������� ����, �-����������
		Dim nPosY			' "��������" ������� ����, Y-����������
		
		' �������� ������� � ������ ���������� �����
		Set oFileName = FileNameHtmlElement
		' �������� ������������� ������� - ���������� ��������
		' �������� ������
		nFileSize = DataSize
		' �������� ���������
		sTitle = toString( HtmlElement.getAttribute("ChooseFileTitle") )
		' �������� �������
		sFilters = Trim( toString( HtmlElement.getAttribute("FileNameFilters") ) )
		
		' �������� ��� ���������� �����
		sFileName = XmlProperty.getAttribute( IMG_LOCAL_FILE_NAME )
		If Not hasValue(sFileName) Then sFileName = Trim(ToString(oFileName.Value))
		If hasValue(sFileName) Then
			' ��������� ���������� �����: ���� ��� ���� (� ���� ������ ToString 
			' ������ �������� ������), �� � ��� ������������ ��� �����:
			sFileExt = Replace( ToString( XService.GetFileExt(sFileName) ), ".", "" )
		End If	
		
		If IsEmpty(m_oPopUpMenu) Then
			Set m_oPopUpMenu = XService.CreateObject("CROC.XPopupMenu")
		End If
		' ������ popup-����
		m_oPopUpMenu.Clear
		m_oPopUpMenu.Add "��������� �� ������..." , FM_UPLOAD, True
		If 0 = SafeCLng(HtmlElement.getAttribute("X_OFF_CLEAR")) Then
			m_oPopUpMenu.Add "��������", FM_CLEAR, nFileSize>0
		End If
		' ����������� ����� ������ ����, � �������� ���� ����������
		If 0 = SafeCLng(HtmlElement.getAttribute("X_OFF_VIEW")) Then
			m_oPopUpMenu.Add "��������", FM_VIEW, Len(sFileExt)>0
		End If
		m_oPopUpMenu.AddSeparator
		m_oPopUpMenu.Add "��������� �� �����...", FM_DOWNLOAD, nFileSize>0
		
		' ���������� �������� ���������� ������, ��� ������� ���������������� ����
		X_GetHtmlElementScreenPos HtmlElement, nPosX, nPosY
		nPosY = nPosY + HtmlElement.offsetHeight
		' ���������� ����...
		nCMD = m_oPopUpMenu.Show( nPosX, nPosY )
		
		' ������������ ��������� �����
		Select Case nCMD
			Case FM_VIEW
				If IsLoaded Then
					' ������ ����������, �.�. ��������� ������ xml
					' ������� ���������� �� ������� ���� �� ��������� ������� � ����������
					sFileName = WriteToTempFileEx( sFileExt )
					' �� ������ ������� ���������� �������
					If IsEmpty(sFileName) Then Exit Sub
					
					On Error Resume Next
					
					' "��������" ���...
					XService.ShellExecute sFileName
					' ���� ���� ������ - ���������� ��������� 
					If 0<>err.number Then
						X_ErrReportEx  "������ ��� ������� ��������� ����� '" & sFileName &  "'" & vbNewLine & err.Description, err.Source 
						On Error Goto 0
						Exit Sub	
					End If	
					On Error Goto 0
					
					' ������� ���� ������������ �� ������ OK � ������ �������� ���������...
					MsgBox "�� ���������� ��������� ������� ""OK""", vbInformation, "�������� �����"
					
					KillTempFile sFileName
				Else
					' �������� � ������� (�� �� ����� LoadProp)
					' ������� ��� ���������� �����
					sFileName = XService.GetTempPath & sFileName
					nFileSize = DataSize
					' �������� ������ ��������
					X_ShowModalDialogEx _
						XService.BaseURL & "x-download.aspx", _
						Array( PropertyUrl, sFileName, 0, True), _
						"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"					
				End If
			Case FM_CLEAR
				' ���� ������������ �� �������� - ������ �� ������
				If Not Confirm( "�� �������?") Then Exit Sub
				ClearValue
			Case FM_UPLOAD
				If Not hasValue(sTitle) Then sTitle = "�������� ����"
				If Not hasValue(sFilters) Then sFilters = "��� ����� (*.*)|*.*||"
				' �������� ����
				sFileName = toString( XService.SelectFile( _
					sTitle, _
					BFF_PATHMUSTEXIST or BFF_FILEMUSTEXIST or BFF_HIDEREADONLY, _
					"", _
					sFileName, _
					sFilters ) )
				' ���� ������ �� ������� - ������� �� ���������
				If Not hasValue(sFileName) Then Exit Sub
				UploadFile sFileName
			Case FM_DOWNLOAD
				' ���������� ������� �����
				If Not hasValue(sFilters) Then sFilters = "��� ����� (*.*)|*.*||"
				sFileName = ToString( XService.SelectFile("������� ���� ��� ����������", BFF_SAVEDLG, "", sFileName, sFilters) )
				If hasValue(sFileName) Then
					If IsLoaded Then
						' ������� ����������� ��� ��������� ������:
						On Error Resume Next
						XService.SaveFileData sFileName, XmlProperty.nodeTypedValue
						' ���� ���� ������ - ���������� ��������� 
						If 0<>Err.Number Then
							X_ErrReportEx "������ ��� ������� ������ � ���� '" & sFileName & "'" & vbNewLine & Err.Description, err.Source 
						End If	
						On Error Goto 0
					Else
						nFileSize = DataSize
						' �������� ������ ��������
						X_ShowModalDialogEx _
							XService.BaseURL & "x-download.aspx", _
							Array( PropertyUrl , sFileName, 0, False) , _
							"dialogWidth:400px; dialogHeight:150px; help:no; center:yes; status:no"
					End If
				End If
		End Select		
	end Sub
	
	
	'-------------------------------------------------------------------------------
	' ���������� ����� ������ "...". �������� ����� ���� ��������.
	Public Sub ShowMenu
		If IsPicture Then
			ShowPictureMenu
		Else
			ShowFileMenu
		End If	
	End Sub
		
	
	'==========================================================================
	' �������� �������� ��� ����������������
	Private Sub SetDirty
		m_oPropertyEditorBase.ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub
	
	
	'==========================================================================
	' ���������� �������
	Private Sub FireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oPropertyEditorBase.EventEngine, sEventName, Me, oEventArgs
	End Sub	
	
	
	'==========================================================================
	' ���������� Html-������� OnKeyUp �� ������. ��������: ��� ����������� �������������.
	Public Sub Internal_OnKeyUp()
		Dim oEventArgs		' As AccelerationEventArgsClass
		
		If window.event Is Nothing Then Exit Sub
		window.event.cancelBubble = True
		Set oEventArgs = CreateAccelerationEventArgsForHtmlEvent()
		Set oEventArgs.Source = Me
		FireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ���� ������� ���������� �� ���������� - ��������� �� � ��������
			ObjectEditor.OnKeyUp Me, oEventArgs
		End If
	End Sub
End Class
