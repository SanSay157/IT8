//******************************************************************************
// ���������������� ����� CROC XML Framework .NET
// ��� ���� �������������, 2004
//******************************************************************************
using System;
using System.Text;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.XUtils;

namespace Croc.XmlFramework.Data
{
	/// <summary>
	/// ���������� ���������� ���������, ������������ ��������� Microsoft SQL Server
	/// </summary>
	public class XDatagramProcessorMsSqlEx : XDatagramProcessorForNonDeferrableDbEx
	{
		/// <summary>
		/// ��� �������� �������� ��������� �������, ������������ ��� ��������. 
		/// ������ �������� ������������ ���� (���� ds:type ����������)
		/// ��������� �������� ������ �� ��������.
		/// </summary>
        private static XThreadSafeCache<object, object> cacheTempTableCreationScripts = new XThreadSafeCache<object, object>();
		
		#region ���������� ������� Singleton

		/// <summary>
		/// ���������
		/// </summary>
		private static XDatagramProcessorEx m_Instance = new XDatagramProcessorMsSqlEx();

		/// <summary>
		/// ���������� ���������
		/// </summary>
		public static XDatagramProcessorEx Instance
		{
			get { return m_Instance; }
		}
		#endregion

		/// <summary>
		/// ���������, ����������� �������� UPDATE � �������������� ������ �� ��������� �������
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="disp">XDbStatementDispatcher</param>
		/// <param name="sTempTableName">��� ��������� ������� (��� ������������)</param>
		/// <param name="bUseMagicBit">������� ������������� "����������� ����"</param>
		/// <param name="sTypeName">��� ���� ����������� ������ ��������</param>
		/// <param name="sSchemaName">������������ �����</param>
		/// <param name="xmlTypeMD">���������� ����</param>
		protected override void updateWithTempTable(
			XStorageConnection xs, 
			XDbStatementDispatcher disp, 
			string sTempTableName, 
			bool bUseMagicBit, 
			string sSchemaName, 
			string sTypeName, 
			XmlElement xmlTypeMD )
		{
			StringBuilder cmdBuilder;
			cmdBuilder = new StringBuilder();
			cmdBuilder.AppendFormat(
				"UPDATE {0} SET {1}{2} = CASE WHEN s.{3} ='1' THEN CASE WHEN d.{2}<{3} THEN d.{2}+1 ELSE 1 END ELSE d.{2} END{1}",
				xs.GetTableQName(sSchemaName, sTypeName),	// 0
				xs.Behavior.SqlNewLine,			// 1
				xs.ArrangeSqlName("ts"),		// 2
				xs.ArrangeSqlName("x_ts"),		// 3
				Int64.MaxValue					// 4
				);
			// ��� ������� ���������� �������� update �� �������� �� ��������� �������, ���� � ������� x_{���_��������} ����� 1, ����� ���� �� ����
			foreach(XmlElement xmlPropMD in xmlTypeMD.SelectNodes("ds:prop[@cp='scalar' and @vt!='bin' and @vt!='text']", xs.MetadataManager.NamespaceManager))
			{
				cmdBuilder.AppendFormat(",[{0}] = CASE WHEN s.[x{0}]='1' THEN s.[c{0}] ELSE d.[{0}] END{1}",
					xmlPropMD.GetAttribute("n"),	// 0
					xs.Behavior.SqlNewLine			// 1
					);
			}
			if(bUseMagicBit)
				cmdBuilder.Append(",[MagicBit]=1" + xs.Behavior.SqlNewLine);
			cmdBuilder.AppendFormat("FROM {0} d JOIN {1} s ON d.ObjectID = s.ObjectID AND (d.ts = s.ts OR s.ts IS NULL)",
				xs.GetTableQName(sSchemaName, sTypeName),	// 0
				sTempTableName								// 1
				);
			disp.DispatchStatement(cmdBuilder.ToString(), true);
		}

		/// <summary>
		/// ���������� ��� ��������� �������
		/// </summary>
		/// <returns>��� ��������� �������</returns>
		protected override string getTempTableName()
		{
			return "##" + base.getTempTableName();
		}

		/// <summary>
		/// ���������� ����� ������� �������� ��������� ������� ��� insert'��.
		/// ��� ������ (��� ����) ��������� �������� createTempTableCreationScript � �������� ���������.
		/// ������������ ��������� ������� {sTempTableName}
		/// </summary>
		/// <param name="xs">���������� XStorageConnection</param>
		/// <param name="sTempTableName">������������ ��������� �������</param>
		/// <param name="xtype">���������� ����</param>
		/// <returns>����� �������</returns>
		protected override string getTempTableCreationScript( XStorageConnection xs, string sTempTableName, XTypeInfo xtype )
		{
			return	"CREATE TABLE " + sTempTableName + 
				"(" 
				+ cacheTempTableCreationScripts.GetValue(xtype, dlgCreateTempTableCreationScript, xs) +
				")";
		}
	}
}
