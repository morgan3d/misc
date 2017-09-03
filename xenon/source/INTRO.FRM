VERSION 2.00
Begin Form Intro 
   BorderStyle     =   0  'None
   ClientHeight    =   4812
   ClientLeft      =   3936
   ClientTop       =   2472
   ClientWidth     =   3624
   ControlBox      =   0   'False
   Height          =   5232
   Left            =   3888
   LinkTopic       =   "Form1"
   ScaleHeight     =   4812
   ScaleWidth      =   3624
   Top             =   2100
   Width           =   3720
   Begin SSPanel Panel3D1 
      Align           =   2  'Align Bottom
      BevelInner      =   1  'Inset
      BevelWidth      =   2
      BorderWidth     =   4
      Caption         =   "Welcome to Xenon!"
      Font3D          =   2  'Raised w/heavy shading
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   24
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      ForeColor       =   &H00004000&
      Height          =   1392
      Left            =   0
      Outline         =   -1  'True
      RoundedCorners  =   0   'False
      TabIndex        =   1
      Top             =   3420
      Width           =   3624
      Begin Timer Timer1 
         Interval        =   30000
         Left            =   480
         Top             =   660
      End
   End
   Begin SSCommand Command3D1 
      AutoSize        =   2  'Adjust Button Size To Picture
      Height          =   2508
      Left            =   0
      Picture         =   INTRO.FRX:0000
      TabIndex        =   0
      Top             =   0
      Width           =   2892
   End
End
Option Explicit

Sub Command3D1_Click ()
    Unload Me
End Sub

Sub Command3D1_KeyPress (KeyAscii As Integer)
    Unload Me
End Sub

Sub Form_KeyPress (KeyAscii As Integer)
    Unload Me
End Sub

Sub Form_Load ()
    Command3D1.AutoSize = 2
    
    Me.Width = Command3D1.Width
    Me.Height = Command3D1.Height + Panel3D1.Height

    Me.Move (screen.Width - Me.Width) * .5, (screen.Height - Me.Height) * .5
End Sub

Sub Form_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single)
    Unload Me
End Sub

Sub Panel3D1_MouseDown (Button As Integer, Shift As Integer, X As Single, Y As Single)
    Unload Me
End Sub

Sub Timer1_Timer ()
    Unload Me
End Sub

