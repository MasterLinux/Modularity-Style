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
  void setup(List<ViewBinding> bindings) {
    _htmlElement = createHtmlElement();

    super.setup(bindings);
    setupHtmlElement(_htmlElement);
  }
}