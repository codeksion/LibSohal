package bookfinder

func (b *BookFinder) SearchFromISBN(isbn string) (string, error) {
	rr, err := b.RequestAndConvertUTF8("/search/?isbn=" + isbn + "&mode=isbn&st=sr&ac=qr")
	if err != nil {
		return "", err
	}
	return b.Parser(rr)
}
