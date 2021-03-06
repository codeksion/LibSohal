package libsohal

import (
	booksearch "backend/libsohal/book_search"
	booksearchgoogle "backend/libsohal/book_search/book_search_google"
	"backend/libsohal/bookfinder"
	"backend/libsohal/imageproxy"
	"backend/libsohal/libgen"
	"log"

	//"backend/libsohal/ipc"
	"backend/libsohal/ocr"
	"backend/libsohal/template"
	"context"
	"fmt"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/valyala/fasthttp"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Config struct {
	BorrowAttention     template.BorrowableAttention
	FiberAddr           string
	MongoAddr           string
	MongoConnectTimeout int
}

type LibSohal struct {
	c           Config
	Fiber       *fiber.App
	Mongo       *mongo.Client
	SearchBooks booksearch.SearchBooks
	//Ipc         ipc.Ipc
	// ApiBook        *apibook.GoogleApisBooks
	// ApiBookPreview *apibookpreview.ApiBookPreview
	Libgen      *libgen.Libgen
	ImageProxy  *imageproxy.ImageProxy
	BookFinder  *bookfinder.BookFinder
	ImageRouter *ImageRouter

	OCR ocr.OCR
}

func NewLibSohal(c Config) (l *LibSohal, err error) {
	l = &LibSohal{
		c: c,
		// ApiBook:        apibook.NewGoogleApisBooks(),
		// ApiBookPreview: apibookpreview.NewApiBookPreview(),
		SearchBooks: booksearch.SearchBooks{
			booksearchgoogle.NewGoogleApisBooks(),
		},
		BookFinder: bookfinder.NewBookFinder(),
		ImageProxy: imageproxy.NewImageProxy(imageproxy.Config{
			Duration: time.Minute,
		}),
		Libgen: libgen.NewLibgen(libgen.Config{
			AddImageCache: func(c *fiber.Ctx, _url string) string {

				l.ImageProxy.Put(_url)

				var u = &fasthttp.URI{}
				c.Request().URI().CopyTo(u)
				u.SetPath("/imageproxy")
				u.SetQueryString("url=" + _url)

				return u.String()
			}, //! Bad desine!
			//Url: ,// URL
		}), // TODO

	}
	// l.Ipc, err = ipc.NewServer(ipc.Config{
	// 	SocketPath: "libsohal",
	// 	OnListenError: func(err error) {
	// 		log.Printf("IPC listen error: \033[31m%+v\033[0m\n", err)
	// 	},
	// 	OnEvent: l.IpcEventHandler,
	// })
	// if err != nil {
	// 	return
	// }
	if l.OCR, err = ocr.NewEasyOcr(ocr.Options{
		Path: "easyocrbin",
	}); err != nil {
		log.Printf("Move easyocrbin to $PATH\n$:\tchmod +x easyocrbin ; sudo cp easyocrbin /usr/bin")
		return
	}

	l.ImageRouter, err = NewImageRouter("static")
	if err != nil {
		return
	}

	l.Fiber = fiber.New(
		fiber.Config{

			Prefork:      os.Getenv("PREFORK") != "",
			ReadTimeout:  time.Second * 30,
			WriteTimeout: time.Second * 30,

			ErrorHandler: func(c *fiber.Ctx, e error) error {

				return c.Status(500).Send(template.ShortCut{
					"error": fmt.Sprint(e),
				}.ToJson())
			},
			BodyLimit: 50 * 1024 * 1024,
			AppName:   "LibSOHAL API",
			//StreamRequestBody: true,
			// WriteTimeout: time.Second * 30, // Unnecessary
		},
	)

	l.Mongo, err = mongo.NewClient(options.Client().ApplyURI(l.c.MongoAddr))
	if err != nil {
		return
	}

	timeoutctx, cancel := context.WithTimeout(context.Background(), time.Second*time.Duration(l.c.MongoConnectTimeout))
	defer cancel()
	err = l.Mongo.Connect(timeoutctx)
	if err != nil {
		return
	}
	l.Handle()
	return
}

func (l *LibSohal) Run() error {
	return l.Fiber.Listen(l.c.FiberAddr)
}
