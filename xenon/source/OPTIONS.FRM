VERSION 2.00
Begin Form OptionsForm 
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   3  'Fixed Double
   Caption         =   "Options"
   ClientHeight    =   2220
   ClientLeft      =   1236
   ClientTop       =   1872
   ClientWidth     =   4008
   Height          =   2640
   Left            =   1188
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2220
   ScaleWidth      =   4008
   Top             =   1500
   Width           =   4104
   Begin CheckBox Check3 
      Caption         =   "Build Tunnel Supports"
      Height          =   288
      Left            =   1440
      TabIndex        =   12
      Top             =   1080
      Value           =   1  'Checked
      Width           =   2352
   End
   Begin CheckBox Check2 
      Caption         =   "Music"
      Height          =   195
      Left            =   1440
      TabIndex        =   11
      Top             =   450
      Value           =   1  'Checked
      Width           =   1545
   End
   Begin SpinButton WinnersSpin 
      Delay           =   200
      Height          =   240
      Left            =   3615
      TdThickness     =   1
      Top             =   1845
      Width           =   195
   End
   Begin PictureBox picture_box 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   1275
      Left            =   450
      ScaleHeight     =   106
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   24
      TabIndex        =   7
      Top             =   405
      Width           =   285
   End
   Begin CommandButton OK_Button 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   345
      Left            =   135
      TabIndex        =   8
      Top             =   1710
      Width           =   1005
   End
   Begin PictureBox ball 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   195
      Left            =   90
      Picture         =   OPTIONS.FRX:0000
      ScaleHeight     =   16
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   20
      TabIndex        =   6
      Top             =   540
      Visible         =   0   'False
      Width           =   240
   End
   Begin Timer Timer1 
      Interval        =   40
      Left            =   45
      Top             =   0
   End
   Begin SpinButton NumPlayersSpin 
      Delay           =   200
      Height          =   240
      Left            =   3615
      TdThickness     =   1
      Top             =   1515
      Width           =   195
   End
   Begin CheckBox Check1 
      Caption         =   "Sound Effects"
      Height          =   195
      Left            =   1440
      TabIndex        =   3
      Top             =   765
      Value           =   1  'Checked
      Width           =   1545
   End
   Begin CheckBox ReboundingCheck 
      Caption         =   "Rebounding Walls"
      Height          =   240
      Left            =   1440
      TabIndex        =   2
      Top             =   135
      Value           =   1  'Checked
      Width           =   1860
   End
   Begin VScrollBar GravityScroll 
      Height          =   1152
      Left            =   855
      Max             =   6
      Min             =   1
      TabIndex        =   1
      Top             =   450
      Value           =   4
      Width           =   240
   End
   Begin Shape Shape2 
      Height          =   240
      Left            =   3210
      Top             =   1845
      Width           =   420
   End
   Begin Label NumWinnersLabel 
      Alignment       =   2  'Center
      Caption         =   "1"
      Height          =   210
      Left            =   3225
      TabIndex        =   10
      Top             =   1860
      Width           =   405
   End
   Begin Label Label1 
      Caption         =   "Number of Winners"
      Height          =   195
      Index           =   2
      Left            =   1455
      TabIndex        =   9
      Top             =   1875
      Width           =   1635
   End
   Begin Label Label1 
      Caption         =   "Number of Players"
      Height          =   195
      Index           =   1
      Left            =   1455
      TabIndex        =   5
      Top             =   1560
      Width           =   1635
   End
   Begin Label NumPlayersLabel 
      Alignment       =   2  'Center
      Caption         =   "2"
      Height          =   190
      Left            =   3240
      TabIndex        =   4
      Top             =   1530
      Width           =   390
   End
   Begin Shape Shape1 
      Height          =   240
      Left            =   3210
      Top             =   1515
      Width           =   420
   End
   Begin Label Label1 
      Caption         =   "Gravity"
      Height          =   195
      Index           =   0
      Left            =   585
      TabIndex        =   0
      Top             =   180
      Width           =   615
   End
End
Declare Function RemoveMenu Lib "User" (ByVal hMenu As Integer, ByVal nPosition As Integer, ByVal wFlags As Integer) As Integer
Declare Function GetSystemMenu Lib "User" (ByVal hWnd As Integer, ByVal bRevert As Integer) As Integer

Const MF_BYPOSITION = &H400

Dim my_gravity As Single
Dim temp_gravity As Single
Dim v As Integer
Dim y As Integer
Dim temp_numPlayers As Integer
Dim temp_numWinners As Integer

Sub Alter_Menu ()

    Dim HSysMenu As Integer
    Dim R As Integer
    
    HSysMenu = GetSystemMenu(hWnd, 0)
  
    R = RemoveMenu(HSysMenu, 8, MF_BYPOSITION)
    R = RemoveMenu(HSysMenu, 7, MF_BYPOSITION)
    R = RemoveMenu(HSysMenu, 5, MF_BYPOSITION)

End Sub

Sub Cancel_Button_Click ()

    Unload OptionsForm

End Sub

Sub Form_Load ()

    Alter_Menu
    
    Move (Screen.Width - Width) * .5, (Screen.Height - Height) * .5
    
    y = picture_box.ScaleHeight * .1
    my_gravity = 1
    temp_gravity = 1
    v = 0
    
    temp_numPlayers = 2
    temp_numWinners = 1
    If Not midiok Then check2 = False
    If Not registered Then check3.Enabled = False

End Sub

Sub Form_Unload (Cancel As Integer)

    rebounding_walls = reboundingCheck
    gravity = Abs((7 - GravityScroll * 1.2) / 3)
    maxPlayer = NumplayersLabel
    oldMaxPlayer = maxPlayer
    numWinners = NumWinnersLabel
    tunneling = check3
    soundOn = check1
    musicOn = check2
    ReDim player(1 To maxPlayer) As Playertype
    
    Hide
    
    PlayerForm.Show 1

End Sub

Sub GravityScroll_Change ()

    temp_gravity = (GravityScroll.Max * 2 - GravityScroll.Value) / 5

End Sub

Sub GravityScroll_Scroll ()
    
    temp_gravity = (GravityScroll.Max * 2 - GravityScroll.Value) / 5

End Sub

Sub NumPlayersSpin_SpinDown ()

    temp_numPlayers = Val(NumplayersLabel.Caption)
    If temp_numPlayers > 2 Then temp_numPlayers = temp_numPlayers - 1
    NumplayersLabel.Caption = temp_numPlayers
    
    If temp_numPlayers < temp_numWinners + 1 Then temp_numWinners = temp_numPlayers - 1
    NumWinnersLabel.Caption = temp_numWinners

End Sub

Sub NumPlayersSpin_SpinUp ()
    
    temp_numPlayers = Val(NumplayersLabel.Caption)
    If temp_numPlayers < 5 Then temp_numPlayers = temp_numPlayers + 1
    NumplayersLabel.Caption = temp_numPlayers

End Sub

Sub OK_Button_Click ()
    
    Unload OptionsForm
    
End Sub

Sub Timer1_Timer ()

    picture_box.Cls
    
    v = v + my_gravity
    y = y + v
    
    bitblt picture_box.hDC, 0, y, ball.ScaleWidth, ball.ScaleHeight, ball.hDC, 0, 0, copyBlt
    picture_box.Refresh
    
    If y > 58 Then
        my_gravity = temp_gravity
        v = -v - my_gravity
    End If

End Sub

Sub WinnersSpin_SpinDown ()

    temp_numWinners = Val(NumWinnersLabel.Caption)
    If temp_numWinners > 1 Then temp_numWinners = temp_numWinners - 1
    NumWinnersLabel.Caption = temp_numWinners

End Sub

Sub WinnersSpin_SpinUp ()
    
    temp_numWinners = Val(NumWinnersLabel.Caption)
    If temp_numWinners < temp_numPlayers - 1 Then temp_numWinners = temp_numWinners + 1
    NumWinnersLabel.Caption = temp_numWinners

End Sub

