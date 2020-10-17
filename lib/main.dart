import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/database.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart' as D;

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: Home(),
    routes: <String, WidgetBuilder>{
    },
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final db = Database();
  List _displayTodos = [];
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<List> getTodosByTime(DateTime T) async {
    await db.init();
    return db.getTodoByTime(T);
  }

  @override
  void initState() {
    getTodosByTime(_selectedDate).then((res) {
      setState(() {
        _displayTodos = res;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {

    final DateTime picked = await D.DatePicker.showSimpleDatePicker(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      dateFormat: "dd-MMMM-yyyy",
      backgroundColor: Colors.lightBlueAccent[200],
      textColor: Colors.black
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        print(picked);
      });
      getTodosByTime(_selectedDate).then((res) {
        setState(() {
          _displayTodos = res;
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Todos"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.cyan,
                Colors.greenAccent
              ]
            )
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Container(
//        color: Colors.black12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.lightGreen[100],
              Colors.cyanAccent[100]
            ]
        )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 600.0,
                child: ListView.builder(
                    itemCount: _displayTodos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          child: CheckboxListTile(
                            activeColor: Colors.cyan[300],
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _displayTodos[index]['name'],
                                ),
                                IconButton(
                                  icon: Icon(Icons.clear),
                                  iconSize: 20.0,
                                  onPressed: () async {
                                    await db.deleteTodo(_displayTodos[index]);
                                    setState(() {
                                      _displayTodos.removeAt(index);
                                    });
                                  },
                                )
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: (_displayTodos[index]['status'] == 1),
                            onChanged: (bool value) async {
                              int status = value ? 1 : 0;
                              setState(() {
                                _displayTodos[index]['status'] = status;
                              });
                              await db.updateTodo(_displayTodos[index]);
                            },
                          )
                      );
                    }
                ),
              ),
            ),
            Container(
              child: ClipPath(
                clipper: CurvedBottomClipper(),
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20.0)],
                      gradient: LinearGradient(
                        colors: [Colors.cyan, Colors.greenAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,)
                  ),
                  height: 140.0,
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              child: Icon(
                                Icons.add,
                                size: 30.0,
                              ),
                              fillColor: Colors.redAccent,
                              padding: EdgeInsets.all(12.0),
                              shape: CircleBorder(),
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        contentPadding: EdgeInsets.all(0),
                                        content: Stack(
                                          overflow: Overflow.visible,
                                          children: <Widget>[
                                            Positioned(
                                              right: -40.0,
                                              top: -40.0,
                                              child: InkResponse(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: <Color>[
                                                      Colors.cyan,
                                                      Colors.greenAccent
                                                    ]
                                                )
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      controller: nameController,
                                                      decoration: InputDecoration(
                                                        icon: Icon(Icons.person),
                                                        labelText: 'Task Name',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: RaisedButton(
                                                      child: Text("ADD"),
                                                      color: Colors.redAccent,
                                                      onPressed: () async {
                                                        Todo todo = Todo(id: 1, name: nameController.text, created_at: DateTime.now().toString(), status: 0);
                                                        await db.addTodo(todo);
                        //                                await db.deleteAll();
                                                        final List T = await db.getTodo();
                                                        setState(() {
                                                          _displayTodos = T;
                                                        });
                                                        nameController.text = "";
                                                      },
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                );
                              }
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {

  final pi = -3.1415;
  @override
  Path getClip(Size size) {
    final roundingRectangle = Rect.fromLTRB(-35, 40, size.width + 35, (17.5 * size.height) / 10);

    final path = Path();
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // returning fixed 'true' value here for simplicity, it's not the part of actual question, please read docs if you want to dig into it
    // basically that means that clipping will be redrawn on any changes
    return true;
  }
}