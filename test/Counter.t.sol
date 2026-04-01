// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/*
Test files end with .t.sol
Test contracts inherit from forge-std/Test.sol
Test functions start with test_ or test
setUp() runs before each test
*/
contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
