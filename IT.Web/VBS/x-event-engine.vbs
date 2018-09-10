Option Explicit
'===============================================================================
'@@!!FILE_x-event-engine
'<GROUP !!SYMREF_VBS>
'<TITLE x-event-engine - ���������� ��������� �������>
':����������:	���������� ��������� �������.
'===============================================================================
'@@!!FUNCTIONS_x-event-engine
'<GROUP !!FILE_x-event-engine><TITLE ������� � ���������>
'@@!!CLASSES_x-event-engine
'<GROUP !!FILE_x-event-engine><TITLE ������>


'===============================================================================
'@@EventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE EventArgsClass>
':����������:	"�������" ����� ���������� �������. 
':����������:	ReturnValue - �������������� ����.
'
'@@!!MEMBERTYPE_Methods_EventArgsClass
'<GROUP EventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_EventArgsClass
'<GROUP EventArgsClass><TITLE ��������>
Class EventArgsClass
	'@@EventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel				
	
	'@@EventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_EventArgsClass><TITLE ReturnValue>
	':����������:	������, ������������ ������������ �������.
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue
	
	'@@EventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_EventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As EventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@CommonEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE CommonEventArgsClass>
':����������:	����� ��������� ������� ��� �������� ����.
'
'@@!!MEMBERTYPE_Methods_CommonEventArgsClass
'<GROUP CommonEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_CommonEventArgsClass
'<GROUP CommonEventArgsClass><TITLE ��������>
Class CommonEventArgsClass
	'@@CommonEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ObjectID>
	':����������:	������������� �������.
	':���������:	Public ObjectID [As String]	
	Public ObjectID

	'@@CommonEventArgsClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ObjectType>
	':����������:	������������ ���� �������
	':���������:	Public ObjectType [As String]
	Public ObjectType

	'@@CommonEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE ReturnValue>
	':����������:	������������ ��������. ����� ������� �� ���������.
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue

	'@@CommonEventArgsClass.Metaname
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Metaname>
	':����������:	������� ������� / ��������� / ������ / ������
	':���������:	Public Metaname [As String]
	Public Metaname

	'@@CommonEventArgsClass.AddEventArgs
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE AddEventArgs>
	':����������:	�������������� ��������� �������.
	':���������:	Public AddEventArgs [As Variant]
	Public AddEventArgs

	'@@CommonEventArgsClass.Values
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Values>
	':����������:	��������� ���������� ������ ����.
	':���������:	Public Values [As Scripting.Dictionary]
	Public Values

	'@@CommonEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_CommonEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@CommonEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_CommonEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As CommonEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@DeleteObjectEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE DeleteObjectEventArgsClass>
':����������:	��������� �������, ��������� � ��������� ������� (�������� DoDelete).
'
'@@!!MEMBERTYPE_Methods_DeleteObjectEventArgsClass
'<GROUP DeleteObjectEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_DeleteObjectEventArgsClass
'<GROUP DeleteObjectEventArgsClass><TITLE ��������>
Class DeleteObjectEventArgsClass
	'@@DeleteObjectEventArgsClass.ObjectID
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ObjectID>
	':����������:	������������� �������.
	':���������:	Public ObjectID [As String]
	Public ObjectID

	'@@DeleteObjectEventArgsClass.ObjectType
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ObjectType>
	':����������:	������������ ���� ������� 
	':���������:	Public ObjectType [As String]
	Public ObjectType

	'@@DeleteObjectEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE ReturnValue>
	':����������:	������������ ��������. ����� ������� �� ���������. 
	':���������:	Public ReturnValue [As Variant]
	Public ReturnValue

	'@@DeleteObjectEventArgsClass.Count
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Count>
	':����������:	���������� ��������� / ��������� ��������.
	':���������:	Public Count [As Integer]
	Public Count

	'@@DeleteObjectEventArgsClass.AddEventArgs
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE AddEventArgs>
	':����������:	�������������� ��������� �������.
	':���������:	Public AddEventArgs [As Variant]
	Public AddEventArgs

	'@@DeleteObjectEventArgsClass.Values
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Values>
	':����������:	��������� ���������� ������ ����.
	':���������:	Public Values [As Scripting.Dictionary]
	Public Values

	'@@DeleteObjectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel	[As Boolean]
	Public Cancel

	'@@DeleteObjectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_DeleteObjectEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As DeleteObjectEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'===============================================================================
'@@AccelerationEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE AccelerationEventArgsClass>
':����������:	��������� ������� Accel.
'
'@@!!MEMBERTYPE_Methods_AccelerationEventArgsClass
'<GROUP AccelerationEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_AccelerationEventArgsClass
'<GROUP AccelerationEventArgsClass><TITLE ��������>
Class AccelerationEventArgsClass
	'@@AccelerationEventArgsClass.keyCode
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE keyCode>
	':����������:	��� ������� / �������.
	':���������:	Public keyCode [As Byte]
	Public keyCode

	'@@AccelerationEventArgsClass.altKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE altKey>
	':����������:	������� ������� ������� Alt.
	':���������:	Public altKey [As Boolean]
	Public altKey

	'@@AccelerationEventArgsClass.ctrlKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE ctrlKey>
	':����������:	������� ������� ������� Ctrl.
	':���������:	Public ctrlKey [As Boolean]
	Public ctrlKey

	'@@AccelerationEventArgsClass.shiftKey
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE shiftKey>
	':����������:	������� ������� ������� Shift.
	':���������:	Public shiftKey [As Boolean]
	Public shiftKey

	'@@AccelerationEventArgsClass.DblClick
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE DblClick>
	':����������:	������� �������� ����� ����.
	':���������:	Public DblClick [As Boolean]
	Public DblClick

	'@@AccelerationEventArgsClass.MenuPosX
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE MenuPosX>
	':����������:	�������� X-���������� ��� ����������� ����������� ���� � ����������, 
	'				���������������� ������� ����������
	':���������:	Public MenuPosX [As Long]
	Public MenuPosX

	'@@AccelerationEventArgsClass.MenuPosY
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE MenuPosY>
	':����������:	�������� Y-���������� ��� ����������� ����������� ���� � ����������, 
	'				���������������� ������� ����������
	':���������:	Public MenuPosY [As Long]
	Public MenuPosY
	
	'@@AccelerationEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@AccelerationEventArgsClass.Processed
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Processed>
	':����������:	������� ����, ��� ������� ���������� ����������.
	':���������:	Public Processed [As Boolean]
	Public Processed

	'@@AccelerationEventArgsClass.Source
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE Source>
	':����������:	������ �� �������� ��������, � ������� ���� ������ ���������� ������.
	':���������:	Public Source [As IXPropertyEditor]
	Public Source

	'@@AccelerationEventArgsClass.HtmlSource
	'<GROUP !!MEMBERTYPE_Properties_AccelerationEventArgsClass><TITLE HtmlSource>
	':����������:	HTML-�������, ���������� ��������� �������.
	':���������:	Public HtmlSource [As HTMLDOMElement]
	Public HtmlSource
		
	'@@AccelerationEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_AccelerationEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As AccelerationEventArgsClass]
	Public Function Self()
		Set  Self = Me
	End Function
End Class


'==============================================================================
' ������� ��������� AccelerationEventArgsClass �� ������ �������� html-������� (window.event)
Function CreateAccelerationEventArgsForHtmlEvent
	With New AccelerationEventArgsClass
		.keyCode	= window.event.keyCode
		.altKey		= window.event.altKey
		.ctrlKey	= window.event.ctrlKey
		.shiftKey	= window.event.shiftKey
		Set .HtmlSource = window.event.srcElement
		Set CreateAccelerationEventArgsForHtmlEvent = .Self()
	End With	
End Function


'==============================================================================
' ������� ��������� AccelerationEventArgsClass �� ������ ���������� ActiveX-������� onKeyUp
Function CreateAccelerationEventArgsForActiveXEvent(nKeyCode, nFlags)
	With New AccelerationEventArgsClass
		.keyCode	= nKeyCode
		.altKey		= CBool(nFlags and KF_ALTLTMASK)
		.ctrlKey	= CBool(nFlags and KF_CTRLMASK)
		.shiftKey	= CBool(nFlags and KF_SHIFTMASK)
		Set CreateAccelerationEventArgsForActiveXEvent = .Self()
	End With
End Function


'==============================================================================
' ������� ��������� AccelerationEventArgsClass �� ������ ���� �������� ����������
Function CreateAccelerationEventArgs(keyCode, altKey, ctrlKey, shiftKey)
	With New AccelerationEventArgsClass
		.keyCode	= keyCode
		.altKey		= altKey
		.ctrlKey	= ctrlKey
		.shiftKey	= shiftKey
		Set CreateAccelerationEventArgs = .Self()
	End With	
End Function


'===============================================================================
'@@GetRestrictionsEventArgsClass
'<GROUP !!CLASSES_x-event-engine><TITLE GetRestrictionsEventArgsClass>
':����������:	
'	��������� ������� "GetRestrictions", ������������� � ���������  ���������� 
'	(������, ��������). ������������ ��� ��������� ��������� ���������� ��� 
'	��������� ������ (���� �� �������, ���� �������� ���������� �����).
'
'@@!!MEMBERTYPE_Methods_GetRestrictionsEventArgsClass
'<GROUP GetRestrictionsEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass
'<GROUP GetRestrictionsEventArgsClass><TITLE ��������>
Class GetRestrictionsEventArgsClass
	'@@GetRestrictionsEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetRestrictionsEventArgsClass.UrlParams
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE UrlParams>
	':����������:	��������� ��������.
	':���������:	Public UrlParams [As String]
	Public UrlParams
	
	'@@GetRestrictionsEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE ReturnValue>
	':����������:	��������� ����������.
	':���������:	Public ReturnValue [As String]
	Public ReturnValue
	
	'@@GetRestrictionsEventArgsClass.Description
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE Description>
	':����������:	�������� �����������.
	':���������:	Public Description [As String]
	Public Description
	
	'@@GetRestrictionsEventArgsClass.ExcludeNodes
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE ExcludeNodes>
	':����������:	������ �� ������� ����������� �� �������� �����. ��. ����������� � [x-utils.vbs]SelectFromTreeDialogClass.ExcludeNodes
	':���������:	Public ExcludeNodes [As String]
	Public ExcludeNodes
	
	'@@GetRestrictionsEventArgsClass.StayOnCurrentPage
	'<GROUP !!MEMBERTYPE_Properties_GetRestrictionsEventArgsClass><TITLE StayOnCurrentPage>
	':����������:	�������, �������� ������������� �������� �� ������� �������� (��� ������������� ���������).
	':���������:	Public StayOnCurrentPage [As Boolean]
	Public StayOnCurrentPage
	
	'@@GetRestrictionsEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetRestrictionsEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As GetRestrictionsEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'==============================================================================
' ��������� �������. ������� ��������� XDelegate
Function X_CreateDelegate(vObject, sMethodName)
	Dim oDelegate	' As CROC.Delegate
	Set oDelegate = New XDelegate
	oDelegate.Init vObject, sMethodName
	Set X_CreateDelegate = oDelegate 
End Function


'==============================================================================
' ��������� �������. ������� ��������� XEventEngine
Function X_CreateEventEngine
	Set X_CreateEventEngine = New XEventEngine
End Function


Dim x_oGlobalStaticHandlers		' As Scripting.Dictionary - ������� ���������� ������������

'===============================================================================
'@@X_RegisterStaticHandler
'<GROUP !!FUNCTIONS_x-event-engine><TITLE X_RegisterStaticHandler>
':����������:	
'	������������ ��������� ��������� � �������� ����������� ����������� �������.
':���������:
'	sHandlerStrongName - [in] ������������ ���������� ���������, ��� ������� 
'			�������������� ���������, �������� ���������� sProcName
'	sProcName - [in] ������������ ���������, �������������� � �������� �����������
':����������:
'	��������� ���������� �������������� ��������� ������������ ������� �� ������ 
'	������������ ��������.
':��. �����:
'	X_GetRegisteredStaticHandlers, <P/>
'	<LINK cee-6, ����������� ���������� � ������� ������� />
':���������:
'	Sub X_RegisterStaticHandler( sHandlerStrongName [As String], sProcName [As String] )
Sub X_RegisterStaticHandler(sHandlerStrongName, sProcName)
	Dim aProcNames	' As Array
	If IsEmpty(x_oGlobalStaticHandlers) Then
		Set x_oGlobalStaticHandlers = CreateObject("Scripting.Dictionary")
	End If
	aProcNames = x_oGlobalStaticHandlers.Item(sHandlerStrongName)
	If IsEmpty(aProcNames) Then
		aProcNames = Array()
	End If
	' ������� ������������ ��������� � ����� �������
	arrayAddition sProcName, aProcNames
	x_oGlobalStaticHandlers.Item(sHandlerStrongName) = aProcNames
End Sub


'===============================================================================
'@@X_GetRegisteredStaticHandlers
'<GROUP !!FUNCTIONS_x-event-engine><TITLE X_GetRegisteredStaticHandlers>
':����������:	
'	���������� ������ ������������ ��������, ������������������ ��� "�������" 
'	�����������, ������� ���������� sHandlerStrongName.
':���������:
'	sHandlerStrongName - [in] ������������ "������" �����������
':���������:
'	������ ������������ ��������, ������������������ ��� ��������� �������������-
'	"�������". ���� ����� �������� ���, ������� ���������� ������ ������.
':��. �����:
'	X_RegisterStaticHandler, <P/>
'	<LINK cee-6, ����������� ���������� � ������� ������� />
':���������:
'	Function X_GetRegisteredStaticHandlers( sHandlerStrongName [As String] ) [As Array]
Function X_GetRegisteredStaticHandlers(sHandlerStrongName)
	If IsEmpty(x_oGlobalStaticHandlers) Then
		X_GetRegisteredStaticHandlers = Array()
	ElseIf  x_oGlobalStaticHandlers.Exists(sHandlerStrongName) Then
		X_GetRegisteredStaticHandlers = x_oGlobalStaticHandlers.Item(sHandlerStrongName)
		If IsEmpty(X_GetRegisteredStaticHandlers) Then
			X_GetRegisteredStaticHandlers = Array()
		End If
	Else
		X_GetRegisteredStaticHandlers = Array()
	End If
End Function


'==============================================================================
' �������� ��� ����������� ��� ��������� �������
' ��������� �������� �� ������ XEventEngine ��� ����, ����� �� ����������� ������� ����� ��������� ������� (����� ".")
'	[in] oEventEngine As XEventEngine - 
'	[in] sEventName As String - ������������ �������
'	[in] oSender As Object - ��������� ������ �������, ������� ����� ������� � ����������� �������
'	[in] oEventArgs As Object - ��������� �������
Sub XEventEngine_FireEvent(oEventEngine, sEventName, oSender, oEventArgs)
	Dim aDelegates		' As XDelegate()
	Dim i

	If Not IsNothing(oEventArgs) Then
		oEventArgs.Cancel = False
	End If
	If Not oEventEngine.Internal_Subscribers.Exists(sEventName) Then Exit Sub
	aDelegates = oEventEngine.Internal_Subscribers.Item(sEventName)
	For i=0 to UBound(aDelegates)
		XDelegate_Execute aDelegates(i), oSender, oEventArgs
		If Not IsNothing(oEventArgs) Then
			If oEventArgs.Cancel Then
				Exit For
			End If
		End If
	Next
End Sub


'==============================================================================
' ���������� �������� (���, �������������� ����������� XDelegate).
' ��������� �������� �� ������ XDelegate ��� ����, ����� �� ����������� ������� ����� ��������� ������� (����� ".")
'	[in] oDelegate As XDelegate - �������
'	[in] oSender As Object - ��������� ������ �������, ������� ����� ������� � ����������� �������
'	[in] oEventArgs As Object - ��������� �������
Sub XDelegate_Execute(oDelegate, oSender, oEventArgs)
	Dim oObjectRef
	With oDelegate
		If .IsObjectRef Then
			' ����� ������ �������
			Set oObjectRef = .ObjectRef
			Execute "oObjectRef." & .MethodName & " oSender, oEventArgs"
		ElseIf .IsMethodRef Then
			' ����� ���������� ��������� ����� ������, ���������� �� GetRef
			Set oObjectRef = .MethodRef
			oObjectRef oSender, oEventArgs
		Else
			' ����� ���������� ��������� �� ������������
			Execute .MethodName & " oSender, oEventArgs"
		End If
	End With
End Sub


'==============================================================================
' ����� ������������� ������ � ������������� �������. ��������� ��� ���������� 
'	������� ������� ������ ������������.
' ��������:
' ��-�� ������ VBScript-runtime ����� �� �������� ������ FireEvent - �� ������� 
'	� ���������� ��������� XEventEngine_FireEvent.
' ������� ��� ��� ����, ����� �� ����������� ���� ��������� �������, ���������� 
'	������� ������� 14 �������� � "stack overflow at line 0"
Class XEventEngine
	Private m_oSubscribers		' As New Scripting.Dictionary - ������� �������� ����������� �� ������� 
								' (��������� ����������� ����������� CROC.Delegate)

	'==============================================================================
	' "�����������"
	Private Sub Class_Initialize
		Set m_oSubscribers = CreateObject("Scripting.Dictionary")
		m_oSubscribers.CompareMode = vbTextCompare
	End Sub

	'==============================================================================
	' ���������� ������� �����������. ��� ����������� �������������!
	Public Property Get Internal_Subscribers
		Set Internal_Subscribers = m_oSubscribers
	End Property

	'==============================================================================
	' ����������� ��� ������ �� �������
	Sub Dispose
		Dim oDlg
		Dim o		' ��������� ���������� ��� �������������� �����
		Dim i
		On Error Resume Next
		Set o = m_oSubscribers
		Set m_oSubscribers = Nothing
		For Each oDlg In o.Items
			For i= 0 To UBound(oDlg)
				oDlg(i).Dispose
			Next
		Next
	End Sub

	'==============================================================================
	' ��������� ���������� �������
	Sub AddHandlerForEvent(sEventName, vObj, sMethodName)
		InsertHandlerForEvent -1, sEventName, vObj, sMethodName
	End Sub

	'==============================================================================
	' ��������� ���������� �������, ���� ��� ������� ������� �� ������ �����������
	'	[retval] True - ���������� ��������, False - ���������� �� ��������
	Function AddHandlerForEventWeakly(sEventName, vObj, sMethodName )
		AddHandlerForEventWeakly = False
		If IsHandlerExists(sEventName) Then Exit Function
		InsertHandlerForEvent -1, sEventName, vObj, sMethodName
		AddHandlerForEventWeakly = True
	End Function

	'==============================================================================
	' ��������� ���������� �������
	Sub AddDelegateForEvent(sEventName, oDelegate)
		InsertDelegateForEvent -1, sEventName, oDelegate
	End Sub

	'==============================================================================
	' ��������� ���������� ������� � ������ ������������ �� ����� � �������� ��������
	Sub InsertHandlerForEvent(ByVal nIndex, sEventName, vObj, sMethodName)
		Dim oSubscriber		' As CROC.Delegate
		Set oSubscriber = X_CreateDelegate(vObj, sMethodName)
		
		InsertDelegateForEvent nIndex, sEventName, oSubscriber		
	End Sub

	'==============================================================================
	' ��������� ���������� ������� � ������ ������������ �� ����� � �������� ��������
	Sub InsertDelegateForEvent(ByVal nIndex, sEventName, oDelegate)
		Dim aHandlers		' As Array
		If m_oSubscribers.Exists(sEventName) Then
			aHandlers = m_oSubscribers.Item(sEventName)
		End If
				
		insertRefInfoArray aHandlers, nIndex, oDelegate
		m_oSubscribers.Item(sEventName) = aHandlers
	End Sub

	'==============================================================================
	' ������� ���� ����������� ��� ��������� ������� � ��������� ��������
	Sub ReplaceHandlerForEvent(sEventName, vObj, sMethodName)
		RemoveAllHandlersForEvent sEventName
		AddHandlerForEvent sEventName, vObj, sMethodName
	End Sub

	'==============================================================================
	' ������� ���� ����������� ��� ��������� ������� � ��������� ��������
	Sub ReplaceDelegateForEvent(sEventName, oDelegate)
		RemoveAllHandlersForEvent sEventName
		AddDelegateForEvent sEventName, oDelegate
	End Sub

	'==============================================================================
	' ������� ��������� ���������� �� ��������� �������
	Sub RemoveHandlerForEvent(sEventName, vObj, sMethodName)
		Dim oSubscriber		' As CROC.Delegate
		Dim aSubscribers	' As Array	- ������ ������������ (����������� CROC.Delegate) ��� �������
		Dim i
		If m_oSubscribers.Exists(sEventName) Then
			Set oSubscriber = X_CreateDelegate(vObj, sMethodName)
			aSubscribers = m_oSubscribers.Item(sEventName)
			For i=0 To UBound(aSubscribers )
				If aSubscribers(i).IsEquals(oSubscriber) Then
					removeArrayItemByIndex aSubscribers, i
					Exit Sub
				End If
			Next
		End If
	End Sub

	'==============================================================================
	' ������� ���� ����������� ��� ��������� �������
	Public Sub RemoveAllHandlersForEvent(sEventName)
		m_oSubscribers.Item(sEventName) = Array()
	End Sub

	'==============================================================================
	' ������� ���� ����������� ��� ���� �������
	Public Sub Clear
		m_oSubscribers.RemoveAll
	End Sub

	'==============================================================================
	' ���������� ������ ������������ ��� �������. ���� ������������ ���, ������������ ������ ������
	Public Function GetHandlersForEvent(sEventName)	' As Array
		GetHandlersForEvent = Array()
		If Not m_oSubscribers.Exists(sEventName) Then Exit Function
		GetHandlersForEvent  = m_oSubscribers.Item(sEventName)
	End Function


	'==============================================================================
	' �������������� ��������� ������������ ������� �� ����� ����� ��������� - �.�. "����������� �������"
	' ��� ������� ������� �� ����������� ������ ������ ���������� ���������/������� � ������������� {������}{������������_�������}.
	' ���� ���������/������� ����������, �� ��� _�����������_ ��� ���������� �������.
	'	[in] sEventsList - ������ ������������ ������� ����������� �������
	'	[in] sPrefix	 - ������� ������������ ���������� ��������/�������. ��������, usrXList_On
	Public Sub InitHandlers(ByVal sEventsList, sPrefix)
		InitHandlersEx sEventsList, sPrefix, False, False
	End Sub


	'==============================================================================
	' �������������� ��������� ������������ ������� �� ����� ����� ��������� - �.�. "����������� �������"
	' �������� ��� �� ��� InitHandlers, �� ����� �����.
	'	[in] sEventsList - ������ ������������ ������� ����������� �������
	'	[in] sPrefix	 - ������� ������������ ���������� ��������/�������. ��������, usrXList_On
	'	[in] bAddIfEmpty As Boolean - ���� True, �� ��������� �� ����� ���������� ����������� � ��������� ������������ 
	'			������ � ������, ���� ��� ������. ���� False, �� ���������� ����������� � ����� ������.
	'	[in] bRewrite As Boolean	- ���� True, �� ��������� ���������� �������������� ��� ����������
	Public Sub InitHandlersEx(ByVal sEventsList, sPrefix, bAddIfEmpty, bRewrite)
		Dim sEventName		' ������������ �������
		Dim sHandlerName	' ������������ �����������
		Dim sPropName		' ������������ ���������, ������������������ � �������� �����������
		
		' ����������������� ������ ������������
		For Each sEventName In Split(sEventsList, ",")
			sHandlerName = sPrefix & sEventName
			If X_IsProcPresented( sHandlerName ) Then
				If bRewrite Then
					ReplaceHandlerForEvent sEventName, Null, sHandlerName
				Else
					' ������ ������� �����: Not bAddIfEmpty Or (Not IsHandlerExists( sEventName ) And bAddIfEmpty),
					' ������ ��� ����� ���������:
					If Not bAddIfEmpty Or Not IsHandlerExists( sEventName ) Then
						AddHandlerForEvent sEventName, Null, sHandlerName
					End If
				End If
			End If
			If Not bRewrite And Not bAddIfEmpty Then
				' � ������ ������ ���������, ������������������ � �������� ����������� � "���������" ������������� � ���������� �������
				For Each sPropName In X_GetRegisteredStaticHandlers(sHandlerName)
					If X_IsProcPresented( sPropName ) Then
						AddHandlerForEvent sEventName, Null, sPropName
					End if 
				Next
			End If
		Next
	End Sub


	'==============================================================================
	' ���������� true, ���� �� �������� ������� ���� ����������
	Public Function IsHandlerExists(sEventName)
		Dim aDelegates
		Dim i		
		IsHandlerExists = False
		If Not m_oSubscribers.Exists(sEventName) Then Exit Function
		aDelegates = m_oSubscribers.Item(sEventName)
		For i=0 To UBound( aDelegates )
			If Not aDelegates(i) Is Nothing Then 
				IsHandlerExists = True
				Exit Function
			End If
		Next		
	End Function
End class



'==============================================================================
' �����, �������� ������ �� �����-�� ���: ���������, ������� ��� ����� ���������� ������
' ��� ���������� ����, ��������������� ���������, ���� ������������ XDelegate_Execute
Class XDelegate
	Private m_oObjectRef		' ������ �� ������ ������
	Private m_sMethodName		' ������������ ������/���������/�������
	Private m_oMethodRef		' ������ �� ������, �������������� ������ �� ���������� ���������, ���������� ����� GetRef

	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
	End Sub
	
	'--------------------------------------------------------------------------
	' ����������� ������ �� ������
	Public Sub Dispose
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
	End Sub


	'--------------------------------------------------------------------------
	' �������������� "�������". �������/���������/����� ������ ������ ����� ��������:
	'	proc(oSender, oEventArg)
	'	[in] vObject - ������ �� ������ ��� ������������ ���������� ���������� �� �������
	'	[in] sMethodName - ������������ ������ ������� (���� �� �����), 
	'		���� ���������� �������/��������� (���� ������ �� �����), 
	'		���� ������, ���������� ����� GetRef(..)
	Sub Init(vObject, vMethodName)
		Set m_oObjectRef = Nothing
		Set m_oMethodRef = Nothing
		If TypeName(vObject)="String" Then
			If Len(vObject)>0 Then
				Execute "Set m_oObjectRef = " & vObject
			End If
			m_sMethodName = vMethodName
		ElseIf IsObject(vMethodName) Then
			' ������ �� ���������� �������/���������
			Set m_oMethodRef = vMethodName
		ElseIf IsObject(vObject) Then
			If Not vObject Is Nothing Then
				Set m_oObjectRef = vObject
			End If
			m_sMethodName = vMethodName
		Else
			' ������������ ���������� �������/���������
			m_sMethodName = vMethodName
		End If
	End Sub


	'--------------------------------------------------------------------------
	' ���������� True, ���� "�������" ������������ ������ �� ����� �������, 
	' ����� False
	Function IsObjectRef()	' As Boolean
		IsObjectRef = Not m_oObjectRef Is Nothing
	End Function


	'--------------------------------------------------------------------------
	' ���������� ������ �� ������, ���� "�������" ������������ ������ �� ����� �������, ����� Nothing
	Function ObjectRef		' As Object
		Set ObjectRef = m_oObjectRef
	End Function


	'--------------------------------------------------------------------------
	' ���������� ������������ ������, �������, ���������
	Function MethodName		' As String
		MethodName = m_sMethodName
	End Function


	'--------------------------------------------------------------------------
	' ���������� True, ���� "�������" ������������ ������ �� ���������� ���������, ���������� ����� GetRef
	Function IsMethodRef
		IsMethodRef = Not m_oMethodRef Is Nothing
	End Function


	'--------------------------------------------------------------------------
	' ���������� ������ �� �������, ���������, ���������� ����� GetRef
	Function MethodRef
		Set MethodRef = m_oMethodRef
	End Function


	'--------------------------------------------------------------------------
	' ���������� ��� ������� XDelegate. ������� �����, ���� ��������� �� ���� � ��� �� ���.
	Function IsEquals(oDelegate)
		IsEquals = False
		If TypeName(oDelegate) <> TypeName(Me) Then Exit Function
		If oDelegate.IsObjectRef Then
			IsEquals = (oDelegate.ObjectRef Is m_oObjectRef And oDelegate.MethodName = m_sMethodName)
		ElseIf oDelegate.IsMethodRef Then
			IsEquals = (oDelegate.MethodRef Is m_oMethodRef)
		ElseIf oDelegate.MethodName = m_sMethodName Then
			IsEquals = True
		End If
	End Function

	'--------------------------------------------------------------------------
	Function Self
		Set Self = Me
	End Function
End Class