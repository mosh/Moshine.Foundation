namespace Moshine.Foundation;

{$IF TOFFEE OR DARWIN}
uses
  Foundation;
{$ENDIF}
type

  FoundationDoubleExtensions = public extension class(Double)
  private
  protected
  public

    {$IF TOFFEE OR DARWIN}
    method epochToDate:Foundation.NSDate;
    begin
      exit Foundation.NSDate.dateWithTimeIntervalSince1970(self);
    end;

    method ToString(precision:Integer := 2):String;
    begin
      var formatter := new NSNumberFormatter;
      formatter.minimumFractionDigits := precision;
      formatter.maximumFractionDigits := precision;
      exit formatter.stringFromNumber(self);
    end;

    {$ENDIF}

  end;

end.