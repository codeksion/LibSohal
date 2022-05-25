## LibSohal Backend API referans notları

### Kurulum & Bağımlılıklar
- go 1.18
- mongodb
- python3 - easyocr
  
```
go mod -x tidy
go build -x -v -u .

python3 -m pip install easyocr

echo '#!/usr/bin/python3 
import sys
import easyocr

reader = easyocr.Reader(["tr"],verbose=False)
text = ""
for i in reader.readtext(sys.argv[1]):
	text += i[1]+" "

print(text)' > /usr/bin/easyocrbin

easyocrbin
```

#### Ortam
`.env`
```
MONGO_ADDR=mongodb://sohal:password@localhost:5432/libsohal
FIBER_ADDR=0.0.0.0:80
```


#### Systemd

`/etc/systemd/system/libsohal.service`
```
[Unit]
Description=LibSohal Backend Software
After=mongo.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=5
ExecDir=/root/libsohal/backend
ExecStart=/root/libsohal/backend/backend

[Install]
WantedBy=multi-user.target
```

## Geliştirici seçenekleri

Söz dizimi: `backend -dev $1 $2 ...`
```
  -category string
    	category array value
  -dev
    	apiyi çalıştırmak yerine ek işlevleri kullanın
  -getbooks
    	Kitapları getir
  -kitapekle string
    	kitap.json, olmasına gerek yok; oluştururuz.
  -newest
    	get newst book
  -page int
    	getbooks page (default 1)
  -searchbook string
    	search RAW book from googleapis
  -systemctl
    	Systemctl service sample
  -title string
    	book title
  -top
    	top books (newest)
  -yetkiliekle
    	yetkili ekle
  -yetkiliisim string
    	yetkili tam isim
  -yetkilipw string
    	yetkili şifresi
  -yetkilirol string
    	yetkili rol (default "öğretmen")

```

Yetkili ekle
`-dev --yetkiliekle --yetkiliisim "Raif" --yetkilipw "204060" --yetkilirol "geliştirici"`



## Yapılacaklar Listesi
- Özel SSL Sertifikası
- Libgen desteği
- Eklenen kitapları düzenleme
- ...



[raifpy](https://github.com/raifpy) tarafından [codeksion](https://codeksion.net) adına, Şehit Ömer Halisdemir Anadolu Lisesi için geliştirildi.
Project: **draft**

