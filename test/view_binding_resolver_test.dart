part of modularity.tests;

class MockView implements View {
  List<View> subviews;
  ViewBindingResolver bindingResolver;
  ClassLoader<View> _instance;
  String defaultLibrary;
  String _id;

  MockView(this.bindingResolver);

  Future<View> createView(String viewType, {String libraryName, ViewBindingResolver bindingResolver, List<View> subviews}) {
    throw new UnimplementedError();
  }

  void setup() {
    throw new UnimplementedError();
  }

  void cleanup() {
    throw new UnimplementedError();
  }

  Future<View> render() {
    throw new UnimplementedError();
  }

  Future<html.HtmlElement> toHtml() {
    throw new UnimplementedError();
  }

  Future addToDOM(String parentId) {
    throw new UnimplementedError();
  }

  Future removeFromDOM() {
    throw new UnimplementedError();
  }

  void notifyAttributeChanged(String name, dynamic value) {

  }

  void onPropertyChanged(String name, dynamic value) {

  }

  void invokeEventHandler(String handlerName, View sender, EventArgs args) {

  }

  String get id => _id;
}

class ViewBindingResolverTest {

  void run() {
    test('application should use defaults if application info is not valid', () {
      var resolverUnderTest = new ViewBindingResolver();
      var mockView = new MockView(resolverUnderTest);

      expect(resolverUnderTest, isNotNull);

      test.expect(appUnderTest.name, Application.defaultName);
      test.expect(appUnderTest.startUri, test.isNull);
      test.expect(appUnderTest.language, Application.defaultLanguage);
      test.expect(appUnderTest.version, Application.defaultVersion);

      test.expect(appUnderTest.info.name, Application.defaultName);
      test.expect(appUnderTest.info.startUri, test.isNull);
      test.expect(appUnderTest.info.language, Application.defaultLanguage);
      test.expect(appUnderTest.info.version, Application.defaultVersion);

      test.expect(appUnderTest.resources, test.isEmpty);
      test.expect(appUnderTest.pages, test.isEmpty);
      test.expect(appUnderTest.tasks, test.isEmpty);
      test.expect(appUnderTest.logger, test.isNull);
      test.expect(appUnderTest.navigator, test.isNotNull);
    });
  }

}