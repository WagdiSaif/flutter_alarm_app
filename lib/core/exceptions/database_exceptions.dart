import 'package:alarmapp/core/exceptions/base_exceptions.dart';

class DataBaseFailure extends BaseExceptions {
  DataBaseFailure([dynamic orignalError, StackTrace? stackTrace])
    : super('Database Failure', orignalError, stackTrace);

  @override
  String toString() => message;
}

class ScheduleFailure extends BaseExceptions {
  ScheduleFailure([dynamic orignalError, StackTrace? stackTrace])
    : super('Schedule Failure', orignalError, stackTrace);

  @override
  String toString() => ' $message';
}

class UnExcepectedFailure extends BaseExceptions {
  UnExcepectedFailure([dynamic orignalError, StackTrace? stackTrace])
    : super('UnExcepected Error', orignalError, stackTrace);
  @override
  String toString() => ' : $message';
}
