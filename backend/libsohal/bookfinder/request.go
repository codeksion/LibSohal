package bookfinder

import (
	"io"
	"strings"
)

func toUtf8(iso8859_1_buf []byte) string {

	buf := make([]rune, len(iso8859_1_buf))
	for i, b := range iso8859_1_buf {
		buf[i] = rune(b)
	}

	return string(buf)
}

func (b *BookFinder) RequestAndConvertUTF8(path string) (io.Reader, error) {
	response, err := b.Client.Get(b.URL + path)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	reader, err := io.ReadAll(response.Body)
	if err != nil {
		return nil, err
	}
	return strings.NewReader(toUtf8(reader)), nil
}
