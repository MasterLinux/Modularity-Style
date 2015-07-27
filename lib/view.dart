part of modularity.ui;

enum ViewBindingType {
  ValueBinding,
  HandlerBinding
}

class ViewBinding {
  final ViewBindingType bindingType;
  final String attributeName;
  final String propertyName;

  ViewBinding(this.bindingType, this.attributeName, this.propertyName);
}

/// Acts as mediator
class ViewBindingResolver {
  final HashMap<String, String> attributeMappings = new HashMap();
  final HashMap<String, String> propertyMappings = new HashMap();
  final HashMap<String, String> handlerMappings = new HashMap();
  final ViewModel viewModel;
  final View view;

  ViewBindingResolver(this.viewModel, this.view);

  void add(ViewBinding binding) {
    switch(binding.bindingType) {
      case ViewBindingType.ValueBinding:
        attributeMappings[binding.attributeName] = binding.propertyName;
        propertyMappings[binding.propertyName] = binding.attributeName;
        break;

      case ViewBindingType.HandlerBinding:
        handlerMappings[binding.attributeName] = binding.propertyName;
        break;
    }
  }

  void invokeEventHandler(String name, View sender, EventArgs args) {
    if (handlerMappings.containsKey(name)) {
      var handlerName = handlerMappings[name];
      viewModel.onEventHandlerInvoked(handlerName, sender, args);

    } else {
      // TODO throw warning
    }
  }

  void notifyPropertyChanged(String propertyName, dynamic value) {
    if (propertyMappings.containsKey(propertyName)) {
      var attributeName = propertyMappings[propertyName];
      view.onPropertyChanged(attributeName, value);

    } else {
      // TODO throw warning
    }
  }

  void notifyAttributeChanged(String attributeName, dynamic value) {
    if (attributeMappings.containsKey(attributeName)) {
      var propertyName = attributeMappings[attributeName];
      viewModel.onAttributeChanged(propertyName, value);

    } else {
      // TODO throw warning
    }
  }
}

abstract class EventArgs {

}

// similar to the state in react.js
abstract class ViewModel {
  ClassLoader<ViewModel> _instance;
  ViewBindingResolver bindingResolver;

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
  void notifyPropertyChanged(String propertyName) {
    var nameSymbol = new Symbol(propertyName);

    if (_instance.hasGetter(nameSymbol)) {
      var value = _instance.getter[nameSymbol].get();

      if (bindingResolver != null) {
        bindingResolver.notifyPropertyChanged(propertyName, value);
      } else {
        // TODO throw warning, binding resolver not found
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
}

/// Represents a view
abstract class View {
  final List<View> subviews = new List<View>();
  ViewBindingResolver bindingResolver;

  ClassLoader<View> _instance;
  String _id;

  static const String defaultLibrary = "modularity.core.view";

  /// Initializes the view with a [ViewModel] and a list of [ViewBinding]s
  View() {
    _instance = new ClassLoader<View>.fromInstance(this);
    _id = new UniqueId("mod_view").build();
    setup();
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
    if (bindingResolver != null) {
      bindingResolver.notifyAttributeChanged(name, value);
    } else {
      // TODO throw warning, binding resolver not found
    }
  }
    //TODO _instance.load()

  /// Handler which is invoked whenever a specific property in view model is changed
  void onPropertyChanged(String name, dynamic value) {
    var nameSymbol = new Symbol(name);

    if (_instance.hasSetter(nameSymbol)) {
      _instance.setter[nameSymbol].set(value);
    }

    // notify children
    for (var subview in subviews) {
      subview.onPropertyChanged(name, value);
    }
  }

  //TODO update children/subviews, too

  /// Invokes a specific event handler
  void invokeEventHandler(String handlerName, View sender, EventArgs args) {
    if (bindingResolver != null) {
      bindingResolver.invokeEventHandler(handlerName, sender, args);
    } else {
      // TODO throw warning, binding resolver not found
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