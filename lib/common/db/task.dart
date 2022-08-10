import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

class Task {
  String title;
  String className;
  late TaskType taskType;
  int deadline;
  late String url;

  String? classId;
  String? reportId;
  late int id;

  Task(this.title, this.className, this.taskType, this.deadline, this.url) {
    var uri = Uri.parse(url);
    classId = uri.queryParameters["idnumber"];
    reportId = uri.queryParameters["reportId"];
    id = DateTime.now().millisecondsSinceEpoch;
  }

  // task as survey
  Task.constructSurvey(
      this.title, this.className, this.deadline, this.reportId, this.classId) {
    taskType = TaskType.Survey;
    url = "$SURVEY_PAGE_URL?$reportId";
    id = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return "Task { id=$id, title=$title, className=$className, taskType=$taskType, deadline=${timeToString(deadline)}, url=$url, classId=$classId, reportId=$reportId } ";
  }
}
