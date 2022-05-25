package libsohal

import (
	"encoding/json"
	"runtime"
	"runtime/debug"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/shirou/gopsutil/v3/cpu"
	"github.com/shirou/gopsutil/v3/mem"
)

type DetailedMemoryUsage struct {
	Alloc      uint64 `json:"alloc"`
	TotalAlloc uint64 `json:"total_alloc"`
	NumGc      int    `json:"num_gc"`
}

type Memoryusage struct {
	Total       uint64
	Used        uint64
	Free        uint64
	UsedPercent float64
}

type monitorstruct struct {
	DetailedMemoryUsage DetailedMemoryUsage `json:"api_usage"`
	Compiler            string              `json:"compiler"`
	NumGoroutine        int                 `json:"num_goroutine"`
	ServerCore          int                 `json:"cpu_core"`
	BuildInfo           debug.BuildInfo     `json:"build_info"`
	SwapMemory          Memoryusage         `json:"swap_memory"`
	Memory              Memoryusage         `json:"memory"`
	//TotalBook           int64               `json:"total_book"`
	CpuStats    []cpu.InfoStat `json:"cpu_stats"`
	CpuPercents []float64      `json:"cpu_percents"`
}

func (m monitorstruct) ToJson() []byte {
	j, _ := json.Marshal(m)
	return j
}

func (l *LibSohal) MonitorRouter(c *fiber.Ctx) error {
	var most monitorstruct = monitorstruct{
		Compiler:     runtime.Compiler,
		ServerCore:   runtime.NumCPU(),
		NumGoroutine: runtime.NumGoroutine(),
	}
	var _apimem runtime.MemStats
	runtime.ReadMemStats(&_apimem)

	most.DetailedMemoryUsage = DetailedMemoryUsage{
		Alloc:      _apimem.Alloc,
		TotalAlloc: _apimem.TotalAlloc,
		NumGc:      int(_apimem.NumGC),

		//Heap: _apimem,
	}

	//fmt.Printf("(_apimem.Alloc / 1024 / 1024): %v\n", (_apimem.Alloc / 1024 / 1024))
	// var rmem syscall.Rusage
	// if err := syscall.Getrusage(syscall.RUSAGE_SELF, &rmem); err != nil {
	// 	log.Fatalln(err)
	// }

	// fmt.Printf("(rmem.Maxrss / 1024 / 1024): %v\n", (rmem.Maxrss / 1024 / 1024))

	// if err := syscall.Getrusage(syscall.RUSAGE_CHILDREN, &rmem); err != nil {
	// 	log.Fatalln(err)
	// }

	// fmt.Printf("child (rmem.Maxrss / 1024 / 1024): %v\n", (rmem.Maxrss / 1024 / 1024))

	// if err := syscall.Getrusage(syscall.RUSAGE_THREAD, &rmem); err != nil {
	// 	log.Fatalln(err)
	// }

	// fmt.Printf("thread (rmem.Maxrss / 1024 / 1024): %v\n", (rmem.Maxrss / 1024 / 1024))

	buildinfo, ok := debug.ReadBuildInfo()
	if !ok {
		return fiber.NewError(500, "Cloudn't read GoBuildInfo")
	}
	most.BuildInfo = *buildinfo

	swapmem, err := mem.SwapMemoryWithContext(c.Context())
	if err != nil {
		return fiber.NewError(500, err.Error())
	}
	most.SwapMemory = Memoryusage{
		Total:       swapmem.Total,
		Used:        swapmem.Used,
		Free:        swapmem.Total - swapmem.Used,
		UsedPercent: swapmem.UsedPercent,
	}

	mem, err := mem.VirtualMemoryWithContext(c.Context())
	if err != nil {
		return fiber.NewError(500, err.Error())
	}

	most.Memory = Memoryusage{
		Total:       mem.Total,
		Used:        mem.Used,
		Free:        mem.Total - mem.Used,
		UsedPercent: mem.UsedPercent,
	}

	stats, err := cpu.InfoWithContext(c.Context())
	if err != nil {
		return fiber.NewError(500, err.Error())
	}
	most.CpuStats = stats

	percents, err := cpu.PercentWithContext(c.Context(), time.Second, true)
	if err != nil {
		return fiber.NewError(500, err.Error())
	}
	most.CpuPercents = percents

	// counter, err := l.Mongo.Database(template.MongoBookDatabase).Collection(template.MongoBookCollection).CountDocuments(c.Context(), map[any]any{})
	// if err != nil {
	// 	return fiber.NewError(500, err.Error())
	// }
	// most.TotalBook = counter

	return c.Send(most.ToJson())

}
