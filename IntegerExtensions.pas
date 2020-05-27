namespace Moshine.Foundation;

{$IF TOFFEE}

uses
  Foundation, RemObjects.Elements.RTL;

type

  IntegerExtensions = public extension class(Integer)
  public
    method AsMonthDay:String;
    begin
      case self of
        1,21,31:
        exit NSString.stringWithFormat('%dst', self);
        2,22:
        exit NSString.stringWithFormat('%dnd', self);
        3,23:
        exit NSString.stringWithFormat('%drd', self);
        else
          exit NSString.stringWithFormat('%dth', self);
      end;

    end;

    method ForDisplay: String;
    begin
      exit self.FormatIntegerForDisplay;
    end;

    method AsDuration: String;
    begin
      var someValue := self;
      exit someValue.FormatAsDuration;
    end;

    method FormatIntegerForDisplay:NSString;
    begin
      exit NSString.stringWithFormat('%d', self);
    end;

    method FormatAsDuration:String;
    begin
      var span := new TimeSpan(0,self,0);
      var value := '';

      if(span.Days > 0)then
      begin
        value := $'{span.Days} Day(s)';

        if(span.Hours > 0)then
        begin
          value := value + ' {span.Hours} Hour(s)';
        end;
        if(span.Minutes > 0)then
        begin
          value := value + ' {span.Minutes} Minute(s)';
        end;

      end
      else if (span.Hours > 0) then
      begin
        value := iif(span.Minutes > 0, $'{span.Hours} Hour(s) {span.Minutes} Minute(s)', $'{span.Hours} Hour(s)');
      end
      else if (span.Minutes > 0)then
      begin
        value := $'{span.Minutes} Minute(s)';
      end
      else
      begin
        value := 'No time has been recorded';
      end;
      exit value;
    end;

  end;

{$ENDIF}

end.