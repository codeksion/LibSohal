package booksearchgoogle

import (
	"crypto/tls"
	"encoding/json"
	"errors"
	"net/http"
)

type ApiBookPreview struct {
	URL    string
	Client *http.Client
}

func NewApiBookPreview() *ApiBookPreview {
	return &ApiBookPreview{
		URL: "https://books.google.com.tr",
		Client: &http.Client{
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					InsecureSkipVerify: true,
				},
			},
		},
	}
}

type BookPreviewLayout struct {
	Page []struct {
		Pid   string `json:"pid"`
		Src   string `json:"src,omitempty"`
		Flags int    `json:"flags,omitempty"`
		Order int    `json:"order,omitempty"`
		Uf    string `json:"uf,omitempty"`
	} `json:"page"`
}

func (b BookPreviewLayout) GetSRCs() (list []string) {
	list = []string{}
	for _, a := range b.Page {
		if a.Src != "" {
			list = append(list, a.Src)
		}
	}

	return
}

func (a *ApiBookPreview) GetBookPreview(googleBookId string) (b BookPreviewLayout, err error) {
	response, err := a.Client.Get(a.URL + "/books?id=" + googleBookId + "&lpg=PA1&hl=tr&pg=PA4&jscmd=click3")
	if err != nil {
		return b, err
	}

	defer response.Body.Close()

	if response.StatusCode != 200 {
		return b, errors.New("cloudn't find preview")
	}

	err = json.NewDecoder(response.Body).Decode(&b)
	return
}
