unit Simple.JSON.DataSet;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,

  Data.DB,

  REST.Response.Adapter;

type
  TypeReturn = (tpJSONObject, tpJSONArray);

  TSimpleJSONDataSetHelper = class Helper for TDataSet
  private
     function DataSetToJSON(AType: TypeReturn): TJSONAncestor;
     procedure JSONToDataSet(AValue: String);
  public
    procedure LoadFromJSON(const AValue: TJSONObject); overload;
    procedure LoadFromJSON(const AValue: TJSONArray); overload;
    procedure LoadFromJSON(const AValue: String); overload;
    function ToJSONObject: TJSONObject;
    function ToJSONArray: TJSONArray;

  end;

implementation

{ TSimpleJSONDataSet }

procedure TSimpleJSONDataSetHelper.LoadFromJSON(const AValue: TJSONObject);
begin
  JSONToDataSet(AValue.ToString);
end;

procedure TSimpleJSONDataSetHelper.LoadFromJSON(const AValue: TJSONArray);
begin
  JSONToDataSet(AValue.ToString);
end;

procedure TSimpleJSONDataSetHelper.LoadFromJSON(const AValue: String);
begin
  JSONToDataSet(AValue);
end;

function TSimpleJSONDataSetHelper.ToJSONObject: TJSONObject;
begin
  Result := TJSONObject(DataSetToJSON(tpJSONObject));
end;

function TSimpleJSONDataSetHelper.ToJSONArray: TJSONArray;
begin
  Result := TJSONArray(DataSetToJSON(tpJSONArray));
end;

procedure TSimpleJSONDataSetHelper.JSONToDataSet(AValue: String);
var
  FJSON: TJSONValue;
  FConversion : TCustomJSONDataSetAdapter;
begin
  if (AValue = EmptyStr) then
  begin
    Exit;
  end;

  FJSON := TJSONObject.ParseJSONValue(AValue);
  FConversion := TCustomJSONDataSetAdapter.Create(nil);

  try
    FConversion.Dataset := Self;
    FConversion.UpdateDataSet(FJSON);
  finally
    FConversion.Free;
    FJSON.Free;
  end;
end;

function TSimpleJSONDataSetHelper.DataSetToJSON(AType: TypeReturn): TJSONAncestor;
var
  FColumnName: String;
  FJSONObject: TJsonObject;
  FJSONArray: TJSONArray;
  FPosition: TBookmark;
begin
  FJSONArray := TJSONArray.Create;
  FJSONObject := TJSONObject.Create;

  Result := FJSONArray;
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
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONNumber.Create(Self.Fields[I].AsFloat)));
                end;

                ftDate:
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONString.Create(FormatDateTime('dd/mm/yyyy', Self.Fields[I].AsDateTime))));
                end;

                ftDatetime:
                begin
                  FJSONObject.AddPair(TJSONPair.Create(TJSONString.Create( FColumnName ), TJSONString.Create(FormatDateTime('dd/mm/yyyy hh:mm:ss', Self.Fields[I].AsDateTime))));
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
    case AType of
      tpJSONArray : Result := FJSONArray;
      tpJSONObject : Result := FJSONObject;
    end;
  end;
end;

end.
