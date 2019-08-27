import 'dart:convert' show json;

import 'package:flutter_wanandroid/utils/string_util.dart';

class ProjectTreeModel {
  int errorCode;
  String errorMsg;
  List<ProjectTreeBean> data;

  ProjectTreeModel.fromParams({this.errorCode, this.errorMsg, this.data});

  factory ProjectTreeModel(jsonStr) => jsonStr == null
      ? null
      : jsonStr is String
          ? new ProjectTreeModel.fromJson(json.decode(jsonStr))
          : new ProjectTreeModel.fromJson(jsonStr);

  ProjectTreeModel.fromJson(jsonRes) {
    errorCode = jsonRes['errorCode'];
    errorMsg = jsonRes['errorMsg'];
    data = jsonRes['data'] == null ? null : [];

    for (var dataItem in data == null ? [] : jsonRes['data']) {
      data.add(
          dataItem == null ? null : new ProjectTreeBean.fromJson(dataItem));
    }
  }

  @override
  String toString() {
    return '{"errorCode": $errorCode,"errorMsg": ${errorMsg != null ? '${json.encode(errorMsg)}' : 'null'},"data": $data}';
  }
}

class ProjectTreeBean {
  int courseId;
  int id;
  int order;
  int parentChapterId;
  int visible;
  bool userControlSetTop;
  String name;
  List<dynamic> children;

  ProjectTreeBean.fromParams(
      {this.courseId,
      this.id,
      this.order,
      this.parentChapterId,
      this.visible,
      this.userControlSetTop,
      this.name,
      this.children});

  ProjectTreeBean.fromJson(jsonRes) {
    courseId = jsonRes['courseId'];
    id = jsonRes['id'];
    order = jsonRes['order'];
    parentChapterId = jsonRes['parentChapterId'];
    visible = jsonRes['visible'];
    userControlSetTop = jsonRes['userControlSetTop'];
    name = StringUtil.urlDecoder(jsonRes['name']);
    children = jsonRes['children'] == null ? null : [];

    for (var childrenItem in children == null ? [] : jsonRes['children']) {
      children.add(childrenItem);
    }
  }

  @override
  String toString() {
    return '{"courseId": $courseId,"id": $id,"order": $order,"parentChapterId": $parentChapterId,"visible": $visible,"userControlSetTop": $userControlSetTop,"name": ${name != null ? '${json.encode(name)}' : 'null'},"children": $children}';
  }
}
