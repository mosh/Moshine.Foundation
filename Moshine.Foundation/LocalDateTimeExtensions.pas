namespace Moshine.Foundation;

{$IFDEF ECHOES}

uses
  NodaTime, NodaTime.TimeZones;

type
  LocalDateTimeExtensions = public extension class(LocalDateTime)

  public
    method ToDateTimeOffset(offsetInHours:Integer):DateTimeOffset;
    begin
      var time := self.PlusHours(offsetInHours);
      var tz := BclDateTimeZone.ForOffset(Offset.FromHours(offsetInHours));
      var timeInZone := time.InZoneLeniently(tz);
      exit timeInZone.ToDateTimeOffset;
    end;

  end;
{$ENDIF}
end.