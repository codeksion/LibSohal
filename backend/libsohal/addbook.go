package libsohal

import (
	"backend/libsohal/template"
	"fmt"
	"io"
	"log"
	"net/url"
	"reflect"
	"time"

	"github.com/gofiber/fiber/v2"
)

type Fotograf struct {
	IsRemote bool   `json:"is_remote"`
	IsBase64 bool   `json:"is_base64"`
	IsLocal  bool   `json:"is_local"`
	Data     string `json:"data"`
}

type AddBookOptions struct {
	Fotograflar []Fotograf    `json:"fotograflar"`
	Kitap       template.Book `json:"kitap"`
}

func (a AddBookOptions) FotogralarRaw() (l []string) {
	l = []string{}
	for _, f := range a.Fotograflar {
		l = append(l, f.Data)
	}

	return

}

func (l *LibSohal) AddBookHandler(c *fiber.Ctx) error {
	log.Println("Kitap eklenecek!")
	var olay AddBookOptions = AddBookOptions{
		Fotograflar: []Fotograf{
			{
				IsRemote: true,
				Data:     "https://books.google.com.tr/books/publisher/content?id=aMwAEAAAQBAJ&hl=tr&pg=PA7&img=1&zoom=3&sig=ACfU3U0UYyAJGqH-Lb0RJyWzW84vM9A5MQ",
			},
		},
		Kitap: template.Book{
			Katagoriler: []string{"bilgisayarlar"},
		},
	}
	if err := c.BodyParser(&olay); err != nil {

		return c.Status(500).Send(template.ShortCut{
			"success": false,
			"error":   err.Error(),
			"example": olay,
		}.ToJson())
	}
	//fmt.Printf("olay: %v\n", olay)

	if reflect.DeepEqual(olay, AddBookOptions{}) || olay.Kitap.ID == "" || olay.Kitap.Baslik == "" {
		return c.Status(500).Send(template.ShortCut{
			"error":   "eksik ya da yanlış parametreler",
			"example": olay,
		}.ToJson())
	}

	for index, value := range olay.Fotograflar {
		var salt string
		if value.IsRemote {

			if parsed, err := url.Parse(value.Data); err == nil {
				salt = parsed.Query().Get("sig")
			}
		}

		if salt == "" {
			salt = time.Now().Format(time.RFC3339)
		}

		filename := fmt.Sprintf("book_%s_%s_%d", olay.Kitap.ID, salt, index)
		fmt.Printf("filename: %v\n", filename)
		olay.Fotograflar[index] = Fotograf{
			IsLocal: true,
			Data:    filename,
		}

		if l.ImageRouter.Exists(filename) {
			log.Printf("Image (%s) exists; skiping\n", salt)
			continue
		}

		switch {
		case value.IsBase64:
			{
				if err := l.ImageRouter.WriteBASE64Image(filename, value.Data); err != nil {
					return err
				}
			}
		case value.IsRemote:
			{

				if value.Data == "" {
					//c.Context().Logger().Printf("remote olarak işaretlenmiş ancak data boş; es geçiliyor!")
					continue
				}
				resp, err := l.ImageRouter.Client.Get(value.Data)
				if err != nil {
					return err
				}
				defer resp.Body.Close()
				writer, err := l.ImageRouter.Writer(filename)
				if err != nil {
					return err
				}

				defer writer.Close()

				if _, err := io.Copy(writer, resp.Body); err != nil {
					return err
				}

			}
		default:
			return fiber.NewError(500, "unimplemented")
		}
	}

	// if olay.OtoFotografEkle {
	// 	log.Println("OtoFotografEkle")
	// 	isbn, err := strconv.Atoi(olay.Kitap.ID)
	// 	if err != nil {
	// 		return err
	// 	}
	// 	if res, err := l.SearchBooks.SearchISBN(int64(isbn)); err == nil {
	// 		olay.Fotograflar = append(olay.Fotograflar, res.DemoPagesUrl...)
	// 	}

	// 	// if veri, err := l.ApiBook.SearchByQuery("isbn:" + olay.Kitap.ID); err == nil && veri.Items[0].VolumeInfo.ReadingModes.Image {
	// 	// 	log.Println("Kitap image preview var")
	// 	// 	if pr, err := l.ApiBookPreview.GetBookPreview(veri.Items[0].ID); err == nil {
	// 	// 		olay.Fotograflar = append(olay.Fotograflar, pr.GetSRCs()...)
	// 	// 	}
	// 	// }
	// }

	fmt.Printf("olay.Fotograflar: %v\n", olay.Fotograflar)

	if dbkitap, err := l.GetBookById(c.Context(), olay.Kitap.ID); err == nil {
		log.Printf("%s kitap zaten var (%s). Sayıya ekleme yapılacak.", olay.Kitap.ID, dbkitap.Baslik)

		dbkitap.Adet++

		if len(olay.Fotograflar) != 0 {
			dbkitap.Fotograflar = append(dbkitap.Fotograflar, olay.FotogralarRaw()...)
		}

		if err := l.UpdateBook(c.Context(), dbkitap); err != nil {
			fmt.Printf("err: %v\n", err)
			return err
		}
	} else {
		olay.Kitap.Fotograflar = olay.FotogralarRaw()
		olay.Kitap.Adet = 1
		if err := l.SetBook(c.Context(), olay.Kitap); err != nil {
			return err
		}
	}

	return c.Send(template.ShortCut{
		"success": true,
	}.ToJson()) //!! TODO OK!

}
