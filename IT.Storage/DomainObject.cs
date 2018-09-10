using System;
using System.Collections;
using System.Collections.Specialized;
using System.Text;
using Croc.XmlFramework.Data;

namespace Croc.IncidentTracker.Storage
{
	public enum DomainObjectState 
	{
		Unknown,
		New,
		Loading,
		Loaded,
		Ghost,
		Invalid
	}

	/// <summary>
	/// 
	/// </summary>
	public class DomainObject: XObjectBase
	{
		protected UnitOfWork m_UoW;
		protected DomainObjectState m_state;
		protected bool m_bToDelete;
		protected HybridDictionary m_propValues = new HybridDictionary(true);

		internal DomainObject(UnitOfWork uow, XTypeInfo typeInfo, Guid objectID, DomainObjectState state): 
			base(typeInfo, objectID)
		{
			m_UoW = uow;
			m_state = state;
		}

		public event EventHandler ObjectLoaded;
		internal UnitOfWork UoW
		{
			get { return m_UoW; }
		}
		public new Int64 TS
		{
			get { return m_nTS; }
			set { m_nTS = value; }
		}

		public bool IsDirty
		{
			get 
			{
				foreach(DomainPropBase prop in m_propValues.Values)
					if (prop.IsDirty)
						return true;
				return false;
			}
		}
		public bool IsDeleted
		{
			get { return m_bToDelete; }
		}

		public bool IsNew
		{
			get { return m_state == DomainObjectState.New; }
		}
		public bool IsGhost
		{
			get { return m_state == DomainObjectState.Ghost; }
		}
		public bool IsLoaded
		{
			get { return m_state == DomainObjectState.Loaded; }
		}
		public void Load()
		{
			if (m_state == DomainObjectState.Ghost)
			{
				m_UoW.loadObject(this);
				if (ObjectLoaded != null)
					ObjectLoaded(this, EventArgs.Empty);
			}
		}
		public void Delete()
		{
			m_UoW.deleteObject(this);
		}
		internal void setDeleted()
		{
			if (m_state == DomainObjectState.New)
			{
				m_state = DomainObjectState.Invalid;
				// Debug.Fail("Новый объект не должен помечаться как удаленный");
				throw new InvalidOperationException("Новый объект не должен помечаться как удаленный");
			}
			else
				m_bToDelete = true;
		}
		public IDictionary Props
		{
			get 
			{ 
				Load();
				return m_propValues; 
			}
		}
		public DomainObjectState State
		{
			get { return m_state; }
			set { m_state = value;}
		}
		public void AcceptChanges()
		{
			foreach(DomainPropBase prop in m_propValues.Values)
				prop.AcceptChanges();
		}
		public void Expire()
		{
			m_state = DomainObjectState.Ghost;
			// сбросить значения всех прогружаемых свойств
			foreach(DomainPropBase prop in m_propValues.Values)
			{
				if (prop is IDomainPropLoadable)
				{
					((IDomainPropLoadable)prop).State = DomainPropLoadableState.Ghost;
				}
			}
		}

		public override string ToString()
		{
			StringBuilder bld = new StringBuilder();
			bld.Append(ObjectType + " (" + ObjectID.ToString() + "):\n");
			foreach(DictionaryEntry entry in m_propValues)
				bld.Append("\t" + entry.Key + " : " + entry.Value.ToString() + "\n");
			return bld.ToString();
		}

		public override XObjectDependency[] References
		{
			get { throw new NotImplementedException(); }
		}
	}
}
