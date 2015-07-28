part of modularity.ui;

abstract class UIComponent<TElement extends html.HtmlElement> {
  final List<UIComponent> children = new List<UIComponent>();

  /// Gets the [id] of the [UIComponent]
  final String id;

  /// Initializes the [UIComponent] with an [id]
  UIComponent(this.id);

  /// Setups the [UIComponent]. Could be used
  /// to register event handler
  void setup(TElement element);

  /// Cleanup function which is used to remove event handler
  /// before the [UIComponent] is removed from DOM
  void cleanup() {
    for (var child in children) {
      child.cleanup();
    }
  }

  /// Gets the [HtmlElement] which represents the [UIComponent]
  Future<TElement> render();

  /// Converts the view to an HTML element
  Future<TElement> toHtml() async {
    var element = await render();
    setup(element);

    for (var child in children) {
      var childElement = await child.toHtml();
      element.children.add(childElement);
    }

    return element;
  }

  /// Adds the [UIComponent] to DOM
  Future addToDOM(String parentId) async {
    var parentNode = html.document.querySelector("#${parentId}");
    var element = (await toHtml())
      ..id = id;

    if (parentNode != null) {
      parentNode.nodes.add(element);
    } else {
      // TODO log node with ID is missing error
    }
  }

  /// Removes the [UIComponent] from DOM
  Future removeFromDOM() async {
    cleanup();

    var node = html.document.querySelector("#${id}");

    if (node != null) {
      node.remove();
    }
  }
}

// TODO rename to View
class SimpleView extends UIComponent<html.DivElement> {

  SimpleView(String id) : super(id);



  @override
  Future<html.DivElement> render() async {
    return await new html.DivElement();
  }

  @override
  void setup(element) {
    // TODO: implement setup
  }
}