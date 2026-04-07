// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import "forge-std/Script.sol";
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

import "src/ERC20Token.sol";
import "src/ERC721Token.sol";
import "src/ERC721Sales.sol";

contract DeploySepoliaScript is Script {
  //address public tis = address(this);
  address alice;
  address bob;
  //keep variables here to reduce stack variables
  address deployer;
  //address adam;
  address usdxAddr = address(0x24872ab3CEeC9dFb24C173F3230Bc1171d98EB3b);
  address dragonsAddr = address(0x5E35Da01DA78E57e91e5013373aaC053b2463846);
  address salesAddr = address(0xaB202C6d7494aD14562e9117d33E835C5612c6dD);
  uint256 balcBf;
  uint256 minNftId = 0;
  uint256 maxNftId = 9;

  uint256[] public pricesEth;
  uint256[] public pricesTok;
  /*For Arbitrum, convert some ETH into Arbitrum ETH: https://bridge.arbitrum.io/?l2ChainId=421613 https://goerli.arbiscan.io */
  //address walletPbk0 = vm.envAddress("WALLET_PBK0");

  function setUp() public {
    //alice = makeAddr("alice");
    //bob = makeAddr("bob");
    //vm.label(address(token), "Token");
  }

  //run() must exists
  function run(
    uint256 scenario
  ) public {
    console.log("run(). scenario:", scenario);

    deployer = msg.sender; //vm.rememberKey(pkey0); set by --sender sender if it exists
    console.log("deployer:", deployer);
    balcBf = deployer.balance;
    console.log("deployer ETH balc:", balcBf, balcBf / 1e18);

    //uint256 pkey1 = vm.envUint("ANVIL1_PRIVATE_KEY");
    //adam = vm.rememberKey(pkey1);

    vm.startBroadcast();
    balcBf = address(deployer).balance;
    console.log("deployer balc:", balcBf);

    if (scenario == 0) {
      console.log("nothing to deploy");
    } else if (scenario == 10) {
      console.log("deploy USDX as USDT");
      USDX usdt = new USDX("TetherUSD", "USDT");
      usdxAddr = address(usdt);
      console.log("USDT addr:", usdxAddr);
      balcBf = usdt.balanceOf(deployer);
      console.log("deployer USDT balc:", balcBf, balcBf / 1e6);
    } else if (scenario == 11) {
      console.log("deploy ERC721 as dragons");
      ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG", minNftId, maxNftId);
      dragonsAddr = address(dragons);
      balcBf = dragons.balanceOf(deployer);
      console.log("deployer NFT balc:", balcBf);
    } else if (scenario == 12) {
      ERC721Sales sales = new ERC721Sales(usdxAddr);
      salesAddr = address(sales);
      console.log("Sales addr:", salesAddr);

      uint256[] memory out = sales.getBalances(usdxAddr, dragonsAddr);
      console.log("getBalances() from deployer: sender ETH and Token balc, decimal");
      console.log(out[0], out[1], out[2]);
    } else if (scenario == 21) {
      //just set-sepolia 21
      ERC721Token dragons = ERC721Token(dragonsAddr);
      console.log("baseURI: ", dragons.baseURI());
      dragons.setBaseURI("https://abc.com/");
      console.log("baseURI: ", dragons.baseURI());
      console.log("token0 URI: ", dragons.tokenURI(minNftId));
    } else if (scenario == 22) {
      ERC721Sales sales = ERC721Sales(payable(salesAddr));
      ERC721Token dragons = ERC721Token(dragonsAddr);
      dragons.safeApproveBatch(salesAddr, minNftId, maxNftId);
      console.log("safeApproveBatch done");

      /*address[] memory nftOwners = dragons.ownerOfBatch(minNftId, maxNftId);

      address[] memory approvedAddrs = dragons.getApprovedBatch(minNftId, maxNftId);

      for (uint256 i = minNftId; i <= maxNftId; i++) {
      console.log("id = %s, is salesCtrt approved: %s", i, salesAddr == approvedAddrs[i]);
      console.log("is Owner == Deployer: %s", nftOwners[i] == deployer);
      }*/
      for (uint256 i = minNftId; i <= maxNftId; i++) {
        pricesEth.push((10 + i) * 1e14);
        pricesTok.push((100 + i) * 1e6);
      }
      console.log("setPriceBatch ETH");
      sales.setPriceBatch(dragonsAddr, minNftId, maxNftId, true, pricesEth);

      console.log("setPriceBatch Token");
      sales.setPriceBatch(dragonsAddr, minNftId, maxNftId, false, pricesTok);

      console.log("Show prices in ETH and Token");
      for (uint256 i = minNftId; i <= maxNftId; i++) {
        (uint256 priceEth, uint256 priceTok) = sales.prices(dragonsAddr, i);
        console.log(priceEth, priceTok);
      }
    }
    vm.stopBroadcast();
  }
}
