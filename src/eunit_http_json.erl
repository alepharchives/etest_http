%% @author Johannes Huning <johannes.huning@wooga.com>
%% @doc JSON specific helper functions.
-module (eunit_http_json).

%% Public helper methods.
-export ([encode/1, decode/1]).


% TODO - Document!
encode(Orddict) ->
  jiffy:encode(pack(Orddict)).

% TODO - Document!
decode(Binary) ->
  unpack(jiffy:decode(Binary)).


%% @doc Attempts to extract a orddict from the given jiffy-JSON.
unpack(Json) when is_list(Json) orelse is_tuple(Json) ->
  unpack(Json, orddict:new());

%% Only tuples and list require deeper unpacking, return simple structs.
unpack(Json) -> Json.

%% @doc Recursively unpacks a nested jiffy-JSON object.
unpack({Proplist}, Dict) when is_list(Proplist) ->
  lists:foldl(
    fun({Key, Value}, Acc) ->
      orddict:store(Key, unpack(Value), Acc)
    end,
    Dict,
    Proplist
  );

% List of jiffy-JSON => list of unpacked structs.
unpack(List, _) when is_list(List) ->
  [unpack(Elem) || Elem <- List].

%% @doc Recursively builds a jiffy-JSON struct from the given orddict.
% Single orddict => jiffy-JSON object.
pack(Orddict = [Head|_]) when is_list(Orddict) andalso is_tuple(Head) ->
  {orddict:fold(
    fun(Key, Value, Acc) ->
      Acc ++ [{Key, pack(Value)}]
    end,
    [],
    Orddict
  )};

% Treat the empty list as an empty object.
pack([]) -> {[]};

% List of orddicts => list of jiffy-JSON objects.
pack(List) when is_list(List) ->
  [pack(Elem) || Elem <- List];

pack(undefined) -> null;

% Simple term => same simple term.
pack(Value) -> Value.