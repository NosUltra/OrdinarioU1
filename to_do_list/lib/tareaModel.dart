import 'dart:convert';

class Tarea {
  String titulo;
  String desc;
  bool estado;

  Tarea({
    required this.titulo,
    required this.desc,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'desc': desc,
      'estado': estado,
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      titulo: json['titulo'],
      desc: json['desc'],
      estado: json['estado'],
    );
  }
}