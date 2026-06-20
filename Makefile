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

CRON_SCHEDULE ?= 0 8 * * *
CRON_MARKER   := $(ID)-push
CRON_ENTRY    := $(CRON_SCHEDULE) cd $(CURDIR) && TIDBYT_DEVICE_ID=$(TIDBYT_DEVICE_ID) TIDBYT_API_KEY=$(TIDBYT_API_KEY) $(MAKE) push \#$(CRON_MARKER)

cron-install:
	( crontab -l 2>/dev/null | grep -v "\#$(CRON_MARKER)"; echo "$(CRON_ENTRY)" ) | crontab -
	@echo "Cron installed: $(CRON_SCHEDULE)"

cron-uninstall:
	crontab -l 2>/dev/null | grep -v "\#$(CRON_MARKER)" | crontab -
	@echo "Cron removed"

.PHONY: install serve render push cron-install cron-uninstall
