package libsohal

import (
	"backend/libsohal/template"
	"context"
	"fmt"
	"io"
	"os"
	"path"
	"time"

	"github.com/gofiber/fiber/v2"
)

const studentPhotoDir = "student_photos"

func init() {
	os.Mkdir(studentPhotoDir, os.ModePerm)
}

func (l *LibSohal) GetBorrowBooksByID(ctx context.Context, bookid string, notrec ...bool) (bt []template.BorrowedBook, err error) {

	s := template.ShortCut{
		"bookid": bookid,
	}

	if len(notrec) != 0 && notrec[0] {
		s["isrecieved"] = false
	}
	return l.GetBorrowBooks(ctx, s)
}
func (l *LibSohal) GetBorrowBooksCountByID(ctx context.Context, bookid string, notrec ...bool) (int64, error) {
	s := template.ShortCut{
		"bookid": bookid,
	}

	if len(notrec) != 0 && notrec[0] {
		s["isrecieved"] = false
	}

	return l.GetBorrowBooksCount(ctx, s)
}

func (l *LibSohal) GetBorrowBooks(ctx context.Context, filter any) (bt []template.BorrowedBook, err error) {
	response, err := l.Mongo.Database(template.BorrowDatabase).Collection(template.BorrowCollection).Find(ctx, filter)
	if err != nil {
		return bt, err

	}

	for response.Next(ctx) {
		var t template.BorrowedBook
		if err := response.Decode(&t); err != nil {
			return bt, err
		}
		bt = append(bt, t)
	}

	return bt, nil
}

func (l *LibSohal) UpdateBorrowBookRaw(ctx context.Context, filter any, book template.BorrowedBook) error {
	return l.Mongo.Database(template.BorrowDatabase).Collection(template.BorrowCollection).FindOneAndReplace(ctx, filter, book).Err()
}

func (l *LibSohal) SetBorrowBook(ctx context.Context, book template.BorrowedBook) error {
	_, err := l.Mongo.Database(template.BorrowDatabase).Collection(template.BorrowCollection).InsertOne(ctx, book)
	return err
}

func (l *LibSohal) UpdateBorrowBook(ctx context.Context, book template.BorrowedBook) error {
	return l.Mongo.Database(template.BorrowDatabase).Collection(template.BorrowCollection).FindOneAndReplace(ctx, map[string]string{
		"borrowid": book.BorrowID,
	}, book).Err()
}

func (l *LibSohal) GetBorrowBooksCount(ctx context.Context, filter any) (int64, error) {
	return l.Mongo.Database(template.BorrowDatabase).Collection(template.BorrowCollection).CountDocuments(ctx, filter)

}

func (l *LibSohal) IsBorrowable(ctx context.Context, bookid string) (bool, error) {
	book, err := l.GetBookById(ctx, bookid)
	if err != nil {
		return false, err
	}

	count, err := l.GetBorrowBooksCountByID(ctx, bookid, true)
	if err != nil {
		return false, err
	}
	fmt.Printf("book.Adet: %v\n", book.Adet)
	fmt.Printf("count: %v\n", count)

	return int64(book.Adet) > count, nil
}

func (l *LibSohal) BorrowBook(ctx context.Context, bbook template.BorrowedBook) error {
	book, err := l.GetBookById(ctx, bbook.BookID)
	if err != nil {
		return err
	}

	// if l.c.BorrowAttention == template.Solid {
	// 	count, err := l.GetBorrowBooksCountByID(ctx, bookid, true)
	// 	if err != nil {
	// 		return err
	// 	}

	// 	if book.Adet <= int(count) {
	// 		return fmt.Errorf("Ödünç almak için yeterli kitap yok::BorrowableAttention is solid and book.Adet smaller than 'BorrowableBookCount'")
	// 	}
	// }

	books, err := l.GetBorrowBooksByID(ctx, bbook.BookID, true)
	if err != nil {
		return err
	}
	if l.c.BorrowAttention == template.Solid && len(books) <= book.Adet {
		return fmt.Errorf("Ödünç almak için yeterli kitap yok::BorrowableAttention is solid and book.Adet smaller than 'BorrowableBookCount'")
	}

	for _, a := range books {
		if a.StudentNo == bbook.StudentNo {
			return fmt.Errorf("Kitap zaten bu kullanıcı tarafından ödünç alınmış")
		}
	}

	return l.SetBorrowBook(ctx, bbook)

}

func (l *LibSohal) RecieveBorrowedBook(ctx context.Context, studentNo, bookid string) error {
	books, err := l.GetBorrowBooks(ctx, map[string]string{
		"bookid": bookid, "studentno": studentNo,
	})

	if err != nil {
		return err
	}

	if len(books) == 0 {
		return fmt.Errorf("Kullanıcı kitabı ödünç almamış")
	}
	books[0].IsRecieved = true
	books[0].WhenRecieved = time.Now()
	return l.UpdateBorrowBook(ctx, books[0])

}

func (l *LibSohal) BorrowBookRouter(c *fiber.Ctx) error {
	tip := c.FormValue("type")
	bookid := c.FormValue("bookid")
	studentno := c.FormValue("studentno")

	if (tip != "borrow" && tip != "return") || bookid == "" || studentno == "" {
		return fiber.NewError(500, "unsupported what option", tip, bookid, studentno)
	}

	switch tip {
	case "borrow":
		{

			var book = template.BorrowedBook{
				BorrowID:  RandStringRunes(30),
				BookID:    bookid,
				StudentNo: studentno,
				When:      time.Now(),
			}

			if f, err := c.FormFile("photo"); err == nil {

				if fi, err := f.Open(); err == nil {
					defer fi.Close()

					//_p := path.Join(studentPhotoDir, fmt.Sprintf("%s_%s_%s", studentno, bookid, time.Now().Format(time.RFC3339Nano)))

					_p := path.Join(studentPhotoDir, fmt.Sprintf("%s_%s", book.BorrowID, book.When.Format(time.RFC3339Nano)))
					fmt.Printf("_p: %v\n", _p)

					if wr, err := os.Create(_p); err == nil {
						io.Copy(wr, fi)
						wr.Close()
						book.PhotoPath = _p
					} else {
						fmt.Printf("err: %v\n", err)
					}
				}
			}

			if err := l.BorrowBook(c.Context(), book); err != nil {
				if book.PhotoPath != "" {
					os.Remove(book.PhotoPath)
				}
				return err
			}

		}
	case "return":
		{
			if err := l.RecieveBorrowedBook(c.Context(), studentno, bookid); err != nil {
				return err
			}
		}

	}
	c.Set("Content-Type", "application/json")

	return c.Send(template.ShortCut{
		"status": "ok",
	}.ToJson())
}
