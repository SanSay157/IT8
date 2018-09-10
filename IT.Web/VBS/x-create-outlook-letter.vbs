' MOLE-VBS-SCRIPT - �������� �����������
'<SCRIPT LANGUAGE="VBS"> ' ���� ��������� �������������
'
' ������ ���� �������� ���� ������������ ������� � ������������ ��� ������������� �������� ������ �� �������
'
'############################################################################################################
' ������� ������ � MS Outlook. � ������ ������� ��������� exception
' [in] sTo				- �������
' [in] sCC				- �����
' [in] sBCC				- ������� �����
' [in] sSubject			- ����
' [in] sMessage			- ���������
' [in] bMessageInHTML	- �������, ��� sMessage - ��� � ������� HTML
' [in] bLeaveSign		- ������� ������������� �������� ����������� � ������ �������
' [in] vXService		- XControls.IXClientService, ��������������� ������ ��� �������� 
'							������������ ��� ���������� ���������� (������������)
' [retval]				- Outlook.MailItem - ��������� ������
'
Function X_CreateOutlookLetter(sTo, sCC, sBCC, sSubject, ByVal sMessage, bMessageInHTML, bLeaveSign, vXService)
	' ���������, �������� ������ ������
	Const OL_FORMAT_RTF = 3     ' ������ � ������� RTF
	Const OL_FORMAT_HTML = 2    ' ������ � ������� HTML

	Dim oLetter				' Outlook.MailItem
	Dim sHTMLBody			' HTML-����� ������
	Dim nPos, nPos2, nPos3	' ������� � ������ ��� ������� ������ (�� ����� �� ���������)

	const INTERNAL_NEW_LINE = "[brHere]" ' ������-��� ��� ����������� �������� ������
	
	' �������� ������ Outlook.MailItem
	If IsObject( vXService) then
		If Nothing Is vXService then
			Set oLetter = CreateObject("Outlook.Application").CreateItem(0)
		Else
			Set oLetter = vXService.CreateObject("Outlook.Application").CreateItem(0)
		End If
	Else
		Set oLetter = CreateObject("Outlook.Application").CreateItem(0)
	End If	

	' ������� "" ����������� ��� ���������� ������ ���� sTo, sCC, sBCC, sSubject - NULL
	oLetter.To = "" & sTo
	oLetter.CC = "" & sCC
	oLetter.BCC = "" & sBCC
	oLetter.Subject = "" & sSubject
	
    On Error Resume Next
    ' ������� ������
    oLetter.Display
    If Err Then
        MsgBox "������ �������� ���� � ����� ���������� MS Outlook. " & _
			   "���������� ������� ��������� ���� � ������ ����������� MS Outlook" _
			    & vbNewLine & Err.Description
        Exit Function
    End If
    On Error GoTo 0
    
	' ���������� �� HTML ������ ������ (�� ������ ������ ��� ������ �������)
	' �.�. Outlook ����� ������� ����������� �� � RTF ������
	' ��� ���� <A... </A>, ����� ������� (��� ����� ������) ���������
    if OL_FORMAT_HTML = oLetter.BodyFormat or OL_FORMAT_RTF = oLetter.BodyFormat then
		sHTMLBody = oLetter.HTMLBody
		
		do while 0 < InStr( UCase(sHTMLBody), "<A" ) 
			' ������ ����
			nPos = InStr( UCase(sHTMLBody), "<A" ) 
			' ����� ���� <A... 
			nPos2 = InStr( nPos, sHTMLBody, ">" )
			' ������ ���� </A> (��� ����� �� ����, �.�. ����� ��������)
			nPos3 = InStr( nPos2, UCase(sHTMLBody), "</A>" ) 
			' �������� ����� ���� ������ �� ��������.
			' ������� ��, ��� �� ������������ ����
			' ����� �� ����� ������������ �� ������ ������������ �����
			' � ���, ��� �������� ����� ����� ������������ ����
			
			sHTMLBody = left( sHTMLBody, nPos - 1 ) & _
				Mid( sHTMLBody, nPos2 + 1, nPos3 - nPos2 - 1 ) & _
				Right( sHTMLBody, len( sHTMLBody ) - nPos3 - len("</A>") + 1)
			' � ���������� ���� �� ��������� ����� �����
		loop
		' ������ ��� ����� ����� ������
		' ��������� ���������� ����������� - ��� ������������ ������, ���� ���� 
		' ������������� ����������� �� �������������� ������ ������� �� ������,
		' �� ���� ������������ .HTMLBody -> ���������� � ���������� -> .HTMLBody
		' ���� ��� ����� ������ ��� ���������� ������������� ������ ������
		' ����� ��� ��������������� � ������ RTF - ����� ������� ����������.
		' ��� ����� ��������� � �����. �� ������ ���� ����������� ������ 
		' HTML ��� RTF, ��� Plain text ���� ���������� ����� ���������!
		oLetter.HTMLBody = sHTMLBody
	end if
	
	' ��������� ������ � ������ RTF ��� ��������� ������ �������������� ������� ��������
	oLetter.BodyFormat = OL_FORMAT_RTF
	
	' ��������� � ������������ ������� � ���� ������ ����: 
	' ������ ����� ��� ����������� �������� ������ � ���������� ������ (������) �����:
	' ���� ��� ������ ������ ���, �� .HTMLBody �� ���������� ������ ���������� - 
	' "������", ������������ outlook'� ��������� �������� � HTML �������
	' � ��������� 1251
	If not bLeaveSign or 0 = len(oLetter.Body) Then
		' ������� �������� ������ ��� ������ ��� � ������ ������� �� ���������� ������
		' - ��������� ������ HTML �������
		oLetter.Body = " " 
	End If
	
	' ������� ��������� � �������� (��� ��� ��� ���) � ���� HTML
	sHTMLBody = oLetter.HTMLBody

	If Not bMessageInHTML Then
		' ����������� ��������� � HTML-������
		' �.�. ������ ��� ����� �������������� ������������ ������ ������,
		' ������� �� �������� [brHere], ����� ������� �������� �����
		oLetter.Body = Replace( sMessage, vbNewLine, INTERNAL_NEW_LINE ) & " "
		sMessage = Replace( oLetter.HTMLBody, INTERNAL_NEW_LINE, "<BR/>" )
		' ������� ���, ��� ����� <BODY>..</BODY>, � ����������
		nPos = InStr(InStr(1, sMessage, "<Body", vbTextCompare), sMessage, ">", vbBinaryCompare)
		sMessage = Mid(sMessage, nPos + 1, InStr(1, sMessage, "</Body", vbTextCompare) - nPos - 1)
	End If
	    
	' ������� � �������� ��������� ����� ����� <BODY> ���� ���������
	nPos = InStr(InStr(1, sHTMLBody, "<Body", vbTextCompare), sHTMLBody, ">", vbBinaryCompare)
	sHTMLBody = Mid(sHTMLBody, 1, nPos + 1) & sMessage & Mid(sHTMLBody, nPos + 1)

	' ���� ����� �.��������:
	' ������� �� ���������� ������ ���� � ������ �� �� ���������� 
	' ����� ��������� �������� �������� � Word-��������� e-mail'a
	sHTMLBody = Replace(sHTMLBody, "<P ALIGN=LEFT>","")
	sHTMLBody = Replace(sHTMLBody, "</P>","<BR/>")
	    
	' ��������� ���������� �����
	oLetter.HTMLBody = sHTMLBody

	' ��������� �������������� ������ � ����� HTML
	oLetter.BodyFormat = OL_FORMAT_HTML
	
	Set X_CreateOutlookLetter = oLetter
End Function



'</SCRIPT>
