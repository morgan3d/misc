VERSION 2.00
Begin Form Xenon 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Xenon"
   ClientHeight    =   4512
   ClientLeft      =   708
   ClientTop       =   1908
   ClientWidth     =   7488
   Height          =   5256
   Icon            =   XENON.FRX:0000
   Left            =   660
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   4512
   ScaleWidth      =   7488
   Top             =   1212
   Width           =   7584
   Begin FileListBox File_Box 
      Height          =   1176
      Hidden          =   -1  'True
      Left            =   7536
      Pattern         =   "*.xe"
      System          =   -1  'True
      TabIndex        =   9
      Top             =   48
      Visible         =   0   'False
      Width           =   1656
   End
   Begin SSPanel BackPanel 
      BevelInner      =   1  'Inset
      BevelWidth      =   2
      BorderWidth     =   4
      Height          =   4524
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   7500
      Begin PictureBox RealGraphic 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   7200
         Index           =   4
         Left            =   5940
         ScaleHeight     =   600
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   80
         TabIndex        =   16
         Top             =   -45
         Visible         =   0   'False
         Width           =   960
      End
      Begin PictureBox RealGraphic 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   7200
         Index           =   3
         Left            =   5400
         ScaleHeight     =   600
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   80
         TabIndex        =   15
         Top             =   -405
         Visible         =   0   'False
         Width           =   960
      End
      Begin PictureBox RealGraphic 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   7200
         Index           =   2
         Left            =   4095
         ScaleHeight     =   600
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   80
         TabIndex        =   14
         Top             =   180
         Visible         =   0   'False
         Width           =   960
      End
      Begin MMControl MMControl1 
         Enabled         =   0   'False
         Height          =   345
         Left            =   360
         TabIndex        =   13
         Top             =   3510
         UpdateInterval  =   15000
         Visible         =   0   'False
         Width           =   3540
      End
      Begin PictureBox explosionGraphic 
         AutoRedraw      =   -1  'True
         BorderStyle     =   0  'None
         Enabled         =   0   'False
         Height          =   1500
         Left            =   480
         ScaleHeight     =   125
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   61
         TabIndex        =   8
         Top             =   2352
         Visible         =   0   'False
         Width           =   732
      End
      Begin PictureBox BlockPalette 
         ClipControls    =   0   'False
         Enabled         =   0   'False
         Height          =   1875
         Index           =   1
         Left            =   1800
         ScaleHeight     =   1848
         ScaleWidth      =   2832
         TabIndex        =   7
         Top             =   2610
         Visible         =   0   'False
         Width           =   2850
      End
      Begin PictureBox BlockPalette 
         ClipControls    =   0   'False
         Enabled         =   0   'False
         Height          =   1875
         Index           =   0
         Left            =   855
         ScaleHeight     =   1848
         ScaleWidth      =   2832
         TabIndex        =   6
         Top             =   2130
         Visible         =   0   'False
         Width           =   2850
      End
      Begin PictureBox RealGraphic 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   7200
         Index           =   1
         Left            =   5040
         ScaleHeight     =   600
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   80
         TabIndex        =   5
         Top             =   -270
         Visible         =   0   'False
         Width           =   960
      End
      Begin Timer Gametimer 
         Enabled         =   0   'False
         Interval        =   40
         Left            =   4815
         Top             =   3690
      End
      Begin PictureBox ForePicture 
         BackColor       =   &H0080C0FF&
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Enabled         =   0   'False
         Height          =   1935
         Left            =   2265
         ScaleHeight     =   1932
         ScaleWidth      =   2340
         TabIndex        =   4
         Top             =   375
         Visible         =   0   'False
         Width           =   2340
      End
      Begin PictureBox RealGraphic 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   7200
         Index           =   0
         Left            =   3060
         ScaleHeight     =   600
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   80
         TabIndex        =   3
         Top             =   90
         Visible         =   0   'False
         Width           =   960
      End
      Begin PictureBox BackPicture 
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Enabled         =   0   'False
         Height          =   684
         Left            =   4260
         Picture         =   XENON.FRX:0302
         ScaleHeight     =   684
         ScaleWidth      =   588
         TabIndex        =   2
         Top             =   2100
         Visible         =   0   'False
         Width           =   588
      End
      Begin PictureBox Display 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         ClipControls    =   0   'False
         Height          =   3468
         Left            =   96
         ScaleHeight     =   289
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   465
         TabIndex        =   1
         Top             =   96
         Width           =   5580
         Begin PictureBox BalloonPicture 
            AutoRedraw      =   -1  'True
            BackColor       =   &H00000000&
            BorderStyle     =   0  'None
            ClipControls    =   0   'False
            Enabled         =   0   'False
            FillColor       =   &H00FFFFFF&
            FillStyle       =   0  'Solid
            Height          =   1116
            Left            =   624
            ScaleHeight     =   93
            ScaleMode       =   3  'Pixel
            ScaleWidth      =   101
            TabIndex        =   10
            Top             =   192
            Visible         =   0   'False
            Width           =   1212
         End
         Begin PictureBox BalloonMaskPicture 
            AutoRedraw      =   -1  'True
            BackColor       =   &H00FFFFFF&
            BorderStyle     =   0  'None
            ClipControls    =   0   'False
            Enabled         =   0   'False
            Height          =   1116
            Left            =   1968
            ScaleHeight     =   93
            ScaleMode       =   3  'Pixel
            ScaleWidth      =   101
            TabIndex        =   11
            Top             =   432
            Visible         =   0   'False
            Width           =   1212
         End
         Begin Image bullet 
            Height          =   384
            Left            =   1512
            Picture         =   XENON.FRX:0740
            Top             =   360
            Visible         =   0   'False
            Width           =   384
         End
      End
      Begin Label quote_label 
         AutoSize        =   -1  'True
         Caption         =   "quote_label"
         Height          =   192
         Left            =   4704
         TabIndex        =   12
         Top             =   4128
         Visible         =   0   'False
         Width           =   996
      End
   End
   Begin Menu FileMenu 
      Caption         =   "&File"
      Begin Menu newgame 
         Caption         =   "&New Game"
      End
      Begin Menu OpenGame 
         Caption         =   "&Open Game"
         Visible         =   0   'False
      End
      Begin Menu savegame 
         Caption         =   "&Save Game"
         Visible         =   0   'False
      End
      Begin Menu filesep1 
         Caption         =   "-"
      End
      Begin Menu exitmenu 
         Caption         =   "E&xit"
      End
   End
   Begin Menu helpmenu 
      Caption         =   "&Help"
      Begin Menu instructions 
         Caption         =   "&Instructions"
         Visible         =   0   'False
      End
      Begin Menu reginfo 
         Caption         =   "&Registration Info"
      End
   End
End
Option Explicit

Sub aboutmenu_Click ()

    aboutbox.Show 1

End Sub

Sub BoreBoard (xx, yy)

    If tunneling Then
        If Not (board(xx, yy).style = 0 And board(xx, yy).number = 1) Then
            board(xx, yy).style = 0
            board(xx, yy).number = 8
            bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
            bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, xenon!BlockPalette(0).hDC, 8 * 16, 16, andblt
            bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, xenon!BlockPalette(0).hDC, 8 * 16, 0, orblt
            bitblt Display.hDC, xx * 16, yy * 16, 16, 16, ForePicture.hDC, xx * 16, yy * 16, copyblt
        End If
    ElseIf board(xx, yy).style > 0 Then
        board(xx, yy).style = -1
        bitblt Display.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
        bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
    End If

End Sub

Sub CreateBalloon (orientation As Integer)

    Static text_width As Integer
    Static text_height As Integer
    Static Index As Integer
    Static length_string As Integer
    Static temp_quote As String

    temp_quote = quote(CInt(Rnd * (lastQuote - 1)) + 1)
    quote_label.Caption = wordWrap(temp_quote)
    
    text_width = quote_label.Width / screen.TwipsPerPixelX
    text_height = quote_label.Height / screen.TwipsPerPixelY
    
    balloonPicture.Width = text_width * 1.5' * screen.TwipsPerPixelX
    balloonPicture.Height = text_height * 2.2' * screen.TwipsPerPixelY
    balloonMaskPicture.Width = text_width * 1.5' * screen.TwipsPerPixelX
    balloonMaskPicture.Height = text_height * 2.2' * screen.TwipsPerPixelY
    
    balloonPicture.Cls
    balloonMaskPicture.Cls

    balloonPicture.FillStyle = 0
    balloonPicture.ForeColor = 0
    balloonPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .35, text_height * 2), 7, , , , .6
    balloonPicture.ForeColor = QBColor(7)
    balloonPicture.FillStyle = 1
    balloonPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .35, text_height * 2), 5, , , , .6

    balloonPicture.FillStyle = 0
    balloonPicture.ForeColor = 0
    balloonPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .25, text_height * 1.7), 10, , , , .5
    balloonPicture.ForeColor = QBColor(7)
    balloonPicture.FillStyle = 1
    balloonPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .25, text_height * 1.7), 8, , , , .5
    
    balloonPicture.FillStyle = 0
    balloonMaskPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .25, text_height * 1.7), 10, , , , .5
    balloonMaskPicture.Circle (balloonPicture.Width * .5 - orientation * text_width * .35, text_height * 2), 7, , , , .6
    
    balloonPicture.FillStyle = 0
    balloonMaskPicture.FillStyle = 0
    balloonPicture.ForeColor = 0
    DrawEllipse balloonPicture.hDC, 0, 0, text_width * 1.5, text_height * 1.5
    DrawEllipse balloonMaskPicture.hDC, 0, 0, text_width * 1.5, text_height * 1.5
    balloonPicture.FillStyle = 1
    balloonPicture.ForeColor = QBColor(7)
    DrawEllipse balloonPicture.hDC, 1, 1, text_width * 1.5 - 1, text_height * 1.5 - 1
    
    length_string = Len(temp_quote)
    
    If length_string > 15 Then
        For Index = length_string * .5 To length_string
            If Mid$(temp_quote, Index, 1) = " " Then
                
                balloonPicture.ForeColor = &HC0C0C0
                balloonPicture.CurrentX = text_width * .25 + 2
                balloonPicture.CurrentY = text_height * .25 + 2
                balloonPicture.Print Left$(temp_quote, Index)
                balloonPicture.CurrentX = text_width * .25 + 2
                balloonPicture.Print Right$(temp_quote, length_string - Index)
                
                balloonPicture.ForeColor = 0
                balloonPicture.CurrentX = text_width * .25
                balloonPicture.CurrentY = text_height * .25
                balloonPicture.Print Left$(temp_quote, Index)
                balloonPicture.CurrentX = text_width * .25
                balloonPicture.Print Right$(temp_quote, length_string - Index)
                
                Exit For
            End If
        Next
    Else
                balloonPicture.ForeColor = &HC0C0C0
                balloonPicture.CurrentX = text_width * .25 + 2
                balloonPicture.CurrentY = text_height * .25 + 2
                balloonPicture.Print temp_quote
                balloonPicture.ForeColor = 0
                balloonPicture.CurrentX = text_width * .25
                balloonPicture.CurrentY = text_height * .25
                balloonPicture.Print temp_quote

    End If
    
    
End Sub

Sub Display_MouseDown (Button As Integer, Shift As Integer, x As Single, y As Single)
    
    Dim i As Integer
    Dim minDist As Single: Dim minIndex As Integer
    Dim st As String
    If gameTimer.Enabled Then
        i = 1
        minDist = (player(i).x - x) ^ 2 + (player(i).y - y) ^ 2: minIndex = 1
        For i = 2 To maxPlayer
            If (player(i).x - x) ^ 2 + (player(i).y - y) ^ 2 < minDist Then minDist = (player(i).x - x) ^ 2 + (player(i).y - y) ^ 2: minIndex = i
        Next
        st = "Name: " & player(minIndex).Title
        If player(minIndex).computer Then st = st & "(computer, level " & player(minIndex).computer & ")"
        st = st & Chr$(10) & "Energy: " & player(minIndex).energy & "%"
        MsgBox st, 64, "Robot Information"
    End If
End Sub

Sub exitmenu_Click ()
    End
End Sub

Sub Form_Load ()

    Dim p As Integer
    Dim boardTitle As String
    Dim temp As String
    Dim index1 As Integer, index2 As Integer
    Randomize Timer
    xenon!File_Box.Path = mypath
    If registered Then
        File_Box.Pattern = "*.xe"
        DoEvents
        ReDim NameArray(0 To File_Box.ListCount - 1) As String
        For p = 0 To File_Box.ListCount - 1
            NameArray(p) = File_Box.List(p)
        Next
    Else
        ReDim NameArray(0 To 11) As String
        NameArray(0) = "bridge.xe"
        NameArray(1) = "castle.xe"
        NameArray(2) = "caverns.xe"
        NameArray(3) = "caves.xe"
        NameArray(4) = "city.xe"
        NameArray(5) = "constr.xe"
        NameArray(6) = "crete.xe"
        NameArray(7) = "island.xe"
        NameArray(8) = "pier.xe"
        NameArray(9) = "pyramid.xe"
        NameArray(10) = "suburbs.xe"
        NameArray(11) = "temple.xe"
    End If
    For p = 0 To 50
        index1 = CInt(Rnd * UBound(NameArray))
        index2 = CInt(Rnd * UBound(NameArray))
        temp = NameArray(index1)
        NameArray(index1) = NameArray(index2)
        NameArray(index2) = temp
    Next
    
    File_Box.Pattern = "*.mid"
    DoEvents
    If File_Box.ListCount > 0 Then
        ReDim MidiArray(0 To File_Box.ListCount - 1) As String
        For p = 0 To File_Box.ListCount - 1
            MidiArray(p) = File_Box.List(p)
        Next
        For p = 0 To 50
            index1 = CInt(Rnd * UBound(MidiArray))
            index2 = CInt(Rnd * UBound(MidiArray))
            temp = MidiArray(index1)
            MidiArray(index1) = MidiArray(index2)
            MidiArray(index2) = temp
        Next
        midiok = True
    Else
        midiok = False
    End If
    
    LoadGraphics
    LoadQuotes
    LoadBoard mypath & GetRandomBoardName(), backGroundStyle, board(), boardTitle
    
    Display.Width = screen.TwipsPerPixelX * (boardX + 1) * 16
    Display.Height = screen.TwipsPerPixelY * (boardY + 1) * 16
    BackPanel.Width = Display.Width + screen.TwipsPerPixelX * 16
    BackPanel.Height = Display.Height + screen.TwipsPerPixelX * 16
    Me.Width = Display.Width + screen.TwipsPerPixelX * 18
    Me.Height = Display.Height + screen.TwipsPerPixelY * (55 + 17)
    Me.Move (screen.Width - Me.Width) / 2, (screen.Height - Me.Height) / 2
    
    DrawBackground xenon!BackPicture, backGroundStyle
    MakeForePicture xenon!ForePicture, xenon!BackPicture
    bitblt xenon!Display.hDC, 0, 0, xenon!ForePicture.ScaleWidth, xenon!ForePicture.ScaleHeight, xenon!ForePicture.hDC, 0, 0, copyblt
    DrawScreen xenon!Display, xenon!ForePicture, True

    If registered Then reginfo.Caption = "About " & gameTitle & "..."
  
End Sub

Sub Form_Unload (Cancel As Integer)
    End
End Sub

Sub Gametimer_Timer ()

    Static i As Integer, y As Integer, p As Integer, dx As Single, dy As Single, radX As Single, radY As Single, s As Single, xx As Integer, yy As Integer, fell As Integer, n As Integer, tempPlayer As playerType, times As Integer, q As Single, junk As Integer

    Select Case gamePeriod
        Case "Starting"
            For i = 1 To maxPlayer
                player(i).x = CInt(Rnd * (boardX - 1)) * 16
                player(i).lastDistance(0) = 1000
                player(i).lastDistance(1) = 800
                For y = 2 To boardY
                    If board(player(i).x \ 16, y).style > 0 Or board(player(i).x \ 16 + 1, y).style > 0 Then Exit For
                Next
                player(i).y = (y - 2) * 16
                For p = 1 To i - 1
                    If Abs(player(p).x - player(i).x) \ 16 < boardX * .5 / maxPlayer Then i = i - 1: Exit For
                Next
            Next
            gamePeriod = "Next Player"
        Case "Next Player"
            If moveRequest Then GoTo movemetunnelme
            If bullet.Visible = False And explosion = 0 And balloonLife = 0 Then
                activePlayer = activePlayer + 1
                If activePlayer > maxPlayer Then activePlayer = 1
                If player(activePlayer).computer Then
                    CalculateShot
                    bulletX = player(activePlayer).x + 16: bulletY = player(activePlayer).y - 2
                    xenon!bullet.Move bulletX - 5, bulletY - 5
                    bulletLife = 200
                    q = player(activePlayer).angle / 180 * 3.1415926 + 1.5707
                    bulletdx = -Cos(q) * player(activePlayer).power / 6
                    bulletdy = -Sin(q) * player(activePlayer).power / 6
                    xenon!bullet.Visible = True
                    'set up players to get hit:
                    For i = 1 To maxPlayer
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
                    moveRequest = 0
                    If Rnd > .9 - player(activePlayer).computer / 12 Or player(activePlayer).whohitme Then
                        Select Case CInt(Rnd * 2)
                            Case 0: moveRequest = -16
                            Case 1: moveRequest = 16
                            Case 2: moveRequest = 0
                        End Select
                    End If
                    If moveRequest And player(activePlayer).x + moveRequest + 1 < boardX * 16 And player(activePlayer).x + moveRequest >= 0 Then
                        xx = player(activePlayer).x \ 16
                        yy = player(activePlayer).y \ 16
                
                        If moveRequest > 0 Then
                            If board(xx + 2, yy).style > 0 Or board(xx + 2, yy).whoshere Or board(xx + 2, yy + 1).style > 0 Or board(xx + 2, yy + 1).whoshere Then moveRequest = 0
                        Else
                           If board(xx - 1, yy).style > 0 Or board(xx - 1, yy).whoshere Or board(xx - 1, yy + 1).style > 0 Or board(xx - 1, yy + 1).whoshere Then moveRequest = 0
                        End If
                    Else
                        moveRequest = 0
                    End If
                    gamePeriod = ""
                Else
                    ControlPanel.Show
                    gamePeriod = "Wait"
                End If
                player(activePlayer).whohitme = 0
            End If
            xenon.ZOrder
        Case "Start Falling", "Start Falling Next Player"

            'wipe out blocks that should be falling, start the falling
            lastFallingBlock = 0
            For yy = boardY - 1 To 0 Step -1
                For xx = 0 To boardX
                    If board(xx, yy).style > -1 And board(xx, yy + 1).style = -1 Then
                        If board(xx, yy).style > 0 Then
                            lastFallingBlock = lastFallingBlock + 1
                            fallingBlock(lastFallingBlock).x = xx * 16
                            fallingBlock(lastFallingBlock).y = yy * 16
                            fallingBlock(lastFallingBlock).block = board(xx, yy)
                        Else
                            bitblt Display.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
                        End If
                        bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
                        board(xx, yy).style = -1
                    End If
                Next
            Next
            If gamePeriod = "Start Falling Next Player" Then gamePeriod = "Falling Next Player" Else gamePeriod = "Falling"
        Case "Falling", "Falling Next Player"
            'wipe guys, wipe blocks
            For p = 1 To maxPlayer
                 bitblt Display.hDC, player(p).x, player(p).y, 32, 32, ForePicture.hDC, player(p).x, player(p).y, copyblt
            Next
            For i = 1 To lastFallingBlock
                bitblt Display.hDC, fallingBlock(i).x, fallingBlock(i).y, 16, 16, ForePicture.hDC, fallingBlock(i).x, fallingBlock(i).y, copyblt
            Next
            'move & draw blocks
            'draw blocks
            i = 1
            Do While i <= lastFallingBlock
                p = False
                If fallingBlock(i).y \ 16 + 1 > boardY Then
                    p = True
                Else
                    If board(fallingBlock(i).x \ 16, fallingBlock(i).y \ 16 + 1).style > -1 Then p = True
                End If
                If p Then
                    board(fallingBlock(i).x \ 16, fallingBlock(i).y \ 16) = fallingBlock(i).block
                    bitblt ForePicture.hDC, fallingBlock(i).x, fallingBlock(i).y, 16, 16, xenon!BlockPalette(fallingBlock(i).block.style).hDC, (fallingBlock(i).block.number Mod 20) * 16, (fallingBlock(i).block.number \ 20) * 16, copyblt
                    bitblt Display.hDC, fallingBlock(i).x, fallingBlock(i).y, 16, 16, xenon!BlockPalette(fallingBlock(i).block.style).hDC, (fallingBlock(i).block.number Mod 20) * 16, (fallingBlock(i).block.number \ 20) * 16, copyblt
                    lastFallingBlock = lastFallingBlock - 1
                    For y = i To lastFallingBlock
                        fallingBlock(y) = fallingBlock(y + 1)
                    Next
                Else
                    fallingBlock(i).y = fallingBlock(i).y + 2
                    bitblt Display.hDC, fallingBlock(i).x, fallingBlock(i).y, 16, 16, xenon!BlockPalette(fallingBlock(i).block.style).hDC, (fallingBlock(i).block.number Mod 20) * 16, (fallingBlock(i).block.number \ 20) * 16, copyblt
                    i = i + 1
                End If
            Loop
            fell = False
            For p = 1 To maxPlayer
                yy = player(p).y \ 16 + 2
                If yy - 1 < boardY Then
                    xx = player(p).x \ 16
                    If board(xx, yy).style < 1 And board(xx + 1, yy).style < 1 Then
                        player(p).y = player(p).y + 2: fell = True
                        player(p).wasfalling = True
                    Else
                        If player(p).wasfalling Then
                            If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "land.wav"), SYNC)
                            player(p).wasfalling = False
                        End If
                    End If
                End If
            Next
            If lastFallingBlock = 0 And Not fell Then
                If gamePeriod = "Falling Next Player" Then
                    gamePeriod = "Create Balloon Next Player"
                Else
                    gamePeriod = "Create Balloon"
                End If
            End If
        Case "Create Balloon", "Create Balloon Next Player"
            If explosion = 0 Then
                If gamePeriod = "Create Balloon Next Player" Then
                    gamePeriod = "Next Player"
                Else
                    gamePeriod = ""
                End If
                i = 1
                Do While i <= maxPlayer
                    If player(i).hit = True Then
                        player(i).hit = False
                        If player(i).x > 16 * boardX / 2 Then
                            CreateBalloon -1
                            balloonX = player(i).x - balloonPicture.ScaleWidth + 32
                        Else
                            CreateBalloon 1
                            balloonX = player(i).x
                        End If
                        balloonY = player(i).y - balloonPicture.ScaleHeight
                        balloonLife = 60
                        Exit Do
                    End If
                    i = i + 1
                Loop
            End If
        Case "", "Wait"
movemetunnelme:
            If tunnelRequest And bullet.Visible = False Then
                xx = player(activePlayer).x \ 16
                yy = player(activePlayer).y \ 16
                Select Case tunnelRequest
                    Case 1
                        BoreBoard xx, yy - 1
                        BoreBoard xx + 1, yy - 1
                    Case 2
                        BoreBoard xx - 1, yy
                        BoreBoard xx - 1, yy + 1
                    Case 3
                        BoreBoard xx, yy + 2
                        BoreBoard xx + 1, yy + 2
                    Case 4
                        BoreBoard xx + 2, yy
                        BoreBoard xx + 2, yy + 1
                End Select
                If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "tunnel.wav"), SYNC)
                tunnelRequest = 0
                gamePeriod = "Start Falling"
            ElseIf moveRequest And bullet.Visible = False Then
                If Abs(moveRequest) = 16 And soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "move.wav"), SYNC)
                player(activePlayer).x = player(activePlayer).x + Sgn(moveRequest)
                If moveRequest > 0 Then moveRequest = moveRequest - 1 Else moveRequest = moveRequest + 1
                If moveRequest = 0 Then
                    gamePeriod = "Falling"
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "silence.wav"), SYNC)
                End If
            Else
                If bullet.Visible = False And player(activePlayer).computer Then gamePeriod = "Next Player"
            End If
    End Select

    If balloonLife Then
        balloonLife = balloonLife - 1
        If balloonLife = 0 Then
            bitblt Display.hDC, balloonX, balloonY, balloonPicture.ScaleWidth, balloonPicture.ScaleHeight, ForePicture.hDC, balloonX, balloonY, copyblt
            i = 1
            While i <= maxPlayer
                If player(i).energy < 0 Then 'finish him!
                    bitblt Display.hDC, player(i).x, player(i).y, 32, 32, ForePicture.hDC, player(i).x, player(i).y, copyblt
                    maxPlayer = maxPlayer - 1
                    tempPlayer = player(i)
                    For p = i To maxPlayer
                        player(p) = player(p + 1)
                    Next
                    player(maxPlayer + 1) = tempPlayer
                Else
                    i = i + 1
                End If
            Wend
        End If
    End If

    DrawScreen Display, ForePicture, False
    
    If bullet.Visible Then
        dx = bulletdx / 10
        dy = bulletdy / 10
        s = 5 / Sqr(bulletdx * bulletdx + bulletdy * bulletdy)
        radX = dx * s
        radY = dy * s
        For i = 1 To 10
            bulletX = bulletX + dx
            bulletY = bulletY + dy
            If rebounding_walls Then
                If bulletX + radX > Display.ScaleWidth Then
                    bulletdx = -Abs(bulletdx): dx = -Abs(dx): radX = -Abs(radX)
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "bounce.wav"), SYNC)
                ElseIf bulletX < radX Then
                    bulletdx = Abs(bulletdx): dx = Abs(dx): radX = Abs(radX)
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "bounce.wav"), SYNC)
                End If
                If bulletY + radY > Display.ScaleHeight Then
                    bulletdy = -Abs(bulletdy): dy = -Abs(dy): radY = -Abs(radY)
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "bounce.wav"), SYNC)
                ElseIf bulletY < radY Then
                    bulletdy = Abs(bulletdy): dy = Abs(dy): radY = Abs(radY)
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "bounce.wav"), SYNC)
                 End If
            ElseIf bulletY + radY > Display.ScaleHeight Then
                bullet.Visible = False
                For n = 1 To maxPlayer
                    xx = player(n).x \ 16: yy = player(n).y \ 16
                    board(xx, yy).whoshere = 0
                    board(xx + 1, yy).whoshere = 0
                    board(xx, yy + 1).whoshere = 0
                    board(xx + 1, yy + 1).whoshere = 0
                Next
                If player(activePlayer).computer Then player(activePlayer).lastDistance(0) = player(player(activePlayer).target).x - bulletX + 16
                Exit For
            End If
            
            xx = (bulletX + radX) \ 16: yy = (bulletY + radY) \ 16
            If yy >= 0 And yy <= boardY And xx >= 0 And xx <= boardX Then
                If board(xx, yy).whoshere Then
                    If activePlayer <> board(xx, yy).whoshere Then player(activePlayer).hitTarget = True
                    player(board(xx, yy).whoshere).energy = player(board(xx, yy).whoshere).energy - 15'hit me, baby
                    player(board(xx, yy).whoshere).whohitme = activePlayer
                    player(board(xx, yy).whoshere).hit = True
                    explosion = 5
                    If player(activePlayer).computer Then player(activePlayer).lastDistance(0) = player(player(activePlayer).target).x - bulletX + 16
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "explode.wav"), SYNC)
                    eXCenter = bulletX
                    eYCenter = bulletY
                    StopBullet
                    If gamePeriod = "Next Player" Then gamePeriod = "Create Balloon Next Player" Else gamePeriod = "Create Balloon"
                    Exit For
                ElseIf board(xx, yy).style > 0 Then
                    If board((bulletX + radX) \ 16, (bulletY + radY) \ 16).style <> 2 Then
                        xx = (bulletX + radX) \ 16: yy = (bulletY + radY) \ 16
                        board(xx, yy).style = -1
                        bitblt ForePicture.hDC, xx * 16, yy * 16, 16, 16, BackPicture.hDC, xx * 16, yy * 16, copyblt
                        If gamePeriod = "Next Player" Then gamePeriod = "Start Falling Next Player" Else gamePeriod = "Start Falling"
                    End If
                    StopBullet
                    If player(activePlayer).computer Then player(activePlayer).lastDistance(0) = player(player(activePlayer).target).x - bulletX + 16
                    explosion = 5
                    If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "explode.wav"), SYNC)
                    eXCenter = bulletX
                    eYCenter = bulletY
                    Exit For
                End If
            End If
        Next
        bulletdy = bulletdy + gravity
        bullet.Move bulletX - 5, bulletY - 5
        bulletLife = bulletLife - 1
        If bulletLife < 0 Then
            explosion = 5
            If soundOn Then junk = sndPlaySound(ByVal CStr(mypath & "explode.wav"), SYNC)
            eXCenter = bulletX
            eYCenter = bulletY
            StopBullet
        End If
    End If

    If maxPlayer <= numWinners Then
        gameTimer.Enabled = False
        explosion = 0
        bulletLife = 0
        bullet.Visible = False
        For xx = 0 To boardX
            For yy = 0 To boardY
                board(xx, yy).whoshere = 0
            Next
        Next
        For p = 1 To maxPlayer
            player(p).wins = player(p).wins + 1
        Next
        TheWindowThatComesUpBeforeTheGame.Show 1
    End If

    times = (times + 1) Mod 50
    If times = 0 And MusicOn Then If MMControl1.Mode <> 526 Then NewSong
    
End Sub

Sub LoadGraphics ()

'   loads graphics so that they are really in picture boxes

    Dim i As Integer

    For i = 0 To 4
        RealLoadPicture realGraphic(i), Display, mypath & "xenon" & (i + 1) & ".max"
        'Debug.Print realGraphic(i).Point(0, 0)
    Next
    RealLoadPicture BlockPalette(0), Display, mypath & "transpar.max"
    RealLoadPicture BlockPalette(1), Display, mypath & "normal.max"
    RealLoadPicture explosionGraphic, Display, mypath & "expl1.max"


End Sub

Sub LoadQuotes ()

    On Error GoTo utoh1
    Open mypath & "quotes.txt " For Input As #1
    On Error GoTo 0
    lastQuote = 0

    While Not EOF(1)
        lastQuote = lastQuote + 1
        ReDim Preserve quote(1 To lastQuote) As String
        Line Input #1, quote(lastQuote)
    Wend
    Close #1
Exit Sub
utoh1:
    Open mypath & "quotes.txt" For Output As #2
    Print #2, "Ouch!"
    Close #2
    Resume
End Sub

Sub newgame_Click ()

    If 1 Then
        gameTimer.Enabled = False
        Unload ControlPanel
        OptionsForm.Show 1
    End If

End Sub

Sub NewSong ()

    currentSong = (currentSong + 1) Mod (UBound(MidiArray) + 1)
    MMControl1.Command = "Close"
    MMControl1.FileName = mypath & MidiArray(currentSong)
    MMControl1.Command = "Open"
    MMControl1.Command = "Play"

End Sub

Sub reginfo_Click ()
    If gameTimer.Enabled Then gameTimer.Enabled = False: gameTimer.Tag = "Turn me back on!"
    aboutbox.Show 1
    If gameTimer.Tag = "Turn me back on!" Then gameTimer.Tag = "": gameTimer.Enabled = True
    xenon.ZOrder
End Sub

Sub StopBullet ()
    Dim i As Integer, xx As Integer, yy As Integer

    bullet.Visible = False

    For i = 1 To maxPlayer
        xx = player(i).x \ 16: yy = player(i).y \ 16
        board(xx, yy).whoshere = 0
        board(xx + 1, yy).whoshere = 0
        board(xx, yy + 1).whoshere = 0
        board(xx + 1, yy + 1).whoshere = 0
    Next

End Sub

Function wordWrap$ (text_string As String)

    Dim Index As Integer
    Dim length_string As Integer
    
    length_string = Len(text_string)
    
    If length_string > 15 Then
        For Index = length_string * .5 To length_string
            If Mid$(text_string, Index, 1) = " " Then
                wordWrap = Left$(text_string, Index) & Chr$(13) & Right$(text_string, length_string - Index)
                Exit For
            End If
        Next
    Else
        wordWrap = text_string
    End If

End Function

