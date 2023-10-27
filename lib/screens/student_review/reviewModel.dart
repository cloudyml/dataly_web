// To parse this JSON data, do
//
//     final studentReviewsModel = studentReviewsModelFromJson(jsonString);

import 'dart:convert';

StudentReviewsModel studentReviewsModelFromJson(String str) =>
    StudentReviewsModel.fromJson(json.decode(str));

String studentReviewsModelToJson(StudentReviewsModel data) =>
    json.encode(data.toJson());

class StudentReviewsModel {
  Result? result;

  StudentReviewsModel({
    this.result,
  });

  factory StudentReviewsModel.fromJson(Map<String, dynamic> json) =>
      StudentReviewsModel(
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result?.toJson(),
      };
}

class Result {
  List<Review>? reviews;
  Avgrating? avgrating;

  Result({
    this.reviews,
    this.avgrating,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                json["reviews"]!.map((x) => Review.fromJson(x))),
        avgrating: json["avgrating"] == null
            ? null
            : Avgrating.fromJson(json["avgrating"]),
      );

  Map<String, dynamic> toJson() => {
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "avgrating": avgrating?.toJson(),
      };
}

class Avgrating {
  double? one;
  double? two;
  double? three;
  double? four;
  double? five;
  double? total;

  Avgrating({
    this.one,
    this.two,
    this.three,
    this.four,
    this.five,
    this.total,
  });

  factory Avgrating.fromJson(Map<String, dynamic> json) => Avgrating(
        one: json["one"]?.toDouble(),
        two: json["two"]?.toDouble(),
        three: json["three"]?.toDouble(),
        four: json["four"]?.toDouble(),
        five: json["five"]?.toDouble(),
        total: json["total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "one": one,
        "two": two,
        "three": three,
        "four": four,
        "five": five,
        "total": total,
      };
}

class Review {
  String? date;
  String? reviewdescription;
  String? linkdinlink;
  String? name;
  String? rating;
  String? course;
  String? id;
  String? experience;
  String? email;

  Review({
    this.date,
    this.reviewdescription,
    this.linkdinlink,
    this.name,
    this.rating,
    this.course,
    this.id,
    this.experience,
    this.email,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        date: json["date"],
        reviewdescription: json["reviewdescription"],
        linkdinlink: json["linkdinlink"],
        name: json["name"],
        rating: json["rating"],
        course: json["course"],
        id: json["id"],
        experience: json["experience"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "reviewdescription": reviewdescription,
        "linkdinlink": linkdinlink,
        "name": name,
        "rating": rating,
        "course": course,
        "id": id,
        "experience": experience,
        "email": email,
      };
}
