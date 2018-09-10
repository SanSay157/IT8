//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������ �� ���������� �������� ��������� �������������� ds-�������, 
	/// ��������� ���������� ����� ����������
	/// <seealso cref="GetObjectIdByExKeyResponse"/>
	/// </summary>
	[Serializable]
	public class GetObjectIdByExKeyRequest : XRequest 
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������
		/// </summary>
		private static readonly string DEF_COMMAND_NAME = "GetObjectIdByExKey";
		/// <summary>
		/// ����� �������� ������ ������������� ������� ����������
		/// </summary>
		private static readonly string ERR_AMBIGUOUS_PARAMS = "������ ���� ������ ���� ������������ ����, ���� ������������ ��������� ������";
		
		#region ���������� ���������� ������ 

		/// <summary>
		/// ������������ ds-����, ��� �������� ����������� ������ �� ��������� 
		/// �������������� ���������� �������; �������� �������� ��������� 
		/// ������������� �������� m_sDataSourceName
		/// </summary>
		private string m_sTypeName = null;
		/// <summary>
		/// ������������ ��������� ������, ��� ���������� �������� ��������� 
		/// ��������� �������������� ���������� �������; �������� �������� 
		/// ��������� ������������� �������� m_sTypeName 
		/// </summary>
		private string m_sDataSourceName = null;
		/// <summary>
		/// ��������� �������� ����������� ����������
		/// </summary>
		private XParamsCollection m_paramsCollection = new XParamsCollection();
		#endregion

		/// <summary>
		/// ����������� �� ���������, ��� ���������� (��)������������
		/// </summary>
		public GetObjectIdByExKeyRequest() : base(DEF_COMMAND_NAME) 
		{}

		
		/// <summary>
		/// ������������ ds-����, ��� �������� ����������� ������ �� ��������� 
		/// �������������� ���������� �������; �������� �������� ��������� 
		/// ������������� �������� DataSourceName
		/// </summary>
		/// <exception cref="ArgumentException">
		/// ��� ������� � �������� �������� �������� ������ ������</exception>
		/// <exception cref="ArgumentNullException">
		/// ��� ������� �������� �������� � null</exception>
		public string TypeName 
		{
			get { return m_sTypeName; } 
			set
			{
				XRequest.ValidateOptionalArgument( value, "TypeName" );
				m_sTypeName = value;
			}
		}

		
		/// <summary>
		/// ������������ ��������� ������, ��� ���������� �������� ��������� 
		/// ��������� �������������� ���������� �������; �������� �������� 
		/// ��������� ������������� �������� sTypeName 
		/// </summary>
		/// <exception cref="ArgumentNullException">
		/// ��� ������� �������� �������� � null</exception>
		public string DataSourceName 
		{
			get { return m_sDataSourceName; }
			set
			{
				XRequest.ValidateOptionalArgument( value, "DataSourceName" );
				m_sDataSourceName = value;
			}
		}


		/// <summary>
		/// ��������� �������� ����������� ���������� 
		/// </summary>
		/// <remarks>
		/// ��� ������� null �������� ��������������� � ��������, ���������������
		/// "������" ��������� �������� ����������
		/// </remarks>
		public XParamsCollection Params 
		{
			get { return m_paramsCollection; }
			set { m_paramsCollection = (null==value? new XParamsCollection() : value); }
		}


		/// <summary>
		/// ��������� ������������ ���������� ������ �������
		/// </summary>
		public override void Validate() 
		{
			// ����������� �������� ������� ���������� - ��� �����������
			// ��������, ������������ ������� �� ����������� 
			base.Validate();

			// ������ ���� ������ ���� ������������ ds-����, ���� ������������ 
			// ��������� ������ - �� �� ��� ������������:
			if (null!=TypeName && 0!=TypeName.Length)
			{
				if (null!=DataSourceName && 0!=DataSourceName.Length)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
			}
			else
			{
				if (null==DataSourceName)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
				if (0==DataSourceName.Length)
					throw new ArgumentException( ERR_AMBIGUOUS_PARAMS );
			}
		}
	}
}

