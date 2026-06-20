-include .env
export TIDBYT_DEVICE_ID TIDBIT_API_KEY

APP    := civics_test.star
WEBP   := civics_test.webp
ID     := civics

install:
	brew install tidbyt/tidbyt/pixlet

serve:
	pixlet serve $(APP)

render:
	pixlet render $(APP)

.PHONY: install serve render
