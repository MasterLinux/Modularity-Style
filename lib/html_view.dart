part of modularity.ui;

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
  void setup() {
    _htmlElement = createHtmlElement();
    super.setup();

    setupHtmlElement(_htmlElement);
  }
}

class TextChangedEventArgs implements EventArgs {
  String text;

  TextChangedEventArgs(this.text);
}


/// View representation of an [InputElement]
class InputElementView extends HtmlElementView<html.InputElement> {
  StreamSubscription<html.Event> _onTextChangedSubscription;

  InputElementView({ViewModel viewModel, List<ViewBinding> bindings}) : super(viewModel: viewModel, bindings: bindings);

  // events
  static const String onTextChangedEvent = "onTextChanged";

  // attributes
  static const String textAttribute = "text";

  @override
  html.InputElement createHtmlElement() => new html.InputElement();

  @override
  void setupHtmlElement(html.InputElement element) {
    _onTextChangedSubscription = element.onInput.listen((event) {
      invokeEventHandler(onTextChangedEvent, this, new TextChangedEventArgs(event.target.value));
    });
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

  /// Sets the [text] of the input element
  set text(String text) => _htmlElement.value = text;

  /// Gets the [text] of the input element
  String get text => _htmlElement.value;
}

class DivElementView extends HtmlElementView<html.DivElement> {

  @override
  html.DivElement createHtmlElement() => new html.DivElement();

  @override
  void setupHtmlElement(html.DivElement element) {
    // does nothing
  }

  @override
  void onPropertyChanged(String name, value) {
    // TODO: implement onPropertyChanged
  }
}
