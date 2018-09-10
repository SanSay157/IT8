using System;
using System.Collections;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Xml;
using Croc.IncidentTracker.Storage;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Core.Configuration;
using Croc.XmlFramework.XUtils;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// ���������� �������� application trigger'a � run-time
	/// </summary>
	class XTriggerDescription
	{
		private string m_sObjectType;
		private XTriggerActions m_action;
		private XTriggerFireTimes m_fireTime;
		private XTriggerFireTypes m_fireType;
		private XDotNetClassDescription m_factory;

		public XTriggerDescription(XTriggerActions action, XTriggerFireTimes fireTimes, XTriggerFireTypes eventType, string sObjectType, XDotNetClassDescription factory)
		{
			m_action = action;
			m_fireTime = fireTimes;
			m_fireType = eventType;
			m_sObjectType = sObjectType;
			m_factory = factory;
			if (!m_factory.Metaclass.IsSubclassOf(typeof(XTrigger)))
				throw new ArgumentException(
					String.Format(
						"����� {0} �� �������� ����������� XTrigger � �� ����� ���� ����������� � �������� ��������", 
						factory.Metaclass.Name 
						)
					);

			Type type = factory.Metaclass;
			object[] attrs = type.GetCustomAttributes(typeof(XTriggerDefinitionAttribute), false);
			if (attrs.Length > 0)
			{
				XTriggerDefinitionAttribute attr = (XTriggerDefinitionAttribute)attrs[0];
				if (m_action == XTriggerActions.Unspecified)
					m_action = attr.Action;
				if (m_fireTime == XTriggerFireTimes.Unspecified)
					m_fireTime = attr.When;
				if (m_fireType == XTriggerFireTypes.Unspecified)
					m_fireType = attr.FireType;
				if (m_sObjectType == null || m_sObjectType.Length == 0)
					m_sObjectType = attr.ObjectType;
			}

			if (m_action == XTriggerActions.Unspecified)
				throw new ApplicationException("�� ��������� ����������������� �������� �������� " + type.Name + ": �� ������ �������� (XTriggerActions)");
			if (m_fireTime == XTriggerFireTimes.Unspecified)
				throw new ApplicationException("�� ��������� ����������������� �������� �������� " + type.Name + ": �� ������ ����� ������������ (XTriggerFireTimes)");
			if (m_fireType == XTriggerFireTypes.Unspecified)
				throw new ApplicationException("�� ��������� ����������������� �������� �������� " + type.Name + ": �� ����� ��� ������������ (XTriggerFireTypes)");
			if ((m_sObjectType == null || m_sObjectType.Length == 0) && m_fireType != XTriggerFireTypes.ForWholeDataSet)
				throw new ApplicationException("�� ��������� ����������������� �������� �������� " + type.Name + ": �� ������ ������������ ���� �������");
		}

		public XTriggerDescription(XTriggerConfiguration trConfig)
			: this(trConfig.Action, trConfig.FireTime, trConfig.FireType, trConfig.ObjectType, new XDotNetClassDescription(trConfig.ClassName))
		{}

		public void ExecuteTrigger(DomainObjectDataSet dataSet, DomainObjectData xobj, IXExecutionContext context)
		{
			XTrigger trigger = (XTrigger)m_factory.GetInstance();
			XTriggerArgs args = new XTriggerArgs(m_action, m_fireTime, m_fireType, dataSet, xobj);
			trigger.Execute(args, context);
		}
		public string ObjectType
		{
			get { return m_sObjectType; }
		}
		public XTriggerActions Action
		{
			get { return m_action; }
		}

		public XTriggerFireTimes FireTime
		{
			get { return m_fireTime; }
		}

		public XTriggerFireTypes FireType
		{
			get { return m_fireType; }
		}
	}

	/// <summary>
	/// ���������� ���������� application ���������. ����� ����� ��� ��������
	/// </summary>
	public class XTriggersController
	{
		private static XTriggersController m_Instance = new XTriggersController();
		private XTriggerDescription[] m_triggersForObjects;
		private XTriggerDescription[] m_triggersForGroups;
		private XTriggerDescription[] m_triggersForWholeDataSet;

		private XTriggersController()
		{
			XTriggersConfiguration config = new XTriggersConfiguration();
			ArrayList aTriggersForObjects = new ArrayList();
			ArrayList aTriggersForGroups = new ArrayList();
			ArrayList aTriggersForWholeDataSet = new ArrayList();
			foreach(XTriggerConfiguration triggerConfig in config.TriggersDescr)
			{
				XTriggerDescription tr_descr = new XTriggerDescription(triggerConfig);
				switch(tr_descr.FireType)
				{
					case XTriggerFireTypes.ForEachObject:
						aTriggersForObjects.Add( tr_descr );
						break;
					case XTriggerFireTypes.ForEachObjectGroup:
						aTriggersForGroups.Add( tr_descr );
						break;
					case XTriggerFireTypes.ForWholeDataSet:
						aTriggersForWholeDataSet.Add( tr_descr );
						break;
				}
			}

			m_triggersForObjects = new XTriggerDescription[aTriggersForObjects.Count];
			aTriggersForObjects.CopyTo(m_triggersForObjects);

			m_triggersForGroups = new XTriggerDescription[aTriggersForGroups.Count];
			aTriggersForGroups.CopyTo(m_triggersForGroups);

			m_triggersForWholeDataSet = new XTriggerDescription[aTriggersForWholeDataSet.Count];
			aTriggersForWholeDataSet.CopyTo(m_triggersForWholeDataSet);
		}

		public static XTriggersController Instance
		{
			get { return m_Instance; }
		}

		public void FireTriggers(DomainObjectDataSet dataSet, XTriggerFireTimes fireTime, IXExecutionContext context)
		{
			if (m_triggersForObjects.Length == 0 && m_triggersForGroups.Length == 0 && m_triggersForWholeDataSet.Length == 0)
				return;
			if (m_triggersForObjects.Length + m_triggersForGroups.Length > 0)
			{
				IEnumerator enumerator = dataSet.GetModifiedObjectsEnumerator(false);
				while (enumerator.MoveNext())
				{
					DomainObjectData xobj = (DomainObjectData)enumerator.Current;
					fireTriggersForObject(xobj, fireTime, context);
				}
			}
			if (m_triggersForWholeDataSet.Length > 0)
			{
				foreach(XTriggerDescription trigger in m_triggersForWholeDataSet)
					trigger.ExecuteTrigger(dataSet, null, context);
			}
		}

		private void fireTriggersForObject(DomainObjectData xobj, XTriggerFireTimes fireTime, IXExecutionContext context)
		{
			if (m_triggersForObjects.Length > 0)
				foreach(XTriggerDescription trigger in m_triggersForObjects)
				{
					if (isTriggerMatchForObject(trigger, xobj, fireTime))
						trigger.ExecuteTrigger(xobj.Context, xobj, context);
				}
			if (m_triggersForGroups.Length > 0)
			{
				ArrayList aObjectTypes = new ArrayList();
				foreach(XTriggerDescription trigger in m_triggersForGroups)
				{
					if (trigger.ObjectType == xobj.ObjectType && aObjectTypes.IndexOf(xobj.ObjectType) == -1)
					{
						aObjectTypes.Add(xobj.ObjectType);
						trigger.ExecuteTrigger(xobj.Context, xobj, context);
					}
				}
			}
		}

		private bool isTriggerMatchForObject(XTriggerDescription trigger, DomainObjectData xobj, XTriggerFireTimes fireTime)
		{
			if ((trigger.ObjectType == "*" || trigger.ObjectType == xobj.ObjectType) && trigger.FireTime == fireTime)
			{
				if (xobj.IsNew && (trigger.Action & XTriggerActions.Insert) > 0)
					return true;
				else if (xobj.ToDelete && (trigger.Action & XTriggerActions.Delete) > 0)
					return true;
				else if (!xobj.ToDelete && !xobj.IsNew && (trigger.Action & XTriggerActions.Update) > 0)
					return true;
			}
			return false;
		}
	}

	/// <summary>
	/// ������������ ���������� ���������
	/// </summary>
	/// <remarks>�������� ����� ������ ������ ���� ������������� ��� � ������</remarks>
	public class XTriggersConfiguration: XConfigurationFile
	{
		/// <summary>
		/// ������������ ����� ������������ XFW.NET
		/// ������������ ��� "�������" ��������������� ���� XFW.NET, �.�. ����� ���� .net ������������ �� �������� (� ������ ��������)
		/// </summary>
		public static string XfwConfigFileName;
		/// <summary>
		/// ������ �������� ��������� �� ����� ������������
		/// </summary>
		protected XTriggerConfiguration[] m_triggersDescr;
		/// <summary>
		/// ����������� ��� �����.
		/// </summary>
		/// <param name="sFileName">��� �����</param>
		/// <param name="sBaseDirectory">�������, ������������ �������� �������� ����</param>
		/// <returns>������ ��� �����</returns>
		/// <exception cref="FileNotFoundException">���� ���� �� ����������</exception>
		internal static string GetFullPath( string sFileName, string sBaseDirectory ) 
		{
			// ������ ��� �����
			string sFullFileName;

			if ( Path.IsPathRooted(sFileName) )
				sFullFileName = sFileName;
			else
				sFullFileName = Path.Combine( sBaseDirectory, sFileName );

			if ( !File.Exists(sFullFileName) )
				throw new FileNotFoundException( "���� �� ������", Path.GetFileName(sFullFileName) );

			return sFullFileName;
		}

		
		public XTriggersConfiguration()
		{
			// "��������", �.�. XFacade.Instance.Config... �� ��������
			// ���� ������������ ����� XFW.NET ������������ �� ������ ����, �� ������� ��� �� ����������� ������ ����� .net ������������ (.config)
			if (XfwConfigFileName == null)
			{
				XfwConfigFileName = ConfigurationSettings.AppSettings[XConfig.DEF_APPCONFIG_KEYNAME];
				XfwConfigFileName = GetFullPath( XfwConfigFileName, XConfig.ApplicationBasePath );
			}
			XConfigurationFile xfw_config = new XConfigurationFile(XfwConfigFileName);

			XmlNodeList xmlTriggers = xfw_config.SelectNodes("it:app-data/it:storage/it:triggers/it:trigger");
			m_triggersDescr = new XTriggerConfiguration[xmlTriggers.Count];
			int i = -1;
			foreach(XmlElement xmlTriggerDescr in xmlTriggers)
			{
				string sAction = xmlTriggerDescr.GetAttribute("action");
				string sWhen = xmlTriggerDescr.GetAttribute("when");
				string sFireType = xmlTriggerDescr.GetAttribute("fire-type");
				string sObjectType = xmlTriggerDescr.GetAttribute("object-type");
				string sClassName = xmlTriggerDescr.GetAttribute("class-name");
				m_triggersDescr[++i] = new XTriggerConfiguration(sAction, sWhen, sFireType, sObjectType, sClassName);
			}
		}

		public XTriggerConfiguration[] TriggersDescr
		{
			get { return m_triggersDescr; }
		}
	}

	/// <summary>
	/// �������� ��������, �������� �� ����� ������������
	/// </summary>
	public class XTriggerConfiguration
	{
		public string ObjectType;
		public XTriggerActions Action;
		public XTriggerFireTimes FireTime;
		public XTriggerFireTypes FireType;
		public string ClassName;

		public XTriggerConfiguration(string sAction, string sWhen, string sFireType, string sObjectType, string sClassName )
		{
			try
			{
				if (sAction == null || sAction.Length == 0)
					Action = XTriggerActions.Unspecified;
				else
					Action = (XTriggerActions)Enum.Parse(typeof(XTriggerActions), sAction); 
			}
			catch
			{
				throw new ArgumentException("������������ �������� ������������ XTriggerActions: " + sAction);
			}
			try
			{
				if (sWhen == null || sWhen.Length == 0)
					FireTime = XTriggerFireTimes.Unspecified;
				else
					FireTime = (XTriggerFireTimes)Enum.Parse(typeof(XTriggerFireTimes), sWhen);
			}
			catch
			{
				throw new ArgumentException("������������ �������� ������������ XTriggerFireTimes: " + sWhen);
			}
			try
			{
				if (sFireType == null || sFireType.Length == 0)
					FireType = XTriggerFireTypes.Unspecified;
				else
					FireType = (XTriggerFireTypes)Enum.Parse(typeof(XTriggerFireTypes), sFireType);
			}
			catch
			{
				throw new ArgumentException("������������ �������� ������������ XTriggerFireTypes:" + sFireType);
			}
			if (sClassName == null || sClassName.Length == 0)
				throw new ArgumentException("�� ������ ������������ ������ ��������");
			ClassName = sClassName;
			ObjectType = sObjectType;
		}
	}

	/// <summary>
	/// ���������� �������, ������������ � Trace ��������� ������������ ��������
	/// </summary>
	public class XLogTrigger: XTrigger
	{
		public override void Execute(XTriggerArgs args, IXExecutionContext context)
		{
			Trace.WriteLine( args.Action + ":" + args.FireType + ":" + args.FireTime + ": " + args.TriggeredObject.ToString(), "Trigger");
		}
	}
}