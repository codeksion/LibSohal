package libsohal

import (
	"backend/libsohal/template"
	"context"
	"fmt"
	"strings"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var replaceMap = map[string][]string{
	"ç": {"c"},
	"c": {"ç"},
	"Ç": {"C"},
	"C": {"Ç"},
	"ğ": {"g"},
	"g": {"ğ"},
	"Ğ": {"G"},
	"G": {"Ğ"},
	"ı": {"i", "I", "İ"},
	"i": {"ı", "I", "İ"},
	"I": {"İ", "ı", "i"},
	"İ": {"I", "ı", "i"},
	"ö": {"o"},
	"o": {"ö"},
	"Ö": {"O"},
	"O": {"Ö"},
	"ş": {"s"},
	"s": {"ş"},
	"Ş": {"S"},
	"S": {"Ş"},
	"ü": {"u"},
	"u": {"ü"},
	"Ü": {"U"},
	"U": {"Ü"},
}

type GetBooksConfig struct {
	SortByNewest bool
	Random       bool
}

func (l *LibSohal) AddBook(ctx context.Context, b template.Book) error {

	var ob template.Book = b

	err := l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).FindOne(ctx, bson.M{
		"id": b.ID,
	}).Decode(&ob)

	if err == nil {
		b.Fotograflar = append(b.Fotograflar, ob.Fotograflar...)
		b.Adet = ob.Adet + 1
		return l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).FindOneAndReplace(ctx, bson.M{"id": b.ID}, b).Err()
	}

	_, err = l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).InsertOne(ctx, b)
	return err

}

func (l *LibSohal) GetBook(ctx context.Context, b bson.M) (book template.Book, err error) {
	err = l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).FindOne(ctx, b).Decode(&book)
	return
}

func (l *LibSohal) GetBookById(ctx context.Context, id string) (template.Book, error) {
	return l.GetBook(ctx, bson.M{
		"id": id,
	})
}

func (l *LibSohal) GetBooks(ctx context.Context, page int, b any, c ...GetBooksConfig) (blist []template.Book, err error) {
	skip := int64((page - 1) * 50)
	max := int64(50)

	options := &options.FindOptions{
		Skip:  &skip,
		Limit: &max,
	}

	var cursor *mongo.Cursor

	if len(c) != 0 {
		if c[0].SortByNewest {
			options.SetSort(bson.M{"_id": -1})
		}

		if c[0].Random { // Test edilmedi!
			if cursor, err = l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).Aggregate(ctx, mongo.Pipeline{
				{
					{
						Key:   "sample",
						Value: bson.M{"size": max},
					},
				},
			}); err != nil {
				return
			}
		}

	}

	if cursor == nil {

		cursor, err = l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).Find(ctx, b, options)
		if err != nil {
			return nil, err
		}
	}

	err = cursor.All(ctx, &blist)
	return
}

func (l *LibSohal) GetBooksCount(ctx context.Context, b bson.M) (int64, error) {
	return l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).CountDocuments(ctx, b)
}

func (l *LibSohal) GetBooksByCategory(ctx context.Context, page int, category string) (bl []template.Book, err error) {
	return l.GetBooks(ctx, page, bson.M{
		"katagoriler": category,
	})
}

func ConvertMongoRegex(text string) primitive.Regex {
	var output string
	for _, tv := range text {
		var anahtar = string(tv)

		for key, value := range replaceMap {
			//for _, tv := range text {
			//var eslesme bool

			if anahtar == key {
				anahtar = fmt.Sprintf("[%s%s ]", anahtar, strings.Join(value, ""))
				break

			}

			if anahtar == string(tv) {
				anahtar = anahtar + "?"
			}

			output += anahtar

		}
	}
	fmt.Printf("output: %v\n", output)
	return primitive.Regex{Pattern: strings.Replace(output, " ", " ?", -1), Options: "i"}
}

func (l *LibSohal) GetBooksByTitleREGEX(ctx context.Context, page int, title string) ([]template.Book, error) {
	return l.GetBooks(ctx, page, bson.M{
		//"title": bson.D{{"$regex", primitive.Regex{Pattern: title, Options: "i"}}},
		"baslik": ConvertMongoRegex(title),
	})
}

func (l *LibSohal) GetBooksTop(ctx context.Context, page int) ([]template.Book, error) {
	return l.GetBooks(ctx, page, bson.M{
		"tag": "top",
	}, GetBooksConfig{SortByNewest: true})
}

func (l *LibSohal) SetBook(ctx context.Context, book template.Book) error {
	_, err := l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).InsertOne(ctx, book)
	return err
}

func (l *LibSohal) UpdateBook(ctx context.Context, book template.Book) error {
	fmt.Printf("book.ID: %v\n", book.ID)
	return l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).FindOneAndReplace(ctx, template.ShortCut{"id": book.ID}, book).Err()
}
