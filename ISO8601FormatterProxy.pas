namespace Moshine.Foundation;

uses
  Foundation,
  {$IF NOT TARGET_OS_IPHONE}
  NJISO8601,
  {$ENDIF}
  ThirdParty;

type

  ISO8601FormatterProxy = public class
  private
  {$IF NOT TARGET_OS_IPHONE}
    useNJ:Boolean;
  {$ENDIF}
  protected
    method BuildISOFormatter:ISO8601DateFormatter;
    begin
      var formatter := new ISO8601DateFormatter;
      formatter.includeTime := true;
      exit formatter;
    end;

    {$IF NOT TARGET_OS_IPHONE}
    method BuildNJFormatter:NJISO8601Formatter;
    begin
      var formatter := new NJISO8601.NJISO8601Formatter;
      formatter.timeZoneStyle := NJISO8601FormatterTimeZoneStyle.NJISO8601FormatterTimeZoneStyleExtended;
      exit formatter;
    end;
    {$ENDIF}

  public
    method dateFromString(stringValue: Foundation.NSString): Foundation.NSDate;
    begin
      {$IF NOT TARGET_OS_IPHONE}
      if useNJ then
      begin
        var formatter := BuildNJFormatter;
        exit formatter.dateFromString(stringValue);
      end;
      {$ENDIF}
      var formatter := BuildISOFormatter;
      exit formatter.dateFromString(stringValue);

    end;

    method stringFromDate(dateValue: Foundation.NSDate): Foundation.NSString;
    begin
    {$IF NOT TARGET_OS_IPHONE}
      if useNJ then
      begin
        var formatter := BuildNJFormatter;
        exit formatter.stringFromDate(dateValue);
      end;
    {$ENDIF}
      var formatter := BuildISOFormatter;
      exit formatter.stringFromDate(dateValue);

    end;

    constructor;
    begin
    {$IF NOT TARGET_OS_IPHONE}
      useNJ := true;
    {$ENDIF}
    end;

  end;

end.