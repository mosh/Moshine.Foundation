namespace Moshine.Foundation.AWS;

uses
  Dapper,
  Moshine.Foundation.Contracts,
  NodaTime;

type

  LocalDateTimeHandler = public class(SqlMapper.TypeHandler<LocalDateTime>)

  private
    property _connectionBuilder:IConnectionBuilder;
  public

    constructor(connectionBuilder:IConnectionBuilder);
    begin
      _connectionBuilder := connectionBuilder;
    end;

    method SetValue(parameter: System.Data.IDbDataParameter; value: LocalDateTime); override;
    begin
      if(_connectionBuilder.IsPostgres)then
      begin
        parameter.Value := value;
      end
      else
      begin
        parameter.Value := value.ToDateTimeUnspecified;
      end;
    end;

    method Parse(value: Object): LocalDateTime; override;
    begin
      if value is LocalDateTime then
      begin
        exit value as LocalDateTime;
      end;
      raise new NotImplementedException;
    end;

  end;
end.