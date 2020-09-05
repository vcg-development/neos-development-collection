@fixtures
# Note: For the routing tests to work we rely on Configuration/Testing/Behat/NodeTypes.Test.Routing.yaml
Feature: Routing behavior of shortcut nodes

  Background:
    Given I have no content dimensions
    And the command CreateRootWorkspace is executed with payload:
      | Key                        | Value           |
      | workspaceName              | "live"          |
      | newContentStreamIdentifier | "cs-identifier" |
    And the event RootNodeAggregateWithNodeWasCreated was published with payload:
      | Key                         | Value                        |
      | contentStreamIdentifier     | "cs-identifier"              |
      | nodeAggregateIdentifier     | "lady-eleonode-rootford"     |
      | nodeTypeName                | "Neos.Neos:Sites"            |
      | coveredDimensionSpacePoints | [{}]                         |
      | initiatingUserIdentifier    | "initiating-user-identifier" |
      | nodeAggregateClassification | "root"                       |
    And the graph projection is fully up to date

    # lady-eleonode-rootford
    #   shernode-homes
    #      sir-david-nodenborough
    #        shortcuts
    #          shortcut-first-child-node
    #            first-child-node
    #            second-child-node
    #          shortcut-parent-node
    #          shortcut-selected-node
    #          shortcut-external-url
    #      sir-david-nodenborough-ii
    #        sir-nodeward-nodington-iii
    #
    # NOTE: The "nodeName" column only exists because it's currently not possible to create unnamed nodes (see https://github.com/neos/contentrepository-development-collection/pull/162)
    And the following CreateNodeAggregateWithNode commands are executed for content stream "cs-identifier" and origin "{}":
      | nodeAggregateIdentifier    | parentNodeAggregateIdentifier | nodeTypeName                                       | initialPropertyValues                                                                                                       | nodeName |
      | shernode-homes             | lady-eleonode-rootford        | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "ignore-me"}                                                                                             | node1    |
      | sir-david-nodenborough     | shernode-homes                | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "david-nodenborough"}                                                                                    | node2    |
      | shortcuts                  | sir-david-nodenborough        | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "shortcuts"}                                                                                             | node3    |
      | shortcut-first-child-node  | shortcuts                     | Neos.Neos:Shortcut                                 | {"uriPathSegment": "shortcut-first-child"}                                                                                  | node4    |
      | first-child-node           | shortcut-first-child-node     | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "first-child-node"}                                                                                      | node5    |
      | second-child-node          | shortcut-first-child-node     | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "second-child-node"}                                                                                     | node6    |
      | shortcut-parent-node       | shortcuts                     | Neos.Neos:Shortcut                                 | {"uriPathSegment": "shortcut-parent-node", "targetMode": "parentNode"}                                                      | node7    |
      | shortcut-selected-node     | shortcuts                     | Neos.Neos:Shortcut                                 | {"uriPathSegment": "shortcut-selected-node", "targetMode": "selectedTarget", "target": "node://sir-nodeward-nodington-iii"} | node8    |
      | shortcut-external-url      | shortcuts                     | Neos.Neos:Shortcut                                 | {"uriPathSegment": "shortcut-external-url", "targetMode": "selectedTarget", "target": "https://neos.io"}                    | node9    |
      | sir-david-nodenborough-ii  | shernode-homes                | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "david-nodenborough-2"}                                                                                  | node10   |
      | sir-nodeward-nodington-iii | sir-david-nodenborough-ii     | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "nodeward-3"}                                                                                            | node11   |
    And A site exists for node name "node1"
    And The documenturipath projection is up to date

  Scenario: Shortcut parent node
    When I am on URL "/"
    Then the node "shortcut-parent-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts.html"

  Scenario: Shortcut selected target node
    When I am on URL "/"
    Then the node "shortcut-selected-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough-2/nodeward-3.html"

  Scenario: Shortcut selected target URL
    When I am on URL "/"
    Then the node "shortcut-external-url" in content stream "cs-identifier" and dimension "{}" should resolve to URL "https://neos.io/"

  Scenario: Shortcut first child node
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/first-child-node.html"

  Scenario: Shortcut first child node is updated when a new first child node aggregate is created
    When the command CreateNodeAggregateWithNode is executed with payload:
      | Key                                      | Value                                                |
      | contentStreamIdentifier                  | "cs-identifier"                                      |
      | nodeAggregateIdentifier                  | "nody-mc-newface"                                    |
      | nodeTypeName                             | "Neos.EventSourcedNeosAdjustments:Test.Routing.Page" |
      | originDimensionSpacePoint                | {}                                                   |
      | parentNodeAggregateIdentifier            | "shortcut-first-child-node"                          |
      | initialPropertyValues                    | {"uriPathSegment": "new-child-node"}                 |
      | succeedingSiblingNodeAggregateIdentifier | "first-child-node"                                   |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/new-child-node.html"

  Scenario: Shortcut first child node is updated when a node aggregate gets moved to be the new first child node
    When the command MoveNodeAggregate is executed with payload:
      | Key                                         | Value                        |
      | contentStreamIdentifier                     | "cs-identifier"              |
      | nodeAggregateIdentifier                     | "sir-nodeward-nodington-iii" |
      | dimensionSpacePoint                         | {}                           |
      | newParentNodeAggregateIdentifier            | "shortcut-first-child-node"  |
      | newSucceedingSiblingNodeAggregateIdentifier | "first-child-node"           |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/nodeward-3.html"

  Scenario: Shortcut first child node is updated when a node aggregate gets moved to be the new first child node on the same leve
    When the command MoveNodeAggregate is executed with payload:
      | Key                                         | Value               |
      | contentStreamIdentifier                     | "cs-identifier"     |
      | nodeAggregateIdentifier                     | "second-child-node" |
      | dimensionSpacePoint                         | {}                  |
      | newParentNodeAggregateIdentifier            | null                |
      | newSucceedingSiblingNodeAggregateIdentifier | "first-child-node"  |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/second-child-node.html"

  Scenario: Shortcut first child node is not updated when a node aggregate gets moved behind an existing first child node
    When the command MoveNodeAggregate is executed with payload:
      | Key                                         | Value                        |
      | contentStreamIdentifier                     | "cs-identifier"              |
      | nodeAggregateIdentifier                     | "sir-nodeward-nodington-iii" |
      | dimensionSpacePoint                         | {}                           |
      | newParentNodeAggregateIdentifier            | "shortcut-first-child-node"  |
      | newSucceedingSiblingNodeAggregateIdentifier | "second-child-node"          |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/first-child-node.html"

  Scenario: Shortcut first child node is not updated when a node aggregate gets moved behind an existing first child node on the same leve
    When the command CreateNodeAggregateWithNode is executed with payload:
      | Key                                      | Value                                                |
      | contentStreamIdentifier                  | "cs-identifier"                                      |
      | nodeAggregateIdentifier                  | "nody-mc-newface"                                    |
      | nodeTypeName                             | "Neos.EventSourcedNeosAdjustments:Test.Routing.Page" |
      | originDimensionSpacePoint                | {}                                                   |
      | parentNodeAggregateIdentifier            | "shortcut-first-child-node"                          |
      | initialPropertyValues                    | {"uriPathSegment": "new-child-node"}                 |
      | succeedingSiblingNodeAggregateIdentifier | "second-child-node"                                  |
    And the graph projection is fully up to date
    And the command MoveNodeAggregate is executed with payload:
      | Key                                         | Value             |
      | contentStreamIdentifier                     | "cs-identifier"   |
      | nodeAggregateIdentifier                     | "nody-mc-newface" |
      | dimensionSpacePoint                         | {}                |
      | newParentNodeAggregateIdentifier            | null              |
      | newSucceedingSiblingNodeAggregateIdentifier | null              |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/first-child-node.html"

  Scenario: Regular document node gets turned into a shortcut node
    When the command ChangeNodeAggregateType was published with payload:
      | Key                     | Value                       |
      | contentStreamIdentifier | "cs-identifier"             |
      | nodeAggregateIdentifier | "sir-david-nodenborough-ii" |
      | newNodeTypeName         | "Neos.Neos:Shortcut"        |
      | strategy                | "happypath"                 |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "sir-david-nodenborough-ii" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough-2/nodeward-3.html"

  Scenario: Shortcut node gets turned into a regular document node
    When the command ChangeNodeAggregateType was published with payload:
      | Key                     | Value                                                |
      | contentStreamIdentifier | "cs-identifier"                                      |
      | nodeAggregateIdentifier | "shortcut-first-child-node"                          |
      | newNodeTypeName         | "Neos.EventSourcedNeosAdjustments:Test.Routing.Page" |
      | strategy                | "happypath"                                          |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child.html"

  Scenario: Change shortcut targetMode from "firstChildNode" to "parentNode"
    When the command "SetNodeProperties" is executed with payload:
      | Key                       | Value                        |
      | contentStreamIdentifier   | "cs-identifier"              |
      | nodeAggregateIdentifier   | "shortcut-first-child-node"  |
      | originDimensionSpacePoint | {}                           |
      | propertyValues            | {"targetMode": "parentNode"} |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts.html"

  Scenario: Change shortcut targetMode from "firstChildNode" to "selectedTarget" (URL)
    When the command "SetNodeProperties" is executed with payload:
      | Key                       | Value                                                            |
      | contentStreamIdentifier   | "cs-identifier"                                                  |
      | nodeAggregateIdentifier   | "shortcut-first-child-node"                                      |
      | originDimensionSpacePoint | {}                                                               |
      | propertyValues            | {"targetMode": "selectedTarget", "target": "http://www.neos.io"} |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "http://www.neos.io/"

  Scenario: Change shortcut targetMode from "parentNode" to "firstChildNode"
    When the following CreateNodeAggregateWithNode commands are executed for content stream "cs-identifier" and origin "{}":
      | nodeAggregateIdentifier | parentNodeAggregateIdentifier | nodeTypeName                                       | initialPropertyValues           | nodeName |
      | new-child-node          | shortcut-parent-node          | Neos.EventSourcedNeosAdjustments:Test.Routing.Page | {"uriPathSegment": "new-child"} | new      |
    When the command "SetNodeProperties" is executed with payload:
      | Key                       | Value                            |
      | contentStreamIdentifier   | "cs-identifier"                  |
      | nodeAggregateIdentifier   | "shortcut-parent-node"           |
      | originDimensionSpacePoint | {}                               |
      | propertyValues            | {"targetMode": "firstChildNode"} |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-parent-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-parent-node/new-child.html"

  Scenario: Change shortcut targetMode from "parentNode" to "selectedTarget" (URL)
    When the command "SetNodeProperties" is executed with payload:
      | Key                       | Value                                                          |
      | contentStreamIdentifier   | "cs-identifier"                                                |
      | nodeAggregateIdentifier   | "shortcut-parent-node"                                         |
      | originDimensionSpacePoint | {}                                                             |
      | propertyValues            | {"targetMode": "selectedTarget", "target": "https://neos.io/"} |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "shortcut-parent-node" in content stream "cs-identifier" and dimension "{}" should resolve to URL "https://neos.io/"

  Scenario: Shortcut node with an invalid targetMode
    Given the command CreateNodeAggregateWithNode is executed with payload and exceptions are caught:
      | Key                           | Value                                                                  |
      | contentStreamIdentifier       | "cs-identifier"                                                        |
      | nodeAggregateIdentifier       | "invalid-target-mode"                                                  |
      | nodeTypeName                  | "Neos.Neos:Shortcut"                                                   |
      | originDimensionSpacePoint     | {}                                                                     |
      | parentNodeAggregateIdentifier | "shortcuts"                                                            |
      | initialPropertyValues         | {"uriPathSegment": "invalid-target-mode", "targetMode": "invalidMode"} |
      | nodeName                      | "some-node-name"                                                       |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "invalid-target-mode" in content stream "cs-identifier" and dimension "{}" should throw an exception

  Scenario: Shortcut node with targetMode "selectedTarget" but without target
    Given the command CreateNodeAggregateWithNode is executed with payload and exceptions are caught:
      | Key                           | Value                                                                        |
      | contentStreamIdentifier       | "cs-identifier"                                                              |
      | nodeAggregateIdentifier       | "invalid-missing-target"                                                     |
      | nodeTypeName                  | "Neos.Neos:Shortcut"                                                         |
      | originDimensionSpacePoint     | {}                                                                           |
      | parentNodeAggregateIdentifier | "shortcuts"                                                                  |
      | initialPropertyValues         | {"uriPathSegment": "invalid-missing-target", "targetMode": "selectedTarget"} |
      | nodeName                      | "some-node-name"                                                             |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "invalid-missing-target" in content stream "cs-identifier" and dimension "{}" should throw an exception

  Scenario: Shortcut node without child nodes and targetMode "firstChildNode"
    Given the command CreateNodeAggregateWithNode is executed with payload and exceptions are caught:
      | Key                           | Value                                                                              |
      | contentStreamIdentifier       | "cs-identifier"                                                                    |
      | nodeAggregateIdentifier       | "invalid-shortcut-first-child-node"                                                |
      | nodeTypeName                  | "Neos.Neos:Shortcut"                                                               |
      | originDimensionSpacePoint     | {}                                                                                 |
      | parentNodeAggregateIdentifier | "shortcuts"                                                                        |
      | initialPropertyValues         | {"uriPathSegment": "invalid-shortcut-first-child", "targetMode": "firstChildNode"} |
      | nodeName                      | "some-node-name"                                                                   |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "invalid-shortcut-first-child-node" in content stream "cs-identifier" and dimension "{}" should throw an exception

  Scenario: Shortcut node with targetMode "selectedTarget" and a non-existing target node
    Given the command CreateNodeAggregateWithNode is executed with payload and exceptions are caught:
      | Key                           | Value                                                                                                                      |
      | contentStreamIdentifier       | "cs-identifier"                                                                                                            |
      | nodeAggregateIdentifier       | "invalid-shortcut-selected-node"                                                                                           |
      | nodeTypeName                  | "Neos.Neos:Shortcut"                                                                                                       |
      | originDimensionSpacePoint     | {}                                                                                                                         |
      | parentNodeAggregateIdentifier | "shortcuts"                                                                                                                |
      | initialPropertyValues         | {"uriPathSegment": "invalid-shortcut-selected-node", "targetMode": "selectedTarget", "target": "node://non-existing-node"} |
      | nodeName                      | "some-node-name"                                                                                                           |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "invalid-shortcut-selected-node" in content stream "cs-identifier" and dimension "{}" should throw an exception

  Scenario: Shortcut node with targetMode "selectedTarget" and a empty target node
    Given the command CreateNodeAggregateWithNode is executed with payload and exceptions are caught:
      | Key                           | Value                                                                                                     |
      | contentStreamIdentifier       | "cs-identifier"                                                                                           |
      | nodeAggregateIdentifier       | "invalid-shortcut-selected-node"                                                                          |
      | nodeTypeName                  | "Neos.Neos:Shortcut"                                                                                      |
      | originDimensionSpacePoint     | {}                                                                                                        |
      | parentNodeAggregateIdentifier | "shortcuts"                                                                                               |
      | initialPropertyValues         | {"uriPathSegment": "invalid-shortcut-selected-node", "targetMode": "selectedTarget", "target": "node://"} |
      | nodeName                      | "some-node-name"                                                                                          |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "invalid-shortcut-selected-node" in content stream "cs-identifier" and dimension "{}" should throw an exception

  Scenario: Recursive shortcuts
    Given the following CreateNodeAggregateWithNode commands are executed for content stream "cs-identifier" and origin "{}":
      | nodeAggregateIdentifier | parentNodeAggregateIdentifier | nodeTypeName       | initialPropertyValues                                                                                      | nodeName |
      | level-1                 | shortcuts                     | Neos.Neos:Shortcut | {"uriPathSegment": "level1", "targetMode": "selectedTarget", "target": "node://level-2"}                   | level1   |
      | level-2                 | shortcuts                     | Neos.Neos:Shortcut | {"uriPathSegment": "level2", "targetMode": "selectedTarget", "target": "node://shortcut-first-child-node"} | level2   |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then the node "level-1" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/first-child-node.html"
    Then the node "level-2" in content stream "cs-identifier" and dimension "{}" should resolve to URL "/david-nodenborough/shortcuts/shortcut-first-child/first-child-node.html"

  Scenario: Unlimited recursive shortcuts
    Given the following CreateNodeAggregateWithNode commands are executed for content stream "cs-identifier" and origin "{}":
      | nodeAggregateIdentifier | parentNodeAggregateIdentifier | nodeTypeName       | initialPropertyValues                                                              | nodeName |
      | node-a                  | shortcuts                     | Neos.Neos:Shortcut | {"uriPathSegment": "a", "targetMode": "selectedTarget", "target": "node://node-b"} | node-a   |
      | node-b                  | shortcuts                     | Neos.Neos:Shortcut | {"uriPathSegment": "b", "targetMode": "selectedTarget", "target": "node://node-a"} | node-b   |
    And The documenturipath projection is up to date
    When I am on URL "/"
    Then trying to resolve node "node-a" in content stream "cs-identifier" and dimension "{}" should throw an exception
