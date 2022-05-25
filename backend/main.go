package main

import (
	"backend/libsohal"
	"backend/libsohal/template"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"math/rand"
	"os"
	"strconv"
	"time"

	_ "embed"

	_ "github.com/joho/godotenv/autoload"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

//go:embed sample.service
var systemctlsample []byte

var (
	dev = flag.Bool("dev", false, "apiyi çalıştırmak yerine ek işlevleri kullanın")

	kitapekle = flag.String("kitapekle", "", "kitap.json, olmasına gerek yok; oluştururuz.")

	yetkiliekle = flag.Bool("yetkiliekle", false, "yetkili ekle")
	yetkiliisim = flag.String("yetkiliisim", "", "yetkili tam isim")
	yetkilirol  = flag.String("yetkilirol", "öğretmen", "yetkili rol")
	yetkilipw   = flag.String("yetkilipw", "", "yetkili şifresi")

	getbooks = flag.Bool("getbooks", false, "Kitapları getir")

	getbooknewest = flag.Bool("newest", false, "get newst book")

	getbookspage     = flag.Int("page", 1, "getbooks page")
	getbookscategory = flag.String("category", "", "category array value")
	getbookstitle    = flag.String("title", "", "book title")
	getbookstop      = flag.Bool("top", false, "top books (newest)")

	searchbook = flag.String("searchbook", "", "search RAW book from googleapis")

	systemctlservice = flag.Bool("systemctl", false, "Systemctl service sample")

	//getbookpreview = flag.String("getbookpreview", "", "get book preview from google: -> bookId")

	/*dev              *bool
	kitapekle        *string
	getbooks         *bool
	getbookspage     *int
	getbookscategory *string
	getbookstitle    *string
	getbookstop      *bool

	getbooknewest *bool*/
)

func init() {
	rand.Seed(time.Now().Unix())

	flag.Parse()
}

func main() {
	// j, _ := json.Marshal(libsohal.AddBookOptions{
	// 	Fotograflar: []libsohal.Fotograf{
	// 		{},
	// 	},
	// 	Kitap: template.Book{},
	// })
	// fmt.Println(string(j))

	sohal, err := libsohal.NewLibSohal(libsohal.Config{
		FiberAddr:           os.Getenv("FIBER_ADDR"),
		MongoAddr:           os.Getenv("MONGO_ADDR"),
		MongoConnectTimeout: 10,
	})
	if err != nil {
		fmt.Printf("libsohal.NewLibSohal ana bileşken tanımlanırken hata ile karşılaşıldı!\n\n%v\n", err)
		os.Exit(1)
	}

	if *dev {
		log.Println("Geliştirici modu açık!")

		switch {
		case *systemctlservice:
			{
				if err := os.WriteFile("libsohal.service", systemctlsample, 0555); err != nil {
					log.Fatalln(err)
				}

				log.Println("Service örneği libsohal.service dosyasına yazıldı.\n\033[31msudo cp libsohal.service /etc/systemd/system/\n\033[0m\033[32msudo systemctl enable --now libsohal.service\033[0m")
			}
		case *kitapekle != "":
			{
				file, err := os.Open(*kitapekle)
				if err != nil {
					file, err := os.Create(*kitapekle)
					if err != nil {
						log.Fatalln(err)
					}
					defer file.Close()
					if _, err := file.Write(template.Book{
						Adet: 1,
					}.ToPretty()); err != nil {
						log.Fatalln(err)
					}
					fmt.Println("dosya, template oluşturuldu; lütfen doldurup aynı komut ile baştan çalıştırın")
					return
				}
				var b template.Book
				if err := json.NewDecoder(file).Decode(&b); err != nil {
					log.Fatalln(err)
				}

				if err := sohal.AddBook(context.Background(), b); err != nil {
					log.Fatalln(err)
				}

				fmt.Printf("Kitap %s eklendi!\n", b.Baslik)
			}

		case *yetkiliekle:
			{
				if *yetkiliisim == "" {
					log.Fatalln("--yetkiliisim 'İsim Soyisim'")

				} else if *yetkilipw == "" || len(*yetkilipw) < 6 {
					log.Fatalln("--yetkilipw <INT:en az 6 haneli>")
				}

				pw, err := strconv.Atoi(*yetkilipw)
				if err != nil {
					log.Fatalln(err)
				}

				if y, err := sohal.GetYetkiliByPW(context.Background(), pw); err == nil {
					log.Fatalf("%d pw'si olan bir yetkili zaten mevcut! (%s)", y.Pw, y.Isim)
				}

				if err := sohal.SetYetkili(context.Background(), libsohal.Yetkili{
					Isim: *yetkiliisim, Rol: *yetkilirol,
					Pw: pw,
				}); err != nil {
					log.Fatalln(err)
				}

				log.Println("Başarılı")

			}

		case *getbooks:
			{

				m := bson.M{}
				if (*getbookscategory) != "" {
					m["katagoriler"] = *getbookscategory
				}
				if (*getbookstitle) != "" {
					m["baslik"] = primitive.Regex{Pattern: *getbookstitle, Options: "i"}
				}

				if *getbookstop {
					m["tag"] = "top"
				}

				c := libsohal.GetBooksConfig{
					SortByNewest: *getbooknewest,
				}

				response, err := sohal.GetBooks(context.Background(), *getbookspage, m, c)

				if err != nil {
					log.Fatalln(err)
				}

				a, _ := json.MarshalIndent(response, "", " ")
				fmt.Println(string(a))

				fmt.Println("Toplam: ", len(response))
			}
		case *searchbook != "":
			{
				yanit, err := sohal.SearchBooks.SearchTitle(*searchbook)
				if err != nil {
					log.Fatalln(err)
				}
				v, _ := json.MarshalIndent(yanit, "", " ")
				fmt.Println(string(v))
			}

		default:
			flag.PrintDefaults()
			os.Exit(1)
		}

		return

	}

	if err := sohal.Run(); err != nil {
		fmt.Printf("sohal.Run ana bileşke çalıştırılırken hata ile karşılaşıldı!\n\n%v\n\n", err)
		fmt.Printf("Portun dinlendiğine dair bir hata alıyorsanız aşağıdaki komudu çalıştırmayı deneyin:\fkillall $(pidof %s)\n\n", os.Args[0])
		fmt.Printf("os.Getenv(\"FIBER_ADDR\"): %v\n", os.Getenv("FIBER_ADDR"))

		os.Exit(1)
	}
}
