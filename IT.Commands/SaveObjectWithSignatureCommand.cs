//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Diagnostics;
using Croc.IncidentTracker.Core;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Data.Security;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// ������� ���������� ������� � ����������� ������� � ��������� ���������,
	/// ���������� ��������� auto-signature � ����������
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Required)]
	[XRequiredRequestType(typeof(SaveObjectInternalRequest))]
	public class SaveObjectWithSignatureCommand : XCommand 
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public virtual XResponse Execute( SaveObjectInternalRequest request, IXExecutionContext context ) 
		{
			ITUser user = (ITUser)XSecurityManager.Instance.GetCurrentUser();
			if (!user.IsServiceAccount)
			{
				string signature = getSignatureText(user);
				// ���� ������� ������������ �� ��������� �������, �� ����� ��������� ������� � ��������� �����
				// �������� �������������� �������
				IEnumerator enumerator = request.DataSet.GetModifiedObjectsEnumerator(true);
				while (enumerator.MoveNext())
				{
					DomainObjectData xobj = (DomainObjectData)enumerator.Current;
					modifyObjectProps(xobj, signature);
				}
			}
			
			// �������� ����������� ������� SaveObject
			request.Name = "SaveObject";
			return context.ExecCommand(request, true);
		}

		/// <summary>
		/// �������� ���������� �������� �������, �������� � ��� �������
		/// </summary>
		/// <param name="xobj">������� ������</param>
		/// <param name="signature">�������</param>
		private void modifyObjectProps(DomainObjectData xobj, string signature)
		{
			// ��������� �� ���� ��������� �������
			foreach (string sPropName in xobj.UpdatedPropNames)
			{
				// ������� ���������� � �������� �� ��� ��������
				XPropInfoBase propInfo = xobj.TypeInfo.GetProp(sPropName);
				
				// ���� ������� ��� ������� �������� �� �����, ���������� ���
				if (hasPropSignature(propInfo))
				{
					object vPropValue = xobj.GetUpdatedPropValue(sPropName);
					if (vPropValue != null && vPropValue != DBNull.Value)
					{
						string sText = null;
						if (propInfo.VarType == XPropType.vt_string || propInfo.VarType == XPropType.vt_text)
							sText = (string)vPropValue;
						else
							throw new ApplicationException("�������� ����������� �������� ������ � ��������� � ��������� �����");

						if (sText != null)
							xobj.SetUpdatedPropValue(sPropName, addSignature(sText, signature));
					}
				}
			}
		}

		/// <summary>
		/// ���������, ������ �� �������� ����� �������
		/// </summary>
		/// <param name="propInfo">���������� ��������</param>
		/// <returns>true - �������� ������ ����� �������</returns>
		private bool hasPropSignature(XPropInfoBase propInfo)
		{
			// ���� �������� �� ���������, ������� �� �����
			if (propInfo.VarType != XPropType.vt_string &&
				propInfo.VarType != XPropType.vt_text)
				return false;

			// ���� �������� �������� ������� auto-signature, ������ true,
			// �� ������� �����
			if (propInfo.SelectSingleNode("itds:auto-signature[.='true']") != null)
				return true;

			// ����� ������� �� �����
			return false;
		}

		/// <summary>
		/// ��������� ������� � ������
		/// </summary>
		/// <param name="text">�������� �����</param>
		/// <param name="signature"></param>
		/// <returns></returns>
		private string addSignature(string text, string signature)
		{
			Debug.Assert(text != null);
			Debug.Assert(signature != null);

			// ���� � ����� ��� �������� ������, �� ������� ���
			if (!text.EndsWith(Environment.NewLine))
				text += Environment.NewLine;

			// ������� ���� �������
			text += signature;

			return text;
		}

		/// <summary>
		/// ���������� ����� �������
		/// </summary>
		/// <param name="user">������� ������������</param>
		/// <returns>����� ������� (�� null)</returns>
		private string getSignatureText(ITUser user)
		{
			return String.Format("[ {0}, {1} ]", user.LastName + " " + user.FirstName,
				DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss"));
		}
	}
}
