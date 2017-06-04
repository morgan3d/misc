
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

Sub MakeOfficeForm (FormName As Form, Window_Active As Integer, ControlBox_Selected As Integer)
  
  Light = 15
  Dark = 0
  
  'Draw black border
  FormName.Line (0, 0)-(FormName.Width - 10, FormName.Height - 10), QBColor(0), B
  
  'Draw shading on outside of form
  FormName.Line (10, 10)-(FormName.Width - 20, 10), QBColor(Light)
  FormName.Line (10, 10)-(10, FormName.Height - 20), QBColor(Light)
  FormName.Line (FormName.Width - 20, 10)-(FormName.Width - 20, FormName.Height - 20), QBColor(Dark)
  FormName.Line (10, FormName.Height - 20)-(FormName.Width - 20, FormName.Height - 20), QBColor(Dark)

  'Draw title bar
  If Window_Active = True Then
    'Draw active title bar
    FormName.Line (60, 50)-(FormName.Width - 70, 360), ACTIVE_TITLE_BAR, BF
    FormName.PSet (FormName.Window_Caption.Left, FormName.Window_Caption.Top), FormName.Point(FormName.Window_Caption.Left, FormName.Window_Caption.Top)
    FormName.ForeColor = QBColor(15)
    FormName.Print FormName.Window_Caption.Caption
    'FormName.Window_Caption.BackColor = ACTIVE_TITLE_BAR
    'FormName.Window_Caption.ForeColor = QBColor(15)
  Else
    'Draw inactive title bar
    FormName.Line (60, 50)-(FormName.Width - 70, 360), INACTIVE_TITLE_BAR, BF
    FormName.PSet (FormName.Window_Caption.Left, FormName.Window_Caption.Top), FormName.Point(FormName.Window_Caption.Left, FormName.Window_Caption.Top)
    FormName.ForeColor = QBColor(0)
    FormName.Print FormName.Window_Caption.Caption
    'FormName.Window_Caption.ForeColor = QBColor(0)
    'FormName.Window_Caption.BackColor = INACTIVE_TITLE_BAR
  End If
  
  'Draw shading around title bar
  FormName.Line (60, 50)-(FormName.Width - 70, 50), QBColor(Dark)
  FormName.Line (60, 50)-(60, 360), QBColor(Dark)
  FormName.Line (60, 360)-(FormName.Width - 70, 360), QBColor(Light)
  FormName.Line (FormName.Width - 70, 360)-(FormName.Width - 70, 40), QBColor(Light)

  If ControlBox_Selected Then
  
    'Draw control box
    FormName.Line (70, 60)-(380, 350), QBColor(8), BF
    FormName.Line (380, 60)-(380, 360), QBColor(0)

    'Draw minus sign
    FormName.Line (110, 200)-Step(220, 40), QBColor(7), BF
    FormName.Line (100, 190)-Step(220, 40), QBColor(0), BF
    FormName.Line (100, 190)-Step(220, 40), QBColor(15), B
  
  Else
    
    'Draw control box
    FormName.Line (70, 60)-(380, 350), QBColor(7), BF
    FormName.Line (380, 60)-(380, 360), QBColor(0)

    'Draw minus sign
    FormName.Line (110, 200)-Step(220, 40), QBColor(8), BF
    FormName.Line (100, 190)-Step(220, 40), QBColor(15), BF
    FormName.Line (100, 190)-Step(220, 40), QBColor(0), B
  
  End If

End Sub

Sub ShowSystemMenu (FormName As Form)

  FormName.PopupMenu MenuForm.Control_Menu, 0, 60, 360

End Sub

