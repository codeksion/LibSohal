package libgen

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"

	"github.com/ciehanski/libgen-cli/libgen"
)

// import (
// 	"log"

// 	"github.com/ciehanski/libgen-cli/libgen"
// )

// func tez() {
// 	books, err := libgen.Search(&libgen.SearchOptions{
// 		Query: "abc",
// 	})
// 	if err != nil {
// 		log.Fatalln(err)
// 	}

// 	for _, v := range books{
// 		if v.
// 	}
// }

func SearchLibgenBook(query string) (l []*libgen.Book, err error) {
	return libgen.Search(&libgen.SearchOptions{
		SearchMirror: url.URL{
			Scheme: "https",
			Host:   "libgen.is",
		},
		Query:   query,
		Results: 3,
	})
}

func DownloadLibgenBook(ctx context.Context, book *libgen.Book) (io.ReadCloser, error) {
	fmt.Printf("book.DownloadURL: %v\n", book.DownloadURL)
	yanit, err := http.Get(book.DownloadURL)
	if err != nil {
		return nil, err
	}

	if yanit.StatusCode != 200 {
		yanit.Body.Close()
		return nil, fmt.Errorf("invalid status code on download book: %v", yanit.Status)
	}

	return yanit.Body, err
}
