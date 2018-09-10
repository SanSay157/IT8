//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005-2006
//******************************************************************************
using System.Collections;
using System.Text;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Data.Security;
using Croc.IncidentTracker.Hierarchy;

namespace Croc.IncidentTracker.Commands.Security
{
	/// <summary>
	/// �������� ����������� ������ ������ ����  �� �����/������������ ��������
	/// � ��������� ������� - ������������ ������ ����
	/// </summary>
    class MenuObjectRightsFormatter
	{
		/// <summary>
        /// ����� ������ ���� �� ����� ������ � �������� "ObjectRights" �������-������ ����
		/// </summary>
		/// <param name="menuitem">������ - ����� ����</param>
		/// <param name="create_rights">������ ���� �� ����� ������</param>
        public static void Write(XMenuActionItem menuitem, XNewObjectRights create_rights)
		{
            //���� ���� ��������,��������� ������ ��� ������ - �� ���������� ��
            if (create_rights.HasReadOnlyProps)
			{
				StringBuilder bld = new StringBuilder();
				writeReadOnlyProps(bld, create_rights.GetReadOnlyPropNames());
				menuitem.Parameters.Add("ObjectRights", bld.ToString());
			}
		}

        /// <summary>
        /// ����� ������ ���� �� ������������ ������ � �������� "ObjectRights" �������-������ ����
        /// </summary>
        /// <param name="menuitem">������ - ����� ����</param>
        /// <param name="rights">����� �� ������������ ������</param>
		public static void Write(XMenuActionItem menuitem, XObjectRights rights)
		{
			StringBuilder bld = new StringBuilder();
            //����� �� ��������
			if (!rights.AllowDelete)
				bld.Append(".deny-delete:1;");
            //����� �� ��������� �������
			if (!rights.AllowParticalOrFullChange)
				bld.Append(".deny-change:1;");
            //���� ���� ��������,��������� ������ ��� ������ - ����� ���������� ��
			else if (rights.HasReadOnlyProps)
			{
				writeReadOnlyProps(bld, rights.GetReadOnlyPropNames());
			}
			if (bld.Length > 0)
				menuitem.Parameters.Add("ObjectRights", bld.ToString());
		}

        /// <summary>
        /// ����� ������ ������� ��������� ������ ��� ������
        /// </summary>
        /// <param name="bld">������ ��� ������</param>
        /// <param name="props">��������� ������������ �������,��������� ������ ��� ������</param>
		private static void writeReadOnlyProps(StringBuilder bld, ICollection props)
		{
			bld.Append(".read-only-props:");
			foreach(string sProp in props)
			{
				bld.Append(sProp);
				bld.Append(",");
			}
			bld.Length--;
			bld.Append(";");
		}
	}
}
