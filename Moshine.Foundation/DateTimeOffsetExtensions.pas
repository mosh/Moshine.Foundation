namespace Moshine.Foundation;

{$IFDEF ECHOES}

uses
  NodaTime;

type
  DateTimeOffsetExtensions = public extension class(DateTimeOffset)
  public
    method OffsetToLocalDateTime:LocalDateTime;
    begin
      var zoned := ZonedDateTime.FromDateTimeOffset(self);
      exit zoned.LocalDateTime.PlusMilliseconds(zoned.Offset.Milliseconds);
    end;
 end;
{$ENDIF}

end.