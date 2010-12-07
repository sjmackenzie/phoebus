.PHONY: rel deps

all: deps
	@rebar compile

compile:
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
	(cd rel && rebar generate target_dir=../dev/$@ overlay_vars=vars/$@_vars.config)

devclean: clean
	rm -rf dev

stage : rel
	$(foreach dep,$(wildcard deps/* apps/*), rm -rf rel/phoebus/lib/$(shell basename $(dep))-* && ln -sf $(abspath $(dep)) rel/phoebus/lib;)

COMBO_PLT = $(HOME)/.phoebus_combo_dialyzer_plt

check_plt: compile
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS) \
		deps/*/ebin

build_plt: compile
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS) \
		deps/*/ebin

dialyzer: compile
	@echo
	@echo Use "'make check_plt'" to check PLT prior to using this target.
	@echo Use "'make build_plt'" to build PLT prior to using this target.
	@echo
	@sleep 1
	dialyzer -Wno_return --plt $(COMBO_PLT) deps/*/ebin | \
	    fgrep -v -f ./dialyzer.ignore-warnings

cleanplt:
	@echo 
	@echo "Are you sure?  It takes about 1/2 hour to re-build."
	@echo Deleting $(COMBO_PLT) in 5 seconds.
	@echo 
	sleep 5
	rm $(COMBO_PLT)

