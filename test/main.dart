library modularity.tests;

import 'package:scheduled_test/scheduled_test.dart';
import 'package:unittest/html_config.dart';

import 'package:modularity_ui/modularity_ui.dart';
import 'package:class_loader/class_loader.dart';
import 'dart:async';
import 'dart:html' as html;

part 'view_binding_resolver_test.dart';

/**
 * Executes all tests of the
 * library.
 */
void main() {
  useHtmlConfiguration();

  new ViewBindingResolverTest().run();

  /*
  var parser = new ViewParser().parse(null, '''
    <?xml version="1.0" encoding="utf-8"?>
    <template
        xmlns:custom="modularity.ui"
        data-context="viewModelName">

        <custom:list items="#{@collectionName}">
            <template>
                <list-item
                        type="file"
                        title="#{.modelPropertyName?:defaultValue}"
                        on-click="#{@functionName()}"/>
            </template>
        </list>
    </template>
  ''');  */
}
