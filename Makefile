NAME   := civics_test
APP    := $(NAME).star
WEBP   := $(NAME).webp
ID     := civicstest

install:
	brew install tidbyt/tidbyt/pixlet

serve:
	pixlet serve $(APP)

render:
	pixlet render $(APP)

push: render
	pixlet push $(TIDBYT_DEVICE_ID) $(WEBP) --api-token $(TIDBYT_API_KEY) --installation-id $(ID)

check:
	pixlet check /tmp/tidbyt-community/apps/civicstest

.PHONY: install serve render push check
