UNIT MainForm;

{=============================================================================================================
   www.GabrielMoraru.com
   FrostedGlass - throwaway test app for the Windows 11 system backdrop (Mica / Acrylic) on a VCL form.
   Every switch is applied at run time and the HRESULT of every DWM call is shown in the status memo.
   What each switch does and the Microsoft sources: ReadMe.md beside this file.
=============================================================================================================}

INTERFACE

USES
  Winapi.Windows, Winapi.Messages, Winapi.UxTheme,
  System.SysUtils, System.Classes, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Themes,
  LightVcl.Visual.AppDataForm, DemoForm;

CONST
  WM_SHOWLOG = WM_USER + 101;

  StylesSubFolder = 'Styles';   // put any *.vsf VCL style files in this folder, next to the EXE

type
  TfrmMain = class(TLightForm)
    pnlControls: TPanel;
    rgBackdrop: TRadioGroup;
    chkExtendFrame: TCheckBox;
    chkBlackClient: TCheckBox;
    chkDarkFrame: TCheckBox;
    lblStyle: TLabel;
    cmbStyle: TComboBox;
    chkStyleBorder: TCheckBox;
    chkStyleClient: TCheckBox;
    lblStatus: TLabel;
    mmoStatus: TMemo;
    lblSample: TLabel;
    pnlParentBg: TPanel;
    pnlOpaque: TPanel;
    btnSample: TButton;
    edtSample: TEdit;
    chkSample: TCheckBox;
    mmoSample: TMemo;
    lstSample: TListBox;
    lblSampleText: TLabel;
    chkWhiteText: TCheckBox;
    chkDarkTheme: TCheckBox;
    chkGlassFrame: TCheckBox;
    lblSample2: TLabel;
    chkNoCaption1: TCheckBox;
    lblNoCaption1: TLabel;
    chkNoCaption2: TCheckBox;
    lblNoCaption2: TLabel;
    rbNoCaption1: TRadioButton;
    lblRbNoCaption1: TLabel;
    rbNoCaption2: TRadioButton;
    lblRbNoCaption2: TLabel;
    rgSample: TRadioGroup;
    rbSample: TRadioButton;
    btnShowDemo: TButton;
    procedure rgBackdropClick(Sender: TObject);
    procedure chkWhiteTextClick(Sender: TObject);
    procedure chkDarkThemeClick(Sender: TObject);
    procedure chkGlassFrameClick(Sender: TObject);
    procedure lblNoCaptionClick(Sender: TObject);
    procedure chkExtendFrameClick(Sender: TObject);
    procedure chkBlackClientClick(Sender: TObject);
    procedure chkDarkFrameClick(Sender: TObject);
    procedure cmbStyleChange(Sender: TObject);
    procedure chkStyleElementsClick(Sender: TObject);
    procedure btnShowDemoClick(Sender: TObject);
  private
    FDemo: TfrmDemo;              // the empty see-through window; owned by this form
    FLog: TStringList;
    FStyleFiles: TStringList;     // full path of each .vsf; index = cmbStyle.ItemIndex - 1
    FBackdropSet: Boolean;        // FALSE until the user picks a backdrop: the window keeps the Windows default
    FBackdrop: Integer;
    FExtendFrame: Boolean;
    FDarkFrame: Boolean;
    procedure Log(CONST Msg: string);
    procedure LogHR(CONST CallName: string; HR: HRESULT);
    procedure ApplyBackdrop;
    procedure ApplyExtendFrame;
    procedure ApplyDarkFrame;
    procedure ApplyAllDwm;
    procedure ApplyDarkThemeToButtons;
    procedure ApplyRestoredState;
    procedure SyncDemo;
    procedure LoadStyleList;
    function  StyleRegistered(CONST StyleName: string): Boolean;
    procedure WMShowLog(var Msg: TMessage); message WM_SHOWLOG;
  protected
    procedure CreateWnd; override;
  public
    destructor Destroy; override;
    procedure LoadForm; override;
    procedure FormPostInitialize; override;
  end;


IMPLEMENTATION {$R *.dfm}

USES
  LightCore.AppData, LightVcl.Visual.AppData, DwmBackdrop;


destructor TfrmMain.Destroy;
begin
  FreeAndNil(FStyleFiles);
  FreeAndNil(FLog);
  inherited Destroy;
end;


{ TAppData.CreateMainForm calls LoadForm right after the form is created, long before FormPostInitialize (LightVcl.Visual.AppData.pas).
  The style combo box must hold its items BEFORE the INI restores its ItemIndex, so the list is filled here. }
procedure TfrmMain.LoadForm;
begin
  LoadStyleList;
  inherited LoadForm;
end;


procedure TfrmMain.FormPostInitialize;
begin
  inherited FormPostInitialize;
  Log(Format('Windows %d.%d build %d', [TOSVersion.Major, TOSVersion.Minor, TOSVersion.Build]));
  if TOSVersion.Build < 22621
  then Log('Build < 22621: DWMWA_SYSTEMBACKDROP_TYPE is not supported on this Windows.');
  if FStyleFiles = NIL
  then LoadStyleList;   // LoadForm did not run (AutoState = asNone)
  ApplyRestoredState;
  btnShowDemoClick(NIL);   // open the see-through window at start-up
end;


{ LoadForm restored the controls, but it fires a control's OnClick only when the INI value differs from the DFM value (LightVcl.Common.IniFile.pas, header), and setting ItemIndex never fires OnChange.
  So every setting is applied once more here, from the restored control values. }
procedure TfrmMain.ApplyRestoredState;
VAR Elements: TStyleElements;
begin
  Log('Applying the restored state...');

  if cmbStyle.ItemIndex < 0          // the INI held an index that the Styles folder no longer has
  then cmbStyle.ItemIndex:= 0;

  // VCL style first: it recreates the window handle (CreateWnd then re-applies whatever DWM setting is already on)
  if cmbStyle.ItemIndex > 0
  then cmbStyleChange(cmbStyle);

  Elements:= StyleElements;
  if chkStyleBorder.Checked then Include(Elements, seBorder) else Exclude(Elements, seBorder);
  if chkStyleClient.Checked then Include(Elements, seClient) else Exclude(Elements, seClient);
  StyleElements:= Elements;

  if chkBlackClient.Checked then Color:= clBlack      else Color:= clBtnFace;
  if chkWhiteText.Checked   then Font.Color:= clWhite else Font.Color:= clWindowText;
  Log('Form Color = ' + ColorToString(Color) + ',  Font.Color = ' + ColorToString(Font.Color));

  FBackdropSet:= rgBackdrop.ItemIndex >= 0;
  if FBackdropSet
  then FBackdrop:= rgBackdrop.ItemIndex;
  FExtendFrame:= chkExtendFrame.Checked;
  FDarkFrame  := chkDarkFrame.Checked;
  ApplyAllDwm;

  if chkGlassFrame.Checked then chkGlassFrameClick(chkGlassFrame);
  if chkDarkTheme.Checked  then ApplyDarkThemeToButtons;
end;



{-------------------------------------------------------------------------------------------------------------
   LOG
   The memo is filled through a posted message, so Log can be called from CreateWnd (while the window and its children are being recreated) without touching the memo's handle there.
-------------------------------------------------------------------------------------------------------------}
procedure TfrmMain.Log(CONST Msg: string);
begin
  if FLog = NIL
  then FLog:= TStringList.Create;
  FLog.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + Msg);
  if HandleAllocated
  then PostMessage(Handle, WM_SHOWLOG, 0, 0);
end;


procedure TfrmMain.LogHR(CONST CallName: string; HR: HRESULT);
begin
  if HR = S_OK
  then Log(CallName + ' -> S_OK')
  else Log(Format('%s -> HRESULT $%.8x  (%s)', [CallName, Cardinal(HR), SysErrorMessage(Cardinal(HR))]));
end;


procedure TfrmMain.WMShowLog(var Msg: TMessage);
begin
  if FLog = NIL then EXIT;
  mmoStatus.Lines.Assign(FLog);
  mmoStatus.SelStart:= Length(mmoStatus.Text);
  SendMessage(mmoStatus.Handle, EM_SCROLLCARET, 0, 0);
end;



{-------------------------------------------------------------------------------------------------------------
   DWM
-------------------------------------------------------------------------------------------------------------}
procedure TfrmMain.ApplyBackdrop;
begin
  LogHR(Format('DwmSetWindowAttribute(DWMWA_SYSTEMBACKDROP_TYPE, %d)', [FBackdrop]),
        SetBackdrop(Handle, FBackdrop));
end;


procedure TfrmMain.ApplyExtendFrame;
begin
  LogHR(Format('DwmExtendFrameIntoClientArea(margins %d)', [-Ord(FExtendFrame)]),
        SetExtendFrame(Handle, FExtendFrame));
end;


procedure TfrmMain.ApplyDarkFrame;
begin
  LogHR(Format('DwmSetWindowAttribute(DWMWA_USE_IMMERSIVE_DARK_MODE, %d)', [Ord(FDarkFrame)]),
        SetDarkFrame(Handle, FDarkFrame));
end;


{ The see-through window copies every switch of this form that changes the glass: backdrop, extend frame, dark frame, client color and the VCL GlassFrame.
  The VCL style needs no copy: TStyleManager.SetStyle applies to every form of the application. }
procedure TfrmMain.SyncDemo;
begin
  if FDemo = NIL then EXIT;
  FDemo.Color:= Color;
  FDemo.GlassFrame.SheetOfGlass:= TRUE;
  FDemo.GlassFrame.Enabled:= chkGlassFrame.Checked;
  FDemo.Backdrop   := FBackdrop;
  FDemo.BackdropSet:= FBackdropSet;
  FDemo.ExtendFrame:= FExtendFrame;
  FDemo.DarkFrame  := FDarkFrame;
  FDemo.ApplyDwm;
end;


procedure TfrmMain.btnShowDemoClick(Sender: TObject);
begin
  if FDemo = NIL
  then AppData.CreateForm(TfrmDemo, FDemo, TRUE, asPosOnly, Self)   // Owner = Self: freed together with this form
  else FDemo.Show;
  SyncDemo;
end;


{ Applies only what the user has switched on: a switch that was never touched keeps the Windows default. }
procedure TfrmMain.ApplyAllDwm;
begin
  if FBackdropSet then ApplyBackdrop;
  if FExtendFrame then ApplyExtendFrame;
  if FDarkFrame   then ApplyDarkFrame;
end;


{ TStyleManager.SetStyle and some StyleElements changes recreate the window handle, and DWM attributes belong to the old handle. So every DWM setting is set again here, on the new handle. }
procedure TfrmMain.CreateWnd;
begin
  inherited CreateWnd;
  if FBackdropSet OR FExtendFrame OR FDarkFrame then
    begin
      Log(Format('CreateWnd: new handle $%x - re-applying the DWM settings', [Handle]));
      ApplyAllDwm;
    end;
end;



{-------------------------------------------------------------------------------------------------------------
   SWITCHES
-------------------------------------------------------------------------------------------------------------}
procedure TfrmMain.rgBackdropClick(Sender: TObject);
begin
  if rgBackdrop.ItemIndex < 0 then EXIT;
  FBackdrop:= rgBackdrop.ItemIndex;      // the items are in DWMSBT_AUTO..DWMSBT_TABBEDWINDOW order
  FBackdropSet:= TRUE;
  if HandleAllocated then ApplyBackdrop;
  SyncDemo;
end;


procedure TfrmMain.chkExtendFrameClick(Sender: TObject);
begin
  FExtendFrame:= chkExtendFrame.Checked;
  if HandleAllocated then ApplyExtendFrame;
  SyncDemo;
end;


procedure TfrmMain.chkBlackClientClick(Sender: TObject);
begin
  if chkBlackClient.Checked
  then Color:= clBlack
  else Color:= clBtnFace;
  Log('Form Color = ' + ColorToString(Color));
  SyncDemo;
end;


procedure TfrmMain.chkDarkFrameClick(Sender: TObject);
begin
  FDarkFrame:= chkDarkFrame.Checked;
  if HandleAllocated then ApplyDarkFrame;
  SyncDemo;
end;


procedure TfrmMain.chkStyleElementsClick(Sender: TObject);
VAR Elements: TStyleElements;
begin
  Elements:= StyleElements;
  if chkStyleBorder.Checked
  then Include(Elements, seBorder)
  else Exclude(Elements, seBorder);
  if chkStyleClient.Checked
  then Include(Elements, seClient)
  else Exclude(Elements, seClient);
  StyleElements:= Elements;
  if FLog <> NIL then   // not during DFM loading
    begin
      Log(Format('StyleElements: seBorder=%s seClient=%s', [BoolToStr(seBorder in Elements, TRUE), BoolToStr(seClient in Elements, TRUE)]));
      if chkDarkTheme.Checked then ApplyDarkThemeToButtons;   // a recreated child handle loses its window theme
    end;
end;



{-------------------------------------------------------------------------------------------------------------
   TEXT ON GLASS
-------------------------------------------------------------------------------------------------------------}

{ Every control with ParentFont = True follows the form's font. The control column (pnlControls) has its own font, so it stays readable. }
procedure TfrmMain.chkWhiteTextClick(Sender: TObject);
begin
  if chkWhiteText.Checked
  then Font.Color:= clWhite
  else Font.Color:= clWindowText;
  Log('Form Font.Color = ' + ColorToString(Font.Color));
end;


{ SetWindowTheme(h, 'DarkMode_Explorer', NIL) on every check box and radio button of the sample area.
  'DarkMode_Explorer' is NOT documented by Microsoft. The controls in pnlControls are skipped, so the switches stay readable. }
procedure TfrmMain.ApplyDarkThemeToButtons;

  procedure ApplyTo(Parent: TWinControl);
  VAR
    i: Integer;
    Ctrl: TControl;
    HR: HRESULT;
  begin
    for i:= 0 to Parent.ControlCount - 1 do
      begin
        Ctrl:= Parent.Controls[i];
        if Ctrl = pnlControls then Continue;
        if ((Ctrl is TCustomCheckBox) OR (Ctrl is TRadioButton)) AND TWinControl(Ctrl).HandleAllocated then
          begin
            if chkDarkTheme.Checked
            then HR:= SetWindowTheme(TWinControl(Ctrl).Handle, 'DarkMode_Explorer', NIL)
            else HR:= SetWindowTheme(TWinControl(Ctrl).Handle, NIL, NIL);
            if HR <> S_OK
            then LogHR('SetWindowTheme(' + Ctrl.Name + ')', HR);
            TWinControl(Ctrl).Invalidate;
          end;
        if Ctrl is TWinControl
        then ApplyTo(TWinControl(Ctrl));   // the radio buttons of a TRadioGroup are its children
      end;
  end;

begin
  if NOT Assigned(SetWindowTheme) then
    begin
      Log('SetWindowTheme is not available (uxtheme.dll not loaded)');
      EXIT;
    end;
  ApplyTo(Self);
  if chkDarkTheme.Checked
  then Log('SetWindowTheme(DarkMode_Explorer) applied to the sample check boxes / radio buttons')
  else Log('SetWindowTheme(NIL, NIL) - default theme restored');
end;


procedure TfrmMain.chkDarkThemeClick(Sender: TObject);
begin
  ApplyDarkThemeToButtons;
end;


{ The VCL's own glass support (TCustomForm.GlassFrame, Vcl.Forms.pas). With SheetOfGlass it calls DwmExtendFrameIntoClientArea with margins -1 AND sets csGlassPaint on every control (TCustomForm.UpdateGlassFrameControls). With csGlassPaint a TLabel draws its text composited (tfComposited, TCustomLabel.DoDrawThemeTextEx in Vcl.StdCtrls.pas) and several controls paint through a buffered paint with alpha. }
procedure TfrmMain.chkGlassFrameClick(Sender: TObject);
begin
  GlassFrame.SheetOfGlass:= TRUE;
  GlassFrame.Enabled:= chkGlassFrame.Checked;
  Log('VCL GlassFrame.Enabled (SheetOfGlass) = ' + BoolToStr(GlassFrame.Enabled, TRUE));
  SyncDemo;
end;


{ A caption label beside a control with an empty Caption: clicking the label works the control. }
procedure TfrmMain.lblNoCaptionClick(Sender: TObject);
begin
  if Sender = lblNoCaption1   then chkNoCaption1.Checked:= NOT chkNoCaption1.Checked else
  if Sender = lblNoCaption2   then chkNoCaption2.Checked:= NOT chkNoCaption2.Checked else
  if Sender = lblRbNoCaption1 then rbNoCaption1.Checked := TRUE else
  if Sender = lblRbNoCaption2 then rbNoCaption2.Checked := TRUE;
end;



{-------------------------------------------------------------------------------------------------------------
   VCL STYLES
-------------------------------------------------------------------------------------------------------------}
procedure TfrmMain.LoadStyleList;
VAR FileName, StylesFolder: string;
begin
  StylesFolder:= TPath.Combine(ExtractFilePath(Application.ExeName), StylesSubFolder);
  FreeAndNil(FStyleFiles);
  FStyleFiles:= TStringList.Create;
  FStyleFiles.Sorted:= FALSE;

  cmbStyle.Items.BeginUpdate;
  try
    cmbStyle.Items.Clear;
    cmbStyle.Items.Add('Windows');
    if TDirectory.Exists(StylesFolder) then
      for FileName in TDirectory.GetFiles(StylesFolder, '*.vsf') do
        begin
          FStyleFiles.Add(FileName);
          cmbStyle.Items.Add(TPath.GetFileNameWithoutExtension(FileName));
        end;
  finally
    cmbStyle.Items.EndUpdate;
  end;
  cmbStyle.ItemIndex:= 0;

  if FStyleFiles.Count = 0
  then Log('No .vsf files found in ' + StylesFolder)
  else Log(Format('%d VCL styles found in %s', [FStyleFiles.Count, StylesFolder]));
end;


function TfrmMain.StyleRegistered(CONST StyleName: string): Boolean;
begin
  for VAR Name in TStyleManager.StyleNames do
    if SameText(Name, StyleName)
    then EXIT(TRUE);
  Result:= FALSE;
end;


procedure TfrmMain.cmbStyleChange(Sender: TObject);
VAR
  FileName: string;
  Info: TStyleInfo;
begin
  if cmbStyle.ItemIndex < 0 then EXIT;

  if cmbStyle.ItemIndex = 0 then
    begin
      TStyleManager.SetStyle(TStyleManager.SystemStyleName);
      Log('VCL style: ' + TStyleManager.SystemStyleName + ' (no style)');
      if chkDarkTheme.Checked then ApplyDarkThemeToButtons;
      EXIT;
    end;

  FileName:= FStyleFiles[cmbStyle.ItemIndex - 1];
  if NOT TStyleManager.IsValidStyle(FileName, Info) then
    begin
      Log('Not a valid VCL style: ' + FileName);
      EXIT;
    end;

  if NOT StyleRegistered(Info.Name)
  then TStyleManager.LoadFromFile(FileName);
  TStyleManager.SetStyle(Info.Name);
  Log('VCL style: ' + Info.Name);
  if chkDarkTheme.Checked then ApplyDarkThemeToButtons;   // SetStyle recreates the child handles, which loses their window theme
end;


end.
