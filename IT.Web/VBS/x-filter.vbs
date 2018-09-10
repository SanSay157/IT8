'===============================================================================
'@@!!FILE_x-filter
'<GROUP !!SYMREF_VBS>
'<TITLE x-filter - ���������� �������/��������>
':����������:	�������� ����� ������� � �����������.
':��. �����:	<LINK Filter, ������� />
'===============================================================================
'@@!!FUNCTIONS_x-filter
'<GROUP !!FILE_x-filter><TITLE ������� � ���������>
'@@!!CLASSES_x-filter
'<GROUP !!FILE_x-filter><TITLE ������>

Option Explicit

'===============================================================================
'@@X_GetFilterObject
'<GROUP !!FUNCTIONS_x-filter><TITLE X_GetFilterObject>
':����������:
'	��������� ������� ��� ������ XFilterObjectClass.
':���������:
'	oIFrameObject - [in] ������ iframe, � ������� ��������� �������� �� ���������,
'                   "������������" <LINK Filter-01, ��������� IFilterObject />.                   
':���������:
'	Public Function X_GetFilterObject( oIFrameObject [As IHTMLElement] ) [As XFilterObjectClass]

Public Function X_GetFilterObject(oIFrameObject)
	Set X_GetFilterObject = New XFilterObjectClass
	X_GetFilterObject.Internal_AttachFrame oIFrameObject
End Function

'===============================================================================
'@@XFilterObjectClass
'<GROUP !!CLASSES_x-filter><TITLE XFilterObjectClass>
':����������:	
'	����� ������������� ������ � �������. 
'
'@@!!MEMBERTYPE_Methods_XFilterObjectClass
'<GROUP XFilterObjectClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XFilterObjectClass
'<GROUP XFilterObjectClass><TITLE ��������>


Class XFilterObjectClass
	Private m_oIFrameObject			' ������ iframe
	
	'---------------------------------------------------------------------------
	':���������:
	'	oIFrameObject - [in] ������ iframe, � ������� ��������� �������� �� ���������, "������������" "���������" IFilterObject
	Public Sub Internal_AttachFrame(oIFrameObject)
		Set m_oIFrameObject = oIFrameObject
	End Sub
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.Enabled
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE Enabled>
	':����������:	
	'	��������, ����������� ������������ ��������� ������� ��� 
	'	����������������� �����.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ���������.
	':���������:	
	'	Public Property Get Enabled() [As Boolean]
	'	Public Property Let Enabled( bEnabled [As Boolean] ) [As Boolean]
	Public Property Get Enabled()
		Enabled = m_oIFrameObject.contentWindow.public_get_Enabled()
	End Property
	Public Property Let Enabled( bEnabled )
		m_oIFrameObject.contentWindow.public_put_Enabled( CBool(bEnabled) )
	End Property

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsComponentReady
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsComponentReady>
	':����������:	
	'	������� �������� ����� ����������� ���������� (� ����� ������ ������ � 
	'   ��������).
	':����������:	
	'	�������� ��������� �������� True, ����� �������� ������� ��������� �, 
	'   �������������, ����� �������� ������� <LINK XFilterObjectClass.Init, Init />, 
	'   � False - � ��������� ������.<P/>
	'   �������� ������ ��� ������.<P/>
	'   ����� ����� ��������� (����� X_WaitForTrue) ����� �������� �� ������ �������
	'   <LINK XFilterObjectClass.Init, Init />.
	':���������:	
	'	Public Property Get IsComponentReady() [As Boolean]
	Public Property Get IsComponentReady()
		IsComponentReady = m_oIFrameObject.contentWindow.public_get_IsComponentReady()
	End Property


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsReady
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsReady>
	':����������:	
	'	������� ���������� ������� ����� ���������� ������������� 
	'   (XFilterObjectClass.IsComponentReady AND Not XFilterObjectClass.IsBusy).
	':����������:	
	'	�������� ��������� �������� True, ���� ���������� ������� ����������, 
	'   � False - � ��������� ������.<P/>
	'   �������� ������ ��� ������.<P/>
	'   ����� ����� ��������� (����� X_WaitForTrue) ����� ������ ������� 
	'   <LINK XFilterObjectClass.Init, Init />.
	':���������:	
	'	Public Property Get IsReady() [As Boolean]
	Public Property Get IsReady()
		IsReady = m_oIFrameObject.contentWindow.public_get_IsReady()
	End Property

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ObjectEditor
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE ObjectEditor>
	':����������:	
	'	���������� � ������� �������� ��������.
	':����������:	
	'   �������� ������ ��� ������.
	':���������:	
	'	Public Property Get ObjectEditor [As ObjectEditor]
	Public Property Get ObjectEditor
		' ������ �� ������ ������������� ��� "��������" public_get_ObjectEditor
		On Error Resume Next
		Set ObjectEditor = m_oIFrameObject.contentWindow.public_get_ObjectEditor()
		Err.Clear
	End Property 
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.IsBusy
	'<GROUP !!MEMBERTYPE_Properties_XFilterObjectClass><TITLE IsBusy>
	':����������:	
	'	������� �����������.<P/>
	'	��� ��� ������ ����� ���� ������� ��������, ����������� ����������� 
	'	��������, �� ��� �������� ������������� � ���������� ������� � �������� 
	'	���������� ����������� ��������.
	':����������:	
	'	�������� ��������� �������� True, ���� ������ ��������� � ��������  
	'   ���������� ����������� ��������, � False - � ��������� ������.<P/>
	'   �������� ������ ��� ������.
	':���������:	
	'	Public Property Get IsBusy() [As Boolean]
	Public Property Get IsBusy()
		IsBusy = m_oIFrameObject.contentWindow.public_get_IsBusy()
	End Property 

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.Init
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE Init>
	':����������:	
	'	������� ��������� ������������� �������.
	':���������:
	'	oEventEngine - 
	'       [in] EventEngine ��� �������� ������� �� ������� � ���������.
	'	oFilterObjectInitializationParamsObject - 
	'       [in] ��������� ������ FilterObjectInitializationParamsClass.
	':���������:
	'	���������� True ��� �������� ���������� ������������� � False
	'   � ��������� ������ (������ ����� ������������ ����� Err).
	':���������:
	'	Function Init ( 
	'		oEventEngine [As XEventEngine], 
	'		oFilterObjectInitializationParamsObject [As FilterObjectInitializationParamsClass] 
	'	) [As Boolean]
	Function Init(oEventEngine, oFilterObjectInitializationParamsObject) 
		Init = m_oIFrameObject.contentWindow.public_Init( oEventEngine, oFilterObjectInitializationParamsObject )
	End Function


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.GetRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE GetRestrictions>
	':����������:	
	'	��������� ��������� ���� ����������� �������.
	':���������:
	'	oFilterObjectGetRestrictionsParamsObject - 
	'       [in] ��������� ������ FilterObjectGetRestrictionsParamsClass.
	':���������:
	'	Sub GetRestrictions ( 
	'		oFilterObjectGetRestrictionsParamsObject [As FilterObjectGetRestrictionsParamsClass] 
	'	)
	Sub GetRestrictions( oFilterObjectGetRestrictionsParamsObject )
		m_oIFrameObject.contentWindow.public_GetRestrictions( oFilterObjectGetRestrictionsParamsObject )
	End Sub


	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ClearRestrictions
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE ClearRestrictions>
	':����������:	
	'	��������� ��������� ����� ����������� ������� � �������� �� ���������.
	':���������:
	'	Sub ClearRestrictions () 
	Sub ClearRestrictions()
		m_oIFrameObject.contentWindow.public_ClearRestrictions()
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.GetXmlState
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE GetXmlState>
	':����������:	
	'	������� ���������� XML-���������� ���������� ��������/������� � �������.
	':���������:
	'	Function GetXmlState () [As IXMLDOMElement]
	Function GetXmlState()
		Set GetXmlState = m_oIFrameObject.contentWindow.public_GetXmlState()
	End Function

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.SetVisibility
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE SetVisibility>
	':����������:	
	'	��������� ������������� ��������� ����������.
	':���������:
	'	bShow - 
	'       [in] True - �������� ������, False - �������� ������.
	':����������:	
	'	���������� �������� - ����� ������ SetVisibility(True) ����� �������� 
	'   �� �������� �������� � ��������� ����!<P/>
	'   �������� ���� �� �������.
	':���������:
    '	Sub SetVisibility ( bShow [As Boolean] )
	Sub SetVisibility(bShow)
		If bShow Then
			m_oIFrameObject.style.display = "block"
		Else
			m_oIFrameObject.style.display = "none"
		End If
	End Sub

	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.OnKeyUp
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE OnKeyUp>
	':����������:	
	'	���������-���������� ���������� ������, ������� � ����������.
	':���������:
	'	oEventArgs - 
	'       [in] ��������� �������, ��������� ������ AccelerationEventArgsClass.
	':���������:
    '	Sub OnKeyUp ( oEventArgs [As AccelerationEventArgsClass] )
	Sub OnKeyUp(oEventArgs)
		m_oIFrameObject.contentWindow.public_OnKeyUp oEventArgs
	End Sub
	
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.ShowDebugMenu
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE ShowDebugMenu>
	':����������:	
	'	��������� ������������� ��� ����������� ����������� ���� �������.
	':���������:
    '	Sub ShowDebugMenu ()
	Sub ShowDebugMenu()
		m_oIFrameObject.contentWindow.public_ShowDebugMenu()
	End Sub
	
	'------------------------------------------------------------------------------
	'@@XFilterObjectClass.SetFocus
	'<GROUP !!MEMBERTYPE_Methods_XFilterObjectClass><TITLE SetFocus>
	':����������:	
	'	��������� ������������� ��� ��������� � ������� ������ �� ���������.
	':���������:
    '	Sub SetFocus ()
	Sub SetFocus()
		m_oIFrameObject.contentWindow.public_SetFocus()
	End Sub
End Class

'===============================================================================
'@@FilterObjectInitializationParamsClass
'<GROUP !!CLASSES_x-filter><TITLE FilterObjectInitializationParamsClass>
':����������:	
'	��������� ��� ������������� �������. ������������ ��� ������ �������
'   <LINK Filter-011, Init /> ���������� ���������� �������� �������.
'
'@@!!MEMBERTYPE_Methods_FilterObjectInitializationParamsClass
'<GROUP FilterObjectInitializationParamsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass
'<GROUP FilterObjectInitializationParamsClass><TITLE ��������>

Class FilterObjectInitializationParamsClass

	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.QueryString
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE QueryString>
	':����������:	
	'	������ ���������� ������� ����������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public QueryString [As QueryStringClass]
	Public QueryString				' As QueryStringClass
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.XmlState
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE XmlState>
	':����������:	
	'	����������� ����� �������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.<P/>
	'   ������ ������� �� ���������� ���������� �������.
	':���������:	
	'	Public XmlState [As IXMLDOMElement]
	Public XmlState					' As IXMLDOMElement, ������ - �������� ���� ����������� �������

	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.OuterContainerPage
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE OuterContainerPage>
	':����������:	
	'	��������� ������ ���������� ����-��������, �� ���� ��������, ��������� � 
	'   ���������������� ��������� ������ XFilterObjectClass:
	'	- ��� ������ - ��� XListPageClass;
	'	- ��� �������� - ��� XTreePageClass.
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public OuterContainerPage [As Object]
	Public OuterContainerPage		' As Object
	
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.DisableContentScrolling
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectInitializationParamsClass><TITLE DisableContentScrolling>
	':����������:	
	'	������� ���������� ���������� ����������� �������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.<P/>
	'   ������������ � ������� � ���������.
	':���������:	
	'	Public DisableContentScrolling [As Boolean]
	Public DisableContentScrolling
	
	'------------------------------------------------------------------------------
	'@@FilterObjectInitializationParamsClass.GetRightsCache
	'<GROUP !!MEMBERTYPE_Methods_FilterObjectInitializationParamsClass><TITLE GetRightsCache>
	':����������:	
	'	������� ���������� ���������� ���������� ��������� ���� ����, 
	'   ObjectRightsCacheClass.
	':���������:
    '	Public Function GetRightsCache [As ObjectRightsCacheClass]
	Public Function GetRightsCache
		Set GetRightsCache = X_RightsCache()
	End Function
	
	'-------------------------------------------------------------------------------
	' �����������
	Private Sub Class_Initialize
		Set QueryString = Nothing
		Set XmlState = Nothing
	End Sub	
End Class


'===============================================================================
'@@FilterObjectGetRestrictionsParamsClass
'<GROUP !!CLASSES_x-filter><TITLE FilterObjectGetRestrictionsParamsClass>
':����������:	
'	��������� ��� ����� ����������� �������. ������������ ��� ������ �������
'   IFilterObject::GetRestrictions.
'
'@@!!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass
'<GROUP FilterObjectGetRestrictionsParamsClass><TITLE ��������>
Class FilterObjectGetRestrictionsParamsClass

	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.Description
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE Description>
	':����������:	
	'	�������� �����������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public Description [As String]
	Public Description

	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE ReturnValue>
	':����������:	
	'	������� ��������� ����� ������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ReturnValue [As Boolean]
	Public ReturnValue
	
	'------------------------------------------------------------------------------
	'@@FilterObjectGetRestrictionsParamsClass.ParamCollectionBuilder
	'<GROUP !!MEMBERTYPE_Properties_FilterObjectGetRestrictionsParamsClass><TITLE ParamCollectionBuilder>
	':����������:	
	'	������������� ��������� �����������. 
	':����������:	
	'	�������� �������� ��� ��� ������, ��� � ��� ������.
	':���������:	
	'	Public ParamCollectionBuilder [As IParamCollectionBuilder]
	Public ParamCollectionBuilder
	
	
	'-------------------------------------------------------------------------------
	' ����������:	�����������
	' ���������:    
	' ���������:	
	' ����������:	
	' �����������:	
	' ������: 
	Private Sub Class_Initialize
		' �� ��������� ��� ��
		ReturnValue = True
		' �� ��������� �������� "������" �����	
		Set ParamCollectionBuilder = New IParamCollectionBuilder
	End Sub
End Class
