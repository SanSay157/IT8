//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005
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
	/// Операция получения идентификатора ds-объекта (ObjectID), заданного 
	/// значениями своих реквизитов
	/// <seealso cref="GetObjectIdByExKeyRequest"/>
	/// <seealso cref="GetObjectIdByExKeyResponse"/>
	/// </summary>
    [Serializable]
	[XTransaction(XTransactionRequirement.Supported)]
	public class GetObjectIdByExKeyCommand : XCommand 
	{
		/// <summary>
		/// Метод запуска операции на выполнение, <входная> точка операции
		/// ПЕРЕГРУЖЕННЫЙ, СТРОГО ТИПИЗИРОВАННЫЙ МЕТОД 
		/// ВЫЗЫВАЕТСЯ ЯДРОМ АВТОМАТИЧЕСКИ
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public GetObjectIdByExKeyResponse Execute( GetObjectIdByExKeyRequest request, IXExecutionContext context ) 
		{
			Guid uidResultObjectID = Guid.Empty;

			// Если в запросе задано наименование источника данных, то для получения 
			// идентификатора объекта используем именно его:
			if (null!=request.DataSourceName && 0!=request.DataSourceName.Length)
				uidResultObjectID = processDataSource(
					request.DataSourceName,
					request.Params,
					context.Connection );
			
			// Иначе (наименование источника данных не задано) формируем явный 
			// запрос на получение ObjectID
			else if (null!=request.TypeName && 0!=request.TypeName.Length)
				uidResultObjectID = processExplicitObjectIdRequest( 
					request.TypeName,
					request.Params,
					context.Connection );

			else
				throw new ArgumentException(
					"Не задано ни наименование типа, ни наменование источника " +
					"данных; получение идентификатора объекта невозможно!", 
					"GetObjectIdByExKeyRequest" );

			return new GetObjectIdByExKeyResponse( uidResultObjectID );
		}


		/// <summary>
		/// Выполняет указанный источник данных; ожидается, что в результате 
		/// выполнения этого источника данных получим идентификатор некого 
		/// объекта (тип тут не задан)
		/// </summary>
		/// <param name="sDataSourceName">Наименование источника данных</param>
		/// <param name="dictionaryParams">
		/// Хеш параметров; здесь в паре ключ пары - наименование параметра, 
		/// значение пары - собственно значение параметра. Последний может быть
		/// типизированным значением, значением в стрковом представленнии.
		/// Технически допустимо значение в виде массива типизированных значений 
		/// или их строковых представлений - в этом случае такие данные 
		/// приводят к формированию условий виде Param IN (value1, ..., valueN)
		/// </param>
		/// <param name="connection">Соединение с СУБД; на момент вызова д.б. открыто</param>
		/// <returns>Значение ObjectID экземпляра объекта</returns>
		protected Guid processDataSource(
			string sDataSourceName,
			Hashtable dictionaryParams,
			XStorageConnection connection ) 
		{
			// Получим источник данных, подставим переданные параметры и выполним его:
			XDataSource dataSource = connection.GetDataSource( sDataSourceName );
			dataSource.SubstituteNamedParams( dictionaryParams, true );
			dataSource.SubstituteOrderBy();

			object oResult = dataSource.ExecuteScalar();
			// Ожидается, что в результате мы получаем GUID:
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );

			return uidResult;
		}


		/// <summary>
		/// Формирует и выполняет явный SQL-запрос на получение значения свойства
		/// (столбца) ObjectID для указанного ds-типа, для экземпляра, заданного 
		/// значениями своих параметров
		/// </summary>
		/// <param name="sRequiredTypeName">
		/// Наименование ds-типа, для которого формируется запрос
		/// </param>
		/// <param name="dictionaryParams">
		/// Хеш параметров; здесь в паре ключ пары - наименование параметра, 
		/// значение пары - собственно значение параметра. Последний может быть
		/// типизированным значением, значением в стрковом представленнии.
		/// Технически допустимо значение в виде массива типизированных значений 
		/// или их строковых представлений, но такие значения в данном случае 
		/// неприменимы и приводят к генерации исключения ArgumentException.
		/// </param>
		/// <param name="connection">Соединение с СУБД; на момент вызова д.б. открыто</param>
		/// <returns>Значение ObjectID экземпляра объекта</returns>
		protected Guid processExplicitObjectIdRequest( 
			string sRequiredTypeName,
			Hashtable dictionaryParams,
			XStorageConnection connection ) 
		{
			// SQL-операция получения значения ObjectID экземпляра заданного типа
			XDbCommand command = connection.CreateCommand();
			// Строка, в которой будем собирать WHERE-условие для SQL-операции
			StringBuilder sWhereClause = new StringBuilder();

			// #1: Формируем WHERE-условие; для этого перебираем все параметры, 
			// переданные в составе коллекции, и для каждого параметра (а) добавляем
			// условие в WHERE-выражение, (б) добавляем соответствующий параметр в
			// коллекцию параметров SQL-операции. Наименование свойства, на которое 
			// накладывается условие и наименование параметра формируются на основании 
			// наименования парамтра, переданного в исходной коллекции; на всякий 
			// пожарный случай к нарименованию параметра в SQL-выражении добавляем 
			// префикс "param":
			foreach( DictionaryEntry item in dictionaryParams )
			{
				// В случае непосредственного запроса на получение ObjectID 
				// массивные значения параметров недопустимы:
				if (item.Value is ArrayList || item.Value is Array)
					throw new ArgumentException( String.Format( 
						"В качестве значения параметра {0} передан массив значений, " +
						"что недопустимо в случае явного запроса идентификатора объекта типа {1}",
						item.Key.ToString(), sRequiredTypeName )
						);

				// Если значение параметра задано как NULL, то это специальный случай
				// условия, обрабатываем его отдельно:
				if (null==item.Value)
				{
					// Наименование свойства, на которое накладывается условие,
					// есть наименования параметра, переданного в коллекции:
					sWhereClause.AppendFormat( 
						"(obj.{0} IS NULL) AND ",
						connection.Behavior.ArrangeSqlName( item.Key.ToString() )
						);
				}
				else
				{
					// Наименование SQL-параметра: наименование параметра из
					// в исходной коллекции, к которому добавлен префикс:
					string sParamName = "param" + item.Key.ToString();
					
					// Наименование свойства, на которое накладывается условие,
					// есть наименования параметра из исходной коллекции:
					sWhereClause.AppendFormat( "(obj.{0}={1}{2}) AND ",
						connection.Behavior.ArrangeSqlName( item.Key.ToString() ),	// 0
						connection.Behavior.ParameterPrefix,						// 1
						sParamName													// 2
						);
					
					// Создаем объект-параметр, добавлем его в коллекцию параметров 
					// SQL-операции:
					XDbParameter param = command.CreateParameter();
					param.ParameterName = sParamName;
					param.VarType = XPropTypeParser.GetNearestTypeForCLR( item.Value.GetType() );
					param.Value = item.Value;
					// Если тип параметра есть строка - ограничим размерность,
					// т.к. в противном случае это будет максимальная размерность - 4К - 
					// и будет достаточно заметно тормозить. В качестве исходной размерности
					// укажем длину реально заданного значения, увеличенного на 2:					
					if (item.Value is string)
						param.Size = ( (string)item.Value ).Length + 2;
					command.Parameters.Add( param );
				}
			}
			sWhereClause.Append( "(1=1)" );


			// #2: Формируем и выполняем полную SQL-операцию
			command.CommandType = System.Data.CommandType.Text;
			command.CommandText = String.Format(
				"SELECT TOP 1 obj.ObjectID FROM {0} obj WHERE {1}",
				connection.GetTableQName( sRequiredTypeName ),
				sWhereClause.ToString()
				);
			object oResult = command.ExecuteScalar();


			// #3: Ожидается, что в результате мы получаем GUID; если 
			// результата нет вообще, возвращаем Guid.Empty;
			Guid uidResult = Guid.Empty;
			if (null!=oResult && DBNull.Value!=oResult)
				uidResult = connection.Behavior.CastGuidValueFromDB( oResult );
			
			return uidResult;
		}
	}
}
