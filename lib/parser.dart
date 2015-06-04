part of modularity.ui;

class ViewParser {
  static const String xmlns = "xmlns";
  static const String defaultNamespace = "modularity.ui";

  View parse(ViewModel viewModel, String xmlString) {
    var template = xml.parse(xmlString);
    var namespaces = <String, String>{};
    View view = null;

    // iterate through each element
    template.descendants
        .where((node) => node.nodeType == xml.XmlNodeType.ELEMENT)
        .forEach((node) {
          var name = node.name;

          // register namespaces
          node.attributes
              .where((attribute) => attribute.name.prefix == xmlns)
              .forEach((attribute) => namespaces[attribute.name.local] = attribute.value);

          // get view namespace
          var namespace = name.prefix != null && namespaces.containsKey(name.prefix) ? namespaces[name.prefix] : defaultNamespace;

          print(name.local);
          print(namespace);
        }
    );

    return view;
  }

  bool _isAttributeWithName(xml.XmlAttribute attribute, String expectedName) {
    return attribute.name == new xml.XmlName(expectedName);
  }
}