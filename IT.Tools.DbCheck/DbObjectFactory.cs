using System;
using System.Xml;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// ������� ������� ��� �������� �������� �������� ��
	/// </summary>
	public class DbObjectFactory
	{
		private const string ERR_INVALID_OBJECT_TYPE = 
			"��� �������� \"{0}\" �� ��������������";
		
		private DbObjectFactory()
		{
		}

		/// <summary>
		/// ������� �������� ������� � �� �� ��� XML-��������
		/// </summary>
		/// <param name="xmlObj"></param>
		/// <returns></returns>
		public static DbObject Create(XmlElement xmlObj)
		{
			string typeName = xmlObj.LocalName;

			switch (typeName)
			{
				case "table":
					return new DbObjectTable(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"), 
						xmlObj.GetAttribute("owner") );

				case "view":
					return new DbObjectView(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"), 
						xmlObj.GetAttribute("owner") );

				case "procedure":
					return new DbObjectProcedure(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"), 
						xmlObj.GetAttribute("owner") );

				case "function":
					return new DbObjectFunction(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"), 
						xmlObj.GetAttribute("owner") );

				case "trigger":
					return new DbObjectTrigger(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"), 
						xmlObj.GetAttribute("owner") );

				default:
					throw new ArgumentException(
						String.Format(ERR_INVALID_OBJECT_TYPE, typeName),
						"xmlObj" );
			}
		}

		/// <summary>
		/// ������� �������� ��������� ������� � �� �� ��� XML-��������
		/// � �������� ������������� �������
		/// </summary>
		/// <param name="xmlObj"></param>
		/// <param name="dbObj"></param>
		/// <returns></returns>
		public static DbObject Create(XmlElement xmlObj, DbObject dbObj)
		{
			string typeName = xmlObj.LocalName;

			switch (typeName)
			{
				case "index":
					return new DbObjectIndex(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"),
						(DbObjectTable) dbObj );

				case "check-constraint":
					return new DbObjectCheckConstraint(
						xmlObj.GetAttribute("name"),
						xmlObj.GetAttribute("description"),
						(DbObjectTable) dbObj );

				default:
					throw new ArgumentException(
						String.Format(ERR_INVALID_OBJECT_TYPE, typeName),
						"xmlObj" );
			}
		}
	}
}
