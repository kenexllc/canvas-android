// Copyright (C) 2019 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:dio/dio.dart';
import 'package:flutter_parent/models/enrollment.dart';
import 'package:flutter_parent/network/utils/api_prefs.dart';
import 'package:flutter_parent/network/utils/dio_config.dart';
import 'package:flutter_parent/network/utils/fetch.dart';

class EnrollmentsApi {
  Future<List<Enrollment>> getObserveeEnrollments({bool forceRefresh = false}) async {
    var dio = canvasDio(pageSize: PageSize.canvasMax, forceRefresh: forceRefresh);
    var params = {
      'include': ['observed_users', 'avatar_url'],
      'state': ['creation_pending', 'invited', 'active', 'completed']
    };
    return fetchList(dio.get('users/self/enrollments', queryParameters: params), depaginateWith: dio);
  }

  Future<List<Enrollment>> getSelfEnrollments({bool forceRefresh = false}) async {
    var dio = canvasDio(pageSize: PageSize.canvasMax, forceRefresh: forceRefresh);
    var params = {
      'state': ['creation_pending', 'invited', 'active', 'completed']
    };
    return fetchList(dio.get('users/self/enrollments', queryParameters: params), depaginateWith: dio);
  }

  Future<List<Enrollment>> getEnrollmentsByGradingPeriod(String courseId, String studentId, String gradingPeriodId,
      {bool forceRefresh = false}) {
    final dio = canvasDio(forceRefresh: forceRefresh);
    final params = {
      'state': ['active', 'completed'], // current_and_concluded state not supported for observers
      'user_id': studentId,
      if (gradingPeriodId?.isNotEmpty == true)
        'grading_period_id': gradingPeriodId,
    };
    return fetchList(
      dio.get(
        'courses/$courseId/enrollments',
        queryParameters: params,
      ),
      depaginateWith: dio,
    );
  }

  Future<bool> pairWithStudent(String pairingCode) async {
    try {
      var pairingResponse = await canvasDio().post(ApiPrefs.getApiUrl(path: 'users/${ApiPrefs.getUser().id}/observees'),
          queryParameters: {'pairing_code': pairingCode});
      return (pairingResponse.statusCode == 200 || pairingResponse.statusCode == 201);
    } on DioError {
      return false;
    }
  }
}
