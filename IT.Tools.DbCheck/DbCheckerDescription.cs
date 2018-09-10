using System;
using System.Configuration;
using System.Data;
using System.Reflection;
using System.Xml;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// �������� ������ �������� ������������� ������� � ��
	/// </summary>
	public class DbCheckerDescription
	{
		private string m_sAssemblyName;

		private string m_sClassName;

		private string m_sDbObjectType;

		/// <summary>
		/// ��� ������, � ������� ���������� ����� ��������
		/// </summary>
		public string AssemblyName
		{
			get { return this.m_sAssemblyName; }
		}

		/// <summary>
		/// �������� ������ ��������
		/// </summary>
		public string ClassName
		{
			get { return this.m_sClassName; }
		}

		/// <summary>
		/// ��� ������� � ��, ������� �������� ����� ����������� ������ �������
		/// </summary>
		public string DbObjectType
		{
			get { return this.m_sDbObjectType; }
		}

		/// <summary>
		/// �����������
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
		/// �����������
		/// </summary>
		/// <param name="xmlDescription">XML-�������, ���������� �������� ������ ��������</param>
		public DbCheckerDescription(XmlElement xmlDescription)
		{
			this.m_sAssemblyName = xmlDescription.GetAttribute("assembly-name");
			this.m_sClassName = xmlDescription.GetAttribute("class-name");
			this.m_sDbObjectType = xmlDescription.GetAttribute("dbobject-type");
		}

		/// <summary>
		/// ������� ��������� IDbChecker
		/// </summary>
		/// <param name="connection">���������� � ��</param>
		/// <returns>��������� ��������� IDbChecker</returns>
		public IDbChecker CreateDbChecker(IDbConnection connection)
		{
			// �������� ���
			Type type = Assembly.Load(this.AssemblyName).GetType(this.ClassName);
			if ( type == null )
			{
				throw new ConfigurationErrorsException( String.Format(
					"�� ������� ��������� ����� {0} �� ������ {1}.",
					this.ClassName,
					this.AssemblyName) ); 
			}

			// �������� �����������
			ConstructorInfo ctor = type.GetConstructor(new Type[] { typeof(IDbConnection) } );
			if (ctor == null)
			{
				throw new ConfigurationErrorsException( String.Format(
					"� ������ {0} �� ������� ����� ���������� �����������.",
					this.ClassName) ); 
			}

			return (IDbChecker) ctor.Invoke(new object[] { connection });
		}
	}
}
