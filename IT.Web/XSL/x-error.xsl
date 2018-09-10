<?xml version="1.0" encoding="windows-1251"?>
<!-- ���� ����� ��� ����������� ������ �� ��������� �� ������� ������ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/TR/WD-xsl"	>

<xsl:script language="VBScript">
<![CDATA['<%

' ������� ���������� ��������������� � 16-������� ���� ��� ������
' [in] oVal  - IXSLRuntime
Function DoHex(oVal)
	const HEX_DIGITS = 8	' ����� ���������������� ��������
	dim sTemp				' ��������� ����������
	sTemp = HEX(CLng(oVal.selectSingleNode("x-res/@c").text))
	DoHex = LCase( "0x" & String( HEX_DIGITS - Len( sTemp), "0") & sTemp)
End Function
    
'%>']]>
</xsl:script>

<xsl:template match="/">
	<HTML>
		<HEAD>
			<!-- ������� ��������� ���� -->
			<TITLE>������!</TITLE>
		</HEAD>
		<BODY>
			<table border="0">
				<tr>
					<td>
						<h2>
							<font color="red">
								��� ���������� �������� �� ������� ��������� ������!
							</font>
						</h2>
					</td>
				</tr>
				<tr>
					<td><b>��������:</b></td>
				</tr>	
				<tr>
					<td><xsl:value-of select="x-res/@user-msg" /></td>
				</tr>
				<xsl:if test="x-res[( (@c) $and$ (@c !='') ) or ( (@sys-msg) and (@sys-msg !='') )]">
					<tr><td><hr/></td></tr>
					<tr><td><br/><h2>���������� ��� ��������������:</h2></td></tr>
					<xsl:if test="x-res[(@c) and (@c !='')]">
						<tr>
						<td  valign="top"><nobr><b>��� ������:</b></nobr></td>
						</tr>	
						<tr>
						<td>
							<B><tt><xsl:eval language="VBScript">DoHex(me)</xsl:eval>
							(<xsl:value-of select="x-res/@c" />)</tt></B>
						</td></tr>
					</xsl:if>
					<xsl:if test="x-res[(@sys-msg) and (@sys-msg !='')]">
						<tr>
							<td  valign="top"><nobr><b>��������� ���������:</b></nobr></td>
							</tr>	
							<tr>
							<td><pre>
								<xsl:value-of select="x-res/@sys-msg" />
							</pre></td>
						</tr>
					</xsl:if>
				</xsl:if>
			</table>
		</BODY>
	</HTML>
</xsl:template>
</xsl:stylesheet>
