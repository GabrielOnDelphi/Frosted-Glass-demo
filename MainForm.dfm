object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'FrostedGlass - Windows 11 backdrop on a VCL form'
  ClientHeight = 600
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  TextHeight = 15
  object lblSample: TLabel
    Left = 360
    Top = 12
    Width = 187
    Height = 15
    Caption = 'Sample controls (which stay opaque?)'
  end
  object lblSampleText: TLabel
    Left = 360
    Top = 512
    Width = 156
    Height = 15
    Caption = 'TLabel - plain text on the form'
  end
  object lblSample2: TLabel
    Left = 760
    Top = 12
    Width = 157
    Height = 15
    Caption = 'Captions as separate labels'
  end
  object lblNoCaption1: TLabel
    Left = 784
    Top = 38
    Width = 120
    Height = 15
    Caption = 'Check box A (label)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Transparent = True
    OnClick = lblNoCaptionClick
  end
  object lblNoCaption2: TLabel
    Left = 784
    Top = 62
    Width = 120
    Height = 15
    Caption = 'Check box B (label)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Transparent = True
    OnClick = lblNoCaptionClick
  end
  object lblRbNoCaption1: TLabel
    Left = 784
    Top = 94
    Width = 120
    Height = 15
    Caption = 'Radio button A (label)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Transparent = True
    OnClick = lblNoCaptionClick
  end
  object lblRbNoCaption2: TLabel
    Left = 784
    Top = 118
    Width = 120
    Height = 15
    Caption = 'Radio button B (label)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    Transparent = True
    OnClick = lblNoCaptionClick
  end
  object pnlControls: TPanel
    Left = 0
    Top = 0
    Width = 350
    Height = 600
    Align = alLeft
    BevelOuter = bvNone
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    ShowCaption = False
    TabOrder = 0
    object lblStyle: TLabel
      Left = 12
      Top = 236
      Width = 51
      Height = 15
      Caption = 'VCL style:'
    end
    object lblStatus: TLabel
      Left = 12
      Top = 412
      Width = 35
      Height = 15
      Caption = 'Status:'
    end
    object rgBackdrop: TRadioGroup
      Left = 12
      Top = 12
      Width = 330
      Height = 140
      Caption = 'Backdrop (DWMWA_SYSTEMBACKDROP_TYPE)'
      Items.Strings = (
        'Auto (0)'
        'None (1)'
        'Mica (2)'
        'Acrylic (3)'
        'Mica Alt / Tabbed (4)')
      ItemIndex = 3
      TabOrder = 0
      OnClick = rgBackdropClick
    end
    object chkExtendFrame: TCheckBox
      Left = 12
      Top = 160
      Width = 330
      Height = 17
      Caption = 'Extend frame into client area (margins -1)'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chkExtendFrameClick
    end
    object chkBlackClient: TCheckBox
      Left = 12
      Top = 184
      Width = 330
      Height = 17
      Caption = 'Black client area (Color = clBlack)'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkBlackClientClick
    end
    object chkDarkFrame: TCheckBox
      Left = 12
      Top = 208
      Width = 330
      Height = 17
      Caption = 'Dark mode frame (DWMWA_USE_IMMERSIVE_DARK_MODE)'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = chkDarkFrameClick
    end
    object cmbStyle: TComboBox
      Left = 12
      Top = 254
      Width = 330
      Height = 23
      Style = csDropDownList
      TabOrder = 4
      OnChange = cmbStyleChange
    end
    object chkStyleBorder: TCheckBox
      Left = 12
      Top = 286
      Width = 330
      Height = 17
      Caption = 'Style draws the frame (seBorder)'
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = chkStyleElementsClick
    end
    object chkStyleClient: TCheckBox
      Left = 12
      Top = 310
      Width = 330
      Height = 17
      Caption = 'Style draws the client (seClient)'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = chkStyleElementsClick
    end
    object chkWhiteText: TCheckBox
      Left = 12
      Top = 338
      Width = 330
      Height = 17
      Caption = 'Text color white (form Font.Color = clWhite)'
      TabOrder = 7
      OnClick = chkWhiteTextClick
    end
    object chkDarkTheme: TCheckBox
      Left = 12
      Top = 362
      Width = 330
      Height = 17
      Caption = 'Dark theme for controls (DarkMode_Explorer)'
      TabOrder = 8
      OnClick = chkDarkThemeClick
    end
    object chkGlassFrame: TCheckBox
      Left = 12
      Top = 386
      Width = 330
      Height = 17
      Caption = 'VCL GlassFrame (Enabled + SheetOfGlass)'
      TabOrder = 9
      OnClick = chkGlassFrameClick
    end
    object mmoStatus: TMemo
      Left = 12
      Top = 430
      Width = 330
      Height = 158
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 10
    end
    object btnShowDemo: TButton
      Left = 192
      Top = 404
      Width = 150
      Height = 23
      Hint =
        'Shows an empty window with the same backdrop. It has no control' +
        's, so you can see through all of it.'
      Caption = 'Show see-through window'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      OnClick = btnShowDemoClick
    end
  end
  object pnlParentBg: TPanel
    Left = 360
    Top = 36
    Width = 380
    Height = 70
    Caption = 'TPanel - ParentBackground = True'
    TabOrder = 1
  end
  object pnlOpaque: TPanel
    Left = 360
    Top = 114
    Width = 380
    Height = 70
    Caption = 'TPanel - ParentBackground = False'
    ParentBackground = False
    TabOrder = 2
  end
  object btnSample: TButton
    Left = 360
    Top = 194
    Width = 120
    Height = 27
    Caption = 'TButton'
    TabOrder = 3
  end
  object edtSample: TEdit
    Left = 360
    Top = 230
    Width = 380
    Height = 23
    TabOrder = 4
    Text = 'TEdit'
  end
  object chkSample: TCheckBox
    Left = 360
    Top = 262
    Width = 380
    Height = 17
    Caption = 'TCheckBox'
    TabOrder = 5
  end
  object mmoSample: TMemo
    Left = 360
    Top = 288
    Width = 380
    Height = 100
    Lines.Strings = (
      'TMemo'
      'Line 2'
      'Line 3')
    TabOrder = 6
  end
  object lstSample: TListBox
    Left = 360
    Top = 396
    Width = 380
    Height = 106
    ItemHeight = 15
    Items.Strings = (
      'TListBox item 1'
      'TListBox item 2'
      'TListBox item 3'
      'TListBox item 4')
    TabOrder = 7
  end
  object chkNoCaption1: TCheckBox
    Left = 760
    Top = 37
    Width = 17
    Height = 17
    TabOrder = 8
  end
  object chkNoCaption2: TCheckBox
    Left = 760
    Top = 61
    Width = 17
    Height = 17
    TabOrder = 9
  end
  object rbNoCaption1: TRadioButton
    Left = 760
    Top = 93
    Width = 17
    Height = 17
    TabOrder = 10
  end
  object rbNoCaption2: TRadioButton
    Left = 760
    Top = 117
    Width = 17
    Height = 17
    TabOrder = 11
  end
  object rgSample: TRadioGroup
    Left = 760
    Top = 194
    Width = 228
    Height = 85
    Caption = 'TRadioGroup (sample)'
    ItemIndex = 0
    Items.Strings = (
      'Item 1'
      'Item 2')
    TabOrder = 12
  end
  object rbSample: TRadioButton
    Left = 760
    Top = 290
    Width = 228
    Height = 17
    Caption = 'TRadioButton (sample)'
    TabOrder = 13
  end
end
