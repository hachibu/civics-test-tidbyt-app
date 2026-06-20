APP := civics_test.star

install:
	brew install tidbyt/tidbyt/pixlet

serve:
	pixlet serve $(APP)

render:
	pixlet render $(APP)

.PHONY: install serve render
