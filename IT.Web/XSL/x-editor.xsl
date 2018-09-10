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
				PROPLIST  -	������ ���� �������, ����������	����������� �� �������� � ����������� 
								������o����������� ����� ;. ��� ��������� PROPLIST ��������� i:hide-in-* ������������.
								��������! � ������ ���� ������ ����� �������� "-" �� ����������� �������������� �����������
				DisableHR - ������ �� �������������� �����������
				ArrayHeight - ������ ������������ �� �������� ��������� �������				
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
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
<msxsl:script language="VBScript" implements-prefix="user">
	<![CDATA['<%

	Dim g_aProps		' ������ ���� ������� ��-�
	Dim g_nCurrentProp	' ������ �������� ��-�� � ������ g_aProps
	Dim g_bNotFirst		' ������� ��-������� ������ ������� IsFirst()

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
	' [in] sPropList - ������ ������������ ��-� ����� ";"
	' ���������� ���-�� ������� � ������
	Function InitPropListIterator(ByVal sPropList)
		sPropList = Trim( "" & sPropList) 
		g_nCurrentProp = 0
		if 0=Len( sPropList) then
			InitPropListIterator = 0
		else
			g_aProps = Split( sPropList, ";")
			InitPropListIterator = UBound( g_aProps)+1
		end if
	End Function
	
	'==========================================================================
	' ���������� ��������� ��� �������� ���� ������ ������ ��� ���������� ������
	Function GetNextPropName()
		GetNextPropName = ""
		if IsEmpty( g_nCurrentProp) then Exit Function
		if not IsArray( g_aProps)	then Exit Function
		if g_nCurrentProp > UBound( g_aProps) then Exit Function
		GetNextPropName = Trim( g_aProps( g_nCurrentProp))
		' �������������� ���������� �������
		g_nCurrentProp = g_nCurrentProp + 1
	End Function
	
	'%>']]>
</msxsl:script>

<!-- ������� ���������� ������������� ����������� HR -->
<xsl:variable name="off-hr" select="number(q:GetValueInt('DisableHR',0))"/>

<!-- ������ ������������ �� �������� ��������� ������� -->
<xsl:variable name="array-height" select="number(q:GetValueInt('ArrayHeight',200))"/>




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
	
	<CENTER>
		<!-- �������� �������, � ������� ����� ��������� ��-�� ������� -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" style="table-layout1:fixed;">
			<COL WIDTH="40%"/>
			<COL WIDTH="60%"/>
			<TBODY>
				<xsl:choose>
					<!-- � ���������� ������ ������ ������� -->
					<xsl:when test="0!=user:InitPropListIterator(q:GetValue('PROPLIST',''))">
						<!-- ��������� � ��������� -->
						<xsl:call-template name="x-editor-xsl-template-iterate-props">
							<xsl:with-param name="build-on-name" select="$build-on-name"/>
							<xsl:with-param name="order-by-name" select="$order-by-name"/>
							<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
						</xsl:call-template>
					</xsl:when>
					<!-- ��������� ������� ��� ���� ������� -->
					<xsl:otherwise>
						<xsl:for-each select="*">
							<!-- 
								���� �� ��������� � ��� ������, � ������� ����������� �������� ��-��
								�� ��������� - ����������� �����. HTML-��� ��� ��� �����������/�����������
							 -->
							<xsl:if test="(d:IsObjectCreationMode() and not(b:MDQueryProp(current(), 'i:behavior/@hide-on-create'))) or (not(d:IsObjectCreationMode()) and not(b:MDQueryProp(current(), 'i:behavior/@hide-on-edit')))" >
								<xsl:call-template name="x-editor-xsl-template-internal-any">
									<xsl:with-param name="build-on-name" select="$build-on-name"/>
									<xsl:with-param name="order-by-name" select="$order-by-name"/>
								</xsl:call-template>
							</xsl:if>	
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</TBODY>
		</TABLE>
	</CENTER>
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
		<xsl:choose>
			<xsl:when test="'-'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
			</xsl:when>
			<xsl:when test="'--'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr-2"/></td></tr>
			</xsl:when>
			<xsl:when test="'---'=$current-name">
				<tr><td colspan="2"><hr class="x-editor-hr-3"/></td></tr>
			</xsl:when>
			<xsl:otherwise>
				<!-- ����� � ������� � ������� ��-�� � ��������� ������ -->
				<xsl:for-each select="*[name()=$current-name]">
					<xsl:call-template name="x-editor-xsl-template-internal-any">
						<xsl:with-param name="build-on-name" select="$build-on-name"/>
						<xsl:with-param name="order-by-name" select="$order-by-name"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		<!-- ����������� ����� ��� ���������� ��������� -->
		<xsl:call-template name="x-editor-xsl-template-iterate-props">
			<xsl:with-param name="build-on-name" select="$build-on-name"/>
			<xsl:with-param name="order-by-name" select="$order-by-name"/>
			<xsl:with-param name="current-name" select="user:GetNextPropName()"/>
		</xsl:call-template>
	</xsl:if>
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
	
	<!-- ��� �������� -->
	<xsl:variable name="prop-name" select="name()"/>
	<!-- ��� �������� �������� -->
	<xsl:variable name="prop-vt" select="b:MDQueryProp(current(), '@vt')"/>
	<!-- ������� �������� -->
	<xsl:variable name="prop-capacity" select="b:MDQueryProp(current(), '@cp')"/>
	<!-- �������� �������� -->
	<xsl:variable name="prop-d" select="q:GetValue(concat(name(),'-title') ,b:MDQueryProp(current(), '@d'))"/>
	<!-- ������� ������������ ������� �������� -->
	<xsl:variable name="prop-maybenull" select="q:GetValue(concat(name(),'-maybenull') ,b:MDQueryProp(current(), '@maybenull'))"/>				
				
	<!-- � ����������� �� ���� �������� ������ UI -->
	<xsl:choose>
		<!-- ������ -->
		<xsl:when test="$prop-vt='string' or $prop-vt='text'">
			<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
			<!-- ������������ ����� ������ -->
			<xsl:variable name="prop-max" select="b:MDQueryProp(current(), 'ds:max')"/>
			<xsl:if test="0=$off-hr">
				<xsl:if test="user:IsNotFirst()">
					<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
				</xsl:if>
			</xsl:if>	

			<tr>
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<xsl:choose>
					<!-- ��� ������� ����� ����� �������� ������������� ���� -->
					<xsl:when test="$prop-max &gt; 256 or $prop-vt='text'">
						<td>
							<xsl:call-template name="std-template-text">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- �������� ���������� ����������� ������ �� ������ -->
					<xsl:when test="b:MDQueryProp(current(), 'i:string-lookup/@ot')">
						<td>
							<xsl:call-template name="std-template-string-lookup">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- �������� -->
					<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<!-- ������������ ���� -->
					<xsl:otherwise>
						<td>
							<xsl:call-template name="std-template-string">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
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
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:choose>
						<!-- ������� ����� -->
						<xsl:when test="b:MDQueryProp(current(), 'i:bits')">
							<xsl:call-template name="std-template-flags"/>
						</xsl:when>

						<!-- �������� -->
						<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>

						<!-- ���� ����� -->
						<xsl:otherwise>
							<xsl:call-template name="std-template-number">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
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
					<xsl:when test="b:MDQueryProp(current(), 'i:const-value-selection')">
						<td valign="top">
							<xsl:choose>
								<xsl:when test="1=$prop-maybenull">
									<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>									
							<xsl:value-of select="$prop-d"/>:
						</td>
						<td>
							<xsl:call-template name="std-template-selector">
								<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
								<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
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
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-string">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
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
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-date">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>
		
		<!-- ������ -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='scalar' or $prop-capacity='link-scalar' )">
			<!-- �������� ����� ��������� ��-�, � ������� ������������ ������������ ������ (�� ��������� �������� ��� ������ ������� ��������) -->
			<xsl:if test="($prop-capacity='scalar' and $build-on-name!=$prop-name or $prop-capacity='link-scalar' and b:MDQueryProp(current(),'@built-on')!=b:GetSpecialName('n')) and (b:IsMDPropExists(current(), 'i:object-presentation') or b:IsMDPropExists(current(), 'i:object-dropdown'))">
				<!-- ���� ��� ��-�� �� ������ �� ������������ - ������� ����� ��� ����������� -->
				<xsl:if test="0=$off-hr">
					<xsl:if test="user:IsNotFirst()">
						<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
					</xsl:if>
				</xsl:if>	
				<tr>
					<td valign="top">
						<xsl:choose>
							<xsl:when test="1=$prop-maybenull">
								<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>									
						<xsl:value-of select="$prop-d"/>:
					</td>
					<td>
						<xsl:call-template name="std-template-object">
							<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
							<xsl:with-param name="maybenull"><xsl:value-of select="w:iif(string($prop-maybenull)='1' or $prop-capacity='link-scalar','1','0')"/></xsl:with-param>
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
				<td valign="top">
					<xsl:choose>
						<xsl:when test="1=$prop-maybenull">
							<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">x-editor-text x-editor-propcaption x-editor-propcaption-notnull</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>									
					<xsl:value-of select="$prop-d"/>:
				</td>
				<td>
					<xsl:call-template name="std-template-file">
						<xsl:with-param name="description"><xsl:value-of select="$prop-d"/></xsl:with-param>
						<xsl:with-param name="maybenull"><xsl:value-of select="$prop-maybenull"/></xsl:with-param>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:when>

		<!-- ������/��������� � list-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:list-selector')">
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
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- �� ��������� ��� ��������� ��������� ��-�� ������� � �������=200 -->
			</tr>
		</xsl:when>

		<!-- ������/��������� � tree-selector'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='collection' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:tree-selector')">
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
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-tree-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects-tree-selector">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- �� ��������� ��� ��������� ��������� ��-�� ������� � �������=200 -->
			</tr>
		</xsl:when>
		
		<!-- ������/����/��������� � element-list'e -->
		<xsl:when test="$prop-vt='object' and ($prop-capacity='array' or $prop-capacity='link' or $prop-capacity='collection' or $prop-capacity='array-membership' or $prop-capacity='collection-membership') and b:IsMDPropExists( current(), 'i:elements-list')">
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
				<xsl:variable name="this-array-height" select="number(q:GetValueInt(concat(name(),'-height'),$array-height))"/>
				<xsl:variable name="this-array-metaname" select="q:GetValue(concat(name(),'-metaname'),'')"/>
				<xsl:choose>
					<xsl:when test="''!=$this-array-metaname"> 
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
								<xsl:with-param name="metaname"><xsl:value-of select="$this-array-metaname"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="{$this-array-height}" width="100%" colspan="2">
							<xsl:call-template name="std-template-objects">
								<xsl:with-param name="height"><xsl:value-of select="$this-array-height"/></xsl:with-param>
							</xsl:call-template>
						</td>
					</xsl:otherwise>
				</xsl:choose>
				<!-- �� ��������� ��� ��������� ��������� ��-�� ������� � �������=200 -->
			</tr>
		</xsl:when>
	</xsl:choose>
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
