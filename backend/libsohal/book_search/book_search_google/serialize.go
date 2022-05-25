package booksearchgoogle

import (
	booksearch "backend/libsohal/book_search"
	"encoding/json"
)

type Books []Book

type Book struct {
	Kind       string     `json:"kind"`
	TotalItems int        `json:"totalItems"`
	Items      []BookItem `json:"items"`
}

type BookItem struct {
	Kind       string     `json:"kind"`
	ID         string     `json:"id"`
	Etag       string     `json:"etag"`
	SelfLink   string     `json:"selfLink"`
	VolumeInfo VolumeInfo `json:"volumeInfo"`
	SaleInfo   struct {
		Country     string `json:"country"`
		Saleability string `json:"saleability"`
		IsEbook     bool   `json:"isEbook"`
	} `json:"saleInfo"`
	AccessInfo struct {
		Country                string `json:"country"`
		Viewability            string `json:"viewability"`
		Embeddable             bool   `json:"embeddable"`
		PublicDomain           bool   `json:"publicDomain"`
		TextToSpeechPermission string `json:"textToSpeechPermission"`
		Epub                   struct {
			IsAvailable bool `json:"isAvailable"`
		} `json:"epub"`
		Pdf struct {
			IsAvailable bool `json:"isAvailable"`
		} `json:"pdf"`
		WebReaderLink       string `json:"webReaderLink"`
		AccessViewStatus    string `json:"accessViewStatus"`
		QuoteSharingAllowed bool   `json:"quoteSharingAllowed"`
	} `json:"accessInfo"`
	SearchInfo struct {
		TextSnippet string `json:"textSnippet"`
	} `json:"searchInfo"`
}

func (buk Book) ToJson() (b []byte) {
	b, _ = json.Marshal(buk)
	return
}

type VolumeInfo struct {
	Title               string   `json:"title"`
	Subtitle            string   `json:"subtitle"`
	Authors             []string `json:"authors"`
	Publisher           string   `json:"publisher"`
	PublishedDate       string   `json:"publishedDate"`
	Description         string   `json:"description"`
	IndustryIdentifiers []struct {
		Type       string `json:"type"`
		Identifier string `json:"identifier"`
	} `json:"industryIdentifiers"`
	ReadingModes struct {
		Text  bool `json:"text"`
		Image bool `json:"image"`
	} `json:"readingModes"`
	PageCount           int      `json:"pageCount"`
	PrintType           string   `json:"printType"`
	Categories          []string `json:"categories"`
	MaturityRating      string   `json:"maturityRating"`
	AllowAnonLogging    bool     `json:"allowAnonLogging"`
	ContentVersion      string   `json:"contentVersion"`
	PanelizationSummary struct {
		ContainsEpubBubbles  bool `json:"containsEpubBubbles"`
		ContainsImageBubbles bool `json:"containsImageBubbles"`
	} `json:"panelizationSummary"`
	// ImageLinks struct {
	// 	SmallThumbnail string `json:"smallThumbnail"`
	// 	Thumbnail      string `json:"thumbnail"`
	// } `json:"imageLinks"`
	ImageLinks          map[string]string `json:"imageLinks"`
	Language            string            `json:"language"`
	PreviewLink         string            `json:"previewLink"`
	InfoLink            string            `json:"infoLink"`
	CanonicalVolumeLink string            `json:"canonicalVolumeLink"`
	AverageRating       float64           `json:"averageRating"`
	RatingsCount        int               `json:"ratingsCount"`
}

func (buk VolumeInfo) ToJson() (b []byte) {
	b, _ = json.Marshal(buk)
	return
}

func (vf VolumeInfo) ToBookSearchResponse() (resp booksearch.BookSearchResponse) {
	resp.Source = "google"
	resp.Title = vf.Title

	if len(vf.Authors) != 0 {
		resp.Writer = vf.Authors[0]
	}
	resp.PublishingDate = vf.PublishedDate
	resp.PageCount = vf.PageCount

	resp.Summary = vf.Description
	if resp.Summary == "" {
		resp.Summary = vf.Title
	}

	resp.PublishingHouse = vf.Publisher

	if len(vf.ImageLinks) != 0 {

		var plist = [1]string{}
		for _, value := range vf.ImageLinks {
			plist[0] = value
		}

		resp.PreviewImageUrl = plist[0]
	}

	resp.Rating = vf.AverageRating
	//resp.PreviewImageUrl = vf.ImageLinks.Thumbnail

	resp.Language = vf.Language
	resp.Categories = vf.Categories

	if vf.ReadingModes.Image {
		resp.SupportDemoPagesUrl = vf.PreviewLink
	}

	// for _, ctg := range vf.Categories {
	// 	ct, err := gtranslate.Translate(ctg, language.English, language.Turkish)
	// 	if err != nil {
	// 		log.Printf("Error on Gtranslate (text: %s lang: EN-TR)\n", ctg)
	// 	} else {
	// 		resp.Categories = append(resp.Categories, strings.ToLower(ct))
	// 	}
	// }

	return

}
