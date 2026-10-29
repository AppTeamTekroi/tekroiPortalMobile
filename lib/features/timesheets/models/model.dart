class UserProjectResponse {
  final String status;
  final List<User> users;
  final List<Project> projects;

  UserProjectResponse({
    required this.status,
    required this.users,
    required this.projects,
  });

  factory UserProjectResponse.fromJson(Map<String, dynamic> json) {
    return UserProjectResponse(
      status: json['status'],
      users: (json['users'] as List).map((u) => User.fromJson(u)).toList(),
      projects: (json['projects'] as List).map((p) => Project.fromJson(p)).toList(),
    );
  }
}

int? parseJsonInt(dynamic value) {
  if (value == null || value == '') return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

class User {
  final int id;
  final String name;
  final int? managerId;

  User({
    required this.id,
    required this.name,
    this.managerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseJsonInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      managerId: parseJsonInt(
        json['manager_id'] ??
            json['reporting_to_id'] ??
            json['reporting_manager_id'] ??
            json['reporting_to'],
      ),
    );
  }
}

class Project {
  final int id;
  final String projectName;

  Project({
    required this.id,
    required this.projectName,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      projectName: json['project_name'],
    );
  }
}

class Domain {
  final String id;
  final String name;

  Domain({
    required this.id,
    required this.name,
  });

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'].toString(),
      name: json['domain'] ?? '',
    );
  }
}


