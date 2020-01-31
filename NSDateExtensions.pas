namespace Moshine.Foundation;

uses
  Foundation, RemObjects.Elements.RTL;

type

  NSDateExtensions = public extension class(NSDate)
  public

    method ForDisplay: String;
    begin
      exit self.FormatDateForDisplay;
    end;

    method Month:String;
    begin
      var formatter := new NSDateFormatter;
      formatter.setDateFormat("MMMM");
      exit formatter.stringFromDate(self);
    end;

    method Year:String;
    begin
      var formatter := new NSDateFormatter;
      formatter.setDateFormat("YYYY");
      exit formatter.stringFromDate(self);
    end;


    method WeekShorterForm:String;
    begin
      var someDate:DateTime := self;
      var gregorian := new NSCalendar WithCalendarIdentifier(NSCalendarIdentifierGregorian);
      var comps := gregorian.components(NSCalendarUnit.CalendarUnitWeekday) fromDate(self);
      var weekday := comps.weekday;
      var day:String;

      case weekday of
        1: day := 'Sun';
        2: day := 'Mon';
        3: day := 'Tues';
        4: day := 'Wed';
        5: day := 'Thurs';
        6: day := 'Fri';
        7: day := 'Sat';
      end;

      exit NSString.stringWithFormat('%@ %@', day,someDate.Day.AsMonthDay);
    end;


    method WeekShortForm:String;
    begin
      var someDate:DateTime := self;
      var dateFormatter := new NSDateFormatter;
      dateFormatter.setDateFormat('EEEE');
      exit NSString.stringWithFormat('%@ %@', dateFormatter.stringFromDate(self),someDate.Day.AsMonthDay);

    end;

    method MonthShortForm:String;
    begin
      var someDate:DateTime := self;
      case someDate.Month of
        1: exit NSString.stringWithFormat('Jan %@', someDate.Day.AsMonthDay);
        2: exit NSString.stringWithFormat('Feb %@', someDate.Day.AsMonthDay);
        3: exit NSString.stringWithFormat('Mar %@', someDate.Day.AsMonthDay);
        4: exit NSString.stringWithFormat('Apr %@', someDate.Day.AsMonthDay);
        5: exit NSString.stringWithFormat('May %@', someDate.Day.AsMonthDay);
        6: exit NSString.stringWithFormat('June %@', someDate.Day.AsMonthDay);
        7: exit NSString.stringWithFormat('July %@', someDate.Day.AsMonthDay);
        8: exit NSString.stringWithFormat('Aug %@', someDate.Day.AsMonthDay);
        9: exit NSString.stringWithFormat('Sept %@', someDate.Day.AsMonthDay);
        10: exit NSString.stringWithFormat('Oct %@', someDate.Day.AsMonthDay);
        11: exit NSString.stringWithFormat('Nov %@', someDate.Day.AsMonthDay);
        12: exit NSString.stringWithFormat('Dec %@', someDate.Day.AsMonthDay);
      end;
    end;

    method FormatDateForDisplay:NSString;
    begin
      exit NSDateFormatter.localizedStringFromDate(self) dateStyle(NSDateFormatterStyle.NSDateFormatterShortStyle ) timeStyle(NSDateFormatterStyle.NSDateFormatterNoStyle );
    end;

    method FormatDateTimeForDisplay:NSString;
    begin
      var dateFormatter := new NSDateFormatter;
      dateFormatter.setDateFormat('E, d MMM HH:mm zzz');

      exit dateFormatter.stringFromDate(self)
    end;

  end;


end.