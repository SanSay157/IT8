<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-choose-image.master" 
	
	Inherits="Croc.XmlFramework.Web.XChooseImagePage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-choose-image.aspx.cs" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolderForContent" Runat="Server">
	<SCRIPT LANGUAGE="VBScript" TYPE="text/vbscript" >
	
	Option Explicit
	
	'------------------------------------------------------------------------------
	' ���������� ���������� ��������
	Dim g_sFileName			' ������� ��������� ����
	Dim g_bIsEmpty			' ������� ���������� ��������
	Dim g_bIsModified		' ������� ����������� 
	Dim g_sInitFileName		' ��������� ��� ����� � ���������
	Dim g_sFilters			' ������ ��������
	Dim g_nMaxFileSize		' ������������ ������ ����� (0, ���� �� ������������)
	Dim g_nMinHeight		' ����������� ��... 
	Dim g_nMaxHeight		'	... ��������������... 
	Dim g_nMinWidth			'		... �������...
	Dim g_nMaxWidth			'			...  ����������� (0, ���� �� ������������)	
	' HTML-��������
	Dim cmdBrowse
	Dim cmdClear
	Dim cmdOk
	Dim cmdCancel
	Dim idImage
	Dim xPaneCaption

	'------------------------------------------------------------------------------
	' ������������� ��������
	Sub Window_OnLoad()
		Dim sCaption	' ��������� ��������
		
		Internal_InitHtmlControls()
		' �������� ������� ��������� ��������
		g_sFileName = ""
		With X_GetDialogArguments(Null) 
			sCaption = .Caption
			g_sInitFileName = "" & .URL
			g_sFilters = "" & .Filters
			g_nMaxFileSize = SafeCLng(.MaxFileSize)
			g_nMinHeight = SafeCLng(.MinHeight)
			g_nMaxHeight = SafeCLng(.MaxHeight)
			g_nMinWidth = SafeCLng(.MinWidth)
			g_nMaxWidth = SafeCLng(.MaxWidth)
			If .OffClear = True Then cmdClear.Style.Display = "NONE"
		End With
		
		If 0<>Len(sCaption) Then xPaneCaption.InnerHtml = sCaption
		g_bIsEmpty = (Len(g_sInitFileName)=0)
		g_bIsModified = False
		If Len(g_sInitFileName) Then
			DoLoadImage g_sInitFileName
		Else
			DoApplyButtons		
		End If
	End Sub


	'------------------------------------------------------------------------------
	' �������������� ������ �� Html-��������
	Sub Internal_InitHtmlControls()
		Set cmdBrowse = document.all("XChooseImage_cmdBrowse")
		Set cmdClear = document.all("XChooseImage_cmdClear")
		Set cmdOk = document.all("XChooseImage_cmdOk")
		Set cmdCancel = document.all("XChooseImage_cmdCancel")
		Set idImage = document.all("idImage")
		Set xPaneCaption = document.all("XChooseImage_xPaneCaption")
	End Sub
	
	
	'------------------------------------------------------------------------------
	' ������������� ����������� ������ � ������������ g_bIsModified � g_bIsEmpty
	Sub DoApplyButtons
		cmdBrowse.disabled = False
		cmdClear.disabled = g_bIsEmpty
		cmdOK.disabled = Not(g_bIsModified)
		cmdCancel.disabled = False
	End Sub


	'------------------------------------------------------------------------------
	' ���������� �������� ����������� � ���������� ������
	' [in] sURL   - URL ��� �������� ��������
	Sub DoLoadImage(sURL)
		cmdBrowse.disabled = True
		cmdOK.disabled = True
		idImage.style.display="NONE"
		g_sFileName = sURL
		idImage.src = sURL
	End Sub


	'<����������� IMAGE>
	'------------------------------------------------------------------------------
	' ���� �������� �� ���������� ��-�� ����, ��� ������� ������� �������������...
	Sub idImage_OnAbort
		MsgBox "�������� ��������: " & vbNewLine & g_sFileName, vbExclamation, "��������"
		XChooseImage_cmdClear_OnClick()  
	End Sub

	'------------------------------------------------------------------------------
	' ... ��� ��������� ����� ������
	Sub idImage_OnError
		MsgBox "������ ��� �������� �����������: " & vbNewLine & g_sFileName & vbNewLine & Err.Description, vbCritical, "������"
		XChooseImage_cmdClear_OnClick()  
	End Sub

	'------------------------------------------------------------------------------
	' ���� �������� ���������� ���������
	Sub idImage_OnLoad
		Dim sImgProps	'������ � ��������� �����������
		Dim nWidth		'������ �����������
		Dim nHeight		'������ �����������
		
		'���� ����������� ������ - �� �� ������� ��� ��������. �������
		'������� ��� �� ����������, ������� �������, ����� ���� ����� ������
		idImage.style.display="BLOCK"
		nWidth  = CLng( idImage.width)
		nHeight = CLng( idImage.height)
		idImage.style.display="NONE"
		If 0<>Len(g_sFileName) Then
			' �������� ���������� ������ � ������ �����������
			If g_nMaxHeight > 0 Then
				If g_nMaxHeight < nHeight Then
					Alert "������������ ���������� ������ ����������� � �������� ����� " & g_nMaxHeight & vbNewLine & "������ ���������� ����������� ����� " & nHeight 
					XChooseImage_cmdClear_OnClick()  
					Exit Sub
				End If
			End If
			If g_nMaxWidth > 0 Then
				If g_nMaxWidth < nWidth Then
					Alert "������������ ���������� ������ ����������� � �������� ����� " & g_nMaxWidth & vbNewLine & "������ ���������� ����������� ����� " & nWidth 
					XChooseImage_cmdClear_OnClick()  
					Exit Sub	
				End If
			End If
			If g_nMinHeight > nHeight Then
				Alert "����������� ���������� ������ ����������� � �������� ����� " & g_nMinHeight & vbNewLine & "������ ���������� ����������� ����� " & nHeight 
				XChooseImage_cmdClear_OnClick()  
				Exit Sub
			End If
			If g_nMinWidth > nWidth Then
				Alert "����������� ���������� ������ ����������� � �������� ����� " & g_nMinWidth & vbNewLine & "������ ���������� ����������� ����� " & nWidth 
				XChooseImage_cmdClear_OnClick()  
				Exit Sub
			End If
			' �������� ���������� ������ �����
			If g_nMaxFileSize > 0 Then
				If g_nMaxFileSize < CLng(idImage.fileSize) Then
					Alert "������������ ���������� ������ ����� ����������� � ������ ����� " & g_nMaxFileSize & vbNewLine & "������ ����� ���������� ����������� ����� " & idImage.fileSize  
					XChooseImage_cmdClear_OnClick()  
					Exit Sub
				End If
			End If
			idImage.style.display="BLOCK"
		End If
		g_bIsModified = (g_sFileName<>g_sInitFileName)
		g_bIsEmpty = false
		
		sImgProps = ""
		if g_bIsModified then sImgProps = "��������� ���� �����������: " & vbNewLine & g_sFileName & vbNewLine & vbNewLine
		sImgProps = sImgProps & _
			"������� ����������� (� ��������): " & nWidth & " x " & nHeight & vbNewLine & _
			"����� ����������� (� ������): " & idImage.fileSize 
		
		idImage.alt = sImgProps
		DoApplyButtons
	End Sub
	'</����������� IMAGE>
	

	'</����������� ������>
	'------------------------------------------------------------------------------
	' ������� ������ ������ ����� ����� � �������� ��������� ���
	Sub XChooseImage_cmdBrowse_OnClick
		Dim sCurrentFilter	' ������ � ��������-�������� ���������� ������
		Dim sImagePath		' �������� ��� ����� ��������� ��������
		
		If 0 = Len(g_sFilters) Then
			sCurrentFilter = "�����������|*.gif;*.jpg;*.jpeg;*.bmp;*.png|��� �����|*.*||"
		Else
			sCurrentFilter = g_sFilters
		End If
		
		sImagePath = XService.SelectFile( _
			"�������� ���� � ������������", _
			BFF_FILEMUSTEXIST or BFF_PATHMUSTEXIST or BFF_HIDEREADONLY, _
			"", "", sCurrentFilter )
			
		If 0<>Len(sImagePath ) Then
			DoLoadImage sImagePath 
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	' ������� �����������
	Sub XChooseImage_cmdClear_OnClick
		g_bIsEmpty = true
		g_bIsModified = (Len(g_sInitFileName)>0)
		g_sFileName = ""
		idImage.style.display="NONE"
		DoApplyButtons
	End Sub 

	'------------------------------------------------------------------------------
	' ��� ������� �� ������ OK - ���������� ���������...
	Sub XChooseImage_cmdOK_OnClick
		If g_bIsEmpty Then
			X_SetDialogWindowReturnValue Null
		Else
			X_SetDialogWindowReturnValue g_sFileName 
		End If	
		window.close
	End Sub

	'------------------------------------------------------------------------------
	' ��� ������� �� ������ ������ - ������ ��������� ���� (Empty ������� ���������)
	Sub XChooseImage_cmdCancel_OnClick
		X_SetDialogWindowReturnValue Empty
		window.close
	End Sub
	'</����������� ������>
	
	'------------------------------------------------------------------------------
	' ���������� ������� ������� � ����
	Sub Document_onKeyPress()
		Select Case window.event.keyCode
			Case VK_ENTER 'Enter
				If Not cmdOK.disabled then XChooseImage_cmdOk_OnClick
			Case VK_ESC 'Esc
				If Not cmdCancel.disabled then XChooseImage_cmdCancel_OnClick
		End Select
	End Sub

	</SCRIPT>

	<DIV STYLE="position:relative; height:100%; width:100%; overflow:auto; padding:0; margin:0; border:#fff groove 2px;">
		<!-- ����������� ������������� ��������� � ������� - ����� �������������� -->
		<TABLE CELLPADDING="0" CELLSPACING="0" STYLE="height:100%; width:100%; border:none;">
			<TR>
				<TD STYLE="text-align:center; vertical-align:middle;"><IMG ID="idImage" STYLE="border:none;" SRC="Images\x-open-help.gif"></TD>
			</TR>
		</TABLE>
	</DIV>
</asp:Content>

