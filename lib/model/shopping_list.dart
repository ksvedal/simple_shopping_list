class ShoppingList {
  String name;
  List<Item> items = [];

  ShoppingList(this.name);

  ShoppingList.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        items = (json['items'] as List<dynamic>)
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList();

  Map<String, dynamic> toJson() => {
        'name': name,
        'items': items,
      };
}

class Item {
  String name;
  bool isDone;

  Item(this.name, this.isDone);

  Item.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isDone = json['isDone'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'isDone': isDone,
      };
}
