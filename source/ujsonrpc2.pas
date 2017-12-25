//
// Author: Dmitriy S. Sinyavskiy, 2017
//
unit ujsonrpc2;
{$IFDEF FPC}
{$MODE objfpc}
{$H+} // make string type AnsiString
{$ENDIF}

interface

uses
  Classes,
  SysUtils,
  superobject;

type
  IJsonRpcMessage = interface
    ['{E9536C8C-5789-4ED1-BAEB-331E6B4CE70A}']
    function AsJSON(indent: boolean = false; escape: boolean = true): string;
    function AsJsonObject: ISuperObject;
  end;

  { TJsonRpcObjectType }

  // Parsed RPC message types
  TJsonRpcObjectType = (jotInvalid, jotRequest, jotNotification, jotSuccess,
    jotError);

  IJsonRpcParsedMessage = interface
    ['{9BC6D534-8EA4-4D5D-9D35-358D717D91DA}']
    function GetMessageType: TJsonRpcObjectType;
    function GetMessagePayload: IJsonRpcMessage;
  end;

  IJsonRpcError = interface
    ['{574043CE-CA33-462F-AF52-49C5B63FF58B}']
    function GetCode: Integer;
    function GetMessage: String;
    function GetData: ISuperObject;
    function AsJsonObject: ISuperObject;
    // props
    property Code: Integer read GetCode;
    property Message: String read GetMessage;
    property Data: ISuperObject read GetData;
  end;

  TJsonRpcRequestObject = class;
  TJsonRpcNotificationObject = class;
  TJsonRpcSuccessObject = class;
  TJsonRpcErrorObject = class;
  TJsonRpcError = class;

  { TJsonRpcMessage }

  TJsonRpcMessage = class(TInterfacedObject, IJsonRpcMessage)
    class function Request(const id: string; const method: string;
      params: ISuperObject): TJsonRpcRequestObject;
    class function Notification(const method: string;
      params: ISuperObject): TJsonRpcNotificationObject; overload;
    class function Notification(const method: string): TJsonRpcNotificationObject;
      overload;
    class function Success(const id: string;
      resultData: ISuperObject): TJsonRpcSuccessObject; overload;
    class function Error(const id: string;
      errorInfo: IJsonRpcError): TJsonRpcErrorObject; overload;
    class function Error(errorInfo: IJsonRpcError): TJsonRpcErrorObject; overload;
    class function Parse(const s: string;
      out AParseError: IJsonRpcError): IJsonRpcParsedMessage;
  public
    function AsJSON(indent: boolean = false; escape: boolean = true): string;
    function AsJsonObject: ISuperObject; virtual; abstract;
  end;

  { TJsonRpcNotificationObject }

  TJsonRpcNotificationObject = class(TJsonRpcMessage, IJsonRpcMessage)
  private
    FMethod: string;
    FParams: ISuperObject;
  public
    constructor Create(const AMethod: string; AParams: ISuperObject); overload;
    constructor Create(const aMethod: string); overload;
    function AsJsonObject: ISuperObject; override;
  published
    property Method: string read FMethod;
    property Params: ISuperObject read FParams;
  end;

  { TJsonRpcRequestObject }

  TJsonRpcRequestObject = class(TJsonRpcNotificationObject, IJsonRpcMessage)
  private
    FID: string;
  public
    constructor Create(const aID: string; const aMethod: string; aParams:
      ISuperObject);
    function AsJsonObject: ISuperObject; override;
  published
    property ID: string read FID;
    property Method;
    property Params;
  end;

  { TJsonRpcSuccessObject }

  TJsonRpcSuccessObject = class(TJsonRpcMessage, IJsonRpcMessage)
  private
    FID: string;
    FResult: ISuperObject;
  public
    constructor Create(const aID: string; AResult: ISuperObject);
    function AsJsonObject: ISuperObject; override;
  published
    property ID: string read FID;
    // Holds Variant type object, can be string, ISuperObject, Int, etc
    // Use GetResult.DataType property to detect actual type.
    property Result: ISuperObject read FResult;
  end;

  { TJsonRpcErrorObject }

  // ErrorObject message contains id and errorInfo
  TJsonRpcErrorObject = class(TJsonRpcMessage, IJsonRpcMessage)
  private
    FErrorInfo: IJsonRpcError;
    FID: string;
  public
    constructor Create(AErrorInfo: IJsonRpcError); overload;
    constructor Create(const AID: string; AErrorInfo: IJsonRpcError); overload;
    function AsJsonObject: ISuperObject; override;
  published
    property ID: string read FID;
    property ErrorInfo: IJsonRpcError read FErrorInfo;
  end;

  { TJsonRpcParsedMessage }

  // Represents parsed result, contains type of parsed message and parsed
  // data as one of TJsonRpcRequestObject, TJsonRpcNotificationObject,
  // TJsonRpcSuccessObject, TJsonRpcErrorObject
  TJsonRpcParsedMessage = class(TInterfacedObject, IJsonRpcParsedMessage)
  private
    FObjType: TJsonRpcObjectType;
    FPayload: IJsonRpcMessage;
  public
    constructor Create(const objType: TJsonRpcObjectType;
      Payload: IJsonRpcMessage);
    destructor Destroy; override;
    function GetMessageType: TJsonRpcObjectType;
    function GetMessagePayload: IJsonRpcMessage;
  end;

  { TJsonRpcError }

  // Error information: code, message, data
  TJsonRpcError = class(TInterfacedObject, IJsonRpcError)
    class function Error(const code: integer; const message: string; data:
      ISuperObject): IJsonRpcError; overload;
    class function Error(const code: integer; const message: string; dataStr:
      string): IJsonRpcError; overload;
    class function ParseError(data: string): IJsonRpcError;
    class function InvalidRequest(data: ISuperObject): IJsonRpcError; overload;
    class function InvalidRequest(data: string): IJsonRpcError; overload;
    class function MethodNotFound(data: ISuperObject): IJsonRpcError; overload;
    class function MethodNotFound(data: string): IJsonRpcError; overload;
    class function InvalidParams(data: ISuperObject): IJsonRpcError; overload;
    class function InvalidParams(data: string): IJsonRpcError; overload;
    class function InternalError(data: ISuperObject): IJsonRpcError; overload;
    class function InternalError(data: string): IJsonRpcError; overload;
  private
    FCode: Integer;
    FData: ISuperObject;
    FMessage: String;
  public
    constructor Create(const code: integer; const message: string); overload;
    constructor Create(const code: integer; const message: string;
      data: ISuperObject); overload;
    constructor Create(const code: integer; const message: string;
      data: string); overload;
    function GetCode: Integer;
    function GetMessage: String;
    function GetData: ISuperObject;
    function AsJsonObject: ISuperObject;
  published
    property Code: Integer read GetCode;
    property Message: String read GetMessage;
    property Data: ISuperObject read GetData;
  end;

const
  JSON_RPC_VERSION_2 = '2.0';

  FIELD_JSONRPC = 'jsonrpc';
  FIELD_ID = 'id';
  FIELD_METHOD = 'method';
  FIELD_PARAMS = 'params';
  FIELD_RESULT = 'result';
  FIELD_ERROR = 'error';
  FIELD_ERROR_CODE = 'code';
  FIELD_ERROR_MSG = 'message';
  FIELD_ERROR_DATA = 'data';

  ERROR_INVALID_JSONRPC_VER = 'Invalid JSON-RPC Version. Supported JSON-RPC 2.0 only';
  ERROR_NO_JSONRPC_FIELD = 'No ''jsonrpc'' field present';
  ERROR_NO_ID_FIELD = 'No ''id'' field present';
  ERROR_NO_METHOD_FIELD = 'No ''method'' field present';
  ERROR_NO_RESULT_FIELD = 'No ''result'' field present';
  ERROR_NO_ERROR_FIELD = 'No ''error'' field present';
  ERROR_INVALID_REQUEST_ID = 'Invalid Request ''id'', MUST BE not empty string or integer';
  ERROR_INVALID_REQUEST_ID_TYPE = 'Invalid Request ''id'' data type, it should be string or integer';
  ERROR_INVALID_ERROR_ID_TYPE = 'Invalid Error ''id'' data type, it should be string or integer';
  ERROR_INVALID_ERROR_ID = 'Invalid Error ''id'', MUST BE not empty string, integer or null';
  ERROR_INVALID_METHOD_NAME = 'Empty ''method'' field';
  ERROR_INVALID_ERROR_OBJ = 'Invalid ''error'' object';
  ERROR_INVALID_ERROR_CODE = 'Invalid ''error.code'', it MUST BE in the range [-32768..-32000]';
  ERROR_INVALID_ERROR_MSG = 'Empty ''error.message''';

  PRC_ERR_INVALID_REQUEST = 'Invalid Request';
  PRC_ERR_METHOD_NOT_FOUND = 'Method Not Found';
  RPC_ERR_INVALID_PARAMS = 'Invalid Params';
  RPC_ERR_INTERNAL_ERROR = 'Internal Error';
  RPC_ERR_PARSE_ERROR = 'Parse Error';

  CODE_INVALID_REQUEST = -32600;
  CODE_METHOD_NOT_FOUND = -32601;
  CODE_INVALID_PARAMS = -32602;
  CODE_INTERNAL_ERROR = -32603;
  CODE_PARSE_ERROR = -32700;

implementation

const
  S_EMPTY_STR = '';

{ TJsonRpcMessage }

function TJsonRpcMessage.AsJSON(indent: boolean; escape: boolean): string;
begin
  Result := AsJsonObject.AsJSon(indent, escape);
end;

{ TJsonRpcMessage }

// Creates JSON-RPC 2.0 request object
// @param  {String} id
// @param  {String} method
// @param  {ISuperObject} [params]: optional
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Request(const id: string;
  const method: string; params: ISuperObject): TJsonRpcRequestObject;
begin
  result := TJsonRpcRequestObject.Create(id, method, params);
end;

// Creates JSON-RPC 2.0 notification object
// @param  {String} method
// @param  {ISuperObject} [params]
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Notification(const method: string;
  params: ISuperObject): TJsonRpcNotificationObject;
begin
  Result := TJsonRpcNotificationObject.Create(method, params);
end;

// Creates JSON-RPC 2.0 notification object
// @param  {String} method
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Notification(const method: string):
  TJsonRpcNotificationObject;
begin
  result := TJsonRpcMessage.Notification(method, nil);
end;

// Creates JSON-RPC 2.0 success object
// @param  {string} id
// @param  {ISuperObject} requestResult
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Success(const id: string;
  resultData: ISuperObject): TJsonRpcSuccessObject;
begin
  result := TJsonRpcSuccessObject.Create(id, resultData);
end;


// Creates JSON-RPC 2.0 error object
// @param  {string} id
// @param  {ISuperObject} error
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Error(const id: string;
  errorInfo: IJsonRpcError): TJsonRpcErrorObject;
begin
  result := TJsonRpcErrorObject.Create(id, errorInfo);
end;

// Creates JSON-RPC 2.0 error object
// @param  {ISuperObject} error
// @return {ISuperObject} JsonRpc object

class function TJsonRpcMessage.Error(errorInfo: IJsonRpcError):
  TJsonRpcErrorObject;
begin
  result := TJsonRpcErrorObject.Create(errorInfo);
end;

//
// @return TJsonRpcParsedMessage
//

// Returns nil if ERROR and AParseError contains error info,
// else IJsonRpcParsedMessage
class function TJsonRpcMessage.Parse(const s: string;
  out AParseError: IJsonRpcError): IJsonRpcParsedMessage;

  // checks if 'id' field present in JSON
  function SubIsIdPresent(AJsonObj: ISuperObject): boolean;
  begin
    Result := AJsonObj.AsObject.Exists(FIELD_ID);
  end;

  // Checks if 'id' field present in JSON and has valid data type
  // for RPC Request object
  function SubIsRequestIdDefValid(AJsonObj: ISuperObject): boolean;
  begin
    // Request MUST have id value string or integer
    Result := SubIsIdPresent(AJsonObj)
      and (AJsonObj.O[FIELD_ID].DataType in [stInt, stString]);
  end;

  // Checks if 'id' field have valid value
  function SubIsRequestIdValueValid(AJsonObj: ISuperObject):Boolean;
  begin
    Result := SubIsRequestIdDefValid(AJsonObj)
      and (Trim(AJsonObj.S[FIELD_ID]) <> S_EMPTY_STR)
  end;

  // Checks if 'id' field present in JSON and has valid data type
  // for RPC Error Object
  function SubIsErrorIdDefValid(AJsonObj: ISuperObject): boolean;
  begin
    // errors MUST have id=null for Invalid Request, Parse Error
    Result := SubIsIdPresent(AJsonObj)
      and (AJsonObj.O[FIELD_ID].DataType in [stInt, stString, stNull]);
  end;

  // Checks if 'id' field have valid value for RPC Error Object
  function SubIsErrorIdValueValid(AJsonObj: ISuperObject): Boolean;
  begin
    Result:=SubIsErrorIdDefValid(AJsonObj)
      and (
        (Trim(AJsonObj.S[FIELD_ID]) <> S_EMPTY_STR)
        or
        ObjectIsNull(AJsonObj.O[FIELD_ID])
      );
  end;

  // Checks if 'method' field present in JSON
  function SubIsMethodPresent(AJsonObj: ISuperObject): boolean;
  begin
    Result := AJsonObj.AsObject.Exists(FIELD_METHOD);
  end;

  // Checks if 'method' field has valid data type
  function SubIsMethodDefValid(AJsonObj: ISuperObject): boolean;
  begin
    result := SubIsMethodPresent(AJsonObj)
      and (AJsonObj.O[FIELD_METHOD].DataType in [stString]);
  end;

  // Checks if 'method' field has valid structure and value
  function SubIsMethodValid(AJsonObj: ISuperObject): boolean;
  begin
    result := SubIsMethodDefValid(AJsonObj)
      and (Trim(AJsonObj.S[FIELD_METHOD]) <> S_EMPTY_STR);
  end;

  // Checks if 'params' field present in JSON
  function SubIsParamsPresent(AJsonObj: ISuperObject): boolean;
  begin
    Result:=AJsonObj.AsObject.Exists(FIELD_PARAMS);
  end;

  // Checks if 'params' field has valid structure and data type
  function SubIsParamsDefValid(AJsonObj: ISuperObject): boolean;
  begin
    Result:=SubIsParamsPresent(AJsonObj)
      and (AJsonObj.O[FIELD_PARAMS].DataType in [stArray, stObject]);
  end;

  // Checks if 'result' field present in JSON
  function SubIsResultPresent(AJsonObj: ISuperObject): boolean;
  begin
    Result:=AJsonObj.AsObject.Exists(FIELD_RESULT);
  end;

  // Checks if 'error' field present in JSON
  function SubIsErrorPresent(AJsonObj: ISuperObject): boolean;
  begin
    Result:=AJsonObj.AsObject.Exists(FIELD_ERROR);
  end;

  // Checks if RPC Error object has valid strucure
  function SubIsErrorObjDefValid(AJsonObj: ISuperObject): boolean;
  var
    errInfo: ISuperObject;
    errCodeDefValid, messageDefValid: boolean;
  begin
    Result:= SubIsErrorPresent(AJsonObj);
    errInfo := AJsonObj.O[FIELD_ERROR];
    errCodeDefValid := errInfo.AsObject.Exists(FIELD_ERROR_CODE)
      and (errInfo.O[FIELD_ERROR_CODE].DataType in [stInt]);
    messageDefValid := errInfo.AsObject.Exists(FIELD_ERROR_MSG)
      and (errInfo.O[FIELD_ERROR_MSG].DataType in [stString]);
    // 'data':any optional
    Result := Result and errCodeDefValid and messageDefValid;
  end;

  // Checks Error Code in allowed range
  function SubIsErrorCodeValid(const ACode: Integer): boolean;
  begin
    Result := (ACode <= -32000) and (ACode >= -32768);
  end;

  // Checks if 'error.message' not empty
  function SubIsErrorMessageValid(const AMsg: String): boolean;
  begin
    Result := (Trim(AMsg) <> S_EMPTY_STR);
  end;


  // Detects RPC message type by structure ONLY, no value checks here.
  // Do value validation in SubParse* functions.
  function SubGetMessageType(AJsonObj: ISuperObject): TJsonRpcObjectType;
  var
    ItLooksLikeNotification,
    ItLooksLikeRequest,
    ItLooksLikeSuccess,
    ItLooksLikeError: boolean;
  begin
    Result:=jotInvalid;
    // MUST have 'method':str and MUST NOT have 'id'
    ItLooksLikeNotification := not SubIsIdPresent(AJsonObj)
      and SubIsMethodDefValid(AJsonObj);
    if ItLooksLikeNotification then
    begin
      Result := jotNotification;
      Exit;
    end;
    // MUST have 'id':str/int, 'method':str
    ItLooksLikeRequest := SubIsRequestIdDefValid(AJsonObj)
      and SubIsMethodDefValid(AJsonObj);
    if ItLooksLikeRequest then
    begin
      Result := jotRequest;
      Exit;
    end;
    // MUST have 'id':str/int, 'result':any
    ItLooksLikeSuccess := SubIsRequestIdDefValid(AJsonObj)
      and SubIsResultPresent(AJsonObj);
    if ItLooksLikeSuccess then
    begin
      Result := jotSuccess;
      Exit;
    end;
    // MUST have 'id':str/int/null, 'error':errorInfo
    // where errorInfo = {code:int, message:str, data:any optional}
    ItLooksLikeError := SubIsErrorIdDefValid(AJsonObj)
      and SubIsErrorObjDefValid(AJsonObj);
    if ItLooksLikeError then
     begin
      Result := jotError;
      Exit;
    end;
  end;

  //
  // Parsing Errors detecting functions named SubCheck*
  //
  // Checks 'jsonrpc' field exists and valid.
  // Returns IJsonRpcError if not OK, or nil if no error
  function SubCheckHeader(AJsonObj: ISuperObject): IJsonRpcError;
  begin
    Result := nil;
    if not AJsonObj.AsObject.Exists(FIELD_JSONRPC) then
    begin
      Result := TJsonRpcError.InvalidRequest(SO(ERROR_NO_JSONRPC_FIELD));
      Exit;
    end;
    if AJsonObj.S[FIELD_JSONRPC] <> JSON_RPC_VERSION_2 then
    begin
      Result := TJsonRpcError.invalidRequest(SO(ERROR_INVALID_JSONRPC_VER));
      Exit;
    end;
  end;

  // Checks 'id' field exists, has corect type and not empty
  // for RPC Request Object.
  // Returns nil and not empty AFoundId if OK,
  // else IJsonRpcError and empty AFoundId.
  function SubCheckRequestId(AJsonObj: ISuperObject;
    var AFoundId: string): IJsonRpcError;
  begin
    Result := nil;
    // check: 1.present, 2.structure, 3.value
    // check: present
    if not SubIsIdPresent(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_NO_ID_FIELD);
      Exit;
    end;
    AFoundId := AJsonObj.S[FIELD_ID];
    // check: structure
    if not SubIsRequestIdDefValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_INVALID_REQUEST_ID_TYPE);
      Exit;
    end;
    // check: value
    if not  SubIsRequestIdValueValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_INVALID_REQUEST_ID);
      Exit;
    end;
  end;

  // Checks 'id' field exists, has corect type and not empty or null
  // for RPC Error Object.
  // Returns nil and not empty AFoundId if OK,
  // else TJsonRpcError and empty AFoundId.
  function SubCheckErrorId(AJsonObj: ISuperObject;
    var AFoundErrorId: ISuperObject): IJsonRpcError;
  begin
    Result := nil;
    if not SubIsIdPresent(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_NO_ID_FIELD);
      Exit;
    end;
    AFoundErrorId := AJsonObj.O[FIELD_ID];
    if not SubIsErrorIdDefValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_INVALID_ERROR_ID_TYPE);
      Exit;
    end;
    if not SubIsErrorIdValueValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_INVALID_ERROR_ID);
      Exit;
    end;
  end;

  // Checks 'method' field exists and not empty.
  // Returns nil and not empty AFoundMethod if OK,
  // else IJsonRpcError and empty AFoundMethod.
  function SubCheckMethod(AJsonObj: ISuperObject;
    var AFoundMethod: string): IJsonRpcError;
  begin
    Result := nil;
    if not SubIsMethodPresent(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_NO_METHOD_FIELD);
      Exit;
    end;
    AFoundMethod := AJsonObj.S[FIELD_METHOD];
    if SubIsMethodValid(AJsonObj) then
      Exit;
    Result := TJsonRpcError.InvalidRequest(ERROR_INVALID_METHOD_NAME);
  end;

  // Checks 'result' field exists, returns IJsonRpcError if not exists
  // or nil if no error
  function SubCheckResult(AJsonObj: ISuperObject): IJsonRpcError;
  begin
    Result := nil;
    if not SubIsResultPresent(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidRequest(ERROR_NO_RESULT_FIELD);
      Exit;
    end;
  end;

  // Checks 'error' field exists and has valid structure.
  // Returns IJsonRpcError if not OK, or nil if no error
  function SubCheckErrorInfo(AJsonObj: ISuperObject): IJsonRpcError;
  var
    errObj: ISuperObject;
  begin
    Result := nil;
    if not SubIsErrorPresent(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidParams(SO(ERROR_NO_ERROR_FIELD));
      Exit;
    end;
    if not SubIsErrorObjDefValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidParams(SO(ERROR_INVALID_ERROR_OBJ));
      Exit;
    end;
    if not SubIsErrorIdValueValid(AJsonObj) then
    begin
      Result := TJsonRpcError.InvalidParams(SO(ERROR_INVALID_ERROR_ID));
      Exit;
    end;
    errObj := AJsonObj.O[FIELD_ERROR];
    if not SubIsErrorMessageValid(errObj.S[FIELD_ERROR_MSG]) then
    begin
      Result := TJsonRpcError.InvalidParams(SO(ERROR_INVALID_ERROR_MSG));
      Exit;
    end;
    if not SubIsErrorCodeValid(errObj.I[FIELD_ERROR_CODE]) then
    begin
      Result := TJsonRpcError.InvalidParams(SO(ERROR_INVALID_ERROR_CODE));
      Exit;
    end;
  end;

  //
  // PARSE RPC OBJECTS FUNCTIONS
  //

  // Tries to parse JSON as JSON-RPC NOTIFICATION
  // Returns TJsonRpcNotificationObject if OK (AParseError=nil),
  // else 'nil' and  AParseError contains error information.
  function SubParseNotification(AJsonObj: ISuperObject;
    out AParseError: IJsonRpcError): IJsonRpcMessage;
  var
    method: string;
    params: ISuperObject;
  begin
    // If NOTIFICATION there is no ID, 'method' MUST be present,
    // 'params' MAY be omitted
    params := nil;
    AParseError:= SubCheckMethod(AJsonObj, method);
    if Assigned(AParseError) then
      Exit;
    // NOTIFICATION FOUND!
    params := AJsonObj.O[FIELD_PARAMS];
    Result := TJsonRpcMessage.Notification(method, params);
  end;

  // Tries to parse JSON as JSON-RPC REQUEST
  // Returns TJsonRpcRequestObject if OK (AParseError=nil),
  // else 'nil' and  AParseError contains error information.
  function SubParseRequest(AJsonObj: ISuperObject;
    out AParseError: IJsonRpcError): IJsonRpcMessage;
  var
    id, method: string;
    params: ISuperObject;
  begin
    // In Reqest fields 'ID', 'method' MUST be present,
    // 'params' MAY be omitted
    AParseError := SubCheckRequestId(AJsonObj, id);
    if Assigned(AParseError) then
      Exit;
    AParseError:= SubCheckMethod(AJsonObj, method);
    if Assigned(AParseError) then
      Exit;
    // REQUEST FOUND!
    params := AJsonObj.O[FIELD_PARAMS];
    Result := TJsonRpcMessage.Request(id, method, params);
  end;

  // Tries to parse JSON as JSON-RPC Success Object
  // Returns TJsonRpcRequestObject if OK (AParseError=nil),
  // else 'nil' and  AParseError contains error information.
  function SubParseSucess(AJsonObj: ISuperObject;
    out AParseError: IJsonRpcError): IJsonRpcMessage;
  var
    id: string;
    resultData: ISuperObject;
  begin
    // fields 'ID', 'result' MUST be present
    AParseError := SubCheckRequestId(AJsonObj, id);
    if Assigned(AParseError) then
      Exit;
    AParseError:= SubCheckResult(AJsonObj);
    if Assigned(AParseError) then
      Exit;
    // SUCCESS OBJECT FOUND!
    resultData := AJsonObj.O[FIELD_RESULT];
    Result := TJsonRpcMessage.Success(id, resultData);
  end;

  // Tries to parse JSON as JSON-RPC Error Object
  // Returns TJsonRpcRequestObject if OK (AParseError=nil),
  // else 'nil' and  AParseError contains error information.
  function SubParseError(AJsonObj: ISuperObject;
    out AParseError: IJsonRpcError): IJsonRpcMessage;
  var
    id: ISuperObject;
    errInfo: ISuperObject;
    errorData: IJsonRpcError;
  begin
    // fields 'ID', 'error' MUST be present
    AParseError := SubCheckErrorId(AJsonObj, id);
    if Assigned(AParseError) then
      Exit;
    AParseError:= SubCheckErrorInfo(AJsonObj);
    if Assigned(AParseError) then
      Exit;
    // ERROR OBJECT FOUND!
    errInfo := AJsonObj.O[FIELD_ERROR];
    errorData := TJsonRpcError.Create(errInfo.I[FIELD_ERROR_CODE],
      errInfo.S[FIELD_ERROR_MSG], errInfo.O[FIELD_ERROR_DATA]);
    if ObjectIsNull(id) then
      Result := TJsonRpcMessage.Error(errorData)
    else
      Result := TJsonRpcMessage.Error(id.AsString, errorData);
  end;
var
  parsedObj: ISuperObject;
  msgType: TJsonRpcObjectType;
  parsedMsg: IJsonRpcMessage;
begin
  Result := nil;
  parsedObj := SO(s);
  if not Assigned(parsedObj) then
  begin
    AParseError := TJsonRpcError.ParseError(s);
    Exit;
  end;
  // try to parse valid json object next
  AParseError := SubCheckHeader(parsedObj); //  must be freed with Result
  if Assigned(AParseError) then
    Exit;

  // header valid parse other parts
  msgType := SubGetMessageType(parsedObj);
  case msgType of
    jotNotification: parsedMsg:=SubParseNotification(parsedObj, AParseError);
    jotRequest: parsedMsg:=SubParseRequest(parsedObj,AParseError);
    jotSuccess: parsedMsg:=SubParseSucess(parsedObj,AParseError);
    jotError: parsedMsg:=SubParseError(parsedObj,AParseError);
  else
    AParseError := TJsonRpcError.InvalidRequest(parsedObj);
    Exit;
  end;
  if Assigned(AParseError) then
  begin
    Result := TJsonRpcParsedMessage.Create(jotInvalid,
      TJsonRpcMessage.Error(TJsonRpcError.InvalidRequest(parsedObj)));
    Exit;
  end;
  Result := TJsonRpcParsedMessage.Create(msgType, parsedMsg);
end;

{ TJsonRpcSuccessObject }

constructor TJsonRpcSuccessObject.Create(const aID: string; AResult:
  ISuperObject);
begin
  FID := aID;
  FResult:=AResult;
end;

function TJsonRpcSuccessObject.AsJsonObject: ISuperObject;
begin
  Result := SO();
  Result.S[FIELD_ID] := FID;
  Result.O[FIELD_RESULT] := FResult.Clone;
end;

{ TJsonRpcErrorObject }

constructor TJsonRpcErrorObject.Create(AErrorInfo: IJsonRpcError);
begin
  FErrorInfo := AErrorInfo;
end;

constructor TJsonRpcErrorObject.Create(const AID: string;
  AErrorInfo: IJsonRpcError);
begin
  Create(AErrorInfo);
  FID:=AID;
end;

function TJsonRpcErrorObject.AsJsonObject: ISuperObject;
begin
  Result := SO();
  Result.S[FIELD_ID]:=FID;
  Result.O[FIELD_ERROR]:=ErrorInfo.AsJsonObject;
end;

{ TJsonRpcParsedMessage }

constructor TJsonRpcParsedMessage.Create(const objType: TJsonRpcObjectType;
  Payload: IJsonRpcMessage);
begin
  inherited Create();
  FObjType := objType;
  FPayload := Payload;
end;

destructor TJsonRpcParsedMessage.Destroy;
begin
  inherited Destroy;
end;

function TJsonRpcParsedMessage.GetMessageType: TJsonRpcObjectType;
begin
  result := FObjType;
end;

function TJsonRpcParsedMessage.GetMessagePayload: IJsonRpcMessage;
begin
  result := FPayload;
end;

{ TJsonRpcNotificationObject }

constructor TJsonRpcNotificationObject.Create(const AMethod: string;
  AParams: ISuperObject);
begin
  inherited Create();
  FMethod:=AMethod;
  FParams:=AParams;
end;

constructor TJsonRpcNotificationObject.Create(const aMethod: string);
begin
  Create(aMethod, nil);
end;

function TJsonRpcNotificationObject.AsJsonObject: ISuperObject;
begin
  Result := SO();
  Result.S[FIELD_METHOD] := FMethod;
  if Assigned(FParams) then
    Result.O[FIELD_PARAMS] := FParams.Clone;
end;

{ TJsonRpcRequestObject }

constructor TJsonRpcRequestObject.Create(const aID: string;
  const aMethod: string; aParams: ISuperObject);
begin
  inherited Create(aMethod, aParams);
  FID := aID;
end;

function TJsonRpcRequestObject.AsJsonObject: ISuperObject;
begin
  Result:=inherited AsJsonObject;
  Result.S[FIELD_ID]:=FID;
end;

{ TJsonRpcError }

class function TJsonRpcError.Error(const code: integer; const message: string;
  data: ISuperObject): IJsonRpcError;
begin
  Result := TJsonRpcError.Create(code, message, data);
end;

class function TJsonRpcError.Error(const code: integer; const message: string;
  dataStr: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(code, message, dataStr);
end;

class function TJsonRpcError.ParseError(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_PARSE_ERROR, RPC_ERR_PARSE_ERROR, data);
end;

class function TJsonRpcError.InvalidRequest(data: ISuperObject): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INVALID_REQUEST, PRC_ERR_INVALID_REQUEST,
    data);
end;

class function TJsonRpcError.InvalidRequest(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INVALID_REQUEST, PRC_ERR_INVALID_REQUEST,
    data);
end;

class function TJsonRpcError.MethodNotFound(data: ISuperObject): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_METHOD_NOT_FOUND,
    PRC_ERR_METHOD_NOT_FOUND, data);
end;

class function TJsonRpcError.MethodNotFound(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_METHOD_NOT_FOUND,
    PRC_ERR_METHOD_NOT_FOUND, data);
end;

class function TJsonRpcError.InvalidParams(data: ISuperObject): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INVALID_PARAMS, RPC_ERR_INVALID_PARAMS,
    data);
end;

class function TJsonRpcError.InvalidParams(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INVALID_PARAMS, RPC_ERR_INVALID_PARAMS,
    data);
end;

class function TJsonRpcError.InternalError(data: ISuperObject): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INTERNAL_ERROR, RPC_ERR_INTERNAL_ERROR,
    data);
end;

class function TJsonRpcError.InternalError(data: string): IJsonRpcError;
begin
  result := TJsonRpcError.Create(CODE_INTERNAL_ERROR, RPC_ERR_INTERNAL_ERROR,
    data);
end;

constructor TJsonRpcError.Create(const code: integer;
  const message: string);
begin
  FCode:=code;
  FMessage:=message;
end;

function TJsonRpcError.GetCode: Integer;
begin
  Result:=FCode;
end;

function TJsonRpcError.GetData: ISuperObject;
begin
  Result:=FData;
end;

function TJsonRpcError.GetMessage: String;
begin
  Result:=FMessage;
end;


function TJsonRpcError.AsJsonObject: ISuperObject;
begin
  Result := SO();
  Result.I[FIELD_ERROR_CODE] := Code;
  Result.S[FIELD_ERROR_MSG] := Message;
  if Assigned(Data) then
    Result.O[FIELD_ERROR_DATA] := Data.Clone;
end;

{ TJsonRpcError }

constructor TJsonRpcError.Create(const code: integer;
  const message: string; data: ISuperObject);
begin
  Create(code, message);
  FData:= data;
end;

constructor TJsonRpcError.Create(const code: integer;
  const message: string; data: string);
begin
  Create(code, message, SO(data));
end;


end.
