-module(cowboy_protocol).

%% API.
-export([start_link/4]).

%% Internal.
-export([init/4]).
-export([parse_request/3]).
-export([resume/6]).

-type opts() :: [{compress, boolean()}
  | {env, cowboy_middleware:env()}
  | {max_empty_lines, non_neg_integer()}
  | {max_header_name_length, non_neg_integer()}
  | {max_header_value_length, non_neg_integer()}
  | {max_headers, non_neg_integer()}
  | {max_keepalive, non_neg_integer()}
  | {max_request_line_length, non_neg_integer()}
  | {middlewares, [module()]}
  | {onresponse, cowboy:onresponse_fun()}
  | {timeout, timeout()}].
-export_type([opts/0]).

-record(state, {
  socket :: inet:socket(),
  transport :: module(),
  middlewares :: [module()],
  compress :: boolean(),
  env :: cowboy_middleware:env(),
  onresponse = undefined :: undefined | cowboy:onresponse_fun(),
  max_empty_lines :: non_neg_integer(),
  req_keepalive = 1 :: non_neg_integer(),
  max_keepalive :: non_neg_integer(),
  max_request_line_length :: non_neg_integer(),
  max_header_name_length :: non_neg_integer(),
  max_header_value_length :: non_neg_integer(),
  max_headers :: non_neg_integer(),
  timeout :: timeout(),
  until :: non_neg_integer() | infinity
}).

-include_lib("cowlib/include/cow_inline.hrl").
-include_lib("cowlib/include/cow_parse.hrl").

%% API.

-spec start_link(ranch:ref(), inet:socket(), module(), opts()) -> {ok, pid()}.
start_link(Ref, Socket, Transport, Opts) ->
  Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
  {ok, Pid}.

%% Internal.

%% Faster alternative to proplists:get_value/3.
get_value(Key, Opts, Default) ->
  case lists:keyfind(Key, 1, Opts) of
    {_, Value} -> Value;
    _ -> Default
  end.

-spec init(ranch:ref(), inet:socket(), module(), opts()) -> ok.
init(Ref, Socket, Transport, Opts) ->
  ok = ranch:accept_ack(Ref),
  Timeout = get_value(timeout, Opts, 5000),
  Until = until(Timeout),
  case recv(Socket, Transport, Until) of
    {ok, Data} ->
      OnFirstRequest = get_value(onfirstrequest, Opts, undefined),
      case OnFirstRequest of
        undefined -> ok;
        _ -> OnFirstRequest(Ref, Socket, Transport, Opts)
      end,
      Compress = get_value(compress, Opts, false),
      MaxEmptyLines = get_value(max_empty_lines, Opts, 5),
      MaxHeaderNameLength = get_value(max_header_name_length, Opts, 64),
      MaxHeaderValueLength = get_value(max_header_value_length, Opts, 4096),
      MaxHeaders = get_value(max_headers, Opts, 100),
      MaxKeepalive = get_value(max_keepalive, Opts, 100),
      MaxRequestLineLength = get_value(max_request_line_length, Opts, 4096),
      Middlewares = get_value(middlewares, Opts, [cowboy_router, cowboy_handler]),
      Env = [{listener, Ref}|get_value(env, Opts, [])],
      OnResponse = get_value(onresponse, Opts, undefined),
      parse_request(Data, #state{socket=Socket, transport=Transport,
        middlewares=Middlewares, compress=Compress, env=Env,
        max_empty_lines=MaxEmptyLines, max_keepalive=MaxKeepalive,
        max_request_line_length=MaxRequestLineLength,
        max_header_name_length=MaxHeaderNameLength,
        max_header_value_length=MaxHeaderValueLength, max_headers=MaxHeaders,
        onresponse=OnResponse, timeout=Timeout, until=Until}, 0);
    {error, _} ->
      terminate(#state{socket=Socket, transport=Transport}) %% @todo ridiculous
  end.

-spec until(timeout()) -> non_neg_integer() | infinity.
until(infinity) ->
  infinity;
until(Timeout) ->
  {Me, S, Mi} = os:timestamp(),
  Me * 1000000000 + S * 1000 + Mi div 1000 + Timeout.
