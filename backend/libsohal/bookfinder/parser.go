package bookfinder

import (
	"io"

	"github.com/PuerkitoBio/goquery"
)

func (l *BookFinder) Parser(reader io.Reader) (string, error) {
	var ozet string

	query, err := goquery.NewDocumentFromReader(reader)
	if err != nil {
		return ozet, err
	}
	query.Find("div").Each(func(i int, s *goquery.Selection) {
		if ozet != "" {
			return
		}
		if s.AttrOr("id", "") == "bookSummary" {
			ozet = s.Text()
		}
	})

	return ozet, nil

}
