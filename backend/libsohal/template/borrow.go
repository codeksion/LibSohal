package template

import "time"

type BorrowableAttention string

const (
	DontCare BorrowableAttention = "dont_care"
	Solid    BorrowableAttention = "solid"
)

const (
	BorrowCollection = "borrow"
	BorrowDatabase   = "borrow"

	StudentCollection = "student"
	StudentDatabase   = "student"
)

type Student struct {
	Name          string         `json:"name"`
	No            int            `json:"no"`
	Class         map[int]string `json:"class"` // 2022:12-G
	BorrowedBooks []string       `json:"borrowed_books"`
}

type BorrowedBook struct {
	BorrowID     string    `json:"borrow_id"`
	BookID       string    `json:"book_id"`
	StudentNo    string    `json:"student_no"`
	When         time.Time `json:"when"`
	IsRecieved   bool      `json:"is_recieved"`
	WhenRecieved time.Time `json:"when_recieved"`
	// Photo        []byte    `json:"photo"` // Sağlıklı değil!
	PhotoPath string `json:"photo_path"`
}
