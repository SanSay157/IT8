<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	������ �������� ��� ������� ������ ����� ("�������")
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
	
<xsl:template match="FilterLotsList">
	<table cellspacing="0" cellpadding="0" class="x-layoutgrid x-filter-layoutgrid">
	<col style="width=30%; padding-right:10px;"/>
	<col style="width=30%; padding-right:10px;"/>
	<col style="width=30%; padding-right:10px;"/>
	<tbody>
		<tr>
			<td title="��������� ����������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-DocsReceiving.ico" align="top" style="background-color:white" /> ��������� ����������</td>
			<td title="������� ������� �� �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept.ico" align="top" style="background-color:white" /> �������</td>
			<td title="����� �� �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Reject.ico" align="top" style="background-color:white" /> ����� �� �������</td>
		</tr>
		<tr>
			<td title="�������� ������� �� �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Thinking.ico" align="top" style="background-color:white" /> �������� �������</td>
			<td title="������� ������� �� �������, �� �� ������ ���� ������ ����������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-NoDocsFeedDate.ico" align="top" style="background-color:white" /> ������� - �� ������ ����</td>
			<td title="������������ ���������� ��������� ���������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Waiting.ico" align="top" style="background-color:white" /> ������������ �����������</td>
		</tr>
		<tr>
			<td title="�������� ������� �� �������, �� �� ������ ���� ������ ����������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Thinking-NoDocsFeedDate.ico" align="top" style="background-color:white" /> �������� ������� - �� ������ ����</td>
			<td title="������� ������� �� ������� � �� ������ ���������� 3 ���" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-3days.ico" align="top" style="background-color:white" /> ������� - �������� 3 ���</td>
			<td title="������ �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Winner.ico" align="top" style="background-color:white" /> �������</td>
		</tr>
		<tr>
			<td title="��������� ������� ���� �������� �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Expired.ico" align="top" style="background-color:white" /> �������� ������� - ����������</td>
			<td title="������� ������� �� ������� � �� ������ ���������� 2 ���" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-2days.ico" align="top" style="background-color:white" /> ������� - �������� 2 ���</td>
			<td title="������ ��������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Loser.ico" align="top" style="background-color:white" /> ��������</td>
		</tr>
		<tr>
      <td title="���������� ������������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-StateContract.ico" align="top" style="background-color:white" /> ���������� ������������</td>
      <td title="������� ������� �� ������� � �� ������ ���������� 1 ����" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-1day.ico" align="top" style="background-color:white" /> ������� - ������� 1 ����</td>
			<td title="������ �������" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Canceled.ico" align="top" style="background-color:white" /> �������</td>
		</tr>
	</tbody>
	</table>
</xsl:template>

</xsl:stylesheet>
