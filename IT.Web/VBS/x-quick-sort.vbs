'===============================================================================
'@@!!FILE_x-quick-sort
'<GROUP !!SYMREF_VBS>
'<TITLE x-quick-sort - ���������� ��������� ������� ����������\, "����������" VBScript>
':����������:
'	���������� ��������� ������� ����������
'===============================================================================
'@@!!FUNCTIONS_x-quick-sort
'<GROUP !!FILE_x-quick-sort><TITLE ������� � ���������>


Option Explicit

'===============================================================================
'@@X_QuickSortArray
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_QuickSortArray>
':����������:	��������� ������� ���������� ������� (QuickSort)
':���������:	
'	aArrayToSort -			[in,out] ���������� ���������� ������
'	oSortCompareFunction -	[in] �������-������� ��� ���������� ������� �������� � 
'								�������������� �������. ������ ����� �������� 
'								SomeFunction(a [As Variant],b [As Variant],vCustomData [As Variant]) [As Boolean]
'								������ ���������� true ���� ������� "�" �.�. ���������� ���� �������� "b"
'	bDesc -					[in] ������� �������� ����������
'	vCustomData -			[in] �������������� ���������������� ������, ������������ � �������-�������
':��. �����:	
'	X_QuickSortArrayPartial, X_AnyCompare, X_StringCompare
':����������:
':���������:	
'	Sub X_QuickSortArray(ByRef aArrayToSort [As Variant()], oSortCompareFunction [As Object], bDesc [As Boolean],  ByRef vCustomData [As Variant])
Sub X_QuickSortArray(ByRef aArrayToSort, oSortCompareFunction, bDesc,  ByRef vCustomData)

	If Not IsArray(aArrayToSort) Then
		' ����������� �� ������!
		Exit Sub
	End If
	
	If 0=(UBound(aArrayToSort)-LBound(aArrayToSort)+1) Then
		' ����������� �� ������!
		Exit Sub
	End If
	
	' � ������ �����������
	X_QuickSortArrayPartial aArrayToSort, _
			oSortCompareFunction, _
			bDesc, _ 
			vCustomData, _ 
			LBound(aArrayToSort), _
			UBound(aArrayToSort), _
			IsObject( aArrayToSort( LBound( aArrayToSort)))
End Sub

'===============================================================================
'@@X_QuickSortArrayPartial
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_QuickSortArrayPartial>
':����������:	��������� ������� ���������� ����� ������� (QuickSort)
':���������:	
'	aArrayToSort -			[in,out] ���������� ���������� ������
'	oSortCompareFunction -	[in] �������-������� ��� ���������� ������� �������� � 
'								�������������� �������. ������ ����� �������� 
'								SomeFunction(a [As Variant],b [As Variant],vCustomData [As Variant]) [As Boolean]
'								������ ���������� true ���� ������� "�" �.�. ���������� ���� �������� "b"
'	bDesc -					[in] ������� �������� ����������
'	vCustomData -			[in] �������������� ���������������� ������, ������������ � �������-�������
'	nLeft -					[in] ������ ������� ������ ����������
'	nRight -				[in] ��������� ������� ������ ����������
'	bIsObjectArray -		[in] ������� ������ � �������� ��������
':��. �����:	
'	X_QuickSortArray, X_AnyCompare, X_StringCompare
':����������:
':���������:	
'	Sub X_QuickSortArrayPartial(ByRef aArrayToSort [As Variant()], oSortCompareFunction [As Object], bDesc [As Boolean],  ByRef vCustomData [As Variant], nLeft [As Long], nRight [As Long], bIsObjectArray [As Boolean] )
Sub X_QuickSortArrayPartial(ByRef aArrayToSort, oSortCompareFunction, bDesc, ByRef vCustomData, _
									nLeft, nRight, bIsObjectArray)
	
	'##################################################################################
	'#                                                                                #
	'#   ��� ����������� ���������� ��������� ������� ����������, ��� ������������!   #
	'#                                                                                #
	'##################################################################################
	'#                                                                                #
	'#   The QuickSort algorithm is explained in thorough detail in the               #
	'#		Visual Basic Language Developer's Handbook                                # 
	'#				by Ken Getz and Mike Gilbert (Sybex, 2000)                        #
	'#                                                                                #
	'##################################################################################
	
	Dim I, J, P, L, R, T
	
	L = nLeft
	R = nRight
	
	Do
		I = L
		J = R
		P = ((L + R) \ 2)
		Do
			If bDesc Then
				While oSortCompareFunction( aArrayToSort(P), aArrayToSort(I), vCustomData)
					I = I + 1
				Wend
				While oSortCompareFunction( aArrayToSort(J), aArrayToSort(P), vCustomData)
					J = J - 1
				Wend
			Else
				While oSortCompareFunction( aArrayToSort(I), aArrayToSort(P), vCustomData)
					I = I + 1
				Wend
				While oSortCompareFunction( aArrayToSort(P), aArrayToSort(J), vCustomData)
					J = J - 1
				Wend
			End If	
			
			If I <= J Then
				If bIsObjectArray Then
					Set T = aArrayToSort(I)
					Set aArrayToSort(I) = aArrayToSort(J)
					Set aArrayToSort(J) = T
					Set T = Nothing
				Else
					T = aArrayToSort(I)
					aArrayToSort(I) = aArrayToSort(J)
					aArrayToSort(J) = T
					T = Null
				End If
				If P = I Then
					P = J
				ElseIf P = J Then
					P = I
				End If
				I = I + 1
				J = J - 1
			End If
		Loop Until I > J
		
		If L < J Then 
			X_QuickSortArrayPartial aArrayToSort, oSortCompareFunction, bDesc, vCustomData, L, J, bIsObjectArray
		End If	
		L = I
	Loop Until I >= R
End Sub

'===============================================================================
'@@X_AnyCompare
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_AnyCompare>
':����������:	������� - ������� ��� ��������� ������������ ��������� ������
':���������:	
'	a -			[in] �������� a
'	b -			[in] �������� b
'	vUseless -	[in] �������������� ��������
':��. �����:	
'	X_QuickSortArray, X_QuickSortArrayPartial, X_StringCompare
':����������:
':���������:	
'	Function X_AnyCompare(a [As Variant],b [As Variant], vUseless [As Variant]) [As Boolean]
':���������:    True - � ������ a<b
Function X_AnyCompare(a,b,vUseless)
	X_AnyCompare = a<b
End Function

'===============================================================================
'@@X_StringCompare
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_StringCompare>
':����������:	������� - ������� ��� ��������� ������������ ��������� ������
':���������:	
'	a -				[in] �������� a
'	b -				[in] �������� b
'	nCompareMode -	[in] ����� ��������� (vbTextCompare ��� vbBinaryCompare)
':��. �����:	
'	X_QuickSortArray, X_QuickSortArrayPartial, X_AnyCompare
':����������:
':���������:
'	Function X_StringCompare(a [As String],b [As String], vUseless [As Long]) [As Boolean]	
':���������:    True - � ������ a<b
Function X_StringCompare(a,b,nCompareMode)
	X_StringCompare=(-1=StrComp(a,b,nCompareMode))
End Function
