// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:molib/molib.dart';

///Класс обертка, для того, чтобы можно было хранить в матрице
///как натуральные дроби так и вещественные числа
class MxEntry {
  final dynamic _value;
  MatrixMode mode = MatrixMode.double;

  MxEntry._({
    required dynamic value,
  }) : _value = value;

  ///[value] может быть равно только [Fraction] или [double]
  factory MxEntry(dynamic value) {
    if (value is! Fraction || value is! double) {
      throw Exception("MxEntry can be either Fraction or double");
    }
    return MxEntry._(value: value);
  }

  dynamic get value => _value;

  MxEntry operator +(Object other) {
    //Technically other value cant anything besides fraction and double
    dynamic newValue;
    if (other is! MxEntry) {
      throw Exception("MxEntry can be add only to mx entry");
    }

    newValue = other.value + newValue;

    return MxEntry(value);
  }

  MxEntry operator -(Object other) {
    throw UnimplementedError();
  }

  MxEntry operator *(Object other) {
    throw UnimplementedError();
  }

  MxEntry operator /(Object other) {
    throw UnimplementedError();
  }

  bool operator >(Object other) {
    throw UnimplementedError();
  }

  bool operator >=(Object other) {
    throw UnimplementedError();
  }

  bool operator <(Object other) {
    throw UnimplementedError();
  }

  bool operator <=(Object other) {
    throw UnimplementedError();
  }

  @override
  String toString() {
    if (_value is double) {
      return _value.toString();
    }
    if (_value is Fraction) {
      return _value.reduced().toString();
    }
    return "";
  }
}
