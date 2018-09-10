<?xml version="1.0" encoding="windows-1251"?>
<!--
	================================================================================================
	����������� �������� ��������� ���������  �����������/����������� ��� ����������� ��������� ������� 
	�������
-->	
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:XFW="http://www.croc.ru/XmlFramework/Behaviors"

	xmlns:w="urn:editor-window-access"
	xmlns:d="urn:object-editor-access"
	xmlns:b="urn:x-page-builder"
	xmlns:ds="http://www.croc.ru/Schemas/XmlFramework/Data/1.0"
	xmlns:i="http://www.croc.ru/Schemas/XmlFramework/Interface/1.0"
	>

	<!--
		=============================================================================================
		����������� ������ ��������� ���������  �����������/����������� ��� ��������� ����������� �������
		�������
		������� ��������
			urn:object-editor-access - ��������� ������� EditorData									
			urn:editor-window-access - ��������� ���� ���������								
		�������������� �������:																		
			�������� ������� X-Storage
		������� ���������:
			[in] height - ������ ������� ��� �������������� ���������� �������
			[in] metaname - ������� ������
			[in] description - �������� ����
			[in] menu-style - ����� ����������� ���� (�������� �� ��������� ������� �� i:prop-menu/@menu-style)
				��������: op-button (�� ���������), vertical-buttons, horizontal-buttons
			[in] button-width - ������ ������ ����
			[in] button-height- ������ ������ ����
			[in] off-create	- ���������� �������� �������
			[in] off-select	- ���������� �������� �������
			[in] off-edit	- ���������� �������� ��������
			[in] off-unlink 	- ���������� �������� ��������� �����
			[in] off-delete		- ���������� �������� �������
			[in] off-position - ���������� �������� ����������� �����/����
			[in] lbl-position-up - ������� �� ������ �������� ����������� �����
			[in] lbl-position-down - ������� �� ������ �������� ����������� ����
			
		��������� �������������:
			HTML -	���, ����������� ��������� ��� ��������� �����������/����������� ��������� ����������� ������� 
			�������
	-->		
	<xsl:template name="std-template-objects">
		<!-- xml �� ����� ����������� ������� -->
		<xsl:param name="xml-params" select="*[0!=0]"/>
		<!-- xml � ������������ -->
		<xsl:param name="xml-prop-md" select="b:GetPropMD(current())"/>
		<!-- ��������: ����������� -->
		<xsl:param name="disabled" select="number(b:nvl(string($xml-params/@disabled),'0'))"/>
		<!-- ��������: ������� ������������ ������� �������� -->
		<xsl:param name="maybenull" select="b:nvl(string($xml-params/@maybenull), string($xml-prop-md/@maybenull))"/>
		<!-- ��������: �������� ���� -->
		<xsl:param name="description" select="b:nvl(string($xml-params/@description),string($xml-prop-md/@d))"/>
		<!-- ��������: ����������� -->
		<xsl:param name="height" select="b:nvl(string($xml-params/@height),'100%')"/>
		<!-- ��������: ��� PropertyEditor'a � ���������� -->
		<xsl:param name="metaname" select="b:nvl(string($xml-params/@metaname), string($xml-prop-md/i:elements-list/@n))"/>
		<!-- ���������� pe: i:elements-list-->
		<xsl:param name="pe-md" select="$xml-prop-md/i:elements-list[($metaname='' and not(@n)) or ($metaname=@n)]"/>
		
		<!-- ������������� �������� Html-�������� ��� PropertyEditor'a -->
		<xsl:param name="html-id" select="b:GetHtmlID(current())"/>

		<!-- ���������� ������ -->
		<xsl:param name="off-create"   select="b:nvl(string($xml-params/@off-create),  string($pe-md/@off-create))"/>
		<xsl:param name="off-select"   select="b:nvl(string($xml-params/@off-select),  string($pe-md/@off-select))"/>
		<xsl:param name="off-edit"     select="b:nvl(string($xml-params/@off-edit),    string($pe-md/@off-edit))"/>
		<xsl:param name="off-unlink"   select="b:nvl(string($xml-params/@off-unlink),  string($pe-md/@off-unlink))"/>
		<xsl:param name="off-delete"   select="b:nvl(string($xml-params/@off-delete),  string($pe-md/@off-delete))"/>
		<xsl:param name="off-position" select="b:nvl(string($xml-params/@off-position),string($pe-md/@off-position))"/>

		<!-- ������� � ������� -->
		<xsl:param name="lbl-position-up"   select="b:nvl(string($xml-params/@lbl-position-up),   string($pe-md/@lbl-position-up))"/>
		<xsl:param name="lbl-position-down" select="b:nvl(string($xml-params/@lbl-position-down), string($pe-md/@lbl-position-down))"/>
		<!-- ���������� �������� ������ -->
		<xsl:param name="off-sortcolumn"   select="b:nvl(string($xml-params/@off-sortcolumn), string($pe-md/@off-sortcolumn))"/>
		<xsl:param name="off-movecolumn"   select="b:nvl(string($xml-params/@off-movecolumn), string($pe-md/@off-movecolumn))"/>
		<!-- ������������ ���������, ������������� ��� �������� ������� -->
		<xsl:param name="use-for-creation" select="b:nvl(string($xml-params/@use-for-creation), string($pe-md/@use-for-creation))"/>
		<!-- ������������ ���������, ������������� ��� �������������� ������� -->
		<xsl:param name="use-for-editing"  select="b:nvl(string($xml-params/@use-for-editing), string($pe-md/@use-for-editing))"/>
		<!-- ������������ ������, ������������� ��� ������ -->
		<xsl:param name="use-list-selector" select="b:nvl(string($xml-params/@use-list-selector), string($pe-md/@use-list-selector))"/>
		<!-- ������������ ������, ������������� ��� ������ -->
		<xsl:param name="use-tree-selector" select="b:nvl(string($xml-params/@use-tree-selector), string($pe-md/@use-tree-selector))"/>
		<!-- VBS ��������� ��� �������� ����� ������ -->
		<xsl:param name="hide-if" select="b:nvl(string($xml-params/@hide-if), string($pe-md/i:hide-if))"/>
		<!-- ����� ����������� ���� -->
		<xsl:param name="menu-style" select="b:nvl(string($xml-params/@menu-style), string($pe-md/i:prop-menu/@menu-style))"/>
		<!-- ������������ ������������ ������: top ��� bottom -->
		<xsl:param name="buttons-valign" select="b:nvl(string($xml-params/@buttons-valign), string('bottom'))" />
		<!-- ������ ������ ���� -->
		<xsl:param name="button-width" select="b:nvl(string($xml-params/@button-width), string($pe-md/i:prop-menu/@button-width))" />
		<!-- ������ ������ ���� -->
		<xsl:param name="button-height" select="b:nvl(string($xml-params/@button-height), string($pe-md/i:prop-menu/@button-height))" />

		<!-- ������� �������� -->
		<xsl:variable name="capacity" select="string($xml-prop-md/@cp)"/>
		<!-- ��������� �������� ��� link'� -->
		<xsl:variable name="order-by" select="string($xml-prop-md/@order-by)"/>
		<!-- ���������� � ������������� VBS-���������� � ����������� ObjectEditor'a -->
		<xsl:variable name="editordata" select="d:UniqueID()"/>

		<!-- ������� ��������� ���������� ���������� �������� -->
		<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%" HEIGHT="{$height}" ID="{$html-id}Container">
			<TR>
				<TD HEIGHT="100%" WIDTH="100%" COLSPAN="2">
					<DIV STYLE="position:relative; width:100%; height:100%;" CLASS="x-editor-control x-editor-objects-list">
					<!-- 
						ACTIVEX - ������ ��������
						
						� �������� �������������� ���������� ������� html-id 
						��������������� ���������� ��������. ��� �������� 
						� ���������� ����������� ����������� ������� �� 
						�������������� ��������� ������� �� ����.
						
						�������������� ��������, ���������� ������, ��������� 
						�� ���� ������������ � ����������� ����:
						
						������� X_DESCR ������ ��������, ������� � ����� ������ 
						����� ���������� �� �������� � ����������.
					-->					
					<OBJECT 
						ID="{$html-id}"
						NAME="{b:GetUniqueNameFor(current())}"
						CLASSID="{b:Evaluate('CLSID_LIST_VIEW')}" 
						BORDER="0" TABINDEX="0"
						WIDTH="100%" HEIGHT="100%"
						
						X_PROPERTY_EDITOR = "XPEObjectsElementsListClass"
						X_DISABLED="{$disabled+1}"
						X_DESCR = "{$description}"
						
						HIDE_IF="{$hide-if}" 
						
						PEMetadataLocator = "i:elements-list[('{$metaname}'='' and not(@n)) or ('{$metaname}'=@n)]"
						OFF_CREATE ="{$off-create}"
						OFF_EDIT   ="{$off-edit}"
						OFF_SELECT ="{$off-select}"
						OFF_UNLINK ="{$off-unlink}"
						OFF_DELETE ="{$off-delete}"						
						EditorMetanameForCreating = "{$use-for-creation}"
						EditorMetanameForEditing  = "{$use-for-editing}"
						ListSelectorMetaname = "{$use-list-selector}"
						TreeSelectorMetaname = "{$use-tree-selector}"
					>
						<xsl:if test="('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and $order-by))">
							<xsl:attribute name="X_SHIFT_OPERATIONS">1</xsl:attribute>
						</xsl:if>
					
						<PARAM NAME="Enabled" VALUE="0"></PARAM>
						<PARAM NAME="ShowBorder" VALUE="0"></PARAM>
						
						<xsl:if test="('1'=$off-sortcolumn) or ('1'=$off-position) or (('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and $order-by!='')))">
							<PARAM NAME="AllowSorting" VALUE="0"></PARAM>
						</xsl:if>
						<xsl:if test="'1'=$off-movecolumn" >
							<PARAM NAME="AllowChangePositions" VALUE="0"></PARAM>
						</xsl:if>
						<PARAM NAME="LockHtmlKeyboardEvents" VALUE="-1"></PARAM>
					</OBJECT>
					<SCRIPT for="{$html-id}" event="OnKeyUp(ByVal oSender, ByVal nKeyCode, ByVal nFlags)" language="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnKeyUpAsync " &amp; nKeyCode &amp; "," &amp; nFlags &amp; ": End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT for="{$html-id}" event="OnDblClick(ByVal oSender, ByVal nIndex , ByVal nColumn, ByVal sID)" language="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnDblClickAsync " &amp; nIndex &amp; "," &amp; nColumn &amp; ",""" &amp; sID &amp; """: End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT FOR="{$html-id}" EVENT="OnRightClick(ByVal oSender, ByVal nIndex, ByVal nColumn, ByVal sID)" LANGUAGE="VBScript">
						window.setTimeout "Dim o: Set o = <xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>""): If Not o Is Nothing Then : o.Internal_OnContextMenuAsync: End If", 0, "VBScript"
					</SCRIPT>
					<SCRIPT FOR="{$html-id}" EVENT="OnSelChange(ByVal oSender, ByVal nPrewRow, ByVal nNewRow)" LANGUAGE="VBScript">
						<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").Internal_DispatchOnSelChange "<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID(""<xsl:value-of select="$html-id"/>"")", nPrewRow, nNewRow
					</SCRIPT>
					</DIV>
				</TD>
				<xsl:if test="$menu-style='vertical-buttons'">
					<TD valign="{$buttons-valign}" style="padding-left:5px;">
						<XFW:XMenuHtmlPE
							ID="{$html-id}Menu" language="VBScript" 
							SolidPageBorder="false" 
							Enabled="True" 
							style="width:100%; height:100%;"
							menu-style="{$menu-style}"
							X_DISABLED="{$disabled}"
							button-width="{$button-width}"
							button-height="{$button-height}"
						>
							<xsl:attribute name="propmenu-xml"><xsl:value-of select="b:GetXmlString($pe-md/i:prop-menu)"/></xsl:attribute>
						</XFW:XMenuHtmlPE>
					</TD>
				</xsl:if>
			</TR>
			
			<!-- 
				��� ���� ������������ ������ ���������� ������� � �������� 
				������ ��� �������������� ���������� ������� html-id 
				��������������� ���������� �������� � ��������� ���������
				"Button" + ������-������������ ������ (Up, Down, Menu)
				-->
			<TR>
				<TD ALIGN="left" NOWRAP="1" CLASS="x-editor-objects-buttons-pane">
					<xsl:if test="('1'!=$off-position) and (('array'=$capacity) or ('link'=$capacity and ''!=$order-by))">
						<BUTTON 
							ID = "{$html-id}ButtonUp" 
							NAME = "{b:GetUniqueNameFor(current())}"
							TITLE = "�����" 
							CLASS = "x-button x-editor-objects-opbutton"
							DISABLED = "1"
							STYLE = "margin-right:3px;"
							X_DISABLED="{$disabled+2}"
						>
							<CENTER>
								<xsl:choose>
									<xsl:when test="''!=$lbl-position-up">
										<!-- �������� ����� ������ -->
										<xsl:value-of select="$lbl-position-up"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- ��� ��������� ������: ������� -->
										<SPAN STYLE="font-family:Webdings">&#53;</SPAN>
									</xsl:otherwise>
								</xsl:choose>
							</CENTER>
						</BUTTON>
						<SCRIPT FOR="{$html-id}ButtonUp" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").DoItemShift True
						</SCRIPT>
						
						<BUTTON
							ID = "{$html-id}ButtonDown" 
							NAME = "{b:GetUniqueNameFor(current())}"
							TITLE = "����" 
							CLASS = "x-button x-editor-objects-opbutton" 
							DISABLED = "1"
							STYLE = "margin-right:3px;"
							X_DISABLED="{$disabled+2}"
						>
							<CENTER>
								<xsl:choose>
									<xsl:when test="''!=$lbl-position-down">
										<!-- �������� ����� ������ -->
										<xsl:value-of select="$lbl-position-down"/>
									</xsl:when>
									<xsl:otherwise>
										<!-- ��� ��������� ������: ������� -->
										<SPAN STYLE="font-family:Webdings">&#54;</SPAN>
									</xsl:otherwise>
								</xsl:choose>
							</CENTER>
						</BUTTON>
						<SCRIPT FOR="{$html-id}ButtonDown" LANGUAGE="VBScript" event="OnClick">
							<xsl:value-of select="$editordata"/>.CurrentPage.GetPropertyEditorByFullHtmlID("<xsl:value-of select="$html-id"/>").DoItemShift False
						</SCRIPT>
					</xsl:if>
				</TD>
				<TD WIDTH="100%" ALIGN="right" NOWRAP="1" CLASS="x-editor-objects-buttons-pane" >
					<xsl:if test="$menu-style!='vertical-buttons'">
						<DIV>
							<XFW:XMenuHtmlPE
								ID="{$html-id}Menu" language="VBScript" 
								SolidPageBorder="false" 
								Enabled="True" 
								style="width:100%; height:100%;"
								menu-style="{$menu-style}"
								X_DISABLED="{$disabled}"
								button-width="{$button-width}"
								button-height="{$button-height}"
							>
								<xsl:attribute name="propmenu-xml"><xsl:value-of select="b:GetXmlString($pe-md/i:prop-menu)"/></xsl:attribute>
							</XFW:XMenuHtmlPE>
						</DIV>	
					</xsl:if>
				</TD>
			</TR>
		</TABLE>
	</xsl:template>
</xsl:stylesheet>
