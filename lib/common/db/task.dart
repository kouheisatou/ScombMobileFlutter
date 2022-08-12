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

  Task(
    this.title,
    this.className,
    this.taskType,
    this.deadline,
    String? url,
    String? reportId,
    String? classId,
  ) {
    // if survey
    // require not null reportId and classId
    if (taskType == TaskType.Survey) {
      url = "$SURVEY_PAGE_URL?surveyId=$reportId";
      this.classId = classId!;
      this.reportId = reportId;
    }
    // if task or test
    // require not null url
    else {
      this.url = url!;
      var uri = Uri.parse(this.url);
      this.classId = uri.queryParameters["idnumber"];
      this.reportId = uri.queryParameters["reportId"];
    }
    id = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return "Task { id=$id, title=$title, className=$className, taskType=$taskType, deadline=${timeToString(deadline)}, url=$url, classId=$classId, reportId=$reportId } ";
  }
}
