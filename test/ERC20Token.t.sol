// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    USDX public usdt;
    ERC20Receiver public erc20receiver;
    address public usdtAddr;
    address public receiverAddr;
    address public ctrtOwner;
    address public tokenOwner;
    address public tis = address(this);
    address public bob = address(2);
    address public charlie = address(3);
    uint8 public decimals;
    uint256 public balc;
    uint256 public tokenAmount = 1000;
    uint256 public receivedAmount = 0;
    bytes4 public b4;

    receive() external payable {
        console.log("ETH received from:", msg.sender);
        console.log("ETH received in Szabo:", msg.value / 1e12);
    }

    event TokenReceived(address indexed from, uint256 indexed amount, bytes data);

    bytes4 private constant _ERC20_RECEIVED = 0x8943ec02;
    // Equals to `bytes4(keccak256(abi.encodePacked("tokenReceived(address,uint256,bytes)")))`
    // OR IERC20Receiver.tokenReceived.selector

    function tokenReceived(address from, uint256 amount, bytes calldata data) external returns (bytes4) {
        console.log("tokenReceived");
        emit TokenReceived(from, amount, data);
        return _ERC20_RECEIVED;
    }

    function setUp() public {
        usdt = new USDX("Tether", "USDT");
        usdtAddr = address(usdt);
        console.log("usdtAddr:", usdtAddr);
        ctrtOwner = usdt.owner();
        assertEq(ctrtOwner, tis);
        balc = usdt.balanceOf(tis);
        console.log("tis balc:", balc);
        decimals = usdt.decimals();
        console.log("decimals:", decimals);
        assertEq(decimals, 6);

        erc20receiver = new ERC20Receiver();
        receiverAddr = address(erc20receiver);
        console.log("receiverAddr:", receiverAddr);
        console.log("setup successful");
    }

    function testTokenReceiver() public {
        tokenAmount = 1000;
        usdt.approve(receiverAddr, tokenAmount * 2);
        erc20receiver.deposit(usdtAddr, tokenAmount);
        balc = usdt.balanceOf(receiverAddr);
        console.log("receiverAddr balc:", balc);
        assertEq(balc, tokenAmount);

        tokenAmount = 250;
        erc20receiver.withdraw(usdtAddr, charlie, tokenAmount);
        balc = usdt.balanceOf(charlie);
        console.log("charlie balc:", balc);
        assertEq(balc, tokenAmount);
    }

    function testMint() public {
        tokenAmount = 1000;
        decimals = usdt.decimals();
        console.log("decimals:", decimals);

        //Non owner should not mint
        vm.prank(charlie);
        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, charlie));
        usdt.mint(bob, tokenAmount);

        //Owner(this contract) can mint
        usdt.mint(bob, tokenAmount);
        receivedAmount = usdt.balanceOf(bob);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, tokenAmount);

        //guest can mint 100 tokens
        vm.prank(charlie);
        usdt.mintToGuest();
        receivedAmount = usdt.balanceOf(charlie);
        console.log("receivedAmount:", receivedAmount);
        assertEq(receivedAmount, 100 * 10 ** decimals);
    }
}
