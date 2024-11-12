// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:molib/src/fraction/exception/fraction_exception.dart';
import 'package:molib/src/fraction/exception/fraction_parse_exception.dart';

class Fraction {
  int _numerator;
  int _denominator;

  Fraction._def(
    this._numerator,
    this._denominator,
  );

  factory Fraction(int numerator, int denominator) {
    if (denominator == 0) {
      throw FractionException("Знаменатель не может быть равен 0.");
    }
    final sign = numerator.sign * denominator.sign;
    return Fraction._def(numerator.abs() * sign, denominator.abs());
  }

  ///Числитель дроби
  int get numerator => _numerator;

  ///Знаменатель дроби
  int get denominator => _denominator;

  ///Parses fraction from string.
  ///Must be in format 'x/y' where x is numerator and y is denominator
  static Fraction parseFraction(String str) {
    final splitted = str.trim().split("/");
    final newNum = int.tryParse(splitted[0]);
    final newDen = int.tryParse(splitted[1]);
    if (splitted.length < 2) {
      throw FractionParseException(
          "Not enough elements after splitting by '/'");
    }
    if (newNum == null) {
      throw FractionParseException("Couldnt parse numerator");
    }
    if (newDen == null) {
      throw FractionParseException("Couldnt parse denominator");
    }
    return Fraction(newNum, newDen);
  }

  Fraction reduced() {
    final gcd = _numerator.gcd(_denominator);
    final reNum = _numerator / gcd;
    final reDe = _denominator / gcd;
    final sign = (reNum.sign * reDe.sign).toInt();
    return Fraction(reNum.toInt().abs() * sign, reDe.toInt().abs());
  }

  Fraction _add(Fraction other) {
    if (_denominator == other._denominator) {
      return Fraction(_numerator + other._numerator, _denominator);
    }
    return Fraction(
        _numerator * other._denominator + other._numerator * _denominator,
        other._denominator * _denominator);
  }

  Fraction _sub(Fraction other) {
    if (_denominator == other._denominator) {
      return Fraction(_numerator - other._numerator, _denominator);
    }

    return Fraction(
        numerator * other.denominator - other.numerator * denominator,
        other.denominator * denominator);
  }

  Fraction operator +(Object other) {
    if (other is Fraction) {
      return _add(other);
    } else if (other is int) {
      return _add(Fraction(other, 1));
    } else {
      throw Exception("Fraction can't be added to this type of object");
    }
  }

  Fraction operator *(Object other) {
    if (other is Fraction) {
      final newDen = other._denominator * _denominator;
      final newNum = other._numerator * _numerator;
      return Fraction(newNum, newDen);
    } else if (other is int) {
      return Fraction(_numerator * other, _denominator);
    } else {
      throw Exception();
    }
  }

  Fraction operator /(Object other) {
    if (other is Fraction) {
      final newNum = _numerator * other.denominator;
      final newDen = _denominator * other.numerator;
      return Fraction(newNum, newDen);
    } else if (other is int) {
      return Fraction(_numerator * other, _denominator);
    } else {
      throw Exception();
    }
  }

  Fraction operator -(Object other) {
    if (other is Fraction) {
      return _sub(other);
    } else if (other is int) {
      return _sub(Fraction(other, 1));
    } else if (other is num) {
      return _sub(Fraction(other.toInt(), 1));
    } else {
      throw Exception("Fraction can't be added to this type of object");
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is Fraction) {
      return numerator * other.denominator == other.numerator * denominator;
    } else if (other is num) {
      return numerator == other * denominator;
    } else {
      throw FractionException(
          "Cannot compare Fraction with ${other.runtimeType}");
    }
  }

  bool operator >(Object other) {
    if (other is Fraction) {
      return numerator * other.denominator > other.numerator * denominator;
    } else if (other is num) {
      return numerator > other * denominator;
    } else {
      throw FractionException(
          "Cannot compare Fraction with this type of object");
    }
  }

  bool operator <(Object other) {
    if (other is Fraction) {
      return numerator * other.denominator < other.numerator * denominator;
    } else if (other is num) {
      return numerator < other * denominator;
    } else {
      throw FractionException(
          "Cannot compare Fraction with this type of object");
    }
  }

  bool operator >=(Object other) {
    if (other is Fraction) {
      return numerator * other.denominator >= other.numerator * denominator;
    } else if (other is num) {
      return numerator >= other * denominator;
    } else {
      throw FractionException(
          "Cannot compare Fraction with ${other.runtimeType}");
    }
  }

  bool operator <=(Object other) {
    if (other is Fraction) {
      return numerator * other.denominator <= other.numerator * denominator;
    } else if (other is num) {
      return numerator <= other * denominator;
    } else {
      throw FractionException(
          "Cannot compare Fraction with ${other.runtimeType}");
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return (denominator == 1) ? "$_numerator" : "$_numerator/$_denominator";
  }

  double toDouble() {
    return _numerator / _denominator;
  }

  int toInt() {
    return toDouble().toInt();
  }
}
