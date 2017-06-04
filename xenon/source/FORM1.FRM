VERSION 2.00
Begin Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   4404
   ClientLeft      =   876
   ClientTop       =   1524
   ClientWidth     =   4224
   ForeColor       =   &H00FFFF00&
   Height          =   4824
   Left            =   828
   LinkTopic       =   "Form1"
   ScaleHeight     =   4404
   ScaleWidth      =   4224
   Top             =   1152
   Width           =   4320
   Begin PictureBox Picture2 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      ForeColor       =   &H00000000&
      Height          =   1500
      Left            =   192
      ScaleHeight     =   125
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   305
      TabIndex        =   2
      Top             =   1728
      Width           =   3660
   End
   Begin PictureBox Picture1 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      FillColor       =   &H00FFFFFF&
      FillStyle       =   0  'Solid
      ForeColor       =   &H00000000&
      Height          =   1500
      Left            =   192
      ScaleHeight     =   125
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   305
      TabIndex        =   0
      Top             =   144
      Width           =   3660
   End
   Begin Label quote_label 
      AutoSize        =   -1  'True
      Caption         =   "quote_label"
      Height          =   192
      Left            =   192
      TabIndex        =   1
      Top             =   3504
      Width           =   996
   End
End
Option Explicit

Dim temp_quote As String

Sub CreateBalloon (picture As PictureBox, mask As PictureBox)

    Static text_width As Integer
    Static text_height As Integer
    Static index As Integer
    Static length_string As Integer
    
    text_width = quote_label.Width / screen.TwipsPerPixelX
    text_height = quote_label.Height / screen.TwipsPerPixelY
    
    picture.FillStyle = 0
    DrawEllipse picture.hDC, 0, 0, text_width * 1.5, text_height * 1.5
    DrawEllipse mask.hDC, 0, 0, text_width * 1.5, text_height * 1.5
    picture.FillStyle = 1
    picture.ForeColor = QBColor(7)
    DrawEllipse picture.hDC, 1, 1, text_width * 1.5 - 1, text_height * 1.5 - 1
    
    length_string = Len(temp_quote)
    
    If length_string > 15 Then
        For index = length_string * .5 To 1 Step -1
            If Mid$(temp_quote, index, 1) = " " Then
                
                picture.ForeColor = &HC0C0C0
                picture.CurrentX = text_width * .25 + 2
                picture.CurrentY = text_height * .25 + 2
                picture.Print Left$(temp_quote, index)
                picture.CurrentX = text_width * .25 + 2
                picture.Print Right$(temp_quote, length_string - index)
                
                picture.ForeColor = 0
                picture.CurrentX = text_width * .25
                picture.CurrentY = text_height * .25
                picture.Print Left$(temp_quote, index)
                picture.CurrentX = text_width * .25
                picture.Print Right$(temp_quote, length_string - index)
                
                Exit For
            End If
        Next
    End If
    
    picture.FillStyle = 0
    picture.Circle (text_width * .5, text_height * 1.7), 10, , , , .5
    picture.Circle (text_width * .4, text_height * 2), 7, , , , .6
    mask.Circle (text_width * .5, text_height * 1.7), 10, , , , .5
    mask.Circle (text_width * .4, text_height * 2), 7, , , , .6

    picture.FillStyle = 1
    picture.ForeColor = QBColor(7)
    picture.Circle (text_width * .5, text_height * 1.7), 8, , , , .5
    picture.Circle (text_width * .4, text_height * 2), 5, , , , .6
    
    picture.Width = text_width * 1.5 * screen.TwipsPerPixelX
    picture.Height = text_height * 2.2 * screen.TwipsPerPixelY
    mask.Width = text_width * 1.5 * screen.TwipsPerPixelX
    mask.Height = text_height * 2.2 * screen.TwipsPerPixelY
    
End Sub

Sub Form_Load ()

    temp_quote = "Wow! that was close! Too close for comfort."
    quote_label.Caption = wordWrap(temp_quote)
    
    CreateBalloon picture1, picture2

    picture1.Refresh

End Sub

Function wordWrap$ (text_string As String)

    Dim index As Integer
    Dim length_string As Integer
    
    length_string = Len(text_string)
    
    If length_string > 15 Then
        For index = length_string * .5 To 1 Step -1
            If Mid$(text_string, index, 1) = " " Then
                wordWrap = Left$(text_string, index) & Chr$(13) & Right$(text_string, length_string - index)
                Exit For
            End If
        Next
    End If

End Function

