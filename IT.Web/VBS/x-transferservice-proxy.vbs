' Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517
Class ExportDataResponse
	Public m_sData
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ExportDataResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ExportDataResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(12)
		Set v(0) = New MemberInfo
		v(0).Name="Data"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ScenarioName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Line1"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line2"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line3"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line4"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="LogFileName"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="Status"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="StartedAt"
		v(8).Prefix="dt"
		v(8).CLRType="DateTime"
		Set v(9) = New MemberInfo
		v(9).Name="FinishedAt"
		v(9).Prefix="dt"
		v(9).CLRType="DateTime"
		Set v(10) = New MemberInfo
		v(10).Name="PercentCompleted"
		v(10).Prefix="n"
		v(10).CLRType="Int32"
		Set v(11) = New MemberInfo
		v(11).Name="SuspendedAt"
		v(11).Prefix="dt"
		v(11).CLRType="DateTime"
		Set v(12) = New MemberInfo
		v(12).Name="ResumeIdleTimeout"
		v(12).Prefix="n"
		v(12).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sData, .selectSingleNode("Data"), "String"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ExportRequest
	Public m_sScenarioName
	Public m_sDestinationFile
	Public m_sHeaderString
	Public m_sScenarioFileId
	Public m_oXmlParams
	Public m_sClientFilePath
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ExportRequest, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ExportRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="ScenarioName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="DestinationFile"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="HeaderString"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="ScenarioFileId"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="XmlParams"
		v(4).Prefix="o"
		v(4).CLRType="XmlElement"
		Set v(5) = New MemberInfo
		v(5).Name="ClientFilePath"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Name"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="SessionID"
		v(7).Prefix="s"
		v(7).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "ScenarioName", m_sScenarioName, "String", false
			.AddParameter "DestinationFile", m_sDestinationFile, "String", false
			.AddParameter "HeaderString", m_sHeaderString, "String", false
			.AddParameter "ScenarioFileId", m_sScenarioFileId, "String", false
			.AddParameter "XmlParams", m_oXmlParams, "XmlElement", false
			.AddParameter "ClientFilePath", m_sClientFilePath, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportCompareObjectsResponse
	Public m_oXmlNewObject
	Public m_oXmlStoredObject
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportCompareObjectsResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportCompareObjectsResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(13)
		Set v(0) = New MemberInfo
		v(0).Name="XmlNewObject"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="XmlStoredObject"
		v(1).Prefix="o"
		v(1).CLRType="XmlElement"
		Set v(2) = New MemberInfo
		v(2).Name="ScenarioName"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line1"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line2"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line3"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Line4"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="LogFileName"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="Status"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="StartedAt"
		v(9).Prefix="dt"
		v(9).CLRType="DateTime"
		Set v(10) = New MemberInfo
		v(10).Name="FinishedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="PercentCompleted"
		v(11).Prefix="n"
		v(11).CLRType="Int32"
		Set v(12) = New MemberInfo
		v(12).Name="SuspendedAt"
		v(12).Prefix="dt"
		v(12).CLRType="DateTime"
		Set v(13) = New MemberInfo
		v(13).Name="ResumeIdleTimeout"
		v(13).Prefix="n"
		v(13).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlNewObject, .selectSingleNode("XmlNewObject"), "XmlElement"
			X_Deserialize m_oXmlStoredObject, .selectSingleNode("XmlStoredObject"), "XmlElement"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportErrorOnSaveResponse
	Public m_oXmlObject
	Public m_sErrDescription
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportErrorOnSaveResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportErrorOnSaveResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(13)
		Set v(0) = New MemberInfo
		v(0).Name="XmlObject"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="ErrDescription"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ScenarioName"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line1"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line2"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line3"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Line4"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="LogFileName"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="Status"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="StartedAt"
		v(9).Prefix="dt"
		v(9).CLRType="DateTime"
		Set v(10) = New MemberInfo
		v(10).Name="FinishedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="PercentCompleted"
		v(11).Prefix="n"
		v(11).CLRType="Int32"
		Set v(12) = New MemberInfo
		v(12).Name="SuspendedAt"
		v(12).Prefix="dt"
		v(12).CLRType="DateTime"
		Set v(13) = New MemberInfo
		v(13).Name="ResumeIdleTimeout"
		v(13).Prefix="n"
		v(13).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlObject, .selectSingleNode("XmlObject"), "XmlElement"
			X_Deserialize m_sErrDescription, .selectSingleNode("ErrDescription"), "String"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportFileDataRequest
	Public m_sData
	Public m_bLastChunk
	Public m_nFileSize
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportFileDataRequest, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportFileDataRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="Data"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="LastChunk"
		v(1).Prefix="b"
		v(1).CLRType="Boolean"
		Set v(2) = New MemberInfo
		v(2).Name="FileSize"
		v(2).Prefix="n"
		v(2).CLRType="Int32"
		Set v(3) = New MemberInfo
		v(3).Name="Name"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="SessionID"
		v(4).Prefix="s"
		v(4).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Data", m_sData, "String", false
			.AddParameter "LastChunk", m_bLastChunk, "Boolean", false
			.AddParameter "FileSize", m_nFileSize, "Int32", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportGetFileResponse
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportGetFileResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportGetFileResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(11)
		Set v(0) = New MemberInfo
		v(0).Name="ScenarioName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Line1"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Line2"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line3"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line4"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="LogFileName"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Status"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="StartedAt"
		v(7).Prefix="dt"
		v(7).CLRType="DateTime"
		Set v(8) = New MemberInfo
		v(8).Name="FinishedAt"
		v(8).Prefix="dt"
		v(8).CLRType="DateTime"
		Set v(9) = New MemberInfo
		v(9).Name="PercentCompleted"
		v(9).Prefix="n"
		v(9).CLRType="Int32"
		Set v(10) = New MemberInfo
		v(10).Name="SuspendedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="ResumeIdleTimeout"
		v(11).Prefix="n"
		v(11).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportRequest
	Public m_sSourceFile
	Public m_sScenarioFileId
	Public m_oXmlParams
	Public m_sClientFilePath
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportRequest, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="SourceFile"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ScenarioFileId"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="XmlParams"
		v(2).Prefix="o"
		v(2).CLRType="XmlElement"
		Set v(3) = New MemberInfo
		v(3).Name="ClientFilePath"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Name"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="SessionID"
		v(5).Prefix="s"
		v(5).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "SourceFile", m_sSourceFile, "String", false
			.AddParameter "ScenarioFileId", m_sScenarioFileId, "String", false
			.AddParameter "XmlParams", m_oXmlParams, "XmlElement", false
			.AddParameter "ClientFilePath", m_sClientFilePath, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ImportUnresolvedResponse
	Public m_oXmlObject
	Public m_sUnreferencedProps
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.ImportUnresolvedResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ImportUnresolvedResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(13)
		Set v(0) = New MemberInfo
		v(0).Name="XmlObject"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="UnreferencedProps"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ScenarioName"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line1"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line2"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line3"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Line4"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="LogFileName"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="Status"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="StartedAt"
		v(9).Prefix="dt"
		v(9).CLRType="DateTime"
		Set v(10) = New MemberInfo
		v(10).Name="FinishedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="PercentCompleted"
		v(11).Prefix="n"
		v(11).CLRType="Int32"
		Set v(12) = New MemberInfo
		v(12).Name="SuspendedAt"
		v(12).Prefix="dt"
		v(12).CLRType="DateTime"
		Set v(13) = New MemberInfo
		v(13).Name="ResumeIdleTimeout"
		v(13).Prefix="n"
		v(13).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlObject, .selectSingleNode("XmlObject"), "XmlElement"
			X_Deserialize m_sUnreferencedProps, .selectSingleNode("UnreferencedProps"), "String"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class TransferServiceErrorResponse
	Public m_sErrorDescription
	Public m_sExceptionString
	Public m_sErrorStatus
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.TransferServiceErrorResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="TransferServiceErrorResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(14)
		Set v(0) = New MemberInfo
		v(0).Name="ErrorDescription"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ExceptionString"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ErrorStatus"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="ScenarioName"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line1"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line2"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Line3"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="Line4"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="LogFileName"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="Status"
		v(9).Prefix="s"
		v(9).CLRType="String"
		Set v(10) = New MemberInfo
		v(10).Name="StartedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="FinishedAt"
		v(11).Prefix="dt"
		v(11).CLRType="DateTime"
		Set v(12) = New MemberInfo
		v(12).Name="PercentCompleted"
		v(12).Prefix="n"
		v(12).CLRType="Int32"
		Set v(13) = New MemberInfo
		v(13).Name="SuspendedAt"
		v(13).Prefix="dt"
		v(13).CLRType="DateTime"
		Set v(14) = New MemberInfo
		v(14).Name="ResumeIdleTimeout"
		v(14).Prefix="n"
		v(14).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sErrorDescription, .selectSingleNode("ErrorDescription"), "String"
			X_Deserialize m_sExceptionString, .selectSingleNode("ExceptionString"), "String"
			X_Deserialize m_sErrorStatus, .selectSingleNode("ErrorStatus"), "String"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class TransferServiceFinishedResponse
	Public m_bSuccess
	Public m_bCloseWindow
	Public m_bWereIgnorableErrors
	Public m_bWasTerminated
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.TransferServiceFinishedResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="TransferServiceFinishedResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(15)
		Set v(0) = New MemberInfo
		v(0).Name="Success"
		v(0).Prefix="b"
		v(0).CLRType="Boolean"
		Set v(1) = New MemberInfo
		v(1).Name="CloseWindow"
		v(1).Prefix="b"
		v(1).CLRType="Boolean"
		Set v(2) = New MemberInfo
		v(2).Name="WereIgnorableErrors"
		v(2).Prefix="b"
		v(2).CLRType="Boolean"
		Set v(3) = New MemberInfo
		v(3).Name="WasTerminated"
		v(3).Prefix="b"
		v(3).CLRType="Boolean"
		Set v(4) = New MemberInfo
		v(4).Name="ScenarioName"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Line1"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Line2"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="Line3"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="Line4"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="LogFileName"
		v(9).Prefix="s"
		v(9).CLRType="String"
		Set v(10) = New MemberInfo
		v(10).Name="Status"
		v(10).Prefix="s"
		v(10).CLRType="String"
		Set v(11) = New MemberInfo
		v(11).Name="StartedAt"
		v(11).Prefix="dt"
		v(11).CLRType="DateTime"
		Set v(12) = New MemberInfo
		v(12).Name="FinishedAt"
		v(12).Prefix="dt"
		v(12).CLRType="DateTime"
		Set v(13) = New MemberInfo
		v(13).Name="PercentCompleted"
		v(13).Prefix="n"
		v(13).CLRType="Int32"
		Set v(14) = New MemberInfo
		v(14).Name="SuspendedAt"
		v(14).Prefix="dt"
		v(14).CLRType="DateTime"
		Set v(15) = New MemberInfo
		v(15).Name="ResumeIdleTimeout"
		v(15).Prefix="n"
		v(15).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_bSuccess, .selectSingleNode("Success"), "Boolean"
			X_Deserialize m_bCloseWindow, .selectSingleNode("CloseWindow"), "Boolean"
			X_Deserialize m_bWereIgnorableErrors, .selectSingleNode("WereIgnorableErrors"), "Boolean"
			X_Deserialize m_bWasTerminated, .selectSingleNode("WasTerminated"), "Boolean"
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class TransferServiceResponse
	Public m_sScenarioName
	Public m_sLine1
	Public m_sLine2
	Public m_sLine3
	Public m_sLine4
	Public m_sLogFileName
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.TransferServiceResponse, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="TransferServiceResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(11)
		Set v(0) = New MemberInfo
		v(0).Name="ScenarioName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Line1"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Line2"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Line3"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Line4"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="LogFileName"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="Status"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="StartedAt"
		v(7).Prefix="dt"
		v(7).CLRType="DateTime"
		Set v(8) = New MemberInfo
		v(8).Name="FinishedAt"
		v(8).Prefix="dt"
		v(8).CLRType="DateTime"
		Set v(9) = New MemberInfo
		v(9).Name="PercentCompleted"
		v(9).Prefix="n"
		v(9).CLRType="Int32"
		Set v(10) = New MemberInfo
		v(10).Name="SuspendedAt"
		v(10).Prefix="dt"
		v(10).CLRType="DateTime"
		Set v(11) = New MemberInfo
		v(11).Name="ResumeIdleTimeout"
		v(11).Prefix="n"
		v(11).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sScenarioName, .selectSingleNode("ScenarioName"), "String"
			X_Deserialize m_sLine1, .selectSingleNode("Line1"), "String"
			X_Deserialize m_sLine2, .selectSingleNode("Line2"), "String"
			X_Deserialize m_sLine3, .selectSingleNode("Line3"), "String"
			X_Deserialize m_sLine4, .selectSingleNode("Line4"), "String"
			X_Deserialize m_sLogFileName, .selectSingleNode("LogFileName"), "String"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class TransferServiceUserAnswerRequest
	Public m_sUserAnswer
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.TransferService.Commands.TransferServiceUserAnswerRequest, Croc.XmlFramework.TransferService.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="TransferServiceUserAnswerRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="UserAnswer"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Name"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="SessionID"
		v(2).Prefix="s"
		v(2).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "UserAnswer", m_sUserAnswer, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class


