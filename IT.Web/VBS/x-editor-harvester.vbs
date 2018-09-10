'===============================================================================
'@@!!FILE_x-editor-harvester
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor-harvester - ������������ ��������� ������������� ��������� � ���������� �������>
':����������:
'	������������ ��������� ������������� ��������� � ���������� �������.
'===============================================================================
'@@!!CLASSES_x-editor-harvester
'<GROUP !!FILE_x-editor-harvester><TITLE ������>
Option Explicit

' "�������" ����� ��� ����������� ���������� �������
Class XPropertyEditorBaseClass
	Public EditorPage				' As EditorPageClass
	Public ObjectEditor				' As ObjectEditorClass
	Public HtmlElement				' As IHtmlElement	- ������ �� ������� Html-�������
	Public PropertyMD				' As XMLDOMElement	- ���������� xml-��������
	Public EventEngine				' As EventEngineClass
	Public EVENTS					' ������ �������
	Public XmlPropertyXPath			' XPath - ������ ��� ��������� �������� � Pool'e
	Public ObjectType				' ������������ ���� ������� ��������� ��������
	Public ObjectID					' ������������� ������� ��������� ��������
	Public PropertyName				' ������������ ��������
	Public PropertyDescription		' �������� ��������
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set EventEngine = X_CreateEventEngine
	End Sub

	'--------------------------------------------------------------------------
	Public Sub Init(oEditorPage, oXmlProperty, oHtmlElement, sEvents, sPEShortName)
		EVENTS = sEvents
		Set EditorPage		= oEditorPage
		Set ObjectEditor	= EditorPage.ObjectEditor
		ObjectType			= oXmlProperty.parentNode.tagName
		ObjectID			= oXmlProperty.parentNode.getAttribute("oid")
		PropertyName		= oXmlProperty.tagName
		XmlPropertyXPath	= ObjectType & "[@oid='" & ObjectID & "']/" & PropertyName
		Set PropertyMD		= ObjectEditor.PropMD(oXmlProperty)
		Set HtmlElement		= oHtmlElement
		' ����������� �������
		If Len("" & sEvents) > 0 Then
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & ObjectType & "_" & PropertyName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & PropertyName & "_" & sPEShortName & "_On"
			EventEngine.InitHandlers EVENTS, "usr_" & sPEShortName & "_On"
		End If
		PropertyDescription = HtmlElement.GetAttribute("X_DESCR")
	End Sub


	'--------------------------------------------------------------------------
	' ���������� Xml-��������
	' [in] bLoad - ������� ������������� ���������� ��������
	Public Function GetXmlProperty(bLoad)
		Set GetXmlProperty = ObjectEditor.XmlObjectPool.selectSingleNode( XmlPropertyXPath )
		If GetXmlProperty Is Nothing Then
			Set GetXmlProperty = ObjectEditor.Pool.GetXmlObject(ObjectType, ObjectID, Null).SelectSingleNode(PropertyName)
		End If
		If GetXmlProperty Is Nothing Then _
			Err.Raise -1, "XPropertyEditorBaseClass::XmlProperty", "�� ������� �������� " & PropertyName & " � xml-�������"
		If bLoad Then	
			If Not IsNull(GetXmlProperty.getAttribute("loaded")) Then
				Set GetXmlProperty = ObjectEditor.LoadXmlProperty( Nothing, GetXmlProperty)
			End If
		End If	
	End Function


	'--------------------------------------------------------------------------
	' ���������� Xml-��������
	Public Property Get XmlProperty
		Set XmlProperty = GetXmlProperty(true)
	End Property


	'-------------------------------------------------------------------------------
	' �������� �������� ��� ����������������
	Public Sub SetDirty
		ObjectEditor.SetXmlPropertyDirty XmlProperty
	End Sub
	
	
	'-------------------------------------------------------------------------------
	' ���������� �����������/������������ �������� ��������
	Public Sub GetRange(ByRef vMin, ByRef vMax)
		vMin = HtmlElement.GetAttribute("X_MIN")
		vMax = HtmlElement.GetAttribute("X_MAX")
		If HasValue(vMin) Then
			With XmlProperty.OwnerDocument.CreateElement("X")
				.dataType=XmlProperty.dataType
				if .dataType="string" Then .dataType="i4" 
				.text = vMin
				vMin = .nodeTypedValue
			End With
		Else
			vMin = X_GetChildValueDef( PropertyMD, "ds:min", Null )
		End If	
		If HasValue(vMax) Then
			With XmlProperty.OwnerDocument.CreateElement("X")
				.dataType=XmlProperty.dataType
				if .dataType="string" Then .dataType="i4" 
				.text = vMax
				vMax = .nodeTypedValue
			End With		
		Else
			vMax = X_GetChildValueDef( PropertyMD, "ds:max", Null )
		End If	
	End Sub
End Class


'-------------------------------------------------------------------------------
' ����������:	������� �������� �������� NOT-NULL-��������, ��������� � 
'				��������� ��������, �� NULL
' ���������:    True - ���� �������� �� NULL, ���� �������� NULL � �������� 
'				��������� ������� NULL-��������; ����� - False
' ���������:	[in] oPropertyEditor - ��������� IPropertyEditor, �������� ��������
'				[in] oGetDataArgs As GetDataArgsClass - 
' ����������:	��� ��������� �������� ���������� �� ������������, �������� 
'				������ ������������ � ���������� ��������� oGetDataArgs
Function ValueCheckOnNullForPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs, bMandatory)
	' ���������� ������� ��� �������� �����������:
	ValueCheckOnNullForPropertyEditor = False
	' �������� �������� ��������� ������� ����������:
	If hasValue(vValue) Then 
		ValueCheckOnNullForPropertyEditor = True
	' �������� �������� ���� NULL: 
	Else
		' �������� ����������� ������� NULL-�������� ��� ��������
		If bMandatory Then
			oGetDataArgs.ErrorMessage = "�������� ��������� """ & oPropertyEditorBase.PropertyDescription & """ ������ ���� ������"
			oGetDataArgs.ReturnValue = False
		Else
			ValueCheckOnNullForPropertyEditor = True
		End If
	End If
End Function


'-------------------------------------------------------------------------------
' ����������:	������� �������� ��������� �������� ��������, ��������� � 
'				��������� ��������, � ���������� �������� �������� (������������
'				�����������)
' ���������:    True � ������ ���� �������� ���������, ����� - False
' ���������:	[in] vValue	- ����������� �������� ��������
'				[in] oIPropertyEditorBase - ��������� PropertyEditorBaseClass, ������ 
'				��������� ��������
'				[in] oGetDataArgs As GetDataArgsClass
' ����������:	��� ��������� �������� ���������� �� ������������, �������� 
'				������ ������������ � ���������� ��������� GetDataArgsClass
' �����������:	
Function ValueCheckRangeForPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs)
	Dim vLowerRangeBound	' �������� ������ ������� ��������� ��������, ds:min
	Dim vUpperRangeBound	' �������� ������� ������� ��������� ��������, ds:max
	
	' ���������� �������� ��������� ������� ����������:
	If Not hasValue(vValue) Then 
		ValueCheckRangeForPropertyEditor = True
		Exit Function
	End If
	' ��� ���� ��������� ������� ���������� ������� ��� �������� �����������
	ValueCheckRangeForPropertyEditor = False
	
	With oPropertyEditorBase
		.GetRange vLowerRangeBound, vUpperRangeBound
		
		' �������� - ������: ��������� �� ����� ������
		If vbString = VarType(vValue) Then
			If Not IsNull(vLowerRangeBound) Then
				If vLowerRangeBound > Len(vValue) Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"����� ������ ��������� """ & .PropertyDescription & """ ������ ���������� ����������" & vbNewLine & _
						vbNewLine & _
						"����� ��������� ������: " & Len(vValue) & vbNewLine & _
						"���������� ���������� �����: " & vLowerRangeBound
					Exit Function					
				End If
			End If
			If Not IsNull(vUpperRangeBound) Then
				If vUpperRangeBound < Len(vValue) Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage =	_
						"����� ������ ��������� """ & .PropertyDescription & """ ������ ����������� ����������" & vbNewLine & _
						vbNewLine & _
						"����� ��������� ������: " & Len( vValue) & vbNewLine & _
						"����������� ���������� �����: " & vUpperRangeBound
					Exit Function					
				End If
			End If
			
		' �������� - �� ������: ��������� �� �������� ��������, ��� ���������� �������� � �����
		Else
			If Not IsNull(vLowerRangeBound) Then
				If vLowerRangeBound > vValue Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"�������� ��������� """ & .PropertyDescription & """ ������ ������������ ���������� ��������" & vbNewLine & _
						vbNewLine & _
						"�������� ��������: " & vValue & vbNewLine & _
						"���������� ���������� ��������: " & vLowerRangeBound
					Exit Function
				End If
			End If
			If Not IsNull(vUpperRangeBound) Then
				If vUpperRangeBound < vValue Then
					oGetDataArgs.ReturnValue = False
					oGetDataArgs.ErrorMessage = _
						"�������� ��������� """ & .PropertyDescription & """ ������ ������������� ���������� ��������" & vbNewLine & _
						vbNewLine & _
						"�������� ��������: " & vValue & vbNewLine & _
						"����������� ���������� ��������: " & vUpperRangeBound
					Exit Function					
				End If
			End If
		End If
		
	End With	
	
	' ��� �������� ������: ������� �������� ����������
	ValueCheckRangeForPropertyEditor = True
End Function 


'-------------------------------------------------------------------------------
' ����������:	������� ������ ������ ��������, �������� � ��������� ��������, 
'				� XML-������ �������-���������.
' ���������:    True � ������ �������� ������ ������ � XML, ����� - False
'				� ������ ������ �������� ������ ������������ � oGetDataArgs
'	[in] vValue - ��������
'	[in] oPEArgsObject As PropertyEditorBaseClass - �������� ��������
'	[in] oGetDataArgs As GetDataArgsClass - ����� ���� �� �����
' ����������:	(1) ������ ������������� ��������� ������� "dirty" � XML-������
'				�������-���������, ��������� �������� �������� �������� �� ���������, 
'				�������� � ���������;
'				(2) ��� ��������� ������ ���������� �� ������������, �������� 
'				������ ������������ � ���������� ��������� oGetDataArgs
Function GetDataFromPropertyEditor( vValue, oPropertyEditorBase, oGetDataArgs )
	GetDataFromPropertyEditor = True
		
	With oPropertyEditorBase
		On Error Resume Next
		oPropertyEditorBase.ObjectEditor.SetPropertyValue .XmlProperty, vValue
		If Err Then
			GetDataFromPropertyEditor = False
			If Not IsNothing(oGetDataArgs) Then
				oGetDataArgs.ReturnValue = False
				oGetDataArgs.ErrorMessage = "������ ��� ��������� ��������� """ & .PropertyDescription & """ � XML"	
			End If
			Err.Clear
		End If
	End With
End Function


'===============================================================================
'@@ChangeEventArgsClass
'<GROUP !!CLASSES_x-editor-harvester><TITLE ChangeEventArgsClass>
':����������:	
'	��������� ������� "Changing", "Changed" (��. �������� ����� ���������� � ����������).
':��������:
'	��������� ������ ������������ ��� �������� ���������� ������� � ��������� 
'	���������� ������� (property editors, XPE):
'	* XPESelectorRadioClass - ��� ������� "Changed";
'	* XPESelectorComboClass - ��� ������� "Changing" � "Changed";
'	* XPEObjectDropdownClass - ��� ������� "Changing" � "Changed".
'
'@@!!MEMBERTYPE_Methods_ChangeEventArgsClass
'<GROUP ChangeEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ChangeEventArgsClass
'<GROUP ChangeEventArgsClass><TITLE ��������>
Class ChangeEventArgsClass
	'@@ChangeEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@ChangeEventArgsClass.OldValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE OldValue>
	':����������:	"������" ��������, �� ���������.
	':���������:	Public OldValue [As Variant]
	Public OldValue
	
	'@@ChangeEventArgsClass.NewValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE NewValue>
	':����������:	"�����" ��������, ����� ���������.
	':���������:	Public NewValue [As Variant]
	Public NewValue
	
	'@@ChangeEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_ChangeEventArgsClass><TITLE ReturnValue>
	':����������:	������, ������������ ������������ �������. 
	':����������:	
	'	�������� �������� ������������� ������ ��� ������ ������� "Changing": 
	'	���������� �������, � �������� "������������" ������ ��������� ����������
	'	�������� - ������� ������������ ��������� ��������. �����:
	'	* True - ��������� �������� ���������;
	'	* False - ��������� �������� ���������; � ���� ������ �������� ��������
	'		�� �������� ��������, ������� "Changed" �� ������������.
	':���������:	Public ReturnValue [As Variant (As Boolean)]
	Public ReturnValue
	
	'@@ChangeEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_ChangeEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As ChangeEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
