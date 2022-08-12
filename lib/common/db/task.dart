import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

@Entity(tableName: "task")
class Task {
  String title;
  String className;
  late TaskType taskType;
  int deadline;
  late String url;

  late String classId;
  late String reportId;
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
    id = "$classId-$reportId";
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
    id = "$classId-$reportId";
  }

  @override
  bool operator ==(Object other) {
    if (other is Task) {
      return (other.reportId == reportId &&
          other.classId == classId &&
          other.taskType == taskType &&
          other.deadline == deadline);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return "Task { id=$id, title=$title, className=$className, taskType=$taskType, deadline=${timeToString(deadline)}, url=$url, classId=$classId, reportId=$reportId } ";
  }
}
