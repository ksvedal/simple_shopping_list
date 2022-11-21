import 'package:flutter/material.dart';
import 'package:simple_shopping_list/model/shopping_list.dart';
import 'package:simple_shopping_list/manager/file_handler.dart';

List<ShoppingList> toDoLists = [];
int currentListIndex = 0;
String currentListName = "P";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController tabController =
      TabController(length: 0, vsync: this, initialIndex: 0);

  late TabBar bar;

  FileHandler fileHandler = FileHandler();

  final taskInputController = TextEditingController();
  final newListInputController = TextEditingController();

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fileHandler.readLists().then((value) {
      setState(() {
        toDoLists = value;
        tabController = TabController(
            length: toDoLists.length,
            vsync: this,
            initialIndex: currentListIndex);
      });
    });
  }

  sortList() {
    setState(() {
      toDoLists[currentListIndex].items.sort((a, _) {
        return a.isDone ? 1 : -1;
      });
    });
    fileHandler.writeList(toDoLists[currentListIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0), // here the desired height
          child: AppBar(
              // ...
              )),
      backgroundColor: const Color.fromARGB(255, 225, 225, 225),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              children: [
                if (toDoLists.isNotEmpty) ...[
                  for (ShoppingList shoppingList in toDoLists) ...[
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color.fromARGB(255, 243, 243, 243),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.transparent, spreadRadius: 1),
                          ],
                        ),
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 10),
                        height: 10,
                        width: 150,
                        child: ListTile(
                            title: Text(shoppingList.name),
                            onTap: () {
                              setState(() {
                                currentListIndex =
                                    toDoLists.indexOf(shoppingList);
                              });
                              currentListName =
                                  toDoLists[currentListIndex].name;
                            }))
                  ]
                ],
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.transparent, spreadRadius: 1),
                      ],
                    ),
                    margin:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    height: 10,
                    width: 150,
                    child: ListTile(
                      title: const Text("+"),
                      onTap: newListDialog,
                    )),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            alignment: Alignment.bottomLeft,
            child: Row(children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  currentListName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: deleteListDialog,
                    child: const Icon(Icons.delete),
                  ),
                ),
              ),
            ]),
          ),

          // List of items in todolist
          Flexible(
            child: ListView(
              children: [
                if (toDoLists.isNotEmpty) ...[
                  for (Item item in toDoLists[currentListIndex].items) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromARGB(255, 236, 236, 236),
                        boxShadow: const [
                          BoxShadow(color: Colors.transparent, spreadRadius: 1),
                        ],
                      ),
                      margin: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      child: ListTile(
                        title: Text(item.name, style: textStyle(item)),
                        onTap: () {
                          setState(() {
                            item.isDone = !item.isDone;
                            sortList();
                          });
                        },
                      ),
                    ),
                  ]
                ] else ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 100),
                      child: const Text("No Lists",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey)),
                    ),
                  )
                ]
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 40),
            child: Row(
              children: <Widget>[
                if (toDoLists.isNotEmpty) ...[
                  Expanded(
                      child: TextField(
                    controller: taskInputController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter a task',
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        if (taskInputController.text.isNotEmpty) {
                          toDoLists[currentListIndex]
                              .items
                              .add(Item(taskInputController.text, false));
                          taskInputController.clear();
                          sortList();
                        }
                      });
                      focusNode.requestFocus();
                    },
                  )),

                  //square add button matchin textfield on the left
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (taskInputController.text.isNotEmpty) {
                            toDoLists[currentListIndex]
                                .items
                                .add(Item(taskInputController.text, false));
                            taskInputController.clear();
                            sortList();
                          }
                        });
                        focusNode.requestFocus();
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle textStyle(Item item) {
    if (item.isDone) {
      return const TextStyle(
        decoration: TextDecoration.lineThrough,
        color: Colors.grey,
        decorationColor: Colors.grey,
        decorationThickness: 2,
        fontSize: 20,
      );
    } else {
      return const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      );
    }
  }

//dialog for deleting list
  void deleteListDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete List"),
            content: const Text("Are you sure you want to delete this list?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    fileHandler
                        .deleteFile(toDoLists.elementAt(currentListIndex).name);
                    toDoLists.removeAt(currentListIndex);
                    tabController = TabController(
                        length: toDoLists.length + 1,
                        vsync: this,
                        initialIndex: currentListIndex);
                    currentListIndex = toDoLists.length - 1;
                    currentListName = toDoLists[currentListIndex].name;
                  });
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              ),
            ],
          );
        });
  }

//dialog for adding new list
  void newListDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("New List"),
            content: TextField(
              controller: newListInputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a name for the list',
              ),
              //ad list when submitted
              onSubmitted: (value) {
                newList();
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  newList();
                },
                child: const Text("Add"),
              ),
            ],
          );
        });
  }

  newList() {
    if (newListInputController.text != "" &&
        toDoLists
            .where((element) => element.name == newListInputController.text)
            .isEmpty) {
      setState(() {
        toDoLists.add(ShoppingList(newListInputController.text));
        currentListIndex = toDoLists.length - 1;
        currentListName = toDoLists[currentListIndex].name;
        tabController = TabController(
            length: toDoLists.length,
            vsync: this,
            initialIndex: currentListIndex);
      });
      fileHandler.writeList(toDoLists[currentListIndex]);
      Navigator.pop(context);
      newListInputController.clear();
    } else {
      Navigator.pop(context);
      listExistDialog();
    }
  }

  listExistDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Oops"),
            content: const Text("A list with that name already exists!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Understandable"),
              ),
            ],
          );
        });
  }
}
