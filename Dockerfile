FROM dart:stable AS builder

COPY . /tmed_tg

WORKDIR /tmed_tg

RUN mkdir build

RUN dart pub get

RUN dart pub global activate dotenv

RUN dart compile exe ./bin/main.dart -o ./build/dartserve

#FROM debian:buster-slim
#COPY --from=builder /tmed_tg/build/ /bin
EXPOSE 8080
CMD ["./build/dartserve"]