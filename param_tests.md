---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# You might not need parameterized tests

_March 2025_

Let's consider an example of a typical JUnit parameterized test:

```java
public class CalculatorTests {
  @ParameterizedTest(name = "{0} should give {1}")
  @MethodSource("calculatorTestScenarios")
  void testCalculator(String expression, int expectedResult) {
    // usually a real test scenario is much longer than one line
    // and consists of GIVEN/WHEN/THEN sections
    assertEquals(expectedResult, Calculator.calculate(expression));
  }

  static Stream<Arguments> calculatorTestScenarios() {
    return Stream.of(
        Arguments.of("1 + 3", 4), // test addition
        Arguments.of("10 - 6", 4),// test subtraction 
        Arguments.of("12 / 3", 4),// test division
        Arguments.of("2 * 2", 4)  // test multiplication
    );
  }
}

// Application under test
class Calculator {
  public static int calculate(String expression) {
    return 4; // TODO implement
  }
}
```

Conceptually this is almost identical to writing the tests without parameterization:

```java
public class CalculatorTests {
  void testCalculation(String expression, int expectedResult) {
    // usually a real test scenario is much longer than one line
    // and consists of GIVEN/WHEN/THEN sections
    assertEquals(expectedResult, Calculator.calculate(expression));
  }
  @Test
  void testAddition()       { testCalculation("1 + 3", 4); }
  @Test
  void testSubtraction()    { testCalculation("10 - 6", 4); }
  @Test
  void testDivision()       { testCalculation("12 / 3", 4); }
  @Test
  void testMultiplication() { testCalculation("2 * 2", 4); }
}
```




