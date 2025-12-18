class WorkshopMetadata {
  String? contentrating;
  String? description;
  String? file;
  General? general;
  String? preview;
  List<String>? tags;
  String? title;
  String? type;
  String? visibility;
  String? workshopid;

  WorkshopMetadata({
    this.contentrating,
    this.description,
    this.file,
    this.general,
    this.preview,
    this.tags,
    this.title,
    this.type,
    this.visibility,
    this.workshopid,
  });

  WorkshopMetadata.fromJson(Map<String, dynamic> json) {
    contentrating = json['contentrating'];
    description = json['description'];
    file = json['file'];
    general = json['general'] != null
        ? new General.fromJson(json['general'])
        : null;
    preview = json['preview'];
    tags = json['tags'].cast<String>();
    title = json['title'];
    type = json['type'];
    visibility = json['visibility'];
    workshopid = json['workshopid']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contentrating'] = this.contentrating;
    data['description'] = this.description;
    data['file'] = this.file;
    if (this.general != null) {
      data['general'] = this.general!.toJson();
    }
    data['preview'] = this.preview;
    data['tags'] = this.tags;
    data['title'] = this.title;
    data['type'] = this.type;
    data['visibility'] = this.visibility;
    data['workshopid'] = this.workshopid;
    return data;
  }
}

class General {
  Properties? properties;

  General({this.properties});

  General.fromJson(Map<String, dynamic> json) {
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.properties != null) {
      data['properties'] = this.properties!.toJson();
    }
    return data;
  }
}

class Properties {
  Schemecolor? schemecolor;

  Properties({this.schemecolor});

  Properties.fromJson(Map<String, dynamic> json) {
    schemecolor = json['schemecolor'] != null
        ? new Schemecolor.fromJson(json['schemecolor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.schemecolor != null) {
      data['schemecolor'] = this.schemecolor!.toJson();
    }
    return data;
  }
}

class Schemecolor {
  int? order;
  String? text;
  String? type;
  String? value;

  Schemecolor({this.order, this.text, this.type, this.value});

  Schemecolor.fromJson(Map<String, dynamic> json) {
    order = json['order'];
    text = json['text'];
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order'] = this.order;
    data['text'] = this.text;
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}
