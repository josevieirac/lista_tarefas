import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Função principaç do APP
void main() {
  // Função que inicia a execução da aplicação
  runApp(
    //Criando Instancia raiz da aplicação
    MaterialApp(
      //Definindo página inicial da aplicação
      home: Home(),
    )
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /*
  List _toDoList = [
    {"title": "Aprender Dart", "ok": true},
    {"title": "Aprender Flutter", "ok": false},
    {"title": "Aprender Node.JS", "ok": true}
  ];
  */
  List _toDoList = [];

  late int _indexRemoved;
  late var _elementRemoved;

  @override
  void initState()  {
    super.initState();
    _readFile().then((value){
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  TextEditingController _novaTarefaController = TextEditingController();

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveFile() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readFile() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "";
    }
  }

  Widget _createList(int index){
    return CheckboxListTile(
      title: Text(_toDoList[index]["title"]),
      value: _toDoList[index]["ok"],
      onChanged: (value) {
        setState(() {
          _toDoList[index]["ok"] = value;
          _saveFile();
          print("Save");
        });
      },
      secondary: CircleAvatar(
        backgroundColor: _createColor(_toDoList[index]["ok"]),
        child: Icon(
          _toDoList[index]["ok"] ? Icons.check : Icons.error,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _createColor(bool flag){
    if(flag){
      return Colors.green;
    }else{
      return Colors.blue;
    }
  }

  Future<void> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    _toDoList.sort((a,b){
      if(a["ok"] && !b["ok"]){
        return 1;
      }else if(!a["ok"] && b["ok"]){
        return -1;
      }else{
        return 0;
      }
    });
    _saveFile();
    print("save");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Lista de Tarefas",
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 1, 10, 1),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _novaTarefaController,
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _toDoList.insert(0, {"title" : _novaTarefaController.text, "ok": false});
                        _novaTarefaController.text = "";
                        _saveFile();
                        print("Save");
                      });
                    },
                    icon: Icon(Icons.add_circle),
                    color: Colors.blue,
                    iconSize: 50,
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refresh();
                  setState(() {});
                },
                child: ListView.builder(
                  itemCount: _toDoList.length,
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(), //Identificador de cada elemento da lista
                      child: _createList(index), //Widget filho padrão, chamando a função
                      direction: DismissDirection.startToEnd, //Direção do deslizamento
                      onDismissed: (direction){
                        _elementRemoved = _toDoList.removeAt(index);
                        _indexRemoved = index;

                        //Exibindo o snackBar
                        ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove a SnackBar atual
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text( "Terefa \"${_elementRemoved["title"]}\" removida!",
                            style: TextStyle(
                                fontSize: 15
                            ),
                          ),
                          action: SnackBarAction(
                            label: "Desfazer",
                            onPressed: (){
                              setState(() {
                                _toDoList.insert(_indexRemoved, _elementRemoved);
                              });
                            },
                          ),
                        )
                        );

                        _saveFile();
                        print("Save");
                      },
                      background: Container( // Widget que aparecerá por trás ao deslizar na lista
                        color: Colors.red,
                        child: Align(
                          alignment: Alignment(-0.95,0),
                          child: Icon(Icons.delete, color: Colors.white,),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
