using System;

namespace Croc.IncidentTracker.Tools.DbCheck
{
	/// <summary>
	/// ������ � ��
	/// </summary>
	public abstract class DbObject
	{
		private string m_sName;

		private string m_sDescription;
		
		/// <summary>
		/// �������� �������
		/// </summary>
		public string Name
		{
			get { return this.m_sName; }
		}
		
		/// <summary>
		/// �������� �������
		/// </summary>
		public string Description
		{
			get { return this.m_sDescription; }
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public abstract string Type
		{
			get;
		}

		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObject(string name, string description)
		{
			this.m_sName = name;
			this.m_sDescription = description;
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public virtual string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ������ [{0}] ({1}).",
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ������ [{0}].",
					Name);
			}
		}
	}

	/// <summary>
	/// ������ � �� � ��������� ���������
	/// </summary>
	public abstract class DbObjectOwned : DbObject
	{
		private string m_sOwner;

		/// <summary>
		/// �������� �������
		/// </summary>
		public string Owner
		{
			get { return this.m_sOwner; }
		}

		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectOwned(string name, string description, string owner)
			: base(name, description)
		{
			this.m_sOwner = owner;
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ������ [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ������ [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// ������ � ��, �������� �� ��������� � �������
	/// </summary>
	public abstract class DbObjectTableChild : DbObject
	{
		private DbObjectTable m_oParentTable;

		/// <summary>
		/// ������������ �������
		/// </summary>
		public DbObjectTable ParentTable
		{
			get { return this.m_oParentTable; }
		}

		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectTableChild(string name, string description, DbObjectTable parentTable)
			: base(name, description)
		{
			this.m_oParentTable = parentTable;
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ��� ������� [{0}].[{1}] ����������� �������� ������ [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"� �� ��� ������� [{0}].[{1}] ����������� �������� ������ [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}

	/// <summary>
	/// ������� � ��
	/// </summary>
	public class DbObjectTable : DbObjectOwned
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectTable(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "table"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ������� [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ������� [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// ������������� � ��
	/// </summary>
	public class DbObjectView : DbObjectOwned
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectView(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "view"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ������������� [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ������������� [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// �������� ��������� � ��
	/// </summary>
	public class DbObjectProcedure : DbObjectOwned
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectProcedure(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "procedure"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� �������� ��������� [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� �������� ��������� [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// ������� � ��
	/// </summary>
	public class DbObjectFunction : DbObjectOwned
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectFunction(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "function"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ������� [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ������� [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// ������� � ��
	/// </summary>
	public class DbObjectTrigger : DbObjectOwned
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		/// <param name="owner"></param>
		public DbObjectTrigger(string name, string description, string owner)
			: base(name, description, owner)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "trigger"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ����������� ��� �������� ������� [{0}].[{1}] ({2}).",
					Owner,
					Name,
					Description);
			}
			else
			{
				return String.Format(
					"� �� ����������� ��� �������� ������� [{0}].[{1}].",
					Owner,
					Name);
			}
		}
	}

	/// <summary>
	/// ������ � ��
	/// </summary>
	public class DbObjectIndex : DbObjectTableChild
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectIndex(string name, string description, DbObjectTable parentTable)
			: base(name, description, parentTable)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "index"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� �� ������� [{0}].[{1}] ����������� ������ [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"� �� �� ������� [{0}].[{1}] ����������� ������ [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}

	/// <summary>
	/// CHECK CONSTRAINT
	/// </summary>
	public class DbObjectCheckConstraint : DbObjectTableChild
	{
		/// <summary>
		/// �����������
		/// </summary>
		/// <param name="name"></param>
		/// <param name="description"></param>
		public DbObjectCheckConstraint(string name, string description, DbObjectTable parentTable)
			: base(name, description, parentTable)
		{
		}

		/// <summary>
		/// ��� ������� � ��
		/// </summary>
		public override string Type
		{
			get { return "check-constraint"; }
		}

		/// <summary>
		/// ���������� ��������� �� ������
		/// </summary>
		/// <returns></returns>
		public override string GetErrorMessage()
		{
			if (Description.Length > 0)
			{
				return String.Format(
					"� �� ��� ������� [{0}].[{1}] ����������� ��� �������� CHECK CONSTRAINT [{2}] ({3}).",
					ParentTable.Owner,
					ParentTable.Name,
					Name,
					Description );
			}
			else
			{
				return String.Format(
					"� �� ��� ������� [{0}].[{1}] ����������� ��� �������� CHECK CONSTRAINT [{2}].",
					ParentTable.Owner,
					ParentTable.Name,
					Name );
			}
		}
	}
}
