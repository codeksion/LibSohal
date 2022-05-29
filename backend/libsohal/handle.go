package libsohal

import (
	booksearch "backend/libsohal/book_search"
	"backend/libsohal/template"
	"errors"
	"fmt"
	"reflect"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	fiberrec "github.com/gofiber/fiber/v2/middleware/recover"
	"go.mongodb.org/mongo-driver/bson"
)

type BookSearchOptions struct {
	Yeni     bool   `json:"yeni"`
	Adet     int    `json:"adet"`
	Sayfa    int    `json:"sayfa"`
	Baslik   string `json:"beslik"`
	Dil      string `json:"dil"`
	Katagori string `json:"katagori"`
	Yazar    string `json:"yazar"`
	YayinEvi string `json:"yayinevi"`
	Tag      string `json:"tag"`
	Id       string `json:"id"`
	Rastgele bool   `json:"rastgele"`
}

type BookMetaOptions struct {
	ISBN   int64  `json:"isbn"`
	Baslik string `json:"baslik"`
}

/*func init() {
	if _, err := os.Stat("static/unknown_book.png"); err != nil {
		log.Fatalln(err)
	}
}*/ //!! fotograf middleware

func (l *LibSohal) Handle() {

	l.Fiber.Use(logger.New(), fiberrec.New())

	l.Fiber.Get("/catagories", l.Catagories())

	l.Fiber.Get("/static/*", l.StaticRouter)

	l.Fiber.Get("/books", func(c *fiber.Ctx) error {
		var bs BookSearchOptions
		if err := c.QueryParser(&bs); err != nil {
			return err
		}

		if reflect.DeepEqual(bs, BookSearchOptions{}) {
			return c.Status(500).Send(template.ShortCut{
				"error": "eksik ya da yanlış parametreler",
				"example": BookSearchOptions{
					Sayfa:  1,
					Baslik: "Nutuk",
				},
			}.ToJson())
		}

		if bs.Sayfa < 1 {
			bs.Sayfa = 1
		}

		var m = bson.M{}

		if bs.Baslik != "" {
			m["baslik"] = ConvertMongoRegex(bs.Baslik)
		}

		if bs.Dil != "" {
			m["dil"] = bs.Dil
		}

		if bs.Katagori != "" {
			m["katagoriler"] = bs.Katagori
		}

		if bs.Yazar != "" {

			//m["yazar"] = ConvertMongoRegex(bs.Yazar)
			m["yazar"] = bs.Yazar
		}

		if bs.YayinEvi != "" {
			m["yayinevi"] = ConvertMongoRegex(bs.YayinEvi)
		}

		if bs.Tag != "" {
			m["tag"] = bs.Tag
		}

		if bs.Id != "" {
			m["id"] = bs.Id
		}

		// if bs.Rastgele {
		// 	bs.Yeni = false
		// }

		yanit, err := l.GetBooks(c.Context(), bs.Sayfa, m, GetBooksConfig{
			SortByNewest: bs.Yeni,
			Max:          bs.Adet,
			//Random:       bs.Rastgele,
		})
		if err != nil {
			return err
		}
		count, err := l.GetBooksCount(c.Context(), m)
		if err != nil {
			return err
		}
		// for i, v := range yanit {
		// 	y, _ := l.GetBorrowBooksCountByID(c.Context(), v.ID, true)
		// 	v.Borrowable = (v.Adet > int(y))
		// 	yanit[i] = v
		// }
		c.Set("Content-Type", "application/json")
		return c.Send(template.Books{
			Books:      yanit,
			TotalItems: count,
		}.ToJson())

	})

	l.Fiber.Get("/bookmeta", func(c *fiber.Ctx) error {
		/*var o BookMetaOptions
		if err := c.QueryParser(&o); err != nil {
			return err
		}
		if reflect.DeepEqual(o, BookMetaOptions{}) {
			return c.Status(500).Send(template.ShortCut{
				"error": "eksik ya da yanlış parametreler",
				"example": BookMetaOptions{
					ISBN:   0,
					Baslik: "nutuk",
				},
			}.ToJson())
		}*/

		key := c.Query("q")
		if key == "" {
			return c.Status(500).Send(template.ShortCut{
				"error":   "eksik ya da yanlış parametreler",
				"example": "q=<ISBN|TITLE>",
			}.ToJson())
		}

		//var book apibook.Book
		var book booksearch.BookSearchResponse
		var err error

		isbn, err := strconv.Atoi(key)
		if err == nil {
			book, err = l.SearchBooks.SearchISBN(int64(isbn))
			//book, err = l.ApiBook.SearchByISBN(int64(isbn))
		} else {
			book, err = l.SearchBooks.SearchTitle(key)
			//book, err = l.ApiBook.SearchByQuery(key)
		}

		if err != nil {
			return err
		}
		return c.Send(book.ToJson())

	})

	l.Fiber.Get("/booksummary", func(c *fiber.Ctx) error {
		isbn := c.Query("isbn")
		if isbn == "" {
			return errors.New("isbn cannot be empty")
		}
		v, err := l.BookFinder.SearchFromISBN(isbn)
		if err != nil {
			return err
		}
		if i := strings.Index(v, "Sayfa Sayisi"); i != -1 {
			v = v[0:i]
		}
		return c.SendString(v)
	})

	l.Fiber.Get("/borrowable", func(c *fiber.Ctx) error {
		bookid := c.Query("book_id")
		if bookid == "" {
			return errors.New("book_id cannot be empty")
		}

		ok, err := l.IsBorrowable(c.Context(), bookid)
		if err != nil {
			return err
		}

		return c.Send(template.ShortCut{"borrowable": ok}.ToJson())
	})

	l.Fiber.Post("/borrow", l.BorrowBookRouter)

	l.Fiber.Post("/ocr", func(c *fiber.Ctx) error {
		image, err := c.FormFile("image")
		if err != nil {
			fmt.Printf("1 err: %v\n", err)
			return err
		}
		file, err := image.Open()
		if err != nil {
			fmt.Printf("2 err: %v\n", err)
			return err
		}

		defer file.Close()

		ocrresult, err := l.OCR.Text(c.Context(), file)
		if err != nil {
			fmt.Printf("3 err: %v\n", err)
			return err
		}

		return c.SendString(ocrresult)

	})

	l.Fiber.Get("/imageproxy", l.ImageProxy.FiberHandler)

	l.Fiber.Get("/cbd", l.Libgen.SearchHandler) // can book dowloadable?

	l.Fiber.Get("/db", l.Libgen.DownloadHandler)

	l.YetkiliMiddleware()
}
