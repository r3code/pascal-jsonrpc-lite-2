//
// Author: Dmitriy S. Sinyavskiy, 2016
//
unit ujsonrpccustomerrors;

{$IFDEF FPC}
{$MODE objfpc}
{$ENDIF}

interface

uses
  Classes, SysUtils, superobject, ujsonrpc;

type

  { TJsonRpcCustomError }

  TJsonRpcCustomError = class
    class function ProcedureException(data: ISuperObject): IJsonRpcError;
      overload;
    class function ProcedureException(data: string): IJsonRpcError; overload;
    class function AuthError(data: ISuperObject): IJsonRpcError; overload;
    class function AuthError(data: string): IJsonRpcError; overload;
  end;

implementation

const
  errorProcedureException = 'Procedure Exception';
  codeProcedureException = -32200;
  errorAuthError = 'Authentication Error';
  codeAuthError = -32201;

{ TJsonRpcCustomError }

class function TJsonRpcCustomError.ProcedureException(data: ISuperObject
  ): IJsonRpcError;
begin
  result := TJsonRpcError.Error(codeProcedureException, errorProcedureException,
    data);
end;

class function TJsonRpcCustomError.ProcedureException(
  data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Error(codeProcedureException, errorProcedureException,
    data);
end;

class function TJsonRpcCustomError.AuthError(data: ISuperObject): IJsonRpcError;
begin
  result := TJsonRpcError.Error(codeAuthError, errorAuthError, data);
end;

class function TJsonRpcCustomError.AuthError(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Error(codeAuthError, errorAuthError, data);
end;

end.
