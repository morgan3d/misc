Option Explicit


Global Const gametitle = "Xenon 1.00 Registered"
Global Const mypath$ = ""'"c:\morgan\projects\xenon\resource\"'"c:\max\xenon\resource\"
Global Const boardX% = 31
Global Const boardY% = 17
Global Const overRide = ""'"c:\morgan\projects\xenon\resource\pipewrks.xe"'"c:\max\xenon\resource\caverns.xe"

Type blockType
    style As Integer
    number As Integer
    WhosHere As Integer
End Type

Global board(0 To boardX, 0 To boardY) As blockType
Global backgroundStyle As Integer
Global boardtitle As String

Sub DrawBackground (BackPicture As Control, n As Integer)

    Const gray& = 256& * 256 + 256 + 1
    
    Dim i As Integer, s As Single
    Dim y As Single, dy As Single, ddy As Single, xx As Integer, yy As Integer
    
    BackPicture.Width = (boardX + 1) * 16 * screen.TwipsPerPixelX
    BackPicture.Height = (boardY + 1) * 16 * screen.TwipsPerPixelY
    BackPicture.ScaleMode = 3
    BackPicture.AutoRedraw = True

    BackPicture.Cls
    Select Case n
        Case 1
            For i = 0 To BackPicture.ScaleHeight Step 5
                s = i / (BackPicture.ScaleHeight + 5)
                BackPicture.Line (0, i)-Step(BackPicture.ScaleWidth, 4), RGB(s * 160 + 50, s * s * s * 200, (1 - s) * 80), BF
                i = i + 5
                s = i / (BackPicture.ScaleHeight + 5)
                BackPicture.Line (0, i)-Step(BackPicture.ScaleWidth, 4), RGB(s * 160 + 50, s * s * s * 200, (1 - s) * 80), BF
            Next
            For i = 1 To 25
                s = Rnd
                BackPicture.PSet (Rnd * Xenon!BackPicture.ScaleWidth, s * s * BackPicture.ScaleHeight * .5), (1 - s) * gray
                s = Rnd
                BackPicture.PSet (Rnd * Xenon!BackPicture.ScaleWidth, s * s * BackPicture.ScaleHeight * .5), (1 - s) * gray
                s = Rnd
                BackPicture.PSet (Rnd * Xenon!BackPicture.ScaleWidth, s * s * BackPicture.ScaleHeight * .5), (1 - s) * gray
                s = Rnd
                BackPicture.PSet (Rnd * Xenon!BackPicture.ScaleWidth, s * s * BackPicture.ScaleHeight * .5), (1 - s) * gray
            Next

        Case 2
            For i = 0 To BackPicture.ScaleHeight Step 5
                s = i / (BackPicture.ScaleHeight + 5)
                BackPicture.Line (0, i)-Step(BackPicture.ScaleWidth, 4), RGB(40 + s * 120, s * 120 + 50, 256), BF
                i = i + 5
                s = i / (BackPicture.ScaleHeight + 5)
                BackPicture.Line (0, i)-Step(BackPicture.ScaleWidth, 4), RGB(40 + s * 120, s * 120 + 50, 256), BF
            Next
            xx = Rnd * ((boardX - 1) * 16 - BackGraphicsFrm!Cloud(0).ScaleWidth)
            yy = Rnd * 100
            bitblt BackPicture.hDC, xx, yy, BackGraphicsFrm!Cloud(0).ScaleWidth, BackGraphicsFrm!Cloud(0).ScaleHeight, BackGraphicsFrm!Cloud(0).hDC, 0, 0, andblt
            bitblt BackPicture.hDC, xx, yy, BackGraphicsFrm!Cloud(0).ScaleWidth, BackGraphicsFrm!Cloud(0).ScaleHeight, BackGraphicsFrm!Cloud(1).hDC, 0, 0, orblt
            
            xx = Rnd * ((boardX - 1) * 16 - BackGraphicsFrm!Cloud(2).ScaleWidth)
            yy = Rnd * 100
            bitblt BackPicture.hDC, xx, yy, BackGraphicsFrm!Cloud(2).ScaleWidth, BackGraphicsFrm!Cloud(2).ScaleHeight, BackGraphicsFrm!Cloud(2).hDC, 0, 0, andblt
            bitblt BackPicture.hDC, xx, yy, BackGraphicsFrm!Cloud(2).ScaleWidth, BackGraphicsFrm!Cloud(2).ScaleHeight, BackGraphicsFrm!Cloud(3).hDC, 0, 0, orblt
            
    End Select
    BackPicture.Refresh

End Sub

'
' Creates a XENON saved board file
'
Sub saveBoard (fileName As String, background As Integer, board() As blockType, boardtitle As String)
    
    Dim fileHandle As Integer
    Dim titleLength As Integer
    Dim byte As String * 1
    Dim x As Integer
    Dim y As Integer, index As Integer
    
    fileHandle = FreeFile
    Open fileName For Binary As #fileHandle
    
    titleLength = Len(boardtitle)
    Put #fileHandle, , titleLength
    For index = 1 To titleLength
        byte = Mid$(boardtitle, index, 1)
        Put #fileHandle, , byte
    Next

    For y = 0 To boardY
        For x = 0 To boardX

            Put #fileHandle, , board(x, y).style
            Put #fileHandle, , board(x, y).number
    
        Next
    Next
    Put #fileHandle, , background
    
    Close #fileHandle

End Sub

'
' Loads a saved XENON board
'
Sub LoadBoard (fileName As String, background As Integer, board() As blockType, boardtitle As String)

    Dim fileHandle As Integer
    Dim titleLength As Integer
    Dim byte As String * 1
    Dim x As Integer
    Dim y As Integer, index As Integer
    
    fileHandle = FreeFile
    If overRide <> "" Then fileName = overRide
    Open fileName For Binary As #fileHandle

    titleLength = Len(boardtitle)
    Get #fileHandle, , titleLength
    boardtitle = ""
    For index = 1 To titleLength
        Get #fileHandle, , byte
        boardtitle = boardtitle + byte
    Next

    For y = 0 To boardY
        For x = 0 To boardX

            Get #fileHandle, , board(x, y).style
            Get #fileHandle, , board(x, y).number
    
        Next
    Next
    Get #fileHandle, , background
    
    Close #fileHandle

End Sub

Sub MakeForePicture (forepicture As Control, BackPicture As Control)

    Dim BackShadow As shadowtype
    Dim x As Integer, y As Integer

    'copy background
    BackPicture.ScaleMode = 3
    forepicture.ScaleMode = 3
    forepicture.Width = BackPicture.Width
    forepicture.Height = BackPicture.Height
    forepicture.AutoRedraw = True
    bitblt forepicture.hDC, 0, 0, forepicture.ScaleWidth, forepicture.ScaleHeight, BackPicture.hDC, 0, 0, copyblt

    For x = 0 To boardX
        For y = 0 To boardY
            If board(x, y).style = -1 Then 'no block

            ElseIf board(x, y).style > 0 Then
                bitblt forepicture.hDC, x * 16, y * 16, 16, 16, Xenon!BlockPalette(board(x, y).style).hDC, (board(x, y).number Mod 20) * 16, (board(x, y).number \ 20) * 16, copyblt
            Else 'transparent
                bitblt forepicture.hDC, x * 16, y * 16, 16, 16, Xenon!BlockPalette(board(x, y).style).hDC, (board(x, y).number Mod 20) * 16, (board(x, y).number \ 20 + 1) * 16, andblt
                bitblt forepicture.hDC, x * 16, y * 16, 16, 16, Xenon!BlockPalette(board(x, y).style).hDC, (board(x, y).number Mod 20) * 16, (board(x, y).number \ 20) * 16, orblt
            End If
        Next
    Next
    
    forepicture.Refresh
 
End Sub

