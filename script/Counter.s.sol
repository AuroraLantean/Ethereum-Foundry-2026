// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;
/**
 * First, it collects all transactions from the script, and only then does it broadcast them all. It can essentially be split into 4 phases:
 * #1 Local Simulation - The contract script is run in a local evm. If a rpc/fork url has been provided, it will execute the script in that context. Any external call (not static, not internal) from a vm.broadcast and/or vm.startBroadcast will be appended to a list.
 *
 * #2 Onchain Simulation - Optional. If a rpc/fork url has been provided, then it will sequentially execute all the collected transactions from the previous phase here.
 *
 * #3 Broadcasting - Optional. If the --broadcast flag is provided and the previous phases have succeeded, it will broadcast the transactions collected at step 1. and simulated at step 2.
 *
 * #4 Verification - Optional. If the --verify flag is provided, there's an API key, and the previous phases have succeeded it will attempt to verify the contract. (eg. etherscan).
 *
 * # Supported RPC Methods
 *   https://book.getfoundry.sh/reference/anvil/
 */

import "forge-std/Script.sol";
import { Counter } from "../src/Counter.sol";

// contract name below must be $Filename+Script
contract CounterScript is Script {
  //address public tis = address(this);
  Counter public counter;
  address alice;
  address bob;
  //keep variables here to reduce stack variables
  uint256 number = 0;
  //bool bool1 = false;
  //uint256 zGenBf;
  //uint256 zGenAf;

  function setUp() public {
    //Label addresses for easier debugging
    alice = makeAddr("alice");
    bob = makeAddr("bob");

    //vm.label(address(token), "Token");
    //vm.label(address(pool), "Pool");
  }

  //run() must exists
  function run(
    uint256 scenario
  ) public {
    console.log("run(). scenario:", scenario);
    //uint256 pkey = vm.envUint("PRIVATE_KEY");
    uint256 pkey = vm.envUint("ANVIL0_PRIVATE_KEY");
    address deployer = vm.rememberKey(pkey);
    console.log("deployer:", deployer);

    vm.startBroadcast(deployer); //or prvkey
    uint256 balc = address(deployer).balance;
    console.log("deployer balc:", balc);

    if (scenario == 0) {
      // deploy a contract
      counter = new Counter(); //(arg1, arg2, ..)
      console.log("Counter:", address(counter));
      number = counter.number();
      console.log("number:", number);
      counter.setNumber(42);
      number = counter.number();
      console.log("number:", number);
    } else if (scenario == 1) {
      // use a deployed contract
      counter = Counter(0x5FbDB2315678afecb367f032d93F642f64180aa3);
      number = counter.number();
      console.log("number:", number);
    }
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
