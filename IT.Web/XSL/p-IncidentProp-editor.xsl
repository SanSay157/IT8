<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	�������� ��������� �������� ���������
	������ ��� �������
	������ ��� �������
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>
	
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
	
	<xsl:variable name="current-page-no" select="q:GetValueInt('page',0)"/>
	
	<CENTER>
		<!-- �������� �������, � ������� ����� ��������� ��-�� ������� -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" style="table-layout1:fixed;">
			<COL WIDTH="40%"/>
			<COL WIDTH="60%"/>
			<tbody>
				<!-- ������������ � ��� ���������� ������ �� ������ �������� -->
				<xsl:if test="$current-page-no=0">
					<xsl:for-each select="IncidentType">
						<xsl:if test="name()!=$build-on-name">
							<tr>
								<td>
									<xsl:choose>
										<xsl:when test="1=b:MDQueryProp(current(), '@maybenull')">
											<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">x-editor-text x-editor-propcaption-notnull</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="b:MDQueryProp(current(), '@d')"/>:
								</td>
								<td>
									<xsl:call-template name="std-template-object-presentation"/>
								</td>
							</tr>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>
						</xsl:if>		
					</xsl:for-each>
					<xsl:for-each select="Name">
						<tr>
							<td>
								<xsl:choose>
									<xsl:when test="1=b:MDQueryProp(current(), '@maybenull')">
										<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">x-editor-text x-editor-propcaption-notnull</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="b:MDQueryProp(current(), '@d')"/>:
							</td>
							<td>
								<xsl:call-template name="std-template-string"/>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:for-each select="Type">
						<tr>
							<td>
								<xsl:choose>
									<xsl:when test="1=b:MDQueryProp(current(), '@maybenull')">
										<xsl:attribute name="class">x-editor-text x-editor-propcaption</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">x-editor-text x-editor-propcaption-notnull</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="b:MDQueryProp(current(), '@d')"/>:
							</td>
							<td>
								<xsl:call-template name="std-template-selector">
									<xsl:with-param name="selector" select="'combo'"/>
                  <xsl:with-param name="disabled">
                    <xsl:choose>
                      <xsl:when test="d:get-IsWizard()">0</xsl:when>
                      <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                </xsl:call-template>
							</td>
						</tr>
					</xsl:for-each>
					<xsl:if test="not(d:get-IsObjectCreationMode())">
						<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						<tr>
							<td/>
							<td>
								<xsl:for-each select="IsArchive">
									<xsl:call-template name="std-template-bool"/>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:if>
				</xsl:if>									
				
				<xsl:if test="($current-page-no!=0)">
					<xsl:variable name="type" select="number(Type)"/>
					<xsl:choose>
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_LONG()">
							<xsl:for-each select="DefDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� ��������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'����������� ��������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ ��������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'������������ ��������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DOUBLE()">
							<xsl:for-each select="DefDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� ��������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'����������� ��������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ ��������:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'������������ ��������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>						
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_STRING()">
							<xsl:for-each select="DefText">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
											<xsl:with-param name="max" select="'4000'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� �����:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'����������� �����'"/>
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="max" select="'4000'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ �����:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'������������ �����'"/>
											<xsl:with-param name="max" select="'4000'"/>
											<xsl:with-param name="vt" select="'i4'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_TEXT()">
							<xsl:for-each select="DefText">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� �����:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'����������� �����'"/>
											<xsl:with-param name="vt" select="'i4'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ �����:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'������������ �����'"/>
											<xsl:with-param name="vt" select="'i4'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>
						
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DATE()">
							<xsl:for-each select="DefDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="vt" select="'date'"/>
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'����������� ��������'"/>
											<xsl:with-param name="vt" select="'date'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'������������ ��������'"/>
											<xsl:with-param name="vt" select="'date'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>

						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_TIME()">
							<xsl:for-each select="DefDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
											<xsl:with-param name="vt" select="'time'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'����������� ��������'"/>
											<xsl:with-param name="vt" select="'time'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="vt" select="'time'"/>
											<xsl:with-param name="description" select="'������������ ��������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>

						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DATEANDTIME()">
							<xsl:for-each select="DefDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">����������� ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'����������� ��������'"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">������������ ��������:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'������������ ��������'"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>

						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_BOOLEAN()">
							<xsl:for-each select="DefDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">�������� �� ���������:</td>
									<td>
										<xsl:call-template name="std-template-selector">
											<xsl:with-param name="description" select="'�������� �� ���������'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>						
					</xsl:choose>					
					<tr>
						<td/>
						<td>
							<xsl:for-each select="IsMandatory">
								<xsl:call-template name="std-template-bool"/>
							</xsl:for-each>
						</td>
					</tr>
          <xsl:if test="$type=w:get-IPROP_TYPE_IPROP_TYPE_PICTURE() or $type=w:get-IPROP_TYPE_IPROP_TYPE_FILE()">
					  <tr>
						  <td/>
						  <td>
							  <xsl:for-each select="IsArray">
								  <xsl:call-template name="std-template-bool"/>
							  </xsl:for-each>
						  </td>
					  </tr>		
          </xsl:if>
          <!--<tr>
						<td/>
						<td>
							<xsl:for-each select="IsArchive">
								<xsl:call-template name="std-template-bool"/>
							</xsl:for-each>
						</td>
					</tr>-->
				</xsl:if>
			</tbody>
		</TABLE>
	</CENTER>
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
