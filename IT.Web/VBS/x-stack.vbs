''
' Класс CStack - стек произвольных объектов
' 


'==============================================================================
' Класс CStack - стек произвольных объектов
' 
Class StackClass   

	''
	' массив - данные стека
	private m_aStack
	''
	' глубина стека		
	private m_nLength

	'--------------------------------------------------------------------------
	' Конструктор объекта
	Private Sub Class_Initialize   
		Const STK_START_SIZE = 8	' начальная глубина стека
		ReDim m_aStack(STK_START_SIZE)	
		m_nLength = 0
	End Sub
	
	'--------------------------------------------------------------------------
	' Очищает стек и переинициализирует его
	Public Sub Clear
		Const STK_START_SIZE = 8	' начальная глубина стека
		Erase m_aStack
		ReDim m_aStack(STK_START_SIZE)
		m_nLength = 0
	End Sub
	
	'--------------------------------------------------------------------------
	' Глубина стека
	' @return глубина стека
	Public Property Get Length
		Length = m_nLength
	End Property
	
	'--------------------------------------------------------------------------
	' Заталкивает значение vVal в стек
	' @param vVal заталкиваемое в стек значение
	Public Sub Push(vVal)
		Const STK_ALLOC_BY = 8		'на сколько увеличивать стековый массив если в нём не хватает места
		If Length+1 > UBound(m_aStack) Then 
			Redim Preserve m_aStack(Length+STK_ALLOC_BY)
		End If
		If IsObject(vVal) Then
			Set m_aStack(Length) = vVal
		Else
			m_aStack(Length) = vVal
		End If
		m_nLength = m_nLength+1	
	End Sub
	
	'--------------------------------------------------------------------------
	' Получение значения с вершины стека без его изъятия из стека
	' @return Значение с вершины стека
	Public Function Top()
		If Length>0 Then
			If IsObject(m_aStack(Length-1)) Then
				Set Top = m_aStack(Length-1)
			Else
			    Top = m_aStack(Length-1)
			End If
		Else
			Top = Empty
		End If
	End Function
	
	'--------------------------------------------------------------------------
	' Взятие значения с вершины стека 
	' @return Значение с вершины стека
	Public Function Pop()
		If Length>0 Then
			If IsObject(m_aStack(Length-1)) Then
				Set Pop = m_aStack(Length-1)
				Set m_aStack(Length-1) = Nothing
			Else
			    Pop = m_aStack(Length-1)
			End If
			m_nLength = m_nLength-1	
		Else
			Pop = Empty
		End If
	End Function
End Class
