## LibSohal
Another server-client based library software for borrowing books.
Supports libgen.


![codacy-quality](https://img.shields.io/codacy/grade/bf89b0e27306470da0c1cb4f1a7e70d2?style=for-the-badge) ![repo-size](https://img.shields.io/github/languages/code-size/codeksion/libsohal?label=code%20size&style=for-the-badge) ![web-status](https://img.shields.io/website?down_color=lightgrey&down_message=down%20%3A%28&style=for-the-badge&up_color=green&up_message=Working&url=https%3A%2F%2Flibsohal.codeksion.net%2F) ![release-downloıads](https://img.shields.io/github/downloads/codeksion/libsohal/total?label=release%20downloads&style=for-the-badge)
![last-commit](https://img.shields.io/github/last-commit/codeksion/libsohal?style=for-the-badge) ![last-release](https://img.shields.io/github/release-date/codeksion/libsohal?label=last%20release&style=for-the-badge)


It's all Turkish. But you can use with fork in any language.

### Dependencies && Setup 

###### Server Side
Should be work on all up to date linux distros. _My suggestion is ubuntu-server_


- python3 `apt install python3`
- easyocr `python3 -m pip install easyocr ## for extract summary from book's back cover`
- easyocrbin `sudo wget https://raw.githubusercontent.com/codeksion/LibSohal/main/backend/easyocrbin?token=GHSAT0AAAAAABKCRLGR54H7UNAIPUMIVX3GYUOFYMA -O /usr/bin/easyocrbin ; sudo chmod +x /usr/bin/easyocrbin`
- mongodb `mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu ## or docker -> docker pull mongo`
- go `go.dev/dl ## for compile backend/utils || not neccesary if you want to use compiled binaries`

##### Build from source code

Dependencies:
- [Golang](https://dl.golang.org) ^1.18.x
- [Flutter](https://docs.flutter.dev/get-started/install) ^3.x
- [Android SDK](https://developer.android.com/studio) for Flutter Android build

```
git clone https://github.com/codeksion/LibSohal
cd LibSohal
bash build.sh
```

##### Download from releases
server-side:
```
wget https://github.com/codeksion/LibSohal/releases/download/v0.2/backend
wget https://github.com/codeksion/LibSohal/releases/download/v0.2/utils
wget https://raw.githubusercontent.com/codeksion/LibSohal/main/backend/easyocrbin?token=GHSAT0AAAAAABKCRLGR54H7UNAIPUMIVX3GYUOFYMA -O easyorcbin
```
client-side:
Go to [releases](https://github.com/codeksion/LibSohal/releases/) or [download compiled apk](https://github.com/codeksion/LibSohal/releases/download/v0.2/libsohal-frontend.apk)

### Dev Note
Still development/draft project :)
