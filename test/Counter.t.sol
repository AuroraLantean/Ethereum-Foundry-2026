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

    //Constrainted inputs
    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 1, 1000 ether);
        //vm.assume(amount > 0 && amount <= 1000 ether);
    }

    function test_RevertWhen_Unauthorized() public {
        //vm.expectRevert("Not authorized");
        //counter.should_revert();
        //OR
        //vm.expectRevert(Token.InsufficientBalance.selector);
        //token.transfer(address(0), 1000);
    }

    //test events
    function test_EmitsTransfer() public {
        //vm.expectEmit(true, true, false, true); //the four booleans specify which topics and data to check.
        //emit Transfer(alice, bob, 100);
        //token.transfer(bob, 100);
    }

    //test time
    function test_timeTravel() public {
        /*// Set block timestamp
        vm.warp(1700000000);

        // Set block number
        vm.roll(18000000);

        // Impersonate an address
        vm.prank(alice);
        contract.doSomething();

        // Give ETH to an address
        vm.deal(alice, 100 ether);

        // Modify storage
        vm.store(address(token), bytes32(0), bytes32(uint256(1000))); */
    }
}
