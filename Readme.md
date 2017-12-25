# Pascal JSON-RPC lite 2

Parse and Serialize JSON-RPC2 messages in free-pascal or Delphi application.
Git Repository: https://github.com/r3code/pascal-jsonrpc-lite-2

This is an enhanced version of https://github.com/r3code/pascal-jsonrpc-lite

Inspired by https://github.com/teambition/jsonrpc-lite.

**An implementation of [JSON-RPC 2.0 specifications](http://jsonrpc.org/specification)**


## Dependencies

SuperObject JSON parsing library https://github.com/hgourvest/superobject


## Install

1. Download.
2. Extract.
3. Add `ujsonrpc2.pas` to your project or add path to `ujsonrpc2.pas` to Lib Path.
```pascal
uses ujsonrpc;
```


## API

### Interface: IJsonRpcMessage
  

#### Method: IJsonRpcMessage.AsJsonObject

Returns object as ISuperObject.    

#### Method: IJsonRpcMessage.AsJSon(indent: boolean = false; escape: boolean = true): string;

Returns a JSON string object representation. 

Params:
- `indent`: {boolean} indent resulting JSON
- `escape`: {boolean} escape special chars


### Class: TJsonRpcMessage

##### Class Method: TJsonRpcMessage.Request(id, method, params)

Creates a JSON-RPC 2.0 request object, return IJsonRpcMessage object.
Realizes IJsonRpcMessage. Returns {IJsonRpcError}.

Params:
- `id`: {String}
- `method`: {String}
- `params`:  {IJsonRpcMessage}

Example:
```pascal
var requestObj: TJsonRpcMessage; 
requestObj := TJsonRpcMessage.Request('123', 'update', SO('{list: [1, 2, 3]}'));
writeln(requestObj.asString);
// {
//   jsonrpc: '2.0',
//   id: '123',
//   method: 'update',
//   params: {list: [1, 2, 3]}
// }
```

##### Class Method: TJsonRpcMessage.Notification(method, params)

Creates a JSON-RPC 2.0 notification object, returns {IJsonRpcMessage}.

Params:
- `method`: {String}
- `params`:  {IJsonRpcMessage}

Example:
```pascal
var notificationObj: TJsonRpcMessage;
notificationObj := TJsonRpcMessage.notification('update', SO('{list: [1, 2, 3]}'));
writeln(notificationObj.asString);
// {
//   jsonrpc: '2.0',
//   method: 'update',
//   params: {list: [1, 2, 3]}
// }
```

#### Class Method: TJsonRpcMessage.Success(id, result)

Creates a JSON-RPC 2.0 success response object, returns {IJsonRpcMessage}.

Params:
- `id`: {String}
- `result`:  {IJsonRpcMessage} 

Example:
```pascal
var msg: TJsonRpcMessage;
msg := TJsonRpcMessage.success('123', 'OK');
writeln(msg.asString);
// {
//   jsonrpc: '2.0',
//   id: '123',
//   result: 'OK',
// }
```

#### Class Method: TJsonRpcMessage.Error(id, error)

Creates a JSON-RPC 2.0 error response object, returns {IJsonRpcMessage}.

Params:
- `id`: {String}
- `error`: {IJsonRpcMessage} use TJsonRpcError or it's siblings 

Example:
```pascal
var msg: TJsonRpcMessage;
msg := TJsonRpcMessage.Error('123', TJsonRpcError.Create(-32000, 'some error', 'blabla'));
writeln(msg.asString);
// {
//   jsonrpc: '2.0',
//   id: '123',
//   error: {code: -32000, 'message': 'some error', data: 'blabla'},
// }
```

#### Class Method: TJsonRpcMessage.Parse(s, err)

Takes a JSON-RPC 2.0 payload (string) and tries to parse it into a JSON. 
If successful, determine what object is it (response, notification, success, 
error, or invalid), and return it's type and properly formatted object.
In case of error see details in `err` value.

Params:
- `s`: {String}
- `err`: {IJsonRpcError}

returns an object of {IJsonRpcParsedMessage} if OK, else `nil` 
and `err` set to one of IJsonRpcError realizations (TJsonRpcError).


### Enum: TJsonRpcObjectType

Shows the type of message detected during `Parse`.
Types: `jotInvalid`, `jotRequest`, `jotNotification`, `jotSuccess`, `jotError`.


### Interface: IJsonRpcParsedMessage

#### Method: IJsonRpcParsedMessage.GetMessageType

Returns one of {TJsonRpcObjectType}.

#### Method: IJsonRpcParsedMessage.GetMessagePayload

Returns stored ref to IJsonRpcMessage.


### Class: TJsonRpcParsedMessage

Realizes interface {IJsonRpcParsedMessage}.

#### Constructor: TJsonRpcParsedMessage.Create(objType, payload)

Create a TJsonRpcParsedMessage instance.

Params:
- `objType`:  {TJsonRpcObjectType} message format type
- `payload`:  {IJsonRpcMessage} message body


### Interface: IJsonRpcError

#### Method: IJsonRpcError.GetCode

Returns error code as {Integer}.

#### Method: IJsonRpcError.GetMessage

Returns error message as {String}.

#### Method: IJsonRpcError.GetMessage

Returns error Data as {ISuperObject}.

#### Method: IJsonRpcError.AsJsonObject

Returns object as {ISuperObject}.


### Class: TJsonRpcError

Describes JSON-RPC 2.0 Error object.
Realizes interface {IJsonRpcMessage}.

#### Constructor: TJsonRpcError.Create(code,message[,data])

Creates an instance.

Params:
- `code`:  {Integer}
- `message`:  {String}
- `data`: {String|ISuperObject|nil} optional

Examples:
```pascal
var error: TJsonRpcError;
error =  TJsonRpcError.Create(-32651, 'some error', 'some data');
```
or
```pascal
var error: TJsonRpcError;
error =  TJsonRpcError.Create(-32651, 'some error', SO('{ a: 1, extra: "some data"}'));
```

#### Class Method: TJsonRpcError.InvalidRequest(data)

Create {TJsonRpcError} object with error code -32600.

Params:
- `data`: {String|ISuperObject|nil} - extra data

#### Class Method: TJsonRpcError.MethodNotFound(data)

Create {TJsonRpcError} object with error code -32601.

Params:
- `data`: {String|ISuperObject|nil} - extra data

#### Class Method: TJsonRpcError.InvalidParams(data)

Create {TJsonRpcError} object with error code -32602.

Params:
- `data`: {String|ISuperObject|nil} - extra data

#### Class Method: TJsonRpcError.InternalError(data)

Create {TJsonRpcError} object with error code  -32603.

Params:
- `data`: {String|ISuperObject|nil} - extra data

#### Class Method: TJsonRpcError.ParseError(data)

Create {TJsonRpcError} object with error code  -32700.

Params:
- `data`: {String} - error text


### Class: TJsonRpcNotificationObject

Describes JSON-RPC 2.0 Notification object.
Realizes interface {IJsonRpcMessage}.

#### Constructor: TJsonRpcNotificationObject.Create(method[,params])

Creates an instance.

Params:
- `method`:  {String}
- `params`: {TSuperArray|ISuperObject} optional


#### Class Method: TJsonRpcNotificationObject.AsJsonObject

Returns object as {ISuperObject}


### Class: TJsonRpcRequestObject

Describes JSON-RPC 2.0 Request object.
Realizes interface {IJsonRpcMessage}.

#### Constructor: TJsonRpcRequestObject.Create(id, method[,params])

Creates an instance.

Params:
- `id`:  {String}
- `method`:  {String}
- `params`: {Array|ISuperObject} optional


#### Class Method: TJsonRpcRequestObject.AsJsonObject

Returns object as {ISuperObject}


### Class: TJsonRpcSuccessObject

Describes JSON-RPC 2.0 Success object.
Realizes interface {IJsonRpcMessage}.

#### Constructor: TJsonRpcSuccessObject.Create(id, result)

Create a {TJsonRpcSuccessObject} instance.

Params:
- `id`:  {String}
- `result`: {ISuperObject} 

To place scalar value as result use superobject as wrapper: `SO('string value'); SO(921)`


#### Class Method: TJsonRpcSuccessObject.AsJsonObject

Returns object as {ISuperObject}


### Class: TJsonRpcErrorObject

Describes JSON-RPC 2.0 Error object.
Realizes interface {IJsonRpcMessage}.

#### Constructor: TJsonRpcErrorObject.Create(id, method[,params])

Creates an instance.

Params:
- `id`:  {String}
- `result`: {ISuperObject} 

To place scalar value as result use superobject as wrapper: `SO('string value'); SO(921)`


#### Class Method: TJsonRpcErrorObject.AsJsonObject

Returns object as {ISuperObject}