<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output 
		omit-xml-declaration="yes"
		standalone="no"
		encoding="UTF-8"
		method="html" 
		version="4.0"
	/> 

	<xsl:param name="applications" select="*[0!=0]" />

	<xsl:template match="/">
		<html>
		<xsl:for-each select="event">
			<xsl:call-template name="new-incident" />
		</xsl:for-each>
		<xsl:for-each select="digest">
			<head>
				<title>it_test: ITRACKER: Digest</title>
			</head>
			<xsl:for-each select="event">
				<xsl:call-template name="new-incident" />
			</xsl:for-each>
		</xsl:for-each>
		<p><font face="Verdana,Arial,Helvetica" size="1">Incident Tracker Messaging Service</font></p>
	<div>
		<xsl:for-each select="$applications">
			<a href="{string(@url)}" target="_blank">
				<xsl:value-of select="string(@title)"/>
			</a>
		</xsl:for-each>
	</div>
		</html>		
	</xsl:template>

	<xsl:template name="new-incident">
		<head>
			<title>it_test: ITRACKER: Новый инцидент № <xsl:value-of select="string(incident/@number)"/></title>
		</head>
		<table border="0" width="600" cellspacing="1" bgcolor="#3077C5" cellpadding="2">
			<tr>
				<td bgcolor="#3077C5"
					style="filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=1, StartColorStr=#FF163890, EndColorStr=#FF4C7FFF);">
					<font size="2" color="#FFFFFF" face="Verdana">Новый инцидент № <xsl:value-of select="string(incident/@number)"/></font></td>
			</tr>
			<tr>
				<td bgcolor="#CADEE8">
					<table border="0" width="100%" cellspacing="0" bgcolor="#E6F2FF" cellpadding="8">
						<tr>
							<td bgcolor="#E6F2FF"><font face="Verdana,Arial,Helvetica" size="2">

<table width="100%" border="0">
	<tr>
		<td>Наименование</td>
		<td><xsl:value-of select="string(incident/n)"/></td>
	</tr>
	<tr>
		<td>Тип</td>
		<td><xsl:value-of select="string(incident/type)"/></td>
	</tr>
	<tr>
		<td>Проект</td>
		<td><xsl:value-of select="string(folder/n)"/></td>
	</tr>
</table>
							
							</font></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</xsl:template>

	
</xsl:stylesheet>  