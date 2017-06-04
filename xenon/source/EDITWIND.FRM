VERSION 2.00
Begin Form Xenon 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Xenon Board Editor"
   ClientHeight    =   4836
   ClientLeft      =   1296
   ClientTop       =   2160
   ClientWidth     =   8436
   Height          =   5580
   Left            =   1248
   LinkTopic       =   "Form3"
   MaxButton       =   0   'False
   ScaleHeight     =   4836
   ScaleWidth      =   8436
   Top             =   1464
   Width           =   8532
   Begin PictureBox BlockPalette 
      ClipControls    =   0   'False
      Height          =   1740
      Index           =   2
      Left            =   4848
      ScaleHeight     =   143
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   141
      TabIndex        =   14
      Top             =   3312
      Visible         =   0   'False
      Width           =   1710
   End
   Begin PictureBox BlockPalette 
      ClipControls    =   0   'False
      Height          =   1740
      Index           =   1
      Left            =   4650
      ScaleHeight     =   143
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   141
      TabIndex        =   13
      Top             =   3210
      Visible         =   0   'False
      Width           =   1710
   End
   Begin PictureBox BlockPalette 
      ClipControls    =   0   'False
      Height          =   1740
      Index           =   0
      Left            =   4380
      ScaleHeight     =   143
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   141
      TabIndex        =   12
      Top             =   3105
      Visible         =   0   'False
      Width           =   1710
   End
   Begin PictureBox ForePicture 
      ClipControls    =   0   'False
      Height          =   1740
      Left            =   3975
      ScaleHeight     =   143
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   141
      TabIndex        =   11
      Top             =   2925
      Visible         =   0   'False
      Width           =   1710
   End
   Begin PictureBox BackPicture 
      ClipControls    =   0   'False
      Height          =   1740
      Left            =   3390
      ScaleHeight     =   143
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   141
      TabIndex        =   10
      Top             =   2640
      Visible         =   0   'False
      Width           =   1710
   End
   Begin PictureBox Display 
      BorderStyle     =   0  'None
      Height          =   3615
      Left            =   0
      ScaleHeight     =   3612
      ScaleWidth      =   7356
      TabIndex        =   7
      Top             =   420
      Width           =   7350
   End
   Begin SSPanel Toolbar 
      Align           =   1  'Align Top
      BackColor       =   &H00C0C0C0&
      Font3D          =   0  'None
      Height          =   420
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   8430
      Begin CommandButton Command1 
         Caption         =   "eraser"
         FontBold        =   0   'False
         FontItalic      =   -1  'True
         FontName        =   "MS Sans Serif"
         FontSize        =   7.8
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   204
         Left            =   5088
         TabIndex        =   15
         Top             =   144
         Width           =   636
      End
      Begin TextBox BoardTitleEdit 
         Height          =   288
         Left            =   480
         TabIndex        =   8
         Text            =   "Xenon"
         Top             =   48
         Width           =   1272
      End
      Begin CommonDialog CommonDialog 
         CancelError     =   -1  'True
         Left            =   7710
         Top             =   15
      End
      Begin ComboBox BackDropDown 
         Height          =   288
         Left            =   2304
         Style           =   2  'Dropdown List
         TabIndex        =   5
         Top             =   48
         Width           =   1596
      End
      Begin PictureBox ShowDraw 
         AutoRedraw      =   -1  'True
         ClipControls    =   0   'False
         Height          =   240
         Index           =   1
         Left            =   4752
         ScaleHeight     =   216
         ScaleWidth      =   264
         TabIndex        =   2
         Top             =   96
         Width           =   285
      End
      Begin PictureBox ShowDraw 
         AutoRedraw      =   -1  'True
         ClipControls    =   0   'False
         Height          =   240
         Index           =   0
         Left            =   4176
         ScaleHeight     =   216
         ScaleWidth      =   264
         TabIndex        =   1
         Top             =   96
         Width           =   285
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Title"
         Height          =   240
         Index           =   3
         Left            =   60
         TabIndex        =   9
         Top             =   90
         Width           =   555
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "Back"
         Height          =   240
         Index           =   2
         Left            =   1776
         TabIndex        =   6
         Top             =   96
         Width           =   540
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "R"
         Height          =   240
         Index           =   1
         Left            =   4560
         TabIndex        =   4
         Top             =   96
         Width           =   264
      End
      Begin Label Label1 
         BackColor       =   &H00C0C0C0&
         Caption         =   "L"
         Height          =   240
         Index           =   0
         Left            =   4032
         TabIndex        =   3
         Top             =   96
         Width           =   180
      End
   End
   Begin Menu filemenu 
      Caption         =   "&File"
      Begin Menu newmenu 
         Caption         =   "&New Board"
      End
      Begin Menu openmenu 
         Caption         =   "&Open Board..."
      End
      Begin Menu savemenu 
         Caption         =   "&Save Board..."
      End
      Begin Menu filesep1 
         Caption         =   "-"
      End
      Begin Menu exitmenu 
         Caption         =   "E&xit"
      End
   End
End
Option Explicit

Sub BackDropDown_Click ()
    DrawScreen
End Sub

Sub Command1_MouseDown (button As Integer, shift As Integer, X As Single, Y As Single)
    If button = 1 Then
        drawBlock(0).style = -1
        ShowDraw(0).Cls
    Else
        drawBlock(1).style = -1
        ShowDraw(1).Cls
    End If

End Sub

Sub Display_MouseDown (button As Integer, shift As Integer, X As Single, Y As Single)
        Dim xx As Integer, yy As Integer, b As Integer


        xx = (X \ 16) * 16
        yy = (Y \ 16) * 16
        If xx > boardX * 16 Then xx = boardX * 16
        If yy > boardY * 16 Then yy = boardY * 16
        If xx < 0 Then xx = 0
        If yy < 0 Then yy = 0
        If button = 1 Then b = 0 Else b = 1
        
        If shift = 2 Then   'grab block
            drawBlock(b) = board(xx \ 16, yy \ 16)
            If drawBlock(b).style = -1 Then
                ShowDraw(b).Cls
            Else
                Bitblt Xenon!ShowDraw(b).hDC, 0, 0, 16, 16, Xenon!BlockPalette(drawBlock(b).style).hDC, (drawBlock(b).number Mod 20) * 16, (drawBlock(b).number \ 20) * 16, copyblt
            End If
            Xenon!ShowDraw(b).Refresh
        Else
            If drawBlock(b).style = -1 Then
                'erase block
                Bitblt display.hDC, xx, yy, 16, 16, backpicture.hDC, xx, yy, copyblt
            ElseIf drawBlock(b).style = 0 Then 'transparent block
                Bitblt display.hDC, xx, yy, 16, 16, BlockPalette(drawBlock(b).style).hDC, (drawBlock(b).number Mod 20) * 16, (drawBlock(b).number \ 20 + 1) * 16, andblt
                Bitblt display.hDC, xx, yy, 16, 16, BlockPalette(drawBlock(b).style).hDC, (drawBlock(b).number Mod 20) * 16, (drawBlock(b).number \ 20) * 16, orblt
            Else 'other
                Bitblt display.hDC, xx, yy, 16, 16, BlockPalette(drawBlock(b).style).hDC, (drawBlock(b).number Mod 20) * 16, (drawBlock(b).number \ 20) * 16, copyblt
            End If
            display.Refresh
            board(xx \ 16, yy \ 16) = drawBlock(b)
        End If

End Sub

Sub Display_MouseMove (button As Integer, shift As Integer, X As Single, Y As Single)
    If button Then Display_MouseDown button, shift, X, Y
End Sub

Sub exitmenu_Click ()

    End

End Sub

Sub Form_Load ()

    Load BackGraphicsFrm
    LoadGraphics
    
    TransparentBlocks.Show
    UnbreakableBlocks.Show
    ShowDraw(0).Width = screen.TwipsPerPixelX * 18
    ShowDraw(0).Height = screen.TwipsPerPixelY * 18
    ShowDraw(1).Width = screen.TwipsPerPixelX * 18
    ShowDraw(1).Height = screen.TwipsPerPixelY * 18

    NormalBlocks.Show
    backdropdown.AddItem "Sunset"
    backdropdown.AddItem "Afternoon"
    backdropdown.ListIndex = 1

    newmenu_click
    
    display.Width = (boardX + 1) * screen.TwipsPerPixelX * 16
    display.Height = (boardY + 1) * screen.TwipsPerPixelY * 16
    Me.Width = display.Width + 2
    Me.Height = display.Height + (21 + 40) * screen.TwipsPerPixelY + toolbar.Height
    Me.Move (screen.Width - Me.Width) * .5, (screen.Height - Me.Height) * .5
    
    drawBlock(0).style = -1
    drawBlock(1).style = -1
    
    DrawScreen
    
End Sub

Sub Form_Unload (Cancel As Integer)
    End
End Sub

Sub LoadGraphics ()
'   loads graphics so that they are really in picture boxes
    
    Dim i As Integer

    display.AutoRedraw = True
    
    RealLoadPicture BlockPalette(0), display, mypath & "transpar.max"
    RealLoadPicture BlockPalette(1), display, mypath & "normal.max"
    RealLoadPicture BlockPalette(2), display, mypath & "unbreak.max"
    

End Sub

Sub newmenu_click ()
    
    Dim X As Integer, Y As Integer

    For X = 0 To boardX
        For Y = 0 To boardY
            board(X, Y).style = -1
        Next
    Next
    backdropdown.ListIndex = 0
    boardtitleedit = "Xenon"
    DrawScreen

End Sub

Sub openmenu_Click ()

    Dim Action As Integer
    Dim boardTitle As String
    Dim backgroundStyle As Integer
    
    Action = 1
    On Error GoTo openCancel

    commonDialog.InitDir = Left$(mypath, Len(mypath) - 1)
    commonDialog.Filter = "Xenon Files (*.xe)|*.xe|All Files (*.*)|*.*|"
    commonDialog.Action = Action
    
    On Error GoTo 0
    
    If Action = 1 Then
        loadBoard CStr(commonDialog.Filename), backgroundStyle, board(), boardTitle
        boardtitleedit.Text = RTrim$(boardTitle)
        backdropdown.ListIndex = backgroundStyle - 1
        DrawScreen
    End If

    Exit Sub

openCancel:

    Action = 0
    Resume

End Sub

Sub savemenu_Click ()
    
    Dim Action As Integer
    
    Action = 2
    On Error GoTo saveCancel

    commonDialog.InitDir = Left$(mypath, Len(mypath) - 1)
    commonDialog.Filter = "Xenon Files (*.xe)|*.xe|All Files (*.*)|*.*|"
    commonDialog.Action = Action
    
    On Error GoTo 0
    
    If Action = 2 Then
        saveBoard CStr(commonDialog.Filename), CInt(backdropdown.ListIndex) + 1, board(), LTrim$(RTrim$(boardtitleedit.Text))
    End If

    Exit Sub

saveCancel:

    Action = 0
    Resume

End Sub

