// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import { Script, console } from "forge-std/Script.sol";
import { Counter } from "../src/Counter.sol";

// contract name below must be $Filename+Script
contract CounterScript is Script {
  Counter public counter;
  address alice;
  address bob;

  function setUp() public {
    //Label addresses for easier debugging
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    //vm.label(address(token), "Token");
    //vm.label(address(pool), "Pool");
  }

  //run() must exists
  function run() public {
    vm.startBroadcast();
    //vm.startBroadcast(deployerAddress);
    //OR
    //uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    //vm.startBroadcast(deployerPrivateKey);

    counter = new Counter();
    //counter.setNumber(42);

    vm.stopBroadcast();
  }
}
/*// Read environment variables
string memory rpcUrl = vm.envString("RPC_URL");
uint256 privateKey = vm.envUint("PRIVATE_KEY");

// Read/write files
string memory config = vm.readFile("config.json");
vm.writeFile("output.txt", "deployed");

// Parse JSON
address addr = vm.parseJsonAddress(json, ".address");

// Console logging
console.log("Deploying to:", block.chainid);
*/
