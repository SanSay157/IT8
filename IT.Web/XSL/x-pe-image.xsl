<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ��������� ������� �������
	���� bin.hex � ���� �����������
-->	
	<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:d="urn:editor-data-access">
	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ������� �������
		���� bin.hex � ���� �����������
		������� ��������
			urn:editor-data-access - ��������� ������� EditorData									
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] maybenull	- ������� ������������ ������� ��������	(0/1)										
			[in] description - �������� ����
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ������� ������� 
			���� bin.hex � ���� �����������
	-->	
	<!-- ������ ������ �������� �� bin.hex -->
	<xsl:template name="std-template-image">
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="d:MDQueryProp(current(), '@d')"/>
		<!-- ��������: ������� ������������ ������� �������� -->
		<xsl:param name="maybenull" select="d:MDQueryProp(current(), '@maybenull')"/>
		<!-- 
			��� ������ �� ������ ����� �������� ������� � ����������� ����, 
			����������� ���������� ���� �������� ��� ���������, ��������� �� ID 
		-->	
		<button disabled="1" style="width:100%" class="x-editor-image-button" >
			<!-- 
				� ���-�� ������ ��� �������������� ���������� �������� html-id ���������������
				���������� ��-��. ��� �������� � ���������� ����������� ����������� 
				������� � �������������� ��������� ������� �� ����������������� ����.
			-->				
			<xsl:attribute name="id"><xsl:value-of select="@html-id"/></xsl:attribute>
			<!-- 
				���� �������� ����� ��������� �������� null - �������� ��������������
				�������� X_MAYBENULL.
				���� �������� �������� �������������� ������������ �������� ��-�� ���
				��������� �� ����.
			-->
			<xsl:if test="1=$maybenull">
				<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
			</xsl:if>
			<!-- 
				�������������� �������� X_DESCR ����� ������� �������� ��-��, �������,
				� ����� ������ ����� ���������� �� �������� � ����������.
				���� �������� �������� �������� �������� ��������������� � ���������
				�������� �� ����.
			-->					
			<xsl:attribute name="X_DESCR"><xsl:value-of select="$description" /></xsl:attribute>

			<table cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
				<tr>
					<td width="10%" align="right" valign="middle"><b>&lt;</b></td>
					<td width="80%" align="center" valign="middle">
						<!-- 
							� ���-�� ������ ��� �������������� ���������� �������� html-id ���������������
							���������� ��-��. ��� �������� � ���������� ����������� ����������� 
							������� � �������������� ��������� ������� �� ����������������� ����.
						-->
						<xsl:attribute name="id"><xsl:value-of select="@html-id"/>Caption</xsl:attribute>
						<xsl:choose>
							<xsl:when test="@data-size=0">
								- ����� -
							</xsl:when>
							<xsl:when test="@local-file-name">
								�����������* [<xsl:value-of select="@data-size"/> ����]	
							</xsl:when>
							<xsl:otherwise>
								�����������
								<xsl:choose>
									<xsl:when test="@data-size">
										[<xsl:value-of select="@data-size"/> ����]	
									</xsl:when>
									<xsl:otherwise>
										???
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</td>	
					<td width="10%" align="left" valign="middle"><b>&gt;</b></td>
				</tr>
			</table>
		</button>
		<script language="VBScript" for="{@html-id}" event="OnClick">
		'<xsl:comment>
		'===========================================================================
		' ��������� ��������� �������� - ��������
		const sHTMLID= "<xsl:value-of select="@html-id"/>"' ���������� �������������
		'<![CDATA[
		dim sOT				'  ��� ������� - ���������� ��-��
		dim nID				'  ������������� ������� - ���������� ��-��
		dim sPN				'  ���  �������� ��-��
		dim sURL			'  URL ��������
		dim oImage			'  �������� c ��������� � ���� XMLDomElement
		dim oButton			'  ������ - ������� ������������� ��������
		dim nFileSize		'  ������ ����� � ��������� � ������
		dim aFileData		'  ������ ����� � ���� SafeArray ����������� ����������� �����
		' ��������  �������� c ��������� �� XML
		set oImage = EditorData.getPropByHTMLID(  sHTMLID )
		' ��������  ��� ������� - ���������� ��-��
		sOT = oImage.parentNode.tagName
		' ��������  ������������� ������� - ���������� ��-��
		nID = oImage.parentNode.getAttribute("oid")
		' ��������  ���  �������� ��-��
		sPN = oImage.tagName
		' �������� URL ��� ��������� ��������
		if (X_GetAttributeDef( oImage, "data-size", -1) <> 0) and ( nID>0 ) then
			sURL = XService.BaseURL & "x-get-image.asp?OT=" & sOT & "&ID=" & nID & "&PN=" & sPN & "&TM=" & CDbl(Now)
		else
			sURL = ""
		end if
		sURL = X_GetAttributeDef( oImage, IMG_LOCAL_FILE_NAME, sURL)
		'�������� ����� ��������...
		sURL = X_SelectImage("����� �����������",sURL,"",0,0,0,0,0)
		'������ ������ ������ - ������ �� ������
		if IsEmpty(sURL) then exit sub 
			
		if IsNull(sURL) then
			'������ ������ �������� - ������� ��������...
			nFileSize = 0	
			aFileData = Empty
		else
			'��������� ������� � ������
			on error resume next

			aFileData = XService.GetFileData(sURL)
			if Err then
				Alert "������ ��� ������� ������ �� �����:" & vbNewLine & vbTab & sURL & vbNewLine & vbTab & Err.Description
				Err.Clear 
				exit sub
			end if
			on error goto 0
			nFileSize = UBound(aFileData)+1
			'���� ��������� ���� ������ - ���� ������� ��������
			if nFileSize = 0 then 
				aFileData = Empty
			end if
		end if	
		'��������� XML
		oImage.setAttribute "data-size", nFileSize
		oImage.removeAttribute LOADED
		if nFileSize=0 then
			oImage.removeAttribute IMG_LOCAL_FILE_NAME
			oImage.Text = ""
		else
			oImage.setAttribute IMG_LOCAL_FILE_NAME, sURL
			oImage.nodeTypedValue = aFileData
		end if
		'�������� ������� � ������...
		set oButton = document.all(  sHTMLID & "Caption" )
		'�������������� ������
		if nFileSize>0 then
			oButton.innerHTML ="�����������<b>*</b> [" & nFileSize & " ����]"
		else
			oButton.innerHTML = "- ����� -"				
		end if
		']]>
		'</xsl:comment>
		</script>
	</xsl:template>

</xsl:stylesheet>
