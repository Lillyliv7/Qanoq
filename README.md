# Kalaallisut-Dictionary

This is an app designed to help learners of the Greenlandic (Kalaallisut) language. It includes a word analyzer to break down complex words, a dictionary, and noun/verb ending charts.

## Building from Scratch
The Releases tab has up to date releases for Windows and Linux, and the site can be accessed on web at https://imlillith888.xyz

To build desktop from scratch (Linux):

Install flutter (https://docs.flutter.dev/install)
```
git clone https://github.com/Lillyliv7/Kalaallisut-Dictionary
cd Kalaallisut-Dictionary/kalaallisutdictionary
flutter run
```

To host a web server:
```
git clone https://github.com/Lillyliv7/Kalaallisut-Dictionary
cd Kalaallisut-Dictionary
sudo docker build -t dict .
sudo docker run --name dict-instance -d -p 80:80 dict
```