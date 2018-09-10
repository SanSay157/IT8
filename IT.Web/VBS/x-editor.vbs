'===============================================================================
'@@!!FILE_x-editor
'<GROUP !!SYMREF_VBS>
'<TITLE x-editor - ������� ������������ ���������>
':����������:	������� ������������ ���������.
':��. �����:	<LINK oe_1, ����������� ��������� />
'===============================================================================
'@@!!CONSTANTS_x-editor
'<GROUP !!FILE_x-editor><TITLE ���������>
'@@!!FUNCTIONS_x-editor
'<GROUP !!FILE_x-editor><TITLE ������� � ���������>
'@@!!CLASSES_x-editor
'<GROUP !!FILE_x-editor><TITLE ������>

Option Explicit

'==============================================================================
'@@AFTERERROR_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE AFTERERROR_nnnn>
':����������:	���������, �������� ����������� �������� � ������ ������������� ������.
':��. �����:	SaveObjectErrorEventArgsClass.

'@@AFTERERROR_DISPLAYMSG
'<GROUP AFTERERROR_nnnn>
':����������:	������� ��������� �� ������ � �������� ��������.
const AFTERERROR_DISPLAYMSG = 0

'@@AFTERERROR_ABORT
'<GROUP AFTERERROR_nnnn>
':����������:	�������� ��������; ��������� �� ������ �� ���������.
const AFTERERROR_ABORT = 1

'@@AFTERERROR_RETRY
'<GROUP AFTERERROR_nnnn>
':����������:	��������� ��������.
const AFTERERROR_RETRY = 2	


'==============================================================================
'@@REASON_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE REASON_nnnn>
':����������:	
'	���������, ������������ � ���������������� ����������� ������� PageEnd, 
'	UnLoad, UnLoading � �������, ������������ ��� ������������ ������� ���������.
':��. �����:	
'	EditorStateChangedEventArgsClass.Reason, GetDataArgsClass.Reason,
'	ObjectEditorClass.WizardGoToNextPage, ObjectEditorClass.WizardGoToPrevPage,
'	ObjectEditorClass.CanSwitchPage, ObjectEditorClass.FetchXmlObject,
'	ObjectEditorClass.OnClose, ObjectEditorClass.OnClosing

'@@REASON_WIZARD_NEXT_PAGE
'<GROUP REASON_nnnn>
':����������:	������� �� �������� �������� �������.
const REASON_WIZARD_NEXT_PAGE = 0

'@@REASON_WIZARD_PREV_PAGE
'<GROUP REASON_nnnn>
':����������:	������� �� ���������� �������� �������.
const REASON_WIZARD_PREV_PAGE = 1

'@@REASON_OK
'<GROUP REASON_nnnn>
':����������:	������ ������ "OK" ("������").
const REASON_OK	= 2

'@@REASON_PAGE_SWITCH
'<GROUP REASON_nnnn>
':����������:	��������� ������������ �������� (��������) ���������.
const REASON_PAGE_SWITCH = 3

'@@REASON_CLOSE
'<GROUP REASON_nnnn>
':����������:	�������� ����������, � ������� ������������� ��������.
const REASON_CLOSE = 4


'==============================================================================
'@@XEB_nnnn
'<GROUP !!CONSTANTS_x-editor><TITLE XEB_nnnn>
':����������:	
'	���������, ������������ ��� ����������� �������� ��� �������, �����������
'	���������� ��� ������� ������ "�����" � ������ �������.
':��. �����:	
'	GetNextPageInfoEventArgsClass.BackMode,
'	ObjectEditorClass.WizardGoToNextPage, ObjectEditorClass.WizardGoToPrevPage

'@@XEB_UNDOCHANGES
'<GROUP XEB_nnnn>
':����������:	"��������" ��� ��������� ������ � ����������� ���������.
const XEB_UNDOCHANGES = 0

'@@XEB_DO_NOTHING
'<GROUP XEB_nnnn>
':����������:	������ �� ������ (��� ��������� � ������ ��������).
const XEB_DO_NOTHING = 1 

'@@XEB_TRY_GET_DATA
'<GROUP XEB_nnnn>
':����������:	���������� ����� ������; ������, ����������� � �������� ����� 
'				������, �� ������������ (�������).
const XEB_TRY_GET_DATA = 2


'==============================================================================
' ������ �������������� � IObjectContainerEventsClass
'==============================================================================

' ��������� ��� ������ ������ ��������� ���������
Class SetCaptionArgsForIObjectContainerClass
	Public Caption ' ���������
End Class

'-------------------------------------------------------------------------------
' ��������� ��� ������������/��������������� ����������� ���������
Class EnableControlsArgsForIObjectContainerClass
	Public Enable ' ������� �����������
End Class

'-------------------------------------------------------------------------------
' ���������� �������� � ���������
Class AddEditorPageArgsForIObjectContainerClass
	Public PageTitle	' ���������
	Public PageID	' �������������
	Public PageHint	' ToolTip
End Class

'-------------------------------------------------------------------------------
' ��������� ������ IObjectContainerEventsClass::OnSetWizardOperations
Class SetWizardOperationsArgsClass
	Public bIsLastPage 
	Public bIsFirstPage
	Public EditorPage	' As EditorPageClass - ��������� ������� ��������
	
	Public Function Self()
		Set  Self = Me
	End Function
End Class

'-------------------------------------------------------------------------------
' ��������� ������ IObjectContainerEventsClass::OnSetEditorOperations
Class SetEditorOperationsArgsClass
	Public EditorPage	' As EditorPageClass - ��������� ������� ��������
	
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@ObjectEditorInitializationParametersClass
'<GROUP !!CLASSES_x-editor><TITLE ObjectEditorInitializationParametersClass>
':����������:	
'	����� ������������ ����� ���������, ������������ ��� �������� ����������
'	������������� ���������� ��������� ObjectEditorClass.
':��. �����:	
'	ObjectEditorClass, IObjectContainerEventsClass
'
'@@!!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass
'<GROUP ObjectEditorInitializationParametersClass><TITLE ��������>
Class ObjectEditorInitializationParametersClass
	
	'@@ObjectEditorInitializationParametersClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ObjectType>
	':����������:	������������ ���� �������, ����������� �������������� / ��������.
	':����������:	�������� �� ��������� - vbNullString.
	':���������:	Public ObjectType [As String]
	Public ObjectType
	
	'@@ObjectEditorInitializationParametersClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ObjectID>
	':����������:	������������� �������, ����������� ��������������.
	':����������:	�������� �� ��������� - vbNullString.
	':���������:	Public ObjectID [As String]
	Public ObjectID
	
	'@@ObjectEditorInitializationParametersClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE XmlObject>
	':����������:	������ �������������� �������
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public XmlObject [As IXMLDOMElement]
	Public XmlObject
	
	'@@ObjectEditorInitializationParametersClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE MetaName>
	':����������:	���������������� ���������.
	':����������:	�������� �������� n �������� i:editor. ��� �������� ���������
	'				��������� ��������� ObjectEditorClass ����� ������������ 
	'				��������� �.�. ������������ ���������.<P/>
	'				�������� �� ��������� - vbNullString.
	':���������:	Public MetaName [As String]
	Public MetaName
	
	'@@ObjectEditorInitializationParametersClass.CreateNewObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE CreateNewObject>
	':����������:	���� ������ �������� ������ �������.
	':����������:	�������� �� ��������� - False.
	':���������:	Public CreateNewObject [As Boolean]
	Public CreateNewObject
	
	'@@ObjectEditorInitializationParametersClass.IsAggregation
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE IsAggregation>
	':����������:	���� ������ ������ ������ (������ �������� ����������) 
	'				��� �������� ��������� (�� "���������"). 
	':����������:	���� ���� ���������� � �������� True, �� ��� "��������" 
	'				�������� ��������� (������� "��" ��� "������") ���������� 
	'				ObjectEditorClass �������� ��������� �������� ���������� 
	'				������.<P/>
	'				���� ���� ���������� � �������� False, �� ��������� �������� 
	'				�� ����������; ��� ��������� ������ ���������� ������ � ���� 
	'				������. ����� ����� ������������ ��� ������ "����������" 
	'				���������, � ��� �� � ������ ���������� �������� � ��������
	'				������� ����������.<P/>
	'				�������� �� ��������� - False.
	':���������:	Public IsAggregation [As Boolean]
	Public IsAggregation
	
	'@@ObjectEditorInitializationParametersClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE QueryString>
	':����������:	���������, ������������ � ��������, ��� ��������� QueryStringClass.
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public QueryString [As QueryStringClass]
	Public QueryString
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectEditor>
	':����������:	������������ ��������. �������� ��� ������ "����������" 
	'				���������, ����� - Nothing.
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public ParentObjectEditor [As ObjectEditorClass]
	Public ParentObjectEditor
	
	'@@ObjectEditorInitializationParametersClass.InterfaceMD
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE InterfaceMD>
	':����������:	���������� ���������.
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public InterfaceMD [As IXMLDOMElement]
	Public InterfaceMD
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectID>
	':����������:	������������� "�������������" �������. �������� ��� ������ 
	'				"����������" ���������, ����� - vbNullString.
	':����������:	�������� �� ��������� - vbNullString.
	':���������:	Public ParentObjectID [As String]
	Public ParentObjectID
	
	'@@ObjectEditorInitializationParametersClass.ParentObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentObjectType>
	':����������:	������������ ���� "�������������" �������. �������� ��� 
	'				������ "����������" ���������, ����� - vbNullString.
	':����������:	�������� �� ��������� - vbNullString.
	':���������:	Public ParentObjectType [As String]
	Public ParentObjectType
	
	'@@ObjectEditorInitializationParametersClass.ParentPropertyName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE ParentPropertyName>
	':����������:	������������ ���������� �������� "�������������" ���������, ���
	'				�������������� (��������) ������� �������� ���������� �����
	'				��������. �������� ��� ������ "����������" ���������.
	':����������:	�������� �� ��������� - vbNullString.
	':���������:	Public ParentPropertyName [As String]
	Public ParentPropertyName
	
	'@@ObjectEditorInitializationParametersClass.EnlistInCurrentTransaction
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE EnlistInCurrentTransaction>
	':����������:	����, ������������ ����� ������ ��������� � ������� ���������� 
	'				����. ���� ����� � True, �� ����� �������� �� ��������/�������� 
	'				����� ����������.
	':����������:	�������� �� ��������� - False.
	':���������:	Public EnlistInCurrentTransaction [As Boolean]
	Public EnlistInCurrentTransaction
	
	'@@ObjectEditorInitializationParametersClass.InitialObjectSet
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE InitialObjectSet>
	':����������:	����, ���������� XML-�������, ������� ���������� �������� � ��� 
	'				��� ������������� ���������.
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public InitialObjectSet [As IXMLDOMElement]
	Public InitialObjectSet
	
	'@@ObjectEditorInitializationParametersClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE Pool>
	':����������:	��� (� ������ �������� / ������������� ���� "�������" ��������� ���������.
	':����������:	�������� �� ��������� - Nothing.
	':���������:	Public Pool [As XObjectPool]
	Public Pool
	
	'@@ObjectEditorInitializationParametersClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorInitializationParametersClass><TITLE SkipInitErrorAlerts>
	':����������:	��������� ��������� � ���� ��� ����������� � ���, 
	'				��� � ������ ������������� ���������� �������� UI ��������� ��� �������� �������, 
	'				�� ������� �������� ������� �������������� ������������.
	':���������:	Public SkipInitErrorAlerts [As Boolean]
	Public SkipInitErrorAlerts
	
	'------------------------------------------------------------------------------
	':����������:	"�����������", ������������ ������ ���������� ������
	Private Sub Class_Initialize
		ObjectType	= vbNullString
		ObjectID	= vbNullString
		MetaName	= vbNullString
		ParentObjectID		= vbNullString
		ParentObjectType	= vbNullString
		ParentPropertyName	= vbNullString
		CreateNewObject = False
		IsAggregation	= False
		EnlistInCurrentTransaction = False
		Set QueryString = Nothing
		Set XmlObject	= Nothing
		Set ParentObjectEditor = Nothing
		Set InterfaceMD = Nothing		
		Set InitialObjectSet = Nothing	
		Set Pool = Nothing
	End Sub
End Class	


'===============================================================================
'@@GetNextPageInfoEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE GetNextPageInfoEventArgsClass>
':����������:	
'	��������� ������� "GetNextPageInfo" - ��������� ���������� � ��������� 
'	�������� ����������� �������.
':��. �����:
'	HasNextPageEventArgsClass, EditorStateChangedEventArgsClass
'
'@@!!MEMBERTYPE_Methods_GetNextPageInfoEventArgsClass
'<GROUP GetNextPageInfoEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass
'<GROUP GetNextPageInfoEventArgsClass><TITLE ��������>
Class GetNextPageInfoEventArgsClass

	'@@GetNextPageInfoEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetNextPageInfoEventArgsClass.PageBuilder
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE PageBuilder>
	':����������:	������ �� ��������� EditorPageBuilder-�, ������������� 
	'				��� ���������� ������������� ��������.
	':���������:	Public PageBuilder [As IEditorPageBuilder]
	Public PageBuilder
	
	'@@GetNextPageInfoEventArgsClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE PageTitle>
	':����������:	��������� ��������.
	':���������:	Public PageTitle [As String]
	Public PageTitle
	
	'@@GetNextPageInfoEventArgsClass.CanBeCached
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE CanBeCached>
	':����������:	�������, �������� ����� ����������� ��������:
	'				* Ture - ������������� �������� ����� ���� ������������;
	'				* False - ����������� ������������� �������� ���������.
	':���������:	Public CanBeCached [As Boolean]
	Public CanBeCached
	
	'@@GetNextPageInfoEventArgsClass.BackMode
	'<GROUP !!MEMBERTYPE_Properties_GetNextPageInfoEventArgsClass><TITLE BackMode>
	':����������:	����� ��������� ������� ��� ����������� �� ���������� ��������
	'				������������� �������.
	':����������:	�������� �������� ���� ��������� ���� XEB_nnnn.
	'				���� �������� ������ (������� �� Empty), �� �������� ��������
	'				�������������� �����, ���������� ��������� BackMode ���������.
	':���������:	Public BackMode [As Int]
	Public BackMode
	
	' ���������� ����� ������������� �������.
	Private Sub Class_Initialize
		Cancel = False
		CanBeCached = False
	End Sub
	
	'@@GetNextPageInfoEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetNextPageInfoEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As GetNextPageInfoEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@HasNextPageEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE HasNextPageEventArgsClass>
':����������:	
'	��������� ������� "HasNextPage" - ��������� �������� ������� ��������� 
'	�������� ����������� �������.
':��. �����:
'	GetNextPageInfoEventArgsClass, EditorStateChangedEventArgsClass
'
'@@!!MEMBERTYPE_Methods_HasNextPageEventArgsClass
'<GROUP HasNextPageEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_HasNextPageEventArgsClass
'<GROUP HasNextPageEventArgsClass><TITLE ��������>
Class HasNextPageEventArgsClass

	'@@HasNextPageEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_HasNextPageEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@HasNextPageEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_HasNextPageEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	���������, ������������ ������������ �������. ��������� ��������:
	'	* True - ��������� �������� (�������) ����������;
	'	* False - ��������� �������� (� �������) ���.
	':���������:	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	' ���������� ����� ������������� ����������
	Private Sub Class_Initialize
		Cancel = False
		ReturnValue = False
	End Sub
	
	'@@HasNextPageEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_HasNextPageEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As HasNextPageEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@EditorStateChangedEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE EditorStateChangedEventArgsClass>
':����������:	
'	���������, ����������� ��������� ��������� ���������; ��������� ������� 
'	Validate, BeforePageStart, PageStart, BeforePageEnd, PageEnd, UnLoading
':��. �����:
'	GetNextPageInfoEventArgsClass, HasNextPageEventArgsClass
'
'@@!!MEMBERTYPE_Methods_EditorStateChangedEventArgsClass
'<GROUP EditorStateChangedEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass
'<GROUP EditorStateChangedEventArgsClass><TITLE ��������>
Class EditorStateChangedEventArgsClass

	'@@EditorStateChangedEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@EditorStateChangedEventArgsClass.Reason
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE Reason>
	':����������:	������� ��������� ���������.
	':����������:	�������� �������� ���� ��������� ���� REASON_nnnn.
	':���������:	Public Reason [As Int]
	Public Reason
	
	'@@EditorStateChangedEventArgsClass.ErrorMessage 
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE ErrorMessage>
	':����������:	
	'	����� ��������� �� ������, ��������� � �������� ���������� ���������� 
	'	������� (��. ���������).
	':����������:			
	'	�������� �������� ������������� ������� ��������� ������ � ��� ������,
	'	����� �������� EditorStateChangedEventArgsClass.ReturnValue ����������� � 
	'	�������� False. � ���� ������ �������� ���������� �������� ����� � ���� 
	'	��������� �� ������.
	'	��� ������� UnLoading �������� ������������.
	':��. �����:
	'	EditorStateChangedEventArgsClass.ReturnValue,
	'	EditorStateChangedEventArgsClass.SilentMode
	':���������:	Public ErrorMessage [As String]
	Public ErrorMessage
	
	'@@EditorStateChangedEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE ReturnValue>
	':����������:	
	'	���������, ������������ ������������ �������. �����:
	'	* ��� ������� ���� <B>Before<I>NNNN</I></B>:
	'		- False - �� ���������� �������� �����������;
	'		- True - ����������� ���������� ���������.
	'	* ��� ������� UnLoading ����� ����� ��������������� � window.event.returnValue � Window_onBeforeUnload
	'	* ��� ���� ��������� ������� - ������������
	':��. �����:
	'	EditorStateChangedEventArgsClass.ErrorMessage,
	'	EditorStateChangedEventArgsClass.SilentMode
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EditorStateChangedEventArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_EditorStateChangedEventArgsClass><TITLE SilentMode>
	':����������:	������� "������" ������ ����� ������ (��. ���������).
	':����������:
	'	���� � �������� ��������� ������� ��������� ������, �� � ����� ������ 
	'	���������� �������� ���� ������ ���������� �������� EditorStateChangedEventArgsClass.ReturnValue
	'	� �������� False. �������� ������ ��� ���� ������������ � ErrorMessage.
	'	������ �������� ����� ������ ����������, ����� ������ ������������ 
	'	����� ������������ (��������, ��� ���������� ������� ������������� 
	'	������-���� �������� �� ������������).<P/>
	'	��� ���� ���������� ��������, ����� �����-���� ����������� �� ���������.<P/>
	'	�������� SilentMode ��������� ����������� �� ������ ������ ��������: 
	'	���� �������� ����������� � True, �� ������ ����������� ������ 
	'	����������� ����� �����-���� ���������. ��� ���� ��� ���������� �� ������ 
	'	����� ���� �������� ����� �������� ReturnValue � ErrorMessage.
	':��. �����:	
	'	EditorStateChangedEventArgsClass.ReturnValue, 
	'	EditorStateChangedEventArgsClass.ErrorMessage
	':���������:	Public SilentMode [As Boolean]
	Public SilentMode

	' ���������� ����� ������������� ����������
	Private Sub Class_Initialize
		ReturnValue = True
		Cancel = False
	End Sub
	
	'@@EditorStateChangedEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EditorStateChangedEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As EditorStateChangedEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
'@@EditorLoadEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE EditorLoadEventArgsClass>
':����������:	��������� ������� "Load" ���������.
'
'@@!!MEMBERTYPE_Methods_EditorLoadEventArgsClass
'<GROUP EditorLoadEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_EditorLoadEventArgsClass
'<GROUP EditorLoadEventArgsClass><TITLE ��������>
Class EditorLoadEventArgsClass

	'@@EditorLoadEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@EditorLoadEventArgsClass.StartPageIndex
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE StartPageIndex>
	':����������:	������ ������ �������� ���������������� ���������, ������� 
	'				����� ������� ����� ���������� �������������.
	':���������:	Public StartPageIndex [As Integer]
	Public StartPageIndex

	'@@EditorLoadEventArgsClass.ErrorDescription
	'<GROUP !!MEMBERTYPE_Properties_EditorLoadEventArgsClass><TITLE ErrorDescription>
	':����������:	���� ���������� ��������� ��� ��������, �� ������� �������������
	'				��������� ����� �������, ��������� ����� �������� � �������������� 
	'				���� ���������.
	':���������:	Public ErrorDescription [As String]
	Public ErrorDescription	
	
	' ���������� ����� ������������� ����������
	Private Sub Class_Initialize
		Cancel = False
		StartPageIndex = 0
	End Sub
	
	'@@EditorLoadEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EditorLoadEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As EditorLoadEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
'@@SaveObjectErrorEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE SaveObjectErrorEventArgsClass>
':����������:	��������� ������� "SaveObjectError" ���������.
'
'@@!!MEMBERTYPE_Methods_SaveObjectErrorEventArgsClass
'<GROUP SaveObjectErrorEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass
'<GROUP SaveObjectErrorEventArgsClass><TITLE ��������>
Class SaveObjectErrorEventArgsClass

	'@@SaveObjectErrorEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@SaveObjectErrorEventArgsClass.Action
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE Action>
	':����������:	��������, ����������� � ������ ������; ���� �� �������� 
	'				AFTERERROR_nnnn.
	':���������:	Public Action [As Int]
	Public Action

	'@@SaveObjectErrorEventArgsClass.ErrNumber
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrNumber>
	':����������:	����� / ��� ������.
	':���������:	Public ErrNumber [As Interger]
	Public ErrNumber

	'@@SaveObjectErrorEventArgsClass.ErrSource
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrSource>
	':����������:	�������� ��������� ������.
	':���������:	Public ErrSource [As String]
	Public ErrSource

	'@@SaveObjectErrorEventArgsClass.ErrDescription
	'<GROUP !!MEMBERTYPE_Properties_SaveObjectErrorEventArgsClass><TITLE ErrDescription>
	':����������:	�������� ������.
	':���������:	Public ErrDescription [As String]
	Public ErrDescription
	
	'@@SaveObjectErrorEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SaveObjectErrorEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As SaveObjectErrorEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function	
End Class


'===============================================================================
':����������: ��������� �����, ������������ �� XmlObjectNavigatorClass
Class XmlObjectNavigatorInternalClass
	Private  m_vResult
	Public Function SetResult(vResult)
		SetResult = 0
		If IsObject(vResult) Then
			Set m_vResult = vResult
		Else
			m_vResult = vResult
		End If		
	End Function
	Public Sub GetResult(vResult)
		If IsObject(m_vResult) Then
			Set vResult = m_vResult
		Else
			vResult = m_vResult
		End If		
	End Sub
End Class


'===============================================================================
'@@XmlObjectNavigatorClass
'<GROUP !!CLASSES_x-editor><TITLE XmlObjectNavigatorClass>
':����������:	
'	����� ������ ��� ������������� ������� �� ���� �������� � ���������� �� ��� 
'	XPath-��������. ������������ � �������� ���������� HTML-������������� �������
'	���������, ��� ������������� ������ ds-�������� � ���� "������".
':����������:	
'	��������� ������ �������������� "�������" ������ (�.�. ��������� ������ ����
'	��������� ���������������). ��� ��������� ����������� ������������:
'	- ObjectEditorClass.CreateXmlObjectNavigatorFor
'	- ObjectEditorClass.CreateXmlObjectNavigator
':��. �����:
'	ObjectEditorClass, <P/>
'	<LINK oe_1, ����������� ��������� />
'
'@@!!MEMBERTYPE_Methods_XmlObjectNavigatorClass
'<GROUP XmlObjectNavigatorClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XmlObjectNavigatorClass
'<GROUP XmlObjectNavigatorClass><TITLE ��������>
Class XmlObjectNavigatorClass
	Private m_oXmlObject		' ������ - ������
	Private m_oObjectEditor		' ��������� ObjectEditor �� �������� ��������
	Private m_oSelectorXsl		' XSLT - ��� ���������� "������������" XPath-��������


	'------------------------------------------------------------------------------
	':����������:	���������� "�������������" XPath-�������
	Private Sub executeXPathQuery( sXPathQuery, vResult)
		Dim sXsltString
		Dim oTemplate	' XslTemplate
		Dim oProcessor	' XslProcessor
		Dim oResultSet
		If IsEmpty(m_oSelectorXsl) Then
			sXsltString = _ 				
				"<?xml version=""1.0""?><xsl:stylesheet version=""1.0"" " & vbNewLine & _ 
				"	xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""" & vbNewLine & _ 
				"	xmlns:result=""urn:x-result""" & vbNewLine & _ 
				"	xmlns:x=""urn:x-client-service""" & vbNewLine & _ 
				"	xmlns:w=""urn:editor-window-access"">" & vbNewLine & _ 
				"<xsl:output method=""text""/>" & vbNewLine & _ 
				"<xsl:template match=""*"">" & vbNewLine & _ 
				"	<xsl:value-of result:result=""result""  select=""result:SetResult(.)""/>" & vbNewLine & _ 
				"</xsl:template>	" & vbNewLine & _ 
				"</xsl:stylesheet>	"
			Set m_oSelectorXsl=XService.XmlFromString( sXsltString) 
		End If
		With m_oSelectorXsl.selectSingleNode("//*[@result:result]/@select")
			.DataType = "string"
			.NodeTypedValue = "result:SetResult(" & sXPathQuery & ")"
		End With
		Set oTemplate = CreateObject( "MSXml2.XslTemplate.3.0")
		' ��������� ������������ ������
		oTemplate.stylesheet = m_oSelectorXsl.ownerDocument
		' ������� ���������
		Set oProcessor = oTemplate.createProcessor
		' �������� ���������� ���������������� �������� - ������
		oProcessor.input = m_oXmlObject
		' �������� ���������� ������ ������� � ������ ���������/�������
		Set oResultSet = New XmlObjectNavigatorInternalClass
		oProcessor.addObject oResultSet, "urn:x-result"
		' �������� ���������� ������ ������� � ���� ���������/�������
		oProcessor.addObject window, "urn:editor-window-access"
		' �������� ���������� ������ ������� � IXClientService
		oProcessor.addObject XService, "urn:x-client-service"
		' ��������������
		oProcessor.transform
		oResultSet.GetResult vResult
	End Sub
	
	
	'-------------------------------------------------------------------------------
	':����������:	
	'	������������� ����������, ����� "�������������" � ������� ���������.
	':���������:	
	'	oObjectEditor - [in] ������ ���������, � �������� ����������� "�������������"
	'	oXmlObject	- [in] ������ ds-�������, "���������������" � "������"
	':����������:	
	'	��������! ���������� �� ObjectEditorClass, ������ �� ��������!
	Public Sub Attach(oObjectEditor, oXmlObject)
		' ���������������� ����� ������ ���� ���!
		If IsObject(m_oObjectEditor) Then Exit Sub
		Set m_oObjectEditor = oObjectEditor
		' ���������� ���������� xml-������ � ���������� ��� � ����� XMLDocument
		Set oXmlObject = oXmlObject.cloneNode( True)
		XService.XmlGetDocument.appendChild oXmlObject
		XService.XmlSetSelectionNamespaces oXmlObject.ownerDocument
		Set m_oXmlObject = oXmlObject
	End Sub
	
	
	'---------------------------------------------------------------------------
	':����������:	������������ ������� ��������
	':���������:	[in] sPropertyPath - ���� �� �������� ����� �����.
	':�������: 		doExpand "Worker.Department"
	'				doExpand "Prop1.SubProp2.SubSubProp3"
	Private Sub doExpand(sPropertyPath)
		Dim aPropertyPath
		Dim oXmlNode
		Dim sXPath
		Dim i
		aPropertyPath = Split(sPropertyPath,".")
		For i=0 To UBound(aPropertyPath)
			If 0=i Then
				sXPath = aPropertyPath(i)
			Else
				sXPath = sXPath & "/*/" & aPropertyPath(i)
			End If		
			' �� ���� ��������� � ���������� � ���� ������������� LOB-��������� (@loaded='0')
			For Each oXmlNode In m_oXmlObject.selectNodes(sXPath & "[@loaded='0' or (*[@oid and not (*)])]")
				LoadXmlProperty oXmlNode 
			Next
		Next
	End Sub


	'---------------------------------------------------------------------------
	':����������:
	'	������������� �������� � ������. � �������� ���������� ������� �� ���� 
	'	(��� ������������� ��� �����������), ��������������� ���������.
	':���������:
	'	oXmlProperty - [in] XML-�������� � ���������� read-only ������, ������� 
	'					��������� ���������� (��������� IXMLDOMElement)
	Private Sub LoadXmlProperty( oXmlProperty )
		Dim oXmlPropertyInPool			' As IXMLDOMElement - �������� � ����, ��������������� ����������� ��������
		Dim oNode						' As IXMLDOMElement - ������-�������� ��������
		
		' ������� ������� �������� � ����, ��� ���� ��� ������������� ������������
		Set oXmlPropertyInPool = m_oObjectEditor.Pool.GetXmlProperty(oXmlProperty.parentNode, oXmlProperty.nodeName)
		' ������� ��������
		oXmlProperty.selectNodes("*|@loaded").removeAll
		' ������ �� ���� ��������� � �������� �� ����
		For Each oNode In oXmlPropertyInPool.selectNodes("*")
			' � ��� ������� �������-�������� �������� ������� ������ ������ � ����, � �������� ��� ����� � ���������� ��������
			oXmlProperty.appendChild m_oObjectEditor.Pool.GetXmlObjectByXmlElement(oNode, Null).cloneNode(true)
		Next
	End Sub


	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.ExpandProperty
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE ExpandProperty>
	':����������:	��������� ������������� �������� ������� �������.
	':���������:    ������� ��������� ������ XmlObjectNavigatorClass.
	':���������:	
	'	sPropertyPaths - [in] ����� ����� �� ��������; ���� ����������� ������� (��. "���������")
	':����������:	
	'	"����" ���� �������� ������� ��������� �������; �������� � "����" 
	'	����������� ������: "��������1.��������2.��������N" (��. ������� �����).
	'	�������� sPropertyPaths ����� �������� ��������� "�����", ����������� 
	'	�������� �������. ����� "�������������" ��� ������� �������, �������� 
	'	������, � ������� �� �������� � ��������� sPropertyPaths.
	':�������:
	'	ExpandProperty "Worker.Department"
	'	ExpandProperty "Prop1.SubProp2.SubSubProp3"
	'	ExpandProperty "Worker.Department,Prop1.SubProp2.SubSubProp3,SomeProp"
	':��. �����:
	'	XmlObjectNavigatorClass.MoveContextTo, 
	'	XmlObjectNavigatorClass.XmlObject
	':���������:
	'	Public Function ExpandProperty( 
	'		sPropertyPaths [As String] 
	'	) [As XmlObjectNavigatorClass]
	Public Function ExpandProperty(sPropertyPaths)
		Dim sPropertyPath
		Dim aPropertyPath
		Dim i
		
		sPropertyPath = Replace(sPropertyPaths, " ", vbNullString)
		sPropertyPath = Replace(sPropertyPath, vbCr, vbNullString)
		sPropertyPath = Replace(sPropertyPath, vbLf, vbNullString )
		sPropertyPath = Replace(sPropertyPath, vbTab, vbNullString)
		
		aPropertyPath = Split(sPropertyPath,",")
		For i=0 To UBound(aPropertyPath)
			doExpand aPropertyPath(i)
		Next
		Set ExpandProperty = Me
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.MoveContextTo
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE MoveContextTo>
	':����������:	����������� ��������� ����������.
	':���������:    ������� ��������� ������ XmlObjectNavigatorClass.
	':���������:	oXmlObject - [in] ����� ��������
	':����������:	
	'	�������� - ��� ds-������, ������������ �������� �������������� 
	'	"�������������" ���� ������� � XML-"������". ���������� �������� 
	'	�������� ��� �������� ��������� XmlObjectNavigatorClass, ��� ������
	'	������� ObjectEditorClass.CreateXmlObjectNavigatorFor ��� 
	'	ObjectEditorClass.CreateXmlObjectNavigator.<P/>
	'	��������, ���������� ��������� oXmlObject, ������ ���� �� ���� �� XML-
	'	���������, ��� � ������� ��������, � ��� �� ������ ������������ ������ 
	'	ds-������� (����� �������� "oid").
	':��. �����:
	'	XmlObjectNavigatorClass.ExpandProperty,
	'	XmlObjectNavigatorClass.XmlObject
	':���������:
	'	Public Function MoveContextTo( 
	'		oXmlObject [As IXMLDOMElement] 
	'	) [As XmlObjectNavigatorClass]
	Public Function MoveContextTo(oXmlObject)
		If Not (oXmlObject.ownerDocument Is m_oXmlObject.ownerDocument) Then
			err.Raise -1, "XmlObjectNavigatorClass::MoveContextTo",  "oXmlObject must be from same Document"
		End If
		If IsNull(oXmlObject.getAttribute("oid")) Then
			err.Raise -1, "XmlObjectNavigatorClass::MoveContextTo",  "oXmlObject must be XmlObject, Not XmlProperty"
		End If	
		Set m_oXmlObject = oXmlObject
		Set MoveContextTo = Me
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectObjectInPool
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectObjectInPool>
	':����������:	
	'	��������� ������ ds-������� �� ���� �������� �� XPath-�������, ������������ 
	'	� "����������� ������" (��. "���������").
	':���������:    
	'	XML-������ ���������� ������� (��� IXMLDOMElement) ��� Nothing.
	':���������:	
	'	sXPathQuery - [in] XPath-������, ������������ ���������� ������ � "������"
	':����������:	
	'	XPath-������ ����������� �� �������� "������" ������, "������������" 
	'	� ��������������� � ���������� (� ������� ���������� XmlObjectNavigatorClass). 
	'	���� ��������� ��������� ������� ���� ds-������, �� ����� ���������� ������ 
	'	�� ���� ������ � ����.
	':������:		
	'	Set oExecutor = nav.SelectObjectInPool( "Tasks/Task[position()=last()]/Worker/SystemUser" )
	':��. �����:
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectNodes, 
	'	XmlObjectNavigatorClass.SelectScalar
	':���������:
	'	Public Function SelectObjectInPool( 
	'		sXPathQuery [As String] 
	'	) [As IXMLDOMElement]
	Public Function SelectObjectInPool(sXPathQuery)
		Dim oLocalObject
		Dim sObjectID
		Set SelectObjectInPool = Nothing
		Set oLocalObject = SelectNode(sXPathQuery)
		If oLocalObject Is Nothing Then Exit Function
		sObjectID = oLocalObject.GetAttribute("oid")
		If Not IsNull(sObjectID) Then
			Set SelectObjectInPool = m_oObjectEditor.Pool.GetXmlObjectByXmlElement( oLocalObject, Null) 	
		End If	
	End Function
	

	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectNode
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectNode>
	':����������:	
	'	��������� ������ ����� ���������� "���������������" XPath-�������.
	':���������:    
	'	��������� ������� (��� ��������� IXMLDOMElement), ��� Nothing.
	':���������:	
	'	sXPathQuery - [in] ����� "���������������" XPath-�������
	':����������:	
	'	"��������������" XPath-������ - ��� ������, ����������� ��������� 
	'	����������� XSLT-�������, � ����� <B>����������</B> ������� (��.
	'	������� �����).<P/>
	'	XPath-������ ����������� �� �������� "������" ������, "������������" 
	'	� ��������������� � ���������� (� ������� ���������� XmlObjectNavigatorClass).
	':�������:		
	'	' "�������������� ������" �������� ����� ���������� ������� SomeFunction:
	'	Set oExecutor = nav.SelectNode( "Tasks/Task/Worker/SystemUser[0!=w:SomeFunction(.)]" )
	'	' "�������������� ������" �������� ����� ����������� XSLT-������� last:
	'	Set oExecutor = nav.SelectNode( "Tasks/Task[position()=last()]/Worker/SystemUser" )
	':��. �����:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectScalar, XmlObjectNavigatorClass.SelectNodes
	':���������:
	'	Public Function SelectNode( sXPathQuery [As String] ) [As IXMLDOMElement]
	Public Function SelectNode(sXPathQuery)
		Dim oNodes
		Set oNodes = SelectNodes(sXPathQuery)
		If 0 < oNodes.Length Then
			Set SelectNode = oNodes.Item(0)
		Else
			Set SelectNode = Nothing
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectScalar
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectScalar>
	':����������:
	'	��������� ��������� ������ ����� ���������� "���������������" XPath-�������.
	':���������:    
	'	��������� ������.
	':���������:	
	'	sXPathQuery - [in] ����� "���������������" XPath-�������
	':����������:	
	'	"��������������" XPath-������ - ��� ������, ����������� ��������� 
	'	����������� XSLT-�������, � ����� <B>����������</B> ������� (��.
	'	������� �����).<P/>
	'	XPath-������ ����������� �� �������� "������" ������, "������������" 
	'	� ��������������� � ���������� (� ������� ���������� XmlObjectNavigatorClass).
	':�������:		
	'	nSum = nav.SelectScalar( "sum(Order/Position/Price)" )
	'	nCount	= nav.SelectScalar( "Order/Position" )
	':��. �����:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectNodes
	':���������:
	'	Public Function SelectScalar( sXPathQuery [As String] ) [As Variant]
	Public Function SelectScalar(sXPathQuery)
		Dim vResult
		executeXPathQuery sXPathQuery, vResult
		If IsObject(vResult) Then 
			If 0=StrComp("IXMLDOMNodeList", TypeName( vResult), vbTextCompare) Then
				SelectScalar = vResult.Length
			Else
				SelectScalar = TypeName( vResult)
			End If
		Else
			SelectScalar = vResult
		End If	
	End Function
	

	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.SelectNodes
	'<GROUP !!MEMBERTYPE_Methods_XmlObjectNavigatorClass><TITLE SelectNodes>
	':����������:	
	'	��������� ������ ������ ����� ���������� "���������������" XPath-�������.
	':���������:    
	'	����� ������ (��� ��������� IXMLDOMSelection), ��� Nothing.
	':���������:	
	'	sXPathQuery - [in] ����� "���������������" XPath-�������
	':����������:	
	'	"��������������" XPath-������ - ��� ������, ����������� ��������� 
	'	����������� XSLT-�������, � ����� <B>����������</B> ������� (��.
	'	������� �����).<P/>
	'	XPath-������ ����������� �� �������� "������" ������, "������������" 
	'	� ��������������� � ���������� (� ������� ���������� XmlObjectNavigatorClass).
	':�������:
	'	Set oExecutors = nav.SelectNodes( "Tasks/Task/Worker/SystemUser[0!=w:SomeFunction(.)]" )
	':��. �����:
	'	XmlObjectNavigatorClass.SelectObjectInPool, 
	'	XmlObjectNavigatorClass.SelectNode, XmlObjectNavigatorClass.SelectScalar
	':���������:
	'	Public Function SelectNodes( sXPathQuery [As String] ) [IXMLDOMSelection]
	Public Function SelectNodes(sXPathQuery)
		Dim vResult
		executeXPathQuery sXPathQuery, vResult
		If 0=StrComp("IXMLDOMNodeList", TypeName( vResult), vbTextCompare) Then
			Set SelectNodes = vResult
		Else
			Set SelectNodes = m_oXmlObject.SelectNodes("*['1'='2']")
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XmlObjectNavigatorClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_XmlObjectNavigatorClass><TITLE XmlObject>
	':����������:	���������� ������� �������� ����������.
	':����������:	
	'	�������� - ��� ds-������, ������������ �������� �������������� 
	'	"�������������" ���� ������� � XML-"������". ���������� �������� 
	'	�������� ��� �������� ��������� XmlObjectNavigatorClass, ��� ������
	'	������� ObjectEditorClass.CreateXmlObjectNavigatorFor ��� 
	'	ObjectEditorClass.CreateXmlObjectNavigator.<P/>
	'	�������� ������ ��� ������.
	':��. �����:
	'	XmlObjectNavigatorClass.MoveContextTo, 
	'	XmlObjectNavigatorClass.ExpandProperty
	':���������:
	'	Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Get XmlObject
		Set XmlObject = m_oXmlObject
	End Property
End Class


'===============================================================================
'@@ObjectEditorClass
'<GROUP !!CLASSES_x-editor><TITLE ObjectEditorClass>
':����������:
'	�����, ����������� ������ � ������ ��������� / �������.
':��������:
'	����� ��������� ������ ����������� �������������� ds-�������:
'	� ������ �������� � ���������� ds-�������, ����������� (���������) ��������;
'	- ������ ������ � ����� ������ ds-��������;
'	- ������ ������ � ����������� ������� ��������;
'	- ������ ������ �� ���������� ���������.
' ������� (������������ ����������� EventEngineClass, ��. ��� �� 
'	<LINK Client_EventEngine, ������������ ������� Web-�������/>):
' <xtable width="100%">
' �������                 �������� �������                                    ����� ���������� �������
' ---------------------   -------------------------------------------------   ------------------------------------
' Load                    ���������� ������������� ���������. ���������       (c������ �� �����������������)
'                          ������� ��� �� �������������������.
' BeforePageStart         ����� ������� ���������� ��������.                  EditorStateChangedEventArgsClass
' PageStart               ������� �������� ��������� � �����������������,     EditorStateChangedEventArgsClass
'                          �������� ���������� ��������, ����� ����������      
'                          �� ������ ��������� �������.
' BeforePageEnd           ����� ������ �� ��������. ���� ReturnValue          EditorStateChangedEventArgsClass
'                          ����������� � �������� False, ������������ 
'                          �������� �� ����������.
' ValidatePage            ��� ����� �� ��������, � �������� ����� ������.     EditorStateChangedEventArgsClass
'                          ���� ReturnValue ����������� � �������� False, 
'                          ������������ �������� �� ����������.
' PageEnd                 ��� ����� �� ��������, ����� ���������� �����       EditorStateChangedEventArgsClass
'                          ������. ���� ReturnValue ����������� � �������� 
'                          False, ������������ �� ����������.
' Validate                �������� ������ ��� �������� ���������.             EditorStateChangedEventArgsClass
' AcceptChanges           (����������� � ����������; � ������� ����������     -
'                          �� ������������).
' SaveObjectError         ��� ���������� ������ ��������� ������.             SaveObjectErrorEventArgsClass
' UnLoading				  ��� �������� ��������� ����� ��������.			  EditorStateChangedEventArgsClass
'							���������� ����� ����������������� ��������		  
' UnLoad                  ��� �������� ��������� ����� ��������.              (������� �� �����������������)
' GetNextPageInfo         ��������� ���������� � ��������� ����               GetNextPageInfoEventArgsClass
'                          "�����������" �������.
' HasNextPage             ��������� ���������� � ������� ���������� ����      HasNextPageEventArgsClass
'                          "�����������" �������.
' GetObject               ��� �������� ������� ds-������� � ������� � ���.    GetObjectEventArgsClass
' Accel                   ��� ������� ���������� ������.                      AccelerationEventArgsClass
' PrepareSaveRequest      ������������ ���������� ������� ��� ��������        PrepareSaveRequestEventArgsClass
'                          ���������� ������ ����.
' Saved                   ����� ��������� ���������� ������ ����.             (c������ �� �����������������)
' SetCaption              ��� ��������� ��������� ������� / ���������.        SetCaptionEventArgsClass
' </xtable>
'	<P/> 
'	�������� ��� �� ��������� ��������� ����������� ����������� �������:
' <xtable width="100%">
' �������� �������                                                  ����������� ����������
' ---------------------------------------------------------------   -----------------------------------------
' GetObjectConflict - ������� ���� (��. XObjectPoolClass)<P/>       ObjectEditorClass.OnGetObjectConflict
'  ������������ ��� ����������� ������������ � ������ ds-�������    
'  ��� �������������� � ����, � ������ ���� �� �������,
'  ����������� � �������.
' DeleteObjectConflict - ������� ����  (��. XObjectPoolClass)<P/>   ObjectEditorClass.OnDeleteObjectConflict
'  ��� ������� �������� ds-�������, ��� ����������� ������ ��
'  ��������� ������.
' </xtable>
'
':��. �����:
'	XObjectPoolClass, XmlObjectNavigatorClass, <P/>
'	<LINK oe_1, ����������� ��������� />
'
'@@!!MEMBERTYPE_Methods_ObjectEditorClass
'<GROUP ObjectEditorClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ObjectEditorClass
'<GROUP ObjectEditorClass><TITLE ��������>
Class ObjectEditorClass
	Private m_sSaveCommandName			' As String - ������������ ��������� �������, ������������ ��� ����������
	Private m_bAggregation				' As Boolean - ������� ����������
	Private m_bIncluded					' As Boolean - ������� ������ � ������ ���������� ���������/�������
	Private m_sUniqueID					' As String - ��� ���������� ����������, ���������� ������ �� ������� ��������� ������	
	Private m_bCreateNewObject			' As Boolean - ������� �������� ������ �������
	Private m_bIsTabbed					' As Boolean - ����� ������	(true - �������� � ����������, false - ��������� ������)
	Private m_sObjectType				' As String - ��� ���� ��������������/������������ �������	
	Private m_sObjectID					' As String - ������������� �������������� �������	
	Private m_sMetaName					' As String - ������������ �������� ���������/������� � ����������	
	Private m_oInterfaceMD				' As XMLDOMElement - ���������� ���������/������� (XmlDOMElement)	
	Private m_oPageStack				' As StackClass - ���� ������������ ������� ����������� �������	
	Private m_oQueryString				' As QueryString -������ QueryStringClass
	Private m_nDefaultBackMode			' As Integer - ����� ��������� ������� �� ��������� ��� �������� ����� �� ��������
	Private m_nCurrentPageNo			' As Integer - ����� �� 1 ���� ������� �������/���� ��������� �������
	Private m_oParseHtmlIDRegExp		' As RegExp - ��������������� ���������� ���������	
	Private m_oObjectContainerEventsImp	' As IObjectContainerEventsClass - ������ �� ���������
	Private m_oPages					' As Scripting.Dictionary - ������� �������� �������: ���� - ������������, �������� - ��������� XEditorPage
	Private m_bIsInterrupted			' As Boolean - ???
	Private m_bMayBeInterrupted			' As Boolean - ???
	Private m_bControlsEnabled			' As Boolean - ������� ����������� ��������� �� ��������	
	Private EVENTS						' As String - ������ ������� ���������
	Private m_oEventEngine				' As EventEngineClass - event engine
	Private m_sParentObjectID			' As String - ������������� ������������� ������� (������ ��� ��������� ����������)
	Private m_sParentObjectType			' As String - ������������ ���� ������������� ������� (������ ��� ��������� ����������)
	Private m_sParentPropertyName		' As String - ������������ ������������� �������� (������ ��� ��������� ����������)
	Private m_oParentObjectEditor		' As ObjectEditorClass - ��������� ������������� ��������� (��� ��������� ��������� - Nothing)
	Private m_oActivePage				' As EditorPageClass - ������� �������� ���������
	Private m_oNamesDictionary			' As Scripting.Dictionary - ���������� ���-����� ���� ������� ��� ��������� ����������� ������������ ��������
	Private m_oPool						' As XObjectPoolClass - ��� ��������
	Private m_bManageCurrentTransaction	' As Boolean - ������� ����, ��� �������� ��������� ������� ����������� ���� (�.�. � Init ������ BeginTransaction, � Save/Cance - Commit/Rollback)
	Private m_oPopUpForDebugMenu		' As CROC.XPopUpMenu ��� ����������� ����
	Private m_bSkipInitErrorAlerts		' As Boolean - ��������� ��������� � ���� ��� ����������� � ���, 
										'	��� � ������ ������������� ���������� �������� UI ��������� ��� �������� �������, 
										'	�� ������� �������� ������� �������������� ������������.

	'------------------------------------------------------------------------------
	' "�����������" �������
	Private Sub Class_Initialize
		const HTML_ID_PARSING_REGEXP = "^PE\$(\w+)\@(\w+)\(([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\)$"
		Set m_oParseHtmlIDRegExp = New RegExp
		Set m_oEventEngine = X_CreateEventEngine
		EVENTS = "Load,BeforePageStart,PageStart,BeforePageEnd,ValidatePage,PageEnd,Validate,AcceptChanges,SaveObjectError,UnLoad,UnLoading," & _
			"GetNextPageInfo,HasNextPage,DeleteObjectConflict,GetObjectConflict,GetObject,Accel,PrepareSaveRequest,Saved,SetCaption"
		m_oParseHtmlIDRegExp.Pattern = HTML_ID_PARSING_REGEXP
		' �������� ������� ��� �������� ���������� ������������ �������
		Set m_oNamesDictionary = CreateObject("Scripting.Dictionary")
		m_oNamesDictionary.CompareMode = vbTextCompare
		
		' ������� ���������� ���������� ����������, � ������� �������� ������� ���������
		m_sUniqueID = "g_oXE_" & Replace( XService.NewGuidString, "-", "")
		ExecuteGlobal	"Dim " & m_sUniqueID
		Execute			"Set " & m_sUniqueID & " = Me"
	End Sub
	

	'------------------------------------------------------------------------------
	':����������:	���������� �������� ������� � ����������� �����������
	Private Sub fireEvent(sEventName, oEventArgs)
		XEventEngine_FireEvent m_oEventEngine, sEventName, Me, oEventArgs
	End Sub
	

	'------------------------------------------------------------------------------
	':����������:	���������� �������� ������� � ����������� �����������. 
	':����������:	������ ��� ����������� �������������!
	Public Sub Internal_FireEvent(sEventName, oEventArgs)
		fireEvent sEventName, oEventArgs
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.EventEngine
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE EventEngine>
	':����������:	���������� ��������� EventEngineClass, ������������ ���������� ��� ��������� �������
	':���������:	Public Property Get EventEngine [As EventEngineClass]
	Public Property Get EventEngine
		Set EventEngine = m_oEventEngine
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectContainerEventsImp
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectContainerEventsImp>
	':����������:	���������� ��������������� � ���������� ���������.
	':����������:	�������� ������ ��� ������.
	':��. �����:	IObjectContainerEventsClass, <LINK oe_1, ����������� ��������� />
	':���������:	Public Property Get ObjectContainerEventsImp [As IObjectContainerEventsClass]
	Public Property Get ObjectContainerEventsImp
		Set ObjectContainerEventsImp = m_oObjectContainerEventsImp
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CurrentPageNo
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE CurrentPageNo>
	':����������:	���������� ����� �������� ���� �������.
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get CurrentPageNo [As Int]
	Public Property Get CurrentPageNo
		CurrentPageNo = m_nCurrentPageNo
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HelpPage>
	':����������:	������������ ������� �������� ������� (�������� �������� 
	'				help-page ������������ ��������� � ���������).
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get HelpPage [As String]
	Public Property Get HelpPage
		HelpPage = InterfaceMD.getAttribute("help-page")
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HelpPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HelpPage>
	':����������:	������� ������� ����������� �������� ������� ��� ���������:
	'				- True - �������� ������� ������; ������������ �������� 
	'					������������ ��������� ObjectEditorClass.HelpPage;
	'				- False - �������� ������� �� ������.
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get IsHelpAvailiable [As Boolean]
	Public Property Get IsHelpAvailiable
		If Not IsNull(HelpPage) Then
			IsHelpAvailiable = True
		Else
			IsHelpAvailiable = False
		End If	
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.TransactionID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE TransactionID>
	':����������:	���������� ������������� ������� ���������� ����������.
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get TransactionID [As String]
	Public Property Get TransactionID
		TransactionID = m_oPool.TransactionID
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.UniqueID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE UniqueID>
	':����������:	���������� ��� ���������� ���������� ����������, � ������� 
	'				��������� ������ �� ������� ��������� ������.
	':���������:	Public Function UniqueID() [As String]
	Public Function UniqueID()
		UniqueID = m_sUniqueID
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Signature
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Signature>
	':����������:	���������� ������ � ���������� ���������.
	':����������:	��������� ������������ ��� ������������ ������������ �����, 
	'				� ������� ����������� ���������������� ������.
	':���������:	Public Function Signature() [As String]
	Public Function Signature()
		Signature = Iif(IsEditor,"XE","XW") & "." & ObjectType & "." & MetaName & "."
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.DefaultBackMode
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE DefaultBackMode>
	':����������:	���������� ��������� ���� XEB_nnnn, ��������������� ��������
	'				���� ��������, ����������� ���������� ��� ������� ������ "�����" 
	'				� ������ �������.
	':����������:	�������� ������ ��� ������.
	':��. �����:	XEB_nnnn
	':���������:	Public Property Get DefaultBackMode [As XEB_nnnn]
	Public Property Get DefaultBackMode
		DefaultBackMode = m_nDefaultBackMode
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SaveCommandName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE SaveCommandName>
	':����������:	
	'	���������� ������������ �������� ������� ����������, ������������ ��� 
	'	���������� ������ ����.
	':����������:	
	'	������������ �������� ����� ���� ������ � ����������� ���������, 
	'	� ���������� ����������, ��� �������� �������� "save-cmd" �������� i:editor. 
	'	�� ��������� ������������ ������������ �������� "SaveObject".<P/>
	'	�������� �������� ��� ��� ������, ��� � ��� ���������.
	':��. �����:	
	'	ObjectEditorClass.Save, <P/>
	'	<LINK stdOp_SaveObject, �������� SaveObject - ������ ������ ds-��������/>
	':���������:	
	'	Public Property Get SaveCommandName [As String]
	'	Public Property Let SaveCommandName( sCommandName [As String] )
	Public Property Get SaveCommandName
		SaveCommandName = m_sSaveCommandName
	End Property
	Public Property Let SaveCommandName(sCommandName)
		m_sSaveCommandName = sCommandName
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetHtmlID>
	':����������:	
	'	���������� ������ � ��������������� HTML-��������, ���������������� 
	'	��������� �������� �������.
	':����������:
	'	� UI ��������� ������� �������� ������������� (��� ����������� ��������� 
	'	�������� - property editor, PE) � �������� HTML-������������� ������������ 
	'	������������ HTML-�������. ��� ������� ������ HTML-�������� �������� ���������� 
	'	���������� ������������� (������� ID ��� HTML-����).
	':��. �����:	
	'	SplitHtmlID
	':���������:	
	'	Public Function GetHtmlID( oXmlProperty [As IXMLDOMElement] ) [As String]
	Public Function GetHtmlID(oXmlProperty)
		const HTML_ID_PREFIX = "PE"
		With oXmlProperty.parentNode
			GetHtmlID = HTML_ID_PREFIX & "$" & oXmlProperty.tagName & "@" & .tagName & "(" & .getAttribute("oid") & ")"
		End With	
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SplitHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SplitHtmlID>
	':����������:	
	'	�������� �� ��������� �������������� HTML-��������, ���������������� 
	'	��������� �������� �������, ������������� � ������������ ���� �������, 
	'	� ��� �� ������������ ��������.
	':���������:
	'	sHtmlID			- [in] �������� ������������� HTML-��������
	'	sObjectType		- [out] ������������ ���� ds-�������
	'	sObjectID		- [out]	������������� ds-�������
	'	sPropertyName	- [out]	������������ ��������
	':���������:
	'	���������� ������� ����������� ������� ��������� ��������������:
	'	- True - �������� ������������� ����� ���������� ������. ��������� ����
	'			��������� (������������� � ��� �������, ��� ��������) ���������
	'			�������.
	'	- False - �������� ������������� ����� ������������ ������. ��������
	'			���������� sObjectType, sObjectID � sPropertyName - ������������.
	':��. �����:
	'	GetHtmlID
	':���������:
	'	Public Function SplitHtmlID ( 
	'		sHtmlID [As String], 
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sPropertyName [As String] 
	'	) [As Boolean]
	Public Function SplitHtmlID( sHtmlID, sObjectType, sObjectID, sPropertyName )
		const IDX_PROPERTY_NAME = 0
		const IDX_OBJECT_TYPE	= 1
		const IDX_OBJECT_ID		= 2
		SplitHtmlID = False
		With m_oParseHtmlIDRegExp.Execute(sHtmlID)
			If 1=.Count Then
				With .Item(0).SubMatches
					If 3=.Count Then
						sObjectType = .Item(IDX_OBJECT_TYPE)
						sObjectID = .Item(IDX_OBJECT_ID)
						sPropertyName = .Item(IDX_PROPERTY_NAME)   
						SplitHtmlID = True
					End If
				End With
			End If
		End With  
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.XmlObjectPool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE XmlObjectPool>
	':����������:	���������� XML-������ �������� ����.
	':����������:	��������! ���������������� ��������� ������ � ��������� XML 
	'				�� �������������! ����������� ������ ������ XObjectPoolClass.
	':��. �����:	ObjectEditorClass.Pool, XObjectPoolClass
	':���������:	Public Property Get XmlObjectPool [As IXMLDOMElement]
	Public Property Get XmlObjectPool
		Set XmlObjectPool = m_oPool.Xml
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Pool
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE Pool>
	':����������:	���������� ������ �� ��������� ���� ������, ������������� 
	'				� ��������� � ������ ������.
	':��. �����:	ObjectEditorClass.XmlObjectPool, XObjectPoolClass
	':���������:	Public Property Get Pool [As XObjectPoolClass]
	Public Property Get Pool
		Set Pool = m_oPool
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetXmlPropertyDirty
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetXmlPropertyDirty>
	':����������:	�������� ��������� �������� ��� ����������������.
	':���������:	oXmlProperty - [in] ��������, ���������� ��� ����������������.
	':����������:	������� ���������������� �������� ����������� � ���� ������.<P/>
	'				������ ���� �������, ���������� ��� ����������������, ����� 
	'				�������� �� ������ ��� ������.
	':��. �����:	ObjectEditorClass.Save
	':���������:	Public Sub SetXmlPropertyDirty( oXmlProperty [As IXMLDOMElement] )
	Public Sub SetXmlPropertyDirty(oXmlProperty)
		m_oPool.SetXmlPropertyDirty oXmlProperty
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ExecuteStatement
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ExecuteStatement>
	':����������:	
	'	��������� ��������� VBScript, � �������������� ������������ � ��������� 
	'	������ �� �������� ������� ������� (��. ���������).
	':���������:
	'	oXmlObject - [in] ������ (XMLDOMElement ��������� ���� �������)
	'	sStmt - [in] ������ � ����������� ���������� (��. ���������)
	':����������:
	'	������ � ���������� VBScript ����� �������� ����������� ���� 
	'	<B>item.<I>PropName1</I>{<I>.PropNameN</I>}</B>, ��� <B>item</B> - ��������
	'	�� �����������, � <B>PropName1</B>, <B>PropNameN</B> - ������� ������������ 
	'	������� �������.<P/>
	'	����� ����������� ��������� VBScript ����� �������� ��� ����������� �� 
	'	�������� ��������������� �������, ���������� �� ������� ������������, 
	'	�������� � �����������.
	':���������:
	'	����������� �������� ���������. 
	':��. �����:	
	'	XObjectPoolClass.ExecuteStatement
	':���������:	
	'	Public Function ExecuteStatement( 
	'		oXmlObject [As IXMLDOMElement], ByVal sStmt [As String]
	'	) [As Variant]
	Public Function ExecuteStatement( oXmlObject, ByVal sStmt)
		ExecuteStatement = m_oPool.ExecuteStatement(oXmlObject, sStmt)
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPropertyValue>
	':����������:	
	'	�������� �������� ���������� ������������ ��������, ��������� OPath-�����.
	':���������:	
	'	sOPath - [in] ������ � �������� �������, � ����� ������� ���� ��������� 
	'			�������, ������������ �������� ".", ������������� ������ ���������� 
	'			������������ ��������
	':���������:
	'	�������������� �������� ���������� ������������ �������� ��� Null, ���� 
	'	�������� �������� �� ������ (�������� "������").<P/>
	'	� ��� ������, ���� sOPath ������������� ������ ���������� �������� (���� 
	'	��������, ��� ��� ������������ �������������), ����� ���������� Null ��� 
	'	��������������� ("������") �������, � ������ "[object]" ��� �������������.<P/>
	'	� ������ ������ �������� ������ �������� � ������� ����� ���������� ������
	'	������� ����������.	
	':��. �����:	
	'	XObjectPoolClass.GetPropertyValue
	':���������:	
	'	Public Function GetPropertyValue( sPropertyPath [As String] ) [As Variant]
	Public Function GetPropertyValue(sPropertyPath)
		GetPropertyValue = m_oPool.GetPropertyValue(XmlObject, sPropertyPath)
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlObjectNavigator
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlObjectNavigator>
	':����������:	
	'	������� ��������� XmlObjectNavigatorClass ��� �������� ("���������") 
	'	�������, � ������������� � ��� ��� ������� �������, �������� ���������� 
	'	i:preload � �������� ��������� � ����������.
	':���������:
	'	���������� ������������������ ��������� "����������" XmlObjectNavigatorClass.
	':��. �����:
	'	ObjectEditorClass.CreateXmlObjectNavigatorFor, ObjectEditorClass.XmlObject, 
	'	XmlObjectNavigatorClass
	':���������:
	'	Public Function CreateXmlObjectNavigator [As XmlObjectNavigatorClass]
	Public Function CreateXmlObjectNavigator
		Dim oPreload
		Set CreateXmlObjectNavigator = CreateXmlObjectNavigatorFor(XmlObject)
		For Each oPreload In m_oInterfaceMD.selectNodes("i:preload")
			CreateXmlObjectNavigator.ExpandProperty oPreload.nodeTypedValue
		Next
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlObjectNavigatorFor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlObjectNavigatorFor>
	':����������:	
	'	������� ��������� XmlObjectNavigatorClass ��� ��������� ds-�������.
	':���������:
	'	oXmlObject - [in] ds-������, ��� �������� ��������� "���������"
	':���������:
	'	���������� ������������������ ��������� "����������" XmlObjectNavigatorClass.
	':��. �����:
	'	ObjectEditorClass.CreateXmlObjectNavigator, XmlObjectNavigatorClass
	':���������:
	'	Public Function CreateXmlObjectNavigatorFor( 
	'		oXmlObject [As IXMLDOMElement]
	'	) [As XmlObjectNavigatorClass]
	Public Function CreateXmlObjectNavigatorFor(oXmlObject)
		Set CreateXmlObjectNavigatorFor = New XmlObjectNavigatorClass
		CreateXmlObjectNavigatorFor.Attach Me, GetXmlObjectFromPoolByXmlElement(oXmlObject, Null)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlObjectFromPool
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlObjectFromPool>
	':����������:	
	'	���������� �� ���� ds-������, �������� ����� � ��������������.
	':���������:
	'	sObjectType - [in] ������������ ���� �������
	'	sObjectID	- [in] ������������� �������
	'	sPreloads	- [in] ������ ������������ ������� �������, ������������ 
	'					�� �������, � ������ ���� ������ ������� �����������
	':���������:
	'	XML-������ �������, ��� ��������� IXMLDOMElement.
	':����������:	
	'	���� ����������� ������ � ���� �����������, �� ����� ��������� ������ 
	'	������� � ���, ���������� �� � �������.
	':��. �����:	
	'	ObjectEditorClass.GetXmlObjectFromPoolByXmlElement, 
	'	XObjectPoolClass.GetXmlObject
	':���������:
	'	Public Function GetXmlObjectFromPool(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sPreloads [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectFromPool(sObjectType, sObjectID, sPreloads)
		Set GetXmlObjectFromPool = m_oPool.GetXmlObject( sObjectType, sObjectID, sPreloads)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlObjectFromPoolByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlObjectFromPoolByXmlElement>
	':����������:	
	'	���������� �� ���� ds-������, �������� XML-������� (� ��� ����� - "���������").
	':���������:
	'	oXmlObjectElement - [in] XML-������, � ��� ����� - "��������"
	'	sPreloads - [in] ������ ������������ ������� �������, ������������ �� �������, 
	'				� ������ ���� ������ ������� �����������
	':����������:	
	'	���� ����������� ������ � ���� �����������, �� ����� ��������� ������ 
	'	������� � ���, ���������� �� � �������.
	':��. �����:	
	'	ObjectEditorClass.GetXmlObjectFromPool, XObjectPoolClass.GetXmlObject
	':���������:
	'	Public Function GetXmlObjectFromPoolByXmlElement(
	'		oXmlObjectElement [As IXMLDOMElement], sPreloads [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectFromPoolByXmlElement(oXmlObjectElement, sPreloads)
		Set GetXmlObjectFromPoolByXmlElement = GetXmlObjectFromPool(oXmlObjectElement.tagName, oXmlObjectElement.getAttribute("oid"), sPreloads)
	End Function

	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.LoadXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE LoadXmlProperty>
	':����������:	
	'	��������� �������� �������� XML-������� � �������.
	':���������:
	'	oXmlObject - [in] ������ (IXMLDOMElement ��������� ���� �������); 
	'			�����  ���� Nothing, ���� vProp - XML-�������� (IXMLDOMElement)
	'	vProp - [in] �������� ������� (XmlDOMElement), ��� ������ � ������ ��������
	'	bReload - [in] ������� ������������, ���� �������� ��� ���������
	':���������:
	'	����������� XML-������ ��������, ��� ��������� IXMLDOMElement. ���� �������� 
	'	�� �������, ������������ Nothing.
	':��. �����:	
	'	ObjectEditorClass.GetXmlObjectFromPool, XObjectPoolClass.LoadXmlProperty
	':���������:
	'	Public Function LoadXmlProperty( 
	'		oXmlObject [As IXMLDOMElement], vProp [As Variant] 
	'	) [As IXMLDOMElement]
	Public Function LoadXmlProperty( oXmlObject, vProp )
		Set LoadXmlProperty = m_oPool.LoadXmlProperty( oXmlObject, vProp )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Init
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Init>
	':����������:	
	'	������������� ������� ��������� (��. ������ "���������").
	':���������:	
	'	oObjectContainerEventsImp - [in] ��������� ������, ������������ "���������" 
	'				���������� IObjectContainerEventsClass (��. ������������)
	'	oParams - [in] �������� ������ ������������� ���������, �������� ������ 
	'				ObjectEditorInitializationParametersClass (��. ������������)
	':���������:	
	'	���������� ������� ��������� ���������� ������������� ���������.
	':����������:
	'	������� ������������� ��������� ����������� �� ���������� ��������:
	'	- ������ ������������ � ���������� �������� ���������� �������������
	'		(��. ������������ ObjectEditorInitializationParametersClass);
	'	- ������������� ������������ ������� ��������� (��. <LINK cee-5, ����������� ���������� />);
	'	- ������ ������������ ��������� (��. <LINK oe-4, �������� ��������� />), 
	'		����������� ������� ������ (��. <LINK oe-3, ������ ������ ��������� />;
	'	- ������������� ���� ������ (� �.�. ������ ���������� ����������, ���� 
	'		��� ��� ������� � �������� ��������� �������������);
	'	- ��� ������������� - �������� ������ �������������� ������� � �������;
	'	- ������������� ����������������� ���������� - �������� ��������� ��������
	'		EditorPageClass, �� �������������; �� ���� ����� ������������ �������
	'		�������� ��������� (��. ������������ ������ EditorPageClass);
	'	- ��������� ������� ��������� "Load";
	'	- ������������ ��������� ���������; �� ���� ����� ������������ �������
	'		"SetCaption". �������������� ����� ��������� ���������� ���������� - 
	'		���������� ����� IObjectContainerEventsClass.OnSetCaption;
	'	- ����������� ��������� �������� ���������.
	':���������:
	'	Public Function Init(
	'		oObjectContainerEventsImp [As IObjectContainerEventsClass], 
	'		oParams [As ObjectEditorInitializationParametersClass]
	'	) [As Boolean]
	Public Function Init(oObjectContainerEventsImp, oParams)
		' �������� �������������� ������� ��-���������
		Dim oXmlObject			' As IXMLDOMElement - ������������� xml-������
		Dim oXmlPage			' As IXMLDOMElement - ���� i:page �� ������������ ���������
		Dim oPage				' As XEditorPageClass - �������� �������� ���������
		Dim j
		Dim oXmlPagesMD			' As IXMLDOMNodeList - ��������� ����� i:page �� ������������ ���������
		Dim oEditorPage			' As EditorPageClass - �������� ���������
		Dim oPreload			' As IXMLDOMElement - i:preload � ����������
		Dim sPreload			' ������ �� i:preload
		Dim oNode				' As IXMLDOMNode
		Dim bEnlistInCurrentTransaction	' As Boolean - ������� ����, ��� �������� �������� � ������� ���������� ���� � �� ��������/�������� ����� ����������
		Dim nEditorStartPageIndex	' As Integer - ������ �������� ����������������� ���������, ������� ����� ������� ����� ���������� �������������
		Dim oLoadedXmlObject		' As IXMLDOMElement - xml-������, ����������� �� �������
		
		MayBeInterrupted = False
		
		With oParams
			m_sObjectType = .ObjectType
			m_sObjectID = .ObjectID
			m_sMetaName	 = vbNullString & .MetaName
			m_bCreateNewObject = .CreateNewObject
			m_bAggregation = .IsAggregation
			m_sParentObjectID = .ParentObjectID
			m_sParentObjectType = .ParentObjectType
			m_sParentPropertyName = .ParentPropertyName
			bEnlistInCurrentTransaction = .EnlistInCurrentTransaction
			Set m_oQueryString = .QueryString
			Set oXmlObject = .XmlObject
			Set m_oParentObjectEditor = .ParentObjectEditor
			Set m_oInterfaceMD = .InterfaceMD
			m_bSkipInitErrorAlerts = .SkipInitErrorAlerts
		End With
		
		' �������� ������� ���������
		If oXmlObject Is Nothing And ( Len("" & m_sObjectType)=0 Or Len("" & m_sObjectID)=0 And Not m_bCreateNewObject) Then
			Err.Raise -1, "ObjectEditor::Init", "������ ���� ����� Xml-������, ���� ��� � ������������� (� ������ �������� ����� ���� �� �����)"
		End If
		Set m_oObjectContainerEventsImp = oObjectContainerEventsImp

		' ���������� ��������� ������ ������ ���� ������ (��. x-editor.aspx.cs::GetPageMD)
		If IsNothing(m_oInterfaceMD) Then
			Err.Raise -1, "ObjectEditor::Init", "�� ������ ���������� ���������"
		End If
		' ��������� ������������ ������� ����������
		m_sSaveCommandName = m_oInterfaceMD.GetAttribute("save-cmd")
		If IsNull(m_sSaveCommandName) Then m_sSaveCommandName = "SaveObject"
		
		' �������������� ��������� ������������ ������� ��������� ����������� ��������� (�� ����� ����� ���������)
		m_oEventEngine.InitHandlers EVENTS, "usrXEditor_On"
		m_oEventEngine.AddHandlerForEventWeakly "DeleteObjectConflict", Me, "OnDeleteObjectConflict"
		m_oEventEngine.AddHandlerForEventWeakly "GetObjectConflict", Me, "OnGetObjectConflict"
		
		' ���� ������� ���� �� ������, �������� ������ ������������ ��������� ��� ����� ����� ��������� ���� i:editor.
		' ������� ��� �������. ���� ������� ��������� ���� ������ ����, �� �� ��� � �������.
		m_sMetaName = vbNullString & m_oInterfaceMD.GetAttribute("n")
		
		' �������� ������� ������ ������� ��� �������� �� ���������� ��������.
		If IsNull(m_oInterfaceMD.GetAttribute("wizard-mode")) Then
			m_bIsTabbed	=  True
		Else
			m_bIsTabbed	=  False
			m_nDefaultBackMode = ParseWizardBackMode( m_oInterfaceMD.getAttribute("wizard-mode") )
		End If
		
		' ���
		m_bManageCurrentTransaction = False
		If IsNothing(m_oParentObjectEditor) Then
			' ������������ ObjectEditor �� ����� - ��� ��������� ��� �������� �������� 
			m_bIncluded = False
			' ������, ����� ���� ����� ���
			If IsNothing(oParams.Pool) Then
				' ��� �� ����� - �������� ����� ���
				Set m_oPool = New XObjectPoolClass
				' �.�. ��� ������� �� ����, �� ���������� ��� ����� �� ������ ��� ��������, ������� ������� �������� ��������� ����� ������
				If m_bAggregation Then
					Err.Raise -1, "ObjectEditorClass::Init", "��� ��������� ��������, � ������, ���� ��� �������� �� ����� �������, ������� �������� ��������� ������������"
				End If
				' ��� �� ���� ������� ���, �� � ������� EnlistInCurrentTransaction ���� �����������, �.�. ������� ���������� �� ����������
				If bEnlistInCurrentTransaction Then
					Err.Raise -1, "ObjectEditorClass::Init", "��� ��������� ��������, � ������, ���� ��� �������� �� ����� �������, ������� ������� �������� EnlistInCurrentTransaction ������������, �.�. ������� ���������� �� ����������"
				End If
				' ���� ��� � �� �����, ����� ���� ������ ��������� �������� ��� ��� ��������������� ����������
				If Not oParams.InitialObjectSet Is Nothing Then
					For Each oNode In oParams.InitialObjectSet.selectNodes("*[*]")
						m_oPool.AppendXmlObject oNode.CloneNode(true)
					Next
				End If
			Else
				' ��� �����
				Set m_oPool = oParams.Pool
				' �.�. ��� ����� �������, �� ���� ������������� ��������� � ���, �� �� ��� �� ������ �������� ��������, ��
				' ������� ���� �������� ���������� ���������� �� �� ����� (���� ��� �� ��������������)
				If Not m_bAggregation Then
					Err.Raise -1, "ObjectEditorClass::Init", "��� ��������� ��������� � �������� ������� ����� �������� ������ ���� ����� ������� ��������� (Aggregation)"
				End If
				' ���� ���� �� ���������, �� ������ ����� ����������
				If Not bEnlistInCurrentTransaction Then
					m_bManageCurrentTransaction = True
					m_oPool.BeginTransaction True ' �.�. m_bAggregation = True
				End If
			End If
		Else
			' ����� ��� ��������� ��� ��������� ��������, ������� ��� �� ������������� ��������� � ������ � ��� ����� ����������
			m_bIncluded = True
			Set m_oPool = m_oParentObjectEditor.Pool
			' �� ������� ����� ���������� ���������� ���� �������������� ������ �� �������� ������, ������� ��������, ��� m_bAggregation=True
			If Not m_bAggregation Then
				Err.Raise -1, "ObjectEditorClass::Init", "��� ���������� ��������� ������ ���� ������ ����� ������� ��������� (Aggregation), �.�. �������� ����� ""����������"" ���������� ����� ������ �������� ��������"
			End If
			' ���� ���� �� ���������, �� ������ ����� ����������
			If Not bEnlistInCurrentTransaction Then
				m_bManageCurrentTransaction = True
				m_oPool.BeginTransaction True ' �.�. m_bAggregation = True
			End If
		End If
		
		' �������������� ������� �������� � ����, ����� �������� �� ���� �������
		m_oPool.RegisterEditor Me

		' ���� �������������� ������� �� ���� �� ������� (��������� � x-utils.vbs::ObjectEditorDialogClass::Show), 
		' �� �� ����� ����� �������� �� ������� � ������� ���� oObjectData - �����������!
		' (������ ����� �������� �� ����� ����������)

		Set oLoadedXmlObject = document.all("oObjectData",0)
		If Not oLoadedXmlObject Is Nothing Then
			Set oLoadedXmlObject = XService.XmlFromString( oLoadedXmlObject.value )
			' ������ ���������� �������� � ��������� ���� �� �����. 
			If Not oLoadedXmlObject Is Nothing Then
				m_oPool.Internal_AppendXmlObjectTreeFromServer oLoadedXmlObject
			End If
		End If
		
		
		' �������������, ��� ������������� ������ ���������� � ����
		If IsNothing(oXmlObject) Then
			' ��� �������� ��� � ������������� �������
			ReportStatus "�������� ������ � �������..."
			sPreload = Empty
			For Each oPreload In m_oInterfaceMD.selectNodes("i:preload")
				If IsEmpty(sPreload) Then
					sPreload =  oPreload.nodeTypedValue
				Else
					sPreload = 	sPreload & " " & oPreload.nodeTypedValue
				End If	
			Next
			Set oXmlObject = m_oPool.GetXmlObject( m_sObjectType, m_sObjectID, sPreload)
			If Not oXmlObject Is Nothing Then m_sObjectID = oXmlObject.getAttribute("oid")
		Else
			' �������� xml-������
			ReportStatus "������������� ������ ��� ��������������..."
			m_sObjectID   = oXmlObject.getAttribute("oid")
			m_sObjectType = oXmlObject.tagName
			If Not IsNull(oXmlObject.getAttribute("new")) Then
				' �������� xml ������ ������ ������� - ������� ��� � ���, ���� ��� ��� ���
				m_oPool.AppendXmlObject oXmlObject
			Else
				' �������� �� ����� xml-������. ����� ������� ��� �������� ��� � oid �������������� �������
				' � � ������ ������� i:preload �� ����� ������
				Set oXmlObject = m_oPool.GetXmlObject( m_sObjectType, m_sObjectID, Empty)
			End If
		End If
		If oXmlObject Is Nothing Then
			With X_GetLastError
				If .IsObjectNotFoundException Then
					Init = "����������� ������ �� ������. �������� �� ��� ������"
				ElseIf .IsSecurityException Then
					Init = "������ � ������������ ������� ��������"
				End If
			End With
			MayBeInterrupted = True			
			Exit Function
		End If
		
		' ������� ������������� ������ � ����������
		m_oPool.EnlistXmlObjectIntoTransaction XmlObject
		
		' �������� ��������������� ����� ������ ����������� �� URL
		ReportStatus "������������� �������� ����������..."
		ApplyURLParams
		
		' � ����������� �� ������ ��������������
		ReportStatus "������������� ����������������� ����������..."

		' �������� ��������� ������� ���������
		Set m_oPages = CreateObject("Scripting.Dictionary")
		m_oPages.CompareMode = vbTextCompare
		Set oXmlPagesMD = InterfaceMD.selectNodes("i:page")
		j=1
		For Each oXmlPage In oXmlPagesMD
			If IsNull(oXmlPage.GetAttribute("n")) Then
				oXmlPage.SetAttribute "n", "PAGE_" & j
			End If
			j=j+1
			Set oEditorPage = New EditorPageClass
			oEditorPage.Init Me, oXmlPage
			m_oPages.Add oEditorPage.PageName, oEditorPage
		Next

		' �������� ������� Load, ����������� ���������� �����������
		nEditorStartPageIndex = 0
		If m_oEventEngine.IsHandlerExists("Load") Then
			With New EditorLoadEventArgsClass
				fireEvent "Load", .Self()
				nEditorStartPageIndex = .StartPageIndex
				If nEditorStartPageIndex >= m_oPages.Count Then
					Alert "���������� ���������� ������� Load ��������� ��������� ������������ �������� �������� StartPageIndex ���������� �������: " & nEditorStartPageIndex
					nEditorStartPageIndex = 0
				End If
				If Len("" & .ErrorDescription) > 0 Then
					Init = .ErrorDescription
					MayBeInterrupted = True			
					Exit Function
				End If
			End With
		End If

		m_oObjectContainerEventsImp.OnInitializeUI Me, Null
		
		If IsEditor Then
			' ������������� ���������
			setCaptionInternal ""
			If IsMultipageEditor Then
				' ����� ������� - �������������� ��������
				For Each oPage In m_oPages.Items
					m_oObjectContainerEventsImp.OnAddEditorPage Me, oPage, Null
				Next
				' ���� ������ ��������� �������� �� 0, �� ������� �������� ������ ��������
				If nEditorStartPageIndex > 0 Then
					m_oObjectContainerEventsImp.OnActivateEditorPage Me, nEditorStartPageIndex, Null
				End If
			End If

			' ��������� ��������� �������� ���������
			ShowEditorPage GetPageByIndex(nEditorStartPageIndex)
		Else
			If IsLinearWizard Then
				' ���, ������ ��������, ������� ������ ��������
				LinearWizardShowPage 1
			ElseIf m_oPages.Count > 0 Then
				' ���������� ������, � ������ 1-� �������� - ���������� ��
				NonlinearWizardShowPage GetPageByIndex(0)
			Else
				' ���������� ������ � ���������� 1-�� ��������� - ������� ������� ���������� �� ������������ �������� �� ����������� ����
				NonlinearWizardShowPage GetWizardNextPageInfo(0)
			End If
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.WizardGoToNextPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE WizardGoToNextPage>
	':����������:	���������� ������� �� ��������� �������� �������.
	':����������:	� �������� ���������� ������ �������� ��������� ���� ������,
	'				� ��� �� ���������� ������� HasNextPage (� ������ ������ 
	'				"����������� �������").<P/>
	'				��� ������������ ������� ������������ ������� ���������		
	'				BeforePageEnd, ValidatePage, PageEnd, BeforePageStart � PageStart.
	':��. �����:	ObjectEditorClass.WizardGoToPrevPage
	':���������:	Public Sub WizardGoToNextPage
	Public Sub WizardGoToNextPage
		Dim oPage		' As XEditorPageClass - �������� ��������� �������� �������
		
		If Not IsWizard Then Err.Raise -1, "ObjectEditorClass::WizardGoToNextPage", "Method supported only for Wizard"
		EnableControls False
		If GetData( REASON_WIZARD_NEXT_PAGE , False ) Then
			If IsLinearWizard Then
				' �������� ������
				' ���� ��������� �������� ����� ����� ������� "����� ���������", �� �� �������� �� ��� ������� ����� ����
				' ����������: CurrentPageNo - ����� ����, �� 1 ������ �������
				If GetPageByIndex(CurrentPageNo).BackMode = XEB_UNDOCHANGES Then
					m_oPool.BackUp
				End If
				LinearWizardShowPage CurrentPageNo + 1
			Else		
				' ���������� ������ - ������� �������� �������� �� ����������������� ����������� ������� GetNextPageInfo
				Set oPage = GetWizardNextPageInfo(CurrentPageNo)
				If oPage.BackMode = XEB_UNDOCHANGES Then
					m_oPool.BackUp
				End If
				NonlinearWizardShowPage oPage
			End If	
		Else
			' ���� � ��������� ������ �� ������� - �������� �� �������� - ������������ ��������
			EnableControls True
		End If
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.WizardGoToPrevPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE WizardGoToPrevPage>
	':����������:	������� �� ���������� �������� �������.
	':����������:	� �������� ���������� ������ �������� ��������� ���� ������.<P/>
	'				��� ������������ ������� ������������ ������� ���������		
	'				BeforePageEnd, ValidatePage, PageEnd, BeforePageStart � PageStart.
	':��. �����:	ObjectEditorClass.WizardGoToNextPage
	':���������:	Public Sub WizardGoToPrevPage
	Public Sub WizardGoToPrevPage
		If Not IsWizard Then Err.Raise -1, "ObjectEditorClass::WizardGoToPrevPage", "Method supported only for Wizard"
		EnableControls False
		If CurrentPage.BackMode = XEB_TRY_GET_DATA Then
			' ���� ������� ������ ��� �����
			If Not GetData( REASON_WIZARD_PREV_PAGE, False  ) Then
				' �� ������� �������. �.�. SilentMode �� ������ � False, �� � GetData ����� �������� ���������. 
				' ����� �� ������ ������������ �������� � ������
				EnableControls True
				Exit Sub
			End If
		ElseIf CurrentPage.BackMode = XEB_UNDOCHANGES Then
			' ������� ��������� ���� � ��, ����� �� ��� �� ������ �� ������� ��������
			m_oPool.Undo
		End If
		' ������� ���������� ��������
		If IsLinearWizard Then
			LinearWizardShowPage CurrentPageNo - 1
		Else
			' �� �������. ���� ����� ��� ���������� �������� �� �����
			With PageStack 
				' ���������� ������� �������� � �����
				.Pop
				' � ��������� �� ����������
				NonlinearWizardShowPage m_oPages.Item(.Pop)
			End With
		End If
	End Sub	


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CanSwitchPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CanSwitchPage>
	':����������:	���������� ������� "����������" ������������ ��������.
	':���������:	True, ���� � ��������� ����� ����������� ��������, False - �����.
	':����������:	���� ������� - ��� �������� ������������ � ������� ������, 
	'				��������� ������������� �� ������� ��������. � �������� ��������
	'				�������� ������������ ���� ������ � ���������� ������� 
	'				BeforePageEnd, ValidatePage, PageEnd.<P/>
	'				��������: � ������ ��������� ����� ������ ��� �������� �������� 
	'				�������� ���������������� (disabled).
	':���������:	Public Function CanSwitchPage [As Boolean]
	Public Function CanSwitchPage
		If Not IsEditor Then Err.Raise -1, "ObjectEditorClass::CanSwitchPage", "Method supported only for Editor"
		EnableControls False
		CanSwitchPage = GetData( REASON_PAGE_SWITCH, False)
		If Not CanSwitchPage Then
			' ���� �� ���������� ������� ������ - ������������ ��������
			EnableControls True
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SwitchToPageByPageID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SwitchToPageByPageID>
	':����������:	������� �� �������� � �������� ���������������.
	':���������:	sPageID - [in] ������������ ������� ��������
	':���������:	Public Sub SwitchToPageByPageID( sPageID [As String] )
	Public Sub SwitchToPageByPageID(sPageID)
		If Not IsEditor Then Err.Raise -1, "ObjectEditorClass::SwitchToPageByPageID", "Method supported only for Editor"
		If m_oPages.Exists(sPageID) Then
			ShowEditorPage m_oPages.item(sPageID)
		Else
			Err.Raise -1, "SwitchToPageByPageID", "����������� ��� ��������"
		End If
	End Sub


	'------------------------------------------------------------------------------
	':����������:	����������� �������� ���������
	':���������:	oEditorPage - [in] ������ �������� ���������, EditorPageClass
	Private Sub ShowEditorPage(oEditorPage)
		SetEditorButtons oEditorPage
		' ��������� HTML-�������
		MakeHTMLForm oEditorPage 
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.NonlinearWizardShowPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE NonlinearWizardShowPage>
	':����������:	����������� �������� ����������� �������.
	':���������:	oEditorPage - [in] ������ �������� �������, ��������� EditorPageClass
	':����������:	� �������� ���������� ������ �������� ���������� ������� HasNextPage.
	':���������:	Public Sub NonlinearWizardShowPage( oEditorPage [As EditorPageClass] )
	Public Sub NonlinearWizardShowPage(oEditorPage)
		Dim nStep		 ' ����� ����
		
		With PageStack
			' ������� ���������� �������� � ����
			.Push oEditorPage.PageName
			nStep = .Length
			m_nCurrentPageNo = nStep
			' ������������� ���������
			setCaptionInternal oEditorPage.PageTitle
			' ������� ������ ������ 
			'	-������ "�����" ����� ������ ��� ������� ���������� �������� � �����
			'	-������ "�����" �������� ������ ��� ������� ��������� ...
			With New HasNextPageEventArgsClass
				fireEvent "HasNextPage", .Self()
				SetWizardButtons nStep=1, Not (.ReturnValue = True), oEditorPage
			End With
			' � ���������� �
			MakeHTMLForm oEditorPage
		End With	
	End Sub


	'------------------------------------------------------------------------------
	':����������:	����������� �������� ��������� �������
	':���������:	nStep - [in] ������� ����� ����
	Private Sub LinearWizardShowPage( nStep )
		Dim oPage		' As XEditorPageClass

		m_nCurrentPageNo = nStep
		' ������ �� 0, � ���� �� 1, ������� "-1"
		Set oPage = GetPageByIndex(nStep - 1)
		' �������� ���������
		setCaptionInternal oPage.PageTitle
		' ������� ������ ������ 
		SetWizardButtons nStep = 1, nStep = m_oPages.Count, oPage
		' ������� ��������
		MakeHTMLForm oPage
	End Sub


	'------------------------------------------------------------------------------
	':����������:	���������� ��������������������� ��������� EditorPageClass ��� 
	'				�������� ����������� ������� c �������� �������.
	':���������:	nCurrentPageNo - [in] ����� ������� �������� (�� 1), ������������ 
	'				������� ���������� ��������� ��������
	':���������:	��������� EditorPageClass
	':����������:	�������� ���������� ������� GetNextPageInfo.
	Private Function GetWizardNextPageInfo(nCurrentPageNo)
		Dim oEditorPage			' As EditorPageClass
		Dim sPageName			' As String - ������������ ��������
		
		With New GetNextPageInfoEventArgsClass
			.PageTitle = "��� �" & (nCurrentPageNo+ 1)
			sPageName = "step" & (nCurrentPageNo + 1)
			fireEvent "GetNextPageInfo", .Self()
			If .PageBuilder Is Nothing Then
				Err.Raise -1, "WizardGoToNextPage", "������������ ���������� OnGetNextPageInfo: PageBuilder Is Nothing"
			End If
			If m_oPages.Exists(sPageName) Then
				If m_oPages.Item(sPageName ).PageBuilder.IsEqual(.PageBuilder) Then
					Set oEditorPage = m_oPages.Item(sPageName)
				Else
					m_oPages.Remove(sPageName)
				End If
			End If
			If IsEmpty(oEditorPage) Then
				Set oEditorPage = New EditorPageClass
				oEditorPage.CanBeCached = .CanBeCached
				' ����� ������� ��� �������� 
				oEditorPage.BackMode	= iif( hasValue(.BackMode), .BackMode, DefaultBackMode )
				oEditorPage.InitIndirect Me, .PageBuilder, sPageName, .PageTitle
				m_oPages.Add sPageName, oEditorPage
			End If
		End With
		Set GetWizardNextPageInfo = oEditorPage
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPageByIndex
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPageByIndex>
	':����������:	���������� ������ �������� (EditorPageClass) �� ��������� 
	'				������� ��������.
	':���������:	nIndex - [in] ������ ������� �������� (������ ���������� - �� 0)
	':���������:	������ �������� ���������, ��������� EditorPageClass.
	':���������:	
	'	Public Function GetPageByIndex( nIndex [As Int] ) [As EditorPageClass]
	Public Function GetPageByIndex(nIndex)
		Set GetPageByIndex = m_oPages.Items()(nIndex)
	End Function


	'------------------------------------------------------------------------------
	':����������:	��������� ������� ����������� �������� ��������.
	':���������:	oEditorPage - [in] ��������� ������������ ��������, EditorPageClass
	Private Sub MakeHTMLForm( oEditorPage )
		If Not IsNothing(m_oActivePage) Then
			m_oActivePage.Hide
		End If
		Set m_oActivePage = oEditorPage
		If m_oActivePage.NeedBuilding Or Not m_oActivePage.CanBeCached Then
			m_oActivePage.PrepareForRender
		End If
		m_oActivePage.Show
		XService.DoEvents
		' ���� ���� ���������������� ����������, �������� ���
		fireEvent "BeforePageStart", Nothing
		CreateAndInitializeHtmlForm false
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.RebuildCurrentPage
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE RebuildCurrentPage>
	':����������:	
	'	������������� HTML-������������� ������� �������� ���������.
	':����������:
	'	� ������� �� ������ ObjectEditorClass.CreateAndInitializeHtmlForm, ���� 
	'	����� ������������� ������������� ������� �������� ��������� ����������.
	':��. �����:
	'	ObjectEditorClass.CreateAndInitializeHtmlForm
	':���������:	
	'	Public Sub RebuildCurrentPage
	Public Sub RebuildCurrentPage
		' ����� ���� ��� �������...
		If IsInterrupted = True Then Exit Sub
		MayBeInterrupted = False
		ReportStatus "������������� ��������..."
		If IsInterrupted = True Then Exit Sub
		If Not CurrentPage.Build Then Exit Sub
		' ����� ���� ��� �������...
		If IsInterrupted = True Then Exit Sub
		' � ���������� ��������� � ������������� ���� ��������, ����������� ����� Xsl...
		X_WaitForTrue UniqueID & ".CreateAndInitializeHtmlFormStep2" , UniqueID & ".CurrentPage.IsReady"			
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateAndInitializeHtmlForm
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateAndInitializeHtmlForm>
	':����������:	
	'	��������� � �������������� HTML-������������� ������� �������� ���������.
	':���������:	
	'	bForceRefreshUI - [in] ����, ����������� �� �������������� ������������ 
	'		HTML-������������� ���� ������������ ���������� �������: True - ���
	'		������������� ���������������, False - ������������ ������������ 
	'		(���� ������� ����; � ���� ������ ����������� ������ ������������� 
	'		������ � ���������� �������)
	':����������:
	'	� ������� �� ������ ObjectEditorClass.RebuildCurrentPage, ���� ����� 
	'	��������� ������������� (��������) ��������� ���� (�) ������������� 
	'	��� �� ���� �� ������������� ��� (�) ��� �������� ������� ���������� 
	'	����������� �� ������������� (������� off-cache ������������ �������� 
	'	i:page, ��. x-net-interface-schema.xsd).
	':��. �����:
	'	ObjectEditorClass.RebuildCurrentPage
	':���������:
	'	Public Sub CreateAndInitializeHtmlForm( bForceRefreshUI [As Boolean] )
	Public Sub CreateAndInitializeHtmlForm(bForceRefreshUI)
		' ����� ���� ��� �������...
		If IsInterrupted = True Then Exit Sub
		MayBeInterrupted = False
		If CurrentPage.NeedBuilding Or Not CurrentPage.CanBeCached Then
			ReportStatus "������������� ��������..."
			If IsInterrupted = True Then Exit Sub
			' ��� ��� ����, ����� ����������� EnableControls True ������������� ������������ ��������
			m_bControlsEnabled = False
			If Not CurrentPage.Build Then Exit Sub
			' ����� ���� ��� �������...
			If IsInterrupted = True Then Exit Sub
			CurrentPage.NeedBuilding = False
			If IsInterrupted = True Then Exit Sub
			' � ���������� ��������� � ������������� ���� ��������, ����������� ����� Xsl...
			X_WaitForTrue UniqueID & ".CreateAndInitializeHtmlFormStep2" , UniqueID & ".CurrentPage.IsReady"			
		Else
			EnableControls False
			If bForceRefreshUI Then _
				CurrentPage.InitPropertyEditorsUI
			CreateAndInitializeHtmlFormStep3
		End If
	End Sub	


	'------------------------------------------------------------------------------
	':����������:	������ � �������������� HTML-����� (��� 2-�)
	':����������:	����� ��� ����������� ������������� � �� ������ ���������� ����.
	Public Sub CreateAndInitializeHtmlFormStep2
		' ����� ���� ��� �������...
		If IsInterrupted Then Exit Sub	
		ReportStatus ""
		CurrentPage.VisibilityTurnOn
		If IsInterrupted Then Exit Sub	
		CurrentPage.PostBuild
		If IsInterrupted Then Exit Sub
		CreateAndInitializeHtmlFormStep3
	End Sub


	'------------------------------------------------------------------------------
	':����������:	����������� ���������� �����
	':����������:	����� ��� ����������� ������������� � �� ������ ���������� ����.
	Public Sub CreateAndInitializeHtmlFormStep3
		If IsInterrupted Then Exit Sub
		' ��������� ����� ����������
		CurrentPage.SetData
		' ����� ���� ��� �������...
		If IsInterrupted Then Exit Sub
		' ��������� ����������� ��������
		EnableControls True
		' ����� ���� ��� �������...
		If IsInterrupted Then Exit Sub
		CurrentPage.SetDefaultFocus
		If IsInterrupted Then Exit Sub
		' ���� ���� ���������������� ����������, �������� ���
		fireEvent "PageStart", Nothing
		If IsInterrupted Then Exit Sub
		MayBeInterrupted = True 
	End Sub


	'------------------------------------------------------------------------------
	':����������:	������� ���������. ������������ ����������� ��������� � ������� 
	'				(x-editor-in-filter). �������� ������ ��� ��������� (�� �������) 
	'				������ (!) �������.
	':����������:	��������! 
	'				����� ��� ����������� ������������� � �� ������ ���������� ����!
	Public Sub Internal_RestartEditor()
		Dim sObjectID			' ������������� �������������� �������
		Dim sTypeName			' ��� �������������� �������
		Dim nIndex				' As Integer - ������ �������� � x-tab-strip.htc
		Dim oPage				' As EditorPage - ������� ������ ��������
		Dim i
		
		sObjectID = ObjectID
		sTypeName = XmlObject.tagName
		' ������� ��� ���������		
		Pool.Clear
		' �������� � ���� ����� ������ � ����������� ��� ������������� �� �������
		Pool.CreateXmlObjectInPool(sTypeName).setAttribute "oid", sObjectID
		fireEvent "Load", New EditorLoadEventArgsClass
		For nIndex = 0 To Pages.Count - 1
			Set oPage = GetPageByIndex(nIndex)
			If oPage.IsHidden Then
				If nIndex = Tabs.ActiveTab Then
					For i = 0 To Pages.Count - 1
						If Not Tabs.IsTabHidden(i) Then
							Tabs.ActiveTab = i
							Exit For
						End If
					Next
				End If
				Tabs.HideTab nIndex, True
			End If
		Next
		' ����: true - ������ �������� UI ���� ���������� �������
		CreateAndInitializeHtmlForm true
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetDefaultFocus
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetDefaultFocus>
	':����������:	������������� ����� ����� �� ������ ��������� ������� ������� 
	'				�������� ���������.
	':��. �����:	EditorPageClass.SetDefaultFocus
	':���������:	Public Sub SetDefaultFocus
	Public Sub SetDefaultFocus
		If IsInterrupted Then Exit Sub
		CurrentPage.SetDefaultFocus
	End Sub
	

	'------------------------------------------------------------------------------
	':����������:
	'	��������� ������ �� ����� � ����������� Xml-������ � �������� ����������
	'	���������� ���������� ������ ��������. �������� ������ ��� ����� �� ��������:
	'	������ / ����� � �������, ������������ �������� ���������, �� � ���������.
	'	���������� �������: BeforePageEnd, ValidatePage, PageEnd.
	':���������:
	'	nReason - [in] ��������, ������������ � ���������� ����������
	'	bSilentMode - [in] ������� "������" ����� �� ��������
	':���������:
	'	���������� �������:
	'	- True - �������� "��� ������" - �� �������� ����� �������;
	'	- False - "��� �����", ������� ������.
	Private Function GetData( nReason, ByVal bSilentMode )
		Dim oEditorStateChangedArgs		' As EditorStateChangedEventArgsClass
		
		MayBeInterrupted = False
		GetData = False
		' ���� ���� ����������(�) ������� "BeforePageEnd", ����������� ��� (����������� ������������ ���)
		Set oEditorStateChangedArgs = New EditorStateChangedEventArgsClass
		With oEditorStateChangedArgs
			.Reason = nReason
			fireEvent "BeforePageEnd", .Self()
			If .ReturnValue <> True Then
				If hasValue(.ErrorMessage) Then Alert .ErrorMessage
				MayBeInterrupted = True
				Exit Function
			End If
		End With
		With New GetDataArgsClass
			.Reason = nReason
			' �� ����� ����������� ��������� ��� �������� ���� ������� (��� ������ XEB_TRY_GET_DATA)
			bSilentMode = ( REASON_WIZARD_PREV_PAGE = nReason)	OR bSilentMode
			.SilentMode = bSilentMode
			CurrentPage.GetData( .Self )
			If .ReturnValue Then
				oEditorStateChangedArgs.SilentMode = bSilentMode
				oEditorStateChangedArgs.Reason = nReason
				With oEditorStateChangedArgs
					.ErrorMessage = vbNullString
					.ReturnValue = True
					fireEvent "ValidatePage", .Self()
					If .ReturnValue <> True And Not bSilentMode Then
						If HasValue(.ErrorMessage) Then
							Alert .ErrorMessage
						End If
					End If
				End With
			End If
			GetData = .ReturnValue And oEditorStateChangedArgs.ReturnValue
			If GetData <> True Then
				MayBeInterrupted = True
				Exit Function
			End If
		End With
		' ��� ������� �������� ����������� PageEnd (���� ���� �����������), ���� ���� � �������� ������ ������ ������
		With oEditorStateChangedArgs
			.ReturnValue = True
			.ErrorMessage = vbNullString
			.SilentMode = bSilentMode
			fireEvent "PageEnd", .Self()
			If .ReturnValue <> True And Not bSilentMode Then
				If hasValue(.ErrorMessage) Then Alert .ErrorMessage
				MayBeInterrupted = True
				GetData = False
				Exit Function
			End If
		End With
		MayBeInterrupted = True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.HtmlPageContainer
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE HtmlPageContainer>
	':����������:	���������� ������ �� DIV-������� (����������), � ������� 
	'				����������� HTML-������������� ���� ������� ���������.
	':��. �����:	ObjectEditorClass.GetHtmlID
	':���������:	Public Property Get HtmlPageContainer [As IHTMLDIVElement]
	Public Property Get HtmlPageContainer
		Set HtmlPageContainer = m_oObjectContainerEventsImp.OnGetPageDiv(Me, Null)
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CurrentPage
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE CurrentPage>
	':����������:	���������� ��������� EditorPageClass, ��������������� ������� 
	'				(��������) ��������.
	':��. �����:	ObjectEditorClass.Pages, EditorPageClass
	':���������:	Public Property Get CurrentPage [As EditorPageClass]
	Public Property Get CurrentPage
		Set CurrentPage = m_oActivePage
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Pages
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE Pages>
	':����������:	���������� ��������� �������� EditorPageClass, ��������������
	'				��������� ���������.
	':����������:	��������! ��������� ����� ���������������� ������ � ����������� 
	'				������� Load. ���� ����������� ����� ��������� �������, �� 
	'				��������� ������������� ��������� ����� ���������� �� �����������
	'				���������.<P/>
	'				������������������ ������� � ��������� (.Items()) ������������� 
	'				������������������ �������� ������� ��������� (i:editor[i:page])
	'				� ����������.
	':��. �����:	ObjectEditorClass.CurrentPage, EditorPageClass
	':���������:	Public Property Get Pages [As Scripting.Dictionary]
	Public Property Get Pages
		Set Pages = m_oPages
	End Property
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ApplyURLParams
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ApplyURLParams>
	':����������:	����������� ������� ������� ����������� �� URL.
	':���������:	Public Sub ApplyURLParams
	Public Sub ApplyURLParams
		Dim sPropName	' ������ ���� �� ��������
		Dim oVProp		' ��������
		Dim oMProp		' ��� ����������
		Dim sObjectID	' ������������� �������
		Dim sOT			' ��� �������
		Dim aIDS		' ������ ���������������
		Dim vValue		' �������� ���������
		Dim sVarType	' ��� ��������
		Dim oDefValue	' As IXMLDOMElement - ���� ds:def
		
		' �������� ������������������� �������� ��������������� ������� ����������� �� URL
		For Each sPropName In QueryString.Names
			If MID(sPropName,1,1) = "." Then
				' �������� �������� ���������� � "."
				sPropName = MID( sPropName , 2)

				Set oVProp =  XmlObject.selectSingleNode(sPropName)
				If oVProp Is Nothing Then
					Alert "�������� """ & sPropName & """ �� ���������� � ������� """ & XmlObject.tagName & """"
				Else
					Set oMProp = PropMD( oVProp)
					sVarType = oMProp.getAttribute("vt")
					Select Case sVarType
						Case "i2", "i4", "ui1", "r4", "r8", "fixed"
							If QueryString.GetValueEx("." & sPropName, vValue) Then
								' ���� �������� �������� ��������, �� 
								'	�������� �������� ��������� � ����� (� ����������� �� ���� ��������)
								' �����
								'	���� �������� ����� �������� �� ���������, �� ��������� ���, ����� - NULL
								If hasValue(vValue) Then
									On Error Resume Next
									Select Case sVarType
										Case "i2":  vValue = CLng(vValue)	' ��� ����� ��� ����� ������������ ��� long
										Case "i4":  vValue = CLng(vValue)
										Case "ui1": vValue = CByte(vValue)
										Case "r4":  vValue = CSng(vValue)
										Case "r8":  vValue = CDbl(vValue)
										Case "fixed": vValue = CCur(vValue)
									End Select
									oVProp.nodeTypedValue = vValue
									If Err Then
										On Error GoTo 0
										Err.Raise -1, "ApplyURLParams", "������ ��� ��������� �������� �������� " & sPropName & " �� URL-��������a: " & vValue
									End If
								Else
									Set oDefValue = oMProp.selectSingleNode("ds:def[@default-type='xml' or @default-type='both']")
									If Not oDefValue Is Nothing Then
										' ���� �������� �� ��������� (������������� ��� ��� ���������)
										oVProp.nodeTypedValue = oDefValue.text
									Else
										' ����������: oVProp.nodeTypedValue=null ������ ������, �.�. ������� ���������
										oVProp.text = ""
									End If
								End If
							End If
						Case "date", "dateTime", "time"
							' �������� � QueryString ����� ���� ���� � ������� VBScript, ���� � ������� xml
							vValue = QueryString.GetValue( "." & sPropName , Now )
							On Error Resume Next
							If IsDate(vValue) Then
								oVProp.nodeTypedValue = CDate(vValue)
							Else
								oVProp.text = vValue
								oVProp.dataType = oVProp.dataType
							End If
							If Err Then
								On Error GoTo 0
								Err.Raise -1, "ApplyURLParams", "������ ��� ��������� �������� �������� " & sPropName & " �� URL-��������a: " & QueryString.GetValue( "." & sPropName, "0")
							End If
							' ������� ������ ����� ��� date
							oVProp.text = oVProp.text ' ���. 69105
						Case "string", "text"
							oVProp.nodeTypedValue =  QueryString.GetValue( "." & sPropName , "")
						Case "object"
							If oMProp.getAttribute("cp") = "scalar" Then
								' ��������� ��������� ��������
								sObjectID = QueryString.GetValue( "." & sPropName, "")
								If Len(sObjectID) > 0 Then
									sOT = oMProp.getAttribute("ot")
									m_oPool.RemoveRelation Nothing, oVProp, oVProp.firstChild
									m_oPool.AddRelation Nothing, oVProp, X_CreateObjectStub(sOT, sObjectID)
								End If
							Else
								' ������� �������� ������� �������� �������� (if any)!
								m_oPool.RemoveAllRelations Nothing, oVProp
								' � ������ ������� ������
								aIDS = Split( QueryString.GetValue( "." & sPropName , ""), ";")
								sOT = oMProp.getAttribute("ot")
								For Each sObjectID In aIDS
									If Len(sObjectID) > 0 Then
										m_oPool.AddRelation Nothing, oVProp, X_CreateObjectStub(sOT, sObjectID)
									End If
								Next
							End If		
						Case Else
							oVProp.text = QueryString.GetValue( "." & sPropName , "")
					End Select
				End If
			End If
		Next
	End Sub


	'------------------------------------------------------------------------------
	':����������:	 ����������� ������ ������ ���������.
	Private Sub SetEditorButtons(oPage)
		With New SetEditorOperationsArgsClass
			Set .EditorPage = oPage
			m_oObjectContainerEventsImp.OnSetEditorOperations Me, .Self
		End With	
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetWizardButtons
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetWizardButtons>
	':����������:	���������� ������������ ��������� ������ �������.
	':���������:	
	'	bPrevious - [in] �������� (True) ����������� ������ "�����"
	'	bNext	- [in] �������� (True) ����������� ������ "�����"
	'	oPage	- [in] �������� ��������� (EditorPageClass), ������� ����� ���������� 
	':���������:
	'	Public Sub SetWizardButtons( 
	'		bIsFirstPage [As Boolean], 
	'		bIsLastPage [As Boolean], 
	'		oPage [As EditorPageClass]
	'	)
	Public Sub SetWizardButtons( bIsFirstPage, bIsLastPage, oPage )
		With New SetWizardOperationsArgsClass
			.bIsFirstPage = bIsFirstPage
			.bIsLastPage = bIsLastPage
			Set .EditorPage = oPage
			m_oObjectContainerEventsImp.OnSetWizardOperations Me, .Self
		End With
	End Sub


	'------------------------------------------------------------------------------
	':����������:	����� ������ ������� ��������.
	':���������:	sMsg - [in] ��������� ������
	Private Sub ReportStatus( sMsg)
		m_oObjectContainerEventsImp.OnSetStatusMessage Me, sMsg, Null
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnDeleteObjectConflict
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnDeleteObjectConflict>
	':����������:	
	'	����������� ���������� ������� ���� "DeleteObjectConflict", ������������ � 
	'	�������� �������� ������� � ����, ��� ���������� �� ���� �������� �� ������ 
	'	�������� � ����.
	':���������:
	'	oSender - [in] ������-�������� ������� (� ������ ������ - ��� ���������)
	'	oEventArgs - [in] ��������� �������, ��������� DeleteObjectConflictEventArgsClass
	':����������:
	'	����������� ���������� ������� ��������� ��������� ������� �� �������: 
	'	- ���� �� ��������� ������ ��������� ������, ��� ������� ������ �������� 
	'		������������ ��������� (������������), �� ���������� ������� ��������� 
	'		� ������������� ��������, � ��������� ������� ��������, ����������� ��
	'		���������. ������� �������� ��� ���� �����������.
	'	- ���� �� ��������� ������ ��������� ������, ��� ������� ������ �������� ����� 
	'		���� ��������, �� ���������� ������� ������ ������������� �������� ��������,
	'		� ��������� ������� ��������, ������� ��������� �� ���������. ���� 
	'		������������ ������������ ��������, �� ���������� ���������� �������� 
	'		�������� (��� ������ �� ��������� ������ ��� ���� ����� �������). ���� ��
	'		������������ ��������� �� ��������, �� �������� �����������.
	':��. �����:	
	'	XObjectPoolClass
	':���������:
	'	Public Sub OnDeleteObjectConflict( 
	'		oSender [As XObjectPoolClass], 
	'		oEventArgs [As DeleteObjectConflictEventArgsClass]
	'	)
	Public Sub OnDeleteObjectConflict(oSender, oEventArgs)
		Dim oXmlRefProp 	    ' As IXMLDOMElement - ����������� ��������
		Dim sMsg			    ' As String - ���������
		Dim nCount			    ' As Integer - ���������� ��������� ������
		Dim bShowMsg		    ' As Boolean - ������� ������ ��������� � �������� �� ������� ������
		Dim sCapacity		    ' ������� ��������
		Dim oPropMD				' As IXMLDOMElement - ���������� ��������
		Dim i
		
		With oEventArgs
			nCount = .NotNullReferences.Count
			If nCount > 0 Then
				If Not .SilentMode Then
					sMsg = "�������� ����������. �� ��������� ������ �����" & iif(nCount=1, "����", "����") & " ������" & iif(nCount>1, "�", "") & ":" & vbNewLine
					For i=0 To nCount-1
						Set oXmlRefProp = .NotNullReferences.GetAt(i).parentNode
						sMsg = sMsg & vbTab & m_oPool.GetObjectPresentation( oXmlRefProp.parentNode ) & vbNewLine
					Next
					MsgBox sMsg, vbOKOnly Or vbExclamation, "�������� �������"
				End If
				.ReturnValue = False
				Exit Sub
			End If
			nCount = .AllReferences.Count
			bShowMsg = False
			If nCount > 0 Then
				If Not .SilentMode Then
					Set .PropertiesToUpdate = New ObjectArrayListClass
					
					sMsg = "�� ��������� ������ �����" & iif(nCount=1, "����", "����") & " ������" & iif(nCount>1, "�", "") & ":" & vbNewLine
					For i=0 To nCount-1
						Set oXmlRefProp = .AllReferences.GetAt(i).parentNode
						' �������� ��������, �� �������� �������� ��������
						If Not m_oPool.IsSameProperties(.SourceXmlProperty, oXmlRefProp ) Then
							' �������� ��� �����
							Set oPropMD = X_GetPropertyMD(oXmlRefProp)
							sCapacity = oPropMD.getAttribute("cp") 
							' TOTHINK: ������ ������ ����� � �� ��� �������� �������� ?
							If sCapacity <> "link" And sCapacity <> "link-scalar" Then
								sMsg = sMsg & vbTab & m_oPool.GetObjectPresentation( oXmlRefProp.parentNode ) & ", �������� " & oPropMD.getAttribute("d") & vbNewLine
								bShowMsg = True
								' �������������, ��� �� ������ � ���� �� �������� ������ �� ��� ���� (�� ���� � �����, ������ �� ���������) - �������, ��� ��������� �� ���������� ������������
								.PropertiesToUpdate.Add oXmlRefProp
							End If
						End If
					Next
					If bShowMsg Then
						sMsg = sMsg & "������� ������ � ��� ������ �� ����?"
						If MsgBox( sMsg, vbYesNo Or vbDefaultButton2 Or vbQuestion, "�������� �������" ) = vbNo Then
							.ReturnValue = False
							Exit Sub
						End If
					End If
					.ReturnValue = True
				End If
			End If
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnGetObjectConflict
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnGetObjectConflict>
	':����������:	
	'	����������� ���������� ������� "GetObjectConflict", ������������� ����� 
	'	� ������ ��������� ������ �������, ��� ������������� � ����.
	':���������:
	'	oSender - [in] ������-�������� ������� (� ������ ������ - ��� ���������)
	'	oEventArgs - [in] ��������� �������, ��������� GetObjectConflictEventArgsClass
	':����������:
	'	����������� ���������� ������� ���������� ������ �������������, ��� 
	'	�����������, ��� ���������� (���������) ���� �������� ������ �������������,
	'	� ���������� �������� ���������� ������ ����� ����������� (� ������ � 
	'	���������� ������� - �������� ��������).
	':��. �����:	
	'	XObjectPoolClass
	':���������:
	'	Public Sub OnGetObjectConflict(
	'		oSender [As XObjectPoolClass], 
	'		oEventArgs [As GetObjectConflictEventArgsClass]
	'	)
	Public Sub OnGetObjectConflict(oSender, oEventArgs)
		Dim vRequestResult

		With oEventArgs
			If Not IsNull(.ObjectInPool.getAttribute("delete")) Then
				vRequestResult = MsgBox( _
					"������ ���������� ������� ���� �������� ������ �������������. " & vbCr & _
					"���������� ������� � ������� ���������� ������ (��) ��� �������� �������� (���)?" & vbCr & _
					"��������! ������ �������� �� ����������� �������������� ������ �� ��������� ������!", _
					vbQuestion + vbYesNo + vbDefaultButton2, "�������������" )
					
				If vbYes = vRequestResult Then
					' ��� ���� ������ "�������", �� ������ ts, ����� ������ ��������� �����, ���� ���� �� ��� ��� ��������
					.ObjectInPool.removeAttribute "ts"
				Else
					' ������� "�������� ��������" - ������ ������� delete
					.ObjectInPool.removeAttribute "delete"
				End If
			Else
				' 
				If Not .ObjectInPool.selectSingleNode("*[@dirty]") Is Nothing Then
					' ���������� ������ � ���� ����� ���������������� ��������
					vRequestResult = MsgBox( _
						"������������� ������ ���� �������� ������ �������������. " & vbCr & _
						"�������� ���� ��������� � ������������ ������, ���������� ������ " & vbCr & _
						"������������� (��), ��� �������� ���� ��������� (���)?" & _
						vbQuestion + vbYesNo + vbDefaultButton2, "�������������" )
						
					If vbYes = vRequestResult Then
						' ������� ������ � ���� �� ������ ��������� � �������
						.ObjectInPool.parentNode.replaceChild .ObjectFromServer, .ObjectInPool
					Else
						' ���� ������ "�������� ���������" - ������ ts
						.ObjectInPool.removeAttribute "ts"
					End If
				End If
			End If
		End With
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MarkObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE MarkObjectAsDeleted>
	':����������:	�������� �������� ������ ��� ���������.
	':���������:	
	'	sObjectType - [in] ��� ���������� �������
	'	sObjectID - [in] ������������� ���������� �������
	'	oXmlProperty - [in] �������� ��������, ������ � ������� �� ������������ 
	'			��������; ���� �� ������������, �������� � Nothing
	':���������:
	'	������� ��������� ���������� "��������" (��������� ��������� delete ��� 
	'	���� �������� � ����). ����� ���������� False � ������ ������ �������� 
	'	��� ��������� ������� <B>DeleteObjectConflict</B>.
	':����������:	
	'	��������� ������ ���������� ��������� delete="1". ��� �� ���������� ��� 
	'	������� � ����, ������� ��������� �� �������� �� ������� � ��������� 
	'	��������� (delete-cascade="1" � ��������������� ��������� ��������).<P/>
	'	���� �� ��������� ������� ���� ������������ ������ (�������� ���������� 
	'	��� notnull="1" � ��������, ���	������� � ���������� �� ������ maybenull="1"), 
	'	�� �������� �����������; ����� ���������� ������� <B>DeleteObjectConflict</B>.<P/>
	'	���� ������������ ������ ���, �� ��������� ��� ������ �� ��������� ������� 
	'	(� ������ ���������� ��������).</P>
	'	������ ������ ����������� ������� ���� ����� ������������ ���������� 
	'	���������� ������� �� ������� �������� ���������, ������ ������� ���� 
	'	��������� ��������� (�.�. ���, ��� ������������� ���������, �� �������
	'	���� ������� ������).
	':��. �����:
	'	ObjectEditorClass.MarkXmlObjectAsDeleted, ObjectEditorClass.OnDeleteObjectConflict,<P/>	
	'	XObjectPoolClass.MarkObjectAsDeleted,<P/>
	'	<LINK oe-2-3-3-2, �������� �������/>
	':���������:
	'	Public Function MarkObjectAsDeleted(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Boolean]
	Public Function MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty)
		Dim oPropertiesToUpdate	' As ObjectArrayListClass - ��������� �������, �� ������� ���������� �������� ������ - ������������ ��� ������������ ���������� ������������� ���� �������
		Dim aPropertyEditors    ' ������ ���������� �������
		Dim oXmlProp			' As IXMLDOMElement - xml-��������
		Dim j
		Dim i
		
		MarkObjectAsDeleted = m_oPool.MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty, False, oPropertiesToUpdate)
		
		If hasValue(oPropertiesToUpdate) Then
			' � ������ ���� �������� ��� ��������� ������� �� ������� ��������, ��������������� ��������� �� ��������� AllReferences
			For i=0 To oPropertiesToUpdate.Count-1
				Set oXmlProp = oPropertiesToUpdate.GetAt(i)
				aPropertyEditors = CurrentPage.GetPropertyEditors(oXmlProp)
				If IsArray(aPropertyEditors) Then
					For j=0 To UBound(aPropertyEditors)
						aPropertyEditors(j).SetData
					Next
				End If				            
			Next
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MarkXmlObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE MarkXmlObjectAsDeleted>
	':����������:	�������� �������� ������ ��� ���������.
	':���������:	
	'	oXmlObject - [in] XML-������ ��� �������� ���������� �������
	'	oXmlProperty - [in] �������� ��������, ������ � ������� �� ������������ 
	'					��������; ���� �� ������������, �������� � Nothing
	':���������:
	'	������� ��������� ���������� "��������" (��������� ��������� delete ��� 
	'	���� �������� � ����). ����� ���������� False � ������ ������ �������� 
	'	��� ��������� ������� <B>DeleteObjectConflict</B>.
	':����������:
	'	��. ��������� � ������ ObjectEditorClass.MarkObjectAsDeleted.
	':��. �����:	
	'	ObjectEditorClass.MarkObjectAsDeleted
	':���������:	
	'	Public Function MarkXmlObjectAsDeleted(
	'		oXmlObject [As IXMLDOMElement], 
	'		oXmlProperty [As IXMLDOMElement]
	'	) [As Boolean]
	Public Function MarkXmlObjectAsDeleted(oXmlObject, oXmlProperty) 
		MarkXmlObjectAsDeleted = MarkObjectAsDeleted(oXmlObject.tagName, oXmlObject.getAttribute("oid"), oXmlProperty)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OpenEditor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OpenEditor>
	':����������:	��������� ��������� ��������.
	':���������:	
	'	oXmlObject	- XML-������ ��� ��������������
	'	sObjectType	- ������������ ���� �������������� ������� 
	'	sObjectID	- ������������� �������������� �������
	'	sMetaName	- ���������������� ���������
	'	bCreate		- ���� �������� �������: True - ������ �������, False - ���������
	'	oParentXmlProperty - XML-��������, � ������� ��������� / ������������� ������
	'	bIsAggregation - ���� ��������� (�� "���������")
	'	bEnlistInCurrentTransaction - ������� ������ ����� ���������� ����������:
	'			- True - �������� �� ������ �������� � ��������� (����������) ����������,
	'				��� ��� �� ��������� ���������� ���;
	'			- False - �������� �������� ����� ���������� ����������
	'	sAuxiliaryUrlArguments - �������������� ���������, ������������ � ��������
	':���������:
	'	��������� ������� �� ����, ��� ��� ������ ������ ���������:
	'	- ���� �������� ��� ������ ������� "��" ("������"), �� ����� ���������� 
	'		������������� ������������������ (����������) �������;
	'	- � ��������� ������ ����� ���������� Empty.
	':����������:
	'	���� ���������, ���������� ���������� bIsAggregation, ���������� ��, 
	'	<I>���</I> ��� ������� ����� ����������, � ��� ������, ����� �������� 
	'	bEnlistInCurrentTransaction ����� � �������� False (����� ����� ���������� 
	'	�� ���������; �������� bIsAggregation � ���� ������ ������������):
	'	- True - ���������� ��������� � ����� ��������������� (TransactionID);
	'	- False - ���������� ��������� ��� ����� �������, � ��� �� ���������������.
	'	<B>��������: ������ �������� ��������� � ����� ��������������� �� ������ 
	'	������ �� ����������! ������� �������� bIsAggregation ������ ������
	'	���������� � �������� True!</B>
	':���������:
	'	Public Function OpenEditor(
	'		oXmlObject [As IXMLDOMElement], 
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		sMetaName [As String], 
	'		bCreate [As Boolean], 
	'		oParentXmlProperty [As IXMLDOMElement], 
	'		bIsAggregation [As Boolean], 
	'		bEnlistInCurrentTransaction [As Boolean], 
	'		sAuxiliaryUrlArguments [As String]
	'	) [As Variant]
	Public Function OpenEditor(oXmlObject, sObjectType, sObjectID, sMetaName, bCreate, oParentXmlProperty, bIsAggregation, bEnlistInCurrentTransaction, sAuxiliaryUrlArguments)
		Dim oObjectEditorDialog

		Set oObjectEditorDialog = New ObjectEditorDialogClass
		oObjectEditorDialog.QueryString.QueryString = sAuxiliaryUrlArguments
		oObjectEditorDialog.IsNewObject = bCreate
		oObjectEditorDialog.IsAggregation = bIsAggregation
		oObjectEditorDialog.EnlistInCurrentTransaction = bEnlistInCurrentTransaction
		oObjectEditorDialog.MetaName = sMetaName
		If IsObject(oXmlObject)=True Then
			Set oObjectEditorDialog.XmlObject = oXmlObject
		Else
		    oObjectEditorDialog.ObjectType = sObjectType
		    oObjectEditorDialog.ObjectID = sObjectID
		    Set oObjectEditorDialog.XmlObject = Pool.FindXmlObject(sObjectType, sObjectID)
		End If
		Set oObjectEditorDialog.ParentObjectEditor = Me
		oObjectEditorDialog.ParentObjectType = oParentXmlProperty.parentNode.tagName
		oObjectEditorDialog.ParentObjectID = oParentXmlProperty.parentNode.getAttribute("oid")
		oObjectEditorDialog.ParentPropertyName = oParentXmlProperty.tagName
		oObjectEditorDialog.SkipInitErrorAlerts = SkipInitErrorAlerts
		
		OpenEditor = ObjectEditorDialogClass_Show(oObjectEditorDialog)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.Save
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE Save>
	':����������:	���� ������ � ���������� ���� ���������������� ������ ����.
	':���������:	���������� ������� ��������� ���������� ����� � ���������� ������.
	':��. �����:	
	'	ObjectEditorClass.FetchXmlObject, <P/>
	'	<LINK stdOp_SaveObject, �������� SaveObject - ������ ������ ds-�������� />
	':���������:	Public Function Save [As Boolean]
	Public Function Save
		EnableControls False
		' ��������� ������� ������ :)
		If Not FetchXmlObject(False) Then
			' ���� ���� ������ �� ��������
			EnableControls True
			Exit Function
		End If
		' ��������� ��������� ������� ��� ��������
		Save = SaveCurrentPool()
		EnableControls True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.FetchXmlObject
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE FetchXmlObject>
	':����������:	���� ������ �� ������������� ���������� ������� � ���.
	':���������:
	'	bSilentMode - [in] ���� ���������� ����� ������ � "�����" ������; ���� �����
	'			� �������� True, �� ��������� �� ������� �� ������������, ������� 
	'			Validate �� ������������
	':���������:
	'	���������� ������� ��������� ���������� ����� ������. 
	':����������:
	'	� �������� ����� ������ ������������ ������� BeforePageEnd, ValidatePage, 
	'	PageEnd � Validate (��������� - ������ � ��� ������, ����� �������� 
	'	��������� bSilentMode ���� False).
	':���������:
	'	Public Function FetchXmlObject( bSilentMode [As Boolean] ) [As Boolean]
	Public Function FetchXmlObject(bSilentMode)
		On Error GoTo 0
		FetchXmlObject = False
		If False = GetData( REASON_OK, bSilentMode) Then
			Exit Function
		End If
		If Not bSilentMode Then
			' ���� ���� ���������������� ���������� ���������� ������
			With New EditorStateChangedEventArgsClass
				.Reason = REASON_OK
				fireEvent "Validate", .Self()
				If .ReturnValue <> True Then 
					If hasValue(.ErrorMessage) Then Alert .ErrorMessage
					Exit Function
				End If
			End With
		End If
		FetchXmlObject = True
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.CreateXmlDatagramRoot
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE CreateXmlDatagramRoot>
	':����������:	
	'	������� �������� ���� XML-��������� � �����������, ������������ ��������� 
	'	�������� ������ ������.
	':��. �����:	
	'	ObjectEditorClass.GetXmlDatagramForSave, ObjectEditorClass.SaveCommandName
	'	<LINK stdOp_SaveObject, �������� SaveObject - ������ ������ ds-�������� />
	':���������:	
	'	Public Function CreateXmlDatagramRoot [As IXMLDOMElement]
	Public Function CreateXmlDatagramRoot
		With XService.XmlGetDocument
			Set CreateXmlDatagramRoot = .appendChild( .createElement("x-datagram"))
		End With
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetXmlDatagramForSave
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetXmlDatagramForSave>
	':����������:	
	'	��������� � ���������� ����������, ������������ ��������� �������� 
	'	������ ������.
	':��. �����:	
	'	ObjectEditorClass.CreateXmlDatagramRoot, ObjectEditorClass.SaveCommandName
	'	<LINK stdOp_SaveObject, �������� SaveObject - ������ ������ ds-�������� />
	':���������:	
	'	Public Function GetXmlDatagramForSave [As IXMLDOMElement]
	Public Function GetXmlDatagramForSave
		Dim oBatchSave					' xml � ��������� ��� ���������� (���� XmlSaveData ��������)
		Dim oNode						' ��� �����
		
		Set oBatchSave = CreateXmlDatagramRoot()
		oBatchSave.setAttribute "transaction-id", TransactionID
		' ��������� � ����������� ����� �� ���� �� �������, �������:
		'	1) ��������������� � ������� ����������
		'	2) ��������� ��� ��������� (��������� delete) ��� �������� ������ (������� new), ���� ����������� (������� dirty � �������)
		' ����������: "����������" �������� � ��������� �������, �.�. ��������� ������� ����� ������������ ������ �� ���, 
		' � ������, "����������" ��������� �������� �������� �������� ������� �������������� ������ �� ������
		For Each oNode In m_oPool.GetChanges()
			oBatchSave.appendChild oNode.cloneNode(True)
		Next
		' ������������ �����. ��� ����� ������:
		' 1) ��� ���������� ( ��������� �� � ��������)
		' 2) ��� "������" �������� � ������� ��������
		' 3) ��� "������" ������(����� �� ���������� � defaultvalue) �������� ��� ����� ��������
		' 4) ��� ��������� dirty
		oBatchSave.SelectNodes("*/*/*/*|*[not(@new)]/*[not(@dirty)]|*[@new]/*[not(@dirty) and not(text()) and not(*)]|//@dirty").removeAll
		
		Set GetXmlDatagramForSave = oBatchSave
	End Function
	

	'------------------------------------------------------------------------------
	':����������:
	'	���������� �������, ��� ������������� � ����� ���������������� ������������.
	Private Function SaveCurrentPool
		const MAX_SAVE_ITERATION_COUNT	= 50	' ������������ ���������� �������� ����� ���������� (��� ������ �� ������������ �����)
		Dim oBatchSave					' xml � ��������� ��� ���������� (���� XmlSaveData ��������)
		Dim nErrNumber					' ��� ������
		Dim sErrSource					' �������� ������
		Dim sErrDescription				' �������� ������
		Dim nErrorAction				' ����������� � ������ ������ ��������(AFTERERROR_nnnn)
		Dim nIterCount					' ���������� �������� ����� ����������
		Dim bMultiSave
		Dim bComplete
		
		
		SaveCurrentPool = Empty
		With X_CreateControlsDisabler(Me)
			' TODO: fireEvent "AcceptChanges"
			
			' ���� ������� �������� ��������� �� ������� ����������, �� ������ ������
			' ������� IsAggregated, ���������� ��� ��� ������� �������� ��������, ������� � ���, ��� �� ������������� ��� ����� ������� ���������,
			' �.�. �� ������ ��������� ��������� � ��
			If IsAggregated Then
				' ���� �� ��������� ������� ����������� - �������� ��
				If m_bManageCurrentTransaction Then
					m_oPool.CommitTransaction
				End If
				SaveCurrentPool = ObjectID
				Exit Function
			End If	
			nIterCount = 0
			Do
				nErrNumber = 0
				' ������� ���������
				Set oBatchSave = GetXmlDatagramForSave()
				If Nothing Is oBatchSave.FirstChild  Then Exit Do ' ������ �� �������� ��� ��� ������ �� ����������...
				
				' �������� ����������
				bMultiSave = False
				If Not IsNull(InterfaceMD.GetAttribute("use-multipart-save")) Then
					If X_GetApproximateXmlSize( oBatchSave) > MAX_POST_SIZE Then
						bMultiSave = True
						Set oBatchSave = oBatchSave.ownerDocument
						' �������� ������
						bComplete = (0<>CLng( X_ShowModalDialogEx(XService.BaseURL & "x-save-object-multipart.aspx", Array(oBatchSave, Me, "ChunkUpload", "ChunkPurge"), "dialogWidth:400px;dialogHeight:280px;help:no;center:yes;status:no")))
						If False = bComplete Then
							' ���, ���� �������� �������������, ���������� ������� ����� ���������������� ��� ����� ��� �����������
							On Error Resume Next
							err.Raise -1, "", "�������� ���������� ���� �������� �������������!"
						Else
							Set oBatchSave = oBatchSave.documentElement
							' �������� � "�����������" XML-� ��� ��������� ������ ������
							On Error Resume Next
							XService.XMLTestErrorInfo oBatchSave
							If Err Then
								X_SetLastServerError XService.LastServerError, Err.number, Err.Source, Err.Description
							Else
								X_ClearLastServerError
							End If							
						end if						
					End If
				End If
				
				If False=bMultiSave Then
					On Error Resume Next
				    X_ExecuteCommand Internal_GetSaveRequest(oBatchSave)
				End If	
					
				nErrNumber = Err.number
				sErrSource = Err.Source
				sErrDescription = Err.Description
				On Error GoTo 0
				
				If 0 = nErrNumber Then Exit Do
				With New SaveObjectErrorEventArgsClass
					.ErrNumber		= nErrNumber
					.ErrSource		= sErrSource
					.ErrDescription	= sErrDescription
					.Action			= AFTERERROR_DISPLAYMSG
					fireEvent "SaveObjectError", .Self()
					nErrorAction	= .Action
				End With
				nIterCount = nIterCount + 1
				If nIterCount > MAX_SAVE_ITERATION_COUNT Then
					X_ErrReportEx "���������� �������� ����� ���������� ��������� ����������� ���������", "SaveCurrentPool"
					Exit Function
				End If
			Loop  While AFTERERROR_RETRY=nErrorAction
			
			If 0=nErrNumber Then
				' �� ���� ������ - ���������
				SaveCurrentPool = ObjectID
				' ���� �� ��������� ������� ����������� - �������� ��
				If m_bManageCurrentTransaction Then
					m_oPool.CommitTransaction
				End If
				fireEvent "Saved", Nothing
			ElseIf  AFTERERROR_DISPLAYMSG=nErrorAction Then
				' ���� ������ � � ��� ���� �������� (X_HandleError ������������ ��������� ������)
				If Not X_HandleError Then
					Alert "���������� ������ ��� ������ �������� ����������:" & vbCr & sErrDescription & vbCr & sErrSource
				End If
				Exit Function
			End If
		End With
	End Function


	'------------------------------------------------------------------------------
	':����������:	���������� ��������� �������� ������� ����������.
	':���������:	oBatchSave - [in] XML-���������� (IXMLDOMElement)
	':���������:	��������� ������� �� ���������� �������� ������
	' ����������:	���������� ������� PrepareSaveRequest.
	'				���������! ������ ��� ����������� �������������!
    Public Function Internal_GetSaveRequest(oBatchSave)
		If m_oEventEngine.IsHandlerExists("PrepareSaveRequest") Then 
			With New PrepareSaveRequestEventArgsClass
				.CommandName = m_sSaveCommandName
				.Context = Metaname
				Set .XmlBatch = oBatchSave
				fireEvent "PrepareSaveRequest", .Self()
				Set Internal_GetSaveRequest = .Request
			End With
		Else
			With New XSaveObjectRequest
				Set .m_oXmlSaveData = oBatchSave
				.m_sName = m_sSaveCommandName
				.m_sContext = Metaname
				Set .m_oRootObjectId = internal_New_XObjectIdentity(ObjectType, ObjectID)
				Set Internal_GetSaveRequest = .Self
			End With
		End If
    End Function
	

	'------------------------------------------------------------------------------
	':����������:	���������� �����������, �� ������ ��������������.
	'				��� ����������� �������������! 
	Public Sub OnCancel
		' ���� �� ��������� ������� ����������� - �������� ��
		If m_bManageCurrentTransaction Then
			m_oPool.RollbackTransaction
		End If
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnClose
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnClose>
	':����������:	�����, ���������� "�����������" ��������� ��� �������� ���� 
	'				(�������) "����������".
	':����������:	����� ���������� ������� UnLoad.
	':��. �����:	IObjectContainerEventsClass
	':���������:	Public Sub OnClose
	Public Sub OnClose
		IsInterrupted = True
		With New EditorStateChangedEventArgsClass
			.Reason = REASON_CLOSE
			fireEvent "UnLoad", .Self()
		End With
		m_oPool.UnRegisterEditor
		Dispose
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnClosing
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnClosing>
	':����������:	�����, ���������� "�����������" ��������� ��� ������ �������� ���� 
	'				(�������) "����������". ��������� ����������������� �������� ���������.
	':���������:	bOkPressed - [in] ������� ����, ��� �������� ��������� ������� �������� ��/������
	':����������:	����� ���������� ������� UnLoading.
	':��. �����:	IObjectContainerEventsClass
	':���������:	Public Function OnClosing As String
	Public Function OnClosing(bOkPressed)
		If m_oEventEngine.IsHandlerExists("UnLoading") Then 
			With New EditorStateChangedEventArgsClass
				.ReturnValue = Empty
				If bOkPressed Then
					.Reason = REASON_OK
				Else
					.Reason = REASON_CLOSE
				End If
				fireEvent "UnLoading", .Self()
				OnClosing = .ReturnValue
			End With
		End If
	End Function
	
	
	'------------------------------------------------------------------------------
	':����������:	��������� IDisposable: ������������ ������.
	'				��� ����������� �������������! 
	Public Sub Dispose
		Dim oPage		' As EditorPageClass
		m_oEventEngine.Dispose
		Set m_oEventEngine = Nothing
		Set m_oPool = Nothing
		Set m_oEventEngine = Nothing
		For Each oPage In m_oPages.Items
			oPage.Dispose
		Next
		Set m_oPages = Nothing
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsControlsEnabled
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsControlsEnabled>
	':����������:	
	'	���������� ������� ���������� ��������� UI ���������: True - �������� 
	'	���������� �������� ��� �����, False - �������� ���������� �������������.
	':����������:	
	'	��������! ������ �������� ������������ ������������� ����������� c��������!<P/>
	'	�������� �������� ������ ��� ������. ��� ���������� ����������� ���������
	'	���������� ��������� ������������ ����� EnableControls.
	':��. �����:
	'	ObjectEditorClass.EnableControls
	':���������:
	'	Public Property Get IsControlsEnabled [As Boolean]
	Public Property Get IsControlsEnabled
		IsControlsEnabled = (True=m_bControlsEnabled)
	End Property
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.EnableControls
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE EnableControls>
	':����������:	����� ������� ���������� ���� ��������� ���������� ���������.
	':���������:	bEnable - [in] ������� ����������� ���������:
	'					- True - ������� �������� ���������� ���������� ��� �����;
	'					- False - ������������� �������� ����������
	':����������:	��������: ����� �������� ���������� ����������, ������� �����
	'				IObjectContainerEventsClass.OnEnableControls.
	':��. �����:	ObjectEditorClass.IsControlsEnabled, IObjectContainerEventsClass
	':���������:	Public Sub EnableControls( ByVal bEnable [As Boolean] )
	Public Sub EnableControls( ByVal bEnable )
		EnableControlsInternal bEnable, True
	End Sub
	

	'------------------------------------------------------------------------------
	':����������:	���������/��������� �������� ����������. 
	':���������:
	'	[in] bEnable	- ������� ����������� ���������
	'	[in] bBubbleUp	- True - �������� ���������� ����������, ����� - ���.
	':����������:
	'	��������! ��� ����������� �������������!
	'	������������ ��� ������ �� ����������� ���������. ���� �������� bBubbleUp
	'	����� � False, �� ����� �� �������� ���������� ����������
	Public Sub EnableControlsInternal(bEnable, bBubbleUp)
		bEnable = (True=bEnable)
		' �������������� ���������� ������...
		If bEnable = IsControlsEnabled Then Exit Sub
		m_bControlsEnabled = bEnable
		CurrentPage.SetEnable bEnable		
		If bBubbleUp Then
			m_oObjectContainerEventsImp.OnEnableControls Me, bEnable, Null
		End If
	End Sub
	

	'------------------------------------------------------------------------------
	':����������:	��������� ��������� ���������. ��� ����������� �������������!
	':���������:
	' 	sEditorCaption	- [in] ������ ���������
	'	sPageCaption	- [in] (���)��������� ��������
	Private Sub setCaptionInternal(ByVal sPageCaption)
		Dim sEditorCaption
		sEditorCaption = InterfaceMD.getAttribute("t")
		If m_oEventEngine.IsHandlerExists("SetCaption") Then 
			With New SetCaptionEventArgsClass
				.EditorCaption = sEditorCaption
				.PageTitle = sPageCaption
				fireEvent "SetCaption", .Self()
				sEditorCaption = .EditorCaption
				sPageCaption = .PageTitle
			End With
		Else
			If Len(sPageCaption) > 0 Then
				sEditorCaption = sEditorCaption & " - " & sPageCaption
			End If
		End If
		SetCaption sEditorCaption, sPageCaption
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.SetCaption
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE SetCaption>
	':����������:	��������� ��������� ���������.
	':���������:
	'	sEditorCaption - [in] ������ � ������� ������ ��������� ���������
	'	sPageCaption - [in] ������ � ������� (���)��������� �������� ���������
	':����������:
	'	��������: ����� �������� ���������� "����������", ������� �����
	'	IObjectContainerEventsClass.OnSetCaption.
	':��. �����:	
	'	IObjectContainerEventsClass
	':���������:	
	'	Public Sub SetCaption(
	'		ByVal sEditorCaption [As String], 
	'		ByVal sPageCaption [As String]
	'	)
	Public Sub SetCaption(ByVal sEditorCaption, ByVal  sPageCaption)
		m_oObjectContainerEventsImp.OnSetCaption Me, sEditorCaption, sPageCaption
	End Sub
	

	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.PropMD
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE PropMD>
	':����������:	
	'	���������� ������ ������������ ��������� �������� �������.
	':���������:	
	'	vProp - [in] �������� �������� �������, ���������� �������� ���������; 
	'			����� ����� ���� ������:
	'			- ������ � ������������� ��������;
	'			- XML-������ ��������, ��� ��������� IXMLDOMElement
	':���������:	
	'	XML � ������������� �������� ������� (������� ds:prop, ����������� 
	'	���������������� �������� ds:type, ��. x-net-data-schema.xsd), ��� 
	'	��������� IXMLDOMElement.
	':���������:
	'	Public Function PropMD( vProp [As Variant] ) [As IXMLDOMElement]
	Public Function PropMD( vProp )
		If vbString = vartype( vProp ) Then
			Set PropMD = X_GetTypeMD( ObjectType ).selectSingleNode( "ds:prop[@n='" & vProp & "']" )
		ElseIf 0=StrComp( TypeName(vProp), "IXMLDOMElement", vbTextCompare ) Then
			' �������� xml-��������
			Set PropMD = X_GetTypeMD( vProp.parentNode.nodeName).selectSingleNode( "ds:prop[@n='" & vProp.nodeName & "']" )
		Else
			Err.Raise -1, "ObjectEditor::PropMD", "�������� vProp ����������������� ����: " & TypeName(vProp) & " (�� String � �� IXMLDOMElement)"
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetPropByHtmlID
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetPropByHtmlID>
	':����������:	
	'	���������� XML-������ �������� ������� �� ����������� �������������� 
	'	HTML-�������� ��������� ��������.
	':���������:
	'	sHtmlID - [in] ���������� ������������� HTML-�������� ��������� ��������
	':���������:
	'	������ �������� �������, ��� ��������� IXMLDOMElement.<P/>
	'	���� �������������, �������� ���������� sHtmlID, ����� ������������ ������,
	'	��� ���� �������� / ������, ��������������� ��������� ��������������, �� 
	'	������������ � ���� ���������, ����� ���������� Nothing.
	':��. �����:
	'	ObjectEditorClass.GetHtmlID, ObjectEditorClass.SplitHtmlID, 
	'	ObjectEditorClass.GetProp
	':���������:
	'	Public Function GetPropByHtmlID( ByRef sHtmlID [As String] ) [As IXMLDOMElement]
	Public Function GetPropByHtmlID( ByRef sHtmlID )
		Dim sObjectType, sObjectID, sPropertyName
		If SplitHtmlID(sHtmlID, sObjectType, sObjectID, sPropertyName) Then   
			Set GetPropByHtmlID = GetXmlObjectFromPool(sObjectType, sObjectID, Null).selectSingleNode(sPropertyName)
		Else
			Set GetPropByHtmlID = Nothing
		End If
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetProp
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetProp>
	':����������:	
	'	���������� �������� �������������� (������������) ������� �� ��� ������������.
	':���������:
	'	sName - [in] ������������ ��������
	':���������:
	'	������ �������� �������, ��� ��������� IXMLDOMElement.
	':��. �����:
	'	ObjectEditorClass.GetPropByHtmlID
	':���������:
	'	Public Function GetProp( sName [As String] ) [As IXMLDOMElement]
	Public Function GetProp(sName)
		Set GetProp = XmlObject.selectSingleNode(sName)
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsIncluded
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsIncluded>
	':����������:	
	'	������� ���������� ���������: True - ������� �������� �������� ���������,
	'	False - �������� �������� "��������".
	':���������:
	'	Public Property Get IsIncluded [As Boolean]
	Public Property Get IsIncluded
		IsIncluded = m_bIncluded
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsMultipageEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsMultipageEditor>
	':����������:	
	'	������� ���������������� ���������: True - ������������� ��������� ��������
	'	��������� (����� �����) �������; False - �������� ������ ���� ���������.
	':���������:
	'	Public Property Get IsMultipageEditor [As Boolean]
	Public Property Get IsMultipageEditor
		IsMultipageEditor = IsEditor And m_oPages.Count>1
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsLinearWizard
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsLinearWizard>
	':����������:	���������� ������� ������ "���������" �������.
	':��. �����:	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard
	':���������:	Public Property Get IsLinearWizard [As Boolean]
	Public Property Get IsLinearWizard
		IsLinearWizard = False
		If Not IsWizard Then Exit Property
		If m_oEventEngine.IsHandlerExists("GetNextPageInfo") Then Exit Property
		IsLinearWizard = True
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsObjectCreationMode
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsObjectCreationMode>
	':����������:	
	'	���������� ������� ������ �������� �������� ������ �������: True - � 
	'	��������� �������� ������ ������ �������; False - � ��������� �������������
	'	������ ������������� (�� ������ ������ ���������) �������.
	':��. �����:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard,
	'	ObjectEditorClass.IsLinearWizard
	':���������:
	'	Public Property Get IsObjectCreationMode [As Boolean]
	Public Property Get IsObjectCreationMode
		IsObjectCreationMode = m_bCreateNewObject
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsEditor>
	':����������:	
	'	���������� ������� ������ "���������" (������� wizard-mode ��� �������� 
	'	i:editor �������� ��������� �� �����, ��. x-net-interface-schema.xsd).
	':��. �����:
	'	ObjectEditorClass.IsWizard, ObjectEditorClass.IsObjectCreationMode
	':���������:
	'	Public Property Get IsEditor [As Boolean]
	Public Property Get IsEditor
		IsEditor = m_bIsTabbed
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsWizard
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsWizard>
	':����������:	
	'	���������� ������� ������ "�������" (��� �������� i:editor �������� ���������
	'	����� ������� wizard-mode, ��. x-net-interface-schema.xsd).
	':��. �����:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsObjectCreationMode,
	'	ObjectEditorClass.IsLinearWizard
	':���������:
	'	Public Property Get IsWizard [As Boolean]
	Public Property Get IsWizard
		IsWizard = Not m_bIsTabbed
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.IsAggregated
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE IsAggregated>
	':����������:	
	'	����������, ��� ������� �������� ���� ��������� ��������, ��������� �� 
	'	������� ������ �������.
	':��. �����:
	'	ObjectEditorClass.IsEditor, ObjectEditorClass.IsWizard, 
	'	ObjectEditorClass.IsObjectCreationMode
	':���������:
	'	Public Property Get IsAggregated [As Boolean]
	Public Property Get IsAggregated
		IsAggregated = m_bAggregation
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectType>
	':����������:	���������� ������������ ���� �������������� (������������) �������.
	':��. �����:	ObjectEditorClass.ObjectID, ObjectEditorClass.MetaName
	':���������:	Public Property Get ObjectType [As String]
	Public Property Get ObjectType
		ObjectType = m_sObjectType
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ObjectID>
	':����������:	���������� ������������� �������������� �������.
	':��. �����:	ObjectEditorClass.ObjectType, ObjectEditorClass.MetaName
	':���������:	Public Property Get ObjectID [As String]
	Public Property Get ObjectID
		ObjectID = m_sObjectID
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.MetaName
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE MetaName>
	':����������:	���������� ������������ �������� ��������� � ����������.
	':��. �����:	ObjectEditorClass.ObjectID, ObjectEditorClass.ObjectType,
	'				ObjectEditorClass.InterfaceMD
	':���������:	Public Property Get MetaName [As String]
	Public Property Get MetaName
		MetaName = m_sMetaName
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.InterfaceMD
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE InterfaceMD>
	':����������:	���������� XML � ������������� ���������.
	':��. �����:	ObjectEditorClass.MetaName
	':���������:	Public Property Get InterfaceMD [As IXMLDOMElement]
	Public Property Get InterfaceMD
		Set InterfaceMD = m_oInterfaceMD
	End Property


	'------------------------------------------------------------------------------
	':����������:	���������� ���� ������� �������. ��� ����������� �������������!
	Private Property Get PageStack
		If IsEmpty(m_oPageStack) Then
			Set m_oPageStack = new StackClass
		End If
		Set PageStack = m_oPageStack
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE QueryString>
	':����������:	���������� ��������� QueryStringClass, ����������� ��������� 
	'				������� �������� ��������� / �������.
	':��. �����:	QueryStringClass
	':���������:	Public Property Get QueryString [As QueryStringClass]
	Public Property Get QueryString
		Set QueryString = m_oQueryString
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE XmlObject>
	':����������:	���������� XML-������ �������������� �������.
	':����������:	��������! ���������������� ��������� XML-������ ������� 
	'				<B>������ �� �������������</B>! ����������� ��������������� 
	'				������ ������� ��������� (ObjectEditorClass) � ���� ������
	'				�������� (XObjectPoolClass).
	':��. �����:	ObjectEditorClass.ObjectType, ObjectEditorClass.ObjectID, <P/>
	'				XObjectPoolClass
	':���������:	Public Property Get XmlObject [As IXMLDOMElement]
	Public Property Get XmlObject
		Set XmlObject = m_oPool.GetXmlObject(ObjectType, ObjectID, Null)  
	End Property


	'@@ObjectEditorClass.SkipInitErrorAlerts
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE SkipInitErrorAlerts>
	':����������:	��������� ��������� � ���� ��� ����������� � ���, 
	'				��� � ������ ������������� ���������� �������� UI ��������� ��� �������� �������, 
	'				�� ������� �������� ������� �������������� ������������.
	':���������:	Public Property Get SkipInitErrorAlerts [As Boolean]
	Public Property Get SkipInitErrorAlerts
		SkipInitErrorAlerts = m_bSkipInitErrorAlerts
	End Property
	
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ParentXmlProperty
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ParentXmlProperty>
	':����������:	���������� XML-������ "�������������" �������� - ���������� 
	'				��������, ������ �������� ����������� � ������� ���������.
	'				��� "���������" ��������� �������� �������� ���� Nothing.
	':����������:	��������! ���������������� ��������� ������ ��������
	'				<B>������ �����������</B>! 
	':��. �����:	ObjectEditorClass.IsIncluded, ObjectEditorClass.IsAggregated, 
	'				ObjectEditorClass.XmlObject
	':���������:	Public Property Get ParentXmlProperty [As IXMLDOMElement]
	Public Property Get ParentXmlProperty
		Set ParentXmlProperty = Nothing
		If Not IsIncluded Then Exit Property
		If Len("" & m_sParentObjectType) > 0 And Len("" & m_sParentObjectID) > 0 Then
			Set ParentXmlProperty = GetXmlObjectFromPool(m_sParentObjectType, m_sParentObjectID, Null).SelectSingleNode(m_sParentPropertyName)
		End If
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ParentObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_ObjectEditorClass><TITLE ParentObjectEditor>
	':����������:	���������� ������ �� ������������ ���������, �� �������� ��� ������� ������� 
	'				��� Nothing ��� ���������
	':���������:	Public Property Get ParentObjectEditor [As ObjectEditorClass]
	Public Property Get ParentObjectEditor
		Set ParentObjectEditor = m_oParentObjectEditor
	End Property
		
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetRootEditor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetRootEditor>
	':����������:	���������� ��������� ��������� ��������� � ������� ����������
	':���������:	��������� ObjectEditorClass, ��� ��������� ��������� ����� ������ ��������� �������� �������
	':���������:
	'	Public Function GetRootEditor() [As ObjectEditorClass]
	Public Function GetRootEditor()
		Dim oEditor		' As ObjectEditorClass
		Set oEditor = Me
		While Not oEditor.ParentObjectEditor Is Nothing
			Set oEditor = oEditor.ParentObjectEditor
		Wend
		Set GetRootEditor = oEditor
	End Function
	
	'------------------------------------------------------------------------------
	':����������:	������� ���������� �������/��������� � ���� ����������� 
	'				������������� ��������. ��� ����������� �������������!
	Public Property Get MayBeInterrupted
		MayBeInterrupted = CBool(m_bMayBeInterrupted)
	End Property  
	Private Property Let MayBeInterrupted(bTrue)
		m_bMayBeInterrupted =  bTrue
	End Property  


	'------------------------------------------------------------------------------
	':����������:	������� ���������� ������ ���������.
	'				��� ����������� �������������!
	Public Property Get IsInterrupted
		IsInterrupted = (true=m_bIsInterrupted)
	End Property
	Public Property Let IsInterrupted(bIsInterrupted)
		m_bIsInterrupted = (true=bIsInterrupted)
	End Property


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetUniqueNameFor
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetUniqueNameFor>
	':����������:	���������� ���������� ������������ ��� ��������.
	':���������:	oProperty - [in] XML-������ ��������, ��� ��������� IXMLDOMElement
	':���������:	������ � ���������� �������������.
	':����������:	������������ ��� ��������� ���������� ��������������� ����������
	'				������� - ������������ ������������ ��������������� ���� � ������
	'				������������� ����������� ������ � ���� �� �������� �� �������� 
	'				���������.
	':���������:
	'	Public Function GetUniqueNameFor( oProperty [As IXMLDOMElement] ) [As String]
	Public Function GetUniqueNameFor(oProperty)
		Const MAX_NAME_LEN = 20
		Const NAME_PREFIX = "un_"
		Dim sRawName
		Dim sName
		Dim i

		sRawName = Mid(oProperty.nodeName, 1, MAX_NAME_LEN)
		sName = NAME_PREFIX & sRawName
		i=0
		While m_oNamesDictionary.Exists(sName)
			sName = NAME_PREFIX & sRawName & "_" & i
			i=i+1
		Wend
		m_oNamesDictionary.Add sName, True
		GetUniqueNameFor = sName
	End Function


	'------------------------------------------------------------------------------
	' ������������� �������� ������������ ��������
	'	[in] oXmlProperty As IXMLDOMElement - xml-�������� ������� � ����
	'	[in] vValue As Variant - �������� ��������
	Function SetPropertyValue(oXmlProperty, vValue)
		SetPropertyValue = Pool.SetPropertyValue( oXmlProperty, vValue )
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.ShowDebugMenu
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE ShowDebugMenu>
	':����������:	����������� ������������ ����������� ���� ���������.
	':���������: 	Public Sub ShowDebugMenu
	Public Sub ShowDebugMenu
		If IsEmpty(m_oPopUpForDebugMenu) Then
			Set m_oPopUpForDebugMenu = XService.CreateObject("CROC.XPopUpMenu")
		End If
		m_oPopUpForDebugMenu.Clear
		m_oPopUpForDebugMenu.Add "���������� " & Iif(IsEditor,"���������", "�������") & " '" & MetaName & "'" , "X_DebugShowXml InterfaceMD"
		m_oPopUpForDebugMenu.Add "���������� ���� '" & ObjectType & "'", "X_DebugShowXml X_GetTypeMD(ObjectType)"
		m_oPopUpForDebugMenu.Add "������� ������", "X_DebugShowXml XmlObject"
		m_oPopUpForDebugMenu.Add "������� ��� ��������", "X_DebugShowXml XmlObjectPool"
		m_oPopUpForDebugMenu.Add "����������� ���������� ��� ����������", "X_DebugShowXml GetXmlDatagramForSave()"
		m_oPopUpForDebugMenu.Add "Html-������ �����������", "X_DebugShowHtml HtmlPageContainer"
		m_oPopUpForDebugMenu.Add "Html-������ ����� ���������", "X_DebugShowHtml document.body.parentNode.outerHTML"
		m_oPopUpForDebugMenu.Add "������ ����������", "alert QueryString.QueryString"
		Execute m_oPopUpForDebugMenu.Show & " ' ��������� ����������� �� ������ ������� ������"
	End Sub


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.GetWindow
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE GetWindow>
	':����������:	���������� ������ HTML-���� (IHTMLWindow2), � ������� ������ ��������.
	':���������:	Public Function GetWindow [As IHTMLWindow2]
	Public Function GetWindow
		Set GetWindow = window
	End Function


	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnKeyUp>
	':����������:	
	'	���������� ������� ���������� ������.
	':���������:
	'	oSender - [in] ������, ��������������� �������
	'	oEventArgs - [in] ��������� �������, ��������� AccelerationEventArgsClass
	':����������:	
	'	����� ���������� ������� Accel, ��������� � ���������� ������� �������� 
	'	���������, �������������� ���������� oEventArgs. ���� ���������� �� 
	'	������������ ������� (�������� AccelerationEventArgsClass.Processed ��������
	'	������������� � �������� False), ����� �������� ���������� � "���������",
	'	������� ����� IObjectContainerEventsClass.OnKeyUp.
	':��. �����:	
	'	IObjectContainerEventsClass
	':���������:	
	'	Public Sub OnKeyUp( 
	'		oSender [As Object], 
	'		oEventArgs [As AccelerationEventArgsClass] )
	Public Sub OnKeyUp(oSender, oEventArgs)
		fireEvent "Accel", oEventArgs
		If Not oEventArgs.Processed Then
			' ' ���� ������� ���������� �� ���������� - ��������� �� � ���������
			m_oObjectContainerEventsImp.OnKeyUp Me, oEventArgs
		End If
	End Sub
	
	'------------------------------------------------------------------------------
	'@@ObjectEditorClass.OnKeyDown
	'<GROUP !!MEMBERTYPE_Methods_ObjectEditorClass><TITLE OnKeyDown>
	':����������:	
	'	���������� ������� ���������� ������.
	':���������:
	'	oSender - [in] ������, ��������������� �������
	'	oEventArgs - [in] ��������� �������, ��������� AccelerationEventArgsClass
	':����������:	
	'	����� �������� ���������� � "���������",
	'	������� ����� IObjectContainerEventsClass.OnKeyDown.
	':��. �����:	
	'	IObjectContainerEventsClass
	':���������:	
	'	Public Sub OnKeyDown( 
	'		oSender [As Object], 
	'		oEventArgs [As AccelerationEventArgsClass] )
	Public Sub OnKeyDown(oSender, oEventArgs)
		m_oObjectContainerEventsImp.OnKeyDown Me, oEventArgs
	End Sub
	
End Class


'===============================================================================
'@@SetCaptionEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE SetCaptionEventArgsClass>
':����������:	��������� ������� "SetCaption".
'
'@@!!MEMBERTYPE_Methods_SetCaptionEventArgsClass
'<GROUP SetCaptionEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_SetCaptionEventArgsClass
'<GROUP SetCaptionEventArgsClass><TITLE ��������>
Class SetCaptionEventArgsClass
	'@@SetCaptionEventArgsClass.PageTitle
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE PageTitle>
	':����������:	��������� �������� / ���� �������.
	':���������:	Public PageTitle [As String]
	Public PageTitle
	
	'@@SetCaptionEventArgsClass.EditorCaption
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE EditorCaption>
	':����������:	������ ��������� ��������� / �������.
	':���������:	Public EditorCaption [As String]
	Public EditorCaption
	
	'@@SetCaptionEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_SetCaptionEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@SetCaptionEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_SetCaptionEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As SetCaptionEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@PrepareSaveRequestEventArgsClass
'<GROUP !!CLASSES_x-editor><TITLE PrepareSaveRequestEventArgsClass>
':����������:	��������� ������� "PrepareSaveRequest".
'
'@@!!MEMBERTYPE_Methods_PrepareSaveRequestEventArgsClass
'<GROUP PrepareSaveRequestEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass
'<GROUP PrepareSaveRequestEventArgsClass><TITLE ��������>
Class PrepareSaveRequestEventArgsClass
	'@@PrepareSaveRequestEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@PrepareSaveRequestEventArgsClass.CommandName
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE CommandName>
	':����������:	������������ �������� ������� ����������, ���������� 
	'				��� ���������� ������������� ������.
	':���������:	Public CommandName [As String]
	':��. �����:	XRequest.Name
	Public CommandName
	
	'@@PrepareSaveRequestEventArgsClass.Context
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Context>
	':����������:	
	':���������:	Public Context [As String]
	Public Context
	
	'@@PrepareSaveRequestEventArgsClass.XmlBatch
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE XmlBatch>
	':����������:	
	':���������:	Public XmlBatch [As IXMLDOMElement]	
	Public XmlBatch
	
	'@@PrepareSaveRequestEventArgsClass.Request
	'<GROUP !!MEMBERTYPE_Properties_PrepareSaveRequestEventArgsClass><TITLE Request>
	':����������:	������ ������� ��� �������� ����������.
	':���������:	Public Request [As Object]
	':��. �����:	
	'	PrepareSaveRequestEventArgsClass.CommandName, 
	'	Croc.XmlFramework.Public.XRequest
	Public Request
	
	'@@PrepareSaveRequestEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_PrepareSaveRequestEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As PrepareSaveRequestEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@ParseWizardBackMode
'<GROUP !!FUNCTIONS_x-editor><TITLE ParseWizardBackMode>
':����������:
'	����������� �������� �������� wizard-mode, ������������� ������ ���������
'	� ������ �������, � �������������� ��������� ���� XEB_nnnn.
':���������:
'	sWizardMode - [in] ������� �������� �������� wizard-mode
':���������:
'	��������� ���� XEB_nnnn.
':����������:
'	���� �������� ��������� sWizardMode �� ����� ���� ������������ �� � ����� 
'	�� ��������� �������� �������� wizard-mode, �� ������� ���������� ��������� 
'	XEB_UNDOCHANGES.<P/>
'	�������� ���������� �������� �������� wizard-mode �������� � ����� 
'	x-net-interface-schema.xsd.
':���������:
'	Public Function ParseWizardBackMode( sWizardMode [As String] ) [As XEB_nnnn]
Public Function ParseWizardBackMode(sWizardMode)
	Dim nBackMode
	Select Case sWizardMode
		Case "do-nothing" 
			nBackMode = XEB_DO_NOTHING
		Case "get-data"   
			nBackMode = XEB_TRY_GET_DATA
		Case Else 
			nBackMode = XEB_UNDOCHANGES 
	End Select
	ParseWizardBackMode = nBackMode
End Function