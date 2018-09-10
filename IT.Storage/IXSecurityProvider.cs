using System;
using System.Collections;
using System.Security.Principal;
using Croc.IncidentTracker.Storage;

namespace Croc.XmlFramework.Data.Security
{
	/// <summary>
	/// ��������� Security-provider'a. 
	/// </summary>
	public interface IXSecurityProvider
	{
		/// <summary>
		/// ������������ �������� ������������ �� ������������.
		/// ���� ������������ � ����� ������������� �� �������, �� ���������� null
		/// </summary>
		/// <param name="sUserName">������������ ������������</param>
		/// <returns></returns>
		XUser CreateUser(string sUserName);
		
		/// <summary>
		/// ���������� ���������-��������� ���������� ������������
		/// </summary>
		/// <returns></returns>
		XUser CreateAnonymousUser();
		
		/// <summary>
		/// ��������� �������� ������������, ������� ���� ��������
		/// </summary>
		/// <param name="user">��������� XUser ��� �����������, � �������� �������� IsFlushed=true</param>
		void UpdateUser(XUser user);
		
		/// <summary>
		/// ���������� ������������ ������������ �� ���������� IPrincipal.
		/// </summary>
		/// <remarks>
		/// ���������� ������ ������������ IPrincipal �� ������������ ������������. 
		/// ��������� ������� ������������ ���������� ��� CreateUser, �������� ����� ������� ���������.
		/// </remarks>
		/// <param name="originalPrincipal">principal</param>
		/// <returns>������������ ������������ ����������</returns>
		string GetUserNameByPrincipal(IPrincipal originalPrincipal);
		
		/// <summary>
		/// �������� �� ���������� ������� � ��, ������������ �� �������, � ������ ����������
		/// </summary>
		/// <param name="user">������������, ����������� ������</param>
		/// <param name="ex">�������� �������</param>
		bool HasSaveObjectPrivilege(XUser user, DomainObjectData xobj, out Exception ex);
		
		/// <summary>
		/// ������ ����������� �������� ������������ ��� ��������.
		/// ������ ��� ����� ��������� ������. ���� ������ ������� ��������, ��� �������� �� ������� �������.
		/// </summary>
		/// <param name="user">������������</param>
		/// <param name="xobj">������, ����� �� ������� �������������</param>
		/// <returns></returns>
		XObjectRights GetObjectRights(XUser user, DomainObjectData xobj);
		
		/// <summary>
		/// ������ ����������� �������� ��� �������� �������
		/// </summary>
		/// <param name="user">������������</param>
		/// <param name="xobj"></param>
		/// <returns></returns>
		XNewObjectRights GetRightsOnNewObject(XUser user, DomainObjectData xobj);

		/// <summary>
		/// ����������� �� ������� XSecurityManager'a �� ������������ ��������
		/// </summary>
		/// <param name="dataSet">����������� ��������� ��������</param>
		void TrackModifiedObjects(DomainObjectDataSet dataSet);
		
		/// <summary>
		/// ������ �� ������� XSecurityManager'a ������������ �������������, 
		/// ��� �������� ������� ������ ���� ������� � ���������� ���������� ���������� ��������� ��������
		/// </summary>
		/// <param name="dataSet">����������� ��������� ��������</param>
		/// <param name="users">��������� �������� ������������� (IList<XUser>)</param>
		/// <returns>������ ������������ ������������� ��� null</returns>
		string[] GetAffectedUserNames(DomainObjectDataSet dataSet, ICollection users);
	}
}