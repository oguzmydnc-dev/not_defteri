import 'package:flutter/material.dart';

class Not {
  final String baslik;
  final String icerik;
  final Color renk;
  final bool sabit;

  const Not({
    required this.baslik,
    required this.icerik,
    this.renk = Colors.yellow,
    this.sabit = false,
  });

  Not copyWith({
    String? baslik,
    String? icerik,
    Color? renk,
    bool? sabit,
  }) {
    return Not(
      baslik: baslik ?? this.baslik,
      icerik: icerik ?? this.icerik,
      renk: renk ?? this.renk,
      sabit: sabit ?? this.sabit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baslik': baslik,
      'icerik': icerik,
      'renk': renk.toARGB32(),
      'sabit': sabit,
    };
  }

  factory Not.fromJson(Map<String, dynamic> json) {
    return Not(
      baslik: json['baslik'],
      icerik: json['icerik'],
      renk: Color(json['renk']),
      sabit: json['sabit'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Not &&
          baslik == other.baslik &&
          icerik == other.icerik &&
          renk.toARGB32() == other.renk.toARGB32() &&
          sabit == other.sabit;

  @override
  int get hashCode =>
      baslik.hashCode ^
      icerik.hashCode ^
      renk.toARGB32().hashCode ^
      sabit.hashCode;

}
