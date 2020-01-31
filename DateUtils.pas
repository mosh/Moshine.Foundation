namespace Moshine.Foundation;

uses
  Foundation;

type


  DateUtils = public class
  public

    class method epochToDate(epoch:Double):NSDate;
    begin
      exit NSDate.dateWithTimeIntervalSince1970(epoch);
    end;
  end;


end.