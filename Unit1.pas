unit Unit1;

interface

USES
  Windows, Messages, SysUtils,FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.MSSQL, FireDAC.Phys.Oracle, FireDAC.Comp.DataMove,FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async,  FireDAC.DApt, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls,goSchemaDB,gotipagem, FireDAC.Phys.FBDef, Vcl.ComCtrls,
  Vcl.OleCtrls, SHDocVw;

type
  TForm1 = class(TForm)
    qryProcedureSource: TFDQuery;
    qryTriggersSource: TFDQuery;
    Panel1: TPanel;
    btnPesquisar: TButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    Panel6: TPanel;
    Panel8: TPanel;
    ckbMM: TCheckBox;
    RichEdit1: TRichEdit;
    Panel10: TPanel;
    panelBanco: TPanel;
    database1: TFDConnection;
    FDCommand1: TFDCommand;
    qryProcedures: TFDMemTable;
    qryProceduresNAME: TWideStringField;
    qryTriggers: TFDMemTable;
    WideStringField1: TWideStringField;
    tvBanco: TTreeView;
    procedure btnPesquisarClick(Sender: TObject);
    procedure Database1AfterConnect(Sender: TObject);
    procedure database1BeforeConnect(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvBancoClick(Sender: TObject);
  private
    { Private declarations }
  public
     procedure Colorindo(RichEdit: TRichEdit;Pesquisa:string);
    { Public declarations }
  end;

var
  Form1: TForm1;
  sPesquisa:string;
  iPrimeiro:integer;

implementation

{$R *.dfm}

procedure TForm1.Colorindo(RichEdit: TRichEdit;Pesquisa:string);
var
  iPosIni : integer;
 
begin
   iPrimeiro := 0;
   //Carrega o RichEdit com as propriedades iniciais
   RichEdit.SelStart  := 0;
   RichEdit.SelLength := length(RichEdit.Text);
   RichEdit.SelAttributes.color := clBlack;
   RichEdit.SelAttributes.style := [];
   RichEdit.SelAttributes.Size  := 10;

   iPosIni := 0;
   while true do
   begin
    //Encontra e atribui a posição inicial do texto no RichEdit
    iPosIni := RichEdit.FindText(Pesquisa, iPosIni, length(RichEdit.Text), []);

    //Verifica se o texto foi encontrado
    if iPosIni >= 0 then
    begin
        if iPrimeiro = 0 then
           iPrimeiro := iPosIni;

        RichEdit.SelStart  := iPosIni;
        RichEdit.SelLength := length(Pesquisa);
        RichEdit.SelAttributes.color := clRed;
        RichEdit.SelAttributes.style := [fsBold];
        RichEdit.SelAttributes.Size  := RichEdit.SelAttributes.Size;
        iPosIni := iPosIni + length(Pesquisa);
    end else
    begin
      break;
    end;
   end;
   RichEdit.SelStart  := 0;
end;

procedure TForm1.Database1AfterConnect(Sender: TObject);
var
   db:TgoSchemaDB;
   modelo:TModeloBanco;
begin
   if database1.DriverName = 'FB' then
      modelo := mbFirebird
   else if database1.DriverName = 'Ora' then
      modelo := mbOracle
   else if database1.DriverName = 'MSSQL' then
      modelo := mbMSSQL;

   db:=TgoSchemaDB.Create(modelo);

   qryProcedures.close;
   qryProcedures.CreateDataSet;
   //qryProcedures.sql.Text := db.SQL.ListProcedures;

   FDCommand1.CommandText.Text := db.SQL.ListProcedures;
   FDCommand1.Open;
   FDCommand1.Fetch(qryProcedures.Table);
   FDCommand1.Close;

   qryProcedureSource.close;
   qryProcedureSource.sql.Text := db.SQL.ListProceduresSource;

   qryTriggers.Close;
   qryTriggers.CreateDataSet;
   //qryTriggers.sql.Text := db.SQL.ListTriggers;

   FDCommand1.CommandText.Text := db.SQL.ListTriggers;
   FDCommand1.Open;
   FDCommand1.Fetch(qryTriggers.Table);
   FDCommand1.Close;

   qryTriggersSource.Close;
   qryTriggersSource.sql.Text := db.SQL.ListTriggersSource;

   case modelo of
      mbFirebird:
      begin
         panelBanco.Caption := 'Firebird';
         panelBanco.Font.Color := $000080FF;
      end;
      mbOracle:
      begin
         panelBanco.Caption := 'Oracle';
         panelBanco.Font.Color := clred;
      end;
      mbMSSQL:
      begin
         panelBanco.Caption := 'SQL Server';
         panelBanco.Font.Color := clblack;
      end;
   end;
end;

procedure TForm1.database1BeforeConnect(Sender: TObject);
begin
   if FileExists('CONNECT.txt') then
   begin
      database1.Params.LoadFromFile('CONNECT.txt');
   end else
   begin
      database1.Params.SaveToFile('CONNECT.txt');
   end;
end;

procedure TForm1.edPesquisaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 13 then
  begin
    btnPesquisar.Click;
  end;
end;

procedure TForm1.btnPesquisarClick(Sender: TObject);
var
   TextoUSADO: string;
   iTotal:integer;
   NodeProcedures : TTreeNode;
   NodeTriggers : TTreeNode;
begin
   sPesquisa := edPesquisa.text;
   Panel10.Caption := 'Ultima Palavra Pesquisada : '+sPesquisa;
   Panel10.Refresh;

   Database1.Close;
   Database1.open;

   iTotal := 0;
   TextoUSADO := '';
   tvbanco.Items.clear;
   NodeProcedures := tvbanco.Items.Add(nil,'Stored Procedures');
   NodeTriggers := tvbanco.Items.Add(nil,'Triggers');

   qryProcedures.First;
   while not qryProcedures.eof do
   begin
      TextoUSADO:='';
      qryProcedureSource.Close;
      qryProcedureSource.ParamByName('NOME').AsString := qryProcedures.fieldbyname('NAME').asString;
      qryProcedureSource.open;
      qryProcedureSource.First;
      while not qryProcedureSource.eof do
      begin
         TextoUSADO := TextoUSADO + qryProcedureSource.fieldbyname('TEXT').asString;
         qryProcedureSource.Next;
      end;

      IF ckbMM.Checked = false then
      begin
         TextoUSADO := uppercase(TextoUSADO);
         sPesquisa  := uppercase(sPesquisa);
      end;

      if (pos(sPesquisa,TextoUSADO) > 0) then
      begin
         tvbanco.Items.AddChild(NodeProcedures,qryProcedures.fieldbyname('NAME').asString) ;
         iTotal := iTotal + 1;
      end;

      qryProcedures.next;
   end;
   NodeProcedures.Text := 'Stored Procedures ('+INTTOSTR(iTotal)+')';
   Application.ProcessMessages;

   iTotal := 0;
   TextoUSADO := '';
   qryTriggers.First;
   while not qryTriggers.eof do
   begin
      TextoUSADO:='';
      qryTriggersSource.Close;
      qryTriggersSource.ParamByName('NOME').AsString := qryTriggers.fieldbyname('NAME').asString;
      qryTriggersSource.open;
      qryTriggersSource.First;
      while not qryTriggersSource.eof do
      begin
         TextoUSADO := TextoUSADO + qryTriggersSource.fieldbyname('TEXT').asString;
         qryTriggersSource.Next;
      end;

      IF ckbMM.Checked = false then
      begin
         TextoUSADO := uppercase(TextoUSADO);
         sPesquisa  := uppercase(sPesquisa);
      end;

      if (pos(sPesquisa,TextoUSADO) > 0) then
      begin
         tvbanco.Items.AddChild(NodeTriggers,qryTriggers.fieldbyname('NAME').asString) ;
         iTotal := iTotal + 1;         
      end;      

      qryTriggers.next;
   end;
   NodeTriggers.text := 'Triggers ('+INTTOSTR(iTotal)+')';
   Application.ProcessMessages;
end;

procedure TForm1.tvBancoClick(Sender: TObject);
VAR
   TextoUSADO: string;
begin
   if ((tvBanco.Selected.Count = 0) and (tvBanco.Selected.Parent <> nil)) then
   begin
      if pos('Procedures',tvBanco.Selected.Parent.Text) > 0 then
      begin
         TextoUSADO:='';
         qryProcedureSource.Close;
         qryProcedureSource.ParamByName('NOME').AsString := tvBanco.Selected.Text;
         qryProcedureSource.open;
         qryProcedureSource.First;
         while not qryProcedureSource.eof do
         begin
            TextoUSADO := TextoUSADO + qryProcedureSource.fieldbyname('TEXT').asString;
            qryProcedureSource.Next;
         end;
         RichEdit1.Text := TextoUSADO;
         Colorindo(RichEdit1,sPesquisa);
         RichEdit1.setfocus;
         RichEdit1.SelStart  := iPrimeiro;
         Panel8.caption := 'Código da Stored Procedure : '+ tvBanco.Selected.Text;
      end else
      if pos('Triggers', tvBanco.Selected.Parent.Text) > 0 then
      begin
         TextoUSADO:='';
         qryTriggersSource.Close;
         qryTriggersSource.ParamByName('NOME').AsString := tvBanco.Selected.Text;
         qryTriggersSource.open;
         qryTriggersSource.First;
         while not qryTriggersSource.eof do
         begin
            TextoUSADO := TextoUSADO + qryTriggersSource.fieldbyname('TEXT').asString;
            qryTriggersSource.Next;
         end;
         RichEdit1.text := TextoUSADO;
         Colorindo(RichEdit1,sPesquisa);
         RichEdit1.setfocus;
         RichEdit1.SelStart  := iPrimeiro;


         qryTriggers.Locate('NAME',tvBanco.Selected.Text,[]);

         Panel8.caption := 'Código da Trigger : '+ tvBanco.Selected.Text;
      end;
      tvBanco.SetFocus;
   end;
end;

end.
