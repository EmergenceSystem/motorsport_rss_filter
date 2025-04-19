-module(motorsport_rss_filter_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ConfigPath = case code:priv_dir(motorsport_rss_filter) of
        {error, bad_name} -> "rss_config.json";
        PrivDir -> filename:join([PrivDir, "rss_config.json"])
    end,
    case file:read_file(ConfigPath) of
        {ok, _} ->
            application:ensure_all_started(rss_filter),
            {ok, Port} = em_filter:find_port(),
            em_filter_sup:start_link(rss_filter, rss_filter_app, Port);
        {error, enoent} when ConfigPath =/= "rss_config.json" ->
            start(normal, []);
        {error, Reason} ->
            {error, {config_error, Reason}}
    end.

stop(_State) ->
    ok.

