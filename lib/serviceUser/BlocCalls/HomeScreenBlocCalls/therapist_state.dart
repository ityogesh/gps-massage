import 'package:equatable/equatable.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistListByTypeModel.dart';
import 'package:gps_massageapp/models/responseModels/serviceUser/homeScreen/TherapistUsersModel.dart';
import 'package:meta/meta.dart';

abstract class TherapistUsersState extends Equatable {}


class LoadingState extends TherapistUsersState {

  @override
  List<Object> get props => null;
}

// ignore: must_be_immutable
class GetTherapistUsersState extends TherapistUsersState {
  List<TherapistDatum> getTherapistsUsers;

  GetTherapistUsersState({@required this.getTherapistsUsers});

  @override
  List<Object> get props => [getTherapistsUsers];
}

// ignore: must_be_immutable
class GetTherapistUsersErrorState extends TherapistUsersState {
  String message;

  GetTherapistUsersErrorState({@required this.message});

  @override
  List<Object> get props => [message];
}
