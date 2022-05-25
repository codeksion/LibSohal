class Monitor {
  ApiUsage? apiUsage;
  String? compiler;
  int? numGoroutine;
  int? cpuCore;
  BuildInfo? buildInfo;
  Memory? swapMemory;
  Memory? memory;
  int? totalBook;
  List<CpuStats>? cpuStats;
  List<double>? cpuPercents;

  Monitor(
      {this.apiUsage,
      this.compiler,
      this.numGoroutine,
      this.cpuCore,
      this.buildInfo,
      this.swapMemory,
      this.memory,
      this.totalBook,
      this.cpuStats,
      this.cpuPercents});

  Monitor.fromJson(Map<String, dynamic> json) {
    apiUsage =
        json['api_usage'] != null ? ApiUsage.fromJson(json['api_usage']) : null;
    compiler = json['compiler'];
    numGoroutine = json['num_goroutine'];
    cpuCore = json['cpu_core'];
    buildInfo = json['build_info'] != null
        ? BuildInfo.fromJson(json['build_info'])
        : null;
    swapMemory = json['swap_memory'] != null
        ? Memory.fromJson(json['swap_memory'])
        : null;
    memory = json['memory'] != null ? Memory.fromJson(json['memory']) : null;
    totalBook = json['total_book'];
    if (json['cpu_stats'] != null) {
      cpuStats = <CpuStats>[];
      json['cpu_stats'].forEach((v) {
        cpuStats!.add(CpuStats.fromJson(v));
      });
    }

    cpuPercents ??= <double>[];

    for (var percent in json["cpu_percents"]) {
      cpuPercents!.add((percent is double)
          ? percent
          : (percent is int)
              ? percent.toDouble()
              : 0);
    }
    //cpuPercents = json['cpu_percents'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (apiUsage != null) {
      data['api_usage'] = apiUsage!.toJson();
    }
    data['compiler'] = compiler;
    data['num_goroutine'] = numGoroutine;
    data['cpu_core'] = cpuCore;
    if (buildInfo != null) {
      data['build_info'] = buildInfo!.toJson();
    }
    if (swapMemory != null) {
      data['swap_memory'] = swapMemory!.toJson();
    }
    if (memory != null) {
      data['memory'] = memory!.toJson();
    }
    data['total_book'] = totalBook;
    if (cpuStats != null) {
      data['cpu_stats'] = cpuStats!.map((v) => v.toJson()).toList();
    }
    data['cpu_percents'] = cpuPercents;
    return data;
  }
}

class ApiUsage {
  int? alloc;
  int? totalAlloc;
  int? numGc;

  ApiUsage({this.alloc, this.totalAlloc});

  ApiUsage.fromJson(Map<String, dynamic> json) {
    alloc = json['alloc'];
    totalAlloc = json['total_alloc'];
    numGc = json["num_gc"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['alloc'] = alloc;
    data['total_alloc'] = totalAlloc;
    data["num_gc"] = numGc;
    return data;
  }
}

class BuildInfo {
  String? goVersion;
  String? path;

  List<Settings>? settings;

  BuildInfo({this.goVersion, this.path, this.settings});

  BuildInfo.fromJson(Map<String, dynamic> json) {
    goVersion = json['GoVersion'];
    path = json['Path'];

    if (json['Settings'] != null) {
      settings = <Settings>[];
      json['Settings'].forEach((v) {
        settings!.add(Settings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['GoVersion'] = goVersion;
    data['Path'] = path;

    if (settings != null) {
      data['Settings'] = settings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Settings {
  String? key;
  String? value;

  Settings({this.key, this.value});

  Settings.fromJson(Map<String, dynamic> json) {
    key = json['Key'];
    value = json['Value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Key'] = key;
    data['Value'] = value;
    return data;
  }
}

// class SwapMemory {
//   int? total;
//   int? used;
//   int? free;
//   int? usedPercent;

//   SwapMemory({this.total, this.used, this.free, this.usedPercent});

//   SwapMemory.fromJson(Map<String, dynamic> json) {
//     total = json['Total'];
//     used = json['Used'];
//     free = json['Free'];
//     usedPercent = json['UsedPercent'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['Total'] = total;
//     data['Used'] = used;
//     data['Free'] = free;
//     data['UsedPercent'] = usedPercent;
//     return data;
//   }
// }

class Memory {
  int? total;
  int? used;
  int? free;
  double? usedPercent;

  Memory({this.total, this.used, this.free, this.usedPercent});

  Memory.fromJson(Map<String, dynamic> json) {
    total = json['Total'];
    used = json['Used'];
    free = json['Free'];
    usedPercent = (json['UsedPercent'] is double)
        ? json['UsedPercent']
        : json['UsedPercent'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Total'] = total;
    data['Used'] = used;
    data['Free'] = free;
    data['UsedPercent'] = usedPercent ?? 0;
    return data;
  }
}

class CpuStats {
  int? cpu;
  String? vendorId;
  String? family;
  String? model;
  int? stepping;
  String? physicalId;
  String? coreId;
  int? cores;
  String? modelName;
  double? mhz;
  int? cacheSize;
  List<String>? flags;
  String? microcode;

  CpuStats(
      {this.cpu,
      this.vendorId,
      this.family,
      this.model,
      this.stepping,
      this.physicalId,
      this.coreId,
      this.cores,
      this.modelName,
      this.mhz,
      this.cacheSize,
      this.flags,
      this.microcode});

  CpuStats.fromJson(Map<String, dynamic> json) {
    cpu = json['cpu'];
    vendorId = json['vendorId'];
    family = json['family'];
    model = json['model'];
    stepping = json['stepping'];
    physicalId = json['physicalId'];
    coreId = json['coreId'];
    cores = json['cores'];
    modelName = json['modelName'];

    mhz = (json["mhz"] is double)
        ? json["mhz"]
        : (json["mhz"] is int ? json["mhz"].toDouble() : 0);
    cacheSize = json['cacheSize'];
    flags = json['flags'].cast<String>();
    microcode = json['microcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['cpu'] = cpu;
    data['vendorId'] = vendorId;
    data['family'] = family;
    data['model'] = model;
    data['stepping'] = stepping;
    data['physicalId'] = physicalId;
    data['coreId'] = coreId;
    data['cores'] = cores;
    data['modelName'] = modelName;
    data['mhz'] = mhz;
    data['cacheSize'] = cacheSize;
    data['flags'] = flags;
    data['microcode'] = microcode;
    return data;
  }
}
