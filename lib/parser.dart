part of modularity.ui;

// TODO Rename to TemplateParser
class ViewParser {
  static const String defaultNamespace = "modularity.ui";
  static const String xmlns = "xmlns";
  static const String templateNodeName = "template";
  static const String dataContextAttrName = "data-context";

  Future<View> parse(ViewModel viewModel, String xmlString) async {
    var document = xml.parse(xmlString);
    return await _parse(document.firstChild);
  }

  Future<View> _parse(xml.XmlNode node, {Map<String, String> namespaces, View parent}) async {
    namespaces = namespaces != null ? namespaces : <String, String>{};
    var view = null;

    if (node.nodeType == xml.XmlNodeType.ELEMENT) {
      var name = (node as xml.XmlNamed).name;

      if (name.local != templateNodeName) {
        var prefix = name.prefix;
        var namespace = prefix != null && namespaces.containsKey(prefix) ? namespaces[prefix] : defaultNamespace;

        //TODO add bindings?
        view = await View.createView(name.local, libraryName: namespace);

        if(parent != null) {
          parent.subviews.add(view);
        }

        print("namespace: ${namespace} - name: ${name}");

        // parse children
        node.children
          .where((child) => child.nodeType == xml.XmlNodeType.ELEMENT)
          .forEach((child) async => await _parse(child, namespaces: namespaces, parent: view));
      }

      // process <template /> node
      else {
        node.attributes.forEach((attribute) {
          var name = attribute.name;

          // register new namespaces
          if (name.prefix == xmlns) {
            namespaces[attribute.name.local] = attribute.value;
          }

          // get data context
          else if (name.local == dataContextAttrName) {
            // TODO get property from view model as context
            print("data-context: ${attribute.value}");
          }
        });

        // parse children
        node.children
          .where((child) => child.nodeType == xml.XmlNodeType.ELEMENT)
          .forEach((child) async => await _parse(child, namespaces: namespaces, parent: parent));
      }
    }

    return view;
  }

  bool _isAttributeWithName(xml.XmlAttribute attribute, String expectedName) {
    return attribute.name == new xml.XmlName(expectedName);
  }
}