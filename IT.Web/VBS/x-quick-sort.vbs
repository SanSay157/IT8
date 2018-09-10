'===============================================================================
'@@!!FILE_x-quick-sort
'<GROUP !!SYMREF_VBS>
'<TITLE x-quick-sort - Реализация алгоритма быстрой сортировки\, "расширение" VBScript>
':Назначение:
'	Реализация алгоритма быстрой сортировки
'===============================================================================
'@@!!FUNCTIONS_x-quick-sort
'<GROUP !!FILE_x-quick-sort><TITLE Функции и процедуры>


Option Explicit

'===============================================================================
'@@X_QuickSortArray
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_QuickSortArray>
':Назначение:	Процедура быстрой сортировки массива (QuickSort)
':Параметры:	
'	aArrayToSort -			[in,out] подлежащий сортировке массив
'	oSortCompareFunction -	[in] функция-делегат для вычисления позиции элемента в 
'								результирующем массиве. Должна иметь прототип 
'								SomeFunction(a [As Variant],b [As Variant],vCustomData [As Variant]) [As Boolean]
'								должна возвращать true если элемент "а" д.б. расположен выше элемента "b"
'	bDesc -					[in] признак обратной сортировки
'	vCustomData -			[in] дополнительные пользовательские данные, передаваемые в функцию-делегат
':См. также:	
'	X_QuickSortArrayPartial, X_AnyCompare, X_StringCompare
':Примечание:
':Сигнатура:	
'	Sub X_QuickSortArray(ByRef aArrayToSort [As Variant()], oSortCompareFunction [As Object], bDesc [As Boolean],  ByRef vCustomData [As Variant])
Sub X_QuickSortArray(ByRef aArrayToSort, oSortCompareFunction, bDesc,  ByRef vCustomData)

	If Not IsArray(aArrayToSort) Then
		' Сортировать то нечего!
		Exit Sub
	End If
	
	If 0=(UBound(aArrayToSort)-LBound(aArrayToSort)+1) Then
		' Сортировать то нечего!
		Exit Sub
	End If
	
	' А теперь отсортируем
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
':Назначение:	Процедура быстрой сортировки части массива (QuickSort)
':Параметры:	
'	aArrayToSort -			[in,out] подлежащий сортировке массив
'	oSortCompareFunction -	[in] функция-делегат для вычисления позиции элемента в 
'								результирующем массиве. Должна иметь прототип 
'								SomeFunction(a [As Variant],b [As Variant],vCustomData [As Variant]) [As Boolean]
'								должна возвращать true если элемент "а" д.б. расположен выше элемента "b"
'	bDesc -					[in] признак обратной сортировки
'	vCustomData -			[in] дополнительные пользовательские данные, передаваемые в функцию-делегат
'	nLeft -					[in] первый элемент границ сортировки
'	nRight -				[in] последний элемент границ сортировки
'	bIsObjectArray -		[in] признак работы с массивом объектов
':См. также:	
'	X_QuickSortArray, X_AnyCompare, X_StringCompare
':Примечание:
':Сигнатура:	
'	Sub X_QuickSortArrayPartial(ByRef aArrayToSort [As Variant()], oSortCompareFunction [As Object], bDesc [As Boolean],  ByRef vCustomData [As Variant], nLeft [As Long], nRight [As Long], bIsObjectArray [As Boolean] )
Sub X_QuickSortArrayPartial(ByRef aArrayToSort, oSortCompareFunction, bDesc, ByRef vCustomData, _
									nLeft, nRight, bIsObjectArray)
	
	'##################################################################################
	'#                                                                                #
	'#   Это стандартная реализация алгоритма быстрой сортировки, без комментариев!   #
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
':Назначение:	Функция - делегат для сравнения произвольных скалярных данных
':Параметры:	
'	a -			[in] параметр a
'	b -			[in] параметр b
'	vUseless -	[in] неиспользуемый параметр
':См. также:	
'	X_QuickSortArray, X_QuickSortArrayPartial, X_StringCompare
':Примечание:
':Сигнатура:	
'	Function X_AnyCompare(a [As Variant],b [As Variant], vUseless [As Variant]) [As Boolean]
':Результат:    True - в случае a<b
Function X_AnyCompare(a,b,vUseless)
	X_AnyCompare = a<b
End Function

'===============================================================================
'@@X_StringCompare
'<GROUP !!FUNCTIONS_x-quick-sort><TITLE X_StringCompare>
':Назначение:	Функция - делегат для сравнения произвольных строковых данных
':Параметры:	
'	a -				[in] параметр a
'	b -				[in] параметр b
'	nCompareMode -	[in] режим сравнения (vbTextCompare или vbBinaryCompare)
':См. также:	
'	X_QuickSortArray, X_QuickSortArrayPartial, X_AnyCompare
':Примечание:
':Сигнатура:
'	Function X_StringCompare(a [As String],b [As String], vUseless [As Long]) [As Boolean]	
':Результат:    True - в случае a<b
Function X_StringCompare(a,b,nCompareMode)
	X_StringCompare=(-1=StrComp(a,b,nCompareMode))
End Function
