package booksearchgoogle

import (
	booksearch "backend/libsohal/book_search"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strings"
	"sync"

	"github.com/bregydoc/gtranslate"
	"golang.org/x/text/language"
)

type GoogleApisBooks struct {
	URL            string
	Client         *http.Client
	ApiBookPreview *ApiBookPreview
}

func NewGoogleApisBooks() *GoogleApisBooks {

	return &GoogleApisBooks{
		URL: "https://www.googleapis.com/books/v1",
		Client: &http.Client{
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					InsecureSkipVerify: true,
				},
			},
		},
		ApiBookPreview: NewApiBookPreview(),
	}
}

func (g *GoogleApisBooks) previewImageURL(id string, zoom int) string {
	return fmt.Sprintf("https://books.google.com/books/content?id=%s&printsec=frontcover&img=1&zoom=%d", id, zoom)
	//https://books.google.com/books/content?id=wqqdDliW5XEC&printsec=frontcover&img=1&zoom=6
}

func (g *GoogleApisBooks) request(rawquery string) (*http.Response, error) {
	return g.Client.Get(g.URL + rawquery)
}

func (g *GoogleApisBooks) BookWithGoogleId(id string) (b BookItem, err error) {
	resp, err := g.Client.Get(g.URL + "/volumes/" + id)
	if err != nil {
		return b, err
	}
	defer resp.Body.Close()
	err = json.NewDecoder(resp.Body).Decode(&b)
	return
}

func (g *GoogleApisBooks) SearchByISBN(isbn int64) (b Book, err error) {
	response, err := g.request(fmt.Sprintf("/volumes?q=isbn:%d", isbn))
	if err != nil {
		return b, err
	}

	defer response.Body.Close()

	if err = json.NewDecoder(response.Body).Decode(&b); err != nil {
		return
	}

	if b.TotalItems == 0 {
		err = errors.New("kitap bulunamadı")
	}
	return
}

func (g *GoogleApisBooks) SearchByQuery(query string) (b Book, err error) {
	response, err := g.request(fmt.Sprintf("/volumes?q=%s", url.QueryEscape(query)))
	if err != nil {
		return b, err
	}

	defer response.Body.Close()

	if err = json.NewDecoder(response.Body).Decode(&b); err != nil {
		return
	}

	if b.TotalItems == 0 {
		err = errors.New("kitap bulunamadı")
	}
	return
}

func (g *GoogleApisBooks) workWithResponse(resp booksearch.BookSearchResponse, googleid ...string) booksearch.BookSearchResponse {
	var wait sync.WaitGroup

	var demopagesurl []string
	var categories = []string{}

	wait.Add(1)
	go func() {
		defer wait.Done()
		for _, k := range resp.Categories {
			k, err := gtranslate.Translate(k, language.English, language.Turkish)
			if err != nil {
				log.Printf("Error Gtranslate (Text: %s Lang: EN-TR)\n", k)
				continue
			}
			categories = append(categories, strings.ToLower(k))
			//resp.Categories[i] = strings.ToLower(k)

		}
	}()

	if len(googleid) != 0 {
		if resp.SupportDemoPagesUrl != "" {
			wait.Add(1)
			go func() {
				defer wait.Done()
				pre, err := g.ApiBookPreview.GetBookPreview(googleid[0])
				if err != nil {
					log.Printf("Error GBookPreview %s %v\n", googleid[0], err)
					return
				}

				// resp.DemoPagesUrl = pre.GetSRCs()
				// if len(resp.DemoPagesUrl) > 20 {
				// 	resp.DemoPagesUrl = resp.DemoPagesUrl[0:20] // Limit
				// }

				demopagesurl = pre.GetSRCs()
				if len(demopagesurl) > 20 {
					demopagesurl = demopagesurl[0:20]
				}

			}()

			wait.Add(1)
			go func() {
				defer wait.Done()
				b, err := g.BookWithGoogleId(googleid[0])
				if err != nil {
					fmt.Printf("err: %v\n", err)
					return
				}
				resp = b.VolumeInfo.ToBookSearchResponse()
			}()
		}
	}

	wait.Wait()

	resp.Categories = categories
	resp.DemoPagesUrl = demopagesurl

	return resp
}

func (g *GoogleApisBooks) SearchISBN(isbn int64) (resp booksearch.BookSearchResponse, err error) {
	var b Book
	if b, err = g.SearchByISBN(isbn); err != nil {
		return
	}
	if len(b.Items) == 0 {
		return resp, errors.New("kitap bulunamadı")
	}

	resp = g.workWithResponse(b.Items[0].VolumeInfo.ToBookSearchResponse(), b.Items[0].ID)

	resp.SearchQuery = fmt.Sprint(isbn)
	return
}

func (g *GoogleApisBooks) SearchTitle(title string) (resp booksearch.BookSearchResponse, err error) {
	var b Book
	if b, err = g.SearchByQuery(title); err != nil {
		return
	}
	if len(b.Items) == 0 {
		return resp, errors.New("kitap bulunamadı")
	}

	resp = g.workWithResponse(b.Items[0].VolumeInfo.ToBookSearchResponse(), b.Items[0].ID)

	resp.SearchQuery = title
	return
}
