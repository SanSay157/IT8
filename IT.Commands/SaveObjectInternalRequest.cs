using System;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Commands;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// "����������" ������ ������� ����������.
	/// �������� xml-����������, ���������� �� �������, � ��������� XDatagram
	/// </summary>
    [Serializable]
	public class SaveObjectInternalRequest: XRequest
	{
		/// <summary>
		/// ������������ �������� �� ���������, ������������ � ����� ������������
		/// </summary>
		private const string DEF_COMMAND_NAME = "SaveObject";

		/// <summary>
		/// ��������� �������� �������� ��� ����������
		/// </summary>
		protected DomainObjectDataSet m_dataSet;

		/// <summary>
		/// ������������� ����������
		/// </summary>
		protected Guid m_TransactionID;

		/// <summary>
		/// �������� ������ �� ���������� �������� SaveObject
		/// <seealso cref="XSaveObjectRequest"/>
		/// </summary>
		protected XSaveObjectRequest m_originalRequest;

		public SaveObjectInternalRequest(XSaveObjectRequest originalRequest, IXExecutionContextService context)
			: base( DEF_COMMAND_NAME ) 
		{
			m_originalRequest = originalRequest;

			// ��������� ������������� ����������
			if (originalRequest.XmlSaveData.HasAttribute("transaction-id"))
				m_TransactionID = new Guid(originalRequest.XmlSaveData.GetAttribute("transaction-id"));
			else
				m_TransactionID = Guid.NewGuid();

			DomainObjectDataXmlFormatter formatter = new DomainObjectDataXmlFormatter(context.Connection.MetadataManager);
			m_dataSet = formatter.DeserializeForSave(originalRequest.XmlSaveData);
		}

		#region ��������� ��������
		/// <summary>
		/// ���������� ��������� �������� ������ ds-��������, ���������������
		/// ��� ����������, �������������� �� ��������� XML-����������, �������
		/// �������� �������� 
		/// </summary>
		public DomainObjectDataSet DataSet 
		{
			get { return m_dataSet; }
		}

		/// <summary>
		/// ���������� �������� ������ �� ���������� �������� SaveObject
		/// </summary>
		public XSaveObjectRequest OriginalRequest 
		{
			get { return m_originalRequest; }
		}

		/// <summary>
		/// ������ �������� post-call-��������, ������� ������ ���� ������� 
		/// ����� ���������� ������ �������, � ������ ��� �� ����������
		/// </summary>
		
		/// <summary>
		/// ������������� ���������� ����������
		/// ����� ��� ������������� ��������� ��������� ����������
		/// </summary>
		public Guid TransactionID
		{
			get { return m_TransactionID; }
		}
		#endregion
	}
}
