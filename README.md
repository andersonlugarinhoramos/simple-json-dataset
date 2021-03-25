# Simple-JSON-DataSet for Delphi
JSONObject as DataSet


```delphi
use
  Simple.JSON.DataSet;

begin
  DataSet.LoadFromJSON(JSONObject);    
end.
```
JSONArray as DataSet


```delphi
use
  Simple.JSON.DataSet;

begin
  DataSet.LoadFromJSON(JSONArray);
end.
```
JSONString as DataSet


```delphi
use
  Simple.JSON.DataSet;

begin
  DataSet.LoadFromJSON(String);
end.
```

DataSet as JSONObject


```delphi
use
  Simple.JSON.DataSet;

begin
  DataSet.ToJSONObject;
end.
```
DataSet as JSONArray


```delphi
use
  Simple.JSON.DataSet;

begin
  DataSet.ToJSONArray;
end.
```
