package main

import (
	"backend/cmd/utils/ip"
	"errors"
	"fmt"
	"os"

	json "github.com/nwidger/jsoncolor"

	"github.com/mkideal/cli"
)

type argvs struct {
	cli.Helper
	Ip      bool `cli:"ip" usage:"Sunucu ip adresini/lerini döndürür"`
	Systemd bool `cli:"systemd" usage:"Örnek systemd servis dosyası oluşturur"`
	//ListNonreturnedBooks bool `cli:"list-nonreturned-books" usage:"İade edilmeyen kitapları/ödünç alan kişileri gösterir"`
}

type sockeT struct {
	cli.Helper
	Path  string `cli:"path" usage:"socket path" dft:"libsohal"`
	Event string `cli:"event" usage:"libsohal'e komut gönder, yanıtı bekle"`
}

func main() {

	if err := cli.Root(&cli.Command{
		Desc:   "Libsohal utils",
		Global: false,
		Argv:   func() interface{} { return &argvs{} },
		Fn: func(ctx *cli.Context) error {
			return parseRoot((ctx.Argv().(*argvs)))
		},
	}, cli.Tree(&cli.Command{
		Name: "socket",
		Desc: "Libsohal socket'e bağlanarak komut gönder/teslim al.",

		Argv:    func() interface{} { return &sockeT{} },
		Aliases: []string{"conn", "dial"},
		//UsageFn: func() string { return "--event help" },
		Fn: func(ctx *cli.Context) error {
			//return parseSocket(ctx.Argv().(*sockeT))
			return errors.New("not implemented yet")
		},
	})).Run(os.Args[1:]); err != nil {
		fmt.Printf("Hata: \033[31m%+v\033[0m\n", err)
	}

}

func parseRoot(a *argvs) error {

	var yanit = map[string]interface{}{}

	switch {
	case a.Ip:
		{
			s, err := ip.A()
			if err != nil {
				yanit["ip"] = err
			}
			yanit["ip"] = s.Humanize()
		}
	case a.Systemd:
		{
			yanit["systemd"] = "sample.systemd.service"
			if err := os.WriteFile(yanit["systemd"].(string), []byte("[Unit]\nDescription=LibSohal Backend software\nAfter=docker.target\nStartLimitIntervalSec=10\n\n[Service]\nType=simple\nRestart=always\nRestartSec=5\nExecDir=/root/libsohal/\nExecStart=/bin/bash /root/libsohal/backend\n\n[Install]\nWantedBy=multi-user.target"), 777); err != nil {
				yanit["systemd"] = err
			} else {
				yanit["systemd-command"] = "sudo cp " + yanit["systemd"].(string) + " /etc/systemd/system/ ; sudo systemctl enable --now " + yanit["systemd"].(string)
			}
		}

	}

	v, err := json.MarshalIndent(yanit, "", " ")
	if err != nil {
		return err
	}
	fmt.Println(string(v))

	return nil

}
