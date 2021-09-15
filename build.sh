#!/bin/bash

(cd server && npm run build)

# cp ./bettertimetable/lib/consts.dart ./consts.dart.bak
sed -i.bak 's/http:\/\/localhost:8888//g' ./bettertimetable/lib/consts.dart
(cd bettertimetable && flutter build web --release)
mv ./bettertimetable/lib/consts.dart.bak ./bettertimetable/lib/consts.dart

zip -r btt.zip ./bettertimetable/build/web \
                ./server/dist \
                ./server/package*.json \
                ./redis \
                ./Dockerfile \
                ./docker-compose.yml