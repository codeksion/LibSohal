package libsohal

import (
	"backend/libsohal/template"
	"context"
	"log"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type Yetkili struct {
	Isim string `json:"isim"` // Ali Mehmet Mehmetoğlu, Mehmet Ali Alioğlu
	Rol  string `json:"rol"`  // öğretmen, geliştirici, nöbetçi
	Pw   int    `json:"pw"`   // int <numeric-keyboard>
}

func (y Yetkili) ToHiddenJSON() []byte {
	return template.ShortCut{
		"isim": y.Isim, "rol": y.Rol,
	}.ToJson()
}

func (l *LibSohal) GetYetkiliByPW(context context.Context, pw int) (y Yetkili, err error) {
	res := l.Mongo.Database(template.MongoYetkiliDatabase).Collection(template.MongoYetkiliCollection).FindOne(context, template.ShortCut{
		"pw": pw,
	})
	err = res.Decode(&y)
	return
}

func (l *LibSohal) SetYetkili(context context.Context, y Yetkili) error {
	_, err := l.Mongo.Database(template.MongoYetkiliDatabase).Collection(template.MongoYetkiliCollection).InsertOne(context, y)
	return err
}

func (l *LibSohal) YetkiliMiddleware() {
	yetkili := l.Fiber.Group("/yetkili", func(c *fiber.Ctx) error {

		pw, err := strconv.Atoi(c.Get("PW"))
		if err != nil || pw == 0 {
			return fiber.ErrUnauthorized
		}

		yetkili, err := l.GetYetkiliByPW(c.Context(), pw)
		if err != nil {
			log.Println(err)
			return fiber.ErrUnauthorized
		}
		c.Locals("yetkili", yetkili)
		return c.Next()
	})

	yetkili.Get("/getMe", func(c *fiber.Ctx) error {
		c.Set("Content-Type", "application/json")
		return c.Send(c.Locals("yetkili").(Yetkili).ToHiddenJSON())
	})

	yetkili.Post("/addBook", func(c *fiber.Ctx) error {
		return c.Next()
	}, l.AddBookHandler)

	yetkili.Get("/monitor", l.MonitorRouter) // monitor.New(monitor.Config{APIOnly: true})

}
