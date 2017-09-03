Option Explicit
Declare Function SetWindowPos Lib "user" (ByVal h%, ByVal hb%, ByVal x%, ByVal y%, ByVal cx%, ByVal cy%, ByVal f%) As Integer
Declare Function sndPlaySound Lib "MMSystem" (lpsound As Any, ByVal flag As Integer) As Integer

Global Const SYNC = 1
Global Const registered% = True'False'True'
Global Const SWP_NOMOVE = 2
Global Const SWP_NOSIZE = 1
Global Const FLAGS = SWP_NOMOVE Or SWP_NOSIZE
Global Const HWND_TOPMOST = -1
Global Const HWND_NOTOPMOST = -2
Global midiok As Integer

Type fallingBlockType
    block As blockType
    x As Integer
    y As Integer
End Type

Type playerType
    title As String * 20
    computer As Integer
    energy As Integer
    power As Integer
    angle As Integer
    x As Integer
    y As Integer
    graphic As Integer
    hit As Integer
    wins As Integer
    wasfalling As Integer
    target As Integer
    lastDistance(0 To 1) As Integer
    hitTarget As Integer
    whohitme As Integer
End Type

Global Const maxFallingBlock% = (boardX + 1) * (boardY + 1)
Global fallingBlock(1 To maxFallingBlock) As fallingBlockType
Global lastFallingBlock As Integer

Global oldMaxPlayer As Integer
Global ActivePlayer As Integer
Global maxPlayer As Integer
Global NumWinners As Integer
Global player() As playerType
Global namearray() As String
Global MIDIarray() As String
Global soundOn As Integer
Global musicOn As Integer

Global balloonX As Integer
Global balloonY As Integer
Global balloonLife As Integer


Global rebounding_walls As Integer   'rebounding walls flag

Global moveRequest As Integer
Global tunnelRequest As Integer
Global tunneling As Integer
Global nameindex As Integer
Global bulletX As Single
Global bulletY As Single
Global bulletdy As Single
Global bulletdx As Single
Global bulletlife As Integer
Global gravity As Single

Global gamePeriod As String
Global oldControlX As Long
Global oldControlY As Long

Global explosion As Integer
Global eXCenter As Integer
Global eYCenter As Integer
Global CurrentSong As Integer

Global quote() As String
Global lastQuote As Integer

Sub CalculateShot ()
    Const PI = 3.141592

    Dim dy As Single, dx As Single, target As Integer, angle As Single, timeout As Integer, bigTimeout As Integer, velocity As Integer
    
    bigTimeout = 0

calcagain:
    Do While bigTimeout < 10 * player(ActivePlayer).computer
        bigTimeout = bigTimeout + 1
        velocity = Rnd * 85 + 15
        
        Do
            target = CInt(Rnd * (maxPlayer - 1)) + 1
        Loop While target = ActivePlayer
        player(ActivePlayer).target = target
    
        dx = player(target).x - player(ActivePlayer).x
        dy = player(target).y - player(ActivePlayer).y
        'fix angle
        If (Not player(ActivePlayer).hitTarget) Or (Rnd > player(ActivePlayer).computer * .09 + .36) Then
            angle = (90 - player(ActivePlayer).angle) / 180 * PI + Rnd * .1 - .05
            If Sgn(Cos(angle)) = dx And player(ActivePlayer).computer > 3 And Abs(player(ActivePlayer).lastDistance(0)) <= Abs(player(ActivePlayer).lastDistance(1)) And Rnd > .08 Then
                'close in for the kill
                angle = (90 - player(ActivePlayer).angle) / 180 * PI + Rnd * .1 - .05
                If dx > 0 Then
                    'shooting to the right
                    If player(ActivePlayer).lastDistance(0) < 0 Then
                        'overshot
                        If angle < PI / 4 Then
                            angle = angle - .5
                        Else
                            angle = angle + .5
                        End If
                    Else
                        'undershot
                        If angle < PI / 4 Then
                            angle = angle + .5
                        Else
                            angle = angle - .5
                        End If
                    End If
                Else
                    'shooting to the left
                    If player(ActivePlayer).lastDistance(0) < 0 Then
                        'undershot
                        If angle > 3 * PI / 4 Then
                            angle = angle - .5
                        Else
                            angle = angle + .5
                        End If
                    Else
                        'over
                        If angle > 3 * PI / 4 Then
                            angle = angle + .5
                        Else
                            angle = angle - .5
                        End If
                    End If
                End If
            Else
                timeout = 0
                Do
                    angle = Rnd * PI
                    timeout = timeout + 1
                Loop While (Sgn(Cos(angle)) <> Sgn(dx) Or Abs(PI / 2 - angle) < .1) And timeout < 5 * player(ActivePlayer).computer
            End If
        Else
            GoTo goforit
        End If
        
        If angle < 0 Then angle = 0
        If angle > PI Then angle = PI

        player(ActivePlayer).lastDistance(1) = player(ActivePlayer).lastDistance(0)
        If Rnd > .5 Then
            velocity = 80
            Exit Do
        End If
        If (dy - Tan(angle) * dx) * Cos(angle) ^ 2 > .1 Then
            velocity = 2 * Sqr((gravity * dx ^ 2) / (2 * Cos(angle) ^ 2 * (dy - Tan(angle) * dx)))
            If velocity > 90 + player(ActivePlayer).computer * 7 Then velocity = 90 + player(ActivePlayer).computer * 7
            If velocity < 15 Then velocity = 15
            Exit Do
        End If
    Loop
    player(ActivePlayer).angle = 90 - (angle / PI) * 180
    player(ActivePlayer).power = velocity

goforit:
    player(ActivePlayer).hitTarget = False

    Select Case player(ActivePlayer).computer
        Case 3, 4
            If player(ActivePlayer).power < 30 Then player(ActivePlayer).power = 30
        Case 5
            If player(ActivePlayer).power < 35 Then player(ActivePlayer).power = 35
            If Abs(player(ActivePlayer).angle) < 15 And bigTimeout < 45 Then GoTo calcagain
    End Select
    
End Sub

Sub DrawScreen (Display As Control, forepicture As Control, force As Integer)

    Static frameTimer As Integer, pframe As Integer
    Static frame As Integer, p As Integer, i As Integer
    
    frameTimer = (frameTimer + 1) Mod 16
    If (frameTimer Mod 2) = 0 Or force Then
        frame = frameTimer / 2
        If explosion Then
            Select Case explosion
                Case 5
                    bitblt Display.hDC, eXCenter - 8, eYCenter - 10, 16, 20, forepicture.hDC, eXCenter - 8, eYCenter - 10, copyblt
                Case 4
                    bitblt Display.hDC, eXCenter - 18, eYCenter - 20, 36, 40, forepicture.hDC, Display.hDC, eXCenter - 18, copyblt
                Case 3
                    bitblt Display.hDC, eXCenter - 28, eYCenter - 30, 56, 60, forepicture.hDC, eXCenter - 28, eYCenter - 30, copyblt
                Case 2
                    bitblt Display.hDC, eXCenter - 32, eYCenter - 34, 64, 68, forepicture.hDC, eXCenter - 32, eYCenter - 34, copyblt
                Case 1
                    bitblt Display.hDC, eXCenter - 40, eYCenter - 40, 80, 80, forepicture.hDC, eXCenter - 40, eYCenter - 40, copyblt
                    explosion = 0
            End Select
        End If
        For i = 1 To lastFallingBlock
            bitblt Display.hDC, fallingBlock(i).x, fallingBlock(i).y, 16, 16, xenon!BlockPalette(fallingBlock(i).block.style).hDC, (fallingBlock(i).block.number Mod 20) * 16, (fallingBlock(i).block.number \ 20) * 16, copyblt
        Next
        For p = 1 To maxPlayer
            pframe = (frame + p * 2) Mod 8
            If gamePeriod <> "Falling" And gamePeriod <> "Falling Next Player" Then bitblt Display.hDC, player(p).x - 4, player(p).y, 40, 32, forepicture.hDC, player(p).x - 4, player(p).y, copyblt
            bitblt Display.hDC, player(p).x, player(p).y, 32, 32, xenon!RealGraphic(player(p).graphic).hDC, 32, pframe * 32, andblt
            bitblt Display.hDC, player(p).x, player(p).y, 32, 32, xenon!RealGraphic(player(p).graphic).hDC, 0, pframe * 32, orblt
        Next

        If explosion Then
            Select Case explosion
                Case 6
                    bitblt Display.hDC, eXCenter - 8, eYCenter - 10, 16, 20, xenon!explosionGraphic.hDC, 8, 52, orblt
                Case 5
                    bitblt Display.hDC, eXCenter - 18, eYCenter - 20, 36, 40, xenon!explosionGraphic.hDC, 32, 44, orblt
                Case 4
                    bitblt Display.hDC, eXCenter - 28, eYCenter - 30, 56, 60, xenon!explosionGraphic.hDC, 84, 32, orblt
                Case 3
                    bitblt Display.hDC, eXCenter - 32, eYCenter - 34, 64, 68, xenon!explosionGraphic.hDC, 152, 28, orblt
                Case 2
                    bitblt Display.hDC, eXCenter - 40, eYCenter - 40, 80, 80, xenon!explosionGraphic.hDC, 228, 24, orblt
            End Select
            explosion = explosion - 1
        End If
        If balloonLife Then
            bitblt Display.hDC, balloonX, balloonY, xenon!BalloonPicture.ScaleWidth, xenon!BalloonPicture.ScaleHeight, xenon!BalloonMaskPicture.hDC, 0, 0, andblt
            bitblt Display.hDC, balloonX, balloonY, xenon!BalloonPicture.ScaleWidth, xenon!BalloonPicture.ScaleHeight, xenon!BalloonPicture.hDC, 0, 0, orblt
        End If
        Display.Refresh
    End If
    

End Sub

Function GetRandomBoardName$ ()

    GetRandomBoardName = namearray(nameindex)
    nameindex = (nameindex + 1) Mod (UBound(namearray) + 1)

End Function

Sub main ()

    Randomize Timer

    Load BackGraphicsFrm
    xenon.Show
    If Not registered Then aboutbox.Show 1: xenon.ZOrder  Else intro.Show

End Sub

