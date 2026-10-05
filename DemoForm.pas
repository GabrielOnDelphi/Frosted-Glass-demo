UNIT DemoForm;

{=============================================================================================================
   www.GabrielMoraru.com
   FrostedGlass - an empty window with the same backdrop as the main form.
   The main form is full of controls, so little of its glass is visible. This window has no controls, so the whole client area shows the backdrop.
   The main form owns this window and pushes every switch to it (TfrmMain.SyncDemo).
=============================================================================================================}

INTERFACE

USES
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  LightVcl.Visual.AppDataForm;

type
  TfrmDemo = class(TLightForm)
  private
    procedure LogFailure(CONST CallName: string; HR: HRESULT);
  protected
    procedure CreateWnd; override;
  public
    { The DWM state, set by the main form. A switch that was never touched keeps the Windows default. }
    Backdrop: Integer;
    BackdropSet: Boolean;
    ExtendFrame: Boolean;
    DarkFrame: Boolean;
    procedure ApplyDwm;
  end;


IMPLEMENTATION {$R *.dfm}

USES
  LightCore.AppData, DwmBackdrop;


{ Only a failure is logged: the main form's status memo already shows the result of the same call on the main window. }
procedure TfrmDemo.LogFailure(CONST CallName: string; HR: HRESULT);
begin
  if HR <> S_OK
  then AppDataCore.LogWarn('frmDemo: ' + CallName + ' -> HRESULT $' + IntToHex(Cardinal(HR), 8) + '  (' + SysErrorMessage(Cardinal(HR)) + ')');
end;


{ Dark frame is also sent when FALSE, so that unchecking the switch on the main form turns it off here too.
  Extend frame FALSE (margins 0) is not sent while the VCL GlassFrame is on: GlassFrame owns the margins then.
  The backdrop is sent only after the user picked one. }
procedure TfrmDemo.ApplyDwm;
begin
  if NOT HandleAllocated then EXIT;
  if BackdropSet
  then LogFailure('SetBackdrop', SetBackdrop(Handle, Backdrop));
  if ExtendFrame OR NOT GlassFrame.Enabled
  then LogFailure('SetExtendFrame', SetExtendFrame(Handle, ExtendFrame));
  LogFailure('SetDarkFrame', SetDarkFrame(Handle, DarkFrame));
end;


{ A VCL style change recreates the window handle, and DWM attributes belong to the old handle. }
procedure TfrmDemo.CreateWnd;
begin
  inherited CreateWnd;
  if BackdropSet OR ExtendFrame OR DarkFrame
  then ApplyDwm;
end;


end.
