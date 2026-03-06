.PHONY: build build-universal run release clean icon bump-build version

include version.env

build:
	@SIGNING_MODE=adhoc ./Scripts/package_app.sh release

build-universal:
	@SIGNING_MODE=adhoc ARCHES="arm64 x86_64" ./Scripts/package_app.sh release

run:
	@./Scripts/compile_and_run.sh

release:
	@if [ -z "$(VERSION)" ]; then echo "Usage: make release VERSION=X.Y.Z"; exit 1; fi
	@./Scripts/release.sh $(VERSION)

clean:
	@rm -rf .build SpotBar.app
	@echo "Cleaned build artifacts."

icon:
	@./Scripts/create_icon.sh

bump-build:
	@BUILD=$$(( $(BUILD_NUMBER) + 1 )); \
	sed -i '' "s/^BUILD_NUMBER=.*/BUILD_NUMBER=$$BUILD/" version.env; \
	echo "Build number bumped to $$BUILD"

version:
	@echo "$(MARKETING_VERSION) ($(BUILD_NUMBER))"
