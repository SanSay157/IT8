<?xml version="1.0" encoding="windows-1251"?>
<!--
===============================================================================
	Третья страница для фильтра списка лотов ("Легенда")
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
			<td title="Получение документов" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-DocsReceiving.ico" align="top" style="background-color:white" /> Получение документов</td>
			<td title="Принято решение об участии" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept.ico" align="top" style="background-color:white" /> Участие</td>
			<td title="Отказ от участия" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Reject.ico" align="top" style="background-color:white" /> Отказ от участия</td>
		</tr>
		<tr>
			<td title="Принятие решения об участии" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Thinking.ico" align="top" style="background-color:white" /> Принятие решения</td>
			<td title="Принято решение об участии, но не задана дата подачи документов" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-NoDocsFeedDate.ico" align="top" style="background-color:white" /> Участие - не задана дата</td>
			<td title="Рассмотрение документов тендерной комиссией" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Waiting.ico" align="top" style="background-color:white" /> Рассмотрение предложения</td>
		</tr>
		<tr>
			<td title="Принятие решения об участии, но не задана дата подачи документов" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Thinking-NoDocsFeedDate.ico" align="top" style="background-color:white" /> Принятие решения - не задана дата</td>
			<td title="Принято решение об участии и до подачи документов 3 дня" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-3days.ico" align="top" style="background-color:white" /> Участие - осталось 3 дня</td>
			<td title="Тендер выигран" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Winner.ico" align="top" style="background-color:white" /> Выигран</td>
		</tr>
		<tr>
			<td title="Просрочен крайний срок принятия решения" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Expired.ico" align="top" style="background-color:white" /> Принятие решения - просрочено</td>
			<td title="Принято решение об участии и до подачи документов 2 дня" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-2days.ico" align="top" style="background-color:white" /> Участие - осталось 2 дня</td>
			<td title="Тендер проигран" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Loser.ico" align="top" style="background-color:white" /> Проигран</td>
		</tr>
		<tr>
      <td title="Заключение госконтракта" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-StateContract.ico" align="top" style="background-color:white" /> Заключение госконтракта</td>
      <td title="Принято решение об участии и до подачи документов 1 день" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Accept-1day.ico" align="top" style="background-color:white" /> Участие - остался 1 день</td>
			<td title="Тендер отменен" class="x-editor-text x-editor-propcaption"><img src="Icons\TenderLotState-Canceled.ico" align="top" style="background-color:white" /> Отменен</td>
		</tr>
	</tbody>
	</table>
</xsl:template>

</xsl:stylesheet>
