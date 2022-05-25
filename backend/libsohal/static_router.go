package libsohal

import (
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
)

func (l *LibSohal) StaticRouter(c *fiber.Ctx) error {
	//!! Local File Inclusions

	// fmt.Printf("c.Path(): %v\n", c.Path())

	// return c.SendString("ok")

	// filename := c.Query("filename")
	// if filename == "" /* || filename == "." || strings.HasPrefix(filename, ".") */ {
	// 	return fiber.NewError(500, "filename cannot be empty")
	// }
	filename := c.Params("*")
	if filename == "" {
		return fiber.NewError(403, "access denied")
	}

	/*if strings.Contains(filename, "/") {
		return fiber.NewError(403, "LFI")
	}*/
	//!! Local File Inclusions

	path := l.ImageRouter.GetFullPath(filename)

	if s, err := os.Stat(path); err == nil {
		if s.IsDir() {
			return fiber.NewError(403, "access denied")
		}
	}

	return c.SendFile(path)

}

func (l *LibSohal) StaticRouterORIGIN(c *fiber.Ctx) error {
	//!! Local File Inclusions

	filename := c.Query("filename")
	if filename == "" /* || filename == "." || strings.HasPrefix(filename, ".") */ {
		return fiber.NewError(500, "filename cannot be empty")
	}
	if strings.Contains(filename, "/") {
		return fiber.NewError(403, "LFI")
	}
	//!! Local File Inclusions

	path := l.ImageRouter.GetFullPath(filename)

	if s, err := os.Stat(path); err == nil {
		if s.IsDir() {
			return fiber.NewError(403, "filename cannot be dot")
		}
	}

	return c.SendFile(path)

}
