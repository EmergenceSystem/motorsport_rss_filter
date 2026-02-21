%%%-------------------------------------------------------------------
%%% @doc Motorsport RSS filter.
%%%
%%% Delegates to rss_filter_app after copying this application's
%%% priv/rss_config.json to the working directory where
%%% rss_filter_app expects to find it.
%%% @end
%%%-------------------------------------------------------------------
-module(motorsport_rss_filter_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ConfigPath = priv_config_path(motorsport_rss_filter),
    case file:copy(ConfigPath, "rss_config.json") of
        {ok, _} ->
            em_filter:start_filter(rss_filter, rss_filter_app);
        {error, enoent} when ConfigPath =/= "rss_config.json" ->
            %% priv not found — try CWD fallback (dev mode)
            em_filter:start_filter(rss_filter, rss_filter_app);
        {error, Reason} ->
            {error, {config_error, Reason}}
    end.

stop(_State) ->
    em_filter:stop_filter(rss_filter).

priv_config_path(App) ->
    case code:priv_dir(App) of
        {error, bad_name} -> "rss_config.json";
        PrivDir           -> filename:join(PrivDir, "rss_config.json")
    end.
