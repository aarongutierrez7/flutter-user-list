import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(userListApp());

class userListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('User List'),
        ),
        body: UserList(),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  @override
  State<UserList> createState() => _UserListState();
}

class User {
  String fullname, username, photoUrl;
  User(this.fullname, this.username, this.photoUrl);
  User.fromJson(Map<String, dynamic> json)
      : fullname = json['name']['first'] + ' ' + json['name']['last'],
        username = json['login']['username'],
        photoUrl = json['picture']['medium'];
}

class _UserListState extends State<UserList> {
  bool loading = false;
  List<User> users = [];

  void initState() {
    users = [];
    loading = true;
    _loadUsers();
    super.initState();
  }

  void _loadUsers() async {
    //await Future.delayed(Duration(seconds: 2));
    var url = Uri.https('randomuser.me', '/api', {"results": '50'});
    final response = await http.get(url);
    List<User> _users = [];

    if (response.statusCode == 200) {
      final json = convert.jsonDecode(response.body);

      for (var jsonUser in json['results']) {
        _users.add(User.fromJson(jsonUser));
      }
      setState(() {
        users = _users;
        loading = false;
      });
      print(url.toString());
    } else {
      throw Exception('Al parecer no se pudo cargar la URL especificada: ' +
          url.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(users[index].fullname),
            subtitle: Text(users[index].username),
            leading: CircleAvatar(
                backgroundImage: NetworkImage(users[index].photoUrl)));
      },
      itemCount: users.length,
    );
  }
}
