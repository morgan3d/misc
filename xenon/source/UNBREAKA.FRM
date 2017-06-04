VERSION 2.00
Begin Form UnbreakableBlocks 
   BackColor       =   &H0000FFFF&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Unbreakable Blocks"
   ClientHeight    =   1920
   ClientLeft      =   804
   ClientTop       =   1836
   ClientWidth     =   2676
   Height          =   2340
   Left            =   756
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   ScaleHeight     =   1920
   ScaleWidth      =   2676
   Top             =   1464
   Width           =   2772
   Begin PictureBox BlockPalette 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   1500
      Left            =   0
      ScaleHeight     =   1500
      ScaleWidth      =   2136
      TabIndex        =   0
      Top             =   0
      Width           =   2130
   End
End

Sub BlockPalette_MouseDown (button As Integer, Shift As Integer, x As Single, y As Single)
    If button = 1 Then
        drawBlock(0).style = 2
        drawBlock(0).number = x \ 16 + 20 * (y \ 16)
        Bitblt Xenon!ShowDraw(0).hDC, 0, 0, 16, 16, Xenon!BlockPalette(drawBlock(0).style).hDC, (drawBlock(0).number Mod 20) * 16, (drawBlock(0).number \ 20) * 16, copyblt
        Xenon!ShowDraw(0).Refresh
    Else
        drawBlock(1).style = 2
        drawBlock(1).number = x \ 16 + 20 * (y \ 16)
        Bitblt Xenon!ShowDraw(1).hDC, 0, 0, 16, 16, Xenon!BlockPalette(drawBlock(1).style).hDC, (drawBlock(1).number Mod 20) * 16, (drawBlock(1).number \ 20) * 16, copyblt
        Xenon!ShowDraw(1).Refresh
    End If

End Sub

Sub Form_Load ()
    
    BlockPalette = LoadPicture(mypath & "unbreak.max")
    Me.Width = BlockPalette.Width + 2 * screen.TwipsPerPixelX
    Me.Height = BlockPalette.Height + 21 * screen.TwipsPerPixelY
    BlockPalette.ScaleMode = 3

End Sub

