%%--------------------------------------------------------------------
%% Copyright (c) 2013-2018 EMQ Enterprise, Inc. (http://emqtt.io)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emq_presence_redis).

-include_lib("emqttd/include/emqttd.hrl").

-behaviour(ecpool_worker).
-include("emq_presence_redis.hrl").
-export([load/1, unload/0]).

%% Hooks functions

-export([on_client_connected/3, on_client_disconnected/3]).


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

%% Called when the plugin application start
load(Env) ->
    emqttd:hook('client.connected', fun ?MODULE:on_client_connected/3, [Env]),
    emqttd:hook('client.disconnected', fun ?MODULE:on_client_disconnected/3, [Env]).

on_client_connected(ConnAck, Client = #mqtt_client{client_id = ClientId}, _Env) ->
    io:format("client ~s connected, connack: ~w~n", [ClientId, ConnAck]),
    emq_presence_redis_server:client_connected(Client),
    {ok, Client}.

on_client_disconnected(Reason, _Client = #mqtt_client{client_id = ClientId}, _Env) ->
    io:format("client ~s disconnected, reason: ~w~n", [ClientId, Reason]),
    ok.
%%
%%on_client_subscribe(ClientId, Username, TopicTable, _Env) ->
%%    io:format("client(~s/~s) will subscribe: ~p~n", [Username, ClientId, TopicTable]),
%%    {ok, TopicTable}.
%%
%%on_client_unsubscribe(ClientId, Username, TopicTable, _Env) ->
%%    io:format("client(~s/~s) unsubscribe ~p~n", [ClientId, Username, TopicTable]),
%%    {ok, TopicTable}.
%%
%%on_session_created(ClientId, Username, _Env) ->
%%    io:format("session(~s/~s) created.", [ClientId, Username]).
%%
%%on_session_subscribed(ClientId, Username, {Topic, Opts}, _Env) ->
%%    io:format("session(~s/~s) subscribed: ~p~n", [Username, ClientId, {Topic, Opts}]),
%%    {ok, {Topic, Opts}}.
%%
%%on_session_unsubscribed(ClientId, Username, {Topic, Opts}, _Env) ->
%%    io:format("session(~s/~s) unsubscribed: ~p~n", [Username, ClientId, {Topic, Opts}]),
%%    ok.
%%
%%on_session_terminated(ClientId, Username, Reason, _Env) ->
%%    io:format("session(~s/~s) terminated: ~p.", [ClientId, Username, Reason]).
%%
%%%% transform message and return
%%on_message_publish(Message = #mqtt_message{topic = <<"$SYS/", _/binary>>}, _Env) ->
%%    {ok, Message};
%%
%%on_message_publish(Message, _Env) ->
%%    io:format("publish ~s~n", [emqttd_message:format(Message)]),
%%    {ok, Message}.
%%
%%on_message_delivered(ClientId, Username, Message, _Env) ->
%%    io:format("delivered to client(~s/~s): ~s~n", [Username, ClientId, emqttd_message:format(Message)]),
%%    {ok, Message}.
%%
%%on_message_acked(ClientId, Username, Message, _Env) ->
%%    io:format("client(~s/~s) acked: ~s~n", [Username, ClientId, emqttd_message:format(Message)]),
%%    {ok, Message}.

%% Called when the plugin application stop
unload() ->
    emqttd:unhook('client.connected', fun ?MODULE:on_client_connected/3),
    emqttd:unhook('client.disconnected', fun ?MODULE:on_client_disconnected/3).
%%    emqttd:unhook('client.subscribe', fun ?MODULE:on_client_subscribe/4),
%%    emqttd:unhook('client.unsubscribe', fun ?MODULE:on_client_unsubscribe/4),
%%    emqttd:unhook('session.created', fun ?MODULE:on_session_created/3),
%%    emqttd:unhook('session.subscribed', fun ?MODULE:on_session_subscribed/4),
%%    emqttd:unhook('session.unsubscribed', fun ?MODULE:on_session_unsubscribed/4),
%%    emqttd:unhook('session.terminated', fun ?MODULE:on_session_terminated/4),
%%    emqttd:unhook('message.publish', fun ?MODULE:on_message_publish/2),
%%    emqttd:unhook('message.delivered', fun ?MODULE:on_message_delivered/4),
%%    emqttd:unhook('message.acked', fun ?MODULE:on_message_acked/4).

