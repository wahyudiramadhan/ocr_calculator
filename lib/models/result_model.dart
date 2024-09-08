class ResultModel {
  final String rawText;
  final String expression;
  final String result;
  final String imagePath;

  ResultModel({
    required this.rawText,
    required this.expression,
    required this.result,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'rawText': rawText,
      'expression': expression,
      'result': result,
      'imagePath': imagePath,
    };
  }

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      rawText: json['rawText'],
      expression: json['expression'],
      result: json['result'],
      imagePath: json['imagePath'],
    );
  }
}
