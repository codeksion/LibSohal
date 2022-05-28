package imageproxy

// Can be usable like normal proxy; not special for image
import (
	"fmt"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/patrickmn/go-cache"
)

type Config struct {
	Duration time.Duration
}

type ImageProxy struct {
	mem *cache.Cache
}

func (i *ImageProxy) Put(image string) {
	i.mem.Add(image, true, 0)
}

func (i *ImageProxy) Get(image string) bool {
	_, ok := i.mem.Get(image)
	return ok
}

func (i *ImageProxy) FiberHandler(c *fiber.Ctx) error {
	url := c.Query("url")
	if url == "" || !i.Get(url) {
		return fmt.Errorf("ImageProxy %s not exists or expired", url)
	}

	resp, err := http.Get(url)
	if err != nil {
		return err
	}

	go func() {
		if dc := c.Context().Done(); dc != nil {
			<-dc
		}
		resp.Body.Close()
	}()

	c.Set("Content-Type", resp.Header.Get("Content-Type"))
	return c.Status(resp.StatusCode).SendStream(resp.Body)

}

func NewImageProxy(c Config) *ImageProxy {
	return &ImageProxy{
		mem: cache.New(c.Duration, c.Duration),
	}
}
