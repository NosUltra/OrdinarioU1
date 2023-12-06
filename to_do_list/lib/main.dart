import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/tareaModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = prefs.getStringList('taskList') ?? [];
    setState(() {
      _tareas =
          taskList.map((task) => Tarea.fromJson(jsonDecode(task))).toList();
    });
  }

  List<Tarea> _tareas = [];

  TextEditingController _tituloController = new TextEditingController();
  TextEditingController _descController = new TextEditingController();

  @override
  void didUpdateWidget(TestPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> addTask(
      BuildContext context, int index, String titulo, String desc) async {
    Color color = Colors.black12;
    var alert = AlertDialog();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (index == -1) {
      alert = AlertDialog(
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Acepetar'),
            onPressed: () async {
              if (_tituloController.text.length > 0) {
                setState(() {
                  _tareas.add(Tarea(
                      titulo: _tituloController.text,
                      desc: _descController.text,
                      estado: false));
                  _tituloController.clear();
                  _descController.clear();
                });

                List<String> taskList =
                    _tareas.map((task) => jsonEncode(task.toJson())).toList();
                prefs.setStringList('taskList', taskList);
                Navigator.of(context).pop();
              } else {
                completaTitulo(index, context);
              }
            },
          ),
        ],
        title: Text("Añadir tarea"),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Titulo"),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: color,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text('Descripcion'),
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      _tituloController.text = titulo;
      _descController.text = desc;
      alert = AlertDialog(

        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Acepetar'),
            onPressed: () async {
              if (_tituloController.text.length > 0) {
                setState(() {
                  _tareas[index].titulo = _tituloController.text;
                  _tareas[index].desc = _descController.text;
                  _tituloController.clear();
                  _descController.clear();
                });

                List<String> taskList =
                    _tareas.map((task) => jsonEncode(task.toJson())).toList();
                prefs.setStringList('taskList', taskList);
                Navigator.of(context).pop();
              } else {
                completaTitulo(index, context);
              }
            },
          ),
        ],
        title: Text("Editar tarea"),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Titulo"),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: color,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Text('Descripcion'),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              filled: true,
              fillColor: color,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
            ]),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return alert;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          height: 100,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.lightBlue, width: 1),
            ),
            onPressed: () {
              addTask(context, -1, 'null', 'null');
            },
            child: Text('AÑADIR TAREA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        body: Container(
            child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              child: Center(
                  child: Text(
                'To Do List',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.grey),
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: _tareas.length == 0
                  ? Center(
                      child: Text(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          'NO HAY TAREAS PENDIENTES'),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: ListView.builder(
                          shrinkWrap: true,

                          itemCount: _tareas.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress: () {
                                dialogDelete(index, context);
                              },
                              onTap: () {
                                dialogDetalles(
                                    _tareas[index].titulo,
                                    _tareas[index].desc,
                                    _tareas[index].estado,
                                    context);
                              },
                              child: Card(
                                color: _tareas[index].estado ==true? Colors.greenAccent : Colors.white,
                                elevation: 6,
                                child: ListTile(
                                  title: Text(_tareas[index].titulo.length > 15
                                      ? (_tareas[index].titulo.substring(0, 15) +
                                      '...')
                                      : _tareas[index].titulo),
                                  subtitle: Text(_tareas[index].desc.length > 30
                                      ? (_tareas[index].desc.substring(0, 30) +
                                      '...')
                                      : _tareas[index].desc),
                                  trailing: Container(
                                    width: 130,
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            dialogDelete(index, context);
                                          },
                                          child: Icon(Icons.delete),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            addTask(
                                                context,
                                                index,
                                                _tareas[index].titulo,
                                                _tareas[index].desc);
                                          },
                                          child: Icon(Icons.edit),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {},
                                          child: MSHCheckbox(
                                            size: 45,
                                            value: _tareas[index].estado,
                                            colorConfig: MSHColorConfig
                                                .fromCheckedUncheckedDisabled(
                                              checkedColor: Colors.blue,
                                            ),
                                            style: MSHCheckboxStyle.stroke,
                                            onChanged: (selected) async {
                                              print('TOCADOOOOOOOOOO');
                                              setState(() {
                                                if (_tareas[index].estado ==
                                                    false) {
                                                  _tareas[index].estado = true;
                                                } else {
                                                  _tareas[index].estado = false;
                                                }
                                              });
                                              SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                              List<String> taskList = _tareas
                                                  .map((task) =>
                                                  jsonEncode(task.toJson()))
                                                  .toList();
                                              prefs.setStringList(
                                                  'taskList', taskList);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            )
          ],
        )));
  }

  void dialogDetalles(
      String titulo, String desc, bool estado, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(desc),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> dialogDelete(int index, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar tarea'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Estas seguro que desea eliminar esta tarea?'),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _tareas.removeAt(index);
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();

                List<String> taskList =
                _tareas.map((task) => jsonEncode(task.toJson())).toList();
                prefs.setStringList('taskList', taskList);
                Navigator.of(context).pop();
              },
              child: Text('ACEPTAR'),
            )
          ],
        );
      },
    );
  }

  Future<void> completaTitulo(int index, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Titulo vacio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Por favor ingresa un titulo para la tarea'),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            )
          ],
        );
      },
    );
  }
}
