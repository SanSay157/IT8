<%@ Page 
	Language="C#" 
	ValidateRequest="false" 
	AutoEventWireup="true" 

	MasterPageFile="~/xu-save-object-multipart.master" 
	
	Inherits="Croc.XmlFramework.Web.XSaveObjectMultipartPage" 
	
	EnableViewState="false"
	EnableSessionState="True" 
 Codebehind="x-save-object-multipart.aspx.cs" %>
<asp:Content runat="server" ContentPlaceHolderID="ContentPlaceHolder" EnableViewState="false">
	<?import namespace="XFW" implementation="x-progress-bar.htc"/>
	<table cellspacing="0" cellpadding="0" width="100%" height="100%" id="idMainTable" style="display:block">
		<tr>
			<td id="idLabel" align="center">Инициализация...</td>
		</tr>
		<tr>
			<td  width="100%" >
				<XFW:XProgressBar
					ID="ProgressObject" language="VBScript" 
					SolidPageBorder="false" 
					Enabled="False" 
					style="width:100%; height:24px;"
				/>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" height="100%" border="1" style="border:none;font-size:60%" cellpadding="2" cellspacing="4">
					<tr>
						<td width="50%">Передано байт:</td>
						<td width="50%" align="right" id="idSizeSent">0</td>
					</tr>
					<tr>
						<td>Байт в блоке:</td>
						<td align="right" id="idChunkSize">?</td>
					</tr>
					<tr>
						<td>Осталось времени:</td>
						<td align="right" id="idETA">?</td>
					</tr>
					<tr>
						<td>Скорость (kbps):</td>
						<td align="right" id="idBandwith">?</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="x-pane-control">
				<table ID="xBarControl" class="x-controlbar" cellspacing="0" cellpadding="0" width="100%" height="100%">
				<tr>
					<td align="center">
						<button class="x-button-wide" style="width: 12em" name="cmdMain" onclick="DoCloseWindow" language="VBScript">Прервать загрузку</button>
					</td>
				</tr>
				</table>
			</td>
		</tr>
	</table>
	<!-- Табличка повтора операции, изначально не видна -->
	<table cellspacing="0" cellpadding="0" width="100%" height="100%" id="idRetryTable" style="table-layout:fixed;display:none;">
		<tr>
			<td align="center">При передаче данных на сервер произошла ошибка!</td>
		</tr>
		<tr height="100%">
			<td>
				<TEXTAREA 
					id="idTechInfo" 
					STYLE="font-family:Courier New;font-size:9pt;width:100%;height:100%;overflow:scroll" 
					readonly>
				</TEXTAREA>
			</td>
		</tr>
		<tr>
			<td class="x-pane-control">
				<table class="x-controlbar">
				<tr>
					<td align="center" style="padding:5px">
						<button class="x-button-wide"  
							id="cmdRetry"  onclick="DoSetRetryResult(true)" 
							language="VBScript">Повторить попытку</button>
						<button class="x-button-wide"  
							id="cmdCancel" onclick="DoSetRetryResult(false)" 
							language="VBScript">Отменить</button>
					</td>
				</tr>
				</table>
			</td>
		</tr>
	</table>
</asp:Content>
