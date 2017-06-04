VERSION 2.00
Begin Form MenuForm 
   Caption         =   "Menu"
   ClientHeight    =   984
   ClientLeft      =   936
   ClientTop       =   1896
   ClientWidth     =   1944
   Height          =   1728
   Left            =   888
   LinkTopic       =   "Form1"
   ScaleHeight     =   984
   ScaleWidth      =   1944
   Top             =   1200
   Width           =   2040
   Begin Menu Control_Menu 
      Caption         =   "Control_Menu"
      Begin Menu Move_Form 
         Caption         =   "&Move"
      End
      Begin Menu Close_Form 
         Caption         =   "&Close   Alt+F4"
      End
   End
End
Option Explicit

Sub Close_Form_Click ()
    Unload ControlPanel
End Sub

Sub Move_Form_Click ()
  
  Dim tc&
  
  MakeOfficeForm ControlPanel, True, False
  
  tc& = SendMessage(ControlPanel.hWnd, WM_SYSCOMMAND, SC_MOVE, 0)

End Sub

