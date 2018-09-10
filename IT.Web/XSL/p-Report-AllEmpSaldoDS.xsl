<?xml version="1.0" encoding="windows-1251"?>

<!-- ������ ������ "������ �� �� �����������" -->

<xsl:stylesheet version="1.0"
	xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
	xmlns:b = "urn:x-page-builder"
	xmlns:w = "urn:editor-window-access"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:user = "urn:offcache"
>
  <!-- ������������������ ������ ��� �����������/����������� ������� ������� -->
  <xsl:import href="it-period-selector.xsl"/>
  <xsl:output
    method="html"
    version="4.0"
    encoding="windows-1251"
    omit-xml-declaration="yes"
    media-type="text/html"/>
  <xsl:template match="FilterReportAllEmpSaldoDS">

    <!-- ���� ��� ������� ���������������� �������; ������������ ���������� ������ -->
    <TABLE BORDER="0" CELLSPACING="1" CELLPADDING="0" STYLE="width:99%;">
      <TBODY>
        <TR>
          <TD CLASS="x-editor-text x-editor-propcaption">
            <NOBR>������ �������:</NOBR>
          </TD>
          <TD STYLE="width:100%;">
            <xsl:call-template name="it-template-period-selector" />
          </TD>
        </TR>
        <TR>
          <TD COLSPAN="2">
            <HR/>
          </TD>
        </TR>
      </TBODY>
    </TABLE>
  </xsl:template>
</xsl:stylesheet>
