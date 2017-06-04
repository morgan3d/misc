
Declare Function SetWindowPos Lib "User" (ByVal h%, ByVal hb%, ByVal X%, ByVal y%, ByVal cx%, ByVal cy%, ByVal f%) As Integer
Declare Function SendMessage Lib "User" (ByVal hWnd As Integer, ByVal wMsg As Integer, ByVal wParam As Integer, lParam As Any) As Long
Declare Function GetSystemMetrics Lib "User" (ByVal nIndex As Integer) As Integer

Global Const IDM_SYSMOVE = 101
Global Const IDM_SYSCLOSE = 102
Global Const MF_ENABLED = 0
Global Const MF_STRING = 0
Global Const ACTIVE_TITLE_BAR = &H80000002
Global Const INACTIVE_TITLE_BAR = &H80000003
Global Const WINDOW_FRAME = &H80000006
Global Const SM_CYMENU = 15
Global Const SC_MOVE = &HF010
Global Const WM_ACTIVATEAPP = &H1C
Global Const WM_CLOSE = &H10
Global Const WM_COMMAND = &H111
Global Const WM_NCACTIVATE = &H86
Global Const WM_NCHITTEST = &H84
Global Const WM_NCLBUTTONDBLCLK = &HA3
Global Const WM_NCLBUTTONDOWN = &HA1
Global Const WM_SYSCOMMAND = &H112
Global Const WM_USER = &H400
Global Const PREPROCESS = -1
Global Const EATMESSAGE = 0
Global Const POSTPROCESS = 1
Global Const HTCLIENT = 1
Global Const HTCAPTION = 2
Global Const HTSYSMENU = 3

Type Rect
  
  Left As Integer
  Top As Integer
  right As Integer
  bottom As Integer

End Type

Global hSysMenu As Long

