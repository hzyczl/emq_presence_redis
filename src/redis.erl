%%%-------------------------------------------------------------------
%%% Copyright © 2015-2018 Anker Innovations Technology Limited All Rights Reserved.
%%% @author ocean
%%% @copyright (C) 2018, Anker
%%% @doc
%%% 
%%% @end
%%% Created : 25. 六月 2018 下午12:14
%%%-------------------------------------------------------------------
-module(redis).
-author("bobo.chen").

-behaviour(ecpool_worker).
-include("emq_presence_redis.hrl").
-include_lib("emqttd/include/emqttd.hrl").

-define(ENV(Key, Opts), proplists:get_value(Key, Opts)).

-export([connect/1, update_client/2]).

%%--------------------------------------------------------------------
%% Redis Connect/Query
%%--------------------------------------------------------------------

connect(Opts) ->
  eredis:start_link(?ENV(host, Opts),
    ?ENV(port, Opts),
    ?ENV(database, Opts),
    ?ENV(password, Opts),
    100,5000).

-spec(update_client(string(), integer()) -> {ok, undefined | binary() | list()} | {error, atom() | binary()}).
update_client(Key,Expire) ->
  ecpool:with_client(?APP, fun(C) -> eredis:q(C, ["SETEX" ,Key,Expire]) end).

