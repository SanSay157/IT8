'===============================================================================
'@@!!FILE_x-vbs
'<GROUP !!SYMREF_VBS>
'<TITLE x-vbs - ����� ����������� �������\, "����������" VBScript>
':����������:
'	����� ����� ����������� �������, �������� � �������, "����������" ����� 
'	����������� ������� VBScript.
'===============================================================================
'@@!!FUNCTIONS_x-vbs
'<GROUP !!FILE_x-vbs><TITLE ������� � ���������>
'@@!!CLASSES_x-vbs
'<GROUP !!FILE_x-vbs><TITLE ������>


'===============================================================================
'@@SafeCLng
'<GROUP !!FUNCTIONS_x-vbs><TITLE SafeCLng>
':����������:	"����������" ���������� ���� ��������� �������� � Long.
':���������:	vValue - [in] ������������� ��������
':���������:	����� ���� Long.
':���������:	���� ���������� �������������� ����������, �� ������� ���������� 0.
':���������:	Function SafeCLng( ByVal vValue [As Variant] ) [As Long]
Function SafeCLng(ByVal vValue)
	If IsNumeric( vValue) Then 
		SafeCLng = CLng( vValue)
	Else
		SafeCLng = 0
	End If
End Function


'===============================================================================
'@@toObject
'<GROUP !!FUNCTIONS_x-vbs><TITLE toObject>
':����������:	"����������" ���������� ���� ��������� �������� � �������.
':���������:	vValue - [in] ������������� ��������
':���������:	������
':���������:	���� ���������� �������������� ����������, �� ������� ���������� Nothing.
':���������:	Function toObject( ByVal vValue [As Variant] ) [As Object]
Function toObject(ByVal vValue)
	If IsNothing(vValue) Then
		Set toObject = Nothing
	Else
		Set toObject = vValue
	End If		
End Function


'===============================================================================
'@@IsNothing
'<GROUP !!FUNCTIONS_x-vbs><TITLE IsNothing>
':����������:	�������� ��������� ������ �� ������ �� "���������".
':���������:	vValue - ����������� ������
':���������:
'	���������� ��������:
'	* <B>False</B> - ���� ��������, ���������� vValue, ���� ������ �� ������, 
'		� �� �������� Nothing;
'	* <B>True</B> - � ��������� ������.
':����������:	
'	���� vValue �� �������� ������� �� ������, �� ������� ���������� True.
':���������:
'	Function IsNothing( ByVal vValue [As Variant] ) [As Boolean]
Function IsNothing(ByVal vValue)
	If IsObject(vValue) Then
		IsNothing = (vValue Is Nothing)
	Else
		IsNothing = True	
	End If
End Function


'===============================================================================
'@@hasValue
'<GROUP !!FUNCTIONS_x-vbs><TITLE hasValue>
':����������:	����������, �������� �� �������� �������� ������������.
':���������:	vValue - [in] ���������� ������ ����; ����� ���� �������
':���������:    True - �������� ����������, False - � ��������� ������.
':����������:	
'	�������� ��������� ������������, ���� ��� �� Empty, �� NULL, �� Nothing 
'	(��� ������ ������), �� ������ ��������� ������ � �� �������� ������.
':���������:	Function hasValue( vValue [As Variant] ) [As Boolean]
Function hasValue( vValue )
	hasValue = True
	If IsObject(vValue) Then
		hasValue = Not(vValue Is Nothing)
	ElseIf IsEmpty(vValue) Then
		hasValue = False
	ElseIf IsNull(vValue) Then
		hasValue = False
	ElseIf Not IsArray(vValue) Then
		hasValue = CBool( Trim(vValue)<>"" )
	ElseIf UBound(vValue)<LBound(vValue) Then 
		hasValue = False
	End If
End Function


'===============================================================================
'@@IsDefined
'<GROUP !!FUNCTIONS_x-vbs><TITLE IsDefined>
':����������:	����������, �������� �� �������� �������� ��������������.
':���������:    True - �������� �������� �������������, False - � ��������� ������.
':���������:	vValue - [in] ���������� ������ ����; ����� ���� �������
':����������:
'	�������� �������� ��������� ��������������, ���� ��� �� Null, �� Empty, � �� 
'	Nothing. � ������� �� hasValue, �� ���������, �������� �� �������������� 
'	�������� ������ (�.�. � ������ ������ ������ ��� ������� ������� ������� 
'	���������� True, ����� ��� hasValue - False).
':���������:	Function IsDefined( vValue [As Variant] ) [As Variant]
Function IsDefined( vValue )
	IsDefined = True
	If IsObject(vValue) Then
		IsDefined = Not(vValue Is Nothing)
	ElseIf IsEmpty(vValue) Then
		IsDefined = False
	ElseIf IsNull(vValue) Then
		IsDefined = False
	End If
End Function


'===============================================================================
'@@toString
'<GROUP !!FUNCTIONS_x-vbs><TITLE toString>
':����������:	���������� ��������� ������������� ��������� ��������.
':���������:    ��������� ������������� ��������� ��������; ������ ������, ����
'				�������� �������� ���� "�����" (��. ����������� � hasValue).
':���������:	vValue - [in] ���������� ������ ����; ����� ���� �������
':����������:	
'	��������! ��� ��������� ���������� ������������� ������������ �����������
'	������� VBScript <B>CStr</B>. �������, ����� ������� � ��������� � �������� 
'	��������� ������ �� ������ �������� � ������������� ������!
':���������:	Function toString( vValue [As Variant] ) [As Variant]
Function toString( vValue )
	If hasValue(vValue) Then
		toString = CStr(vValue)
	Else
		toString = ""
	End If
End Function


'===============================================================================
'@@nvl
'<GROUP !!FUNCTIONS_x-vbs><TITLE nvl>
':����������:	Returns the first nonnull expression among its arguments
':���������:
':���������:
':���������:	Function nvl( a [As Variant], b [As Variant] ) [As Variant]
Function nvl( a, b )
	nvl = Coalesce( Array(a,b) )
End Function


'===============================================================================
'@@Coalesce
'<GROUP !!FUNCTIONS_x-vbs><TITLE Coalesce>
':����������:	Returns the first nonnull expression among its arguments
':���������:
':���������:
':���������:	Function Coalesce( aParams [As Array] ) [As Variant]
Function Coalesce(aParams)
    ' ���������� ����� �������� ���� �������
    ' ����� ������ ���������� ������������ ������������� ��������
	For Each Coalesce in aParams
		If hasValue(Coalesce) Then Exit Function
	Next
End Function


'===============================================================================
'@@iif
'<GROUP !!FUNCTIONS_x-vbs><TITLE iif>
':����������:	���������� ���� �� ���� �������� ��������, � ����������� �� 
'				���������� ���������� ��������� ����������� ���������.
':���������:    �������� ��������� vForTrue, ���� ��������� ����������� ��� 
'				���������� True, ��� �������� ��������� vForFalse� � ���������
'				������.
':���������:	bExpression - [in] ���������� ���������
'				vForTrue - [in] �������� ��� ������ ���� bExpression ���� True
'				vForFalse - [in] �������� ��� ������ ���� bExpression ���� False
':����������:	��������� bExpression ����������� ���� ���.
':���������:	
'	Function iif( bExpression [As Boolean], vForTrue [As Variant], vForFalse [As Variant] ) [As Variant]
Function iif( bExpression, vForTrue, vForFalse )
	If (bExpression) Then
		If IsObject(vForTrue) Then
			Set iif = vForTrue
		Else
			iif = vForTrue
		End If	
	Else
		If IsObject(vForFalse) Then
			Set iif = vForFalse
		Else	
			iif = vForFalse
		End If
	End If
End Function


'===============================================================================
'@@isEqual
'<GROUP !!FUNCTIONS_x-vbs><TITLE isEqual>
':����������:	��������� ��������� ���� �������� ��������. 
':���������:    True - ���� �������� �����, False � ��������� ������.
':���������:	
'	vValueA - [in] ������ ������������ ��������
'	vValueB - [in] ������ ������������ ��������
':����������:	
'	������� ��������� ���������� ������� (� ��������� �� ���������� ���� � VBS), 
'	��� "�����" (��. ����������� � hasValue) ��� ��� ������ �� ���� � ��� ��
'	������. ������� �� ��������� ��������� ��������, ��� ����� ������������
'	������� isArrayEqual.
':���������:	
'	Function isEqual( vValueA [As Variant], vValueB [As Variant] ) [As Boolean]
Function isEqual( vValueA, vValueB )
	isEqual = False
	
	If IsObject(vValueA) Then
		If IsObject(vValueB) Then
		
			' ������������ ������ �� ������:
			If vValueA Is vValueB Then 
				isEqual = True
			End If
			
		End If
	Else
		If Not IsObject(vValueB) Then
			
			' �������� ��� �������� �� "�����":
			If hasValue(vValueA) Then
				If hasValue(vValueB) Then 
				
					' ��������� ��������: 
					If vValueB = vValueA Then 
						isEqual = True
					End If
					
				End If
				
			Else
				
				' ���� ��� �������� - "�����", ��� ��������� �������
				If Not hasValue(vValueB) Then 
					isEqual = True
				End If
			
			End if
			
		End If
	End If
End Function


'===============================================================================
'@@isInteger
'<GROUP !!FUNCTIONS_x-vbs><TITLE isInteger>
':����������:	����������, �������� �� ���������� �������� ����� ������.
':���������:    True, ���� �������� �������� ���� ����� �����, False � ��������� ������
':���������:	vValue - [in] ����������� ��������
':����������:	
'	������� ��������� ������� ������ ���������� ���� ��������� �������� � 
'	�������������� ����, ��������� ��������� ������� <B>CLng</B>. ����� �������
'	�������� ����������� �������� ����� ���� �������.<P/>
'	��������! � �������� �������� ������������ �������� �����������	������� Err!
':���������:	Function isInteger( ByVal vValue [As Variant] ) [As Boolean]
Function isInteger( ByVal vValue )
	isInteger = False
	
	' ����������� �������� �.�. ����� ������ ������ ���� ��� �� "�����" 
	' � �� ������ �� ������:
	If hasValue(vValue) Then
		If Not IsObject(vValue) Then
			
			' �������� ���������� ����� ����� ����������� ��������� �������� 
			' � ������� �����; ��� ���� �������������� ������ ������� ����������
			On Error Resume Next
			vValue = CLng(vValue)
			If Not Err Then 
				isInteger = True
			End if
			On Error Goto 0
			
		End if
	End if
End Function


'===============================================================================
'@@isCurrency
'<GROUP !!FUNCTIONS_x-vbs><TITLE isCurrency>
':����������:	����������, �������� �� ���������� �������� ��������� ���� Currency.
':���������:	vValue - [in] ����������� ��������
':���������:	
'	True, ���� ��� �������� ����� ���� �������� � Currency, False � ��������� ������
'	(��. ��� �� ������ "���������").
':����������:	
'	������� ��������� ������� ������ ���������� ���� ��������� �������� � 
'	���������� ���� (������������� ������� <B>CCur</B> � <B>CDbl</B>). ����� 
'	�������	�������� ����������� �������� ����� ���� �������.<P/>
'	��������! � �������� �������� ������������ �������� �����������	������� Err!
':���������:	Function isCurrency( ByVal vValue [As Variant] ) [As Boolean]
Function isCurrency( ByVal vValue )
	isCurrency = False
	If hasValue(vValue) Then
		If Not IsNumeric(vValue) Then Exit Function
		If CCur(vValue) <> CDbl(vValue) Then Exit Function
		isCurrency = True
	End If
End Function


'===============================================================================
'@@isEmptyGuid
'<GROUP !!FUNCTIONS_x-vbs><TITLE isEmptyGuid>
':����������:	�����������, ������������� �� ���������� ������ "��������" GUID.
':���������:    True - ���� �������� ���� "�������" GUID, False � ��������� ������.
':���������:	sGuid - [in] ����������� ��������, GUID, ����������� � ������
':����������:	
'	���� ���������� �������� ���� "������" (��. �������� ������� hasValue), �� 
'	������� ���������� True (�.�. ������ ������ �������������� � "��������" GUID).
':���������:	Function isEmptyGuid( ByVal sGuid [As String] ) [As Boolean]
Function isEmptyGuid( ByVal sGuid )
	If hasValue(sGuid) Then
		isEmptyGuid = CBool(0 = StrComp( Trim(sGuid),"00000000-0000-0000-0000-000000000000",1))
	Else
		isEmptyGuid = True
	End If
End Function


'===============================================================================
'@@splitString
'<GROUP !!FUNCTIONS_x-vbs><TITLE splitString>
':����������:	
'	���������� ������ ����������� ������� VBScript <B>Split</B>. � ������� �� 
'	����������� ������� ������ ������� <B><I>������</I></B> ���������� ������. 
'	� ������, ���� �������� ������ ����� (��� "�����", ��. ����������� � hasValue),
'	� �������� ���������� ������������ ������ ������, �� ���������� �� ������ 
'	��������.
':���������:    ������, ���������� � ���������� ��������� �������� ������.
':���������:	sString - [in] ����������� ������
'				sDelimeter - [in] ��������� ��� ������ �����������
':������: 		
'	Dim aTest, vEmpty
'	aTest = splitString( "1;2;34", ";" )	' aTest ���� ������ � ���������� 1, 2 � 34
'	aTest = splitString( vEmpty, ";" )		' aTest ���� ������ ������
':���������:	
'	Function splitString( sString [As String], sDelimeter [As String] ) [As Array]
Function splitString( sString, sDelimeter )
	If hasValue( sString ) Then
		splitString = Split( sString, sDelimeter )
	Else
		splitString = Array()
	End If
End Function


'===============================================================================
'@@getPosInArray
'<GROUP !!FUNCTIONS_x-vbs><TITLE getPosInArray>
':����������:	���������� ������� �������� � ���������� �������.
':���������:    ������ �������� � �������, ��� <B>-1</B>, ���� ������� �� ������.
':���������:	
'	vValue - [in] ������� ��������
'	aArray - [in] ������
':���������:	
'	Function getPosInArray( vValue [As Variant], aArray [As Array] ) [As Int]
Function getPosInArray( vValue, aArray )
	Dim i	' ���������� �����
	getPosInArray = -1
	For i = LBound( aArray ) To UBound( aArray )
		If aArray( i ) = vValue Then
			getPosInArray = i
			Exit For
		End If
	Next
End Function


'===============================================================================
'@@arrayAddition
'<GROUP !!FUNCTIONS_x-vbs><TITLE arrayAddition>
':����������:	��������� �������� � ����� �������, ���������� ��� ����������
':���������:	
'	vValue - [in] ����������� ��������; ����� ���� ��������, � ���� ������ � 
'				������� ������ aArray ��������������� ����������� ��� ��������
'	aArray - [in,out] ������� ������, � ������� ����������� �������
':����������:	
'	� �������� aArray ����� ���� ������ "�����" (��. ����������� � hasValue), 
'	������� ���������������� ��� ������ ������.
':��. �����:	
'	arraySubtraction, isArrayEqual, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':���������:	
'	Sub arrayAddition( vValue [As Variant], ByRef aArray [As Array] )
Sub arrayAddition( vValue, ByRef aArray )
	Dim i		' ���������� �����

	' ��������������� �������� ���������: ���� ����������� �������� ���� "�����" -
	' ���������� ��� � ������ ������ - ��� �������� "���������" �������� � 
	' �������������������� ����������, ����� �� ��� �.�. ������:
	If Not hasValue( aArray ) Then aArray = Array()

	' ���� vValue - ������, ��������� ��� ��� �������� � ����� ��������� �������:
	If IsArray( vValue ) Then
		ReDim Preserve aArray( UBound(aArray) + UBound(vValue) + 1 )
		For i = LBound(vValue) To UBound(vValue)
			' ...���� ������� - ������, �� ��� ���� ���������� Set'��:
			If IsObject( vValue(i) ) Then
				Set aArray( UBound(aArray) - UBound(vValue) + i ) = vValue(i)
			Else
				aArray( UBound(aArray) - UBound(vValue) + i ) = vValue(i)
			End If
		Next
	' ...����� ��������� ���� ��������:
	Else
		ReDim Preserve aArray( UBound(aArray) + 1 )
			' ...���� ������� - ������, �� ��� ���� ���������� Set'��:
		If IsObject( vValue ) Then
			Set aArray( UBound(aArray) ) = vValue
		Else
			aArray( UBound(aArray) ) = vValue
		End if
	End If
End Sub


'===============================================================================
'@@arraySubtraction
'<GROUP !!FUNCTIONS_x-vbs><TITLE arraySubtraction>
':����������:	
'	"��������" �� ��������� ������� �������� ������; ���������� �������� � ����� 
'	����� (��. ������ ���������).
':���������:	
'	arReduced		- [in] �������� ������ (�����������)
'	arDeducted		- [in] ���������� ������ (����������)
'	arDifference	- [out] ��������; ���� �������� ������, �� Empty
'	arCommon		- [out] ����� �����; ���� ����� ����� ������, �� Empty
':����������:	
'	� ������ �������� �������� �� ��������, ������� ������������ � �������� 
'	(�����������) �������, �� ����������� � ����������; � ����� ����� �������� �� 
'	��������, ������� ���� ������� �� ��������� (������������) �������.
':��. �����:	
'	arrayAddition, isArrayEqual, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':���������:	
'	Sub arraySubtraction( 
'		arReduced [As Array], 
'		arDeducted [As Array], 
'		ByRef arDifference [As Array], 
'		ByRef arCommon [As Array] 
'	)
Sub arraySubtraction( arReduced, arDeducted, ByRef arDifference, ByRef arCommon )
	Dim bFound		' ����, ������������ ������ �� ������� arReduced � arDeducted
	Dim i, j		' ���������� �����

	ReDim arCommon( -1 )
	ReDim arDifference( -1 )

	For i = LBound(arReduced) To UBound(arReduced)
		bFound = False
		For j = LBound(arDeducted) To UBound(arDeducted)
		
			' ���������� �������� �������� 
			If isEqual( arReduced(i), arDeducted(j) ) Then
				bFound = true
				bIsObject = false
			End If
			
		Next
		
		' ���� ������� ��� ������ � ����������, �� �������� ��� � ����� �����...
		If bFound Then
			ReDim Preserve arCommon( UBound(arCommon) + 1 )
			If IsObject( arReduced(i) ) Then
				Set arCommon( UBound(arCommon) ) = arReduced(i)
			Else
				arCommon( UBound(arCommon) ) = arReduced(i)
			End if
		' ...����� - � ��������.
		Else
			ReDim Preserve arDifference( UBound(arDifference)  + 1 )
			If IsObject( arReduced(i) ) Then
				Set arDifference( UBound(arDifference) ) = arReduced(i)
			Else
				arDifference( UBound(arDifference) ) = arReduced(i)
			End if
		End If
	Next
End Sub


'===============================================================================
'@@isArrayEqual
'<GROUP !!FUNCTIONS_x-vbs><TITLE isArrayEqual>
':����������:	
'	��������� ������������ ��������� ��������. �������� bOrdered ����������, 
'	������������ �� ������� � ������ ������� ���������� ��������� ��� ���.
':���������:    True - � ������ ��������� ��������, False - �����.
':���������:	
'	arFirst		- [in] ������ ������������ ������ ("�����" �������� ���������)
'	arSecond	- [in] ������ ������������ ������ ("������" �������� ���������)
'	bOrdered	- [in] ���������� ������� ����� ���������� ���������; �����:
'					* True - ��������� ������������ � ������ ������� ����������.
'					������� ��������� �������, ������ ���� ��� ���� i �����������:
'					arFirst(i) = arSecond(i);
'					* False - ������� �����, ���� ����� �������� ��������� � ��� 
'					���� ��� ������� �������� ������� arFirst ���������� ������� 
'					������� arSecond � ����� �� ���������.
':��. �����:	
'	arrayAddition, arraySubtraction, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':���������:	
'	Function isArrayEqual( 
'		arFirst [As Array], 
'		arSecond [As Array], 
'		bUseOrder [As Boolean] 
'	) [As Boolean]
Function isArrayEqual( arFirst, arSecond, bUseOrder )
	Dim bExists	' ���� ������������� �������� ������� arFirst � ������� arSecond
	Dim i, j	' ���������� �����

	isArrayEqual = True
	
	' � ������ �� ���������� ����, ������� �� ����� 
	If ( UBound(arFirst)-LBound(arFirst) ) <> ( UBound(arSecond)-LBound(arSecond) ) Then
		isArrayEqual = False
		
	' � ������ ��������� � ������ ������� ���������� ��� �� ������ ���������:
	ElseIf bUseOrder And ( UBound(arFirst)<>UBound(arSecond) ) Then
		isArrayEqual = False
		
	Else 
		' ���������� ��������:
	
		For i = LBound( arFirst ) To UBound( arFirst ) 
			If bUseOrder Then
				' � ������ ��������� � ������ ������� ���������� ������� �����������;
				' ���� ������� �� ������ ��������, ������ ������� �� �����. ���  
				' ��������� ���������, ��� �������� ����� ���� ��������
				If Not isEqual( arFirst(i),arSecond(i) ) Then
					isArrayEqual = false
					Exit For
				End If 
			Else
				' � ������ ��������� ��� ����� ������� �������� ����� ������ ������� 
				' ������� ������� �� ������; ���� �������� ��� - ������� �� �����:
				bExists = False
				For j = LBound( arSecond ) to UBound( arSecond ) 
					If isEqual( arFirst(i),arSecond(j) ) Then
						bExists = True
						Exit For
					End If
				Next
				' ���� ������� �� ������, ������� �� �����.
				If Not bExists Then
					isArrayEqual = False
					Exit For
				End If
			End If
		Next
	End If
End Function


'===============================================================================
'@@addRefIntoArray
'<GROUP !!FUNCTIONS_x-vbs><TITLE addRefIntoArray>
':����������:
'	��������� � ������ ���������� ������ (��������� ��� ��������� �� �������)
':���������:
'	aArray	- [in] ������, � ������� ����������� ������
'	oRef	- [in] ����������� ������ (����� ���� Nothing)
':��. �����:	
'	arrayAddition, arraySubtraction, isArrayEqual, insertRefInfoArray, removeArrayItemByIndex
':���������:	Sub addRefIntoArray( ByRef aArray [As Array], ByRef oRef [As Object] )
Sub addRefIntoArray( ByRef aArray, ByRef oRef )
	insertRefInfoArray aArray, -1, oRef
End Sub


'===============================================================================
'@@insertRefInfoArray
'<GROUP !!FUNCTIONS_x-vbs><TITLE insertRefInfoArray>
':����������:
'	����������� � ������ ���������� ������ (��������� ��� ��������� �� �������),
'	��� ������� � ������� ��������.
':���������: 
'	aArray	- [in] ������, � ������� ����������� ������
'	nIndex	- [in] ������ ������������ ������� �������, � ������� ����� ��������� ������
'	oRef	- [in] ������������ ������ (����� ���� Nothing)
':����������:
'	���� �������� ������ ��������� �� ��������� �������, �� ������ ����������� 
'	� ����� �������, ��������� ���������.
':��. �����:	
'	arrayAddition, arraySubtraction, isArrayEqual, addRefIntoArray, removeArrayItemByIndex
':���������:	
'	Sub insertRefInfoArray( ByRef aArray [As Array], nIndex [As Int], ByRef oRef [As Object] )
Sub insertRefInfoArray(ByRef aArray, nIndex, ByRef oRef)
	Dim nUpper
	Dim i
	If Not IsArray(aArray) Then
		aArray = Array()
	End If
	nUpper = Ubound(aArray)
	If (nIndex <0) or (nIndex>nUpper) then nIndex = nUpper+1
	Redim Preserve aArray(nUpper+1)
	For i=nUpper To nIndex Step -1
		Set aArray(i+1) = aArray(i)
	Next
	Set aArray(nIndex) = oRef
End Sub


'===============================================================================
'@@removeArrayItemByIndex
'<GROUP !!FUNCTIONS_x-vbs><TITLE removeArrayItemByIndex>
':����������:	������� �� ������� ������� � �������� ��������.
':���������:
'	oArray	- [in] ������, � ������� ��������� �������
'	nIndex	- [in] ������ ���������� ��������
':��. �����:	
'	arrayAddition, arraySubtraction, isArrayEqual, addRefIntoArray, insertRefInfoArray
':���������:
'	Sub removeArrayItemByIndex( ByRef oArray [As Array], ByVal nIndex [As Int] )
Sub removeArrayItemByIndex(ByRef oArray, ByVal nIndex)
	Dim nUpper	' ������ �������� �������� �������
	If Not IsArray(oArray) Then Exit Sub
	If nIndex < LBound(oArray) Or nIndex > UBound(oArray) Then Exit Sub
	nUpper = UBound(oArray) -1 
	For i=nIndex To nUpper
		oArray(i) = oArray(i+1)
	Next
	ReDim Preserve oArray(nUpper)
End Sub


'===============================================================================
'@@ParseFormatString
'<GROUP !!FUNCTIONS_x-vbs><TITLE ParseFormatString>
':����������:	
'	��������� ������ �� �������� ��������� ������, ����� ����������� ����������
'	������������� ���������������� ��������� � �������� ������� ��������� ������.
':���������:
'	sFormatString - [in] ��������� ������
'	�Values	- [in] ������ ��������, ������������� � ��������� ������
':���������:
'	������, ���������� � ���������� ����������� �������� � ��������� ������.
':����������:
'	��������� ������ - ��� ������, � ����� ������� ������ ����������� - ������ 
'	���� "(N)", ��� N - ����� �����������, ����� �����, ������� � ����.<P/>
'	������� ��������� ������ ����� ������ ����� ����������� (������� ������� 
'	������� ������) �� ��������� ������������� ��������� �� ������� aValues, � 
'	���������, ���������������� ������� �����������.<P/>
'	� ��������� ������ ����������� ��������� ���������� ����������� � ����� 
'	� ��� �� ��������; ��� ����������� ��� ��������� ����� ��������� ����� 
'	�������� �� ���� � �� �� ��������.<P/>
'	���� ��� ����������� � ������� N � ������� aValues ��������������� �������
'	�����������, �� ������� ���������� ������.
':������:
'	Dim sTest
'	sTest = ParseFormatString( _
'		"��� �������� (0). �������� '(0)' �������� ��� ������ (1)", _
'		Array( "������","ParseFormatString" ) )
'	' ...� sTest ����� "��� �������� ������. �������� '������' �������� ��� ������ ParseFormatString" 
':���������:
'	Function ParseFormatString( ByVal sFormatString [As String], aValues [As Array] ) [As String]
Function ParseFormatString( ByVal sFormatString, aValues )
	Dim oRegExp		' RegExp
	Dim nIndex		' ������
	Set oRegExp = New RegExp
	oRegExp.Pattern = "{(\d+)}"
	oRegExp.Multiline = True
	oRegExp.Global = True
	For Each oMatch In oRegExp.Execute(sFormatString)
		nIndex = CLng( oMatch.SubMatches(0) )
		If UBound(aValues) < nIndex Then
			Err.Raise -1, "ParseFormatString", "����������� ������� ������ �����������"
		End If
		sFormatString = Replace(sFormatString, oMatch.Value, aValues(nIndex))
	Next
	ParseFormatString = sFormatString
End Function


'===============================================================================
'@@ObjectArrayListClass
'<GROUP !!CLASSES_x-vbs><TITLE ObjectArrayListClass>
':����������:	��������� ������ �� �������, � ������������ ��������.
'
'@@!!MEMBERTYPE_Methods_ObjectArrayListClass
'<GROUP ObjectArrayListClass><TITLE ������>
'@@!!MEMBERTYPE_Properties_ObjectArrayListClass
'<GROUP ObjectArrayListClass><TITLE ��������>
Class ObjectArrayListClass
	Private m_aList		' ������
	Private m_nIndex	' ������ ���������� ���������� ��������
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		const ALLOC_SIZE = 8 	' ��������� ������ �������
		ReDim m_aList(ALLOC_SIZE)
		m_nIndex = 0
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Add
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE Add>
	':����������:	��������� �������� ������ �� ������ � ����� ���������.
	':���������:	oObject - [in] ����������� ������ �� ������
	':���������:	Public Sub Add( oObject [As Object] )
	Public Sub Add( oObject )
		Dim nNewSize			' ����� ������
		Const GROWTH_SIZE = 8	' ������, �� ������� ������������� ������ ��� ���������� �������

		Set m_aList(m_nIndex) = oObject
		If m_nIndex = UBound(m_aList) Then
		    nNewSize = UBound(m_aList) + 1 + GROWTH_SIZE
			ReDim Preserve m_aList(nNewSize)
		End If
		m_nIndex = m_nIndex + 1
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Insert
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE Insert>
	':����������:	��������� �������� ������ �� ������ � ���������, � ��������� �������.
	':���������:	nIndex	- [in] ������� (������), � ������� ����������� �������
	'				oObject	- [in] ����������� ������ �� ������
	':���������:	Public Sub Insert( nIndex [As Int], oObject [As Object] )
	Public Sub Insert( nIndex, oObject )
		Dim i
		If nIndex = -1 Or nIndex = m_nIndex Then
			Add oObject
		ElseIf nIndex >= m_nIndex And nIndex<0 Then
			Err.Raise 9, "ObjectArrayListClass", "������ �� ��������� �������"
		Else
			If m_nIndex = UBound(m_aList) Then
				nNewSize = UBound(m_aList) + 1 + GROWTH_SIZE
				ReDim Preserve m_aList(nNewSize)
			End If
			For i=m_nIndex To nIndex+1 Step -1
				Set m_aList(i) = m_aList(i-1)
			Next
			Set m_aList(nIndex) = oObject
			m_nIndex = m_nIndex + 1
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.AddRange
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE AddRange>
	':����������:	��������� ��� �������� ��������� ������� � ����� ���������.
	':���������:	aObjects - [in] ������ ����������� ���������
	':����������:	���������, ��� ������ aObjects �������� ������ �� �������;
	'				����������� �������� ����� �������� �� ������������. ������
	'				aObjects ����� ���� ������.
	':���������:	Public Sub AddRange( aObjects [As Array] )
	Public Sub AddRange( aObjects )
		Dim i
		If Not IsArray(aObjects) Then Exit Sub
		ReDim Preserve m_aList( UBound(m_aList) + UBound(aObjects) + 1 )
		For i=0 To UBound(aObjects)
			Set m_aList(m_nIndex) = aObjects(i)
			m_nIndex = m_nIndex + 1
		Next
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Remove
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE Remove>
	':����������:	������� �� ��������� ��� ��������, ���������� �������� �� ������� ������.
	':���������:	oObject - [in] ������ �� ������
	':���������:	Public Sub Remove( oObject [As Object] )
	Public Sub Remove( oObject )
		Dim i
		i = 0
		Do While i < m_nIndex
			If m_aList(i) Is oObject Then RemoveAt i
			i = i + 1
		Loop
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.RemoveAt
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE RemoveAt>
	':����������:	������� �� ��������� ������� � �������� ��������.
	':���������:	nIndex - [in] ������ (�������) ���������� �������� ���������
	':���������:	Public Sub RemoveAt( nIndex [As Int] )
	Public Sub RemoveAt( nIndex )
		Dim i
		If nIndex<m_nIndex Then
			' ������� ��� ����������� �������� �� ��������� � ������
			For i=nIndex To m_nIndex-2
				Set m_aList(i) = m_aList(i+1)
			Next
			' ��������� �����, �� ������� �������� �������� �������
			Set m_aList(m_nIndex-1) = Nothing
			m_nIndex = m_nIndex - 1
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.RemoveAll
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE RemoveAll>
	':����������:	������� ��� �������� ���������.
	':���������:	Public Sub RemoveAll
	Public Sub RemoveAll
		Erase m_aList
		m_nIndex = 0
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.IsExists
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE IsExists>
	':����������:	��������� ������� � ��������� ��������, ����������� 
	'				��������� ������ �� ������.
	':���������:	oObject - [in] ������ �� ������, ������� ������� �����������
	':���������:	True, ���� � ��������� ���������� �������, ���������� 
	'				��������� ������, False � ��������� ������.
	':��. �����:	IndexOf
	':���������:	Public Function IsExists( oObject [As Object] ) [As Boolean]
	Public Function IsExists( oObject )
		IsExists = CBool( IndexOf(oObject)>-1 )
	End Function

	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.IndexOf
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE IndexOf>
	':����������:	
	'	���������� ������ �������� ���������, � ������� ��������� ��������� 
	'	������ �� ������.
	':���������:	
	'	oObject - [in] ������� ������ �� ������
	':���������:	
	'	������ �������� ���������, � ������� ��������� ������ �� �������� ������.
	'	���� ������� �� ������, ������� ���������� <B>-1</B>.
	':���������:	
	'	Public Function IndexOf( oObject [As Object] ) [As Int]
	Public Function IndexOf( oObject )
		Dim i
		IndexOf = -1
		For i=0 To m_nIndex-1
			If m_aList(i) Is oObject Then
				IndexOf = i
				Exit For
			End If
		Next
	End Function
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.GetArray
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE GetArray>
	':����������:	���������� ������ - ����� ���������.
	':���������:	������, ��� �������� �������� ���� ����� ��������� ���������.
	':���������:	Public Function GetArray() [As Array]
	Public Function GetArray()
		Dim aRet
		Dim i
		aRet = Array()
		If m_nIndex>0 Then
			ReDim aRet(m_nIndex-1)
			For i=0 To UBound(aRet)
				Set aRet(i) = m_aList(i)
			Next
		End If
		GetArray = aRet
	End Function
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.IsEmpty
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE IsEmpty>
	':����������:	���������� ������� ����, ������ �� ��������� ��� ���.
	':���������:	True, ���� ��������� ������, False - �����.
	':���������:	Public Function IsEmpty() [As Boolean]
	Public Function IsEmpty()
		IsEmpty = CBool(m_nIndex=0)
	End Function
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.First
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE First>
	':����������:	���������� ������ �� ������, ����������� � ������ �������� ���������.
	':���������:	������ �� ������. 
	':����������:	
	'	�������� ������ ��� ������.<P/>
	'	���� ��������� �����, �� ������� ������ �������� �������� � ��������� 
	'	������ ������� ����������.
	':��. �����:	ObjectArrayListClass.GetAt
	':���������:	Property Get First [As Object]
	Property Get First
		Set First = GetAt(0)
	End Property
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Last
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE Last>
	':����������:	���������� ������ �� ������, ����������� � ��������� �������� ���������.
	':���������:	������ �� ������. 
	':����������:	
	'	�������� ������ ��� ������.<P/>
	'	���� ��������� �����, �� ������� ������ �������� �������� � ��������� 
	'	������ ������� ����������.
	':��. �����:	GetAt
	':���������:	Property Get Last [As Object]
	Property Get Last
		Set Last = GetAt(m_nIndex-1)			
	End Property
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Count
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE Count>
	':����������:	���������� ���������� ��������� � ������.
	':����������:	�������� ������ ��� ������.
	':���������:	Property Get Count [As Int]
	Property Get Count
		Count = m_nIndex
	End Property

	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.GetAt
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE GetAt>
	':����������:	
	'	���������� ������ �� ������, ����������� � ���������, � �������� 
	'	� �������� ��������.
	':���������:	
	'	nIndex	- [in] ������ ��������, � ������� ��������� ��������� ������
	':���������:	
	'	������ �� ������, ����������� � ��������� �� ���������� ������� nIndex.
	':����������:	
	'	������� ������ ������� � ������������ �������� (��� ������ ���������), � ��� 
	'	�� � ������ ������ ���������, �������� � ��������� ������ ������� ����������.
	':��. �����:	ObjectArrayListClass.First, ObjectArrayListClass.Last
	':���������:	Public Function GetAt( nIndex [As Int] ) [As Object]
	Public Function GetAt( nIndex )
		If nIndex < m_nIndex And nIndex>=0 Then
			Set GetAt = m_aList(nIndex)
		Else
			' 9 - runtime ������ VBScript "Subscript out of range"
			Err.Raise 9, "ObjectArrayListClass", "������ �� ��������� �������"
		End If
	End Function
End Class


'===============================================================================
'@@DateTimeFormatter
'<GROUP !!CLASSES_x-vbs><TITLE DateTimeFormatter>
':����������:	
'	����� ������������� ������ �������� ���� / ������� � ���� �����.
':��������:
'	��������� �������� ������������� ����, ������ ������, ����, ����, �����, 
'	������, ������ ������ � ������ � ������ ��� � ������ � ���� ������. � ������ 
'	�������������� �������� ��������� �������� �������������, ����������
'	���������� ���� (��� ����, ������ ������, ����, ����� � ������).
'
'@@!!MEMBERTYPE_Methods_DateTimeFormatter
'<GROUP DateTimeFormatter><TITLE ������>
'@@!!MEMBERTYPE_Properties_DateTimeFormatter
'<GROUP DateTimeFormatter><TITLE ��������>
Class DateTimeFormatter
	Private m_bIsInitalized		' ������� ������������� ��������� �������������
	Private m_dtSrcDateTime		' �������� ���� / �����
	Private m_bSetLeadingZero	' ������� ��������� ���������� ����� 
	
	Private m_sDay		' ��������� ������������� ������ ��� (�����)
	Private m_sMonth	' ��������� ������������� ������ ������
	Private m_sYear		' ��������� ������������� ������ ����
	Private m_sWeekNum	' ��������� ������������� ������ ������ � ������
	Private m_sWeekday	' ��������� ������������� ��� ������ (�������� "1" �����.
						' ������������, "2" - ��������, � �.�. �� "7")

	Private m_sHour		' ��������� ������������� ����
	Private m_sMinute	' ��������� ������������� �����
	Private m_sSecond	' ��������� ������������� ������
	
	
	'--------------------------------------------------------------------------
	' ������������� ����������
	Private Sub Class_Initialize
		m_bIsInitalized = False
		m_dtSrcDateTime = DateSerial( 0,0,0 )
		m_bSetLeadingZero = True
	End Sub
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.Initialize
	'<GROUP !!MEMBERTYPE_Methods_DateTimeFormatter><TITLE Initialize>
	':����������:	
	'	���������� "�������������" �������� ���� � ������� � ���������������
	'	��������� ������������� �� ������.
	':���������:	
	'	dtSrcDateTime - [in] �������� ���� � �����; ���� Null, ������������ 
	'		������� ���� � �����
	'	bSetLeadingZero - [in] ������� ��������� ���������� �������� ���� ��� 
	'		������������ ���������� ������������� ��� ���, ������, �����, �����
	'		� ������ � ��� �������, ����� �������� �������� �������� ���� ����� 
	'		(�.�. ������ 10)
	':����������:	
	'	�������� ��� �������� ���������� ������
	':���������:
	'	Public Sub Initialize( dtSrcDateTime [As Date], bSetLeadingZero [As Boolean] )
	Public Sub Initialize( dtSrcDateTime, bSetLeadingZero )
		' ���������� �������� ��������
		If hasValue(dtSrcDateTime) Then
			m_dtSrcDateTime = dtSrcDateTime
		Else
			m_dtSrcDateTime = Now()
		End If
		m_bSetLeadingZero = bSetLeadingZero
		' �������� ���������� ����� �������������
		innerInitialize()
	End Sub
	
	
	'--------------------------------------------------------------------------
	':����������:	���������� "�������������" ��������� ������������� ������
	'				���� � �������, �������� ���������� ����������.
	':����������:	�������� ��� �������� ���������� ������.
	Private Sub innerInitialize()
		Dim nDay		' ����� ��� � ������
		Dim nDayInWeek	' ����� ��� � ������ (1 - ��� �����������)
		Dim nWeekNum	' ����� ������ � ������ ������
	
		' ��������� ����� ������ � ������ ������
		nDay = Day(m_dtSrcDateTime)
		nDayInWeek = Weekday(m_dtSrcDateTime,vbMonday)
		nWeekNum = 0
		' ���� ���� ������, �����. �������� ����, �� �����������, �� ��������
		' ���� - � �������� ������; ��������� ��� ������ ��� ���� ������ ������
		If ( nDayInWeek <> 7 ) Then ' NB! ������ ���������� � vbSunday, �.�. ��� ������ 1!
			nWeekNum = nWeekNum + 1
			' ...��� ���� "���������" � ������� ���������� ���������� 
			' ����������� - �� ���� ����� ����� ������� "������" ������
			nDay = nDay - nDayInWeek
		End If
		' �� ����������� � �� ������ ������ - ��������� ���-�� "������" ������:
		nWeekNum = nWeekNum + (nDay\7)
		' ��������, ����� ��������� � �������� ������; ������� ����� "���������" 
		' ������ ��� ������ ������:
		If (nDay Mod 7) > 0 Then nWeekNum = nWeekNum + 1
		
		' ��������� ������ �������� ���� � �������:
		m_sYear = CStr( Year(m_dtSrcDateTime) )
		m_sMonth = CStr( Month(m_dtSrcDateTime) )
		m_sDay = CStr( Day(m_dtSrcDateTime) )
		m_sWeekday = CStr( nDayInWeek )
		m_sWeekNum = CStr( nWeekNum )
		m_sHour	= CStr( Hour(m_dtSrcDateTime) )
		m_sMinute = CStr( Minute(m_dtSrcDateTime) )
		m_sSecond = CStr( Second(m_dtSrcDateTime) )
		
		' ���� ���������, ����������� ���������� ������������� ����, ������ 
		' �����, ����� � ������ ����������� ������:
		If m_bSetLeadingZero Then
			m_sMonth = Left( "00", 2-Len(m_sMonth) ) & m_sMonth
			m_sDay = Left( "00", 2-Len(m_sDay) ) & m_sDay
			
			m_sHour	= Left( "00", 2-Len(m_sHour) ) & m_sHour
			m_sMinute = Left( "00", 2-Len(m_sMinute) ) & m_sMinute
			m_sSecond = Left( "00", 2-Len(m_sSecond) ) & m_sSecond
		End If
		
		m_bIsInitalized = True
	End Sub
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.YearString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE YearString>
	':����������:	
	'	���������� ��������� ������������� ������ ����, ��������������� 
	'	�������� ���� (��. �������� SrcDate).
	':����������:	
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get YearString [As String]
	Public Property Get YearString
		If Not m_bIsInitalized Then innerInitialize
		YearString = m_sYear
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.MonthString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE MonthString>
	':����������:	
	'	���������� ��������� ������������� ������ ������, � ������������ �������� 
	'	����� / �������� (��. �������� SrcDate).
	':����������:	
	'	������������� ����� ��������� ���������� ������ ���� -	� ��� ������, 
	'	���� �������� �������� �������� ���� ������; ����� ��������� ������������ 
	'	��������� LeadingZero.<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get MonthString [As String]
	Public Property Get MonthString
		If Not m_bIsInitalized Then innerInitialize
		MonthString = m_sMonth
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.DayString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE DayString>
	':����������:	
	'	���������� ��������� ������������� ��� ������, � ������������ �������� 
	'	����� / �������� (��. �������� SrcDate).
	':����������:	
	'	������������� ����� ��������� ���������� ������ ���� -	� ��� ������, 
	'	���� �������� �������� �������� ���� ������; ����� ��������� ������������ 
	'	��������� LeadingZero.<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get DayString [As String]
	Public Property Get DayString
		If Not m_bIsInitalized Then innerInitialize
		DayString = m_sDay
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.WeekdayString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE WeekdayString>
	':����������:	
	'	���������� ��������� ������������� ������ ��� � ������, ���������������
	'	�������� ���� (��. �������� SrcDate).
	':����������:	
	'	�������� "1" ������������� �����������, "2" - �������, � �.�., �� "7".<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get WeekdayString [As String]
	Public Property Get WeekdayString
		If Not m_bIsInitalized Then innerInitialize
		WeekdayString = m_sWeekday
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.WeekNumString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE WeekNumString>
	':����������:	
	'	���������� ��������� ������������� ������ ������ � ������, � 
	'	������������ � �������� ����� (��. �������� SrcDate).
	':����������:	
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get WeekNumString [As String]
	Public Property Get WeekNumString
		If Not m_bIsInitalized Then innerInitialize
		WeekNumString = m_sWeekNum
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.HourString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE HourString>
	':����������:	
	'	���������� ��������� ������������� ����, � ������������ �������� 
	'	����� / �������� (��. �������� SrcDate).
	':����������:	
	'	������������� ����� ��������� ���������� ������ ���� -	� ��� ������, 
	'	���� �������� �������� �������� ���� ������; ����� ��������� ������������ 
	'	��������� LeadingZero.<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get HourString [As String]
	Public Property Get HourString
		If Not m_bIsInitalized Then innerInitialize
		HourString = m_sHour
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.MinuteString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE MinuteString>
	':����������:	
	'	���������� ��������� ������������� �����, � ������������ �������� 
	'	����� / �������� (��. �������� SrcDate).
	':����������:	
	'	������������� ����� ��������� ���������� ������ ���� -	� ��� ������, 
	'	���� �������� �������� �������� ���� ������; ����� ��������� ������������ 
	'	��������� LeadingZero.<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get MinuteString [As String]
	Public Property Get MinuteString
		If Not m_bIsInitalized Then innerInitialize
		MinuteString = m_sMinute
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.SecondString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE SecondString>
	':����������:	
	'	���������� ��������� ������������� ������, � ������������ �������� 
	'	����� / �������� (��. �������� SrcDate).
	':����������:	
	'	������������� ����� ��������� ���������� ������ ���� -	� ��� ������, 
	'	���� �������� �������� �������� ���� ������; ����� ��������� ������������ 
	'	��������� LeadingZero.<P/>
	'	�������� ������ ��� ������.
	':���������:	
	'	Public Property Get SecondString [As String]
	Public Property Get SecondString
		If Not m_bIsInitalized Then innerInitialize
		SecondString = m_sSecond
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.LeadingZero
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE LeadingZero>
	':����������:	
	'	���������� ����� ���������� ����������� ���� � ��������� �������������� 
	'	����, ������ ������, �����, ����� � ������, � ��� ������, ���� �������� 
	'	�������� �������� ���� ������.
	':����������:	
	'	��������� �������� �������� �������� � ��������� ���� ��������� 
	'	������������� (�������� ������� DateTimeFormatter.YearString, 
	'	DateTimeFormatter.MonthString, DateTimeFormatter.WeekdayString, 
	'	DateTimeFormatter.WeekNumString, DateTimeFormatter.HourString, 
	'	DateTimeFormatter.MinuteString � DateTimeFormatter.SecondString).<P/>
	'	�������� �������� ��� ��� ������, ��� � ��� ���������.
	':���������:	
	'	Public Property Get LeadingZero [As Boolean]
	'	Public Property Let LeadingZero( bUseLeadingZero [As Boolean] )
	Public Property Get LeadingZero
		LeadingZero = m_bSetLeadingZero 
	End Property
	
	Public Property Let LeadingZero( bUseLeadingZero )
		m_bSetLeadingZero = bUseLeadingZero
		m_bIsInitalized = False
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.SrcDate
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE SrcDate>
	':����������:	
	'	�������� �������� ���� / �������, ����� ������� ���������� ���������� 
	'	������ ���� *String.
	':����������:	
	'	��������� �������� �������� �������� � ��������� ���� ��������� 
	'	������������� (�������� ������� DateTimeFormatter.YearString, 
	'	DateTimeFormatter.MonthString, DateTimeFormatter.WeekdayString, 
	'	DateTimeFormatter.WeekNumString, DateTimeFormatter.HourString, 
	'	DateTimeFormatter.MinuteString � DateTimeFormatter.SecondString).<P/>
	'	�������� �������� ��� ��� ������, ��� � ��� ���������.
	':���������:
	'	Public Property Get SrcDate [As Date]
	'	Public Property Let SrcDate( dtValue [As Date] )
	Public Property Get SrcDate
		SrcDate = m_dtSrcDateTime
	End Property
	
	Public Property Let SrcDate( dtValue )
		If hasValue(dtValue) Then
			m_dtSrcDateTime = dtValue
		Else
			m_dtSrcDateTime = Date()
		End If
		m_bIsInitalized = False
	End Property
End Class


'===============================================================================
'@@DateToDateTimeFormatter
'<GROUP !!FUNCTIONS_x-vbs><TITLE DateToDateTimeFormatter>
':����������:	��� �������� ����/������� ��������� ������ DateTimeFormatter.
':���������:    ������������������ ��������� ������ DateTimeFormatter.
':���������:	dtDateTime - [in] �������� ����/�����
':����������:	
'	������������� ����, ������ ������, �����, ����� � ������, ��������������� 
'	�������������� ��������, �������� ���������� ���� (���� ������������� ���� 
'	��� ������ ������ ��������� �������� �������� ���� ������).
':������:
'	Dim oDTF	' As DateTimeFormatter
'	Set oDTF = DateToDateTimeFormatter( Now() )
'	MsgBox oDTF.DayString
':��. �����:	DateTimeFormatter
':���������:	
'	Function DateToDateTimeFormatter( dtDateTime [As Date] ) [As DateTimeFormatter]
Function DateToDateTimeFormatter( dtDateTime )
	Set DateToDateTimeFormatter = new DateTimeFormatter
	DateToDateTimeFormatter.Initialize dtDateTime, True
End Function


'===============================================================================
'@@GetDateValue
'<GROUP !!FUNCTIONS_x-vbs><TITLE GetDateValue>
':����������:	�� ������ ���� ��������� ���� ��� �������.
':���������:	dt - [in] �������� ����
':���������:	
'	����, ��������������� ��������, ��� �������� ������� ����������� � 00:00:00
':���������:
'	Function GetDateValue(dt [As Date] ) [As Date]
Function GetDateValue(dt)
	GetDateValue = DateSerial( Year(dt), Month(dt), Day(dt) )
End Function
