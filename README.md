## LibSohal
Another server-client based library software for barrow books.
It's all Turkish. But you can use with fork in any language.

### Dependencies && Setup 

###### Server Side
Should be work on all up to date linux distros. _My suggestion is ubuntu-server_


- python3 `apt install python3`
- easyocr `python3 -m pip install easyocr ## for extract summary from book's back cover`
- easyocrbin `sudo wget ... -O /usr/bin/easyocrbin ; sudo chmod +x /- usr/bin/easyocrbin`
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
wget ...
wget ...
```
client-side:
Go to [releases]()

### Dev Note
Still development/draft project :)