//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Data;
using System.Globalization;
using System.Xml;
using Croc.IncidentTracker.Commands;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// �����, ����������� ��������������� ������ ���������� "�����������" 
	/// �������� ������� ���������� - ������ (GetObject), ������ ��������� � 
	/// ����� �������� (SaveObject), �������� (DeleteObject), � ��� �� 
	/// �������� ���������� "���������� ������" (ExecuteDataSource)
	/// 
	/// ����� ��� �� ��������� ��������������� ������ ������������, ������� 
	/// � ��������� ������ ���������� ds-������� - XML-��������� �������������
	/// ������ ds-�������� �� ���������� �������, ������������� � ��������� 
	/// ��������� � ������ ������
	/// </summary>
	public class ObjectOperationHelper 
	{
		/// <summary>
		/// ����������� ����� � ��������� ������ ������������� ���������� ������� � ������� ����������
		/// </summary>
		private static readonly string ERR_INVALID_APPSERVERFACADE = "��������� ������� � ������� ���������� �� ���������������!";
		/// <summary>
		/// ����������� ����� � ��������� ������ ���������� ��������
		/// </summary>
		private static readonly string ERRFMT_INVALID_NULL_OPERATION_RESULT = "������ ���������� �������� {0} ������� ����������: � �������� ���������� ������� null";
		/// <summary>
		/// ����������� ����� � ��������� ������ ���������� ������
		/// </summary>
		private static readonly string ERRFMT_INVALID_DATA_NOTLOAD = "������ ������� {0} �� ���������";
		
		#region ���������� ���������� � ������ ������
		
		/// <summary>
		/// ������ �� ����� ������� ���������� - ���������� ���������� IXFacade.
		/// ������ ������ ���� ����������������� �� �������� ���������� �������
		/// ��� ������ ������-���� ������������ ������ ������
		/// <seealso cref="IXFacade"/>
		/// </summary>
		private static IXFacade m_appServerFacade = null;
		
		/// <summary>
		/// �������, ���������� ��� ����, ��� ������, ������������� helper-��,
		/// ���� ����� ������ (� ���������� ���� ������� new="1")
		/// </summary>
		private bool m_bIsNewObject;
		/// <summary>
		/// ������������ ds-���� �������, ������ �������� ������������� helper-��
		/// </summary>
		private string m_sTypeName;
		/// <summary>
		/// ������������� ds-�������, ������ �������� ������������� helper-��
		/// </summary>
		private Guid m_uidObjectID;
		/// <summary>
		/// XML-������ (����������) ds-�������, �������������� helper-��
		/// </summary>
		private XmlElement m_xmlDatagram;

		/// <summary>
		/// ���������� ����������� �������
		/// ������, �.�. ��� ��������������� (�) ������������ "���������" ������
		/// (�) ������ ��� ������� ���� ���������������� ��������� � ������� 
		/// ���������� � ����� ����������� ��������� �������� ��� �������
		/// </summary>
		private ObjectOperationHelper() 
		{
			if (null==m_appServerFacade)
				throw new InvalidOperationException( ERR_INVALID_APPSERVERFACADE );

			m_bIsNewObject = true;
			m_sTypeName = null;
			m_uidObjectID = Guid.NewGuid();
			m_xmlDatagram = null;
		}

		
		#endregion

		/// <summary>
		/// ������ �� ��������� ������� � ������� ����������
		/// ��������! ������ �������� ������ ���� ����������������� ����� �������
		/// ������ ���������� ��� ����� ������������ ������ ������!
		/// </summary>
		/// <exception cref="InvalidOperationException">
		/// ���� ��� ������ �������� �������� ��� ���� null;
		/// </exception>
		/// <exception cref="ArgumentNullException">
		/// ���� � �������� �������� �������� ��������������� null;
		/// </exception>
		public static IXFacade AppServerFacade 
		{
			get 
			{
				if (null==m_appServerFacade)
					throw new InvalidOperationException( ERR_INVALID_APPSERVERFACADE );
				return m_appServerFacade;
			}
			set
			{
				if (null==value)
					throw new ArgumentNullException( ERR_INVALID_APPSERVERFACADE, "AppServerFacade");
				m_appServerFacade = value;
			}
		}


		#region ��������� ������ ��������� ���������� ������� ObjectOperationHelper 

		/// <summary>
		/// "���������" ����� ��������� ���������� ������ 
		/// </summary>
		/// <returns>
		/// ��������� ������, ��� �������� �������� ������� "������������ ����" � 
		/// "������������� �������" (TypeName � ObjectID) �� ����������������
		/// </returns>
		public static ObjectOperationHelper GetInstance() 
		{
			return new ObjectOperationHelper();
		}

		
		/// <summary>
		/// "���������" ����� ��������� ���������� ������ 
		/// ������ ������������ ���� ds-�������
		/// </summary>
		/// <param name="sTypeName">������������ ds-����</param>
		/// <returns>
		/// ��������� ������, ��� �������� �������� �������� "������������ ����"
		/// (TypeName) ������ � �����. � ���������� ����������; �������� ��������
		/// "������������� �������" (ObjectID) �� ����������������
		/// </returns>
		public static ObjectOperationHelper GetInstance( string sTypeName ) 
		{
			ObjectOperationHelper helper = new ObjectOperationHelper();
			helper.TypeName = sTypeName;
			helper.ObjectID = Guid.Empty;
			return helper;
		}


		/// <summary>
		/// "���������" ����� ��������� ���������� ������ 
		/// ������ ������������ ���� � ������������� ds-�������
		/// </summary>
		/// <param name="sTypeName">������������ ds-����</param>
		/// <param name="uidObjectID">������������� ds-�������</param>
		/// <returns>
		/// ��������� ������, ��� �������� �������� ������� "������������ ����"
		/// (TypeName) � "������������� �������" (ObjectID) ���������������� �
		/// ������������ � ����������� �����������.
		/// ���� � �������� �������������� ������� ������� Guid.Empty, ��������
		/// IsNew ��������������� � �������� true;
		/// </returns>
		public static ObjectOperationHelper GetInstance( string sTypeName, Guid uidObjectID ) 
		{
			ObjectOperationHelper helper = new ObjectOperationHelper();
			helper.TypeName = sTypeName;
			helper.ObjectID = uidObjectID;
			return helper;
		}

		
		/// <summary>
		/// ����� ��������� "�����" ��������� ���������������� �������, ������� 
		/// ����� ������������� ����������; ��� ����� ����� ����� ���� ����������
		/// ����� �������������, � ���� ������ ������ �������� ������� ���������� 
		/// ��� "�����" (��������������, �������� ObjectID ���������� Guid.Empty,
		/// � ����� ID ����� �������� ��� �������� �������� NewlySetObjectID)
		/// </summary>
		/// <param name="helperSrc">��������, "�����������" ���������</param>
		/// <param name="bKeepObjectID">������� ���������� ��������� �������������� �������</param>
		/// <returns>���������, "����������" �����</returns>
		public static ObjectOperationHelper CloneFrom( ObjectOperationHelper helperSrc, bool bKeepObjectID ) 
		{
			ObjectOperationHelper helperClone = new ObjectOperationHelper();
			
			// ��������� ������ ��������� ��������:
			helperClone.m_sTypeName = helperSrc.m_sTypeName;
			helperClone.m_uidObjectID = helperSrc.m_uidObjectID;
			helperClone.m_bIsNewObject = helperSrc.m_bIsNewObject;
			// ���������� ��������� ��������� (���� ���, �������, ����):
			if (null!=helperSrc.m_xmlDatagram)
				helperClone.m_xmlDatagram = (XmlElement)helperSrc.m_xmlDatagram.CloneNode(true);
			else
				helperClone.m_xmlDatagram = null;
			
			// ����� ��� ������� �� ����� bKeepObjectID: ���� ������������� 
			// �� ���������, �� ������������� �������� ������ ��� "�����", 
			// �� ��� ���� ��������� XML-������ ������� (� � ���� ������, 
			// ��������������, ����������� new="1"):
			if (!bKeepObjectID)
			{
				// ������� "�����" ���� �������� ������� (�.�. �� ���� ��������
				// �������� � �������� NewlySetObjectID):
				helperClone.m_bIsNewObject = true;
				helperClone.NewlySetObjectID = Guid.Empty; // ...��� ������������� �����
				helperClone.m_xmlDatagram.SetAttribute( "new","1" );
			}
			
			// ��� � �������� �����:
			return helperClone;
		}
		
		
		#endregion 

		#region ��������� �������� - �������� ������������� � ������ �������������� ds-�������
		
		/// <summary>
		/// ������������ ���� ds-�������, �������������� ��������-helper-��.
		/// ���������� �������� �� ������ ���� ������ ������� ��� null-���������
		/// </summary>
		public string TypeName 
		{
			get { return m_sTypeName; }
			set
			{
				ValidateRequiredArgument( value, "TypeName" );
				// ���� �������� ��� ���������� �� ��� �������������, �� ����������, 
				// ���� ������� ���� ���������, ��� �����������, �.�. ���������
				// ������ ������� ����; ������� ��:
				if (value!=m_sTypeName && IsLoaded)
					m_xmlDatagram = null;
				m_sTypeName = value;
			}
		}

		
		/// <summary>
		/// ������������� ds-�������, �������������� ��������-helper-��.
		/// </summary>
		/// <remarks>
		/// ���� � �������� �������� �������� �������� Guid.Empty, �� ��������
		/// �������� IsNew ��������������� � true; ���� ���������� ������� 
		/// ��������� (�������� �������� Datagram != null), �� ��� ��������
		/// oid ��������� �������� ���������� ������������� ������������ ����� 
		/// ��������, � ��� �� ������ ������� new="1"
		/// </remarks>
		public Guid ObjectID 
		{
			get { return (m_bIsNewObject? Guid.Empty : m_uidObjectID); }
			set 
			{
				if (value!=m_uidObjectID && IsLoaded)
					m_xmlDatagram = null;
				
				m_bIsNewObject = (Guid.Empty == value);
				m_uidObjectID = (Guid.Empty == value? Guid.NewGuid() : value);
			}
		}

		
		/// <summary>
		/// ������������� ������ �������
		/// </summary>
		public Guid NewlySetObjectID 
		{
			get { return m_uidObjectID; }
			set 
			{
				if (!m_bIsNewObject)
					throw new ArgumentException( "������������� ������ ���������� �� ����� ���� ����� ��� ��� ������������� �������!","NewObjectID" );
			
				m_uidObjectID = (value==Guid.Empty? Guid.NewGuid() : value);

				// ���� ���������� ��� ���� (��� ������ �������, ��. �������� ����), 
				// �� ������������� �������� �������������� ������� � ����������:
				if (null!=m_xmlDatagram)
					m_xmlDatagram.SetAttribute( "oid", m_uidObjectID.ToString() );
			}
		}
		
		/// <summary>
		/// ������� ����, ��� helper-������ ����������� ������ ������ ds-�������
		/// �������� ������ ��� ������ 
		/// </summary>
		public bool IsNewObject 
		{
			get { return m_bIsNewObject; }
			set
			{
				if (IsLoaded && value!=m_bIsNewObject)
					m_xmlDatagram = null;
				m_bIsNewObject = value;
			}
		}


		/// <summary>
		/// ������� ����, ��� ������ ds-������� ��������� � helper-������
		/// </summary>
		public bool IsLoaded 
		{
			get { return (null!=m_xmlDatagram); }
		}

		
		/// <summary>
		/// ������ ds-�������, ������������ � helper-������
		/// ����� ���� �������� ���������� �������� � null - ��� �������� �� 
		/// �������� � ������ �����-���� �������� �������!
		/// </summary>
		public XmlElement Datagram 
		{
			get { return m_xmlDatagram; }
		}


		#endregion
		
		#region ������ ������ � ������������ ������ ��������� ������������� ds-��������
		
		/// <summary>
		/// ���������� ������, �������������� helper-��������; ������� ����� 
		/// �������� � �������� ���������� (������ / ��������) �� �����������
		/// </summary>
		public void Clear() 
		{
			m_bIsNewObject = true;
			m_sTypeName = null;
			m_uidObjectID = Guid.NewGuid();
			m_xmlDatagram = null;
		}
		
		
		/// <summary>
		/// ��������� XML-�������� ���������� � ������� ���������� �������� 
		/// ds-�������, �������������� helper-��������
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <returns>XML-�������, ����������� ������ ���������� ��������</returns>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		public XmlElement PropertyXml( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			XmlElement xmlProp = (XmlElement)Datagram.SelectSingleNode( sPropName );
			if (null==xmlProp)
				throw new ArgumentException( String.Format( 
					"��������� �������� {0} �� ������������ � ������� {1} (oid:{2})",
					sPropName, TypeName, ObjectID.ToString().ToUpper()) 
				);

			return xmlProp;
		}

		
		/// <summary>
		/// ���������� ������ ���������� ������������ �������� ds-�������, 
		/// ����������� �������� ������ (LOB/BLOB). ����������� ������ �����
		/// ������������ � ���������� �������; ������ � ��� ����� ���� �������
		/// ����� ����� <see cref="PropertyXml"/>
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		public void UploadBinaryProp( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// ��������, ��� ������� ������������� ���� bin.base64,
			XmlElement xmlBinaryProp = PropertyXml( sPropName );
			string sXmlTypeName = xmlBinaryProp.GetAttribute("dt:dt"); 
			if ( "bin.base64"!=sXmlTypeName && "text"!=sXmlTypeName && "string"!=sXmlTypeName )
				throw new ArgumentException("�� ��� ��� ��������");
			// ���� �������� ��� ���������� - ������ �������
			if ( "0" != xmlBinaryProp.GetAttribute("loaded") )
				return;

			// ��������� ������:
			XGetPropertyRequest request = new XGetPropertyRequest( TypeName, ObjectID, sPropName );
			XGetPropertyResponse response = (XGetPropertyResponse)AppServerFacade.ExecCommand( request );

			xmlBinaryProp.RemoveAll();
			xmlBinaryProp.InnerXml = response.XmlProperty.InnerXml;
		}

		
		/// <summary>
		/// ��������� ��������������� �������� ���������� ���������� ������������ 
		/// �������� ds-�������; ������ ���������� �� ����������, �������������
		/// ������ ����������� helper-�
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="vtPropType">��� ����������� ��������</param>
		/// <returns>�������� ��������</returns>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public object GetPropValue( string sPropName, XPropType vtPropType ) 
		{
			return XmlPropValueReader.GetTypedValueFromXml( PropertyXml(sPropName), vtPropType );
		}

		/// <summary>
		/// ��������� ��������������� �������� ���������� ���������� ������������ 
		/// �������� ds-�������; ������ ���������� �� ����������, �������������
		/// ������ ����������� helper-�
		/// ������������� �����
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="vtPropType">��� ����������� ��������</param>
		/// <param name="bMustExists">���� ������� �������� ������� ��������</param>
		/// <returns></returns>
		public object GetPropValue( string sPropName, XPropType vtPropType, bool bMustExists )
		{
			XmlElement xmlData = PropertyXml(sPropName);
			// ��������� ������� �����-���� ������:
			if (String.Empty != xmlData.InnerText)
				return XmlPropValueReader.GetTypedValueFromXml( PropertyXml(sPropName), vtPropType );
			else
			{
				if (bMustExists)
					throw new ArgumentException( String.Format( 
						"��������� �������� {0} ������� {1} (oid:{2}) �� �������� ������ (null)",
						sPropName, TypeName, ObjectID.ToString().ToUpper() ) 
					);
				else
					return null;
			}
		}

		
		/// <summary>
		/// ��������� ��������������� �������� ��� ���������� ���������� 
		/// ������������ �������� ds-�������; ������ ������������ � ����������,
		/// ������������� ������ ����������� helper-�
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="vtPropType">��� ���������������� ��������</param>
		/// <param name="oValue">��������������� ��������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public void SetPropValue( string sPropName, XPropType vtPropType, object oValue ) 
		{
			PropertyXml(sPropName).InnerText = XmlPropValueWriter.GetXmlTypedValue( oValue, vtPropType );
		}

		
		/// <summary>
		/// ��������� ��������� ��������� ������ ��� ���������� �������� 
		/// ds-�������; ������ ������������ � ����������, ������������� ������
		/// ����������� helper-�
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="sRefTypeName">������������ ds-���� �� ������</param>
		/// <param name="oRefObjectID">������������� ds-������� �� ������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public void SetPropScalarRef( string sPropName, string sRefTypeName, Guid oRefObjectID ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "�� ����� ������������� ������� �� ������ (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// ���� #1: ��������� ������ �������� ��������� ������� �� ������:
			XmlElement xmlProxy = Datagram.OwnerDocument.CreateElement( sRefTypeName );
			xmlProxy.SetAttribute( "oid", oRefObjectID.ToString() );

			// ���� #2: ���������� �������� ��� ������ ���������� ��������:
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			// ������� ��� ��������� ����
			xmlRefProperty.RemoveAll();
			xmlRefProperty.AppendChild( xmlProxy );
		}
		

		/// <summary>
		/// ���������� ������ ���������� ���������� �������� ds-�������, 
		/// ����������� ������ �� �������. ����������� ������ �����
		/// ������������ � ���������� �������; ������ � ��� ����� ���� �������
		/// ����� ����� <see cref="PropertyXml"/>
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		public void UploadArrayProp( string sPropName ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// ��������� ������:
			XGetPropertyRequest request = new XGetPropertyRequest( TypeName, ObjectID, sPropName );
			XGetPropertyResponse response = (XGetPropertyResponse)AppServerFacade.ExecCommand( request );

			XmlElement xmlArrayProp = PropertyXml( sPropName );
			xmlArrayProp.RemoveAll();
			xmlArrayProp.InnerXml = response.XmlProperty.InnerXml;
		}

		
		/// <summary>
		/// ��������� �������� ��������� ������ � ��������� ��������� ��������
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="sRefTypeName">������������ ds-���� �� ������</param>
		/// <param name="oRefObjectID">������������� ds-������� �� ������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public void AddArrayPropRef( string sPropName, string sRefTypeName, Guid oRefObjectID )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "�� ����� ������������� ������� �� ������ (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			// ���� #1: ��������� ������ �������� ��������� ������� �� ������:
			XmlElement xmlProxy = Datagram.OwnerDocument.CreateElement( sRefTypeName );
			xmlProxy.SetAttribute( "oid", oRefObjectID.ToString() );

			// ���� #2: ���������� �������� ��� ������ ���������� ��������:
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			xmlRefProperty.AppendChild( xmlProxy );
		}


		/// <summary>
		/// ������� �������� ��������� ������ �� ���������� ���������� ��������
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="sRefTypeName">������������ ds-���� �� ������</param>
		/// <param name="oRefObjectID">������������� ds-������� �� ������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public void RemoveArrayPropRef( string sPropName, string sRefTypeName, Guid oRefObjectID )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			ValidateRequiredArgument( sRefTypeName, "sRefTypeName" );
			if (Guid.Empty==oRefObjectID)
				throw new ArgumentException( "�� ����� ������������� ������� �� ������ (Guid.Empty)", "oRefObjectID" );
			if (null==Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );
			
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			XmlNode xmlRefArrayItem = xmlRefProperty.SelectSingleNode( String.Format("{0}[oid='{1}']", sRefTypeName, oRefObjectID.ToString()) );
			if ( null!=xmlRefArrayItem )
				xmlRefProperty.RemoveChild( xmlRefArrayItem );
		}


		/// <summary>
		/// ������� ��� ������ � ��������� ��������� ��������� ��������
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public void ClearArrayProp( string sPropName )
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			XmlElement xmlRefProperty = PropertyXml(sPropName);
			// ������� ��� ��������� ����
			xmlRefProperty.RemoveAll();
		}

		
		/// <summary>
		/// ���������� ����� ��������� �������-heler-�, ������������������ 
		/// � ������������ � ������� ��������� ��������� ������ ���������� 
		/// �������� ds-�������. ������ ���������� �� ����������, �������������
		/// ������ ����������� helper-�.
		/// ���� ������ �� ������ ���, �� ��������� ������ ������� �� �����
		/// bStrictExistenceCheck - ���� �� �����, �� ������������ ����������;
		/// ���� ������� - �� � �������� ���������� ������������ null;
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <param name="bStrictExistenceCheck">����� "�������" ��������</param>
		/// <returns>
		///		-- ������������������ ������-helper 
		///		-- null, ���� ������ �� ������ ��� � bStrictExistenceCheck �����
		///		� false
		///	</returns>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public ObjectOperationHelper GetInstanceFromPropScalarRef( string sPropName, bool bStrictExistenceCheck ) 
		{
			ValidateRequiredArgument( sPropName, "sPropName" );
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			XmlElement xmlPropRef = PropertyXml( sPropName );
			XmlElement xmlPropRefStub = (XmlElement)xmlPropRef.FirstChild;
			
			// ��������� ������� ������ ��������� ������
			// ���� ������ ��� � ����� ����������� � ������� ��������� ������� - 
			// ���������� ����������; ����� - ������ ���������� null
			if ( null == xmlPropRefStub )
			{
				if (bStrictExistenceCheck)
					throw new ArgumentException("�������� " + sPropName + " �� �������� ������ ��������� ��������� ������!");
				else 
					return null;
			}
			
			ObjectOperationHelper helperRef = new ObjectOperationHelper();
			helperRef.IsNewObject = false;
			helperRef.TypeName = xmlPropRefStub.Name;

			string sObjectRefID = xmlPropRefStub.GetAttribute("oid");
			if ( null!=sObjectRefID || String.Empty!=sObjectRefID )
			{
				helperRef.ObjectID = new Guid(sObjectRefID);
			}
			else
			{
				// ���� ������������� ������� �� ������ �� �����, � ��� ���� ������
				// ������� ��������� ������� - ���������� ����������; ����� - ������ 
				// ���������� null:
				if (bStrictExistenceCheck)
					throw new ArgumentException("��������� ������ �� �������� " + sPropName + " �� �������� �������������� �������!");
				else
					return null;
			}

			return helperRef;
		}


		/// <summary>
		/// ���������� ����� ��������� �������-heler-�, ������������������ 
		/// � ������������ � ������� ��������� ��������� ������ ���������� 
		/// �������� ds-�������. ������ ���������� �� ����������, �������������
		/// ������ ����������� helper-�.
		/// ������������� �����
		/// </summary>
		/// <param name="sPropName">������������ �������� ds-�������</param>
		/// <returns>������������������ ������-helper</returns>
		/// <exception cref="ArgumentException">
		/// ���� ������ ��� ���������� �������� � ���������� ���
		/// </exception>
		/// <remarks>
		/// ��������!
		/// ���������� helper-������� �� ��������� ������������ ���������� 
		/// ���� / �������� ������������ ���� � �������� ��������, ��������
		/// � ���������� ����������!
		/// </remarks>
		public ObjectOperationHelper GetInstanceFromPropScalarRef( string sPropName ) 
		{
			return GetInstanceFromPropScalarRef( sPropName, true );
		}


		/// <summary>
		/// ������� ��������� ������ ������� �� ���������� ������� - ������ 
		/// ������ � ���������� ����� �������. � ������ ������ ����� ����������
		/// ��� "���������" �������� ����� ��������������� Storage-�, � � �����
		/// ���������� �� �����. ������ ��� ����� - ���������� ��������� - � 
		/// ������������ ����� "�������� �������"
		/// </summary>
		/// <param name="arrPropNames">
		/// ������ ������������ �������, �������� � ������ ������� ��������� 
		/// �� ����������
		/// </param>
		public void DropPropertiesXml( params string[] arrPropNames ) 
		{
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			foreach( string sPropName in arrPropNames )
				Datagram.RemoveChild( PropertyXml(sPropName) );
		}
		
		
		/// <summary>
		/// ������� ��� �������� �� ���������� ����� ���������. �� ����������
		/// ��������� ������ ������ � ���������� ����� �������. � ������ ������ 
		/// ����� ���������� ��� "���������" �������� ����� ��������������� 
		/// Storage-�, � � ����� �� ����� ���������� � ��. ������ ��� ����� - 
		/// ���������� ��������� - � ������������ ����� "�������� �������"
		/// </summary>
		/// <param name="arrPropNames">
		/// ������ ������������ �������, �������� � ������ ������� �� ������ 
		/// ��������� �� ����������
		/// </param>
		public void DropPropertiesXmlExcept( params string[] arrPropNames ) 
		{
			if (null == Datagram)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_DATA_NOTLOAD,TypeName) );

			ArrayList arrDoppingPropNames = new ArrayList();
			
			// ��������� ��� ��������, ������������ � ����������: ���� 
			// ��������������� �������� �� ������ � ������ ���, �������
			// ������� �� ���� - �� ������� ��� � �������� ���������
			foreach( XmlNode xmlChild in Datagram.ChildNodes )
				if ( Array.IndexOf(arrPropNames, xmlChild.Name) < arrPropNames.GetLowerBound(0) )
					arrDoppingPropNames.Add( xmlChild.Name );
			
			foreach( string sPropName in arrDoppingPropNames )
				Datagram.RemoveChild( PropertyXml(sPropName) );
		}
		
		
		/// <summary>
		/// ����� ��������������� ����������� ����������, ���������� ������ 
		/// ���������� ds-��������, �������������� � �������� helper-��.
		/// ���������� ���������� ������������ ��� �������������� ������ 
		/// ������ ���������� ��������, � ����� ����� �������������� ��� 
		/// �������� � �������� ������ ��������.
		/// </summary>
		/// <param name="helpers">
		/// ������ helper-��������, ������ �������� ����� �������� �� ������
		/// � ������� ����� ����������. �������� ������� ����� ���� null-���;
		/// ����� ��� ����� ���������� ����� ��������������.
		/// </param>
		/// <returns>
		/// XML-������� � ������� ����������� ����������.
		/// </returns>
		public static XmlElement MakeComplexDatagarmm( ObjectOperationHelper[] helpers ) 
		{
			// ������������ ���������: � ���� - ����������� - ������ � ��������
			// ��������� �������� �.�. ������� �� ����������� ������������� - 
			// ��� Storage ��������, ��� � ���������� ������������� ������ 
			// ���������� ��������:
			XmlDocument xmlComplexDatagram = new XmlDocument();
			XmlElement xmlComplexDatagramRoot = xmlComplexDatagram.CreateElement("x-datagram");
			xmlComplexDatagram.AppendChild( xmlComplexDatagramRoot );
			foreach( ObjectOperationHelper helper in helpers )
			{
				// ���� ������� ������� ���� null - ����������:
				if (null==helper)
					continue;
				// ...����� - ��������� �� ������: ������� ���� � ������� XML-������:
				ValidateRequiredArgument( helper.TypeName, "helper.TypeName" );
				if (null==helper.Datagram)
					throw new InvalidOperationException( "������ ������� ���� " + helper.TypeName + " �� ���������" );
				xmlComplexDatagramRoot.AppendChild( xmlComplexDatagram.ImportNode( helper.Datagram, true ) );
			}
			
			return xmlComplexDatagramRoot;
		}

		
		#endregion

		#region ������ ������ � �������� ���������� - ������, ������ � �������� ������ ds-��������
		
		/// <summary>
		/// ��������� ������������� ds-�������, ������������ �����������, �� 
		/// ��������� ������ ����� �������
		/// </summary>
		/// <param name="bIsStrictCheck">
		/// ������� ��������: ���� �������� ����� � true, � ds-������� � ������� ���, 
		/// ����� �������� ���������� ����������; ���� ����� � false, �� ������ �������
		/// ���������� ����������� ������
		/// </param>
		/// <returns>
		/// ���������� ������� ������� ������� � �� �� ������ ������
		/// </returns>
		public bool CheckExistence( bool bIsStrictCheck ) 
		{
			// ������������ ���� �������� ������� �.�. ������ ����� ���������
			// �������-helper-�
			ValidateRequiredArgument( TypeName,"TypeName" );
			ValidateRequiredArgument( ObjectID,"ObjectID" );

			// ��������� ������ �� ���������� �������� "GetObjectIdByExKey" - 
			// �������� ��������� �������������� ������� �� ��� "��������" 
			// ���������:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest( );
			requestGetId.TypeName = TypeName;
			requestGetId.Params = new XParamsCollection();
			requestGetId.Params.Add( "ObjectID", ObjectID );

			// ��������� �������� - �������� ������ ����������
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			// ��������� ������ ���� ������:
			if ( null==responseGetId )
				throw new ApplicationException("������ ���������� �������� ������� ���������� (GetObjectIdByExKey) - � �������� ���������� ������� null!" );
			if ( responseGetId.ObjectID != Guid.Empty )
				return true;
			else if (!bIsStrictCheck)
				return false;
			else
				throw new InvalidOperationException( String.Format(
					"��������� ������ ���� {0} c ��������������� {1} �� ����������",
					TypeName, ObjectID.ToString()
				));
		}
		

		/// <summary>
		/// ��������� �������������� ds-�������, ��������� ���������� ����� 
		/// "��������" �������. ���������� �������� �������, GetObjectIdByExKey
		/// </summary>
		/// <param name="keyPropsCollection">
		/// ��������� �������� "��������" ������� �������, ��� ������ ���� 
		/// XParamsCollection. ����� ������������ ��������� ���� ������������
		/// ��������, �������� ��������� - �������� ��������
		/// </param>
		/// <returns>������������� ds-�������</returns>
		/// <remarks>
		/// (1) ������������ ���� �������� ������� �.�. ������ ����� ���������
		///		�������-helper-�; ��. �������� TypeName � "���������" ������
		/// (2) ���� ������� ������������� (������) ������ �� �����, ����� 
		///		������������� ���������� ���� ArgumentException, ��. ���������� 
		///		�������� GetObjectIdByExKeyCommand
		/// (3) ���������� ������������� ��� �� ��������������� ��� ��������
		///		�������� ObjectID �������� �������-helper-�
		/// </remarks>
		public Guid GetObjectIdByExtProp( XParamsCollection keyPropsCollection ) 
		{
			// ������������ ���� �������� ������� �.�. ������ ����� ���������
			// �������-helper-�
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ��������� ������ �� ���������� �������� "GetObjectIdByExKey" - 
			// �������� ��������� �������������� ������� �� ��� "��������" 
			// ���������:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest( );
			requestGetId.TypeName = TypeName;
			requestGetId.Params = keyPropsCollection;

			// ��������� �������� - �������� ������ ����������
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			if ( null==responseGetId )
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObjectIdByExKey") );

			// ���������� � ���������� ������������� �� ������ ���������� 
			// � �������� ����������, �� � ������������� ��� �������� �����.
			// �������� helper-�:
			ObjectID = responseGetId.ObjectID;
			return ObjectID;
		}

		
		/// <summary>
		/// ��������� ������ ds-�������, ��������� ���������� TypeName � ObjectID
		/// ������� ���������� helper-�������. ���������� �������� �������, 
		/// GetObject. 
		/// </summary>
		/// <remarks>
		/// (1) ������������� ������� ����� ���� ����� ��� Guid.Empty - 
		///		� ���� ������ ����� �������� ������ ���������� ds-������� 
		///		� ����������������� ��������� �������� new � ���������������
		///		��������� �������� oid; ����� ���������� �������� ��� ��������
		///		����� ������������ ����� �������� ObjectID.
		/// (2) �������� �������� �������:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject() 
		{
			// �������� ������������� �������
			LoadObject( (string[])null );
		}

			
		/// <summary>
		/// ������������� ������� - ��������� ������ ds-�������, ��������� 
		/// ���������� TypeName � ObjectID, � �������� ����� ��� �������
		/// ���������� �������� �������, GetObject. 
		/// </summary>
		/// <param name="arrPreloadProperties">������ ������������ ������������ ����������, �.�. null</param>
		/// <remarks>
		/// (1) ������������� ������� ����� ���� ����� ��� Guid.Empty - 
		///		� ���� ������ ����� �������� ������ ���������� ds-������� 
		///		� ����������������� ��������� �������� new � ���������������
		///		��������� �������� oid; ����� ���������� �������� ��� ��������
		///		����� ������������ ����� �������� ObjectID.
		/// (2) �������� �������� �������:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject( string[] arrPreloadProperties ) 
		{
			// ������������ ���� �������� ������� �.�. ������ 
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ��������� ������ �� ���������� �������� ��������� ������ 
			// ds-�������, GetObject. � �����. �� ������������� ��������,
			// ������������� ������� ����� ���� ����� ��� Guid.Empty - 
			// � ���� ������ ����� �������� ������ ���������� ds-������� 
			// � ����������������� ��������� �������� new � ���������������
			// ��������� �������� oid
			XGetObjectRequest requestGet = new XGetObjectRequest( TypeName, ObjectID );
			requestGet.PreloadProperties = arrPreloadProperties;
			XGetObjectResponse responseGet = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGet );
			if (null==responseGet)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObject") );

			// ������������ �������� ������� � �����. � ����������� �������:
			m_xmlDatagram = responseGet.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );
		}

		
		/// <summary>
		/// ��������� ������ ds-�������, ��������� ���������� TypeName - �
		/// ������ ObjectID - ���������� ����� "��������" �������. 
		/// ���������� �������� �������, GetObjectByExKey		
		/// </summary>
		/// <param name="keyPropsCollection">
		/// ��������� �������� "��������" ������� �������, ��� ������ ���� 
		/// XParamsCollection. ����� ������������ ��������� ���� ������������
		/// ��������, �������� ��������� - �������� ��������
		/// </param>
		/// <remarks>
		/// (1) ������������ ���� �������� ������� �.�. ������ ����� ���������
		///		�������-helper-�; ��. �������� TypeName � "���������" ������
		/// (2) ���� ������� (������) ������ �� �����, ����� ������������� 
		///		���������� ���� ArgumentException, ��. ���������� �������� 
		///		GetObjectByExKeyCommand
		/// (3) ����� �������� �������� �������:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public void LoadObject( XParamsCollection keyPropsCollection ) 
		{
			// ������������ ���� ������ ���� ������
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ��������� ������ �� ���������� �������� "GetObjectByExKey" - 
			// �������� �������� ������ �������, ��������� ����������
			// ����� �������:
			GetObjectByExKeyRequest requestGetEx = new GetObjectByExKeyRequest( TypeName, keyPropsCollection );

			// ��������� �������� - �������� ������ ����������
			XGetObjectResponse responseGet = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGetEx );
			if (null==responseGet)
				throw new InvalidOperationException( String.Format(ERRFMT_INVALID_NULL_OPERATION_RESULT,"GetObject") );

			// ������������� �������� ������� � �����. �� ���������� ���������� 
			// (����������, �������� ����� ���� �������������� � ����� �������
			// ������������ ���������� - ��� ��� ��������� �������� ���� �������
			// � �����. � ���������� �� ����������)
			m_xmlDatagram = responseGet.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );
		}

		
		/// <summary>
		/// "����������" �������� ������ ds-�������, ��������� ���������� 
		/// TypeName - � ������ ObjectID - ���������� ����� "��������" 
		/// �������. � ������� �� LoadObject, ������� ��������� �������� 
		/// ��������� ��������������, � ��������� ������ ������ � ��� ������
		/// ���� ������������� ����� �������.
		/// ���������� �������� ������� GetObjectIdByExKey � GetObject
		/// </summary>
		/// <param name="keyPropsCollection">
		/// ��������� �������� "��������" ������� �������, ��� ������ ���� 
		/// XParamsCollection. ����� ������������ ��������� ���� ������������
		/// ��������, �������� ��������� - �������� ��������
		/// </param>
		/// <returns>
		/// ���������� �������: true, ���� ������, �������� ���������� �����
		/// �������, ��� ������ � ��� ������ ������� ���������; ����� - false
		/// </returns>
		/// <remarks>
		/// (1) ������������ ���� �������� ������� �.�. ������ ����� ���������
		///		�������-helper-�; ��. �������� TypeName � "���������" ������
		/// (2) ����� �������� �������� �������:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public bool SafeLoadObject( XParamsCollection keyPropsCollection ) 
		{
			// ������������ ���� ������� ������ ���� ������
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ...�������� ������������� �����
			return SafeLoadObject( keyPropsCollection, null );
		}


		/// <summary>
		/// ������������ ������ ������ SafeLoadObject; ��������� ����������� 
		/// ��������� ���. �������.
		/// </summary>
		/// <param name="keyPropsCollection">
		/// ��������� �������� "��������" ������� �������, ��� ������ ���� 
		/// XParamsCollection. ����� ������������ ��������� ���� ������������
		/// ��������, �������� ��������� - �������� ��������
		/// </param>
		/// <param name="arrPreloadProperties">
		/// ������ ������������ ������������ ����������, �.�. null
		/// </param>
		/// <returns>
		/// ���������� �������: true, ���� ������, �������� ���������� �����
		/// �������, ��� ������ � ��� ������ ������� ���������; ����� - false
		/// </returns>
		/// <remarks>
		/// (1) ������������ ���� �������� ������� �.�. ������ ����� ���������
		///		�������-helper-�; ��. �������� TypeName � "���������" ������
		/// (2) ����� �������� �������� �������:
		///		<see cref="ObjectID"/>, 
		///		<see cref="IsNewObject"/>, 
		///		<see cref="IsLoaded"/>
		///		<see cref="Datagram"/>
		/// </remarks>
		public bool SafeLoadObject( XParamsCollection keyPropsCollection, string[] arrPreloadProperties ) 
		{
			// ������������ ���� ������� ������ ���� ������
			ValidateRequiredArgument( TypeName,"TypeName" );

			// ���� ��������� ������� ��������������� �� ������ - �� � ���� �������� 
			// ("��������" ��������������) ������� ��� ObjectID; �������, ��� ���� 
			// ���������, ���� ������������� �.�. ������:
			if (null == keyPropsCollection)
			{
				if (Guid.Empty==ObjectID)
					throw new ArgumentException( "�� ������ �� ��������� \"�������\" ���������������, �� ��� ������������� �������!" );
				keyPropsCollection = new XParamsCollection();
				keyPropsCollection.Add( "ObjectID", ObjectID );
			}

			// #1: ��������� ������ �� ����������� �������������� ������� 
			// ��������� ���������� ��� "��������" �������:
			GetObjectIdByExKeyRequest requestGetId = new GetObjectIdByExKeyRequest();
			requestGetId.TypeName = TypeName;
			requestGetId.Params = keyPropsCollection;
			// ��������� �������� - �������� ������ ����������
			GetObjectIdByExKeyResponse responseGetId = (GetObjectIdByExKeyResponse)AppServerFacade.ExecCommand( requestGetId );
			if (null==responseGetId)
				return false;
			// ���� ������������� ������� ���������� �� ������� - �������
			if (Guid.Empty==responseGetId.ObjectID)
				return false; 
			
			// #2: ��������� ������ �� �������� ������ ��������� 
			// ������������������� ds-�������:
			XGetObjectRequest requestGetObject = new XGetObjectRequest( TypeName, responseGetId.ObjectID );
			requestGetObject.PreloadProperties = arrPreloadProperties;
			XGetObjectResponse responseGetObject = (XGetObjectResponse)AppServerFacade.ExecCommand( requestGetObject );
			if (null==responseGetObject)
				return false;
			if (null==responseGetObject.XmlObject)
				return false;

			// ������������� �������� ������� � �����. � ����������� ds-�������:
			m_xmlDatagram = responseGetObject.XmlObject;
			m_bIsNewObject = ("1"==m_xmlDatagram.GetAttribute("new"));
			m_uidObjectID = XmlConvert.ToGuid( m_xmlDatagram.GetAttribute("oid") );

			return true;
		}

		
		/// <summary>
		/// ���������� ������ ds-�������, �������������� �����������, 
		/// ������������� helper-��������. ���������� �������� ������� 
		/// ���������� SaveObject
		/// </summary>
		/// <remarks>
		/// ���� ������������ ������ ������ ������� - �� ����� ������
		/// ������� new � ���������� ������� ����� ����
		/// </remarks>
		public void SaveObject() 
		{
            // ������������ ���� � ������������� ������� ������ ���� ������
            ValidateRequiredArgument(TypeName, "TypeName");
            if (null == Datagram)
                throw new InvalidOperationException(ERRFMT_INVALID_DATA_NOTLOAD);

            // ��������� ������ �� ���������� �������� ������ ������
            XSaveObjectRequest requestSave = new XSaveObjectRequest();
            requestSave.XmlSaveData = Datagram;
            // ...� ��������� �������� - �������� ������ ����������
            AppServerFacade.ExecCommand(requestSave);

            // ���� ������ ������ ��� ������ - ������ ������� "new" � ����������
            // � �����. ������������� �������� �������� IsNewObject - ��� ���� 
            // ������ �������� ����� ������, �� ����� �������� (�.�. ���������
            // �������� "�����" ����������):
            Datagram.RemoveAttribute("new");
            m_bIsNewObject = false;
		}
		
        /// <summary>
		/// ��������� ����������� ������ ������ ���������� �������� �� ���� 
		/// ���������� �������� SaveObject; ������������� �����
		/// </summary>
		/// <param name="helpers">
		/// ������ helper-��������, ������ �������� ����� �������� �� ������
		/// � ������� ����� ����������. �������� ������� ����� ���� null-���;
		/// ����� ��� ����� ���������� ����� ��������������.
		/// </param>
		/// <remarks>
		/// (1) ��������! ����� �� ��������� �����-���� �������� ��������������
		///		������ ���������, �������������� � helper-��������. ��� ������ 
		///		��������� ������� �������� ������������ ������, �������������� 
		///		� �����������, ������ ����������� ���������� �����!
		/// (2) ���� ������������ ������ ������ ������� - �� ����� ������
		///		������� new � ��������������� ���������� ����� ����
		/// </remarks>
		public static void SaveComplexDatagram( params ObjectOperationHelper[] helpers ) 
		{
            SaveComplexDatagram(helpers, null, null);
		}

		/// <summary>
		/// ��������� ����������� ������ ������ ���������� �������� �� ���� 
		/// ���������� �������� SaveObject; ������������� �����
		/// </summary>
		/// <param name="helpers">
		/// ������ helper-��������, ������ �������� ����� �������� �� ������
		/// � ������� ����� ����������. �������� ������� ����� ���� null-���;
		/// ����� ��� ����� ���������� ����� ��������������.
		/// </param>
        /// <param name="rootObjectID">
        /// TODO: ������� ��������
        /// </param>
        /// <param name="sContext">
        /// TODO: ������� ��������
        /// </param>
		/// <remarks>
		/// (1) ��������! ����� �� ��������� �����-���� �������� ��������������
		///		������ ���������, �������������� � helper-��������. ��� ������ 
		///		��������� ������� �������� ������������ ������, �������������� 
		///		� �����������, ������ ����������� ���������� �����!
		/// (2) ���� ������������ ������ ������ ������� - �� ����� ������
		///		������� new � ��������������� ���������� ����� ����
		/// </remarks>
		public static void SaveComplexDatagram( ObjectOperationHelper[] helpers, XObjectIdentity rootObjectID, string sContext ) 
		{
            // ������������ ���������: 
            XmlElement xmlComplexDatagramRoot = MakeComplexDatagarmm(helpers);

            // ... � �������� ������������� �����, ����������� ����������:
            SaveComplexDatagram(xmlComplexDatagramRoot, rootObjectID, sContext);

            // ���� ������ ����������� ��� ������ - ������� �������� "new" � ����
            // ��������� ���� helper-��, ����������� � ������; ��� ���� ������ 
            // �������� ����� ������, �� ����� �������� (�.�. ��������� �������� 
            // "�����" ����������):
            foreach (ObjectOperationHelper helper in helpers)
            {
                if (null != helper)
                {
                    helper.m_xmlDatagram.RemoveAttribute("new");
                    helper.m_bIsNewObject = false;
                }
            }
		}
		
		/// <summary>
		/// ��������� ����������� ������ ������ ���������� �������� �� ���� 
		/// ���������� �������� SaveObject; ������������� �����
		/// </summary>
		/// <param name="xmlComplexDatagramRoot">XML-������ ����������� ����������</param>
        /// <param name="rootObjectID">TODO: ������� ��������</param>
        /// <param name="sContext">��������</param>
		/// <remarks>
		/// (1) ��������! ����� �� ��������� �����-���� �������� ��������������
		///		������ ���������, �������������� � helper-��������. ��� ������ 
		///		��������� ������� �������� ������������ ������, �������������� 
		///		� �����������, ������ ����������� ���������� �����!
		/// (2) ����� ������ �������� ���������� ����� �� ��������������! ����
		///		������ ���������� ������������� �� ��������� ������ helper-��������,
		///		�� ��������� �.�. ����������� ��� ���������������
		/// </remarks>
        public static void SaveComplexDatagram(XmlElement xmlComplexDatagramRoot, XObjectIdentity rootObjectID, string sContext) 
		{

			// ��������� ������ � ��������� �������� - �������� ������ ����������
			XSaveObjectRequest requestSave = new XSaveObjectRequest();
			requestSave.XmlSaveData = xmlComplexDatagramRoot;
            requestSave.RootObjectId = rootObjectID;
            requestSave.Context = sContext;
			AppServerFacade.ExecCommand( requestSave );
		}


		/// <summary>
		/// ������� ������ ds-�������, ��������� ������������� ���� � 
		/// ���������������, ��������������� ������� helper-��������. 
		/// ���������� �������� ������� ���������� DeleteObject
		/// </summary>
		/// <returns>True, ���� ������ ��� ������, false - �����</returns>
		/// <remarks>
		/// ���� helper-������ �������� ������ ds-�������, �� �����
		/// ��������� ���������� �������� ��� ������ ����� ��������
		/// </remarks>
		public bool DeleteObject() 
		{
			ValidateRequiredArgument( TypeName, "TypeName" );
			if (Guid.Empty==ObjectID)
				throw new ArgumentException("������������� ���������� ������� �� �����", "ObjectID");

			XDeleteObjectRequest requestDelete = new XDeleteObjectRequest( TypeName, ObjectID );
			XDeleteObjectResponse responseDelete = (XDeleteObjectResponse)AppServerFacade.ExecCommand( requestDelete );

			if ( 0!=responseDelete.DeletedObjectQnt)
				m_xmlDatagram = null;
			return ( 0!=responseDelete.DeletedObjectQnt );
		}

		
		/// <summary>
		/// ������� ������ ds-�������, ��������� ������������� ���� � -
		/// ������ ObjectID - ���������� ����� "��������" �������.
		/// ���������� �������� �������, DeleteObjectByExKey
		/// </summary>
		/// <param name="keyPropsCollection">
		/// ��������� �������� "��������" ������� �������, ��� ������ ���� 
		/// XParamsCollection. ����� ������������ ��������� ���� ������������
		/// ��������, �������� ��������� - �������� ��������
		/// </param>
		/// <param name="bTreatNotExistsAsDeleted">
		/// ����, ����������� ���������� ������ � ������ ���������� ���������� 
		/// �������: ���� true, �� "��������" �������������� ����������� �������
		/// (�� ����� ��� ���� ���������� false), ���� false - �� ��� �������
		/// �������� �������������� ������������ ����������.
		/// </param>
		/// <returns>True, ���� ������ ��� ������, false - �����</returns>
		/// <remarks>
		/// (1) ������������ ���� �������� ������� �.�. ������ ����� ���������
		///		�������-helper-�; ��. �������� TypeName � "���������" ������
		/// (2) ���� �������� ������ ������ �� �����, ����� ������������� 
		///		���������� ���� ArgumentException, ��. ���������� �������� 
		///		DeleteObjectByExKeyCommand
		/// (3) ���� helper-������ �������� ������ ds-�������, �� �����
		///		��������� ���������� �������� ��� ������ ����� ��������
		/// </remarks>
		public bool DeleteObject( XParamsCollection keyPropsCollection, bool bTreatNotExistsAsDeleted ) 
		{
			ValidateRequiredArgument( TypeName,"sTypeName" );
			if (null==keyPropsCollection)
				throw new ArgumentNullException( "keyPropsCollection", "��������� �������������� ��������������� �������� ������ ���� ������!" );

			DeleteObjectByExKeyRequest requestDeleteEx = new DeleteObjectByExKeyRequest( TypeName, keyPropsCollection );
			requestDeleteEx.TreatNotExistsObjectAsDeleted = bTreatNotExistsAsDeleted;
			XDeleteObjectResponse responseDelete = (XDeleteObjectResponse)AppServerFacade.ExecCommand( requestDeleteEx );

			if ( 0!=responseDelete.DeletedObjectQnt )
				m_xmlDatagram = null;
			return ( 0!=responseDelete.DeletedObjectQnt );
		}


		#endregion

		#region ������ ������ � �������� ���������� - ���������� "���������� ������" (data-sources)
		
		/// <summary>
		/// ��������� �������� ������� ���������� "��������� �������� ������" 
		/// (ExecuteDataSource) � ���������� ���������� ������ ��� DataTable
		/// </summary>
		/// <param name="sDataSourceName">������������ ��������� ������</param>
		/// <param name="dataSourceParams">��������� �������� ���������� ��������� ������</param>
		/// <returns>��������� ����������, ��� DataTable</returns>
		public static DataTable ExecAppDataSource( string sDataSourceName, XParamsCollection dataSourceParams ) 
		{
			// "��������" �������� ������� ���������� 
			if (null==sDataSourceName)
				throw new ArgumentNullException("������������ �������� ��������� sDataSourceName");
			if (0==sDataSourceName.Length)
				throw new ArgumentException("������������ �������� ��������� sDataSourceName");

			// ��������� ������ �� ���������� �������� ExecuteDataSource - ����������
			// ���������������� SQL-��������, �������� � ���������� ����������
			XExecuteDataSourceRequest request = new XExecuteDataSourceRequest();
			request.DataSourceName = sDataSourceName;
			request.Params = dataSourceParams;

			XExecuteDataSourceResponse response = (XExecuteDataSourceResponse)AppServerFacade.ExecCommand( request );
			if (null==response)
				throw new InvalidOperationException("������ ���������� �������� ������� ����������: � �������� ���������� ������� null");

			return response.Data;
		}


		/// <summary>
		/// ��������� �������� ������� ���������� "��������� �������� ������" 
		/// (ExecuteDataSource) � ���������� ��������� �������� (�������������
		/// �������� ������ ������ ������� ������� ��������� DataTable)
		/// </summary>
		/// <param name="sDataSourceName">������������ ��������� ������</param>
		/// <param name="dataSourceParams">��������� �������� ���������� ��������� ������</param>
		/// <returns>
		/// �������� ��������� ��������. ���� � ���������� DataTable �������
		/// �� ����� ��� �� ����� ��������� ������, ����� ���������� null
		/// </returns>
		public static object ExecAppDataSourceScalar( string sDataSourceName, XParamsCollection dataSourceParams ) 
		{
			DataTable resultData = ExecAppDataSource( sDataSourceName, dataSourceParams );

			// ��� ���������� ������ ������ ������� ������ ������ ����������� 
			// ���������� (����, �������, ������� ������������):
			object oResult = null;
			if (null!=resultData)
			{
				if (resultData.Rows.Count>0 && resultData.Columns.Count>0)
					oResult = resultData.Rows[0][0];
			}

			return oResult;
		}
	
		
		/// <summary>
		/// ��������� �������� ������� ���������� "��������� �������� ������" 
		/// (ExecuteDataSource) � ���������� ������ � ���� ��������� XML, 
		/// ������������������ ��� ������ ���������������� ������-���������������
		/// <see cref="DataTableXmlFormatter"/>
		/// </summary>
		/// <param name="sDataSourceName">������������ ��������� ������</param>
		/// <param name="dataSourceParams">��������� �������� ���������� ��������� ������</param>
		/// <param name="sResultItemName">������������ �������� XML-���������, �����. ������ �������� ������</param>
		/// <returns>�������� XML � ������� ��������� ������</returns>
		public static XmlDocument ExecAppDataSourceSpecial( 
			string sDataSourceName, 
			XParamsCollection dataSourceParams, 
			string sResultItemName ) 
		{
			// "��������" �������� ������� ���������� 
			if (null==sDataSourceName)
				throw new ArgumentNullException("������������ �������� ��������� sDataSourceName");
			if (0==sDataSourceName.Length)
				throw new ArgumentException("������������ �������� ��������� sDataSourceName");
			if (null==sResultItemName)
				throw new ArgumentNullException("������������ �������� ��������� sResultItemName");
			if (0==sResultItemName.Length)
				throw new ArgumentNullException("������������ �������� ��������� sResultItemName");

			// ��������� ������ �� ���������� �������� ExecuteDataSource - ����������
			// ���������������� SQL-��������, �������� � ���������� ����������
			XExecuteDataSourceRequest request = new XExecuteDataSourceRequest();
			request.DataSourceName = sDataSourceName;
			// ���� ��������� ������ - ����������� ��:
			if (null!=dataSourceParams)
				request.Params = dataSourceParams;

			XExecuteDataSourceResponse response = (XExecuteDataSourceResponse)AppServerFacade.ExecCommand( request );
			if (null==response)
				throw new InvalidOperationException("������ ���������� �������� ������� ����������: � �������� ���������� ������� null");

			// ��� ��������� ��������� XML-��������� ���������� �����-�������������:
			return DataTableXmlFormatter.GetXmlFromDataTable( 
				response.Data,
				DataTableXmlFormatter.DEFAULT_ROOT_ELEMENT_NAME,
				sResultItemName
			);
		}

		
		#endregion

		#region ����� ��������������� ������ - ��������������� �������� ������������� ������

		/// <summary>
		/// ������������ �������� ������, �������������� � ���� ������ � �������
		/// bin.hex, � ������, �������������� � ������� bin.base64
		/// </summary>
		/// <param name="sDataBinHex">�������� ������ � ������� � bin.hex-�������</param>
		/// <returns>�������������� ������ � ������� � bin.base64</returns>
		/// <remarks>
		/// ���� � �������� �������� ������ ����� null, ����� ��������� ������ ������
		/// </remarks>
		public static string ConvertBinHexToBinBase64( string sDataBinHex ) 
		{
			string sResultDataBinBase64 = String.Empty;
			if (null!=sDataBinHex && sDataBinHex.Length>0)
			{
				// ��������� ������ ����, �� ��������� ���������� ������
				int nSize = (sDataBinHex.Length/2);
				byte[] arrPictureData = new byte[nSize];
				for( int nIndex=0; nIndex<nSize; nIndex++ )
					arrPictureData[nIndex] = byte.Parse( sDataBinHex.Substring(nIndex*2, 2), NumberStyles.HexNumber );
				
				// �� ��������� ����������� ������� (������) ���� ���������
				// ������ � ������������� bin.base64:
				sResultDataBinBase64 = Convert.ToBase64String(arrPictureData);
			}
			return sResultDataBinBase64;
		}


		/// <summary>
		/// ������������ �������� ������, �������������� � ���� ������ � �������
		/// bin.base64, � ������, �������������� � ������� bin.hex
		/// </summary>
		/// <param name="sDataBinBase64">�������� ������ � ������� � ������� bin.base64</param>
		/// <returns>�������������� ������ � ������� � bin.hex</returns>
		/// <remarks>
		/// ���� � �������� �������� ������ ����� null, ����� ��������� ������ ������
		/// </remarks>
		public static string ConvertBinBase64ToBinHex( string sDataBinBase64 ) 
		{
			string sResultDataBinHex = String.Empty;
			if (null!=sDataBinBase64 && 0!=sDataBinBase64.Length)
			{
				// �������� ������ ����
				byte[] arrPictureData = Convert.FromBase64String( sDataBinBase64 );
				// ����� �������� ��������������� �������� ��������� �����
				System.Text.StringBuilder sPictureBinHex = new System.Text.StringBuilder( arrPictureData.Length*2 );
				// ... � ��������� ��� 16-������ �������������� 
				for( int nIndex=0; nIndex<arrPictureData.Length; nIndex++)
					sPictureBinHex.Append( arrPictureData[nIndex].ToString("x2") );
				sResultDataBinHex = sPictureBinHex.ToString();
			}
			return sResultDataBinHex;
		}
	

		#endregion 

		#region ������ �������� �������� ���������� ��������

		/// <summary>
		/// ������ ��������� � ������ ��������� (String.Empty, Guid.Empty � �.�.)
		/// </summary>
		private const string ERR_ARG_EMPTY_MSG_FMT = "�������� ��������� {0} ������ ���� ������!";
		/// <summary>
		/// ������ ��������� �� ���������, ������� �� ����� ���� ���������� � null
		/// </summary>
		private const string ERR_ARG_NOTNULL_MSG_FMT = "�������� {0} �� ����� ���� ����� � null!";
		/// <summary>
		/// ������ ��������� �� ������� ��������� ���������, ��������� GUID-������������� �������
		/// </summary>
		private const string ERR_ARG_INVALID_GUID_FMT = "�������� ��������� {0} �� �������� GUID-��������������� �������!";
        /// <summary>
        /// ������ ��������� �� ������� �������������� ���������, ��������� �������
        /// </summary>
        private const string ERR_ARG_INVALID_PERCENTAGE_FMT = "�������� ��������� {0} ������ ���� ����� ������������� ������ �� ����� 100!";
		

		/// <summary>
		/// ����� ���������� �������� ������������� ��������� ��������� - � ������,
		/// ���� �������� ����� null ��� String.Empty, ���������� ��������������� 
		/// ����������
		/// </summary>
		/// <param name="sArgValue">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <exception cref="ArgumentNullException">���� null == sArgValue</exception>
		/// <exception cref="ArgumentException">���� String.Empty == sArgValue</exception>
		public static void ValidateRequiredArgument( string sArgValue, string sArgName ) 
		{
			ValidateRequiredArgument( sArgValue, sArgName, null );
		}

       
		
		/// <summary>
		/// ����� ���������� �������� ������������� ��������� ��������� - � ������,
		/// ���� �������� ����� null ��� String.Empty, ���������� ��������������� 
		/// ����������; ����� ��� �� ��������� �������� ������������ ��������� 
		/// �������� ���������� ����, ������ ��: Int32, Bool, Guid;
		/// </summary>
		/// <param name="sArgValue">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <param name="oTreatAsType">
		/// ���, �� ������������ �������� ����������� �������� ��������; ����� ���� 
		/// ���� �� �������� Int32, Bool, Guid, ��� null - � ��������� ������ 
		/// �������� �� ������������ ���� �� �����������
		/// </param>
		/// <exception cref="ArgumentNullException">���� null == sArgValue</exception>
		/// <exception cref="ArgumentException">���� String.Empty == sArgValue</exception>
		public static void ValidateRequiredArgument( string sArgValue, string sArgName, Type oTreatAsType ) 
		{
			if (null == sArgValue)
				throw new ArgumentNullException( sArgName, String.Format( ERR_ARG_NOTNULL_MSG_FMT,sArgName ) );
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		
			if (null != oTreatAsType)
			{
				bool bIsAcceptableType = true;
				try
				{
					if (oTreatAsType.Equals( typeof(Int32) ))
					{
						Int32.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Boolean) ))
					{
						Boolean.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Guid) ))
					{
						new Guid( sArgValue );
					}
					else
						bIsAcceptableType = false;
				}
				catch(Exception err)
				{
					throw new ArgumentException( 
						String.Format(
							"�������� �������� {0} ({1}) �� ����� ���� ��������� � ���������� ���� {2}",
							sArgName, sArgValue, oTreatAsType.Name
						), sArgName, err );
				}
				if (!bIsAcceptableType)
					throw new ArgumentException(
						"������� �������� �� ����� ���� ��������� �� ������������ ���� " + oTreatAsType.Name + " - ��������� ��� �� ��������������!",
						"oTreatAsType" );
			}
		}

		
		/// <summary>
		/// ����� ���������� �������� ��������� ���� System.Guid - � ������, ���� 
		/// �������� ����� Guid.Empty, ���������� ��������������� ����������
		/// </summary>
		/// <param name="uidArgValue">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <exception cref="ArgumentException">���� Guid.Empty == uidArgValue</exception>
		public static void ValidateRequiredArgument( Guid uidArgValue, string sArgName ) 
		{
			if (Guid.Empty == uidArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		}

		
		/// <summary>
		/// ����� ���������� �������� ��������������� ���������� ��������� - 
		/// � ������, ���� �������� ����� String.Empty, ���������� 
		/// ��������������� ����������
		/// </summary>
		/// <param name="sArgValue">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <exception cref="ArgumentException">���� String.Empty == sArgValue</exception>
		public static void ValidateOptionalArgument( string sArgValue, string sArgName ) 
		{
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );
		}

		
		/// <summary>
		/// ����� ���������� �������� ��������������� ���������� ��������� - 
		/// � ������, ���� �������� ����� String.Empty, ���������� 
		/// ��������������� ����������
		/// </summary>
		/// <param name="sArgValue">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <param name="oTreatAsType">
		/// ���, �� ������������ �������� ����������� �������� ��������; ����� ���� 
		/// ���� �� �������� Int32, Bool, Guid, ��� null - � ��������� ������ 
		/// �������� �� ������������ ���� �� �����������
		/// </param>
		/// <exception cref="ArgumentException">���� String.Empty == sArgValue</exception>
		/// <exception cref="ArgumentException">���� �������� �������� �� �����. ���������� ����</exception>
		public static void ValidateOptionalArgument( string sArgValue, string sArgName, Type oTreatAsType ) 
		{
			if (String.Empty == sArgValue)
				throw new ArgumentException( String.Format( ERR_ARG_EMPTY_MSG_FMT,sArgName ), sArgName );

			if (null!=oTreatAsType && null!=sArgValue)
			{
				bool bIsAcceptableType = true;
				try
				{
					if (oTreatAsType.Equals( typeof(Int32) ))
					{
						Int32.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Boolean) ))
					{
						Boolean.Parse( sArgValue );
					}
					else if (oTreatAsType.Equals( typeof(Guid) ))
					{
						new Guid( sArgValue );
					}
					else
						bIsAcceptableType = false;
				}
				catch(Exception err)
				{
					throw new ArgumentException( 
						String.Format(
							"�������� �������� {0} ({1}) �� ����� ���� ��������� � ���������� ���� {2}",
							sArgName, sArgValue, oTreatAsType.Name
						), sArgName, err );
				}
				if (!bIsAcceptableType)
					throw new ArgumentException(
						"������� �������� �� ����� ���� ��������� �� ������������ ���� " + oTreatAsType.Name + " - ��������� ��� �� ��������������!",
						"oTreatAsType" );
			}
		}

		
		/// <summary>
		/// �������� ������������ ���������� ���������, ��������� GUID-�������������
		/// </summary>
		/// <param name="sObjectID">�������� ���������</param>
		/// <param name="sArgName">������������ ���������</param>
		/// <exception cref="ArgumentNullException">���� null == sObjectID</exception>
		/// <exception cref="ArgumentException">���� String.Empty == sObjectID</exception>
		/// <exception cref="ArgumentException">���� sObjectID �� ����� ���� �������� � GUID</exception>
		public static Guid ValidateRequiredArgumentAsID( string sObjectID, string sArgName ) 
		{
			// #1: ���������, ��� ������ ������ ������ (�� null � �� ������):
			ValidateRequiredArgument(sObjectID, sArgName);

			// #2: ������� ��������� � Guid:
			Guid uidResulGuid;
			try { uidResulGuid = new Guid( sObjectID.ToLower().Trim() ); }
			catch( Exception err )
			{
				throw new ArgumentException( String.Format(ERR_ARG_INVALID_GUID_FMT,sArgName), sArgName, err );
			}

			// #3: ���������, ��� ���������� Guid �� ���� Guid.Empty:
			if (Guid.Empty == uidResulGuid)			
				throw new ArgumentException( String.Format(ERR_ARG_EMPTY_MSG_FMT,sArgName), sArgName );

			return uidResulGuid;
		}


        /// <summary>
        /// �������� ������������ �������������� ���������, ��������� �������
        /// </summary>
        /// <param name="nPercent">�������� ���������</param>
        /// <param name="sArgName">������������ ���������</param>
        /// <exception cref="ArgumentNullException">���� null == nPercent</exception>
        /// <exception cref="ArgumentException">���� nPercent ������ 0 </exception>
        /// <exception cref="ArgumentException">���� nPercent ������ 100 </exception>
        public static int ValidateRequiredArgumentAsPercentage(int nPercent, string sArgName)
        {
            // #2: ���������, ��� ������� ������ ��� ����� 0 � �� ����� 100
            if ( (nPercent < 0 ) || (nPercent > 100 ) )
                throw new ArgumentException(String.Format(ERR_ARG_INVALID_PERCENTAGE_FMT, sArgName), sArgName);

            return nPercent;
        }
		
		#endregion 
	}
}