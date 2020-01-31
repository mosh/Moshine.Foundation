namespace Moshine.Foundation;

{$IFDEF ECHOES}
uses
  System;
{$ELSEIF TOFFEE}
uses
  Foundation;
{$ENDIF}


type

  DateExtensions = public extension class(RemObjects.Elements.RTL.DateTime)

  private

  {$IFDEF ECHOES}
  const DefaultDateTimeFormat:String = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.FFFFFFFK";
  {$ENDIF}

  public




    class method ParseISO8601DateTime(value:String):RemObjects.Elements.RTL.DateTime;
    begin
      {$IFDEF ECHOES}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ELSEIF TOFFEE}
      var formatter := new NSISO8601DateFormatter;
      exit formatter.dateFromString(value);
      {$ELSE}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}

    end;

    class method ToISO8601(value:RemObjects.Elements.RTL.DateTime):String;
    begin
      {$IFDEF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime(value).ToString(DefaultDateTimeFormat, System.Globalization.CultureInfo.CurrentCulture);
      {$ELSEIF TOFFEE}
      var formatter := new NSISO8601DateFormatter;
      exit formatter.stringFromDate(value);
      {$ELSE}
      raise RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}


    end;

  end;

end.