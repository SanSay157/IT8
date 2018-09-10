using System;
using Croc.XmlFramework.Core;

namespace Croc.IncidentTracker.Storage
{
	/// <summary>
	/// ������� ���, �� �������� ������ ����������� ��� ���� ���������� application ���������
	/// </summary>
	public abstract class XTrigger
	{
		public abstract void Execute(XTriggerArgs args, IXExecutionContext context);
	}

	/// <summary>
	/// ��������� ��������
	/// </summary>
	public class XTriggerArgs
	{
		private XTriggerActions m_action;
		private XTriggerFireTimes m_fireTime;
		private XTriggerFireTypes m_fireType;
		private DomainObjectDataSet m_dataSet;
		private DomainObjectData m_xobj;

		public XTriggerArgs(XTriggerActions action, XTriggerFireTimes fireTimes, XTriggerFireTypes eventType, DomainObjectDataSet dataSet, DomainObjectData xobj)
		{
			m_action = action;
			m_fireTime = fireTimes;
			m_fireType = eventType;
			m_dataSet = dataSet;
			m_xobj = xobj;
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

		public DomainObjectDataSet DataSet
		{
			get { return m_dataSet; }
		}

		public DomainObjectData TriggeredObject
		{
			get { return m_xobj; }
		}

	}

	/// <summary>
	/// ������� ������ application trigger, 
	/// � ������� �������� �������� ��������� ��������, ���������� ����, ��� ��� �������� � ����� ������������
	/// </summary>
	[AttributeUsage(AttributeTargets.Class)]
	public class XTriggerDefinitionAttribute: Attribute
	{
		private XTriggerActions m_action;
		private XTriggerFireTimes m_when;
		private XTriggerFireTypes m_fireType;
		private string m_sObjectType;

		public XTriggerDefinitionAttribute(XTriggerActions action, XTriggerFireTimes when, XTriggerFireTypes fireType, string sObjectType)
		{
			m_action = action;
			m_when = when;
			m_fireType = fireType;
			m_sObjectType = sObjectType;
		}

		public XTriggerActions Action
		{
			get { return m_action; }
		}

		public XTriggerFireTimes When
		{
			get { return m_when; }
		}

		public XTriggerFireTypes FireType
		{
			get { return m_fireType; }
		}
		public string ObjectType
		{
			get { return m_sObjectType; }
		}
	}

	/// <summary>
	/// ��� ������������ ��������
	/// </summary>
	public enum XTriggerFireTypes
	{
		Unspecified,
		/// <summary>
		/// ��� ������� ��������
		/// </summary>
		ForEachObject,
		/// <summary>
		/// ��� ������ ���������� ��������
		/// </summary>
		ForEachObjectGroup,
		/// <summary>
		/// ���� ��� ��� ����� DataSet'a
		/// </summary>
		ForWholeDataSet
	}

	/// <summary>
	/// ����� ������������ ��������
	/// </summary>
	public enum XTriggerFireTimes
	{
		Unspecified,
		Before,
		After
	}

	/// <summary>
	/// �������� ��� ��������, �� ������� ����������� �������
	/// </summary>
	[Flags]
	public enum XTriggerActions
	{
		/// <summary>
		/// ������������
		/// </summary>
		Unspecified = 0,
		/// <summary>
		/// �������
		/// </summary>
		Insert = 1,
		/// <summary>
		/// ����������
		/// </summary>
		Update = 2,
		/// <summary>
		/// ��������
		/// </summary>
		Delete = 4,
		/// <summary>
		/// ����� ��������
		/// </summary>
		All = Insert | Update | Delete
	}
}
