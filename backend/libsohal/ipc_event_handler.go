package libsohal

import (
	"backend/libsohal/template"
	"context"
)

func (l *LibSohal) IpcEventMap() map[string]func(ctx context.Context) (any, error) { // Ne kadar sağlıklı?
	return map[string]func(ctx context.Context) (any, error){
		"nonreturnedbooks": func(ctx context.Context) (any, error) {
			return l.GetBorrowBooks(ctx, template.ShortCut{"isrecieved": false})
		},
	}
}

// func (l *LibSohal) IpcEventHandler(event string) []byte {
// 	var value any
// 	var err error

// 	ctx, cancel := context.WithTimeout(context.Background(), l.Ipc.Timeout)
// 	defer cancel()

// 	ms := l.IpcEventMap()

// 	switch event {
// 	case "help":
// 		{
// 			list := make([]string, len(ms))
// 			for key, _ := range ms {
// 				list = append(list, key)
// 			}

// 			value = list
// 		}

// 	default:
// 		if fn, ok := ms[event]; ok {
// 			value, err = fn(ctx)
// 		} else {
// 			err = fmt.Errorf("not impelemented: %s", event)
// 		}

// 	}

// 	if err != nil {
// 		log.Printf("IPC event error: %+v\n", err)
// 		return template.ShortCut{"error": err.Error()}.ToJson()
// 	}

// 	jv, err := json.Marshal(value)
// 	if err != nil {
// 		log.Printf("IPC event-json-pack error: %+v\n", err)
// 		return template.ShortCut{"error": err.Error()}.ToJson()
// 	}
// 	return jv

// }
