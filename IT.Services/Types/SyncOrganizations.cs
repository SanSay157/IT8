//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
// �������������� ������ � ������������, ������������ � ������� ������������� 
// ������ ����������� - ��. ���������� ������� CommonService
using System;

namespace Croc.IncidentTracker.Services
{
	/// <summary>
	/// ������������ ������ ���������� �����������, �������� ������� ������������ 
	/// � ��������������� ����������� ������� Incident Tracker
	/// </summary>
	[Serializable]
	public class OrganizationInfo 
	{
		/// <summary>
		/// ������ c ��������� �������������� �����������, ������ �������
		/// ������������ ����������� ������. 
		/// �������� ������������� ����������� �������� ObjectID ������� 
		/// ������������� (Organization). 
		/// ������������ ��������; �� ����� ���� ������ �������.
		/// </summary>
		public string ObjectID;

		/// <summary>
		/// ������ � ��������� ���� �������� ����������� � ���, ����������������
		/// ������� ��������. �������� �������� �������� ��� ��� �������� ��������
		/// � IT � � ���������� ������������ ��� ������ ��������.
		/// �������� ������������� �������� ���� ������������� ��Ȼ 
		/// (Organization.RefCodeNSI) ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������.
		/// </summary>
		public string RefCodeNSI;

		/// <summary>
		/// ������� ������������, ������������ �����������.
		/// �������� ������������� �������� �������� ������������ 
		/// (Organization.ShortName) ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������.
		/// </summary>
		public string ShortName;
		
		/// <summary>
		/// ������ ������������ �����������.
		/// �������� ������������� �������� ������������� (Organization.Name) 
		/// ������� ������������� (Organization).
		/// ������������ ��������; �� ����� ���� ������ �������
		/// </summary>
		public string Name;

		/// <summary>
		/// ������ � ��������� �������������� ����������� ����������� (������� �����
		/// ����������� ����������). ����������� �������� - ������������� �������� 
		/// ��������������� ����������� � ������� IT, ��� ���� �������� �������� ����
		/// ������������� � �������.
		/// �������� ������������� ��������  ������������� (Organization.Parent) 
		/// ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������; ���� �������� �� ������, ��
		/// ���������, ��� ������ ����������� ����������� �� ������.
		/// </summary>
		public string ParentOrganizationID;
		
		/// <summary>
		/// ������ � ��������� �������������� ����������, ������������ ����������� 
		/// ��������� �������. ����������� �������� - ������������� �������� 
		/// ���������� � ������� IT (�.�., � �������� ���, ������), ��� ���� ��������� 
		/// �������� ���� ������������� � �������.
		/// �������� ������������ ��������  ��������� ������� (Organization.Director) 
		/// ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������; ���� �������� �� ������, ��
		/// ���������, ��� ������ ����������� �������� ������� �� �����.
		/// </summary>
		/// <remarks>
		/// ��������!
		/// �� ������ ����� � �������� �������� � ��� ��� �������� ����������� 
		/// ������������ ������������� ������������� - ��. ���������� ������� 
		/// ������������� ������ ����������� ����������� ������� NSISyncService.
		/// ��������������, ����� ������ ������������� ������������� �������������� 
		/// �� �����!
		/// </remarks>
		public string DirectorEmployeeID;

		/// <summary>
		/// ������ ����� � ���������������� ��������, ������������ � ������ 
		/// ������������. ������ ����������� �������� - ������������� �������� 
		/// ������� � ������� IT (�.�., � �������� ���, ������), ��� ���� ��������� 
		/// �������� ���� ������������ � �������.
		/// �������� ������������� ��������  ��������� (�����-������ Organization_Branch) 
		/// ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������; ���� �������� �� ������, ��
		/// ���������, ��� � ������ ������������ �� ���������� �� ���� �������.
		/// </summary>
		/// <remarks>
		/// ��������!
		/// �� ������ ����� � �������� �������� � ��� ��� �������� ��������
		/// ������������ ������������� ������������� - ��. ���������� ������� 
		/// ������������� ������ ����������� �������� ������� NSISyncService.
		/// ��������������, ����� ������ ������������� ������������� �������������� 
		/// �� �����!
		/// </remarks>
		public string[] BranchesIDs;

		/// <summary>
		/// ������ � ������� ����������� � �������� �����������.
		/// �������� ������������� �������� ������������ (Organization.Comment) 
		/// ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������; 		
		/// </summary>
		public string Comment;

		/// <summary>
		/// ������ � ��������������� ���������������� �������� ����������� 
		/// � ������� Navision.
		/// �������� ������������� �������� �������������� �� ������� ������� 
		/// (Organization.ExternalID) ������� ������������� (Organization).
		/// ������� �������� �� �������� ������������; 		
		/// </summary>
		public string NavisionID;
		
		/// <summary>
		/// ������� ����������� - ���������� ������� IT
		/// �������� ������������� �������� ������������-�������� �������� 
		/// (Organization.Home) ������� ������������� (Organization).
		/// ������� �������� �������� ������������. 
		/// </summary>
		/// <remarks>
		/// ��� ���� ������������ ������ �������� �.�. ����������� � �������� false.
		/// </remarks>
		public bool IsOwnOrganization = false;

		/// <summary>
		/// ������� �����������, ����������� ������� � ��������� ��������� ���
		/// ��������� �� ���.
		/// �������� ������������� �������� ��������� �������� �� ��� 
		/// (Organization.OwnTenderParticipant) ������� ������������� (Organization).
		/// ������� �������� �������� ������������. 
		/// </summary>
		public bool IsOwnTenderParticipant = false;


		/// <summary>
		/// ����� ����������� �������� ������������ �������� �������� �����������
		/// </summary>
		/// <param name="bTestOID">������� - ��������� ��� ��� ������������� ObjectID</param>
		public void Validate( bool bTestOID ) 
		{
			if (bTestOID)
				ObjectOperationHelper.ValidateRequiredArgument( 
					ObjectID, 
					"������������� ����������� � ������� Incident Tracker" );
			
			ObjectOperationHelper.ValidateOptionalArgument( 
				ShortName, 
				"������� ������������ ����������� (OrganizationInfo.ShortName)" );
			
			ObjectOperationHelper.ValidateRequiredArgument( 
				Name, 
				"������ ������������ ����������� (OrganizationInfo.Name)" );
			
			ObjectOperationHelper.ValidateOptionalArgument( 
				DirectorEmployeeID, 
				"������������� ���������� - ��������� ������� (OrganizationInfo.DirectorEmployeeID)", 
				typeof(Guid) );

			ObjectOperationHelper.ValidateOptionalArgument( 
				ParentOrganizationID,
				"������������� ����������� ����������� (OrganizationInfo.ParentOrganizationID)",
				typeof(Guid) );

			if (null!=BranchesIDs)
			{
				for( int nIndex=0; nIndex<BranchesIDs.Length; nIndex++ )
				{
					ObjectOperationHelper.ValidateOptionalArgument(
						BranchesIDs[nIndex],
						String.Format( "������������� �������, ������������ � ������������ (OrganizationInfo.BranchesIDs[{0}])",nIndex ),
						typeof(Guid) );
				}
			}
		}
	}
}