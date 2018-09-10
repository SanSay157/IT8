//******************************************************************************
// ������� ������������ ���������� ��������� - Incident Tracker
// ��� ���� �������������, 2005
//******************************************************************************
using System;
using System.Collections;
using System.Text;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Data;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Commands
{
	/// <summary>
	/// �������� ��������� �������������� ds-������� (ObjectID), ��������� 
	/// ���������� ����� ����������
	/// <seealso cref="GetObjectIdByExKeyRequest"/>
	/// <seealso cref="GetObjectIdByExKeyResponse"/>
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectIdByExKeyCommand : XCommand 
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, <�������> ����� ��������
		/// �������������, ������ �������������� ����� 
		/// ���������� ����� �������������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public GetObjectIdByExKeyResponse Execute( GetObjectIdByExKeyRequest request, IXExecutionContext context ) 
		{
			Guid uidResultObjectID = Guid.Empty;

			// ���� � ������� ������ ������������ ��������� ������, �� ��� ��������� 
			// �������������� ������� ���������� ������ ���:
			if (null!=request.DataSourceName && 0!=request.DataSourceName.Length)
				uidResultObjectID = processDataSource(
					request.DataSourceName,
					request.Params,
					context.Connection );
			
			// ����� (������������ ��������� ������ �� ������) ��������� ����� 
			// ������ �� ��������� ObjectID
			else if (null!=request.TypeName && 0!=request.TypeName.Length)
				uidResultObjectID = processExplicitObjectIdRequest( 
					request.TypeName,
					request.Params,
					context.Connection );

			else
				throw new ArgumentException(
					"�� ������ �� ������������ ����, �� ����������� ��������� " +
					"������; ��������� �������������� ������� ����������!", 
					"GetObjectIdByExKeyRequest" );

			return new GetObjectIdByExKeyResponse( uidResultObjectID );
		}


		/// <summary>
		/// ��������� ��������� �������� ������; ���������, ��� � ���������� 
		/// ���������� ����� ��������� ������ ������� ������������� ������ 
		/// ������� (��� ��� �� �����)
		/// </summary>
		/// <param name="sDataSourceName">������������ ��������� ������</param>
		/// <param name="dictionaryParams">
		/// ��� ����������; ����� � ���� ���� ���� - ������������ ���������, 
		/// �������� ���� - ���������� �������� ���������. ��������� ����� ����
		/// �������������� ���������, ��������� � �������� ��������������.
		/// ���������� ��������� �������� � ���� ������� �������������� �������� 
		/// ��� �� ��������� ������������� - � ���� ������ ����� ������ 
		/// �������� � ������������ ������� ���� Param IN (value1, ..., valueN)
		/// </param>
		/// <param name="connection">���������� � ����; �� ������ ������ �.�. �������</param>
		/// <returns>�������� ObjectID ���������� �������</returns>
		protected Guid processDataSource(
			string sDataSourceName,
			Hashtable dictionaryParams,
			XStorageConnection connection ) 
		{
			// ������� �������� ������, ��������� ���������� ��������� � �������� ���:
			XDataSource dataSource = connection.GetDataSource( sDataSourceName );
			dataSource.SubstituteNamedParams( dictionaryParams, true );
			dataSource.SubstituteOrderBy();

			object oResult = dataSource.ExecuteScalar();
			// ���������, ��� � ���������� �� �������� GUID:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );

			return uidResult;
		}


		/// <summary>
		/// ��������� � ��������� ����� SQL-������ �� ��������� �������� ��������
		/// (�������) ObjectID ��� ���������� ds-����, ��� ����������, ��������� 
		/// ���������� ����� ����������
		/// </summary>
		/// <param name="sRequiredTypeName">
		/// ������������ ds-����, ��� �������� ����������� ������
		/// </param>
		/// <param name="dictionaryParams">
		/// ��� ����������; ����� � ���� ���� ���� - ������������ ���������, 
		/// �������� ���� - ���������� �������� ���������. ��������� ����� ����
		/// �������������� ���������, ��������� � �������� ��������������.
		/// ���������� ��������� �������� � ���� ������� �������������� �������� 
		/// ��� �� ��������� �������������, �� ����� �������� � ������ ������ 
		/// ����������� � �������� � ��������� ���������� ArgumentException.
		/// </param>
		/// <param name="connection">���������� � ����; �� ������ ������ �.�. �������</param>
		/// <returns>�������� ObjectID ���������� �������</returns>
		protected Guid processExplicitObjectIdRequest( 
			string sRequiredTypeName,
			Hashtable dictionaryParams,
			XStorageConnection connection ) 
		{
			// SQL-�������� ��������� �������� ObjectID ���������� ��������� ����
			XDbCommand command = connection.CreateCommand();
			// ������, � ������� ����� �������� WHERE-������� ��� SQL-��������
			StringBuilder sWhereClause = new StringBuilder();

			// #1: ��������� WHERE-�������; ��� ����� ���������� ��� ���������, 
			// ���������� � ������� ���������, � ��� ������� ��������� (�) ���������
			// ������� � WHERE-���������, (�) ��������� ��������������� �������� �
			// ��������� ���������� SQL-��������. ������������ ��������, �� ������� 
			// ������������� ������� � ������������ ��������� ����������� �� ��������� 
			// ������������ ��������, ����������� � �������� ���������; �� ������ 
			// �������� ������ � ������������� ��������� � SQL-��������� ��������� 
			// ������� "param":
			foreach( DictionaryEntry item in dictionaryParams )
			{
				// � ������ ����������������� ������� �� ��������� ObjectID 
				// ��������� �������� ���������� �����������:
				if (item.Value is ArrayList || item.Value is Array)
					throw new ArgumentException( String.Format( 
						"� �������� �������� ��������� {0} ������� ������ ��������, " +
						"��� ����������� � ������ ������ ������� �������������� ������� ���� {1}",
						item.Key.ToString(), sRequiredTypeName )
						);

				// ���� �������� ��������� ������ ��� NULL, �� ��� ����������� ������
				// �������, ������������ ��� ��������:
				if (null==item.Value)
				{
					// ������������ ��������, �� ������� ������������� �������,
					// ���� ������������ ���������, ����������� � ���������:
					sWhereClause.AppendFormat( 
						"(obj.{0} IS NULL) AND ",
						connection.Behavior.ArrangeSqlName( item.Key.ToString() )
						);
				}
				else
				{
					// ������������ SQL-���������: ������������ ��������� ��
					// � �������� ���������, � �������� �������� �������:
					string sParamName = "param" + item.Key.ToString();
					
					// ������������ ��������, �� ������� ������������� �������,
					// ���� ������������ ��������� �� �������� ���������:
					sWhereClause.AppendFormat( "(obj.{0}={1}{2}) AND ",
						connection.Behavior.ArrangeSqlName( item.Key.ToString() ),	// 0
						connection.Behavior.ParameterPrefix,						// 1
						sParamName													// 2
						);
					
					// ������� ������-��������, �������� ��� � ��������� ���������� 
					// SQL-��������:
					XDbParameter param = command.CreateParameter();
					param.ParameterName = sParamName;
					param.VarType = XPropTypeParser.GetNearestTypeForCLR( item.Value.GetType() );
					param.Value = item.Value;
					// ���� ��� ��������� ���� ������ - ��������� �����������,
					// �.�. � ��������� ������ ��� ����� ������������ ����������� - 4� - 
					// � ����� ���������� ������� ���������. � �������� �������� �����������
					// ������ ����� ������� ��������� ��������, ������������ �� 2:					
					if (item.Value is string)
						param.Size = ( (string)item.Value ).Length + 2;
					command.Parameters.Add( param );
				}
			}
			sWhereClause.Append( "(1=1)" );


			// #2: ��������� � ��������� ������ SQL-��������
			command.CommandType = System.Data.CommandType.Text;
			command.CommandText = String.Format(
				"SELECT TOP 1 obj.ObjectID FROM {0} obj WHERE {1}",
				connection.GetTableQName( sRequiredTypeName ),
				sWhereClause.ToString()
				);
			object oResult = command.ExecuteScalar();


			// #3: ���������, ��� � ���������� �� �������� GUID; ���� 
			// ���������� ��� ������, ���������� Guid.Empty;
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );
			
			return uidResult;
		}
	}
}
