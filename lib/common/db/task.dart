import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/utils.dart';

@Entity(tableName: "task")
class Task {
  String title;
  String className;
  late int taskType;
  int deadline;
  late String url;

  late String classId;
  late String reportId;
  @primaryKey
  late String id;
  int? customColor;

  // for inflate survey
  Task(
    this.title,
    this.className,
    this.taskType,
    this.deadline,
    this.url,
    this.reportId,
    this.classId,
    this.customColor,
  ) {
    if (classId == "") {
      classId = className;
    }
    id = "$taskType-$classId-$reportId";
  }

  // for inflate task or test
  Task.idFromUrl(
    this.title,
    this.className,
    this.taskType,
    this.deadline,
    this.url,
    this.customColor,
  ) {
    var uri = Uri.parse(url);
    classId = uri.queryParameters["idnumber"]!;
    reportId = uri.queryParameters["reportId"]!;
    id = "$taskType-$classId-$reportId";
  }

  @override
  bool operator ==(Object other) {
    if (other is Task) {
      return (other.id == id);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "Task { id=$id, title=$title, className=$className, taskType=$taskType, deadline=${timeToString(deadline)}, url=$url, classId=$classId, reportId=$reportId } ";
  }
}
