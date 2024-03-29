import 'package:flutter/material.dart';
import 'package:nexus_mobile_app/enum/TaskStatus.dart';
import 'package:nexus_mobile_app/models/User.dart';
import 'package:nexus_mobile_app/services/APIRoutes.dart';
import 'package:nexus_mobile_app/services/AuthorizedClient.dart';

class AuthenticationRepository {
  User user;
  bool isAuthenticated;

  Future<bool> init() async {
    try {
      var token = await AuthorizedClient.retrieveAccessToken();
      if (token == null) {
        throw ErrorDescription("No stored token");
      }
      this.user = User.fromMap(
          await AuthorizedClient.get(route: APIRoutes.routes[User] + '/self'));
      if (user == null) {
        throw ErrorDescription("Bad response");
      }
    } catch (err) {
      isAuthenticated = false;
      return isAuthenticated;
    }
    isAuthenticated = true;
    return isAuthenticated;
  }

  Future<User> signIn(String username, String password) async {
    try {
      final stat = await AuthorizedClient.authenticate(
          username: username, password: password);
      if (stat != TaskStatus.SUCCESS)
        throw ErrorDescription("Error signing in.");
      this.user = User.fromMap(
          await AuthorizedClient.get(route: APIRoutes.routes[User] + '/self'));
    } catch (err) {
      return null;
    }
    return this.user;
  }

  Future signOut() async {
    await AuthorizedClient.deauthorize();
  }
}
