#! /usr/bin/env sh

if [ -z "$DEBUG" ]; then
    DEBUG=0
else
    DEBUG=1
fi

GIT_LAST_LOG=$(git log -1 | tr -d "'")

GIT_TAG_LOG=$(git tag -l --points-at HEAD)

if [ ! -z "$GIT_TAG_LOG" ]
then
    GIT_LAST_LOG=""
fi

if [ "$DEBUG" -eq 1 ]; then
    echo "Building CGRateS cgr-engine with debug flags ..."
    go install -gcflags "all=-N -l" -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-engine
    /root/go/bin/dlv --listen=:2345 --headless=true --api-version=2 exec /usr/bin/cgr-engine
    exit
fi

echo "Building CGRateS ..."

go install -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-engine
cr=$?

go install -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-loader
cl=$?

go install -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-console
cc=$?

go install -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-migrator
cm=$?

go install -ldflags "-X 'github.com/cgrates/cgrates/utils.GitLastLog=$GIT_LAST_LOG'" github.com/cgrates/cgrates/cmd/cgr-tester
ct=$?

exit $cr || $cl || $cc || $cm || $ct
