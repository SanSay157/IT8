<?xml version="1.0" encoding="windows-1251"?>
<!--
	=============================================================================================
	Страница редактора активности / папки (Folder) 
	=============================================================================================
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:XService="urn:x-client-service"
	xmlns:q="urn:query-string-access"
	xmlns:d="urn:object-editor-access"
	xmlns:w="urn:editor-window-access"
	xmlns:b="urn:x-page-builder"
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	user:off-cache="1"
>

<xsl:output 
	method="html" 
	version="4.0" 
	encoding="windows-1251"
	omit-xml-declaration="yes"
	media-type="text/html"/>

<xsl:template match="Folder">
	<!-- Основная таблица, в которой будут разложены св-ва объекта -->
	<TABLE BORDER="0" CELLSPACING="5" CELLPADDING="0" WIDTH="90%">
		<COL WIDTH="20%"/>
		<COL WIDTH="80%"/>
		<TBODY>
			<!-- Основные реквизиты: Организация-Клиент, наименование и коды активности -->
			<xsl:if test="@new and not(Customer/Organization)">
				<xsl:for-each select="Customer">
					<TR>
						<TD class="x-editor-text x-editor-propcaption"><NOBR>Клиент:</NOBR></TD>
						<TD>
							<xsl:call-template name="std-template-object" />
						</TD>
					</TR>
				</xsl:for-each>
			</xsl:if>
			
			<xsl:for-each select="Name">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>Наименование:</NOBR></TD>
					<TD>
						<xsl:if test="@read-only">
							<xsl:call-template name="std-template-string" >
								<xsl:with-param name="disabled" select="'1'" />
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="not(@read-only)">
							<xsl:call-template name="std-template-string"/>
						</xsl:if>
					</TD>
				</TR>
			</xsl:for-each>


      <xsl:for-each select="Owner">
        <TR>
          <TD class="x-editor-text x-editor-propcaption">
            <NOBR>Владелец:</NOBR>
          </TD>
          <TD>
            <xsl:if test="@read-only">
              <xsl:call-template name="std-template-object-dropdown" >
                <xsl:with-param name="disabled" select="'1'" />
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(@read-only)">
              <xsl:call-template name="std-template-object-dropdown"/>
            </xsl:if>
          </TD>
        </TR>
      </xsl:for-each>
      
      
			<!-- Поля "Внутренний код проекта" и "Код в Navision" доступны только для активностей -->
			<xsl:if test="not(w:IsDirectory())">
				<xsl:for-each select="ExternalID">
					<TR>
						<TD class="x-editor-text x-editor-propcaption"><NOBR>Код:</NOBR></TD>
						<TD>
							<xsl:if test="@read-only">
								<xsl:call-template name="std-template-string" >
									<xsl:with-param name="disabled" select="'1'" />
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="not(@read-only)">
								<xsl:call-template name="std-template-string"/>
							</xsl:if>
						</TD>
					</TR>
				</xsl:for-each>
			</xsl:if>
			<!-- Направления: только для активностей -->
			<xsl:if test="not(w:IsDirectory())">
				<xsl:for-each select="Directions">
					<TR>
						<TD COLSPAN="2" class="x-editor-text x-editor-propcaption" valign="bottom">Направления:</TD>
					</TR>
					<TR>
						<TD height="200" COLSPAN="2">
							<xsl:call-template name="std-template-objects-selector" />
						</TD>
					</TR>
				</xsl:for-each>
			</xsl:if>
			
			<TR><TD COLSPAN="2"><HR CLASS="x-editor-hr"/></TD></TR>
			
			<!-- Состояние и дата блокировки списания: если редактируем существующую папку -->
			<xsl:if test="not(@new)">
				<xsl:for-each select="State">
					<TR>
						<TD class="x-editor-text x-editor-propcaption"><NOBR>Состояние:</NOBR></TD>
						<TD>
							<xsl:if test="@read-only">
								<xsl:call-template name="std-template-selector" >
									<xsl:with-param name="disabled" select="'1'" />
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="not(@read-only)">
								<xsl:call-template name="std-template-selector" />
							</xsl:if>
						</TD>
					</TR>
				</xsl:for-each>
			</xsl:if>
			
			<!-- Тип инцидента по умолчанию -->
			<xsl:for-each select="DefaultIncidentType">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>Тип инцидента по умолчанию:</NOBR></TD>
					<TD>
            <xsl:if test="@read-only">
              <xsl:call-template name="std-template-object" >
                <xsl:with-param name="disabled" select="'1'" />
              </xsl:call-template>
            </xsl:if>
            <xsl:if test="not(@read-only)">
              <xsl:call-template name="std-template-object"/>
            </xsl:if>
					</TD>
				</TR>
			</xsl:for-each>
			<xsl:for-each select="IsLocked">
				<TR>
					<TD class="x-editor-text x-editor-propcaption"><NOBR>&#160;</NOBR></TD>
					<TD>
							<xsl:if test="@read-only">
								<xsl:call-template name="std-template-bool" >
									<xsl:with-param name="disabled" select="'1'" />
								</xsl:call-template>
							</xsl:if>
							<xsl:if test="not(@read-only)">
								<xsl:call-template name="std-template-bool" />
							</xsl:if>
					</TD>
				</TR>
			</xsl:for-each>
			
			
			<TR><TD COLSPAN="2"><HR CLASS="x-editor-hr"/></TD></TR>
			
			<!-- Описание -->
			<xsl:for-each select="Description">
				<TR>
					<TD COLSPAN="2" class="x-editor-text x-editor-propcaption" valign="bottom">Описание:</TD>
				</TR>
				<TR>
					<TD COLSPAN="2">
						<xsl:if test="@read-only">
							<xsl:call-template name="std-template-text" >
								<xsl:with-param name="minheight" select="'100'" />
								<xsl:with-param name="maxheight" select="'100'" />
								<xsl:with-param name="disabled" select="'1'" />
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="not(@read-only)">
							<xsl:call-template name="std-template-text" >
								<xsl:with-param name="minheight" select="'100'" />
								<xsl:with-param name="maxheight" select="'100'" />
							</xsl:call-template>
						</xsl:if>
						
					</TD>
				</TR>
			</xsl:for-each>
			
			<TR><TD COLSPAN="2"><HR CLASS="x-editor-hr"/></TD></TR>
			
			<!-- Служебные поля: -->
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption" COLSPAN="2"><B>Служебные поля</B></TD>
			</TR>
			<TR>
				<TD CLASS="x-editor-text x-editor-propcaption">Внутренний идентификатор:</TD>
				<TD>
					<INPUT READONLY="1" TYPE="TEXT" CLASS="x-editor-control x-editor-string-field" STYLE="width:100%; background-color:menu;">
						<xsl:attribute name="VALUE">
							<xsl:value-of select="@oid"/>
						</xsl:attribute>
					</INPUT>
				</TD>
			</TR>

		</TBODY>
	</TABLE>
</xsl:template>

<xsl:include href="x-pe-datetime.xsl"/>
<xsl:include href="x-pe-string.xsl"/>
<xsl:include href="x-pe-bool.xsl"/>
<xsl:include href="x-pe-object.xsl"/>
<xsl:include href="x-pe-objects-selector.xsl"/>
<xsl:include href="x-pe-selector.xsl"/>

</xsl:stylesheet>
