Option Explicit

'==============================================================================
' PE ��� ����������� �������� �������� � ���� r4ead-only ����. 
' �������������� ������������ ���� �������. ����������� �������������� � ������� VBS-���������, ����������� ���������� � XSLT-������.
' ��� ��������� ������� ��������� ����������� ������������ �������-�������� (���������� object-presentation), 
' ��� ����������� ������� ��������� ����������� ������������ �������-��������� ��������
Class PEReadOnlyClass
	Private m_oEditorPage			' As EditorPageClass
	Private m_oObjectEditor			' As ObjectEditorClass
	Private m_oHtmlElement			' As IHtmlElement	- ������ �� ������� Html-�������
	Private m_oPropertyMD			' As XMLDOMElement	- ���������� xml-��������
	Private m_sXmlPropertyXPath		' As String - XPAth - ������ ��� ��������� �������� � Pool'e
	Private m_sObjectType			' As String - ������������ ���� ������� ��������� ��������
	Private m_sObjectID				' As String - ������������� ������� ��������� ��������
	Private m_sPropertyName			' As String - ������������ ��������
	Private m_sExpression			' As String	- VBS-���������
	Private m_bAutoCaptionToolTip	' As Boolean - ������� ��������������� ��������� ������� ���������� ����
	Private m_bIsObject				' As Boolean - ������� ���������� ��������
	
	'==========================================================================
	' ���������� ��������� ObjectEditorClass - ���������,
	' � ������ �������� �������� ������ �������� ��������
	Public Property Get ObjectEditor
		Set ObjectEditor = m_oObjectEditor
	End Property


	'==========================================================================
	' ���������� ��������� EditorPageClass - �������� ���������,
	' �� ������� ����������� ������ �������� ��������
	Public Property Get ParentPage
		Set ParentPage = m_oEditorPage
	End Property


	'==========================================================================
	' ������������� ��������� ��������.
	' ��. IPropertyEditor::Init
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement)
		Set m_oEditorPage	= oEditorPage
		Set m_oObjectEditor = m_oEditorPage.ObjectEditor
		Set m_oHtmlElement	= oHtmlElement
		m_sObjectType		= oXmlProperty.parentNode.tagName
		m_sObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		m_sPropertyName		= oXmlProperty.tagName
		m_sXmlPropertyXPath	= m_sObjectType & "[@oid='" & m_sObjectID & "']/" & m_sPropertyName
		Set m_oPropertyMD	= m_oObjectEditor.PropMD(oXmlProperty)
		Set m_oHtmlElement  = oHtmlElement
		m_bIsObject = CBool(m_oPropertyMD.getAttribute("vt") = "object")
		m_sExpression = HtmlElement.GetAttribute("ValueExpression")
		If Not hasValue(m_sExpression) Then
			If m_bIsObject Then
				m_sExpression = "item.ObjectID"
			Else
				m_sExpression = "item." & m_sPropertyName
			End If
		End If
		m_bAutoCaptionToolTip = CBool(HtmlElement.GetAttribute("AutoToolTip") = "1")
	End Sub
	
	
	'==========================================================================
	' IPropertyEdior: ����� ���������� ��� ���������� �������� ���������, ����� 
	'	������������� ���� PE �� ��������
	Public Sub FillData()
	End Sub

	
	'==========================================================================
	' ���������� Xml-��������
	' ��������� ��. IPropertyEditor::XmlProperty
	Public Property Get XmlProperty
		Set XmlProperty = m_oObjectEditor.XmlObjectPool.selectSingleNode( m_sXmlPropertyXPath )
		If XmlProperty Is Nothing Then
			Set XmlProperty = m_oObjectEditor.Pool.GetXmlObject(m_sObjectType, m_sObjectID, Null).SelectSingleNode(m_sPropertyName)
		End If
		If XmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "�� ������� �������� " & PropertyName & " � xml-�������"
		If Not IsNull(XmlProperty.getAttribute("loaded")) Then
			Set XmlProperty = m_oObjectEditor.LoadXmlProperty( Nothing, XmlProperty)
		End If		
	End Property

	
	'==========================================================================
	' ������������� �������� � ����������
	' ��. IPropertyEditor::SetData	
	Public Sub SetData
		SetDataEx XmlProperty
	End Sub
	
	'==========================================================================
	' ������������� ��������. ������������ ��� �����������, 
	'	�.�. �� �������� XmlProperty ����������� ����������
	' ����� ������������� ������ ������������� ������� � ������������ ��
	'	��������� ���������� �������� � ���� 
	'	[in] oXmlProperty As IXMLDOMElement - �������������� ������ �� ������� xml-��������
	Private Sub SetDataEx(oXmlProperty)
		Dim oXmlItem		' As XMLDOMELement - ������-�������� ��������
		Dim sCaption		' As String - ��������� ������������� �������

		If m_bIsObject Then			
			Set oXmlItem = oXmlProperty.firstChild
		Else
			Set oXmlItem = oXmlProperty.parentNode
		End If

		' ��������� ������ � ������� ������������� �������� ��������
		If Not(Nothing Is oXmlItem) Then
			' ������ ����� ������ - ����������� VBS-���������
			sCaption = vbNullString & ObjectEditor.ExecuteStatement( oXmlItem, m_sExpression )
		End if

		' ����������� ������ ������������� � UI:
		SetText sCaption
	End Sub
	
	
	'==========================================================================
	' ���� � �������� ������
	' ��������� ��. IPropertyEditor::GetDataArgsClass
	Public Sub GetData(oGetDataArgs)
		' Nothing to do
	End Sub
	
	'==========================================================================
	' ���������� ������� (��)�������������� ��������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Get Mandatory
		Mandatory = False
	End Property
	
	'==========================================================================
	' ��������� (��)��������������
	' ��������� ��. IPropertyEditor::Mandatory
	Public Property Let Mandatory(bMandatory)
	End Property
	
	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Get Enabled
		 Enabled = Not (HtmlElement.disabled)
	End Property

	'==========================================================================
	' ��������� (��)�����������
	' ��������� ��. IPropertyEditor::Enabled
	Public Property Let Enabled(bEnabled)
		' �����������/������������ ������
		HtmlElement.disabled = Not( bEnabled )
	End Property
	
	
	'==========================================================================
	' ��������� ������
	' ��������� ��. IPropertyEditor::SetFocus
	Public Function SetFocus
		SetFocus = X_SafeFocus( HtmlElement )
	End Function
	
	
	'==========================================================================
	' ��������� ��������� HTML-�������� ��������� ��������
	' ��������� ��. IPropertyEditor::HtmlElement
	Public Property Get HtmlElement
		Set HtmlElement = m_oHtmlElement
	End Property
	
	'==========================================================================
	' ������ ������ � ������� ���������
	' ��������� ��. IDisposable::Dispose
	Public Sub Dispose
	End Sub
	
	
	'==========================================================================
	' ���������� �������� ��������
	Public Property Get Value
		Set oXmlProperty = XmlProperty
		If m_bIsObject Then
			If oXmlProperty.firstChild Is Nothing Then
				Set Value = Nothing
			Else	
				' �������� ������-��������
				Set Value = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oXmlProperty.firstChild, Null )
			End If
		Else
			Value = oXmlProperty.nodeTypedValue
		End If
	End Property

	'==========================================================================
	' ������������� �������� � �������� � � xml-��������
	Public Property Let Value(vValue)
		Dim oXmlProperty		' As IXMLDOMElement - ������� ��������
		
		Set oXmlProperty = XmlProperty
		If m_bIsObject Then
			' ������ ������� ��������
			If Not oXmlProperty.firstChild Is Nothing Then
				' ���� ��-�� �������� - ������� ���
				m_oObjectEditor.Pool.RemoveRelation Nothing, oXmlProperty, oXmlProperty.firstChild
			End If
			' ��������� �������� ��������
			If Not IsNothing(vValue) Then
				m_oObjectEditor.Pool.AddRelation Nothing, oXmlProperty, vValue
			End If
		Else
			m_oObjectEditor.Pool.SetPropertyValue oXmlProperty, vValue
		End If
		SetDataEx oXmlProperty
	End Property
	
	
	'==========================================================================
	' ������������� ���������� ��������� ������ ����������� ������������� ��������
	Private Sub SetText(sText)
		HtmlElement.Value = sText
		If m_bAutoCaptionToolTip Then
			ToolTip = sText
		End If
	End Sub
	
	'==========================================================================
	' �������������/���������� Vbs-��������� ��� ���������� ������������� ��������
	' ��������� ��. i:object-presentation
	Public Property Get Expression
		Expression = m_sExpression
	End Property 
	Public Property Let Expression(value)
		m_sExpression = value
		SetData
	End Property 
	
	'==========================================================================
	' �������������/���������� ������ ��� ���������� ����, � ������� ������������ ������ ����������� ������
	Public Property Let ToolTip(sValue)
		HtmlElement.Title = sValue
	End Property
	Public Property Get ToolTip
		ToolTip = HtmlElement.Title
	End Property
End Class