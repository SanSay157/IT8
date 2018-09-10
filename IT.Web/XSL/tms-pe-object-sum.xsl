<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	Cтраница генерации элементов отображения/модификации для скалярного объектного 
	свойства типа "Сумма" (vt="object" ot="Sum" cp="scalar")
-->	
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:w="urn:editor-window-access"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"	
	xmlns:user="urn:это_нужно_для_блока_msxsl:script"
	>

	<xsl:output 
		method="html" 
		version="4.0" 
		encoding="windows-1251"
		omit-xml-declaration="yes"
		media-type="text/html"/>

	<msxsl:script language="VBScript" implements-prefix="user">

		<![CDATA['<%
		' Формирует часть XPath запрса, содержащую фильтр по переданному метаимени
		' [in] sMetaName - метаимя
		Function GetMetaNameFilter( sMetaName )
			If IsNull(sMetaName) Or IsEmpty(sMetaName) Or sMetaName="" Then
				GetMetaNameFilter = "[(not(@n)) or (@n='')]"
			Else
				GetMetaNameFilter = "[@n='" & sMetaName & "']"
			End If
		End Function
		
		'%>']]>

	</msxsl:script>

	<!--
	-->		
	<xsl:template name="tms-template-sum">
		<!-- xml со всеми параметрами шаблона -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml с метаданными -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- Параметр: признак допустимости пустого значения -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- Параметр: описание поля -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- Идентификатор главного Html-контрола для PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>
		<!-- Параметр: имя PropertyEditor'a в метаданных -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:object-presentation/@n))"/>
		<!-- Параметр: символ, отображаемый кнопкой выбора (на данный момент на задается метаданными) -->
		<xsl:param name="select-symbol" select="b:nvl(string($xml-params/@select-symbol), 'arrow')"/>
		<!-- метаданные pe: i:object-presentation -->
		<xsl:param name="pe-md" select="$xml-prop-md/i:object-presentation[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		<!-- Параметр: метанаименование списка, используемого для заполнения комбобокса -->
		<xsl:param name="list-metaname" select="b:nvl(string($xml-params/@list-metaname), string($pe-md/@use-list))" />
		<!-- Управление операциями -->
		<xsl:param name="off-edit" select="b:nvl(string($xml-params/@off-edit),   string($pe-md/@off-edit))"/>
		<xsl:param name="off-unlink" select="b:nvl(string($xml-params/@off-unlink), string($pe-md/@off-unlink))"/>
		<xsl:param name="off-create-currency" select="b:nvl(string($xml-params/@off-create-currency), string($pe-md/@off-create-currency))"/>
		<!-- Параметр: запрещение всех операций -->
		<xsl:param name="off-operations" select="b:nvl(string($xml-params/@off-operations), string($pe-md/@off-operations))"/>

		<!-- переменная с наименованием VBS-переменной с экземпляром ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<table border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td width="30%">
					<!--
						ПОЛЕ ВВОДА СУММЫ
					-->
					<INPUT
						ID="{$html-id}SumValue"
						STYLE="WIDTH:100%"
						VALUE=""
						X_TYPE="fixed"
						X_DESCR = "Сумма"
						>
						<xsl:choose>
							<xsl:when test="1=$maybenull">
								<!-- 
									Если свойство может принимать значение null - выставим дополнительный
									аттрибут X_MAYBENULL.
									Этот аттрибут позволит контролировать допустимость значения св-ва при
									обработке из кода.
								-->						
								<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
								<!-- Выставляем стиль не-обязательного свойства -->
								<xsl:attribute name="CLASS">x-editor-control x-editor-numeric-field</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<!-- Выставляем стиль обязательного свойства -->
								<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-numeric-field</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</INPUT>
				</td>
				<td width="30%" style="padding-left:3px;">
					<!--
						ВЫПАДАЮЩИЙ СПИСОК ВАЛЮТ
					-->
					<SELECT
						ID="{$html-id}Currency"
						STYLE="WIDTH:100%"
						X_LISTMETANAME="{$list-metaname}" 
						X_DESCR="Валюта"
						EmptyValueText="" 
						UseCache="0" 
						CacheSalt="0" 
						RefreshButtonID=""
						>
						<!-- Обработка обязательных/необязательных свойств -->
						<xsl:choose>
							<xsl:when test="'1'=$maybenull">
								<!-- 
									Если свойство может принимать значение null - выставим дополнительный
									атрибут X_MAYBENULL.
									Этот атрибут позволит контролировать допустимость значения св-ва при
									обработке из кода.
								-->						
								<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
								<!-- Выставляем стиль не-обязательного свойства -->
								<xsl:attribute name="CLASS">x-editor-control x-editor-dropdown</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<!-- Выставляем стиль обязательного свойства -->
								<xsl:attribute name="CLASS">x-editor-control-notnull x-editor-dropdown</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
							
						<!-- добавим пустое значение, если это явно не запрещено параметром -->
						<option selected="1"></option>
					</SELECT>
					<SCRIPT FOR="{$html-id}Currency" LANGUAGE="VBScript" EVENT="OnChange">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").CurrencyPropertyEditor.Internal_OnChange
					</SCRIPT>
				</td>
				<td nowrap="1" class="x-editor-text x-editor-propcaption" style="padding-left:3px;">по курсу</td>
				<td width="30%" style="padding-left:3px;">
					<!--
						ПОЛЕ ВВОДА КУРСА ПЕРЕВОДА
					-->
					<INPUT
						ID="{$html-id}Exchange"
						STYLE="WIDTH:100%"
						VALUE=""
						X_TYPE="r4"
						X_DESCR = "Курс перевода"
						X_MAYBENULL="YES"
						CLASS="x-editor-control x-editor-numeric-field"
						>
					</INPUT>
				</td>
				<td style="padding-left:3px;">
					<!--
						КНОПКА ОПЕРАЦИЙ С ОБЪЕКТОМ, ОТОБРАЖАЕМЫМ ЭЛЕМЕНТОМ
						Не отображается, если все действия с объектом запрещены:
						прячем всю ячейку "раскладки"
					-->
					<xsl:if test="$off-operations">
						<xsl:attribute name="STYLE">display:none</xsl:attribute>
					</xsl:if>
					<BUTTON
						CLASS="x-button x-editor-objectpresentation-button"
						ID="{$html-id}"
						X_PROPERTY_EDITOR="PEObjectSumClass"
						X_DESCR="{$description}" 
						X_DISABLED="{$disabled+1}"
						PEMetadataLocator="{concat( 'i:object-presentation',user:GetMetaNameFilter( string( $metaname )))}"
						OFF_EDIT="{$off-edit}"
						OFF_UNLINK="{$off-unlink}"
						OFF_CREATE_CURRENCY ="{$off-create-currency}"
						SumValueID="{$html-id}SumValue" 
						CurrencyID="{$html-id}Currency" 
						ExchangeID="{$html-id}Exchange" 
					>
						<!-- если все действия запрещены - то и установка фокуса так же запрещена -->
						<xsl:if test="$off-operations">
							<xsl:attribute name="TABINDEX">-1</xsl:attribute>
						</xsl:if>						
					
						<!-- 
							Если свойство может принимать значение null - выставим 
							атрибут X_MAYBENULL. Этот атрибут позволит контролировать 
							допустимость значения свойства при обработке из кода.
						-->						
						<xsl:if test="'1'=$maybenull">
							<xsl:attribute name="X_MAYBENULL">YES</xsl:attribute>
						</xsl:if>

						<!-- 
							Символ, отображаемый кнопкой выбора.
							Внимание: для точного отображения символа исподьзуется 
							явное задание шрифта, перекрывающего возможные задания,
							сделанные через стилевой класс в CSS
						-->
						<xsl:choose>
							<xsl:when test="'dots'=$select-symbol">
								<!-- Символ: точки -->
								<SPAN STYLE="font-family:Verdana;">...</SPAN>
							</xsl:when>
							<xsl:otherwise>
								<!-- Все остальные случаи: стрелка -->
								<SPAN STYLE="font-family:Webdings">&#54;</SPAN>
							</xsl:otherwise>
						</xsl:choose>
					</BUTTON>
					<script for="{$html-id}" language="VBScript" event="OnClick">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").ShowMenu
					</script>
				</td>
			</tr>
		</table>
	</xsl:template>

</xsl:stylesheet>