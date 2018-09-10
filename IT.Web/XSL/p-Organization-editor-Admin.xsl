<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:XService="urn:x-client-service" xmlns:q="urn:query-string-access" xmlns:d="urn:object-editor-access" xmlns:w="urn:editor-window-access" xmlns:b="urn:x-page-builder" xmlns:msxsl="urn:schemas-microsoft-com:xslt">
	<xsl:output method="html" version="4.0" encoding="windows-1251" omit-xml-declaration="yes" media-type="text/html"/>
	<xsl:template match="Organization">
		<table width="100%" cellspacing="3" cellpadding="0">
			<col width="30%" />
			<col width="70%" />
      <tr>
        <td class="x-editor-text x-editor-propcaption">Наименование:</td>
        <td>
          <xsl:for-each select="Name">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Краткое наименование:</td>
        <td>
          <xsl:for-each select="ShortName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="Home">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="OwnTenderParticipant">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="Supplier">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="HoldingPart">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td/>
        <td>
          <xsl:for-each select="StructureHasDefined">
            <xsl:call-template name="std-template-bool">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr>
        <td class="x-editor-text x-editor-propcaption">Примечание:</td>
        <td>
          <xsl:for-each select="Comment">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>      
		</table>
	</xsl:template>
  <xsl:include href="x-pe-string.xsl"/>
	<xsl:include href="x-pe-bool.xsl"/>
</xsl:stylesheet>
