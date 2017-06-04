VERSION 2.00
Begin Form AboutBox 
   BackColor       =   &H00000000&
   BorderStyle     =   0  'None
   ClientHeight    =   4008
   ClientLeft      =   6156
   ClientTop       =   2508
   ClientWidth     =   3096
   Height          =   4428
   Left            =   6108
   LinkTopic       =   "Form1"
   ScaleHeight     =   334
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   258
   Top             =   2136
   Width           =   3192
   Begin PictureBox BackDrop 
      BorderStyle     =   0  'None
      ClipControls    =   0   'False
      Height          =   1260
      Left            =   1632
      ScaleHeight     =   105
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   105
      TabIndex        =   4
      TabStop         =   0   'False
      Top             =   336
      Visible         =   0   'False
      Width           =   1260
   End
   Begin PictureBox Display 
      AutoRedraw      =   -1  'True
      FontBold        =   -1  'True
      FontItalic      =   0   'False
      FontName        =   "MS Serif"
      FontSize        =   7.8
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2892
      Left            =   0
      ScaleHeight     =   239
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   255
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   1080
      Width           =   3084
      Begin SSCommand Next_Inactive 
         Enabled         =   0   'False
         Height          =   192
         Left            =   2544
         Picture         =   ABOUTBOX.FRX:0000
         RoundedCorners  =   0   'False
         TabIndex        =   8
         Top             =   2592
         Visible         =   0   'False
         Width           =   300
      End
      Begin SSCommand Prev_Inactive 
         Enabled         =   0   'False
         Height          =   192
         Left            =   2544
         Picture         =   ABOUTBOX.FRX:04BA
         RoundedCorners  =   0   'False
         TabIndex        =   7
         Top             =   2352
         Visible         =   0   'False
         Width           =   300
      End
      Begin SSCommand Next_Button 
         Height          =   192
         Left            =   2208
         Picture         =   ABOUTBOX.FRX:0974
         RoundedCorners  =   0   'False
         TabIndex        =   6
         Top             =   2592
         Width           =   300
      End
      Begin SSCommand Prev_Button 
         Height          =   192
         Left            =   2208
         Picture         =   ABOUTBOX.FRX:0E2E
         RoundedCorners  =   0   'False
         TabIndex        =   5
         Top             =   2352
         Width           =   300
      End
      Begin CommandButton ok 
         Caption         =   "&Ok"
         Height          =   492
         Left            =   288
         TabIndex        =   1
         Top             =   2352
         Width           =   588
      End
   End
   Begin PictureBox Printed_Text 
      AutoRedraw      =   -1  'True
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Serif"
      FontSize        =   7.8
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   204
      Left            =   336
      ScaleHeight     =   15
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   51
      TabIndex        =   0
      Top             =   336
      Visible         =   0   'False
      Width           =   636
   End
   Begin Timer Timer1 
      Interval        =   40
      Left            =   60
      Top             =   420
   End
   Begin Label Text_Label 
      AutoSize        =   -1  'True
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Serif"
      FontSize        =   7.8
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   195
      Left            =   390
      TabIndex        =   2
      Top             =   90
      Visible         =   0   'False
      Width           =   225
   End
End
Const elasticity = 4

Dim top_text As Integer
Dim v As Single
Dim direction As Integer

Sub Form_Load ()

    Dim success As Integer
    Dim CR As String, j As Integer, hh As Integer: hh = -1
    Dim byte As String * 1200, tt As String
    Dim fileHandle As Integer
    
    CR = Chr$(13)
    
    success = SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, FLAGS)
    
    Width = 257 * screen.TwipsPerPixelX
    Height = 332 * screen.TwipsPerPixelY

    Move (screen.Width - Width) * .5, (screen.Height - Height) * .5
    
    prev_button.Move 190, 196 + 83
    Next_Button.Move 190, 216 + 80
    prev_Inactive.Move 190, 196 + 83
    Next_Inactive.Move 190, 216 + 80
    
    ok.Move 20, 196 + 80
    
    fileHandle = FreeFile
    If registered Then
        Open mypath & "test2.dat" For Binary As #fileHandle
    Else
        Open mypath & "test.dat" For Binary As #fileHandle
    End If

    While Not EOF(fileHandle)
        Get #fileHandle, , byte
        tt = tt + byte
    Wend
    tt = LTrim$(RTrim$(tt))
    i = 1
    text_label.Caption = ""
    While i < Len(tt) - 3
        text_label.Caption = text_label.Caption + Mid$(tt, i, 1)
        If Mid$(tt, i + 1, 3) = "___" Then
            text_label.Caption = text_label.Caption & "_________________________"
            'tt = Left$(tt, i - 1) & "_________________________" & Right$(tt, Len(tt) - i - 2)
            'i = i + Len("_________________________") + 4
            i = i + 3
            If hh = -1 Then
                hh = 0
                While text_label.Height < 280
                    text_label = text_label & CR
                    hh = hh + 1
                Wend
            Else
                For j = 1 To hh
                    text_label = text_label & CR
                Next
            End If
        End If
        i = i + 1
    Wend
    Close #fileHandle
    
    text_label.Caption = gametitle & CR & text_label.Caption
    
    Printed_Text.Width = text_label.Width
    Printed_Text.Height = text_label.Height
    Printed_Text.Print text_label.Caption
    
    RealLoadPicture backdrop, display, mypath & "17x8313.max"
    
    display.Width = Width
    display.Height = Height
    display.Move 0, 0

End Sub

Sub Next_Button_Click ()
    
    v = 47
    direction = 1
    Next_Button.Enabled = False
    prev_button.Enabled = False
    Next_Inactive.Visible = True
    prev_Inactive.Visible = True
    timer1.Enabled = True

End Sub

Sub ok_Click ()
 Unload Me
End Sub

Sub Prev_Button_Click ()

    v = -47
    direction = -1
    Next_Button.Enabled = False
    prev_button.Enabled = False
    Next_Inactive.Visible = True
    prev_Inactive.Visible = True
    timer1.Enabled = True

End Sub

Sub Timer1_Timer ()
    
    
    bitblt display.hDC, 0, 0, display.ScaleWidth, display.ScaleHeight, backdrop.hDC, 0, 0, copyblt
    bitblt display.hDC, 15, 1, 230, 280, Printed_Text.hDC, 0, top_text, andblt
    display.Refresh
    
    If v < -3 Or v > 3 Then
        top_text = top_text + v
        v = v - elasticity * direction
    Else
        timer1.Enabled = False
        v = 0
        If top_text > 0 Then
            prev_button.Enabled = True
            prev_Inactive.Visible = False
        Else
            prev_button.Enabled = False
            prev_Inactive.Visible = True
        End If
        
        Next_Button.Enabled = True
        Next_Inactive.Visible = False
        Next_Button.SetFocus
    
    End If

End Sub

