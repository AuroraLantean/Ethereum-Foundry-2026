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

contract DeployScript is Script {
  //address public tis = address(this);
  address alice;
  address bob;
  //keep variables here to reduce stack variables
  address deployer;
  address adam;
  address usdxAddr;
  address nftAddr;
  uint256 balcBf;
  uint256 minNftId = 0;
  uint256 maxNftId = 9;

  uint256[] public pricesEth;
  uint256[] public pricesTok;
  /*For Arbitrum, convert some ETH into Arbitrum ETH: https://bridge.arbitrum.io/?l2ChainId=421613 https://goerli.arbiscan.io */
  address walletPbk0 = vm.envAddress("WALLET_PBK0");

  function setUp() public {
    alice = makeAddr("alice");
    bob = makeAddr("bob");
    //vm.label(address(token), "Token");
    //vm.label(address(pool), "Pool");
    console.log("walletPbk0:", walletPbk0);
  }

  //run() must exists
  function run(
    uint256 scenario
  ) public {
    console.log("run(). scenario:", scenario);
    uint256 pkey0 = vm.envUint("ANVIL0_PRIVATE_KEY");
    deployer = vm.rememberKey(pkey0);
    console.log("deployer:", deployer);

    uint256 pkey1 = vm.envUint("ANVIL1_PRIVATE_KEY");
    adam = vm.rememberKey(pkey1);
    console.log("deployer:", deployer);

    vm.startBroadcast(deployer);
    balcBf = address(deployer).balance;
    console.log("deployer balc:", balcBf);

    if (scenario == 0) {
      console.log("deploy GoldCoin");
      ERC20Token goldtoken = new ERC20Token("GoldCoin", "GOLC");
      console.log("GoldCoin addr:", address(goldtoken));
      balcBf = goldtoken.balanceOf(deployer);
      console.log("deployer GoldCoin balc:", balcBf, balcBf / 1e18);
    } else if (scenario == 1) {
      console.log("deploy ERC721 as dragons");
      ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG", minNftId, maxNftId);
      nftAddr = address(dragons);
      balcBf = dragons.balanceOf(deployer);
      console.log("deployer NFT balc:", balcBf);
    } else if (scenario == 2) {
      console.log("deploy USDX as USDT");
      USDX usdt = new USDX("TetherUSD", "USDT");
      usdxAddr = address(usdt);
      console.log("USDT addr:", usdxAddr);
      balcBf = usdt.balanceOf(deployer);
      console.log("deployer USDT balc:", balcBf, balcBf / 1e6);
    } else if (scenario == 3) {
      console.log("deploy ArrayOfStructs");
      ArrayOfStructs ctrt = new ArrayOfStructs(100);
      address ctrtAddr = address(ctrt);
      console.log("arrayOfStructsJSON addr:", ctrtAddr);
    } else if (scenario == 4) {
      console.log("nothing");
    } else if (scenario == 5) {
      console.log("deploy USDX, ERC721, and NftSales...");
      balcBf = deployer.balance;
      console.log("deployer:", deployer);
      console.log("deployer ETH balc:", balcBf, balcBf / 1e18);

      USDX usdt = new USDX("TetherUSD", "USDT");
      usdxAddr = address(usdt);
      console.log("USDT addr:", usdxAddr);
      balcBf = usdt.balanceOf(deployer);
      console.log("deployer USDT balc:", balcBf, balcBf / 1e6);

      ERC721Token dragons = new ERC721Token("DragonsNFT", "DRAG", minNftId, maxNftId);
      nftAddr = address(dragons);
      console.log("DragonsNFT addr:", nftAddr);
      balcBf = dragons.balanceOf(deployer);
      console.log("deployer NFT balc:", balcBf);

      dragons.setBaseURI("https://abc.com/");
      console.log("baseURI: ", dragons.baseURI());
      console.log("token0 URI: ", dragons.tokenURI(minNftId));

      ERC721Sales sales = new ERC721Sales(usdxAddr);
      address salesAddr = address(sales);
      console.log("Sales addr:", salesAddr);

      uint256[] memory out = sales.getBalances(usdxAddr, nftAddr);
      console.log("getBalances() from deployer: [sender ETH Balc, Token balc and decimal]...");
      console.log(out[0], out[1], out[2]);
      /* 0: uint256[]: out 9999975238569100584676,9000000000000000,10,0,0,0,6 */

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
      sales.setPriceBatch(nftAddr, minNftId, maxNftId, true, pricesEth);

      console.log("setPriceBatch Token");
      sales.setPriceBatch(nftAddr, minNftId, maxNftId, false, pricesTok);

      console.log("Show prices in ETH and Token");
      for (uint256 i = minNftId; i <= maxNftId; i++) {
        (uint256 priceEth, uint256 priceTok) = sales.prices(nftAddr, i);
        console.log(priceEth, priceTok);
      }
      //uint256 priceInWeiEth = 1e15;
      //uint256 tokenDp = 1e6;
      //uint256 priceInWeiToken = 100 * 1e6;

      //nftBalc = dragons.balanceOf(tis);
      //console.log("tis nftBalc:", nftBalc);
      console.log("deployer=", deployer);
      console.log("USDT_ADDR=", usdxAddr);
      console.log("DRAGONS_ADDR=", nftAddr);
      console.log("SALES_ADDR=", salesAddr);

      console.log("");
      payable(walletPbk0).transfer(1 ether);
      balcBf = address(walletPbk0).balance;
      console.log("walletPbk0 balc:", balcBf, balcBf / 1e18);
      usdt.transfer(walletPbk0, 999e6);
      balcBf = usdt.balanceOf(walletPbk0);
      console.log("walletPbk0 USDT balc:", balcBf, balcBf / 1e6);

      console.log("adam:", adam);
      usdt.transfer(adam, 9001e6);
      balcBf = usdt.balanceOf(adam);
      console.log("adam USDT balc:", balcBf, balcBf / 1e6);

      console.log("");
      console.log("copy and paste below to deployAddrRaw.txt, then run 'just abiExtract'");
      console.log("{##Deployer##:#", deployer, "#");
      console.log("##USDT_ADDR##:#", usdxAddr, "#");
      console.log("##DRAGONS_ADDR##:#", nftAddr, "#");
      console.log("##SALES_ADDR##:#", salesAddr, "#}");
    }
    vm.stopBroadcast();
  }
}
