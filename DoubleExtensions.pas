namespace Moshine.Foundation.Shared;

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
    {$ENDIF}

  end;

end.