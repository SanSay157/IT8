<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	����������� �������� ��������� �������� ���������/������� �� ���������						
	������� ��������� ���a����:																	
		urn:x-client-service - ��������� IXClientService								
		urn:object-editor-access - ��������� ������� EditorData									
		urn:editor-window-access - ��������� ������� ���� ���������								
		urn:query-string-access - ��������� ������ ������� ��������
			���������, ����������� ����� ������ �������:
				@XPATH_������_���_���������_��������=[���������]
				��� ��������� ::= ��������:��������[;���������]

				��� ������ �������� ����� ������������ �������������� ���������, �������������� ������ ��������:
				display �� ����������: 
					1 (�� ���������) - ���������� ��������
					0 - �� ���������� ��������
				separator-before - ����������� HR �� ������ �������� ��������. ��������: 1, 2, 3
				separator-after - ����������� HR ����� ������ �������� ��������. �������� ����������� separator-before
				
				������:
				x.editor2.xsl?@Name=&@Code=maybenull:0&@Parent/Department/Name=readonly:1
				
				������ ����� ������ ������������ ��������� ���������:
				DisableHR 		- ������ �� �������������� �����������
				ArrayHeight 	- ������ (� ��������) ������������ �� �������� ��������� �������
				MainTableHeight - ������ �������� ������� (����� ���� 100%)
				
				��� ���������� ��������� PROPLIST ������������ ����������� ���� ������� � ������ ����������
								i:hide-in-* � � ������� ���������� �� � XML ������� (������ ��������� � 
								�������� ���������� � ���������)				
				
	�������������� �������:																		
		������ X-Storage										
	��������� �������������:
		HTML - ���, ���������� ��������� ��� �������������� ������� ����������� �������
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:���_�����_���_�����_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	>
<!-- for debug: user:off-cache="1"-->
<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<msxsl:script language="VBScript" implements-prefix="user">
<![CDATA['<%
Option Explicit
Dim g_oProps			' Scripting.Dictionary - ��������� ������������ ������� � �� ����������. 
						' ���� - XPath ������ �� ��������� ��-�� ������������ �������� xml-�������, 
						' �������� - Scripting.Dictionary - ��������� ���������� �������� (XSLT-������� ����������� ��-��)
Dim g_nPropCount		' ���������� ������������ �������
Dim g_nCurrentProp		' ������ �������� ��-�� � ������ g_aProps
Dim g_bNotFirst			' ������� ��-������� ������ ������� IsFirst()


'==========================================================================
' ��������� xpath ��� ���������� ����������. ��������� ��������� xpath-�������, �������� �����������, ���� �� ��������� XSLT
'	[in] oContext - As IXMLDOMNodeList - ��������
'	[in] sXPath - As String - xpath-������
'	[retval] IXMLDOMSelection
Function selectNodes(oContext, sXPath)
	Set selectNodes = oContext.item(0).selectNodes(sXPath)
End Function


'==========================================================================
' ���������� true, ���� ������� �� ������ ���, ����� ���������� false
Function IsNotFirst()
	if not g_bNotFirst then
		IsNotFirst = false
		g_bNotFirst = true
	else
		IsNotFirst = true
	end if
End Function


'==========================================================================
' �������������� �������� ��� ������������ �������
' ���������� ���-�� ������� � ������
'	[in] oXmlParams - 
'	[in] oContext	- 
'	[in] oTypeMD 	- ���������� ���� (���� ds:type)
'	[in] bCreating  - true - ���� ����� �������� �������, ����� false
Function InitPropListIterator(oXmlParams, oContext, ByVal oTypeMD, bCreating)
	Dim oXmlObject		' As IXMLDOMElement
	Dim nPropCount		' As Integer - ���������� �������
	Dim aProps			' As String()
	Dim sPair			' As String - ���� ���/��������
	Dim nIndex			' As Integer
	Dim sPropName		' As String
	Dim sPropValue		' As String
	Dim sParamName		' As String
	Dim sParamValue		' As String - �������� ��������� ��������	
	Dim oXmlParamsList	' As IXMLDOMNodeList - ��������� ���������� (param)
	Dim oXmlParam		' As IXMLDOMElement - xml-���� param
	Dim oPropParams		' As Scripting.Dictionary - ��������� ���������� ������ ��������
	
	InitPropListIterator = ""
	Set oXmlObject = oContext.item(0)
	Set oTypeMD = oTypeMD.item(0)
	Set g_oProps = CreateObject("Scripting.Dictionary")
	g_oProps.CompareMode = vbTextCompare
	g_nCurrentProp = 0
	
	If IsObject(oXmlParams) Then
		Set oXmlParamsList = oXmlParams.item(0).childNodes
		If oXmlParamsList.length > 0 Then
			For Each oXmlParam In oXmlParamsList
				sPropName = oXmlParam.getAttribute("n")
				sPropValue = oXmlParam.text
				If UCase(sPropName) = "PROPLIST" Then
					InitPropListFromLegacyFormat sPropValue
				ElseIf Left(sPropName,1) = "@" Then
					sPropName = MID( sPropName , 2)
					If sPropName = "*" Then
						InitPropListForAllProps oXmlObject, oTypeMD, bCreating
					Else
						If g_oProps.Exists(sPropName) Then
							Set oPropParams = g_oProps.item(sPropName)
						Else
							g_oProps.Add sPropName, Nothing
							Set oPropParams = Nothing
						End If
						If Len(sPropValue) > 0 Then
							If oPropParams Is Nothing Then
								Set oPropParams = CreateObject("Scripting.Dictionary")
								oPropParams.CompareMode = vbTextCompare
							End If
							For Each sPair In Split( sPropValue, ";" )
								nIndex = InStr(sPair, ":")
								If nIndex > 0 Then
									sParamName	= Mid(sPair, 1, nIndex -1)
									sParamValue = Mid(sPair, nIndex+1, Len(sPair) - nIndex)
									oPropParams.item(sParamName) = sParamValue
								End If
							Next
							Set g_oProps.item(sPropName) = oPropParams
						End If
					End If
				End If
			Next
		End If
	End If
	
	If g_oProps.Count = 0 Then
		InitPropListForAllProps oXmlObject, oTypeMD, bCreating
	End If
	g_nPropCount = g_oProps.Count
End Function


'==========================================================================
' �������������� ��������� ������� g_oProps ��� ���� ������� �� ����������, 
' ��� ������� � 1-�� ������������� �������� (i:*) �� ������ hide-on-create/edit
' ��������: ������������ g_oProps
'	[in] oXmlObject - ������� xml-������ �� ����� XSLT �������
'	[in] oTypeMD 	- ���������� ���� (���� ds:type)
'	[in] bCreating  - true - ���� ����� �������� �������, ����� false
Function InitPropListForAllProps(oXmlObject, oTypeMD, bCreating)
	Dim sPropName	'
	Dim sXPath		'
	Dim oNode		' 
	
	If bCreating Then
		sXPath = "ds:prop[not(i:*[1]/@hide-on-create)]"
	Else
		sXPath = "ds:prop[not(i:*[1]/@hide-on-edit)]"
	End If
	For Each oNode In oTypeMD.selectNodes(sXPath)
		sPropName = oNode.getAttribute("n")
		If Not oXmlObject.selectSingleNode(sPropName) Is Nothing Then
			If Not g_oProps.Exists(sPropName) Then
				g_oProps.Add sPropName, Nothing
			End If
		End If
	Next
End Function


'==========================================================================
' �������������� ��������� ������� � ���������� (g_oProps) �� ��������� PROPLIST ("������" ������ x-editor.xsl)
' ��������: ������������ g_oProps
'	[in] sPropList - �������� ��������� PROPLIST. ������: Prop1;Prop2;-;Prop3
Sub InitPropListFromLegacyFormat(sPropList)
	Dim sPropName
	Dim aProp
	Dim i, j
	Dim oPropParams
	
	aProp = Split(sPropList, ";")
	For i = 0 To UBound(aProp)
		sPropName = aProp(i)
		If sPropName = "-" Or sPropName = "--" Or sPropName = "---" Then
			For j=i-1 To 0 Step -1
				If Left(aProp(j),1) <> "-" Then
					Set oPropParams = g_oProps.item(aProp(j))
					If oPropParams Is Nothing Then
						Set oPropParams = CreateObject("Scripting.Dictionary")
						oPropParams.CompareMode = vbTextCompare
						Set g_oProps.item(aProp(j)) = oPropParams
					End If
					oPropParams.item("separator-after") = Len(sPropName)
				End If
			Next
		ElseIf Not g_oProps.Exists(sPropName) Then
			g_oProps.Add sPropName, Nothing
		End If
	Next
End Sub


'==========================================================================
' ���������� ��������� ��� ��������, ���� ������ ������ ��� ���������� ������
Function GetNextPropName()
	GetNextPropName = ""
	If IsEmpty( g_nCurrentProp) then Exit Function
	If g_nCurrentProp >= g_nPropCount then Exit Function
	GetNextPropName = Trim( g_oProps.Keys()(g_nCurrentProp))
	' �������������� ���������� �������
	g_nCurrentProp = g_nCurrentProp + 1
End Function


'==========================================================================
' ���������� �������� ��������� ��������� �������� ��������, 
' ���� ���������� ��������� ��������, ���� �������� �� ���������
Function GetCurrentPropParam(sParamValue, vDefaultValue)
	Dim oParamDict		' As Scripting.Dictionary - ��������� ���������� �������� ��������
	Dim sPropName		' ������������ ��������
	
	GetCurrentPropParam = vDefaultValue
	If IsEmpty( g_nCurrentProp) then Exit Function
	If g_nCurrentProp > g_nPropCount then Exit Function
	' -1, �.�. � GetNextPropName g_nCurrentProp ��� ���������������
	sPropName = g_oProps.Keys()(g_nCurrentProp - 1) 
	Set oParamDict = g_oProps.Item(sPropName)
	If Not oParamDict Is Nothing Then
		If oParamDict.Exists(sParamValue) Then
			GetCurrentPropParam = oParamDict.item(sParamValue)
		End If
	End If
End Function


'==========================================================================
' ������� � ���������� IXMLDOMElement � ����������� �������� ��������
' ������������ ���� params � ����������, ���������������� ���������� �������� ��������
' ��� ����, ������������ �������� - ���� ������������ ���������, �������� �������� - �������� ���������
' ���� ��������� ��� �������� �������� �� ������, �� ������������ ������ ���� params
'	[in] oContext As IXMLDOMNodeList - XSLT-�������� ������ �������
'	[retvla] As IXMLDOMElement
Function GetCurrentPropXmlParams(oContext)
	Dim oXmlRootDoc		' As IXMLDOMDocument
	Dim oXmlRoot		' As IXMLDOMElement
	Dim oParamDict		' As Scripting.Dictionary - ��������� ���������� �������� ��������
	Dim sPropName		' ������������ ��������
	Dim sKey			' As String - ��� ���������
	
	Set oXmlRootDoc = oContext.item(0).ownerDocument.cloneNode(false)
	Set oXmlRoot = oXmlRootDoc.createElement("params")
	oXmlRootDoc.appendChild oXmlRoot
	Set GetCurrentPropXmlParams = oXmlRoot

	sPropName = g_oProps.Keys()(g_nCurrentProp - 1) 
	Set oParamDict = g_oProps.Item(sPropName)
	If Not oParamDict Is Nothing Then
		For Each sKey In oParamDict.Keys()
			oXmlRoot.setAttribute sKey, oParamDict.item(sKey)
		Next
	End If
End Function

'%>']]>
</msxsl:script>

<!-- ������� ���������� ������������� ����������� HR -->
<xsl:variable name="off-hr" select="number(q:GetValueInt('DisableHR',0))"/>

<!-- ������ ������������ �� �������� ��������� ������� -->
<xsl:variable name="array-height" select="number(q:GetValueInt('ArrayHeight',200))"/>

<!-- ������ �������� ������� -->
<xsl:variable name="main-table-height" select="q:GetValue('MainTableHeight', '0')"/>

<xsl:template match="*">
	<!-- 
		���� ������������ ��������/������ ���������� �������, �������� ����� �������,
		������������ ��� ���������� ����������� ���������� �������� � ������� �����.
		����� � ��� ���������� ����� ������ 0, ��� ������� �� ������� � ������ ���������� ��-��
	-->
	<!-- ��� ��������, �� ������� ��������� ����������� ��������� �������� -->
	<xsl:variable name="build-on-name" select="b:GetSpecialName('built-on')"/>
	<!-- ��� ���������� �������� ����� -->
	<xsl:variable name="order-by-name" select="b:GetSpecialName('order-by')"/>	
	
	<!-- �������� �������, � ������� ����� ��������� ��-�� ������� -->
	<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" WIDTH="100%">
		<xsl:if test="$main-table-height != '0'">
			<xsl:attribute name="height"><xsl:value-of select="$main-table-height"/></xsl:attribute>
		</xsl:if>
		<COL />
		<COL width="100%"/>
		<TBODY>
			<xsl:value-of select="user:InitPropListIterator(q:SerializeToXml(), current(), b:GetTypeMD(string(name())), d:IsObjectCreationMode() )" />
			<xsl:call-template name="x-editor-xsl-template-iterate-props">
				<xsl:with-param name="build-on-name" select="$build-on-name"/>
				<xsl:with-param name="order-by-name" select="$order-by-name"/>
				<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
			</xsl:call-template>
		</TBODY>
	</TABLE>
</xsl:template>

<!-- 
	=============================================================================================
	���������� ����������� ������� ��� ����������� ����������������� ������ ��-� �� ������ 
	[in] build-on-name	- ��� ��������, �� ������� ��������� ����������� ��������� ��������
	[in] order-by-name	- ��� ���������� �������� �����
	[in] current-name	- ��� �������� ��������� �������� (��� ������ ������ - ���� ������ ��-� ����������)
-->
<xsl:template name="x-editor-xsl-template-iterate-props">
	<!-- ��� ��������, �� ������� ��������� ����������� ��������� �������� -->
	<xsl:param name="build-on-name" />
	<!-- ��� ���������� �������� ����� -->
	<xsl:param name="order-by-name" />
	<!-- ��� �������� ��������� �������� -->
	<xsl:param name="current-name" />

	<!--  �������� �� �������� ����� �������-->
	<xsl:if test="''!=$current-name">
		<xsl:if test="user:GetCurrentPropParam('display', '1') != '0'">
			<xsl:variable name="hide-if" select="user:GetCurrentPropParam('hide-if', '')"/>
			<xsl:choose>
				<xsl:when test="$hide-if != ''">
					<xsl:if test="not(b:Evaluate($hide-if))">
						<xsl:call-template name="x-editor-xsl-template-render-prop">
							<xsl:with-param name="build-on-name" select="$build-on-name"/>
							<xsl:with-param name="order-by-name" select="$order-by-name"/>
							<xsl:with-param name="current-name" select="$current-name"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="x-editor-xsl-template-render-prop">
						<xsl:with-param name="build-on-name" select="$build-on-name"/>
						<xsl:with-param name="order-by-name" select="$order-by-name"/>
						<xsl:with-param name="current-name" select="$current-name"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- ����������� ����� ��� ���������� ��������� -->
		<xsl:call-template name="x-editor-xsl-template-iterate-props">
			<xsl:with-param name="build-on-name" select="$build-on-name"/>
			<xsl:with-param name="order-by-name" select="$order-by-name"/>
			<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- -->
<xsl:template name="x-editor-xsl-template-render-prop">
	<!-- ��� ��������, �� ������� ��������� ����������� ��������� �������� -->
	<xsl:param name="build-on-name" />
	<!-- ��� ���������� �������� ����� -->
	<xsl:param name="order-by-name" />
	<!-- ��� �������� ��������� �������� -->
	<xsl:param name="current-name" />
	<xsl:variable name="sep-before" select="user:GetCurrentPropParam('separator-before', '0')"/>
	<xsl:variable name="sep-after"  select="user:GetCurrentPropParam('separator-after', '0')"/>
	
	<!-- ����� � ������� � ������� ��-�� � ��������� ������ -->
	<xsl:for-each select="user:selectNodes(current(), $current-name)">
		<xsl:if test="$sep-before != '0'">
			<tr><td colspan="2"><hr class="x-editor-hr-{$sep-before}"/></td></tr>
		</xsl:if>
		<xsl:call-template name="x-editor-xsl-template-internal-any">
			<xsl:with-param name="build-on-name" select="$build-on-name"/>
			<xsl:with-param name="order-by-name" select="$order-by-name"/>
		</xsl:call-template>
		<xsl:if test="$sep-after != '0'">
			<tr><td colspan="2"><hr class="x-editor-hr-{$sep-after}"/></td></tr>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- 
	=============================================================================================
	���������� ������� ��� ����������� ������ ������ ��������... 
	[in] build-on-name - ��� ��������, �� ������� ��������� ����������� ��������� ��������
	[in] order-by-name - ��� ���������� �������� �����
-->
<xsl:template name="x-editor-xsl-template-internal-any">
	<!-- ��� ��������, �� ������� ��������� ����������� ��������� �������� -->
	<xsl:param name="build-on-name" />
	<!-- ��� ���������� �������� ����� -->
	<xsl:param name="order-by-name" />

	<!-- ���������� �������� -->	
	<xsl:variable name="xml-prop-md" select="b:GetPropMD(current())"/>
	<!-- ��� �������� -->
	<xsl:variable name="prop-name" select="name()"/>
	<!-- ��� �������� �������� -->
	<xsl:variable name="prop-vt" select="string($xml-prop-md/@vt)"/>
	
	<!-- ������� �������� -->
	<xsl:variable name="prop-capacity" select="string($xml-prop-md/@cp)"/>
	<xsl:variable name="prop-d-script" select="b:Evaluate(user:GetCurrentPropParam('description-vbs', ''))"/>
	<xsl:variable name="prop-d-static" select="user:GetCurrentPropParam('description', string($xml-prop-md/@d))"/>
	<!-- �������� �������� -->
	<xsl:variable name="prop-d" select="w:nvl($prop-d-script,$prop-d-static)"/>
	<!-- ������� ������������ ������� �������� -->
	<xsl:variable name="prop-maybenull" select="user:GetCurrentPropParam('maybenull', string($xml-prop-md/@maybenull))"/>
				
	<!-- � ����������� �� ���� �������� ������ UI -->
	<xsl:choose>
		<!-- ������ -->
		<xsl:when test="$prop-vt='string' or $prop-vt='text'">
			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<!-- ������������ ����� ������ -->
			<xsl:variable name="prop-max" select="number($xml-prop-md/ds:max)"/>
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	

			<tr>
				<xsl:choose>
					<!-- ��� ������� ����� ����� ������������ ������� -->
					<xsl:when test="$prop-max &gt; 256 or $prop-vt='text'">
						<xsl:call-template name="prop-caption-template">
							<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
							<xsl:with-param name="prop-d" select="$prop-d"/>
							<xsl:with-param name="valign" select="top"/>
							<xsl:with-param name="class-name" select="'x-editor-propcaption-multiline'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="prop-caption-template">
							<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
							<xsl:with-param name="prop-d" select="$prop-d"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<!-- ��� ������� ����� ����� �������� ������������� ���� -->
					<xsl:when test="$prop-max &gt; 256 or $prop-vt='text'">
						<td>
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- �������� ���������� ����������� ������ �� ������ -->
					<xsl:when test="$xml-prop-md/i:string-lookup/@ot">
						<td>
							<xsl:call-template name="std-template-string-lookup">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- �������� -->
					<xsl:when test="$xml-prop-md/i:const-value-selection">
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- ������������ ���� -->
					<xsl:otherwise>
						<td>
							<xsl:call-template name="std-template-string">
								<xsl:with-param name="description"><xsl:value-of select="user:GetCurrentPropParam('description', $prop-d)"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="user:GetCurrentPropParam('maybenull', $prop-maybenull)"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:when>

		<!-- ����� -->
		<xsl:when test="($prop-vt='i2' or $prop-vt='i4' or $prop-vt='r4' or $prop-vt='r8' or $prop-vt='fixed' or $prop-vt='ui1') and $order-by-name!=$prop-name">

			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<xsl:call-template name="prop-caption-template">
					<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
					<xsl:with-param name="prop-d" select="$prop-d"/>
				</xsl:call-template>
				<td>
					<xsl:choose>
						<!-- ������� ����� -->
						<xsl:when test="$xml-prop-md/i:bits">
							<xsl:call-template name="std-template-flags">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</xsl:when>

						<!-- �������� -->
						<xsl:when test="$xml-prop-md/i:const-value-selection">
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</xsl:when>

						<!-- ���� ����� -->
						<xsl:otherwise>
							<xsl:call-template name="std-template-number">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</xsl:when>

		<!-- ������ �������� -->
		<xsl:when test="$prop-vt='boolean'">

			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<xsl:choose>
					<!-- �������� -->
					<xsl:when test="$xml-prop-md/i:const-value-selection">
						<xsl:call-template name="prop-caption-template">
							<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
							<xsl:with-param name="prop-d" select="$prop-d"/>
						</xsl:call-template>
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- ������� -->
					<xsl:otherwise>
						<td valign="top">
							<br />
						</td>
						<td>
							<xsl:call-template name="std-template-bool">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
								<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
								<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
			</tr>
		</xsl:when>

		<!-- UUID -->
		<xsl:when test="$prop-vt='uuid'">

			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<xsl:call-template name="prop-caption-template">
					<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
					<xsl:with-param name="prop-d" select="$prop-d"/>
				</xsl:call-template>
				<td>
					<xsl:call-template name="std-template-string">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
						
		<!-- ���� -->
		<xsl:when test="$prop-vt='dateTime' or $prop-vt='date' or $prop-vt='time'">

			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	

			<tr>
				<xsl:call-template name="prop-caption-template">
					<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
					<xsl:with-param name="prop-d" select="$prop-d"/>
				</xsl:call-template>
				<td>
					<xsl:call-template name="std-template-date">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
		
		<!-- ������ -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='scalar' or $prop-capacity='link-scalar')">
			<!-- �������� ����� ��������� ��-�, � ������� ������������ ������������ ������ (�� ��������� �������� ��� ������ ������� ��������) -->
			<xsl:if test="($prop-capacity='scalar' and $build-on-name!=$prop-name or $prop-capacity='link-scalar' and $xml-prop-md/@built-on != b:GetSpecialName('n')) and ($xml-prop-md/i:object-presentation or $xml-prop-md/i:object-dropdown)">
				<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
				<xsl:if test="0=$off-hr">
					<xsl:if test="user:IsNotFirst()">
						<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
					</xsl:if>
				</xsl:if>	
				<tr>
					<xsl:call-template name="prop-caption-template">
						<xsl:with-param name="prop-maybenull" select="w:iif(string($prop-maybenull)='1' or $prop-capacity='link-scalar','1','0')"/>
						<xsl:with-param name="prop-d" select="$prop-d"/>
					</xsl:call-template>
					<td>
						<xsl:call-template name="std-template-object">
							<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
							<xsl:with-param name="maybenull"><xsl:value-of select="w:iif(string($prop-maybenull)='1' or $prop-capacity='link-scalar','1','0')"/></xsl:with-param>
							<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
							<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
		</xsl:when>
						
		<!-- �������� -->
		<xsl:when test="$prop-vt='bin'">

			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<xsl:call-template name="prop-caption-template">
					<xsl:with-param name="prop-maybenull" select="$prop-maybenull"/>
					<xsl:with-param name="prop-d" select="$prop-d"/>
				</xsl:call-template>
				<td>
					<xsl:call-template name="std-template-file">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>

		<!-- ������/��������� � list-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and $xml-prop-md/i:list-selector">
			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="user:GetCurrentPropParam('height',$array-height)"/>
				<td height="{$this-array-height}" width="100%" colspan="2">
					<xsl:call-template name="std-template-objects-selector">
						<xsl:with-param name="height">100%</xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>

		<!-- ������/��������� � tree-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and $xml-prop-md/i:tree-selector">
			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="user:GetCurrentPropParam('height',$array-height)"/>
				<td height="{$this-array-height}" width="100%" colspan="2">
					<xsl:call-template name="std-template-objects-tree-selector">
						<xsl:with-param name="height">100%</xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
		
		<!-- ������/����/��������� � element-list'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='link' or $prop-capacity='collection' or $prop-capacity='array-membership' or $prop-capacity='collection-membership') and $xml-prop-md/i:elements-list">
			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	
			<tr>
				<td valign="top" colspan="2" class="x-editor-text x-editor-propcaption">
					<xsl:value-of select="$prop-d"/>:
				</td>
			</tr>
			<tr>
				<xsl:variable name="this-array-height" select="user:GetCurrentPropParam('height',$array-height)"/>
				<td height="{$this-array-height}" width="100%" colspan="2">
					<xsl:call-template name="std-template-objects">
						<xsl:with-param name="height">100%</xsl:with-param>
						<xsl:with-param name="xml-params" select="user:GetCurrentPropXmlParams(current())"/>
						<xsl:with-param name="xml-prop-md" select="$xml-prop-md"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
	</xsl:choose>
</xsl:template>	

<xsl:template name="prop-caption-template">
	<xsl:param name="prop-maybenull"/>
	<xsl:param name="prop-d"/>
	<xsl:param name="valign" select="'middle'"/>
	<xsl:param name="class-name" select="''"/>

	<td>
		<xsl:attribute name="vAlign"><xsl:value-of select="$valign"/></xsl:attribute>
		<xsl:choose>
			<xsl:when test="1=$prop-maybenull">
				<xsl:attribute name="class">x-editor-text x-editor-propcaption <xsl:value-of select="$class-name"/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="class">x-editor-text x-editor-propcaption <xsl:value-of select="$class-name"/> x-editor-propcaption-notnull</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<NOBR><xsl:value-of select="$prop-d"/>:</NOBR>
	</td>
</xsl:template>

<!-- ����������� ������ ��� �����������/����������� ������������ �������� ��-� -->
<xsl:include href="x-pe-file.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��-� -->
<xsl:include href="x-pe-string.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ �������� ��-� -->
<xsl:include href="x-pe-number.xsl"/>
<!-- ����������� ������ ��� �����������/����������� �������� ������ ��-� -->
<xsl:include href="x-pe-flags.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��-�  ���� � �������-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
<xsl:include href="x-pe-object.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
<xsl:include href="x-pe-objects.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ��������� ��������� ��-� � ���� read-only ������ -->
<xsl:include href="x-pe-objects-selector.xsl"/>
<!-- ����������� ������ ��� ����������� /����������� ��������� ��������� ��-� � ���� ������ � ���������� -->
<xsl:include href="x-pe-objects-tree-selector.xsl"/>
<!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
