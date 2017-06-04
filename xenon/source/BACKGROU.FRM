VERSION 2.00
Begin Form BackgroundEdit 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Background"
   ClientHeight    =   2565
   ClientLeft      =   2445
   ClientTop       =   2235
   ClientWidth     =   3570
   Height          =   2970
   Left            =   2385
   LinkTopic       =   "Form4"
   MaxButton       =   0   'False
   ScaleHeight     =   2565
   ScaleWidth      =   3570
   Top             =   1890
   Width           =   3690
   Begin PictureBox Picture1 
      Height          =   2130
      Left            =   0
      ScaleHeight     =   2100
      ScaleWidth      =   3540
      TabIndex        =   2
      Top             =   450
      Width           =   3570
   End
   Begin SSPanel Panel3D1 
      Align           =   1  'Align Top
      Height          =   465
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   3570
      Begin ComboBox BackDropDown 
         Height          =   300
         Left            =   180
         Style           =   2  'Dropdown List
         TabIndex        =   1
         Top             =   90
         Width           =   3210
      End
   End
End
Sub Form_Load ()

    BackDropDown.AddItem "Sunset"
    BackDropDown.ListIndex = 0

End Sub

