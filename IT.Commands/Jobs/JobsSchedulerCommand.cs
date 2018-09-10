using System;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Jobs
{
	/// <summary>
	/// ����������� �������
	/// </summary>
	public class JobsSheduler
	{
		/// <summary>
		/// ����������� ������
		/// </summary>
        private JobsSheduler()
		{
		}

		/// <summary>
		/// ��������� �����������
		/// </summary>
		public static void Run()
		{
			XRequest request = new XRequest("JobsScheduler");
			XFacade.Instance.ExecCommandAsync(request);
		}
	}
	
	/// <summary>
	/// ������� ������� ������������ ��� ���������� �������
	/// </summary>
	/// <remarks>��������! ������� ������ ����������� ������ � ����������� ������</remarks>
	[XTransaction(XTransactionRequirement.Disabled)]
	public class JobsSchedulerCommand : XCommand
	{
		/// <summary>
		/// ����� ������� �������� �� ����������, ��������� ����� ��������
		/// </summary>
		/// <param name="request">������ �� ���������� ��������</param>
		/// <param name="context">�������� ���������� ��������</param>
		/// <returns>��������� ����������</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context) 
		{
			new JobsLoop().Run();

			return new XResponse();
		}
	}
}
