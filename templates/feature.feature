# /features/<capability>.feature
# Feature file: scenarios for the named capability.
# Every scenario carries `# AC: AC-N` reference(s) pointing to the capability spec's acceptance criteria.

@<capability> @<area> @<criticality>
Feature: <Capability name>

  As a <actor>
  I want <capability>
  So that <value>

  # Background applies to all scenarios in this file
  Background:
    Given <preconditions common to all scenarios>

  # AC: AC-1
  @inc-NNN @phase-NN
  Scenario: <happy-path scenario name>
    Given <state>
    When <action>
    Then <outcome>

  # AC: AC-2
  @inc-NNN @phase-NN
  Scenario: <another scenario name>
    Given <state>
    When <action>
    Then <outcome>

  # AC: AC-1, AC-3
  @inc-NNN @phase-NN @security-critical
  Scenario: <security-critical scenario>
    # Security-critical scenarios require companion negative-case scenarios
    # (input validation failures, authz failures) per testing-standards.md.
    Given <state>
    When <legitimate action>
    Then <expected outcome>

  # AC: AC-1
  @inc-NNN @phase-NN @security-critical @negative
  Scenario: <negative case for the security-critical scenario>
    Given <state>
    When <malformed input | unauthorized actor>
    Then <validation failure | authz denial>
    And <expected error or rejection behavior>

# Notes on tagging:
# - Every scenario added in an increment is tagged @inc-NNN (for ui-test-engineer to filter).
# - Every scenario is tagged @phase-NN (for phase-close consolidation).
# - Security-critical scenarios (capabilities classified >= confidential, or trust-boundary-crossing) tagged @security-critical.
# - Negative-case scenarios for security-critical happy paths tagged @negative @security-critical.
# - Criticality tags (@<criticality>) determine regression frequency per testing-standards.md.
