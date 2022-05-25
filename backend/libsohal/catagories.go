package libsohal

import (
	"backend/libsohal/template"
	"context"
	"log"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func compareStrings(list []string, key string) bool {
	for _, a := range list {
		if a == key {
			return true
		}
	}
	return false
}

func (l *LibSohal) Catagories() fiber.Handler {
	var catagories = []string{}
	go func() {
		for range time.NewTicker(time.Second * 60).C {
			imlec, err := l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).Find(context.Background(), template.ShortCut{}, options.Find())
			if err != nil {
				log.Println("error on catagories loop Find: ", err)
				continue
			}

			var booklist []template.Book

			if err := imlec.All(context.Background(), &booklist); err != nil {
				log.Println("error on cataogires loop All: ", err)
				continue
			}
			//fmt.Printf("len(booklist): %v\n", len(booklist))
			for _, v := range booklist {
				for _, k := range v.Katagoriler {

					if k != "" && !compareStrings(catagories, k) {
						catagories = append(catagories, k)
					}
				}
			}
		}
	}()

	return func(c *fiber.Ctx) error {
		return c.SendString(strings.Join(catagories, ","))
	}

}
