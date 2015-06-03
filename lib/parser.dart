part of modularity.ui;

class ViewParser {
  static const String namespaceAttributeName = "namespace";
  static const String defaultNamespace = "modularity.ui";

  View parse(ViewModel viewModel, String xmlString) {
    var template = xml.parse(xmlString);
    String parentNamespace = null;
    View view = null;

    // iterate through each element
    template.descendants
        .where((node) => node.nodeType == xml.XmlNodeType.ELEMENT)
        .forEach((node) {
          var name = node.name.local;
          var namespaceAttribute = node.attributes
              .firstWhere((attribute) => _isAttributeWithName(attribute, namespaceAttributeName), orElse: () => null);

          if(namespaceAttribute != null) {
            parentNamespace = namespaceAttribute.value;
          } else if(parentNamespace == null) {
            parentNamespace = defaultNamespace;
          }

          print(name);
          print(parentNamespace);

        }
    );

    return view;
  }

  bool _isAttributeWithName(xml.XmlAttribute attribute, String expectedName) {
    return attribute.name == new xml.XmlName(expectedName);
  }
}