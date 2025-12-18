class HyprctlMonitor {
  int? id;
  String? name;
  String? description;
  String? make;
  String? model;
  String? serial;
  int? width;
  int? height;
  int? physicalWidth;
  int? physicalHeight;
  double? refreshRate;
  int? x;
  int? y;
  ActiveWorkspace? activeWorkspace;
  ActiveWorkspace? specialWorkspace;
  List<int>? reserved;
  double? scale;
  int? transform;
  bool? focused;
  bool? dpmsStatus;
  bool? vrr;
  String? solitary;
  List<String>? solitaryBlockedBy;
  bool? activelyTearing;
  List<String>? tearingBlockedBy;
  String? directScanoutTo;
  List<String>? directScanoutBlockedBy;
  bool? disabled;
  String? currentFormat;
  String? mirrorOf;
  List<String>? availableModes;
  String? colorManagementPreset;
  int? sdrBrightness;
  int? sdrSaturation;
  double? sdrMinLuminance;
  int? sdrMaxLuminance;

  HyprctlMonitor({
    this.id,
    this.name,
    this.description,
    this.make,
    this.model,
    this.serial,
    this.width,
    this.height,
    this.physicalWidth,
    this.physicalHeight,
    this.refreshRate,
    this.x,
    this.y,
    this.activeWorkspace,
    this.specialWorkspace,
    this.reserved,
    this.scale,
    this.transform,
    this.focused,
    this.dpmsStatus,
    this.vrr,
    this.solitary,
    this.solitaryBlockedBy,
    this.activelyTearing,
    this.tearingBlockedBy,
    this.directScanoutTo,
    this.directScanoutBlockedBy,
    this.disabled,
    this.currentFormat,
    this.mirrorOf,
    this.availableModes,
    this.colorManagementPreset,
    this.sdrBrightness,
    this.sdrSaturation,
    this.sdrMinLuminance,
    this.sdrMaxLuminance,
  });

  HyprctlMonitor.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    name = json['name'];
    description = json['description'];
    make = json['make'];
    model = json['model'];
    serial = json['serial'];
    width = (json['width'] as num?)?.toInt();
    height = (json['height'] as num?)?.toInt();
    physicalWidth = (json['physicalWidth'] as num?)?.toInt();
    physicalHeight = (json['physicalHeight'] as num?)?.toInt();
    refreshRate = (json['refreshRate'] as num?)?.toDouble();
    x = (json['x'] as num?)?.toInt();
    y = (json['y'] as num?)?.toInt();
    activeWorkspace = json['activeWorkspace'] != null
        ? ActiveWorkspace.fromJson(json['activeWorkspace'])
        : null;
    specialWorkspace = json['specialWorkspace'] != null
        ? ActiveWorkspace.fromJson(json['specialWorkspace'])
        : null;
    reserved = json['reserved']?.cast<int>();
    scale = (json['scale'] as num?)?.toDouble();
    transform = (json['transform'] as num?)?.toInt();
    focused = json['focused'];
    dpmsStatus = json['dpmsStatus'];
    vrr = json['vrr'];
    solitary = json['solitary'];
    solitaryBlockedBy = json['solitaryBlockedBy']?.cast<String>();
    activelyTearing = json['activelyTearing'];
    tearingBlockedBy = json['tearingBlockedBy']?.cast<String>();
    directScanoutTo = json['directScanoutTo'];
    directScanoutBlockedBy = json['directScanoutBlockedBy']?.cast<String>();
    disabled = json['disabled'];
    currentFormat = json['currentFormat'];
    mirrorOf = json['mirrorOf'];
    availableModes = json['availableModes']?.cast<String>();
    colorManagementPreset = json['colorManagementPreset'];
    sdrBrightness = (json['sdrBrightness'] as num?)?.toInt();
    sdrSaturation = (json['sdrSaturation'] as num?)?.toInt();
    sdrMinLuminance = (json['sdrMinLuminance'] as num?)?.toDouble();
    sdrMaxLuminance = (json['sdrMaxLuminance'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['make'] = make;
    data['model'] = model;
    data['serial'] = serial;
    data['width'] = width;
    data['height'] = height;
    data['physicalWidth'] = physicalWidth;
    data['physicalHeight'] = physicalHeight;
    data['refreshRate'] = refreshRate;
    data['x'] = x;
    data['y'] = y;
    if (activeWorkspace != null) {
      data['activeWorkspace'] = activeWorkspace!.toJson();
    }
    if (specialWorkspace != null) {
      data['specialWorkspace'] = specialWorkspace!.toJson();
    }
    data['reserved'] = reserved;
    data['scale'] = scale;
    data['transform'] = transform;
    data['focused'] = focused;
    data['dpmsStatus'] = dpmsStatus;
    data['vrr'] = vrr;
    data['solitary'] = solitary;
    data['solitaryBlockedBy'] = solitaryBlockedBy;
    data['activelyTearing'] = activelyTearing;
    data['tearingBlockedBy'] = tearingBlockedBy;
    data['directScanoutTo'] = directScanoutTo;
    data['directScanoutBlockedBy'] = directScanoutBlockedBy;
    data['disabled'] = disabled;
    data['currentFormat'] = currentFormat;
    data['mirrorOf'] = mirrorOf;
    data['availableModes'] = availableModes;
    data['colorManagementPreset'] = colorManagementPreset;
    data['sdrBrightness'] = sdrBrightness;
    data['sdrSaturation'] = sdrSaturation;
    data['sdrMinLuminance'] = sdrMinLuminance;
    data['sdrMaxLuminance'] = sdrMaxLuminance;
    return data;
  }
}

class ActiveWorkspace {
  int? id;
  String? name;

  ActiveWorkspace({this.id, this.name});

  ActiveWorkspace.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
