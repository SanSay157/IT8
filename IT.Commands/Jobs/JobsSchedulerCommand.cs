using System;
using Croc.XmlFramework.Core;
using Croc.XmlFramework.Public;

namespace Croc.IncidentTracker.Jobs
{
	/// <summary>
	/// Планировщик заданий
	/// </summary>
	public class JobsSheduler
	{
		/// <summary>
		/// Конструктор класса
		/// </summary>
        private JobsSheduler()
		{
		}

		/// <summary>
		/// Запускает планировщик
		/// </summary>
		public static void Run()
		{
			XRequest request = new XRequest("JobsScheduler");
			XFacade.Instance.ExecCommandAsync(request);
		}
	}
	
	/// <summary>
	/// Команда запуска планировщика для выполнения заданий
	/// </summary>
	/// <remarks>ВНИМАНИЕ! Команда должна выполняться только в асинхронном режиме</remarks>
	[XTransaction(XTransactionRequirement.Disabled)]
	public class JobsSchedulerCommand : XCommand
	{
		/// <summary>
		/// Метод запуска операции на выполнение, «входная» точка операции
		/// </summary>
		/// <param name="request">Запрос на выполнение операции</param>
		/// <param name="context">Контекст выполнения операции</param>
		/// <returns>Результат выполнения</returns>
		public override XResponse Execute(XRequest request, IXExecutionContext context) 
		{
			new JobsLoop().Run();

			return new XResponse();
		}
	}
}
