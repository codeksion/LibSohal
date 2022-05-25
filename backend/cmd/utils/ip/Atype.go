package ip

type AIp struct {
	Ifindex   int         `json:"ifindex"`
	Ifname    string      `json:"ifname"`
	Flags     []string    `json:"flags"`
	Mtu       int         `json:"mtu"`
	Qdisc     string      `json:"qdisc"`
	Operstate string      `json:"operstate"`
	Group     string      `json:"group"`
	Txqlen    int         `json:"txqlen"`
	LinkType  string      `json:"link_type"`
	Address   string      `json:"address"`
	Broadcast string      `json:"broadcast"`
	AddrInfo  []AAddrInfo `json:"addr_info"`
}

func (ap AIp) Humanize() (a AHumanize) {
	a.MacAddress = ap.Address
	a.InterfaceName = ap.Ifname
	for _, _a := range ap.AddrInfo {
		if _a.Local != "" {
			a.Addrs = append(a.Addrs, _a.Local)
		}
	}

	return

}

type AAddrInfo struct {
	Family            string `json:"family"`
	Local             string `json:"local"`
	Prefixlen         int    `json:"prefixlen"`
	Broadcast         string `json:"broadcast"`
	Scope             string `json:"scope"`
	Dynamic           bool   `json:"dynamic"`
	Noprefixroute     bool   `json:"noprefixroute"`
	Label             string `json:"label"`
	ValidLifeTime     int    `json:"valid_life_time"`
	PreferredLifeTime int    `json:"preferred_life_time"`
}

type AHumanize struct {
	InterfaceName string
	MacAddress    string
	Addrs         []string
}
type AsHumanize []AHumanize

type AIps []AIp

func (as AIps) Humanize() (a AsHumanize) {
	a = make([]AHumanize, len(as))
	for index, y := range as {
		a[index] = y.Humanize()
	}
	return
}
