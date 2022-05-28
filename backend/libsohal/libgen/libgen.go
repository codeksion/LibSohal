package libgen

import (
	"backend/libsohal/template"
	"bytes"
	"context"
	"crypto/tls"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	libgenapi "github.com/mattboran/libgen-go/api"
	"github.com/patrickmn/go-cache"
)

type LibgenBooks []libgenapi.DownloadableResult

func (l LibgenBooks) Take() libgenapi.DownloadableResult {
	if len(l) == 0 {
		return nil
	}

	var pdfformat libgenapi.DownloadableResult

	for _, a := range l {
		fx := strings.Split(a.Filename(), ".")
		ext := fx[len(fx)-1]
		if ext == "epub" { // best reading format
			return a
		} else if ext == "pdf" && pdfformat == nil {
			pdfformat = a
		}
	}

	if pdfformat != nil {
		return pdfformat
	}

	return l[0]
}

type Config struct {
	Url           *url.URL
	AddImageCache func(c *fiber.Ctx, _url string) string //?? BAD DESIGN!
}

type Libgen struct {
	config Config
	Mem    *cache.Cache
	// DownloadClient  *http.Client // Skiping; library not supporting
	DownloadHandler fiber.Handler
	SearchHandler   fiber.Handler
}

func NewLibgen(c Config) (l *Libgen) {
	if c.Url == nil {
		c.Url = &url.URL{
			Scheme: "https",
			Host:   "libgen.is",
		}
	}

	l = &Libgen{
		config: c,
		Mem:    cache.New(time.Minute*5, time.Minute*5),
		SearchHandler: func(c *fiber.Ctx) error {
			query := c.Query("query")
			if query == "" {
				return fiber.NewError(500, "query cannot be empty")
			}

			// Library doesnot supporting context
			books, err := libgenapi.Search(libgenapi.TextbookSearchInput{
				Query: []string{query},
				//Criteria: "def",
				Page: 1,
			})
			if err != nil {
				return fiber.NewError(500, fmt.Sprintf("libgen search %s error: %v", query, err))
			}
			//fmt.Printf("books: %+v\n", *books)

			book := LibgenBooks(books.Results).Take() // maybe
			if book == nil {
				return fiber.NewError(500, fmt.Sprintf("could't find book: %s", query))
			}

			l.Mem.Set(query, book.Mirrors(), 0)

			c.Set("Content-Type", "application/json")
			return c.Send(template.ShortCut{
				"name": book.Name(),
			}.ToJson())

		},
		DownloadHandler: func(c *fiber.Ctx) error {
			query := c.Query("query")
			if query == "" {
				return fiber.NewError(500, "query cannot be empty")
			}
			value, ok := l.Mem.Get(query)
			if !ok {
				return fiber.NewError(500, fmt.Sprintf("title %s not exists or expired", query))
			}
			results /*, ok */ := value.([]libgenapi.Mirror) // skiping type control

			fmt.Printf("results: %v\n", results)
			var bookbody *http.Response
			var errlist = []error{}

			for _, m := range results {
				var err error
				bookbody, err = DownloadMirror(c.Context(), m)
				if err != nil {
					fmt.Printf("err: %v\n", err)
					errlist = append(errlist, err)
				} else {
					break
				}
			}

			if bookbody == nil {
				return fiber.NewError(500, fmt.Sprintf("%d mirror tried to download book errors=%+v", len(results), errlist))
			}
			cc := c.Context()

			go func() {

				if dc := cc.Done(); dc != nil {
					<-dc
				}
				bookbody.Body.Close()
			}()

			c.Set("Content-Disposition", bookbody.Header.Get("Content-Disposition"))
			return c.SendStream(bookbody.Body, int(bookbody.ContentLength))

		},
	}
	return
}

var clientwithtimeout = &http.Client{
	Timeout: time.Second * 10,
	Transport: &http.Transport{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	},
}

func DownloadMirror(ctx context.Context, mirror libgenapi.Mirror) (*http.Response, error) {

	req, err := http.NewRequestWithContext(ctx, "GET", mirror.Link(), nil)
	if err != nil {
		return nil, err
	}
	response, err := clientwithtimeout.Do(req)
	if err != nil {
		return nil, err
	} else if response.StatusCode != 200 {
		response.Body.Close()
		return nil, fmt.Errorf("unexcepted status code=%d", response.StatusCode)
	}
	read, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, err
	}

	response.Body.Close()
	respurl := response.Request.URL.String()

	var _url string

	switch {
	case strings.Contains(respurl, "libgen"):
		{
			getindex := bytes.Index(read, []byte("get.php"))
			if getindex == -1 {
				err = fmt.Errorf("libgen.* query 'get.php' not exists")
				break
			}
			full := read[getindex : getindex+bytes.Index(read[getindex:], []byte("\""))]
			fmt.Printf("full: %v\n", string(full))

			u, _ := url.Parse(mirror.Link())
			_url = (&url.URL{
				Scheme: u.Scheme,
				Host:   u.Host,
			}).String() + "/" + string(full)
		}
	default:
		err = fmt.Errorf("unimplemented mirror url: %s", mirror.Link())
	}

	if err != nil {
		return nil, err
	}

	fmt.Printf("_url: %v\n", _url)

	yanit, err := http.Get(_url)
	if err != nil {
		return nil, err
	}
	if yanit.StatusCode != 200 {
		yanit.Body.Close()
		return nil, fmt.Errorf("unexcepted status code %d", yanit.StatusCode)
	}

	return yanit, nil

}
