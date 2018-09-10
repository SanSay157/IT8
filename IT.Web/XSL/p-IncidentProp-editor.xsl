<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Страница редактора свойства инцидента
	Первый шаг мастера
	Второй шаг мастера
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
		Если отрисовываем редактор/мастер вложенного объекта, получаем имена свойств,
		используемых для построения вируального объектного свойства и индекса линка.
		Иначе в эти переменные будет занесён 0, что никогда не совпадёт с именем объектного св-ва
	-->
	<!-- имя свойства, на котором построено виртуальное объектное свойство -->
	<xsl:variable name="build-on-name" select="b:GetSpecialName('built-on')"/>
	<!-- имя индексного свойства линка -->
	<xsl:variable name="order-by-name" select="b:GetSpecialName('order-by')"/>
	
	<xsl:variable name="current-page-no" select="q:GetValueInt('page',0)"/>
	
	<CENTER>
		<!-- Основная таблица, в которой будут разложены св-ва объекта -->
		<TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" WIDTH="99%" style="table-layout1:fixed;">
			<COL WIDTH="40%"/>
			<COL WIDTH="60%"/>
			<tbody>
				<!-- Наименование и тип показываем только на первой странице -->
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
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'Минимальное значение'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="description" select="'Максимальное значение'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DOUBLE()">
							<xsl:for-each select="DefDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Минимальное значение'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Максимальное значение'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>						
						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_STRING()">
							<xsl:for-each select="DefText">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
											<xsl:with-param name="max" select="'4000'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальная длина:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Минимальная длина'"/>
											<xsl:with-param name="vt" select="'i4'"/>
											<xsl:with-param name="max" select="'4000'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальная длина:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Максимальная длина'"/>
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
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-text">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальная длина:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Минимальная длина'"/>
											<xsl:with-param name="vt" select="'i4'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDouble">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальная длина:</td>
									<td>
										<xsl:call-template name="std-template-number">
											<xsl:with-param name="description" select="'Максимальная длина'"/>
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
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="vt" select="'date'"/>
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Минимальное значение'"/>
											<xsl:with-param name="vt" select="'date'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Максимальное значение'"/>
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
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
											<xsl:with-param name="vt" select="'time'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Минимальное значение'"/>
											<xsl:with-param name="vt" select="'time'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="vt" select="'time'"/>
											<xsl:with-param name="description" select="'Максимальное значение'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<tr><td colspan="2"><hr class="x-editor-hr"/></td></tr>				
						</xsl:when>

						<xsl:when test="$type=w:get-IPROP_TYPE_IPROP_TYPE_DATEANDTIME()">
							<xsl:for-each select="DefDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MinDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Минимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Минимальное значение'"/>
											<xsl:with-param name="vt" select="'dateTime'"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:for-each>
							<xsl:for-each select="MaxDate">
								<tr>
									<td class="x-editor-text x-editor-propcaption">Максимальное значение:</td>
									<td>
										<xsl:call-template name="std-template-date">
											<xsl:with-param name="description" select="'Максимальное значение'"/>
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
									<td class="x-editor-text x-editor-propcaption">Значение по умолчанию:</td>
									<td>
										<xsl:call-template name="std-template-selector">
											<xsl:with-param name="description" select="'Значение по умолчанию'"/>
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



<!-- Стандартный шаблон для отображения/модификации произвольных двоичных св-в -->
<xsl:include href="x-pe-file.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных текстовых св-в -->
<xsl:include href="x-pe-string.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных числовых св-в -->
<xsl:include href="x-pe-number.xsl"/>
<!-- Стандартный шаблон для отображения/модификации двоичных флагов св-в -->
<xsl:include href="x-pe-flags.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных св-в  даты и времени-->
<xsl:include href="x-pe-datetime.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных скалярных объектных св-в -->
<xsl:include href="x-pe-object.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных массивных объектных св-в -->
<xsl:include href="x-pe-objects.xsl"/>
<!-- Стандартный шаблон для отображения/модификации массивных объектных св-в в виде read-only списка -->
<xsl:include href="x-pe-objects-selector.xsl"/>
<!-- Стандартный шаблон для отображения /модификации массивных объектных св-в в виде дерева с чекбоксами -->
<xsl:include href="x-pe-objects-tree-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации числовых св-в, поддерживающих выбор из набора значений -->
<xsl:include href="x-pe-selector.xsl"/>
<!-- Стандартный шаблон для отображения/модификации произвольных логических св-в -->
<xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
