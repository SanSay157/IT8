'���������� ��������� ��� ������� "OutLimit"
Option Explicit

Sub usrXEditor_OnValidate(oSender, oEventArgs)
    Dim oNode       'XMLDOMElement
    Dim oid         'GUID
    With oSender
        oid = .XmlObject.getAttribute("oid")

        '��������� ���������� ����� ������������ ������ � ����� �� �����	
        For Each oNode in .XmlObjectPool.selectNodes("OutLimit")          
            
            '���������� oid ����� ������, �� ���������� ����������� ���� �����, ������� ��� � ����
            If .XmlObject.selectSingleNode("OutType/OutType").getAttribute("oid") = oNode.selectSingleNode("OutType/OutType").getAttribute("oid") And _
                oid <> oNode.getAttribute("oid")then
                oEventArgs.ErrorMessage = "����� � ������ ����� ��� ����������!"
                oEventArgs.ReturnValue = False
                Exit Sub
            End If
        Next
    End With
End Sub