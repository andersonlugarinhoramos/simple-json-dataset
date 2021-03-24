unit Simple.JSON.DataSet;

interface

uses
  VCl.StdCtrls,

  System.Classes,
  System.SysUtils,
  System.JSON,

  Data.DB,

  REST.Response.Adapter;

type
  TSimpleJSONDataSetHelper = class Helper for TDataSet
  private
    procedure JSONObjectToDataSet(AValue: String);
    procedure JSONArrayToDataSet(AValue: String);
  public
    procedure JSONToDataSet(AValue: String);
    function DataSetToJSON: String;
  end;

implementation

{ TSimpleJSONDataSet }

procedure TSimpleJSONDataSetHelper.JSONArrayToDataSet(AValue: String);
var
  FJSON: TJSONArray;
  FConversion : TCustomJSONDataSetAdapter;
begin
  FJSON := TJSONObject.ParseJSONValue(AValue) as TJSONArray;
  FConversion := TCustomJSONDataSetAdapter.Create(Nil);

  try
    FConversion.Dataset := Self;
    FConversion.UpdateDataSet(FJSON);
  finally
    FConversion.Free;
    FJSON.Free;
  end;
end;

procedure TSimpleJSONDataSetHelper.JSONObjectToDataSet(AValue: String);
var
  FJSON: TJSONObject;
  FConversion : TCustomJSONDataSetAdapter;
begin
  FJSON := TJSONObject.ParseJSONValue(AValue) as TJSONObject;
  FConversion := TCustomJSONDataSetAdapter.Create(Nil);

  try
    FConversion.Dataset := Self;
    FConversion.UpdateDataSet(FJSON);
  finally
    FConversion.Free;
    FJSON.Free;
  end;
end;

procedure TSimpleJSONDataSetHelper.JSONToDataSet(AValue: String);
begin
  if (AValue = EmptyStr) then
  begin
    Exit;
  end;

  if Copy(AValue,1,1) = '[' then
    JSONArrayToDataSet(AValue)
  else
    JSONObjectToDataSet(AValue);
end;

function TSimpleJSONDataSetHelper.DataSetToJSON: String;
var
  FColumnName: String;
  FJSONObject: TJsonObject;
  FJSONArray: TJSONArray;
  FPosition: TBookmark;
begin
  FJSONArray := TJSONArray.Create;
  try
    if Self.Active then
    begin
      Self.GotoBookmark(FPosition);
      try
        Self.DisableControls;
        Self.First;

        while not(Self.Eof) do
        begin
          FJSONObject := TJSONObject.Create;
          try
            for var I := 0 to Self.FieldDefs.Count-1 do
            begin
              FColumnName := Self.FieldDefs[I].Name;

              case Self.Fields[I].Datatype of
                ftBoolean:
                begin
                  if Self.Fields[I].AsBoolean = True then
                    FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONTrue.Create))
                  else
                    FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONFalse.Create));
                end;

                ftInteger,
                ftFloat,
                ftSmallint,
                ftWord,
                ftCurrency :
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONNumber.Create(Self.Fields[I].Value)));
                end;

                ftDate:
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONString.Create(FormatDateTime('yyyy-mm-dd', Self.Fields[I].AsDateTime))));
                end;

                ftDatetime:
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONString.Create(FormatDateTime('yyyy-mm-dd hh:mm:ss', Self.Fields[I].AsDateTime))));
                end;

                ftTime:
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONString.Create(FormatDateTime('hh:mm:ss', Self.Fields[I].AsDateTime))));
                end;

              else
                FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ),TJSONString.Create(Self.Fields[I].AsString)));
              end;
            end;
          finally
            FJSONArray.Add(FJSONObject);
          end;
          Self.Next;
        end;
      finally
        Self.GotoBookmark(FPosition);
        Self.FreeBookmark(FPosition);
        Self.EnableControls;
      end;
    end;
  finally
    Result := FJSONArray.ToString;
    FJSONArray.Free;
  end;
end;

end.
