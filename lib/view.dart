part of modularity.ui;

/*
enum ViewBindingType {
  EVENT_HANDLER,
  ATTRIBUTE
}

class ViewBinding {
  final ViewBindingType type;
  final String attributeName;
  final String propertyName;
  final dynamic defaultValue;

  ViewBinding(this.type, this.attributeName, this.propertyName, {this.defaultValue});
} */


abstract class ViewBindingCollection {

}

abstract class EventArgs {

}

// similar to the state in react.js
abstract class ViewModel {
  List<View> _views = new List<View>();
  ClassLoader<ViewModel> _instance;

  /// Initializes the view model
  ViewModel() {
    _instance = new ClassLoader<ViewModel>.fromInstance(this);
  }

  /// Notifies the view that a specific property in this view model is changed
  /// Must be called to update the user interface
  ///
  /// Example:
  ///     // implement setter which notifies the view on update
  ///     set specificProperty(String val) {
  ///       _specificProperty = val;
  ///       notifyPropertyChanged("specificProperty");
  ///     }
  ///
  ///     // implement getter which is required to get
  ///     // the value for updating the view
  ///     String get specificProperty => _specificProperty;
  ///
  void notifyPropertyChanged(String name) {
    var nameSymbol = new Symbol(name);

    if (_instance.hasGetter(nameSymbol)) {
      var value = _instance.getter[nameSymbol].get();

      for (var view in _views) {
        view.onPropertyChanged(name, value);
      }
    } else {
      // TODO throw warning, getter not found
    }
  }

  /// Handler which is invoked whenever a specific view attribute is changed
  void onAttributeChanged(String name, dynamic value) {
    var nameSymbol = new Symbol(name);

    if (_instance.hasSetter(nameSymbol)) {
      _instance.setter[nameSymbol].set(value);
    } else {
      // TODO throw warning, setter not found
    }
  }

  /// Handler which is invoked whenever the view throws an event
  void onEventHandlerInvoked(String name, View sender, EventArgs args) {
    var nameSymbol = new Symbol(name);

    if (_instance.hasMethod(nameSymbol)) {
      _instance.methods[nameSymbol].invoke([sender, args]);
    } else {
      // TODO throw warning, method not found
    }
  }

  /// Subscribes a view as observer so it is able to listen for attribute changes
  void subscribe(View view) {
    if (!_views.contains(view)) {
      _views.add(view);
    }
  }

  /// Unsubscribes a specific view from listening
  void unsubscribe(View view) {
    if (_views.contains(view)) {
      _views.remove(view);
    }
  }
}

/// Represents a view
abstract class View {
  final List<View> subviews = new List<View>();
  final ViewModel viewModel;

  ClassLoader<View> _instance;
  String _id;

  static const String defaultLibrary = "modularity.core.view";

  /// Initializes the view with a [ViewModel] and a list of [ViewBinding]s
  View({this.viewModel, List<ViewBinding> bindings}) {
    _instance = new ClassLoader<View>.fromInstance(this);
    _id = new UniqueId("mod_view").build();
    setup();

    if (viewModel != null) {
      viewModel.subscribe(this);
    }
  }

  /// Loads a view by its [viewType]
  static Future<View> createView(String viewType, {String libraryName: View.defaultLibrary, List<ViewBinding> bindings, ViewModel viewModel, List<View> subviews}) async {
    var viewLoader = new ClassLoader<View>(new Symbol(libraryName), new Symbol(viewType), const Symbol(""), [], {
      #viewModel: viewModel,
      #bindings: bindings
    });

    await viewLoader.load();
    return viewLoader.instance;
  }

  /// Setups the view. Used
  /// to add event handler, etc.
  void setup();

  /// Cleanup function which is used to remove events [StreamSubscription], etc.
  /// before the view is removed from DOM
  void cleanup() {
    viewModel.unsubscribe(this);

    for (var subview in subviews) {
      subview.cleanup();
    }
  }

  /// Gets the ID of the view
  String get id => _id;

  /// TODO comment
  Future<View> render();

  /// Converts the view to an HTML element
  Future<html.HtmlElement> toHtml() async {
    return (await render()).toHtml();
  }

  /// Adds the view to DOM
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

  /// Removes the view from DOM
  Future removeFromDOM() async {
    cleanup();

    var node = html.document.querySelector("#${id}");

    if (node != null) {
      node.remove();
    } else {
      // TODO log warning -> node already removed from DOM
    }
  }

  /// Notifies the view model that a specific view attribute is changed
  void notifyAttributeChanged(String name, dynamic value) {
    if (viewModel != null) {
      viewModel.onAttributeChanged(name, value);
    }
  }

  /// Handler which is invoked whenever a specific property in view model is changed
  void onPropertyChanged(String name, dynamic value) {
    //TODO _instance.load()

    //resolve property name
    var names = _mappings.properties[name].attributeNames;

    for (var name in names) {
      var nameSymbol = new Symbol(name);

      if (_instance.hasSetter(nameSymbol)) {
        _instance.setter[nameSymbol].set(value);
      }
    }

    // notify children
    for (var subview in subviews) {
      subview.onPropertyChanged(name, value);
    }
  }

  //TODO update children/subviews, too

  /// Invokes a specific event handler
  void invokeEventHandler(String name, View sender, EventArgs args) {
    if (viewModel != null) {
      viewModel.onEventHandlerInvoked(_eventHandlerBindings[name], sender, args);
    }
  }
}


/*

class TestView extends View {
  //TODO remove

  TestView({ViewModel viewModel, List<ViewBinding> bindings}) :
  super(viewModel: viewModel, bindings: bindings);

  @override
  Future<View> render() async {
    return await View.createView("TextInput", viewModel: viewModel, bindings: [
      new ViewBinding(ViewBindingType.EVENT_HANDLER, TextInput.onTextChangedEvent, "testFunc"),
      new ViewBinding(ViewBindingType.ATTRIBUTE, TextInput.textAttribute, "title")
    ]);
  }
}  */

//TODO add ListView, FileTree, GridView, Button, TextView, Search