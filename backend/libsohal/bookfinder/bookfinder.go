package bookfinder

import (
	"crypto/tls"
	"net/http"
)

type BookFinder struct {
	URL    string
	Client *http.Client
}

func NewBookFinder() *BookFinder {
	return &BookFinder{
		URL: "https://www.bookfinder.com",
		Client: &http.Client{
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					InsecureSkipVerify: true,
				},
			},
		},
	}
}
