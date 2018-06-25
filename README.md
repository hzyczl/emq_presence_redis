
emq-presence_redis
===================
Use to record connect client to redis
-------------

Each plugin should have a 'etc/{plugin_name}.conf|config' file to store application config.

Config
----------------------

```
[

  {emqttd_presence_redis, [

    {redis_pool, [
        %% ecpool options
        {pool_size, 8},
        {auto_reconnect, 1},

        %% redis options
        {host,     "127.0.0.1"},
        {port,     7002},
        {password, "myredis"},
        {database, "0"},
    ]},

		 // ANKER:DEVICE:DEV_KEY
		 // expire  60 seconds
    {connected, [{key_prefix,"ANKER:DEVICE:~p"},{expire,60000}]},
  ]}

].
```

License
-------

Apache License Version 2.0
