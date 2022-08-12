import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

class Task {
  String title;
  String className;
  late TaskType taskType;
  int deadline;
  late String url;

  late String classId;
  late String reportId;
  late int id;
  int? customColor;

  Task(
    this.title,
    this.className,
    this.taskType,
    this.deadline,
    this.url,
    String? reportId,
    String? classId,
    this.customColor,
  ) {
    // if survey
    // require not null reportId and classId
    if (taskType == TaskType.Survey) {
      this.classId = classId!;
      this.reportId = reportId!;
    }
    // if task or test
    // require not null url
    else {
      var uri = Uri.parse(url);
      this.classId = uri.queryParameters["idnumber"]!;
      this.reportId = uri.queryParameters["reportId"]!;
    }

    id = DateTime.now().millisecondsSinceEpoch;
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
