.PHONY: rel deps

all: deps
	@rebar compile

build:
	@rebar compile

deps:
	@rebar get-deps

rel: deps
	@rebar compile generate

relforce: deps
	@rebar compile generate force=1

clean:
	@rebar clean

distclean: clean relclean
	@rebar delete-deps

test:
	rebar skip_deps=true eunit

relclean:
	rm -rf rel/phoebus

##
## Developer targets
##
stagedevrel: dev1 dev2 dev3
	$(foreach dev,$^,$(foreach dep,$(wildcard deps/* apps/*), rm -rf dev/$(dev)/lib/$(shell basename $(dep))-* && ln -sf $(abspath $(dep)) dev/$(dev)/lib;))


devrel: dev1 dev2 dev3

dev1 dev2 dev3:
	mkdir -p dev
	(cd rel && ../rebar generate target_dir=../dev/$@ overlay_vars=vars/$@_vars.config)

devclean: clean
	rm -rf dev

stage : rel
	$(foreach dep,$(wildcard deps/* apps/*), rm -rf rel/phoebus/lib/$(shell basename $(dep))-* && ln -sf $(abspath $(dep)) rel/phoebus/lib;)
