VERSION 2.00
Begin Form PlayerForm 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   0  'None
   Caption         =   "Player Information"
   ClientHeight    =   3225
   ClientLeft      =   1350
   ClientTop       =   1800
   ClientWidth     =   5670
   Height          =   3630
   Left            =   1290
   LinkTopic       =   "Form1"
   ScaleHeight     =   3225
   ScaleWidth      =   5670
   Top             =   1455
   Width           =   5790
   Begin SSPanel Panel3D1 
      Align           =   1  'Align Top
      BevelWidth      =   2
      Font3D          =   2  'Raised w/heavy shading
      Height          =   3228
      Left            =   0
      Outline         =   -1  'True
      RoundedCorners  =   0   'False
      TabIndex        =   1
      Top             =   0
      Width           =   5676
      Begin PictureBox GuyPicture 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         Height          =   780
         Left            =   768
         ScaleHeight     =   52
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   55
         TabIndex        =   12
         Top             =   768
         Width           =   828
      End
      Begin SSPanel TitleBar 
         BevelOuter      =   1  'Inset
         Caption         =   "Player 1"
         Font3D          =   4  'Inset w/heavy shading
         FontBold        =   -1  'True
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   348
         Left            =   432
         RoundedCorners  =   0   'False
         TabIndex        =   11
         Top             =   96
         Width           =   4860
      End
      Begin SSOption X_Player 
         Caption         =   "Terminator"
         Height          =   204
         Index           =   5
         Left            =   2928
         TabIndex        =   10
         TabStop         =   0   'False
         Top             =   2448
         Width           =   1740
      End
      Begin SSOption X_Player 
         Caption         =   "R. Daneel"
         Height          =   204
         Index           =   4
         Left            =   2928
         TabIndex        =   9
         TabStop         =   0   'False
         Top             =   2112
         Width           =   1740
      End
      Begin SSOption X_Player 
         Caption         =   "Data"
         Height          =   204
         Index           =   3
         Left            =   2928
         TabIndex        =   8
         TabStop         =   0   'False
         Top             =   1776
         Width           =   1740
      End
      Begin SSOption X_Player 
         Caption         =   "Robbie"
         Height          =   204
         Index           =   2
         Left            =   2928
         TabIndex        =   7
         TabStop         =   0   'False
         Top             =   1440
         Width           =   1740
      End
      Begin SSOption X_Player 
         Caption         =   "Can Opener"
         Height          =   204
         Index           =   1
         Left            =   2928
         TabIndex        =   6
         TabStop         =   0   'False
         Top             =   1104
         Width           =   1740
      End
      Begin SSOption X_Player 
         Height          =   204
         Index           =   0
         Left            =   2928
         TabIndex        =   5
         Top             =   768
         Value           =   -1  'True
         Width           =   204
      End
      Begin CommandButton DoneButton 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Next Player"
         Height          =   348
         Left            =   2208
         TabIndex        =   0
         Top             =   2784
         Width           =   1308
      End
      Begin TextBox PlayerName 
         Height          =   288
         Left            =   3168
         TabIndex        =   2
         Top             =   720
         Width           =   2124
      End
      Begin Label Label1 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Computer"
         Height          =   192
         Index           =   1
         Left            =   1872
         TabIndex        =   3
         Top             =   1104
         Width           =   804
      End
      Begin Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Human"
         Height          =   204
         Index           =   0
         Left            =   1872
         TabIndex        =   4
         Top             =   768
         Width           =   684
      End
      Begin Image Image1 
         Height          =   216
         Index           =   3
         Left            =   5376
         Picture         =   PLAYER.FRX:0000
         Stretch         =   -1  'True
         Top             =   2928
         Width           =   216
      End
      Begin Image Image1 
         Height          =   216
         Index           =   2
         Left            =   5376
         Picture         =   PLAYER.FRX:05A2
         Stretch         =   -1  'True
         Top             =   144
         Width           =   216
      End
      Begin Image Image1 
         Height          =   216
         Index           =   1
         Left            =   96
         Picture         =   PLAYER.FRX:0B44
         Stretch         =   -1  'True
         Top             =   2928
         Width           =   216
      End
      Begin Image Image1 
         Height          =   216
         Index           =   0
         Left            =   96
         Picture         =   PLAYER.FRX:10E6
         Stretch         =   -1  'True
         Top             =   144
         Width           =   216
      End
   End
End
Dim p As Integer

Sub DoneButton_Click ()
    
    Dim index As Integer
    
    'save code goes here
    player(p).Title = PlayerName
    For index = 0 To 5
        If X_Player(index).Value = True Then
            player(p).computer = index
            If index > 0 Then player(p).Title = X_Player(index).Caption
        End If
    Next
    
    
    p = p + 1
    If p <= maxPlayer Then
        titlebar.Caption = "Player " & p
        PlayerName = "Player " & p
        X_Player(0) = True
        If p = maxPlayer Then DoneButton.Caption = "Start Game"
        
        player(p).graphic = p - 1
        bitblt GuyPicture.hDC, GuyPicture.ScaleWidth * .5 - 16, GuyPicture.ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(p).graphic).hDC, 32, 0, andBlt
        bitblt GuyPicture.hDC, GuyPicture.ScaleWidth * .5 - 16, GuyPicture.ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(p).graphic).hDC, 0, 0, orBlt
        GuyPicture.Refresh
    Else
        Unload Me
    End If
    
End Sub

Sub Form_Load ()

    Move (Screen.Width - Width) * .5, (Screen.Height - Height) * .5
    p = 1
    PlayerName = "Player " & p
    
    player(p).graphic = 0
    bitblt GuyPicture.hDC, GuyPicture.ScaleWidth * .5 - 16, GuyPicture.ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(p).graphic).hDC, 32, 0, andBlt
    bitblt GuyPicture.hDC, GuyPicture.ScaleWidth * .5 - 16, GuyPicture.ScaleHeight * .5 - 16, 32, 32, Xenon!RealGraphic(player(p).graphic).hDC, 0, 0, orBlt
    GuyPicture.Refresh
        
End Sub

Sub Form_Unload (Cancel As Integer)
        
        For p = 1 To maxPlayer
            player(p).power = 75
            player(p).angle = CInt(Rnd * 180) - 90
            player(p).energy = 100
            player(p).x = 0
            player(p).y = 0
        Next
        activePlayer = 0
        gamePeriod = "Starting"
        Hide
        LoadBoard mypath & GetRandomBoardName(), backGroundStyle, board(), boardTitle
        DrawBackground Xenon!BackPicture, backGroundStyle
        MakeForePicture Xenon!ForePicture, Xenon!BackPicture
        bitblt Xenon!Display.hDC, 0, 0, Xenon!ForePicture.ScaleWidth, Xenon!ForePicture.ScaleHeight, Xenon!ForePicture.hDC, 0, 0, copyblt
        DoEvents

        TheWindowThatComesUpBeforeTheGame.Show 1

End Sub

Sub X_Player_Click (index As Integer, Value As Integer)

    If index = 0 Then PlayerName.Enabled = True Else PlayerName.Enabled = False
    
End Sub

