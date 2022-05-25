package booksearch

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"sync"
)

type BookSearchResponse struct {
	Source string `json:"source"`

	SearchQuery string `json:"search_query"`

	Title   string `json:"title"`
	Summary string `json:"summary"`
	//Author  string `json:"author"`
	Writer string `json:"writer"`

	PageCount int `json:"page_count"`

	PreviewImageUrl string `json:"preview_image_url"`
	Language        string `json:"language"`

	Categories []string `json:"categories"`

	Rating float64 `json:"rating"`

	DemoPagesUrl        []string `json:"demo_pages_url"`
	SupportDemoPagesUrl string   `json:"-"`

	PublishingHouse string `json:"publishing_house"`
	PublishingDate  string `json:"publishing_date"`
}

func (bsr BookSearchResponse) ToJson() []byte {
	j, _ := json.Marshal(bsr)
	return j
}

type BookSearch interface {
	SearchISBN(int64) (BookSearchResponse, error)
	SearchTitle(string) (BookSearchResponse, error)
}

type SearchBooks []BookSearch
type SearchBooksResponse []BookSearchResponse

func (sr SearchBooksResponse) Best() (BookSearchResponse, error) {
	if len(sr) == 0 {
		return BookSearchResponse{}, errors.New("kitap bulunamadı")
	} else if len(sr) == 1 {
		return sr[0], nil
	}

	log.Println("SearchBooksResponse birden fazla! Henüz kodlanmadı... (booksearch.go)")

	return sr[0], nil

}

func (s SearchBooks) SearchISBN(isbn int64) (sr BookSearchResponse, err error) {

	for index, sfn := range s {
		res, err := sfn.SearchISBN(isbn)
		if err != nil {
			fmt.Printf("err: %v\n", err)
			if index+1 == len(s) {
				return sr, err
			}
			continue
		}
		return res, nil

	}
	return sr, errors.New("kitap bulunamadı")
}

func (s SearchBooks) SearchTitle(title string) (sr BookSearchResponse, err error) {

	for index, sfn := range s {
		res, err := sfn.SearchTitle(title)
		if err != nil {
			fmt.Printf("err: %v\n", err)
			if index+1 == len(s) {
				return sr, err
			}
			continue
		}
		return res, nil

	}
	return sr, errors.New("kitap bulunamadı")
}

func (s SearchBooks) SearchISBNAsync(isbn int64) (sr SearchBooksResponse) {
	var wait sync.WaitGroup
	for _, sfn := range s {
		wait.Add(1)
		go func(sfn BookSearch) {
			defer wait.Done()
			res, err := sfn.SearchISBN(isbn)
			if err != nil {
				fmt.Printf("err: %v\n", err)
				return
			}
			sr = append(sr, res)
		}(sfn)
	}

	wait.Wait()
	return
}

func (s SearchBooks) SearchTitleAsycn(title string) (sr SearchBooksResponse) {
	var wait sync.WaitGroup
	for _, sfn := range s {
		wait.Add(1)
		go func(sfn BookSearch) {
			defer wait.Done()
			res, err := sfn.SearchTitle(title)
			if err != nil {
				fmt.Printf("err: %v\n", err)
				return
			}
			sr = append(sr, res)
		}(sfn)
	}

	wait.Wait()
	return
}
