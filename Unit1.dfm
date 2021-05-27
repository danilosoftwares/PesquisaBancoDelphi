object Form1: TForm1
  Left = 192
  Top = 124
  Caption = 'Pesquisa Banco'
  ClientHeight = 749
  ClientWidth = 1352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 289
    Top = 65
    Width = 1063
    Height = 684
    Align = alClient
    Caption = 'Panel6'
    TabOrder = 2
    object Panel8: TPanel
      Left = 1
      Top = 1
      Width = 1061
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      Caption = 'C'#243'digo'
      TabOrder = 0
    end
    object RichEdit1: TRichEdit
      Left = 1
      Top = 29
      Width = 1061
      Height = 654
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Lucida Console'
      Font.Style = []
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WantReturns = False
      WordWrap = False
      Zoom = 100
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1352
    Height = 65
    Align = alTop
    TabOrder = 0
    object btnPesquisar: TButton
      AlignWithMargins = True
      Left = 4
      Top = 6
      Width = 97
      Height = 21
      Margins.Top = 5
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Pesquisar'
      TabOrder = 0
      OnClick = btnPesquisarClick
    end
    object edPesquisa: TEdit
      AlignWithMargins = True
      Left = 107
      Top = 6
      Width = 830
      Height = 21
      Margins.Top = 5
      Margins.Bottom = 5
      Align = alClient
      AutoSize = False
      TabOrder = 1
      OnKeyDown = edPesquisaKeyDown
    end
    object ckbMM: TCheckBox
      AlignWithMargins = True
      Left = 943
      Top = 4
      Width = 213
      Height = 25
      Margins.Right = 10
      Align = alRight
      BiDiMode = bdRightToLeft
      Caption = 'Diferenciar Maiusculo e Minusculo'
      ParentBiDiMode = False
      TabOrder = 2
    end
    object Panel10: TPanel
      Left = 1
      Top = 32
      Width = 1350
      Height = 32
      Align = alBottom
      BevelOuter = bvLowered
      Color = clInfoBk
      TabOrder = 3
    end
    object panelBanco: TPanel
      Left = 1166
      Top = 1
      Width = 185
      Height = 31
      Align = alRight
      BevelOuter = bvLowered
      Caption = 'FIREBIRD'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 33023
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 65
    Width = 289
    Height = 684
    Align = alLeft
    Caption = 'Panel2'
    TabOrder = 1
    object tvBanco: TTreeView
      Left = 1
      Top = 1
      Width = 287
      Height = 682
      Align = alClient
      Indent = 19
      RowSelect = True
      TabOrder = 0
      OnClick = tvBancoClick
    end
  end
  object qryProcedureSource: TFDQuery
    Connection = database1
    SQL.Strings = (
      'SELECT *'
      'FROM RDB$PROCEDURES'
      'WHERE RDB$PROCEDURE_NAME = :NOME')
    Left = 560
    Top = 176
    ParamData = <
      item
        Name = 'NOME'
      end>
  end
  object qryTriggersSource: TFDQuery
    Connection = database1
    SQL.Strings = (
      'SELECT *'
      'FROM RDB$TRIGGERS'
      'WHERE RDB$TRIGGER_NAME = :NOME')
    Left = 512
    Top = 274
    ParamData = <
      item
        Name = 'NOME'
        DataType = ftString
        ParamType = ptInput
      end>
  end
  object database1: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=manager'
      
        'Database=D:\Projetos\Delphi 7\Teles Cabeleireiros\Banco de Dados' +
        '\TELES CABELEIREIROS.FDB'
      'Server=localhost'
      'Protocol=TCPIP'
      'DriverID=FB')
    FormatOptions.AssignedValues = [fvRound2Scale]
    FormatOptions.Round2Scale = True
    LoginPrompt = False
    AfterConnect = Database1AfterConnect
    BeforeConnect = database1BeforeConnect
    Left = 409
    Top = 169
  end
  object FDCommand1: TFDCommand
    Connection = database1
    FetchOptions.AssignedValues = [evItems]
    FetchOptions.Items = [fiBlobs, fiDetails]
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    CommandKind = skSelect
    Left = 401
    Top = 249
  end
  object qryProcedures: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 929
    Top = 129
    object qryProceduresNAME: TWideStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      FixedChar = True
      Size = 31
    end
  end
  object qryTriggers: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 921
    Top = 233
    object WideStringField1: TWideStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      FixedChar = True
      Size = 31
    end
  end
end
