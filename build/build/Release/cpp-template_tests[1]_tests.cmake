add_test([=[MathTest.BasicAssertion]=]  /home/alissoneves/cpp-template/build/build/Release/cpp-template_tests [==[--gtest_filter=MathTest.BasicAssertion]==] --gtest_also_run_disabled_tests)
set_tests_properties([=[MathTest.BasicAssertion]=]  PROPERTIES WORKING_DIRECTORY /home/alissoneves/cpp-template/build/build/Release SKIP_REGULAR_EXPRESSION [==[\[  SKIPPED \]]==])
set(  cpp-template_tests_TESTS MathTest.BasicAssertion)
