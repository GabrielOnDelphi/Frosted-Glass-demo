# FrostedGlass - Windows 11 backdrop on a VCL form

A throwaway test app. It answers one question: can a VCL form, such as the forms of BioniX, show the Windows 11 system backdrop (Mica or Acrylic), and must the VCL style ("skin") be turned off for that?

Every switch works at run time. The memo at the bottom left shows the Windows build number and the result (HRESULT) of every DWM call; `S_OK` means Windows accepted the call. It does not mean the backdrop is visible - only your eyes can tell that.

## The switches (left column)

| Switch | What it does |
|---|---|
| Backdrop | Calls `DwmSetWindowAttribute(Handle, DWMWA_SYSTEMBACKDROP_TYPE, Value, 4)` with Auto (0), None (1), Mica (2), Acrylic (3) or Mica Alt / Tabbed (4). At the first start Acrylic is selected. With no item selected (an INI from an older version) the window keeps the Windows default. |
| Extend frame into client area (margins -1) | Calls `DwmExtendFrameIntoClientArea` with all four margins = -1 ("sheet of glass"): the frame material may then show in the whole client area. Unchecked = margins 0. |
| Black client area | Sets the form `Color` to `clBlack` (else `clBtnFace`). GDI black has alpha 0, so with the frame extended the backdrop should show through it. |
| Dark mode frame | `DWMWA_USE_IMMERSIVE_DARK_MODE` = 1 or 0. Dark Mica/Acrylic instead of light. |
| VCL style | "Windows" = no style. The other items are the `.vsf` files in the `Styles` folder next to the EXE (see "Build and run"), loaded with `TStyleManager.LoadFromFile` (once) and `TStyleManager.SetStyle`. With no such folder, the list holds only "Windows". |
| Style draws the frame (seBorder) / the client (seClient) | Adds or removes the element in the form's `StyleElements`. With a style active, the style paints the title bar and the client area over whatever DWM draws; turning these off lets you see if DWM shows through. |
| Text color white | Sets the form `Font.Color` to `clWhite` (else `clWindowText`); every sample control with `ParentFont = True` follows. Tests whether non-black GDI text shows on the glass. |
| Dark theme for controls | Calls `SetWindowTheme(Handle, 'DarkMode_Explorer', nil)` on every check box and radio button of the sample area, then invalidates it. Unchecked calls `SetWindowTheme(Handle, nil, nil)`. **`DarkMode_Explorer` is NOT documented by Microsoft** - it is the theme name Windows Explorer uses for itself. |
| VCL GlassFrame (Enabled + SheetOfGlass) | The VCL's own glass support (`TCustomForm.GlassFrame`). It calls `DwmExtendFrameIntoClientArea` with margins -1 by itself AND marks every control with `csGlassPaint` (`TCustomForm.UpdateGlassFrameControls` in the Delphi 13 source file `source\vcl\Vcl.Forms.pas`). With that flag a `TLabel` draws its text composited, with a real alpha (`tfComposited` in `Vcl.StdCtrls.pas`, `TCustomLabel.DoDrawThemeTextEx`), and several controls paint through a buffered paint. Use it instead of "Extend frame", not together with it. |

The whole switch column sits on an opaque panel (`ParentBackground = False`, its own black font), so its captions stay readable whatever you switch.

`TStyleManager.SetStyle` recreates the window handle, and the DWM settings belong to the old handle. The form therefore sets all of them again in its `CreateWnd` override; the memo logs a line `CreateWnd: new handle ...` each time.

The middle column holds typical controls (two panels with `ParentBackground` True and False, button, edit, check box, memo, list box, label). The right column holds a captioned `TRadioGroup` and `TRadioButton`, and the group **"Captions as separate labels"**: check boxes and radio buttons with an EMPTY caption, each with a white transparent `TLabel` beside it; clicking the label works the control. This is the fallback if the themed check box ignores `Font.Color`.

## The see-through window

The main form is full of controls, so little of its glass is visible. A second window, "FrostedGlass - see-through window" (`DemoForm.pas`), has no controls at all, so its whole client area shows the backdrop. It opens at start-up; the button "Show see-through window" opens it again after you close it.

The main form copies these switches to the see-through window every time you change one: Backdrop, Extend frame, Black client area, Dark mode frame and VCL GlassFrame. The VCL style needs no copy: it applies to every form of the application. The see-through window also sets its DWM settings again in its own `CreateWnd` override. It writes only a failed DWM call to the log; the memo shows the results of the main window.

## Saved state

All switches, the backdrop and the VCL style are saved to the INI file on close (LightSaber `SaveForm`, `asFull`) and restored at the next start. LightSaber restores the controls in `LoadForm` before the form is shown, but it fires a control's `OnClick` only when the saved value differs from the DFM value. So `FormPostInitialize` applies every setting once more from the restored controls; the memo logs `Applying the restored state...` followed by the DWM results.

## A suggested order

At the first start, Acrylic, "Extend frame", "Black client area" and "Dark mode frame" are already on, so the frosted effect is visible at once.

1. Style "Windows", Backdrop = Acrylic, "Extend frame" and "Black client area" off. Expected: the backdrop shows only in the title bar.
2. Check "Extend frame" and "Black client area". Expected: the backdrop shows in the client area too, the controls stay opaque; black text may become invisible.
3. Pick a VCL style from the `Styles` folder. Then uncheck seBorder and seClient one by one.

## Unknown until you run it

- Whether the backdrop shows at all on a VCL form with a VCL style active.
- Whether a style with `seBorder` on hides the backdrop in the title bar (expected: yes, the style paints its own frame).
- Whether `seClient` off plus "Black client area" lets the backdrop show with a style active.
- How each control looks over the backdrop (text drawn in black on black glass may disappear).
- Whether "Auto" picks anything for a plain Win32 app.
- Your first run found: with Acrylic + Extend frame + Black client + Dark frame, the captions of check boxes, radio buttons, the radio group, the label and the `ParentBackground = True` panel were invisible.

## Result (Gabriel's test, 2026-10-04)

- Best combination: Acrylic + Extend frame + Dark mode frame + style "Windows" + Text color white + Dark theme for controls + VCL GlassFrame. Black client area OFF.
- With it, the captions on glass are readable (TLabel, TCheckBox, the `ParentBackground = True` panel).
- But the white form font also goes into the controls that paint their own white background (TEdit, TMemo, TListBox): their text becomes white on white, and TMemo / TListBox show black painting bars. Each such control would need its own font color, and GlassFrame does not paint them cleanly.
- Turning a switch off and on again does not always restore the earlier look (the test app does not undo every step in the right order).
- Conclusion: the frosted backdrop works well only on an empty window, or in the parts of a window without controls. Not worth adding to BioniX, whose forms are full of controls.

## Sources

- `DWMWA_SYSTEMBACKDROP_TYPE`: "Retrieves or specifies the system-drawn backdrop material of a window, including behind the non-client area ... supported starting with Windows 11 Build 22621." https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
- `DWM_SYSTEMBACKDROP_TYPE` values (not declared in Delphi 13, so `DwmBackdrop.pas` declares them, 0..4): https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwm_systembackdrop_type
- Delphi 13 declarations: the Delphi source file `source\rtl\win\Winapi.DwmApi.pas` (`DWMWA_SYSTEMBACKDROP_TYPE = 38`, `DWMWA_USE_IMMERSIVE_DARK_MODE = 20`).

## Build and run

Written and tested with Delphi 13, Win32. It needs Windows 11 build 22621 or newer for the backdrop.

1. Clone the LightSaber library: https://github.com/GabrielOnDelphi/Delphi-LightSaber
2. Make its units visible to the compiler, in ONE of two ways:
   - Add these three LightSaber folders to the Delphi Library path for Win32 (in Tools > Options): the root folder, `FrameVCL` and `External`.
   - Or define an environment variable `LightSaber` that holds the LightSaber root folder (in Windows, or as an IDE "user override" environment variable in Tools > Options). `FrostedGlass.dproj` reads it as `$(LightSaber)` and adds the same three folders to the project search path. On the command line: `msbuild FrostedGlass.dproj /p:LightSaber=<LightSaber folder>`.
3. Optional: create a folder `Styles` next to `FrostedGlass.exe` and copy some `.vsf` VCL style files into it. Delphi ships its styles in its `Redist\styles\vcl` folder.
4. Build and run. The switches are saved on close to an INI file (LightSaber `AppData`) and restored at the next start.

## License

Mozilla Public License 2.0 (MPL-2.0), see `LICENSE`. LightSaber, which this demo uses, has its own terms: https://github.com/GabrielOnDelphi/Delphi-LightSaber/blob/main/System/Copyright.txt
