// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:molib/src/exception/fraction_parse_exception.dart';

class Fraction {
  int numerator;
  int denominator;
  Fraction(
    this.numerator,
    this.denominator,
  );

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
    final gcd = numerator.gcd(denominator);
    final reNum = numerator / gcd;
    final reDe = denominator / gcd;
    return Fraction(reNum.toInt(), reDe.toInt());
  }

  Fraction _add(Fraction other) {
    if (denominator == other.denominator) {
      return Fraction(numerator + other.numerator, denominator);
    }
    final gcd = denominator.gcd(other.denominator);
    final lcm = (denominator * other.denominator) / gcd;
    final newNum = numerator * (lcm / denominator) +
        other.numerator * (lcm / other.denominator);
    return Fraction(newNum.toInt(), lcm.toInt());
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
      final newDen = other.denominator * denominator;
      final newNum = other.numerator * numerator;
      return Fraction(newNum, newDen);
    } else if (other is int) {
      return Fraction(numerator * other, denominator);
    } else {
      throw Exception();
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$numerator/$denominator";
  }

  double toDouble() {
    return numerator / denominator;
  }

  int toInt() {
    return toDouble().toInt();
  }
}
