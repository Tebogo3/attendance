import 'package:attendance/constants/constants.dart';
import 'package:attendance/models/attendance_model.dart';
import 'package:attendance/services/location_service.dart';
import 'package:attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AttendanceModel? attendanceModel;

  String todayDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  bool _isLoading = false;

  bool get isLoading => _isLoading;
//any widget listening to this will refresh
  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _attendanceHistoryMonth =
      DateFormat('MMMM yyyy').format(DateTime.now());

  String get attendanceHistoryMonth => _attendanceHistoryMonth;

  set attendanceHistoryMonth(String value) {
    _attendanceHistoryMonth = value;
    notifyListeners();
  }

//check whether checked In for today or not...if yes then we will store that in attendance register
  Future getTodayAttendance() async {
    final List result = await _supabase
        .from(Constants.attendanceTable)
        .select()
        .eq("employee_id", _supabase.auth.currentUser!.id)
        .eq('date', todayDate);

    if (result.isNotEmpty) {
      attendanceModel = AttendanceModel.fromJson(result
          .first); //many attandence but one particully employee with one data
    }
    notifyListeners();
  }

  //First check whether employee checked In that day and if yes insert a new data for that day
  Future markAttendance(BuildContext context) async {
    Map? getLocation =
        await LocationService().initializeAndGetLocation(context);
    if (getLocation != null) {
      if (attendanceModel?.checkIn == null) {
        await _supabase.from(Constants.attendanceTable).insert({
          'employee_id': _supabase.auth.currentUser!.id,
          'date': todayDate,
          'check_in': DateFormat('HH:mm').format(DateTime.now()),
          'check_in_location': getLocation,
        });
      } else if (attendanceModel?.checkOut == null) {
        await _supabase
            .from(Constants.attendanceTable)
            .update({
              'check_out': DateFormat('HH:mm').format(DateTime.now()),
              'check_out_location': getLocation
            })
            .eq('employee_id', _supabase.auth.currentUser!.id)
            .eq('date', todayDate);
      } else {
        Utils.showSnackBar('You have already checked out today!', context);
      }
      getTodayAttendance(); //to get the latest data and update the UI because we have notify listener
    } else {
      Utils.showSnackBar("Not able to get your location", context,
          color: Colors.red);
      getTodayAttendance();
    }
  }

  Future<List<AttendanceModel>> getAttendanceHistory() async {
    final List data = await _supabase
        .from(Constants.attendanceTable)
        .select()
        .eq('employee_id', _supabase.auth.currentUser!.id)
        .textSearch('date', "'$attendanceHistoryMonth'", config: 'english')
        .order('created_at', ascending: false);

    return data
        .map((attendance) => AttendanceModel.fromJson(attendance))
        .toList();
  }
}
