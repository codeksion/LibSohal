package ip

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

func A() (as AIps, err error) {
	res, err := exec.Command("ip", "-j", "a").CombinedOutput()
	if err != nil {
		return as, fmt.Errorf("failed to call 'ip': %s:%v", string(res), err)
	}

	err = json.Unmarshal(res, &as)
	return
}
