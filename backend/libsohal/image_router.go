package libsohal

import (
	"crypto/tls"
	"encoding/base64"
	"io"
	"net/http"
	"os"
	"path"
	"runtime"
)

type ImageRouter struct {
	StaticDirPath string
	GetFullPath   func(string) string
	Client        *http.Client
}

func NewImageRouter(dirpath string) (imager *ImageRouter, err error) {
	if _, err := os.Stat(dirpath); err != nil {
		if !os.IsNotExist(err) {
			return nil, err
		}

		if err := os.MkdirAll(dirpath, os.ModePerm); err != nil {
			return nil, err
		}
	}

	imager = &ImageRouter{
		Client: &http.Client{
			Transport: &http.Transport{
				TLSClientConfig: &tls.Config{
					InsecureSkipVerify: true,
				},
			},
		},
		StaticDirPath: dirpath,
		GetFullPath: func(s string) string {
			if s[0] == '/' {
				s = s[1:]
			}
			return path.Join(imager.StaticDirPath, s)
		},
	}
	return
}

func (i *ImageRouter) WriteImage(filename string, body []byte) error {
	file, err := i.Writer(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	file.Write(body)
	return nil
}

func (i *ImageRouter) Writer(filename string) (io.WriteCloser, error) {
	file, err := os.Create(i.GetFullPath(filename))
	return file, err

}

func (i *ImageRouter) WriteBASE64Image(filename string, base64body string) error {
	b, err := base64.StdEncoding.DecodeString(base64body)
	if err != nil {
		return err
	}
	defer runtime.GC() //!! UNSTABLE

	return i.WriteImage(filename, b)
}

func (i *ImageRouter) Exists(filename string) bool {
	_, err := os.Stat(i.GetFullPath(filename))
	return err == nil
}
