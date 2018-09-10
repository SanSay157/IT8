<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >

	<xsl:output 
		omit-xml-declaration="yes"
		standalone="no"
		encoding="UTF-8"
		method="html" 
		version="4.0"
	/> 

	<!-- Приложения -->
	<xsl:param name="applications" select="*[0!=0]" /> 

	<!-- Основной шаблон -->
	<xsl:template match="/">
		<HTML>
			<!-- Одиночное событие -->
			<xsl:for-each select="event[1]">
				<xsl:variable name="title"><xsl:call-template name="mail-subject"/></xsl:variable>
				<HEAD>
					<title>Incident Tracker - <xsl:value-of select="$title"/></title>
					<xsl:call-template name="styles"/>
				</HEAD>	
				<BODY>
				<DIV CLASS="it-mail">
					<!--Не отображаем скрытое поле - preview-info-->
					<!--<xsl:call-template name="preview-info" />-->
          <!-- полностью удаляем шапку нотификации трекера (логотип компании, дату, время и тд.) -->
					<!--
          <xsl:call-template name="heading" />
          -->
					<xsl:call-template name="one-event" >
						<xsl:with-param name="title" select="$title" />
					</xsl:call-template>
					<!-- Сообщение о тестовом режиме эксплуатации - ВЫКЛЮЧЕНО! -->
					<!-- <xsl:call-template name="test-regime-warning"/> -->
				</DIV>
				</BODY>	
			</xsl:for-each>
			<!-- Дайджест -->
			<xsl:for-each select="digest[1]">
				<HEAD>
					<title>Incident Tracker - Сборник оповещений на 
						<xsl:for-each select="@createdAt">
							<xsl:call-template name="date-only"/>
						</xsl:for-each>
					</title>
					<xsl:call-template name="styles"/>
				</HEAD>
				<BODY>
				<DIV CLASS="it-mail">
          <!-- полностью удаляем шапку нотификации трекера (логотип компании, дату, время и тд.) -->
          <!--
					<xsl:call-template name="heading"/>
          -->
					<xsl:for-each select="event">
						<xsl:variable name="title"><xsl:call-template name="mail-subject"/></xsl:variable>
						<xsl:call-template name="one-event" >
              <xsl:with-param name="title" select="$title" />
              <xsl:with-param name="showTitle" select="1" />
						</xsl:call-template>
            <BR/>
            <BR/>
            <HR/>
            <BR/>
            <BR/>
					</xsl:for-each>
					<!-- Сообщение о тестовом режиме эксплуатации - ВЫКЛЮЧЕНО! -->
					<!-- <xsl:call-template name="test-regime-warning"/> -->
				</DIV>
				</BODY>	
			</xsl:for-each>
		</HTML>
	</xsl:template>
	
	<!-- "Константный" шаблон, выводящий предупреждение, что сообщение - тестовое -->
	<xsl:template name="test-regime-warning">
		<DIV STYLE="margin:10px 3px 3px 3px; border:#b99 solid 1px; background:#ebb; color:#642; padding:5px; font:normal 9px;">
			ВНИМАНИЕ!<BR/>
			Данное сообщение сформировано системой Incident Tracker, находящейся 
			в <B>опытной эксплуатации</B>. Содержание сообщения отражает действия, 
			выполняемые в тестовой системе, и не имеет отношения к задачам и 
			процессам действующей системы Incident Tracker. По всем вопросам, 
			связанным с сообщениями, обращайтесь в службу технической поддержки компании КРОК (974-22-74 #4400).
		</DIV>
	</xsl:template>

	<!-- Формирование отчета о единичном событии -->
	<xsl:template name="one-event">
    <xsl:param name="title" select="'Untitled'"/>
    <xsl:param name="showTitle" select="0"/>
		
		<DIV CLASS="mail-body">
      <!-- полностью удаляем шапку нотификации трекера (логотип компании, дату, время и тд.)-->
      <!--
			<DIV CLASS="mail-timing"><xsl:call-template name="event-datetime"/></DIV>
      -->
			<!-- Собственно название события, зависит от типа, event/@event-type -->
      <!--
      <DIV CLASS="mail-subject"><xsl:value-of select="$title"/></DIV>
			<HR/>
      -->
      <!-- Далее идут детали события -->
			<TABLE CELLSPACING="0" CELLPADDING="0">
        <!-- Событие -->
        <xsl:if test="$showTitle = 1">
          <TR>
            <TD CLASS="content-subj">
              <NOBR>Событие</NOBR>
            </TD>
            <TD CLASS="content-text">
              <xsl:value-of select="$title"/>
            </TD>
          </TR>
        </xsl:if>
			<xsl:choose>			
				<xsl:when test="1=number(@event-type)">
					<!-- Создание инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="inc"/></EM></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="2=number(@event-type)">
					<!-- Изменение состояния инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Новое состояние</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="state"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="3=number(@event-type)">
					<!-- Удаление инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент удалил</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee" /></EM></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="4=number(@event-type)">
					<!-- Новое задание по инциденту -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="r"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Задание создал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="5=number(@event-type)">
					<!-- Изменение роли исполнителя по инциденту -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Новая роль</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="r"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="6=number(@event-type)">
					<!-- Удаление задания по инциденту -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="r"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Задание удалил</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="7=number(@event-type)">
					<!-- Изменение наименования, описания или описания решения инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент изменил</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="8=number(@event-type)">
					<!-- Изменение приоритета, крайнего срока инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Новый крайний срок</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="date-only"/></EM></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Новый приоритет</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="priority"/></EM></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="9=number(@event-type)">
					<!-- Перенос инцидента -  экспорт -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент перенес</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="10=number(@event-type)">
					<!-- Перенос инцидента -  импорт -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент перенес</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="11=number(@event-type)">
					<!-- Добавление участника проектной команды -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Новый участник</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участника добавил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="12=number(@event-type)">
					<!-- Удаление участника проектной команды -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Исключенный участник</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участника исключил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="13=number(@event-type)">
					<!-- Удаление роли у участника проектной команды -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участник</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="r[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Снимаемая роль</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль снял</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="14=number(@event-type)">
					<!-- Добавление роли участника проектной команды -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участник</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="r[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Назначаемая роль</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль назначил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="15=number(@event-type)">
					<!-- Удаление организации -->
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="16=number(@event-type)">
					<!-- Снятие директора организации -->
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Организация</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Бывший директор</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee" /></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Снял</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="17=number(@event-type)">
					<!-- Установка директора организации -->
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Организация</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Новый директор</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee" /></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Назначил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="18=number(@event-type)">
					<!-- Изменение наименование проектной активности (папки) -->
					<TR>
						<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
						<TD CLASS="content-text"><xsl:value-of select="old-name"/></TD>
					</TR>
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Новое наименование</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переименовал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="19=number(@event-type)">
					<!-- Изменение внешнего ID проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="20=number(@event-type)">
					<!-- Изменение блокировки списаний по проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<!-- Изменение блокировки списаний по проектной активности (папки) -->
					<xsl:for-each select="allow-TimeLoss[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Cписания</NOBR></TD>
							<TD CLASS="content-text">
								<EM>
									<xsl:choose>
										<xsl:when test="@n='0'">
										    Разрешены 	
										</xsl:when>
										<xsl:otherwise>
											Заблокированы
										</xsl:otherwise>
									</xsl:choose>
								</EM>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
			    </xsl:when>
				<xsl:when test="21=number(@event-type)">
					<!-- Удаление корневой проектной активности (папки) -->
					<TR>
						<TD CLASS="content-subj"><NOBR>Удаленная активность</NOBR></TD>
						<TD CLASS="content-text"><EM><xsl:value-of select="deleted-folder"/></EM></TD>
					</TR>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="22=number(@event-type)">
					<!-- Удаление некорневой проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Удаленная активность</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="deleted-folder"/></EM></TD>
						</TR>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="23=number(@event-type)">
					<!-- Создание корневой проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Создал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="24=number(@event-type)">
					<!-- Создание некорневой проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Создал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="25=number(@event-type)">
					<!-- Изменение клиента у проектной активности - экспорт -->
					<xsl:for-each select="moved-folder">
						<TD CLASS="content-subj"><NOBR>Перемещаемый проект</NOBR></TD>
						<TD CLASS="content-text"><EM><xsl:value-of select="."/></EM></TD>
					</xsl:for-each>
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Перенос ИЗ</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="26=number(@event-type)">
					<!-- Изменение клиента у проектной активности - импорт -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="27=number(@event-type)">
					<!-- Перенос проектной активности в другую папку - экспорт -->
					<xsl:for-each select="moved-folder">
						<TD CLASS="content-subj"><NOBR>Перемещаемый проект</NOBR></TD>
						<TD CLASS="content-text"><EM><xsl:value-of select="."/></EM></TD>
					</xsl:for-each>
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Перенос ИЗ</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="28=number(@event-type)">
					<!-- Перенос проектной активности в другую папку - импорт -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>				
				<xsl:when test="29=number(@event-type)">
					<!-- Изменение состояния или признака прототипа у проектной активности -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="changed[1]">
						<xsl:if test="@old-State!=@new-State">
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text">
								<xsl:for-each select="@old-State[1]">
									<xsl:call-template name="folder-state"/>									
								</xsl:for-each>
								&#160;
								<tt>--&gt;</tt>
								&#160;
								<EM>
									<xsl:for-each select="@new-State[1]">
										<xsl:call-template name="folder-state"/>									
									</xsl:for-each>
								</EM>
							</TD>
						</TR>
						</xsl:if>					
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>	
				<xsl:when test="30=number(@event-type)">
					<!-- Изменение типа активности у проектной активности -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>	
				<xsl:when test="31=number(@event-type)">
					<!-- Перенос организации - экспорт -->
					<xsl:for-each select="old-parent-name[1]">
						<TD CLASS="content-subj"><NOBR>Перемещаемая организация</NOBR></TD>
						<TD CLASS="content-text"><EM><xsl:value-of select="."/></EM></TD>
					</xsl:for-each>
					<TR>
						<TD CLASS="content-subj"><NOBR>Перенос ИЗ</NOBR></TD>
						<TD CLASS="content-text">
							<xsl:choose>
								<xsl:when test="org">
									<xsl:value-of select="org[1]/n"/>
								</xsl:when>
								<xsl:otherwise>
									&lt;&lt;&lt; Корневая &gt;&gt;&gt;
								</xsl:otherwise>
							</xsl:choose>
						</TD>
					</TR>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="32=number(@event-type)">
					<!-- Перенос организации - импорт -->
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Перемещенная организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переместил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="33=number(@event-type)">
					<!-- Изменение наименования или сокращенного наименования организации -->
					<xsl:for-each select="old[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Наименование до</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="@n"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Краткое наименование до</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="@sn"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Переименованная организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="34=number(@event-type)">
					<!-- Создание организации -->
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Создал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="35=number(@event-type)">
					<!-- Изменение запланированного времени -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="r"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="changes[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Запланированное время (мин)</NOBR></TD>
							<TD CLASS="content-text">было: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@old-PlannedTime)"/>
								</xsl:call-template>
								,<EM> стало: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@new-PlannedTime)"/>
								</xsl:call-template>
								</EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="36=number(@event-type)">
					<!-- Изменение оставшегося времени -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="r"/></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="changes[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Оставшееся время (мин)</NOBR></TD>
							<TD CLASS="content-text">было: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@old-LeftTime)"/>
								</xsl:call-template>
							,<EM> стало: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@new-LeftTime)"/>
								</xsl:call-template>
							</EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="37=number(@event-type)">
					<!-- Изменение блокировки по системе в целом -->
					<xsl:for-each select="BlockDate[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Новая дата блокировки</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="date-only"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Установил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="38=number(@event-type)">
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Создал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="39=number(@event-type)">
					<!-- Снятие атрибута 'временный' у организации -->
					<xsl:for-each select="temp-org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Временная организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="."/>&#160;</EM></TD>
						</TR>
					</xsl:for-each>				
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Постоянная организация</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>				
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Атрибут снял</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>						
				</xsl:when>
				<xsl:when test="40=number(@event-type)">
					<!-- Создание нового тендера -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="41=number(@event-type)">
					<!-- Создание участия в лоте -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участник лота</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="42=number(@event-type)">
					<!-- Модификация участника в лоте -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участник лота</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Модифицировал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="43=number(@event-type)">
					<!-- Удаление участника в лоте -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="org[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участник лота</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="n"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="44=number(@event-type)">
					<!-- Изменение директора тендера - снятие -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Снятый директор</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Снял</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="45=number(@event-type)">
					<!-- Изменение директора тендера - назначение -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Новый директор</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Назначил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="46=number(@event-type)">
					<!-- Удаление тендера -->
					<xsl:for-each select="deleted-tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="47=number(@event-type)">
					<!-- Изменение состояния лота -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Новое состояние лота</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="lot-state"/></EM></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="48=number(@event-type)">
					<!-- Превышение запланированного времени по инциденту -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="date-only"/></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="task[1]">
						<xsl:for-each select="w[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Задание для</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
							</TR>
						</xsl:for-each>
						<TR>
							<TD CLASS="content-subj"><NOBR>Роль</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="r"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="timespent[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Время (мин)</NOBR></TD>
							<TD CLASS="content-text">запланировано: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@planned)"/>
								</xsl:call-template>
							,<EM> затрачено: 
								<xsl:call-template name="format-minutes">
									<xsl:with-param name="m" select="number(@totalspent)"/>
								</xsl:call-template>
							</EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Ответственный</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="49=number(@event-type)">
					<!-- Приближение крайнего срока инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="date-only"/></EM></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Дней осталось</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="../days[1]"/></EM></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="50=number(@event-type)">
					<!-- Нарушение крайнего срока инцидента -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Проект</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="n"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="inc"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Тип инцидента</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="type"/></TD>
						</TR>
						<xsl:for-each select="deadline">
							<TR>
								<TD CLASS="content-subj"><NOBR>Крайний срок</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="date-only"/></EM></TD>
							</TR>
						</xsl:for-each>	
						<TR>
							<TD CLASS="content-subj"><NOBR>Дней прошло</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:value-of select="../days[1]"/></EM></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Приоритет</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="priority"/></TD>
						</TR>
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text"><xsl:value-of select="state"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Инцидент зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="51=number(@event-type)">
					<!-- Создание нового лота -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Новый лот</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Зарегистрировал</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="52=number(@event-type)">
					<!-- Изменение лота -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="53=number(@event-type)">
					<!-- Удаление лота -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
						<xsl:for-each select="lot[1]">
							<TR>
								<TD CLASS="content-subj"><NOBR>Лот</NOBR></TD>
								<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
							</TR>
							<TR>
								<TD CLASS="content-subj"><NOBR>Состояние лота</NOBR></TD>
								<TD CLASS="content-text"><xsl:call-template name="lot-state"/></TD>
							</TR>
						</xsl:for-each>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Удалил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="54=number(@event-type)">
					<!-- Изменение описание тендера -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="tender"/></EM></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="55=number(@event-type)">
					<!-- Изменение состояния тендера -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="changes[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние</NOBR></TD>
							<TD CLASS="content-text">
								<xsl:for-each select="@old-State[1]">
									<xsl:call-template name="lot-state-ex"/>									
								</xsl:for-each>
								&#160;
								<tt>--&gt;</tt>
								&#160;
								<EM>
									<xsl:for-each select="@new-State[1]">
									<xsl:call-template name="lot-state-ex"/>									
									</xsl:for-each>
								</EM>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Состояние изменил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee" /></TD>
						</TR>
					</xsl:for-each>					
				</xsl:when>
				<xsl:when test="56=number(@event-type)">
					<!-- Добавления сотрудника в список лиц, принимающих участие в подготовке тендера -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Добавленный сотрудник</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участника добавил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="57=number(@event-type)">
					<!-- Исключение сотрудника из списка лиц, принимающих участие в подготовке тендера -->
					<xsl:for-each select="tender[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Тендер</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="tender"/></TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Исключенный сотрудник</NOBR></TD>
							<TD CLASS="content-text"><EM><xsl:call-template name="employee"/></EM></TD>
						</TR>
					</xsl:for-each>					
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj"><NOBR>Участника исключил</NOBR></TD>
							<TD CLASS="content-text"><xsl:call-template name="employee"/></TD>
						</TR>
					</xsl:for-each>		
				</xsl:when>
				<xsl:when test="58=number(@event-type)">
					<!-- Добавление направления у проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Проект</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="direction[1]">
							<TR>
								<TD CLASS="content-subj">
									<NOBR>Добавленное направление</NOBR>
								</TD>
								<TD CLASS="content-text">
									<EM>
										<xsl:value-of select="n"/>
									</EM>
								</TD>
							</TR>
					</xsl:for-each>
					<xsl:for-each select="ratio[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Доля затрат (процент)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="number(@percentage)"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Направление добавил</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="59=number(@event-type)">
					<!-- Удаление направления у проектной активности (папки) -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Проект</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="direction[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Удаленное направление</NOBR>
							</TD>
							<TD CLASS="content-text">
								<EM>
									<xsl:value-of select="n"/>
								</EM>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="ratio[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Доля затрат до удаления (процент)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="number(@percentage)"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Направление удалил</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="60=number(@event-type)">
					<!-- Изменение доли затрат направления у проектной активности -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Проект</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="direction[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Измененное направление</NOBR>
							</TD>
							<TD CLASS="content-text">
								<EM>
									<xsl:value-of select="n"/>
								</EM>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="ratio[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Доля затрат до изменения (процент)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="number(@old-percentage)"/>
							</TD>
						</TR>
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Доля затрат после изменения (процент)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="number(@new-percentage)"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Направление изменил</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="61=number(@event-type)">
				<!-- Изменение нормы рабочего времени сотрудника -->
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Сотрудник</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Норму изменил</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="rate[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Норма рабочего времени до изменения (часов)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="@oldvalue"/>
							</TD>
						</TR>
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Норма рабочего времени после изменения (часов)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<EM>
									<xsl:value-of select="@newvalue"/>
								</EM>
							</TD>
						</TR>
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Дата</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="@date"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="62=number(@event-type)">
					<!-- Переход проектной активности в состояние "Ожидание закрытия" -->
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Проект</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="63=number(@event-type)">
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Сотрудник</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="folder[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Проект</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="n"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="employment[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Планируемая занятость сотрудника (проценты)</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="@percent"/>
							</TD>
						</TR>
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Дата начала</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="@datebegin"/>
							</TD>
						</TR>
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Дата окончания</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:value-of select="@dateend"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Изменил</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="64=number(@event-type)">
					<!-- Переход проектной активности в состояние "Ожидание закрытия" -->
					<xsl:for-each select="employee[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Сотрудник</NOBR>
							</TD>
							<TD CLASS="content-text">
								<xsl:call-template name="employee"/>
							</TD>
						</TR>
					</xsl:for-each>
					<xsl:for-each select="author[1]">
						<TR>
							<TD CLASS="content-subj">
								<NOBR>Ответственный менеджер</NOBR>
							</TD>
							<TD CLASS="content-text">
								<EM>
									<xsl:call-template name="employee"/>
								</EM>
							</TD>
						</TR>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<h1>( Неизвестный класс события <xsl:value-of select="@event-type"/> - обратитесь к разработчикам системы )</h1>
				</xsl:otherwise>
			</xsl:choose>
        <!-- Дата события -->
        <TR>
          <TD CLASS="content-subj">
            <NOBR>Дата события</NOBR>
          </TD>
          <TD CLASS="content-text">
            <xsl:call-template name="event-datetime"/>
          </TD>
        </TR>		
			</TABLE>
			
			<!-- 
				Ссылки для открытия
			-->
			<DIV STYLE="border:#ddd solid 1px; padding:5px; margin:15px 3px 5px 3px; background-color:#f0f3f6;">
			<xsl:variable name="evt" select="current()"/>
			<xsl:for-each select="$applications">
				
				<DIV CLASS="content-links">Открыть в Incident Tracker (<xsl:value-of select="@title"/>, <a target="_blank" href="{@url}"><xsl:value-of select="@url"/></a>):</DIV>
				<xsl:variable name="app-url" select="@url"/>
				
				<TABLE CELLSPACING="0" CELLPADDING="0" CLASS="mail-links">
				
				<xsl:if test="'Internal'=@title">
					<xsl:for-each select="$evt/org[1][not(deleted)]">
						<TR>
							<TD><DIV><B>Организация</B></DIV></TD>
              <TD>
                <DIV>
								  <A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}nsi-redirect.aspx?OT=Organization&amp;ID={@id}&amp;FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&amp;COMMAND=CARD">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
                </DIV>
              </TD>
						</TR>
					</xsl:for-each>
				</xsl:if>
				
				<xsl:for-each select="$evt/folder[1][not(deleted)]">
					<TR>
            <TD><DIV><B>Проект</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-get-report.aspx?NAME=r-Folder.xml&amp;ID={@id}">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
							<xsl:call-template name="middot"/>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-tree.aspx?METANAME=Main&amp;LocateFolderByID={@id}">Найти в иерархии<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
				</xsl:for-each>
				
				<xsl:for-each select="$evt/incident[1][not(deleted)]">
					<TR>
            <TD><DIV><B>Инцидент</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-get-report.aspx?NAME=r-Incident.xml&amp;DontCacheXslfo=true&amp;IncidentID={@id}">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
							<xsl:call-template name="middot"/>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-list.aspx?OT=Incident&amp;METANAME=IncidentSearchingList&amp;OpenEditorByIncidentID={@id} ">Редактирование<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
							<xsl:call-template name="middot"/>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-tree.aspx?METANAME=Main&amp;LocateIncidentByID={@id}">Найти в иерархии<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
				</xsl:for-each>
				
				<xsl:if test="'Internal'=@title">
					<xsl:for-each select="$evt/employee[1]|$evt/task[1]/w">
					<TR>
            <TD><DIV><B>Сотрудник</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}nsi-redirect.aspx?OT=SystemUser&amp;ID={@id}&amp;FROM=0AEFC1FD-4D42-4AAC-8369-76E5A812EFF3&amp;COMMAND=CARD">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
					</xsl:for-each>
				</xsl:if>
				
				<xsl:for-each select="$evt/tender[1][not(deleted)]">
					<TR>
            <TD><DIV><B>Тендер</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-get-report.aspx?NAME=r-Tender.xml&amp;TenderID={@id}">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
					<xsl:for-each select="lot[1][not(deleted)]">
					<TR>
            <TD><DIV><B>Лот</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-get-report.aspx?NAME=r-Lot.xml&amp;LotID={@id}">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
					</xsl:for-each>
				</xsl:for-each>
				
				<xsl:for-each select="$evt/lot[1][not(deleted)]">
					<TR>
            <TD><DIV><B>Лот</B></DIV></TD>
            <TD>
              <DIV>
							<A TARGET="_blank" CLASS="pseudoBtn" HREF="{$app-url}x-get-report.aspx?NAME=r-Lot.xml&amp;LotID={@id}">Просмотр<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
              </DIV>
            </TD>
					</TR>
				</xsl:for-each>
				</TABLE>
				<A TARGET="_blank" HREF="{$app-url}?ManageUserSubscription={$evt/@event-type}">Изменение настроек рассылки<SPAN CLASS="spnGoTo">&#187;</SPAN></A>
			</xsl:for-each>
			</DIV>
		</DIV>		
	</xsl:template>
	
  
	<!-- Выводит дату/время события 
		01.04.2006, 12:43:55
		2006-03-17T18:35:52.4030000+03:00
	-->
	<xsl:template name="event-datetime">
		<xsl:value-of select="concat(substring(string(@event-occured),9,2),'.',substring(string(@event-occured),6,2),'.',substring(string(@event-occured),1,4), ', ', substring(string(@event-occured),12,8))" />
	</xsl:template>
	
	<xsl:template name="tender">
		<xsl:if test="num">
			№ <xsl:value-of select="num"/>
		</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:value-of select="n"/>
	</xsl:template>	
	
	<!-- "Тема" сообщения -->
	<xsl:template name="mail-subject">
		<xsl:choose>
			<xsl:when test="1=number(@event-type)">
				Новый инцидент №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="2=number(@event-type)">
				Изменение состояния инцидента №<xsl:value-of select="incident/@number"/>: <xsl:value-of select="incident/state"/>
			</xsl:when>
			<xsl:when test="3=number(@event-type)">
				Удаление инцидента №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="4=number(@event-type)">
				Новое задание по инциденту №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="5=number(@event-type)">
				Изменение роли исполнителя по инциденту №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="6=number(@event-type)">
				Удаление задания по инциденту №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="7=number(@event-type)">
				Изменение наименования, описания или описания решения инцидента №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="8=number(@event-type)">
				Изменение приоритета, крайнего срока инцидента №<xsl:value-of select="incident/@number"/>
			</xsl:when>
			<xsl:when test="9=number(@event-type)">
				Перенос инцидента №<xsl:value-of select="incident/@number"/> в другую активность - экспорт из <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="10=number(@event-type)">
				Перенос инцидента №<xsl:value-of select="incident/@number"/> в другую активность - импорт в <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="11=number(@event-type)">
				Добавление участника проектной команды в <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="12=number(@event-type)">
				Удаление участника проектной команды из <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="13=number(@event-type)">
				Удаление роли <xsl:value-of select="r/n" /> у участника проектной команды из <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="14=number(@event-type)">
				Добавление роли <xsl:value-of select="r/n" /> участнику проектной команды в <xsl:value-of select="folder/n" />
			</xsl:when>
			<xsl:when test="15=number(@event-type)">
				Удаление организации <xsl:value-of select="org/n" />
			</xsl:when>
			<xsl:when test="16=number(@event-type)">
				Снятие директора организации
			</xsl:when>
			<xsl:when test="17=number(@event-type)">
				Установка директора организации
			</xsl:when>
			<xsl:when test="18=number(@event-type)">
				Изменение наименования проектной активности (папки)
			</xsl:when>
			<xsl:when test="19=number(@event-type)">
				Изменение внешнего ID проектной активности (папки)
			</xsl:when>
			<xsl:when test="20=number(@event-type)">
				Изменение блокировки списаний по проектной активности (папки)
			</xsl:when>
			<xsl:when test="21=number(@event-type)">
				Удаление корневой проектной активности (папки)
			</xsl:when>
			<xsl:when test="22=number(@event-type)">
				Удаление некорневой проектной активности (папки)
			</xsl:when>
			<xsl:when test="23=number(@event-type)">
				Создание корневой проектной активности (папки)
			</xsl:when>
			<xsl:when test="24=number(@event-type)">
				Создание некорневой проектной активности (папки)
			</xsl:when>
			<xsl:when test="25=number(@event-type)">
				Изменение клиента у проектной активности - экспорт
			</xsl:when>
			<xsl:when test="26=number(@event-type)">
				Изменение клиента у проектной активности - импорт
			</xsl:when>
			<xsl:when test="27=number(@event-type)">
				Перенос проектной активности в другую папку - экспорт
			</xsl:when>
			<xsl:when test="28=number(@event-type)">
				Перенос проектной активности в другую папку - импорт
			</xsl:when>
			<xsl:when test="29=number(@event-type)">
				Изменение состояния или признака прототипа у проектной активности
			</xsl:when>
			<xsl:when test="30=number(@event-type)">
				Изменение типа активности у проектной активности
			</xsl:when>
			<xsl:when test="31=number(@event-type)">
				Перенос организации - экспорт
			</xsl:when>
			<xsl:when test="32=number(@event-type)">
				Перенос организации - импорт
			</xsl:when>
			<xsl:when test="33=number(@event-type)">
				Изменение наименования или сокращенного наименования организации
			</xsl:when>
			<xsl:when test="34=number(@event-type)">
				Создание организации
			</xsl:when>
			<xsl:when test="35=number(@event-type)">
				Изменение запланированного времени
			</xsl:when>
			<xsl:when test="36=number(@event-type)">
				Изменение оставшегося времени
			</xsl:when>
			<xsl:when test="37=number(@event-type)">
				Изменение блокировки по системе в целом
			</xsl:when>
			<xsl:when test="38=number(@event-type)">
				Создание временной организации
			</xsl:when>
			<xsl:when test="39=number(@event-type)">
				Снятие атрибута 'временный' у организации
			</xsl:when>
			<xsl:when test="40=number(@event-type)">
				Создание нового тендера
			</xsl:when>
			<xsl:when test="41=number(@event-type)">
				Создание участия в лоте
			</xsl:when>
			<xsl:when test="42=number(@event-type)">
				Модификация участника в лоте
			</xsl:when>
			<xsl:when test="43=number(@event-type)">
				Удаление участника в лоте
			</xsl:when>
			<xsl:when test="44=number(@event-type)">
				Изменение директора тендера - снятие
			</xsl:when>
			<xsl:when test="45=number(@event-type)">
				Изменение директора тендера - назначение
			</xsl:when>
			<xsl:when test="46=number(@event-type)">
				Удаление тендера
			</xsl:when>
			<xsl:when test="47=number(@event-type)">
				Изменение состояния лота
			</xsl:when>
			<xsl:when test="48=number(@event-type)">
				Превышение запланированного времени по инциденту
			</xsl:when>
			<xsl:when test="49=number(@event-type)">
				Приближение крайнего срока инцидента
			</xsl:when>
			<xsl:when test="50=number(@event-type)">
				Нарушение крайнего срока инцидента
			</xsl:when>
			<xsl:when test="51=number(@event-type)">
				Создание нового лота
			</xsl:when>
			<xsl:when test="52=number(@event-type)">
				Изменение лота
			</xsl:when>
			<xsl:when test="53=number(@event-type)">
				Удаление лота
			</xsl:when>
			<xsl:when test="54=number(@event-type)">
				Изменение описание тендера
			</xsl:when>
			<xsl:when test="55=number(@event-type)">
				Изменение состояния тендера
			</xsl:when>
			<xsl:when test="56=number(@event-type)">
				Добавления сотрудника в список лиц, принимающих участие в подготовке тендера
			</xsl:when>
			<xsl:when test="57=number(@event-type)">
				Исключение сотрудника из списка лиц, принимающих участие в подготовке тендера
			</xsl:when>
			<xsl:when test="58=number(@event-type)">
				Добавление направления у проектной активности (папки)
			</xsl:when>
			<xsl:when test="59=number(@event-type)">
				Удаление направления у проектной активности (папки)
			</xsl:when>
			<xsl:when test="60=number(@event-type)">
				Изменение доли затрат направления у проектной активности
			</xsl:when>
			<xsl:when test="61=number(@event-type)">
				Изменение нормы рабочего дня у сотрудника
			</xsl:when>
			<xsl:when test="62=number(@event-type)">
				Переход проектной активности в состояние "Ожидание закрытия"
			</xsl:when>
			<xsl:when test="63=number(@event-type)">
				Изменение плана занятости сотрудника
			</xsl:when>
			<xsl:when test="64=number(@event-type)">
				Превышение плановой занятости сотрудника на проектах.
			</xsl:when>
			<xsl:otherwise>
				UNDER CONSTRUCTION =  <xsl:value-of select="@event-type"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Сотрудник -->
	<xsl:template name="employee">
		<a href="mailto:{email}"><xsl:value-of select="fio"/>
			<xsl:if test="''!=string(phone)">
				<xsl:text> </xsl:text><NOBR>(<xsl:value-of select="phone"/>)</NOBR>
			</xsl:if>	
		</a>
	</xsl:template>

	<!-- Инцидент -->
	<xsl:template name="inc">
		<xsl:value-of select="@number"/> <xsl:text> - </xsl:text> <xsl:value-of select="n"/>
	</xsl:template>

	<!-- Приоритет -->
	<xsl:template name="priority">
		<xsl:variable name="p" select="number(concat('0',string(priority)))"/>
		<xsl:choose>
			<xsl:when test="$p=1">
				Высокий
			</xsl:when>
			<xsl:when test="$p=2">
				Средний
			</xsl:when>
			<xsl:when test="$p=3">
				Низкий
			</xsl:when>
			<xsl:otherwise>
				Не указан
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Состояние папки (активности) -->
	<xsl:template name="folder-state">
		<xsl:param name="p" select="number(concat('0',string(.)))"/>
		<xsl:choose>
			<xsl:when test="$p=1">
				Открыто
			</xsl:when>
			<xsl:when test="$p=2">
				Ожидание закрытия
			</xsl:when>
			<xsl:when test="$p=4">
				Закрыто
			</xsl:when>
			<xsl:when test="$p=8">
				Заморожено
			</xsl:when>
			<xsl:otherwise>
				Не известно (<xsl:value-of select="$p"/>)
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- формирование времени -->
	<xsl:template name="format-minutes">
		<xsl:param name="m" select="number('0')"/>
		<xsl:variable name="hours" select="floor(((number($m)) mod 600) div 60)"/>
		<xsl:variable name="days" select="floor(number($m) div 600)"/>
		<xsl:variable name="minutes" select="number($m) mod 60"/>
		
		<xsl:if test="$days!=0">
			<xsl:value-of select="concat( string($days), ' дн.')"/> 
		</xsl:if>
		<xsl:if test="$hours!=0 or ($days=0 and $minutes=0)">
			<xsl:if test="$days!=0">
				<xsl:value-of select="', '"/> 
			</xsl:if>
			<xsl:value-of select="concat( string($hours), ' ч.')"/> 
		</xsl:if>
		<xsl:if test="$minutes!=0">
			<xsl:if test="($days!=0) or ($hours!=0)">
				<xsl:value-of select="', '"/> 
			</xsl:if>
			<xsl:value-of select="concat( string($minutes), ' мин.')"/> 
		</xsl:if>
		
	</xsl:template>
		
	<!-- Состояние лота -->
	<xsl:template name="lot-state">
		<xsl:for-each select="state[1]">
			<xsl:call-template name="lot-state-ex"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="lot-state-ex">
		<xsl:variable name="p" select="number(concat('0',string(.)))"/>
		<xsl:choose>
			<xsl:when test="$p=0">
				Получение документов
			</xsl:when>
			<xsl:when test="$p=1">
				Принятие решения
			</xsl:when>
			<xsl:when test="$p=2">
				Участие
			</xsl:when>
			<xsl:when test="$p=3">
				Отказ от участия
			</xsl:when>
			<xsl:when test="$p=4">
				Рассмотрение предложения
			</xsl:when>
			<xsl:when test="$p=5">
				Выигран
			</xsl:when>
			<xsl:when test="$p=6">
				Проигран
			</xsl:when>
			<xsl:when test="$p=7">
				Отменен
			</xsl:when>
			<xsl:otherwise>
				Не указан
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<!-- Крайний срок -->
	<xsl:template name="date-only">
		<xsl:value-of select="concat(substring(string(.),9,2),'.',substring(string(.),6,2),'.',substring(string(.),1,4))" />
	</xsl:template>	
	
	<!-- Выводит поле, скрытое при явном просмотре сообщения, но отображаемое в режиме auto-preview в списке в Outlook -->
	<xsl:template name="preview-info">
		<DIV STYLE="position:absolute; top:-50px; height:0px; width:1px; height:1px; overflow:hidden; padding:2px; font-size:1px;">
			<xsl:choose>			
				<!-- #1: Создание инцидента -->
				<!-- #2: Изменение состояния инцидента -->
				<!-- #3: Удаление инцидента -->
				<!-- #4: Новое задание по инциденту -->
				<!-- #5: Изменение роли исполнителя по инциденту -->
				<!-- #6: Удаление задания по инциденту -->
				<!-- #7: Изменение наименования, описания или описания решения инцидента -->
				<!-- #8: Изменение приоритета, крайнего срока инцидента -->
				<!-- #9: Перенос инцидента -  экспорт -->
				<!-- #10: Перенос инцидента -  импорт -->
				<xsl:when test="1 &lt;= number(@event-type) and number(@event-type) &lt;= 10">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						Инцидент: <xsl:call-template name="inc"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #11: Добавление участника проектной команды -->
				<!-- #12: Удаление участника проектной команды -->
				<!-- #13: Удаление роли у участника проектной команды -->
				<!-- #14: Добавление роли участника проектной команды -->
				<xsl:when test="11 &lt;= number(@event-type) and number(@event-type) &lt;= 14">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #15: Удаление организации -->
				<!-- #16: Снятие директора организации -->
				<!-- #17: Установка директора организации -->
				<xsl:when test="15 &lt;= number(@event-type) and number(@event-type) &lt;= 17">
					<xsl:for-each select="org[1]">
						Организация: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #18: Изменение наименование проектной активности (папки) -->
				<xsl:when test="18=number(@event-type)">
					Активность: <xsl:value-of select="old-name"/><BR />
				</xsl:when>
				
				<!-- #19: Изменение внешнего ID проектной активности (папки) -->
				<!-- #20: Изменение блокировки списаний по проектной активности (папки) -->
				<xsl:when test="19=number(@event-type) or 20=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Активность: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #21: Удаление корневой проектной активности (папки) -->
				<xsl:when test="21=number(@event-type)">
					Удаленная активность: <xsl:value-of select="deleted-folder"/><BR />
				</xsl:when>
				<!-- #22: Удаление некорневой проектной активности (папки) -->
				<xsl:when test="22=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Удаленная активность: <xsl:value-of select="./deleted-folder"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #23: Создание корневой проектной активности (папки) -->
				<!-- #24: Создание некорневой проектной активности (папки) -->
				<xsl:when test="23=number(@event-type) or 24=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Активность (каталог): <xsl:value-of select="n"/>
					</xsl:for-each>
				</xsl:when>
				
				<!-- #25: Изменение клиента у проектной активности - экспорт -->
				<xsl:when test="25=number(@event-type)">
					<xsl:for-each select="moved-folder">
						Перемещаемая активность (каталог): <xsl:value-of select="."/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #26: Изменение клиента у проектной активности - импорт -->
				<xsl:when test="26=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Активность (каталог): <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #27: Перенос проектной активности в другую папку - экспорт -->
				<xsl:when test="27=number(@event-type)">
					<xsl:for-each select="moved-folder">
						Перемещаемая активность (каталог): <xsl:value-of select="."/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #28: Перенос проектной активности в другую папку - импорт -->
				<!-- #29: Изменение состояния или признака прототипа у проектной активности -->
				<!-- #30: Изменение типа активности у проектной активности -->
				<xsl:when test="28=number(@event-type) or 29=number(@event-type) or 30=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Активность (каталог): <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>				
				
				<!-- #31: Перенос организации - экспорт -->
				<xsl:when test="31=number(@event-type)">
					<xsl:for-each select="old-parent-name[1]">
						Перемещаемая организация: <xsl:value-of select="."/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #32: Перенос организации - экспорт -->
				<xsl:when test="32=number(@event-type)">
					<xsl:for-each select="org[1]">
						Перемещенная организация: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #33: Изменение наименования или сокращенного наименования организации -->
				<!-- #34: Создание организации -->
				<xsl:when test="33=number(@event-type) or 34=number(@event-type)">
					<xsl:for-each select="org[1]">
						Организация: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #35: Изменение запланированного времени -->
				<!-- #36: Изменение оставшегося времени -->
				<xsl:when test="35=number(@event-type) or 36=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						Инцидент: <xsl:call-template name="inc"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #37: Изменение блокировки по системе в целом -->
				<xsl:when test="37=number(@event-type)">
					<xsl:for-each select="BlockDate[1]">
						Новая дата блокировки: <xsl:call-template name="date-only"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #38: Создание описания организации -->
				<!-- #39: Снятие атрибута 'временный' у организации -->
				<xsl:when test="38=number(@event-type) or 39=number(@event-type)">
					<xsl:for-each select="org[1]">
						Организация: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #40: Создание нового тендера -->
				<xsl:when test="40=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #41: Создание участия в лоте -->
				<!-- #42: Модификация участника в лоте -->
				<!-- #43: Удаление участника в лоте -->
				<xsl:when test="41=number(@event-type) or 42=number(@event-type) or 43=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
						<xsl:for-each select="lot[1]">
							Лот: <xsl:call-template name="tender"/><BR />
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
				
				<!-- #44: Изменение директора тендера - снятие -->
				<!-- #45: Изменение директора тендера - назначение -->
				<xsl:when test="44=number(@event-type) or 45=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #46: Удаление тендера -->
				<xsl:when test="46=number(@event-type)">
					<xsl:for-each select="deleted-tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #47: Изменение состояния лота -->
				<xsl:when test="47=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
						<xsl:for-each select="lot[1]">
							Лот: <xsl:call-template name="tender"/><BR />
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
				
				<!-- #48: Превышение запланированного времени по инциденту -->
				<!-- #49: Приближение крайнего срока инцидента -->
				<!-- #50: Нарушение крайнего срока инцидента -->
				<xsl:when test="48=number(@event-type) or 49=number(@event-type) or 50=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
					<xsl:for-each select="incident[1]">
						Инцидент: <xsl:call-template name="inc"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #51: Создание нового лота -->
				<!-- #52: Изменение лота -->
				<!-- #53: Удаление лота -->
				<xsl:when test="51=number(@event-type) or 52=number(@event-type) or 53=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
						<xsl:for-each select="lot[1]">
							Лот: <xsl:call-template name="tender"/><BR />
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
				
				<!-- #54: Изменение описание тендера -->
				<!-- #55: Изменение состояния тендера -->
				<!-- #56: Добавления сотрудника в список лиц, принимающих участие в подготовке тендера -->
				<!-- #57: Исключение сотрудника из списка лиц, принимающих участие в подготовке тендера -->
				<xsl:when test="54=number(@event-type) or 55=number(@event-type) or 56=number(@event-type) or 57=number(@event-type)">
					<xsl:for-each select="tender[1]">
						Тендер: <xsl:call-template name="tender"/><BR />
					</xsl:for-each>
				</xsl:when>
				
				<!-- #58: Добавление направления у проектной активности (папки) -->
				<!-- #59: Удаление направления у проектной активности (папки) -->
				<!-- #60: Изменение доли затрат направления у проектной активности -->
				<xsl:when test="58=number(@event-type) or 59=number(@event-type) or 60=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>

				<!-- #61: Изменение нормы рабочего времени сотрудника -->
				<xsl:when test="61=number(@event-type)">
					<xsl:for-each select="employee[1]">
						Сотрудник: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>

				<!-- #62: Переход проектной активности в состояние "Ожидание закрытия" -->
				<xsl:when test="62=number(@event-type)">
					<xsl:for-each select="folder[1]">
						Проект: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				<!-- #63: Изменение плана занятости сотрудника -->
				<xsl:when test="63=number(@event-type)">
					<xsl:for-each select="employee[1]">
						Сотрудник: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				<!-- #64: Превышение плановой занятости сотрудника на проектах -->
				<xsl:when test="64=number(@event-type)">
					<xsl:for-each select="employee[1]">
						Сотрудник: <xsl:value-of select="n"/><BR />
					</xsl:for-each>
				</xsl:when>
				<!-- Во всех остальных случаях - просто пусто -->
				<xsl:otherwise>
					<SPAN> </SPAN>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- для того, чтобы вытеснить из auto-preview текст заголовка (или, 
				по крайней мере отделить текст заголовка от значимого текста) -->
			<BR />
			<BR />
			<BR />
		</DIV>
	</xsl:template>
	
	<!-- Выводит заголовок -->	
	<xsl:template name="heading">
		<TABLE CELLSPACING="0" CELLPADDING="0" CLASS="mail-head">
		<TBODY>
			<TR>
				<TD CLASS="head-pane-1" STYLE="position: relative; width:100%;">
					<DIV CLASS="head-title"><NOBR>Incident Tracker</NOBR></DIV>
					<DIV CLASS="head-subtitle"><NOBR>Система оперативного управления проектами</NOBR></DIV>
				</TD>
				<!-- TODO: По-хорошему, здесь надо выводить наименование компании-владелицы системы -->
				<TD CLASS="head-pane-2"><NOBR STYLE="color:white;">Компания <A HREF="http://www.croc.ru/" STYLE="color:#2D4;"><B>КРОК</B></A></NOBR></TD>
			</TR>
		</TBODY>
		</TABLE>
	</xsl:template>
	
	<!-- Выводит разделитель -->	
	<xsl:template name="middot">
		<xsl:text> </xsl:text>
		<xsl:value-of disable-output-escaping="yes" select="'&amp;middot;'"/>
		<xsl:text> </xsl:text>
	</xsl:template>	
	
	<!-- Выводит стили -->
		<!-- ВНИМЕНИЕ! Указание шрифта для BODY определяет шрифт, используемый при reply письма! -->
	<xsl:template name="styles">
	<STYLE>
		BODY { 
			margin: 0px 5px 5px 5px; 
			font-family: Verdana, Helvetica;
			font-weight: normal;
			font-size: 10px;
			cursor: default;
		}
	   
		DIV.it-mail, DIV.it-mail TD {
			font-family: Verdana;
			font-weight: normal;
			font-size: 9px;
			color: #357;
			cursor: default;
		}
		DIV.it-mail { margin: 0px; }
		DIV.it-mail TD {
			color: #357;
			text-align: left;
			vertical-align: top;
			font-size: 11px;
		}
		DIV.it-mail HR { border: #ddeeff groove 4px; border-width: 0px 0px 3px 0px; }
		DIV.it-mail EM { font-weight: bold; font-style: normal; color: #D33; }
		DIV.it-mail EM A { font-weight: bold; color: #D33; }
		DIV.it-mail A { color: #369; text-decoration: none; }
		DIV.it-mail A:hover { color: #58B; text-decoration: underline; }
		
		.spnGoTo {
			display: block-inline;
			margin: 0px 0px 0px 0px;
			padding: 0px 1px 0px 0px;
		}
		A:hover SPAN.spnGoTo { 
			display: block-inline;
			margin: 0px 0px 0px 0px;
			padding: 0px 0px 0px 1px;
			text-decoration: none; 
		}

		.mail-head {
			margin: 0px 0px 10px 0px;
			color: #fff;
			background-color: #369;
			border: #F7AF00 groove 3px; 
			border-width: 0px 0px 3px 0px;
		}
		.head-pane-1 {
			text-align: left;
			vertical-align: middle;
			height: 27px;
			padding: 5px 250px 0px 10px;
		}
		.head-pane-2 {
			text-align: left;
			vertical-align: middle;
			height: 27px;
			padding: 5px 10px 5px 10px;
			font-size: 10px;
			color: #fff;
		}
		.head-title {
			position: absolute;
			top: 0px;
			left: 15px;
			font-family: Georgia;
			font-weight: bold;
			font-size: 25px;
			font-style: italic;
			color: #f5f7ff;
		}
		.head-subtitle {
			position: absolute;
			top: 30px;
			left: 5px;
			text-transform: uppercase; 
			font-family: Verdana;
			font-size: 8px;
			font-weight: bold;
			color: #036; 
		}
	   
		.mail-body {
			margin: 0px 0px 0px 0px;
			padding: 0px 5px 5px 5px;
		}
		.mail-timing {
			font-size: 9px;
			font-weight: normal;
		}
		.mail-subject { 
			font-weight: normal;
			font-size: 18px;
		}
		.content-subj {
			padding: 2px 5px 2px 2px;
			border: #d0ddee solid 1px;
			border-width: 0px 0px 1px 0px;
		}
		.content-text {
			font-weight: bold;
			padding: 2px 2px 2px 5px;
			border: #d0ddee solid 1px;
			border-width: 0px 0px 1px 0px;
		}
		.content-links { 
			font-size: 11px;
			margin: 0px 0px 0px 1px; 
		}
    
    table.mail-links {
      margin-left:20px;
      padding-top:5px;
      vertical-align: top
    }
    
    table.mail-links td div {
      margin-left : 15px
    }
	</STYLE>
	</xsl:template>
</xsl:stylesheet>  
