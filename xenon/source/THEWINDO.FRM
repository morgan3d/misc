VERSION 2.00
Begin Form TheWindowThatComesUpBeforeTheGame 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   3  'Fixed Double
   ClientHeight    =   3756
   ClientLeft      =   300
   ClientTop       =   2016
   ClientWidth     =   5904
   ControlBox      =   0   'False
   Height          =   4176
   Left            =   252
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3756
   ScaleWidth      =   5904
   Top             =   1644
   Width           =   6000
   Begin SSPanel Panel3D2 
      Font3D          =   4  'Inset w/heavy shading
      Height          =   3132
      Left            =   96
      RoundedCorners  =   0   'False
      TabIndex        =   2
      Top             =   48
      Width           =   5724
      Begin SSPanel PWins 
         BevelOuter      =   1  'Inset
         Height          =   444
         Index           =   4
         Left            =   3120
         RoundedCorners  =   0   'False
         TabIndex        =   4
         Top             =   2352
         Visible         =   0   'False
         Width           =   1788
      End
      Begin PictureBox PPic 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   732
         Index           =   4
         Left            =   3648
         ScaleHeight     =   61
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   12
         Top             =   1536
         Visible         =   0   'False
         Width           =   732
      End
      Begin SSPanel PWins 
         BevelOuter      =   1  'Inset
         Height          =   444
         Index           =   3
         Left            =   816
         RoundedCorners  =   0   'False
         TabIndex        =   11
         Top             =   2352
         Visible         =   0   'False
         Width           =   1788
      End
      Begin PictureBox PPic 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   732
         Index           =   3
         Left            =   1344
         ScaleHeight     =   61
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   10
         Top             =   1536
         Visible         =   0   'False
         Width           =   732
      End
      Begin SSPanel PWins 
         BevelOuter      =   1  'Inset
         Height          =   444
         Index           =   2
         Left            =   3840
         RoundedCorners  =   0   'False
         TabIndex        =   9
         Top             =   960
         Visible         =   0   'False
         Width           =   1788
      End
      Begin PictureBox PPic 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   732
         Index           =   2
         Left            =   4368
         ScaleHeight     =   61
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   8
         Top             =   144
         Visible         =   0   'False
         Width           =   732
      End
      Begin SSPanel PWins 
         BevelOuter      =   1  'Inset
         Height          =   444
         Index           =   1
         Left            =   1968
         RoundedCorners  =   0   'False
         TabIndex        =   7
         Top             =   960
         Visible         =   0   'False
         Width           =   1788
      End
      Begin PictureBox PPic 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   732
         Index           =   1
         Left            =   2544
         ScaleHeight     =   61
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   6
         Top             =   144
         Visible         =   0   'False
         Width           =   732
      End
      Begin SSPanel PWins 
         BevelOuter      =   1  'Inset
         Height          =   444
         Index           =   0
         Left            =   96
         RoundedCorners  =   0   'False
         TabIndex        =   5
         Top             =   960
         Visible         =   0   'False
         Width           =   1788
      End
      Begin PictureBox PPic 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   732
         Index           =   0
         Left            =   624
         ScaleHeight     =   61
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   3
         Top             =   144
         Visible         =   0   'False
         Width           =   732
      End
   End
   Begin CommandButton Command2 
      BackColor       =   &H00C0C0C0&
      Cancel          =   -1  'True
      Caption         =   "&Enter The Caves of Death"
      Default         =   -1  'True
      Height          =   348
      Left            =   1824
      TabIndex        =   0
      Top             =   3312
      Width           =   3996
   End
   Begin CommandButton Command1 
      BackColor       =   &H00C0C0C0&
      Caption         =   "Stop Game"
      Height          =   348
      Left            =   96
      TabIndex        =   1
      Top             =   3312
      Width           =   1260
   End
End
Option Explicit

Sub Command1_Click ()

    Unload Me

End Sub

Sub Command2_Click ()

    Hide
    Unload Me
    GamePeriod = "Starting"
    Xenon!Gametimer.Enabled = True

End Sub

Sub Form_Load ()
    
    Dim index As Integer, p As Integer
    
    Move (screen.Width - Width) * .5, (screen.Height - Height) * .5
    
    maxPlayer = oldMaxPlayer
    For p = 1 To maxPlayer
        player(p).power = 75
        player(p).angle = CInt(Rnd * 180) - 90
        player(p).energy = 100
        player(p).x = 0
        player(p).y = 0
        player(p).hit = False
    Next
    activePlayer = CInt(Rnd * (maxPlayer - 1)) + 1
    GamePeriod = "Starting"
    Unload ControlPanel
    LoadBoard mypath & GetRandomBoardName(), backGroundStyle, board(), boardTitle
    Command2.Caption = "&" & boardTitle

    DrawBackground Xenon!BackPicture, backGroundStyle
    MakeForePicture Xenon!ForePicture, Xenon!BackPicture
    bitblt Xenon!Display.hDC, 0, 0, Xenon!ForePicture.ScaleWidth, Xenon!ForePicture.ScaleHeight, Xenon!ForePicture.hDC, 0, 0, copyblt
    
    For index = 0 To oldMaxPlayer - 1
        PWins(index).Visible = True
        If player(index + 1).computer Then PWins(index).FontBold = False
        PWins(index).Caption = RTrim(player(index + 1).Title) & Chr$(13) & player(index + 1).wins & " Win"
        If player(index + 1).wins <> 1 Then
            PWins(index).Caption = PWins(index).Caption & "s"
        End If
  
        PPic(index).Visible = True
        
        bitblt PPic(index).hDC, PPic(index).ScaleWidth * .5 - 16, PPic(index).ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(index + 1).graphic).hDC, 32, 0, andBlt
        bitblt PPic(index).hDC, PPic(index).ScaleWidth * .5 - 16, PPic(index).ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(index + 1).graphic).hDC, 0, 0, orBlt
        PPic(index).Refresh
    Next

End Sub

