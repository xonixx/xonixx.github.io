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
        Arguments.of("1 + 3", 4), // tests addition
        Arguments.of("10 - 6", 4),// tests subtraction 
        Arguments.of("12 / 3", 4),// tests division
        Arguments.of("2 * 2", 4)  // tests multiplication
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

Surprisingly, the less-clever second variant also has some advantages:

- It's conceptually simpler, less framework magic involved (JUnit engine).

- It's less straightforward (although, of course, possible) to run a single test case with parameterized test.
  
- It's more IDE-friendly (therefore, maintainable, comprehensible).

Compare this (notice, how IDE helps with the meaning of arguments):

![](param_tests1.png)

to this (not much help):

![](param_tests2.png)

If this is not convincing enough, here is an example from a real project:

![](param_tests3.png)

☝ Good luck matching to test parameters!





