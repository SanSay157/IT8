using System;
using System.Configuration;
using System.Data;
using System.Reflection;
using System.Xml;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// Описание класса проверки существования объекта в БД
	/// </summary>
	public class DbCheckerDescription
	{
		private string m_sAssemblyName;

		private string m_sClassName;

		private string m_sDbObjectType;

		/// <summary>
		/// Имя сборки, в которой содержится класс проверки
		/// </summary>
		public string AssemblyName
		{
			get { return this.m_sAssemblyName; }
		}

		/// <summary>
		/// Название класса проверки
		/// </summary>
		public string ClassName
		{
			get { return this.m_sClassName; }
		}

		/// <summary>
		/// Тип объекта в БД, наличие которого будет проверяться данным классом
		/// </summary>
		public string DbObjectType
		{
			get { return this.m_sDbObjectType; }
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="assemblyName"></param>
		/// <param name="className"></param>
		/// <param name="dbObjectType"></param>
		public DbCheckerDescription(string assemblyName, string className, string dbObjectType)
		{
			this.m_sAssemblyName = assemblyName;
			this.m_sClassName = className;
			this.m_sDbObjectType = dbObjectType;
		}

		/// <summary>
		/// Конструктор
		/// </summary>
		/// <param name="xmlDescription">XML-элемент, содержащий описание класса проверки</param>
		public DbCheckerDescription(XmlElement xmlDescription)
		{
			this.m_sAssemblyName = xmlDescription.GetAttribute("assembly-name");
			this.m_sClassName = xmlDescription.GetAttribute("class-name");
			this.m_sDbObjectType = xmlDescription.GetAttribute("dbobject-type");
		}

		/// <summary>
		/// Создает экземпляр IDbChecker
		/// </summary>
		/// <param name="connection">Соединение с БД</param>
		/// <returns>Созданный экземпляр IDbChecker</returns>
		public IDbChecker CreateDbChecker(IDbConnection connection)
		{
			// получаем тип
			Type type = Assembly.Load(this.AssemblyName).GetType(this.ClassName);
			if ( type == null )
			{
				throw new ConfigurationErrorsException( String.Format(
					"Не удалось загрузить класс {0} из сборки {1}.",
					this.ClassName,
					this.AssemblyName) ); 
			}

			// получаем конструктор
			ConstructorInfo ctor = type.GetConstructor(new Type[] { typeof(IDbConnection) } );
			if (ctor == null)
			{
				throw new ConfigurationErrorsException( String.Format(
					"В классе {0} не удалось найти подходящий конструктор.",
					this.ClassName) ); 
			}

			return (IDbChecker) ctor.Invoke(new object[] { connection });
		}
	}
}
