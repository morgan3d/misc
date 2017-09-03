VERSION 2.00
Begin Form BackGraphicsFrm 
   BackColor       =   &H0080C0FF&
   Caption         =   "Background Graphics"
   ClientHeight    =   4020
   ClientLeft      =   1365
   ClientTop       =   1485
   ClientWidth     =   7095
   Height          =   4425
   Left            =   1305
   LinkTopic       =   "Form1"
   ScaleHeight     =   268
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   473
   Top             =   1140
   Visible         =   0   'False
   Width           =   7215
   Begin PictureBox Cloud 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   690
      Index           =   3
      Left            =   1170
      ScaleHeight     =   46
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   76
      TabIndex        =   4
      Top             =   810
      Width           =   1140
   End
   Begin PictureBox Cloud 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   690
      Index           =   2
      Left            =   945
      ScaleHeight     =   46
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   76
      TabIndex        =   3
      Top             =   585
      Width           =   1140
   End
   Begin PictureBox Cloud 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   690
      Index           =   1
      Left            =   675
      ScaleHeight     =   46
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   76
      TabIndex        =   2
      Top             =   405
      Width           =   1140
   End
   Begin PictureBox Temp 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   690
      Left            =   2025
      ScaleHeight     =   46
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   55
      TabIndex        =   1
      Top             =   1665
      Width           =   825
   End
   Begin PictureBox Cloud 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   690
      Index           =   0
      Left            =   450
      ScaleHeight     =   46
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   76
      TabIndex        =   0
      Top             =   225
      Width           =   1140
   End
End
Option Explicit

Sub Form_Load ()

    RealLoadPicture cloud(0), temp, mypath & "cmask1.max"
    RealLoadPicture cloud(1), temp, mypath & "c1.max"
    RealLoadPicture cloud(2), temp, mypath & "cmask2.max"
    RealLoadPicture cloud(3), temp, mypath & "c2.max"

End Sub

