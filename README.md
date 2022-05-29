## LibSohal
Another server-client based library software for borrowing books.
Supports libgen a bit.
It's all Turkish. But you can use with fork in any language.

### Dependencies && Setup 

###### Server Side
Should be work on all up to date linux distros. _My suggestion is ubuntu-server_


- python3 `apt install python3`
- easyocr `python3 -m pip install easyocr ## for extract summary from book's back cover`
- easyocrbin `sudo wget ... -O /usr/bin/easyocrbin ; sudo chmod +x /usr/bin/easyocrbin`
- mongodb `mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu ## or docker -> docker pull mongo`
- go `go.dev/dl ## for compile backend/utils || not neccesary if you use pre-compiled binary`

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
Go to [releases](https://github.com/codeksion/LibSohal/releases/) or [download compiled apk](https://github.com/codeksion/LibSohal/releases/download/v0.1/libsohal-frontend.apk)

### Dev Note
Still development/draft project :)