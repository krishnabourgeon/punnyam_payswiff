class BillListResponseModel {
  bool? status;
  List<Bills>? list;
  var grossTotal;
  Meta? meta;
  Links? links;
  BillListResponseModel(
      {this.status, this.list, this.grossTotal, this.meta, this.links});
  BillListResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['list'] != null) {
      list = <Bills>[];
      json['list'].forEach((v) {
        list!.add(Bills.fromJson(v));
      });
    }
    grossTotal = json['gross_total'];
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['gross_total'] = grossTotal;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (links != null) {
      data['links'] = links!.toJson();
    }
    return data;
  }
}

class Bills {
  int? billId;
  String? billDate;
  String? counter;
  String? devotee;
  String? paymentMode;
  String? total;
  Bills(
      {this.billId,
      this.billDate,
      this.counter,
      this.devotee,
      this.paymentMode,
      this.total});
  Bills.fromJson(Map<String, dynamic> json) {
    billId = json['bill_id'];
    billDate = json['bill_date'];
    counter = json['counter'];
    devotee = json['devotee'];
    paymentMode = json['payment_mode'];
    total = json['total'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bill_id'] = billId;
    data['bill_date'] = billDate;
    data['counter'] = counter;
    data['devotee'] = devotee;
    data['payment_mode'] = paymentMode;
    data['total'] = total;
    return data;
  }
}

class Meta {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  String? nextPageUrl;
  String? prevPageUrl;
  int? from;
  int? to;
  Meta(
      {this.total,
      this.perPage,
      this.currentPage,
      this.lastPage,
      this.nextPageUrl,
      this.prevPageUrl,
      this.from,
      this.to});
  Meta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    nextPageUrl = json['next_page_url'];
    prevPageUrl = json['prev_page_url'];
    from = json['from'];
    to = json['to'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['per_page'] = perPage;
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;
    data['next_page_url'] = nextPageUrl;
    data['prev_page_url'] = prevPageUrl;
    data['from'] = from;
    data['to'] = to;
    return data;
  }
}

class Links {
  String? self;
  String? first;
  String? last;
  String? prev;
  String? next;
  Links({this.self, this.first, this.last, this.prev, this.next});
  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'];
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['self'] = self;
    data['first'] = first;
    data['last'] = last;
    data['prev'] = prev;
    data['next'] = next;
    return data;
  }
}
