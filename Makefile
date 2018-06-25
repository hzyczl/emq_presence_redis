PROJECT = emq_presence_redis
PROJECT_DESCRIPTION = EMQ PRESENCE STATE TO REDIS
PROJECT_VERSION = 1.0.0

DEPS = eredis ecpool clique

dep_eredis = git https://github.com/wooga/eredis master
dep_ecpool = git https://github.com/emqtt/ecpool master
dep_clique = git https://github.com/emqtt/clique

BUILD_DEPS = emqttd cuttlefish
dep_emqttd = git https://github.com/emqtt/emqttd master
dep_cuttlefish = git https://github.com/emqtt/cuttlefish

ERLC_OPTS += +debug_info
ERLC_OPTS += +'{parse_transform, lager_transform}'

NO_AUTOPATCH = cuttlefish

COVER = true

include erlang.mk

app:: rebar.config

app.config::
	./deps/cuttlefish/cuttlefish -l info -e etc/ -c etc/emq_presence_redis.conf -i priv/emq_presence_redis.schema -d data
