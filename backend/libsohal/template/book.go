package template

import "encoding/json"

const MongoBookDatabase = "books"
const MongoBookCollection = "book"
const MongoYetkiliDatabase = "yetkililer"
const MongoYetkiliCollection = "yetkili"

type Book struct {
	ID          string `json:"id"`
	Baslik      string `json:"baslik"`
	Yazar       string `json:"yazar"`
	Dil         string `json:"dil"` // türkçe english deutchsland
	SayfaSayisi int    `json:"sayfa_sayisi"`

	Adet int `json:"adet"`

	Katagoriler []string `json:"katagoriler"`

	YayinEvi  string `json:"yayin_evi"`
	BasimYili string `json:"basim_yili"`

	KitapKonumu BookLocation `json:"kitap_konumu"`

	Fotograflar []string `json:"fotograflar"`

	Tag string `json:"tag"` // top

	Ozet string `json:"ozet"`

	//Borrowable bool `json:"borrowable" mongo:"-"`
}

func (b Book) ToPretty() []byte {
	a, _ := json.MarshalIndent(b, "", " ")
	return a
}

type Books struct {
	Books      []Book `json:"books"`
	TotalItems int64  `json:"total_items"`
}

func (b Books) ToJson() []byte {
	j, _ := json.Marshal(b)
	return j
}
