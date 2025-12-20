
.PHONY: book

# Run Widgetbook with optional overrides:
#   make book              # defaults to chrome
#   make book DEVICE=macos # run on macOS
#   make book ARGS="--debug" # pass extra args to flutter run
book:
	flutter run -t lib/widgetbook.dart -d $(DEVICE) $(ARGS)

DEVICE ?= chrome
ARGS ?=