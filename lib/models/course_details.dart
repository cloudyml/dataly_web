class CourseDetails {
  String courseName;
  String courseId;
  String courseDocumentId;
  String coursePrice;
  String courseDescription;
  String createdBy;
  String amountPayable;
  String amount_Payable;
  String discount;
  bool isItComboCourse;
  String courseImageUrl;
  String courseLanguage;
  List courses;
  dynamic curriculum;
  String numOfVideos;
  String FcSerialNumber;
  String courseContent;
  String reviews;
  bool? show;
  bool? trialCourse;
  String trialDays;
  String? duration;
  String? findex;
  bool? multiCombo;
  bool? international;
  String? dataly_actual_price;
  String? dataly_discounted_price;

  CourseDetails({
    required this.courseName,
    required this.courseId,
    required this.coursePrice,
    required this.courseDescription,
    required this.amountPayable,
    required this.amount_Payable,
    required this.discount,
    required this.isItComboCourse,
    required this.courseImageUrl,
    required this.courseLanguage,
    required this.courses,
    required this.curriculum,
    required this.numOfVideos,
    required this.createdBy,
    required this.courseDocumentId,
    required this.FcSerialNumber,
    required this.courseContent,
    required this.show,
    required this.reviews,
    required this.trialCourse,
    required this.trialDays,
    this.duration,
    this.findex,
    this.multiCombo,
    this.international,
    this.dataly_actual_price,
    this.dataly_discounted_price
  });
}
