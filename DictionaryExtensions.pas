namespace Moshine.Foundation;

uses
  RemObjects.Elements.System;

type

{$IF ISLAND}


  DictionaryExtensions = public extension class(Object)
  public
    method ToDictionary:Dictionary<String,Object>;
    begin
      var dict := new Dictionary<String,Object>;
      try

        var propertyInfos := typeOf(self).Properties.Where(a ->
          not a.IsStatic and
          assigned(a.ReadMethod) and assigned(a.WriteMethod) and
          (a.Arguments.Count = 0)).ToList();

        for each propertyInfo in propertyInfos do
        begin
          var propertyValue := propertyInfo.GetValue(self,[]);
          dict.Add(propertyInfo.Name,propertyValue);
        end;

      except
        on ex:Exception do
        begin
          writeLn($'{ex.Message}');
          raise;
        end;
      end;
      exit dict;
    end;

  end;

{$ENDIF}


end.