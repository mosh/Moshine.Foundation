namespace Moshine.Foundation;

type

  DateExtensions = public extension class(RemObjects.Elements.RTL.DateTime)

  private

  {$IFDEF ECHOES}
  const DefaultDateTimeFormat:String = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.FFFFFFFK";
  {$ENDIF}

  public




    class method ParseISO8601DateTime(value:String):RemObjects.Elements.RTL.DateTime;
    begin

    end;

    class method ToISO8601(value:RemObjects.Elements.RTL.DateTime):String;
    begin
      {$IFDEF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime(value).ToString(DefaultDateTimeFormat, System.Globalization.CultureInfo.CurrentCulture);
      {$ELSEIF TOFFEE}
      {$ELSE}
      raise RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}


    end;

  end;

end.