unit Simple.JSON.DataSet;

interface

uses
  VCl.StdCtrls,

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

end.
