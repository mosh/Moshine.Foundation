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

  class property FormatterForParsing1 : NSISO8601DateFormatter read
    begin
      var formatter := new NSISO8601DateFormatter;
      formatter.timeZone := NSTimeZone.localTimeZone;
      formatter.formatOptions := NSISO8601DateFormatOptions.WithInternetDateTime;
      exit formatter;
    end;

  class property FormatterForParsing2 : NSISO8601DateFormatter read
    begin
      var formatter := new NSISO8601DateFormatter;
      formatter.timeZone := NSTimeZone.localTimeZone;
      formatter.formatOptions := NSISO8601DateFormatOptions.WithInternetDateTime or NSISO8601DateFormatOptions.WithFractionalSeconds;
      exit formatter;
    end;


  class property FormatterForToString : NSISO8601DateFormatter read
    begin
      var formatter := new NSISO8601DateFormatter;
      formatter.timeZone := NSTimeZone.localTimeZone;
      formatter.formatOptions := NSISO8601DateFormatOptions.WithInternetDateTime or NSISO8601DateFormatOptions.WithDashSeparatorInDate or NSISO8601DateFormatOptions.WithColonSeparatorInTime or NSISO8601DateFormatOptions.WithColonSeparatorInTimeZone;
      exit formatter;
    end;

  {$ENDIF}

  public

    class method ParseISO8601DateTime(value:String):RemObjects.Elements.RTL.DateTime;
    begin
      {$IFDEF ECHOES}
      exit System.DateTime.ParseExact(value, DefaultDateTimeFormat,nil);
      {$ELSEIF TOFFEE}
      var outValue := FormatterForParsing1.dateFromString(value);
      if(not assigned(outValue))then
      begin
        outValue := FormatterForParsing2.dateFromString(value);
      end;
      exit outValue;
      {$ELSE}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}

    end;

    class method ToISO8601(value:RemObjects.Elements.RTL.DateTime):RemObjects.Elements.RTL.String;
    begin
      {$IFDEF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime(value).ToString(DefaultDateTimeFormat, System.Globalization.CultureInfo.CurrentCulture);
      {$ELSEIF TOFFEE}
      exit FormatterForToString.stringFromDate(value);
      {$ELSE}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}
    end;

    class method Now:RemObjects.Elements.RTL.DateTime;
    begin
      {$IFDEF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime.Now;
      {$ELSEIF TOFFEE}
      exit new RemObjects.Elements.RTL.PlatformDateTime;
      {$ELSE}
      raise new RemObjects.Elements.RTL.NotImplementedException;
      {$ENDIF}

    end;

  end;

end.