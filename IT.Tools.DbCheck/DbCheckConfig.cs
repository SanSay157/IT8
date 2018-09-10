using System;
using System.Collections;
using System.Xml;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// ������������ �������� ������������ ��
	/// </summary>
	public class DbCheckConfig : XConfigurationFile
	{
		private string m_sConfigFileName;

		private DbObject[] m_aDbObjects;

		private DbCheckerDescription[] m_aDbCheckerDescriptions;

		/// <summary>
		/// ������ ��� ����� ������������
		/// </summary>
		public string ConfigFileName
		{
			get { return this.m_sConfigFileName; }
		}

		/// <summary>
		/// ������ �������� � ��, �������� � ����� ������������
		/// </summary>
		public DbObject[] DbObjects
		{
			get { return this.m_aDbObjects; }
		}

		/// <summary>
		/// ������ �������� ������� ��������, �������� � ����� ������������
		/// </summary>
		public DbCheckerDescription[] DbCheckerDescriptions
		{
			get { return this.m_aDbCheckerDescriptions; }
		}
		
		/// <summary>
		/// ����������
		/// </summary>
		public DbCheckConfig(string sConfigFileFullName)
			: base(sConfigFileFullName)
		{
			this.m_sConfigFileName = sConfigFileFullName;

			// ������ � c������ �������� �������� � ��
			loadDbObjects();

			// ������ � c������ �������� "��������������"
			loadDbCheckers();
		}

		/// <summary>
		/// ������ �� ����� �������� �������� ��
		/// </summary>
		private void loadDbObjects()
		{
			ArrayList dbObjList = new ArrayList();

			string xpath = String.Format("{0}dbobjects/{0}*", this.RootElementNSPrefix);
			XmlNodeList xmlObjects = SelectNodes(xpath);

			foreach (XmlElement xmlObj in xmlObjects)
			{
				DbObject dbObj = DbObjectFactory.Create(xmlObj);
				dbObjList.Add(dbObj);

				string xpathChild = String.Format("{0}*", this.RootElementNSPrefix);
				XmlNodeList xmlChilds = xmlObj.SelectNodes(xpathChild, this.NSManager);

				foreach (XmlElement xmlChild in xmlChilds)
				{
					DbObject dbChild = DbObjectFactory.Create(xmlChild, dbObj);
					dbObjList.Add(dbChild);
				}
			}

			this.m_aDbObjects = (DbObject[]) dbObjList.ToArray(typeof(DbObject));
		}

		/// <summary>
		/// ������ �� ����� �������� "��������������"
		/// </summary>
		private void loadDbCheckers()
		{
			ArrayList dbDescriptionList = new ArrayList();

			string xpath = String.Format("{0}dbcheckers/{0}dbchecker", this.RootElementNSPrefix);
			XmlNodeList xmlDescriptions = SelectNodes(xpath);

			foreach (XmlElement xmlDescr in xmlDescriptions)
			{
				DbCheckerDescription dbDescr = new DbCheckerDescription(xmlDescr);
				dbDescriptionList.Add(dbDescr);
			}

			this.m_aDbCheckerDescriptions = (DbCheckerDescription[]) dbDescriptionList.ToArray(typeof(DbCheckerDescription));
		}
	}
}
