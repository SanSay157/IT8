'Обработчик редактора для объекта "Contract"
Option Explicit



Dim g_oObjectEditor			' текущий редактор (устанавливается один раз в OnLoad)
Dim g_oPool					' текущий пул (устанавливается один раз в OnLoad)



' ::Загрузка редактора
Sub usrXEditor_OnLoad(oSender, oEventArgs)
    Set g_oObjectEditor = oSender
	Set g_oPool = oSender.Pool
End Sub

''==============================================================================
'' :: Установка заголовка редактора
Sub usrXEditor_OnSetCaption( oSender, oEventArgs )
    Dim  sCaption
    Dim  oXmlObject
    Dim  sExternalID
    Dim  sEditorMode

    

    If g_oObjectEditor.IsObjectCreationMode Then
		'sEditorMode = "Создание"
	Else
        sExternalID = g_oPool.Xml.selectSingleNode("Folder/ExternalID").nodeTypedValue
		sEditorMode = "Редактирование"
        sCaption = "<TABLE CELLPADDING='0' CELLSPACING='3' STYLE='color:#fff;' WIDTH='100%'>" & _
				"<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=3 STYLE='font-size:14pt;'>Приходный договор: " & sEditorMode & "</TD></TR>" & _
                "<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=3 STYLE='font-size:12pt;'>Проект: " & g_oPool.Xml.selectSingleNode("Folder/Name").nodeTypedValue & "</TD></TR>" & _
                "<TR><TD>&nbsp;&nbsp;</TD><TD COLSPAN=3 STYLE='font-size:12pt;'>Код проекта: " & sExternalID & "</TD></TR>"
        sCaption = sCaption & "</TABLE>"
        oEventArgs.EditorCaption = sCaption
	End If
    
	
End Sub


Sub usrXEditor_OnPageEnd(oSender, oEventArgs)
    oSender.Pool.GetXmlProperty(oSender.XmlObject, "OutContracts").RemoveAttribute "dirty"
    oSender.Pool.GetXmlProperty(oSender.XmlObject, "IncDocs").RemoveAttribute "dirty"
    oSender.Pool.GetXmlProperty(oSender.XmlObject, "OutDocs").RemoveAttribute "dirty"    
End Sub