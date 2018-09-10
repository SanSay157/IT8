<?xml version="1.0" encoding="windows-1251"?>
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
	xmlns:msxsl="urn:schemas-microsoft-com:xslt">
  
  <xsl:output
    method="html"
    version="4.0"
    encoding="windows-1251"
    omit-xml-declaration="yes"
    media-type="text/html"/>
  
  <xsl:template match="FilterTendersList">
    <table cellspacing="2" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
      <col width="13%" />
      <col width="25%" />
      <!-- ������� - ������������ ����������� -->
      <col width="3%" />
      <col width="13%" />
      <col width="27%" />
      <!-- ������� - ������������ ����������� -->
      <col width="3%" />
      <col width="3%" />
      <col width="13%" />
      <tr>
        <td class="x-editor-text x-editor-propcaption">��������:</td>
        <td>
          <xsl:for-each select="CustomerName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">
          <b>��������:</b>
        </td>
        <td>
          <xsl:for-each select="Company">
            <xsl:call-template name="std-template-object-dropdown">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td colspan="2" class="x-editor-text x-editor-propcaption">������ ����������</td>
      </tr>
      <tr >
        <td class="x-editor-text x-editor-propcaption">�����������:</td>
        <td>
          <xsl:for-each select="OrganizerName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">���������:</td>
        <td>
          <xsl:for-each select="Competitor">
            <xsl:call-template name="std-template-object-presentation" />
          </xsl:for-each>
        </td>
        <td />
        
        <!-- ������ ������ ���������� -->
        <td class="x-editor-text x-editor-propcaption">c:</td>
        <td>
          <xsl:for-each select="DocFeedingBegin">
            <xsl:call-template name="std-template-date">
              <xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
      <tr >
        <td class="x-editor-text x-editor-propcaption">�������� �������:</td>
        <td>
          <xsl:for-each select="TenderName">
            <xsl:call-template name="std-template-string">
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <td class="x-editor-text x-editor-propcaption">��������� �������:</td>
        <td>
          <xsl:for-each select="TenderState">
            <xsl:call-template name="std-template-selector">
              <xsl:with-param name="selector">combo</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
        <td />
        <!-- ��������� ������ ���������� -->
        <td class="x-editor-text x-editor-propcaption">��:</td>
        <td style="padding-bottom:5px;">
          <xsl:for-each select="DocFeedingEnd">
            <xsl:call-template name="std-template-date">
              <xsl:with-param name="format">dd.MM.yyyy</xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </td>
      </tr>
    </table>
  </xsl:template>

  <!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��-� -->
  <xsl:include href="x-pe-string.xsl"/>
  <!-- ����������� ������ ��� �����������/����������� ������������ ��-�  ���� � �������-->
  <xsl:include href="x-pe-datetime.xsl"/>
  <!-- ����������� ������ ��� �����������/����������� ������������ ��������� ��������� ��-� -->
  <xsl:include href="x-pe-object.xsl"/>
  <!-- ����������� ������ ��� �����������/����������� �������� ��-�, �������������� ����� �� ������ �������� -->
  <xsl:include href="x-pe-selector.xsl"/>
  <!-- ����������� ������ ��� �����������/����������� ������������ ���������� ��-� -->
  <xsl:include href="x-pe-bool.xsl"/>

</xsl:stylesheet>
