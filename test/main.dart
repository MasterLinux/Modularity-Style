library modularity.tests;

import 'package:scheduled_test/scheduled_test.dart' as test;
import 'package:unittest/html_config.dart';

import 'package:modularity_ui/modularity_ui.dart';

/**
 * Executes all tests of the
 * library.
 */
void main() {
  useHtmlConfiguration();

  var parser = new ViewParser().parse(null, '''
    <?xml version="1.0" ?>
    <template dataContext="viewModelName">
        <list namespace="test.namespace" items="#{@collectionName}">
            <template>
                <list-item
                        type="file"
                        title="#{.modelPropertyName?:defaultValue}"
                        on-click="#{@functionName()}"/>
            </template>
        </list>
    </template>
  ''');
}
