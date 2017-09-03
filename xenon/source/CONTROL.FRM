VERSION 2.00
Begin Form ControlPanel 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   0  'None
   ClientHeight    =   2160
   ClientLeft      =   1185
   ClientTop       =   3810
   ClientWidth     =   7035
   FillColor       =   &H00FFFFFF&
   Height          =   2565
   Left            =   1125
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2160
   ScaleWidth      =   7035
   Top             =   3465
   Width           =   7155
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   345
      Index           =   10
      Left            =   6345
      TabIndex        =   32
      Top             =   1350
      Width           =   450
      Begin SSCommand DigButton 
         Enabled         =   0   'False
         Height          =   330
         Index           =   7
         Left            =   0
         Picture         =   CONTROL.FRX:0000
         RoundedCorners  =   0   'False
         TabIndex        =   37
         Top             =   0
         Visible         =   0   'False
         Width           =   435
      End
      Begin SSCommand DigButton 
         Height          =   330
         Index           =   3
         Left            =   0
         Picture         =   CONTROL.FRX:053A
         RoundedCorners  =   0   'False
         TabIndex        =   33
         Top             =   0
         Width           =   435
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   345
      Index           =   9
      Left            =   5895
      TabIndex        =   30
      Top             =   1710
      Width           =   450
      Begin SSCommand DigButton 
         Enabled         =   0   'False
         Height          =   330
         Index           =   6
         Left            =   0
         Picture         =   CONTROL.FRX:0A74
         RoundedCorners  =   0   'False
         TabIndex        =   36
         Top             =   0
         Visible         =   0   'False
         Width           =   435
      End
      Begin SSCommand DigButton 
         Height          =   330
         Index           =   2
         Left            =   0
         Picture         =   CONTROL.FRX:0FAE
         RoundedCorners  =   0   'False
         TabIndex        =   31
         Top             =   0
         Width           =   435
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   345
      Index           =   8
      Left            =   5445
      TabIndex        =   28
      Top             =   1350
      Width           =   450
      Begin SSCommand DigButton 
         Enabled         =   0   'False
         Height          =   330
         Index           =   5
         Left            =   0
         Picture         =   CONTROL.FRX:14E8
         RoundedCorners  =   0   'False
         TabIndex        =   35
         Top             =   0
         Visible         =   0   'False
         Width           =   435
      End
      Begin SSCommand DigButton 
         Height          =   330
         Index           =   1
         Left            =   0
         Picture         =   CONTROL.FRX:1A22
         RoundedCorners  =   0   'False
         TabIndex        =   29
         Top             =   0
         Width           =   435
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   345
      Index           =   6
      Left            =   5895
      TabIndex        =   26
      Top             =   1005
      Width           =   450
      Begin SSCommand DigButton 
         Enabled         =   0   'False
         Height          =   330
         Index           =   4
         Left            =   0
         Picture         =   CONTROL.FRX:1F5C
         RoundedCorners  =   0   'False
         TabIndex        =   34
         Top             =   0
         Visible         =   0   'False
         Width           =   435
      End
      Begin SSCommand DigButton 
         Height          =   330
         Index           =   0
         Left            =   0
         Picture         =   CONTROL.FRX:2496
         RoundedCorners  =   0   'False
         TabIndex        =   27
         Top             =   0
         Width           =   435
      End
   End
   Begin PictureBox AngleIndicator 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      DrawWidth       =   2
      FillColor       =   &H00C0C0C0&
      FillStyle       =   0  'Solid
      Height          =   732
      Left            =   1725
      Picture         =   CONTROL.FRX:29D0
      ScaleHeight     =   49
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   118
      TabIndex        =   22
      Top             =   765
      Width           =   1764
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   264
      Index           =   7
      Left            =   1728
      TabIndex        =   18
      Top             =   1550
      Width           =   1788
      Begin HScrollBar AngleScroll 
         Height          =   240
         LargeChange     =   2
         Left            =   10
         Max             =   90
         Min             =   -90
         TabIndex        =   19
         Top             =   10
         Width           =   1760
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   345
      Index           =   5
      Left            =   4320
      TabIndex        =   14
      Top             =   1728
      Width           =   915
      Begin SSCommand MoveButton 
         Enabled         =   0   'False
         Height          =   315
         Index           =   3
         Left            =   435
         Picture         =   CONTROL.FRX:2E0E
         RoundedCorners  =   0   'False
         TabIndex        =   24
         Top             =   15
         Visible         =   0   'False
         Width           =   450
      End
      Begin SSCommand MoveButton 
         Enabled         =   0   'False
         Height          =   315
         Index           =   2
         Left            =   15
         Picture         =   CONTROL.FRX:3120
         RoundedCorners  =   0   'False
         TabIndex        =   23
         Top             =   15
         Visible         =   0   'False
         Width           =   450
      End
      Begin SSCommand MoveButton 
         Height          =   315
         Index           =   0
         Left            =   10
         Picture         =   CONTROL.FRX:3432
         RoundedCorners  =   0   'False
         TabIndex        =   17
         Top             =   10
         Width           =   450
      End
      Begin SSCommand MoveButton 
         Height          =   315
         Index           =   1
         Left            =   435
         Picture         =   CONTROL.FRX:3744
         RoundedCorners  =   0   'False
         TabIndex        =   16
         Top             =   15
         Width           =   450
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   328
      Index           =   4
      Left            =   4320
      TabIndex        =   13
      Top             =   1008
      Width           =   914
      Begin CommandButton PassButton 
         BackColor       =   &H00000000&
         Cancel          =   -1  'True
         Caption         =   "&Done"
         Height          =   300
         Left            =   10
         TabIndex        =   15
         Top             =   10
         Width           =   876
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   328
      Index           =   3
      Left            =   4320
      TabIndex        =   11
      Top             =   576
      Width           =   914
      Begin CommandButton ShootButton 
         BackColor       =   &H00000000&
         Caption         =   "&Fire!"
         Height          =   300
         Left            =   10
         TabIndex        =   12
         Top             =   12
         Width           =   876
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   856
      Index           =   2
      Left            =   240
      TabIndex        =   7
      Top             =   768
      Width           =   808
      Begin PictureBox RobotPicture 
         BackColor       =   &H0080C0FF&
         ClipControls    =   0   'False
         Height          =   828
         Left            =   15
         ScaleHeight     =   53
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   50
         TabIndex        =   8
         Top             =   15
         Width           =   780
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   1260
      Index           =   1
      Left            =   1248
      TabIndex        =   3
      Top             =   768
      Width           =   288
      Begin PictureBox EnergyBar 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         Height          =   1232
         Left            =   10
         ScaleHeight     =   80
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   15
         TabIndex        =   4
         Top             =   10
         Width           =   252
      End
   End
   Begin SSPanel Panel 
      BevelOuter      =   1  'Inset
      Height          =   1040
      Index           =   0
      Left            =   3696
      TabIndex        =   1
      Top             =   768
      Width           =   285
      Begin VScrollBar PowerScroll 
         Height          =   1020
         LargeChange     =   10
         Left            =   15
         Max             =   -1
         Min             =   -100
         TabIndex        =   2
         Top             =   15
         Value           =   -50
         Width           =   252
      End
   End
   Begin MsgBlaster MsgBlaster1 
      Prop8           =   "Click on ""..."" for the About Box ---->"
   End
   Begin Label Label1 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Bore && Tunnel"
      Height          =   195
      Left            =   5535
      TabIndex        =   25
      Top             =   675
      Width           =   1215
   End
   Begin Label Label 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Move"
      Height          =   195
      Index           =   3
      Left            =   4500
      TabIndex        =   21
      Top             =   1485
      Width           =   465
   End
   Begin Label AngleLabel 
      Alignment       =   2  'Center
      BackColor       =   &H00C0C0C0&
      Caption         =   "0°"
      Height          =   204
      Left            =   2400
      TabIndex        =   20
      Top             =   1872
      Width           =   492
   End
   Begin Label PowerLabel 
      Alignment       =   2  'Center
      BackColor       =   &H00C0C0C0&
      Caption         =   "50%"
      Height          =   204
      Left            =   3600
      TabIndex        =   10
      Top             =   1872
      Width           =   492
   End
   Begin Label Label 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Angle"
      Height          =   192
      Index           =   2
      Left            =   2352
      TabIndex        =   9
      Top             =   528
      Width           =   492
   End
   Begin Label Label 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Power"
      Height          =   192
      Index           =   1
      Left            =   3552
      TabIndex        =   6
      Top             =   528
      Width           =   528
   End
   Begin Label Label 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   "Energy"
      Height          =   192
      Index           =   0
      Left            =   1104
      TabIndex        =   5
      Top             =   528
      Width           =   600
   End
   Begin Label Window_Caption 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "(Robot Name)"
      Height          =   192
      Left            =   48
      TabIndex        =   0
      Top             =   60
      Visible         =   0   'False
      Width           =   1176
   End
End
Option Explicit

Dim Window_Active As Integer
Dim ControlBox_Selected As Integer

Sub AngleScroll_Change ()
    
    Update_Angle_Indicator
    AngleLabel.Caption = AngleScroll.Value & "°"

End Sub

Sub AngleScroll_Scroll ()
    
    Update_Angle_Indicator
    AngleLabel.Caption = AngleScroll.Value & "°"

End Sub

Sub DigButton_Click (index As Integer)
    
    Dim xx As Integer, yy As Integer

    tunnelRequest = index + 1

    xx = player(activePlayer).x \ 16
    yy = player(activePlayer).y \ 16

    Select Case tunnelRequest
        Case 1
            If yy >= 1 Then
                If board(xx, yy - 1).style < 1 And board(xx + 1, yy - 1).style < 1 Then tunnelRequest = 0
            Else
                tunnelRequest = 0
            End If
        Case 2
            If xx >= 1 Then
                If board(xx - 1, yy).style < 1 And board(xx - 1, yy + 1).style < 1 Then tunnelRequest = 0
            Else
                tunnelRequest = 0
            End If
        Case 3
            If yy <= boardY - 2 Then
                If board(xx, yy + 2).style < 1 And board(xx + 1, yy + 2).style < 1 Then tunnelRequest = 0
            Else
                tunnelRequest = 0
            End If
        Case 4
            If xx <= boardX + 2 Then
                If board(xx + 2, yy).style < 1 And board(xx + 2, yy + 1).style < 1 Then tunnelRequest = 0
            Else
                tunnelRequest = 0
            End If
    End Select

    If tunnelRequest Then
        For index = 0 To 3
            digButton(index).Enabled = False
            digButton(index + 4).Visible = True
        Next
    End If
    
End Sub

Sub draw_energy ()

    Dim y As Integer
    Dim s As Single
    
    For y = EnergyBar.ScaleHeight - (player(activePlayer).energy * EnergyBar.ScaleHeight / 100) To EnergyBar.ScaleHeight Step 2
        
        s = y / EnergyBar.ScaleHeight
        EnergyBar.Line (0, y)-Step(EnergyBar.ScaleWidth, 1), RGB(255 - s * 100, (1 - s) * 255, 0), B
    
    Next

End Sub

Sub Form_Deactivate ()

  Window_Active = False

End Sub

Sub Form_Load ()
  
  Dim success As Integer
  Dim index As Integer
  
  If Not registered Then
    For index = 4 To 7
        digButton(index).Visible = True
        digButton(index - 4).Enabled = False
    Next
  End If
  
  moveRequest = 0
  robotpicture.AutoRedraw = True
  bitblt robotpicture.hDC, robotpicture.ScaleWidth * .5 - 16, robotpicture.ScaleHeight * .5 - 16, 32, 32, xenon!RealGraphic(player(activePlayer).graphic).hDC, 32, 0, andBlt
  bitblt robotpicture.hDC, robotpicture.ScaleWidth * .5 - 16, robotpicture.ScaleHeight * .5 - 16, 32, 32, xenon!RealGraphic(player(activePlayer).graphic).hDC, 0, 0, orBlt
  robotpicture.Refresh
  
  success = SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, FLAGS)
  
  window_caption.Caption = RTrim(player(activePlayer).Title)
  PowerScroll.Value = -player(activePlayer).power
  AngleScroll.Value = player(activePlayer).angle
  
  Update_Angle_Indicator
  draw_energy
  
  
  Move oldControlX, OldControlY
  
  window_caption.Move (Width - window_caption.Width) \ 2 + 200, 90
  
  'Setup Message Blaster
  MsgBlaster1.hWndTarget = hWnd
  MsgBlaster1.MsgList(0) = WM_NCHITTEST
  MsgBlaster1.MsgPassage(0) = EATMESSAGE
  MsgBlaster1.MsgList(1) = WM_CLOSE
  MsgBlaster1.MsgList(2) = WM_NCACTIVATE
  MsgBlaster1.MsgList(3) = WM_NCLBUTTONDBLCLK
  MsgBlaster1.MsgPassage(3) = EATMESSAGE
  MsgBlaster1.MsgList(4) = WM_NCLBUTTONDOWN
  MsgBlaster1.MsgList(5) = WM_COMMAND
  MsgBlaster1.MsgPassage(5) = PREPROCESS
  MsgBlaster1.MsgList(6) = WM_ACTIVATEAPP

  Form_Paint

End Sub

Sub Form_LostFocus ()
  
  Window_Active = True

End Sub

Sub Form_Paint ()
  
  MakeOfficeForm controlPanel, Window_Active, ControlBox_Selected

End Sub

Sub Form_Unload (Cancel As Integer)
    
    Select Case gamePeriod
        Case "Falling": gamePeriod = "Falling Next Player"
        Case "Start Falling": gamePeriod = "Start Falling Next Player"
        Case Else: gamePeriod = "Next Player"
    End Select

    oldControlX = controlPanel.Left
    OldControlY = controlPanel.Top
    player(activePlayer).power = Abs(PowerScroll.Value)
    player(activePlayer).angle = AngleScroll.Value

End Sub

Sub MoveButton_Click (index As Integer)

    Dim i As Integer, xx As Integer, yy As Integer
    If 1 Then
        Select Case index
            Case 0: moveRequest = -16
            Case 1: moveRequest = 16
        End Select
    
        If player(activePlayer).x + moveRequest >= 0 And player(activePlayer).x + moveRequest + 1 < boardX * 16 And xenon!bullet.Visible = 0 Then
            xx = player(activePlayer).x \ 16
            yy = player(activePlayer).y \ 16
    
            If moveRequest > 0 Then
                If board(xx + 2, yy).style > 0 Or board(xx + 2, yy).whoshere Or board(xx + 2, yy + 1).style > 0 Or board(xx + 2, yy + 1).whoshere Then moveRequest = 0
            Else
               If board(xx - 1, yy).style > 0 Or board(xx - 1, yy).whoshere Or board(xx - 1, yy + 1).style > 0 Or board(xx - 1, yy + 1).whoshere Then moveRequest = 0
            End If
            If moveRequest Then
                MoveButton(2).Visible = True
                MoveButton(3).Visible = True
                For i = 0 To 3
                    MoveButton(i).Enabled = False
                Next
             
            End If
        Else
            moveRequest = 0
        End If
    End If

End Sub

Sub MsgBlaster1_Message (MsgVal As Integer, wParam As Integer, lParam As Long, lRetVal As Long)
  
  Static i As Integer, tc&
  Static FormTop As Integer
  Static FormLeft As Integer
  Static xPos As Integer
  Static yPos As Integer
  
  Select Case MsgVal
    
    Case WM_NCACTIVATE
      
      If wParam Then
        Window_Active = True
      Else
        Window_Active = False
      End If
      Form_Paint
    
    Case WM_NCHITTEST
      
      FormTop = Top / Screen.TwipsPerPixelY
      FormLeft = Left / Screen.TwipsPerPixelX
      
      xPos = (lParam And &HFFFF&) - FormLeft
      yPos = (lParam / 65536) - FormTop
      
      If (yPos < 31) And (yPos > 4) And (xPos < 32) And (xPos > 3) Then
        lRetVal = HTSYSMENU
      ElseIf (yPos < 31) And (yPos > 4) And (xPos > 3) And (xPos < Width / Screen.TwipsPerPixelX - 5) Then
        lRetVal = HTCAPTION
      Else
        lRetVal = HTCLIENT
      End If
    
    Case WM_NCLBUTTONDBLCLK
      If wParam = HTSYSMENU Then
        Unload controlPanel
      End If
    
    Case WM_NCLBUTTONDOWN
      
      If wParam = HTSYSMENU Then
        ControlBox_Selected = True
        Form_Paint
        
        ShowSystemMenu controlPanel
        
        ControlBox_Selected = False
        Form_Paint
      
      End If
  
  End Select

End Sub

Sub PassButton_Click ()

    If moveRequest = 0 And tunnelRequest = 0 Then Unload controlPanel

End Sub

Sub PowerScroll_Change ()

    PowerLabel.Caption = Abs(PowerScroll.Value) & "%"

End Sub

Sub PowerScroll_Scroll ()
    
    PowerLabel.Caption = Abs(PowerScroll.Value) & "%"

End Sub

Function Radian (q As Integer)

    Radian = q * 3.14 / 180

End Function

Sub ShootButton_Click ()

    Dim q As Single, i As Integer, xx As Integer, yy As Integer, junk As Integer

    If gamePeriod <> "Falling" And gamePeriod <> "Falling Next Player" And moveRequest = 0 Then
        ShootButton.Enabled = False
        bulletX = player(activePlayer).x + 16: bulletY = player(activePlayer).y - 2
        xenon!bullet.Move bulletX - 5, bulletY - 5
        bulletLife = 200
        q = Radian(CInt(AngleScroll.Value)) + 1.5707
        bulletdx = -Cos(q) * Abs(PowerScroll.Value) / 6
        bulletdy = -Sin(q) * Abs(PowerScroll.Value) / 6
        xenon!bullet.Visible = True
        'set up players to get hit:
        For i = 1 To maxplayer
            xx = player(i).x \ 16: yy = player(i).y \ 16
            board(xx, yy).whoshere = i
            board(xx + 1, yy).whoshere = i
            board(xx, yy + 1).whoshere = i
            board(xx + 1, yy + 1).whoshere = i
        Next
        xx = player(activePlayer).x \ 16: yy = player(activePlayer).y \ 16
        board(xx, yy).whoshere = 0'don't hit self
        board(xx + 1, yy).whoshere = 0

        If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "shoot.wav"), SYNC)
    End If

End Sub

Sub Update_Angle_Indicator ()

    Static q As Single
    
    AngleIndicator.DrawWidth = 1
    AngleIndicator.FillColor = QBColor(8)
    AngleIndicator.Circle (AngleIndicator.ScaleWidth * .5, AngleIndicator.ScaleHeight * .95), AngleIndicator.ScaleWidth / 2.5 + 2, QBColor(8), , , 1 / 1.1
    AngleIndicator.FillColor = RGB(120, 120, 255)
    AngleIndicator.Circle (AngleIndicator.ScaleWidth * .5, AngleIndicator.ScaleHeight * .95), AngleIndicator.ScaleWidth / 2.5, 0, , , 1 / 1.1

    q = Radian(CInt(AngleScroll.Value)) + 1.5707
    AngleIndicator.DrawWidth = 2
    AngleIndicator.Line (AngleIndicator.ScaleWidth * .5 + 2, AngleIndicator.ScaleHeight * .95)-Step(-Cos(q) * AngleIndicator.ScaleWidth / 2.8, -Sin(q) * AngleIndicator.ScaleHeight / 1.3), RGB(100, 100, 225)
    AngleIndicator.Line (AngleIndicator.ScaleWidth * .5, AngleIndicator.ScaleHeight * .95 - 2)-Step(-Cos(q) * AngleIndicator.ScaleWidth / 2.8, -Sin(q) * AngleIndicator.ScaleHeight / 1.3)
    
    AngleIndicator.Line (AngleIndicator.ScaleWidth * .5 - AngleIndicator.ScaleWidth / 2.5 - 5, AngleIndicator.ScaleHeight * .95)-Step(AngleIndicator.ScaleWidth * 2 / 2.5 + 10, 2 * Screen.TwipsPerPixelY), AngleIndicator.BackColor, BF
    AngleIndicator.Line (AngleIndicator.ScaleWidth * .5 - AngleIndicator.ScaleWidth / 2.5, AngleIndicator.ScaleHeight * .95)-Step(AngleIndicator.ScaleWidth * 2 / 2.5, 0)
    AngleIndicator.Line (AngleIndicator.ScaleWidth * .5 - AngleIndicator.ScaleWidth / 2.5, AngleIndicator.ScaleHeight * .95 + 1)-Step(AngleIndicator.ScaleWidth * 2 / 2.5, 1), QBColor(15), B
    
End Sub

