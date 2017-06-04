VERSION 2.00
Begin Form NormalBlocks 
   BackColor       =   &H0000FFFF&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Normal Blocks"
   ClientHeight    =   1968
   ClientLeft      =   1164
   ClientTop       =   2184
   ClientWidth     =   2556
   Height          =   2388
   Left            =   1116
   LinkTopic       =   "Form5"
   MaxButton       =   0   'False
   ScaleHeight     =   1968
   ScaleWidth      =   2556
   Top             =   1812
   Width           =   2652
   Begin PictureBox BlockPalette 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   1590
      Left            =   0
      ScaleHeight     =   1596
      ScaleWidth      =   2088
      TabIndex        =   0
      Top             =   0
      Width           =   2085
   End
End

Sub BlockPalette_MouseDown (button As Integer, Shift As Integer, x As Single, y As Single)
    
    If button = 1 Then
        drawBlock(0).style = 1
        drawBlock(0).number = x \ 16 + 20 * (y \ 16)
        Bitblt Xenon!ShowDraw(0).hDC, 0, 0, 16, 16, Xenon!BlockPalette(drawBlock(0).style).hDC, (drawBlock(0).number Mod 20) * 16, (drawBlock(0).number \ 20) * 16, copyblt
        Xenon!ShowDraw(0).Refresh
    Else
        drawBlock(1).style = 1
        drawBlock(1).number = x \ 16 + 20 * (y \ 16)
        Bitblt Xenon!ShowDraw(1).hDC, 0, 0, 16, 16, Xenon!BlockPalette(drawBlock(1).style).hDC, (drawBlock(1).number Mod 20) * 16, (drawBlock(1).number \ 20) * 16, copyblt
        Xenon!ShowDraw(1).Refresh
    End If

End Sub

Sub Form_Load ()

    BlockPalette = LoadPicture(mypath & "normal.max")
    Me.Width = BlockPalette.Width + 2 * screen.TwipsPerPixelX
    Me.Height = BlockPalette.Height + 21 * screen.TwipsPerPixelY
    BlockPalette.ScaleMode = 3

End Sub

