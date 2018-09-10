' Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517
Class XCommandProfile
	Public m_sName
	Public m_sDescription

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XCommandProfile, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XCommandProfile"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(1)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Description"
		v(1).Prefix="s"
		v(1).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", false
			.AddParameter "Description", m_sDescription, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sName, .selectSingleNode("Name"), "String"
			X_Deserialize m_sDescription, .selectSingleNode("Description"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XObjectData
	Public m_oXmlData
	Public m_sTypeName

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XObjectData, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XObjectData"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(1)
		Set v(0) = New MemberInfo
		v(0).Name="XmlData"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="TypeName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "XmlData", m_oXmlData, "XmlElement", false
			.AddParameter "TypeName", m_sTypeName, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlData, .selectSingleNode("XmlData"), "XmlElement"
			X_Deserialize m_sTypeName, .selectSingleNode("@TypeName"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XRequest
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XRequest, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XRequest"
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

Class XRequestData
	Public m_oXmlData
	Public m_sTypeName

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XRequestData, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XRequestData"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(1)
		Set v(0) = New MemberInfo
		v(0).Name="XmlData"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="TypeName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "XmlData", m_oXmlData, "XmlElement", false
			.AddParameter "TypeName", m_sTypeName, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlData, .selectSingleNode("XmlData"), "XmlElement"
			X_Deserialize m_sTypeName, .selectSingleNode("@TypeName"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XResponse, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XResponse"
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

Class XResponseData
	Public m_oXmlData
	Public m_sTypeName

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XResponseData, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XResponseData"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(1)
		Set v(0) = New MemberInfo
		v(0).Name="XmlData"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="TypeName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "XmlData", m_oXmlData, "XmlElement", false
			.AddParameter "TypeName", m_sTypeName, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlData, .selectSingleNode("XmlData"), "XmlElement"
			X_Deserialize m_sTypeName, .selectSingleNode("@TypeName"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XRunningCommandInfo
	Public m_oProfile
	Public m_sName
	Public m_sDescription
	Public m_sID
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_sSessionID
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XRunningCommandInfo, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XRunningCommandInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(10)
		Set v(0) = New MemberInfo
		v(0).Name="Profile"
		v(0).Prefix="o"
		v(0).CLRType="XCommandProfile"
		Set v(1) = New MemberInfo
		v(1).Name="Name"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Description"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="ID"
		v(3).Prefix="s"
		v(3).CLRType="Guid"
		Set v(4) = New MemberInfo
		v(4).Name="Status"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="StartedAt"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="FinishedAt"
		v(6).Prefix="dt"
		v(6).CLRType="DateTime"
		Set v(7) = New MemberInfo
		v(7).Name="PercentCompleted"
		v(7).Prefix="n"
		v(7).CLRType="Int32"
		Set v(8) = New MemberInfo
		v(8).Name="SuspendedAt"
		v(8).Prefix="dt"
		v(8).CLRType="DateTime"
		Set v(9) = New MemberInfo
		v(9).Name="SessionID"
		v(9).Prefix="s"
		v(9).CLRType="String"
		Set v(10) = New MemberInfo
		v(10).Name="ResumeIdleTimeout"
		v(10).Prefix="n"
		v(10).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Profile", m_oProfile, "XCommandProfile", false
			.AddParameter "Name", m_sName, "String", false
			.AddParameter "Description", m_sDescription, "String", false
			.AddParameter "ID", m_sID, "Guid", false
			.AddParameter "Status", m_sStatus, "String", false
			.AddParameter "StartedAt", m_dtStartedAt, "DateTime", false
			.AddParameter "FinishedAt", m_dtFinishedAt, "DateTime", false
			.AddParameter "PercentCompleted", m_nPercentCompleted, "Int32", false
			.AddParameter "SuspendedAt", m_dtSuspendedAt, "DateTime", false
			.AddParameter "SessionID", m_sSessionID, "String", false
			.AddParameter "ResumeIdleTimeout", m_nResumeIdleTimeout, "Int32", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oProfile, .selectSingleNode("Profile"), "XCommandProfile"
			X_Deserialize m_sName, .selectSingleNode("Name"), "String"
			X_Deserialize m_sDescription, .selectSingleNode("Description"), "String"
			X_Deserialize m_sID, .selectSingleNode("ID"), "Guid"
			X_Deserialize m_sStatus, .selectSingleNode("Status"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("StartedAt"), "DateTime"
			X_Deserialize m_dtFinishedAt, .selectSingleNode("FinishedAt"), "DateTime"
			X_Deserialize m_nPercentCompleted, .selectSingleNode("PercentCompleted"), "Int32"
			X_Deserialize m_dtSuspendedAt, .selectSingleNode("SuspendedAt"), "DateTime"
			X_Deserialize m_sSessionID, .selectSingleNode("SessionID"), "String"
			X_Deserialize m_nResumeIdleTimeout, .selectSingleNode("ResumeIdleTimeout"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSerializableXml
	Public m_oXml

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XSerializableXml, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSerializableXml"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(0)
		Set v(0) = New MemberInfo
		v(0).Name="Xml"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Xml", m_oXml, "XmlElement", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXml, .selectSingleNode("Xml"), "XmlElement"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSessionInfo
	Public m_sSessionID
	Public m_sOwnerIdentityName
	Public m_dtStartedAt
	Public m_dtLastAccessedAt

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XSessionInfo, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSessionInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="SessionID"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="OwnerIdentityName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="StartedAt"
		v(2).Prefix="dt"
		v(2).CLRType="DateTime"
		Set v(3) = New MemberInfo
		v(3).Name="LastAccessedAt"
		v(3).Prefix="dt"
		v(3).CLRType="DateTime"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "SessionID", m_sSessionID, "String", true
			.AddParameter "OwnerIdentityName", m_sOwnerIdentityName, "String", true
			.AddParameter "StartedAt", m_dtStartedAt, "DateTime", true
			.AddParameter "LastAccessedAt", m_dtLastAccessedAt, "DateTime", true
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sSessionID, .selectSingleNode("@SessionID"), "String"
			X_Deserialize m_sOwnerIdentityName, .selectSingleNode("@OwnerIdentityName"), "String"
			X_Deserialize m_dtStartedAt, .selectSingleNode("@StartedAt"), "DateTime"
			X_Deserialize m_dtLastAccessedAt, .selectSingleNode("@LastAccessedAt"), "DateTime"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XVersion
	Public m_nMajor
	Public m_nMinor
	Public m_nBuild
	Public m_nRevision

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Public.XVersion, Croc.XmlFramework.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XVersion"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="Major"
		v(0).Prefix="n"
		v(0).CLRType="Int32"
		Set v(1) = New MemberInfo
		v(1).Name="Minor"
		v(1).Prefix="n"
		v(1).CLRType="Int32"
		Set v(2) = New MemberInfo
		v(2).Name="Build"
		v(2).Prefix="n"
		v(2).CLRType="Int32"
		Set v(3) = New MemberInfo
		v(3).Name="Revision"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Major", m_nMajor, "Int32", false
			.AddParameter "Minor", m_nMinor, "Int32", false
			.AddParameter "Build", m_nBuild, "Int32", false
			.AddParameter "Revision", m_nRevision, "Int32", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_nMajor, .selectSingleNode("Major"), "Int32"
			X_Deserialize m_nMinor, .selectSingleNode("Minor"), "Int32"
			X_Deserialize m_nBuild, .selectSingleNode("Build"), "Int32"
			X_Deserialize m_nRevision, .selectSingleNode("Revision"), "Int32"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class


' Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517
Class XAssemblyVersion
	Public m_sFileName
	Public m_oVersion
	Public m_bIsGlobal

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XAssemblyVersion, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XAssemblyVersion"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="FileName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Version"
		v(1).Prefix="o"
		v(1).CLRType="XVersion"
		Set v(2) = New MemberInfo
		v(2).Name="IsGlobal"
		v(2).Prefix="b"
		v(2).CLRType="Boolean"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "FileName", m_sFileName, "String", false
			.AddParameter "Version", m_oVersion, "XVersion", false
			.AddParameter "IsGlobal", m_bIsGlobal, "Boolean", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sFileName, .selectSingleNode("FileName"), "String"
			X_Deserialize m_oVersion, .selectSingleNode("Version"), "XVersion"
			X_Deserialize m_bIsGlobal, .selectSingleNode("IsGlobal"), "Boolean"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XChunkPurgeRequest
	Public m_sTransactionID
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XChunkPurgeRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XChunkPurgeRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="TransactionID"
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
			.AddParameter "TransactionID", m_sTransactionID, "Guid", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XChunkUploadRequest
	Public m_sTransactionID
	Public m_sOwnerID
	Public m_aChunkData
	Public m_sChunkText
	Public m_nOrderIndex
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XChunkUploadRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XChunkUploadRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="TransactionID"
		v(0).Prefix="s"
		v(0).CLRType="Guid"
		Set v(1) = New MemberInfo
		v(1).Name="OwnerID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="ChunkData"
		v(2).Prefix="a"
		v(2).CLRType="Byte[]"
		Set v(3) = New MemberInfo
		v(3).Name="ChunkText"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="OrderIndex"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="Name"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="SessionID"
		v(6).Prefix="s"
		v(6).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "TransactionID", m_sTransactionID, "Guid", false
			.AddParameter "OwnerID", m_sOwnerID, "Guid", false
			.AddParameter "ChunkData", m_aChunkData, "Byte[]", false
			.AddParameter "ChunkText", m_sChunkText, "String", false
			.AddParameter "OrderIndex", m_nOrderIndex, "Int32", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XColumnInfo
	Public m_sName
	Public m_sTitle
	Public m_sAlignment
	Public m_nWidth
	Public m_sOrderBy
	Public m_sVarType

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XColumnInfo, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XColumnInfo"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="Name"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Title"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Alignment"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Width"
		v(3).Prefix="n"
		v(3).CLRType="Int32"
		Set v(4) = New MemberInfo
		v(4).Name="OrderBy"
		v(4).Prefix="s"
		v(4).CLRType="String"
		Set v(5) = New MemberInfo
		v(5).Name="VarType"
		v(5).Prefix="s"
		v(5).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Name", m_sName, "String", false
			.AddParameter "Title", m_sTitle, "String", false
			.AddParameter "Alignment", m_sAlignment, "String", false
			.AddParameter "Width", m_nWidth, "Int32", false
			.AddParameter "OrderBy", m_sOrderBy, "String", false
			.AddParameter "VarType", m_sVarType, "String", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sName, .selectSingleNode("Name"), "String"
			X_Deserialize m_sTitle, .selectSingleNode("Title"), "String"
			X_Deserialize m_sAlignment, .selectSingleNode("Alignment"), "String"
			X_Deserialize m_nWidth, .selectSingleNode("Width"), "Int32"
			X_Deserialize m_sOrderBy, .selectSingleNode("OrderBy"), "String"
			X_Deserialize m_sVarType, .selectSingleNode("VarType"), "String"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XDataTableSerializableWrapper
	Public m_oXmlDataTable

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XDataTableSerializableWrapper, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XDataTableSerializableWrapper"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(0)
		Set v(0) = New MemberInfo
		v(0).Name="XmlDataTable"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "XmlDataTable", m_oXmlDataTable, "XmlElement", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlDataTable, .selectSingleNode("XmlDataTable"), "XmlElement"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XDeleteObjectRequest
	Public m_sTypeName
	Public m_sObjectID
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XDeleteObjectRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XDeleteObjectRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ObjectID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="Name"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="SessionID"
		v(3).Prefix="s"
		v(3).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XDeleteObjectResponse
	Public m_nDeletedObjectQnt
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XDeleteObjectResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XDeleteObjectResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="DeletedObjectQnt"
		v(0).Prefix="n"
		v(0).CLRType="Int32"
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
			X_Deserialize m_nDeletedObjectQnt, .selectSingleNode("DeletedObjectQnt"), "Int32"
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

Class XExecuteDataSourceRequest
	Public m_sDataSourceName
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XExecuteDataSourceRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XExecuteDataSourceRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="DataSourceName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="Params"
		v(1).Prefix="o"
		v(1).CLRType="XParamsCollection"
		Set v(2) = New MemberInfo
		v(2).Name="Name"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="SessionID"
		v(3).Prefix="s"
		v(3).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
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

Class XExecuteDataSourceResponse
	Public m_oDataWrapped
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XExecuteDataSourceResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XExecuteDataSourceResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="DataWrapped"
		v(0).Prefix="o"
		v(0).CLRType="XDataTableSerializableWrapper"
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
			X_Deserialize m_oDataWrapped, .selectSingleNode("DataWrapped"), "XDataTableSerializableWrapper"
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

Class XGetAnySessionVariableRequest
	Public m_sDestinationSessionID
	Public m_sVariableName
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetAnySessionVariableRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetAnySessionVariableRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(3)
		Set v(0) = New MemberInfo
		v(0).Name="DestinationSessionID"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="VariableName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Name"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="SessionID"
		v(3).Prefix="s"
		v(3).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "DestinationSessionID", m_sDestinationSessionID, "String", false
			.AddParameter "VariableName", m_sVariableName, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetAssemblyVersionsResponse
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetAssemblyVersionsResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetAssemblyVersionsResponse"
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

Class XGetBinPropertyResponse
	Public m_aValue
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetBinPropertyResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetBinPropertyResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Value"
		v(0).Prefix="a"
		v(0).CLRType="Byte[]"
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
			X_Deserialize m_aValue, .selectSingleNode("Value"), "Byte[]"
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

Class XGetConfigElementRequest
	Public m_sParameterPath
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetConfigElementRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetConfigElementRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="ParameterPath"
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
			.AddParameter "ParameterPath", m_sParameterPath, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetConfigElementResponse
	Public m_oParameterElement
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetConfigElementResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetConfigElementResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="ParameterElement"
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
			X_Deserialize m_oParameterElement, .selectSingleNode("ParameterElement"), "XmlElement"
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

Class XGetCurrentTimeResponse
	Public m_dtCurrentTime
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetCurrentTimeResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetCurrentTimeResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="CurrentTime"
		v(0).Prefix="dt"
		v(0).CLRType="DateTime"
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
			X_Deserialize m_dtCurrentTime, .selectSingleNode("CurrentTime"), "DateTime"
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

Class XGetCurrentUserResponse
	Public m_sUserIdentity
	Public m_sThreadIdentity
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetCurrentUserResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetCurrentUserResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="UserIdentity"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ThreadIdentity"
		v(1).Prefix="s"
		v(1).CLRType="String"
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
			X_Deserialize m_sUserIdentity, .selectSingleNode("UserIdentity"), "String"
			X_Deserialize m_sThreadIdentity, .selectSingleNode("ThreadIdentity"), "String"
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

Class XGetListDataRequest
	Public m_sTypeName
	Public m_sMetaName
	Public m_oParams
	Public m_aValueObjectIDs
	Public m_nFirstRow
	Public m_nLastRow
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetListDataRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetListDataRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="MetaName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="Params"
		v(2).Prefix="o"
		v(2).CLRType="XParamsCollection"
		Set v(3) = New MemberInfo
		v(3).Name="ValueObjectIDs"
		v(3).Prefix="a"
		v(3).CLRType="Guid[]"
		Set v(4) = New MemberInfo
		v(4).Name="FirstRow"
		v(4).Prefix="n"
		v(4).CLRType="Int32"
		Set v(5) = New MemberInfo
		v(5).Name="LastRow"
		v(5).Prefix="n"
		v(5).CLRType="Int32"
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
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "MetaName", m_sMetaName, "String", false
			.AddParameter "Params", m_oParams, "XParamsCollection", false
			.AddParameter "ValueObjectIDs", m_aValueObjectIDs, "Guid[]", false
			.AddParameter "FirstRow", m_nFirstRow, "Int32", false
			.AddParameter "LastRow", m_nLastRow, "Int32", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetMenuResponse
	Public m_oXmlMenu
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetMenuResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetMenuResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="XmlMenu"
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
			X_Deserialize m_oXmlMenu, .selectSingleNode("XmlMenu"), "XmlElement"
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

Class XGetMetadataResponse
	Public m_oMetadata
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetMetadataResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetMetadataResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Metadata"
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
			X_Deserialize m_oMetadata, .selectSingleNode("Metadata"), "XmlElement"
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

Class XGetMetadataRootResponse
	Public m_oMetadataRoot
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetMetadataRootResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetMetadataRootResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="MetadataRoot"
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
			X_Deserialize m_oMetadataRoot, .selectSingleNode("MetadataRoot"), "XmlElement"
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

Class XGetMetadataVersionResponse
	Public m_sVersion
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetMetadataVersionResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetMetadataVersionResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Version"
		v(0).Prefix="s"
		v(0).CLRType="String"
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
			X_Deserialize m_sVersion, .selectSingleNode("Version"), "String"
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

Class XGetObjectRequest
	Public m_sTypeName
	Public m_sObjectID
	Public m_aPreloadProperties
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ObjectID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="PreloadProperties"
		v(2).Prefix="a"
		v(2).CLRType="String[]"
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
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "PreloadProperties", m_aPreloadProperties, "String[]", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetObjectResponse
	Public m_oXmlObject
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="XmlObject"
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
			X_Deserialize m_oXmlObject, .selectSingleNode("XmlObject"), "XmlElement"
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

Class XGetObjectsRequest
	Public m_aList
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectsRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectsRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="List"
		v(0).Prefix="a"
		v(0).CLRType="XObjectIdentity[]"
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
			.AddParameter "List", m_aList, "XObjectIdentity[]", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetObjectsResponse
	Public m_oXmlObjectsList
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectsResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectsResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="XmlObjectsList"
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
			X_Deserialize m_oXmlObjectsList, .selectSingleNode("XmlObjectsList"), "XmlElement"
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

Class XGetObjectsRightsRequest
	Public m_aPermissions
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectsRightsRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectsRightsRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="Permissions"
		v(0).Prefix="a"
		v(0).CLRType="XObjectPermission[]"
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
			.AddParameter "Permissions", m_aPermissions, "XObjectPermission[]", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetObjectsRightsResponse
	Public m_aObjectPermissionCheckList
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetObjectsRightsResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetObjectsRightsResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="ObjectPermissionCheckList"
		v(0).Prefix="a"
		v(0).CLRType="Boolean[]"
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
			X_Deserialize m_aObjectPermissionCheckList, .selectSingleNode("ObjectPermissionCheckList"), "Boolean[]"
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

Class XGetPropertyRequest
	Public m_sTypeName
	Public m_sObjectID
	Public m_sPropName
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetPropertyRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetPropertyRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ObjectID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="PropName"
		v(2).Prefix="s"
		v(2).CLRType="String"
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
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "PropName", m_sPropName, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetPropertyResponse
	Public m_oXmlProperty
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetPropertyResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetPropertyResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="XmlProperty"
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
			X_Deserialize m_oXmlProperty, .selectSingleNode("XmlProperty"), "XmlElement"
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

Class XGetServerSoftwareVersionResponse
	Public m_oNetVersion
	Public m_oOSVersion
	Public m_sOSPlatform
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetServerSoftwareVersionResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetServerSoftwareVersionResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(8)
		Set v(0) = New MemberInfo
		v(0).Name="NetVersion"
		v(0).Prefix="o"
		v(0).CLRType="XVersion"
		Set v(1) = New MemberInfo
		v(1).Name="OSVersion"
		v(1).Prefix="o"
		v(1).CLRType="XVersion"
		Set v(2) = New MemberInfo
		v(2).Name="OSPlatform"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Status"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="StartedAt"
		v(4).Prefix="dt"
		v(4).CLRType="DateTime"
		Set v(5) = New MemberInfo
		v(5).Name="FinishedAt"
		v(5).Prefix="dt"
		v(5).CLRType="DateTime"
		Set v(6) = New MemberInfo
		v(6).Name="PercentCompleted"
		v(6).Prefix="n"
		v(6).CLRType="Int32"
		Set v(7) = New MemberInfo
		v(7).Name="SuspendedAt"
		v(7).Prefix="dt"
		v(7).CLRType="DateTime"
		Set v(8) = New MemberInfo
		v(8).Name="ResumeIdleTimeout"
		v(8).Prefix="n"
		v(8).CLRType="Int32"
		GetMembersInfo=v
	End Function


	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oNetVersion, .selectSingleNode("NetVersion"), "XVersion"
			X_Deserialize m_oOSVersion, .selectSingleNode("OSVersion"), "XVersion"
			X_Deserialize m_sOSPlatform, .selectSingleNode("OSPlatform"), "String"
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

Class XGetSessionVariableRequest
	Public m_sVariableName
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetSessionVariableRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetSessionVariableRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="VariableName"
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
			.AddParameter "VariableName", m_sVariableName, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetSessionVariableResponse
	Public m_sValueType
	Public m_oSerializedValue
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetSessionVariableResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetSessionVariableResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(7)
		Set v(0) = New MemberInfo
		v(0).Name="ValueType"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="SerializedValue"
		v(1).Prefix="o"
		v(1).CLRType="XmlElement"
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
			X_Deserialize m_sValueType, .selectSingleNode("ValueType"), "String"
			X_Deserialize m_oSerializedValue, .selectSingleNode("SerializedValue"), "XmlElement"
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

Class XGetTreeDataRequest
	Public m_sAction
	Public m_aExcludedNodes
	Public m_sMetaName
	Public m_oPath
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetTreeDataRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetTreeDataRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Action"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ExcludedNodes"
		v(1).Prefix="a"
		v(1).CLRType="XObjectIdentity[]"
		Set v(2) = New MemberInfo
		v(2).Name="MetaName"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Path"
		v(3).Prefix="o"
		v(3).CLRType="XTreePath"
		Set v(4) = New MemberInfo
		v(4).Name="Params"
		v(4).Prefix="o"
		v(4).CLRType="XParamsCollection"
		Set v(5) = New MemberInfo
		v(5).Name="Name"
		v(5).Prefix="s"
		v(5).CLRType="String"
		Set v(6) = New MemberInfo
		v(6).Name="SessionID"
		v(6).Prefix="s"
		v(6).CLRType="String"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Action", m_sAction, "String", false
			.AddParameter "ExcludedNodes", m_aExcludedNodes, "XObjectIdentity[]", false
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

Class XGetTreeMenuRequest
	Public m_sMetaName
	Public m_oPath
	Public m_oParams
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetTreeMenuRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetTreeMenuRequest"
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

Class XGetTypeMDRequest
	Public m_sTypeName
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetTypeMDRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetTypeMDRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
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
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XGetTypeMDResponse
	Public m_oTypeMD
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XGetTypeMDResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XGetTypeMDResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="TypeMD"
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
			X_Deserialize m_oTypeMD, .selectSingleNode("TypeMD"), "XmlElement"
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

Class XObjectPermission
	Public m_sAction
	Public m_sTypeName
	Public m_sObjectID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XObjectPermission, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XObjectPermission"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="Action"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="TypeName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ObjectID"
		v(2).Prefix="s"
		v(2).CLRType="Guid"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "Action", m_sAction, "String", false
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sAction, .selectSingleNode("Action"), "String"
			X_Deserialize m_sTypeName, .selectSingleNode("TypeName"), "String"
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XParamsCollection
	Public m_oXmlParams

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XParamsCollection, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XParamsCollection"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(0)
		Set v(0) = New MemberInfo
		v(0).Name="XmlParams"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "XmlParams", m_oXmlParams, "XmlElement", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_oXmlParams, .selectSingleNode("XmlParams"), "XmlElement"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSaveObjectRequest
	Public m_oXmlSaveData
	Public m_sContext
	Public m_oRootObjectId
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XSaveObjectRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSaveObjectRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="XmlSaveData"
		v(0).Prefix="o"
		v(0).CLRType="XmlElement"
		Set v(1) = New MemberInfo
		v(1).Name="Context"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="RootObjectId"
		v(2).Prefix="o"
		v(2).CLRType="XObjectIdentity"
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
			.AddParameter "XmlSaveData", m_oXmlSaveData, "XmlElement", false
			.AddParameter "Context", m_sContext, "String", false
			.AddParameter "RootObjectId", m_oRootObjectId, "XObjectIdentity", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSetAnySessionVariableRequest
	Public m_sDestinationSessionID
	Public m_sVariableName
	Public m_sValueType
	Public m_oSerializedValue
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XSetAnySessionVariableRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSetAnySessionVariableRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="DestinationSessionID"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="VariableName"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="ValueType"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="SerializedValue"
		v(3).Prefix="o"
		v(3).CLRType="XmlElement"
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
			.AddParameter "DestinationSessionID", m_sDestinationSessionID, "String", false
			.AddParameter "VariableName", m_sVariableName, "String", false
			.AddParameter "ValueType", m_sValueType, "String", false
			.AddParameter "SerializedValue", m_oSerializedValue, "XmlElement", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSetSessionVariableRequest
	Public m_sVariableName
	Public m_sValueType
	Public m_oSerializedValue
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XSetSessionVariableRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSetSessionVariableRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(4)
		Set v(0) = New MemberInfo
		v(0).Name="VariableName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ValueType"
		v(1).Prefix="s"
		v(1).CLRType="String"
		Set v(2) = New MemberInfo
		v(2).Name="SerializedValue"
		v(2).Prefix="o"
		v(2).CLRType="XmlElement"
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
			.AddParameter "VariableName", m_sVariableName, "String", false
			.AddParameter "ValueType", m_sValueType, "String", false
			.AddParameter "SerializedValue", m_oSerializedValue, "XmlElement", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSleepRequest
	Public m_nTimeOut
	Public m_nSuspendTimeout
	Public m_nIterationsCount
	Public m_bCallSuspend
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XSleepRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSleepRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="TimeOut"
		v(0).Prefix="n"
		v(0).CLRType="Int32"
		Set v(1) = New MemberInfo
		v(1).Name="SuspendTimeout"
		v(1).Prefix="n"
		v(1).CLRType="Int32"
		Set v(2) = New MemberInfo
		v(2).Name="IterationsCount"
		v(2).Prefix="n"
		v(2).CLRType="Int32"
		Set v(3) = New MemberInfo
		v(3).Name="CallSuspend"
		v(3).Prefix="b"
		v(3).CLRType="Boolean"
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
			.AddParameter "TimeOut", m_nTimeOut, "Int32", false
			.AddParameter "SuspendTimeout", m_nSuspendTimeout, "Int32", false
			.AddParameter "IterationsCount", m_nIterationsCount, "Int32", false
			.AddParameter "CallSuspend", m_bCallSuspend, "Boolean", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XSleepResponse
	Public m_nReturn
	Public m_sStatus
	Public m_dtStartedAt
	Public m_dtFinishedAt
	Public m_nPercentCompleted
	Public m_dtSuspendedAt
	Public m_nResumeIdleTimeout

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XSleepResponse, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XSleepResponse"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(6)
		Set v(0) = New MemberInfo
		v(0).Name="Return"
		v(0).Prefix="n"
		v(0).CLRType="Int32"
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
			X_Deserialize m_nReturn, .selectSingleNode("Return"), "Int32"
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

Class XStopAnySessionRequest
	Public m_sDestinationSessionID
	Public m_sName
	Public m_sSessionID

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XStopAnySessionRequest, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XStopAnySessionRequest"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="DestinationSessionID"
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
			.AddParameter "DestinationSessionID", m_sDestinationSessionID, "String", false
			.AddParameter "Name", m_sName, "String", true
			.AddParameter "SessionID", m_sSessionID, "String", true
			Set Serialize = .ToXml()
		End With
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XTreeNode
	Public m_sTypeName
	Public m_sObjectID
	Public m_sTitle
	Public m_sIcon
	Public m_bIsLeafNode
	Public m_oAppData

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XTreeNode, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XTreeNode"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(5)
		Set v(0) = New MemberInfo
		v(0).Name="TypeName"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ObjectID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="Title"
		v(2).Prefix="s"
		v(2).CLRType="String"
		Set v(3) = New MemberInfo
		v(3).Name="Icon"
		v(3).Prefix="s"
		v(3).CLRType="String"
		Set v(4) = New MemberInfo
		v(4).Name="IsLeafNode"
		v(4).Prefix="b"
		v(4).CLRType="Boolean"
		Set v(5) = New MemberInfo
		v(5).Name="AppData"
		v(5).Prefix="o"
		v(5).CLRType="XParamsCollection"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "TypeName", m_sTypeName, "String", false
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "Title", m_sTitle, "String", false
			.AddParameter "Icon", m_sIcon, "String", false
			.AddParameter "IsLeafNode", m_bIsLeafNode, "Boolean", false
			.AddParameter "AppData", m_oAppData, "XParamsCollection", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sTypeName, .selectSingleNode("TypeName"), "String"
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
			X_Deserialize m_sTitle, .selectSingleNode("Title"), "String"
			X_Deserialize m_sIcon, .selectSingleNode("Icon"), "String"
			X_Deserialize m_bIsLeafNode, .selectSingleNode("IsLeafNode"), "Boolean"
			X_Deserialize m_oAppData, .selectSingleNode("AppData"), "XParamsCollection"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class

Class XTreePath
	Public m_aPathNodes

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Commands.XTreePath, Croc.XmlFramework.Commands.Interop, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XTreePath"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(0)
		Set v(0) = New MemberInfo
		v(0).Name="PathNodes"
		v(0).Prefix="a"
		v(0).CLRType="XObjectIdentity[]"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "PathNodes", m_aPathNodes, "XObjectIdentity[]", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_aPathNodes, .selectSingleNode("PathNodes"), "XObjectIdentity[]"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class


' Croc.XmlFramework.Data.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517
Class XObjectIdentity
	Public m_sObjectType
	Public m_sObjectID
	Public m_vTS

	Public Property Get CLRFullTypeName
		CLRFullTypeName="Croc.XmlFramework.Data.XObjectIdentity, Croc.XmlFramework.Data.Public, Version=2.0.0.0, Culture=neutral, PublicKeyToken=5cc95d2b805c9517"
	End Property

	Public Property Get CLRTypeName
		CLRTypeName="XObjectIdentity"
	End Property

	Public Function GetMembersInfo
		Dim v
		ReDim v(2)
		Set v(0) = New MemberInfo
		v(0).Name="ObjectType"
		v(0).Prefix="s"
		v(0).CLRType="String"
		Set v(1) = New MemberInfo
		v(1).Name="ObjectID"
		v(1).Prefix="s"
		v(1).CLRType="Guid"
		Set v(2) = New MemberInfo
		v(2).Name="TS"
		v(2).Prefix="v"
		v(2).CLRType="Int64"
		GetMembersInfo=v
	End Function

	Function Serialize
		With New XSerializerClass
			.Init TypeName(Me)
			.AddParameter "ObjectType", m_sObjectType, "String", false
			.AddParameter "ObjectID", m_sObjectID, "Guid", false
			.AddParameter "TS", m_vTS, "Int64", false
			Set Serialize = .ToXml()
		End With
	End Function

	Function Deserialize(oXmlRoot)
		With oXmlRoot
			X_Deserialize m_sObjectType, .selectSingleNode("ObjectType"), "String"
			X_Deserialize m_sObjectID, .selectSingleNode("ObjectID"), "Guid"
			X_Deserialize m_vTS, .selectSingleNode("TS"), "Int64"
		End With
		Set Deserialize = Me
	End Function

	Property Get Self
		Set Self = Me
	End Property
End Class


