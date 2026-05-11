class UserModel {
  final String studentId;
  final String firstName;
  final String role;
  final int status;
  final String profilePic;
  final String gender;
  final int mobile;
  final String email;
  final List<String> mappedTo;
  final String rollNo;

  UserModel({
    required this.studentId,
    required this.firstName,
    required this.role,
    required this.status,
    required this.profilePic,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.mappedTo,
    required this.rollNo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      studentId: json['student_id'] ?? '',
      firstName: json['first_name'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 0,
      profilePic: json['profile_pic'] ?? '',
      gender: json['gender'] ?? '',
      mobile: json['mobile'] ?? 0,
      email: json['email'] ?? '',
      mappedTo: List<String>.from(json['mapped_to'] ?? []),
      rollNo: json['roll_no'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'first_name': firstName,
      'role': role,
      'status': status,
      'profile_pic': profilePic,
      'gender': gender,
      'mobile': mobile,
      'email': email,
      'mapped_to': mappedTo,
      'roll_no': rollNo,
    };
  }
}
