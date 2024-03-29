﻿namespace Moshine.Foundation;

{$IFDEF ECHOES}
uses
  System;
{$ELSEIF TOFFEE OR DARWIN}
uses
  Foundation;
{$ENDIF}


type

  DateExtensions = public extension class(RemObjects.Elements.RTL.DateTime)

  private

  {$IFDEF ECHOES}
  const DefaultDateTimeFormat:String = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.FFFFFFFK";
  {$ENDIF}

  {$IF TOFFEE OR DARWIN}

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
      {$ELSEIF TOFFEE OR DARWIN}
      var outValue := FormatterForParsing1.dateFromString(value);
      if(not assigned(outValue))then
      begin
        outValue := FormatterForParsing2.dateFromString(value);
      end;
      exit outValue;
      {$ELSE}
      exit RemObjects.Elements.RTL.DateTime.TryParseISO8601(value);
      {$ENDIF}

    end;

    class method ToISO8601(value:RemObjects.Elements.RTL.DateTime):RemObjects.Elements.RTL.String;
    begin
      {$IF TOFFEE}
      exit FormatterForToString.stringFromDate(value);
      {$ELSEIF ECHOES}
      exit RemObjects.Elements.RTL.PlatformDateTime(value).ToString(DefaultDateTimeFormat, System.Globalization.CultureInfo.CurrentCulture);
      {$ELSE}
      exit $'{value.ToString('yyyy-MM-dd')}T{value.ToString('hh:mm:ss')}Z';
      {$ENDIF}
    end;

    class method Now:RemObjects.Elements.RTL.DateTime;
    begin
      {$IF TOFFEE}
      exit new RemObjects.Elements.RTL.PlatformDateTime;
      {$ELSE}
      exit RemObjects.Elements.RTL.PlatformDateTime.Now;
      {$ENDIF}
    end;

    class method TimeSinceEpochNow:Double;
    begin
      {$IF ECHOES}
      exit DateTimeOffset.Now.ToUnixTimeSeconds;
      {$ELSEIF TOFFEE}
      var date := new Foundation.NSDate;
      exit date.timeIntervalSince1970;
      {$ELSE}
      var span := RemObjects.Elements.Rtl.DateTime.TimeSince(new RemObjects.Elements.RTL.DateTime(1970,1,1));
      exit span.TotalSeconds;
      {$ENDIF}
    end;

    method TimeSinceEpoch:Double;
    begin
      var span := self - new RemObjects.Elements.RTL.DateTime(1970,1,1);
      exit span.TotalSeconds;
    end;

    method FirstOfMonth:RemObjects.Elements.RTL.DateTime;
    begin
      exit new RemObjects.Elements.RTL.DateTime(self.Year, self.Month,1);
    end;

    method FirstOfYear:RemObjects.Elements.RTL.DateTime;
    begin
      exit new RemObjects.Elements.RTL.DateTime(self.Year, 1,1);
    end;

    // DateTime.UTCNow gives UTC, this converts to local time
    method Local:RemObjects.Elements.RTL.DateTime;
    begin
      exit self.Add(RemObjects.Elements.RTL.TimeZone.Local.OffsetToUTC);
    end;



  end;

end.