unit goSchemaDB;

interface 

{
   Alteracoes

   18/02/19 - Danilo - modificado para adaptar para o sql server - mago
}

uses goTipagem, Classes;

type
   TgoSchemaDB = class;
   TSQLSchemaDB = class;

   TgoSchemaDB = class
   private
      { private declarations }
      fbanco:TModeloBanco;
      FSQL: TSQLSchemaDB;
    procedure SetSQL(const Value: TSQLSchemaDB);
   protected
      { protected declarations }
   public
      { public declarations }
      constructor Create(_banco: TModeloBanco);
      class function Get(_banco: TModeloBanco):TgoSchemaDB;
   published
      { published declarations }
      property SQL:TSQLSchemaDB read FSQL write SetSQL;
   end;

   TSQLSchemaDB = class
   private
      { private declarations }
      forigem:TgoSchemaDB;
      fSQL:TStringList;
   protected
      { protected declarations }
   public
      { public declarations }
      constructor Create(_origem:TgoSchemaDB);
      function ListProcedures: string;
      function ListProceduresParameters: string;
      function ListProceduresSource: string;
      function ListTables: string;
      function ListTablesColumns: string;
      function ListTablesColumnsKEY: string;
      function ListTriggers: string;
      function ListTriggersSource: string;
      function ListViews: string;
   published
      { published declarations }
   end;

implementation

uses
  SysUtils;

{ TgoSchemaDB }

constructor TgoSchemaDB.Create(_banco: TModeloBanco);
begin
   fbanco:=_banco;
   FSQL:=TSQLSchemaDB.Create(self);
end;

class function TgoSchemaDB.Get(_banco: TModeloBanco): TgoSchemaDB;
begin
   result := TgoSchemaDB.Create(_banco);
end;

procedure TgoSchemaDB.SetSQL(const Value: TSQLSchemaDB);
begin
  FSQL := Value;
end;

{ TSQLSchemaDB }

constructor TSQLSchemaDB.Create(_origem: TgoSchemaDB);
begin
   forigem:=_origem;
   fSQL:=TStringList.Create;
end;

function TSQLSchemaDB.ListProcedures():string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$PROCEDURE_NAME NAME');
      fSQL.Add('FROM RDB$PROCEDURES');
      fSQL.Add('ORDER BY RDB$PROCEDURE_NAME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('SELECT NAME FROM dbo.sysobjects WHERE (type = "P") ORDER BY NAME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT OBJECT_NAME NAME FROM User_Procedures ORDER BY OBJECT_NAME');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListProceduresParameters:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$PROCEDURE_NAME AS NOMEPROCEDURE,RDB$PROCEDURE_PARAMETERS.RDB$PARAMETER_NAME NOME,');
      fSQL.Add('CASE ');
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 261) THEN "ftString"');//"BLOB"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 14) THEN "ftString"');//"CHAR"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 40) THEN "ftString"');//"CSTRING"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 11) THEN "ftFloat"');//"D_FLOAT"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 27) THEN "ftFloat"');//"DOUBLE"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 10) THEN "ftFloat"');//"FLOAT"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 16) THEN "ftFloat"');//"INT64"
      fSQL.Add(' WHEN ((rdb$fields.rdb$field_type = 8) AND (rdb$fields.RDB$FIELD_PRECISION = 0)) THEN "ftInteger"');//"INTEGER"
      fSQL.Add(' WHEN ((rdb$fields.rdb$field_type = 8) AND (rdb$fields.RDB$FIELD_PRECISION > 0)) THEN "ftBCD"');//"BCD"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 9) THEN "ftFloat"');//""QUAD"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 7) THEN "ftFloat"');//""SMALLINT"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 12) THEN "ftDate"');//""DATE"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 13) THEN "ftTime"');//"TIME"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 35) THEN "ftDateTime"');//"TIMESTAMP"
      fSQL.Add(' WHEN (rdb$fields.rdb$field_type = 37) THEN "ftString"');//"VARCHAR"
      fSQL.Add('END TIPO,');
      fSQL.Add('CASE RDB$PARAMETER_TYPE');
      fSQL.Add('   WHEN 0 THEN "ptInput"');
      fSQL.Add('   WHEN 1 THEN "ptOutput"');
      fSQL.Add('END DIRECAO');
      fSQL.Add('FROM RDB$PROCEDURE_PARAMETERS, RDB$FIELDS');
      fSQL.Add('WHERE RDB$FIELDS.RDB$FIELD_NAME = RDB$PROCEDURE_PARAMETERS.RDB$FIELD_SOURCE');
      fSQL.Add('AND RDB$PROCEDURE_NAME = :PROCEDURE');
      fSQL.Add('ORDER BY DIRECAO,RDB$PARAMETER_NUMBER');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add(' SELECT     "NOME" = name,                                                     ');
      fSQL.Add('                                                                               ');
      fSQL.Add('      CASE                                                                     ');
      fSQL.Add('          WHEN type_name(user_type_id) = "int" THEN "ftFloat"                  ');
      fSQL.Add('          WHEN type_name(user_type_id) = "varchar" THEN "ftString"             ');
      fSQL.Add('          WHEN type_name(user_type_id) = "date" THEN "ftDateTime"              ');
      fSQL.Add('          WHEN type_name(user_type_id) = "numeric" THEN "ftFloat"              ');
      fSQL.Add('          WHEN type_name(user_type_id) = "float" THEN "ftFloat"                ');
      fSQL.Add('          WHEN type_name(user_type_id) = "date" THEN "ftDateTime"              ');
      fSQL.Add('      END TIPO,                                                                ');
      fSQL.Add('                                                                               ');
      fSQL.Add('      CASE                                                                     ');
      fSQL.Add('          WHEN is_output = 0 THEN "ptInput"                                    ');
      fSQL.Add('          WHEN is_output = 1 THEN "ptOutput"                                   ');
      fSQL.Add('      END DIRECAO                                                              ');
      fSQL.Add('                                                                               ');
      fSQL.Add('  from sys.parameters where object_id = object_id(:PROCEDURE)                  ');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT OWNER, OBJECT_NAME AS NOMEPROCEDURE, ARGUMENT_NAME AS NOME,');
      fSQL.Add('CASE');
      fSQL.Add('    WHEN DATA_TYPE = ''NUMBER'' THEN ''ftFloat''');
      fSQL.Add('    WHEN DATA_TYPE = ''VARCHAR2'' THEN ''ftString''');
      fSQL.Add('    WHEN DATA_TYPE = ''DATE'' THEN ''ftDateTime''');
      fSQL.Add('    WHEN DATA_TYPE = ''FLOAT'' THEN ''ftFloat''');
      fSQL.Add('    WHEN DATA_TYPE = ''TIMESTAMP'' THEN ''ftDateTime''');
      fSQL.Add('END TIPO,');
      fSQL.Add('CASE');
      fSQL.Add('    WHEN IN_OUT = ''IN'' THEN ''ptInput''');
      fSQL.Add('    WHEN IN_OUT = ''OUT'' THEN ''ptOutput''');
      fSQL.Add('END DIRECAO');
      fSQL.Add('FROM SYS.ALL_ARGUMENTS');
      fSQL.Add('WHERE OBJECT_NAME = :PROCEDURE');
      fSQL.Add('ORDER BY OWNER, OBJECT_NAME, SEQUENCE');
   end;
   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListProceduresSource:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$PROCEDURE_SOURCE TEXT FROM RDB$PROCEDURES WHERE RDB$PROCEDURE_NAME = :NOME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('sp_helptext :NOME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('select TEXT from user_source where name = :NOME and type = "PROCEDURE" order by line');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListTriggers:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$TRIGGER_NAME NAME, RDB$RELATION_NAME TABLE_NAME');
      fSQL.Add('FROM RDB$TRIGGERS');
      fSQL.Add('WHERE ((RDB$SYSTEM_FLAG=0) OR (RDB$SYSTEM_FLAG IS NULL))');
      fSQL.Add('ORDER BY RDB$TRIGGER_NAME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('SELECT NAME FROM dbo.sysobjects WHERE (type = "TR") ORDER BY NAME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT OBJECT_NAME NAME');
      fSQL.Add('FROM all_objects');
      fSQL.Add('WHERE object_type = "TRIGGER"');
      fSQL.Add('ORDER BY OBJECT_NAME');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListTriggersSource:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$TRIGGER_SOURCE TEXT FROM RDB$TRIGGERS WHERE RDB$TRIGGER_NAME = :NOME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('sp_helptext :NOME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('select TEXT from user_source where name = :NOME and type = "TRIGGER" order by line');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListTables:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$RELATION_NAME NAME FROM RDB$RELATIONS WHERE RDB$FLAGS = 1 AND RDB$VIEW_SOURCE IS NULL ORDER BY RDB$RELATION_NAME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('SELECT NAME FROM dbo.sysobjects WHERE (type = "U") ORDER BY NAME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT TABLE_NAME NAME FROM USER_TABLES TABELAS ORDER BY TABLE_NAME');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListTablesColumns:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT CAMPOS.RDB$FIELD_NAME NOME,');
      fSQL.Add('CASE');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 261) THEN ''ftString'' --''BLOB''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 14) THEN ''ftString'' --''CHAR''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 40) THEN ''ftString'' --''CSTRING''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 11) THEN ''ftFloat'' --''D_FLOAT''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 27) THEN ''ftFloat'' --''DOUBLE''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 10) THEN ''ftFloat'' --''FLOAT''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 16) THEN ''ftFloat'' --''INT64''');
      fSQL.Add(' WHEN ((RDB$FIELDS.rdb$field_type = 8) AND (RDB$FIELDS.RDB$FIELD_PRECISION = 0)) THEN ''ftInteger'' --''INTEGER''');
      fSQL.Add(' WHEN ((RDB$FIELDS.rdb$field_type = 8) AND (RDB$FIELDS.RDB$FIELD_PRECISION > 0)) THEN ''ftBCD'' --''BCD''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 9) THEN ''ftFloat'' --''QUAD''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 7) THEN ''ftFloat'' --''SMALLINT''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 12) THEN ''ftDate'' --''DATE''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 13) THEN ''ftTime'' --''TIME''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 35) THEN ''ftDateTime'' --''TIMESTAMP''');
      fSQL.Add(' WHEN (RDB$FIELDS.rdb$field_type = 37) THEN ''ftString'' --''VARCHAR''');
      fSQL.Add('END TIPO,');
      fSQL.Add(' CAMPOS.RDB$FIELD_POSITION ORDEM, RDB$FIELDS.RDB$FIELD_LENGTH TAMANHO');
      fSQL.Add('FROM RDB$RELATIONS TABELAS, RDB$RELATION_FIELDS CAMPOS, RDB$FIELDS, RDB$TYPES TIPOS');
      fSQL.Add('WHERE TABELAS.RDB$RELATION_NAME = CAMPOS.RDB$RELATION_NAME');
      fSQL.Add('AND CAMPOS.RDB$FIELD_SOURCE = RDB$FIELDS.RDB$FIELD_NAME');
      fSQL.Add('AND');
      fSQL.Add('RDB$FIELDS.RDB$FIELD_TYPE = TIPOS.RDB$TYPE AND');
      fSQL.Add('TIPOS.RDB$FIELD_NAME = ''RDB$FIELD_TYPE''');
      fSQL.Add('AND TIPOS.RDB$TYPE_NAME <> ''BLOB''');
      fSQL.Add('AND TABELAS.RDB$SYSTEM_FLAG = 0');
      fSQL.Add('AND CAMPOS.RDB$RELATION_NAME = :TABELA');
      fSQL.Add('ORDER BY CAMPOS.RDB$FIELD_POSITION');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('SELECT                                                    ');
      fSQL.Add('    c.name NOME,                                          ');
      fSQL.Add('	CASE                                                    ');
      fSQL.Add('      WHEN t.Name = "numeric" THEN "ftFloat"              ');
      fSQL.Add('      WHEN t.Name = "varchar" THEN "ftString"             ');
      fSQL.Add('      WHEN t.Name = "date" THEN "ftDateTime"              ');
      fSQL.Add('      WHEN t.Name = "timestamp" THEN "ftTimeStamp"        ');
      fSQL.Add('      WHEN t.Name = "text" THEN "ftBlob"                  ');
      fSQL.Add('      WHEN t.Name = "float" THEN "ftFloat"                ');
      fSQL.Add('	  WHEN t.Name = "int" THEN "ftInteger"                  ');
      fSQL.Add('  END TIPO,                                               ');
      fSQL.Add('    C.max_length TAMANHO,                                 ');
      fSQL.Add('    C.column_id ORDEM                                     ');
      fSQL.Add('FROM                                                      ');
      fSQL.Add('    sys.columns c                                         ');
      fSQL.Add('INNER JOIN                                                ');
      fSQL.Add('    sys.types t ON c.user_type_id = t.user_type_id        ');
      fSQL.Add('WHERE                                                     ');
      fSQL.Add('    c.object_id = OBJECT_ID(:TABELA)                      ');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT');
      fSQL.Add('    COLUNAS.COLUMN_NAME AS NOME,');
      fSQL.Add('    CASE');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''NUMBER'' THEN ''ftFloat''');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''VARCHAR2'' THEN ''ftString''');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''DATE'' THEN ''ftDateTime''');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''TIMESTAMP(6)'' THEN ''ftTimeStamp''');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''BLOB'' THEN ''ftBlob''');
      fSQL.Add('        WHEN COLUNAS.DATA_TYPE = ''FLOAT'' THEN ''ftFloat''');
      fSQL.Add('    END TIPO');
      fSQL.Add('FROM');
      fSQL.Add('    USER_TABLES TABELAS,');
      fSQL.Add('    USER_TAB_COLUMNS COLUNAS');
      fSQL.Add('WHERE');
      fSQL.Add('    TABELAS.TABLE_NAME = COLUNAS.TABLE_NAME');
      fSQL.Add('    AND TABELAS.TABLE_NAME = :TABELA');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;


function TSQLSchemaDB.ListTablesColumnsKEY:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('select b.rdb$field_name as Campo');
      fSQL.Add('from rdb$relation_constraints a,');
      fSQL.Add('rdb$index_segments b');
      fSQL.Add('where a.rdb$relation_name = :TABELA');
      fSQL.Add('and a.rdb$constraint_type = ''PRIMARY KEY''');
      fSQL.Add('and b.rdb$index_name = a.rdb$index_name');
      fSQL.Add('order by a.rdb$index_name, b.rdb$field_position');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('select COLUMN_NAME CAMPO from information_schema.KEY_COLUMN_USAGE where TABLE_NAME= :TABELA');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT cols.COLUMN_NAME CAMPO');
      fSQL.Add('FROM all_constraints cons, all_cons_columns cols');
      fSQL.Add('WHERE cons.constraint_type = "P"');
      fSQL.Add('AND cons.constraint_name = cols.constraint_name');
      fSQL.Add('AND cons.owner = cols.owner');
      fSQL.Add('AND cols.table_name = :TABELA');
      fSQL.Add('ORDER BY cols.table_name');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

function TSQLSchemaDB.ListViews:string;
begin
   fSQL.Clear;
   if forigem.fbanco = mbFirebird then
   begin
      fSQL.Add('SELECT RDB$RELATION_NAME AS NOME');
      fSQL.Add('FROM RDB$RELATIONS');
      fSQL.Add('WHERE NOT RDB$VIEW_BLR IS NULL');
      fSQL.Add('ORDER BY RDB$RELATION_NAME');
   end else
   if forigem.fbanco = mbMSSQL then
   begin
      fSQL.Add('SELECT NAME NOME FROM dbo.sysobjects WHERE (type = "V") ORDER BY NAME');
   end else
   if forigem.fbanco = mbOracle then
   begin
      fSQL.Add('SELECT VIEW_NAME NOME FROM USER_VIEWS ORDER BY VIEW_NAME');
   end;

   fSQL.text := stringReplace(fSQL.text,'"','''',[rfReplaceAll]);
   result:=fSQL.Text;
end;

end.
