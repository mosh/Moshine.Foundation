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

  {$IF TOFFEE}
  class property StandardFormatter : NSISO8601DateFormatter read
    begin
      var options := NSISO8601DateFormatOptions.WithInternetDateTime or NSISO8601DateFormatOptions.WithDashSeparatorInDate or NSISO8601DateFormatOptions.WithColonSeparatorInTime or NSISO8601DateFormatOptions.WithColonSeparatorInTimeZone;
      var formatter := new NSISO8601DateFormatter;
      formatter.timeZone := NSTimeZone.localTimeZone;
      formatter.formatOptions := options;
      exit formatter;
    end;
  {$ENDIF}

  public

    class method ParseISO8601DateTime(value:String):RemObjects.Elements.RTL.DateTime;
    begin
      {$IFDEF ECHOES}
      exit System.DateTime.ParseExact(value, DefaultDateTimeFormat,nil);
      {$ELSEIF TOFFEE}
      exit StandardFormatter.dateFromString(value);
      {$ELSE}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}

    end;

    class method ToISO8601(value:RemObjects.Elements.RTL.DateTime):String;
    begin
      {$IFDEF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime(value).ToString(DefaultDateTimeFormat, System.Globalization.CultureInfo.CurrentCulture);
      {$ELSEIF TOFFEE}
      exit StandardFormatter.stringFromDate(value);
      {$ELSE}
      raise RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}
    end;

    class method Now:DateTime;
    begin
      {$IFDEF ECHOES}
      exit PlatformDateTime.Now;
      {$ELSEIF TOFFEE}
      exit new PlatformDateTime;
      {$ELSE}
      raise RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}

    end;

  end;

end.