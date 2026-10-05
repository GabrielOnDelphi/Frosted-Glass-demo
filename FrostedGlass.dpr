program FrostedGlass;

{ Needs the LightSaber library: https://github.com/GabrielOnDelphi/Delphi-LightSaber
  How to make its units visible to the compiler: ReadMe.md }

uses
  // madExcept is a commercial third-party library. ($IFDEF madshi) is false unless "madshi" is in DCC_Define.
  {$IFDEF madshi}
  madExcept, madLinkDisAsm, madListModules, {$ENDIF}

  Vcl.Themes,
  Vcl.Styles,
  MainForm in 'MainForm.pas' {frmMain},
  DemoForm in 'DemoForm.pas' {frmDemo},
  DwmBackdrop in 'DwmBackdrop.pas',
  LightVcl.Visual.AppData,
  LightVcl.Visual.AppDataForm,
  LightCore.AppData,
  Vcl.Forms;

{$R *.res}

begin
  CONST
     MultiThreaded= FALSE;                 // True => Only if we need to use multithreading in the Log.
  CONST
     AppName= 'FrostedGlass';               // Names the INI file used by SaveForm/LoadForm.

  AppData:= TAppData.Create(AppName, '', MultiThreaded);
  Application.MainFormOnTaskbar:= TRUE;
  AppData.CreateMainForm(TfrmMain, asFull);      // asFull: every switch is saved on close and restored at the next start
  AppData.Run;
end.
