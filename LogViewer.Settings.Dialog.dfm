object frmLogViewerSettings: TfrmLogViewerSettings
  Left = 0
  Top = 0
  Caption = 'Settings'
  ClientHeight = 373
  ClientWidth = 938
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlConfigTree: TPanel
    Left = 0
    Top = 0
    Width = 201
    Height = 332
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
  end
  object pgcMain: TPageControl
    Left = 201
    Top = 0
    Width = 737
    Height = 332
    ActivePage = tsDisplayValuesSettings
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 1
    ExplicitWidth = 598
    object tsWatches: TTabSheet
      Caption = 'Watches'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 856
      ExplicitHeight = 0
    end
    object tsCallstack: TTabSheet
      Caption = 'Callstack'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 575
      ExplicitHeight = 0
    end
    object tsWinIPC: TTabSheet
      Caption = 'WinIPC'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 575
      ExplicitHeight = 0
    end
    object tsWinODS: TTabSheet
      Caption = 'OutputDebugString API'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 575
      ExplicitHeight = 0
    end
    object tsComport: TTabSheet
      Caption = 'Serial port'
      ImageIndex = 4
      ExplicitWidth = 590
    end
    object tsZeroMQ: TTabSheet
      Caption = 'ZeroMQ'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 575
      ExplicitHeight = 0
    end
    object tsDisplayValuesSettings: TTabSheet
      Caption = 'DisplayValuesSettings'
      ImageIndex = 6
    end
    object tsAdvanced: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 856
      ExplicitHeight = 0
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 332
    Width = 938
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 799
    object btnClose: TButton
      Left = 660
      Top = 6
      Width = 120
      Height = 25
      Action = actClose
      TabOrder = 0
    end
  end
  object aclMain: TActionList
    Left = 328
    Top = 192
    object actClose: TAction
      Caption = '&Close'
      OnExecute = actCloseExecute
    end
  end
end
