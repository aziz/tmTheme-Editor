#!/usr/bin/env bash

if [ ! -d "node_modules" ]; then
	npm install
fi

if hash coffee 2>/dev/null; then
	coffee app.coffee
else
	./node_modules/coffee-script/bin/coffee app.coffee
fi
