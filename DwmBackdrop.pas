UNIT DwmBackdrop;

{=============================================================================================================
   www.GabrielMoraru.com
   FrostedGlass - the three DWM calls that both forms use. Each one returns the HRESULT, so the caller decides whether to log it.
=============================================================================================================}

INTERFACE

USES
  Winapi.Windows, Winapi.DwmApi, Winapi.UxTheme;

CONST
  { DWM_SYSTEMBACKDROP_TYPE - not declared in Delphi 13 (Winapi.DwmApi.pas).
    The C enumeration has no explicit values, so they are 0..4.
    https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwm_systembackdrop_type }
  DWMSBT_AUTO            = 0;
  DWMSBT_NONE            = 1;
  DWMSBT_MAINWINDOW      = 2;   // Mica
  DWMSBT_TRANSIENTWINDOW = 3;   // Desktop Acrylic
  DWMSBT_TABBEDWINDOW    = 4;   // Mica Alt

function SetBackdrop   (Wnd: HWND; Backdrop: Integer): HRESULT;
function SetExtendFrame(Wnd: HWND; Extend: Boolean): HRESULT;
function SetDarkFrame  (Wnd: HWND; Dark: Boolean): HRESULT;

IMPLEMENTATION


function SetBackdrop(Wnd: HWND; Backdrop: Integer): HRESULT;
VAR Value: Integer;
begin
  Value:= Backdrop;
  Result:= DwmSetWindowAttribute(Wnd, DWMWA_SYSTEMBACKDROP_TYPE, @Value, SizeOf(Value));
end;


{ Margins -1 = "sheet of glass": the frame covers the whole client area. Margins 0 = normal frame. }
function SetExtendFrame(Wnd: HWND; Extend: Boolean): HRESULT;
VAR
  Margins: Winapi.UxTheme.TMargins;
  Size: Integer;
begin
  if Extend
  then Size:= -1
  else Size:= 0;
  Margins.cxLeftWidth   := Size;
  Margins.cxRightWidth  := Size;
  Margins.cyTopHeight   := Size;
  Margins.cyBottomHeight:= Size;
  Result:= DwmExtendFrameIntoClientArea(Wnd, Margins);
end;


function SetDarkFrame(Wnd: HWND; Dark: Boolean): HRESULT;
VAR Value: Integer;   // a 4-byte BOOL: 1 or 0
begin
  Value:= Ord(Dark);
  Result:= DwmSetWindowAttribute(Wnd, DWMWA_USE_IMMERSIVE_DARK_MODE, @Value, SizeOf(Value));
end;


end.
