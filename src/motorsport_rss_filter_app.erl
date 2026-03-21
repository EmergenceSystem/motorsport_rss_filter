%%%-------------------------------------------------------------------
%%% @doc Motorsport RSS filter application.
%%%
%%% Responsibility:
%%%   - copy priv/rss_config.json to working directory
%%%   - start rss_filter application
%%%
%%% rss_filter handles em_filter internally.
%%%-------------------------------------------------------------------
-module(motorsport_rss_filter_app).

-behaviour(application).

-export([start/2, stop/1]).

%%====================================================================
%% Application callbacks
%%====================================================================

start(_StartType, _StartArgs) ->
    copy_config(),
    application:ensure_all_started(rss_filter),
    em_filter:start_agent(motorsport_rss_filter, rss_filter_app, #{
        capabilities => rss_filter_app:base_capabilities()
                        ++ [<<"motorsport">>, <<"f1">>, <<"rally">>, <<"wrc">>]
    }),
    {ok, self()}.

stop(_State) ->
    ok.

%%====================================================================
%% Internal
%%====================================================================

copy_config() ->
    case code:priv_dir(motorsport_rss_filter) of

        %% running in release
        PrivDir when is_list(PrivDir) ->
            Src = filename:join(PrivDir, "rss_config.json"),
            file:copy(Src, "rss_config.json"),
            ok;

        %% running in dev mode
        {error, bad_name} ->
            ok
    end.
