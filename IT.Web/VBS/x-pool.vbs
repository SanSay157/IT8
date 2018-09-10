'===============================================================================
'@@!!FILE_x-pool
'<GROUP !!SYMREF_VBS>
'<TITLE x-pool - ������������ ���� �������� �� ������� �������>
':����������:	������������ ���� �������� �� ������� �������.
'===============================================================================
'@@!!CLASSES_x-pool
'<GROUP !!FILE_x-pool><TITLE ������>
Option Explicit
 
Const ATTR_NOTNULL = "notnull"		' ������� xml-�������� - ������� ��������������, ����������� ������� meybenull ������������


'==============================================================================
' ��������� ����
Class XObjectPoolStateClass
	Public XmlObjectPool		' As IXMLDOMElement - �������� ������� xml-���� ��������
	Public TransactionID		' As String - ������������� ����������
End Class


'==============================================================================
' ���������� �����, �������� ��� ������ ������������ ��������� � ����, �������� �� ����, 
' � ������� ��� ������ ��������� XObjectPoolClass
Class Internal_EvaluatorClass
	Private m_oPool
	
	Public Sub Init(oPool)
		Set m_oPool = oPool
	End Sub
	
	Private Function pool()
		Set pool = m_oPool
	End Function
	
	Public Function Evaluate(sStatement, oXmlObject)
		Evaluate = Eval(sStatement)
	End Function
	
	Public Function GetPropertyValue(oXmlObjectX, sOPath)
		GetPropertyValue = m_oPool.GetPropertyValue(oXmlObjectX, sOPath)
	End Function
End Class


'==============================================================================
Function X_EvaluateInWindow (oPool, sStatement, oXmlObject)
	With New Internal_EvaluatorClass
		.Init oPool
		X_EvaluateInWindow = .Evaluate(sStatement, oXmlObject)
	End With
End Function


'===============================================================================
'@@XObjectPoolClass
'<GROUP !!CLASSES_x-pool><TITLE XObjectPoolClass>
':����������:	�����, �������������� <B>��� ��������</B>.
':��������:		<B>��� ��������</B> - ���������, �������������� ����������� 
'				���������� �������� ��� XML-��������� �� ������� �������.
':��. �����:	<LINK oe-2, ��� �������� - ����� ��������/>
'
'@@!!MEMBERTYPE_Methods_XObjectPoolClass
'<GROUP XObjectPoolClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_XObjectPoolClass
'<GROUP XObjectPoolClass><TITLE ��������>
Class XObjectPoolClass
	Private m_oXmlObjectPool			' As IXMLDOMElement - xml-���, ������� "x-o"
	Private m_oPoolTransactionLog		' As StackClass - transaction log, ������� ����� - ��������� XObjectPoolStateClass
	Private m_sTransactionID			' As String - ������������� ������� ����������
	Private m_oBackStack				' As StackClass - "������������" ���� �����. ������� ����� - IXMLDOMElement, ����� m_oXmlObjectPool
	Private m_oActiveEditorStack		' As StackClass, ������� ����� ������������ ���������� ���������� � ����������� ObjectEditorClass
	Private m_oExecuteStatementRegExp	' As RegExp - ���������� ��������� ��� ����������
	Private m_oXmlPendingActions		' As IXMLDOMElement - xml-���� x-pending-actions, ����������� ��������� ���� x-o, ��� �������� ������� �� ���������� ���������
	Private m_bHasPendingActions		' As Boolean - ���������� ������� ��� ����������� ������� ���������� ��������
										'	������������ � applyPendingActionsForObject
	
	'---------------------------------------------------------------------------
	' ����������� - ���������� ����� ������������� ������ ���������� ������
	Private Sub Class_Initialize
		Set m_oXmlObjectPool = XService.XmlGetDocument
		Set m_oXmlObjectPool = m_oXmlObjectPool.AppendChild(m_oXmlObjectPool.CreateElement("x-o"))
		Set m_oXmlPendingActions = m_oXmlObjectPool.AppendChild( m_oXmlObjectPool.ownerDocument.CreateElement("x-pending-actions") )
		m_sTransactionID = CreateGuid
		Set m_oActiveEditorStack	= New StackClass
		Set m_oPoolTransactionLog	= New StackClass
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Xml
	'<GROUP !!MEMBERTYPE_Properties_XObjectPoolClass><TITLE Xml>
	':����������:	������������ XML � ������� ����� ���� ��������.
	':����������:	�������� XML-������� ������ ���� - ������� <B>x-o</B>.
	':���������:	Public Property Get Xml [As IXMLDOMElement]
	Public Property Get Xml
		Set Xml = m_oXmlObjectPool
	End Property


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RegisterEditor
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RegisterEditor>
	':����������:	������������ �������� ��������. ����� ��������� ����� 
	'				������������ ��� ������� ����.
	':���������:	oObjectEditor - [in] ������� ��������, ��������� ObjectEditorClass
	':��. �����:	XObjectPoolClass.UnRegisterEditor
	':���������:	Public Sub RegisterEditor( oObjectEditor [As ObjectEditorClass] )
	Public Sub RegisterEditor(oObjectEditor)
		If Not IsNothing(oObjectEditor) Then
			m_oActiveEditorStack.Push oObjectEditor
		Else
			m_oActiveEditorStack.Push Nothing
		End If
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.UnRegisterEditor
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE UnRegisterEditor>
	':����������:	������� ����������� �������� ���������.
	':��. �����:	XObjectPoolClass.RegisterEditor
	':���������:	Public Sub UnRegisterEditor()
	Public Sub UnRegisterEditor()
		m_oActiveEditorStack.Pop
	End Sub
	
	
	'---------------------------------------------------------------------------
	':����������:	���������� ��������� ��������� ���������, ��� Nothing, ���� 
	'				���������� ��� �� ��� ���������������.
	':����������:	�������� ������ ��� ������.
	Private Property Get ObjectEditor
		If IsObject(m_oActiveEditorStack.Top) Then
			Set ObjectEditor = m_oActiveEditorStack.Top
		Else
			Set ObjectEditor = Nothing
		End If
	End Property
	
	
	'---------------------------------------------------------------------------
	':����������:	���������� ������ ���� (IHtmlWindow) ��������� ���������, 
	'				���� ��� ���������� �� ����, � ������� ��� ������ ������� ������.
	':���������:	���������� ������ ���� (IHtmlWindow).
	Private Function GetEditorAnotherWindow
		Set GetEditorAnotherWindow = Nothing
		If Not ObjectEditor Is Nothing Then
			If Not ObjectEditor.GetWindow Is window Then
				Set GetEditorAnotherWindow = ObjectEditor.GetWindow 
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	':����������:	���������� �������� ������� ��������� ���������.
	':���������:	sEventName - [in] ������������ �������
	'				oEventArgs - [in] ��������� ������ ���������� ������� (��� Nothing)
	Private Sub FireEventInEditor( sEventName, oEventArgs )
		Dim oObjectEditor 
		Set oObjectEditor = ObjectEditor
		If Not oObjectEditor Is Nothing Then
			oObjectEditor.Internal_FireEvent sEventName, oEventArgs
		End If
	End Sub

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.TransactionID
	'<GROUP !!MEMBERTYPE_Properties_XObjectPoolClass><TITLE TransactionID>
	':����������:	���������� ������������� ������� ����������.
	':����������:	�������� ������ ��� ������.
	':���������:	Public Property Get TransactionID [As String]
	Public Property Get TransactionID
		TransactionID = m_sTransactionID
	End Property


	'---------------------------------------------------------------------------
	':����������:	���������� "������������" ���� �����.
	Private Property Get BackStack
		If IsEmpty( m_oBackStack) Then
			Set m_oBackStack = new StackClass
		End If
		Set BackStack = m_oBackStack
	End Property


	'---------------------------------------------------------------------------
	':����������:	�������������� ���� m_oXmlPendingActions.
	Private Sub initXmlPendingActionsElement()
		Set m_oXmlPendingActions = m_oXmlObjectPool.selectSingleNode("x-pending-actions")
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.BeginTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE BeginTransaction>
	':����������:	�������� ����� ���������� ����������.
	':���������:	
	'	bAggregation - [in] ������� ���������; �����:
	'		* True - ����� ���������� ���������� � ������� ���������� ����������, 
	'		* False - ���������� ��������� ���������� ���������� ����������.
	':����������:
	'	<B>��������!</B> ��� ������, ���������� �� ������ BeginTransaction, � 
	'	�������� ��������� ���������� <B>�������������</B>. ��� ����, ����� ������ 
	'	XObjectPoolClass.CommitTransaction ������ �������� <B>�������������</B>, 
	'	� � ������ ������ XObjectPoolClass.RollbackTransaction - <B>�����������</B>.
	':��. �����:	
	'	XObjectPoolClass.CommitTransaction, XObjectPoolClass.RollbackTransaction,<P/>
	'	<LINK oe-2-3-2, �������������� ������/>
	':���������:	
	'	Public Sub BeginTransaction( bAggregation [As Boolean] )
	Public Sub BeginTransaction(bAggregation)
		Dim oPoolState		' As XObjectPoolStateClass - ������� ��������� ����

		' ������� ������� ��������� ���� � ����
		Set oPoolState = New XObjectPoolStateClass
		oPoolState.TransactionID = m_sTransactionID
		Set oPoolState.XmlObjectPool = m_oXmlObjectPool
		m_oPoolTransactionLog.Push oPoolState
		Set m_oXmlObjectPool = m_oXmlObjectPool.cloneNode(true)
		initXmlPendingActionsElement
		If Not bAggregation Then
			m_sTransactionID = CreateGuid
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CommitTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CommitTransaction>
	':����������:	��������� ������� ���������� ����������.
	':����������:
	'	<B>��������!</B> ��� ������, ���������� �� ������ XObjectPoolClass.BeginTransaction, 
	'	� �������� ��������� � ����� ������ XObjectPoolClass.CommitTransaction 
	'	���������� <B>�������������</B>!
	':��. �����:	
	'	XObjectPoolClass.BeginTransaction, XObjectPoolClass.RollbackTransaction,<P/>
	'	<LINK oe-2-3-2, �������������� ������/>
	':���������:	
	'	Public Sub CommitTransaction()
	Public Sub CommitTransaction
		Dim oPoolState		' As XObjectPoolStateClass - ������� ��������� ����

		If m_oPoolTransactionLog.Length>0 Then
			' �������� ���������� ��������� ����
			Set oPoolState = m_oPoolTransactionLog.Pop
			If m_sTransactionID = oPoolState.TransactionID Then
			Else
				' TODO:
				' ���� ������� ���������� - ���������� (� ���, ����� ��������), ��
				' ��� ������� �� �������� ����, ���������� � ������� ����������, ���� ������� �� ���� ����� � �����
			End If
		Else
			' ��� �������������� ������������ ������ ��-�� �������������� ������� BeginTransaction � Commit/Rollback ��������
			Err.Raise -1, "XObjectPoolClass::CommitTransaction", "����� CommitTransaction ��� ���������������� BeginTransaction"
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RollbackTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RollbackTransaction>
	':����������:	
	'	���������� ������� ���������� ����������, ��������� ������ ����
	'	� ���������, ����������������� ������ ����������.
	':����������:
	'	<B>��������!</B> ��� ������, ���������� �� ������ XObjectPoolClass.BeginTransaction, 
	'	����� ������ XObjectPoolClass.RollbackTransaction �������� <B>�����������</B>!
	':��. �����:	
	'	XObjectPoolClass.BeginTransaction, XObjectPoolClass.CommitTransaction,<P/>
	'	<LINK oe-2-3-2, �������������� ������/>
	':���������:	
	'	Public Sub RollbackTransaction()
	Public Sub RollbackTransaction
		Dim oPoolState		' As XObjectPoolStateClass - ������� ��������� ����

		If m_oPoolTransactionLog.Length>0 Then
			' �������� � ����������� ���������� ��������� ����
			Set oPoolState = m_oPoolTransactionLog.Pop
			Set m_oXmlObjectPool = oPoolState.XmlObjectPool
			initXmlPendingActionsElement
			m_sTransactionID = oPoolState.TransactionID
		Else
			' ��� �������������� ������������ ������ ��-�� �������������� ������� BeginTransaction � Commit/Rollback ��������
			Err.Raise -1, "XObjectPoolClass::CommitTransaction", "����� RollbackTransaction ��� ���������������� BeginTransaction"
		End If
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetChanges
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetChanges>
	':����������:	
	'	���������� ��������� � XML-������� �����, ��������� � ���������� ��������.
	':���������:
	'	��������� XML-������, ��� ��������� IXMLDOMNodeList.
	':����������:
	'	� ��������� ���������� ������ ��������, �������:
	'		* ��������������� � ������� ����������;
	'		* �������� ������ (XML-������ ������� �������� ��������� <B>new</B>);
	'		* �������� ���������� (XML-������ ������� �������� ��������� <B>delete</B>);
	'		* ���������� (������� <B>dirty</B> � ������� �������).
	':���������:
	'	Public Function GetChanges [As IXMLDOMNodeList]
	Public Function GetChanges
		Set GetChanges = m_oXmlObjectPool.selectNodes("*[@transaction-id='" & m_sTransactionID & "' and (@delete or @new or *[@dirty])]")
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Backup
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Backup>
	':����������:	��������� ������� ��������� ���� �� ���������� ����.
	':��. �����:	XObjectPoolClass.Undo, <LINK oe-2-3-2, �������������� ������/>
	':���������:	Public Sub Backup()
	Public Sub Backup
		BackStack.Push m_oXmlObjectPool.cloneNode( True ) 
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Undo
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Undo>
	':����������:	��������������� ��������� ����, ����������� ����� �� ����������
	'				����� ������� XObjectPoolClass.Backup.
	':��. �����:	XObjectPoolClass.Backup, <LINK oe-2-3-2, �������������� ������/>
	':���������:	Public Sub Undo()
	Public Sub Undo
		Set m_oXmlObjectPool = BackStack.Pop
		initXmlPendingActionsElement
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.Clear
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE Clear>
	':����������:	������� ��� ������� �� ����.
	':���������:	Public Sub Clear()
	Public Sub Clear
		m_oXmlObjectPool.selectNodes("*[local-name()!='x-pending-actions']").removeAll
	End Sub


	'===========================================================================
	' �������� ��������
		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.LoadXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE LoadXmlProperty>
	':����������:	
	'	��������� ������ ��������������� �������� XML-������� � �������.
	':���������:
	'	oXmlObject	- [in] ������ (IXMLDOMElement ��������� ���� �������); ����� 
	'					���� Nothing, ���� vProp - XML-�������� (IXMLDOMElement)
	'	vProp		- [in] �������� ������� (XmlDOMElement), ��� ������ � ������ 
	'					��������
	':���������:
	'	����������� XML-������ ��������, ��� ��������� IXMLDOMElement. ���� �������� 
	'	�� �������, ������������ Nothing.
	':��. �����:
	'	XObjectPoolClass.GetXmlProperty, XObjectPoolClass.GetPropertyValue,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:	
	'	Public Function LoadXmlProperty( 
	'		ByVal oXmlObject [As IXMLDOMElement], vProp [As Variant] 
	'	) [As IXMLDOMElement]
	Public Function LoadXmlProperty( ByVal oXmlObject, vProp )
		Dim sObjectType				' As String - ��� �������
		Dim sObjectID				' As String - ������������� �������
		Dim oXmlObjectFromPool		' As IXMLDOMElement - xml-������ �� ����
		Dim sPropertyName			' As String - ������������ ��������
		Dim oXmlProperty			' As IXMLDOMElement - ������������ ��������
		Dim oXmlPropertyFromServer	' As IXMLDOMElement - ��������, ��������� � �������
		Dim oXmlNode				' As IXMLDOMNode
		Dim aErr					' As Array - ������ ����� ������� Err
		
		Set LoadXmlProperty = Nothing
		' ������� ��� ��������
		If vbString = VarType( vProp) Then
			sPropertyName = vProp
		ElseIf 0 = StrComp( TypeName(vProp), "IXMLDOMElement", vbTextCompare) Then
			sPropertyName = vProp.nodeName
			Set oXmlObject = vProp.parentNode
		Else
			Err.Raise -1, "XObjectPoolClass::LoadXmlProperty", "�������� vProp ����������������� ����: " & TypeName(vPropName) & ". ������ ���� String ��� IXMLDOMElement"
		End If
		
		' ������� ��� � ID ��������������� �������
		sObjectID	= oXmlObject.getAttribute("oid")
		sObjectType = oXmlObject.tagName
		' ������ � �������� �������� �������� ��-��: 
		' ���� ������ ����������� � ����, �� � ������� �� ������ ����� � ������������ ��������� ���������
		Set oXmlObjectFromPool = GetXmlObject(sObjectType, sObjectID, sPropertyName)
		If oXmlObjectFromPool Is Nothing Then Exit Function
		Set oXmlProperty = oXmlObjectFromPool.selectSingleNode(sPropertyName) 
		If oXmlProperty Is Nothing Then Exit Function
		Set LoadXmlProperty = oXmlProperty
		
		If ("0" = oXmlProperty.getAttribute("loaded")) Then
			' ������� �������� � �������
			
			If Not GetEditorAnotherWindow Is Nothing Then _
				On Error Resume Next
			Set oXmlPropertyFromServer = X_LoadObjectPropertyFromServer(sObjectType, sObjectID, sPropertyName)
			If Not GetEditorAnotherWindow Is Nothing Then 
				' ���� ������� ���� ���������� �� ����, � ������� ��� ������ �������� ��������..
				aErr = Array(Err.number, Err.Source, Err.Description)
				On Error GoTo 0
				If X_WasErrorOccured Then
					' ��������� �������� ��������� ������ � ���� ��������� ���������
					With X_GetLastError
						GetEditorAnotherWindow.X_SetLastServerError .LastServerError, .ErrNumber, .ErrSource, .ErrDescription
					End With
					' � ������� ������ � ������� ����
					X_ClearLastServerError
				End If	
				If aErr(0)<>0 Then
					Err.Raise aErr(0), aErr(1), aErr(2)
				End If
			End If
			If oXmlPropertyFromServer Is Nothing Then Exit Function
			
			' �� ������ ������ ������� ��������..
			oXmlProperty.selectNodes("*|@loaded").removeAll
			' ���� ������������ ��-�� - ���������, �� ��������� ��� ������� �� ���� � ���, 
			' � � ����� �������� ������� ��������, �����, ���� ��������� ��� ��������, �� ������ ��������� ����������
			If X_GetPropertyMD(oXmlProperty).getAttribute("vt") = "object" Then
				' �� ���� �������� � ��������
				InsertXmlObjectsFromPropIntoPool oXmlPropertyFromServer
				' ������ � oXmlPropertyFromServer �������� ���� �������� - ��������� �� � ������������ ��������
				For Each oXmlNode In oXmlPropertyFromServer.selectNodes("*[@oid]")
					' � ��������� �������� � ������������ �������� ������� � ����
					oXmlProperty.appendChild oXmlNode
				Next
				applyPendingActions oXmlObjectFromPool.tagName, oXmlObjectFromPool.getAttribute("oid"), oXmlProperty
			Else
				' ����������� ��-��, ��� ����� ���� ������ ��������� ��� �������� 
				' (��� ������ ������� ��������� ��-�� ������� ����������)
				oXmlProperty.text = oXmlPropertyFromServer.text
			End If
		End If		
	End Function
	
		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlProperty>
	':����������:	�������� ���� ��������, ��������� OPath-�����.
	':���������:	
	'	oXmlObject	- [in] ������ (IXMLDOMElement ��������� ���� �������)
	'	sOPath		- [in] ������ � �������� �������, � ����� ������� ���� ��������� 
	'					�������, ������������ �������� "."
	':���������:
	'	XML-������ ��������, ��� ��������� IXMLDOMElement. ���� ��������, ��������� 
	'	� �������, ���, �� ������������ Nothing.
	':��. �����:
	'	XObjectPoolClass.LoadXmlProperty, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function GetXmlProperty( 
	'		ByVal oXmlObject [As IXMLDOMElement], sOPath [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlProperty(ByVal oXmlObject, sOPath)
		Dim aProps		' As Array - ������ ���� ������� � ����
		Dim nUpper		' As Long - ������������ ������ � ������� ���� �������
		Dim oProp		' As IXMLDOMElement - ������� �������� c������� 
		Dim sPreload	' As String - ������� ������� ��� ��������� ��� ��������� ������� � �������
		Dim i, j
		
		Set GetXmlProperty = Nothing
		aProps = Split( sOPath, ".")
		nUpper = UBound( aProps)
		For i = 0 to nUpper
			' ��������� �� ����� ��������� �������
			Select Case aProps(i)
				Case "ObjectID"
					Set GetXmlProperty = oXmlObject.selectSingleNode("@oid")
					GetXmlProperty.dataType = "string"
					Exit Function
				Case "ts"
					Set GetXmlProperty = oXmlObject.selectSingleNode("@ts")
					If Not Nothing Is GetXmlProperty Then GetXmlProperty.dataType = "string"
					Exit Function
			End Select
			' ��������������, ��� ������ �������� � ����
			sPreload = Null
			For j = i To nUpper
				If Not IsNull(sPreload) Then sPreload = sPreload & "."
				sPreload = sPreload & aProps(j)
			Next
			' ���� ������� ��� � ����, �� ����� ������ ������ ������� GetObject � ���������� ������ ���� ��������� ��-�
			Set oXmlObject = GetXmlObjectByXmlElement(oXmlObject, sPreload)
			If oXmlObject Is Nothing Then Exit Function
			' �������� �������� ��������
			Set oProp = LoadXmlProperty( oXmlObject, aProps(i) )
			If i = nUpper Then
				' ����� �� ��������
				Set GetXmlProperty = oProp
			Else
				' ���� �������� ���, ������ Nothing
				If oProp Is Nothing Then Exit Function
				Set oXmlObject = oProp.firstChild
				' ���� � ��� ���� ��������, ��������� � ����, �� �� ���������� (������� ��� ��� ��������� ��������, ���� �����������)
				If oXmlObject Is Nothing Then 
					' ������ ��������� �� ��������������� ��������
					Exit Function
				End If
			End If
		Next
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetPropertyValue>
	':����������:	
	'	�������� �������� ���������� ������������ ��������, ��������� OPath-�����.
	':���������:	
	'	oXmlObject	- [in] ������ (IXMLDOMElement ��������� ���� �������)
	'	sOPath		- [in] ������ � �������� �������, � ����� ������� ���� ��������� 
	'					�������, ������������ �������� ".", ������������� ������ 
	'					���������� ������������ ��������
	':���������:
	'	�������������� �������� ���������� ������������ �������� ��� Null, ���� 
	'	�������� �������� �� ������ (�������� "������").<P/>
	'	� ��� ������, ���� sOPath ������������� ������ ���������� �������� (���� 
	'	��������, ��� ��� ������������ �������������), ����� ���������� Null ��� 
	'	��������������� ("������") �������, � ������ "[object]" ��� �������������.
	':��. �����:
	'	XObjectPoolClass.LoadXmlProperty, XObjectPoolClass.GetXmlProperty, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function GetPropertyValue( 
	'		oXmlObjectX [As IXMLDOMElement], sOPath [As String]
	'	) [As Variant]
	Public Function GetPropertyValue(oXmlObjectX, sOPath)
		Dim oProp	' �������� (XMLDOMElement)
		GetPropertyValue = Null
		Set oProp = GetXmlProperty(oXmlObjectX, sOPath)
		If oProp Is Nothing Then Exit Function
		If Not Nothing Is oProp Then
			If IsNull( oProp.dataType) Then
				' �� ��� ��������� ��������� ��������
				If Not oProp.firstChild Is Nothing Then
					GetPropertyValue = "[object]"
				Else
					' � ������ ���������������� ���������� �������� ������ Null
					Exit Function
				End If
			Else
				' �� ��� ��������� �������� ���������� ��������
				GetPropertyValue = oProp.nodeTypedValue
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	':����������:	���������� ������ �� ���� ����������� ���������.
	':����������:	������ ��� ��������� � ���� �� � ExecuteStatement (��. ���. 149911)
	'				�� ��������������� ������ �����!!!
	Private Function pool()
		Set pool = Me
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.ExecuteStatement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE ExecuteStatement>
	':����������:	
	'	��������� ��������� VBScript, � �������������� ������������ � ��������� 
	'	������ �� �������� ������� ������� (��. ���������).
	':���������:
	'	oXmlObject - [in] ������ (XMLDOMElement ��������� ���� �������)
	'	sStmt - [in] ������ � ����������� ���������� (��. ���������)
	':���������:
	'	���������� ����������� �������� ���������.
	':����������:
	'	������ � ���������� VBScript ����� �������� ����������� ���� 
	'	<B>item.<I>PropName1</I>{<I>.PropNameN</I>}</B>, ��� <B>item</B> - ��������
	'	�� �����������, � <B>PropName1</B>, <B>PropNameN</B> - ������� ������������ 
	'	������� �������.<P/>
	'	����� ����������� ��������� VBScript ����� �������� ��� ����������� �� 
	'	�������� ��������������� �������, ���������� �� ������� ������������, ��������
	'	� �����������.
	':��. �����:
	'	XObjectPoolClass.GetPropertyValue,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function ExecuteStatement( 
	'		oXmlObject [As IXMLDOMElement], ByVal sStmt [As String]
	'	) [As Variant]
	Public Function ExecuteStatement( oXmlObject, ByVal sStmt)	' ��������! ��������� - �� ���������������!
		' ����� �������� ��������� ���� [��� ������, ����� ����, ���� � ������ _]item.[������������ ������������������ ����� ����, ���� � ������ _ . ]
		const SEARCH_PATTERN = "(\W|^)item\.(((\.|\w)+))"
		' �� ��������� ���� [��� ������, ����� ����, ���� � ������ _]X_GetPropValue(oXmlObject,"[������������ ������������������ ����� ����, ���� � ������ _ . ]")
		const REPLACE_PATTERN = "$1GetPropertyValue(oXmlObject, ""$3"")"
		Dim sPrepared	' ���������, �������������� � ����������...
		
		' �������� ������� ������
		ExecuteStatement = Null
		sStmt = Replace( XService.LineUpText( sStmt), "item()", "oXmlObject")
		if 0 = Len( sStmt) then exit function

		' �������������� ������ ����������� ��������� (�� �������������...)
		if not IsObject(m_oExecuteStatementRegExp) then
			' ������ ������
			set m_oExecuteStatementRegExp = new RegExp
			' ����� ������ ��� ���������
			m_oExecuteStatementRegExp.Global = true
			' ��� ����������� �� ��������
			m_oExecuteStatementRegExp.IgnoreCase = true
			' � �������� �����
			m_oExecuteStatementRegExp.Multiline=true
			' ������ ����� ��������� ���� [��� ������, ����� ����, ���� � ������ _]item.[������������ ������������������ ����� ����, ���� � ������ _ . ] 
			m_oExecuteStatementRegExp.Pattern = SEARCH_PATTERN 	
		end if
		
		' ��������� ������� � ����������������
		sPrepared = m_oExecuteStatementRegExp.Replace( sStmt , REPLACE_PATTERN)
		' ��������� ���������... 
		If Not GetEditorAnotherWindow Is Nothing Then
			ExecuteStatement = GetEditorAnotherWindow.X_EvaluateInWindow(Me, sPrepared, oXmlObject)
		Else
			ExecuteStatement = Eval( sPrepared)
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectsByOPath
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectsByOPath>
	':����������:	
	'	���������� ��������� ��������-�������� ���������� ��������, ��������� 
	'	OPath-�����.
	':���������:	
	'	oXmlObjectX	- [in] ������ (IXMLDOMElement ��������� ���� �������)
	'	sOPath		- [in] ������ � �������� �������, � ����� ������� ���� ��������� 
	'					�������, ������������ �������� ".", ������������� ������ 
	'					���������� ��������
	':���������:
	'	������ ���������� ��������, ��� ��������� IXMLDOMNodeList. ���� �������� 
	'	�� ������� ��� ������, ����� ���������� Nothing.
	':��. �����:
	'	XObjectPoolClass.GetXmlObjectByOPath, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������: 
	'	Public Function GetXmlObjectsByOPath(
	'		oXmlObjectX [As IXMLDOMElement], sOPath [As String]
	'	) [As IXMLDOMNodeList]
	Public Function GetXmlObjectsByOPath(oXmlObjectX, sOPath)
		Dim oProp	' �������� (XMLDOMElement)
		
		Set GetXmlObjectsByOPath = Nothing
		Set oProp = GetXmlProperty(oXmlObjectX, sOPath)
		If Not oProp Is Nothing Then
			If oProp.hasChildNodes Then
				Set GetXmlObjectsByOPath = GetXmlObjectsByXmlNodeList( oProp.childNodes, Null )
			End If
		End If
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectByOPath
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectByOPath>
	':����������:	
	'	���������� ������-�������� ���������� ��������, ��������� OPath-�����.
	':���������:	
	'	oXmlObject	- [in] ������ (IXMLDOMElement ��������� ���� �������)
	'	sOPath		- [in] ������ � �������� �������, � ����� ������� ���� ��������� 
	'					�������, ������������ �������� ".", ������������� ������ 
	'					���������� ��������
	':���������:
	'	������ ���������� ��������, ��� ��������� IXMLDOMElement. ���� �������� 
	'	�� ������� ��� ������, ����� ���������� Nothing. ���� �������� - ���������, 
	'	�� ����� ���������� ������ ������� ��������.
	':��. �����:
	'	XObjectPoolClass.GetXmlObjectsByOPath, XObjectPoolClass.GetPropertyValue, 
	'	XObjectPoolClass.GetXmlObject,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������: 
	'	Public Function GetXmlObjectByOPath( 
	'		oXmlObject [As IXMLDOMElement], sOPath [As String] 
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectByOPath(oXmlObject, sOPath)
		Dim oNodeList		' IXMLDOMNodeList
		
		Set GetXmlObjectByOPath = Nothing
		Set oNodeList = GetXmlObjectsByOPath(oXmlObject, sOPath)
		If Not oNodeList Is Nothing Then
			If oNodeList.length > 0 Then
				Set GetXmlObjectByOPath = oNodeList.item(0)
			End If
		End If
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.FindXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE FindXmlObject>
	':����������:	
	'	"�����" � ���� ������ �������, ��������� ����� � ���������������.
	':���������:
	'	sObjectType - [in] ��� �������
	'	sObjectID   - [in] ������������� �������
	':���������:
	'	���������� ������ � ���� �� XML-������ ������� � ��������� ����� � 
	'	���������������. Nothing - ���� ������ � ���� �����������.
	':��. �����:
	'	XObjectPoolClass.FindObjectByXmlElement
	':���������:
	'	Public Function FindXmlObject( 
	'		sObjectType [As String], sObjectID [As String] 
	'	) [As IXMLDOMElement]
	Public Function FindXmlObject(sObjectType, sObjectID)
		Set FindXmlObject = m_oXmlObjectPool.selectSingleNode(sObjectType & "[@oid='" & sObjectID & "']")
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.FindObjectByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE FindObjectByXmlElement>
	':����������:	
	'	"�����" � ���� ������ �������, ��������� ������� �� XML-������ �������.
	':���������:
	'	oXmlObjectRef - [in] XML-������ ������ ��� "��������" �������. 
	':���������:
	'	���������� ������ � ���� �� XML-������ �������. Nothing - ���� ������� 
	'	������ � ���� �����������.
	':��. �����:
	'	XObjectPoolClass.FindXmlObject
	':���������:
	'	Public Function FindObjectByXmlElement( 
	'		oXmlObjectRef [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function FindObjectByXmlElement(oXmlObjectRef)
		Set FindObjectByXmlElement = FindXmlObject(oXmlObjectRef.tagName, oXmlObjectRef.getAttribute("oid") )
	End Function
	
	
	'------------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObject>
	':����������:	
	'	���������� ������ �� ����. ���� ������ � ���� �����������, �� ����� 
	'	��������� ������ ������� � ���, ���������� �� � �������.
	':���������:	
	'	sObjectType - [in] ������������ ���� �������
	'	sObjectID	- [in] ������������� �������
	'	sPreloads	- [in] ������ ������������ ������� �������, ������������ 
	'					�� �������, � ������ ���� ������ ������� �����������
	':���������:
	'	XML-������ �������, ��� ��������� IXMLDOMElement.
	':��. �����:	
	'	XObjectPoolClass.GetXmlProperty,<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function GetXmlObject(
	'		sObjectType [As String],
	'		sObjectID [As String],
	'		sPreloads [As String]
	'	) [As IXMLDOMElement]
	Public Function GetXmlObject(sObjectType, sObjectID, sPreloads)
		Dim oXmlObject		' As IXMLDOMElement - ����������� Xml - ������
		Dim aErr			' As Array - ������ ����� ������� Err
		
		Set GetXmlObject = Nothing
		' �������� ������� ������� � ���� ��������
		If HasValue(sObjectID) Then
			Set oXmlObject = m_oXmlObjectPool.selectSingleNode(sObjectType & "[@oid='" & sObjectID & "']")
		Else
			Set oXmlObject = Nothing
		End If	
		If oXmlObject is Nothing Then
			' �� ����� - ������ � �������...
			' ������� ������ � �������
			
			If Not GetEditorAnotherWindow Is Nothing Then _
				On Error Resume Next
			Set oXmlObject = X_GetObjectFromServer( sObjectType, sObjectID, sPreloads)
			If Not GetEditorAnotherWindow Is Nothing Then 
				' ���� ������� ���� ���������� �� ����, � ������� ��� ������ �������� ��������..
				aErr = Array(Err.number, Err.Source, Err.Description)
				On Error GoTo 0
				If X_WasErrorOccured Then
					' ��������� �������� ��������� ������ � ���� ��������� ���������
					With X_GetLastError
						GetEditorAnotherWindow.X_SetLastServerError .LastServerError, .ErrNumber, .ErrSource, .ErrDescription
					End With
					' � ������� ������ � ������� ����
					X_ClearLastServerError
				End If	
				If aErr(0)<>0 Then
					Err.Raise aErr(0), aErr(1), aErr(2)
				End If
			End If
			If oXmlObject Is Nothing Then Exit Function
			Set oXmlObject = Internal_AppendXmlObjectTreeFromServer(oXmlObject)
		End If
		Set GetXmlObject = oXmlObject
	End Function
 
 
	'---------------------------------------------------------------------------
	':����������:	
	'	��������� � ��� ������ ��������, ���������� �� ������� GetObject.
	':���������:	
	'	oXmlObject - [in] ����������� ������, ��� ��������� IXMLDOMElement
	':����������:	
	'	� ���������� ������ oXmlObject ������������ ������ ������ XML-�������; ���� 
	'	�� � �������� �������� (��� ������ GetObject) ���� ������ ������������ 
	'	��������, �� oXmlObject ������������ "������" ��������.<P/>
	'	��������! ������ ����� �������� ���������� � ���� ���������� �� ������!
	Public Function Internal_AppendXmlObjectTreeFromServer(oXmlObject)
		Dim oProp			' As IXMLDOMElement - xml-�������� 

		With New GetObjectEventArgsClass
			Set .XmlObject = oXmlObject
			FireEventInEditor "GetObject", .Self() 
		End With
		' �������� ��� � ��� ��������
		' �����: ��������� ������ � ��� �� ������ InsertXmlObjectsFromPropIntoPool, 
		' ����� ��� �������� �������� �� ������������ ������� �� �������������� ����������  ������
		Set oXmlObject = m_oXmlObjectPool.appendChild(oXmlObject)
		' ������ � ������� ��� ������ � ������������ ��������� (���� ���� ������� ��������),
		' ������� ���� ��� ������� �������� �� ������������ ������� ����������� � ���, � � ��������� �������� ��������.
		For Each oProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
			InsertXmlObjectsFromPropIntoPool oProp
		Next
		' ��� ���� ��������� ������� �������� ���������� ��������
		applyPendingActionsForObject oXmlObject
		' � ��������� ������� ����� ���� ��������� ��������, ����������� �� ��������� �������
		For Each oProp In getScalarObjectPropsOfObject(oXmlObject, True)
			CheckPropForDeletedObjectRef oProp
		Next
		Set Internal_AppendXmlObjectTreeFromServer = oXmlObject
	End Function

	
	'---------------------------------------------------------------------------
	':����������:	
	'	��������������� �����: ��������� ������� �� ������������� � ������� 
	'	���������� �������� � ���.
	':���������:	oProp - [in] XML-��������, ��������� IXMLDOMElement
	Private Sub InsertXmlObjectsFromPropIntoPool(oProp)
		Dim oXmlObject			' As IXMLDOMElement - ������ � �������� oProp
		
		For Each oXmlObject In oProp.selectNodes("*[*]")
			InsertXmlObjectFromPropIntoPool oXmlObject, oProp
		Next
	End Sub


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.InsertXmlObjectFromPropIntoPool
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE InsertXmlObjectFromPropIntoPool>
	':����������:	
	'	��������������� �����. ��������� ������ �� ������������� � ������� 
	'	�������� � ���.
	':���������:	
	'	oXmlObject - [in] ������ � �������� oProp, ��������� IXMLDOMElement
	'	oProp - [in] XML-��������, ��������� IXMLDOMElement
	':����������:	
	'	� �������� ���������� ������ ����� ����������� ������������ ����������� �
	'	��� ����������� � ��� ������; ��� ������������� �������������� ����� 
	'	���������� ������� <B>GetObjectConflict</B>.
	':��. �����:
	'	XObjectPoolClass.GetObjectConflictEventArgsClass
	':���������:	
	'	Public Sub InsertXmlObjectFromPropIntoPool( 
	'		oXmlObject [As IXMLDOMElement], 
	'		oProp [As IXMLDOMElement] )
	Public Sub InsertXmlObjectFromPropIntoPool(oXmlObject, oProp)
		Dim oObjectInPool		' As IXMLDOMElement - ������ � ����
		Dim oChildProp			' As IXMLDOMElement - �������� ������� oXmlObject
			
		For Each oChildProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
			InsertXmlObjectsFromPropIntoPool oChildProp
		Next
		' � ��������� ������� ����� ���� ��������� ��������, ����������� �� ��������� �������
		For Each oChildProp In getScalarObjectPropsOfObject(oXmlObject, True)
			CheckPropForDeletedObjectRef oChildProp
		Next
		' ������ ������� ������ �� ������������ �������� � ����
		Set oObjectInPool = m_oXmlObjectPool.selectSingleNode(oXmlObject.tagName & "[@oid='" & oXmlObject.getAttribute("oid") & "']")
		If Not oObjectInPool Is Nothing Then
			' ������ ��� ���� � ����, �������� ��� ts
			If "" & oObjectInPool.getAttribute("ts") <> "" & oXmlObject.getAttribute("ts") Then
				' ts ������
				With New GetObjectConflictEventArgsClass
					Set .LoadedProperty = oProp
					Set .ObjectInPool = oObjectInPool
					Set .ObjectFromServer = oXmlObject
					FireEventInEditor "GetObjectConflict", .Self()
				End With
			Else
				' ts ���������, �� ������ � ���� ������� ��� ��������� - ������ �� ���� ������ �� ������������� ��������
				If Not IsNull(oObjectInPool.getAttribute("delete")) Then
					' �������� RemoveRelation(Nothing, oProp, oXmlObject) ����� ��� ����������, �.�. ������� �������� �������� � ����������� ������� �� ����
					oProp.removeChild oXmlObject
				End If
			End If
		Else
			' ������� ��� � ���� - �������
			m_oXmlObjectPool.appendChild oXmlObject.cloneNode(true)
		End If	
		' ������� ������-�������� � �������� �� ��� ��������, ���� ����� �� ������� ������
		If oXmlObject.parentNode Is oProp Then
			oProp.ReplaceChild X_CreateStubFromXmlObject(oXmlObject), oXmlObject
		End If
	End Sub


	'---------------------------------------------------------------------------
	':����������:	
	'	��������� ���������� �� � �������� �������� ������ (������) �� ��������� 
	'	������. ���� ����� ������ ����������, �� �������� ���������, ��� ���� 
	'	��������� ������� loaded.
	':���������:
	'	oProp - [in] ����������� ��������
	':����������:
	'	������ ���������� ������ ��� ��������� ��������� �������.
	'	���������� �����.
	Private Sub CheckPropForDeletedObjectRef( oProp )
		Dim oObject		' ������-�������� ��������
		Set oObject = oProp.firstChild
		If oObject Is Nothing Then Exit Sub
		If Not m_oXmlObjectPool.selectSingleNode(oObject.tagName & "[@delete and @oid='" & oObject.getAttribute("oid") & "']") Is Nothing Then
			oProp.removeChild oObject
			SetXmlPropertyDirty oProp
		End If
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectByXmlElement
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectByXmlElement>
	':����������:	
	'	���������� ������, �������� XML-������� (� �.�. � ���������), �� ����.
	':���������:
	'	oXmlObjectElement - [in] XML-������ �������; �������� - ��������
	'	sPreloads - [in] ������ ������������ ������� �������, ������������ 
	'					�� �������, � ������ ����� ������ ������� �����������
	':���������:
	'	XML-������ �������, ��� ��������� IXMLDOMElement.
	':����������:
	'	���� ������ ����������� � ����, �� ����� ��������� ������ ������� � ���, 
	'	���������� �� � �������.
	':��. �����:
	'	XObjectPoolClass.GetXmlObject, XObjectPoolClass.GetXmlObjectsByXmlNodeList<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function GetXmlObjectByXmlElement(
	'		oXmlObjectElement [As IXMLDOMElement],
	'		sPreloads [As String]
	'	) [As IXMLDOMElement]
	Public Function GetXmlObjectByXmlElement(oXmlObjectElement, sPreloads)
		Set GetXmlObjectByXmlElement = GetXmlObject(oXmlObjectElement.tagName, oXmlObjectElement.getAttribute("oid"), sPreloads)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetXmlObjectsByXmlNodeList
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetXmlObjectsByXmlNodeList>
	':����������:	���������� ��������� �������� �� ���� �� ��������� ��������.
	':���������:
	'	oXmlNodeList - [in] ������ XML-�������� ��� ��������, ��� ��������� XMLDOMNodeList
	'	sPreloads - [in] ������ ������������ �������, ������������ �� �������, 
	'				� ������ ����� ������ �������� �����������
	':���������:
	'	��������� XML-������ �������� � ����, ��� ��������� IXMLDOMNodeList.
	':����������:
	'	������ ������-�������� �����������, ���� �� ����������� � ����.
	':��. �����:
	'	XObjectPoolClass.GetXmlObject, XObjectPoolClass.GetXmlObjectByXmlElement<P/>
	'	<LINK oe-2-3-1, ����������� ���������������� ������� � XML-��������/>
	':���������:
	'	Public Function GetXmlObjectsByXmlNodeList(
	'		oXmlNodeList [As XMLDOMNodeList], 
	'		sPreloads [As String]
	'	) [As IXMLDOMNodeList]
	Public Function GetXmlObjectsByXmlNodeList(oXmlNodeList, sPreloads)
		Dim sXPath		' xpath-������
		Dim oNode		' As IXMLDOMNode
		
		For Each oNode In oXmlNodeList
			' ������� ������ � ��� �� �������� (���� ��� ��� ��� ���)
			GetXmlObjectByXmlElement oNode, sPreloads
			If Len(sXPath) > 0 Then sXPath = sXPath & " | "
			sXPath = sXPath & oNode.tagName & "[@oid='" & oNode.getAttribute("oid") & "']"
		Next
		If IsEmpty(sXPath) Then
			' xpath-������, ������� �������� ������ ������ ������
			sXPath = "dummy[@oid='-1']"
		End If
		Set GetXmlObjectsByXmlNodeList = m_oXmlObjectPool.selectNodes(sXPath)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CreateXmlObjectInPool
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CreateXmlObjectInPool>
	':����������:	
	'	������� ����� ������ � �������� ��� � ���, ������� � ������� ����������.
	':���������:
	'	sObjectType - [in] ������������ ���� ������������ �������
	':���������:
	'	XML-������, ��������� � ����, ��� ��������� IXMLDOMElement.
	':���������:
	'	Public Function CreateXmlObjectInPool( sObjectType [As String] ) [As IXMLDOMElement]
	Public Function CreateXmlObjectInPool(sObjectType)
		Set CreateXmlObjectInPool = GetXmlObject(sObjectType, Null, Null)
		CreateXmlObjectInPool.SetAttribute "transaction-id", m_sTransactionID
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AppendXmlObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AppendXmlObject>
	':����������:	��������� ���������� ������ � ���. 
	':���������:	
	'	oXmlObject - [in] �����������  ������, ��������� IXMLDOMElement
	':���������:
	'	������, ����������� � ���, ��������� IXMLDOMElement.
	':����������:	
	'	���� � ���� ������ ������� ��� ������������, �� ���������� �� �����������; 
	'	����� ���������� XML-������, �������������� � ����.
	':���������:
	'	Public Function AppendXmlObject( oXmlObject [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function AppendXmlObject(oXmlObject)
		Dim sObjectID
		Dim oObjectInPool
		Dim oProp			' As IXMLDOMElement - xml-�������� 
		
		sObjectID = oXmlObject.getAttribute("oid")
		If IsNull(sObjectID) Then Err.Raise -1, "XObjectPoolClass::AppendXmlObject", "�� ����� ������������� �������"
		Set oObjectInPool = m_oXmlObjectPool.selectSingleNode(oXmlObject.tagName & "[@oid='" & sObjectID & "']")
		If oObjectInPool Is Nothing Then
			Set oObjectInPool = m_oXmlObjectPool.appendChild( oXmlObject)
			' ������ ����� �������� � ������������ ���������,
			' ������� ���� ��� ������� �������� �� ������������ ������� ����������� � ���, � � ��������� �������� ��������.
			For Each oProp In oXmlObject.selectNodes("*[not(@loaded)][*[@oid and *]]")
				InsertXmlObjectsFromPropIntoPool oProp
			Next
			' ��� ���� ��������� ������� �������� ���������� ��������
			applyPendingActionsForObject oXmlObject
			' � ���������� ������� ����� ���� �������������� ��������� ��������, ����������� �� ��������� �������
			For Each oProp In getScalarObjectPropsOfObject(oXmlObject, True)
				CheckPropForDeletedObjectRef oProp
			Next
		End If
		Set AppendXmlObject = oObjectInPool
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.ReloadObject
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE ReloadObject>
	':����������:	������������� ������������� ������ ������� � �������.
	':���������:	oXmlObject - [in] XML-������ ��� ��������
	':��. �����:	XObjectPoolClass.GetXmlObject
	':���������:	Public Sub ReloadObject( oXmlObject [As IXMLDOMElement] )
	Public Sub ReloadObject( oXmlObject )
		Dim sObjectType
		Dim sObjectID
		
		sObjectType = oXmlObject.nodeName
		sObjectID	= oXmlObject.getAttribute("oid")
		' ������ ������ �� ����
		m_oXmlObjectPool.selectNodes(sObjectType & "[@oid='" & sObjectID & "']").removeAll
		' �������� � ��� � �������
		GetXmlObject sObjectType, sObjectID, Null
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetObjectPresentation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetObjectPresentation>
	':����������:	���������� ��������� ������������� �������.
	':���������:	oXmlObject - [in] XML-������ � ����
	':���������:	��������� ������������� �������.
	':����������:
	'	<B><I>��������� �������������</I></B> ������� - ��� ��������� ������, 
	'	��������������� ����������� ���������� �������.<P/>
	'	������������� ������� <I>�����������</I> �� ��������� ������ ������� � 
	'	VBScript-��������� ����������� ���������� �������������, ��������� 
	'	��������� <B>i:to-string</B> � ������������ ���� ������� � ����������. ���
	'	���������� ��������� ����������� ����� ExecuteStatement (��������������,
	'	��������� ����� �������� ����������� ���� item.PropNameN - ��. �������� 
	'	������ ExecuteStatement).<P/>
	'	���� ������� <B>i:to-string</B> �� �����, �� � �������� ���������� 
	'	������������� ����� ��������� ������ ���� <B>���</B>(<B>�������������</B>).
	':���������:	
	'	Public Function GetObjectPresentation( oXmlObject [As IXMLDOMElement] ) [As String]
	Public Function GetObjectPresentation(oXmlObject)
		Dim oTypeMD			' As IXMLDOMElement - ���������� ���� oXmlObject
		Dim oToStringMD		' As IXMLDOMElement - ������� i:to-string � ������������ ����
		Dim sToStringStmt	' As String - ��������� ��� ���������� ������������� �������
		
		' TODO! �������� ���������� �������.
		Set oTypeMD = X_GetTypeMD(oXmlObject.tagName)
		' ���� ��� �� ����� ������, ����� ������, ������� ����� �������, ��� oTypeMD ������ �� Nothing
		Set oToStringMD = oTypeMD.selectSingleNode("i:to-string")
		If oToStringMD Is Nothing Then
			' ���� ��� ���� �� ������ ����������� ������������� (i:to-string), �� ��������� ���������: ���(�������������)
			sToStringStmt = "item().nodeName & ""("" & item.ObjectID & "")"""
		Else
			sToStringStmt = oToStringMD.text
		End If
		' �������� ������������� �������
		GetObjectPresentation = ExecuteStatement(oXmlObject, sToStringStmt)
	End Function
	
	'===========================================================================
	' ��������� �������� �������

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReverseXmlProperty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReverseXmlProperty>
	':����������:	
	'	���������� XML-�������� ������� oXmlObject, ���������� �������� ���������
	'	�������� oParentXmlProperty.
	':���������:
	'	oXmlObject - [in] ������ (IXMLDOMElement ��������� ���� �������)
	'	oParentXmlProperty - [in] �������� �������
	':���������:
	'	�������� ��������, ��� ��������� IXMLDOMElement. ���� ��������� ��������
	'	��� ��������� oParentXmlProperty ���, �� ����� ���������� Nothing.
	':��. �����:
	'	XObjectPoolClass.GetReversePropertyMD,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� ��������/>
	':���������:
	'	Public Function GetReverseXmlProperty(
	'		oXmlObject [As IXMLDOMElement], oParentXmlProperty [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function GetReverseXmlProperty(oXmlObject, oParentXmlProperty)
		Dim oReversePropMD		' As IXMLDOMElement - ���������� ��������� ��������
		
		Set GetReverseXmlProperty = Nothing
		' ������� ���������� ��������, ����������� "��������" �������� oParentXmlProperty
		Set oReversePropMD =  GetReversePropertyMD(oParentXmlProperty)
		If Not oReversePropMD Is Nothing Then
			' ��������, ��� ���������� ������ ������������� ���� ����, ������� ������� ���������, ��� ���������� �� ��������
			If oReversePropMD.parentNode.getAttribute("n") <> oXmlObject.nodeName Then
				Err.Raise -1, "XObjectPoolClass::GetReverseXmlProperty", "��� ������� oXmlObject �� ��������� � �����, ������� �������� ��������, ���������� �������� �������� oParentXmlProperty"
			End If
			' ������� ��� xml-��������
			Set GetReverseXmlProperty = oXmlObject.selectSingleNode( oReversePropMD.getAttribute("n") )
		End If
	End Function

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReversePropertyMD
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReversePropertyMD>
	':����������:	
	'	���������� ������������ �������� �������, ����������� �������� ��������� 
	'	�������� oParentXmlProperty.
	':���������:	
	'	oParentXmlProperty - [in] XML-��������, ��������� IXMLDOMElement
	':���������:
	'	������������ �������� (���� <B>ds:type/ds:prop</B>) ��������, ����������� 
	'	�������� ��������� �������� oParentXmlProperty, ��� ��������� IXMLDOMElemet.
	'	���� ��� �������� �������� �� ����������, ����� ���������� Nothing.
	':��. �����:
	'	XObjectPoolClass.GetReverseMDProp, XObjectPoolClass.GetReverseXmlProperty,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� ��������/>
	':���������:
	'	Public Function GetReversePropertyMD( oParentXmlProperty [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function GetReversePropertyMD(oParentXmlProperty)
		Set GetReversePropertyMD = GetReverseMDProp( X_GetPropertyMD(oParentXmlProperty) )
	End Function
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.GetReverseMDProp
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE GetReverseMDProp>
	':����������:	
	'	���������� ������������ �������� �������, ����������� �������� ��������� 
	'	������������ �������� oParentPropMD.
	':���������:	
	'	oParentPropMD - [in] ������������ ��������� ��������, ��������� IXMLDOMElement
	':���������:
	'	������������ �������� (���� <B>ds:type/ds:prop</B>) ��������, ����������� 
	'	�������� ��������� �������� oParentPropMD, ��� ��������� IXMLDOMElemet.
	'	���� ��� �������� �������� �� ����������, ����� ���������� Nothing.
	':��. �����:
	'	XObjectPoolClass.GetReversePropertyMD, XObjectPoolClass.GetReverseXmlProperty,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� ��������/>
	':���������:
	'	Public Function GetReverseMDProp( oParentPropMD [As IXMLDOMElement] ) [As IXMLDOMElement]
	Public Function GetReverseMDProp(oParentPropMD)
		Dim sPropName			' As String - ������������ �������� 
		Dim sOwnerTypeName		' As String - ������������ �������-��������� ��������
		Dim sXPath				' As String - XPath
		Dim sReversePropOwnerTypeName	' As String - ������������ ���� ������� ��������� ��������� ��������
		
		sPropName = oParentPropMD.getAttribute("n")
		sOwnerTypeName = oParentPropMD.parentNode.getAttribute("n")
		sReversePropOwnerTypeName = oParentPropMD.getAttribute("ot")
		If IsNull(sReversePropOwnerTypeName) Then Err.Raise -1, "GetReverseMDProp", "����� ������ ���������� ������ ��� ��������� �������"
		Select Case oParentPropMD.getAttribute("cp")
			Case "collection"
				sXPath = "ds:prop[@cp='collection-membership' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "collection-membership"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='collection' and @ot='" & sOwnerTypeName & "']"
			Case "link", "link-scalar"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='scalar' and @vt='object' and @ot='" & sOwnerTypeName & "']"
			Case "scalar"
				sXPath = "ds:prop[(@cp='link' or @cp='link-scalar') and @vt='object' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "array"
				sXPath = "ds:prop[@cp='array-membership' and @built-on='" & sPropName & "' and @ot='" & sOwnerTypeName & "']"
			Case "array-membership"
				sXPath = "ds:prop[@n='" & oParentPropMD.getAttribute("built-on") & "' and @cp='array' and @ot='" & sOwnerTypeName & "']"
		End Select
		If IsEmpty(sXPath) Then
			Set GetReverseMDProp = Nothing
		Else
			Set GetReverseMDProp = X_GetTypeMD(sReversePropOwnerTypeName).selectSingleNode(sXPath)
		End If
	End Function
	
	
	'===========================================================================
	' ��������� ��������

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.SetXmlPropertyDirty
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE SetXmlPropertyDirty>
	':����������:	
	'	�������� �������� ��� ����������������. ������-�������� �������� 
	'	���������� � �����������.
	':���������:
	'	oXmlProperty - [in] ��������, ���������� ��� ����������������
	':��. �����:
	'	XObjectPoolClass.EnlistXmlObjectIntoTransaction
	':���������:
	'	Public Sub SetXmlPropertyDirty( oXmlProperty [As IXMLDOMElement] )
	Public Sub SetXmlPropertyDirty(oXmlProperty)
		oXmlProperty.SetAttribute "dirty", 1
		oXmlProperty.removeAttribute "loaded"
		oXmlProperty.ParentNode.SetAttribute "transaction-id", m_sTransactionID
	End Sub

	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.EnlistXmlObjectIntoTransaction
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE EnlistXmlObjectIntoTransaction>
	':����������:	�������� �������� XML-������ � ������� ����������.
	':���������:	oXmlObject - [in] XML-������, �������� ��������
	':��. �����:	XObjectPoolClass.SetXmlPropertyDirty
	':���������:
	'	Public Sub EnlistXmlObjectIntoTransaction( oXmlObject [As IXMLDOMElement] )
	Public Sub EnlistXmlObjectIntoTransaction(oXmlObject)
		GetXmlObjectByXmlElement(oXmlObject, Null).SetAttribute "transaction-id", m_sTransactionID
	End Sub
	

	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.IsSameProperties
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE IsSameProperties>
	':����������:	���������� ������ �� XML-�������� �������.
	':���������:	oProp1 - [in] ������ �� ������������ ��������, "�����" ��������
	'				oProp2 - [in] ������ �� ������������ ��������, "������" ��������
	':���������:	True, ���� oProp1 � oProp2 ���� ���� � �� �� �������� ������ 
	'				� ���� �� �������.
	':��. �����:	XObjectPoolClass.CheckReferences, <LINK oe-2-3-3-2, �������� �������/>
	':���������:	
	'	Public Function IsSameProperties( 
	'		oProp1 [As IXMLDOMElement], oProp2 [As IXMLDOMElement] 
	'	) [As Boolean]
	Public Function IsSameProperties(oProp1, oProp2)
		If oProp1 Is Nothing Or oProp2 Is Nothing Then
			IsSameProperties = false
		ElseIf oProp1 Is oProp2 Then
			IsSameProperties = true
		Else
			IsSameProperties = _
				oProp1.tagName & "@" & oProp1.parentNode.tagName & "(" & oProp1.parentNode.getAttribute("oid") & ")" = _
				oProp2.tagName & "@" & oProp2.parentNode.tagName & "(" & oProp2.parentNode.getAttribute("oid") & ")"
		End If		
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.CheckReferences
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE CheckReferences>
	':����������: 
	'	��� ��������� (����������) ������� ������� ��� ������ �� ����, � ����� 
	'	��� ������ �� �������, ����������� �� �������� ����� ������ � ���������
	'	���������.
	':���������:
	'	oXmlObject - [in] ��������� XML-������ (������ �� ������ � ����, 
	'			��������� IXMLDOMElement)
	'	oXmlProperty - [in] ���� ������, �� ������������ ������ � ������ 
	'			�������� �� �������� � ������ oNotNullReferences.
	'	oAllReferences - [in] ������ ���� ������ �� ��������� �������, ���
	'			��������� ������ ObjectArrayListClass
	'	oNotNullReferences - [in] ������ ������ �� ��������� ������� �� 
	'			������������ �������, ��� ��������� ObjectArrayListClass
	'	oObjectsToDelete - [in] ������ ������ �� ������� � ����, ������� 
	'			���� �������� ��� ���������; ��������� ObjectArrayListClass
	'	oXmlPropCascade - [in] �������� � ��������� ���������; �������� ������ 
	'			��� ����������� ��������, ��� ����������� �������. ������������ 
	'			��� ���������� �������� ������ �� ������� ���������� ������� �� 
	'			������� (����� ��������� ������), �� ������� ������� ������ 
	'			��������� ��������� � ��������� ���������. ���� �� ������������,
	'			�������� ��� Nothing.
	':����������:
	'	��� ��������� ������ ���������� � ������ oAllReferences.<P/>
	'	���� ������ ������������, �� ��� ���������� � ������ oNotNullReferences, 
	'	���������� - ������ �������� ���������� oXmlProperty.<P/>
	'	� oObjectsToDelete �������� ���������� ������, � ����� ��� �������, 
	'	����������� �� ���� �� ������� � ��������� ���������.
	':��. �����:
	'	XObjectPoolClass.MarkObjectAsDeleted, XObjectPoolClass.IsSameProperties,<P/>
	'	<LINK oe-2-3-3-2, �������� �������/>
	':���������:
	'	Public Sub CheckReferences(
	'		oXmlObject [As IXMLDOMElement], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		oAllReferences [As ObjectArrayListClass], 
	'		oNotNullReferences [As ObjectArrayListClass], 
	'		oObjectsToDelete [As ObjectArrayListClass], 
	'		oXmlPropCascade [As IXMLDOMElement] )
	Public Sub CheckReferences(oXmlObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, oXmlPropCascade)
		Dim oRef			' As XMLDOMElement - ������ �� ��������� ������, xml-������-�������� ��������
		Dim oProp			' As XMLDOMElement - �������� ���������� ������ oRef
		Dim oPropMD			' As XMLDOMElement - ���������� �������� oProp
		Dim bIsNotNull		' As Boolean - ������� ������������� ��������
		Dim sCapacity		' As String - ������� ��������
		Dim bIgnore			' As Boolean - ������� ������������� ������� ������

		If oObjectsToDelete.IsExists(oXmlObject) Then Exit Sub
		' ������� ���������� ������ � ������ ���������
		oObjectsToDelete.Add oXmlObject
		' ������� ��� ������ � ���� �� ��������� ������
		For Each oRef In m_oXmlObjectPool.selectNodes("*/*/" & oXmlObject.nodeName & "[@oid='" & oXmlObject.getAttribute("oid") & "']")
			Set oProp = oRef.parentNode
			Set oPropMD = X_GetPropertyMD(oProp)
			' ������������ ������ ����� ���� �� ����-��, ��� �� �������� ���������, ����� ���� ���������
			If Not oPropMD Is Nothing Then
				If Not IsNull(oPropMD.GetAttribute("delete-cascade")) Then
					' ������� ������ �� �������� � ��������� ��������� - �������� ���� ���������� ��� ��������� ���� ������
					CheckReferences oProp.parentNode, Nothing, oAllReferences, oNotNullReferences, oObjectsToDelete, oProp
				Else
					bIgnore = False
					If Not oXmlPropCascade Is Nothing Then
						' ���� �����, ������ ��� ��������� ���������� ��� ������������ �������.
						' ���� ������� ������ (oRef) �������� �������� �������� ��� oXmlPropCascade, �� �� ������� �� ���� ������
						bIgnore = IsSameProperties(GetReverseXmlProperty(oXmlObject, oProp), oXmlPropCascade)
					End If
					If Not bIgnore Then
						If Not IsSameProperties(oXmlProperty, oProp) Then
							' ������� ������, �������� �� ��������������:
							' ���� � �������� ����� ������� notnull, ������� ������ ������������
							bIsNotNull = Not IsNull(oProp.getAttribute(ATTR_NOTNULL))
							If Not bIsNotNull Then
								' ����� ��������� �������������� �� ������������
								sCapacity = oPropMD.getAttribute("cp")
								If sCapacity = "scalar" Then
									bIsNotNull = IsNull(oPropMD.getAttribute("maybenull"))
								ElseIf sCapacity = "array" Then
									' �������� � ������� ������ ������������ ��������
									bIsNotNull = True
								ElseIf sCapacity = "collection" Then
									' �������� � ��������� ������������ �������� ������ ���� ��� ��������� ��-��
									bIsNotNull = GetReverseMDProp(oPropMD) Is Nothing
								End If
							End If
							If bIsNotNull Then
								' ������ ������������.
								oNotNullReferences.Add oRef
							End If
						End If
						oAllReferences.Add oRef
					End If
				End If
			End If
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.MarkObjectAsDeleted
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE MarkObjectAsDeleted>
	':����������:	�������� �������, ��������� ����� � ���������������.
	':���������:	
	'	sObjectType - [in] ��� ���������� �������
	'	sObjectID - [in] ������������� ���������� �������
	'	oXmlProperty - [in] �������� ��������, ������ � ������� �� ������������ 
	'			��������; ���� �� ������������, �������� � Nothing
	'	bSilentMode - [in] ������� "������ ������"; ��������������� � ���������� 
	'			�������, ������������� ��� ����������� ��������� ��������
	'	oPropertiesToUpdate - [out] ��������� ������� (������ oXmlProperty), 
	'			������� ���������� �������� ��-�� ����, ��� �� ��� ���� ������� 
	'			������; ��������� ObjectArrayListClass
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
	'	(� ������ ���������� ��������).
	':��. �����:
	'	XObjectPoolClass.CheckReferences, XObjectPoolClass.IsSameProperties, 
	'	DeleteObjectConflictEventArgsClass,<P/>
	'	<LINK oe-2-3-3-2, �������� �������/>
	':���������:
	'	Public Function MarkObjectAsDeleted(
	'		sObjectType [As String], 
	'		sObjectID [As String], 
	'		oXmlProperty [As IXMLDOMElement], 
	'		bSilentMode [As Boolean], 
	'		ByRef oPropertiesToUpdate [As ObjectArrayListClass]
	'	) [As Boolean]
	Public Function MarkObjectAsDeleted(sObjectType, sObjectID, oXmlProperty, bSilentMode, ByRef oPropertiesToUpdate)
		Dim oXmlObject			' As XMLDOMElement - xml-������
		Dim oAllReferences		' As ObjectArrayListClass - ������ ���� ������ �� ��������� �������
		Dim oNotNullReferences	' As ObjectArrayListClass - ������ ������ �� ��������� ������� �� ������������ �������
		Dim oObjectsToDelete	' As ObjectArrayListClass - ������ ������ �� ������� � ����, ������� ���� �������� ��� ���������
		
		MarkObjectAsDeleted = False
		' ������������� � ���, ��� ������ � ����
		Set oXmlObject = GetXmlObject(sObjectType, sObjectID, Null)
		' oXmlObject Is Nothing ���� �� �����, �.�. ��� �������� � ������� ��������������� ������� ����� exception

		Set oAllReferences = New ObjectArrayListClass
		Set oNotNullReferences = New ObjectArrayListClass
		Set oObjectsToDelete = New ObjectArrayListClass
		CheckReferences oXmlObject, oXmlProperty, oAllReferences, oNotNullReferences, oObjectsToDelete, Nothing
		' ������ � ��� ���� ������ �������� ������� ���� �������, � ����� ������ ������ �� ���, ��� ����, ��� � ������������.
		' ���� ������ ������������ ������ �� ����, �� ������� ������
		If oNotNullReferences.Count>0 Or oAllReferences.Count>1 Then
			With New DeleteObjectConflictEventArgsClass
				.SilentMode = bSilentMode
				Set .SourceXmlProperty = oXmlProperty
				Set .ObjectsToDelete = oObjectsToDelete
				Set .NotNullReferences = oNotNullReferences
				Set .AllReferences = oAllReferences
				FireEventInEditor "DeleteObjectConflict", .Self()
				If Not .ReturnValue Then Exit Function
				Set oPropertiesToUpdate = .PropertiesToUpdate
			End With
		End If
		Internal_DoMarkObjectAsDeleted oAllReferences, oObjectsToDelete
		MarkObjectAsDeleted = True
	End Function

	
	'---------------------------------------------------------------------------
	':����������:
	'	��������� �������� ���� �������� �� ������ oObjectsToDelete � ������� 
	'	���� ������ �� ������ oAllReferences.
	':���������:
	'	oAllReferences - [in] ������ ���� ������ �� ��������� �������, ObjectArrayListClass 
	'	oObjectsToDelete - [in] ������ ������ �� ������� � ����, ������� ���� 
	'			�������� ��� ���������, ObjectArrayListClass
	':����������:
	'	XML-�������� � ����� ������� ������ ��������� �� �������/�������� �� ����!
	'	��������! ����� �������� ���������� � �� ������ ���������� ����!
	Public Sub Internal_DoMarkObjectAsDeleted(oAllReferences, oObjectsToDelete)
		Dim oRef				' As IXMLDOMELement - ���������
		Dim i
		Dim oXmlObject			' As XMLDOMElement - xml-������
		Dim oPropMD		' As IXMLDOMELement - ���������� �������� (ds:prop)
		
		' �� ���� ������� �� ��������� �������
		For i=0 To oAllReferences.Count-1
			' oRef - ������-�������� (��������) � xml-�������� ����������� �� ��������� ������, oRef.parentNode - xml-��������
			Set oRef = oAllReferences.GetAt(i)
			' TODO: ����� ��������� overhead ��������� � �������������� �������� ������� ���������� ������� � ������, ���� �� �����
			RemoveRelation Nothing, oRef.parentNode, oRef
		Next
		' �� ���� �������� �� ������ ���������
		For i=0 To oObjectsToDelete.Count-1
			Set oXmlObject = oObjectsToDelete.GetAt(i)
			' ���� ������ �� ��, �� ������� ��� ��������� � ������� � ����������, ����� ������ ������ �� ����
			If IsNull(oXmlObject.getAttribute("new")) Then
				oXmlObject.setAttribute "delete", "1"
				oXmlObject.setAttribute "transaction-id", m_sTransactionID
			Else
				' ����������: oObjectsToDelete �������� ������ �� xml-������� �� ����, ������� ��������� �������� ���������
				deleteNewObject oXmlObject
				
				' ��� ������ �������� �������������� ������� �� ���� ����������� ��������� �� ���� ������� ������.
				' ���� � ���� ���������� ������� ���� ��������� ������ � �������� ���������, 
				' �� ������ ��������� ������ �� �������� ������� 
				' (��� ����� ����, ���� �������� ������ �������� ������� ���������� ��-�� �������� ������������� �������)
				For Each oPropMD In X_GetTypeMD(oXmlObject.tagName).selectNodes("ds:prop[@delete-cascade='1']")
					Set oPropMD = GetReverseMDProp(oPropMD)
					If Not oPropMD Is Nothing Then
						m_oXmlObjectPool.selectNodes(_
							oPropMD.parentNode.getAttribute("n") & "/" & oPropMD.getAttribute("n") & "/" & _
								oXmlObject.tagName & "[@oid='" & oXmlObject.getAttribute("oid") & "']").removeAll
					End If
				Next
			End If
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	':����������:	������� ����� ������ �� ����
	':���������:	oXmlObject - [in] XML-������ � ����, IXMLDOMElement
	Private Sub deleteNewObject(oXmlObject)
		Dim sTypeName		' ��� ���������� �������
		Dim sObjectID		' ������������� ���������� �������
		
		' ������ ��� pending-actions, ��������� � ��������� ��������
		sTypeName = oXmlObject.tagName
		sObjectID = oXmlObject.getAttribute("oid")
		m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "'] | *[@ref-ot='" & sTypeName & "' and @ref-oid='" & sObjectID & "']").removeAll
		recalculateHasPendingActionsFlag
		
		m_oXmlObjectPool.removeChild oXmlObject
	End Sub
	
	'===========================================================================
	' �������� � ���������� ��������
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AddRelation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AddRelation>
	':����������:	
	'	��������� ������ �� ������ � ��������� ��������. ��� ���� ��������������� 
	'	������� �������������� �������� �������� � ������������ ������� (���� 
	'	����� ����������).
	':���������:
	'	oXmlObject	- [in] ������, � �������� �������� ��������� ������; ���� 
	'			�������� vPropName ����� ��� IXMLDOMElement, �� ������ �������� 
	'			����� ���� ����� � Nothing.
	'	vPropName	- [in] ��������, � ������� ��������� ������; ����� �������� 
	'			���� ������������ ��������, ���� ������ �� XML-���� ��������
	'	oRefObject	- [in] ����������� ������-�������� ��������; ����� ���� 
	'			"���������". ��������� IXMLDOMElement (��. ���������)
	':���������:
	'	����������� � �������� �������� �������-��������, ��������� IXMLDOMElement.<P/>
	'	���� � �������� ���������� ������ �� ������� ��������� ���������� 
	'	BusinessLogicException, ObjectNotFoundException ��� SecurityException,
	'	�� ����� ������ Nothing ��� ��������� ������ ������� ����������.
	':����������:
	'	��������� ������-�������� ����� ���� �� ��������� � ��� (���� ������ ��� 
	'	"��������"); ��� �� � ��� ����� ���� �� ���������� �������� ��������. 
	'	� ���� ������ ����� ������ � ������� <B>�� ���������</B>, � ��������� 
	'	������ <B>�� ���������� ��������</B>. ��� ������ ���������� ��������, 
	'	������� ���������� ��� ����������� �������� ������� / �������� (���� 
	'	����� ���������).<P/>
	'	<B>��������!</B> XML-������, ���������� ���������� oRefObject, �� �����������!
	':��. �����:
	'	XObjectPoolClass.AddRelationWithOrder, XObjectPoolClass.RemoveRelation,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� �������� />,
	'	<LINK oe-2-3-4, ���������� �������� />
	':���������:
	'	Public Function AddRelation(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function AddRelation(ByVal oXmlObject, vProp, ByVal oRefObject)
		Set AddRelation = AddRelationWithOrder( oXmlObject, vProp, oRefObject, Nothing )
	End Function


	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.AddRelationWithOrder
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE AddRelationWithOrder>
	':����������:	
	'	��������� ������ �� ������ � ��������� �������� � ������ �������. ��� 
	'	���� ��������������� ������� �������������� �������� �������� � ������������ 
	'	������� (���� ����� ����������).
	':���������:
	'	oXmlObject	- [in] ������, � �������� �������� ��������� ������; ���� 
	'			�������� vPropName ������ ��� IXMLDOMElement, �� ������ �������� 
	'			����� ���� ����� � Nothing.
	'	vPropName	- [in] ��������, � ������� ��������� ������; ����� �������� 
	'			���� ������������ ��������, ���� ������ �� XML-���� ��������
	'	oRefObject	- [in] ����������� ������-�������� ��������; ����� ���� 
	'			"���������". ��������� IXMLDOMElement (��. ���������)
	'	oBeforeObject - [in] ������-��������, ����� ������� ���������� ������� 
	'			�������-��������, ����������� oRefObject, ��������� IXMLDOMElement
	'			(�� ����������� - �������� �������-�������� ��������, ����������
	'			�������� ��� � �������������� ������� � ��������, ����� ������� 
	'			���� ���������� �������)
	':���������:
	'	����������� � �������� �������� �������-��������, ��������� IXMLDOMElement.<P/>
	'	���� � �������� ���������� ������ �� ������� ��������� ���������� 
	'	BusinessLogicException, ObjectNotFoundException ��� SecurityException,
	'	�� ����� ������ Nothing ��� ��������� ������ ������� ����������.
	':����������:
	'	��������� ������-�������� ����� ���� �� ��������� � ��� (���� ������ ��� 
	'	"��������"); ��� �� � ��� ����� ���� �� ���������� �������� ��������. 
	'	� ���� ������ ����� ������ � ������� <B>�� ���������</B>, � ��������� 
	'	������ <B>�� ���������� ��������</B>. ��� ������ ���������� ��������, 
	'	������� ���������� ��� ����������� �������� ������� / �������� (���� 
	'	����� ���������).<P/>
	'	������, ���� � ���� ������������ ������� ���� �������� ������������ ��� 
	'	�������� vProp, �� ������ ����������� � ��� (���� ��� ��� ��� �� ����).<P/> 
	'	<B>��������!</B> XML-������, ���������� ���������� oRefObject, �� �����������!
	':��. �����:
	'	XObjectPoolClass.AddRelation, XObjectPoolClass.RemoveRelation,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� �������� />,
	'	<LINK oe-2-3-4, ���������� �������� />
	':���������:
	'	Public Function AddRelationWithOrder(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement]
	'		oBeforeObject [As IXMLDOMElement]
	'	) [As IXMLDOMElement]
	Public Function AddRelationWithOrder(ByVal oXmlObject, vProp, ByVal oRefObject, oBeforeObject)
		Dim oPropMD			' As IXMLDOMElement - ���������� ��������������� ��������
		Dim oProp			' As IXMLDOMElement - �������������� ��������
		Dim oReversePropMD	' As IXMLDOMElement - ���������� ��������� ��������
		Dim oBeforeObjectLocal	' As IXMLDOMElement - ���� �������-�������� (������) � ��������, ����� ������� ���� �������� ���������� ������
		
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		Set oXmlObject = oProp.parentNode
		If IsNothing(oRefObject) Then
			Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "�� ����� ����������� ������-��������"
		End If
		Set oPropMD = X_GetPropertyMD(oProp)
		Select Case oPropMD.getAttribute("cp")
			Case "scalar"
				If Not oProp.firstChild Is Nothing Then
					Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "��������� ��������� �������� ������ ���� ������ ����� ������� ����� ������"
				End If
			Case "array-membership"
				Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "�������� ���� 'array-membership' �� ������ ����������������"
			Case Else
				' � ��������� �������� ��������, ��� ������������ ������� ��� � ��������
				If Not oProp.selectSingleNode("*[@oid='" & oRefObject.getAttribute("oid") & "']") Is Nothing Then
					Err.Raise -1, "XObjectPoolClass::AddRelationWithOrder", "����������� ������ ��� ���� � ��������"
				End If
		End Select
		' ������� ������ � ��������
		If oBeforeObject Is Nothing Then
			Set AddRelationWithOrder = oProp.appendChild( X_CreateStubFromXmlObject(oRefObject) )
		Else
			' ������� ���� ������� � �������� (�.�. ������), �.�. ��� ����� �������� ��� ������
			Set oBeforeObjectLocal = oProp.selectSingleNode(oBeforeObject.tagName & "[@oid='" & oBeforeObject.getAttribute("oid") & "']")
			Set AddRelationWithOrder = oProp.insertBefore( X_CreateStubFromXmlObject(oRefObject), oBeforeObjectLocal)
		End if
		' ������� �������� ��� ����������������
		SetXmlPropertyDirty oProp
		Set oReversePropMD = GetReversePropertyMD(oProp)
		If oReversePropMD Is Nothing Then Exit Function
		' ���� �����, ������ �������� �������� � ������� oRefObject ����������.
		
		' ������������ �������� ��������, ����, � ������, ���� ������ ��� �������� �� ���������, �������� ������ �� ���������� ��������
		addRefInternal oRefObject.tagName, oRefObject.getAttribute("oid"), oReversePropMD, X_CreateStubFromXmlObject(oXmlObject)
	End Function

		
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RemoveRelation
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RemoveRelation>
	':����������:	
	'	������� ������ �� ������ �� ���������� ��������. ��� ���� ��������������� 
	'	������� �������������� �������� �������� � �������-�������� (���� ����� 
	'	����������). ��� ����� ������-�������� (���� ��� ��� ����� �������� ��������) 
	'	������ ����������� � ���.
	':���������:
	'	oXmlObject	- [in] ������, �� �������� �������� ������� ������; ���� 
	'			�������� vPropName ����� ��� IXMLDOMElement, �� ���� ��������
	'			����� ���� ����� � Nothing.
	'	vPropName	- [in] ��������, �� �������� ������� ������; ����� �������� 
	'			���� ������������ ��������, ���� ������ �� XML-���� ��������
	'	oRefObject	- [in] ������-�������� ��������; ����� ���� "���������"
	':��. �����:
	'	XObjectPoolClass.RemoveAllRelations, XObjectPoolClass.AddRelation,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� �������� />,
	'	<LINK oe-2-3-4, ���������� �������� />
	':���������:
	'	Public Sub RemoveRelation(
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		vProp [As Variant], 
	'		ByVal oRefObject [As IXMLDOMElement] )
	Public Sub RemoveRelation(ByVal oXmlObject, vProp, ByVal oRefObject)
		Dim oProp			' As IXMLDOMElement - �������������� ��������
		
		If oRefObject Is Nothing Then Exit Sub
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		removeRelationFromLoadedProp oProp, oRefObject
	End Sub

	
	'---------------------------------------------------------------------------
	':����������:	"��������" ������� ������ �� ������ �� ���������� ��������. 
	':����������:
	'	� ������� �� RemoveRelation �� ���������� ��������, �.�. ��������������, 
	'	��� �������� ��� ����������. ��� ���� ��������������� ������� �������������� 
	'	�������� �������� � �������-��������(���� ��� ����). ��� ����� ������ 
	'	�������� (���� ��� ��� ����� �������� ��������) ������ ����������� � ���.
	':���������:
	'	oProp - [in] ��������, � ������� ��������� ������; ������ �� XML-���� ��������
	'	oRefObject - [in] ����������� ������-�������� ��������; ����� ���� "���������"
	Private Sub removeRelationFromLoadedProp(oProp, oRefObject)
		Dim oXmlObject 		' As IXMLDOMElement - ������, �� �������� �������� ������� ������
		Dim oPropMD			' As IXMLDOMElement - ���������� ��������������� ��������
		Dim oReversePropMD	' As IXMLDOMElement - ���������� ��������� ��������
		
		Set oXmlObject = oProp.parentNode
		' ���� �������� ���� array-membership, �� ��������
		Set oPropMD = X_GetPropertyMD(oProp)
		If oPropMD.getAttribute("cp") = "array-membership" Then
			Err.Raise -1, "XObjectPoolClass::RemoveRelation", "�������� ���� 'array-membership' �� ������ ����������������"
		End If
		' ������ � �������� ������-��������, ������ �� ������� ������ �������
		Set oRefObject = oProp.selectSingleNode(oRefObject.nodeName & "[@oid='" & oRefObject.getAttribute("oid") & "']")
		' �� �����? �� ��������
		If oRefObject Is Nothing Then Exit Sub
		' ������ ������
		oRefObject.parentNode.removeChild oRefObject
		' ������� �������� ��� ����������������
		SetXmlPropertyDirty oProp
		' ������� �������� ��������,���� ��� ����
		Set oReversePropMD = GetReversePropertyMD(oProp)
		If oReversePropMD Is Nothing Then Exit Sub
		
		' ������������ �������� ��������, ����, � ������, ���� ������ ��� �������� �� ���������, �������� ������ �� ���������� ��������
		removeRefInternal oRefObject.tagName, oRefObject.getAttribute("oid"), oReversePropMD, X_CreateStubFromXmlObject(oXmlObject)
	End Sub
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.RemoveAllRelations
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE RemoveAllRelations>
	':����������:	
	'	������� ��� ������ �� ���������� ��������. �������� RemoveRelation ��� 
	'	������� �������-��������.
	':���������:
	'	oXmlObject	- [in] ������, �� �������� �������� ������� ������; ���� 
	'			�������� vPropName ����� ��� IXMLDOMElement, �� ���� ��������
	'			����� ���� ����� � Nothing.
	'	vPropName	- [in] ��������, �� �������� ������� ������; ����� �������� 
	'			���� ������������ ��������, ���� ������ �� XML-���� ��������
	':��. �����:
	'	XObjectPoolClass.RemoveRelation, XObjectPoolClass.AddRelation,<P/>
	'	<LINK oe-2-3-3-1, �������� � ���������� �������� />,
	'	<LINK oe-2-3-4, ���������� �������� />
	':���������:
	'	Public Sub RemoveAllRelations( 
	'		ByVal oXmlObject [As IXMLDOMElement], 
	'		ByVal vProp [As Variant] )
	Public Sub RemoveAllRelations(ByVal oXmlObject, ByVal vProp )
		Dim oProp			' As IXMLDOMElement - �������������� ��������
		Dim oRefObject		' As IXMLDOMElement - xml-������-��������
		
		Set oProp = LoadXmlProperty( oXmlObject, vProp )
		For Each oRefObject In oProp.childNodes
			removeRelationFromLoadedProp oProp, oRefObject
		Next
	End Sub
	
	
	'---------------------------------------------------------------------------
	':����������:	��������� ������ � ��������.
	':���������:
	'	sTypeName - [in] ��� ������� ���������
	'	sObjectID - [in] ������������� ������� ���������
	'	oPropMD - [in] ���������� ��������
	'	oXmlObjectValue - [in] �������� �������-��������
	Private Sub addRefInternal(sTypeName, sObjectID, oPropMD, oXmlObjectValue)
		manageRefInternal sTypeName, sObjectID, oPropMD, "add", oXmlObjectValue
	End Sub

	
	'---------------------------------------------------------------------------
	':����������:	������� ������ �� ��������.
	':���������:
	'	sTypeName - [in] ��� ������� ���������
	'	sObjectID - [in] ������������� ������� ���������
	'	oPropMD - [in] ���������� ��������
	'	oXmlObjectValue - [in] �������� �������-��������
	Private Sub removeRefInternal(sTypeName, sObjectID, oPropMD, oXmlObjectValue)
		manageRefInternal sTypeName, sObjectID, oPropMD, "remove", oXmlObjectValue
	End Sub

	
	'---------------------------------------------------------------------------
	':����������:	��������� ��� ������� ������ �/�� ��������.
	':���������:
	'	sTypeName - [in] ��� ������� ���������
	'	sObjectID - [in] ������������� ������� ���������
	'	oPropMD - [in] ���������� ��������
	'	sAction - [in] ��������: add - ��������, remove - �������
	'	oXmlObjectValue - [in] �������� �������-��������
	Private Sub manageRefInternal(sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue)
		Dim oXmlObject	' As IXMLDOMElemnt - ������ �������� � ����
		Dim oProp		' As IXMLDOMElemnt - �������� ������� ���������
		
		' ���� �������� ���������, �� �������� "��������" (add) ���� ���������� ��� "��������" (set)
		If oPropMD.getAttribute("cp") = "scalar" And sAction = "add" Then
			sAction = "set"
		End If
		Set oXmlObject = m_oXmlObjectPool.selectSingleNode(sTypeName & "[@oid='" & sObjectID & "']")
		If oXmlObject Is Nothing Then
			' ������� �������� ����� ���������� �������� ��� � ���� - �������� "���������� ��������"
			addPendingAction sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue
		Else
			' ������ ����, ������� ��� ��������
			Set oProp = oXmlObject.selectSingleNode( oPropMD.getAttribute("n") )
			If oProp Is Nothing Then
				' ������ ����, �� �������� ��� - ������ �� ������
			ElseIf Not IsNull( oProp.getAttribute("loaded") ) Then
				' ������ ����, �������� ����, �� ��� �� ����������� (�������������, ��� ��������� ��������)
				addPendingAction sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue
			Else
				' �����, ��� ��������� � ����� ��������������:
				' ���� �������� ���������, �� ������� ��������. 
				If sAction = "set" Then
					oProp.selectNodes("*").removeAll
				End If
				If sAction = "add" Or sAction ="set" Then
					oProp.appendChild oXmlObjectValue
				ElseIf sAction = "remove" Then
					oProp.selectNodes(oXmlObjectValue.nodeName & "[@oid='" & oXmlObjectValue.getAttribute("oid") & "']").removeAll
				End If
			End If
		End If
	End Sub

	'===========================================================================
	' �������� � ����������� ����������
	
	'---------------------------------------------------------------------------
	' ��������� ������� ������� ���������� ��������
	Private Sub recalculateHasPendingActionsFlag
		m_bHasPendingActions = m_oXmlPendingActions.ChildNodes.Length > 0
	End Sub


	'---------------------------------------------------------------------------
	':����������:	������� � ���� ������ �� ���������� ��������.
	':���������:
	'	sTypeName - [in] ��� ������� ���������
	'	sObjectID - [in] ������������� ������� ���������
	'	oPropMD - [in] ���������� ��������
	'	sAction - [in] ��������: add - ��������, remove - �������
	'	oXmlObjectValue - [in] �������� �������-��������
	Private Sub addPendingAction(sTypeName, sObjectID, oPropMD, sAction, oXmlObjectValue)
		Dim sPropName			' As String - ������������ ��������
		Dim oXmlAction			' As IXMLDOMElement - xml-���� action - ������ ����������� ��������
		Dim sValueOID			' As String - ������������� �������-��������
		Dim sReverseActionXPath ' As String - ����� xpath  ������� � ������� �� ��������
		Dim oXmlReverseAction	' As IXMLDOMElement - xml-���� action - ������ ����������� ��������, ��������� ��������
		
		sPropName = oPropMD.getAttribute("n") 
		sValueOID = oXmlObjectValue.getAttribute("oid")
		If oPropMD.getAttribute("cp") = "scalar" Then
			m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & sPropName & "']").removeAll
		End If
		' ���������� ������������ ��������� ��������
		If sAction = "remove" Then
			sReverseActionXPath = "@action='add' or @action='set'"
		ElseIf sAction = "add" Or sAction = "set" Then
			sReverseActionXPath = "@action='remove'"
		End If
		Set oXmlReverseAction = m_oXmlPendingActions.selectSingleNode("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & sPropName & "' and " & sReverseActionXPath & " and @ref-oid='" & sValueOID & "']")
		If Not oXmlReverseAction Is Nothing Then
			' ������� �������� (����������) �������� ������������ ���������� (��������), 
			' ����� ������ ������ ���������� ��������, �.�. ��� �� ������ �� ������
			oXmlReverseAction.parentNode.removeChild oXmlReverseAction
			recalculateHasPendingActionsFlag
			Exit Sub
		End If
		' �������� ������ �� ���������� ��������
		Set oXmlAction = m_oXmlPendingActions.appendChild( m_oXmlPendingActions.ownerDocument.createElement("action") )
		oXmlAction.setAttribute "ot", sTypeName
		oXmlAction.setAttribute "oid", sObjectID
		oXmlAction.setAttribute "prop", sPropName
		oXmlAction.setAttribute "action", sAction
		oXmlAction.setAttribute "ref-ot", oXmlObjectValue.tagName
		oXmlAction.setAttribute "ref-oid", sValueOID
		
		recalculateHasPendingActionsFlag
	End Sub

	'---------------------------------------------------------------------------
	':����������:	
	'	��������� ���������� �������� ��� ��������� ��������� �������. 
	':���������:
	'	oXmlObject	- [in] As IXMLDOMElement - ������, ��� �������� ����������� ���������� �������� (���� ����)
	':����������:
	'	��� ������� ���������� �������� �������� applyPendingActions
	Private Sub applyPendingActionsForObject(oXmlObject)
		Dim oProp			' As IXMLDOMElement - xml-�������� 
		If Not m_bHasPendingActions Then Exit Sub
		For Each oProp In getObjectPropsOfObject(oXmlObject, False)
			applyPendingActions oXmlObject.tagName, oXmlObject.getAttribute("oid"), oProp
		Next
	End Sub
	
	'---------------------------------------------------------------------------
	':����������:	
	'	��������� ���������� �������� ��� ��������� �������� ��������� �������. 
	'	����� ���������� ������ ���������� �������� �� ���� ���������.
	':���������:
	'	sTypeName - [in] ��� ������� ���������
	'	sObjectID - [in] ������������� ������� ���������
	'	oProp - [in] �������� ������� ���������, ��� �������� ���� ��������� ���������� ��������
	Private Sub applyPendingActions(sTypeName, sObjectID, oProp)
		Dim oXmlActions		' As IXMLDOMNodeList - ��������� ������� ���������� �������� (���� action)
		Dim oXmlAction		' As IXMLDOMELement - xml-���� ������ ����������� �������� (action)
		Dim sAction			' As String - ������������ �������� (add, remove)
		Dim sValueOID		' As String - ������������� �������-��������
		
		Set oXmlActions = m_oXmlPendingActions.selectNodes("*[@ot='" & sTypeName & "' and @oid='" & sObjectID & "' and @prop='" & oProp.tagName & "']")
		If oXmlActions.length > 0 Then
			' �������� "���������� ��������"
			For Each oXmlAction In oXmlActions
				sAction = oXmlAction.getAttribute("action")
				sValueOID = oXmlAction.getAttribute("ref-oid")
				If sAction = "remove" Then
					oProp.selectNodes("*[@oid='" & sValueOID & "']").removeAll
				ElseIf sAction = "set" Then
					oProp.selectNodes("*").removeAll
					oProp.appendChild X_CreateObjectStub( oXmlAction.getAttribute("ref-ot"), sValueOID )
				ElseIf sAction = "add" Then
					oProp.appendChild X_CreateObjectStub( oXmlAction.getAttribute("ref-ot"), sValueOID )
				End If
			Next
			oXmlActions.removeAll
			recalculateHasPendingActionsFlag
		End If
	End Sub

	' /�������� � ����������� ����������
	'===========================================================================
	
	'---------------------------------------------------------------------------
	':����������:	
	'	���������� ��������� xml-������� ����������� �������,
	'	��������������� �������, ������������ � XPath-������� ��������� ������������ �������
	':���������:
	'	oXmlObject		- [in] xml-������
	'	sXPathFilter	- [in] ������ xpath-�������
	'	bOnlyNotEmpty	- [in] As Boolean - ������� "�������� ������ �������� ��������" (False - ���)
	Private Function getPropsOfObjectByMDFilter(oXmlObject, sXPathFilter, bOnlyNotEmpty)
		Dim oPropMD		' As IXMLDOMElement - ���� ������������ �������� (ds:prop)
		Dim sXPath		' As String - ����������� ������ xpath-������� ��� ��������� ��������� �������
		If Len("" & sXPathFilter) > 0 Then sXPathFilter = "[" & sXPathFilter & "]"
		For Each oPropMD In X_GetTypeMD(oXmlObject.tagName).selectNodes("ds:prop" & sXPathFilter)
			If Not IsEmpty(sXPath) Then sXPath = sXPath & " | "
			sXPath = sXPath & oPropMD.getAttribute("n")
			If bOnlyNotEmpty Then sXPath = sXPath & "[*[@oid]]"
		Next
		' ���� xpath �� �����������, ���������� �����, ����� ������ �� �����, �.�. ������ ������ ������ ����������
		If IsEmpty(sXPath) Then sXPath = "dontfind[1=0]"
		Set getPropsOfObjectByMDFilter = oXmlObject.selectNodes(sXPath)
	End Function
		
	'---------------------------------------------------------------------------
	':����������:	
	'	���������� ��������� ��������� xml-������� ����������� �������
	':���������:
	'	oXmlObject		- [in] xml-������
	'	bOnlyNotEmpty	- [in] As Boolean - ������� "�������� ������ �������� ��������" (False - ���)
	Private Function getObjectPropsOfObject(oXmlObject, bOnlyNotEmpty)
		Set getObjectPropsOfObject = getPropsOfObjectByMDFilter(oXmlObject, "@vt='object'", bOnlyNotEmpty)
	End Function
	
	'---------------------------------------------------------------------------
	':����������:	
	'	���������� ��������� ��������� ��������� xml-������� ����������� �������
	':���������:
	'	oXmlObject		- [in] As IXMLDOMElement - xml-������
	'	bOnlyNotEmpty	- [in] As Boolean - ������� "�������� ������ �������� ��������" (False - ���)
	Private Function getScalarObjectPropsOfObject(oXmlObject, bOnlyNotEmpty)
		Set getScalarObjectPropsOfObject = getPropsOfObjectByMDFilter(oXmlObject, "@vt='object' and @cp='scalar'", bOnlyNotEmpty)
	End Function
	
	
	'---------------------------------------------------------------------------
	'@@XObjectPoolClass.SetPropertyValue
	'<GROUP !!MEMBERTYPE_Methods_XObjectPoolClass><TITLE SetPropertyValue>
	':����������:	������������� �������� ������������ ��������.
	':���������:
	'	oXmlProperty - [in] XML-�������� ������� � ����, IXMLDOMElement
	'	vValue - [in] �������������� ��������, ���������� ��� ��������
	':���������:
	'	True - ���� �������� �������� ���������� (� ������� dirty ��� �������� 
	'	����������), ����� - False.
	':���������:
	'	Public Function SetPropertyValue(
	'		oXmlProperty [As IXMLDOMElement], 
	'		ByVal vValue [As Variant]
	'	) [As Boolean]
	Public Function SetPropertyValue(oXmlProperty, ByVal vValue)
		Dim vValueInXml		' As Variant - �������� �������� � XML-������ �������-���������
		
		SetPropertyValue = False
		vValueInXml = oXmlProperty.nodeTypedValue
		' �.�. �������� ����� MSXML ��������� ��� 0A (chr(10)), � �� ��� 0D0A (chr(13)+chr(10)=vbNewLine),
		' �� � ���������� �������� ������ ������� 0D
		If oXmlProperty.dataType = "string" And hasValue(vValue) Then
			vValue = Replace(vValue, vbNewLine, chr(10))
		End If
		' ��������, ��� �������� ����������������
		If IsNull(vValue) Then
			If IsNull(vValueInXml) Then Exit Function
			oXmlProperty.text = ""
		ElseIf Not IsNull(vValueInXml) Then
			If vValueInXml = vValue Then Exit Function
		End If
	
		' ��������� �������� ����������� ��� ��������� ������. 
		' ���� IsNull(vValue), �� �������� �� �������� ����
		If Not IsNull(vValue) Then
			oXmlProperty.nodeTypedValue = vValue
		End If
		SetXmlPropertyDirty oXmlProperty
		SetPropertyValue = True
	End Function
End Class


'===============================================================================
'@@GetObjectEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE GetObjectEventArgsClass>
':����������:	����� ���������� ������� "GetObject".
':����������:	������� "GetObject" ������������ ��� �������� ������� � �������.
'
'@@!!MEMBERTYPE_Methods_GetObjectEventArgsClass
'<GROUP GetObjectEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_GetObjectEventArgsClass
'<GROUP GetObjectEventArgsClass><TITLE ��������>
Class GetObjectEventArgsClass
	'@@GetObjectEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetObjectEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetObjectEventArgsClass.XmlObject
	'<GROUP !!MEMBERTYPE_Properties_GetObjectEventArgsClass><TITLE XmlObject>
	':����������:	XML c ������� ������������ �������, �� ��������� � ���.
	':���������:	Public XmlObject [As IXMLDOMElement]
	Public XmlObject
	
	'@@GetObjectEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetObjectEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As GetObjectEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@GetObjectConflictEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE GetObjectConflictEventArgsClass>
':����������:	����� ���������� ������� "GetObjectConflict".
':����������:	
'	������� "GetObject" ������������ ��� �������� ������ �������� �������, 
'	��� ������������� ��������� ����������� ������ � �������, ��������������� 
'	� ����.
'
'@@!!MEMBERTYPE_Methods_GetObjectConflictEventArgsClass
'<GROUP GetObjectConflictEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass
'<GROUP GetObjectConflictEventArgsClass><TITLE ��������>
Class GetObjectConflictEventArgsClass
	'@@GetObjectConflictEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel
	
	'@@GetObjectConflictEventArgsClass.LoadedProperty
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE LoadedProperty>
	':����������:	��������, � ���������� ��������� �������� ��������� ��������.
	':���������:	Public LoadedProperty [As IXMLDOMElement]
	Public LoadedProperty
	
	'@@GetObjectConflictEventArgsClass.ObjectInPool
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE ObjectInPool>
	':����������:	������, ��������� ���������, � ����.
	':���������:	Public ObjectInPool [As IXMLDOMElement]
	Public ObjectInPool
	
	'@@GetObjectConflictEventArgsClass.ObjectFromServer
	'<GROUP !!MEMBERTYPE_Properties_GetObjectConflictEventArgsClass><TITLE ObjectFromServer>
	':����������:	������, ��������� ���������, ��������� � �������.
	':���������:	Public ObjectFromServer [As IXMLDOMElement]
	Public ObjectFromServer

	'@@GetObjectConflictEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_GetObjectConflictEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As GetObjectConflictEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class


'===============================================================================
'@@DeleteObjectConflictEventArgsClass
'<GROUP !!CLASSES_x-pool><TITLE DeleteObjectConflictEventArgsClass>
':����������:	����� ���������� ������� "DeleteObjectConflict".
':����������:	
'	������� "DeleteObjectConflict" ������������ ��� ������� ��������, 
'	� ������ ����������� "���������� ���������" ��������� ������.
'	�������� ��������� (�, ��������������, ��������� �������) ����������� ��� 
'	������ ������ XObjectPoolClass.MarkObjectAsDeleted.
'
'@@!!MEMBERTYPE_Methods_DeleteObjectConflictEventArgsClass
'<GROUP DeleteObjectConflictEventArgsClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass
'<GROUP DeleteObjectConflictEventArgsClass><TITLE ��������>
Class DeleteObjectConflictEventArgsClass
	'@@DeleteObjectConflictEventArgsClass.Cancel
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE Cancel>
	':����������:	�������, �������� ���������� ������� ��������� �������.
	':���������:	Public Cancel [As Boolean]
	Public Cancel

	'@@DeleteObjectConflictEventArgsClass.SilentMode
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE SilentMode>
	':����������:	������� "����� ������".
	':����������: 
	'	���� �������� ���������� � �������� True, �� ���������� ���������� �������
	'	������ ����������� ����� �����-���� ��������� ��� ������������.
	'	�������� �������� � False, ���� �������� ���������� � ������� ��������, 
	'	������������������ �������������.
	':���������:	Public SilentMode [As Boolean]
	Public SilentMode

	'@@DeleteObjectConflictEventArgsClass.AllReferences
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE AllReferences>
	':����������:	������ ���� ������ �� ��������� �������.
	':���������:	Public AllReferences [As ObjectArrayListClass]
	Public AllReferences

	'@@DeleteObjectConflictEventArgsClass.NotNullReferences
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE NotNullReferences>
	':����������:	������ ������ �� ��������� ������� �� ������������ �������.
	':���������:	Public NotNullReferences [As ObjectArrayListClass]
	Public NotNullReferences

	'@@DeleteObjectConflictEventArgsClass.ObjectsToDelete
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE ObjectsToDelete>
	':����������:	������ ������ �� ������� � ����, ������� ���� �������� ��� ���������.
	':���������:	Public ObjectsToDelete [As ObjectArrayListClass]
	Public ObjectsToDelete

	'@@DeleteObjectConflictEventArgsClass.ReturnValue
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE ReturnValue>
	':����������:	���������, ������������ ������������ �������. 
	':����������:	����� - ������� ����������� / ���������� ��������� ��������: 
	'				True - ����������, False - ��������.
	':���������:	Public ReturnValue [As Boolean]
	Public ReturnValue

	'@@DeleteObjectConflictEventArgsClass.SourceXmlProperty
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE SourceXmlProperty>
	':����������:	XML-��������, �� �������� ���� �������� ��������.
	':���������:	Public SourceXmlProperty [As IXMLDOMElement]
	Public SourceXmlProperty

	'@@DeleteObjectConflictEventArgsClass.PropertiesToUpdate
	'<GROUP !!MEMBERTYPE_Properties_DeleteObjectConflictEventArgsClass><TITLE PropertiesToUpdate>
	':����������:	��������� �������, �� ������� ���������� �������� ������.
	':����������:	������������ ��� ������������ ���������� ������������� ���� �������.
	':���������:	Public PropertiesToUpdate [As ObjectArrayListClass]
	Public PropertiesToUpdate
	
	' ���������� ����� ������������� ����������, "�����������".
	Private Sub Class_Initialize
		ReturnValue = True
		Set PropertiesToUpdate = Nothing
	End Sub

	'@@DeleteObjectConflictEventArgsClass.Self
	'<GROUP !!MEMBERTYPE_Methods_DeleteObjectConflictEventArgsClass><TITLE Self>
	':����������:	���������� ������ �� ������� ��������� ������.
	':���������:	Public Function Self() [As DeleteObjectConflictEventArgsClass]
	Public Function Self
		Set Self = Me
	End Function
End Class
