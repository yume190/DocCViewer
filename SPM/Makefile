
REPO:=https://github.com/apple/swift-argument-parser
TAG:=1.4.0
# TAG:=1.3.1
# TAG:=1.3.0


# REPO:=https://github.com/pointfreeco/swift-composable-architecture
# TAG:=1.11.2
# TAG:=1.10.4


TOKEN:=""

clone: 
	git clone --depth 1 --branch $(TAG) $(REPO)


run: 
	swift run Cli \
		--repo $(REPO) \
		--path swift-composable-architecture \
		--tag $(TAG) \
		--token $(TOKEN)

remoteBuild:
	curl -L \
		-X POST \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $(TOKEN)" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		https://api.github.com/repos/yume190/TestDoc/dispatches \
		-d '{"event_type":"build_docc","client_payload":{"repo":"$(REPO)","tag":"$(TAG)","token":"$(TOKEN)"}}'

assets:
	curl -L \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $(TOKEN)" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
  	https://api.github.com/repos/yume190/TestDoc/releases/162259612/assets | jq

	

build:
	swift build --package-path /Users/yume/Desktop/DocCViewer/SPM/swift-composable-architecture \
	--target ComposableArchitecture -Xswiftc -emit-symbol-graph -Xswiftc -emit-symbol-graph-dir \
	-Xswiftc /Users/yume/Desktop/DocCViewer/SPM/swift-composable-architecture/.build/pointfreeco_swift_composable_architecture/symbol/ComposableArchitecture

preivew:
	$(xcrun --find docc) preview \
	--additional-symbol-graph-dir /Users/yume/Desktop/DocCViewer/SPM/swift-composable-architecture/.build/pointfreeco_swift_composable_architecture/symbol/ComposableArchitecture \
	--output-path dist \
	/Users/yume/Desktop/DocCViewer/SPM/swift-composable-architecture/Sources/ComposableArchitecture/Documentation.docc


release:
	swift build -c release --static-swift-stdlib
