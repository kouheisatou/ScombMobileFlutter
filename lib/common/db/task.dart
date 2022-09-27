import 'package:floor/floor.dart';
import 'package:scomb_mobile/common/db/class_cell.dart';
import 'package:scomb_mobile/common/utils.dart';

@Entity(tableName: "task")
class Task {
  String title;
  late String className;
  late int taskType;
  int deadline;
  late String url;

  late String classId;
  late String reportId;
  @primaryKey
  late String id;
  int? customColor;
  late bool addManually;
  late bool done;

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
    this.addManually,
    this.done,
  ) {
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
    this.addManually,
  ) {
    var uri = Uri.parse(url);
    classId = uri.queryParameters["idnumber"]!;

    String? reportId = uri.queryParameters["reportId"];
    String? examId = uri.queryParameters["examinationId"];
    if (reportId != null) {
      this.reportId = reportId;
    } else if (examId != null) {
      this.reportId = examId;
    } else {
      this.reportId = "";
    }

    id = "$taskType-$classId-${this.reportId}";
    done = false;
  }

  Task.userTask(
    this.title,
    ClassCell? relatedClass,
    this.taskType,
    this.deadline,
  ) {
    addManually = true;
    url = relatedClass?.url ?? "";
    className = relatedClass?.name ?? "";
    classId = relatedClass?.classId ?? "";
    reportId = "usertask${DateTime.now().millisecondsSinceEpoch.hashCode}";
    customColor = relatedClass?.customColorInt;
    id = "$taskType-$classId-$reportId";
    done = false;
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
    return "Task { id=$id, title=$title, className=$className, taskType=$taskType, deadline=${timeToString(deadline)}, url=$url, classId=$classId, reportId=$reportId, customColor=$customColor, done=$done } ";
  }
}
