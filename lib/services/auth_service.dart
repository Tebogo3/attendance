import 'package:attendance/services/db_service.dart';
import 'package:attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  //this is an instance of Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  //this is an instance of DbService
  final DbService _dbService = DbService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;
//any widget listening to this will refresh
  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future registerEmployee(
      String email, String password, BuildContext context) async {
    try {
      setIsLoading = true;
      if (email == "" || password == "") {
        throw ("All Fields are required");
      }
      // ignore: unused_local_variable
      final AuthResponse response =
          await _supabase.auth.signUp(email: email, password: password);
      await _dbService.insertNewUser(email, response.user!.id);
      Utils.showSnackBar('Successfully registered!', context,
          color: Colors.green);
      await loginEmployee(email, password, context);
      Navigator.pop(context);
    } catch (e) {
      setIsLoading = false;
      Utils.showSnackBar(e.toString(), context, color: Colors.red);
    }
  }

  Future loginEmployee(
      String email, String password, BuildContext context) async {
    try {
      setIsLoading = true;
      if (email == "" || password == "") {
        throw ("All Fields are required");
      }
      final AuthResponse response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      setIsLoading = false;
    } catch (e) {
      setIsLoading = false;
      Utils.showSnackBar(e.toString(), context, color: Colors.red);
    }
  }

  Future signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

//if the user has signed In
  User? get currentUser => _supabase.auth.currentUser;
}
