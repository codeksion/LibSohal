package template

import "encoding/json"

type ShortCut map[string]interface{}

func (c ShortCut) ToJson() []byte {
	a, _ := json.Marshal(c)
	return a
}
