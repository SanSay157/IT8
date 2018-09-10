' Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null
Class CheckDatagramRequest
	Public m_sName
	Public m_sSessionID
	Public m_oXmlDatagram
	Public m_aObjectsToCheck

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.CheckDatagramRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="CheckDatagramRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="XmlDatagram"
		v(2).Prefix="o"
		v(2).CLRType="XmlElement"
		Set v(3) = New MemberInfo
		v(3).Name="ObjectsToCheck"
		v(3).Prefix="a"
		v(3).CLRType="XObjectIdentity[]"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "XmlDatagram", m_oXmlDatagram, "XmlElement", false
			.AddParameter "ObjectsToCheck", m_aObjectsToCheck, "XObjectIdentity[]", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class ContractLocatorInTreeRequest
	Public m_sName
	Public m_sSessionID
	Public m_sContractOID
	Public m_sExternalID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.ContractLocatorInTreeRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="ContractLocatorInTreeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ContractOID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		Set v(3) = New MemberInfo
		v(3).Name="ExternalID"
		v(3).Prefix="s"
		v(3).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "ContractOID", m_sContractOID, "Guid", false
			.AddParameter "ExternalID", m_sExternalID, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class DeleteObjectByExKeyRequest
	Public m_sTypeName
	Public m_sDataSourceName
	Public m_oParams
	Public m_sName
	Public m_sSessionID
	Public m_bTreatNotExistsObjectAsDeleted

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.DeleteObjectByExKeyRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="DeleteObjectByExKeyRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="DataSourceName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Params"
		v(2).Prefix="o"
		v(2).CLRType="XParamsCollection"
		Set v(3) = New MemberInfo
		v(3).Name="Name"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="SessionID"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="TreatNotExistsObjectAsDeleted"
		v(5).Prefix="b"
		v(5).CLRType="Boolean"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "DataSourceName", m_sDataSourceName, "String", false
			.AddParameter "Params", m_oParams, "XParamsCollection", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "TreatNotExistsObjectAsDeleted", m_bTreatNotExistsObjectAsDeleted, "Boolean", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class DKPLocatorResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_sPath
	Public m_sObjectID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.DKPLocatorResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="DKPLocatorResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="Path"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="ObjectID"
		v(7).Prefix="s"
		v(7).CLRType="Guid"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_sPath, .selectSingleNode("Path"), "String"
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class DurationInfo
	Public m_nDuration
	Public m_nWorkDayDuration
	Public m_nDays
	Public m_nHours
	Public m_nMinutes
	Public m_sDaysLabel
	Public m_sHoursLabel
	Public m_sMinutesLabel
	Public m_sDurationString

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.DurationInfo, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="DurationInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(8)
		Set v(0) = New MemberInfo
		v(0).Name="Duration"
		v(0).Prefix="n"
		v(0).CLRType="Int32"
		Set v(1) = New MemberInfo
		v(1).Name="WorkDayDuration"
		v(1).Prefix="n"
		v(1).CLRType="Int32"
		Set v(2) = New MemberInfo
		v(2).Name="Days"
		v(2).Prefix="n"
		v(2).CLRType="Int32"
		Set v(3) = New MemberInfo
		v(3).Name="Hours"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="Minutes"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="DaysLabel"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="HoursLabel"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="MinutesLabel"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="DurationString"
		v(8).Prefix="s"
		v(8).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Duration", m_nDuration, "Int32", false
			.AddParameter "WorkDayDuration", m_nWorkDayDuration, "Int32", false
			.AddParameter "Days", m_nDays, "Int32", false
			.AddParameter "Hours", m_nHours, "Int32", false
			.AddParameter "Minutes", m_nMinutes, "Int32", false
			.AddParameter "DaysLabel", m_sDaysLabel, "String", false
			.AddParameter "HoursLabel", m_sHoursLabel, "String", false
			.AddParameter "MinutesLabel", m_sMinutesLabel, "String", false
			.AddParameter "DurationString", m_sDurationString, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_nDuration, .selectSingleNode("Duration"), "Int32"
			X_Deserialize m_nWorkDayDuration, .selectSingleNode("WorkDayDuration"), "Int32"
			X_Deserialize m_nDays, .selectSingleNode("Days"), "Int32"
			X_Deserialize m_nHours, .selectSingleNode("Hours"), "Int32"
			X_Deserialize m_nMinutes, .selectSingleNode("Minutes"), "Int32"
			X_Deserialize m_sDaysLabel, .selectSingleNode("DaysLabel"), "String"
			X_Deserialize m_sHoursLabel, .selectSingleNode("HoursLabel"), "String"
			X_Deserialize m_sMinutesLabel, .selectSingleNode("MinutesLabel"), "String"
			X_Deserialize m_sDurationString, .selectSingleNode("DurationString"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class EmployeeExpenseInfo
	Public m_sEmployeeID
	Public m_nRateExpense
	Public m_nRealExpense

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.EmployeeExpenseInfo, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="EmployeeExpenseInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="EmployeeID"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="RateExpense"
		v(1).Prefix="n"
		v(1).CLRType="Int32"
		Set v(2) = New MemberInfo
		v(2).Name="RealExpense"
		v(2).Prefix="n"
		v(2).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "id", m_sEmployeeID, "String", true
			.AddParameter "rq", m_nRateExpense, "Int32", true
			.AddParameter "rl", m_nRealExpense, "Int32", true
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sEmployeeID, .selectSingleNode("@id"), "String"
			X_Deserialize m_nRateExpense, .selectSingleNode("@rq"), "Int32"
			X_Deserialize m_nRealExpense, .selectSingleNode("@rl"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class EmployeeLocatorInCompanyTreeRequest
	Public m_sName
	Public m_sSessionID
	Public m_sLastName
	Public m_aIgnoredObjects
	Public m_bAllowArchive

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.EmployeeLocatorInCompanyTreeRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="EmployeeLocatorInCompanyTreeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="LastName"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="IgnoredObjects"
		v(3).Prefix="a"
		v(3).CLRType="Guid[]"
		Set v(4) = New MemberInfo
		v(4).Name="AllowArchive"
		v(4).Prefix="b"
		v(4).CLRType="Boolean"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "LastName", m_sLastName, "String", false
			.AddParameter "IgnoredObjects", m_aIgnoredObjects, "Guid[]", false
			.AddParameter "AllowArchive", m_bAllowArchive, "Boolean", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class FactorizeProjectOutcomeRequest
	Public m_sName
	Public m_sSessionID
	Public m_sContractID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.FactorizeProjectOutcomeRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="FactorizeProjectOutcomeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ContractID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "ContractID", m_sContractID, "Guid", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class FactorizeProjectOutcomeResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.FactorizeProjectOutcomeResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="FactorizeProjectOutcomeResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
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

Class FolderLocatorInTreeRequest
	Public m_sName
	Public m_sSessionID
	Public m_sFolderOID
	Public m_sFolderExID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.FolderLocatorInTreeRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="FolderLocatorInTreeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="FolderOID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		Set v(3) = New MemberInfo
		v(3).Name="FolderExID"
		v(3).Prefix="s"
		v(3).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "FolderOID", m_sFolderOID, "Guid", false
			.AddParameter "FolderExID", m_sFolderExID, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetCurrentUserClientProfileResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_nWorkdayDuration
	Public m_sSystemUserID
	Public m_sEmployeeID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetCurrentUserClientProfileResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetCurrentUserClientProfileResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(8)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="WorkdayDuration"
		v(6).Prefix="n"
		v(6).CLRType="Int32"
		Set v(7) = New MemberInfo
		v(7).Name="SystemUserID"
		v(7).Prefix="s"
		v(7).CLRType="Guid"
		Set v(8) = New MemberInfo
		v(8).Name="EmployeeID"
		v(8).Prefix="s"
		v(8).CLRType="Guid"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_nWorkdayDuration, .selectSingleNode("WorkdayDuration"), "Int32"
			X_Deserialize m_sSystemUserID, .selectSingleNode("SystemUserID"), "Guid"
			X_Deserialize m_sEmployeeID, .selectSingleNode("EmployeeID"), "Guid"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetCurrentUserNavInfoResponse
	Public m_oNavigationInfo
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetCurrentUserNavInfoResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetCurrentUserNavInfoResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="NavigationInfo"
		v(0).Prefix="o"
		v(0).CLRType="UserNavigationInfo"
		Set v(1) = New MemberInfo
		v(1).Name="Status"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="StartedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="FinishedAt"
		v(3).Prefix="dt"
		v(3).CLRType="DateTime"
		Set v(4) = New MemberInfo
		v(4).Name="PercentCompleted"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="SuspendedAt"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="ResumeIdleTimeout"
		v(6).Prefix="n"
		v(6).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oNavigationInfo, .selectSingleNode("NavigationInfo"), "UserNavigationInfo"
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

Class GetEmployeesExpensesRequest
	Public m_sName
	Public m_sSessionID
	Public m_sIdentificationMethod
	Public m_sEmployeesIDsList
	Public m_sExceptDepartmentIDsList
	Public m_dtPeriodBegin
	Public m_dtPeriodEnd

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetEmployeesExpensesRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetEmployeesExpensesRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="IdentificationMethod"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="EmployeesIDsList"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="ExceptDepartmentIDsList"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="PeriodBegin"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="PeriodEnd"
		v(6).Prefix="dt"
		v(6).CLRType="DateTime"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "IdentificationMethod", m_sIdentificationMethod, "String", false
			.AddParameter "EmployeesIDsList", m_sEmployeesIDsList, "String", false
			.AddParameter "ExceptDepartmentIDsList", m_sExceptDepartmentIDsList, "String", false
			.AddParameter "PeriodBegin", m_dtPeriodBegin, "DateTime", false
			.AddParameter "PeriodEnd", m_dtPeriodEnd, "DateTime", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetExpensesDataResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_sEmployeeID
	Public m_oPreviousMonth
	Public m_oCurrentMonth
	Public m_oCurrentDay

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetExpensesDataResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetExpensesDataResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(9)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="EmployeeID"
		v(6).Prefix="s"
		v(6).CLRType="Guid"
		Set v(7) = New MemberInfo
		v(7).Name="PreviousMonth"
		v(7).Prefix="o"
		v(7).CLRType="PeriodExpensesInfo"
		Set v(8) = New MemberInfo
		v(8).Name="CurrentMonth"
		v(8).Prefix="o"
		v(8).CLRType="PeriodExpensesInfo"
		Set v(9) = New MemberInfo
		v(9).Name="CurrentDay"
		v(9).Prefix="o"
		v(9).CLRType="PeriodExpensesInfo"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_sEmployeeID, .selectSingleNode("EmployeeID"), "Guid"
			X_Deserialize m_oPreviousMonth, .selectSingleNode("PreviousMonth"), "PeriodExpensesInfo"
			X_Deserialize m_oCurrentMonth, .selectSingleNode("CurrentMonth"), "PeriodExpensesInfo"
			X_Deserialize m_oCurrentDay, .selectSingleNode("CurrentDay"), "PeriodExpensesInfo"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetFilterTendersInfoRequest
	Public m_sSelectedTenderID
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetFilterTendersInfoRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetFilterTendersInfoRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="SelectedTenderID"
		v(0).Prefix="s"
		v(0).CLRType="Guid"
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
			.AddParameter "SelectedTenderID", m_sSelectedTenderID, "Guid", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetFilterTendersInfoResponse
	Public m_sOrganizationID
	Public m_dtDocFeedingDate
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetFilterTendersInfoResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetFilterTendersInfoResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="OrganizationID"
		v(0).Prefix="s"
		v(0).CLRType="Guid"
		Set v(1) = New MemberInfo
		v(1).Name="DocFeedingDate"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="Status"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="StartedAt"
		v(3).Prefix="dt"
		v(3).CLRType="DateTime"
		Set v(4) = New MemberInfo
		v(4).Name="FinishedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="PercentCompleted"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="SuspendedAt"
		v(6).Prefix="dt"
		v(6).CLRType="DateTime"
		Set v(7) = New MemberInfo
		v(7).Name="ResumeIdleTimeout"
		v(7).Prefix="n"
		v(7).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sOrganizationID, .selectSingleNode("OrganizationID"), "Guid"
			X_Deserialize m_dtDocFeedingDate, .selectSingleNode("DocFeedingDate"), "DateTime"
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

Class GetKassBallanceRequest
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetKassBallanceRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetKassBallanceRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(1)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetKassBallanceResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_ssKassBallance

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetKassBallanceResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetKassBallanceResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="sKassBallance"
		v(6).Prefix="s"
		v(6).CLRType="String"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_ssKassBallance, .selectSingleNode("sKassBallance"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetMailMsgInfoRequest
	Public m_sName
	Public m_sSessionID
	Public m_sObjectID
	Public m_sObjectType
	Public m_aEmployeeIDs

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetMailMsgInfoRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetMailMsgInfoRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ObjectID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		Set v(3) = New MemberInfo
		v(3).Name="ObjectType"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="EmployeeIDs"
		v(4).Prefix="a"
		v(4).CLRType="Guid[]"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "ObjectType", m_sObjectType, "String", false
			.AddParameter "EmployeeIDs", m_aEmployeeIDs, "Guid[]", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetMailMsgInfoResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_sTo
	Public m_sSubject
	Public m_sFolderPath
	Public m_sProjectLinks
	Public m_sIncidentLinks

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetMailMsgInfoResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetMailMsgInfoResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(10)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="To"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="Subject"
		v(7).Prefix="s"
		v(7).CLRType="String"
		Set v(8) = New MemberInfo
		v(8).Name="FolderPath"
		v(8).Prefix="s"
		v(8).CLRType="String"
		Set v(9) = New MemberInfo
		v(9).Name="ProjectLinks"
		v(9).Prefix="s"
		v(9).CLRType="String"
		Set v(10) = New MemberInfo
		v(10).Name="IncidentLinks"
		v(10).Prefix="s"
		v(10).CLRType="String"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_sTo, .selectSingleNode("To"), "String"
			X_Deserialize m_sSubject, .selectSingleNode("Subject"), "String"
			X_Deserialize m_sFolderPath, .selectSingleNode("FolderPath"), "String"
			X_Deserialize m_sProjectLinks, .selectSingleNode("ProjectLinks"), "String"
			X_Deserialize m_sIncidentLinks, .selectSingleNode("IncidentLinks"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetObjectByExKeyRequest
	Public m_sTypeName
	Public m_sDataSourceName
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetObjectByExKeyRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetObjectByExKeyRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="DataSourceName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Params"
		v(2).Prefix="o"
		v(2).CLRType="XParamsCollection"
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
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "DataSourceName", m_sDataSourceName, "String", false
			.AddParameter "Params", m_oParams, "XParamsCollection", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetObjectIdByExKeyRequest
	Public m_sTypeName
	Public m_sDataSourceName
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetObjectIdByExKeyRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetObjectIdByExKeyRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="DataSourceName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Params"
		v(2).Prefix="o"
		v(2).CLRType="XParamsCollection"
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
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "DataSourceName", m_sDataSourceName, "String", false
			.AddParameter "Params", m_oParams, "XParamsCollection", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class GetObjectIdByExKeyResponse
	Public m_sObjectID
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetObjectIdByExKeyResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetObjectIdByExKeyResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="ObjectID"
		v(0).Prefix="s"
		v(0).CLRType="Guid"
		Set v(1) = New MemberInfo
		v(1).Name="Status"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="StartedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="FinishedAt"
		v(3).Prefix="dt"
		v(3).CLRType="DateTime"
		Set v(4) = New MemberInfo
		v(4).Name="PercentCompleted"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="SuspendedAt"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="ResumeIdleTimeout"
		v(6).Prefix="n"
		v(6).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
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

Class GetObjectsRightsExResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_aObjectsRights

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.GetObjectsRightsExResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="GetObjectsRightsExResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="ObjectsRights"
		v(6).Prefix="a"
		v(6).CLRType="XObjectRightsDescr[]"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_aObjectsRights, .selectSingleNode("ObjectsRights"), "XObjectRightsDescr[]"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class IncidentLocatorInTreeRequest
	Public m_sName
	Public m_sSessionID
	Public m_sIncidentOID
	Public m_nIncidentNumber

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.IncidentLocatorInTreeRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="IncidentLocatorInTreeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="IncidentOID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		Set v(3) = New MemberInfo
		v(3).Name="IncidentNumber"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "IncidentOID", m_sIncidentOID, "Guid", false
			.AddParameter "IncidentNumber", m_nIncidentNumber, "Int32", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class MoveFolderRequest
	Public m_sName
	Public m_sSessionID
	Public m_aObjectsID
	Public m_sNewParent
	Public m_sNewCustomer
	Public m_sNewActivityType

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.MoveFolderRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="MoveFolderRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ObjectsID"
		v(2).Prefix="a"
		v(2).CLRType="Guid[]"
		Set v(3) = New MemberInfo
		v(3).Name="NewParent"
		v(3).Prefix="s"
		v(3).CLRType="Guid"
		Set v(4) = New MemberInfo
		v(4).Name="NewCustomer"
		v(4).Prefix="s"
		v(4).CLRType="Guid"
		Set v(5) = New MemberInfo
		v(5).Name="NewActivityType"
		v(5).Prefix="s"
		v(5).CLRType="Guid"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "ObjectsID", m_aObjectsID, "Guid[]", false
			.AddParameter "NewParent", m_sNewParent, "Guid", false
			.AddParameter "NewCustomer", m_sNewCustomer, "Guid", false
			.AddParameter "NewActivityType", m_sNewActivityType, "Guid", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class MoveObjectsRequest
	Public m_sName
	Public m_sSessionID
	Public m_sSelectedObjectType
	Public m_aSelectedObjectsID
	Public m_sNewParent
	Public m_sParentPropName
	Public m_sSubTreeSelectorPropName

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.MoveObjectsRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="MoveObjectsRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="SelectedObjectType"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="SelectedObjectsID"
		v(3).Prefix="a"
		v(3).CLRType="Guid[]"
		Set v(4) = New MemberInfo
		v(4).Name="NewParent"
		v(4).Prefix="s"
		v(4).CLRType="Guid"
		Set v(5) = New MemberInfo
		v(5).Name="ParentPropName"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="SubTreeSelectorPropName"
		v(6).Prefix="s"
		v(6).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "SelectedObjectType", m_sSelectedObjectType, "String", false
			.AddParameter "SelectedObjectsID", m_aSelectedObjectsID, "Guid[]", false
			.AddParameter "NewParent", m_sNewParent, "Guid", false
			.AddParameter "ParentPropName", m_sParentPropName, "String", false
			.AddParameter "SubTreeSelectorPropName", m_sSubTreeSelectorPropName, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class NavigationItemIDs

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.NavigationItemIDs, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="NavigationItemIDs"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(-1)
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class PeriodExpensesInfo
	Public m_dtPeriodStartDate
	Public m_dtPerionEndDate
	Public m_bIsOneDayPeriod
	Public m_sPeriodName
	Public m_oExpectedExpense
	Public m_oRealExpense
	Public m_oRemainsExpense
	Public m_sCompleteness

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.PeriodExpensesInfo, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="PeriodExpensesInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="PeriodStartDate"
		v(0).Prefix="dt"
		v(0).CLRType="DateTime"
		Set v(1) = New MemberInfo
		v(1).Name="PerionEndDate"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="IsOneDayPeriod"
		v(2).Prefix="b"
		v(2).CLRType="Boolean"
		Set v(3) = New MemberInfo
		v(3).Name="PeriodName"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="ExpectedExpense"
		v(4).Prefix="o"
		v(4).CLRType="DurationInfo"
		Set v(5) = New MemberInfo
		v(5).Name="RealExpense"
		v(5).Prefix="o"
		v(5).CLRType="DurationInfo"
		Set v(6) = New MemberInfo
		v(6).Name="RemainsExpense"
		v(6).Prefix="o"
		v(6).CLRType="DurationInfo"
		Set v(7) = New MemberInfo
		v(7).Name="Completeness"
		v(7).Prefix="s"
		v(7).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "PeriodStartDate", m_dtPeriodStartDate, "DateTime", false
			.AddParameter "PerionEndDate", m_dtPerionEndDate, "DateTime", false
			.AddParameter "IsOneDayPeriod", m_bIsOneDayPeriod, "Boolean", false
			.AddParameter "PeriodName", m_sPeriodName, "String", false
			.AddParameter "ExpectedExpense", m_oExpectedExpense, "DurationInfo", false
			.AddParameter "RealExpense", m_oRealExpense, "DurationInfo", false
			.AddParameter "RemainsExpense", m_oRemainsExpense, "DurationInfo", false
			.AddParameter "Completeness", m_sCompleteness, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_dtPeriodStartDate, .selectSingleNode("PeriodStartDate"), "DateTime"
			X_Deserialize m_dtPerionEndDate, .selectSingleNode("PerionEndDate"), "DateTime"
			X_Deserialize m_bIsOneDayPeriod, .selectSingleNode("IsOneDayPeriod"), "Boolean"
			X_Deserialize m_sPeriodName, .selectSingleNode("PeriodName"), "String"
			X_Deserialize m_oExpectedExpense, .selectSingleNode("ExpectedExpense"), "DurationInfo"
			X_Deserialize m_oRealExpense, .selectSingleNode("RealExpense"), "DurationInfo"
			X_Deserialize m_oRemainsExpense, .selectSingleNode("RemainsExpense"), "DurationInfo"
			X_Deserialize m_sCompleteness, .selectSingleNode("Completeness"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class TreeLocatorResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout
	Public m_sTreePath
	Public m_sObjectID
	Public m_bMore

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.TreeLocatorResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="TreeLocatorResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(8)
		Set v(0) = New MemberInfo
		v(0).Name="Status"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="StartedAt"
		v(1).Prefix="dt"
		v(1).CLRType="DateTime"
		Set v(2) = New MemberInfo
		v(2).Name="FinishedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="PercentCompleted"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="SuspendedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="ResumeIdleTimeout"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
		Set v(6) = New MemberInfo
		v(6).Name="TreePath"
		v(6).Prefix="s"
		v(6).CLRType="String"
		Set v(7) = New MemberInfo
		v(7).Name="ObjectID"
		v(7).Prefix="s"
		v(7).CLRType="Guid"
		Set v(8) = New MemberInfo
		v(8).Name="More"
		v(8).Prefix="b"
		v(8).CLRType="Boolean"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
			X_Deserialize m_sTreePath, .selectSingleNode("TreePath"), "String"
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
			X_Deserialize m_bMore, .selectSingleNode("More"), "Boolean"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class UpdateActivityStateRequest
	Public m_sName
	Public m_sSessionID
	Public m_sActivity
	Public m_sNewState
	Public m_sDescription
	Public m_sInitiator

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.UpdateActivityStateRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="UpdateActivityStateRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Activity"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		Set v(3) = New MemberInfo
		v(3).Name="NewState"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="Description"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="Initiator"
		v(5).Prefix="s"
		v(5).CLRType="Guid"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "Activity", m_sActivity, "Guid", false
			.AddParameter "NewState", m_sNewState, "String", false
			.AddParameter "Description", m_sDescription, "String", false
			.AddParameter "Initiator", m_sInitiator, "Guid", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class UserNavigationInfo
	Public m_oUsedNavigationItems
	Public m_bUseOwnStartPage
	Public m_sOwnStartPage
	Public m_bShowExpensesPanel
	Public m_nExpensesPanelAutoUpdateDelay

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.UserNavigationInfo, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="UserNavigationInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="UsedNavigationItems"
		v(0).Prefix="o"
		v(0).CLRType="NameValueCollection"
		Set v(1) = New MemberInfo
		v(1).Name="UseOwnStartPage"
		v(1).Prefix="b"
		v(1).CLRType="Boolean"
		Set v(2) = New MemberInfo
		v(2).Name="OwnStartPage"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="ShowExpensesPanel"
		v(3).Prefix="b"
		v(3).CLRType="Boolean"
		Set v(4) = New MemberInfo
		v(4).Name="ExpensesPanelAutoUpdateDelay"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "UsedNavigationItems", m_oUsedNavigationItems, "NameValueCollection", false
			.AddParameter "UseOwnStartPage", m_bUseOwnStartPage, "Boolean", false
			.AddParameter "OwnStartPage", m_sOwnStartPage, "String", false
			.AddParameter "ShowExpensesPanel", m_bShowExpensesPanel, "Boolean", false
			.AddParameter "ExpensesPanelAutoUpdateDelay", m_nExpensesPanelAutoUpdateDelay, "Int32", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oUsedNavigationItems, .selectSingleNode("UsedNavigationItems"), "NameValueCollection"
			X_Deserialize m_bUseOwnStartPage, .selectSingleNode("UseOwnStartPage"), "Boolean"
			X_Deserialize m_sOwnStartPage, .selectSingleNode("OwnStartPage"), "String"
			X_Deserialize m_bShowExpensesPanel, .selectSingleNode("ShowExpensesPanel"), "Boolean"
			X_Deserialize m_nExpensesPanelAutoUpdateDelay, .selectSingleNode("ExpensesPanelAutoUpdateDelay"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class UserSubscriptionForEventClassRequest
	Public m_sName
	Public m_sSessionID
	Public m_sAction
	Public m_nEventClass

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.UserSubscriptionForEventClassRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="UserSubscriptionForEventClassRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SessionID"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Action"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="EventClass"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "Action", m_sAction, "String", false
			.AddParameter "EventClass", m_nEventClass, "Int32", false
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XObjectRightsDescr
	Public m_aReadOnlyProps
	Public m_bDenyDelete
	Public m_bDenyChange
	Public m_bDenyCreate

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.IncidentTracker.Commands.XObjectRightsDescr, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XObjectRightsDescr"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="ReadOnlyProps"
		v(0).Prefix="a"
		v(0).CLRType="String[]"
		Set v(1) = New MemberInfo
		v(1).Name="DenyDelete"
		v(1).Prefix="b"
		v(1).CLRType="Boolean"
		Set v(2) = New MemberInfo
		v(2).Name="DenyChange"
		v(2).Prefix="b"
		v(2).CLRType="Boolean"
		Set v(3) = New MemberInfo
		v(3).Name="DenyCreate"
		v(3).Prefix="b"
		v(3).CLRType="Boolean"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "ReadOnlyProps", m_aReadOnlyProps, "String[]", false
			.AddParameter "DenyDelete", m_bDenyDelete, "Boolean", false
			.AddParameter "DenyChange", m_bDenyChange, "Boolean", false
			.AddParameter "DenyCreate", m_bDenyCreate, "Boolean", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_aReadOnlyProps, .selectSingleNode("ReadOnlyProps"), "String[]"
			X_Deserialize m_bDenyDelete, .selectSingleNode("DenyDelete"), "Boolean"
			X_Deserialize m_bDenyChange, .selectSingleNode("DenyChange"), "Boolean"
			X_Deserialize m_bDenyCreate, .selectSingleNode("DenyCreate"), "Boolean"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XXGetNodeDragResponse
	Public m_oXmlNodeDrag
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Extension.Commands.XXGetNodeDragResponse, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XXGetNodeDragResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="XmlNodeDrag"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="Status"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="StartedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="FinishedAt"
		v(3).Prefix="dt"
		v(3).CLRType="DateTime"
		Set v(4) = New MemberInfo
		v(4).Name="PercentCompleted"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="SuspendedAt"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="ResumeIdleTimeout"
		v(6).Prefix="n"
		v(6).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlNodeDrag, .selectSingleNode("XmlNodeDrag"), "XmlElement"
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

Class XXGetTreeNodeDragRequest
	Public m_sMetaName
	Public m_oPath
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Extension.Commands.XXGetTreeNodeDragRequest, Croc.IncidentTracker.Commands.Interop, Version=9.0.1.0, Culture=neutral, PublicKeyToken=null"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XXGetTreeNodeDragRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="MetaName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Path"
		v(1).Prefix="o"
		v(1).CLRType="XTreePath"
		Set v(2) = New MemberInfo
		v(2).Name="Params"
		v(2).Prefix="o"
		v(2).CLRType="XParamsCollection"
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
			.AddParameter "MetaName", m_sMetaName, "String", false
			.AddParameter "Path", m_oPath, "XTreePath", false
			.AddParameter "Params", m_oParams, "XParamsCollection", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class


