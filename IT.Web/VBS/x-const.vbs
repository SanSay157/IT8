' ���� ���������� �������� XFW.NET
Option Explicit

const MAX_POST_SIZE	= 65536         ' ������ ������, ������������� �� ������
const MAX_GET_SIZE	= 2000	        ' ������������ ������ ������ URL ��� ������������� GET �������
const ABOUT_BLANK = "about:blank"   ' ��������� URL ��� �������� ������� ����

'CLSID-��� ������������ �����������
Const CLSID_LIST_VIEW = "CLSID:B1E34CF7-16B5-4DA0-877A-7838116881C5" 
Const CLSID_TREE_VIEW = "CLSID:4BB69C5B-87D1-4630-ABB5-34CE7AB57724" 
Const CLSID_POPUP_MENU = "CLSID:5D303927-4DED-454B-828B-389A87DE4B7E" 
Const CLSID_XDOWNLOAD = "CLSID:31A948DA-9A04-4A95-8138-3B62E9AB92FC" 
Const CLSID_XSERVICE = "CLSID:31A948DA-9A04-4A95-8138-3B62E9AB92FC" 
Const CLSID_DT_PICKER = "CLSID:A5F5AB19-67A3-40EA-BC7C-70A64BBFF8A4" 
Const CLSID_COMBOBOX = "CLSID:EB98C2B1-BEF9-4C24-B248-0F1634BD1488" 
Const CLSID_MSXML = "CLSID:f5078f32-c551-11d3-89b9-0000f81fe221" 

' ������� ����. ����� ������ 36 ������. ����������� 32 �����
Const GUID_EMPTY = "00000000-0000-0000-0000-000000000000"

' ����� ������ �����
Const TSM_LEAFNODE = "leafnode" 
Const TSM_LEAFNODES = "leafnodes" 
Const TSM_ANYNODE = "anynode" 
Const TSM_ANYNODES = "anynodes" 

' ������������ QUERY_SET. ���������� � ����������� ������� XTreeView (OnDataLoading, OnDataLoaded)
Const QUERY_SET_ROOT  = 0 	' �������� ��������� �������� ��������� ��������; ��� ������� ������ ���� �������������� ��������� ��������� ��������� sNodePath �������� ������ ������;
Const QUERY_SET_CHILD = -1 	' �������� ��������� ��������� ��������, ����������� ��������, ����������� �����, ������������ � �������� �������� ��������� sNodePath (�������� ��� ���� �� ����� ���� ����� ������ �������);
Const QUERY_SET_NODE  = 1	' �������� ��������, ���� �������� �������� ��������� ��������� sNodePath (�������� ��� ���� �� ����� ���� ����� ������ �������).

'Croc.XmlFramework.XConst+TreeRefreshMode
' ����� ���������� ������
' ��������� � ����������� ��������/��������/����������� ���� ������
' ��. ����� DoRefreshTree � x-tree-std-ops.vbs
Const TRM_NONE = 0 ' ������ �� ���������
Const TRM_NODE = 1 ' �������� ������� ���� ������
Const TRM_CHILDS = 2 ' �������� (�������������) �������� ���� �������� ���� ������
Const TRM_PARENT = 4 ' ����������  (������������) ��������� ����� ������� �������� ����
Const TRM_TREE = 8 ' �������� �� ������
Const TRM_PARENTNODE = 16 ' ���������� ������� �������� ����
Const TRM_PARENTNODES = 32 ' ���������� ����� ������� � ������� �������� ���� � �� �����


'Croc.XmlFramework.XConst+ListMode
Const LM_LIST = 0 
Const LM_SINGLE = 1 
Const LM_MULTIPLE = 2 
Const LM_MULTIPLE_OR_NONE = 3 


' ������������ action'�� ����������� ������ 
const CMD_EDIT			= "DoEdit"			' �������������
const CMD_ADD			= "DoCreate"		' �������
const CMD_DELETE		= "DoDelete"		' �������
const CMD_SYSINFO		= "DoSysInfo"		' ��������� ����������
const CMD_REPORT		= "DoReport"		' �����
const CMD_REFRESH		= "DoRefresh"		' ��������
const CMD_RESETFILTER	= "DoResetFilter"	' �������� ������
const CMD_EXCEL			= "DoExcelExport"	' ������� � Excel [������ ������]
const CMD_HELP			= "DoHelp"			' ������
const CMD_VIEW			= "DoView"			' ��������
const CMD_MOVE			= "DoMove"			' ������� ������� � ������ [������ ������]
const CMD_NODEREFRESH	= "DoNodeRefresh"	' ���������� ���� � ������ [������ ������]

'########################################################################################################
' ��������� ����� ������ ��� XService.CreateErrorDialog
Const ERRDLG_ICON_ERROR			= 0		' ������
Const ERRDLG_ICON_WARNING		= 1		' ��������������
Const ERRDLG_ICON_INFORMATION	= 2		' ����������
Const ERRDLG_ICON_QUESTION		= 3		' ������
Const ERRDLG_ICON_SECURITY		= 4		' ������������

'########################################################################################################
' ����� ������������ ��������� ������ (��� ������������� ����� ���������)
const VK_ESC				= 27	' ESC
const VK_INS				= 45	' INSERT
const VK_DEL				= 46	' DELETE
const VK_DBLCLICK			= &H100		' ������� ���� ����� �������
' �������� ������� WriteEnumAsVbsConst("VK_", System.Windows.Forms.Keys.A.GetType(), Response);
'System.Windows.Forms.Keys
Const VK_NONE = 0 
Const VK_LBUTTON = 1 
Const VK_RBUTTON = 2 
Const VK_CANCEL = 3 
Const VK_MBUTTON = 4 
Const VK_XBUTTON1 = 5 
Const VK_XBUTTON2 = 6 
Const VK_BACK = 8 
Const VK_TAB = 9 
Const VK_LINEFEED = 10 
Const VK_CLEAR = 12 
Const VK_RETURN = 13 
Const VK_ENTER = 13 
Const VK_SHIFTKEY = 16 
Const VK_CONTROLKEY = 17 
Const VK_MENU = 18 
Const VK_PAUSE = 19 
Const VK_CAPSLOCK = 20 
Const VK_CAPITAL = 20 
Const VK_KANAMODE = 21 
Const VK_HANGUELMODE = 21 
Const VK_HANGULMODE = 21 
Const VK_JUNJAMODE = 23 
Const VK_FINALMODE = 24 
Const VK_KANJIMODE = 25 
Const VK_HANJAMODE = 25 
Const VK_ESCAPE = 27 
Const VK_IMECONVERT = 28 
Const VK_IMENONCONVERT = 29 
Const VK_IMEACEEPT = 30 
Const VK_IMEMODECHANGE = 31 
Const VK_SPACE = 32 
Const VK_PAGEUP = 33 
Const VK_PRIOR = 33 
Const VK_PAGEDOWN = 34 
Const VK_NEXT = 34 
Const VK_END = 35 
Const VK_HOME = 36 
Const VK_LEFT = 37 
Const VK_UP = 38 
Const VK_RIGHT = 39 
Const VK_DOWN = 40 
Const VK_SELECT = 41 
Const VK_PRINT = 42 
Const VK_EXECUTE = 43 
Const VK_PRINTSCREEN = 44 
Const VK_SNAPSHOT = 44 
Const VK_INSERT = 45 
Const VK_DELETE = 46 
Const VK_HELP = 47 
Const VK_D0 = 48 
Const VK_D1 = 49 
Const VK_D2 = 50 
Const VK_D3 = 51 
Const VK_D4 = 52 
Const VK_D5 = 53 
Const VK_D6 = 54 
Const VK_D7 = 55 
Const VK_D8 = 56 
Const VK_D9 = 57 
Const VK_A = 65 
Const VK_B = 66 
Const VK_C = 67 
Const VK_D = 68 
Const VK_E = 69 
Const VK_F = 70 
Const VK_G = 71 
Const VK_H = 72 
Const VK_I = 73 
Const VK_J = 74 
Const VK_K = 75 
Const VK_L = 76 
Const VK_M = 77 
Const VK_N = 78 
Const VK_O = 79 
Const VK_P = 80 
Const VK_Q = 81 
Const VK_R = 82 
Const VK_S = 83 
Const VK_T = 84 
Const VK_U = 85 
Const VK_V = 86 
Const VK_W = 87 
Const VK_X = 88 
Const VK_Y = 89 
Const VK_Z = 90 
Const VK_LWIN = 91 
Const VK_RWIN = 92 
Const VK_APPS = 93 
Const VK_NUMPAD0 = 96 
Const VK_NUMPAD1 = 97 
Const VK_NUMPAD2 = 98 
Const VK_NUMPAD3 = 99 
Const VK_NUMPAD4 = 100 
Const VK_NUMPAD5 = 101 
Const VK_NUMPAD6 = 102 
Const VK_NUMPAD7 = 103 
Const VK_NUMPAD8 = 104 
Const VK_NUMPAD9 = 105 
Const VK_MULTIPLY = 106 
Const VK_ADD = 107 
Const VK_SEPARATOR = 108 
Const VK_SUBTRACT = 109 
Const VK_DECIMAL = 110 
Const VK_DIVIDE = 111 
Const VK_F1 = 112 
Const VK_F2 = 113 
Const VK_F3 = 114 
Const VK_F4 = 115 
Const VK_F5 = 116 
Const VK_F6 = 117 
Const VK_F7 = 118 
Const VK_F8 = 119 
Const VK_F9 = 120 
Const VK_F10 = 121 
Const VK_F11 = 122 
Const VK_F12 = 123 
Const VK_F13 = 124 
Const VK_F14 = 125 
Const VK_F15 = 126 
Const VK_F16 = 127 
Const VK_F17 = 128 
Const VK_F18 = 129 
Const VK_F19 = 130 
Const VK_F20 = 131 
Const VK_F21 = 132 
Const VK_F22 = 133 
Const VK_F23 = 134 
Const VK_F24 = 135 
Const VK_NUMLOCK = 144 
Const VK_SCROLL = 145 
Const VK_LSHIFTKEY = 160 
Const VK_RSHIFTKEY = 161 
Const VK_LCONTROLKEY = 162 
Const VK_RCONTROLKEY = 163 
Const VK_LMENU = 164 
Const VK_RMENU = 165 
Const VK_BROWSERBACK = 166 
Const VK_BROWSERFORWARD = 167 
Const VK_BROWSERREFRESH = 168 
Const VK_BROWSERSTOP = 169 
Const VK_BROWSERSEARCH = 170 
Const VK_BROWSERFAVORITES = 171 
Const VK_BROWSERHOME = 172 
Const VK_VOLUMEMUTE = 173 
Const VK_VOLUMEDOWN = 174 
Const VK_VOLUMEUP = 175 
Const VK_MEDIANEXTTRACK = 176 
Const VK_MEDIAPREVIOUSTRACK = 177 
Const VK_MEDIASTOP = 178 
Const VK_MEDIAPLAYPAUSE = 179 
Const VK_LAUNCHMAIL = 180 
Const VK_SELECTMEDIA = 181 
Const VK_LAUNCHAPPLICATION1 = 182 
Const VK_LAUNCHAPPLICATION2 = 183 
Const VK_OEMSEMICOLON = 186 
Const VK_OEMPLUS = 187 
Const VK_OEMCOMMA = 188 
Const VK_OEMMINUS = 189 
Const VK_OEMPERIOD = 190 
Const VK_OEMQUESTION = 191 
Const VK_OEMTILDE = 192 
Const VK_OEMOPENBRACKETS = 219 
Const VK_OEMPIPE = 220 
Const VK_OEMCLOSEBRACKETS = 221 
Const VK_OEMQUOTES = 222 
Const VK_OEM8 = 223 
Const VK_OEMBACKSLASH = 226 
Const VK_PROCESSKEY = 229 
Const VK_ATTN = 246 
Const VK_CRSEL = 247 
Const VK_EXSEL = 248 
Const VK_ERASEEOF = 249 
Const VK_PLAY = 250 
Const VK_ZOOM = 251 
Const VK_NONAME = 252 
Const VK_PA1 = 253 
Const VK_OEMCLEAR = 254 
Const VK_KEYCODE = 65535 
Const VK_SHIFT = 65536 
Const VK_CONTROL = 131072 
Const VK_ALT = 262144 
Const VK_MODIFIERS = -65536 


'########################################################################################################
' ���������	����� ����-������
Const KF_ALTLTMASK	= 4				' Alt
Const KF_CTRLMASK	= 2				' Control
Const KF_SHIFTMASK	= 1				' Shift

'########################################################################################################
' ���������	���������� � ������
Const CORDER_ASC = 1
Const CORDER_DESC = 2

'########################################################################################################
' ���������	������������ � ������
Const CALIGN_CENTER	= 3
Const CALIGN_LEFT =	1
Const CALIGN_RIGHT = 2

'########################################################################################################
' �����, ������������ ��� ������ XFileDownload::SelectFile
const BFF_CREATEPROMPT			= &H002000
const BFF_FILEMUSTEXIST			= &H001000
const BFF_HIDEREADONLY			= &H000004
const BFF_NODEREFERENCELINKS	= &H100000
const BFF_NONETWORKBUTTON		= &H020000
const BFF_NOREADONLYRETURN		= &H008000
const BFF_NOTESTFILECREATE		= &H010000
const BFF_NOVALIDATE			= &H000100
const BFF_OVERWRITEPROMPT		= &H000002
const BFF_PATHMUSTEXIST			= &H000800
const BFF_READONLY 				= &H000001
const BFF_SHAREAWARE			= &H004000
const BFF_SAVEDLG				= &H200000
