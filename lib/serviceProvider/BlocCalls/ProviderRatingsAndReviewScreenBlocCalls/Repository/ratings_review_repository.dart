import 'dart:convert';

import 'package:gps_massageapp/constantUtils/constantsUtils.dart';
import 'package:gps_massageapp/models/responseModels/serviceProvider/providerReviewandRatingsViewResponseModel.dart';
import 'package:http/http.dart' as http;

abstract class GetTherapistReviewRepository {
  String accessToken = HealingMatchConstants.accessToken;
  int therapistId = HealingMatchConstants.userId;

  Future<List<TherapistReviewList>> getTherapistReviewById(
      String accessToken, int therapistId, int pageNumber, int pageSize);
}

class GetTherapistReviewRepositoryImpl implements GetTherapistReviewRepository {
  @override
  String accessToken;

  @override
  int therapistId;

  @override
  Future<List<TherapistReviewList>> getTherapistReviewById(
      String accessToken, int therapistId, int pageNumber, int pageSize) async {
    try {
      print("Api hit");
      final url =
          'http://106.51.49.160:9094/api/mobileReview/userReviewListById?page=$pageNumber&size=$pageSize';
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'x-access-token': '$accessToken'
      };
      final response = await http.post(url,
          headers: headers,
          body: json.encode({
            "therapistId": therapistId,
          }));
      print('Therapist repo token : $accessToken : Tid  : $therapistId');
      if (response.statusCode == 200) {
        var therapistData = json.decode(response.body);
        List<TherapistReviewList> therapistUsers =
            ProviderReviewandRatingsViewResponseModel.fromJson(therapistData)
                .therapistsData
                .therapistReviewList;
        print('Types list:  $therapistData');
        return therapistUsers;
      } else {
        print('Error occurred!!! TypeMassages response');
        throw Exception();
      }
    } catch (e) {
      print('Exception : ${e.toString()}');
    }
  }
}
