''
' ����� CStack - ���� ������������ ��������
' 


'==============================================================================
' ����� CStack - ���� ������������ ��������
' 
Class StackClass   

	''
	' ������ - ������ �����
	private m_aStack
	''
	' ������� �����		
	private m_nLength

	'--------------------------------------------------------------------------
	' ����������� �������
	Private Sub Class_Initialize   
		Const STK_START_SIZE = 8	' ��������� ������� �����
		ReDim m_aStack(STK_START_SIZE)	
		m_nLength = 0
	End Sub
	
	'--------------------------------------------------------------------------
	' ������� ���� � ������������������ ���
	Public Sub Clear
		Const STK_START_SIZE = 8	' ��������� ������� �����
		Erase m_aStack
		ReDim m_aStack(STK_START_SIZE)
		m_nLength = 0
	End Sub
	
	'--------------------------------------------------------------------------
	' ������� �����
	' @return ������� �����
	Public Property Get Length
		Length = m_nLength
	End Property
	
	'--------------------------------------------------------------------------
	' ����������� �������� vVal � ����
	' @param vVal ������������� � ���� ��������
	Public Sub Push(vVal)
		Const STK_ALLOC_BY = 8		'�� ������� ����������� �������� ������ ���� � �� �� ������� �����
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
	' ��������� �������� � ������� ����� ��� ��� ������� �� �����
	' @return �������� � ������� �����
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
	' ������ �������� � ������� ����� 
	' @return �������� � ������� �����
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
