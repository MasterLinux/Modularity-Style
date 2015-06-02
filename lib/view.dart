library modularity.ui;

import 'dart:html' as html;
import 'dart:async' show StreamSubscription, Future;

import 'package:class_loader/class_loader.dart';

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
}

/// Converts a [ViewTemplateModel] to a [View]
class ViewConverter implements Converter<ViewTemplateModel, Future<View>> {
  final ViewModel viewModel;

  ViewConverter({this.viewModel});

  Future<View> convert(ViewTemplateModel value) async {
    var bindings = new List<ViewBinding>();
    var subviews = new List<View>();

    if (value.subviews != null) {
      for (var subview in value.subviews) {
        subviews.add(await convert(subview));
      }
    }

    if (value.attributes != null) {
      for (var attribute in value.attributes) {
        bindings.add(new ViewBinding(
            ViewBindingType.ATTRIBUTE,
            attribute.attributeName,
            attribute.propertyName,
            defaultValue: attribute.defaultValue
        ));
      }
    }

    if (value.events != null) {
      for (var event in value.events) {
        bindings.add(new ViewBinding(
            ViewBindingType.EVENT_HANDLER,
            event.attributeName,
            event.propertyName
        ));
      }
    }

    return await View.createView(
        value.type,
        libraryName: value.lib != null ? value.lib : View.defaultLibrary,
        viewModel: viewModel,
        bindings: bindings,
        subviews: subviews
    );
  }

  ViewTemplateModel convertBack(Future<View> value) {
    throw new UnimplementedError();
  }
}

// similar to the state in react.js
abstract class ViewModel {
  ClassLoader<ViewModel> _instance;
  List<View> _views = new List<View>();

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
  final Map<String, String> _eventHandlerBindings = new Map<String, String>();
  final Map<String, String> _attributeBindings = new Map<String, String>();
  final Map<String, String> _propertyBindings = new Map<String, String>();
  final List<View> subviews = new List<View>();
  final ViewModel viewModel;
  String _id;

  static const String defaultLibrary = "modularity.core.view";

  /// Initializes the view with a [ViewModel] and a list of [ViewBinding]s
  View({this.viewModel, List<ViewBinding> bindings}) {
    _id = new utility.UniqueId("mod_view").build();
    setup(bindings);

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

  /// Setups the view. Can be overridden to add event handler, etc.
  void setup(List<ViewBinding> bindings) {
    //map attributes to view model
    if (bindings != null) {
      for (var binding in bindings) {
        addBinding(binding);
      }
    }
  }

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
  void onPropertyChanged(String name, dynamic value); //TODO update children/subviews, too

  /// Invokes a specific event handler
  void invokeEventHandler(String name, View sender, EventArgs args) {
    if (viewModel != null) {
      viewModel.onEventHandlerInvoked(_eventHandlerBindings[name], sender, args);
    }
  }

/*
  /// Checks whether a specific attribute binding exists
  bool hasAttribute(String name) => _attributeBindings.containsKey(name);

  /// Checks whether a specific event handler binding exists
  bool hasEventHandler(String name) => _eventHandlerBindings.containsKey(name);

  /// Invokes a specific event handler
  void invokeEventHandler(String name, View sender, EventArgs args) {
    viewModel.invokeEventHandler(_eventHandlerBindings[name], sender, args);
  }

  /// Notifies the view that a specific property in view model is changed
  void notifyPropertyChanged(String propertyName, dynamic value) {
    var attributeName = _propertyBindings.containsKey(propertyName) ? _propertyBindings[propertyName] : null;

    if (attributeName != null) {
      onAttributeChanged(attributeName, value);
    }
  }

  /// Handler which is invoked whenever a specific property in view model is changed
  void onAttributeChanged(String name, dynamic value) {
  }

  /// Adds a new view binding
  void addBinding(ViewBinding binding) {
    // TODO allow multiple bindings
    if (viewModel != null) {
      switch (binding.type) {
        case ViewBindingType.ATTRIBUTE:
          _addAttributeBinding(binding.attributeName, binding.propertyName, binding.defaultValue);
          break;
        case ViewBindingType.EVENT_HANDLER:
          _addEventHandlerBinding(binding.attributeName, binding.propertyName);
          break;
      }
    } else {
      // TODO log error viewModel is null
    }
  }

  void _addEventHandlerBinding(String attributeName, String propertyName) {
    if (viewModel.containsEventHandler(propertyName)) {
      if (!_eventHandlerBindings.containsKey(attributeName)) {
        _eventHandlerBindings[attributeName] = propertyName;
      } else {
        //TODO log error. binding already exists
      }
    } else {
      //TODO event handler is missing
    }
  }

  void _addAttributeBinding(String attributeName, String propertyName, dynamic defaultValue) {
    if (viewModel.containsProperty(propertyName)) {
      if (!_attributeBindings.containsKey(attributeName) && !_propertyBindings.containsKey(propertyName)) {
        _attributeBindings[attributeName] = propertyName;
        _propertyBindings[propertyName] = attributeName;

        if (defaultValue != null) {
          viewModel.updateProperty(propertyName, defaultValue);
          //onAttributeChanged(attributeName, defaultValue);
        }
      } else {
        //TODO log error. binding already exists
      }
    } else {
      //TODO attribute is missing
    }
  } */
}

/// A view implementation used to create views using a [HtmlElement]
abstract class HtmlElementView<TElement extends html.HtmlElement> extends View {
  TElement _htmlElement;

  HtmlElementView({ViewModel viewModel, List<ViewBinding> bindings}) : super(viewModel: viewModel, bindings: bindings);

  @override
  Future<TElement> toHtml() async => _htmlElement;

  /// Method used to create the HTML element
  /// which represents this view
  TElement createHtmlElement();

  /// Method used to setup the HTML element like adding event handler, etc.
  void setupHtmlElement(TElement element);

  @override
  Future<View> render() async {
    return this;
  }

  @override
  void setup(List<ViewBinding> bindings) {
    _htmlElement = createHtmlElement();

    super.setup(bindings);
    setupHtmlElement(_htmlElement);
  }
}

class TextChangedEventArgs implements EventArgs {
  String text;

  TextChangedEventArgs(this.text);
}

///
///
class TextInput extends HtmlElementView<html.InputElement> {
  StreamSubscription<html.Event> _onTextChangedSubscription;

  TextInput({ViewModel viewModel, List<ViewBinding> bindings}) : super(viewModel: viewModel, bindings: bindings);

  // events
  static const String onTextChangedEvent = "onTextChanged";

  // attributes
  static const String textAttribute = "text";

  @override
  html.InputElement createHtmlElement() {
    return new html.InputElement();
  }

  @override
  void setupHtmlElement(html.InputElement element) {
    if (hasEventHandler(onTextChangedEvent)) {
      _onTextChangedSubscription = element.onInput.listen((event) {
        invokeEventHandler(onTextChangedEvent, this, new TextChangedEventArgs(event.target.value));
      });
    }
  }

  @override
  void cleanup() {
    super.cleanup();

    if (_onTextChangedSubscription != null) {
      _onTextChangedSubscription.cancel();
      _onTextChangedSubscription = null;
    }
  }

  @override
  void onPropertyChanged(String name, dynamic value) {
    switch (name) {
      case textAttribute:
        text = value as String;
        break;
    }
  }

  set text(String text) => _htmlElement.value = text;

  String get text => _htmlElement.value;
}

class ContentView extends HtmlElementView<html.DivElement> {

  @override
  html.DivElement createHtmlElement() => new html.DivElement();

  @override
  void setupHtmlElement(html.DivElement element) {
    // does nothing
  }
}

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
}

//TODO add ListView, FileTree, GridView, Button, TextView, Search