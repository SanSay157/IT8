'===============================================================================
'@@!!FILE_x-vbs
'<GROUP !!SYMREF_VBS>
'<TITLE x-vbs - Общие утилитарные функции\, "расширение" VBScript>
':Назначение:
'	Набор общих утилитарных функций, процедур и классов, "расширящих" набор 
'	стандартных функций VBScript.
'===============================================================================
'@@!!FUNCTIONS_x-vbs
'<GROUP !!FILE_x-vbs><TITLE Функции и процедуры>
'@@!!CLASSES_x-vbs
'<GROUP !!FILE_x-vbs><TITLE Классы>


'===============================================================================
'@@SafeCLng
'<GROUP !!FUNCTIONS_x-vbs><TITLE SafeCLng>
':Назначение:	"Безопасное" приведение типа исходного значения к Long.
':Параметры:	vValue - [in] Преобразуемое значение
':Результат:	Число типа Long.
':Замечание:	Если выполнение преобразования невозможно, то функция возвращает 0.
':Сигнатура:	Function SafeCLng( ByVal vValue [As Variant] ) [As Long]
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
':Назначение:	"Безопасное" приведение типа исходного значения к объекту.
':Параметры:	vValue - [in] Преобразуемое значение
':Результат:	Объект
':Замечание:	Если выполнение преобразования невозможно, то функция возвращает Nothing.
':Сигнатура:	Function toObject( ByVal vValue [As Variant] ) [As Object]
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
':Назначение:	Проверка заданного ссылки на объект на "непустоту".
':Параметры:	vValue - Проверяемая ссылка
':Результат:
'	Логическое значение:
'	* <B>False</B> - если значение, задаваемое vValue, есть ссылка на объект, 
'		и не является Nothing;
'	* <B>True</B> - в противном случае.
':Примечание:	
'	Если vValue не является ссылкой на объект, то функция возвращает True.
':Сигнатура:
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
':Назначение:	Определяет, является ли заданное значение определенным.
':Параметры:	vValue - [in] переменная любого типа; может быть ссылкой
':Результат:    True - значение определено, False - в противном случае.
':Примечание:	
'	Значение считается определенным, если это не Empty, не NULL, не Nothing 
'	(для случая ссылки), не строка ненулевой длинны и не непустой массив.
':Сигнатура:	Function hasValue( vValue [As Variant] ) [As Boolean]
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
':Назначение:	Определяет, является ли заданное значение типизированным.
':Результат:    True - значение является типизрованным, False - в противном случае.
':Параметры:	vValue - [in] переменная любого типа; может быть ссылкой
':Примечание:
'	Заданное значение считается типизированным, если оно не Null, не Empty, и не 
'	Nothing. В отличие от hasValue, не проверяет, является ли типизированное 
'	значение пустым (т.е. в случае пустой строки или пустого массива функция 
'	возвращает True, тогда как hasValue - False).
':Сигнатура:	Function IsDefined( vValue [As Variant] ) [As Variant]
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
':Назначение:	Возвращает строковое представление заданного значения.
':Результат:    Строковое представление заданного значения; пустая строка, если
'				заданное значение есть "ничто" (см. комментарии к hasValue).
':Параметры:	vValue - [in] переменная любого типа; может быть ссылкой
':Примечание:	
'	Внимание! Для получения строкового представления используется стандартная
'	функция VBScript <B>CStr</B>. Поэтому, вызов функции с указанием в качестве 
'	параметра ссылки на объект приведет к возникновению ошибки!
':Сигнатура:	Function toString( vValue [As Variant] ) [As Variant]
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
':Назначение:	Returns the first nonnull expression among its arguments
':Параметры:
':Результат:
':Сигнатура:	Function nvl( a [As Variant], b [As Variant] ) [As Variant]
Function nvl( a, b )
	nvl = Coalesce( Array(a,b) )
End Function


'===============================================================================
'@@Coalesce
'<GROUP !!FUNCTIONS_x-vbs><TITLE Coalesce>
':Назначение:	Returns the first nonnull expression among its arguments
':Параметры:
':Результат:
':Сигнатура:	Function Coalesce( aParams [As Array] ) [As Variant]
Function Coalesce(aParams)
    ' Переменной цикла является сама функция
    ' Таким образм происходит присваивание возвращаемого значения
	For Each Coalesce in aParams
		If hasValue(Coalesce) Then Exit Function
	Next
End Function


'===============================================================================
'@@iif
'<GROUP !!FUNCTIONS_x-vbs><TITLE iif>
':Назначение:	Возвращает одно из двух заданных значений, в зависимости от 
'				результата вычисления заданного логического выражения.
':Результат:    Значение параметра vForTrue, если выражение вычисляется как 
'				логическое True, или значение параметра vForFalseв в противном
'				случае.
':Параметры:	bExpression - [in] логическое выражение
'				vForTrue - [in] значение для случая если bExpression есть True
'				vForFalse - [in] значение для случая если bExpression есть False
':Примечание:	Выражение bExpression вычисляется один раз.
':Сигнатура:	
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
':Назначение:	Выполняет сравнение двух заданных значений. 
':Результат:    True - если значения равны, False в противном случае.
':Параметры:	
'	vValueA - [in] первое сравниваемое значение
'	vValueB - [in] второе сравниваемое значение
':Примечание:	
'	Равными считаются одинаковые скаляры (с точностью до приведения типа в VBS), 
'	два "ничто" (см. комментарии к hasValue) или две ссылки на один и тот же
'	объект. Фукнция не выполняет сравнение массивов, для этого используется
'	функция isArrayEqual.
':Сигнатура:	
'	Function isEqual( vValueA [As Variant], vValueB [As Variant] ) [As Boolean]
Function isEqual( vValueA, vValueB )
	isEqual = False
	
	If IsObject(vValueA) Then
		If IsObject(vValueB) Then
		
			' Сравниваются ссылкы на объект:
			If vValueA Is vValueB Then 
				isEqual = True
			End If
			
		End If
	Else
		If Not IsObject(vValueB) Then
			
			' Проверим оба значения на "ничто":
			If hasValue(vValueA) Then
				If hasValue(vValueB) Then 
				
					' Сравнение скаляров: 
					If vValueB = vValueA Then 
						isEqual = True
					End If
					
				End If
				
			Else
				
				' Если оба значения - "ничто", они считаются равными
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
':Назначение:	Определяет, является ли переданное значение целым числом.
':Результат:    True, если заданное значение есть целое число, False в противном случае
':Параметры:	vValue - [in] проверяемое значение
':Примечание:	
'	Функция выполняет попытку явного приведения типа заданного значения к 
'	целочисленному типу, используя системную функцию <B>CLng</B>. Таким образом
'	исходное проверяемое значение может быть строкой.<P/>
'	Внимание! В процессе проверки сбрасывается значение встроенного	объекта Err!
':Сигнатура:	Function isInteger( ByVal vValue [As Variant] ) [As Boolean]
Function isInteger( ByVal vValue )
	isInteger = False
	
	' Проверяемое значение м.б. целым числом только если это не "ничто" 
	' и не ссылка на объект:
	If hasValue(vValue) Then
		If Not IsObject(vValue) Then
			
			' Проверка проводится путем явной конвертации заданного значения 
			' в длинное целое; при этом контролируются ошибки времени выполнения
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
':Назначение:	Определяет, является ли переданное значение значением типа Currency.
':Параметры:	vValue - [in] проверяемое значение
':Результат:	
'	True, если тип значения может быть приведен к Currency, False в противном случае
'	(см. так же раздел "Замечания").
':Примечание:	
'	Функция выполняет попытку явного приведения типа заданного значения к 
'	численному типу (имспользуется функции <B>CCur</B> и <B>CDbl</B>). Таким 
'	образом	исходное проверяемое значение может быть строкой.<P/>
'	Внимание! В процессе проверки сбрасывается значение встроенного	объекта Err!
':Сигнатура:	Function isCurrency( ByVal vValue [As Variant] ) [As Boolean]
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
':Назначение:	Определеяет, соответствует ли переданная строка "нулевому" GUID.
':Результат:    True - если значение есть "нулевой" GUID, False в противном случае.
':Параметры:	sGuid - [in] тестируемое значение, GUID, приведенный в строку
':Примечание:	
'	Если переданное значение есть "ничего" (см. описание функции hasValue), то 
'	функция возварщает True (т.е. пустая строка приравнивается к "нулевому" GUID).
':Сигнатура:	Function isEmptyGuid( ByVal sGuid [As String] ) [As Boolean]
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
':Назначение:	
'	Улучшенный аналог стандартной функции VBScript <B>Split</B>. В отличие от 
'	стандартной функции данная функция <B><I>всегда</I></B> возвращает массив. 
'	В случае, если исходная строка пуста (или "ничто", см. комментарии к hasValue),
'	в качестве результата возвращается пустой массив, не содержащий ни одного 
'	элемента.
':Результат:    Массив, полученный в результате разбиения исходной строки.
':Параметры:	sString - [in] разбиваемая строка
'				sDelimeter - [in] подстрока или символ разделителя
':Пример: 		
'	Dim aTest, vEmpty
'	aTest = splitString( "1;2;34", ";" )	' aTest есть массив с элементами 1, 2 и 34
'	aTest = splitString( vEmpty, ";" )		' aTest есть пустой массив
':Сигнатура:	
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
':Назначение:	Определяет позицию элемента в одномерном массиве.
':Результат:    Индекс элемента в массиве, или <B>-1</B>, если элемент не найден.
':Параметры:	
'	vValue - [in] искомое значение
'	aArray - [in] массив
':Сигнатура:	
'	Function getPosInArray( vValue [As Variant], aArray [As Array] ) [As Int]
Function getPosInArray( vValue, aArray )
	Dim i	' переменная цикла
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
':Назначение:	Добавляет значение в конец массива, увеличивая его размерноть
':Параметры:	
'	vValue - [in] добавляемое значение; может быть массивом, в этом случае в 
'				целевой массив aArray последовательно добавляются все элементы
'	aArray - [in,out] целевой массив, в который добавляется элемент
':Примечание:	
'	В качестве aArray может быть задано "ничто" (см. комментарии к hasValue), 
'	которое интерпретируется как пустой массив.
':См. также:	
'	arraySubtraction, isArrayEqual, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':Сигнатура:	
'	Sub arrayAddition( vValue [As Variant], ByRef aArray [As Array] )
Sub arrayAddition( vValue, ByRef aArray )
	Dim i		' переменная цикла

	' Предварительная проверка параметра: если добавляемое значение есть "ничто" -
	' превращаем его в пустой массив - это позволит "добавлять" значения к 
	' неинициализированным переменным, делая из них т.о. массив:
	If Not hasValue( aArray ) Then aArray = Array()

	' Если vValue - массив, добавляем все его элементы в конец исходного массива:
	If IsArray( vValue ) Then
		ReDim Preserve aArray( UBound(aArray) + UBound(vValue) + 1 )
		For i = LBound(vValue) To UBound(vValue)
			' ...если элемент - объект, то его надо копировать Set'ом:
			If IsObject( vValue(i) ) Then
				Set aArray( UBound(aArray) - UBound(vValue) + i ) = vValue(i)
			Else
				aArray( UBound(aArray) - UBound(vValue) + i ) = vValue(i)
			End If
		Next
	' ...иначе добавляем одно значение:
	Else
		ReDim Preserve aArray( UBound(aArray) + 1 )
			' ...если элемент - объект, то его надо копировать Set'ом:
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
':Назначение:	
'	"Вычитает" из исходного массива заданный массив; возвращает разность и общую 
'	часть (см. секцию замечаний).
':Параметры:	
'	arReduced		- [in] исходный массив (уменьшаемое)
'	arDeducted		- [in] вычитаемый массив (вычитаемое)
'	arDifference	- [out] разность; если разность пустая, то Empty
'	arCommon		- [out] общая часть; если общая часть пустая, то Empty
':Примечание:	
'	В массив разности попадают те елементы, которые присутствуют в исходном 
'	(уменьшаемом) массиве, но отсутствуют в вычитаемом; в общую часть попадают те 
'	элементы, которые были удалены из исходного (уменьшаемого) массива.
':См. также:	
'	arrayAddition, isArrayEqual, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':Сигнатура:	
'	Sub arraySubtraction( 
'		arReduced [As Array], 
'		arDeducted [As Array], 
'		ByRef arDifference [As Array], 
'		ByRef arCommon [As Array] 
'	)
Sub arraySubtraction( arReduced, arDeducted, ByRef arDifference, ByRef arCommon )
	Dim bFound		' флаг, показывающий найден ли элемент arReduced в arDeducted
	Dim i, j		' переменные цикла

	ReDim arCommon( -1 )
	ReDim arDifference( -1 )

	For i = LBound(arReduced) To UBound(arReduced)
		bFound = False
		For j = LBound(arDeducted) To UBound(arDeducted)
		
			' Сравниваем элементы массивов 
			If isEqual( arReduced(i), arDeducted(j) ) Then
				bFound = true
				bIsObject = false
			End If
			
		Next
		
		' Если элемент был найден в вычтиаемом, то копируем его в общую часть...
		If bFound Then
			ReDim Preserve arCommon( UBound(arCommon) + 1 )
			If IsObject( arReduced(i) ) Then
				Set arCommon( UBound(arCommon) ) = arReduced(i)
			Else
				arCommon( UBound(arCommon) ) = arReduced(i)
			End if
		' ...иначе - в разность.
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
':Назначение:	
'	Выполняет поэлементное сравнение массивов. Параметр bOrdered определяет, 
'	сравниваются ли массивы с учетом порядка следования элементов или нет.
':Результат:    True - в случае равенства массивов, False - иначе.
':Параметры:	
'	arFirst		- [in] первый сравниваемый массив ("левый" аргумент сравнения)
'	arSecond	- [in] второй сравниваемый массив ("правый" аргумент сравнения)
'	bOrdered	- [in] определяет порядок учета следования элементов; здесь:
'					* True - сравнение производится с учётом порядка следования.
'					Массивы считаются равными, только если для всех i выполняется:
'					arFirst(i) = arSecond(i);
'					* False - массивы равны, если длины массивов совпадают и при 
'					этом для каждого элемента массива arFirst существует елемент 
'					массива arSecond с таким же значением.
':См. также:	
'	arrayAddition, arraySubtraction, addRefIntoArray, insertRefInfoArray, removeArrayItemByIndex
':Сигнатура:	
'	Function isArrayEqual( 
'		arFirst [As Array], 
'		arSecond [As Array], 
'		bUseOrder [As Boolean] 
'	) [As Boolean]
Function isArrayEqual( arFirst, arSecond, bUseOrder )
	Dim bExists	' флаг существования элемента массива arFirst в массиве arSecond
	Dim i, j	' переменные цикла

	isArrayEqual = True
	
	' В случае не совпадения длин, массивы не равны 
	If ( UBound(arFirst)-LBound(arFirst) ) <> ( UBound(arSecond)-LBound(arSecond) ) Then
		isArrayEqual = False
		
	' В случае сравнения с учетом порядка индексация так же должна совпадать:
	ElseIf bUseOrder And ( UBound(arFirst)<>UBound(arSecond) ) Then
		isArrayEqual = False
		
	Else 
		' Сравниваем элементы:
	
		For i = LBound( arFirst ) To UBound( arFirst ) 
			If bUseOrder Then
				' В режиме сравнения с учётом порядка сравниваем массивы поэлементно;
				' если найдены не равные элементы, значит массивы не равны. При  
				' сравнении учитываем, что элементы могут быть ссылками
				If Not isEqual( arFirst(i),arSecond(i) ) Then
					isArrayEqual = false
					Exit For
				End If 
			Else
				' В режиме сравнения без учёта порядка пытаемся найти каждый элемент 
				' первого массива во втором; если такового нет - массивы не равны:
				bExists = False
				For j = LBound( arSecond ) to UBound( arSecond ) 
					If isEqual( arFirst(i),arSecond(j) ) Then
						bExists = True
						Exit For
					End If
				Next
				' если элемент не найден, массивы не равны.
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
':Назначение:
'	Добавляет в массив переданную ссылку (интерфейс или указатель на функцию)
':Параметры:
'	aArray	- [in] массив, в который добавляется ссылка
'	oRef	- [in] добавляемая ссылка (может быть Nothing)
':См. также:	
'	arrayAddition, arraySubtraction, isArrayEqual, insertRefInfoArray, removeArrayItemByIndex
':Сигнатура:	Sub addRefIntoArray( ByRef aArray [As Array], ByRef oRef [As Object] )
Sub addRefIntoArray( ByRef aArray, ByRef oRef )
	insertRefInfoArray aArray, -1, oRef
End Sub


'===============================================================================
'@@insertRefInfoArray
'<GROUP !!FUNCTIONS_x-vbs><TITLE insertRefInfoArray>
':Назначение:
'	Вставляется в массив переданную ссылку (интерфейс или указатель на функцию),
'	как элемент с заданым индексом.
':Параметры: 
'	aArray	- [in] массив, в который добавляется ссылка
'	nIndex	- [in] индекс добавляемого элемнта массива, в котором будет сохранена ссылка
'	oRef	- [in] добавляетмая ссылка (может быть Nothing)
':Примечание:
'	Если заданный индекс находится за границами массива, то ссылка добавляется 
'	в конец массива, последним элементом.
':См. также:	
'	arrayAddition, arraySubtraction, isArrayEqual, addRefIntoArray, removeArrayItemByIndex
':Сигнатура:	
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
':Назначение:	Удаляет из массива элемент с заданным индексом.
':Параметры:
'	oArray	- [in] массив, в котором удаляется элемент
'	nIndex	- [in] индекс удаляемого элемента
':См. также:	
'	arrayAddition, arraySubtraction, isArrayEqual, addRefIntoArray, insertRefInfoArray
':Сигнатура:
'	Sub removeArrayItemByIndex( ByRef oArray [As Array], ByVal nIndex [As Int] )
Sub removeArrayItemByIndex(ByRef oArray, ByVal nIndex)
	Dim nUpper	' индекс верхнего элемента массива
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
':Назначение:	
'	Получение строки по заданной форматной строке, путем подстановки текстового
'	представления соответствующего параметра в заданную позицию форматной строки.
':Параметры:
'	sFormatString - [in] форматная строка
'	аValues	- [in] массив значений, подставляемых в форматную строку
':Результат:
'	Строка, полученная в результате подстановки значений в форматную строку.
':Примечания:
'	Форматная строка - это строка, в текст которой входят подстановки - строки 
'	вида "(N)", где N - номер подстановки, целое числа, начиная с нуля.<P/>
'	Функция формирует строку путем замены строк подстановки (включая символы 
'	круглых скобок) на текстовое представления элементов из массива aValues, с 
'	индексами, соответствующими номерам подстановок.<P/>
'	В форматной строке допускается включение нескольких подстановок с одним 
'	и тем же индексом; при подстановке все включения такой подстроки будут 
'	заменены на одно и то же значение.<P/>
'	Если для подстановки с номером N в массиве aValues соответствующий элемент
'	отсутствует, то функция генерирует ошибку.
':Пример:
'	Dim sTest
'	sTest = ParseFormatString( _
'		"Это тестовая (0). Значение '(0)' получено при вызове (1)", _
'		Array( "строка","ParseFormatString" ) )
'	' ...в sTest будет "Это тестовая строка. Значение 'строка' получено при вызове ParseFormatString" 
':Сигнатура:
'	Function ParseFormatString( ByVal sFormatString [As String], aValues [As Array] ) [As String]
Function ParseFormatString( ByVal sFormatString, aValues )
	Dim oRegExp		' RegExp
	Dim nIndex		' индекс
	Set oRegExp = New RegExp
	oRegExp.Pattern = "{(\d+)}"
	oRegExp.Multiline = True
	oRegExp.Global = True
	For Each oMatch In oRegExp.Execute(sFormatString)
		nIndex = CLng( oMatch.SubMatches(0) )
		If UBound(aValues) < nIndex Then
			Err.Raise -1, "ParseFormatString", "Размерность массива меньше необходимой"
		End If
		sFormatString = Replace(sFormatString, oMatch.Value, aValues(nIndex))
	Next
	ParseFormatString = sFormatString
End Function


'===============================================================================
'@@ObjectArrayListClass
'<GROUP !!CLASSES_x-vbs><TITLE ObjectArrayListClass>
':Назначение:	Коллекция ссылок на объекты, с произвольным доступом.
'
'@@!!MEMBERTYPE_Methods_ObjectArrayListClass
'<GROUP ObjectArrayListClass><TITLE Методы>
'@@!!MEMBERTYPE_Properties_ObjectArrayListClass
'<GROUP ObjectArrayListClass><TITLE Свойства>
Class ObjectArrayListClass
	Private m_aList		' массив
	Private m_nIndex	' индекс следующего свободного элемента
	
	'--------------------------------------------------------------------------
	Private Sub Class_Initialize
		const ALLOC_SIZE = 8 	' начальный размер массива
		ReDim m_aList(ALLOC_SIZE)
		m_nIndex = 0
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Add
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE Add>
	':Назначение:	Добавляет заданную ссылку на объект в конец коллекции.
	':Параметры:	oObject - [in] добавляемая ссылка на объект
	':Сигнатура:	Public Sub Add( oObject [As Object] )
	Public Sub Add( oObject )
		Dim nNewSize			' новый размер
		Const GROWTH_SIZE = 8	' размер, на который увеличивается массив при достижении потолка

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
	':Назначение:	Вставляет заданную ссылку на объект в коллекцию, в указанную позицию.
	':Параметры:	nIndex	- [in] позиция (индекс), в которую вставляется элемент
	'				oObject	- [in] добавляемая ссылка на объект
	':Сигнатура:	Public Sub Insert( nIndex [As Int], oObject [As Object] )
	Public Sub Insert( nIndex, oObject )
		Dim i
		If nIndex = -1 Or nIndex = m_nIndex Then
			Add oObject
		ElseIf nIndex >= m_nIndex And nIndex<0 Then
			Err.Raise 9, "ObjectArrayListClass", "Индекс за пределами массива"
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
	':Назначение:	Добавляет все элементы заданного массива в конец коллекции.
	':Параметры:	aObjects - [in] массив добавляемых элементов
	':Примечание:	Ожидается, что массив aObjects содержит ссылки на объекты;
	'				специальная проверка типов значений не производится. Массив
	'				aObjects может быть пустым.
	':Сигнатура:	Public Sub AddRange( aObjects [As Array] )
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
	':Назначение:	Удаляет из коллекции все элементы, являющиеся ссылками на заднный объект.
	':Параметры:	oObject - [in] ссылка на объект
	':Сигнатура:	Public Sub Remove( oObject [As Object] )
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
	':Назначение:	Удаляет из коллекции элемент с заданным индексом.
	':Параметры:	nIndex - [in] индекс (позиция) удаляемого элемента коллекции
	':Сигнатура:	Public Sub RemoveAt( nIndex [As Int] )
	Public Sub RemoveAt( nIndex )
		Dim i
		If nIndex<m_nIndex Then
			' сдвинем все последующие элементы за удаляемым к началу
			For i=nIndex To m_nIndex-2
				Set m_aList(i) = m_aList(i+1)
			Next
			' освободим объек, на который указывал послений элемент
			Set m_aList(m_nIndex-1) = Nothing
			m_nIndex = m_nIndex - 1
		End If
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.RemoveAll
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE RemoveAll>
	':Назначение:	Удяляет все элементы коллекции.
	':Сигнатура:	Public Sub RemoveAll
	Public Sub RemoveAll
		Erase m_aList
		m_nIndex = 0
	End Sub
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.IsExists
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE IsExists>
	':Назначение:	Проверяет наличие в коллекции элемента, содержащего 
	'				указанную ссылку на объект.
	':Параметры:	oObject - [in] ссылка на объект, наличие которой проверяется
	':Результат:	True, если в коллекции существует элемент, содержащий 
	'				указанную ссылку, False в противном случае.
	':См. также:	IndexOf
	':Сигнатура:	Public Function IsExists( oObject [As Object] ) [As Boolean]
	Public Function IsExists( oObject )
		IsExists = CBool( IndexOf(oObject)>-1 )
	End Function

	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.IndexOf
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE IndexOf>
	':Назначение:	
	'	Возвращает индекс элемента коллекции, в котором храниться указанная 
	'	ссылка на объект.
	':Параметры:	
	'	oObject - [in] Искомая ссылка на объект
	':Результат:	
	'	Индекс элемента коллекции, в котором храниться ссылка на заданный объект.
	'	Если элемент не найден, функция возвращает <B>-1</B>.
	':Сигнатура:	
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
	':Назначение:	Возвращает массив - копию коллекции.
	':Результат:	Массив, все значения которого есть копии элементов коллекции.
	':Сигнатура:	Public Function GetArray() [As Array]
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
	':Назначение:	Возвращает признак того, пустая ли коллекция или нет.
	':Результат:	True, если коллекция пустая, False - иначе.
	':Сигнатура:	Public Function IsEmpty() [As Boolean]
	Public Function IsEmpty()
		IsEmpty = CBool(m_nIndex=0)
	End Function
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.First
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE First>
	':Назначение:	Возвращает ссылку на объект, сохраненную в первом элементе коллекции.
	':Результат:	Ссылка на объект. 
	':Примечание:	
	'	Свойство только для чтения.<P/>
	'	Если коллекция пуста, то попытка чтения свойства приводит к генерации 
	'	ошибки времени исполнения.
	':См. также:	ObjectArrayListClass.GetAt
	':Сигнатура:	Property Get First [As Object]
	Property Get First
		Set First = GetAt(0)
	End Property
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Last
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE Last>
	':Назначение:	Возвращает ссылку на объект, сохраненную в последнем элементе коллекции.
	':Результат:	Ссылка на объект. 
	':Примечание:	
	'	Свойство только для чтения.<P/>
	'	Если коллекция пуста, то попытка чтения свойства приводит к генерации 
	'	ошибки времени исполнения.
	':См. также:	GetAt
	':Сигнатура:	Property Get Last [As Object]
	Property Get Last
		Set Last = GetAt(m_nIndex-1)			
	End Property
	
	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.Count
	'<GROUP !!MEMBERTYPE_Properties_ObjectArrayListClass><TITLE Count>
	':Назначение:	Возвращает количество элементов в списке.
	':Примечание:	Свойство только для чтения.
	':Сигнатура:	Property Get Count [As Int]
	Property Get Count
		Count = m_nIndex
	End Property

	'--------------------------------------------------------------------------
	'@@ObjectArrayListClass.GetAt
	'<GROUP !!MEMBERTYPE_Methods_ObjectArrayListClass><TITLE GetAt>
	':Назначение:	
	'	Возвращает ссылку на объект, сохраненную в коллекции, в элементе 
	'	с заданным индексом.
	':Параметры:	
	'	nIndex	- [in] индекс элемента, в котором сохранена требуемая ссылка
	':Результат:	
	'	Ссылка на объект, сохраненная в коллекции по указанному индексу nIndex.
	':Примечание:	
	'	Попытка вызова функции с некорректным индексом (вне границ коллекции), а так 
	'	же в случае пустой коллекции, приводит к генерации ошибки времени исполнения.
	':См. также:	ObjectArrayListClass.First, ObjectArrayListClass.Last
	':Сигнатура:	Public Function GetAt( nIndex [As Int] ) [As Object]
	Public Function GetAt( nIndex )
		If nIndex < m_nIndex And nIndex>=0 Then
			Set GetAt = m_aList(nIndex)
		Else
			' 9 - runtime ошибка VBScript "Subscript out of range"
			Err.Raise 9, "ObjectArrayListClass", "Индекс за пределами массива"
		End If
	End Function
End Class


'===============================================================================
'@@DateTimeFormatter
'<GROUP !!CLASSES_x-vbs><TITLE DateTimeFormatter>
':Назначение:	
'	Класс представления частей заданной даты / времени в виде строк.
':Описание:
'	Позволяет получить представление даты, номера месяца, года, часа, минут, 
'	секунд, номера недели в месяце и номера дня в неделе в виде строки. В случае 
'	односимвольных значений позволяет получить представление, включающее
'	лидирующие нули (для даты, номера месяца, часа, минут и секунд).
'
'@@!!MEMBERTYPE_Methods_DateTimeFormatter
'<GROUP DateTimeFormatter><TITLE Методы>
'@@!!MEMBERTYPE_Properties_DateTimeFormatter
'<GROUP DateTimeFormatter><TITLE Свойства>
Class DateTimeFormatter
	Private m_bIsInitalized		' Признак инициализации строковых представлений
	Private m_dtSrcDateTime		' Исходная дата / время
	Private m_bSetLeadingZero	' Признак включения лидирующих нулей 
	
	Private m_sDay		' Строковое представление номера дня (число)
	Private m_sMonth	' Строковое представление номера месяца
	Private m_sYear		' Строковое представление номера года
	Private m_sWeekNum	' Строковое представление номера недели в месяце
	Private m_sWeekday	' Строковое представление дня недели (значение "1" соотв.
						' понедельнику, "2" - вторнику, и т.д. до "7")

	Private m_sHour		' Строковое представление часа
	Private m_sMinute	' Строковое представление минут
	Private m_sSecond	' Строковое представление секунд
	
	
	'--------------------------------------------------------------------------
	' Инициализация экземпляра
	Private Sub Class_Initialize
		m_bIsInitalized = False
		m_dtSrcDateTime = DateSerial( 0,0,0 )
		m_bSetLeadingZero = True
	End Sub
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.Initialize
	'<GROUP !!MEMBERTYPE_Methods_DateTimeFormatter><TITLE Initialize>
	':Назначение:	
	'	Прикладная "инициализация" заданной даты и времени в соответствующие
	'	строковые представление ее частей.
	':Параметры:	
	'	dtSrcDateTime - [in] исходная дата и время; если Null, используется 
	'		текущая дата и время
	'	bSetLeadingZero - [in] признак включения лидирующих символов нуля при 
	'		формировании строкового представления для дня, месяца, часов, минут
	'		и секунд в тех случаях, когда исходное значение содержит одну цифру 
	'		(т.е. меньше 10)
	':Примечание:	
	'	Изменяет все свойства экземпляра класса
	':Сигнатура:
	'	Public Sub Initialize( dtSrcDateTime [As Date], bSetLeadingZero [As Boolean] )
	Public Sub Initialize( dtSrcDateTime, bSetLeadingZero )
		' Запоминаем исходные значения
		If hasValue(dtSrcDateTime) Then
			m_dtSrcDateTime = dtSrcDateTime
		Else
			m_dtSrcDateTime = Now()
		End If
		m_bSetLeadingZero = bSetLeadingZero
		' Вызываем внутренний метод инициализации
		innerInitialize()
	End Sub
	
	
	'--------------------------------------------------------------------------
	':Назначение:	Внутренняя "инициализация" строковых представлений частей
	'				даты и времени, заданных внутренней переменной.
	':Примечание:	Изменяет все свойства экземпляра класса.
	Private Sub innerInitialize()
		Dim nDay		' номер дня в месяце
		Dim nDayInWeek	' номер дня в неделе (1 - это понедельник)
		Dim nWeekNum	' номер недели в данном месяце
	
		' Посчитаем номер недели в данном месяце
		nDay = Day(m_dtSrcDateTime)
		nDayInWeek = Weekday(m_dtSrcDateTime,vbMonday)
		nWeekNum = 0
		' Если день недели, соотв. заданной дате, не воскресенье, то заданная
		' дата - в середине недели; засчитаем эту неделю как одну неделю месяца
		If ( nDayInWeek <> 7 ) Then ' NB! Нельзя сравнивать с vbSunday, т.к. она всегда 1!
			nWeekNum = nWeekNum + 1
			' ...при этом "сдвинемся" в сторону ближайшего прошедшего 
			' воскресенья - от него далее будем считать "полные" недели
			nDay = nDay - nDayInWeek
		End If
		' От воскресенья и до начала месяца - определим кол-во "полных" недель:
		nWeekNum = nWeekNum + (nDay\7)
		' Возможно, месяц начинался с середины недели; считаем такую "частичную" 
		' неделю как неделю месяца:
		If (nDay Mod 7) > 0 Then nWeekNum = nWeekNum + 1
		
		' Выполняем разбор заданной даты и времени:
		m_sYear = CStr( Year(m_dtSrcDateTime) )
		m_sMonth = CStr( Month(m_dtSrcDateTime) )
		m_sDay = CStr( Day(m_dtSrcDateTime) )
		m_sWeekday = CStr( nDayInWeek )
		m_sWeekNum = CStr( nWeekNum )
		m_sHour	= CStr( Hour(m_dtSrcDateTime) )
		m_sMinute = CStr( Minute(m_dtSrcDateTime) )
		m_sSecond = CStr( Second(m_dtSrcDateTime) )
		
		' Если требуется, расставляем полученное представление даты, месяца 
		' часов, минут и секунд лидирующими нулями:
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
	':Назначение:	
	'	Возвращает строковое представление номера года, соответствующее 
	'	исходной дате (см. свойство SrcDate).
	':Примечание:	
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get YearString [As String]
	Public Property Get YearString
		If Not m_bIsInitalized Then innerInitialize
		YearString = m_sYear
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.MonthString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE MonthString>
	':Назначение:	
	'	Возвращает строковое представление номера месяца, в соответствии исходной 
	'	датой / временем (см. свойство SrcDate).
	':Примечание:	
	'	Представление может содержать лидирующий символ нуля -	в том случае, 
	'	если исходное значение содержит один символ; такое включение определяется 
	'	свойством LeadingZero.<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get MonthString [As String]
	Public Property Get MonthString
		If Not m_bIsInitalized Then innerInitialize
		MonthString = m_sMonth
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.DayString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE DayString>
	':Назначение:	
	'	Возвращает строковое представление дня месяца, в соответствии исходной 
	'	датой / временем (см. свойство SrcDate).
	':Примечание:	
	'	Представление может содержать лидирующий символ нуля -	в том случае, 
	'	если исходное значение содержит один символ; такое включение определяется 
	'	свойством LeadingZero.<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get DayString [As String]
	Public Property Get DayString
		If Not m_bIsInitalized Then innerInitialize
		DayString = m_sDay
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.WeekdayString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE WeekdayString>
	':Назначение:	
	'	Возвращает строковое представление номера дня в неделе, соответствующее
	'	исходной дате (см. свойство SrcDate).
	':Примечание:	
	'	Значению "1" соответствует понедельник, "2" - вторник, и т.д., до "7".<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get WeekdayString [As String]
	Public Property Get WeekdayString
		If Not m_bIsInitalized Then innerInitialize
		WeekdayString = m_sWeekday
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.WeekNumString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE WeekNumString>
	':Назначение:	
	'	Возвращает строковое представление номера недели в месяце, в 
	'	соответствии с исходной датой (см. свойство SrcDate).
	':Примечание:	
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get WeekNumString [As String]
	Public Property Get WeekNumString
		If Not m_bIsInitalized Then innerInitialize
		WeekNumString = m_sWeekNum
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.HourString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE HourString>
	':Назначение:	
	'	Возвращает строковое представление часа, в соответствии исходной 
	'	датой / временем (см. свойство SrcDate).
	':Примечание:	
	'	Представление может содержать лидирующий символ нуля -	в том случае, 
	'	если исходное значение содержит один символ; такое включение определяется 
	'	свойством LeadingZero.<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get HourString [As String]
	Public Property Get HourString
		If Not m_bIsInitalized Then innerInitialize
		HourString = m_sHour
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.MinuteString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE MinuteString>
	':Назначение:	
	'	Возвращает строковое представление минут, в соответствии исходной 
	'	датой / временем (см. свойство SrcDate).
	':Примечание:	
	'	Представление может содержать лидирующий символ нуля -	в том случае, 
	'	если исходное значение содержит один символ; такое включение определяется 
	'	свойством LeadingZero.<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get MinuteString [As String]
	Public Property Get MinuteString
		If Not m_bIsInitalized Then innerInitialize
		MinuteString = m_sMinute
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.SecondString
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE SecondString>
	':Назначение:	
	'	Возвращает строковое представление секунд, в соответствии исходной 
	'	датой / временем (см. свойство SrcDate).
	':Примечание:	
	'	Представление может содержать лидирующий символ нуля -	в том случае, 
	'	если исходное значение содержит один символ; такое включение определяется 
	'	свойством LeadingZero.<P/>
	'	Свойство только для чтения.
	':Сигнатура:	
	'	Public Property Get SecondString [As String]
	Public Property Get SecondString
		If Not m_bIsInitalized Then innerInitialize
		SecondString = m_sSecond
	End Property
	
	
	'--------------------------------------------------------------------------
	'@@DateTimeFormatter.LeadingZero
	'<GROUP !!MEMBERTYPE_Properties_DateTimeFormatter><TITLE LeadingZero>
	':Назначение:	
	'	Определяет режим добавления лидирующего нуля в строковых представлениях 
	'	даты, номера месяца, часов, минут и секунд, в том случае, если исходное 
	'	значение содержит один символ.
	':Примечание:	
	'	Изменение значения свойства приведет к пересчету всех строковых 
	'	представлений (значения свойств DateTimeFormatter.YearString, 
	'	DateTimeFormatter.MonthString, DateTimeFormatter.WeekdayString, 
	'	DateTimeFormatter.WeekNumString, DateTimeFormatter.HourString, 
	'	DateTimeFormatter.MinuteString и DateTimeFormatter.SecondString).<P/>
	'	Свойство доступно как для чтения, так и для изменения.
	':Сигнатура:	
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
	':Назначение:	
	'	Исходное значение даты / времени, части которых отражаются свойствами 
	'	класса вида *String.
	':Примечание:	
	'	Изменение значения свойства приведет к пересчету всех строковых 
	'	представлений (значения свойств DateTimeFormatter.YearString, 
	'	DateTimeFormatter.MonthString, DateTimeFormatter.WeekdayString, 
	'	DateTimeFormatter.WeekNumString, DateTimeFormatter.HourString, 
	'	DateTimeFormatter.MinuteString и DateTimeFormatter.SecondString).<P/>
	'	Свойство доступно как для чтения, так и для изменения.
	':Сигнатура:
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
':Назначение:	Для заданной даты/времени формирует объект DateTimeFormatter.
':Результат:    Инициализированный экземпляр класса DateTimeFormatter.
':Параметры:	dtDateTime - [in] исходная дата/время
':Примечание:	
'	Представления даты, номера месяца, часов, минут и секунд, предоставляемых 
'	результирующим объектом, включают лидирующие нули (если представление даты 
'	или номера месяца исходного значения содержит один символ).
':Пример:
'	Dim oDTF	' As DateTimeFormatter
'	Set oDTF = DateToDateTimeFormatter( Now() )
'	MsgBox oDTF.DayString
':См. также:	DateTimeFormatter
':Сигнатура:	
'	Function DateToDateTimeFormatter( dtDateTime [As Date] ) [As DateTimeFormatter]
Function DateToDateTimeFormatter( dtDateTime )
	Set DateToDateTimeFormatter = new DateTimeFormatter
	DateToDateTimeFormatter.Initialize dtDateTime, True
End Function


'===============================================================================
'@@GetDateValue
'<GROUP !!FUNCTIONS_x-vbs><TITLE GetDateValue>
':Назначение:	Из полной даты формирует дату без времени.
':Параметры:	dt - [in] исходная дата
':Результат:	
'	Дата, соответствующая исходной, где значение времени установлено в 00:00:00
':Сигнатура:
'	Function GetDateValue(dt [As Date] ) [As Date]
Function GetDateValue(dt)
	GetDateValue = DateSerial( Year(dt), Month(dt), Day(dt) )
End Function
