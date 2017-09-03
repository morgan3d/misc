'   Windows GDI API Customized for VB
'
'   Morgan McGuire, 3/18/95-6/25/95
'

Option Explicit

'Blit Operation Constants:
Global Const copyblt& = &HCC0020 ' (DWORD) dest = source
Global Const andblt& = &H8800C6  ' (DWORD) dest = source AND dest
Global Const AndNotBlt& = &H440328    ' (DWORD) dest = source AND (NOT dest )
Global Const XorBlt& = &H660046 ' (DWORD) dest = source XOR dest
Global Const orblt& = &HEE0086    ' (DWORD) dest = source OR dest
Global Const NotCopyBlt& = &H330008

'PolyFillMode Constants:
Global Const PolyFillFast% = 1'Fill polygons based on alternating lines (is fast?)
Global Const PolyFillNormalVector% = 2'Fill Polygons if their 3d Normal is into the screen in a left handed coordinate system

'Background Modes:
Global Const BkTransparent% = 1
Global Const BkOpaque% = 2

Type shadowtype
    hDC As Integer
    bmp As Integer
    prevBmp As Integer
End Type

Type VectorInt2d
    X As Integer
    Y As Integer
End Type

Type bitmap
  bmType As Integer
  bmWidth As Integer
  bmHeight As Integer
  bmWidthBytes As Integer

  bmPlanes As String * 1
  bmBitsPixel As String * 1
  bmBits As Long
End Type

'Bit-Blitting:
Declare Sub bitblt Lib "GDI" Alias "#34" (ByVal DestPicturehDC As Integer, ByVal destX As Integer, ByVal destY As Integer, ByVal DestWidth As Integer, ByVal DestHeight As Integer, ByVal sourcehdc As Integer, ByVal SourceX As Integer, ByVal SourceY As Integer, ByVal BltOperation As Long)
Declare Sub StretchBlt Lib "GDI" Alias "#35" (ByVal DestPicturehDC As Integer, ByVal destX As Integer, ByVal destY As Integer, ByVal DestWidth As Integer, ByVal DestHeight As Integer, ByVal sourcehdc As Integer, ByVal SourceX As Integer, ByVal SourceY As Integer, ByVal sourceWidth As Integer, ByVal sourceheight As Integer, ByVal dwRop&)

'Draw Primatives:
Declare Sub SetBrushOrg Lib "GDI" (ByVal DestPicturehDC As Integer, ByVal X As Integer, ByVal Y As Integer) 'position graphics cursor
Declare Sub DrawLineTo Lib "GDI" Alias "#19" (ByVal DestPicturehDC As Integer, ByVal toX As Integer, ByVal toY As Integer)
Declare Sub DrawPolyLine Lib "GDI" Alias "#37" (ByVal DestPicturehDC As Integer, lpPoints As VectorInt2d, ByVal nCount As Integer)

Declare Sub DrawPolygon Lib "GDI" Alias "#36" (ByVal DestPicturehDC As Integer, Coordinates As VectorInt2d, ByVal numPoints As Integer)
Declare Sub DrawRectangle Lib "GDI" Alias "#27" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer)
Declare Sub DrawRoundRect Lib "GDI" Alias "#28" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer, ByVal X3 As Integer, ByVal Y3 As Integer)

Declare Sub DrawEllipse Lib "GDI" Alias "#24" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer)
Declare Sub DrawChord Lib "GDI" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer, ByVal X3 As Integer, ByVal Y3 As Integer, ByVal X4 As Integer, ByVal Y4 As Integer)
Declare Sub DrawArc Lib "GDI" Alias "#23" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer, ByVal X3 As Integer, ByVal Y3 As Integer, ByVal X4 As Integer, ByVal Y4 As Integer)
Declare Function DrawPie Lib "GDI" (ByVal DestPicturehDC As Integer, ByVal X1 As Integer, ByVal Y1 As Integer, ByVal X2 As Integer, ByVal Y2 As Integer, ByVal X3 As Integer, ByVal Y3 As Integer, ByVal X4 As Integer, ByVal Y4 As Integer) As Integer

'Set Color & Draw Modes:
Declare Function SetBkColor Lib "GDI" (ByVal ObjectWindowhDC As Integer, ByVal RGBColor As Long) As Long
Declare Sub SetTextColor Lib "GDI" (ByVal ObjectWindowhDC As Integer, ByVal RGBColor As Long)
Declare Sub SetROP2 Lib "GDI" (ByVal ObjWindowhDC As Integer, ByVal nDrawMode As Integer) 'set Drawmode:
Declare Sub SetBkMode Lib "GDI" Alias "#2" (ByVal ObjectWindowhDC As Integer, ByVal nBkMode As Integer)
Declare Sub SetPolyFillMode Lib "GDI" Alias "#6" (ByVal ObjectWindowhDC As Integer, ByVal nPolyFillMode As Integer)

'Bitmap Functions:
Declare Function CreateBitmap Lib "GDI" (ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal cbPlanes As Integer, ByVal cbBits As Integer, lpvBits As Any) As Integer
Declare Function CreateCompatibleBitmap Lib "GDI" (ByVal hDC As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer) As Integer

'Device Context Handle Operations:
Declare Function CreateCompatibleDC Lib "GDI" (ByVal hDC As Integer) As Integer
Declare Function DeleteDC Lib "GDI" (ByVal hDC As Integer) As Integer
Declare Function selectObject Lib "GDI" (ByVal hDC As Integer, ByVal hObject As Integer) As Integer
Declare Function DeleteObject Lib "GDI" (ByVal hObject As Integer) As Integer
Declare Function APIGetObject Lib "GDI" Alias "GetObject" (ByVal hObject As Integer, ByVal nCount As Integer, bmp As Any) As Integer

Sub CreateBmp (src As Control, resulthDC As Integer, resultBmp As Integer, prevresultBMP As Integer)
  
  resulthDC = CreateCompatibleDC(src.hDC) 'Create DC to hold stage
  resultBmp = CreateCompatibleBitmap(src.hDC, src.ScaleWidth, src.ScaleHeight)
  prevresultBMP = selectObject(resulthDC, resultBmp) 'Select bitmap

End Sub

Sub CreateCopy (src As Control, resulthDC As Integer, resultBmp As Integer, prevresultBMP As Integer)
  
  Dim temp As shadowtype
  
  CreateShadow src, temp
  
  resulthDC = CreateCompatibleDC(src.hDC) 'Create DC to hold stage
  resultBmp = CreateCompatibleBitmap(src.hDC, src.ScaleWidth, src.ScaleHeight)
  prevresultBMP = selectObject(resulthDC, resultBmp) 'Select bitmap
  bitblt resulthDC, 0, 0, src.ScaleWidth, src.ScaleHeight, temp.hDC, 0, 0, copyblt
  
  DestroyShadow temp

End Sub

Sub CreateMask (maskhdc As Integer, Maskbmp As Integer, prevMaskBmp As Integer, src As Control, dest As Control, transparentcolor As Long)
  
  'creates a monochrome inverted mask (for transparency)
  
  Dim success As Integer
  Dim tempBmp As Integer
  Dim prevTempBmp As Integer
  Dim temphdc As Integer
  Dim OrigColor As Long
  
  src.ScaleMode = 3'pixel

  'allocate memory for mask
  maskhdc = CreateCompatibleDC(dest.hDC)
  Maskbmp = CreateBitmap(src.ScaleWidth, src.ScaleHeight, 1, 1, ByVal 0&)'monochrome bitmap
  prevMaskBmp = selectObject(maskhdc, Maskbmp)

  'make temp=source
  temphdc = CreateCompatibleDC(dest.hDC)
  prevTempBmp = selectObject(temphdc, src.Picture)
  
  OrigColor = SetBkColor(temphdc, transparentcolor)
  bitblt maskhdc, 0, 0, src.ScaleWidth, src.ScaleHeight, temphdc, 0, 0, copyblt
  
  'cleanup
  success = selectObject(temphdc, prevTempBmp)
  success = DeleteDC(temphdc)

End Sub

Sub CreateShadow (src As Control, shadow As shadowtype)
  
  'creates a pointer to a bitmap
  src.ScaleMode = 3'pixel

  'make temp=source
  shadow.hDC = CreateCompatibleDC(src.hDC)
  shadow.prevBmp = selectObject(shadow.hDC, src.Picture)

End Sub

Sub DestroyBmp (maskhdc As Integer, Maskbmp As Integer, prevMaskBmp As Integer)
  
  'cleans up, deleting mask and freeing system resources
  
  Dim success As Integer
  
  success = selectObject(maskhdc, prevMaskBmp)
  success = DeleteObject(Maskbmp)
  success = DeleteDC(maskhdc)

End Sub

Sub DestroyShadow (shadow As shadowtype)
  
  'cleans up, deleting mask and freeing system resources
  
  Dim success As Integer
  
  success = selectObject(shadow.hDC, shadow.prevBmp)
  success = DeleteDC(shadow.hDC)

End Sub

Sub RealLoadPicture (dest As Control, temp As Control, filename As String)

    Dim shadow As shadowtype
    On Error GoTo errh
    'both controls are pictureboxes

    temp.ScaleMode = 3
    temp.AutoSize = True
    temp.BorderStyle = 0
    temp = LoadPicture(filename)
    CreateShadow temp, shadow
    dest.ScaleMode = 3
    dest.AutoRedraw = True
    dest.Height = temp.Height
    dest.Width = temp.Width
    
    dest.AutoRedraw = True
    bitblt dest.hDC, 0, 0, temp.ScaleWidth, temp.ScaleHeight, shadow.hDC, 0, 0, copyblt
    
    dest.Refresh
    DestroyShadow shadow
    On Error GoTo 0
    Exit Sub
errh:
    MsgBox "You must run Xenon from an icon and set the Working Directory to the path with the Xenon files.  Read the file XENON.WRI for full instructions."
End

End Sub

Sub SubtractColor (resulthDC As Integer, src As Control, transparentcolor As Long)
  
  'resulthDC contains result of maskhDC cut from image in src picture control

  Dim success As Long           'holds result
  Dim tempBmp As Integer
  Dim prevTempBmp As Integer
  Dim temphdc As Integer
  
  Dim Maskbmp As Integer        'holds mask
  Dim prevMaskBmp As Integer
  Dim maskhdc As Integer

  Dim sourceBmp As Integer        'holds copy of src
  Dim prevSourceBmp As Integer
  Dim sourcehdc As Integer
  
  src.ScaleMode = 3'pixel
  
  CreateMask maskhdc, Maskbmp, prevMaskBmp, src, src, transparentcolor
  CreateCopy src, sourcehdc, sourceBmp, prevSourceBmp
  CreateBmp src, temphdc, tempBmp, prevTempBmp

  'cut and place result in temp
  bitblt temphdc, 0, 0, src.ScaleWidth, src.ScaleHeight, maskhdc, 0, 0, NotCopyBlt
  bitblt temphdc, 0, 0, src.ScaleWidth, src.ScaleHeight, sourcehdc, 0, 0, andblt
  
  'copy temp to source
  bitblt resulthDC, 0, 0, src.ScaleWidth, src.ScaleHeight, temphdc, 0, 0, copyblt
  
  'cleanup
  DestroyBmp temphdc, tempBmp, prevTempBmp
  DestroyBmp sourcehdc, sourceBmp, prevSourceBmp
  DestroyBmp maskhdc, Maskbmp, prevMaskBmp
  
End Sub

Sub TransparentBlt (dest As Control, ByVal srcBmp As Integer, ByVal destX As Integer, ByVal destY As Integer, ByVal TransColor As Long)
      
      Const PIXEL = 3

      Static destScale As Integer
      Static srcDC As Integer  'source bitmap (color)
      Static saveDC As Integer 'backup copy of source bitmap
      Static maskDC As Integer 'mask bitmap (monochrome)
      Static invDC As Integer  'inverse of mask bitmap (monochrome)
      Static resultDC As Integer 'combination of source bitmap & background
      Static bmp As bitmap 'description of the source bitmap
      Static hResultBmp As Integer 'Bitmap combination of source & background

      Static hSaveBmp As Integer 'Bitmap stores backup copy of source bitmap
      Static hMaskBmp As Integer 'Bitmap stores mask (monochrome)
      Static hInvBmp As Integer  'Bitmap holds inverse of mask (monochrome)
      Static hPrevBmp As Integer 'Bitmap holds previous bitmap selected in DC
      Static hSrcPrevBmp As Integer  'Holds previous bitmap in source DC
      Static hSavePrevBmp As Integer 'Holds previous bitmap in saved DC
      Static hDestPrevBmp As Integer 'Holds previous bitmap in destination DC
      Static hMaskPrevBmp As Integer 'Holds previous bitmap in the mask DC
      Static hInvPrevBmp As Integer  'Holds previous bitmap in inverted mask DC
      Static OrigColor As Long  'Holds original background color from source DC
      Static success As Integer 'Stores result of call to Windows API
      
      destScale = dest.ScaleMode 'Store ScaleMode to restore later
      dest.ScaleMode = PIXEL 'Set ScaleMode to pixels for Windows GDI
      'Retrieve bitmap to get width (bmp.bmWidth) & height (bmp.bmHeight)
      success = APIGetObject(srcBmp, Len(bmp), bmp)
      srcDC = CreateCompatibleDC(dest.hDC)    'Create DC to hold stage
      saveDC = CreateCompatibleDC(dest.hDC)   'Create DC to hold stage
      maskDC = CreateCompatibleDC(dest.hDC)   'Create DC to hold stage
      invDC = CreateCompatibleDC(dest.hDC)    'Create DC to hold stage
      resultDC = CreateCompatibleDC(dest.hDC) 'Create DC to hold stage
      'Create monochrome bitmaps for the mask-related bitmaps:
      hMaskBmp = CreateBitmap(bmp.bmWidth, bmp.bmHeight, 1, 1, ByVal 0&)

      hInvBmp = CreateBitmap(bmp.bmWidth, bmp.bmHeight, 1, 1, ByVal 0&)
      'Create color bitmaps for final result & stored copy of source
      hResultBmp = CreateCompatibleBitmap(dest.hDC, bmp.bmWidth, bmp.bmHeight)
      hSaveBmp = CreateCompatibleBitmap(dest.hDC, bmp.bmWidth, bmp.bmHeight)
      hSrcPrevBmp = selectObject(srcDC, srcBmp)     'Select bitmap in DC
      hSavePrevBmp = selectObject(saveDC, hSaveBmp) 'Select bitmap in DC
      hMaskPrevBmp = selectObject(maskDC, hMaskBmp) 'Select bitmap in DC
      hInvPrevBmp = selectObject(invDC, hInvBmp)    'Select bitmap in DC
      hDestPrevBmp = selectObject(resultDC, hResultBmp) 'Select bitmap
      bitblt saveDC, 0, 0, bmp.bmWidth, bmp.bmHeight, srcDC, 0, 0, copyblt 'Make backup of source bitmap to restore later

      'Create mask: set background color of source to transparent color.
      OrigColor = SetBkColor(srcDC, TransColor)
      bitblt maskDC, 0, 0, bmp.bmWidth, bmp.bmHeight, srcDC, 0, 0, copyblt
      TransColor = SetBkColor(srcDC, OrigColor)
      'Create inverse of mask to AND w/ source & combine w/ background.
      bitblt invDC, 0, 0, bmp.bmWidth, bmp.bmHeight, maskDC, 0, 0, NotCopyBlt
      'Copy background bitmap to result & create final transparent bitmap
      bitblt resultDC, 0, 0, bmp.bmWidth, bmp.bmHeight, dest.hDC, destX, destY, copyblt
      'AND mask bitmap w/ result DC to punch hole in the background by
      'painting black area for non-transparent portion of source bitmap.
      bitblt resultDC, 0, 0, bmp.bmWidth, bmp.bmHeight, maskDC, 0, 0, andblt
      'AND inverse mask w/ source bitmap to turn off bits associated
      'with transparent area of source bitmap by making it black.
      bitblt srcDC, 0, 0, bmp.bmWidth, bmp.bmHeight, invDC, 0, 0, andblt
      'XOR result w/ source bitmap to make background show through.
      bitblt resultDC, 0, 0, bmp.bmWidth, bmp.bmHeight, srcDC, 0, 0, orblt
      bitblt dest.hDC, destX, destY, bmp.bmWidth, bmp.bmHeight, resultDC, 0, 0, copyblt'Display transparent bitmap on backgrnd
      bitblt srcDC, 0, 0, bmp.bmWidth, bmp.bmHeight, saveDC, 0, 0, copyblt'Restore backup of bitmap.
      hPrevBmp = selectObject(srcDC, hSrcPrevBmp) 'Select orig object
      hPrevBmp = selectObject(saveDC, hSavePrevBmp) 'Select orig object
      hPrevBmp = selectObject(resultDC, hDestPrevBmp) 'Select orig object
      hPrevBmp = selectObject(maskDC, hMaskPrevBmp) 'Select orig object
      hPrevBmp = selectObject(invDC, hInvPrevBmp) 'Select orig object
      success = DeleteObject(hSaveBmp)   'Deallocate system resources.
      success = DeleteObject(hMaskBmp)   'Deallocate system resources.
      success = DeleteObject(hInvBmp)    'Deallocate system resources.
      success = DeleteObject(hResultBmp) 'Deallocate system resources.
      success = DeleteDC(srcDC)          'Deallocate system resources.
      success = DeleteDC(saveDC)         'Deallocate system resources.
      success = DeleteDC(invDC)          'Deallocate system resources.
      success = DeleteDC(maskDC)         'Deallocate system resources.
      success = DeleteDC(resultDC)       'Deallocate system resources.
      dest.ScaleMode = destScale 'Restore ScaleMode of destination.
End Sub

