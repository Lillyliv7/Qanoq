# Qanoq

Qanoq is an app designed to help learners of the Greenlandic (Kalaallisut) language. It includes a word analyzer to break down complex words, a dictionary, and noun/verb ending charts.

## Building from Scratch
The Releases tab has up to date releases for Windows, Linux and prebuilt Docker images; the site can also be accessed on web at https://qanoq.gl

To build desktop from scratch (Linux):

Install flutter (https://docs.flutter.dev/install)
```
git clone https://github.com/Lillyliv7/Qanoq
cd Qanoq/Qanoq
flutter run
```

To host a web server:
```
git clone https://github.com/Lillyliv7/Qanoq
cd Qanoq/Qanoq
sudo docker build -t qanoq .
sudo docker run --name qanoq-instance -d -p 80:80 qanoq
```